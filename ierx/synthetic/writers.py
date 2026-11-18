"""Write a synthetic fixture as load files, matcher extracts and evaluation files.

Layout under the output folder::

    load/        MariaDB seeds per CBS tenant and the tenant store, PostgreSQL seed for IMS
    extracts/    CSV copies of the loaded rows plus the scope map (safe matcher input)
    evaluation/  truth manifest, mutation log, scenario list, run metadata (never matcher input)
    invalid/     inputs that must be rejected or quarantined, with their own manifest
"""

from __future__ import annotations

from collections import Counter
import csv
from datetime import date
import hashlib
import json
from pathlib import Path
from typing import Any

from ierx.synthetic.generator import (
    GENERATOR_VERSION,
    REVIEW,
    SCENARIOS,
    SCOPES,
    Fixture,
    Row,
)

NULL = r"\N"  # NULL marker in CSV files, as in MariaDB and PostgreSQL text dumps

CBS_COLUMNS = {
    "m_office": ["id", "parent_id", "hierarchy", "external_id", "name", "opening_date"],
    "m_code": ["id", "code_name", "is_system_defined"],
    "m_code_value": [
        "id", "code_id", "code_value", "code_description", "order_position", "is_active",
        "is_mandatory",
    ],
    "m_client": [
        "id", "account_no", "external_id", "status_enum", "activation_date", "office_id",
        "firstname", "middlename", "lastname", "fullname", "display_name", "mobile_no",
        "date_of_birth", "submittedon_date", "legal_form_enum", "email_address",
    ],
    "m_client_identifier": [
        "id", "client_id", "document_type_id", "document_key", "status", "active",
    ],
}  # fmt: skip
IMS_COLUMNS = {
    "administration_country": ["id", "country", "countrycode"],
    "mel_mifosoffices": ["id", "mifos_pk", "name", "name_decorated", "parent_id", "external_id"],
    "mel_client": [
        "id", "flag", "uid", "id_no", "client_names", "fname", "mname", "lname", "dateofbirth",
        "phone1", "phone2", "country_id", "date_of_survey",
    ],
    "mel_duediligence": [
        "id", "client_id", "client_names", "mifos_uid_external", "mifos_demo_graphics_pk",
        "first_name", "last_name", "mifos_entity_full_names", "mifos_dob", "cd_date_of_birth",
        "mifos_phone", "phone_number", "office_mifos_id_id", "mifos_national_id",
        "mifos_passport_no", "date_of_survey", "is_draft_data", "mifos_client_activation_status",
        "mifos_is_biz_registered", "submit_to_cbs", "client_demo_graphics_cbs_status",
        "client_other_info_cbs_status", "entity_other_info_cbs_status",
        "business_info_cbs_status", "recruitment_surv_cbs_status", "loan_app_cbs_status",
        "cash_flow_cbs_status", "balance_sheet_cbs_status", "projection_rate_cbs_status",
        "next_of_kin", "loan_documents",
    ],
    "due_diligence_demographics": [
        "id", "client_names", "mifos_uid_external", "mifos_demo_graphics_pk", "first_name",
        "last_name", "mifos_entity_full_names", "mifos_dob", "cd_date_of_birth", "mifos_phone",
        "mifos_altenative_phone", "phone_number", "office_mifos_id_id", "date_of_survey",
        "mifos_client_activation_status", "mifos_is_biz_registered", "submit_to_cbs",
        "client_demo_graphics_cbs_status", "next_of_kin",
    ],
}  # fmt: skip
# Parents first, so foreign keys hold row by row.
CBS_ORDER = ["m_office", "m_code", "m_code_value", "m_client", "m_client_identifier"]
IMS_ORDER = [
    "administration_country",
    "mel_mifosoffices",
    "mel_client",
    "mel_duediligence",
    "due_diligence_demographics",
]
MANIFEST_COLUMNS = [
    "row_key", "source_system", "source_table", "source_scope", "source_row_id",
    "truth_entity_id", "truth_tenant_scope", "scenario_id", "case", "variant",
    "expected_outcome", "expected_cbs_scope", "expected_cbs_client_id", "note",
]  # fmt: skip
MARIADB_MODE = (
    "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,"
    "NO_ENGINE_SUBSTITUTION"
)
BANNER = "-- Synthetic fixture data only. Every person, phone and document here is invented."


def _maria(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "b'1'" if value else "b'0'"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, date):
        return f"'{value.isoformat()}'"
    text = str(value).replace("\\", "\\\\").replace("'", "''")
    return f"'{text}'"


def _pg(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, date):
        return f"'{value.isoformat()}'"
    return "'" + str(value).replace("'", "''") + "'"


def _csv_value(value: Any) -> str:
    if value is None:
        return NULL
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, date):
        return value.isoformat()
    return str(value)


def _inserts(table: str, columns: list[str], rows: list[Row], dialect: str) -> list[str]:
    lit = _maria if dialect == "mariadb" else _pg
    name = f"`{table}`" if dialect == "mariadb" else f'ims."{table}"'
    quote = (lambda c: f"`{c}`") if dialect == "mariadb" else (lambda c: f'"{c}"')
    head = f"INSERT INTO {name} ({', '.join(quote(c) for c in columns)}) VALUES"
    out = []
    for start in range(0, len(rows), 100):
        end = start + 100
        chunk = rows[start:end]
        values = ",\n".join(
            "  (" + ", ".join(lit(r.values.get(c)) for c in columns) + ")" for r in chunk
        )
        out.append(f"{head}\n{values};")
    return out


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def _write_csv(path: Path, header: list[str], rows: list[list[Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(header)
        writer.writerows([_csv_value(v) for v in row] for row in rows)


def _cbs_seed(fx: Fixture, tenant: str, database: str, people: int) -> str:
    lines = [
        BANNER,
        f"-- CBS tenant {tenant}. Load into an empty {database} after cbs.tenant.mariadb.sql.",
        f"-- Generator {GENERATOR_VERSION}, seed {fx.seed}, {people} people.",
        "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;",
        f"SET SESSION sql_mode = '{MARIADB_MODE}';",
        "SET SESSION foreign_key_checks = 1;",
        "SET SESSION unique_checks = 1;",
        "START TRANSACTION;",
    ]
    for table in CBS_ORDER:
        lines += _inserts(table, CBS_COLUMNS[table], fx.table("cbs", tenant, table), "mariadb")
    lines.append("COMMIT;")
    return "\n".join(lines) + "\n"


def _tenant_store_seed(fx: Fixture) -> str:
    lines = [
        BANNER,
        "-- CBS tenant registry. Load into an empty cbs_tenant_store_dq after",
        "-- cbs.tenant-store.mariadb.sql. Connection settings keep the schema defaults.",
        "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;",
        f"SET SESSION sql_mode = '{MARIADB_MODE}';",
        "START TRANSACTION;",
        "INSERT INTO `tenant_server_connections` (`id`, `schema_name`) VALUES",
        ",\n".join(f"  ({i}, '{s.database}')" for i, s in enumerate(SCOPES, start=1)) + ";",
        "INSERT INTO `tenants` (`id`, `identifier`, `name`, `timezone_id`, `oltp_id`, "
        "`report_id`) VALUES",
        ",\n".join(
            f"  ({i}, '{s.key}', '{s.label}', 'UTC', {i}, {i})"
            for i, s in enumerate(SCOPES, start=1)
        )
        + ";",
        "COMMIT;",
    ]
    return "\n".join(lines) + "\n"


def _ims_seed(fx: Fixture, people: int) -> str:
    lines = [
        BANNER,
        "-- IMS. Load into a database where ims.postgresql.sql has created the ims schema.",
        f"-- Generator {GENERATOR_VERSION}, seed {fx.seed}, {people} people.",
        "BEGIN;",
        "SET CONSTRAINTS ALL IMMEDIATE;",
    ]
    for table in IMS_ORDER:
        lines += _inserts(table, IMS_COLUMNS[table], fx.table("ims", "ims", table), "postgresql")
    lines.append("-- Move each identity sequence past the explicit IDs loaded above.")
    lines.append("DO $$")
    lines.append("BEGIN")
    for table in IMS_ORDER:
        lines.append(
            f"  PERFORM setval(pg_get_serial_sequence('ims.{table}', 'id'), "
            f'(SELECT max("id") FROM ims."{table}"));'
        )
    lines += ["END", "$$;", "COMMIT;"]
    return "\n".join(lines) + "\n"


def _extracts(fx: Fixture, root: Path) -> None:
    for table in CBS_ORDER:
        columns = CBS_COLUMNS[table]
        rows = [
            [scope.key] + [r.values.get(c) for c in columns]
            for scope in SCOPES
            for r in fx.table("cbs", scope.key, table)
        ]
        _write_csv(root / f"cbs_{table}.csv", ["tenant_scope"] + columns, rows)
    for table in IMS_ORDER:
        columns = IMS_COLUMNS[table]
        rows = [[r.values.get(c) for c in columns] for r in fx.table("ims", "ims", table)]
        _write_csv(root / f"ims_{table}.csv", columns, rows)
    scope_rows: list[list[Any]] = []
    for scope in SCOPES:
        scope_rows.append(
            ["tenant", "", "", scope.key, scope.database, "", scope.country_code,
             scope.calling_code, "0"]
        )  # fmt: skip
    for r in fx.table("ims", "ims", "administration_country"):
        tenant = r.truth_tenant
        scope_rows.append(
            ["ims_country", "administration_country", r.id, tenant, "", "",
             r.values["countrycode"], "", ""]
        )  # fmt: skip
    for r in fx.table("ims", "ims", "mel_mifosoffices"):
        scope_rows.append(
            ["ims_office", "mel_mifosoffices", r.id, r.truth_tenant, "", r.values["mifos_pk"],
             "", "", ""]
        )  # fmt: skip
    _write_csv(
        root / "scope_map.csv",
        [
            "kind", "ims_table", "ims_id", "tenant_scope", "cbs_database", "cbs_office_id",
            "country_code", "calling_code", "national_trunk_prefix",
        ],
        scope_rows,
    )  # fmt: skip


def _manifest(fx: Fixture) -> list[list[Any]]:
    ordered = sorted(
        fx.rows,
        key=lambda r: (r.system, r.scope, CBS_ORDER.index(r.table) if r.system == "cbs"
                       else IMS_ORDER.index(r.table), r.id),
    )  # fmt: skip
    out = []
    for r in ordered:
        cbs = r.counterpart
        case = SCENARIOS[r.scenario][0] if r.scenario in SCENARIOS else "reference_data"
        out.append(
            [
                r.key, r.system, r.table, r.scope, r.id, r.entity_id, r.truth_tenant,
                r.scenario, case, r.variant, r.outcome, cbs.scope if cbs else None,
                cbs.id if cbs else None, r.note or None,
            ]
        )  # fmt: skip
    return out


def _metadata(fx: Fixture, people: int, root: Path) -> dict[str, Any]:
    rows_by_table = Counter(f"{r.system}.{r.scope}.{r.table}" for r in fx.rows)
    by_scenario: dict[str, dict[str, Any]] = {}
    for p in fx.people:
        entry = by_scenario.setdefault(p.scenario, {"people": 0, "rows": Counter()})
        entry["people"] += 1
    for r in fx.rows:
        if r.scenario in SCENARIOS:
            by_scenario[r.scenario]["rows"][f"{r.system}.{r.table}"] += 1
    outcomes = Counter(f"{r.system}.{r.table}:{r.outcome}" for r in fx.rows)
    return {
        "generator": "ierx.synthetic",
        "generator_version": GENERATOR_VERSION,
        "seed": fx.seed,
        "people": people,
        "brief": "docs/schemas/SYNTHETIC_CUSTOMER_MATCHING.md",
        "scopes": [
            {
                "tenant_scope": s.key,
                "cbs_database": s.database,
                "country": s.country,
                "country_code": s.country_code,
                "calling_code": s.calling_code,
            }
            for s in SCOPES
        ],
        "row_counts": dict(sorted(rows_by_table.items())),
        "scenarios": {
            sid: {
                "case": SCENARIOS[sid][0],
                "people": by_scenario[sid]["people"],
                "rows": dict(sorted(by_scenario[sid]["rows"].items())),
            }
            for sid in sorted(by_scenario)
        },
        "expected_outcomes": dict(sorted(outcomes.items())),
        "review_rows": sum(1 for r in fx.rows if r.outcome == REVIEW),
        "invalid_fixtures": [
            {
                "fixture_id": i.fixture_id,
                "engine": i.engine,
                "expected_outcome": i.expected_outcome,
            }
            for i in fx.invalid
        ],
        "files_sha256": {
            str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(root.rglob("*"))
            if p.is_file() and p.name != "run_metadata.json"
        },
    }


def _invalid(fx: Fixture, root: Path) -> None:
    rows = []
    for inv in fx.invalid:
        if inv.engine == "raw_csv":
            name = f"{inv.fixture_id}_cbs_tenant_a_m_client_raw.csv"
            header = list(inv.raw_rows[0])
            _write_csv(root / name, header, [[r[c] for c in header] for r in inv.raw_rows])
        else:
            ext = "mariadb.sql" if inv.engine == "mariadb" else "postgresql.sql"
            name = f"{inv.fixture_id}.{ext}"
            if inv.engine == "mariadb":
                body = [
                    f"-- {inv.fixture_id}: {inv.description}. Expected: {inv.expected_outcome}.",
                    f"SET SESSION sql_mode = '{MARIADB_MODE}';",
                    "START TRANSACTION;",
                    inv.statement,
                    "ROLLBACK;",
                ]
            else:
                body = [
                    f"-- {inv.fixture_id}: {inv.description}. Expected: {inv.expected_outcome}.",
                    "BEGIN;",
                    "SET CONSTRAINTS ALL IMMEDIATE;",
                    inv.statement,
                    "ROLLBACK;",
                ]
            _write(root / name, "\n".join(body) + "\n")
        rows.append(
            [inv.fixture_id, inv.engine, inv.target, inv.table, name, inv.description,
             inv.expected_outcome, inv.expected_error]
        )  # fmt: skip
    _write_csv(
        root / "invalid_manifest.csv",
        ["fixture_id", "engine", "target", "table", "file", "description", "expected_outcome",
         "expected_error"],
        rows,
    )  # fmt: skip


def _load_script(fx: Fixture) -> str:
    counts = Counter((r.scope, r.table) for r in fx.rows)
    checks = []
    for scope in SCOPES:
        for table in CBS_ORDER:
            n = counts[(scope.key, table)]
            checks.append(f"check_count maria {scope.database} {table} {n}")
    for table in IMS_ORDER:
        checks.append(f'check_count pg "$PG_DB" {table} {counts[("ims", table)]}')
    body = r"""#!/usr/bin/env bash
# Load the synthetic seed into local MariaDB and PostgreSQL, check row counts, then confirm
# that every invalid input is rejected.
#
#   SCHEMA_DIR=/path/to/inkomoko-erx/docs/schemas ./load_local.sh
#
# Optional: MARIADB_ARGS="--user=me --password=secret" PSQL_ARGS="-h localhost -U me" PG_DB=ims_dq
# WARNING: drops and recreates cbs_dq_tenant_a, cbs_dq_tenant_b, cbs_tenant_store_dq and $PG_DB.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SCHEMA_DIR="${SCHEMA_DIR:?set SCHEMA_DIR to the docs/schemas folder of the repo}"
MARIADB_ARGS="${MARIADB_ARGS:-}"
PSQL_ARGS="${PSQL_ARGS:-}"
PG_DB="${PG_DB:-ims_dq}"
maria() { mariadb $MARIADB_ARGS "$@"; }
pg() { psql -X -q -v ON_ERROR_STOP=1 $PSQL_ARGS "$@"; }
UTF="CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

for t in tenant_a tenant_b; do
  db="cbs_dq_$t"
  maria -e "DROP DATABASE IF EXISTS $db; CREATE DATABASE $db $UTF"
  maria --abort-source-on-error --database="$db" --execute="source $SCHEMA_DIR/cbs.tenant.mariadb.sql"
  maria --abort-source-on-error --database="$db" --execute="source $HERE/load/cbs_$t.sql"
done
maria -e "DROP DATABASE IF EXISTS cbs_tenant_store_dq; CREATE DATABASE cbs_tenant_store_dq $UTF"
maria --abort-source-on-error --database=cbs_tenant_store_dq \
  --execute="source $SCHEMA_DIR/cbs.tenant-store.mariadb.sql"
maria --abort-source-on-error --database=cbs_tenant_store_dq \
  --execute="source $HERE/load/cbs_tenant_store.sql"
pg -d postgres -c "DROP DATABASE IF EXISTS $PG_DB"
pg -d postgres -c "CREATE DATABASE $PG_DB"
pg -d "$PG_DB" -f "$SCHEMA_DIR/ims.postgresql.sql"
pg -d "$PG_DB" -f "$HERE/load/ims.sql"
echo "Clean load finished with constraints on."

status=0
check_count() {
  local engine=$1 db=$2 table=$3 want=$4 got
  if [ "$engine" = maria ]; then
    got=$(maria -N -B --database="$db" -e "SELECT COUNT(*) FROM \`$table\`")
  else
    got=$(pg -At -d "$db" -c "SELECT COUNT(*) FROM ims.\"$table\"")
  fi
  if [ "$got" != "$want" ]; then echo "COUNT MISMATCH $db.$table: $got, expected $want"; status=1; fi
}
__CHECKS__
[ $status -eq 0 ] && echo "Row counts match run_metadata.json."

while IFS=, read -r fid engine target table file rest; do
  [ "$fid" = fixture_id ] && continue
  case "$engine" in
    mariadb) cmd=(maria --database="$target") ;;
    postgresql) cmd=(pg -d "$PG_DB") ;;
    *) echo "$fid: raw extract for the ingestion quarantine test ($file)"; continue ;;
  esac
  if "${cmd[@]}" < "$HERE/invalid/$file" > /dev/null 2>&1; then
    echo "$fid LOADED but should be rejected"; status=1
  else
    echo "$fid rejected as expected"
  fi
done < "$HERE/invalid/invalid_manifest.csv"
exit $status
"""
    return body.replace("__CHECKS__", "\n".join(checks))


def _readme(fx: Fixture, people: int) -> str:
    counts = Counter((r.system, r.scope, r.table) for r in fx.rows)
    by_person = Counter(p.scenario for p in fx.people)
    outcome_rows: dict[str, Counter] = {}
    for r in fx.rows:
        if r.system == "ims" and r.scenario in SCENARIOS:
            outcome_rows.setdefault(r.scenario, Counter())[r.outcome] += 1
    lines = [
        "# Synthetic CBS and IMS seed data",
        "",
        f"Seed {fx.seed}, {people} fictional people, generator version {GENERATOR_VERSION}. "
        "Built to `docs/schemas/SYNTHETIC_CUSTOMER_MATCHING.md`.",
        "",
        "Every name, phone number and document number is invented. Phones use the unassigned "
        "calling codes +990 (tenant A) and +999 (tenant B), and emails use `example.invalid`. "
        "Keep this data out of any contact workflow and out of version control.",
        "",
        "## Folders",
        "",
        "| Folder | Contents | Give to the matcher? |",
        "| --- | --- | --- |",
        "| `load/` | MariaDB seeds for `cbs_dq_tenant_a`, `cbs_dq_tenant_b` and the tenant "
        "store; PostgreSQL seed for the `ims` schema | Yes, after loading |",
        "| `extracts/` | The same rows as CSV, plus `scope_map.csv` (tenant, country, office "
        "and calling-code map) | Yes |",
        "| `evaluation/` | `truth_manifest.csv`, `mutation_log.csv`, `scenarios.csv`, "
        "`run_metadata.json` | **Never** |",
        "| `invalid/` | Inputs that must be rejected or quarantined, with "
        "`invalid_manifest.csv` | Ingestion tests only |",
        "",
        "## Load",
        "",
        "```text",
        "SCHEMA_DIR=/path/to/inkomoko-erx/docs/schemas ./load_local.sh",
        "```",
        "",
        "The script recreates the fixture databases, loads the team schema and the seed with "
        "foreign keys and unique checks on, compares row counts and confirms each invalid input "
        "fails. To load by hand, run the schema file and then the matching `load/` file for "
        "each database, in this order: tenant A, tenant B, tenant store, IMS.",
        "",
        "## Reading the CSV files",
        "",
        r"`\N` means NULL; an empty field is an empty string. Read every column as text so "
        "leading zeros and spaces survive:",
        "",
        "```python",
        r'pd.read_csv(path, dtype=str, keep_default_na=False, na_values=[r"\N"])',
        "```",
        "",
        "## Answer key",
        "",
        "`truth_manifest.csv` has one row per loaded row, keyed by system, table, scope and ID. "
        "IMS rows carry the expected outcome (`link`, `review` or `unmatched`) and the CBS "
        "tenant and client ID of the true counterpart, if any. CBS client rows carry the "
        "outcome of their IMS counterparts; identifier rows are `evidence` and code tables are "
        "`reference`. `mutation_log.csv` lists every planned difference with its true and "
        "emitted value.",
        "",
        "## Row counts",
        "",
        "| Source | Table | Rows |",
        "| --- | --- | ---: |",
    ]
    for (system, scope, table), n in sorted(counts.items()):
        lines.append(f"| {system} {scope} | `{table}` | {n} |")
    lines += [
        "",
        "## Scenarios",
        "",
        "| ID | Case | People | IMS rows: link / review / unmatched |",
        "| --- | --- | ---: | --- |",
    ]
    for sid in sorted(SCENARIOS):
        o = outcome_rows.get(sid, Counter())
        lines.append(
            f"| {sid} | {SCENARIOS[sid][0]} | {by_person[sid]} | "
            f"{o['link']} / {o['review']} / {o['unmatched']} |"
        )
    lines += [
        "",
        "## Regenerate",
        "",
        "```text",
        f"python -m ierx.synthetic --people {people} --seed {fx.seed} --out <folder>",
        "```",
        "",
        "The same seed and people count reproduce these files byte for byte; "
        "`run_metadata.json` lists their SHA-256 hashes.",
    ]
    return "\n".join(lines) + "\n"


def write_fixture(fx: Fixture, out_dir: Path, people: int) -> dict[str, Any]:
    """Write every output file and return the run metadata."""
    out_dir = Path(out_dir)
    _write(out_dir / "README.md", _readme(fx, people))
    _write(out_dir / "load_local.sh", _load_script(fx))
    (out_dir / "load_local.sh").chmod(0o755)
    load = out_dir / "load"
    for scope in SCOPES:
        _write(load / f"cbs_{scope.key}.sql", _cbs_seed(fx, scope.key, scope.database, people))
    _write(load / "cbs_tenant_store.sql", _tenant_store_seed(fx))
    _write(load / "ims.sql", _ims_seed(fx, people))
    _extracts(fx, out_dir / "extracts")
    evaluation = out_dir / "evaluation"
    _write_csv(evaluation / "truth_manifest.csv", MANIFEST_COLUMNS, _manifest(fx))
    _write_csv(
        evaluation / "mutation_log.csv",
        ["row_key", "source_table", "column", "truth_value", "emitted_value", "mutation"],
        [
            [m.row.key, m.row.table, m.column, m.truth_value, m.emitted_value, m.kind]
            for m in sorted(fx.mutations, key=lambda m: (m.row.key, m.column))
        ],
    )
    _write_csv(
        evaluation / "scenarios.csv",
        ["scenario_id", "case", "construction", "expected_behaviour"],
        [[sid, *SCENARIOS[sid]] for sid in sorted(SCENARIOS)],
    )
    _invalid(fx, out_dir / "invalid")
    meta = _metadata(fx, people, out_dir)
    _write(evaluation / "run_metadata.json", json.dumps(meta, indent=2) + "\n")
    return meta

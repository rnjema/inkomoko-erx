"""Build synthetic CBS and IMS customer records from one set of fictional people.

The construction follows docs/schemas/SYNTHETIC_CUSTOMER_MATCHING.md:

* every fictional person gets a private ``truth_entity_id`` before any source row exists;
* names, birth dates, phones and documents are drawn once per person and then mutated per
  scenario when the CBS and IMS rows are emitted;
* CBS and IMS use independent ID sequences, some numeric IDs overlap on purpose, and row
  order carries no information about the scenario;
* the truth (entity, scenario, expected outcome) lives only in the evaluation files.

Everything here is fabricated. Phone numbers use the unassigned calling codes +990 and +999,
so no generated number can reach a real phone.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date, timedelta
import random
from typing import Any, Callable
import unicodedata

GENERATOR_VERSION = "1.0.0"
DEFAULT_SEED = 4950
DEFAULT_PEOPLE = 200
MIN_PEOPLE = 100

LINK, REVIEW, UNMATCHED = "link", "review", "unmatched"
EVIDENCE, REFERENCE = "evidence", "reference"


@dataclass(frozen=True)
class Scope:
    """One CBS tenant database and the country it serves."""

    key: str
    label: str
    database: str
    country: str
    country_code: str
    calling_code: str
    offices: tuple[str, ...]


SCOPES = (
    Scope(
        "tenant_a",
        "Synthetic Tenant A",
        "cbs_dq_tenant_a",
        "Synthetic Country A",
        "XA",
        "990",
        ("A Head Office", "A North Branch", "A South Branch"),
    ),
    Scope(
        "tenant_b",
        "Synthetic Tenant B",
        "cbs_dq_tenant_b",
        "Synthetic Country B",
        "XB",
        "999",
        ("B Head Office", "B East Branch"),
    ),
)
SCOPE = {s.key: s for s in SCOPES}
OTHER_TENANT = {"tenant_a": "tenant_b", "tenant_b": "tenant_a"}

# Document types are tenant-local code values, so the same type has a different ID per tenant.
DOC_TYPES = {
    "tenant_a": (
        "National ID - Synthetic Country A",
        "Passport",
        "National ID - Synthetic Country B",
    ),
    "tenant_b": (
        "Passport",
        "National ID - Synthetic Country B",
        "National ID - Synthetic Country A",
    ),
}
NATIONAL_DOC = {
    "XA": "National ID - Synthetic Country A",
    "XB": "National ID - Synthetic Country B",
}

SCENARIOS = {
    "S01": (
        "clean_shared_key",
        "CBS external_id equals IMS mifos_uid_external in the right tenant; demographics agree.",
        "Link if the candidate key is enabled.",
    ),
    "S02": (
        "missing_or_blank_keys",
        "NULL, empty and whitespace keys on either side; one IMS client has no due diligence.",
        "Skip empty-key joins and try demographic matching.",
    ),
    "S03": (
        "formatting_difference",
        "IMS key differs by case or surrounding spaces; separate customers hold 000NN and NN.",
        "Normalize only under a documented rule; keep leading zeros; no false merge.",
    ),
    "S04": (
        "stale_or_orphaned_reference",
        "IMS key was never issued in CBS, or names a different current CBS customer.",
        "Surface the bad reference; check fallback evidence before linking.",
    ),
    "S05": (
        "swapped_keys",
        "Two IMS records carry each other's CBS external_id; demographics untouched.",
        "Flag both conflicts; no silent false links.",
    ),
    "S06": (
        "duplicate_ims_evidence",
        "One IMS client submits twice with the same key; two distinct people claim one key.",
        "Keep repeat submissions as observations; send a shared key to review.",
    ),
    "S07": (
        "tenant_collision",
        "Same m_client.id and external_id in both tenants; IMS tenant hint dropped or wrong.",
        "No cross-tenant joins; unresolved scope goes to review.",
    ),
    "S08": (
        "unproven_numeric_reference",
        "mifos_demo_graphics_pk points to the right ID, an unrelated ID or no row; "
        "unrelated rows share a local ID.",
        "Numeric coincidences stay visible and never link on their own.",
    ),
    "S09": (
        "source_only",
        "People only in CBS or only in IMS, including near neighbours.",
        "Leave unmatched.",
    ),
    "S10": (
        "name_variation_corroborated",
        "Case, accents, missing middle name, reordered names or a typo; DOB and phone agree "
        "for most, absent for two.",
        "Recover corroborated pairs; review the uncorroborated ones.",
    ),
    "S11": (
        "shared_or_recycled_phone",
        "Household members share a phone; a CBS-only phone reappears on a later IMS-only person.",
        "Require independent corroboration.",
    ),
    "S12": (
        "dob_quality",
        "Text DOB in other formats, ambiguous day and month, year only, invalid, or plausibly "
        "wrong.",
        "Parse supported formats only; keep ambiguity and conflicts visible.",
    ),
    "S13": (
        "common_name_and_dob",
        "Different people with the same name and DOB; with and without other evidence.",
        "Use extra evidence where present; leave ties unresolved.",
    ),
    "S14": (
        "conflicting_document_evidence",
        "Spacing on one document, one string under two types or issuers, contradictory "
        "documents.",
        "Compare within type and issuer; flag contradictions.",
    ),
}

FIRST_F = (
    "Aline", "Alice", "Amani", "Ange", "Agnes", "Beatrice", "Chantal", "Clarisse", "Claudine",
    "Diane", "Divine", "Esther", "Faith", "Furaha", "Grace", "Imani", "Jeanne", "Josiane", "Joy",
    "Mercy", "Nadine", "Neema", "Odette", "Rehema", "Sandrine", "Solange", "Vestine", "Zawadi",
    "Annette", "Benigne", "Consolee", "Delphine", "Florence", "Gloria", "Liliane", "Pacifique",
)  # fmt: skip
FIRST_M = (
    "Baraka", "Bosco", "Claude", "Daniel", "Didier", "Emmanuel", "Eric", "Fabrice", "Faustin",
    "Gaspard", "Hamisi", "Innocent", "Joseph", "Juma", "Musa", "Olivier", "Patrick", "Pierre",
    "Samuel", "Viateur", "Aloys", "Augustin", "Cyprien", "Damascene", "Elias", "Gilbert",
    "Isaac", "Janvier", "Kevin", "Moses", "Noel", "Prosper", "Silas", "Valens",
)  # fmt: skip
FIRST_ACCENTED = (
    "Aimée", "Clémentine", "Hélène", "Immaculée", "Désiré", "Jérôme", "Théogène", "Célestin",
    "Félicien", "Eugène", "Agnès", "Béatrice", "Consolée", "Bénigne", "Théophile", "Médard",
)  # fmt: skip
MIDDLE = (
    "Marie", "Claire", "Paul", "Bosco", "Christine", "Pascal", "Josephine", "Xavier",
    "Clarisse", "Damien", "Mary", "John", "Jean", "Rose", "Esperance", "Bernard",
)  # fmt: skip
LAST = (
    "Uwimana", "Mukamana", "Niyonzima", "Habimana", "Nshimiyimana", "Mugisha", "Ndayisaba",
    "Hakizimana", "Uwase", "Ingabire", "Bizimana", "Nsengiyumva", "Tuyishime", "Iradukunda",
    "Kamanzi", "Mutoni", "Umutoni", "Ndikumana", "Nzeyimana", "Bigirimana", "Ntakirutimana",
    "Mwangi", "Otieno", "Wanjiru", "Achieng", "Kiprono", "Mutua", "Odhiambo", "Mbuyi",
    "Lokonga", "Ilunga", "Kabongo", "Tshibanda", "Nyiraneza", "Mukeshimana", "Twagirimana",
    "Ishimwe", "Niyitegeka", "Manirakiza", "Nduwimana", "Akinyi", "Wekesa",
)  # fmt: skip
MONTHS = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
KEY_LETTERS = "BCDFGHJKLMNPQRSTVWXZ"
DD_REQUIRED_BOOLEANS = (
    "is_draft_data",
    "mifos_client_activation_status",
    "mifos_is_biz_registered",
    "submit_to_cbs",
    "client_demo_graphics_cbs_status",
    "client_other_info_cbs_status",
    "entity_other_info_cbs_status",
    "business_info_cbs_status",
    "recruitment_surv_cbs_status",
    "loan_app_cbs_status",
    "cash_flow_cbs_status",
    "balance_sheet_cbs_status",
    "projection_rate_cbs_status",
    "next_of_kin",
    "loan_documents",
)
DEMO_REQUIRED_BOOLEANS = (
    "mifos_client_activation_status",
    "mifos_is_biz_registered",
    "submit_to_cbs",
    "client_demo_graphics_cbs_status",
    "next_of_kin",
)

KEEP = object()  # marker: emit the person's true value


class Lazy:
    """A value that depends on IDs assigned after every row exists."""

    def __init__(self, fn: Callable[[], Any]):
        self.fn = fn


def resolve(value: Any) -> Any:
    return value.fn() if isinstance(value, Lazy) else value


def fold(text: str | None) -> str:
    """Approximate utf8mb4_unicode_ci equality: case, accents and trailing spaces ignored."""
    if text is None:
        return ""
    stripped = "".join(
        c for c in unicodedata.normalize("NFKD", text) if not unicodedata.combining(c)
    )
    return stripped.casefold().rstrip(" ")


def strip_accents(text: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFKD", text) if not unicodedata.combining(c))


@dataclass(eq=False)
class Row:
    system: str  # "cbs" or "ims"
    scope: str  # tenant key for CBS, "ims" for IMS
    table: str
    values: dict[str, Any]
    entity_id: str | None = None
    scenario: str = "REF"
    variant: str = ""
    outcome: str = REFERENCE
    counterpart: Row | None = None  # the CBS m_client row of the same person, if any
    truth_tenant: str = ""
    note: str = ""

    @property
    def id(self) -> int:
        return self.values["id"]

    @property
    def key(self) -> str:
        return f"{self.system}:{self.scope}:{self.table}:{self.id}"


@dataclass(eq=False)
class Person:
    entity_id: str
    scenario: str
    variant: str
    tenant: str
    office: str
    first: str
    middle: str | None
    last: str
    dob: date
    phone: str  # nine-digit subscriber number
    nationality: str  # issuer of national_id
    national_id: str
    passport: str | None
    external_id: str | None
    joined: date
    has_docs: bool = True
    cbs: Row | None = None
    ims: Row | None = None

    @property
    def display(self) -> str:
        return " ".join(x for x in (self.first, self.middle, self.last) if x)


@dataclass
class Mutation:
    row: Row
    column: str
    truth_value: Any
    emitted_value: Any
    kind: str


@dataclass
class InvalidFixture:
    fixture_id: str
    engine: str  # "mariadb", "postgresql" or "raw_csv"
    target: str  # database or file the input is aimed at
    table: str
    description: str
    expected_outcome: str
    expected_error: str
    statement: str = ""
    raw_rows: list[dict[str, Any]] = field(default_factory=list)


@dataclass
class Fixture:
    seed: int
    people: list[Person]
    rows: list[Row]
    mutations: list[Mutation]
    invalid: list[InvalidFixture]

    def table(self, system: str, scope: str, table: str) -> list[Row]:
        rows = [r for r in self.rows if (r.system, r.scope, r.table) == (system, scope, table)]
        return sorted(rows, key=lambda r: r.id)


ID_START = {
    ("cbs", "m_client"): 1001,
    ("cbs", "m_client_identifier"): 1,
    ("ims", "mel_client"): 1101,
    ("ims", "mel_duediligence"): 2001,
    ("ims", "due_diligence_demographics"): 701,
}


class _Builder:
    def __init__(self, people: int, seed: int):
        if people < MIN_PEOPLE:
            raise ValueError(f"people must be at least {MIN_PEOPLE}, got {people}")
        self.n = people
        self.seed = seed
        self.rng = random.Random(seed)
        self.people: list[Person] = []
        self.rows: list[Row] = []
        self.mutations: list[Mutation] = []
        self.pins: list[tuple[Row, Row]] = []
        self.invalid: list[InvalidFixture] = []
        self._names: set[tuple[str, str]] = set()
        self._phones: set[str] = set()
        self._keys: set[str] = set()
        self._docs: set[str] = set()
        self._entities: set[str] = set()
        self._uids: set[str] = set()
        self.office_rows: dict[tuple[str, str], Row] = {}
        self.mifos_office_rows: dict[tuple[str, str], Row] = {}
        self.country_rows: dict[str, Row] = {}
        self.code_rows: dict[tuple[str, str], Row] = {}

    # ---------------------------------------------------------------- unique values
    def _unique(self, used: set[str], make: Callable[[], str]) -> str:
        for _ in range(10_000):
            value = make()
            if fold(value) not in used:
                used.add(fold(value))
                return value
        raise RuntimeError("could not draw a unique value")

    def digits(self, n: int) -> str:
        return "".join(self.rng.choice("0123456789") for _ in range(n))

    def new_phone(self) -> str:
        return self._unique(self._phones, lambda: "7" + self.digits(8))

    def new_key(self) -> str:
        return self._unique(
            self._keys, lambda: "".join(self.rng.choices(KEY_LETTERS, k=3)) + self.digits(5)
        )

    def new_national(self, issuer: str, dob: date) -> str:
        if issuer == "XA":
            make = lambda: "9" + str(dob.year) + self.rng.choice("78") + self.digits(10)
        else:
            make = lambda: "8" + self.digits(7)
        return self._unique(self._docs, make)

    def new_passport(self) -> str:
        return self._unique(self._docs, lambda: "XP" + self.digits(7))

    def new_uid(self) -> str:
        return self._unique(self._uids, lambda: "U" + self.digits(7))

    def new_entity(self) -> str:
        return self._unique(self._entities, lambda: "P" + self.digits(6))

    def new_date(self, start: date, end: date) -> date:
        return start + timedelta(days=self.rng.randrange((end - start).days + 1))

    def new_name(self, *, accented=False, middle=None, last=None) -> tuple[str, str | None, str]:
        for _ in range(10_000):
            if accented:
                first = self.rng.choice(FIRST_ACCENTED)
            else:
                first = self.rng.choice(FIRST_F if self.rng.random() < 0.5 else FIRST_M)
            mid = middle if middle is not None else self.rng.choice(MIDDLE)
            if middle is None and self.rng.random() > 0.4:
                mid = None
            sur = last or self.rng.choice(LAST)
            if (fold(first), fold(sur)) not in self._names:
                self._names.add((fold(first), fold(sur)))
                return first, mid, sur
        raise RuntimeError("could not draw a unique name")

    # ---------------------------------------------------------------- people
    def person(
        self,
        scenario: str,
        variant: str,
        *,
        tenant: str | None = None,
        office: str | None = None,
        accented: bool = False,
        middle: str | None = None,
        name: tuple[str, str | None, str] | None = None,
        last: str | None = None,
        dob: date | None = None,
        phone: str | None = None,
        nationality: str | None = None,
        passport: bool | None = None,
        external_id: Any = KEEP,
        joined: date | None = None,
    ) -> Person:
        tenant = tenant or ("tenant_a" if self.rng.random() < 0.6 else "tenant_b")
        scope = SCOPE[tenant]
        first, mid, sur = name or self.new_name(accented=accented, middle=middle, last=last)
        birth = dob or self.new_date(date(1965, 1, 1), date(2004, 12, 31))
        issuer = nationality or (
            scope.country_code
            if self.rng.random() < 0.92
            else SCOPE[OTHER_TENANT[tenant]].country_code
        )
        has_passport = passport if passport is not None else self.rng.random() < 0.3
        p = Person(
            entity_id=self.new_entity(),
            scenario=scenario,
            variant=variant,
            tenant=tenant,
            office=office or self.rng.choice(scope.offices),
            first=first,
            middle=mid,
            last=sur,
            dob=birth,
            phone=phone or self.new_phone(),
            nationality=issuer,
            national_id=self.new_national(issuer, birth),
            passport=self.new_passport() if has_passport else None,
            external_id=self.new_key() if external_id is KEEP else external_id,
            joined=joined or self.new_date(date(2016, 1, 4), date(2025, 12, 19)),
        )
        self.people.append(p)
        return p

    # ---------------------------------------------------------------- formatting
    def phone_text(self, p_phone: str, tenant: str, style: str) -> str:
        cc = SCOPE[tenant].calling_code
        s = p_phone
        return {
            "national": "0" + s,
            "national_spaced": f"0{s[:3]} {s[3:6]} {s[6:]}",
            "intl": f"+{cc}{s}",
            "intl_spaced": f"+{cc} {s[:3]} {s[3:6]} {s[6:]}",
            "intl_no_plus": f"{cc}{s}",
            "bare": s,
        }[style]

    @staticmethod
    def spaced_national(doc: str) -> str:
        if len(doc) == 16:
            return f"{doc[0]} {doc[1:5]} {doc[5]} {doc[6:13]} {doc[13]} {doc[14:]}"
        return f"{doc[:2]} {doc[2:5]} {doc[5:]}"

    def survey_date(self, p: Person) -> date:
        return p.joined - timedelta(days=self.rng.randrange(1, 45))

    # ---------------------------------------------------------------- rows
    def add(self, row: Row) -> Row:
        self.rows.append(row)
        return row

    def apply(self, row: Row, overrides: dict[str, tuple[Any, str]] | None) -> None:
        for column, (value, kind) in (overrides or {}).items():
            truth = row.values.get(column)
            row.values[column] = value
            if truth != value or isinstance(value, Lazy) or isinstance(truth, Lazy):
                self.mutations.append(Mutation(row, column, truth, value, kind))

    def emit_cbs(self, p: Person, *, docs: bool = True, note: str = "") -> Row:
        rng = self.rng
        office = self.office_rows[(p.tenant, p.office)]
        activation = p.joined + timedelta(days=rng.randrange(0, 15))
        email = None
        if rng.random() < 0.25:
            local = f"{strip_accents(p.first)}.{strip_accents(p.last)}".lower()
            email = f"{local}{rng.randrange(10, 99)}@example.invalid"
        row = self.add(
            Row(
                "cbs",
                p.tenant,
                "m_client",
                {
                    "id": None,
                    "account_no": None,
                    "external_id": p.external_id,
                    "status_enum": 300,
                    "activation_date": activation,
                    "office_id": Lazy(lambda: office.id),
                    "firstname": p.first,
                    "middlename": p.middle,
                    "lastname": p.last,
                    "fullname": p.display if rng.random() < 0.2 else None,
                    "display_name": p.display,
                    "mobile_no": self.phone_text(
                        p.phone,
                        p.tenant,
                        rng.choices(["national", "intl", "bare"], [0.7, 0.2, 0.1])[0],
                    ),
                    "date_of_birth": p.dob,
                    "submittedon_date": p.joined,
                    "legal_form_enum": 1,
                    "email_address": email,
                },
                p.entity_id,
                p.scenario,
                p.variant,
                truth_tenant=p.tenant,
                note=note,
            )
        )
        row.values["account_no"] = Lazy(lambda: f"{row.id:09d}")
        p.cbs = row
        if docs and p.has_docs:
            self.emit_identifier(p, NATIONAL_DOC[p.nationality], p.national_id)
            if p.passport:
                self.emit_identifier(p, "Passport", p.passport)
        return row

    def emit_identifier(self, p: Person, doc_type: str, key: str) -> Row:
        client = p.cbs
        code = self.code_rows[(p.tenant, doc_type)]
        return self.add(
            Row(
                "cbs",
                p.tenant,
                "m_client_identifier",
                {
                    "id": None,
                    "client_id": Lazy(lambda: client.id),
                    "document_type_id": Lazy(lambda: code.id),
                    "document_key": key,
                    "status": 300,
                    "active": 1,
                },
                p.entity_id,
                p.scenario,
                p.variant,
                EVIDENCE,
                truth_tenant=p.tenant,
            )
        )

    def emit_ims_client(
        self,
        p: Person,
        outcome: str,
        *,
        overrides: dict[str, tuple[Any, str]] | None = None,
        docs: bool = True,
        note: str = "",
    ) -> Row:
        rng = self.rng
        country = self.country_rows[p.tenant]
        style = rng.choice(["national", "national_spaced", "intl", "intl_spaced", "intl_no_plus"])
        id_no = None
        if docs and p.has_docs:
            roll = rng.random()
            if roll < 0.5:
                id_no = p.national_id
            elif roll < 0.7:
                id_no = self.spaced_national(p.national_id)
        row = self.add(
            Row(
                "ims",
                "ims",
                "mel_client",
                {
                    "id": None,
                    "flag": False,
                    "uid": self.new_uid(),
                    "id_no": id_no,
                    "client_names": p.display,
                    "fname": p.first,
                    "mname": p.middle,
                    "lname": p.last,
                    "dateofbirth": p.dob.isoformat(),
                    "phone1": self.phone_text(p.phone, p.tenant, style),
                    "phone2": None,
                    "country_id": Lazy(lambda: country.id),
                    "date_of_survey": self.survey_date(p).isoformat(),
                },
                p.entity_id,
                p.scenario,
                p.variant,
                outcome,
                p.cbs,
                p.tenant,
                note,
            )
        )
        self.apply(row, overrides)
        p.ims = row
        return row

    def emit_dd(
        self,
        p: Person,
        client: Row | None,
        outcome: str,
        *,
        overrides: dict[str, tuple[Any, str]] | None = None,
        docs: bool = True,
        pk: Any = None,
        survey: date | None = None,
        note: str = "",
    ) -> Row:
        office = self.mifos_office_rows[(p.tenant, p.office)]
        values: dict[str, Any] = {
            "id": None,
            "client_id": Lazy(lambda: client.id) if client else None,
            "client_names": p.display,
            "mifos_uid_external": p.external_id,
            "mifos_demo_graphics_pk": pk,
            "first_name": p.first,
            "last_name": p.last,
            "mifos_entity_full_names": p.display,
            "mifos_dob": p.dob,
            "cd_date_of_birth": p.dob.isoformat(),
            "mifos_phone": self.phone_text(p.phone, p.tenant, "intl"),
            "phone_number": self.phone_text(p.phone, p.tenant, "national"),
            "office_mifos_id_id": Lazy(lambda: office.id),
            "mifos_national_id": p.national_id if docs and p.has_docs else None,
            "mifos_passport_no": p.passport if docs and p.has_docs else None,
            "date_of_survey": (survey or self.survey_date(p)).isoformat(),
        }
        values.update({b: False for b in DD_REQUIRED_BOOLEANS})
        row = self.add(
            Row(
                "ims",
                "ims",
                "mel_duediligence",
                values,
                p.entity_id,
                p.scenario,
                p.variant,
                outcome,
                p.cbs,
                p.tenant,
                note,
            )
        )
        self.apply(row, overrides)
        return row

    def emit_demo(self, p: Person, dd: Row, outcome: str, note: str = "") -> Row:
        copied = (
            "client_names",
            "mifos_uid_external",
            "mifos_demo_graphics_pk",
            "first_name",
            "last_name",
            "mifos_entity_full_names",
            "mifos_dob",
            "cd_date_of_birth",
            "mifos_phone",
            "phone_number",
            "office_mifos_id_id",
            "date_of_survey",
        )
        values: dict[str, Any] = {"id": None}
        values.update({c: dd.values[c] for c in copied})
        values["mifos_altenative_phone"] = None
        values.update({b: False for b in DEMO_REQUIRED_BOOLEANS})
        return self.add(
            Row(
                "ims",
                "ims",
                "due_diligence_demographics",
                values,
                p.entity_id,
                p.scenario,
                p.variant,
                outcome,
                p.cbs,
                p.tenant,
                note,
            )
        )

    def emit_ims(
        self,
        p: Person,
        outcome: str,
        *,
        client: dict[str, tuple[Any, str]] | None = None,
        dd: dict[str, tuple[Any, str]] | None = None,
        docs: bool = True,
        pk: Any = None,
        demographics: bool = False,
        note: str = "",
    ) -> tuple[Row, Row]:
        c = self.emit_ims_client(p, outcome, overrides=client, docs=docs, note=note)
        d = self.emit_dd(p, c, outcome, overrides=dd, docs=docs, pk=pk, note=note)
        if demographics:
            self.emit_demo(p, d, outcome, note)
        return c, d

    # ---------------------------------------------------------------- reference data
    def reference(self) -> None:
        for scope in SCOPES:
            for i, name in enumerate(scope.offices, start=1):
                self.office_rows[(scope.key, name)] = self.add(
                    Row(
                        "cbs",
                        scope.key,
                        "m_office",
                        {
                            "id": i,
                            "parent_id": None if i == 1 else 1,
                            "hierarchy": "." if i == 1 else f".{i}.",
                            "external_id": None,
                            "name": name,
                            "opening_date": date(2014 + i, 1 + i, 6),
                        },
                        truth_tenant=scope.key,
                    )
                )
            self.add(
                Row(
                    "cbs",
                    scope.key,
                    "m_code",
                    {"id": 1, "code_name": "Customer Identifier", "is_system_defined": True},
                    truth_tenant=scope.key,
                )
            )
            for i, doc_type in enumerate(DOC_TYPES[scope.key], start=1):
                self.code_rows[(scope.key, doc_type)] = self.add(
                    Row(
                        "cbs",
                        scope.key,
                        "m_code_value",
                        {
                            "id": i,
                            "code_id": 1,
                            "code_value": doc_type,
                            "code_description": None,
                            "order_position": i - 1,
                            "is_active": True,
                            "is_mandatory": False,
                        },
                        truth_tenant=scope.key,
                    )
                )
        for i, scope in enumerate(SCOPES, start=1):
            self.country_rows[scope.key] = self.add(
                Row(
                    "ims",
                    "ims",
                    "administration_country",
                    {"id": i, "country": scope.country, "countrycode": scope.country_code},
                    truth_tenant=scope.key,
                )
            )
        offices = [(s.key, name) for s in SCOPES for name in s.offices]
        ims_ids = list(range(1, len(offices) + 1))
        self.rng.shuffle(ims_ids)
        for ims_id, (tenant, name) in zip(ims_ids, offices):
            cbs_office = self.office_rows[(tenant, name)]
            self.mifos_office_rows[(tenant, name)] = self.add(
                Row(
                    "ims",
                    "ims",
                    "mel_mifosoffices",
                    {
                        "id": ims_id,
                        "mifos_pk": cbs_office.id,
                        "name": name,
                        "name_decorated": name if cbs_office.id == 1 else ".." + name,
                        "parent_id": cbs_office.values["parent_id"],
                        "external_id": None,
                    },
                    truth_tenant=tenant,
                )
            )

    # ---------------------------------------------------------------- scenarios
    def s01_clean(self, count: int) -> None:
        for _ in range(count):
            p = self.person("S01", "baseline")
            cbs = self.emit_cbs(p, docs=self.rng.random() > 0.1)
            pk = Lazy(lambda r=cbs: r.id) if self.rng.random() < 0.2 else None
            client, _ = self.emit_ims(p, LINK, pk=pk, demographics=self.rng.random() < 0.35)
            if self.rng.random() < 0.15:
                client.values["phone2"] = self.phone_text(self.new_phone(), p.tenant, "national")

    def s02_missing_keys(self) -> None:
        cases = (
            ("cbs_null_ims_null", "tenant_a", None, None),
            ("cbs_null_ims_empty", "tenant_a", None, ""),
            ("cbs_null_ims_whitespace", "tenant_b", None, "   "),
            ("cbs_empty_ims_null", "tenant_a", "", None),
            ("cbs_whitespace_ims_empty", "tenant_b", " ", ""),
        )
        for variant, tenant, cbs_key, ims_key in cases:
            p = self.person("S02", variant, tenant=tenant, external_id=cbs_key)
            self.emit_cbs(p)
            dd = None if ims_key == cbs_key else {"mifos_uid_external": (ims_key, "blank_key")}
            self.emit_ims(p, LINK, dd=dd, docs=False)
        p = self.person("S02", "ims_client_without_due_diligence")
        self.emit_cbs(p)
        self.emit_ims_client(p, LINK, docs=False)

    def s03_formatting(self) -> None:
        for variant, change in (
            ("key_case_changed", lambda k: k.lower()),
            ("key_surrounding_spaces", lambda k: f" {k} "),
            ("key_case_and_trailing_space", lambda k: k.capitalize() + " "),
        ):
            p = self.person("S03", variant)
            self.emit_cbs(p)
            self.emit_ims(p, LINK, dd={"mifos_uid_external": (change(p.external_id), variant)})
        n = self._unique(self._keys, lambda: str(self.rng.randrange(10, 99)))
        long_token = "000" + n
        self._keys.add(fold(long_token))
        for variant, token in (("token_with_leading_zeros", long_token), ("short_token", n)):
            p = self.person("S03", variant, tenant="tenant_a", external_id=token)
            self.emit_cbs(p, note=f"distinct customers hold {long_token} and {n}")
            self.emit_ims(p, LINK)

    def s04_stale(self, donors: list[Person]) -> None:
        p = self.person("S04", "stale_key_fallback_agrees")
        self.emit_cbs(p)
        self.emit_ims(
            p,
            LINK,
            dd={"mifos_uid_external": (self.new_key(), "never_issued_key")},
            note="key not in CBS; name, DOB, phone and documents agree",
        )
        p = self.person("S04", "orphan_key_ims_only", external_id=None)
        self.emit_ims(
            p, UNMATCHED, dd={"mifos_uid_external": (self.new_key(), "never_issued_key")}
        )
        p = self.person("S04", "key_names_other_customer")
        donor = self.rng.choice([d for d in donors if d.tenant == p.tenant])
        self.emit_cbs(p)
        self.emit_ims(
            p,
            REVIEW,
            dd={"mifos_uid_external": (donor.external_id, "key_of_other_customer")},
            note="key belongs to a different current CBS customer",
        )

    def s05_swapped(self) -> None:
        tenant = self.rng.choice(["tenant_a", "tenant_b"])
        r = self.person("S05", "swapped_pair", tenant=tenant)
        t = self.person("S05", "swapped_pair", tenant=tenant)
        self.emit_cbs(r)
        self.emit_cbs(t)
        self.emit_ims(r, REVIEW, dd={"mifos_uid_external": (t.external_id, "swapped_key")})
        self.emit_ims(t, REVIEW, dd={"mifos_uid_external": (r.external_id, "swapped_key")})

    def s06_duplicates(self) -> None:
        p = self.person("S06", "repeated_submission")
        self.emit_cbs(p)
        client, first = self.emit_ims(p, LINK, demographics=True)
        later = date.fromisoformat(first.values["date_of_survey"]) + timedelta(days=400)
        self.emit_dd(
            p,
            client,
            LINK,
            survey=later,
            overrides={"mifos_phone": (self.phone_text(p.phone, p.tenant, "intl_spaced"), "fmt")},
            note="second submission for the same IMS client",
        )
        owner = self.person("S06", "key_claimed_by_two_people")
        self.emit_cbs(owner)
        self.emit_ims(owner, REVIEW)
        other = self.person(
            "S06", "key_claimed_by_two_people", tenant=owner.tenant, external_id=None
        )
        self.emit_ims(
            other,
            REVIEW,
            dd={"mifos_uid_external": (owner.external_id, "key_claimed_by_other_person")},
        )

    def s07_tenant_collision(self) -> None:
        x = self.person("S07", "same_id_and_key_hint_ok", tenant="tenant_a")
        y = self.person(
            "S07", "same_id_and_key_hint_dropped", tenant="tenant_b", external_id=x.external_id
        )
        w = self.person("S07", "same_id_and_key_hint_ok", tenant="tenant_a")
        z = self.person(
            "S07", "same_id_and_key_hint_wrong", tenant="tenant_b", external_id=w.external_id
        )
        for p in (x, y, w, z):
            self.emit_cbs(p)
        self.pins += [(x.cbs, y.cbs), (z.cbs, w.cbs)]
        self.emit_ims(x, LINK)
        self.emit_ims(w, LINK)
        self.emit_ims(
            y,
            REVIEW,
            client={"country_id": (None, "tenant_hint_dropped")},
            dd={"office_mifos_id_id": (None, "tenant_hint_dropped")},
        )
        wrong_office = self.mifos_office_rows[("tenant_a", SCOPE["tenant_a"].offices[0])]
        wrong_country = self.country_rows["tenant_a"]
        self.emit_ims(
            z,
            REVIEW,
            client={"country_id": (Lazy(lambda: wrong_country.id), "tenant_hint_wrong")},
            dd={"office_mifos_id_id": (Lazy(lambda: wrong_office.id), "tenant_hint_wrong")},
        )

    def s08_numeric(self, donors: list[Person]) -> None:
        p = self.person("S08", "pk_matches_own_cbs_id")
        cbs = self.emit_cbs(p)
        self.emit_ims(p, LINK, pk=Lazy(lambda: cbs.id), demographics=True)

        p = self.person("S08", "pk_points_to_unrelated_customer")
        self.emit_cbs(p)
        donor = self.rng.choice([d for d in donors if d.tenant == p.tenant]).cbs
        self.emit_ims(
            p,
            LINK,
            dd={"mifos_uid_external": (None, "key_missing")},
            pk=Lazy(lambda: donor.id),
            note="pk names an unrelated CBS customer; link only on name, DOB and phone",
        )

        p = self.person("S08", "pk_points_to_no_row")
        self.emit_cbs(p)
        tenant = p.tenant
        missing = Lazy(
            lambda: max(r.id for r in self.rows if (r.scope, r.table) == (tenant, "m_client"))
            + 500
        )
        self.emit_ims(p, LINK, dd={"mifos_uid_external": (None, "key_missing")}, pk=missing)

        c = self.person("S08", "same_local_id_unrelated_cbs_only", tenant="tenant_a")
        self.emit_cbs(c)
        i = self.person("S08", "same_local_id_unrelated_ims_only", external_id=None)
        client, _ = self.emit_ims(i, UNMATCHED)
        self.pins.append((c.cbs, client))

    def s09_source_only(self, count: int) -> None:
        pairs = 2
        for _ in range(pairs):
            a = self.person("S09", "near_neighbour_cbs_only")
            self.emit_cbs(a)
            b = self.person(
                "S09",
                "near_neighbour_ims_only",
                tenant=a.tenant,
                office=a.office,
                last=a.last,
                dob=self.new_date(date(a.dob.year, 1, 1), date(a.dob.year, 12, 28)),
                external_id=None,
            )
            self.emit_ims(b, UNMATCHED)
        rest = max(0, count - 2 * pairs)
        for k in range(rest):
            if k % 2 == 0:
                key = None if k % 4 == 0 else KEEP
                self.emit_cbs(self.person("S09", "cbs_only", external_id=key))
            else:
                p = self.person("S09", "ims_only", external_id=None)
                if k % 4 == 1:
                    self.emit_ims_client(p, UNMATCHED)
                else:
                    self.emit_ims(p, UNMATCHED)

    def s10_names(self) -> None:
        def upper(p):
            return {
                "fname": (p.first.upper(), "upper_case"),
                "mname": (p.middle.upper() if p.middle else None, "upper_case"),
                "lname": (p.last.upper(), "upper_case"),
                "client_names": (p.display.upper(), "upper_case"),
            }, {
                "first_name": (p.first.upper(), "upper_case"),
                "last_name": (p.last.upper(), "upper_case"),
                "mifos_entity_full_names": (p.display.upper(), "upper_case"),
                "client_names": (p.display.upper(), "upper_case"),
            }

        def accents(p):
            first = strip_accents(p.first)
            full = strip_accents(p.display)
            return {
                "fname": (first, "accents_removed"),
                "client_names": (full, "accents_removed"),
            }, {
                "first_name": (first, "accents_removed"),
                "mifos_entity_full_names": (full, "accents_removed"),
                "client_names": (full, "accents_removed"),
            }

        def no_middle(p, base=None):
            first = base or p.first
            full = f"{first} {p.last}"
            return {
                "fname": (first, "middle_name_omitted"),
                "mname": (None, "middle_name_omitted"),
                "client_names": (full, "middle_name_omitted"),
            }, {
                "first_name": (first, "middle_name_omitted"),
                "mifos_entity_full_names": (full, "middle_name_omitted"),
                "client_names": (full, "middle_name_omitted"),
            }

        def reorder(p):
            full = f"{p.last.upper()} {p.first}"
            return {
                "fname": (p.last, "names_reordered"),
                "lname": (p.first, "names_reordered"),
                "mname": (None, "names_reordered"),
                "client_names": (full, "names_reordered"),
            }, {
                "first_name": (p.last, "names_reordered"),
                "last_name": (p.first, "names_reordered"),
                "mifos_entity_full_names": (full, "names_reordered"),
                "client_names": (full, "names_reordered"),
            }

        def typo(p):
            s = p.last
            spots = [k for k in range(1, len(s) - 2) if s[k] != s[k + 1]]
            i = self.rng.choice(spots)
            rest = i + 2
            bad = s[:i] + s[i + 1] + s[i] + s[rest:]
            full = " ".join(x for x in (p.first, p.middle, bad) if x)
            return {
                "lname": (bad, "typo_in_last_name"),
                "client_names": (full, "typo_in_last_name"),
            }, {
                "last_name": (bad, "typo_in_last_name"),
                "mifos_entity_full_names": (full, "typo_in_last_name"),
                "client_names": (full, "typo_in_last_name"),
            }

        def accents_no_middle(p):
            return no_middle(p, base=strip_accents(p.first))

        def no_dob_new_phone(p, client, dd):
            phone = self.new_phone()
            client.update(
                {
                    "dateofbirth": (None, "dob_missing"),
                    "phone1": (self.phone_text(phone, p.tenant, "national"), "different_phone"),
                }
            )
            dd.update(
                {
                    "mifos_dob": (None, "dob_missing"),
                    "cd_date_of_birth": (None, "dob_missing"),
                    "mifos_phone": (self.phone_text(phone, p.tenant, "intl"), "different_phone"),
                    "phone_number": (self.phone_text(phone, p.tenant, "national"), "diff_phone"),
                }
            )

        def no_dob_no_phone(p, client, dd):
            client.update({"dateofbirth": (None, "dob_missing"), "phone1": (None, "no_phone")})
            dd.update(
                {
                    "mifos_dob": (None, "dob_missing"),
                    "cd_date_of_birth": (None, "dob_missing"),
                    "mifos_phone": (None, "no_phone"),
                    "phone_number": (None, "no_phone"),
                }
            )

        plan = (
            ("upper_case", upper, {}, None, LINK),
            ("accents_removed", accents, {"accented": True}, None, LINK),
            ("middle_name_omitted", no_middle, {"middle": "Marie"}, None, LINK),
            ("names_reordered", reorder, {}, None, LINK),
            ("typo_in_last_name", typo, {}, None, LINK),
            ("accents_removed_and_middle_omitted", accents_no_middle,
             {"accented": True, "middle": "Paul"}, None, LINK),
            ("typo_without_dob_or_shared_phone", typo, {}, no_dob_new_phone, REVIEW),
            ("reordered_without_dob_or_phone", reorder, {}, no_dob_no_phone, REVIEW),
        )  # fmt: skip
        for variant, change, kwargs, extra, outcome in plan:
            p = self.person("S10", variant, **kwargs)
            self.emit_cbs(p)
            client, dd = change(p)
            dd["mifos_uid_external"] = (None, "key_missing")
            if extra:
                extra(p, client, dd)
            self.emit_ims(p, outcome, client=client, dd=dd, docs=False)

    def s11_phones(self) -> None:
        h1 = self.person("S11", "household_shared_phone")
        h2 = self.person(
            "S11",
            "household_shared_phone",
            tenant=h1.tenant,
            office=h1.office,
            last=h1.last,
            phone=h1.phone,
        )
        for p in (h1, h2):
            self.emit_cbs(p, note="phone shared with a household member")
            self.emit_ims(p, LINK, dd={"mifos_uid_external": (None, "key_missing")}, docs=False)
        old = self.person("S11", "recycled_phone_cbs_only", joined=date(2017, 3, 13))
        self.emit_cbs(old)
        new = self.person(
            "S11",
            "recycled_phone_ims_only",
            tenant=old.tenant,
            phone=old.phone,
            external_id=None,
            joined=date(2024, 8, 19),
        )
        self.emit_ims(new, UNMATCHED, note="phone used by an unrelated CBS customer in 2017")

    def s12_dob(self) -> None:
        y = lambda: self.rng.randrange(1970, 2000)
        plan = (
            ("day_first_unambiguous", date(y(), self.rng.randrange(1, 13), 23), LINK),
            ("month_name", date(y(), self.rng.randrange(1, 13), 17), LINK),
            ("ambiguous_day_month", date(y(), 4, 5), REVIEW),
            ("year_only", None, REVIEW),
            ("impossible_date", None, REVIEW),
            ("not_a_date", None, REVIEW),
            ("plausible_wrong_date", date(y(), 7, 21), REVIEW),
        )
        for variant, dob, outcome in plan:
            p = self.person("S12", variant, dob=dob)
            self.emit_cbs(p)
            d = p.dob
            typed = None
            if variant == "day_first_unambiguous":
                text, typed = f"{d.day:02d}/{d.month:02d}/{d.year}", d
            elif variant == "month_name":
                text, typed = f"{d.day} {MONTHS[d.month - 1]} {d.year}", d
            elif variant == "ambiguous_day_month":
                text = f"{d.day:02d}/{d.month:02d}/{d.year}"
            elif variant == "year_only":
                text = str(d.year)
            elif variant == "impossible_date":
                text = f"31/02/{d.year}"
            elif variant == "not_a_date":
                text = "unknown"
            else:
                typed = d.replace(day=12)
                text = typed.isoformat()
            client = {"dateofbirth": (text, variant)}
            dd = {
                "mifos_uid_external": (None, "key_missing"),
                "mifos_dob": (typed, variant),
                "cd_date_of_birth": (text, variant),
            }
            self.emit_ims(p, outcome, client=client, dd=dd, docs=False)

    def s13_common_name(self) -> None:
        name = self.new_name(middle="")
        name = (name[0], None, name[2])
        dob = self.new_date(date(1985, 1, 1), date(1995, 12, 31))
        tenant = self.rng.choice(["tenant_a", "tenant_b"])
        office = SCOPE[tenant].offices[0]
        for variant, outcome in (
            ("same_name_dob_with_phone", LINK),
            ("same_name_dob_with_phone", LINK),
            ("same_name_dob_no_other_evidence", REVIEW),
        ):
            p = self.person("S13", variant, tenant=tenant, office=office, name=name, dob=dob)
            self.emit_cbs(p)
            client: dict[str, tuple[Any, str]] = {}
            dd = {"mifos_uid_external": (None, "key_missing")}
            if outcome == REVIEW:
                client["phone1"] = (None, "no_phone")
                dd.update({"mifos_phone": (None, "no_phone"), "phone_number": (None, "no_phone")})
            self.emit_ims(p, outcome, client=client, dd=dd, docs=False)

    def s14_documents(self) -> None:
        no_key = {"mifos_uid_external": (None, "key_missing")}
        no_phone = {"mifos_phone": (None, "no_phone"), "phone_number": (None, "no_phone")}

        p = self.person("S14", "same_document_spacing", tenant="tenant_a", nationality="XA")
        self.emit_cbs(p)
        spaced = self.spaced_national(p.national_id)
        self.emit_ims(
            p,
            LINK,
            client={"id_no": (spaced, "document_spacing"), "phone1": (None, "no_phone")},
            dd={**no_key, **no_phone, "mifos_national_id": (spaced, "document_spacing")},
        )

        a = self.person("S14", "same_string_other_type_owner", nationality="XB")
        self.emit_cbs(a)
        self.emit_ims(a, LINK, dd=dict(no_key))
        b = self.person(
            "S14", "same_string_other_type_ims_only", tenant=a.tenant, external_id=None
        )
        self.emit_ims(
            b,
            UNMATCHED,
            dd={
                "mifos_national_id": (None, "other_type"),
                "mifos_passport_no": (a.national_id, "same_string_as_other_persons_national_id"),
            },
        )

        c = self.person("S14", "same_string_other_issuer", tenant="tenant_a", nationality="XA")
        d = self.person("S14", "same_string_other_issuer", tenant="tenant_a", nationality="XB")
        d.national_id = c.national_id
        for p in (c, d):
            self.emit_cbs(p, note="same document string under a different issuer")
            self.emit_ims(p, LINK, dd=dict(no_key))

        e = self.person("S14", "contradictory_documents", passport=True)
        self.emit_cbs(e)
        self.emit_ims(
            e,
            REVIEW,
            client={"id_no": (None, "doc_removed")},
            dd={
                **no_key,
                "mifos_national_id": (
                    self.new_national(e.nationality, e.dob),
                    "contradicts_cbs_national_id",
                ),
            },
            note="passport agrees with CBS, national ID contradicts it",
        )

    # ---------------------------------------------------------------- IDs and checks
    def assign_ids(self) -> None:
        groups: dict[tuple[str, str, str], list[Row]] = {}
        for row in self.rows:
            if row.values.get("id") is None:
                groups.setdefault((row.system, row.scope, row.table), []).append(row)
        for (system, _, table), rows in sorted(groups.items()):
            self.rng.shuffle(rows)
            next_id = ID_START[(system, table)]
            for row in rows:
                row.values["id"] = next_id
                next_id += 1 if self.rng.random() < 0.85 else self.rng.randrange(2, 5)
        for _ in range(10):
            if all(a.id == b.id for a, b in self.pins):
                break
            for anchor, follower in self.pins:
                target = anchor.id
                if follower.id == target:
                    continue
                for other in groups[(follower.system, follower.scope, follower.table)]:
                    if other is not follower and other.id == target:
                        other.values["id"] = follower.id
                        break
                follower.values["id"] = target
        if not all(a.id == b.id for a, b in self.pins):
            raise RuntimeError("could not satisfy the pinned shared IDs")

    def resolve_all(self) -> None:
        for row in self.rows:
            for column, value in row.values.items():
                row.values[column] = resolve(value)
        for m in self.mutations:
            m.emitted_value = resolve(m.emitted_value)
            m.truth_value = resolve(m.truth_value)

    def set_cbs_outcomes(self) -> None:
        by_entity: dict[str, list[str]] = {}
        for row in self.rows:
            if row.system == "ims" and row.entity_id:
                by_entity.setdefault(row.entity_id, []).append(row.outcome)
        for row in self.rows:
            if (row.system, row.table) == ("cbs", "m_client"):
                found = by_entity.get(row.entity_id or "", [])
                row.outcome = LINK if LINK in found else REVIEW if REVIEW in found else UNMATCHED

    def check_constraints(self) -> None:
        """Mirror the unique keys, lengths and date rules that the two engines will enforce."""
        for scope in SCOPES:
            clients = [r for r in self.rows if (r.scope, r.table) == (scope.key, "m_client")]
            ids = [r.id for r in clients]
            assert len(ids) == len(set(ids)), "duplicate m_client.id"
            keys = [
                fold(r.values["external_id"])
                for r in clients
                if r.values["external_id"] is not None
            ]
            assert len(keys) == len(
                set(keys)
            ), f"external_id collides under collation in {scope.key}"
            accounts = [r.values["account_no"] for r in clients]
            assert len(accounts) == len(set(accounts))
            docs = [
                (r.values["document_type_id"], fold(r.values["document_key"]))
                for r in self.rows
                if (r.scope, r.table) == (scope.key, "m_client_identifier")
            ]
            assert len(docs) == len(set(docs)), f"document key collides in {scope.key}"
            for r in clients:
                v = r.values
                assert len(v["account_no"]) <= 20 and len(v["display_name"]) <= 100
                assert all(len(v[c] or "") <= 50 for c in ("firstname", "middlename", "lastname"))
                assert v["external_id"] is None or len(v["external_id"]) <= 100
        for row in self.rows:
            if row.table in ("mel_duediligence", "due_diligence_demographics"):
                assert row.values["mifos_dob"] is None or isinstance(row.values["mifos_dob"], date)
            if row.table == "mel_client":
                assert row.values["flag"] is not None

    # ---------------------------------------------------------------- invalid input
    def build_invalid(self) -> None:
        a_clients = [r for r in self.rows if (r.scope, r.table) == ("tenant_a", "m_client")]
        keyed = sorted(
            (r for r in a_clients if r.values["external_id"] and r.scenario == "S01"),
            key=lambda r: r.id,
        )
        taken = keyed[0].values["external_id"]
        cased = keyed[1].values["external_id"].lower()
        a_doc = next(
            r for r in sorted(self.rows, key=lambda r: (r.table, r.id))
            if (r.scope, r.table) == ("tenant_a", "m_client_identifier")
        )  # fmt: skip
        doc_type = a_doc.values["document_type_id"]
        has_type = {
            r.values["client_id"]
            for r in self.rows
            if (r.scope, r.table) == ("tenant_a", "m_client_identifier")
            and r.values["document_type_id"] == doc_type
        }
        other_client = next(
            r.id for r in sorted(a_clients, key=lambda r: r.id) if r.id not in has_type
        )
        ims_client = min(r.id for r in self.rows if r.table == "mel_client")
        cols = "(`id`, `account_no`, `external_id`, `office_id`, `firstname`, `lastname`, `display_name`, `date_of_birth`)"  # noqa: E501

        def client(ident, ext, display, dob, office=1):
            ext_sql = "NULL" if ext is None else f"'{ext}'"
            disp_sql = "NULL" if display is None else f"'{display}'"
            return (
                f"INSERT INTO `m_client` {cols} VALUES ({ident}, '{ident:09d}', {ext_sql}, "
                f"{office}, 'Invalid', 'Fixture', {disp_sql}, '{dob}');"
            )

        def ident(doc_type, key, client_id):
            return (
                "INSERT INTO `m_client_identifier` (`id`, `client_id`, `document_type_id`, "
                f"`document_key`, `status`, `active`) VALUES (900001, {client_id}, {doc_type}, "
                f"'{key}', 300, 1);"
            )

        dd_cols = '("id", "client_id", "first_name", "mifos_dob"'
        bools = ", ".join(f'"{b}"' for b in DD_REQUIRED_BOOLEANS)
        falses = ", ".join("false" for _ in DD_REQUIRED_BOOLEANS)
        maria = (
            ("INV01", "tenant_a", "m_client", "Duplicate non-null external_id in one tenant",
             client(900001, taken, "Invalid Fixture", "1990-01-01"), "unique key external_id"),
            ("INV02", "tenant_a", "m_client", "external_id equal to an existing key except for "
             "letter case (utf8mb4_unicode_ci)",
             client(900001, cased, "Invalid Fixture", "1990-01-01"), "unique key external_id"),
            ("INV03", "tenant_a", "m_client", "display_name missing",
             client(900001, None, None, "1990-01-01"), "NOT NULL display_name"),
            ("INV04", "tenant_a", "m_client", "date_of_birth is not a calendar date",
             client(900001, None, "Invalid Fixture", "1990-02-30"), "incorrect date value"),
            ("INV05", "tenant_b", "m_client", "office_id has no m_office row",
             client(900001, None, "Invalid Fixture", "1990-01-01", office=99), "foreign key"),
            ("INV06", "tenant_a", "m_client_identifier", "document_key longer than 50 characters",
             ident(a_doc.values["document_type_id"], "X" * 60, other_client), "data too long"),
            ("INV07", "tenant_a", "m_client_identifier", "Same document type and key on a second "
             "customer", ident(a_doc.values["document_type_id"], a_doc.values["document_key"],
                               other_client), "unique key (document_type_id, document_key)"),
        )  # fmt: skip
        for fid, tenant, table, desc, stmt, err in maria:
            self.invalid.append(
                InvalidFixture(
                    fid, "mariadb", SCOPE[tenant].database, table, desc, "reject", err, stmt
                )
            )
        pg = (
            ("INV08", "mel_client", "flag missing",
             'INSERT INTO ims."mel_client" ("id", "fname", "flag") VALUES (900001, \'Invalid\', '
             "NULL);", "NOT NULL flag"),
            ("INV09", "mel_duediligence", "Required booleans missing",
             f'INSERT INTO ims."mel_duediligence" {dd_cols}) VALUES (900001, {ims_client}, '
             "'Invalid', NULL);", "NOT NULL is_draft_data"),
            ("INV10", "mel_duediligence", "mifos_dob is not a calendar date",
             f'INSERT INTO ims."mel_duediligence" {dd_cols}, {bools}) VALUES (900001, '
             f"{ims_client}, 'Invalid', '1990-02-31', {falses});", "date/time field value out "
             "of range"),
            ("INV11", "mel_duediligence", "client_id has no mel_client row",
             f'INSERT INTO ims."mel_duediligence" {dd_cols}, {bools}) VALUES (900001, 999999, '
             f"'Invalid', NULL, {falses});", "foreign key"),
        )  # fmt: skip
        for fid, table, desc, stmt, err in pg:
            self.invalid.append(
                InvalidFixture(fid, "postgresql", "ims", table, desc, "reject", err, stmt)
            )
        source = keyed[2].values
        raw = [
            {k: source[k] for k in ("id", "account_no", "external_id", "office_id", "display_name")},
            {"id": 900002, "account_no": "900000002", "external_id": source["external_id"],
             "office_id": source["office_id"], "display_name": "Raw Duplicate Fixture"},
        ]  # fmt: skip
        self.invalid.append(
            InvalidFixture(
                "INV12",
                "raw_csv",
                "tenant_a raw extract",
                "m_client",
                "Raw extract where two CBS customers in one tenant share an external_id",
                "quarantine",
                "duplicate external_id within tenant",
                raw_rows=raw,
            )
        )


def generate(people: int = DEFAULT_PEOPLE, seed: int = DEFAULT_SEED) -> Fixture:
    """Return a reproducible fixture with every scenario in the brief."""
    b = _Builder(people, seed)
    b.reference()
    curated = 6 + 5 + 3 + 2 + 3 + 4 + 5 + 8 + 4 + 7 + 3 + 6
    source_only = max(10, round(0.08 * people))
    baseline = people - curated - source_only
    b.s01_clean(baseline)
    donors = [p for p in b.people if p.scenario == "S01"]
    b.s02_missing_keys()
    b.s03_formatting()
    b.s04_stale(donors)
    b.s05_swapped()
    b.s06_duplicates()
    b.s07_tenant_collision()
    b.s08_numeric(donors)
    b.s09_source_only(source_only)
    b.s10_names()
    b.s11_phones()
    b.s12_dob()
    b.s13_common_name()
    b.s14_documents()
    if len(b.people) != people:
        raise RuntimeError(f"built {len(b.people)} people, expected {people}")
    b.assign_ids()
    b.resolve_all()
    b.set_cbs_outcomes()
    b.check_constraints()
    b.build_invalid()
    return Fixture(seed, b.people, b.rows, b.mutations, b.invalid)

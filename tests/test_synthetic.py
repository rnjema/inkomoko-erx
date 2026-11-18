from collections import Counter
import csv
import json
from pathlib import Path
import tempfile
import unittest

from ierx.synthetic import generate, write_fixture
from ierx.synthetic.generator import (
    DD_REQUIRED_BOOLEANS,
    LINK,
    REVIEW,
    SCENARIOS,
    UNMATCHED,
    fold,
)


def snapshot(fx):
    rows = sorted((r.key, sorted(r.values.items()), r.entity_id, r.outcome) for r in fx.rows)
    return repr(rows)


def cbs_clients(fx, scenario=None):
    return [
        r
        for r in fx.rows
        if r.table == "m_client" and (scenario is None or r.scenario == scenario)
    ]


class SyntheticFixtureTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.fx = generate(200, 4950)

    def test_same_seed_gives_same_rows_and_labels(self):
        self.assertEqual(snapshot(self.fx), snapshot(generate(200, 4950)))
        self.assertNotEqual(snapshot(self.fx), snapshot(generate(200, 4951)))

    def test_people_count_and_minimum(self):
        self.assertEqual(len(self.fx.people), 200)
        with self.assertRaises(ValueError):
            generate(50, 1)

    def test_every_scenario_is_present(self):
        people = Counter(p.scenario for p in self.fx.people)
        rows = Counter(r.scenario for r in self.fx.rows if r.system == "ims")
        for sid in SCENARIOS:
            self.assertGreater(people[sid], 0, sid)
        for sid in set(SCENARIOS) - {"S09"}:
            self.assertGreater(rows[sid], 0, sid)
        outcomes = {r.outcome for r in self.fx.rows if r.system == "ims"}
        self.assertTrue({LINK, REVIEW, UNMATCHED} <= outcomes)

    def test_row_keys_are_unique(self):
        keys = [r.key for r in self.fx.rows]
        self.assertEqual(len(keys), len(set(keys)))

    def test_tenant_collision_reuses_id_and_key_across_tenants(self):
        rows = cbs_clients(self.fx, "S07")
        by_key = {}
        for r in rows:
            by_key.setdefault(r.values["external_id"], []).append(r)
        self.assertEqual(len(by_key), 2)
        for pair in by_key.values():
            self.assertEqual({r.scope for r in pair}, {"tenant_a", "tenant_b"})
            self.assertEqual(pair[0].id, pair[1].id)
            self.assertNotEqual(pair[0].entity_id, pair[1].entity_id)

    def test_leading_zero_tokens_stay_distinct(self):
        tokens = sorted(
            r.values["external_id"]
            for r in cbs_clients(self.fx, "S03")
            if r.values["external_id"].isdigit()
        )
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0], "000" + tokens[1])

    def test_cbs_keys_respect_tenant_collation(self):
        for tenant in ("tenant_a", "tenant_b"):
            keys = [
                fold(r.values["external_id"])
                for r in cbs_clients(self.fx)
                if r.scope == tenant and r.values["external_id"] is not None
            ]
            self.assertEqual(len(keys), len(set(keys)))

    def test_required_ims_values_are_supplied(self):
        for r in self.fx.rows:
            if r.table == "mel_client":
                self.assertIs(r.values["flag"], False)
            if r.table == "mel_duediligence":
                for column in DD_REQUIRED_BOOLEANS:
                    self.assertIsNotNone(r.values[column])

    def test_written_files_keep_truth_out_of_extracts(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            meta = write_fixture(self.fx, out, 200)
            with open(out / "evaluation" / "truth_manifest.csv", newline="") as handle:
                manifest = list(csv.DictReader(handle))
            self.assertEqual(len(manifest), len(self.fx.rows))
            self.assertEqual(meta["seed"], 4950)
            stored = json.loads((out / "evaluation" / "run_metadata.json").read_text())
            self.assertEqual(stored["row_counts"], meta["row_counts"])
            entity_ids = {p.entity_id for p in self.fx.people}
            for path in (out / "extracts").glob("*.csv"):
                text = path.read_text()
                header = text.splitlines()[0].split(",")
                self.assertFalse(
                    {"truth_entity_id", "scenario_id", "expected_outcome"} & set(header)
                )
                self.assertFalse(any(e in text for e in entity_ids), path.name)
                self.assertNotIn("S0", "".join(header))


if __name__ == "__main__":
    unittest.main()

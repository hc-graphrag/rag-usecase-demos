import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from demo import load_cases, retrieve, run, score, terms  # noqa: E402


class RetrievalTests(unittest.TestCase):
    def test_six_synthetic_use_cases_retrieve_expected_source(self):
        results = run()
        self.assertEqual(6, len(results))
        for result in results:
            self.assertTrue(result["results"])
            self.assertEqual(
                result["expected_doc_id"],
                result["results"][0]["doc_id"],
                result["case_id"],
            )

    def test_case_filter_selects_one_use_case(self):
        results = run("contracts")
        self.assertEqual(["contracts"], [row["case_id"] for row in results])

    def test_ranking_is_deterministic_on_ties(self):
        case = {
            "documents": [
                {"doc_id": "b", "source": "synthetic://b", "title": "alpha", "text": ""},
                {"doc_id": "a", "source": "synthetic://a", "title": "alpha", "text": ""},
            ]
        }
        self.assertEqual(["a", "b"], [x["doc_id"] for x in retrieve(case, "alpha")])

    def test_empty_query_has_zero_score(self):
        self.assertEqual(0.0, score("", "any text"))

    def test_all_case_ids_are_unique(self):
        cases = load_cases()
        ids = [case["case_id"] for case in cases]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertEqual(6, len(ids))


if __name__ == "__main__":
    unittest.main()

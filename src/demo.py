"""Deterministic lexical retrieval over explicitly synthetic demo cases."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DATA = ROOT / "data" / "synthetic_cases.json"


def terms(text: str) -> set[str]:
    """Return normalized alphanumeric words and Japanese character bigrams."""
    normalized = text.casefold()
    words = set(re.findall(r"[a-z0-9]+", normalized))
    japanese = "".join(re.findall(r"[\u3040-\u30ff\u3400-\u9fff]", normalized))
    words.update(japanese[i : i + 2] for i in range(max(0, len(japanese) - 1)))
    return words


def score(query: str, document: str) -> float:
    q = terms(query)
    if not q:
        return 0.0
    return len(q & terms(document)) / len(q)


def load_cases(path: Path = DEFAULT_DATA) -> list[dict[str, Any]]:
    with path.open(encoding="utf-8") as f:
        payload = json.load(f)
    return payload["cases"]


def retrieve(case: dict[str, Any], query: str, top_k: int = 3) -> list[dict[str, Any]]:
    ranked = [
        {
            "doc_id": doc["doc_id"],
            "source": doc["source"],
            "title": doc["title"],
            "score": score(query, doc["title"] + " " + doc["text"]),
        }
        for doc in case["documents"]
    ]
    return sorted(ranked, key=lambda row: (-row["score"], row["doc_id"]))[:top_k]


def run(case_filter: str = "all", data_path: Path = DEFAULT_DATA) -> list[dict[str, Any]]:
    results = []
    for case in load_cases(data_path):
        if case_filter != "all" and case["case_id"] != case_filter:
            continue
        for query in case["queries"]:
            results.append({
                "case_id": case["case_id"],
                "name": case["name"],
                "query_id": query["query_id"],
                "query": query["text"],
                "expected_doc_id": query["expected_doc_id"],
                "results": retrieve(case, query["text"]),
            })
    return results


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", default="all", help="case id or all")
    parser.add_argument("--data", type=Path, default=DEFAULT_DATA)
    args = parser.parse_args()
    print(json.dumps(run(args.case, args.data), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

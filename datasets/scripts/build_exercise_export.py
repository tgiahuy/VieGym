#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import re
import sys
import unicodedata
from collections import defaultdict, deque
from pathlib import Path
from typing import Any

from common import DATASETS_ROOT, load_json, sha256_file, write_json


DIFFICULTY_MAPPING = {
    "beginner": "BEGINNER",
    "intermediate": "INTERMEDIATE",
    "expert": "ADVANCED",
}


def normalized_text(value: str) -> str:
    decomposed = unicodedata.normalize("NFD", value)
    ascii_value = "".join(character for character in decomposed if unicodedata.category(character) != "Mn")
    return re.sub(r"[^a-z0-9]+", " ", ascii_value.lower()).strip()


def slug(value: str) -> str:
    return normalized_text(value).replace(" ", "-")


def record_checksum(record: dict[str, Any]) -> str:
    canonical = __import__("json").dumps(record, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def select_candidates(
    raw_records: list[dict[str, Any]],
    reviews: dict[str, Any],
    equipment_mapping: dict[str, str],
    muscle_mapping: dict[str, str],
    limit: int,
) -> list[dict[str, Any]]:
    eligible = []
    by_id = {record["id"]: record for record in raw_records}
    for review_id in reviews:
        if review_id not in by_id:
            raise ValueError(f"Reviewed Exercise does not exist in pinned source: {review_id}")

    for record in raw_records:
        equipment = record.get("equipment")
        primary = record.get("primaryMuscles") or []
        secondary = record.get("secondaryMuscles") or []
        if record.get("category") != "strength":
            continue
        if equipment not in equipment_mapping or not primary:
            continue
        if any(muscle not in muscle_mapping for muscle in [*primary, *secondary]):
            continue
        if record.get("level") not in DIFFICULTY_MAPPING:
            continue
        if not record.get("instructions"):
            continue
        eligible.append(record)

    selected: list[dict[str, Any]] = []
    selected_ids: set[str] = set()
    for review_id in sorted(reviews):
        record = by_id[review_id]
        if record not in eligible:
            raise ValueError(f"Reviewed Exercise is not eligible under canonical mappings: {review_id}")
        selected.append(record)
        selected_ids.add(review_id)

    buckets: dict[str, deque[dict[str, Any]]] = defaultdict(deque)
    for record in sorted(eligible, key=lambda item: item["id"]):
        if record["id"] not in selected_ids:
            muscle_code = muscle_mapping[record["primaryMuscles"][0]]
            buckets[muscle_code].append(record)

    muscle_codes = sorted(buckets)
    while len(selected) < limit and any(buckets.values()):
        for muscle_code in muscle_codes:
            if buckets[muscle_code] and len(selected) < limit:
                record = buckets[muscle_code].popleft()
                selected.append(record)
                selected_ids.add(record["id"])
    if len(selected) != limit:
        raise ValueError(f"Only {len(selected)} eligible records found; expected {limit}")
    return selected


def transform_record(
    raw: dict[str, Any],
    review: dict[str, Any] | None,
    equipment_mapping: dict[str, str],
    muscle_mapping: dict[str, str],
    equipment_overrides: dict[str, list[str]],
    aliases: dict[str, list[str]],
    source_version: str,
) -> dict[str, Any]:
    verified = review is not None
    name_vi = review["nameVi"] if review else None
    display_name = name_vi or raw["name"]
    equipment_codes = [equipment_mapping[raw["equipment"]], *equipment_overrides.get(raw["id"], [])]
    equipment_codes = list(dict.fromkeys(equipment_codes))
    muscle_groups = [
        {"code": muscle_mapping[muscle], "role": "PRIMARY"}
        for muscle in raw["primaryMuscles"]
    ]
    primary_codes = {item["code"] for item in muscle_groups}
    muscle_groups.extend(
        {"code": muscle_mapping[muscle], "role": "SECONDARY"}
        for muscle in raw.get("secondaryMuscles") or []
        if muscle_mapping[muscle] not in primary_codes
    )
    search_parts = [display_name, raw["name"], *(aliases.get(raw["id"]) or [])]
    result = {
        "commonMistakes": review["commonMistakesVi"] if review else [],
        "description": review["descriptionVi"] if review else f"Exercise candidate: {raw['name']}.",
        "difficulty": DIFFICULTY_MAPPING[raw["level"]],
        "equipment": [{"code": code, "required": True} for code in sorted(equipment_codes)],
        "importKey": f"FREE_EXERCISE_DB:{raw['id']}",
        "instructionSteps": review["instructionStepsVi"] if review else list(raw["instructions"]),
        "media": [],
        "muscleGroups": sorted(muscle_groups, key=lambda item: (item["role"], item["code"])),
        "name": display_name,
        "nameEn": raw["name"],
        "nameVi": name_vi,
        "safetyNotes": review["safetyNotesVi"] if review else [],
        "searchName": normalized_text(" ".join(search_parts))[:180],
        "slug": slug(raw["id"])[:200],
        "source": "FREE_EXERCISE_DB",
        "sourceExternalId": raw["id"],
        "sourceVersion": source_version,
        "verified": verified,
        "visibility": "PUBLIC" if verified else "HIDDEN",
    }
    result["recordChecksum"] = record_checksum(result)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the deterministic VieGym Exercise export")
    parser.add_argument("--limit", type=int, default=120)
    parser.add_argument(
        "--output",
        type=Path,
        default=DATASETS_ROOT / "exports" / "viegym_exercises_v1.json",
    )
    args = parser.parse_args()
    manifest = load_json(DATASETS_ROOT / "manifests" / "exercise_sources.json")
    source = next(item for item in manifest["sources"] if item["source"] == "FREE_EXERCISE_DB")
    raw_path = DATASETS_ROOT / "exercise" / "raw" / source["dataFile"]
    if sha256_file(raw_path) != source["dataSha256"]:
        raise ValueError("Raw source checksum does not match the pinned manifest")

    raw_records = load_json(raw_path)
    equipment_mapping = load_json(DATASETS_ROOT / "exercise" / "mappings" / "equipment_mapping.json")
    muscle_mapping = load_json(DATASETS_ROOT / "exercise" / "mappings" / "muscle_mapping.json")
    equipment_overrides = load_json(
        DATASETS_ROOT / "exercise" / "mappings" / "multi_equipment_overrides.json"
    )
    aliases = load_json(DATASETS_ROOT / "exercise" / "mappings" / "exercise_aliases.json")
    reviews = load_json(DATASETS_ROOT / "exercise" / "review" / "golden_reviews.json")
    selected = select_candidates(raw_records, reviews, equipment_mapping, muscle_mapping, args.limit)
    records = [
        transform_record(
            raw,
            reviews.get(raw["id"]),
            equipment_mapping,
            muscle_mapping,
            equipment_overrides,
            aliases,
            source["commitSha"],
        )
        for raw in selected
    ]
    records.sort(key=lambda record: record["importKey"])
    export = {
        "datasetVersion": manifest["datasetVersion"],
        "records": records,
        "schemaVersion": 1,
    }
    write_json(args.output, export)
    report = {
        "datasetVersion": manifest["datasetVersion"],
        "exportSha256": sha256_file(args.output),
        "hiddenPendingReview": sum(record["visibility"] == "HIDDEN" for record in records),
        "publicVerified": sum(record["visibility"] == "PUBLIC" for record in records),
        "recordCount": len(records),
    }
    write_json(DATASETS_ROOT / "exercise" / "processed" / "build_report.json", report)
    print(
        f"Built {len(records)} records ({report['publicVerified']} PUBLIC, "
        f"{report['hiddenPendingReview']} HIDDEN) -> {args.output}"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"build failed: {error}", file=sys.stderr)
        raise SystemExit(1)

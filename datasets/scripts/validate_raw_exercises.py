#!/usr/bin/env python3
from __future__ import annotations

import sys
from collections import Counter

from common import DATASETS_ROOT, load_json, write_json


REQUIRED_FIELDS = {
    "id",
    "name",
    "level",
    "primaryMuscles",
    "secondaryMuscles",
    "instructions",
    "category",
}


def main() -> int:
    raw_path = DATASETS_ROOT / "exercise" / "raw" / "free_exercise_db.json"
    records = load_json(raw_path)
    if not isinstance(records, list) or not records:
        raise ValueError("Raw Exercise source must be a non-empty JSON array")

    ids: Counter[str] = Counter()
    missing: Counter[str] = Counter()
    empty: Counter[str] = Counter()
    equipment: Counter[str] = Counter()
    muscles: Counter[str] = Counter()
    invalid_records: list[str] = []
    for index, record in enumerate(records):
        if not isinstance(record, dict):
            invalid_records.append(f"index:{index}")
            continue
        record_id = str(record.get("id", f"index:{index}"))
        ids[record_id] += 1
        for field in REQUIRED_FIELDS:
            if field not in record:
                missing[field] += 1
            elif record[field] in (None, "", []):
                empty[field] += 1
        equipment[str(record.get("equipment") or "<null>")] += 1
        for muscle in record.get("primaryMuscles") or []:
            muscles[str(muscle)] += 1
        for muscle in record.get("secondaryMuscles") or []:
            muscles[str(muscle)] += 1

    duplicates = sorted(record_id for record_id, count in ids.items() if count > 1)
    report = {
        "duplicateIds": duplicates,
        "equipmentCounts": dict(sorted(equipment.items())),
        "emptyFieldCounts": dict(sorted(empty.items())),
        "invalidRecords": invalid_records,
        "missingRequiredFieldCounts": dict(sorted(missing.items())),
        "muscleCounts": dict(sorted(muscles.items())),
        "recordCount": len(records),
        "valid": not duplicates and not invalid_records and not missing,
    }
    report_path = DATASETS_ROOT / "exercise" / "processed" / "raw_validation_report.json"
    write_json(report_path, report)
    if not report["valid"]:
        raise ValueError(f"Raw validation failed; see {report_path}")
    print(f"Validated {len(records)} raw Exercise records -> {report_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"raw validation failed: {error}", file=sys.stderr)
        raise SystemExit(1)

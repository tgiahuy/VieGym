#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
import sys
from collections import Counter

from common import DATASETS_ROOT, load_json, write_json


DIFFICULTIES = {"BEGINNER", "INTERMEDIATE", "ADVANCED"}
VISIBILITIES = {"PUBLIC", "HIDDEN"}
ROLES = {"PRIMARY", "SECONDARY"}


def main() -> int:
    export_path = DATASETS_ROOT / "exports" / "viegym_exercises_v1.json"
    export = load_json(export_path)
    records = export.get("records")
    if not isinstance(records, list) or not records:
        raise ValueError("Processed export must contain a non-empty records array")

    errors: list[str] = []
    import_keys: Counter[str] = Counter()
    slugs: Counter[str] = Counter()
    for record in records:
        key = str(record.get("importKey"))
        import_keys[key] += 1
        slugs[str(record.get("slug"))] += 1
        if record.get("difficulty") not in DIFFICULTIES:
            errors.append(f"{key}: invalid difficulty")
        if record.get("visibility") not in VISIBILITIES:
            errors.append(f"{key}: invalid visibility")
        if not record.get("name") or not record.get("searchName") or not record.get("description"):
            errors.append(f"{key}: missing canonical text")
        if not any(muscle.get("role") == "PRIMARY" for muscle in record.get("muscleGroups", [])):
            errors.append(f"{key}: missing PRIMARY muscle")
        if any(muscle.get("role") not in ROLES or not muscle.get("code") for muscle in record.get("muscleGroups", [])):
            errors.append(f"{key}: invalid muscle mapping")
        if any(not item.get("code") for item in record.get("equipment", [])):
            errors.append(f"{key}: invalid equipment mapping")
        if record.get("media"):
            errors.append(f"{key}: media must be disabled")
        checksum_record = dict(record)
        expected_checksum = checksum_record.pop("recordChecksum", None)
        canonical = json.dumps(
            checksum_record, ensure_ascii=False, sort_keys=True, separators=(",", ":")
        )
        actual_checksum = hashlib.sha256(canonical.encode("utf-8")).hexdigest()
        if expected_checksum != actual_checksum:
            errors.append(f"{key}: record checksum mismatch")
        if record.get("visibility") == "PUBLIC":
            if not record.get("verified") or not record.get("nameVi"):
                errors.append(f"{key}: PUBLIC record is not Vietnamese-reviewed")
            if not record.get("instructionSteps") or not record.get("safetyNotes"):
                errors.append(f"{key}: PUBLIC record lacks reviewed instructions/safety notes")
            if not re.search(r"[ăâđêôơưáàảãạéèẻẽẹíìỉĩịóòỏõọúùủũụýỳỷỹỵ]", record["nameVi"].lower()):
                # Common Vietnamese gym names may contain no diacritics, so this is informational only.
                pass

    errors.extend(f"duplicate import key: {key}" for key, count in import_keys.items() if count > 1)
    errors.extend(f"duplicate slug: {value}" for value, count in slugs.items() if count > 1)
    by_external_id = {record["sourceExternalId"]: record for record in records}
    golden_equipment = {
        "Barbell_Bench_Press_-_Medium_Grip": {"BARBELL", "BENCH"},
        "Incline_Dumbbell_Press": {"DUMBBELL", "ADJUSTABLE_BENCH"},
        "Pullups": {"BODYWEIGHT", "PULL_UP_BAR"},
    }
    for external_id, required_codes in golden_equipment.items():
        record = by_external_id.get(external_id)
        actual_codes = {item["code"] for item in record.get("equipment", [])} if record else set()
        if not required_codes.issubset(actual_codes):
            errors.append(
                f"golden fixture {external_id}: expected {sorted(required_codes)}, got {sorted(actual_codes)}"
            )
    report = {
        "errors": errors,
        "hiddenPendingReview": sum(record["visibility"] == "HIDDEN" for record in records),
        "publicVerified": sum(record["visibility"] == "PUBLIC" for record in records),
        "recordCount": len(records),
        "valid": not errors,
    }
    report_path = DATASETS_ROOT / "exercise" / "processed" / "processed_validation_report.json"
    write_json(report_path, report)
    if errors:
        raise ValueError(f"Processed validation failed with {len(errors)} error(s); see {report_path}")
    print(f"Validated {len(records)} processed Exercise records -> {report_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"processed validation failed: {error}", file=sys.stderr)
        raise SystemExit(1)

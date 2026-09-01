#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
import urllib.request
from pathlib import Path

from common import DATASETS_ROOT, load_json, sha256_file


def download(url: str, destination: Path, expected_sha256: str) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    partial = destination.with_suffix(destination.suffix + ".part")
    request = urllib.request.Request(url, headers={"User-Agent": "VieGym-Dataset-Importer/1.0"})
    with urllib.request.urlopen(request, timeout=60) as response, partial.open("wb") as output:
        while chunk := response.read(1024 * 1024):
            output.write(chunk)
    actual = sha256_file(partial)
    if actual != expected_sha256:
        partial.unlink(missing_ok=True)
        raise ValueError(f"Checksum mismatch for {url}: expected {expected_sha256}, got {actual}")
    partial.replace(destination)


def main() -> int:
    parser = argparse.ArgumentParser(description="Fetch pinned Exercise metadata snapshots")
    parser.add_argument(
        "--manifest",
        type=Path,
        default=DATASETS_ROOT / "manifests" / "exercise_sources.json",
    )
    args = parser.parse_args()
    manifest = load_json(args.manifest)
    included = [source for source in manifest["sources"] if source.get("included")]
    if not included:
        raise ValueError("Manifest has no included Exercise source")

    for source in included:
        if source.get("mediaAllowed"):
            raise ValueError(f"Media must remain disabled for {source['source']}")
        destination = DATASETS_ROOT / "exercise" / "raw" / source["dataFile"]
        download(source["dataUrl"], destination, source["dataSha256"])
        license_snapshot = DATASETS_ROOT / "manifests" / "licenses" / source["licenseFile"]
        if sha256_file(license_snapshot) != source["licenseSha256"]:
            raise ValueError(f"Committed license snapshot mismatch for {source['source']}")
        print(f"Fetched {source['source']} -> {destination} ({source['dataSha256']})")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"fetch failed: {error}", file=sys.stderr)
        raise SystemExit(1)

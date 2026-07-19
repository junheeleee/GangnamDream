#!/usr/bin/env python3
"""Gate provenance and human review for promoted high-resolution masters."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import subprocess
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "tools" / "art_master_manifest.json"
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
REQUIRED_REVIEW_CRITERIA = {
    "architecture",
    "props",
    "perspective",
    "lettering",
    "crop",
    "tile_seams",
}
EXPECTED_ENGINE = {
    "name": "Real-ESRGAN ncnn Vulkan",
    "release": "v0.2.5.0",
    "repository_url": "https://github.com/xinntao/Real-ESRGAN/",
    "release_url": "https://github.com/xinntao/Real-ESRGAN/releases/tag/v0.2.5.0",
    "archive_url": "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-macos.zip",
    "license": "BSD-3-Clause",
    "license_url": "https://raw.githubusercontent.com/xinntao/Real-ESRGAN/master/LICENSE",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_size(path: Path) -> tuple[int, int]:
    return png_size_bytes(path.read_bytes()[:24])


def png_size_bytes(data: bytes) -> tuple[int, int]:
    if not data.startswith(PNG_SIGNATURE) or len(data) < 24:
        raise ValueError("not a readable PNG")
    return struct.unpack(">II", data[16:24])


def valid_hash(value: Any) -> bool:
    return isinstance(value, str) and SHA256_RE.fullmatch(value) is not None


def git_source(source_ref: str, relative: str) -> tuple[bytes | None, str]:
    result = subprocess.run(
        ["git", "show", f"{source_ref}:{relative}"],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        return None, result.stderr.decode("utf-8", errors="replace").strip()
    return result.stdout, ""


def audit(manifest_path: Path = MANIFEST) -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    counts = {"assets": 0, "promoted": 0, "full_frame": 0}
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read manifest: {exc}"], counts
    if int(manifest.get("schema_version", 0)) != 1:
        errors.append("unsupported manifest schema")

    engine = manifest.get("engine")
    if not isinstance(engine, dict):
        return errors + ["engine provenance is missing"], counts
    for key, expected in EXPECTED_ENGINE.items():
        if engine.get(key) != expected:
            errors.append(f"engine {key} is not the pinned official value")
    for key in ("archive_sha256", "binary_sha256"):
        if not valid_hash(engine.get(key)):
            errors.append(f"engine {key} is not a SHA-256")
    models = engine.get("models", {})
    if not isinstance(models, dict) or not models:
        errors.append("engine models are missing")
        models = {}
    for model_name, model in models.items():
        if not isinstance(model, dict):
            errors.append(f"model {model_name} provenance is malformed")
            continue
        for key in ("bin_sha256", "param_sha256"):
            if not valid_hash(model.get(key)):
                errors.append(f"model {model_name} {key} is not a SHA-256")

    assets = manifest.get("assets", [])
    if not isinstance(assets, list) or not assets:
        return errors + ["manifest has no art master assets"], counts
    seen_ids: set[str] = set()
    seen_paths: set[str] = set()
    for row in assets:
        counts["assets"] += 1
        if not isinstance(row, dict):
            errors.append("asset row is malformed")
            continue
        asset_id = str(row.get("asset_id", ""))
        relative = str(row.get("path", ""))
        label = asset_id or relative or "<unnamed>"
        runtime = (ROOT / relative).resolve()
        try:
            runtime.relative_to(ROOT.resolve())
        except ValueError:
            errors.append(f"{label}: runtime path escapes the repository")
            continue
        if asset_id in seen_ids:
            errors.append(f"duplicate asset id: {asset_id}")
        if relative in seen_paths:
            errors.append(f"duplicate asset path: {relative}")
        seen_ids.add(asset_id)
        seen_paths.add(relative)
        if row.get("risk_class") != "clean_environment":
            errors.append(f"{label}: blind super-resolution is limited to clean environments")
        if row.get("kind") != "Background" or row.get("priority") != "P0":
            errors.append(f"{label}: pilot promotion must be a P0 Background")
        if row.get("model") not in models:
            errors.append(f"{label}: model is not pinned in engine provenance")
        if not valid_hash(row.get("source_sha256")) or not valid_hash(row.get("output_sha256")):
            errors.append(f"{label}: input/output SHA-256 is missing")
        source_dimensions = row.get("source_dimensions")
        output_dimensions = row.get("output_dimensions")
        if not (
            isinstance(source_dimensions, list)
            and len(source_dimensions) == 2
            and all(isinstance(value, int) and value > 0 for value in source_dimensions)
        ):
            errors.append(f"{label}: source dimensions are invalid")
            continue
        if not (
            isinstance(output_dimensions, list)
            and len(output_dimensions) == 2
            and all(isinstance(value, int) and value > 0 for value in output_dimensions)
        ):
            errors.append(f"{label}: output dimensions are invalid")
            continue
        scale_value = row.get("scale")
        scale = scale_value if type(scale_value) is int else 0
        if scale == 0:
            errors.append(f"{label}: scale is not an integer")
        if scale < 2 or scale > 4:
            errors.append(f"{label}: scale must stay within the reviewed 2x-4x range")
        if output_dimensions != [value * scale for value in source_dimensions]:
            errors.append(f"{label}: output dimensions do not equal the pinned scale")
        if row.get("tile_policy") != "full_frame":
            errors.append(f"{label}: promotable output must use full_frame tiling")
        elif type(row.get("tile_size")) is not int:
            errors.append(f"{label}: full_frame tile size is not an integer")
        elif row["tile_size"] < max(source_dimensions):
            errors.append(f"{label}: full_frame tile is smaller than the source")
        else:
            counts["full_frame"] += 1

        source_ref = str(row.get("source_ref", ""))
        if re.fullmatch(r"[0-9a-f]{7,40}", source_ref) is None:
            errors.append(f"{label}: source_ref is not a pinned Git commit")
        else:
            source_data, source_error = git_source(source_ref, relative)
            if source_data is None:
                errors.append(f"{label}: cannot read reviewed source: {source_error}")
            else:
                if hashlib.sha256(source_data).hexdigest() != row.get("source_sha256"):
                    errors.append(f"{label}: reviewed Git source hash changed")
                try:
                    actual_source_dimensions = list(png_size_bytes(source_data[:24]))
                except ValueError as exc:
                    errors.append(f"{label}: reviewed Git source {exc}")
                else:
                    if actual_source_dimensions != source_dimensions:
                        errors.append(
                            f"{label}: reviewed source dimensions {actual_source_dimensions} != {source_dimensions}"
                        )

        review = row.get("review", {})
        if not isinstance(review, dict):
            errors.append(f"{label}: human review block is malformed")
            review = {}
        if review.get("verdict") != "PASS":
            errors.append(f"{label}: human review verdict is not PASS")
        criteria_value = review.get("criteria", [])
        criteria = set(criteria_value) if isinstance(criteria_value, list) else set()
        missing_criteria = sorted(REQUIRED_REVIEW_CRITERIA - criteria)
        if missing_criteria:
            errors.append(f"{label}: review criteria missing {', '.join(missing_criteria)}")
        crops = review.get("crops", [])
        if not isinstance(crops, list) or len(crops) < 3:
            errors.append(f"{label}: fewer than three 100% review crops")
        else:
            crop_names: set[str] = set()
            for crop in crops:
                box = crop.get("source_box", []) if isinstance(crop, dict) else []
                crop_name = str(crop.get("name", "")) if isinstance(crop, dict) else ""
                if (
                    not crop_name
                    or crop_name in crop_names
                    or not isinstance(box, list)
                    or len(box) != 4
                    or not all(isinstance(value, int) for value in box)
                    or box[0] < 0
                    or box[1] < 0
                    or box[2] <= box[0]
                    or box[3] <= box[1]
                    or box[2] > source_dimensions[0]
                    or box[3] > source_dimensions[1]
                    or crop.get("verdict") != "PASS"
                ):
                    errors.append(f"{label}: invalid or unapproved 100% crop")
                    break
                crop_names.add(crop_name)
        rejected = row.get("rejected_trials", [])
        if not isinstance(rejected, list):
            errors.append(f"{label}: rejected trial ledger is malformed")
            rejected = []
        rejected_by_tile = {
            int(trial.get("tile_size", -1)): trial
            for trial in rejected
            if isinstance(trial, dict) and str(trial.get("tile_size", "")).lstrip("-").isdigit()
        }
        for rejected_tile in (0, 256):
            trial = rejected_by_tile.get(rejected_tile, {})
            if (
                "seam" not in str(trial.get("reason", "")).lower()
                or not valid_hash(trial.get("output_sha256"))
            ):
                errors.append(
                    f"{label}: rejected tile-seam trial {rejected_tile} is not fully documented"
                )

        if row.get("status") == "promoted":
            counts["promoted"] += 1
            if not runtime.is_file():
                errors.append(f"{label}: promoted runtime asset is missing")
                continue
            try:
                actual_dimensions = list(png_size(runtime))
            except ValueError as exc:
                errors.append(f"{label}: {exc}")
                continue
            if actual_dimensions != output_dimensions:
                errors.append(
                    f"{label}: promoted dimensions {actual_dimensions} != {output_dimensions}"
                )
            actual_hash = sha256(runtime)
            if actual_hash != row.get("output_sha256"):
                errors.append(f"{label}: promoted asset changed after review")
        else:
            errors.append(f"{label}: only promoted rows belong in the release manifest")
    return errors, counts


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    args = parser.parse_args()
    errors, counts = audit(args.manifest.resolve())
    for error in errors:
        print("ART_MASTER_AUDIT_ERROR " + error)
    if errors:
        return 1
    print(
        "ART_MASTER_AUDIT_OK assets=%d promoted=%d full_frame=%d"
        % (counts["assets"], counts["promoted"], counts["full_frame"])
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

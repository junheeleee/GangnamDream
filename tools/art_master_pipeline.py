#!/usr/bin/env python3
"""Build reproducible high-resolution art candidates without blind promotion.

The runtime asset is never used as the source after promotion. Instead, the
manifest points at the reviewed pre-upscale Git revision and its SHA-256. This
keeps a promoted master reproducible without checking a duplicate source image
into the repository.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "tools" / "art_master_manifest.json"
DEFAULT_OUTPUT = Path(tempfile.gettempdir()) / "gangnam_art_master_candidates"
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_size_bytes(data: bytes) -> tuple[int, int]:
    if not data.startswith(PNG_SIGNATURE) or len(data) < 24:
        raise ValueError("source is not a readable PNG")
    return struct.unpack(">II", data[16:24])


def png_size(path: Path) -> tuple[int, int]:
    return png_size_bytes(path.read_bytes())


def load_manifest(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if int(payload.get("schema_version", 0)) != 1:
        raise ValueError("unsupported art master manifest schema")
    return payload


def find_asset(manifest: dict[str, Any], asset_id: str) -> dict[str, Any]:
    matches = [row for row in manifest.get("assets", []) if row.get("asset_id") == asset_id]
    if len(matches) != 1:
        raise ValueError(f"expected exactly one manifest row for {asset_id!r}")
    return matches[0]


def require_hash(path: Path, expected: str, label: str) -> None:
    actual = sha256(path)
    if actual != expected:
        raise ValueError(f"{label} hash mismatch: expected {expected}, got {actual}")


def repository_path(relative: str) -> Path:
    path = (ROOT / relative).resolve()
    try:
        path.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError(f"asset path escapes the repository: {relative}") from exc
    return path


def verify_engine(
    manifest: dict[str, Any], engine_path: Path, model_dir: Path, model_name: str
) -> None:
    engine = manifest["engine"]
    if not engine_path.is_file():
        raise ValueError(f"missing engine binary: {engine_path}")
    if not os.access(engine_path, os.X_OK):
        raise ValueError(f"engine is not executable: {engine_path}")
    require_hash(engine_path, str(engine["binary_sha256"]), "engine binary")
    model = engine.get("models", {}).get(model_name)
    if not isinstance(model, dict):
        raise ValueError(f"model is not pinned in manifest: {model_name}")
    require_hash(model_dir / f"{model_name}.bin", str(model["bin_sha256"]), "model bin")
    require_hash(model_dir / f"{model_name}.param", str(model["param_sha256"]), "model param")


def source_from_git(asset: dict[str, Any]) -> bytes:
    source_ref = str(asset["source_ref"])
    relative_path = str(asset["path"])
    repository_path(relative_path)
    result = subprocess.run(
        ["git", "show", f"{source_ref}:{relative_path}"],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        message = result.stderr.decode("utf-8", errors="replace").strip()
        raise ValueError(f"cannot read reviewed source {source_ref}:{relative_path}: {message}")
    actual_hash = hashlib.sha256(result.stdout).hexdigest()
    if actual_hash != asset["source_sha256"]:
        raise ValueError(
            f"reviewed source hash mismatch: expected {asset['source_sha256']}, got {actual_hash}"
        )
    actual_size = list(png_size_bytes(result.stdout))
    if actual_size != asset["source_dimensions"]:
        raise ValueError(
            f"reviewed source dimensions mismatch: expected {asset['source_dimensions']}, got {actual_size}"
        )
    return result.stdout


def write_ab_sheets(source_path: Path, candidate: Path, asset: dict[str, Any], output_dir: Path) -> None:
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError as exc:
        raise RuntimeError("--ab requires Pillow") from exc

    source = Image.open(source_path).convert("RGB")
    master = Image.open(candidate).convert("RGB")
    scale = int(asset["scale"])
    font = ImageFont.load_default(size=22)
    for crop in asset["review"]["crops"]:
        box = tuple(int(value) for value in crop["source_box"])
        baseline = source.crop(box).resize(
            ((box[2] - box[0]) * scale, (box[3] - box[1]) * scale),
            Image.Resampling.LANCZOS,
        )
        master_box = tuple(value * scale for value in box)
        enhanced = master.crop(master_box)
        width, height = baseline.size
        sheet = Image.new("RGB", (width * 2, height + 48), "#111111")
        sheet.paste(baseline, (0, 48))
        sheet.paste(enhanced, (width, 48))
        draw = ImageDraw.Draw(sheet)
        draw.text((16, 12), "ORIGINAL x3 LANCZOS", fill="white", font=font)
        draw.text((width + 16, 12), "REAL-ESRGAN x3 FULL FRAME", fill="white", font=font)
        sheet.save(output_dir / f"{asset['asset_id']}_ab_{crop['name']}.png", optimize=True)


def build(args: argparse.Namespace) -> int:
    manifest_path = args.manifest.resolve()
    manifest = load_manifest(manifest_path)
    asset = find_asset(manifest, args.asset)
    if (
        asset.get("risk_class") != "clean_environment"
        or asset.get("kind") != "Background"
        or asset.get("priority") != "P0"
    ):
        raise ValueError("deterministic super-resolution is limited to reviewed P0 environments")
    engine_path = args.engine.resolve()
    model_dir = args.model_dir.resolve()
    model_name = str(asset["model"])
    verify_engine(manifest, engine_path, model_dir, model_name)
    source_data = source_from_git(asset)

    source_width, source_height = (int(value) for value in asset["source_dimensions"])
    if asset.get("tile_policy") != "full_frame":
        raise ValueError("only the reviewed full_frame tile policy may build a promotable master")
    tile_size = int(asset["tile_size"])
    if tile_size < max(source_width, source_height):
        raise ValueError("full_frame tile is smaller than the reviewed source")

    output_dir = args.output_dir.resolve()
    try:
        output_dir.relative_to(ROOT.resolve())
    except ValueError:
        pass
    else:
        raise ValueError("candidate output must remain outside the Godot project")
    output_dir.mkdir(parents=True, exist_ok=True)
    candidate = output_dir / f"{asset['asset_id']}_{model_name}_{asset['scale']}x.png"
    candidate.unlink(missing_ok=True)

    with tempfile.TemporaryDirectory(prefix="gangnam-art-master-") as temp_dir:
        source_path = Path(temp_dir) / Path(str(asset["path"])).name
        source_path.write_bytes(source_data)
        command = [
            str(engine_path),
            "-i", str(source_path),
            "-o", str(candidate),
            "-s", str(asset["scale"]),
            "-t", str(tile_size),
            "-m", str(model_dir),
            "-n", model_name,
            "-f", "png",
        ]
        subprocess.run(command, cwd=engine_path.parent, check=True)
        if args.ab:
            write_ab_sheets(source_path, candidate, asset, output_dir)

    actual_dimensions = list(png_size(candidate))
    actual_hash = sha256(candidate)
    if actual_dimensions != asset["output_dimensions"]:
        raise ValueError(
            f"candidate dimensions mismatch: expected {asset['output_dimensions']}, got {actual_dimensions}"
        )
    if actual_hash != asset["output_sha256"]:
        raise ValueError(
            f"candidate hash mismatch: expected {asset['output_sha256']}, got {actual_hash}"
        )

    evidence = {
        "schema_version": 1,
        "asset_id": asset["asset_id"],
        "source_ref": asset["source_ref"],
        "source_sha256": asset["source_sha256"],
        "model": model_name,
        "scale": asset["scale"],
        "tile_size": tile_size,
        "engine_sha256": manifest["engine"]["binary_sha256"],
        "output_dimensions": actual_dimensions,
        "output_sha256": actual_hash,
    }
    evidence_path = output_dir / f"{asset['asset_id']}_evidence.json"
    evidence_path.write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if args.promote:
        if not args.human_review_pass:
            raise ValueError("--promote requires --human-review-pass after 100% A/B inspection")
        if asset.get("status") != "promoted" or asset.get("review", {}).get("verdict") != "PASS":
            raise ValueError("manifest does not contain a completed human PASS verdict")
        destination = repository_path(str(asset["path"]))
        shutil.copy2(candidate, destination)
        require_hash(destination, str(asset["output_sha256"]), "promoted runtime asset")
        print(f"ART_MASTER_PROMOTED {destination.relative_to(ROOT)}")

    print(
        "ART_MASTER_BUILD_OK asset=%s dimensions=%dx%d sha256=%s"
        % (asset["asset_id"], actual_dimensions[0], actual_dimensions[1], actual_hash)
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    subparsers = parser.add_subparsers(dest="command", required=True)
    builder = subparsers.add_parser("build")
    builder.add_argument("asset")
    builder.add_argument("--engine", type=Path, required=True)
    builder.add_argument("--model-dir", type=Path, required=True)
    builder.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT)
    builder.add_argument("--ab", action="store_true")
    builder.add_argument("--promote", action="store_true")
    builder.add_argument("--human-review-pass", action="store_true")
    builder.set_defaults(handler=build)
    args = parser.parse_args()
    try:
        return int(args.handler(args))
    except (KeyError, OSError, RuntimeError, ValueError, subprocess.SubprocessError) as exc:
        print(f"ART_MASTER_BUILD_FAIL {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Offline crop of eight receipt-bound store captures; never starts Godot.

Requires Pillow for PNG decoding. Receipts are caller assertions: hashes bind
bytes, not capture provenance, visual correctness, or release approval.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import io
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile

from store_shot_check import EXPECTED

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "tools/StoreScreenshotExport.gd"
MAX_BYTES = 20 * 1024 * 1024
SOURCE_SIZE = (1280, 800)
CROP = (0, 40, 1280, 760)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_regular(path: Path) -> bytes:
    # Refuse final-component symlinks/FIFOs rather than following/blocking.
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, "rb") as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
            raise ValueError(f"not a regular file: {path}")
        data = stream.read(MAX_BYTES + 1)
    if len(data) > MAX_BYTES:
        raise ValueError(f"file exceeds {MAX_BYTES} bytes: {path}")
    return data


def load_contract() -> tuple[list[dict], str]:
    """Read the existing eight captions without booting its legacy scene."""
    raw = read_regular(CONTRACT)
    match = re.search(r"const STORE_SET := (\[.*?\n\])", raw.decode(), re.S)
    if not match:
        raise ValueError("missing canonical STORE_SET")
    entries = ast.literal_eval(match.group(1))
    if not isinstance(entries, list) or len(entries) != 8:
        raise ValueError("canonical STORE_SET must contain eight entries")
    for entry, dst in zip(entries, EXPECTED):
        if (not isinstance(entry, dict) or set(entry) != {"src", "dst", "ko", "en"}
                or entry["dst"] != dst or entry["src"] != "store_en_" + dst
                or any(not isinstance(v, str) or not v.strip() for v in entry.values())):
            raise ValueError("canonical store names/captions changed; review contract")
    return entries, sha(raw)


def object_keys(value: object, keys: set[str], label: str) -> dict:
    if not isinstance(value, dict) or set(value) != keys:
        raise ValueError(f"invalid {label} fields; expected {sorted(keys)}")
    return value


def digest(value: object, length: int = 64) -> str:
    if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{%d}" % length, value):
        raise ValueError(f"expected {length}-character lowercase hex digest")
    return value


def json_bytes(value: object) -> bytes:
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode()


def write_new(path: Path, data: bytes) -> None:
    with path.open("xb") as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())
    if read_regular(path) != data:
        raise OSError(f"output readback mismatch: {path}")


def export(manifest_path: Path, output_parent: Path) -> Path:
    try:
        from PIL import Image
    except ImportError as exc:
        raise ValueError("offline export requires Python with Pillow; no game was started") from exc

    # Keep all validation/decoding before creating any output directory.
    if manifest_path.is_symlink():
        raise ValueError("source manifest must not be a symlink")
    manifest_path = manifest_path.resolve(strict=True)
    source = manifest_path.parent
    parent = output_parent.resolve(strict=True)
    if not parent.is_dir() or parent == source or source in parent.parents:
        raise ValueError("output parent must be an existing directory outside the source directory")
    if parent == ROOT or ROOT in parent.parents:
        raise ValueError("output parent must be outside the repository")

    contract, contract_sha = load_contract()
    raw_manifest = read_regular(manifest_path)
    receipt = object_keys(json.loads(raw_manifest),
                          {"schema_version", "language", "candidate", "capture_record", "frames"}, "receipt")
    if type(receipt["schema_version"]) is not int or receipt["schema_version"] != 1 or receipt["language"] != "en":
        raise ValueError("receipt must be schema_version=1, language=en")
    candidate = object_keys(receipt["candidate"], {"source_commit", "source_tree", "build_id"}, "candidate")
    digest(candidate["source_commit"], 40)
    digest(candidate["source_tree"], 40)
    if not isinstance(candidate["build_id"], str) or not re.fullmatch(r"[A-Za-z0-9._-]{1,80}", candidate["build_id"]):
        raise ValueError("invalid build_id")
    capture = object_keys(receipt["capture_record"], {"file", "sha256"}, "capture_record")
    name = capture["file"]
    if not isinstance(name, str) or not re.fullmatch(r"[A-Za-z0-9_-][A-Za-z0-9._-]*", name):
        raise ValueError("capture_record.file must be a plain filename")
    if name == manifest_path.name or name.lower().endswith(".png"):
        raise ValueError("capture record must be separate from receipt and PNGs")
    capture_bytes = read_regular(source / name)
    if not capture_bytes or sha(capture_bytes) != digest(capture["sha256"]):
        raise ValueError("capture record is empty or hash differs")
    frames = receipt["frames"]
    if not isinstance(frames, list) or len(frames) != 8:
        raise ValueError("receipt needs exactly eight ordered frames")
    expected_sources = [entry["src"] for entry in contract]
    actual = sorted(p.name for p in source.iterdir() if p.suffix.lower() == ".png")
    if actual != sorted(expected_sources):
        raise ValueError("source PNG roster differs from the canonical eight frames")

    prepared = []
    source_hashes, output_hashes = set(), set()
    for entry, frame in zip(contract, frames):
        object_keys(frame, {"file", "sha256"}, "frame")
        if frame["file"] != entry["src"]:
            raise ValueError("frame order/name differs from canonical shotlist")
        data = read_regular(source / entry["src"])
        source_sha = sha(data)
        if source_sha != digest(frame["sha256"]) or source_sha in source_hashes:
            raise ValueError(f"source hash mismatch or duplicate: {entry['src']}")
        with Image.open(io.BytesIO(data)) as image:
            if (image.format != "PNG" or image.size != SOURCE_SIZE
                    or image.mode not in ("RGB", "RGBA") or getattr(image, "n_frames", 1) != 1):
                raise ValueError(f"expected single RGB/RGBA PNG 1280x800: {entry['src']}")
            image.verify()
        with Image.open(io.BytesIO(data)) as image:
            image.load()
            cropped = image.crop(CROP)
            buffer = io.BytesIO()
            cropped.save(buffer, format="PNG")
        output_bytes = buffer.getvalue()
        output_sha = sha(output_bytes)
        if output_sha in output_hashes:
            raise ValueError("duplicate cropped frames")
        source_hashes.add(source_sha)
        output_hashes.add(output_sha)
        prepared.append((output_bytes, {
            "file": entry["dst"], "sha256": output_sha, "bytes": len(output_bytes),
            "source": entry["src"], "source_sha256": source_sha, "source_bytes": len(data),
            "source_size": list(SOURCE_SIZE), "crop_box": list(CROP), "size": [1280, 720],
            "caption_ko": entry["ko"], "caption_en": entry["en"],
        }))

    out = Path(tempfile.mkdtemp(prefix="gangnam-store-export-", dir=parent))
    try:
        write_new(out / "source-manifest.json", raw_manifest)
        write_new(out / "capture-record.bin", capture_bytes)
        for data, entry in prepared:
            write_new(out / entry["file"], data)
        complete = {
            "schema_version": 1, "scope": "offline_crop_only", "language": "en",
            "candidate_claim": candidate, "source_directory": str(source),
            "source_manifest_sha256": sha(raw_manifest), "capture_record": capture,
            "capture_record_copy": "capture-record.bin", "contract_sha256": contract_sha,
            "exporter_sha256": sha(read_regular(Path(__file__).resolve())),
            "unverified": ["capture_provenance", "candidate_match", "capture_isolation",
                           "visual_quality", "release_approval"],
            "frames": [entry for _, entry in prepared],
        }
        pending = out / "manifest.pending.json"
        write_new(pending, json_bytes(complete))
        # Publish only after every payload and the receipt have passed readback.
        # link is exclusive: a pre-existing completion file can never be overwritten.
        os.link(pending, out / "manifest.json")
    except Exception as exc:
        raise ValueError(f"export incomplete; preserve partial output at {out}: {exc}") from exc
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--output-parent", type=Path, required=True)
    args = parser.parse_args()
    try:
        out = export(args.manifest, args.output_parent)
    except (OSError, ValueError, SyntaxError) as exc:
        print(f"STORE_SHOT_EXPORT_ERROR {exc}", file=sys.stderr)
        return 1
    print(f"STORE_SHOT_EXPORT_OK count=8 size=1280x720 scope=offline_crop_only dir={out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

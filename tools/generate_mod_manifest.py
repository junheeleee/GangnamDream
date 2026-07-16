#!/usr/bin/env python3
"""Generate the deterministic visual/audio replacement manifest for asset mods."""

from __future__ import annotations

import argparse
import json
import re
import struct
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "autoloads" / "ImageRegistry.gd"
OUTPUT = ROOT / "assets" / "mod_asset_manifest.json"
DOC = ROOT / "docs" / "MODDING.md"
BEGIN = "<!-- BEGIN GENERATED ASSET MANIFEST -->"
END = "<!-- END GENERATED ASSET MANIFEST -->"


def block(source: str, name: str) -> str:
    match = re.search(rf"^const {re.escape(name)}\s*=\s*\{{(.*?)^\}}", source, re.M | re.S)
    if not match:
        raise ValueError(f"missing dictionary {name}")
    return match.group(1)


def dictionary_entries(source: str, name: str) -> list[tuple[str, str]]:
    return re.findall(
        r'"([^"]+)"\s*:\s*"(res://assets/[^"]+)"',
        block(source, name),
    )


def image_size(path: Path) -> tuple[int, int] | None:
    data = path.read_bytes()
    if data.startswith(b"\x89PNG\r\n\x1a\n") and len(data) >= 24:
        return struct.unpack(">II", data[16:24])
    if data.startswith(b"\xff\xd8"):
        offset = 2
        while offset + 9 < len(data):
            if data[offset] != 0xFF:
                offset += 1
                continue
            marker = data[offset + 1]
            offset += 2
            if marker in (0xD8, 0xD9):
                continue
            if offset + 2 > len(data):
                break
            length = int.from_bytes(data[offset : offset + 2], "big")
            if marker in range(0xC0, 0xC4) and offset + 7 < len(data):
                return (
                    int.from_bytes(data[offset + 5 : offset + 7], "big"),
                    int.from_bytes(data[offset + 3 : offset + 5], "big"),
                )
            offset += max(2, length)
    if path.suffix.lower() == ".svg":
        text = data.decode("utf-8", errors="ignore")[:4096]
        width = re.search(r'\bwidth=["\']([0-9.]+)', text)
        height = re.search(r'\bheight=["\']([0-9.]+)', text)
        if width and height:
            return int(float(width.group(1))), int(float(height.group(1)))
        view_box = re.search(r'\bviewBox=["\'][^"\']*?([0-9.]+)\s+([0-9.]+)["\']', text)
        if view_box:
            return int(float(view_box.group(1))), int(float(view_box.group(2)))
    return None


def visual_rows() -> list[dict]:
    source = REGISTRY.read_text(encoding="utf-8")
    groups: dict[tuple[str, str], set[str]] = defaultdict(set)
    for kind, constant in (
        ("portrait", "PORTRAITS"),
        ("background", "BACKGROUNDS"),
        ("cg", "CG"),
    ):
        for asset_id, full_path in dictionary_entries(source, constant):
            groups[(kind, full_path.removeprefix("res://assets/"))].add(asset_id)
    for constant, full_path in re.findall(
        r'^const (PLAYER_[A-Z_]+)\s*=\s*"(res://assets/characters/[^"]+)"',
        source,
        re.M,
    ):
        groups[("portrait", full_path.removeprefix("res://assets/"))].add(constant.lower())

    rows = []
    for (kind, relative), ids in sorted(groups.items()):
        source_path = ROOT / "assets" / relative
        size = image_size(source_path) if source_path.exists() else None
        rows.append(
            {
                "kind": kind,
                "ids": sorted(ids),
                "relative_path": relative,
                "resolution": f"{size[0]}x{size[1]}" if size else "unknown",
            }
        )
    return rows


def audio_rows() -> list[dict]:
    groups: dict[str, set[str]] = defaultdict(set)
    for filename in ("AudioManager.gd", "BGMPlayer.gd"):
        source = (ROOT / "autoloads" / filename).read_text(encoding="utf-8")
        for asset_id, full_path in re.findall(
            r'"([^"]+)"\s*:\s*"(res://assets/audio/[^"]+)"', source
        ):
            groups[full_path.removeprefix("res://assets/")].add(asset_id)
    return [
        {
            "ids": sorted(ids),
            "relative_path": relative,
            "bytes": (ROOT / "assets" / relative).stat().st_size
            if (ROOT / "assets" / relative).exists()
            else 0,
        }
        for relative, ids in sorted(groups.items())
    ]


def manifest() -> dict:
    return {
        "version": 1,
        "override_root": "user://mods/assets/",
        "policy": "Exact relative paths only; invalid or absent replacements fall back to built-in assets.",
        "visuals": visual_rows(),
        "audio": audio_rows(),
    }


def markdown_table(rows: list[dict]) -> str:
    lines = [
        BEGIN,
        "| Type | Runtime ID(s) | Relative path | Resolution |",
        "|---|---|---|---:|",
    ]
    for row in rows:
        ids = ", ".join(f"`{item}`" for item in row["ids"])
        lines.append(
            f"| {row['kind']} | {ids} | `{row['relative_path']}` | {row['resolution']} |"
        )
    lines.append(END)
    return "\n".join(lines)


def rendered_doc(current: str, rows: list[dict]) -> str:
    if BEGIN not in current or END not in current:
        raise ValueError("MODDING.md is missing generated manifest markers")
    prefix, rest = current.split(BEGIN, 1)
    _, suffix = rest.split(END, 1)
    return prefix + markdown_table(rows) + suffix


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    data = manifest()
    output_text = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    current_doc = DOC.read_text(encoding="utf-8")
    doc_text = rendered_doc(current_doc, data["visuals"])
    if args.check:
        failures = []
        if not OUTPUT.exists() or OUTPUT.read_text(encoding="utf-8") != output_text:
            failures.append(str(OUTPUT.relative_to(ROOT)))
        if current_doc != doc_text:
            failures.append(str(DOC.relative_to(ROOT)))
        if failures:
            print("MOD_MANIFEST_STALE " + ", ".join(failures))
            return 1
        print(
            f"MOD_MANIFEST_OK visuals={len(data['visuals'])} audio={len(data['audio'])}"
        )
        return 0
    OUTPUT.write_text(output_text, encoding="utf-8")
    DOC.write_text(doc_text, encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)} and {DOC.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

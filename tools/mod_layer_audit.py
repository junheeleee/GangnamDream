#!/usr/bin/env python3
"""Audit Gangnam Dream's data-only community translation and asset layer."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVENT_ALLOWED = {
    "id", "title", "description", "subtitle", "description_orthodox",
    "description_unorthodox", "description_low_mental", "description_long_gosiwon",
    "description_long_apartment", "description_if_known",
    "description_memory_if_known", "description_if_moral", "choices",
}
CHOICE_ALLOWED = {"text", "result_text", "tooltip", "text_if_moral"}
ENDING_ALLOWED = {
    "id", "title", "subtitle", "description", "detailed_description", "epilogue",
    "condition", "description_if_known",
}


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"{path}: {exc}") from exc


def validate_text_dict(label: str, value, errors: list[str]) -> None:
    if not isinstance(value, dict) or not all(
        isinstance(key, str) and isinstance(text, str) for key, text in value.items()
    ):
        errors.append(f"{label}: expected string-to-string object")


def validate_pack(pack: Path) -> list[str]:
    errors: list[str] = []
    code = pack.name
    if not re.fullmatch(r"[A-Za-z0-9-]{2,24}", code):
        errors.append(f"unsafe language code directory: {code}")
        return errors
    ui_path = pack / f"ui_{code}.json"
    if ui_path.exists():
        ui = read_json(ui_path)
        if not isinstance(ui, dict) or not all(
            isinstance(key, str) and isinstance(value, str) for key, value in ui.items()
        ):
            errors.append(f"{ui_path}: UI table must contain strings only")
    event_dir = pack / f"events_{code}"
    if event_dir.exists():
        for path in sorted(event_dir.glob("*.json")):
            rows = read_json(path)
            if not isinstance(rows, list):
                errors.append(f"{path}: expected array")
                continue
            for index, row in enumerate(rows):
                label = f"{path}:{index}"
                if not isinstance(row, dict):
                    errors.append(f"{label}: expected object")
                    continue
                unknown = set(row) - EVENT_ALLOWED
                if unknown:
                    errors.append(f"{label}: gameplay/non-text keys forbidden: {sorted(unknown)}")
                if not isinstance(row.get("id"), str) or not row.get("id"):
                    errors.append(f"{label}: missing id")
                for key in (
                    "description_if_known",
                    "description_memory_if_known",
                    "description_if_moral",
                ):
                    if key in row:
                        validate_text_dict(f"{label}:{key}", row[key], errors)
                for choice_index, choice in enumerate(row.get("choices", [])):
                    choice_label = f"{label}:choice{choice_index}"
                    if not isinstance(choice, dict):
                        errors.append(f"{choice_label}: expected object")
                        continue
                    unknown_choice = set(choice) - CHOICE_ALLOWED
                    if unknown_choice:
                        errors.append(
                            f"{choice_label}: gameplay/non-text keys forbidden: {sorted(unknown_choice)}"
                        )
                    if "text_if_moral" in choice:
                        validate_text_dict(
                            f"{choice_label}:text_if_moral", choice["text_if_moral"], errors
                        )
    endings_path = pack / f"endings_{code}.json"
    if endings_path.exists():
        rows = read_json(endings_path)
        if not isinstance(rows, list):
            errors.append(f"{endings_path}: expected array")
        else:
            for index, row in enumerate(rows):
                label = f"{endings_path}:{index}"
                if not isinstance(row, dict):
                    errors.append(f"{label}: expected object")
                    continue
                unknown = set(row) - ENDING_ALLOWED
                if unknown:
                    errors.append(f"{label}: gameplay/non-text keys forbidden: {sorted(unknown)}")
                if "description_if_known" in row:
                    validate_text_dict(
                        f"{label}:description_if_known", row["description_if_known"], errors
                    )
    if not event_dir.exists() and not endings_path.exists() and not ui_path.exists():
        errors.append("pack contains none of the supported language files")
    return errors


def validate_repository() -> list[str]:
    errors: list[str] = []
    loader = (ROOT / "autoloads" / "ModLoader.gd").read_text(encoding="utf-8")
    if 'const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg"]' not in loader:
        errors.append("image extension allowlist changed or missing")
    if 'const AUDIO_EXTENSIONS := ["wav", "ogg", "mp3"]' not in loader:
        errors.append("audio extension allowlist changed or missing")
    if re.search(r'(load|preload)\([^\n]*user://', loader):
        errors.append("direct user:// script/resource loading detected")
    docs = (ROOT / "docs" / "MODDING.md").read_text(encoding="utf-8")
    for phrase in (
        "user://lang/<code>/",
        "user://mods/assets/",
        "스크립트 모딩은 지원하지 않습니다",
        "Community translations and asset mods supported.",
    ):
        if phrase not in docs:
            errors.append(f"MODDING.md missing: {phrase}")
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "generate_mod_manifest.py"), "--check"],
        cwd=ROOT, capture_output=True, text=True,
    )
    if result.returncode:
        errors.append(result.stdout.strip() or result.stderr.strip() or "manifest check failed")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pack", type=Path, help="Validate one user language directory")
    args = parser.parse_args()
    try:
        errors = validate_pack(args.pack.expanduser().resolve()) if args.pack else validate_repository()
    except ValueError as exc:
        errors = [str(exc)]
    if errors:
        for error in errors:
            print("MOD_LAYER_AUDIT_ERROR", error)
        return 1
    scope = f"pack={args.pack}" if args.pack else "repository"
    print(f"MOD_LAYER_AUDIT_OK {scope} scripts=0 text_only=1 exact_paths=1")
    return 0


if __name__ == "__main__":
    sys.exit(main())

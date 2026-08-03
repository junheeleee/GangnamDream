#!/usr/bin/env python3
"""Generate and audit the runtime third-party notice ledger.

The runtime JSON is a deterministic view of existing source records. Provider,
license, and attribution facts stay in their owning ledgers instead of being
copied into UI code.

    python3 tools/third_party_notice_audit.py --write
    python3 tools/third_party_notice_audit.py
    python3 tools/third_party_notice_audit.py --self-test
    python3 tools/third_party_notice_audit.py --pack-zip build/qa/full.zip
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
COMPONENTS_REL = "assets/third_party/THIRD_PARTY_COMPONENTS.json"
GODOT_LICENSE_REL = "assets/third_party/GODOT_ENGINE_LICENSE.txt"
GODOT_COPYRIGHT_REL = "assets/third_party/GODOT_ENGINE_COPYRIGHT.txt"
FONT_LEDGER_REL = "assets/fonts/FONT_LICENSE_LEDGER.md"
AUDIO_MANIFEST_REL = "assets/audio/AUDIO_SOURCE_MANIFEST.json"
AUDIO_NOTICE_REL = "assets/audio/AUDIO_THIRD_PARTY_NOTICES.md"
OUTPUT_REL = "content/meta/third_party_notices.json"
EXPORT_PRESETS_REL = "export_presets.cfg"

EXPECTED_COMPONENTS = 1
EXPECTED_FONT_FAMILIES = 3
EXPECTED_FONT_FILES = 6
EXPECTED_AUDIO_SOURCES = 21
EXPECTED_AUDIO_ASSETS = 139
EXPECTED_ATTRIBUTION_AUDIO_SOURCES = 1
EXPECTED_EXPORT_PRESETS = 10
EXPECTED_PACKAGED_NOTICE_FILES = 10
EXPECTED_GODOT = {
    "id": "godot_engine",
    "version": "4.6.2",
    "source_revision": "4.6.2-stable",
    "license": "MIT License",
    "license_text_path": GODOT_LICENSE_REL,
    "license_text_sha256": (
        "b0435e3b3e4e55238f05f4b306f30524a1b2e20147810d436eaa554fa6855c80"
    ),
    "copyright_text_path": GODOT_COPYRIGHT_REL,
    "copyright_text_sha256": (
        "dc043a7dbf69632560219e72fbc61ef9fa7338c7a773660acd81b51590b69104"
    ),
}
EXPECTED_FONT_LICENSE_HASHES = {
    "OFL-NotoColorEmoji.txt": (
        "6b8fb65f9c022d3902191c5fe93f3d02ecfd88256db16eb187b4f136e5916b68"
    ),
    "OFL-NotoSansJP.txt": (
        "babcfe66c8a098b2fa279bc724a3a342f8124f77ce18941fbcc1bbb39823cded"
    ),
    "OFL-Pretendard.txt": (
        "9884c81482f64d1a80941098f152c0c9ea944d57ed45bf38324a2601a50b9ef1"
    ),
}

HASH_RE = re.compile(r"^[0-9a-f]{64}$")
SHORT_HASH_RE = re.compile(r"^[0-9a-f]{16}$")
COMPONENT_FIELDS = {
    "id",
    "kind",
    "name",
    "version",
    "source_revision",
    "provider",
    "license",
    "source_url",
    "license_url",
    "license_text_path",
    "license_text_sha256",
    "copyright_url",
    "copyright_text_path",
    "copyright_text_sha256",
    "notice_status",
}
AUDIO_LIBRARY_FIELDS = {
    "provider",
    "title",
    "source_type",
    "license",
    "license_url",
    "source_url",
    "attribution_required",
}
AUDIO_SOURCE_LICENSE_FIELDS = {
    "provider",
    "title",
    "license",
    "license_url",
    "source_url",
    "attribution_required",
}
ALLOWED_AUDIO_SOURCE_TYPES = {
    "field_recording",
    "object_recording",
    "real_instrument_sample",
}


@dataclass
class SourceSnapshot:
    components: dict[str, Any]
    font_ledger: str
    audio_manifest: dict[str, Any]
    file_hashes: dict[str, str]
    text_files: dict[str, str]


def sha256_path(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def res_path(path: str) -> str:
    return f"res://{path}"


def safe_relative_path(raw: Any) -> str | None:
    value = str(raw).strip()
    path = PurePosixPath(value)
    if not value or path.is_absolute() or ".." in path.parts or path.as_posix() != value:
        return None
    return value


def normalize_pack_member(raw: str) -> str:
    value = raw.replace("\\", "/")
    if value.startswith("res://"):
        value = value[6:]
    while value.startswith("./"):
        value = value[2:]
    return value


def load_json(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError(f"{path.relative_to(ROOT)} root must be an object")
    return payload


def load_snapshot() -> SourceSnapshot:
    components_path = ROOT / COMPONENTS_REL
    font_ledger_path = ROOT / FONT_LEDGER_REL
    audio_manifest_path = ROOT / AUDIO_MANIFEST_REL
    components = load_json(components_path)
    font_ledger = font_ledger_path.read_text(encoding="utf-8")
    audio_manifest = load_json(audio_manifest_path)

    paths: set[Path] = {
        components_path,
        font_ledger_path,
        audio_manifest_path,
        ROOT / GODOT_LICENSE_REL,
        ROOT / GODOT_COPYRIGHT_REL,
        ROOT / AUDIO_NOTICE_REL,
    }
    paths.update((ROOT / "assets/fonts").glob("*.ttf"))
    paths.update((ROOT / "assets/fonts").glob("OFL-*.txt"))
    paths.update((ROOT / "assets/audio").glob("*.wav"))
    paths.update((ROOT / "assets/audio").glob("*.ogg"))

    file_hashes: dict[str, str] = {}
    text_files: dict[str, str] = {}
    for path in sorted(paths):
        relative = path.relative_to(ROOT).as_posix()
        if not path.is_file():
            continue
        file_hashes[relative] = sha256_path(path)
        if path.suffix.lower() in {".txt", ".md"}:
            text_files[relative] = path.read_text(encoding="utf-8")
    return SourceSnapshot(
        components=components,
        font_ledger=font_ledger,
        audio_manifest=audio_manifest,
        file_hashes=file_hashes,
        text_files=text_files,
    )


def validate_components(
    snapshot: SourceSnapshot,
    errors: list[str],
) -> tuple[list[dict[str, Any]], list[str]]:
    payload = snapshot.components
    if payload.get("schema_version") != 1:
        errors.append("component ledger schema_version must be 1")
    raw_components = payload.get("components")
    if not isinstance(raw_components, list):
        errors.append("component ledger components must be an array")
        return [], []
    if len(raw_components) != EXPECTED_COMPONENTS:
        errors.append(
            f"component inventory must be {EXPECTED_COMPONENTS}, got {len(raw_components)}"
        )

    entries: list[dict[str, Any]] = []
    license_copies: list[str] = []
    seen: set[str] = set()
    for index, raw in enumerate(raw_components):
        if not isinstance(raw, dict):
            errors.append(f"component {index} must be an object")
            continue
        component_id = str(raw.get("id", "")).strip()
        missing = sorted(COMPONENT_FIELDS - set(raw))
        if missing:
            errors.append(
                f"component {component_id or index}: missing fields: {', '.join(missing)}"
            )
        if not component_id:
            errors.append(f"component {index}: empty id")
        elif component_id in seen:
            errors.append(f"duplicate component id: {component_id}")
        seen.add(component_id)
        for field in COMPONENT_FIELDS - {
            "license_text_sha256", "copyright_text_sha256"
        }:
            if not str(raw.get(field, "")).strip():
                errors.append(f"component {component_id or index}: empty {field}")
        for field in ("source_url", "license_url", "copyright_url"):
            if not str(raw.get(field, "")).startswith("https://"):
                errors.append(f"component {component_id or index}: {field} must be https")

        copy_values: dict[str, tuple[str, str]] = {}
        for copy_kind in ("license", "copyright"):
            path_field = f"{copy_kind}_text_path"
            hash_field = f"{copy_kind}_text_sha256"
            copy_path = safe_relative_path(raw.get(path_field))
            if copy_path is None:
                errors.append(f"component {component_id or index}: unsafe {path_field}")
                copy_path = ""
            expected_hash = str(raw.get(hash_field, ""))
            if not HASH_RE.fullmatch(expected_hash):
                errors.append(
                    f"component {component_id or index}: invalid {copy_kind} SHA-256"
                )
            actual_hash = snapshot.file_hashes.get(copy_path)
            if actual_hash is None:
                errors.append(
                    f"component {component_id or index}: {copy_kind} text missing: "
                    f"{copy_path}"
                )
            elif actual_hash != expected_hash:
                errors.append(
                    f"component {component_id or index}: {copy_kind} hash mismatch"
                )
            copy_values[copy_kind] = (copy_path, expected_hash)

        if component_id == EXPECTED_GODOT["id"]:
            for field, expected in EXPECTED_GODOT.items():
                if str(raw.get(field, "")) != expected:
                    errors.append(
                        f"component {component_id}: {field} must match Godot 4.6.2-stable"
                    )

        license_path, license_hash = copy_values.get("license", ("", ""))
        copyright_path, copyright_hash = copy_values.get("copyright", ("", ""))
        for copy_path in (license_path, copyright_path):
            if copy_path:
                license_copies.append(copy_path)
        entries.append(
            {
                "id": component_id,
                "kind": str(raw.get("kind", "")),
                "name": str(raw.get("name", "")),
                "version": str(raw.get("version", "")),
                "provider": str(raw.get("provider", "")),
                "license": str(raw.get("license", "")),
                "source_url": str(raw.get("source_url", "")),
                "license_url": str(raw.get("license_url", "")),
                "license_text_path": res_path(license_path) if license_path else "",
                "license_text_sha256": license_hash,
                "copyright_url": str(raw.get("copyright_url", "")),
                "copyright_text_path": (
                    res_path(copyright_path) if copyright_path else ""
                ),
                "copyright_text_sha256": copyright_hash,
                "notice_status": str(raw.get("notice_status", "")),
            }
        )
    entries.sort(key=lambda item: item["id"])
    return entries, sorted(set(license_copies))


def markdown_cells(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def unwrap_code(value: str) -> str:
    if len(value) >= 2 and value.startswith("`") and value.endswith("`"):
        return value[1:-1]
    return value


def font_rows(text: str, errors: list[str]) -> list[dict[str, str]]:
    lines = text.splitlines()
    header_index = -1
    for index, line in enumerate(lines):
        cells = markdown_cells(line) if line.lstrip().startswith("|") else []
        if cells and cells[0] == "파일" and "패밀리" in cells:
            header_index = index
            break
    if header_index < 0:
        errors.append("font ledger table header missing")
        return []

    rows: list[dict[str, str]] = []
    for line in lines[header_index + 2 :]:
        if not line.lstrip().startswith("|"):
            break
        cells = markdown_cells(line)
        if len(cells) != 7:
            errors.append(f"font ledger row must have 7 cells: {line}")
            continue
        license_match = re.search(r"\(([^)]+\.txt)\)", cells[4])
        if license_match is None:
            errors.append(f"font ledger license link missing: {cells[0]}")
            license_copy = ""
        else:
            license_copy = license_match.group(1)
        rows.append(
            {
                "file": unwrap_code(cells[0]),
                "family": cells[1],
                "version": cells[2],
                "copyright": cells[3],
                "license_copy": license_copy,
                "role": cells[5],
                "short_sha256": unwrap_code(cells[6]),
            }
        )
    return rows


def font_family_sources(
    text: str, errors: list[str]
) -> dict[str, dict[str, str]]:
    lines = text.splitlines()
    header_index = -1
    for index, line in enumerate(lines):
        cells = markdown_cells(line) if line.lstrip().startswith("|") else []
        if cells == ["패밀리", "제공자", "공식 출처"]:
            header_index = index
            break
    if header_index < 0:
        errors.append("font family source table header missing")
        return {}
    sources: dict[str, dict[str, str]] = {}
    for line in lines[header_index + 2 :]:
        if not line.lstrip().startswith("|"):
            break
        cells = markdown_cells(line)
        if len(cells) != 3:
            errors.append(f"font family source row must have 3 cells: {line}")
            continue
        family, provider, source_url = (cell.strip() for cell in cells)
        if family in sources:
            errors.append(f"duplicate font family source: {family}")
        if not provider:
            errors.append(f"font family source has empty provider: {family}")
        if not source_url.startswith("https://"):
            errors.append(f"font family source must be https: {family}")
        sources[family] = {"provider": provider, "source_url": source_url}
    return sources


def font_license_hashes(text: str, errors: list[str]) -> dict[str, str]:
    lines = text.splitlines()
    header_index = -1
    for index, line in enumerate(lines):
        cells = markdown_cells(line) if line.lstrip().startswith("|") else []
        if cells == ["라이선스 사본", "SHA-256"]:
            header_index = index
            break
    if header_index < 0:
        errors.append("font license integrity table header missing")
        return {}
    hashes: dict[str, str] = {}
    for line in lines[header_index + 2 :]:
        if not line.lstrip().startswith("|"):
            break
        cells = markdown_cells(line)
        if len(cells) != 2:
            errors.append(f"font license integrity row must have 2 cells: {line}")
            continue
        filename, digest = (unwrap_code(cell.strip()) for cell in cells)
        if PurePosixPath(filename).name != filename or not filename.startswith("OFL-"):
            errors.append(f"unsafe font license integrity path: {filename}")
        if filename in hashes:
            errors.append(f"duplicate font license integrity row: {filename}")
        if not HASH_RE.fullmatch(digest):
            errors.append(f"invalid font license SHA-256: {filename}")
        hashes[filename] = digest
    return hashes


def license_name(text: str, path: str, errors: list[str]) -> str:
    match = re.search(
        r"licensed under the (SIL Open Font License), Version ([0-9.]+)\.",
        text,
    )
    if match is None:
        errors.append(f"font license identity missing: {path}")
        return ""
    if "SIL OPEN FONT LICENSE Version 1.1" not in text:
        errors.append(f"font license body missing OFL 1.1 marker: {path}")
    return f"{match.group(1)} {match.group(2)}"


def font_entry_id(family: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "_", family.casefold()).strip("_")
    return f"font_{slug}"


def validate_fonts(
    snapshot: SourceSnapshot,
    errors: list[str],
) -> tuple[list[dict[str, Any]], list[str], int]:
    rows = font_rows(snapshot.font_ledger, errors)
    family_sources = font_family_sources(snapshot.font_ledger, errors)
    license_hashes = font_license_hashes(snapshot.font_ledger, errors)
    if len(rows) != EXPECTED_FONT_FILES:
        errors.append(f"font ledger must contain {EXPECTED_FONT_FILES} files, got {len(rows)}")

    actual_fonts = {
        path
        for path in snapshot.file_hashes
        if path.startswith("assets/fonts/") and path.endswith(".ttf")
    }
    ledger_fonts = {f"assets/fonts/{row['file']}" for row in rows if row["file"]}
    for path in sorted(ledger_fonts - actual_fonts):
        errors.append(f"font file missing: {path}")
    for path in sorted(actual_fonts - ledger_fonts):
        errors.append(f"font file has no ledger row: {path}")

    grouped: dict[str, list[dict[str, str]]] = {}
    for row in rows:
        filename = row["file"]
        if PurePosixPath(filename).name != filename or not filename.endswith(".ttf"):
            errors.append(f"font ledger has unsafe filename: {filename}")
            continue
        path = f"assets/fonts/{filename}"
        short_hash = row["short_sha256"]
        if not SHORT_HASH_RE.fullmatch(short_hash):
            errors.append(f"font ledger has invalid short SHA-256: {filename}")
        actual_hash = snapshot.file_hashes.get(path)
        if actual_hash is not None and not actual_hash.startswith(short_hash):
            errors.append(f"font SHA-256 mismatch: {filename}")
        if not row["family"].strip():
            errors.append(f"font ledger has empty family: {filename}")
            continue
        grouped.setdefault(row["family"], []).append(row)

    if len(grouped) != EXPECTED_FONT_FAMILIES:
        errors.append(
            f"font family inventory must be {EXPECTED_FONT_FAMILIES}, got {len(grouped)}"
        )
    if set(family_sources) != set(grouped):
        errors.append(
            "font family source coverage mismatch: "
            f"missing={sorted(set(grouped) - set(family_sources))} "
            f"extra={sorted(set(family_sources) - set(grouped))}"
        )
    actual_license_names = {
        PurePosixPath(path).name
        for path in snapshot.file_hashes
        if path.startswith("assets/fonts/OFL-") and path.endswith(".txt")
    }
    if set(license_hashes) != actual_license_names:
        errors.append(
            "font license integrity coverage mismatch: "
            f"missing={sorted(actual_license_names - set(license_hashes))} "
            f"extra={sorted(set(license_hashes) - actual_license_names)}"
        )
    if license_hashes != EXPECTED_FONT_LICENSE_HASHES:
        errors.append("font license canonical SHA-256 set mismatch")
    for filename, expected_hash in license_hashes.items():
        actual_hash = snapshot.file_hashes.get(f"assets/fonts/{filename}")
        if actual_hash is not None and actual_hash != expected_hash:
            errors.append(f"font license SHA-256 mismatch: {filename}")

    entries: list[dict[str, Any]] = []
    license_copies: list[str] = []
    for family, family_rows in sorted(grouped.items(), key=lambda item: item[0].casefold()):
        versions = sorted({row["version"] for row in family_rows})
        copyrights = sorted({row["copyright"] for row in family_rows})
        copies = sorted({row["license_copy"] for row in family_rows if row["license_copy"]})
        if len(versions) != 1:
            errors.append(f"font family {family}: versions disagree")
        if len(copyrights) != 1:
            errors.append(f"font family {family}: copyright statements disagree")
        if len(copies) != 1:
            errors.append(f"font family {family}: license copies disagree")
        copy_name = copies[0] if copies else ""
        copy_path = f"assets/fonts/{copy_name}" if copy_name else ""
        text = snapshot.text_files.get(copy_path)
        if text is None:
            errors.append(f"font family {family}: license copy missing: {copy_path}")
            parsed_license = ""
        else:
            parsed_license = license_name(text, copy_path, errors)
        if copy_path:
            license_copies.append(copy_path)
        source_record = family_sources.get(family, {})
        entries.append(
            {
                "id": font_entry_id(family),
                "kind": "font_family",
                "name": family,
                "version": versions[0] if versions else "",
                "copyright": copyrights[0] if copyrights else "",
                "provider": str(source_record.get("provider", "")),
                "license": parsed_license,
                "source_url": str(source_record.get("source_url", "")),
                "license_text_path": res_path(copy_path) if copy_path else "",
                "notice_status": "license_copy_required",
                "roles": sorted({row["role"] for row in family_rows}),
                "shipped_files": [
                    res_path(f"assets/fonts/{row['file']}")
                    for row in sorted(family_rows, key=lambda item: item["file"])
                ],
            }
        )
    return entries, sorted(set(license_copies)), len(rows)


def validate_audio(
    snapshot: SourceSnapshot,
    errors: list[str],
) -> tuple[list[dict[str, Any]], int, int, int]:
    payload = snapshot.audio_manifest
    if payload.get("schema_version") != 1:
        errors.append("audio source manifest schema_version must be 1")
    libraries = payload.get("libraries")
    assets = payload.get("assets")
    if not isinstance(libraries, dict):
        errors.append("audio source manifest libraries must be an object")
        libraries = {}
    if not isinstance(assets, dict):
        errors.append("audio source manifest assets must be an object")
        assets = {}
    if len(libraries) != EXPECTED_AUDIO_SOURCES:
        errors.append(
            f"audio source inventory must be {EXPECTED_AUDIO_SOURCES}, got {len(libraries)}"
        )

    actual_assets = {
        PurePosixPath(path).name
        for path in snapshot.file_hashes
        if path.startswith("assets/audio/") and Path(path).suffix.lower() in {".wav", ".ogg"}
    }
    if len(actual_assets) != EXPECTED_AUDIO_ASSETS:
        errors.append(
            f"shipping audio inventory must be {EXPECTED_AUDIO_ASSETS}, got {len(actual_assets)}"
        )
    manifest_assets = set(assets)
    for name in sorted(actual_assets - manifest_assets):
        errors.append(f"audio asset has no source record: {name}")
    for name in sorted(manifest_assets - actual_assets):
        errors.append(f"audio source record references missing asset: {name}")

    used_by: dict[str, set[str]] = {str(key): set() for key in libraries}
    used_license_records: dict[str, list[dict[str, Any] | None]] = {
        str(key): [] for key in libraries
    }
    source_assignments = 0
    for name, raw in sorted(assets.items()):
        if not isinstance(raw, dict):
            errors.append(f"audio asset {name}: source record must be an object")
            continue
        expected_hash = str(raw.get("output_sha256", ""))
        if not HASH_RE.fullmatch(expected_hash):
            errors.append(f"audio asset {name}: invalid output SHA-256")
        actual_hash = snapshot.file_hashes.get(f"assets/audio/{name}")
        if actual_hash is not None and actual_hash != expected_hash:
            errors.append(f"audio asset {name}: output hash mismatch")
        sources = raw.get("sources")
        if not isinstance(sources, list) or not sources:
            errors.append(f"audio asset {name}: no source records")
            continue
        packs_for_asset: set[str] = set()
        for source_index, source in enumerate(sources):
            if not isinstance(source, dict):
                errors.append(f"audio asset {name}: source {source_index} must be an object")
                continue
            pack = str(source.get("pack", ""))
            if pack not in libraries:
                errors.append(f"audio asset {name}: unknown source library: {pack}")
            else:
                packs_for_asset.add(pack)
                license_record = source.get("license_record")
                if license_record is None:
                    used_license_records[pack].append(None)
                elif not isinstance(license_record, dict):
                    errors.append(
                        f"audio asset {name}: source {source_index} "
                        "license_record must be an object"
                    )
                else:
                    missing = sorted(
                        AUDIO_SOURCE_LICENSE_FIELDS - set(license_record)
                    )
                    if missing:
                        errors.append(
                            f"audio asset {name}: source {source_index} "
                            "license_record missing fields: " + ", ".join(missing)
                        )
                    for field in AUDIO_SOURCE_LICENSE_FIELDS - {
                        "attribution_required"
                    }:
                        if not str(license_record.get(field, "")).strip():
                            errors.append(
                                f"audio asset {name}: source {source_index} "
                                f"license_record empty {field}"
                            )
                    for field in ("source_url", "license_url"):
                        if not str(license_record.get(field, "")).startswith("https://"):
                            errors.append(
                                f"audio asset {name}: source {source_index} "
                                f"license_record {field} must be https"
                            )
                    if not isinstance(
                        license_record.get("attribution_required"), bool
                    ):
                        errors.append(
                            f"audio asset {name}: source {source_index} "
                            "license_record attribution_required must be boolean"
                        )
                    used_license_records[pack].append(dict(license_record))
            if not str(source.get("original_file", "")).strip():
                errors.append(f"audio asset {name}: source {source_index} has no original file")
            if not HASH_RE.fullmatch(str(source.get("sha256", ""))):
                errors.append(f"audio asset {name}: source {source_index} has invalid SHA-256")
            if str(source.get("source_type", "")) not in ALLOWED_AUDIO_SOURCE_TYPES:
                errors.append(f"audio asset {name}: source {source_index} has invalid type")
        for pack in packs_for_asset:
            used_by[pack].add(name)
            source_assignments += 1

    entries: list[dict[str, Any]] = []
    attribution_count = 0
    for library_id, raw in sorted(libraries.items()):
        if not isinstance(raw, dict):
            errors.append(f"audio source {library_id}: entry must be an object")
            continue
        missing = sorted(AUDIO_LIBRARY_FIELDS - set(raw))
        if missing:
            errors.append(f"audio source {library_id}: missing fields: {', '.join(missing)}")
        for field in AUDIO_LIBRARY_FIELDS - {"attribution_required"}:
            if not str(raw.get(field, "")).strip():
                errors.append(f"audio source {library_id}: empty {field}")
        if str(raw.get("source_type", "")) not in ALLOWED_AUDIO_SOURCE_TYPES:
            errors.append(f"audio source {library_id}: invalid source_type")
        for field in ("source_url", "license_url"):
            if not str(raw.get(field, "")).startswith("https://"):
                errors.append(f"audio source {library_id}: {field} must be https")
        library_attribution = raw.get("attribution_required")
        if not isinstance(library_attribution, bool):
            errors.append(f"audio source {library_id}: attribution_required must be boolean")
            library_attribution = False
        shipping_assets = sorted(used_by.get(library_id, set()))
        if not shipping_assets:
            errors.append(f"audio source {library_id}: unused by shipping assets")
        source_records = used_license_records.get(library_id, [])
        overridden = [record for record in source_records if record is not None]
        has_library_fallback = any(record is None for record in source_records)
        effective: dict[str, Any] = raw
        if overridden and not has_library_fallback:
            unique_records = {
                json.dumps(record, ensure_ascii=False, sort_keys=True)
                for record in overridden
            }
            if len(unique_records) != 1:
                errors.append(
                    f"audio source {library_id}: used per-file license records disagree"
                )
            effective = json.loads(sorted(unique_records)[0])
        elif overridden and has_library_fallback:
            errors.append(
                f"audio source {library_id}: mixes per-file records with library fallback"
            )
        attribution = effective.get("attribution_required", False)
        if attribution is True:
            attribution_count += 1
        entries.append(
            {
                "id": str(library_id),
                "kind": "audio_source",
                "name": str(effective.get("title", "")),
                "provider": str(effective.get("provider", "")),
                "license": str(effective.get("license", "")),
                "license_url": str(effective.get("license_url", "")),
                "source_url": str(effective.get("source_url", "")),
                "source_type": str(raw.get("source_type", "")),
                "source_collection": str(raw.get("title", "")),
                "notice_status": (
                    "attribution_required" if attribution else "voluntary_credit"
                ),
                "shipping_asset_count": len(shipping_assets),
                "shipping_assets": [
                    res_path(f"assets/audio/{name}") for name in shipping_assets
                ],
            }
        )
    entries.sort(
        key=lambda item: (
            item["notice_status"] != "attribution_required",
            item["name"].casefold(),
            item["id"],
        )
    )
    if attribution_count != EXPECTED_ATTRIBUTION_AUDIO_SOURCES:
        errors.append(
            "attribution-required audio inventory must be "
            f"{EXPECTED_ATTRIBUTION_AUDIO_SOURCES}, got {attribution_count}"
        )
    return entries, len(actual_assets), attribution_count, source_assignments


def build_notice(snapshot: SourceSnapshot, errors: list[str]) -> dict[str, Any]:
    component_entries, component_copies = validate_components(snapshot, errors)
    font_entries, font_copies, font_file_count = validate_fonts(snapshot, errors)
    audio_entries, audio_asset_count, attribution_count, source_assignments = (
        validate_audio(snapshot, errors)
    )

    package_license_copies = sorted(set(component_copies + font_copies))
    source_ledgers = [COMPONENTS_REL, FONT_LEDGER_REL, AUDIO_MANIFEST_REL]
    provenance_paths = sorted(set(source_ledgers + package_license_copies))
    generated_from: list[dict[str, str]] = []
    for path in provenance_paths:
        digest = snapshot.file_hashes.get(path)
        if digest is None:
            errors.append(f"generated source missing: {path}")
            digest = ""
        generated_from.append({"path": res_path(path), "sha256": digest})
    if AUDIO_NOTICE_REL not in snapshot.file_hashes:
        errors.append(f"package audio notice missing: {AUDIO_NOTICE_REL}")

    return {
        "schema_version": 1,
        "generated_by": "tools/third_party_notice_audit.py",
        "generated_from": generated_from,
        "surface": {
            "title": {"ko": "제3자 고지", "en": "Third-Party Notices"},
            "intro": {
                "ko": (
                    "이 게임은 아래의 게임 엔진, 서체, 오디오 출처를 사용합니다. "
                    "각 항목의 출처와 라이선스를 확인할 수 있습니다."
                ),
                "en": (
                    "This game uses the engine, fonts, and audio sources listed below. "
                    "Each entry includes its source and license."
                ),
            },
            "package_note": {
                "ko": (
                    "라이선스 전문이 필요한 항목은 사본을 배포 파일에 함께 넣었습니다. "
                    "오디오 파일별 상세 출처는 별도 원장에 기록되어 있습니다."
                ),
                "en": (
                    "Required license texts are included with the distributed game. "
                    "Per-file audio provenance is recorded in a separate ledger."
                ),
            },
            "labels": {
                "provider": {"ko": "제공자", "en": "Provider"},
                "copyright": {"ko": "저작권", "en": "Copyright"},
                "license": {"ko": "라이선스", "en": "License"},
                "source": {"ko": "출처", "en": "Source"},
                "license_terms": {"ko": "라이선스 원문", "en": "License terms"},
                "license_copy_required": {
                    "ko": "라이선스 전문 동봉",
                    "en": "License text included",
                },
                "attribution_required": {
                    "ko": "저작자 표시 필요",
                    "en": "Attribution required",
                },
                "voluntary_credit": {
                    "ko": "표시 의무 없음 · 제작진 표기",
                    "en": "Voluntary credit",
                },
            },
        },
        "distribution": {
            "source_ledgers": [res_path(path) for path in source_ledgers],
            "package_license_copies": [
                res_path(path) for path in package_license_copies
            ],
            "package_notice_files": [res_path(AUDIO_NOTICE_REL)],
            "in_game_notice_data": res_path(OUTPUT_REL),
        },
        "summary": {
            "component_entries": len(component_entries),
            "font_families": len(font_entries),
            "font_files": font_file_count,
            "audio_sources": len(audio_entries),
            "audio_assets": audio_asset_count,
            "attribution_required_audio_sources": attribution_count,
            "audio_source_assignments": source_assignments,
        },
        "sections": [
            {
                "id": "engine",
                "title": {"ko": "게임 엔진", "en": "Game Engine"},
                "entries": component_entries,
            },
            {
                "id": "fonts",
                "title": {"ko": "서체", "en": "Fonts"},
                "entries": font_entries,
            },
            {
                "id": "audio",
                "title": {"ko": "오디오", "en": "Audio"},
                "entries": audio_entries,
            },
        ],
    }


def validate_export_filters(errors: list[str]) -> None:
    text = (ROOT / EXPORT_PRESETS_REL).read_text(encoding="utf-8")
    filters = re.findall(r'^include_filter="([^"]*)"$', text, flags=re.MULTILINE)
    if len(filters) != EXPECTED_EXPORT_PRESETS:
        errors.append(
            f"export include filters must be {EXPECTED_EXPORT_PRESETS}, "
            f"got {len(filters)}"
        )
    required = {
        "assets/fonts/*.txt",
        "assets/fonts/*.md",
        "assets/audio/*.md",
        "assets/third_party/*.txt",
        "assets/third_party/*.json",
    }
    for index, raw_filter in enumerate(filters):
        values = {value.strip() for value in raw_filter.split(",")}
        missing = sorted(required - values)
        if missing:
            errors.append(
                f"export preset {index}: notice include filter missing "
                + ", ".join(missing)
            )


def required_pack_paths(
    notice: dict[str, Any], errors: list[str]
) -> list[str]:
    distribution = notice.get("distribution")
    if not isinstance(distribution, dict):
        errors.append("generated notice distribution must be an object")
        return []
    raw_paths: list[Any] = []
    for key in (
        "source_ledgers",
        "package_license_copies",
        "package_notice_files",
    ):
        values = distribution.get(key)
        if not isinstance(values, list):
            errors.append(f"generated notice distribution {key} must be an array")
            continue
        raw_paths.extend(values)
    raw_paths.append(distribution.get("in_game_notice_data"))

    paths: list[str] = []
    for raw in raw_paths:
        value = str(raw or "")
        if not value.startswith("res://"):
            errors.append(f"packaged notice path must use res://: {value!r}")
            continue
        relative = safe_relative_path(value.removeprefix("res://"))
        if relative is None:
            errors.append(f"unsafe packaged notice path: {value!r}")
            continue
        paths.append(relative)
    if len(paths) != len(set(paths)):
        errors.append("generated notice distribution has duplicate packaged paths")
    paths = sorted(set(paths))
    if len(paths) != EXPECTED_PACKAGED_NOTICE_FILES:
        errors.append(
            "packaged notice inventory must contain "
            f"{EXPECTED_PACKAGED_NOTICE_FILES} files, got {len(paths)}"
        )
    for relative in paths:
        if not (ROOT / relative).is_file():
            errors.append(f"packaged notice source missing: {relative}")
    return paths


def validate_pack_members(
    notice: dict[str, Any],
    members: dict[str, bytes],
    errors: list[str],
    label: str,
) -> int:
    unsafe = [
        name
        for name in members
        if (
            not name
            or PurePosixPath(name).is_absolute()
            or ".." in PurePosixPath(name).parts
            or PurePosixPath(name).as_posix() != name
        )
    ]
    if unsafe:
        errors.append(f"{label}: unsafe ZIP member paths: {sorted(unsafe)[:5]}")
    required = required_pack_paths(notice, errors)
    for relative in required:
        packaged = members.get(relative)
        if packaged is None:
            errors.append(f"{label}: packaged notice missing: {relative}")
            continue
        source = (ROOT / relative).read_bytes()
        if packaged != source:
            errors.append(f"{label}: packaged notice bytes differ: {relative}")
    return len(required)


def validate_pack_zip(
    notice: dict[str, Any], raw_path: str, errors: list[str]
) -> tuple[str, int]:
    path = Path(raw_path)
    if not path.is_absolute():
        path = ROOT / path
    label = path.name
    if not path.is_file():
        errors.append(f"{label}: pack ZIP missing: {path}")
        return label, 0
    if not zipfile.is_zipfile(path):
        errors.append(f"{label}: not a ZIP pack: {path}")
        return label, 0
    try:
        with zipfile.ZipFile(path) as archive:
            normalized: list[str] = []
            members: dict[str, bytes] = {}
            for info in archive.infolist():
                if info.is_dir():
                    continue
                member = normalize_pack_member(info.filename)
                normalized.append(member)
                if member not in members:
                    members[member] = archive.read(info)
    except (OSError, zipfile.BadZipFile) as exc:
        errors.append(f"{label}: cannot read pack ZIP: {exc}")
        return label, 0
    if len(normalized) != len(set(normalized)):
        errors.append(f"{label}: duplicate normalized ZIP member paths")
    count = validate_pack_members(notice, members, errors, label)
    return label, count


def rendered_json(payload: dict[str, Any]) -> str:
    return json.dumps(payload, ensure_ascii=False, indent=2) + "\n"


def rendered_audio_notice(entries: list[dict[str, Any]]) -> str:
    required = [
        entry
        for entry in entries
        if entry.get("notice_status") == "attribution_required"
    ]
    voluntary = [
        entry
        for entry in entries
        if entry.get("notice_status") == "voluntary_credit"
    ]
    lines = [
        "# Gangnam Dream Audio Notices",
        "",
        "> Generated by tools/third_party_notice_audit.py from",
        "> AUDIO_SOURCE_MANIFEST.json. Do not edit by hand.",
        "",
        "The shipped files are edited game-ready renders; raw source libraries",
        "are not redistributed. Per-output source hashes and edit history remain",
        "in AUDIO_SOURCE_MANIFEST.json.",
        "",
        "## Attribution Required",
        "",
    ]
    for entry in required:
        lines.extend(
            [
                f"### {entry['name']}",
                "",
                f"- Provider: {entry['provider']}",
                f"- License: {entry['license']}",
                f"- Source: {entry['source_url']}",
                f"- License text: {entry['license_url']}",
                f"- Shipping outputs: {entry['shipping_asset_count']}",
                "",
            ]
        )
    lines.extend(["## Voluntary Credits", ""])
    for entry in voluntary:
        lines.extend(
            [
                f"- {entry['provider']} — {entry['name']} — "
                f"{entry['license']} — {entry['source_url']} — "
                f"{entry['license_url']}"
            ]
        )
    lines.append("")
    return "\n".join(lines)


def verify_generated(
    expected: str,
    actual: str | None,
    errors: list[str],
    path: str = OUTPUT_REL,
) -> None:
    if actual is None:
        errors.append(f"generated notice missing: {path}; run --write")
    elif actual != expected:
        errors.append(f"generated notice stale: {path}; run --write")


def mutate_font_license_body(snapshot: SourceSnapshot) -> None:
    path = "assets/fonts/OFL-Pretendard.txt"
    original = snapshot.text_files[path]
    mutated = original.replace(
        "must be distributed entirely under this license, and must not be",
        "[DELETED LEGAL CONDITION]",
        1,
    )
    digest = hashlib.sha256(mutated.encode("utf-8")).hexdigest()
    snapshot.text_files[path] = mutated
    snapshot.file_hashes[path] = digest
    snapshot.font_ledger = snapshot.font_ledger.replace(
        EXPECTED_FONT_LICENSE_HASHES["OFL-Pretendard.txt"], digest, 1
    )


def run_pack_member_self_tests(notice: dict[str, Any]) -> list[str]:
    failures: list[str] = []
    fixture_errors: list[str] = []
    paths = required_pack_paths(notice, fixture_errors)
    if fixture_errors:
        return [f"self-test pack fixture could not be built: {fixture_errors}"]
    baseline = {relative: (ROOT / relative).read_bytes() for relative in paths}
    with tempfile.TemporaryDirectory(prefix="gangnam-third-party-pack-") as tmp:
        pack = Path(tmp) / "notices.zip"
        with zipfile.ZipFile(pack, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for relative, payload in baseline.items():
                archive.writestr(relative, payload)
        baseline_errors: list[str] = []
        validate_pack_zip(notice, str(pack), baseline_errors)
        if baseline_errors:
            failures.append(
                f"self-test pack baseline was rejected: {baseline_errors}"
            )

    missing = baseline.copy()
    missing.pop(GODOT_COPYRIGHT_REL)
    missing_errors: list[str] = []
    validate_pack_members(notice, missing, missing_errors, "missing-fixture")
    if not any("packaged notice missing" in error for error in missing_errors):
        failures.append(
            "self-test pack_missing: absent Godot COPYRIGHT was accepted"
        )

    stale = baseline.copy()
    stale[OUTPUT_REL] += b"\n"
    stale_errors: list[str] = []
    validate_pack_members(notice, stale, stale_errors, "stale-fixture")
    if not any("packaged notice bytes differ" in error for error in stale_errors):
        failures.append(
            "self-test pack_stale: modified runtime notice was accepted"
        )
    return failures


def run_self_tests(
    snapshot: SourceSnapshot, expected: dict[str, Any]
) -> tuple[list[str], int]:
    failures: list[str] = []
    mutations: list[
        tuple[str, str, Callable[[SourceSnapshot], None]]
    ] = [
        (
            "component_required_field",
            "missing fields: provider",
            lambda value: value.components["components"][0].pop("provider"),
        ),
        (
            "godot_license_hash",
            "license hash mismatch",
            lambda value: value.file_hashes.__setitem__(GODOT_LICENSE_REL, "0" * 64),
        ),
        (
            "godot_copyright_hash",
            "copyright hash mismatch",
            lambda value: value.file_hashes.__setitem__(
                GODOT_COPYRIGHT_REL, "0" * 64
            ),
        ),
        (
            "font_file_presence",
            "font file missing",
            lambda value: value.file_hashes.pop(
                "assets/fonts/Pretendard-Regular.ttf"
            ),
        ),
        (
            "font_hash",
            "font SHA-256 mismatch",
            lambda value: setattr(
                value,
                "font_ledger",
                value.font_ledger.replace(
                    "6d0af5258997aec7", "0000000000000000", 1
                ),
            ),
        ),
        (
            "font_source_url",
            "font family source must be https",
            lambda value: setattr(
                value,
                "font_ledger",
                value.font_ledger.replace(
                    "https://github.com/orioncactus/pretendard",
                    "http://example.invalid/pretendard",
                    1,
                ),
            ),
        ),
        (
            "font_license_body_hash",
            "font license SHA-256 mismatch",
            lambda value: value.file_hashes.__setitem__(
                "assets/fonts/OFL-Pretendard.txt", "0" * 64
            ),
        ),
        (
            "font_license_coordinated_mutation",
            "font license canonical SHA-256 set mismatch",
            mutate_font_license_body,
        ),
        (
            "audio_library_ownership",
            "unknown source library",
            lambda value: value.audio_manifest["libraries"].pop("horse_gallop"),
        ),
        (
            "audio_output_hash",
            "output hash mismatch",
            lambda value: value.file_hashes.__setitem__(
                "assets/audio/amb_amusement_park.wav", "0" * 64
            ),
        ),
        (
            "audio_per_file_license",
            "license_record missing fields: provider",
            lambda value: value.audio_manifest["assets"][
                "sfx_horse_gallop.wav"
            ]["sources"][0]["license_record"].pop("provider"),
        ),
        (
            "audio_required_field",
            "empty provider",
            lambda value: value.audio_manifest["libraries"]["owlish_cc0"].__setitem__(
                "provider", ""
            ),
        ),
    ]
    for name, marker, mutate in mutations:
        candidate = copy.deepcopy(snapshot)
        mutate(candidate)
        errors: list[str] = []
        build_notice(candidate, errors)
        if not any(marker in error for error in errors):
            failures.append(
                f"self-test {name}: mutation was not rejected with {marker!r}: {errors}"
            )

    manual = copy.deepcopy(expected)
    manual["sections"][0]["entries"].append(
        {"id": "handwritten_notice", "provider": "not in a source ledger"}
    )
    stale_errors: list[str] = []
    verify_generated(rendered_json(expected), rendered_json(manual), stale_errors)
    if not any("generated notice stale" in error for error in stale_errors):
        failures.append("self-test generated_stale: manual entry was not rejected")
    failures.extend(run_pack_member_self_tests(expected))
    return failures, len(mutations) + 3


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--write",
        action="store_true",
        help="regenerate the deterministic runtime notice JSON",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="prove source, hash, ownership, and stale-output mutations are rejected",
    )
    parser.add_argument(
        "--pack-zip",
        action="append",
        default=[],
        metavar="PATH",
        help=(
            "inspect an actual Godot export-pack ZIP; may be repeated for "
            "full and V2 packages"
        ),
    )
    args = parser.parse_args()

    try:
        snapshot = load_snapshot()
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"THIRD_PARTY_NOTICE_FAIL cannot load source records: {exc}")
        return 1

    errors: list[str] = []
    validate_export_filters(errors)
    notice = build_notice(snapshot, errors)
    expected = rendered_json(notice)
    output_path = ROOT / OUTPUT_REL
    audio_notice_path = ROOT / AUDIO_NOTICE_REL
    audio_entries = next(
        section["entries"]
        for section in notice["sections"]
        if section["id"] == "audio"
    )
    expected_audio_notice = rendered_audio_notice(audio_entries)
    if not errors and args.write:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(expected, encoding="utf-8")
        audio_notice_path.write_text(expected_audio_notice, encoding="utf-8")
        print(f"THIRD_PARTY_NOTICE_WRITE path={OUTPUT_REL}")
        print(f"THIRD_PARTY_NOTICE_WRITE path={AUDIO_NOTICE_REL}")
    elif not errors:
        actual = output_path.read_text(encoding="utf-8") if output_path.is_file() else None
        verify_generated(expected, actual, errors)
        actual_audio_notice = (
            audio_notice_path.read_text(encoding="utf-8")
            if audio_notice_path.is_file()
            else None
        )
        verify_generated(
            expected_audio_notice,
            actual_audio_notice,
            errors,
            AUDIO_NOTICE_REL,
        )

    pack_results: list[tuple[str, int]] = []
    if not errors:
        for raw_pack in args.pack_zip:
            pack_results.append(validate_pack_zip(notice, raw_pack, errors))

    if errors:
        for error in errors:
            print(f"THIRD_PARTY_NOTICE_FAIL {error}")
        return 1

    summary = notice["summary"]
    print(
        "THIRD_PARTY_NOTICE_OK "
        f"components={summary['component_entries']} "
        f"font_families={summary['font_families']} "
        f"font_files={summary['font_files']} "
        f"audio_sources={summary['audio_sources']} "
        f"audio_assets={summary['audio_assets']} "
        f"attribution_required_audio={summary['attribution_required_audio_sources']} "
        f"presets={EXPECTED_EXPORT_PRESETS}"
    )
    for label, count in pack_results:
        print(f"THIRD_PARTY_PACK_OK pack={label} files={count}")
    if args.self_test:
        failures, mutation_count = run_self_tests(snapshot, notice)
        if failures:
            for failure in failures:
                print(f"THIRD_PARTY_NOTICE_SELF_TEST_FAIL {failure}")
            return 1
        print(f"THIRD_PARTY_NOTICE_SELF_TEST_OK mutations={mutation_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

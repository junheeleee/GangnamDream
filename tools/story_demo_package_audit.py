#!/usr/bin/env python3
"""Audit the fixed-source public multilingual story-demo package."""

from __future__ import annotations

import argparse
import ast
import copy
from dataclasses import dataclass
import hashlib
import json
import os
import plistlib
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[1]
PROFILE = "story_demo_rc"
GAME_VERSION = "0.1.0-dev"
BUILD_ID = "2026.08.31.1"
BUILD_FLAVOR = "story_demo_rc"
PRESET = "Story Demo macOS"
APP_STEM = "GangnamDream-StoryDemo"
BUNDLE_ID = "dev.junheelee.gangnamdream.storydemo"
APP_VERSION = "2026.8.31"
CUSTOM_USER_DIR = "GangnamDream_StoryDemo_v1"
ENTRY_SCENE = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
CHECK_SCENE = "res://tools/StoryDemoFourLanguageCheck.tscn"
TARGET_MARKER = (
    "STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=30 "
    "weeks=120 settlements=30 ap_surface=0 save=5 story=10 build=2026.08.31.1"
)
NATIVE_MARKER_PREFIX = "STORY_DEMO_NATIVE_ENTRY_OK"
SMOKE_MARKER_PREFIX = "STORY_DEMO_WRAPPER_SMOKE_OK"
RETURN_MARKER_PREFIX = "STORY_DEMO_RETURN_SMOKE_OK"
RESUME_MARKER_PREFIX = "STORY_DEMO_RESUME_SMOKE_OK"
REAL_FLOW_MARKER_PREFIX = "STORY_DEMO_REAL_FLOW_SMOKE_OK"
EXPECTED_GODOT = "4.6.2.stable.official.71f334935"
APP_REL = f"build/story_demo/macos/{APP_STEM}.app"
ZIP_REL = f"build/story_demo/macos/{APP_STEM}.zip"
MANIFEST_REL = "build/story_demo/MANIFEST.json"
CHECKSUM_REL = "build/story_demo/MANIFEST.sha256"
AUDIT_SOURCE_ROOT_ENV = "STORY_DEMO_AUDIT_SOURCE_ROOT"
PRODUCT_REVISION = "ce57751eb5555828dfb28af87ab6026e8ab93fb9"
PRODUCT_TREE = "0e1ad9a26cdef953d94308015d527080a718eea2"
PRODUCT_RUNTIME_SCOPE = (
    "project.godot",
    "export_presets.cfg",
    "icon.png",
    "icon.png.import",
    "icon.svg",
    "icon.svg.import",
    "assets",
    "autoloads",
    "content",
    "locale",
    "playtests",
    "scenes",
    "steam_input",
    "systems",
    "ui_components",
)
HISTORIC_ARCHIVE_REL = "build/order124/archive/2026.08.24.2"
HISTORIC_EVIDENCE_REL = "tools/evidence/order124_build_2026.08.24.2"
HISTORIC_MANIFEST_NAME = "MANIFEST.json"
HISTORIC_CHECKSUM_NAME = "MANIFEST.sha256"
HISTORIC_LOSS_RECEIPT_NAME = "LOSS_RECEIPT.json"
HISTORIC_ZIP_NAME = "macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.zip"
MISSING_STATE_SHA256 = hashlib.sha256(b"missing\0").hexdigest()
WRAPPER_REQUIRED_MARKER_TOKENS = {
    "start": "1",
    "save": "1",
    "continue": "1",
    "month": "m02",
    "weeks": "4",
    "settlement": "1",
}
DENSITY_SELF_TEST_MARKER = "STORY_DEMO_DENSITY_AUDIT_SELF_TEST_OK cases=29"
DENSITY_MARKER = (
    "STORY_DEMO_DENSITY_AUDIT_OK "
    f"source={PRODUCT_REVISION} tree={PRODUCT_TREE} build={BUILD_ID} "
    "variants=14 choices=29 receipts_per_run={'clean': 9, 'restitution': 10, "
    "'escalation': 10} signatures=1800 clean=360 restitution=720 escalation=720"
)
DENSITY_HUMAN_GATE_MARKER = (
    "  HUMAN_GATE OPEN human_route_density=not_measured "
    "human_fun=not_measured automation_is_not_GO"
)
REAL_FLOW_ROUTES = (
    {
        "language": "ko",
        "route": "clean",
        "m02": "clean",
        "receipts": 9,
        "runtime_qa_namespace":
            "GangnamDream_StoryDemo_RuntimeQA_package_real_clean",
    },
    {
        "language": "en",
        "route": "restitution",
        "m02": "fallout",
        "receipts": 10,
        "runtime_qa_namespace":
            "GangnamDream_StoryDemo_RuntimeQA_package_real_restitution",
    },
    {
        "language": "zh-CN",
        "route": "escalation",
        "m02": "fallout",
        "receipts": 10,
        "runtime_qa_namespace":
            "GangnamDream_StoryDemo_RuntimeQA_package_real_escalation",
    },
)
REAL_FLOW_ROW_KEYS = {
    "passed", "language", "route", "m02", "months", "weeks",
    "settlements", "receipts", "cold_restart", "exact_resume",
    "runtime_qa_namespace", "args", "marker",
}

HASH_RE = re.compile(r"^[0-9a-f]{64}$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
UTC_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
SOURCE_CONTRACT = (
    "project.godot",
    "export_presets.cfg",
    "playtests/order124/StoryChoiceM1M6Playtest.gd",
    "playtests/order124/StoryChoiceM1M6Playtest.gd.uid",
    "playtests/order124/StoryChoiceM1M6Playtest.tscn",
    "scenes/StoryMode.gd",
    "autoloads/FontKit.gd",
    "assets/fonts/NotoSansSC-Variable.ttf",
    "assets/fonts/NotoSansSC-Variable.ttf.import",
    "assets/fonts/NotoSansTC-Variable.ttf",
    "assets/fonts/NotoSansTC-Variable.ttf.import",
    "assets/fonts/OFL-NotoSansSC.txt",
    "assets/fonts/OFL-NotoSansTC.txt",
    "assets/fonts/FONT_LICENSE_LEDGER.md",
    "content/meta/third_party_notices.json",
    "content/events_ja/story_demo_events.json",
    "content/events_zh-CN/story_demo_events.json",
    "content/events_zh-TW/story_demo_events.json",
    "locale/ui_ja.json",
    "locale/ui_zh-CN.json",
    "locale/ui_zh-TW.json",
    "locale/catalog_ja.json",
    "locale/catalog_zh-CN.json",
    "locale/catalog_zh-TW.json",
    "tools/StoryDemoFourLanguageCheck.gd",
    "tools/StoryDemoFourLanguageCheck.gd.uid",
    "tools/StoryDemoFourLanguageCheck.tscn",
    "tools/FontRoutingCheck.gd",
    "tools/FontRoutingCheck.gd.uid",
    "tools/FontRoutingCheck.tscn",
    "tools/I18nInfrastructureCheck.gd",
    "tools/I18nInfrastructureCheck.gd.uid",
    "tools/I18nInfrastructureCheck.tscn",
    "tools/third_party_notice_audit.py",
    "tools/story_demo_localization_audit.py",
    "tools/story_demo_density_audit.py",
    "tools/fixtures/story_demo_density_contract.json",
    "docs/human_gates.json",
    f"{HISTORIC_EVIDENCE_REL}/{HISTORIC_MANIFEST_NAME}",
    f"{HISTORIC_EVIDENCE_REL}/{HISTORIC_CHECKSUM_NAME}",
    f"{HISTORIC_EVIDENCE_REL}/{HISTORIC_LOSS_RECEIPT_NAME}",
    "tools/audit_scope.json",
    "tools/build_story_demo_macos.sh",
    "tools/story_demo_package_audit.py",
)
PROTECTED_LABELS = {
    "product_project_godot",
    "product_export_presets",
    "retail_v2_user_save_files",
    "order103_candidate_user_dir",
    "order124_candidate_user_dir",
    "story_demo_candidate_user_dir",
    "story_demo_build2_archive",
    "build_order103",
    "build_demo",
    "build_playtest",
}


@dataclass(frozen=True)
class HistoricArchiveContract:
    build_id: str
    source_revision: str
    source_tree: str
    engine_version: str
    manifest_sha256: str
    manifest_size: int
    checksum_sha256: str
    checksum_size: int
    checksum_line: str
    zip_sha256: str
    zip_size: int
    app_tree_sha256: str
    app_file_count: int
    launcher_sha256: str
    launcher_size: int
    pck_sha256: str
    pck_size: int
    archive_inventory_sha256: str
    rebuild_zip_sha256: str
    rebuild_zip_size: int
    rebuild_app_tree_sha256: str
    rebuild_app_file_count: int
    rebuild_launcher_sha256: str
    rebuild_launcher_size: int
    rebuild_pck_sha256: str
    rebuild_pck_size: int


HISTORIC_ARCHIVE = HistoricArchiveContract(
    build_id="2026.08.24.2",
    source_revision="e9aff5f06c2e3ec3708426156074674a56a4c3f6",
    source_tree="ad4d88a6aed68a79074f6f8e3204bf0474f6dbc4",
    engine_version="4.6.2.stable.official.71f334935",
    manifest_sha256="87f3491f7e526762203a83eb4ed25bbbba79981f7dc3ec812d49cdd955db1194",
    manifest_size=9238,
    checksum_sha256="38566c8aba5e395ee5e6ca964e4c41ece9770ccefaedc1f04c5670268c39e314",
    checksum_size=95,
    checksum_line=(
        "87f3491f7e526762203a83eb4ed25bbbba79981f7dc3ec812d49cdd955db1194"
        "  build/order124/MANIFEST.json\n"
    ),
    zip_sha256="626196d6a74f50373ddc3e6d0cb8b3a502f052d4436f308361d8b82d3ab45a75",
    zip_size=389505944,
    app_tree_sha256="c21d5ba71c5516465849cc7596d48ed430a4fc903eeeb7033340d36e5afb6a85",
    app_file_count=7,
    launcher_sha256="291d39bfa8f6014b40745012e725eb1a398076d223ea89e1caa2d8804495c7c7",
    launcher_size=184222320,
    pck_sha256="04e3e67e1591df5984f804f299edcba0c95eb6e8281362d253c134df0d64b7d8",
    pck_size=337642500,
    archive_inventory_sha256="84b5f16dac820fd946240bf72519dea155f1ff49e1724a72aed5d35664916d41",
    rebuild_zip_sha256="e05fabe42dbf104537d41e177ff97c4ae0b4f111771db20862ad2320db9db7a3",
    rebuild_zip_size=389505948,
    rebuild_app_tree_sha256="ad3ed20f0fa3d3fac02d4c550ea58bd1ae4e569ba6f03465d12815a16311b345",
    rebuild_app_file_count=7,
    rebuild_launcher_sha256="4c0aa3aa5c762d5ae41a1d094d21d621e0ce60002a5a56292f23266118433ede",
    rebuild_launcher_size=184222320,
    rebuild_pck_sha256="5e66c19426831570328bc006ac83861cbde6028defad0f3901a9397bc3ef418c",
    rebuild_pck_size=337642500,
)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def strict_json_loads(data: bytes | str) -> object:
    text = data.decode("utf-8") if isinstance(data, bytes) else data

    def reject_duplicates(pairs: list[tuple[str, object]]) -> dict[str, object]:
        result: dict[str, object] = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f"duplicate JSON key: {key}")
            result[key] = value
        return result

    return json.loads(text, object_pairs_hook=reject_duplicates)


def strict_value_equal(actual: object, expected: object) -> bool:
    if type(actual) is not type(expected):
        return False
    if isinstance(expected, dict):
        if not isinstance(actual, dict) or actual.keys() != expected.keys():
            return False
        return all(strict_value_equal(actual[key], value) for key, value in expected.items())
    if isinstance(expected, list):
        return isinstance(actual, list) and len(actual) == len(expected) and all(
            strict_value_equal(left, right) for left, right in zip(actual, expected)
        )
    return actual == expected


def expected_loss_receipt(contract: HistoricArchiveContract) -> dict[str, object]:
    return {
        "schema_version": 1,
        "record_type": "historic_build_archive_loss",
        "status": "missing_with_loss_receipt",
        "build_id": contract.build_id,
        "archive_restored": False,
        "candidate_eligible": False,
        "archive": {
            "path": HISTORIC_ARCHIVE_REL,
            "expected_inventory_sha256": contract.archive_inventory_sha256,
            "expected_file_count": 3,
            "observed_state_at_recording": "missing",
        },
        "source": {
            "revision": contract.source_revision,
            "tree": contract.source_tree,
        },
        "expected_artifacts": {
            "manifest": {
                "path": HISTORIC_MANIFEST_NAME,
                "sha256": contract.manifest_sha256,
                "size_bytes": contract.manifest_size,
            },
            "checksum": {
                "path": HISTORIC_CHECKSUM_NAME,
                "sha256": contract.checksum_sha256,
                "size_bytes": contract.checksum_size,
                "exact_line": contract.checksum_line,
            },
            "zip": {
                "path": HISTORIC_ZIP_NAME,
                "sha256": contract.zip_sha256,
                "size_bytes": contract.zip_size,
            },
            "app": {
                "tree_sha256": contract.app_tree_sha256,
                "file_count": contract.app_file_count,
            },
            "launcher": {
                "sha256": contract.launcher_sha256,
                "size_bytes": contract.launcher_size,
            },
            "resource_pack": {
                "sha256": contract.pck_sha256,
                "size_bytes": contract.pck_size,
            },
        },
        "tracked_evidence": {
            "root": HISTORIC_EVIDENCE_REL,
            "manifest": f"{HISTORIC_EVIDENCE_REL}/{HISTORIC_MANIFEST_NAME}",
            "checksum": f"{HISTORIC_EVIDENCE_REL}/{HISTORIC_CHECKSUM_NAME}",
            "loss_receipt": f"{HISTORIC_EVIDENCE_REL}/{HISTORIC_LOSS_RECEIPT_NAME}",
            "archive_payload_recovered": False,
        },
        "reconstruction_attempt": {
            "method": "clean_one_shot_same_source_same_engine",
            "source_revision": contract.source_revision,
            "source_tree": contract.source_tree,
            "engine_version": contract.engine_version,
            "zip": {
                "sha256": contract.rebuild_zip_sha256,
                "size_bytes": contract.rebuild_zip_size,
            },
            "app": {
                "tree_sha256": contract.rebuild_app_tree_sha256,
                "file_count": contract.rebuild_app_file_count,
            },
            "launcher": {
                "sha256": contract.rebuild_launcher_sha256,
                "size_bytes": contract.rebuild_launcher_size,
            },
            "resource_pack": {
                "sha256": contract.rebuild_pck_sha256,
                "size_bytes": contract.rebuild_pck_size,
            },
            "matches_historical": False,
        },
    }


def path_components_are_real_directories(root: Path, relative_parent: str) -> bool:
    current = root
    if current.is_symlink() or not current.is_dir():
        return False
    for part in PurePosixPath(relative_parent).parts:
        current = current / part
        if current.is_symlink() or not current.is_dir():
            return False
    return True


def regular_file(path: Path) -> bool:
    try:
        return not path.is_symlink() and stat.S_ISREG(path.lstat().st_mode)
    except OSError:
        return False


def inventory_sha256(root: Path, relative_files: tuple[str, ...]) -> str:
    rows = [
        f"file\0{relative}\0{sha256_path(root / relative)}\n".encode()
        for relative in sorted(relative_files)
    ]
    return sha256_bytes(b"".join(rows))


def validate_archive_contract_constants(
    contract: HistoricArchiveContract,
) -> list[str]:
    errors: list[str] = []
    checksum_bytes = contract.checksum_line.encode("utf-8")
    if len(checksum_bytes) != contract.checksum_size:
        errors.append("archive contract checksum size is internally inconsistent")
    if sha256_bytes(checksum_bytes) != contract.checksum_sha256:
        errors.append("archive contract checksum SHA-256 is internally inconsistent")
    archive_rows = (
        f"file\0{HISTORIC_MANIFEST_NAME}\0{contract.manifest_sha256}\n".encode(),
        f"file\0{HISTORIC_CHECKSUM_NAME}\0{contract.checksum_sha256}\n".encode(),
        f"file\0{HISTORIC_ZIP_NAME}\0{contract.zip_sha256}\n".encode(),
    )
    if sha256_bytes(b"".join(sorted(archive_rows))) != contract.archive_inventory_sha256:
        errors.append("archive contract aggregate SHA-256 is internally inconsistent")
    for label, value in (
        ("manifest", contract.manifest_sha256),
        ("checksum", contract.checksum_sha256),
        ("ZIP", contract.zip_sha256),
        ("app", contract.app_tree_sha256),
        ("launcher", contract.launcher_sha256),
        ("PCK", contract.pck_sha256),
        ("archive", contract.archive_inventory_sha256),
        ("rebuild ZIP", contract.rebuild_zip_sha256),
        ("rebuild app", contract.rebuild_app_tree_sha256),
        ("rebuild launcher", contract.rebuild_launcher_sha256),
        ("rebuild PCK", contract.rebuild_pck_sha256),
    ):
        if not HASH_RE.fullmatch(value):
            errors.append(f"archive contract {label} hash is malformed")
    for label, historical, rebuilt in (
        ("ZIP", contract.zip_sha256, contract.rebuild_zip_sha256),
        ("app", contract.app_tree_sha256, contract.rebuild_app_tree_sha256),
        ("launcher", contract.launcher_sha256, contract.rebuild_launcher_sha256),
        ("PCK", contract.pck_sha256, contract.rebuild_pck_sha256),
    ):
        if historical == rebuilt:
            errors.append(f"archive contract rebuild {label} falsely matches historical")
    return errors


def validate_historic_manifest_bytes(
    data: bytes,
    contract: HistoricArchiveContract,
    errors: list[str],
) -> None:
    if len(data) != contract.manifest_size:
        errors.append("historic manifest size drifted")
    if sha256_bytes(data) != contract.manifest_sha256:
        errors.append("historic manifest SHA-256 drifted")
    try:
        payload = strict_json_loads(data)
    except (UnicodeDecodeError, json.JSONDecodeError, ValueError) as exc:
        errors.append(f"historic manifest is not strict JSON: {exc}")
        return
    if not isinstance(payload, dict):
        errors.append("historic manifest root must be an object")
        return
    source = payload.get("source", {})
    engine = payload.get("engine", {})
    package = payload.get("package", {})
    zip_info = package.get("zip", {}) if isinstance(package, dict) else {}
    app_info = package.get("app", {}) if isinstance(package, dict) else {}
    launcher_info = package.get("launcher", {}) if isinstance(package, dict) else {}
    pck_info = package.get("resource_pack", {}) if isinstance(package, dict) else {}
    expected = (
        (payload.get("schema_version"), 1, "schema_version"),
        (payload.get("profile"), "order124_m1m6_story_choice", "profile"),
        (payload.get("build_id"), contract.build_id, "build_id"),
        (source.get("revision") if isinstance(source, dict) else None, contract.source_revision, "source revision"),
        (source.get("tree") if isinstance(source, dict) else None, contract.source_tree, "source tree"),
        (engine.get("version") if isinstance(engine, dict) else None, contract.engine_version, "engine version"),
        (zip_info.get("path"), "build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.zip", "ZIP path"),
        (zip_info.get("sha256"), contract.zip_sha256, "ZIP SHA-256"),
        (zip_info.get("size_bytes"), contract.zip_size, "ZIP size"),
        (app_info.get("tree_sha256"), contract.app_tree_sha256, "app tree SHA-256"),
        (app_info.get("file_count"), contract.app_file_count, "app file count"),
        (launcher_info.get("sha256"), contract.launcher_sha256, "launcher SHA-256"),
        (launcher_info.get("size_bytes"), contract.launcher_size, "launcher size"),
        (pck_info.get("sha256"), contract.pck_sha256, "PCK SHA-256"),
        (pck_info.get("size_bytes"), contract.pck_size, "PCK size"),
    )
    for actual, wanted, label in expected:
        if type(actual) is not type(wanted) or actual != wanted:
            errors.append(f"historic manifest {label} drifted")


def validate_checksum_bytes(
    data: bytes,
    contract: HistoricArchiveContract,
    errors: list[str],
) -> None:
    expected = contract.checksum_line.encode("utf-8")
    if data != expected:
        errors.append("historic checksum bytes drifted")
    if len(data) != contract.checksum_size:
        errors.append("historic checksum size drifted")
    if sha256_bytes(data) != contract.checksum_sha256:
        errors.append("historic checksum SHA-256 drifted")


def validate_source_evidence_blobs(
    root: Path,
    revision: str,
    evidence: dict[str, bytes],
    errors: list[str],
) -> None:
    if not COMMIT_RE.fullmatch(revision):
        errors.append("archive evidence source revision is not a full commit")
        return
    for name, data in evidence.items():
        relative = f"{HISTORIC_EVIDENCE_REL}/{name}"
        try:
            tree_row = subprocess.check_output(
                ["git", "-C", str(root), "ls-tree", revision, "--", relative],
                text=True,
                stderr=subprocess.STDOUT,
            ).strip()
            fields = tree_row.split(None, 3)
            if len(fields) != 4 or fields[0] != "100644" or fields[1] != "blob":
                errors.append(f"selected source lacks regular tracked loss evidence: {relative}")
                continue
            if git_bytes(root, revision, relative) != data:
                errors.append(f"selected source loss evidence bytes drifted: {relative}")
        except (OSError, subprocess.CalledProcessError) as exc:
            errors.append(f"selected source loss evidence unavailable: {relative}: {exc}")


def validate_loss_evidence(
    root: Path,
    contract: HistoricArchiveContract,
    errors: list[str],
    source_revision: str = "",
) -> str:
    evidence_root = root / HISTORIC_EVIDENCE_REL
    parent_rel = str(PurePosixPath(HISTORIC_EVIDENCE_REL).parent)
    if not path_components_are_real_directories(root, parent_rel):
        errors.append("historic loss evidence ancestor must be a real directory")
        return ""
    if evidence_root.is_symlink() or not evidence_root.is_dir():
        errors.append("historic loss evidence root must be a real directory")
        return ""
    expected_entries = {
        HISTORIC_MANIFEST_NAME,
        HISTORIC_CHECKSUM_NAME,
        HISTORIC_LOSS_RECEIPT_NAME,
    }
    entries = {
        item.relative_to(evidence_root).as_posix()
        for item in evidence_root.rglob("*")
    }
    if entries != expected_entries:
        errors.append(f"historic loss evidence inventory drifted: {sorted(entries)}")
    evidence: dict[str, bytes] = {}
    for name in sorted(expected_entries):
        path = evidence_root / name
        if not regular_file(path):
            errors.append(f"historic loss evidence must be a regular file: {name}")
            continue
        try:
            evidence[name] = path.read_bytes()
        except OSError as exc:
            errors.append(f"cannot read historic loss evidence {name}: {exc}")
    if set(evidence) != expected_entries:
        return ""
    validate_historic_manifest_bytes(evidence[HISTORIC_MANIFEST_NAME], contract, errors)
    validate_checksum_bytes(evidence[HISTORIC_CHECKSUM_NAME], contract, errors)
    try:
        receipt = strict_json_loads(evidence[HISTORIC_LOSS_RECEIPT_NAME])
    except (UnicodeDecodeError, json.JSONDecodeError, ValueError) as exc:
        errors.append(f"loss receipt is not strict JSON: {exc}")
    else:
        expected_receipt = expected_loss_receipt(contract)
        if not isinstance(receipt, dict) or not strict_value_equal(receipt, expected_receipt):
            errors.append("loss receipt facts or types drifted")
        elif (
            receipt.get("archive_restored") is not False
            or receipt.get("candidate_eligible") is not False
            or receipt.get("tracked_evidence", {}).get("archive_payload_recovered") is not False
            or receipt.get("reconstruction_attempt", {}).get("matches_historical") is not False
        ):
            errors.append("loss receipt must keep every recovery/eligibility claim false")
    if source_revision:
        validate_source_evidence_blobs(root, source_revision, evidence, errors)
    inventory_rows = [
        f"file\0{name}\0{sha256_bytes(evidence[name])}\n".encode()
        for name in sorted(evidence)
    ]
    return sha256_bytes(b"".join(inventory_rows))


def validate_physical_archive(
    archive_root: Path,
    contract: HistoricArchiveContract,
    errors: list[str],
) -> None:
    expected_entries = {
        HISTORIC_MANIFEST_NAME,
        HISTORIC_CHECKSUM_NAME,
        "macos",
        HISTORIC_ZIP_NAME,
    }
    if archive_root.is_symlink() or not archive_root.is_dir():
        errors.append("historic physical archive root must be a real directory")
        return
    entries = {
        item.relative_to(archive_root).as_posix()
        for item in archive_root.rglob("*")
    }
    if entries != expected_entries:
        errors.append(f"historic physical archive inventory drifted: {sorted(entries)}")
    macos = archive_root / "macos"
    if macos.is_symlink() or not macos.is_dir():
        errors.append("historic physical archive macos entry must be a real directory")
    manifest = archive_root / HISTORIC_MANIFEST_NAME
    checksum = archive_root / HISTORIC_CHECKSUM_NAME
    zip_path = archive_root / HISTORIC_ZIP_NAME
    for label, path in (("manifest", manifest), ("checksum", checksum), ("ZIP", zip_path)):
        if not regular_file(path):
            errors.append(f"historic physical archive {label} must be a regular file")
    if not all(regular_file(path) for path in (manifest, checksum, zip_path)):
        return
    validate_historic_manifest_bytes(manifest.read_bytes(), contract, errors)
    validate_checksum_bytes(checksum.read_bytes(), contract, errors)
    if zip_path.stat().st_size != contract.zip_size:
        errors.append("historic physical ZIP size drifted")
    if sha256_path(zip_path) != contract.zip_sha256:
        errors.append("historic physical ZIP SHA-256 drifted")
    actual_inventory = inventory_sha256(
        archive_root,
        (HISTORIC_MANIFEST_NAME, HISTORIC_CHECKSUM_NAME, HISTORIC_ZIP_NAME),
    )
    if actual_inventory != contract.archive_inventory_sha256:
        errors.append("historic physical archive aggregate SHA-256 drifted")


def archive_guard_state(
    root: Path,
    contract: HistoricArchiveContract = HISTORIC_ARCHIVE,
    source_revision: str = "",
) -> tuple[dict[str, object] | None, list[str]]:
    errors: list[str] = []
    archive_root = root / HISTORIC_ARCHIVE_REL
    archive_parent = str(PurePosixPath(HISTORIC_ARCHIVE_REL).parent)
    parent_is_real = path_components_are_real_directories(root, archive_parent)
    if archive_root.is_symlink():
        errors.append("historic archive root must not be a live or dangling symlink")
        return None, errors
    elif archive_root.exists():
        if not parent_is_real:
            errors.append("historic archive ancestor must be a real directory")
        validate_physical_archive(archive_root, contract, errors)
        if source_revision:
            validate_loss_evidence(
                root,
                contract,
                errors,
                source_revision=source_revision,
            )
        if errors:
            return None, errors
        return {
            "exists": True,
            "kind": "directory",
            "state": "physical_exact_archive",
            "sha256": contract.archive_inventory_sha256,
            "file_count": 3,
            "evidence_sha256": contract.archive_inventory_sha256,
        }, []
    else:
        if not parent_is_real:
            # Missing parents are allowed, but no existing ancestor may be a symlink or file.
            current = root
            for part in PurePosixPath(archive_parent).parts:
                current = current / part
                if current.is_symlink() or (current.exists() and not current.is_dir()):
                    errors.append("historic missing archive ancestor is not a real directory")
                    break
                if not current.exists():
                    break
        if errors:
            return None, errors
        evidence_sha = validate_loss_evidence(
            root,
            contract,
            errors,
            source_revision=source_revision,
        )
        if errors:
            return None, errors
        return {
            "exists": False,
            "kind": "missing",
            "state": "missing_with_loss_receipt",
            "sha256": MISSING_STATE_SHA256,
            "file_count": 0,
            "evidence_sha256": evidence_sha,
        }, []


def validate_archive_protected_row(
    row: dict[str, object],
    expected_state: dict[str, object] | None,
) -> list[str]:
    errors: list[str] = []
    before = row.get("before")
    after = row.get("after")
    if not isinstance(before, dict) or not isinstance(after, dict):
        return ["protected BUILD 2026.08.24.2 states must be objects"]
    if row.get("passed") is not True or not strict_value_equal(before, after):
        errors.append("protected BUILD 2026.08.24.2 before/after mismatch")
    if expected_state is None:
        errors.append("protected BUILD 2026.08.24.2 has no valid canonical state")
        return errors
    for side, state in (("before", before), ("after", after)):
        if not strict_value_equal(state, expected_state):
            errors.append(
                f"protected BUILD 2026.08.24.2 {side} is not exact physical or missing evidence state"
            )
    if before.get("state") not in {
        "physical_exact_archive",
        "missing_with_loss_receipt",
    }:
        errors.append("protected BUILD 2026.08.24.2 state label drifted")
    if not HASH_RE.fullmatch(str(before.get("evidence_sha256", ""))):
        errors.append("protected BUILD 2026.08.24.2 lacks evidence SHA-256")
    return errors


def git_bytes(repository: Path, revision: str, relative: str) -> bytes:
    return subprocess.check_output(
        ["git", "-C", str(repository), "show", f"{revision}:{relative}"]
    )


def app_tree(root: Path) -> tuple[str, int]:
    rows: list[bytes] = []
    count = 0
    for path in sorted(root.rglob("*"), key=lambda item: item.relative_to(root).as_posix()):
        relative = path.relative_to(root).as_posix()
        if path.is_symlink():
            rows.append(f"link\0{relative}\0{os.readlink(path)}\n".encode())
            count += 1
        elif path.is_file():
            rows.append(f"file\0{relative}\0{sha256_path(path)}\n".encode())
            count += 1
    return sha256_bytes(b"".join(rows)), count


def section_values(text: str, section: str) -> dict[str, str]:
    match = re.search(
        rf"(?ms)^\[{re.escape(section)}\]\s*$\n(.*?)(?=^\[|\Z)", text
    )
    if match is None:
        return {}
    values: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if "=" in line and not line.lstrip().startswith(("#", ";")):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip().strip('"')
    return values


def marker_tokens(marker: str, prefix: str) -> dict[str, str] | None:
    parts = marker.split()
    if not parts or parts[0] != prefix:
        return None
    values: dict[str, str] = {}
    for part in parts[1:]:
        if "=" not in part:
            return None
        key, value = part.split("=", 1)
        if not key or not value or key in values:
            return None
        values[key] = value
    return values


def source_repository_for_audit(artifact_root: Path, errors: list[str]) -> Path:
    configured = os.environ.get(AUDIT_SOURCE_ROOT_ENV, "").strip()
    if not configured:
        return artifact_root
    candidate = Path(configured)
    if not candidate.is_absolute():
        errors.append(f"{AUDIT_SOURCE_ROOT_ENV} must be an absolute path")
        return artifact_root
    repository = candidate.resolve()
    try:
        top_level = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "--show-toplevel"],
            text=True,
            stderr=subprocess.STDOUT,
        ).strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        errors.append(f"{AUDIT_SOURCE_ROOT_ENV} is not a readable Git worktree: {exc}")
        return repository
    if Path(top_level).resolve() != repository:
        errors.append(f"{AUDIT_SOURCE_ROOT_ENV} must name the Git worktree root")
    return repository


def product_source_identity_errors(
    repository: Path,
    package_revision: str,
    package_tree: str,
    product_revision: str = PRODUCT_REVISION,
    product_tree: str = PRODUCT_TREE,
    runtime_scope: tuple[str, ...] = PRODUCT_RUNTIME_SCOPE,
) -> list[str]:
    errors: list[str] = []
    if not COMMIT_RE.fullmatch(package_revision):
        return ["package source revision is not a full Git hash"]
    if not COMMIT_RE.fullmatch(package_tree):
        errors.append("package source tree is not a full Git hash")
    if not COMMIT_RE.fullmatch(product_revision):
        errors.append("product revision is not a full Git hash")
    if not COMMIT_RE.fullmatch(product_tree):
        errors.append("product tree is not a full Git hash")
    if errors:
        return errors
    try:
        resolved_package = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "--verify",
             f"{package_revision}^{{commit}}"],
            text=True,
            stderr=subprocess.STDOUT,
        ).strip()
        resolved_package_tree = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse",
             f"{resolved_package}^{{tree}}"],
            text=True,
            stderr=subprocess.STDOUT,
        ).strip()
        resolved_product = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "--verify",
             f"{product_revision}^{{commit}}"],
            text=True,
            stderr=subprocess.STDOUT,
        ).strip()
        resolved_product_tree = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse",
             f"{resolved_product}^{{tree}}"],
            text=True,
            stderr=subprocess.STDOUT,
        ).strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        return [f"product/package Git identity is unavailable: {exc}"]
    if resolved_package != package_revision:
        errors.append("package source revision did not resolve exactly")
    if resolved_package_tree != package_tree:
        errors.append("package source tree does not match revision")
    if resolved_product != product_revision:
        errors.append("product revision did not resolve exactly")
    if resolved_product_tree != product_tree:
        errors.append("exact product tree drifted")
    ancestor = subprocess.run(
        ["git", "-C", str(repository), "merge-base", "--is-ancestor",
         product_revision, package_revision],
        capture_output=True,
        text=True,
    )
    if ancestor.returncode != 0:
        errors.append("exact product commit is not an ancestor of package source")
    try:
        changed = subprocess.check_output(
            ["git", "-C", str(repository), "diff", "--name-only", "-z",
             "--no-renames", product_revision, package_revision, "--",
             *runtime_scope],
            stderr=subprocess.STDOUT,
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        errors.append(f"product/runtime zero-diff check failed: {exc}")
    else:
        changed_paths = [
            part.decode("utf-8", "replace")
            for part in changed.split(b"\0") if part
        ]
        if changed_paths:
            errors.append(
                "package source changes protected product/runtime paths: "
                + ", ".join(changed_paths)
            )
    return errors


def expected_real_story_roundtrips() -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for route in REAL_FLOW_ROUTES:
        route_name = str(route["route"])
        language = str(route["language"])
        receipts = int(route["receipts"])
        marker_parts = {
            "build": BUILD_ID,
            "language": language,
            "route": route_name,
            "m02": str(route["m02"]),
            "months": "6",
            "weeks": "24",
            "settlements": "6",
            "receipts": str(receipts),
            "story": "real",
            "manual_save": "1",
            "cold_restart": "1",
            "exact_resume": "1",
            "overlay": "clear",
            "input": "clear",
            "ap_ledger": "0",
        }
        marker = REAL_FLOW_MARKER_PREFIX + " " + " ".join(
            f"{key}={value}" for key, value in marker_parts.items()
        )
        rows.append({
            "passed": True,
            "language": language,
            "route": route_name,
            "m02": route["m02"],
            "months": 6,
            "weeks": 24,
            "settlements": 6,
            "receipts": receipts,
            "cold_restart": True,
            "exact_resume": True,
            "runtime_qa_namespace": route["runtime_qa_namespace"],
            "args": [
                "--story-demo-real-flow-smoke",
                f"--story-demo-real-flow-route={route_name}",
                f"--story-demo-language={language}",
            ],
            "marker": marker,
        })
    return rows


def real_story_roundtrip_errors(value: object) -> list[str]:
    errors: list[str] = []
    expected_rows = expected_real_story_roundtrips()
    if not isinstance(value, list) or len(value) != len(expected_rows):
        return [
            "real StoryMode roundtrip inventory must contain exact clean, "
            "restitution, escalation rows"
        ]
    for index, (actual, expected) in enumerate(zip(value, expected_rows)):
        if not isinstance(actual, dict):
            errors.append(f"real StoryMode roundtrip {index} must be an object")
            continue
        if set(actual) != REAL_FLOW_ROW_KEYS:
            errors.append(
                f"real StoryMode roundtrip {index} field inventory drifted"
            )
        if not strict_value_equal(actual, expected):
            errors.append(f"real StoryMode roundtrip {index} contract drifted")
        marker_values = marker_tokens(
            str(actual.get("marker", "")), REAL_FLOW_MARKER_PREFIX
        )
        expected_values = marker_tokens(
            str(expected["marker"]), REAL_FLOW_MARKER_PREFIX
        )
        if marker_values is None or marker_values != expected_values:
            errors.append(
                f"real StoryMode roundtrip {index} marker token contract drifted"
            )
    return errors


def expected_density_contract(
    repository: Path, revision: str
) -> dict[str, object]:
    paths = {
        "audit": "tools/story_demo_density_audit.py",
        "fixture": "tools/fixtures/story_demo_density_contract.json",
        "human_gates": "docs/human_gates.json",
    }
    blobs = {
        key: git_bytes(repository, revision, relative)
        for key, relative in paths.items()
    }
    return {
        "passed": True,
        "scope": "structural_automation_only",
        "source_revision": PRODUCT_REVISION,
        "source_tree": PRODUCT_TREE,
        "build_id": BUILD_ID,
        "audit_path": paths["audit"],
        "audit_sha256": sha256_bytes(blobs["audit"]),
        "fixture_path": paths["fixture"],
        "fixture_sha256": sha256_bytes(blobs["fixture"]),
        "human_gates_path": paths["human_gates"],
        "human_gates_sha256": sha256_bytes(blobs["human_gates"]),
        "self_test_marker": DENSITY_SELF_TEST_MARKER,
        "marker": DENSITY_MARKER,
        "human_gate_marker": DENSITY_HUMAN_GATE_MARKER,
    }


def density_contract_errors(
    value: object, repository: Path, revision: str
) -> list[str]:
    if not isinstance(value, dict):
        return ["story density evidence must be an object"]
    try:
        expected = expected_density_contract(repository, revision)
    except (OSError, subprocess.CalledProcessError) as exc:
        return [f"story density source evidence is unavailable: {exc}"]
    if not strict_value_equal(value, expected):
        return ["story density evidence contract drifted"]
    return []


def synthetic_archive_fixture() -> tuple[HistoricArchiveContract, bytes, bytes, bytes]:
    zip_bytes = b"synthetic exact historic ZIP for guard self-test\n"
    zip_hash = sha256_bytes(zip_bytes)
    source_revision = "1" * 40
    source_tree = "2" * 40
    app_hash = sha256_bytes(b"synthetic historic app tree")
    launcher_hash = sha256_bytes(b"synthetic historic launcher")
    pck_hash = sha256_bytes(b"synthetic historic pck")
    manifest_payload = {
        "schema_version": 1,
        "profile": "order124_m1m6_story_choice",
        "build_id": "2099.01.01.1",
        "source": {"revision": source_revision, "tree": source_tree},
        "engine": {"version": EXPECTED_GODOT},
        "package": {
            "zip": {
                "path": "build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.zip",
                "sha256": zip_hash,
                "size_bytes": len(zip_bytes),
            },
            "app": {"tree_sha256": app_hash, "file_count": 7},
            "launcher": {"sha256": launcher_hash, "size_bytes": 101},
            "resource_pack": {"sha256": pck_hash, "size_bytes": 202},
        },
    }
    manifest_bytes = (
        json.dumps(manifest_payload, ensure_ascii=False, indent=2) + "\n"
    ).encode("utf-8")
    manifest_hash = sha256_bytes(manifest_bytes)
    checksum_line = f"{manifest_hash}  build/order124/MANIFEST.json\n"
    checksum_bytes = checksum_line.encode("utf-8")
    checksum_hash = sha256_bytes(checksum_bytes)
    rows = (
        f"file\0{HISTORIC_MANIFEST_NAME}\0{manifest_hash}\n".encode(),
        f"file\0{HISTORIC_CHECKSUM_NAME}\0{checksum_hash}\n".encode(),
        f"file\0{HISTORIC_ZIP_NAME}\0{zip_hash}\n".encode(),
    )
    contract = HistoricArchiveContract(
        build_id="2099.01.01.1",
        source_revision=source_revision,
        source_tree=source_tree,
        engine_version=EXPECTED_GODOT,
        manifest_sha256=manifest_hash,
        manifest_size=len(manifest_bytes),
        checksum_sha256=checksum_hash,
        checksum_size=len(checksum_bytes),
        checksum_line=checksum_line,
        zip_sha256=zip_hash,
        zip_size=len(zip_bytes),
        app_tree_sha256=app_hash,
        app_file_count=7,
        launcher_sha256=launcher_hash,
        launcher_size=101,
        pck_sha256=pck_hash,
        pck_size=202,
        archive_inventory_sha256=sha256_bytes(b"".join(sorted(rows))),
        rebuild_zip_sha256=sha256_bytes(b"different rebuilt zip"),
        rebuild_zip_size=22,
        rebuild_app_tree_sha256=sha256_bytes(b"different rebuilt app"),
        rebuild_app_file_count=7,
        rebuild_launcher_sha256=sha256_bytes(b"different rebuilt launcher"),
        rebuild_launcher_size=101,
        rebuild_pck_sha256=sha256_bytes(b"different rebuilt pck"),
        rebuild_pck_size=202,
    )
    return contract, manifest_bytes, checksum_bytes, zip_bytes


def materialize_loss_fixture(
    root: Path,
    contract: HistoricArchiveContract,
    manifest_bytes: bytes,
    checksum_bytes: bytes,
) -> None:
    evidence = root / HISTORIC_EVIDENCE_REL
    evidence.mkdir(parents=True)
    (evidence / HISTORIC_MANIFEST_NAME).write_bytes(manifest_bytes)
    (evidence / HISTORIC_CHECKSUM_NAME).write_bytes(checksum_bytes)
    (evidence / HISTORIC_LOSS_RECEIPT_NAME).write_text(
        json.dumps(expected_loss_receipt(contract), ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def materialize_physical_fixture(
    root: Path,
    manifest_bytes: bytes,
    checksum_bytes: bytes,
    zip_bytes: bytes,
) -> None:
    archive = root / HISTORIC_ARCHIVE_REL
    (archive / "macos").mkdir(parents=True)
    (archive / HISTORIC_MANIFEST_NAME).write_bytes(manifest_bytes)
    (archive / HISTORIC_CHECKSUM_NAME).write_bytes(checksum_bytes)
    (archive / HISTORIC_ZIP_NAME).write_bytes(zip_bytes)


def archive_guard_self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    checks = 0
    errors.extend(validate_archive_contract_constants(HISTORIC_ARCHIVE))
    checks += 15
    actual_state, actual_errors = archive_guard_state(root)
    checks += 1
    if (
        actual_errors
        or actual_state is None
        or actual_state.get("state")
        not in {"physical_exact_archive", "missing_with_loss_receipt"}
    ):
        errors.append("current historic archive is neither exact physical nor canonical missing evidence")

    contract, manifest_bytes, checksum_bytes, zip_bytes = synthetic_archive_fixture()

    def expect_valid(case_root: Path, state_name: str, label: str) -> None:
        nonlocal checks
        state, case_errors = archive_guard_state(case_root, contract)
        checks += 1
        if case_errors or state is None or state.get("state") != state_name:
            errors.append(f"archive guard rejected valid {label}: {case_errors}")

    def expect_invalid(case_root: Path, label: str) -> None:
        nonlocal checks
        state, case_errors = archive_guard_state(case_root, contract)
        checks += 1
        if state is not None or not case_errors:
            errors.append(f"archive guard accepted adversarial {label}")

    with tempfile.TemporaryDirectory(prefix="story-demo-archive-guard-") as temporary:
        base = Path(temporary)
        physical = base / "valid-physical"
        materialize_physical_fixture(physical, manifest_bytes, checksum_bytes, zip_bytes)
        expect_valid(physical, "physical_exact_archive", "physical archive")

        missing = base / "valid-missing"
        materialize_loss_fixture(missing, contract, manifest_bytes, checksum_bytes)
        expect_valid(missing, "missing_with_loss_receipt", "missing evidence")

        empty = base / "empty-archive"
        (empty / HISTORIC_ARCHIVE_REL).mkdir(parents=True)
        expect_invalid(empty, "empty archive directory")

        manifest_only = base / "manifest-only"
        archive = manifest_only / HISTORIC_ARCHIVE_REL
        archive.mkdir(parents=True)
        (archive / HISTORIC_MANIFEST_NAME).write_bytes(manifest_bytes)
        expect_invalid(manifest_only, "manifest-only archive")

        zip_only = base / "zip-only"
        archive = zip_only / HISTORIC_ARCHIVE_REL
        (archive / "macos").mkdir(parents=True)
        (archive / HISTORIC_ZIP_NAME).write_bytes(zip_bytes)
        expect_invalid(zip_only, "ZIP-only archive")

        fake_zip = base / "fake-zip"
        materialize_physical_fixture(fake_zip, manifest_bytes, checksum_bytes, b"fake")
        expect_invalid(fake_zip, "fake ZIP")

        extra = base / "extra-entry"
        materialize_physical_fixture(extra, manifest_bytes, checksum_bytes, zip_bytes)
        (extra / HISTORIC_ARCHIVE_REL / "extra-empty").mkdir()
        expect_invalid(extra, "extra empty archive directory")

        target = base / "root-link-target"
        materialize_physical_fixture(target, manifest_bytes, checksum_bytes, zip_bytes)
        root_link = base / "root-link"
        (root_link / PurePosixPath(HISTORIC_ARCHIVE_REL).parent).mkdir(parents=True)
        (root_link / HISTORIC_ARCHIVE_REL).symlink_to(
            target / HISTORIC_ARCHIVE_REL,
            target_is_directory=True,
        )
        expect_invalid(root_link, "live root symlink")

        dangling = base / "dangling-root-link"
        (dangling / PurePosixPath(HISTORIC_ARCHIVE_REL).parent).mkdir(parents=True)
        (dangling / HISTORIC_ARCHIVE_REL).symlink_to(
            base / "does-not-exist",
            target_is_directory=True,
        )
        expect_invalid(dangling, "dangling root symlink")

        nested_link = base / "nested-link"
        materialize_physical_fixture(nested_link, manifest_bytes, checksum_bytes, zip_bytes)
        nested_archive = nested_link / HISTORIC_ARCHIVE_REL
        external_macos = base / "external-macos"
        shutil.move(str(nested_archive / "macos"), external_macos)
        (nested_archive / "macos").symlink_to(external_macos, target_is_directory=True)
        expect_invalid(nested_link, "nested directory symlink")

        file_link = base / "file-link"
        materialize_physical_fixture(file_link, manifest_bytes, checksum_bytes, zip_bytes)
        linked_manifest = file_link / HISTORIC_ARCHIVE_REL / HISTORIC_MANIFEST_NAME
        external_manifest = base / "external-manifest.json"
        shutil.move(str(linked_manifest), external_manifest)
        linked_manifest.symlink_to(external_manifest)
        expect_invalid(file_link, "file symlink")

        special_file = base / "special-file"
        materialize_physical_fixture(special_file, manifest_bytes, checksum_bytes, zip_bytes)
        special_zip = special_file / HISTORIC_ARCHIVE_REL / HISTORIC_ZIP_NAME
        special_zip.unlink()
        os.mkfifo(special_zip)
        expect_invalid(special_file, "special-file ZIP")

        def mutated_missing(label: str) -> tuple[Path, Path]:
            case_root = base / label
            materialize_loss_fixture(case_root, contract, manifest_bytes, checksum_bytes)
            return case_root, case_root / HISTORIC_EVIDENCE_REL

        case_root, evidence = mutated_missing("missing-manifest")
        (evidence / HISTORIC_MANIFEST_NAME).unlink()
        expect_invalid(case_root, "missing tracked manifest")

        case_root, evidence = mutated_missing("missing-checksum")
        (evidence / HISTORIC_CHECKSUM_NAME).unlink()
        expect_invalid(case_root, "missing tracked checksum")

        for label, replacement in (
            ("checksum-one-space", checksum_bytes.replace(b"  build/", b" build/")),
            ("checksum-crlf", checksum_bytes[:-1] + b"\r\n"),
            ("checksum-no-lf", checksum_bytes[:-1]),
            ("checksum-path-rewrite", checksum_bytes.replace(b"build/order124/", b"tools/evidence/")),
        ):
            case_root, evidence = mutated_missing(label)
            (evidence / HISTORIC_CHECKSUM_NAME).write_bytes(replacement)
            expect_invalid(case_root, label)

        case_root, evidence = mutated_missing("nonexact-manifest")
        (evidence / HISTORIC_MANIFEST_NAME).write_bytes(manifest_bytes + b" ")
        expect_invalid(case_root, "nonexact manifest")

        case_root, evidence = mutated_missing("evidence-file-link")
        evidence_manifest = evidence / HISTORIC_MANIFEST_NAME
        external_evidence_manifest = base / "external-evidence-manifest.json"
        shutil.move(str(evidence_manifest), external_evidence_manifest)
        evidence_manifest.symlink_to(external_evidence_manifest)
        expect_invalid(case_root, "evidence file symlink")

        case_root, evidence = mutated_missing("evidence-dangling-link")
        evidence_checksum = evidence / HISTORIC_CHECKSUM_NAME
        evidence_checksum.unlink()
        evidence_checksum.symlink_to(base / "missing-checksum-target")
        expect_invalid(case_root, "evidence dangling file symlink")

        def mutate_receipt(label: str, mutation) -> None:
            case_root, evidence = mutated_missing(label)
            receipt_path = evidence / HISTORIC_LOSS_RECEIPT_NAME
            payload = strict_json_loads(receipt_path.read_bytes())
            assert isinstance(payload, dict)
            mutation(payload)
            receipt_path.write_text(
                json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            expect_invalid(case_root, label)

        mutate_receipt("archive-restored-true", lambda value: value.__setitem__("archive_restored", True))
        mutate_receipt("candidate-eligible-true", lambda value: value.__setitem__("candidate_eligible", True))
        mutate_receipt("false-as-zero", lambda value: value.__setitem__("archive_restored", 0))
        mutate_receipt(
            "altered-historic-hash",
            lambda value: value["expected_artifacts"]["zip"].__setitem__("sha256", "0" * 64),
        )
        mutate_receipt(
            "altered-historic-size",
            lambda value: value["expected_artifacts"]["zip"].__setitem__("size_bytes", 1),
        )
        mutate_receipt(
            "stale-source-receipt",
            lambda value: value["source"].__setitem__("revision", "3" * 40),
        )

        case_root, evidence = mutated_missing("duplicate-receipt-key")
        receipt_path = evidence / HISTORIC_LOSS_RECEIPT_NAME
        receipt_bytes = receipt_path.read_bytes().replace(
            b'  "archive_restored": false,\n',
            b'  "archive_restored": false,\n  "archive_restored": false,\n',
            1,
        )
        receipt_path.write_bytes(receipt_bytes)
        expect_invalid(case_root, "duplicate receipt key")

        root_symlink = base / "evidence-root-symlink"
        external = base / "external-evidence-root"
        materialize_loss_fixture(external, contract, manifest_bytes, checksum_bytes)
        (root_symlink / PurePosixPath(HISTORIC_EVIDENCE_REL).parent).mkdir(parents=True)
        (root_symlink / HISTORIC_EVIDENCE_REL).symlink_to(
            external / HISTORIC_EVIDENCE_REL,
            target_is_directory=True,
        )
        expect_invalid(root_symlink, "evidence root symlink")

        ancestor_symlink = base / "evidence-ancestor-symlink"
        external_tools = base / "external-tools"
        (external_tools / "evidence/order124_build_2026.08.24.2").mkdir(parents=True)
        source_evidence = missing / HISTORIC_EVIDENCE_REL
        for name in (HISTORIC_MANIFEST_NAME, HISTORIC_CHECKSUM_NAME, HISTORIC_LOSS_RECEIPT_NAME):
            shutil.copy2(source_evidence / name, external_tools / "evidence/order124_build_2026.08.24.2" / name)
        ancestor_symlink.mkdir()
        (ancestor_symlink / "tools").symlink_to(external_tools, target_is_directory=True)
        expect_invalid(ancestor_symlink, "evidence ancestor symlink")

        case_root, evidence = mutated_missing("evidence-extra-entry")
        (evidence / "EXTRA").write_text("extra\n", encoding="utf-8")
        expect_invalid(case_root, "extra evidence entry")

        tracked = base / "tracked-source"
        tracked.mkdir()
        git_base = ["git", "-C", str(tracked), "-c", "user.name=Archive Guard", "-c", "user.email=guard@example.invalid"]
        subprocess.run(["git", "-C", str(tracked), "init", "-q"], check=True)
        subprocess.run(git_base + ["commit", "--allow-empty", "-q", "-m", "empty"], check=True)
        empty_revision = subprocess.check_output(
            ["git", "-C", str(tracked), "rev-parse", "HEAD"], text=True
        ).strip()
        materialize_loss_fixture(tracked, contract, manifest_bytes, checksum_bytes)
        subprocess.run(["git", "-C", str(tracked), "add", HISTORIC_EVIDENCE_REL], check=True)
        subprocess.run(git_base + ["commit", "-q", "-m", "evidence"], check=True)
        evidence_revision = subprocess.check_output(
            ["git", "-C", str(tracked), "rev-parse", "HEAD"], text=True
        ).strip()
        state, case_errors = archive_guard_state(
            tracked,
            contract,
            source_revision=evidence_revision,
        )
        checks += 1
        if case_errors or state is None:
            errors.append(f"archive guard rejected evidence from selected source commit: {case_errors}")
        state, case_errors = archive_guard_state(
            tracked,
            contract,
            source_revision=empty_revision,
        )
        checks += 1
        if state is not None or not case_errors:
            errors.append("archive guard accepted selected source commit without loss evidence")
        subprocess.run(
            [
                "git",
                "-C",
                str(tracked),
                "update-index",
                "--chmod=+x",
                f"{HISTORIC_EVIDENCE_REL}/{HISTORIC_MANIFEST_NAME}",
            ],
            check=True,
        )
        subprocess.run(git_base + ["commit", "-q", "-m", "bad mode"], check=True)
        executable_revision = subprocess.check_output(
            ["git", "-C", str(tracked), "rev-parse", "HEAD"], text=True
        ).strip()
        state, case_errors = archive_guard_state(
            tracked,
            contract,
            source_revision=executable_revision,
        )
        checks += 1
        if state is not None or not case_errors:
            errors.append("archive guard accepted non-100644 evidence blob")

        valid_state, valid_state_errors = archive_guard_state(missing, contract)
        if valid_state is None or valid_state_errors:
            errors.append("could not prepare protected-row guard self-test")
        else:
            valid_row = {
                "before": dict(valid_state),
                "after": dict(valid_state),
                "passed": True,
            }
            checks += 1
            if validate_archive_protected_row(valid_row, valid_state):
                errors.append("protected-row guard rejected canonical missing state")

            partial_state = {
                "exists": True,
                "kind": "directory",
                "state": "physical_exact_archive",
                "sha256": contract.archive_inventory_sha256,
                "file_count": 3,
                "evidence_sha256": contract.archive_inventory_sha256,
            }
            stable_partial = {
                "before": dict(partial_state),
                "after": dict(partial_state),
                "passed": True,
            }
            checks += 1
            if not validate_archive_protected_row(stable_partial, valid_state):
                errors.append("protected-row guard accepted stable fabricated physical state")

            mixed_row = {
                "before": dict(valid_state),
                "after": dict(partial_state),
                "passed": True,
            }
            checks += 1
            if not validate_archive_protected_row(mixed_row, valid_state):
                errors.append("protected-row guard accepted mixed before/after states")

    return errors, checks


def package_contract_self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    checks = 0

    valid_roundtrips = expected_real_story_roundtrips()
    checks += 1
    if real_story_roundtrip_errors(valid_roundtrips):
        errors.append("real StoryMode route validator rejected its exact baseline")

    def reject_roundtrip(label: str, mutate: object) -> None:
        nonlocal checks
        candidate = copy.deepcopy(valid_roundtrips)
        mutate(candidate)  # type: ignore[operator]
        checks += 1
        if not real_story_roundtrip_errors(candidate):
            errors.append(f"real StoryMode route validator accepted {label}")

    reject_roundtrip("missing route", lambda rows: rows.pop())
    reject_roundtrip(
        "duplicate route", lambda rows: rows.__setitem__(1, copy.deepcopy(rows[0]))
    )
    reject_roundtrip(
        "route order swap", lambda rows: rows.__setitem__(slice(0, 2), [rows[1], rows[0]])
    )
    reject_roundtrip(
        "wrong locale", lambda rows: rows[1].__setitem__("language", "ko")
    )
    reject_roundtrip(
        "wrong M02 identity", lambda rows: rows[1].__setitem__("m02", "clean")
    )
    reject_roundtrip(
        "wrong receipt count", lambda rows: rows[1].__setitem__("receipts", 9)
    )
    reject_roundtrip(
        "boolean receipt count", lambda rows: rows[0].__setitem__("receipts", True)
    )
    reject_roundtrip(
        "shared namespace", lambda rows: rows[1].__setitem__(
            "runtime_qa_namespace", rows[0]["runtime_qa_namespace"])
    )
    reject_roundtrip(
        "wrong args", lambda rows: rows[1]["args"].__setitem__(
            2, "--story-demo-language=ko")
    )
    reject_roundtrip(
        "legacy choice field", lambda rows: rows[0].__setitem__("choice", 0)
    )
    reject_roundtrip(
        "legacy choice argument", lambda rows: rows[0]["args"].__setitem__(
            1, "--story-demo-real-flow-choice=0")
    )
    reject_roundtrip(
        "marker missing route", lambda rows: rows[0].__setitem__(
            "marker", rows[0]["marker"].replace(" route=clean", "", 1))
    )
    reject_roundtrip(
        "marker duplicate route", lambda rows: rows[0].__setitem__(
            "marker", rows[0]["marker"] + " route=clean")
    )
    reject_roundtrip(
        "marker wrong route", lambda rows: rows[0].__setitem__(
            "marker", rows[0]["marker"].replace(
                "route=clean", "route=escalation", 1))
    )
    reject_roundtrip(
        "marker wrong receipts", lambda rows: rows[1].__setitem__(
            "marker", rows[1]["marker"].replace("receipts=10", "receipts=9", 1))
    )
    reject_roundtrip(
        "marker extra legacy choice", lambda rows: rows[2].__setitem__(
            "marker", rows[2]["marker"] + " choice=1")
    )
    reject_roundtrip(
        "marker bare token", lambda rows: rows[2].__setitem__(
            "marker", rows[2]["marker"] + " stray")
    )

    with tempfile.TemporaryDirectory(prefix="story-demo-density-contract-") as temporary:
        density_repository = Path(temporary)
        subprocess.check_call(["git", "init", "-q", str(density_repository)])
        subprocess.check_call(
            ["git", "-C", str(density_repository), "config", "user.name", "QA"])
        subprocess.check_call(
            ["git", "-C", str(density_repository), "config", "user.email",
             "qa@example.invalid"])
        for relative, content in (
            ("tools/story_demo_density_audit.py", "audit\n"),
            ("tools/fixtures/story_demo_density_contract.json", "{}\n"),
            ("docs/human_gates.json", "{}\n"),
        ):
            destination = density_repository / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(content, encoding="utf-8")
        subprocess.check_call(["git", "-C", str(density_repository), "add", "."])
        subprocess.check_call(
            ["git", "-C", str(density_repository), "commit", "-q", "-m",
             "density fixture"])
        density_revision = subprocess.check_output(
            ["git", "-C", str(density_repository), "rev-parse", "HEAD"],
            text=True,
        ).strip()
        valid_density = expected_density_contract(
            density_repository, density_revision)
        checks += 1
        if density_contract_errors(
                valid_density, density_repository, density_revision):
            errors.append("density validator rejected its exact baseline")

        def reject_density(label: str, key: str, value: object) -> None:
            nonlocal checks
            candidate = copy.deepcopy(valid_density)
            candidate[key] = value
            checks += 1
            if not density_contract_errors(
                    candidate, density_repository, density_revision):
                errors.append(f"density validator accepted {label}")

        reject_density("self-test count drift", "self_test_marker",
                       DENSITY_SELF_TEST_MARKER.replace("29", "28"))
        reject_density("actual marker drift", "marker",
                       DENSITY_MARKER.replace("variants=14", "variants=13"))
        reject_density("human gate closure", "human_gate_marker",
                       DENSITY_HUMAN_GATE_MARKER.replace("OPEN", "GO"))
        reject_density("audit hash drift", "audit_sha256", "0" * 64)
        reject_density("fixture hash drift", "fixture_sha256", "0" * 64)
        reject_density("human gate hash drift", "human_gates_sha256", "0" * 64)
        reject_density("scope drift", "scope", "human_GO")
        reject_density("product revision drift", "source_revision", "0" * 40)
        reject_density("product tree drift", "source_tree", "0" * 40)
        reject_density("build drift", "build_id", "2026.08.25.1")

    with tempfile.TemporaryDirectory(prefix="story-demo-product-identity-") as temporary:
        repository = Path(temporary)
        subprocess.check_call(["git", "init", "-q", str(repository)])
        subprocess.check_call(
            ["git", "-C", str(repository), "config", "user.name", "QA"])
        subprocess.check_call(
            ["git", "-C", str(repository), "config", "user.email", "qa@example.invalid"])
        (repository / "project.godot").write_text("product\n", encoding="utf-8")
        (repository / "tools").mkdir()
        (repository / "tools" / "qa.txt").write_text("one\n", encoding="utf-8")
        subprocess.check_call(["git", "-C", str(repository), "add", "."])
        subprocess.check_call(
            ["git", "-C", str(repository), "commit", "-q", "-m", "product"])
        product_revision = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "HEAD"], text=True
        ).strip()
        product_tree = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "HEAD^{tree}"], text=True
        ).strip()
        (repository / "tools" / "qa.txt").write_text("two\n", encoding="utf-8")
        subprocess.check_call(["git", "-C", str(repository), "commit", "-qam", "qa"])
        qa_revision = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "HEAD"], text=True
        ).strip()
        qa_tree = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "HEAD^{tree}"], text=True
        ).strip()
        valid_identity_errors = product_source_identity_errors(
            repository, qa_revision, qa_tree, product_revision, product_tree,
            ("project.godot",))
        checks += 1
        if valid_identity_errors:
            errors.append(
                f"product identity rejected QA-only descendant: {valid_identity_errors}")
        (repository / "project.godot").write_text("runtime drift\n", encoding="utf-8")
        subprocess.check_call(["git", "-C", str(repository), "commit", "-qam", "runtime"])
        runtime_revision = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "HEAD"], text=True
        ).strip()
        runtime_tree = subprocess.check_output(
            ["git", "-C", str(repository), "rev-parse", "HEAD^{tree}"], text=True
        ).strip()
        checks += 1
        if not product_source_identity_errors(
            repository, runtime_revision, runtime_tree, product_revision,
            product_tree, ("project.godot",)):
            errors.append("product identity accepted runtime drift")
        checks += 1
        if not product_source_identity_errors(
            repository, product_revision, product_tree, qa_revision, qa_tree,
            ("project.godot",)):
            errors.append("product identity accepted a non-ancestor product")
        checks += 1
        if not product_source_identity_errors(
            repository, qa_revision, qa_tree, product_revision, "0" * 40,
            ("project.godot",)):
            errors.append("product identity accepted a wrong product tree")

    return errors, checks


def source_self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    build_path = root / "tools/build_story_demo_macos.sh"
    audit_path = root / "tools/story_demo_package_audit.py"
    controller_path = root / "playtests/order124/StoryChoiceM1M6Playtest.gd"
    for path in (root / relative for relative in SOURCE_CONTRACT):
        if not path.is_file():
            errors.append(f"missing source contract file: {path.relative_to(root)}")
    if errors:
        return errors, 0

    result = subprocess.run(
        ["bash", "-n", str(build_path)], capture_output=True, text=True
    )
    if result.returncode != 0:
        errors.append(f"build script syntax error: {result.stderr.strip()}")
    build_text = build_path.read_text(encoding="utf-8")
    runtime_scope_match = re.search(
        r"(?ms)^readonly -a PRODUCT_RUNTIME_SCOPE=\((.*?)^\)", build_text
    )
    if runtime_scope_match is None:
        errors.append("build script lacks exact product runtime scope array")
    else:
        builder_runtime_scope = tuple(
            line.strip() for line in runtime_scope_match.group(1).splitlines()
            if line.strip()
        )
        if builder_runtime_scope != PRODUCT_RUNTIME_SCOPE:
            errors.append("build script product runtime scope drifted")
    contract_paths_match = re.search(
        r"(?ms)^contract_paths = \[(.*?)^\]$", build_text
    )
    if contract_paths_match is None:
        errors.append("build manifest lacks source contract path list")
    else:
        try:
            builder_contract = tuple(ast.literal_eval(
                "[" + contract_paths_match.group(1) + "]"))
        except (SyntaxError, ValueError):
            builder_contract = ()
        if builder_contract != SOURCE_CONTRACT:
            errors.append("build manifest source contract path/order drifted")
    required_tokens = (
        "archive --format=tar",
        "SOURCE_STATUS",
        'STAGE_PROJECT="$WORK_DIR/source"',
        '"$STAGE_PROJECT/project.godot"',
        '"$STAGE_PROJECT/export_presets.cfg"',
        ENTRY_SCENE,
        CHECK_SCENE,
        PRESET,
        APP_STEM,
        BUILD_ID,
        CUSTOM_USER_DIR,
        "boot_splash/show_image",
        "--export-release",
        "codesign --force --deep --sign -",
        "STORY_DEMO_NATIVE_PROBE_PATH",
        "--story-demo-smoke",
        "--story-demo-return-smoke",
        "--story-demo-resume-smoke",
        "--story-demo-real-flow-smoke",
        "--story-demo-real-flow-route=clean",
        "--story-demo-real-flow-route=restitution",
        "--story-demo-real-flow-route=escalation",
        "--fixed-fps 60",
        "--qa=story-demo",
        TARGET_MARKER,
        RETURN_MARKER_PREFIX,
        RESUME_MARKER_PREFIX,
        APP_REL,
        "restore_candidate_user_data",
        "cleanup_recovery_after_success",
        "STORY_DEMO_RECOVERY_ROOT",
        "original-hold",
        "quarantine",
        "exact_states_match",
        "story_demo_candidate_user_dir",
        "order124_candidate_user_dir",
        "story_demo_build2_archive",
        HISTORIC_ARCHIVE_REL,
        HISTORIC_EVIDENCE_REL,
        "--archive-state",
        "--source-revision",
        "missing_with_loss_receipt",
        "pre_build_candidate_snapshot",
        "fresh_package_smoke",
        "cold_restart_resume",
        "real_story_roundtrips",
        "GangnamDream_StoryDemo_RuntimeQA_package_real_clean",
        "GangnamDream_StoryDemo_RuntimeQA_package_real_restitution",
        "GangnamDream_StoryDemo_RuntimeQA_package_real_escalation",
        "launcher_process",
        '"version": "2026.8.31"',
        "no_existing_candidate_save",
        "tools/audit_scope.json",
        ".json.bak",
        "capture_protected",
        "protected before/after mismatch",
        "story_demo_package_audit.py",
        "readonly SMOKE_TIMEOUT_TICKS=480",
        "timed_out=1",
        "for _grace_tick in $(seq 1 20)",
        "for _termination_grace_tick in $(seq 1 20)",
        "terminate_native_process_bounded",
        'terminate_native_process_bounded "$NATIVE_PID" "native no-argument probe"',
        'kill -KILL "$NATIVE_PID"',
        "exit_code=124",
        "STORY_DEMO_BUILD_LOCK_DIR",
        "EARLY_STORY_DEMO_BUILD_LOCK_DIR",
        ".GangnamDream_StoryDemo_v1.build-lock",
        "acquire_story_demo_build_lock",
        "release_story_demo_build_lock",
        'rmdir "$STORY_DEMO_BUILD_LOCK_DIR"',
        '"$STORY_DEMO_USER_DATA_RESTORED" != "1"',
        "PUBLISH_STAGE_ROOT",
        ".story_demo-publish.",
        "rollback_story_demo_publish",
        "PUBLISH_PREVIOUS_STATE",
        "PUBLISH_NEW_STATE",
        "PUBLISH_SWAP_STARTED=1",
        "PUBLISH_COMMITTED=1",
        "trap '' INT TERM",
        "trap '' INT TERM PIPE",
        'echo "STORY_DEMO_MACOS_BUILD_OK build=$BUILD_ID revision=$SOURCE_COMMIT tree=$SOURCE_TREE" || true',
        '"months=6" "weeks=24" "settlements=6" "receipts=9"',
        '"months=6" "weeks=24" "settlements=6" "receipts=10"',
        '"cold_restart=1"',
        '"exact_resume=1"',
        "PRODUCT_RUNTIME_SCOPE",
        "merge-base --is-ancestor",
        "diff --quiet --no-ext-diff",
        PRODUCT_REVISION,
        PRODUCT_TREE,
        "tools/story_demo_density_audit.py",
        "tools/fixtures/story_demo_density_contract.json",
        "docs/human_gates.json",
        DENSITY_SELF_TEST_MARKER,
        DENSITY_MARKER,
        DENSITY_HUMAN_GATE_MARKER,
        "require_exact_marker_tokens",
        AUDIT_SOURCE_ROOT_ENV,
    )
    for token in required_tokens:
        if token not in build_text:
            errors.append(f"build script missing required contract token: {token}")
    audit_text = audit_path.read_text(encoding="utf-8")
    audit_guard_tokens = (
        "archive_restored",
        "candidate_eligible",
        "physical_exact_archive",
        "missing_with_loss_receipt",
        "strict_json_loads",
    )
    for token in audit_guard_tokens:
        if token not in audit_text:
            errors.append(f"archive guard audit missing required token: {token}")
    for forbidden in (
        'rm -rf "$STORY_DEMO_USER_DATA_DIR"',
        'rm -rf "$FINAL_APP_OUTPUT"',
        'ditto "$VERIFIED_APP" "$FINAL_APP_OUTPUT"',
        'mv "$FINALIZED_ZIP" "$FINAL_ZIP"',
        '> "$FINAL_CHECKSUM"',
        "if ! restore_candidate_user_data",
    ):
        if forbidden in build_text:
            errors.append(f"build script contains unsafe recovery construct: {forbidden}")
    cold_sequence = (
        'run_godot_prefix_gate "$KO_LOG"',
        'run_godot_prefix_gate "$COLD_RESTART_RESUME_LOG"',
        'run_godot_prefix_gate "$EN_LOG"',
    )
    positions = [build_text.find(token) for token in cold_sequence]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        errors.append("cold-restart resume must run in a new launcher process immediately after the fresh KO smoke")
    normalized_build = " ".join(build_text.replace("\\\n", " ").split())
    real_flow_commands = (
        "-- --story-demo-real-flow-smoke --story-demo-real-flow-route=clean --story-demo-language=ko",
        "-- --story-demo-real-flow-smoke --story-demo-real-flow-route=restitution --story-demo-language=en",
        "-- --story-demo-real-flow-smoke --story-demo-real-flow-route=escalation --story-demo-language=zh-CN",
    )
    for command in real_flow_commands:
        if command not in normalized_build:
            errors.append(f"build script lacks real StoryMode package command: {command}")
    if normalized_build.count(
        '"$LAUNCHER" --rendering-driver opengl3 '
        '--resolution 1280x800 --fixed-fps 60 '
        '-- --story-demo-real-flow-smoke'
    ) != 3:
        errors.append(
            "all three real StoryMode package runs must use default CoreAudio "
            "with deterministic 60 FPS pacing"
        )
    if "--audio-driver Dummy" in normalized_build:
        errors.append(
            "real StoryMode package runs must not hide CoreAudio teardown"
        )
    if "--story-demo-real-flow-choice=" in normalized_build:
        errors.append("build script still uses a legacy real-flow choice argument")
    if build_text.count("emitted a non-exact marker count") != 3:
        errors.append("each real StoryMode package run must require exactly one marker")

    lock_position = build_text.find(
        "acquire_story_demo_build_lock || lock_acquire_status=$?"
    )
    early_lock_position = build_text.find(
        'EARLY_STORY_DEMO_BUILD_LOCK_DIR="$HOME/Library/Application Support/'
    )
    source_status_position = build_text.find('SOURCE_STATUS="$(git -C "$PROJECT_DIR" status')
    product_identity_position = build_text.find("merge-base --is-ancestor")
    archive_preflight_position = build_text.find("archive_guard_preflight_status=0")
    staging_position = build_text.find('WORK_DIR="$(mktemp -d')
    snapshot_position = build_text.find(
        'capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_ORIGINAL_STATE"'
    )
    if (
        early_lock_position < 0
        or source_status_position < 0
        or early_lock_position >= source_status_position
    ):
        errors.append("concurrent-build lock preflight must precede source preflight")
    if (
        product_identity_position < source_status_position
        or archive_preflight_position < product_identity_position
        or staging_position < archive_preflight_position
    ):
        errors.append(
            "product identity and archive guards must pass before staging or mutation"
        )
    if lock_position < 0 or snapshot_position < 0 or lock_position >= snapshot_position:
        errors.append("exclusive build lock must be acquired before the candidate snapshot")
    lock_mask_position = build_text.rfind("trap '' INT TERM", 0, lock_position)
    lock_handler_restore = build_text.find("trap 'exit 130' INT", lock_position)
    if lock_mask_position < 0 or lock_handler_restore < lock_position:
        errors.append("lock mkdir/ownership handoff must be signal-masked")
    cleanup_position = build_text.find("cleanup() {")
    rollback_position = build_text.find("rollback_story_demo_publish", cleanup_position)
    release_position = build_text.find("release_story_demo_build_lock", cleanup_position)
    if (
        cleanup_position < 0
        or rollback_position < cleanup_position
        or release_position < rollback_position
    ):
        errors.append("EXIT cleanup must roll back publishing before releasing the build lock")
    cleanup_end = build_text.find("trap cleanup EXIT", cleanup_position)
    cleanup_body = build_text[cleanup_position:cleanup_end]
    lock_owner_guard = cleanup_body.find(
        'if [[ "$STORY_DEMO_BUILD_LOCK_ACQUIRED" == "1" ]]'
    )
    qa_cleanup = cleanup_body.find('remove_runtime_qa_dir "$qa_cleanup_path"')
    if lock_owner_guard < 0 or qa_cleanup < lock_owner_guard:
        errors.append("only the exclusive-lock owner may clean fixed RuntimeQA namespaces")
    for namespace_variable in (
        "$REAL_FLOW_CLEAN_QA_DIR",
        "$REAL_FLOW_RESTITUTION_QA_DIR",
        "$REAL_FLOW_ESCALATION_QA_DIR",
    ):
        if namespace_variable not in cleanup_body:
            errors.append(
                f"EXIT cleanup lacks exact RuntimeQA namespace: {namespace_variable}"
            )
    cleanup_termination = cleanup_body.find(
        'terminate_native_process_bounded "$NATIVE_PID" "cleanup launcher"'
    )
    cleanup_restore = cleanup_body.find("restore_candidate_user_data")
    if (
        cleanup_termination < lock_owner_guard
        or cleanup_restore < cleanup_termination
    ):
        errors.append("EXIT cleanup must bound launcher termination before restoration")
    termination_start = build_text.find("terminate_native_process_bounded() {")
    termination_end = build_text.find("rollback_story_demo_publish() {", termination_start)
    termination_body = build_text[termination_start:termination_end]
    termination_sequence = (
        'kill -TERM "$process_id"',
        "for _termination_grace_tick in $(seq 1 20)",
        "sleep 0.25",
        'kill -KILL "$process_id"',
        'wait "$process_id"',
    )
    termination_positions = [termination_body.find(token) for token in termination_sequence]
    if (
        termination_start < 0
        or termination_end < termination_start
        or any(position < 0 for position in termination_positions)
        or termination_positions != sorted(termination_positions)
    ):
        errors.append("bounded launcher termination must use TERM, 5s grace, KILL, then wait")

    smoke_gate_start = build_text.find("run_godot_prefix_gate() {")
    smoke_gate_end = build_text.find("require_marker_tokens() {", smoke_gate_start)
    smoke_gate_body = build_text[smoke_gate_start:smoke_gate_end]
    smoke_timeout_sequence = (
        'for _smoke_tick in $(seq 1 "$SMOKE_TIMEOUT_TICKS")',
        "sleep 0.25",
        "timed_out=1",
        "for _grace_tick in $(seq 1 20)",
        "sleep 0.25",
        'kill -KILL "$NATIVE_PID"',
        "exit_code=124",
    )
    search_from = 0
    for token in smoke_timeout_sequence:
        position = smoke_gate_body.find(token, search_from)
        if position < 0:
            errors.append(f"120s smoke timeout sequence lacks: {token}")
            break
        search_from = position + len(token)
    staged_audit_position = normalized_build.find(
        'STORY_DEMO_AUDIT_SOURCE_ROOT="$PROJECT_DIR" python3 '
        '"$STAGE_PROJECT/tools/story_demo_package_audit.py" --manifest "$PUBLISH_MANIFEST"'
    )
    swap_position = normalized_build.find("PUBLISH_SWAP_STARTED=1")
    if (
        staged_audit_position < 0
        or swap_position < 0
        or staged_audit_position >= swap_position
    ):
        errors.append("publish-stage manifest audit must pass before the final-set swap starts")
    publish_moves = (
        'mv "$OUTPUT_DIR" "$PUBLISH_PREVIOUS_SET"',
        'mv "$PUBLISH_READY_SET" "$OUTPUT_DIR"',
    )
    publish_move_positions = [normalized_build.find(token) for token in publish_moves]
    final_audit_position = normalized_build.find(
        'STORY_DEMO_AUDIT_SOURCE_ROOT="$PROJECT_DIR" python3 '
        '"$STAGE_PROJECT/tools/story_demo_package_audit.py" --manifest "$FINAL_MANIFEST"'
    )
    commit_position = normalized_build.rfind("PUBLISH_COMMITTED=1")
    commit_mask_position = normalized_build.rfind(
        "trap '' INT TERM", 0, commit_position
    )
    if (
        any(position < swap_position for position in publish_move_positions)
        or publish_move_positions != sorted(publish_move_positions)
        or final_audit_position < publish_move_positions[-1]
        or commit_position < final_audit_position
        or commit_mask_position < final_audit_position
    ):
        errors.append("publish set must swap by ordered renames and signal-masked commit after final audit")

    wrapper_sample = (
        f"{SMOKE_MARKER_PREFIX} language=ko size=1280x800 "
        + " ".join(
            f"{key}={value}" for key, value in WRAPPER_REQUIRED_MARKER_TOKENS.items()
        )
    )
    expected_wrapper_sample = {
        "language": "ko",
        "size": "1280x800",
        **WRAPPER_REQUIRED_MARKER_TOKENS,
    }
    if marker_tokens(wrapper_sample, SMOKE_MARKER_PREFIX) != expected_wrapper_sample:
        errors.append("wrapper smoke marker token parser drifted")
    wrapper_contract_checks = 1
    wrapper_parts = wrapper_sample.split()
    for key in expected_wrapper_sample:
        missing_sample = " ".join(
            part for part in wrapper_parts if not part.startswith(f"{key}=")
        )
        if marker_tokens(missing_sample, SMOKE_MARKER_PREFIX) == expected_wrapper_sample:
            errors.append(f"wrapper smoke marker accepted missing {key}")
        wrapper_contract_checks += 1
    duplicate_sample = wrapper_sample + " language=ja"
    if marker_tokens(duplicate_sample, SMOKE_MARKER_PREFIX) is not None:
        errors.append("wrapper smoke marker accepted a duplicate token")
    wrapper_contract_checks += 1
    if marker_tokens(wrapper_sample, "WRONG_PREFIX") is not None:
        errors.append("wrapper smoke marker accepted a wrong prefix")
    wrapper_contract_checks += 1
    if marker_tokens(wrapper_sample + " empty=", SMOKE_MARKER_PREFIX) is not None:
        errors.append("wrapper smoke marker accepted an empty token value")
    wrapper_contract_checks += 1

    controller_tokens = (
        "--story-demo-return-smoke",
        "--story-demo-resume-smoke",
        "STORY_DEMO_RETURN_SMOKE",
        "STORY_DEMO_RESUME_SMOKE",
        "--story-demo-real-flow-smoke",
        "--story-demo-real-flow-route=",
        # Compatibility only; package commands above must use exact route IDs.
        "--story-demo-real-flow-choice=",
        "STORY_DEMO_REAL_FLOW_SMOKE",
        "language=%s route=%s m02=%s",
        "months=6 weeks=24 settlements=6 receipts=%d",
        "cold_restart=1",
        "exact_resume=1",
    )
    controller_text = controller_path.read_text(encoding="utf-8")
    for token in controller_tokens:
        if token not in controller_text:
            errors.append(f"story-demo controller missing package-smoke token: {token}")

    project = section_values((root / "project.godot").read_text(encoding="utf-8"), "application")
    if project.get("run/main_scene") != "res://scenes/SplashScreen.tscn":
        errors.append("product project.godot main scene drifted from SplashScreen")
    if "config/use_custom_user_dir" in project or "config/custom_user_dir_name" in project:
        errors.append("candidate custom user-dir settings leaked into product project.godot")

    preset_text = (root / "export_presets.cfg").read_text(encoding="utf-8")
    mac_sections = []
    for match in re.finditer(r"(?m)^\[preset\.(\d+)\]$", preset_text):
        number = match.group(1)
        values = section_values(preset_text, f"preset.{number}")
        if values.get("platform") == "macOS":
            mac_sections.append(number)
    if not mac_sections:
        errors.append("product export_presets.cfg has no macOS preset to stage")
    else:
        number = mac_sections[0]
        preset = section_values(preset_text, f"preset.{number}")
        options = section_values(preset_text, f"preset.{number}.options")
        if preset.get("name") != "macOS":
            errors.append("product macOS preset identity drifted")
        if options.get("application/bundle_identifier") != "dev.junheelee.gangnamdream":
            errors.append("product macOS bundle identifier drifted")
        if options.get("binary_format/architecture") != "universal":
            errors.append("product macOS preset must remain universal")

    # The packaging, controller, and check pairs are independently authored.
    # Require completeness within a pair; the build preflight requires all pairs.
    for pair in (
        (
            "playtests/order124/StoryChoiceM1M6Playtest.gd",
            "playtests/order124/StoryChoiceM1M6Playtest.gd.uid",
            "playtests/order124/StoryChoiceM1M6Playtest.tscn",
        ),
        (
            "tools/StoryDemoFourLanguageCheck.gd",
            "tools/StoryDemoFourLanguageCheck.gd.uid",
            "tools/StoryDemoFourLanguageCheck.tscn",
        ),
    ):
        paths = [root / path for path in pair]
        if any(path.exists() for path in paths):
            for relative in pair:
                if not (root / relative).is_file():
                    errors.append(f"incomplete story-demo source pair: {relative}")
    archive_errors, archive_checks = archive_guard_self_test(root)
    errors.extend(archive_errors)
    contract_errors, contract_checks = package_contract_self_test(root)
    errors.extend(contract_errors)
    return (
        errors,
        len(required_tokens)
        + len(forbidden)
        + len(controller_tokens)
        + len(audit_guard_tokens)
        + len(real_flow_commands)
        + wrapper_contract_checks
        + archive_checks
        + contract_checks
        + 15,
    )


def validate_manifest_shape(payload: dict, errors: list[str]) -> None:
    expected = {
        "schema_version": 1,
        "profile": PROFILE,
        "game_version": GAME_VERSION,
        "build_id": BUILD_ID,
        "build_flavor": BUILD_FLAVOR,
    }
    for key, value in expected.items():
        if payload.get(key) != value:
            errors.append(f"manifest {key}={payload.get(key)!r}, expected {value!r}")
    timestamps = payload.get("timestamps", {})
    if not isinstance(timestamps, dict):
        errors.append("manifest timestamps must be an object")
    else:
        for key in ("started_utc", "generated_utc"):
            if not UTC_RE.fullmatch(str(timestamps.get(key, ""))):
                errors.append(f"manifest timestamps.{key} is not canonical UTC")
        if all(UTC_RE.fullmatch(str(timestamps.get(key, ""))) for key in ("started_utc", "generated_utc")):
            started = datetime.strptime(timestamps["started_utc"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
            generated = datetime.strptime(timestamps["generated_utc"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
            if generated < started:
                errors.append("manifest generated_utc predates started_utc")
    source = payload.get("source", {})
    if not isinstance(source, dict):
        errors.append("manifest source must be an object")
    else:
        expected_source_keys = {
            "requested_ref", "revision", "tree", "product_revision",
            "product_tree", "product_ancestor", "product_runtime_scope",
            "product_runtime_diff", "status", "staging", "contract_files",
            "staged_project_sha256", "staged_export_presets_sha256",
        }
        if set(source) != expected_source_keys:
            errors.append("manifest source field inventory drifted")
        for key in ("revision", "tree"):
            if not COMMIT_RE.fullmatch(str(source.get(key, ""))):
                errors.append(f"manifest source.{key} is not a full Git hash")
        if source.get("product_revision") != PRODUCT_REVISION:
            errors.append("manifest source.product_revision drifted")
        if source.get("product_tree") != PRODUCT_TREE:
            errors.append("manifest source.product_tree drifted")
        if source.get("product_ancestor") is not True:
            errors.append("manifest source.product_ancestor must be true")
        if not strict_value_equal(
            source.get("product_runtime_scope"), list(PRODUCT_RUNTIME_SCOPE)
        ):
            errors.append("manifest product runtime scope drifted")
        if not strict_value_equal(source.get("product_runtime_diff"), []):
            errors.append("manifest product runtime diff must be empty")
        if source.get("status") != "clean":
            errors.append("manifest source.status must be clean")
        if source.get("staging") != "full_git_archive_outside_repository":
            errors.append("manifest source.staging contract drifted")
    engine = payload.get("engine", {})
    if not isinstance(engine, dict) or engine.get("version") != EXPECTED_GODOT:
        errors.append(f"manifest engine.version must be {EXPECTED_GODOT}")
    app = payload.get("application", {})
    expected_app = {
        "name": APP_STEM,
        "bundle_identifier": BUNDLE_ID,
        "version": APP_VERSION,
        "entry_scene": ENTRY_SCENE,
        "custom_user_dir_name": CUSTOM_USER_DIR,
        "splash_enabled": False,
    }
    if not isinstance(app, dict):
        errors.append("manifest application must be an object")
    else:
        for key, value in expected_app.items():
            if app.get(key) != value:
                errors.append(f"manifest application.{key} drifted")


def audit_manifest(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        payload = strict_json_loads(path.read_bytes())
    except (OSError, UnicodeDecodeError, json.JSONDecodeError, ValueError) as exc:
        return [f"cannot read manifest: {exc}"]
    if not isinstance(payload, dict):
        return ["manifest root must be an object"]
    validate_manifest_shape(payload, errors)

    artifact_root = path.resolve().parents[2]
    if path.resolve() != artifact_root / MANIFEST_REL:
        errors.append(f"manifest must be located at {MANIFEST_REL}")
    repository = source_repository_for_audit(artifact_root, errors)
    source = payload.get("source", {}) if isinstance(payload.get("source"), dict) else {}
    revision = str(source.get("revision", ""))
    tree = str(source.get("tree", ""))
    if COMMIT_RE.fullmatch(revision):
        errors.extend(product_source_identity_errors(
            repository,
            revision,
            tree,
        ))
        source_files = source.get("contract_files", [])
        if not isinstance(source_files, list) \
                or len(source_files) != len(SOURCE_CONTRACT):
            errors.append("manifest fixed-source contract inventory drifted")
        for index, row in enumerate(
            source_files if isinstance(source_files, list) else []
        ):
            if not isinstance(row, dict):
                errors.append(f"fixed-source contract row {index} must be an object")
                continue
            if set(row) != {"path", "sha256", "size_bytes"}:
                errors.append(f"fixed-source contract row {index} fields drifted")
            relative = str(row.get("path", ""))
            if index >= len(SOURCE_CONTRACT) or relative != SOURCE_CONTRACT[index]:
                errors.append(f"fixed-source contract row {index} path/order drifted")
            try:
                blob = git_bytes(repository, revision, relative)
                expected_hash = sha256_bytes(blob)
                if row.get("sha256") != expected_hash:
                    errors.append(f"fixed-source hash mismatch: {relative}")
                size = row.get("size_bytes")
                if isinstance(size, bool) or not isinstance(size, int) \
                        or size != len(blob):
                    errors.append(f"fixed-source size mismatch: {relative}")
            except (OSError, subprocess.CalledProcessError):
                errors.append(f"fixed-source file unavailable at revision: {relative}")

    archive_expected_state, archive_state_errors = archive_guard_state(
        repository,
        source_revision=revision if COMMIT_RE.fullmatch(revision) else "",
    )
    errors.extend(f"historic archive guard: {error}" for error in archive_state_errors)
    protected = payload.get("protected", [])
    labels = {
        str(row.get("label", "")) for row in protected if isinstance(row, dict)
    } if isinstance(protected, list) else set()
    if labels != PROTECTED_LABELS or not isinstance(protected, list) or len(protected) != len(PROTECTED_LABELS):
        errors.append(f"protected inventory labels drifted: {sorted(labels)}")
    for row in protected if isinstance(protected, list) else []:
        if not isinstance(row, dict):
            errors.append("protected row must be an object")
            continue
        before = row.get("before", {})
        after = row.get("after", {})
        if not isinstance(before, dict) or not isinstance(after, dict):
            errors.append(f"protected {row.get('label')} states must be objects")
            continue
        if not strict_value_equal(before, after) or row.get("passed") is not True:
            errors.append(f"protected before/after mismatch: {row.get('label')}")
        if not HASH_RE.fullmatch(str(before.get("sha256", ""))):
            errors.append(f"protected {row.get('label')} lacks SHA-256")
        if row.get("label") == "story_demo_build2_archive":
            errors.extend(validate_archive_protected_row(row, archive_expected_state))
    expected_protected_paths = {
        "product_project_godot": "project.godot",
        "product_export_presets": "export_presets.cfg",
        "retail_v2_user_save_files": "~/Library/Application Support/Godot/app_userdata",
        "order103_candidate_user_dir": "~/Library/Application Support/GangnamDream_ORDER103_M01M06_v1",
        "order124_candidate_user_dir": "~/Library/Application Support/GangnamDream_ORDER124_StoryChoice_v1",
        "story_demo_candidate_user_dir": "~/Library/Application Support/GangnamDream_StoryDemo_v1",
        "story_demo_build2_archive": "build/order124/archive/2026.08.24.2",
        "build_order103": "build/order103",
        "build_demo": "build/demo",
        "build_playtest": "build/playtest",
    }
    for row in protected if isinstance(protected, list) else []:
        if not isinstance(row, dict):
            continue
        expected_path = expected_protected_paths.get(str(row.get("label", "")))
        if expected_path is not None and row.get("path") != expected_path:
            errors.append(f"protected path drifted: {row.get('label')}")

    package = payload.get("package", {})
    zip_info = package.get("zip", {}) if isinstance(package, dict) else {}
    app_info = package.get("app", {}) if isinstance(package, dict) else {}
    launcher_info = package.get("launcher", {}) if isinstance(package, dict) else {}
    pck_info = package.get("resource_pack", {}) if isinstance(package, dict) else {}
    if not isinstance(app_info, dict) or app_info.get("path") != APP_REL:
        errors.append("manifest extracted app path drifted")
    local_app = artifact_root / APP_REL
    if not local_app.is_dir():
        errors.append(f"candidate app missing: {APP_REL}")
    else:
        local_tree_hash, local_file_count = app_tree(local_app)
        if app_info.get("tree_sha256") != local_tree_hash:
            errors.append("delivered app tree SHA-256 mismatch")
        if app_info.get("file_count") != local_file_count:
            errors.append("delivered app file count mismatch")
        local_launcher = local_app / "Contents/MacOS" / APP_STEM
        local_pck = local_app / "Contents/Resources" / f"{APP_STEM}.pck"
        for label, item, info in (
            ("launcher", local_launcher, launcher_info),
            ("resource pack", local_pck, pck_info),
        ):
            if not item.is_file():
                errors.append(f"delivered {label} missing")
            elif not isinstance(info, dict) or info.get("sha256") != sha256_path(item):
                errors.append(f"delivered {label} SHA-256 mismatch")
            elif info.get("size_bytes") != item.stat().st_size:
                errors.append(f"delivered {label} size mismatch")
        if local_launcher.is_file() and not os.access(local_launcher, os.X_OK):
            errors.append("delivered launcher is not executable")
        if sys.platform == "darwin":
            result = subprocess.run(
                ["/usr/bin/codesign", "--verify", "--deep", "--strict", str(local_app)],
                capture_output=True, text=True,
            )
            if result.returncode != 0:
                errors.append(f"delivered app codesign verification failed: {result.stderr.strip()}")
    if not isinstance(zip_info, dict) or zip_info.get("path") != ZIP_REL:
        errors.append("manifest ZIP path drifted")
        return errors
    zip_path = artifact_root / ZIP_REL
    if not zip_path.is_file():
        errors.append(f"candidate ZIP missing: {ZIP_REL}")
        return errors
    if zip_info.get("sha256") != sha256_path(zip_path):
        errors.append("candidate ZIP SHA-256 mismatch")
    if zip_info.get("size_bytes") != zip_path.stat().st_size:
        errors.append("candidate ZIP size mismatch")

    with zipfile.ZipFile(zip_path) as archive:
        app_names: set[str] = set()
        for info in archive.infolist():
            name = info.filename
            normalized = PurePosixPath(name)
            if not name or "\\" in name or normalized.is_absolute() or ".." in normalized.parts:
                errors.append(f"unsafe ZIP member: {name!r}")
                continue
            if normalized.parts and normalized.parts[0].endswith(".app"):
                app_names.add(normalized.parts[0])
        expected_app_name = f"{APP_STEM}.app"
        if app_names != {expected_app_name}:
            errors.append(f"ZIP app identity mismatch: {sorted(app_names)}")
        with tempfile.TemporaryDirectory(prefix="story_demo-audit-") as temp:
            destination = Path(temp)
            if sys.platform == "darwin" and Path("/usr/bin/ditto").is_file():
                result = subprocess.run(
                    ["/usr/bin/ditto", "-x", "-k", str(zip_path), str(destination)],
                    capture_output=True, text=True,
                )
                if result.returncode != 0:
                    errors.append(f"ditto extraction failed: {result.stderr.strip()}")
                    return errors
            else:
                archive.extractall(destination)
            app_path = destination / expected_app_name
            plist_path = app_path / "Contents/Info.plist"
            try:
                plist = plistlib.loads(plist_path.read_bytes())
            except (OSError, plistlib.InvalidFileException) as exc:
                errors.append(f"cannot read app Info.plist: {exc}")
                return errors
            for key in ("CFBundleExecutable", "CFBundleName", "CFBundleDisplayName"):
                if plist.get(key) != APP_STEM:
                    errors.append(f"packaged app {key} drifted")
            if plist.get("CFBundleIdentifier") != BUNDLE_ID:
                errors.append("packaged app bundle identifier drifted")
            if str(plist.get("CFBundleVersion", "")) != APP_VERSION:
                errors.append(f"packaged app CFBundleVersion must be {APP_VERSION}")
            if str(plist.get("CFBundleShortVersionString", "")) != "0.1.0":
                errors.append("packaged app CFBundleShortVersionString must be 0.1.0")
            launcher = app_path / "Contents/MacOS" / APP_STEM
            pck = app_path / "Contents/Resources" / f"{APP_STEM}.pck"
            expected_package_identity = (
                (app_info, "name", expected_app_name),
                (launcher_info, "path", f"{expected_app_name}/Contents/MacOS/{APP_STEM}"),
                (pck_info, "path", f"{expected_app_name}/Contents/Resources/{APP_STEM}.pck"),
            )
            for info, key, expected in expected_package_identity:
                if not isinstance(info, dict) or info.get(key) != expected:
                    errors.append(f"packaged {key} identity drifted: expected {expected}")
            tree_hash, file_count = app_tree(app_path)
            if not isinstance(app_info, dict) or app_info.get("tree_sha256") != tree_hash:
                errors.append("packaged app tree SHA-256 mismatch")
            if not isinstance(app_info, dict) or app_info.get("file_count") != file_count:
                errors.append("packaged app file count mismatch")
            for label, item, info in (
                ("launcher", launcher, launcher_info),
                ("resource pack", pck, pck_info),
            ):
                if not item.is_file():
                    errors.append(f"packaged {label} missing")
                elif not isinstance(info, dict) or info.get("sha256") != sha256_path(item):
                    errors.append(f"packaged {label} SHA-256 mismatch")
                elif info.get("size_bytes") != item.stat().st_size:
                    errors.append(f"packaged {label} size mismatch")
            if launcher.is_file() and not os.access(launcher, os.X_OK):
                errors.append("packaged launcher is not executable")
            if sys.platform == "darwin" and app_path.is_dir():
                result = subprocess.run(
                    ["/usr/bin/codesign", "--verify", "--deep", "--strict", str(app_path)],
                    capture_output=True, text=True,
                )
                if result.returncode != 0:
                    errors.append(f"packaged app codesign verification failed: {result.stderr.strip()}")

    validation = payload.get("validation", {})
    if not isinstance(validation, dict):
        errors.append("manifest validation must be an object")
    else:
        targeted = validation.get("targeted_story_choice", {})
        if not isinstance(targeted, dict) or not targeted.get("passed") or targeted.get("marker") != TARGET_MARKER:
            errors.append("targeted StoryDemoFourLanguageCheck evidence drifted")
        errors.extend(density_contract_errors(
            validation.get("story_density_contract"), repository, revision
        ))
        codesign = validation.get("codesign", {})
        if not isinstance(codesign, dict) or not codesign.get("passed") or codesign.get("mode") != "ad-hoc":
            errors.append("ad-hoc codesign evidence missing")
        native = validation.get("native_no_argument", {})
        native_marker = str(native.get("marker", "")) if isinstance(native, dict) else ""
        if not isinstance(native, dict) or native.get("args") != []:
            errors.append("native launch must record an empty argument list")
        for token in (
            NATIVE_MARKER_PREFIX,
            f"profile={PROFILE}",
            f"build={BUILD_ID}",
            f"scene={ENTRY_SCENE}",
            f"custom_user_dir={CUSTOM_USER_DIR}",
            "language=en",
        ):
            if not isinstance(native, dict) or not native.get("passed") or token not in native_marker:
                errors.append(f"native no-argument evidence lacks {token}")
        if " path=" not in native_marker or not native_marker.rsplit(" path=", 1)[-1].endswith(f"/{CUSTOM_USER_DIR}"):
            errors.append("native marker user-data path is not the isolated custom directory")
        smokes = validation.get("package_smokes", [])
        expected_smokes = [
            ("ko", "1280x800"),
            ("en", "960x600"),
            ("ja", "1280x800"),
            ("zh-CN", "960x600"),
            ("zh-TW", "1280x800"),
        ]
        actual_smokes = [
            (str(item.get("language", "")), str(item.get("size", "")))
            for item in smokes if isinstance(item, dict) and item.get("passed")
        ] if isinstance(smokes, list) else []
        if actual_smokes != expected_smokes:
            errors.append(f"package smoke matrix drifted: {actual_smokes}")
        if not isinstance(smokes, list) or len(smokes) != len(expected_smokes):
            errors.append("package smoke inventory must contain all five demo locales")
        for item in smokes if isinstance(smokes, list) else []:
            if not isinstance(item, dict):
                continue
            if item.get("passed") is not True:
                errors.append("package smoke evidence must record passed=true")
            language = str(item.get("language", ""))
            size = str(item.get("size", ""))
            marker_values = marker_tokens(
                str(item.get("marker", "")), SMOKE_MARKER_PREFIX
            )
            expected_wrapper_marker = {
                "language": language,
                "size": size,
                **WRAPPER_REQUIRED_MARKER_TOKENS,
            }
            if marker_values is None:
                errors.append("package smoke marker prefix drifted")
            else:
                for key, value in expected_wrapper_marker.items():
                    if marker_values.get(key) != value:
                        errors.append(
                            f"package smoke marker for {language} lacks {key}={value}"
                        )

        story_return = validation.get("story_return_black_overlay", {})
        expected_return_args = [
            "--qa=story-demo",
            "--story-demo-return-smoke",
            "--story-demo-language=ko",
        ]
        if not isinstance(story_return, dict):
            errors.append("story-return black-overlay smoke evidence must be an object")
        else:
            if (
                story_return.get("passed") is not True
                or story_return.get("language") != "ko"
                or story_return.get("size") != "1280x800"
                or story_return.get("args") != expected_return_args
            ):
                errors.append("story-return black-overlay smoke contract drifted")
            return_values = marker_tokens(
                str(story_return.get("marker", "")), RETURN_MARKER_PREFIX
            )
            expected_return = {
                "build": BUILD_ID,
                "screen": "transition",
                "month": "2",
                "overlay": "clear",
                "input": "clear",
                "choices": "1",
                "settlements": "1",
            }
            if return_values is None:
                errors.append("story-return black-overlay smoke marker prefix drifted")
            else:
                for key, value in expected_return.items():
                    if return_values.get(key) != value:
                        errors.append(
                            f"story-return black-overlay smoke marker lacks {key}={value}"
                        )

        cold_resume = validation.get("cold_restart_resume", {})
        expected_cold_args = [
            "--qa=story-demo",
            "--story-demo-resume-smoke",
            "--story-demo-language=ko",
        ]
        if not isinstance(cold_resume, dict):
            errors.append("cold-restart resume evidence must be an object")
        else:
            expected_cold_shape = {
                "passed": True,
                "source": "fresh_package_smoke",
                "producer_language": "ko",
                "launcher_process": "separate",
                "save_path": "user://story_demo_save.json",
                "args": expected_cold_args,
            }
            for key, value in expected_cold_shape.items():
                if cold_resume.get(key) != value:
                    errors.append(f"cold-restart resume {key} contract drifted")
            cold_values = marker_tokens(
                str(cold_resume.get("marker", "")), RESUME_MARKER_PREFIX
            )
            expected_cold_marker = {
                "build": BUILD_ID,
                "month": "2",
                "weeks": "4",
                "settlements": "1",
                "choices": "1",
                "phase": "transition",
                "screen": "transition",
                "overlay": "clear",
                "input": "clear",
            }
            if cold_values is None:
                errors.append("cold-restart resume marker prefix drifted")
            else:
                for key, value in expected_cold_marker.items():
                    if cold_values.get(key) != value:
                        errors.append(
                            f"cold-restart resume marker lacks {key}={value}"
                        )

        errors.extend(real_story_roundtrip_errors(
            validation.get("real_story_roundtrips")
        ))

        resume = validation.get("existing_save_resume", {})
        if not isinstance(resume, dict):
            errors.append("existing-save resume evidence must be an object")
        elif (
            resume.get("passed") is not True
            or resume.get("source") != "pre_build_candidate_snapshot"
            or resume.get("save_path")
            != "user://story_demo_save.json"
        ):
            errors.append("existing-save resume contract drifted")
        else:
            status = resume.get("status")
            applicable = resume.get("applicable")
            if status == "not_applicable":
                if (
                    applicable is not False
                    or resume.get("reason") != "no_existing_candidate_save"
                    or resume.get("input_save") is not None
                    or resume.get("marker") != ""
                ):
                    errors.append("not-applicable existing-save resume evidence drifted")
            elif status == "passed":
                input_save = resume.get("input_save", {})
                if applicable is not True or not isinstance(input_save, dict):
                    errors.append("applicable existing-save resume evidence is incomplete")
                else:
                    numeric_keys = ("month", "weeks", "settlements", "choices")
                    for key in numeric_keys:
                        value = input_save.get(key)
                        if isinstance(value, bool) or not isinstance(value, int):
                            errors.append(f"existing-save input {key} must be an integer")
                    if not HASH_RE.fullmatch(str(input_save.get("sha256", ""))):
                        errors.append("existing-save input lacks SHA-256")
                    if (
                        not isinstance(input_save.get("size_bytes"), int)
                        or input_save.get("size_bytes", 0) <= 0
                        or input_save.get("schema_version") != 1
                        or input_save.get("profile") != PROFILE
                    ):
                        errors.append("existing-save input identity drifted")
                    phase = str(input_save.get("phase", ""))
                    screen = str(input_save.get("screen", ""))
                    expected_screen = "recap" if phase == "recap" else "transition"
                    if phase not in {"story", "transition", "recap"} or screen != expected_screen:
                        errors.append("existing-save input phase/screen contract drifted")
                    resume_values = marker_tokens(
                        str(resume.get("marker", "")), RESUME_MARKER_PREFIX
                    )
                    if resume_values is None:
                        errors.append("existing-save resume marker prefix drifted")
                    else:
                        expected_resume = {
                            "build": BUILD_ID,
                            "month": str(input_save.get("month")),
                            "weeks": str(input_save.get("weeks")),
                            "settlements": str(input_save.get("settlements")),
                            "choices": str(input_save.get("choices")),
                            "phase": phase,
                            "screen": screen,
                            "overlay": "clear",
                            "input": "clear",
                        }
                        for key, value in expected_resume.items():
                            if resume_values.get(key) != value:
                                errors.append(
                                    f"existing-save resume marker lacks {key}={value}"
                                )
            else:
                errors.append(f"existing-save resume status drifted: {status!r}")

    checksum = artifact_root / CHECKSUM_REL
    if not checksum.is_file():
        errors.append(f"manifest checksum missing: {CHECKSUM_REL}")
    else:
        expected_line = f"{sha256_path(path)}  {MANIFEST_REL}\n"
        if checksum.read_text(encoding="utf-8") != expected_line:
            errors.append("MANIFEST.sha256 does not match MANIFEST.json")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--self-test", action="store_true")
    group.add_argument("--manifest", type=Path)
    group.add_argument("--archive-state", action="store_true")
    parser.add_argument("--source-revision", default="")
    args = parser.parse_args()

    if args.archive_state:
        if not args.source_revision:
            parser.error("--archive-state requires --source-revision")
        state, errors = archive_guard_state(
            ROOT,
            source_revision=args.source_revision,
        )
        if errors or state is None:
            for error in errors or ["archive state is unavailable"]:
                print(f"STORY_DEMO_PACKAGE_AUDIT_FAIL: {error}", file=sys.stderr)
            return 1
        print(json.dumps(state, ensure_ascii=False, sort_keys=True))
        return 0
    if args.source_revision:
        parser.error("--source-revision is only valid with --archive-state")
    if args.self_test:
        errors, checks = source_self_test(ROOT)
        marker = f"STORY_DEMO_PACKAGE_AUDIT_SELF_TEST_OK checks={checks}"
    elif args.manifest is not None:
        errors = audit_manifest(args.manifest.resolve())
        marker = f"STORY_DEMO_PACKAGE_AUDIT_OK manifest={MANIFEST_REL}"
    else:
        state, errors = archive_guard_state(ROOT)
        state_name = str(state.get("state", "invalid")) if state is not None else "invalid"
        marker = f"STORY_DEMO_ARCHIVE_GUARD_OK state={state_name}"
    if errors:
        for error in errors:
            print(f"STORY_DEMO_PACKAGE_AUDIT_FAIL: {error}", file=sys.stderr)
        return 1
    print(marker)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Audit the fixed-source ORDER-124 macOS story-choice candidate."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import plistlib
import re
import subprocess
import sys
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[1]
PROFILE = "order124_m1m6_story_choice"
GAME_VERSION = "0.1.0-dev"
BUILD_ID = "2026.08.24.2"
BUILD_FLAVOR = "order124_story_choice_playtest"
PRESET = "ORDER-124 M01-M06 Story Choice Playtest"
APP_STEM = "GangnamDream-ORDER124-M01M06-StoryChoicePlaytest"
BUNDLE_ID = "dev.junheelee.gangnamdream.order124storychoice"
CUSTOM_USER_DIR = "GangnamDream_ORDER124_StoryChoice_v1"
ENTRY_SCENE = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
CHECK_SCENE = "res://tools/StoryChoiceM1M6Check.tscn"
TARGET_MARKER = (
    "STORY_CHOICE_M1M6_CHECK_OK months=6 weeks=24 settlements=6 "
    "commitments=0 routes=2 save=1 m6=1"
)
NATIVE_MARKER_PREFIX = "ORDER124_NATIVE_ENTRY_OK"
SMOKE_MARKER_PREFIX = "ORDER124_WRAPPER_SMOKE_OK"
EXPECTED_GODOT = "4.6.2.stable.official.71f334935"
APP_REL = f"build/order124/macos/{APP_STEM}.app"
ZIP_REL = f"build/order124/macos/{APP_STEM}.zip"
MANIFEST_REL = "build/order124/MANIFEST.json"
CHECKSUM_REL = "build/order124/MANIFEST.sha256"

HASH_RE = re.compile(r"^[0-9a-f]{64}$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
UTC_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
SOURCE_CONTRACT = (
    "project.godot",
    "export_presets.cfg",
    "playtests/order124/StoryChoiceM1M6Playtest.gd",
    "playtests/order124/StoryChoiceM1M6Playtest.gd.uid",
    "playtests/order124/StoryChoiceM1M6Playtest.tscn",
    "tools/StoryChoiceM1M6Check.gd",
    "tools/StoryChoiceM1M6Check.gd.uid",
    "tools/StoryChoiceM1M6Check.tscn",
    "tools/audit_scope.json",
    "tools/build_order124_macos.sh",
    "tools/order124_package_audit.py",
)
PROTECTED_LABELS = {
    "product_project_godot",
    "product_export_presets",
    "retail_v2_user_save_files",
    "order103_candidate_user_dir",
    "order124_candidate_user_dir",
    "build_order103",
    "build_demo",
    "build_playtest",
}


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


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


def source_self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    build_path = root / "tools/build_order124_macos.sh"
    audit_path = root / "tools/order124_package_audit.py"
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
        "ORDER124_NATIVE_PROBE_PATH",
        "--order124-smoke",
        TARGET_MARKER,
        APP_REL,
        "restore_candidate_user_data",
        "order124_candidate_user_dir",
        "tools/audit_scope.json",
        ".json.bak",
        "capture_protected",
        "protected before/after mismatch",
        "order124_package_audit.py",
    )
    for token in required_tokens:
        if token not in build_text:
            errors.append(f"build script missing required contract token: {token}")

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
    for pair in (SOURCE_CONTRACT[2:5], SOURCE_CONTRACT[5:8]):
        paths = [root / path for path in pair]
        if any(path.exists() for path in paths):
            for relative in pair:
                if not (root / relative).is_file():
                    errors.append(f"incomplete ORDER-124 source pair: {relative}")
    return errors, len(required_tokens)


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
        for key in ("revision", "tree"):
            if not COMMIT_RE.fullmatch(str(source.get(key, ""))):
                errors.append(f"manifest source.{key} is not a full Git hash")
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
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read manifest: {exc}"]
    if not isinstance(payload, dict):
        return ["manifest root must be an object"]
    validate_manifest_shape(payload, errors)

    artifact_root = path.resolve().parents[2]
    if path.resolve() != artifact_root / MANIFEST_REL:
        errors.append(f"manifest must be located at {MANIFEST_REL}")
    repository = artifact_root
    source = payload.get("source", {}) if isinstance(payload.get("source"), dict) else {}
    revision = str(source.get("revision", ""))
    tree = str(source.get("tree", ""))
    if COMMIT_RE.fullmatch(revision):
        try:
            actual_tree = subprocess.check_output(
                ["git", "-C", str(repository), "rev-parse", f"{revision}^{{tree}}"],
                text=True,
            ).strip()
            if actual_tree != tree:
                errors.append("manifest source tree does not match revision")
        except (OSError, subprocess.CalledProcessError) as exc:
            errors.append(f"manifest revision is unavailable in repository: {exc}")
        source_files = source.get("contract_files", [])
        actual_paths = {
            str(row.get("path", "")) for row in source_files if isinstance(row, dict)
        } if isinstance(source_files, list) else set()
        if actual_paths != set(SOURCE_CONTRACT) or not isinstance(source_files, list) or len(source_files) != len(SOURCE_CONTRACT):
            errors.append("manifest fixed-source contract inventory drifted")
        for row in source_files if isinstance(source_files, list) else []:
            if not isinstance(row, dict):
                continue
            relative = str(row.get("path", ""))
            try:
                expected_hash = sha256_bytes(git_bytes(repository, revision, relative))
                if row.get("sha256") != expected_hash:
                    errors.append(f"fixed-source hash mismatch: {relative}")
            except (OSError, subprocess.CalledProcessError):
                errors.append(f"fixed-source file unavailable at revision: {relative}")

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
        if before != after or not row.get("passed"):
            errors.append(f"protected before/after mismatch: {row.get('label')}")
        if not HASH_RE.fullmatch(str(before.get("sha256", ""))):
            errors.append(f"protected {row.get('label')} lacks SHA-256")
    expected_protected_paths = {
        "product_project_godot": "project.godot",
        "product_export_presets": "export_presets.cfg",
        "retail_v2_user_save_files": "~/Library/Application Support/Godot/app_userdata",
        "order103_candidate_user_dir": "~/Library/Application Support/GangnamDream_ORDER103_M01M06_v1",
        "order124_candidate_user_dir": "~/Library/Application Support/GangnamDream_ORDER124_StoryChoice_v1",
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
        with tempfile.TemporaryDirectory(prefix="order124-audit-") as temp:
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
            errors.append("targeted StoryChoiceM1M6Check evidence drifted")
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
            "language=ko",
        ):
            if not isinstance(native, dict) or not native.get("passed") or token not in native_marker:
                errors.append(f"native no-argument evidence lacks {token}")
        if " path=" not in native_marker or not native_marker.rsplit(" path=", 1)[-1].endswith(f"/{CUSTOM_USER_DIR}"):
            errors.append("native marker user-data path is not the isolated custom directory")
        smokes = validation.get("package_smokes", [])
        expected_smokes = [("ko", "1280x800"), ("en", "960x600")]
        actual_smokes = [
            (str(item.get("language", "")), str(item.get("size", "")))
            for item in smokes if isinstance(item, dict) and item.get("passed")
        ] if isinstance(smokes, list) else []
        if actual_smokes != expected_smokes:
            errors.append(f"package smoke matrix drifted: {actual_smokes}")
        if not isinstance(smokes, list) or len(smokes) != len(expected_smokes):
            errors.append("package smoke inventory must contain exactly KO and EN")
        for item in smokes if isinstance(smokes, list) else []:
            if isinstance(item, dict) and SMOKE_MARKER_PREFIX not in str(item.get("marker", "")):
                errors.append("package smoke marker prefix drifted")

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
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--self-test", action="store_true")
    group.add_argument("--manifest", type=Path)
    args = parser.parse_args()

    if args.self_test:
        errors, checks = source_self_test(ROOT)
        marker = f"ORDER124_PACKAGE_AUDIT_SELF_TEST_OK checks={checks}"
    else:
        errors = audit_manifest(args.manifest.resolve())
        marker = f"ORDER124_PACKAGE_AUDIT_OK manifest={MANIFEST_REL}"
    if errors:
        for error in errors:
            print(f"ORDER124_PACKAGE_AUDIT_FAIL: {error}", file=sys.stderr)
        return 1
    print(marker)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

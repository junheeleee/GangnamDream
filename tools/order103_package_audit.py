#!/usr/bin/env python3
"""Audit the isolated ORDER-103 macOS candidate and its source templates."""

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
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[1]
PROFILE = "order103_m1m6_playtest"
GAME_VERSION = "0.1.0-dev"
BUILD_ID = "2026.08.24.1"
BUILD_FLAVOR = "story_map_m1m6_playtest"
SAVE_NAMESPACE = "story_map_m1m6_playtest_v1"
SAVE_SCHEMA = 1
PRESET = "ORDER-103 M01-M06 Playtest"
APP_STEM = "GangnamDream-ORDER103-M01M06-ChoicePlaytest"
BUNDLE_ID = "dev.junheelee.gangnamdream.storymapm1m6"
CUSTOM_USER_DIR = "GangnamDream_ORDER103_M01M06_v1"
ENTRY_SCENE = "res://order103/Entry.tscn"
PLAYTEST_SCENE = "res://tools/StoryMapM1M6Playtest.tscn"
AUTOSAVE_PATH = "user://story_map_m1m6_playtest_autosave.json"
EXPECTED_GODOT = "4.6.2.stable.official.71f334935"
ZIP_REL = f"build/order103/macos/{APP_STEM}.zip"
MANIFEST_REL = "build/order103/MANIFEST.json"
CHECKSUM_REL = "build/order103/MANIFEST.sha256"

EXPORT_ROOT = Path("tools/order103_export")
PROJECT_TEMPLATE = EXPORT_ROOT / "project.godot"
PRESET_TEMPLATE = EXPORT_ROOT / "export_presets.cfg"
RESOURCES_FILE = EXPORT_ROOT / "resources.txt"
WRAPPER_COPY = {
    PROJECT_TEMPLATE.as_posix(): "project.godot",
    PRESET_TEMPLATE.as_posix(): "export_presets.cfg",
    (EXPORT_ROOT / "Entry.tscn").as_posix(): "order103/Entry.tscn",
    (EXPORT_ROOT / "Entry.gd").as_posix(): "order103/Entry.gd",
    (EXPORT_ROOT / "AudioManagerStub.gd").as_posix():
        "order103/AudioManagerStub.gd",
}
REQUIRED_RESOURCES = {
    "tools/StoryMapM1M6Playtest.gd",
    "tools/StoryMapM1M6Playtest.tscn",
    "systems/StoryMapMonthlyRuntime.gd",
    "content/meta/story_map.json",
    "content/meta/story_map_m1m6_en.json",
    "autoloads/UIStyle.gd",
    "autoloads/FontKit.gd",
}
FORBIDDEN_RESOURCES = {
    "project.godot",
    "export_presets.cfg",
    "scenes/SplashScreen.tscn",
    "scenes/StartMenu.tscn",
    "scenes/StartMenu.gd",
    "scenes/MainGame.tscn",
    "scenes/MainGame.gd",
    "scenes/SeoulCycleBoard.tscn",
    "scenes/SeoulCycleBoard.gd",
    "autoloads/GameState.gd",
    "autoloads/SaveManager.gd",
    "systems/BuildFlavor.gd",
    "systems/DemoCoreLoopV2.gd",
}
HASH_RE = re.compile(r"^[0-9a-f]{64}$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
UTC_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
REF_RE = re.compile(r"res://([^\"'\s\)\]\},]+)")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_relative(raw: str) -> str | None:
    if not raw or "\\" in raw or raw != raw.strip():
        return None
    path = PurePosixPath(raw)
    if path.is_absolute() or ".." in path.parts or path.as_posix() != raw:
        return None
    return raw


def parse_resources_text(text: str, errors: list[str]) -> list[str]:
    result: list[str] = []
    seen: set[str] = set()
    for number, raw in enumerate(text.splitlines(), 1):
        if not raw or raw.startswith("#"):
            continue
        value = safe_relative(raw)
        if value is None:
            errors.append(f"resources.txt:{number}: unsafe path {raw!r}")
            continue
        if value in seen:
            errors.append(f"resources.txt:{number}: duplicate path {value}")
            continue
        seen.add(value)
        result.append(value)
    return result


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


def source_template_errors(root: Path) -> tuple[list[str], int, int]:
    errors: list[str] = []
    required = [*WRAPPER_COPY, RESOURCES_FILE.as_posix(),
                "tools/build_order103_macos.sh"]
    for relative in required:
        if not (root / relative).is_file():
            errors.append(f"missing template input: {relative}")
    if errors:
        return errors, 0, 0

    resources_text = (root / RESOURCES_FILE).read_text(encoding="utf-8")
    resources = parse_resources_text(resources_text, errors)
    missing_required = sorted(REQUIRED_RESOURCES - set(resources))
    if missing_required:
        errors.append(f"resources.txt missing required paths: {missing_required}")
    forbidden = sorted(set(resources) & FORBIDDEN_RESOURCES)
    if forbidden:
        errors.append(f"resources.txt includes product paths: {forbidden}")
    for relative in resources:
        path = root / relative
        if not path.is_file() or path.is_symlink():
            errors.append(f"resource is missing, not a file, or a symlink: {relative}")

    project = (root / PROJECT_TEMPLATE).read_text(encoding="utf-8")
    app = section_values(project, "application")
    autoload = section_values(project, "autoload")
    expected_app = {
        "config/name": APP_STEM,
        "run/main_scene": ENTRY_SCENE,
        "config/use_custom_user_dir": "true",
        "config/custom_user_dir_name": CUSTOM_USER_DIR,
    }
    for key, expected in expected_app.items():
        if app.get(key) != expected:
            errors.append(f"project.godot {key}={app.get(key)!r}, expected {expected!r}")
    if autoload.get("AudioManager") != "*res://order103/AudioManagerStub.gd":
        errors.append("project.godot must autoload the ORDER-103 AudioManager stub")
    if autoload.get("UIStyle") != "*res://autoloads/UIStyle.gd":
        errors.append("project.godot must autoload UIStyle from the isolated payload")
    rendering = section_values(project, "rendering")
    if rendering.get("textures/vram_compression/import_etc2_astc") != "true":
        errors.append("project.godot must enable ETC2/ASTC for the universal macOS export")

    entry_text = (root / EXPORT_ROOT / "Entry.gd").read_text(encoding="utf-8")
    for token in (
        'const PROFILE := "order103_m1m6_playtest"',
        'const BUILD_ID := "2026.08.24.1"',
        'const BUILD_FLAVOR := "story_map_m1m6_playtest"',
        'const SAVE_NAMESPACE := "story_map_m1m6_playtest_v1"',
        "const SAVE_SCHEMA := 1",
        'const MAIN_SCENE := "res://tools/StoryMapM1M6Playtest.tscn"',
        "ORDER103_NATIVE_ENTRY_OK",
        "ORDER103_NATIVE_PROBE_PATH",
        "ORDER103_WRAPPER_SMOKE_OK",
        "remaining_jsons := _user_json_files()",
        'ends_with(".json")',
    ):
        if token not in entry_text:
            errors.append(f"Entry.gd missing identity/smoke contract token: {token}")

    preset_text = (root / PRESET_TEMPLATE).read_text(encoding="utf-8")
    if len(re.findall(r"(?m)^\[preset\.\d+\]$", preset_text)) != 1:
        errors.append("export preset template must contain exactly one preset")
    preset = section_values(preset_text, "preset.0")
    options = section_values(preset_text, "preset.0.options")
    for key, expected in {
        "name": PRESET,
        "platform": "macOS",
        "export_filter": "all_resources",
        "exclude_filter": "",
    }.items():
        if preset.get(key) != expected:
            errors.append(f"export preset {key}={preset.get(key)!r}, expected {expected!r}")
    if options.get("application/bundle_identifier") != BUNDLE_ID:
        errors.append("export preset bundle identifier drifted")
    # CFBundleVersion is a separate macOS numeric triplet; the full candidate
    # BUILD_ID remains fixed in Entry.gd and MANIFEST.json.
    if options.get("application/version") != "2026.8.24":
        errors.append("export preset CFBundleVersion drifted")
    if options.get("binary_format/architecture") != "universal":
        errors.append("ORDER-103 candidate must be a universal macOS app")

    copied = set(resources) | set(WRAPPER_COPY.values())
    checked_refs = 0
    text_inputs = list(resources) + list(WRAPPER_COPY)
    for relative in text_inputs:
        path = root / relative
        if path.suffix not in {".gd", ".tscn", ".tres", ".godot", ".gdshader"}:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for raw_ref in REF_RE.findall(text):
            ref = raw_ref.rstrip(".,:;")
            checked_refs += 1
            if ref not in copied:
                errors.append(f"{relative}: res:// dependency not copied: {ref}")

    result = subprocess.run(
        ["bash", "-n", str(root / "tools/build_order103_macos.sh")],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        errors.append(f"build script syntax error: {result.stderr.strip()}")
    build_text = (root / "tools/build_order103_macos.sh").read_text(encoding="utf-8")
    for token in (
        "archive --format=tar", "--export-release", PRESET, ZIP_REL,
        "order103_package_audit.py", "ORDER103_WRAPPER_SMOKE_OK",
        "ORDER103_NATIVE_PROBE_PATH",
    ):
        if token not in build_text:
            errors.append(f"build script missing required contract token: {token}")
    return errors, len(resources), checked_refs


def git_bytes(repository: Path, revision: str, relative: str) -> bytes:
    return subprocess.check_output(
        ["git", "-C", str(repository), "show", f"{revision}:{relative}"]
    )


def input_payload_digest(wrapper: list[dict], resources: list[dict]) -> str:
    lines: list[bytes] = []
    for item in wrapper:
        lines.append(
            f"wrapper\0{item['source_path']}\0{item['destination_path']}\0{item['sha256']}\n".encode()
        )
    for item in resources:
        lines.append(f"resource\0{item['path']}\0{item['sha256']}\n".encode())
    return sha256_bytes(b"".join(sorted(lines)))


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


def validate_manifest_shape(payload: dict, errors: list[str]) -> None:
    expected = {
        "schema_version": 1,
        "profile": PROFILE,
        "game_version": GAME_VERSION,
        "build_id": BUILD_ID,
        "build_flavor": BUILD_FLAVOR,
        "save_namespace": SAVE_NAMESPACE,
        "save_schema_version": SAVE_SCHEMA,
    }
    for key, value in expected.items():
        if payload.get(key) != value:
            errors.append(f"manifest {key}={payload.get(key)!r}, expected {value!r}")
    if not UTC_RE.fullmatch(str(payload.get("generated_utc", ""))):
        errors.append("manifest generated_utc is not canonical UTC")
    source = payload.get("source", {})
    if not isinstance(source, dict):
        errors.append("manifest source must be an object")
        return
    for key in ("revision", "tree"):
        if not COMMIT_RE.fullmatch(str(source.get(key, ""))):
            errors.append(f"manifest source.{key} is not a full Git hash")
    if source.get("status") != "clean":
        errors.append("manifest source.status must be clean")
    engine = payload.get("engine", {})
    if not isinstance(engine, dict) or engine.get("version") != EXPECTED_GODOT:
        errors.append(f"manifest engine.version must be {EXPECTED_GODOT}")
    app = payload.get("application", {})
    expected_app = {
        "bundle_identifier": BUNDLE_ID,
        "entry_scene": ENTRY_SCENE,
        "playtest_scene": PLAYTEST_SCENE,
        "custom_user_dir_name": CUSTOM_USER_DIR,
        "autosave_path": AUTOSAVE_PATH,
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

    inputs = payload.get("inputs", {})
    wrapper = inputs.get("wrapper", []) if isinstance(inputs, dict) else []
    resources = inputs.get("resources", []) if isinstance(inputs, dict) else []
    if not isinstance(wrapper, list) or not isinstance(resources, list):
        errors.append("manifest input inventories must be arrays")
        wrapper, resources = [], []
    if COMMIT_RE.fullmatch(revision):
        expected_wrapper = set(WRAPPER_COPY.items())
        actual_wrapper: set[tuple[str, str]] = set()
        for item in wrapper:
            if not isinstance(item, dict):
                errors.append("manifest wrapper row must be an object")
                continue
            pair = (str(item.get("source_path", "")), str(item.get("destination_path", "")))
            actual_wrapper.add(pair)
            try:
                digest = sha256_bytes(git_bytes(repository, revision, pair[0]))
                if item.get("sha256") != digest:
                    errors.append(f"wrapper input hash mismatch: {pair[0]}")
            except (OSError, subprocess.CalledProcessError):
                errors.append(f"wrapper input unavailable at revision: {pair[0]}")
        if actual_wrapper != expected_wrapper:
            errors.append("manifest wrapper copy inventory drifted")
        try:
            resource_text = git_bytes(
                repository, revision, RESOURCES_FILE.as_posix()
            ).decode("utf-8")
            listed = parse_resources_text(resource_text, errors)
            actual_paths = [str(item.get("path", "")) for item in resources if isinstance(item, dict)]
            if actual_paths != listed:
                errors.append("manifest resource inventory differs from fixed resources.txt")
            for item in resources:
                if not isinstance(item, dict):
                    continue
                relative = str(item.get("path", ""))
                digest = sha256_bytes(git_bytes(repository, revision, relative))
                if item.get("sha256") != digest:
                    errors.append(f"resource input hash mismatch: {relative}")
        except (OSError, UnicodeDecodeError, subprocess.CalledProcessError) as exc:
            errors.append(f"cannot validate fixed resource inventory: {exc}")
    if isinstance(inputs, dict) and wrapper and resources:
        if inputs.get("payload_sha256") != input_payload_digest(wrapper, resources):
            errors.append("manifest input payload SHA-256 mismatch")

    package = payload.get("package", {})
    zip_info = package.get("zip", {}) if isinstance(package, dict) else {}
    if not isinstance(zip_info, dict) or zip_info.get("path") != ZIP_REL:
        errors.append("manifest ZIP path drifted")
        return errors
    zip_path = artifact_root / ZIP_REL
    if not zip_path.is_file():
        errors.append(f"candidate ZIP missing: {ZIP_REL}")
        return errors
    actual_zip_hash = sha256_path(zip_path)
    if zip_info.get("sha256") != actual_zip_hash:
        errors.append("candidate ZIP SHA-256 mismatch")
    if zip_info.get("size_bytes") != zip_path.stat().st_size:
        errors.append("candidate ZIP size mismatch")

    with zipfile.ZipFile(zip_path) as archive:
        app_names: set[str] = set()
        for info in archive.infolist():
            name = info.filename
            normalized = PurePosixPath(name)
            if (not name or "\\" in name or normalized.is_absolute()
                    or ".." in normalized.parts):
                errors.append(f"unsafe ZIP member: {name!r}")
                continue
            if normalized.parts and normalized.parts[0].endswith(".app"):
                app_names.add(normalized.parts[0])
        expected_app_name = f"{APP_STEM}.app"
        if app_names != {expected_app_name}:
            errors.append(f"ZIP app identity mismatch: {sorted(app_names)}")
        with tempfile.TemporaryDirectory(prefix="order103-audit-") as temp:
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
            if plist.get("CFBundleIdentifier") != BUNDLE_ID:
                errors.append("packaged app bundle identifier drifted")
            executable = str(plist.get("CFBundleExecutable", ""))
            launcher = app_path / "Contents/MacOS" / executable
            if executable != APP_STEM or not launcher.is_file() or not os.access(launcher, os.X_OK):
                errors.append("packaged native launcher identity or executable mode drifted")
            app_info = package.get("app", {}) if isinstance(package, dict) else {}
            launcher_info = package.get("launcher", {}) if isinstance(package, dict) else {}
            tree_hash, file_count = app_tree(app_path)
            if not isinstance(app_info, dict) or app_info.get("tree_sha256") != tree_hash:
                errors.append("packaged app tree SHA-256 mismatch")
            if not isinstance(app_info, dict) or app_info.get("file_count") != file_count:
                errors.append("packaged app file count mismatch")
            if launcher.is_file() and (
                not isinstance(launcher_info, dict)
                or launcher_info.get("sha256") != sha256_path(launcher)
            ):
                errors.append("packaged launcher SHA-256 mismatch")
            if sys.platform == "darwin" and app_path.is_dir():
                result = subprocess.run(
                    ["/usr/bin/codesign", "--verify", "--deep", "--strict", str(app_path)],
                    capture_output=True, text=True,
                )
                if result.returncode != 0:
                    errors.append(f"packaged app codesign verification failed: {result.stderr.strip()}")

    validation = payload.get("validation", {})
    required_passes = (
        "source_import", "targeted_story_map", "package_import",
        "codesign", "native_no_argument",
    )
    if not isinstance(validation, dict):
        errors.append("manifest validation must be an object")
    else:
        for key in required_passes:
            if not isinstance(validation.get(key), dict) or not validation[key].get("passed"):
                errors.append(f"manifest validation.{key} is not passed")
        smokes = validation.get("package_smokes", [])
        expected_smokes = [("ko", "1280x800"), ("en", "960x600")]
        actual_smokes = [
            (str(item.get("language", "")), str(item.get("size", "")))
            for item in smokes if isinstance(item, dict) and item.get("passed")
        ] if isinstance(smokes, list) else []
        if actual_smokes != expected_smokes:
            errors.append(f"package smoke matrix drifted: {actual_smokes}")

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
        errors, resources, references = source_template_errors(ROOT)
        marker = (
            f"ORDER103_PACKAGE_AUDIT_SELF_TEST_OK resources={resources} "
            f"references={references}"
        )
    else:
        errors = audit_manifest(args.manifest.resolve())
        marker = f"ORDER103_PACKAGE_AUDIT_OK manifest={MANIFEST_REL}"
    if errors:
        for error in errors:
            print(f"ORDER103_PACKAGE_AUDIT_FAIL: {error}", file=sys.stderr)
        return 1
    print(marker)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

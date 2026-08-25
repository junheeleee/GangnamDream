#!/usr/bin/env python3
"""Audit the fixed-source public multilingual story-demo package."""

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
PROFILE = "story_demo_rc"
GAME_VERSION = "0.1.0-dev"
BUILD_ID = "2026.08.25.1"
BUILD_FLAVOR = "story_demo_rc"
PRESET = "Story Demo macOS"
APP_STEM = "GangnamDream-StoryDemo"
BUNDLE_ID = "dev.junheelee.gangnamdream.storydemo"
APP_VERSION = "2026.8.25"
CUSTOM_USER_DIR = "GangnamDream_StoryDemo_v1"
ENTRY_SCENE = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
CHECK_SCENE = "res://tools/StoryDemoFourLanguageCheck.tscn"
TARGET_MARKER = (
    "STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=4 months=30 "
    "weeks=120 settlements=30 ap_surface=0 save=5 story=5 build=2026.08.25.1"
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
WRAPPER_REQUIRED_MARKER_TOKENS = {
    "start": "1",
    "save": "1",
    "continue": "1",
    "month": "m02",
    "weeks": "4",
    "settlement": "1",
}
REAL_FLOW_RELEASE_MARKER_TOKENS = {
    "months": "6",
    "weeks": "24",
    "settlements": "6",
    "receipts": "9",
    "cold_restart": "1",
    "exact_resume": "1",
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


def marker_tokens(marker: str, prefix: str) -> dict[str, str] | None:
    parts = marker.split()
    if not parts or parts[0] != prefix:
        return None
    values: dict[str, str] = {}
    for part in parts[1:]:
        if "=" in part:
            key, value = part.split("=", 1)
            if key in values:
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
        "--story-demo-real-flow-choice=0",
        "--story-demo-real-flow-choice=1",
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
        "build/order124/archive/2026.08.24.2",
        "pre_build_candidate_snapshot",
        "fresh_package_smoke",
        "cold_restart_resume",
        "real_story_roundtrips",
        "GangnamDream_StoryDemo_RuntimeQA_package_real_clean",
        "GangnamDream_StoryDemo_RuntimeQA_package_real_fallout",
        "launcher_process",
        '"version": "2026.8.25"',
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
        '"cold_restart=1"',
        '"exact_resume=1"',
        AUDIT_SOURCE_ROOT_ENV,
    )
    for token in required_tokens:
        if token not in build_text:
            errors.append(f"build script missing required contract token: {token}")
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
        "-- --story-demo-real-flow-smoke --story-demo-real-flow-choice=0 --story-demo-language=ko",
        "-- --story-demo-real-flow-smoke --story-demo-real-flow-choice=1 --story-demo-language=zh-CN",
    )
    for command in real_flow_commands:
        if command not in normalized_build:
            errors.append(f"build script lacks real StoryMode package command: {command}")

    lock_position = build_text.find(
        "acquire_story_demo_build_lock || lock_acquire_status=$?"
    )
    early_lock_position = build_text.find(
        'EARLY_STORY_DEMO_BUILD_LOCK_DIR="$HOME/Library/Application Support/'
    )
    source_status_position = build_text.find('SOURCE_STATUS="$(git -C "$PROJECT_DIR" status')
    snapshot_position = build_text.find(
        'capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_ORIGINAL_STATE"'
    )
    if (
        early_lock_position < 0
        or source_status_position < 0
        or early_lock_position >= source_status_position
    ):
        errors.append("concurrent-build lock preflight must precede source preflight")
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

    controller_tokens = (
        "--story-demo-return-smoke",
        "--story-demo-resume-smoke",
        "STORY_DEMO_RETURN_SMOKE",
        "STORY_DEMO_RESUME_SMOKE",
        "--story-demo-real-flow-smoke",
        "--story-demo-real-flow-choice=",
        "STORY_DEMO_REAL_FLOW_SMOKE",
        "months=6 weeks=24 settlements=6 receipts=9",
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
    return (
        errors,
        len(required_tokens)
        + len(forbidden)
        + len(controller_tokens)
        + len(real_flow_commands)
        + wrapper_contract_checks
        + 7,
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
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
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
        if row.get("label") == "story_demo_build2_archive" and (
            not before.get("exists") or int(before.get("file_count", 0)) < 3
        ):
            errors.append("protected BUILD 2026.08.24.2 archive is incomplete")
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

        real_roundtrips = validation.get("real_story_roundtrips", [])
        expected_real_roundtrips = [
            {
                "language": "ko",
                "choice": 0,
                "m02": "clean",
                "months": 6,
                "weeks": 24,
                "settlements": 6,
                "receipts": 9,
                "cold_restart": True,
                "exact_resume": True,
                "runtime_qa_namespace": "GangnamDream_StoryDemo_RuntimeQA_package_real_clean",
                "args": [
                    "--story-demo-real-flow-smoke",
                    "--story-demo-real-flow-choice=0",
                    "--story-demo-language=ko",
                ],
            },
            {
                "language": "zh-CN",
                "choice": 1,
                "m02": "fallout",
                "months": 6,
                "weeks": 24,
                "settlements": 6,
                "receipts": 9,
                "cold_restart": True,
                "exact_resume": True,
                "runtime_qa_namespace": "GangnamDream_StoryDemo_RuntimeQA_package_real_fallout",
                "args": [
                    "--story-demo-real-flow-smoke",
                    "--story-demo-real-flow-choice=1",
                    "--story-demo-language=zh-CN",
                ],
            },
        ]
        if not isinstance(real_roundtrips, list) or len(real_roundtrips) != 2:
            errors.append("real StoryMode roundtrip inventory must contain clean and fallout")
        else:
            for index, expected_roundtrip in enumerate(expected_real_roundtrips):
                actual_roundtrip = real_roundtrips[index]
                if not isinstance(actual_roundtrip, dict):
                    errors.append(f"real StoryMode roundtrip {index} must be an object")
                    continue
                if actual_roundtrip.get("passed") is not True:
                    errors.append(f"real StoryMode roundtrip {index} did not pass")
                for key, value in expected_roundtrip.items():
                    if actual_roundtrip.get(key) != value:
                        errors.append(f"real StoryMode roundtrip {index} {key} contract drifted")
                real_values = marker_tokens(
                    str(actual_roundtrip.get("marker", "")),
                    REAL_FLOW_MARKER_PREFIX,
                )
                expected_real_marker = {
                    "build": BUILD_ID,
                    "language": expected_roundtrip["language"],
                    "choice": str(expected_roundtrip["choice"]),
                    "m02": expected_roundtrip["m02"],
                    **REAL_FLOW_RELEASE_MARKER_TOKENS,
                    "story": "real",
                    "manual_save": "1",
                    "overlay": "clear",
                    "input": "clear",
                    "ap_ledger": "0",
                }
                if real_values is None:
                    errors.append(f"real StoryMode roundtrip {index} marker prefix drifted")
                else:
                    for key, value in expected_real_marker.items():
                        if real_values.get(key) != value:
                            errors.append(
                                f"real StoryMode roundtrip {index} marker lacks {key}={value}"
                            )

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
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--self-test", action="store_true")
    group.add_argument("--manifest", type=Path)
    args = parser.parse_args()

    if args.self_test:
        errors, checks = source_self_test(ROOT)
        marker = f"STORY_DEMO_PACKAGE_AUDIT_SELF_TEST_OK checks={checks}"
    else:
        errors = audit_manifest(args.manifest.resolve())
        marker = f"STORY_DEMO_PACKAGE_AUDIT_OK manifest={MANIFEST_REL}"
    if errors:
        for error in errors:
            print(f"STORY_DEMO_PACKAGE_AUDIT_FAIL: {error}", file=sys.stderr)
        return 1
    print(marker)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

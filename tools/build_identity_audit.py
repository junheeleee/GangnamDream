#!/usr/bin/env python3
"""Verify screen/save/build-manifest identity without making it a save gate."""

from __future__ import annotations

import argparse
import datetime
import hashlib
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[1]
BUILD_INFO = ROOT / "systems" / "BuildInfo.gd"
BUILD_FLAVOR = ROOT / "systems" / "BuildFlavor.gd"
SAVE_MANAGER = ROOT / "autoloads" / "SaveManager.gd"
BUILD_SCRIPT = ROOT / "tools" / "build.sh"
EXPORT_PRESETS = ROOT / "export_presets.cfg"
IDENTITY_FIELDS = (
    "game_version",
    "build_id",
    "build_flavor",
    "save_namespace",
)
PROFILE_ARTIFACT_COUNTS = {"full": 1, "demo": 3, "playtest": 3}
FULL_RC_ARTIFACT_PATHS = (
    "build/windows/GangnamDream.exe",
    "build/macos/GangnamDream.zip",
    "build/linux/GangnamDream.x86_64",
)
FULL_RC_STAGE_SEQUENCE = (
    "require_clean_playtest_source",
    "require_current_package_build_id",
    "require_fresh_import_cache",
    "clear_full_rc_receipts",
    "prepare_playtest_imports",
    "require_clean_playtest_source",
    "build_windows",
    "build_macos",
    "build_linux",
    "require_clean_playtest_source",
    "write_full_rc_manifest",
    "require_clean_playtest_source",
)
PRESET_FEATURES = {
    "Windows": "",
    "macOS": "",
    "Web": "",
    "Linux / Steam Deck": "",
    "Windows Demo": "gangnam_demo",
    "macOS Demo": "gangnam_demo",
    "Linux / Steam Deck Demo": "gangnam_demo",
    "Windows V2 Playtest": "gangnam_demo,core_loop_v2_playtest",
    "macOS V2 Playtest": "gangnam_demo,core_loop_v2_playtest",
    "Linux / Steam Deck V2 Playtest": "gangnam_demo,core_loop_v2_playtest",
}
CHECKSUM_RE = re.compile(r"^([0-9a-f]{64})\s+(.+?)\s*$")
BUILD_ID_RE = re.compile(
    r"^(?P<date>\d{4}\.\d{2}\.\d{2})\.(?P<sequence>[1-9]\d*)$"
)
EXPECTED_GODOT_VERSION = "4.6.2.stable.official.71f334935"


def string_const(path: Path, name: str) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(
        rf'^const\s+{re.escape(name)}\s*:?=\s*"([^"]+)"\s*$',
        text,
        flags=re.MULTILINE,
    )
    if not match:
        raise ValueError(f"{path.relative_to(ROOT)}: missing string const {name}")
    return match.group(1)


def int_const(path: Path, name: str) -> int:
    text = path.read_text(encoding="utf-8")
    match = re.search(
        rf"^const\s+{re.escape(name)}\s*=?\s*(\d+)\s*$",
        text,
        flags=re.MULTILINE,
    )
    if not match:
        raise ValueError(f"{path.relative_to(ROOT)}: missing int const {name}")
    return int(match.group(1))


def expected_profile(profile: str) -> dict[str, str]:
    common = {
        "game_version": string_const(BUILD_INFO, "GAME_VERSION"),
        "build_id": string_const(BUILD_INFO, "BUILD_ID"),
        "save_version": str(int_const(SAVE_MANAGER, "SAVE_VERSION")),
    }
    demo_feature = string_const(BUILD_FLAVOR, "_DEMO_FEATURE")
    if profile == "full":
        return {
            **common,
            "build_flavor": "full",
            "save_namespace": "legacy",
            "features": "none",
        }
    if profile == "demo":
        return {
            **common,
            "build_flavor": "demo",
            "save_namespace": "legacy",
            "features": demo_feature,
        }
    if profile == "playtest":
        playtest_feature = string_const(BUILD_FLAVOR, "PLAYTEST_FEATURE")
        return {
            **common,
            "build_flavor": string_const(
                BUILD_FLAVOR, "PLAYTEST_FLAVOR_ID"
            ),
            "save_namespace": string_const(
                BUILD_FLAVOR, "PLAYTEST_SAVE_NAMESPACE"
            ),
            "features": f"{demo_feature},{playtest_feature}",
        }
    raise ValueError(f"unknown profile: {profile}")


def parse_manifest(path: Path) -> dict[str, str]:
    if not path.is_file():
        raise ValueError(f"missing manifest: {path}")
    values: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.removeprefix("#").strip()
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def parse_checksum_rows(path: Path) -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        match = CHECKSUM_RE.fullmatch(raw)
        if match:
            rows.append((match.group(1), match.group(2)))
    return rows


def sha256_path(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def manifest_errors(
    profile: str,
    values: dict[str, str],
    checksum_rows: list[tuple[str, str]] | None = None,
    require_revision: bool = True,
) -> list[str]:
    expected = expected_profile(profile)
    errors = [
        f"{profile}: {key}={values.get(key)!r}, expected {value!r}"
        for key, value in expected.items()
        if values.get(key) != value
    ]
    if require_revision:
        for key in ("revision", "tree"):
            if not re.fullmatch(r"[0-9a-f]{40}", values.get(key, "")):
                errors.append(f"{profile}: {key} is not a full Git hash")
    if values.get("profile") != profile:
        errors.append(
            f"{profile}: profile={values.get('profile')!r}, expected {profile!r}"
        )
    allowed_source_status = {"clean", "dirty"} if profile == "full" else {"clean"}
    if values.get("source_status") not in allowed_source_status:
        errors.append(
            f"{profile}: source_status={values.get('source_status')!r}, "
            f"expected one of {sorted(allowed_source_status)}"
        )
    if values.get("godot") != EXPECTED_GODOT_VERSION:
        errors.append(
            f"{profile}: godot={values.get('godot')!r}, "
            f"expected {EXPECTED_GODOT_VERSION!r}"
        )
    if not re.fullmatch(
        r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z",
        values.get("generated_utc", ""),
    ):
        errors.append(f"{profile}: generated_utc is not canonical UTC")
    if checksum_rows is not None:
        expected_count = PROFILE_ARTIFACT_COUNTS[profile]
        count_invalid = (
            len(checksum_rows) < 1
            if profile == "full"
            else len(checksum_rows) != expected_count
        )
        if count_invalid:
            errors.append(
                f"{profile}: artifact checksums={len(checksum_rows)}, "
                f"expected {'at least 1' if profile == 'full' else expected_count}"
            )
        paths = [path for _digest, path in checksum_rows]
        if len(paths) != len(set(paths)):
            errors.append(f"{profile}: duplicate artifact checksum path")
        for digest, raw_path in checksum_rows:
            if not re.fullmatch(r"[0-9a-f]{64}", digest):
                errors.append(f"{profile}: malformed artifact SHA-256")
            path = PurePosixPath(raw_path)
            if path.is_absolute() or ".." in path.parts or path.as_posix() != raw_path:
                errors.append(f"{profile}: unsafe artifact path {raw_path!r}")
    return errors


def artifact_file_errors(
    profile: str, checksum_rows: list[tuple[str, str]]
) -> list[str]:
    errors: list[str] = []
    for expected_hash, raw_path in checksum_rows:
        path = PurePosixPath(raw_path)
        if path.is_absolute() or ".." in path.parts or path.as_posix() != raw_path:
            continue
        artifact = ROOT / path
        if not artifact.is_file():
            errors.append(f"{profile}: artifact missing: {raw_path}")
        elif sha256_path(artifact) != expected_hash:
            errors.append(f"{profile}: artifact SHA-256 mismatch: {raw_path}")
    web_rows = {
        raw_path for _digest, raw_path in checksum_rows
        if raw_path.startswith("build/web/")
    }
    if profile == "full" and web_rows:
        web_root = ROOT / "build" / "web"
        actual_web_files = {
            path.relative_to(ROOT).as_posix()
            for path in web_root.rglob("*")
            if path.is_file() and path.name != "MANIFEST.sha256"
        }
        if web_rows != actual_web_files:
            errors.append(
                "full: web manifest file coverage mismatch: "
                f"missing={sorted(actual_web_files - web_rows)} "
                f"extra={sorted(web_rows - actual_web_files)}"
            )
    return errors


def full_rc_manifest_errors(
    values: dict[str, str], checksum_rows: list[tuple[str, str]]
) -> list[str]:
    """Require one clean manifest for the three native full-RC artifacts."""
    errors = manifest_errors("full", values, checksum_rows)
    if values.get("source_status") != "clean":
        errors.append("full_rc: source_status must be clean")
    actual_paths = tuple(raw_path for _digest, raw_path in checksum_rows)
    if actual_paths != FULL_RC_ARTIFACT_PATHS:
        errors.append(
            "full_rc: artifact paths/order mismatch: "
            f"actual={list(actual_paths)!r} "
            f"expected={list(FULL_RC_ARTIFACT_PATHS)!r}"
        )
    return errors


def git_value(*args: str) -> str:
    return subprocess.check_output(
        ["git", "-C", str(ROOT), *args], text=True
    ).strip()


def package_build_id_errors(
    build_id: str,
    commit_date: str,
    first_parent_build_id: str | None = None,
) -> list[str]:
    """Reject a package label that does not uniquely identify clean HEAD."""
    match = BUILD_ID_RE.fullmatch(build_id)
    if match is None:
        return [
            f"build_id={build_id!r} must use YYYY.MM.DD.N with N >= 1"
        ]
    build_date = match.group("date")
    try:
        datetime.date.fromisoformat(build_date.replace(".", "-"))
    except ValueError:
        return [f"build_id={build_id!r} contains an invalid calendar date"]
    if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", commit_date):
        return [f"HEAD commit date={commit_date!r} is not canonical YYYY-MM-DD"]
    try:
        datetime.date.fromisoformat(commit_date)
    except ValueError:
        return [f"HEAD commit date={commit_date!r} is not a valid calendar date"]
    expected_date = commit_date.replace("-", ".")
    if build_date != expected_date:
        return [
            f"build_id={build_id!r} is stale for HEAD commit date "
            f"{commit_date}; issue {expected_date}.N before packaging"
        ]
    if first_parent_build_id == build_id:
        return [
            f"build_id={build_id!r} was already used by HEAD's first parent; "
            f"increment {expected_date}.N before packaging this revision"
        ]
    return []


def git_first_parent_build_id() -> str | None:
    """Return the first parent's BUILD_ID, or None for the root commit."""
    lineage = git_value("rev-list", "--parents", "-n", "1", "HEAD").split()
    if len(lineage) < 2:
        return None
    parent_text = git_value(
        "show", f"{lineage[1]}:systems/BuildInfo.gd"
    )
    match = re.search(
        r'^const\s+BUILD_ID\s*:?=\s*"([^"]+)"\s*$',
        parent_text,
        flags=re.MULTILINE,
    )
    if match is None:
        raise ValueError("HEAD's first parent is missing BuildInfo.BUILD_ID")
    return match.group(1)


def manifest_source_errors(profile: str, values: dict[str, str]) -> list[str]:
    errors: list[str] = []
    try:
        expected_revision = git_value("rev-parse", "HEAD")
        expected_tree = git_value("rev-parse", "HEAD^{tree}")
        status = git_value("status", "--porcelain", "--untracked-files=all")
    except (OSError, subprocess.CalledProcessError) as exc:
        return [f"{profile}: cannot inspect current Git source: {exc}"]
    expected_status = "clean" if not status else "dirty"
    if values.get("revision") != expected_revision:
        errors.append(
            f"{profile}: revision does not match current HEAD {expected_revision}"
        )
    if values.get("tree") != expected_tree:
        errors.append(f"{profile}: tree does not match current HEAD tree {expected_tree}")
    if values.get("source_status") != expected_status:
        errors.append(
            f"{profile}: source_status does not match current worktree "
            f"{expected_status!r}"
        )
    return errors


def export_preset_errors(text: str) -> list[str]:
    errors: list[str] = []
    actual: dict[str, str] = {}
    blocks = re.split(r"(?m)(?=^\[preset\.\d+\]\s*$)", text)
    for block in blocks:
        if not re.match(r"^\[preset\.\d+\]", block):
            continue
        name_match = re.search(r'^name="([^"]+)"$', block, flags=re.MULTILINE)
        feature_match = re.search(
            r'^custom_features="([^"]*)"$', block, flags=re.MULTILINE
        )
        if name_match is None or feature_match is None:
            errors.append("export preset missing name or custom_features")
            continue
        name = name_match.group(1)
        if name in actual:
            errors.append(f"duplicate export preset name: {name}")
        actual[name] = feature_match.group(1)
    if set(actual) != set(PRESET_FEATURES):
        errors.append(
            "export preset identity set mismatch: "
            f"missing={sorted(set(PRESET_FEATURES) - set(actual))} "
            f"extra={sorted(set(actual) - set(PRESET_FEATURES))}"
        )
    for name, expected in PRESET_FEATURES.items():
        if name in actual and actual[name] != expected:
            errors.append(
                f"export preset {name}: custom_features={actual[name]!r}, "
                f"expected {expected!r}"
            )
    return errors


def build_script_errors(build_script: str) -> list[str]:
    errors: list[str] = []
    required_calls = {
        "full manifest audit": (
            r'python3\s+"\$PROJECT_DIR/tools/build_identity_audit\.py"'
            r'\s*(?:\\\s*)?'
            r'--manifest\s+"full=\$manifest"'
        ),
        "demo manifest audit": (
            r'python3\s+"\$PROJECT_DIR/tools/build_identity_audit\.py"'
            r'\s*(?:\\\s*)?'
            r'--manifest\s+"demo=\$manifest"'
        ),
        "playtest manifest audit": (
            r'python3\s+"\$PROJECT_DIR/tools/build_identity_audit\.py"'
            r'\s*(?:\\\s*)?'
            r'--manifest\s+"playtest=\$manifest"'
        ),
        "full RC aggregate manifest audit": (
            r'^\s*--require-full-rc-manifest\s+"\$manifest"'
        ),
        "playtest feature header": (
            r'write_identity_header\s+"\$GD_PLAYTEST_FLAVOR"\s+'
            r'"\$GD_PLAYTEST_NAMESPACE"\s*(?:\\\s*)?'
            r'"\$GD_DEMO_FEATURE,\$GD_PLAYTEST_FEATURE"'
        ),
    }
    for label, pattern in required_calls.items():
        if not re.search(pattern, build_script, flags=re.MULTILINE):
            errors.append(f"build.sh malformed or missing {label}")
    web_markers = {
        "recursive web artifact scan": 'find "$PROJECT_DIR/build/web" -type f',
        "web manifest exclusion and stable order": (
            "! -name 'MANIFEST.sha256' -print0 | sort -z"
        ),
    }
    for label, marker in web_markers.items():
        if marker not in build_script:
            errors.append(f"build.sh malformed or missing {label}")
    date_guard = re.search(
        r'^require_current_package_build_id\(\) \{\n'
        r'(?P<body>.*?)^\}\s*$',
        build_script,
        flags=re.MULTILINE | re.DOTALL,
    )
    if date_guard is None or not re.search(
        r'python3\s+"\$PROJECT_DIR/tools/build_identity_audit\.py"\s+'
        r'--require-head-date',
        date_guard.group("body") if date_guard else "",
    ):
        errors.append("build.sh malformed or missing package build-id date guard")
    for aggregate in ("build_demo", "build_playtest", "build_full_rc"):
        function = re.search(
            rf'^{aggregate}\(\) \{{\n(?P<body>.*?)^\}}\s*$',
            build_script,
            flags=re.MULTILINE | re.DOTALL,
        )
        if function is None or not re.search(
            r'^\s+require_current_package_build_id\s*$',
            function.group("body") if function else "",
            flags=re.MULTILINE,
        ):
            errors.append(f"build.sh {aggregate} omitted package build-id date guard")
    full_rc_function = re.search(
        r'^build_full_rc\(\) \{\n(?P<body>.*?)^\}\s*$',
        build_script,
        flags=re.MULTILINE | re.DOTALL,
    )
    full_rc_body = full_rc_function.group("body") if full_rc_function else ""
    actual_full_rc_stages = tuple(
        line.strip()
        for line in full_rc_body.splitlines()
        if re.fullmatch(r"[a-z_]+", line.strip())
    )
    if actual_full_rc_stages != FULL_RC_STAGE_SEQUENCE:
        errors.append(
            "build.sh build_full_rc stage sequence mismatch: "
            f"actual={actual_full_rc_stages!r} "
            f"expected={FULL_RC_STAGE_SEQUENCE!r}"
        )
    full_rc_manifest = re.search(
        r'^write_full_rc_manifest\(\) \{\n(?P<body>.*?)^\}\s*$',
        build_script,
        flags=re.MULTILINE | re.DOTALL,
    )
    full_rc_manifest_body = (
        full_rc_manifest.group("body") if full_rc_manifest else ""
    )
    for artifact_path in FULL_RC_ARTIFACT_PATHS:
        expected = f'$PROJECT_DIR/{artifact_path}'
        if expected not in full_rc_manifest_body:
            errors.append(
                f"build.sh full RC manifest omitted artifact {artifact_path}"
            )
    export_guard = re.search(
        r'^run_retail_export\(\) \{\n(?P<body>.*?)^\}\s*$',
        build_script,
        flags=re.MULTILINE | re.DOTALL,
    )
    export_guard_body = export_guard.group("body") if export_guard else ""
    for guard_token in (
        'rm -f -- "$artifact"',
        "SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|ERROR:",
        '"$exit_code" -ne 0',
        '! -f "$artifact"',
    ):
        if guard_token not in export_guard_body:
            errors.append(f"build.sh retail export guard omitted {guard_token}")
    for function_name, invocation in (
        ("build_windows", 'run_retail_export "Windows"'),
        ("build_macos", 'run_retail_export "macOS"'),
        ("build_linux", 'run_retail_export "Linux / Steam Deck"'),
    ):
        function = re.search(
            rf'^{function_name}\(\) \{{\n(?P<body>.*?)^\}}\s*$',
            build_script,
            flags=re.MULTILINE | re.DOTALL,
        )
        if function is None or invocation not in function.group("body"):
            errors.append(f"build.sh {function_name} bypasses retail export guard")
    return errors


def static_errors() -> list[str]:
    errors: list[str] = []
    build_info = BUILD_INFO.read_text(encoding="utf-8")
    save_manager = SAVE_MANAGER.read_text(encoding="utf-8")
    build_script = BUILD_SCRIPT.read_text(encoding="utf-8")
    for field in IDENTITY_FIELDS:
        if f'"{field}"' not in build_info:
            errors.append(f"BuildInfo artifact_identity omitted {field}")
        if field not in save_manager:
            errors.append(f"SaveManager omitted {field}")
        if f"# {field}=" not in build_script:
            errors.append(f"build.sh manifest omitted {field}")
    for token in ("# save_version=", "# features=", "build_identity_audit.py"):
        if token not in build_script:
            errors.append(f"build.sh missing manifest/audit token: {token}")
    errors.extend(build_script_errors(build_script))
    errors.extend(export_preset_errors(EXPORT_PRESETS.read_text(encoding="utf-8")))
    return errors


def run_self_test() -> list[str]:
    failures: list[str] = []
    profiles = ("full", "demo", "playtest")
    for profile in profiles:
        baseline = expected_profile(profile)
        baseline.update(
            {
                "profile": profile,
                "source_status": "clean",
                "revision": "a" * 40,
                "tree": "b" * 40,
                "godot": EXPECTED_GODOT_VERSION,
                "generated_utc": "2026-08-03T00:00:00Z",
            }
        )
        rows = [
            ("c" * 64, f"build/fixture-{profile}-{index}.bin")
            for index in range(PROFILE_ARTIFACT_COUNTS[profile])
        ]
        if manifest_errors(profile, baseline, rows):
            failures.append(f"{profile}: valid fixture rejected")
        for field in (*IDENTITY_FIELDS, "save_version", "features"):
            mutated = baseline.copy()
            mutated[field] = "mutated"
            if not manifest_errors(profile, mutated, rows):
                failures.append(f"{profile}: {field} mutation accepted")
        for field in ("revision", "tree"):
            mutated = baseline.copy()
            mutated[field] = "short"
            if not manifest_errors(profile, mutated, rows):
                failures.append(f"{profile}: {field} mutation accepted")
        for field in ("profile", "source_status"):
            mutated = baseline.copy()
            mutated[field] = "mutated"
            if not manifest_errors(profile, mutated, rows):
                failures.append(f"{profile}: {field} mutation accepted")
        for field in ("godot", "generated_utc"):
            mutated = baseline.copy()
            mutated[field] = "mutated"
            if not manifest_errors(profile, mutated, rows):
                failures.append(f"{profile}: {field} mutation accepted")
        if not manifest_errors(profile, baseline, rows[:-1]):
            failures.append(f"{profile}: missing artifact checksum accepted")
        malformed_rows = rows.copy()
        malformed_rows[0] = ("short", malformed_rows[0][1])
        if not manifest_errors(profile, baseline, malformed_rows):
            failures.append(f"{profile}: malformed artifact checksum accepted")
    full_rc_baseline = expected_profile("full")
    full_rc_baseline.update(
        {
            "profile": "full",
            "source_status": "clean",
            "revision": "d" * 40,
            "tree": "e" * 40,
            "godot": EXPECTED_GODOT_VERSION,
            "generated_utc": "2026-08-24T00:00:00Z",
        }
    )
    full_rc_rows = [
        (str(index) * 64, path)
        for index, path in enumerate(FULL_RC_ARTIFACT_PATHS, start=1)
    ]
    if full_rc_manifest_errors(full_rc_baseline, full_rc_rows):
        failures.append("full_rc: valid aggregate fixture rejected")
    for label, mutated_rows in (
        ("missing artifact", full_rc_rows[:-1]),
        ("extra artifact", [*full_rc_rows, ("4" * 64, "build/extra.bin")]),
        ("wrong order", [full_rc_rows[1], full_rc_rows[0], full_rc_rows[2]]),
        ("wrong path", [full_rc_rows[0], full_rc_rows[1], ("3" * 64, "build/linux/wrong")]),
    ):
        if not full_rc_manifest_errors(full_rc_baseline, mutated_rows):
            failures.append(f"full_rc: {label} accepted")
    # Exercise the parser as well, so comment formatting cannot silently drift.
    with tempfile.TemporaryDirectory(prefix="gangnam-build-id-") as tmp:
        fixture = Path(tmp) / "MANIFEST.sha256"
        fixture.write_text(
            "\n".join(
                [*(f"# {key}={value}" for key, value in baseline.items())]
                + [f"{digest}  {path}" for digest, path in rows]
            ),
            encoding="utf-8",
        )
        if parse_manifest(fixture).get("build_id") != baseline["build_id"]:
            failures.append("manifest parser lost build_id")
        if parse_checksum_rows(fixture) != rows:
            failures.append("manifest parser lost artifact checksum rows")
    build_id_date_cases = (
        ("2026.08.10.1", "2026-08-10", "2026.08.09.9", False),
        ("2026.08.10.27", "2026-08-10", "2026.08.10.26", False),
        ("2026.08.10.27", "2026-08-10", "2026.08.10.27", True),
        ("2026.08.03.2", "2026-08-10", None, True),
        ("2026.02.30.1", "2026-02-28", None, True),
        ("2026.08.10.0", "2026-08-10", None, True),
        ("2026-08-10.1", "2026-08-10", None, True),
        ("2026.08.10.1", "not-a-date", None, True),
    )
    for (
        build_id, commit_date, first_parent_build_id, should_fail
    ) in build_id_date_cases:
        failed = bool(package_build_id_errors(
            build_id, commit_date, first_parent_build_id
        ))
        if failed != should_fail:
            failures.append(
                "package build-id date fixture returned the wrong result: "
                f"build_id={build_id!r} commit_date={commit_date!r} "
                f"first_parent_build_id={first_parent_build_id!r}"
            )
    build_script = BUILD_SCRIPT.read_text(encoding="utf-8")
    script_mutations = {
        "full manifest invocation": '--manifest "full=$manifest"',
        "demo manifest invocation": '--manifest "demo=$manifest"',
        "playtest manifest invocation": '--manifest "playtest=$manifest"',
        "playtest feature header": '"$GD_DEMO_FEATURE,$GD_PLAYTEST_FEATURE"',
        "recursive web artifact scan": 'find "$PROJECT_DIR/build/web" -type f',
        "web manifest exclusion and stable order": (
            "! -name 'MANIFEST.sha256' -print0 | sort -z"
        ),
        "package build-id date audit": "--require-head-date",
        "demo package build-id date guard": (
            "build_demo() {\n  require_clean_playtest_source\n"
            "  require_current_package_build_id"
        ),
        "playtest package build-id date guard": (
            "build_playtest() {\n  require_clean_playtest_source\n"
            "  require_current_package_build_id"
        ),
        "full RC package build-id date guard": (
            "build_full_rc() {\n  require_clean_playtest_source\n"
            "  require_current_package_build_id"
        ),
        "full RC aggregate manifest audit": (
            '--require-full-rc-manifest "$manifest"'
        ),
    }
    for label, marker in script_mutations.items():
        if marker not in build_script:
            failures.append(f"build.sh self-test fixture lost {label}")
            continue
        mutated = (
            build_script.replace(marker, "MUTATED_WEB_MANIFEST_LOGIC", 1)
            if label in {
                "recursive web artifact scan",
                "web manifest exclusion and stable order",
            }
            else build_script.replace(marker, f"+    {marker}", 1)
        )
        if not build_script_errors(mutated):
            failures.append(f"build.sh accepted malformed {label}")
    full_rc_function = re.search(
        r'^build_full_rc\(\) \{\n(?P<body>.*?)^\}\s*$',
        build_script,
        flags=re.MULTILINE | re.DOTALL,
    )
    if full_rc_function is None:
        failures.append("build.sh self-test fixture lost build_full_rc")
    else:
        original_body = full_rc_function.group("body")
        original_lines = original_body.splitlines(keepends=True)
        stage_line_indexes = [
            index
            for index, line in enumerate(original_lines)
            if re.fullmatch(r"\s+[a-z_]+\s*", line)
        ]
        for stage_index, line_index in enumerate(stage_line_indexes):
            mutated_lines = original_lines.copy()
            newline = "\n" if mutated_lines[line_index].endswith("\n") else ""
            mutated_lines[line_index] = "  true" + newline
            mutated_body = "".join(mutated_lines)
            mutated_script = (
                build_script[: full_rc_function.start("body")]
                + mutated_body
                + build_script[full_rc_function.end("body") :]
            )
            if not build_script_errors(mutated_script):
                failures.append(
                    "build.sh accepted missing/reordered full RC stage "
                    f"{stage_index}"
                )
    guard_env = dict(os.environ)
    guard_env["GODOT"] = "/usr/bin/true"
    guard_test = subprocess.run(
        ["bash", str(BUILD_SCRIPT), "full-rc-self-test"],
        cwd=ROOT,
        env=guard_env,
        capture_output=True,
        text=True,
        check=False,
    )
    if (
        guard_test.returncode != 0
        or "FULL_RC_EXPORT_GUARD_SELF_TEST_OK cases=3" not in guard_test.stdout
    ):
        failures.append(
            "build.sh full RC export guard behavior self-test failed: "
            f"exit={guard_test.returncode} output={guard_test.stdout!r} "
            f"stderr={guard_test.stderr!r}"
        )
    preset_text = EXPORT_PRESETS.read_text(encoding="utf-8")
    mutated_preset = preset_text.replace(
        'custom_features="gangnam_demo,core_loop_v2_playtest"',
        'custom_features="gangnam_demo"',
        1,
    )
    if not export_preset_errors(mutated_preset):
        failures.append("export presets accepted a V2 feature mutation")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest",
        action="append",
        default=[],
        metavar="PROFILE=PATH",
        help="verify a full, demo, or playtest MANIFEST.sha256",
    )
    parser.add_argument(
        "--require-full-rc-manifest",
        metavar="PATH",
        help=(
            "require a clean full manifest containing exactly the Windows, "
            "macOS, and Linux release-candidate artifacts"
        ),
    )
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument(
        "--require-head-date",
        action="store_true",
        help="require BUILD_ID's date to equal the current HEAD commit date",
    )
    args = parser.parse_args()

    errors = static_errors()
    checked = 0
    for raw in args.manifest:
        if "=" not in raw:
            errors.append(f"invalid --manifest value: {raw}")
            continue
        profile, raw_path = raw.split("=", 1)
        try:
            errors.extend(
                manifest_errors(
                    profile,
                    parse_manifest(Path(raw_path)),
                    parse_checksum_rows(Path(raw_path)),
                )
            )
            errors.extend(
                artifact_file_errors(profile, parse_checksum_rows(Path(raw_path)))
            )
            errors.extend(manifest_source_errors(profile, parse_manifest(Path(raw_path))))
            checked += 1
        except ValueError as exc:
            errors.append(str(exc))
    if args.require_full_rc_manifest:
        try:
            full_rc_path = Path(args.require_full_rc_manifest)
            full_rc_values = parse_manifest(full_rc_path)
            full_rc_rows = parse_checksum_rows(full_rc_path)
            errors.extend(full_rc_manifest_errors(full_rc_values, full_rc_rows))
            errors.extend(artifact_file_errors("full", full_rc_rows))
            errors.extend(manifest_source_errors("full", full_rc_values))
            checked += 1
        except ValueError as exc:
            errors.append(str(exc))
    self_tests = 0
    if args.self_test:
        errors.extend(run_self_test())
        self_tests = 3 * 14 + 2 + 8 + 11 + 1 + 5 + 12 + 3
    if args.require_head_date:
        try:
            errors.extend(
                package_build_id_errors(
                    string_const(BUILD_INFO, "BUILD_ID"),
                    git_value("show", "-s", "--format=%cs", "HEAD"),
                    git_first_parent_build_id(),
                )
            )
        except (OSError, subprocess.CalledProcessError, ValueError) as exc:
            errors.append(f"cannot verify package build-id date: {exc}")
    if errors:
        for error in errors:
            print(f"BUILD_IDENTITY_AUDIT_FAIL {error}", file=sys.stderr)
        return 1
    print(
        "BUILD_IDENTITY_AUDIT_OK "
        f"profiles=3 identity_fields={len(IDENTITY_FIELDS)} "
        f"manifests={checked} self_tests={self_tests}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

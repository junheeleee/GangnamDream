#!/bin/bash
## Build the isolated ORDER-124 story-choice macOS candidate from a fixed clean commit.

set -euo pipefail

readonly EXPECTED_BUILD_ID="2026.08.24.2"
readonly EXPECTED_GODOT="4.6.2.stable.official.71f334935"
readonly PROFILE="order124_m1m6_story_choice"
readonly PRESET_NAME="ORDER-124 M01-M06 Story Choice Playtest"
readonly APP_STEM="GangnamDream-ORDER124-M01M06-StoryChoicePlaytest"
readonly BUNDLE_ID="dev.junheelee.gangnamdream.order124storychoice"
readonly ENTRY_SCENE="res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
readonly CHECK_SCENE="res://tools/StoryChoiceM1M6Check.tscn"
readonly CUSTOM_USER_DIR="GangnamDream_ORDER124_StoryChoice_v1"
readonly APP_REL="build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.app"
readonly ZIP_REL="build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.zip"
readonly MANIFEST_REL="build/order124/MANIFEST.json"
readonly CHECKSUM_REL="build/order124/MANIFEST.sha256"
readonly TARGET_MARKER="STORY_CHOICE_M1M6_CHECK_OK months=6 weeks=24 settlements=6 commitments=0 routes=2 save=1 m6=1"
readonly NATIVE_MARKER_PREFIX="ORDER124_NATIVE_ENTRY_OK"
readonly SMOKE_MARKER_PREFIX="ORDER124_WRAPPER_SMOKE_OK"

usage() {
  echo "usage: GODOT=/path/to/Godot $0 [--source <commit>] --build-id 2026.08.24.2" >&2
}

SOURCE_REF="HEAD"
BUILD_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      SOURCE_REF="$2"
      shift 2
      ;;
    --build-id)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      BUILD_ID="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ORDER124_BUILD_FAIL: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ "$BUILD_ID" != "$EXPECTED_BUILD_ID" ]]; then
  echo "ORDER124_BUILD_FAIL: --build-id must be $EXPECTED_BUILD_ID" >&2
  exit 2
fi
if [[ -z "${GODOT:-}" || ! -x "$GODOT" ]]; then
  echo "ORDER124_BUILD_FAIL: set GODOT to an executable Godot 4.6.2 binary" >&2
  exit 2
fi
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ORDER124_BUILD_FAIL: native macOS export and codesign require a macOS host" >&2
  exit 1
fi
for command_name in git tar python3 mktemp ditto codesign plutil; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ORDER124_BUILD_FAIL: required command is unavailable: $command_name" >&2
    exit 1
  fi
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ORDER124_BUILD_FAIL: project is not a Git worktree" >&2
  exit 1
fi
SOURCE_STATUS="$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)"
if [[ -n "$SOURCE_STATUS" ]]; then
  echo "ORDER124_BUILD_FAIL: source worktree is dirty; build only from a fixed clean commit" >&2
  printf '%s\n' "$SOURCE_STATUS" | sed 's/^/  /' >&2
  exit 1
fi
SOURCE_COMMIT="$(git -C "$PROJECT_DIR" rev-parse --verify "$SOURCE_REF^{commit}")"
SOURCE_TREE="$(git -C "$PROJECT_DIR" rev-parse "$SOURCE_COMMIT^{tree}")"
if [[ ! "$SOURCE_COMMIT" =~ ^[0-9a-f]{40}$ || ! "$SOURCE_TREE" =~ ^[0-9a-f]{40}$ ]]; then
  echo "ORDER124_BUILD_FAIL: source did not resolve to a full commit and tree" >&2
  exit 1
fi
GODOT_VERSION="$($GODOT --version 2>&1 | head -n 1)"
if [[ "$GODOT_VERSION" != "$EXPECTED_GODOT" ]]; then
  echo "ORDER124_BUILD_FAIL: expected Godot $EXPECTED_GODOT, got $GODOT_VERSION" >&2
  exit 1
fi

TEMP_PARENT="${TMPDIR:-/tmp}"
case "$(cd "$TEMP_PARENT" 2>/dev/null && pwd -P || true)" in
  "$PROJECT_DIR"|"$PROJECT_DIR"/*) TEMP_PARENT="/tmp" ;;
esac
WORK_DIR="$(mktemp -d "$TEMP_PARENT/gangnamdream-order124.XXXXXX")"
case "$(cd "$WORK_DIR" && pwd -P)" in
  "$PROJECT_DIR"|"$PROJECT_DIR"/*)
    echo "ORDER124_BUILD_FAIL: staging directory must be outside the repository" >&2
    exit 1
    ;;
esac

STAGE_PROJECT="$WORK_DIR/source"
PACKAGE_STAGE="$WORK_DIR/package-stage"
VERIFY_STAGE="$WORK_DIR/verify-stage"
RAW_ZIP="$WORK_DIR/raw.zip"
FINALIZED_ZIP="$WORK_DIR/$APP_STEM.zip"
IMPORT_LOG="$WORK_DIR/import.log"
TARGET_LOG="$WORK_DIR/target.log"
EXPORT_LOG="$WORK_DIR/export.log"
NATIVE_LOG="$WORK_DIR/native.log"
NATIVE_PROBE="$WORK_DIR/native-entry.marker"
KO_LOG="$WORK_DIR/smoke-ko.log"
EN_LOG="$WORK_DIR/smoke-en.log"
PROTECTED_BEFORE="$WORK_DIR/protected-before.json"
PROTECTED_AFTER="$WORK_DIR/protected-after.json"
PROTECTED_RESULT="$WORK_DIR/protected-result.json"
ORDER124_USER_DATA_DIR="$HOME/Library/Application Support/$CUSTOM_USER_DIR"
ORDER124_USER_DATA_BACKUP="$WORK_DIR/order124-user-data-before"
ORDER124_USER_DATA_EXISTED=0
ORDER124_USER_DATA_SNAPSHOT_READY=0
ORDER124_USER_DATA_RESTORED=0
BUILD_STARTED_UTC="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

restore_candidate_user_data() {
  if [[ "$ORDER124_USER_DATA_SNAPSHOT_READY" != "1" || "$ORDER124_USER_DATA_RESTORED" == "1" ]]; then
    return 0
  fi
  case "$ORDER124_USER_DATA_DIR" in
    "$HOME/Library/Application Support/$CUSTOM_USER_DIR") ;;
    *)
      echo "ORDER124_BUILD_FAIL: candidate user-data restore target escaped its exact namespace" >&2
      return 1
      ;;
  esac
  if [[ -e "$ORDER124_USER_DATA_DIR" || -L "$ORDER124_USER_DATA_DIR" ]]; then
    rm -rf "$ORDER124_USER_DATA_DIR"
  fi
  if [[ "$ORDER124_USER_DATA_EXISTED" == "1" ]]; then
    mkdir -p "$(dirname "$ORDER124_USER_DATA_DIR")"
    ditto "$ORDER124_USER_DATA_BACKUP" "$ORDER124_USER_DATA_DIR"
  fi
  ORDER124_USER_DATA_RESTORED=1
}

cleanup() {
  local exit_code=$?
  if [[ -n "${NATIVE_PID:-}" ]]; then
    kill -TERM "$NATIVE_PID" >/dev/null 2>&1 || true
    wait "$NATIVE_PID" >/dev/null 2>&1 || true
  fi
  if ! restore_candidate_user_data; then
    echo "ORDER124_BUILD_FAIL: could not restore the pre-build candidate user-data namespace" >&2
    exit_code=1
  fi
  case "$WORK_DIR" in
    "$TEMP_PARENT"/gangnamdream-order124.*) rm -rf "$WORK_DIR" ;;
  esac
  exit "$exit_code"
}
trap cleanup EXIT INT TERM

# Hash only player data/config JSON under Godot's user root; engine logs and
# shader caches are not saves. Prior candidates and demo artifacts are hashed
# as complete file/symlink inventories.
capture_protected() {
  local output_path="$1"
  python3 - "$output_path" "$PROJECT_DIR" \
    "$HOME/Library/Application Support/Godot/app_userdata" \
    "$HOME/Library/Application Support/GangnamDream_ORDER103_M01M06_v1" \
    "$ORDER124_USER_DATA_DIR" <<'PY'
from __future__ import annotations
import hashlib, json, os, sys
from pathlib import Path

output, root, user_root, order103_user, order124_user = map(Path, sys.argv[1:])

def file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

def is_player_save(path: Path) -> bool:
    return path.name.endswith((".json", ".json.bak", ".json.tmp"))

def state(path: Path, save_only: bool = False, exclude_top: str = "") -> dict:
    rows: list[bytes] = []
    count = 0
    if not path.exists() and not path.is_symlink():
        rows.append(b"missing\0")
        return {"exists": False, "sha256": hashlib.sha256(b"".join(rows)).hexdigest(), "file_count": 0}
    if path.is_file() or path.is_symlink():
        items = [path]
        base = path.parent
    else:
        items = sorted(path.rglob("*"), key=lambda item: item.relative_to(path).as_posix())
        base = path
    for item in items:
        relative = item.relative_to(base).as_posix()
        if exclude_top and relative.split("/", 1)[0] == exclude_top:
            continue
        if item.is_symlink():
            if not save_only or is_player_save(item):
                rows.append(f"link\0{relative}\0{os.readlink(item)}\n".encode())
                count += 1
        elif item.is_file() and (not save_only or is_player_save(item)):
            rows.append(f"file\0{relative}\0{file_hash(item)}\n".encode())
            count += 1
    return {"exists": True, "sha256": hashlib.sha256(b"".join(rows)).hexdigest(), "file_count": count}

specs = [
    ("product_project_godot", root / "project.godot", False, "", "project.godot"),
    ("product_export_presets", root / "export_presets.cfg", False, "", "export_presets.cfg"),
    ("retail_v2_user_save_files", user_root, True, "GangnamDream_ORDER124_StoryChoice_v1", "~/Library/Application Support/Godot/app_userdata"),
    ("order103_candidate_user_dir", order103_user, False, "", "~/Library/Application Support/GangnamDream_ORDER103_M01M06_v1"),
    ("order124_candidate_user_dir", order124_user, False, "", "~/Library/Application Support/GangnamDream_ORDER124_StoryChoice_v1"),
    ("build_order103", root / "build/order103", False, "", "build/order103"),
    ("build_demo", root / "build/demo", False, "", "build/demo"),
    ("build_playtest", root / "build/playtest", False, "", "build/playtest"),
]
payload = []
for label, path, save_only, exclude_top, manifest_path in specs:
    payload.append({"label": label, "path": manifest_path, "state": state(path, save_only, exclude_top)})
output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
}

case "$ORDER124_USER_DATA_DIR" in
  "$HOME/Library/Application Support/$CUSTOM_USER_DIR") ;;
  *)
    echo "ORDER124_BUILD_FAIL: candidate user-data target escaped its exact namespace" >&2
    exit 1
    ;;
esac
if [[ -L "$ORDER124_USER_DATA_DIR" ]]; then
  echo "ORDER124_BUILD_FAIL: candidate user-data namespace must not be a symlink" >&2
  exit 1
fi
if [[ -e "$ORDER124_USER_DATA_DIR" ]]; then
  ditto "$ORDER124_USER_DATA_DIR" "$ORDER124_USER_DATA_BACKUP"
  ORDER124_USER_DATA_EXISTED=1
fi
ORDER124_USER_DATA_SNAPSHOT_READY=1
capture_protected "$PROTECTED_BEFORE"
if [[ -e "$ORDER124_USER_DATA_DIR" || -L "$ORDER124_USER_DATA_DIR" ]]; then
  rm -rf "$ORDER124_USER_DATA_DIR"
fi
mkdir -p "$STAGE_PROJECT" "$PACKAGE_STAGE" "$VERIFY_STAGE"
git -C "$PROJECT_DIR" archive --format=tar "$SOURCE_COMMIT" \
  | tar -xf - -C "$STAGE_PROJECT"

for required in \
  project.godot \
  export_presets.cfg \
  playtests/order124/StoryChoiceM1M6Playtest.gd \
  playtests/order124/StoryChoiceM1M6Playtest.gd.uid \
  playtests/order124/StoryChoiceM1M6Playtest.tscn \
  tools/StoryChoiceM1M6Check.gd \
  tools/StoryChoiceM1M6Check.gd.uid \
  tools/StoryChoiceM1M6Check.tscn \
  tools/audit_scope.json \
  tools/build_order124_macos.sh \
  tools/order124_package_audit.py; do
  if [[ ! -f "$STAGE_PROJECT/$required" ]]; then
    echo "ORDER124_BUILD_FAIL: fixed source commit lacks $required" >&2
    exit 1
  fi
done
python3 "$STAGE_PROJECT/tools/order124_package_audit.py" --self-test

# Only the archived staging project is rewritten. The product settings remain
# protected and are rehashed after native smoke.
python3 - "$STAGE_PROJECT/project.godot" "$STAGE_PROJECT/export_presets.cfg" <<'PY'
from __future__ import annotations
import re, sys
from pathlib import Path

project_path, presets_path = Path(sys.argv[1]), Path(sys.argv[2])

def set_section_value(text: str, section: str, key: str, value: str) -> str:
    match = re.search(rf"(?ms)^\[{re.escape(section)}\]\s*$\n(.*?)(?=^\[|\Z)", text)
    if match is None:
        raise SystemExit(f"ORDER124_BUILD_FAIL: missing section [{section}]")
    body = match.group(1)
    pattern = re.compile(rf"(?m)^{re.escape(key)}=.*$")
    line = f"{key}={value}"
    if pattern.search(body):
        body = pattern.sub(line, body, count=1)
    else:
        body = body.rstrip("\n") + "\n" + line + "\n\n"
    return text[:match.start(1)] + body + text[match.end(1):]

project = project_path.read_text(encoding="utf-8")
for key, value in (
    ("config/name", '"GangnamDream-ORDER124-M01M06-StoryChoicePlaytest"'),
    ("run/main_scene", '"res://playtests/order124/StoryChoiceM1M6Playtest.tscn"'),
    ("config/use_custom_user_dir", "true"),
    ("config/custom_user_dir_name", '"GangnamDream_ORDER124_StoryChoice_v1"'),
    ("boot_splash/show_image", "false"),
    ("boot_splash/image", '""'),
):
    project = set_section_value(project, "application", key, value)
project_path.write_text(project, encoding="utf-8")

presets = presets_path.read_text(encoding="utf-8")
mac_number = None
for match in re.finditer(r"(?m)^\[preset\.(\d+)\]$", presets):
    number = match.group(1)
    section = re.search(rf"(?ms)^\[preset\.{number}\]\s*$\n(.*?)(?=^\[|\Z)", presets)
    if section and re.search(r'(?m)^name="macOS"$', section.group(1)) and re.search(r'(?m)^platform="macOS"$', section.group(1)):
        mac_number = number
        break
if mac_number is None:
    raise SystemExit("ORDER124_BUILD_FAIL: product macOS export preset not found")
for key, value in (
    ("name", '"ORDER-124 M01-M06 Story Choice Playtest"'),
    ("export_path", '"build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.zip"'),
):
    presets = set_section_value(presets, f"preset.{mac_number}", key, value)
for key, value in (
    ("application/bundle_identifier", '"dev.junheelee.gangnamdream.order124storychoice"'),
    ("application/short_version", '"0.1.0"'),
    ("application/version", '"2026.8.24"'),
):
    presets = set_section_value(presets, f"preset.{mac_number}.options", key, value)
presets_path.write_text(presets, encoding="utf-8")
PY

run_godot_exact_gate() {
  local log_path="$1"
  local marker="$2"
  shift 2
  local exit_code=0
  if "$@" >"$log_path" 2>&1; then
    exit_code=0
  else
    exit_code=$?
  fi
  if [[ $exit_code -ne 0 ]] \
      || grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$log_path" \
      || ! grep -Fqx "$marker" "$log_path"; then
    echo "ORDER124_BUILD_FAIL: Godot gate failed (exit=$exit_code, expected=$marker)" >&2
    sed -n '1,320p' "$log_path" >&2
    exit 1
  fi
}

if ! "$GODOT" --headless --path "$STAGE_PROJECT" --import >"$IMPORT_LOG" 2>&1; then
  echo "ORDER124_BUILD_FAIL: full fixed-source import failed" >&2
  sed -n '1,320p' "$IMPORT_LOG" >&2
  exit 1
fi
if grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$IMPORT_LOG"; then
  echo "ORDER124_BUILD_FAIL: fixed-source import contains engine/script errors" >&2
  sed -n '1,320p' "$IMPORT_LOG" >&2
  exit 1
fi
run_godot_exact_gate "$TARGET_LOG" "$TARGET_MARKER" \
  "$GODOT" --headless --path "$STAGE_PROJECT" --quit-after 3600 "$CHECK_SCENE"

if ! "$GODOT" --headless --path "$STAGE_PROJECT" --export-release \
    "$PRESET_NAME" "$RAW_ZIP" >"$EXPORT_LOG" 2>&1; then
  echo "ORDER124_BUILD_FAIL: macOS release export failed" >&2
  sed -n '1,360p' "$EXPORT_LOG" >&2
  exit 1
fi
if [[ ! -s "$RAW_ZIP" ]]; then
  echo "ORDER124_BUILD_FAIL: macOS export did not create a ZIP" >&2
  exit 1
fi

ditto -x -k "$RAW_ZIP" "$PACKAGE_STAGE"
APP_COUNT="$(find "$PACKAGE_STAGE" -maxdepth 1 -type d -name '*.app' | wc -l | tr -d ' ')"
if [[ "$APP_COUNT" != "1" ]]; then
  echo "ORDER124_BUILD_FAIL: exported ZIP must contain exactly one top-level app" >&2
  exit 1
fi
SOURCE_APP="$(find "$PACKAGE_STAGE" -maxdepth 1 -type d -name '*.app' -print -quit)"
INFO_PLIST="$SOURCE_APP/Contents/Info.plist"
OLD_EXECUTABLE="$(plutil -extract CFBundleExecutable raw "$INFO_PLIST")"
OLD_LAUNCHER="$SOURCE_APP/Contents/MacOS/$OLD_EXECUTABLE"
OLD_PCK="$SOURCE_APP/Contents/Resources/$OLD_EXECUTABLE.pck"
if [[ ! -f "$OLD_LAUNCHER" || ! -f "$OLD_PCK" ]]; then
  echo "ORDER124_BUILD_FAIL: exported app launcher or resource pack is missing" >&2
  exit 1
fi
if [[ "$OLD_EXECUTABLE" != "$APP_STEM" ]]; then
  mv "$OLD_LAUNCHER" "$SOURCE_APP/Contents/MacOS/$APP_STEM"
  mv "$OLD_PCK" "$SOURCE_APP/Contents/Resources/$APP_STEM.pck"
fi
plutil -replace CFBundleExecutable -string "$APP_STEM" "$INFO_PLIST"
plutil -replace CFBundleName -string "$APP_STEM" "$INFO_PLIST"
plutil -replace CFBundleDisplayName -string "$APP_STEM" "$INFO_PLIST" 2>/dev/null \
  || plutil -insert CFBundleDisplayName -string "$APP_STEM" "$INFO_PLIST"
FINAL_APP="$PACKAGE_STAGE/$APP_STEM.app"
if [[ "$SOURCE_APP" != "$FINAL_APP" ]]; then
  mv "$SOURCE_APP" "$FINAL_APP"
fi
codesign --force --deep --sign - --options runtime "$FINAL_APP"
codesign --verify --deep --strict "$FINAL_APP"
ditto -c -k --sequesterRsrc --keepParent "$FINAL_APP" "$FINALIZED_ZIP"
ditto -x -k "$FINALIZED_ZIP" "$VERIFY_STAGE"
VERIFIED_APP="$VERIFY_STAGE/$APP_STEM.app"
codesign --verify --deep --strict "$VERIFIED_APP"
LAUNCHER="$VERIFIED_APP/Contents/MacOS/$APP_STEM"
PCK="$VERIFIED_APP/Contents/Resources/$APP_STEM.pck"
if [[ ! -x "$LAUNCHER" || ! -f "$PCK" ]]; then
  echo "ORDER124_BUILD_FAIL: finalized native launcher or PCK is missing" >&2
  exit 1
fi

# Finder-equivalent no-argument launch: only an environment probe is supplied.
ORDER124_NATIVE_PROBE_PATH="$NATIVE_PROBE" "$LAUNCHER" >"$NATIVE_LOG" 2>&1 &
NATIVE_PID=$!
NATIVE_READY=0
for _attempt in $(seq 1 160); do
  if [[ -s "$NATIVE_PROBE" ]] && grep -Eq "^${NATIVE_MARKER_PREFIX}([[:space:]]|$)" "$NATIVE_PROBE"; then
    NATIVE_READY=1
    break
  fi
  if ! kill -0 "$NATIVE_PID" >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done
if [[ "$NATIVE_READY" != "1" ]]; then
  echo "ORDER124_BUILD_FAIL: native no-argument entry marker was not observed" >&2
  sed -n '1,280p' "$NATIVE_LOG" >&2
  exit 1
fi
NATIVE_MARKER="$(grep -E "^${NATIVE_MARKER_PREFIX}([[:space:]]|$)" "$NATIVE_PROBE" | tail -n 1)"
for identity_token in \
  "profile=$PROFILE" \
  "build=$BUILD_ID" \
  "scene=$ENTRY_SCENE" \
  "custom_user_dir=$CUSTOM_USER_DIR" \
  "language=ko" \
  "path="; do
  if [[ "$NATIVE_MARKER" != *"$identity_token"* ]]; then
    echo "ORDER124_BUILD_FAIL: native marker lacks identity token $identity_token" >&2
    exit 1
  fi
done
NATIVE_USER_DATA_DIR="${NATIVE_MARKER##* path=}"
case "$NATIVE_USER_DATA_DIR" in
  */"$CUSTOM_USER_DIR") ;;
  *)
    echo "ORDER124_BUILD_FAIL: native marker resolved outside the isolated custom user dir" >&2
    exit 1
    ;;
esac
kill -TERM "$NATIVE_PID" >/dev/null 2>&1 || true
wait "$NATIVE_PID" >/dev/null 2>&1 || true
NATIVE_PID=""
if grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$NATIVE_LOG"; then
  echo "ORDER124_BUILD_FAIL: native no-argument log contains engine/script errors" >&2
  sed -n '1,280p' "$NATIVE_LOG" >&2
  exit 1
fi

run_godot_prefix_gate() {
  local log_path="$1"
  local marker_prefix="$2"
  shift 2
  local exit_code=0
  if "$@" >"$log_path" 2>&1; then
    exit_code=0
  else
    exit_code=$?
  fi
  if [[ $exit_code -ne 0 ]] \
      || grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$log_path" \
      || ! grep -Eq "^${marker_prefix}([[:space:]]|$)" "$log_path"; then
    echo "ORDER124_BUILD_FAIL: package smoke failed (exit=$exit_code, prefix=$marker_prefix)" >&2
    sed -n '1,320p' "$log_path" >&2
    exit 1
  fi
}

run_godot_prefix_gate "$KO_LOG" "$SMOKE_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  -- --qa=order124 --order124-smoke --order124-language=ko
run_godot_prefix_gate "$EN_LOG" "$SMOKE_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 960x600 \
  -- --qa=order124 --order124-smoke --order124-language=en
KO_MARKER="$(grep -E "^${SMOKE_MARKER_PREFIX}([[:space:]]|$)" "$KO_LOG" | tail -n 1)"
EN_MARKER="$(grep -E "^${SMOKE_MARKER_PREFIX}([[:space:]]|$)" "$EN_LOG" | tail -n 1)"
codesign --verify --deep --strict "$VERIFIED_APP"

restore_candidate_user_data
capture_protected "$PROTECTED_AFTER"
python3 - "$PROTECTED_BEFORE" "$PROTECTED_AFTER" "$PROTECTED_RESULT" <<'PY'
from __future__ import annotations
import json, sys
from pathlib import Path

before_path, after_path, output_path = map(Path, sys.argv[1:])
before = {row["label"]: row for row in json.loads(before_path.read_text(encoding="utf-8"))}
after = {row["label"]: row for row in json.loads(after_path.read_text(encoding="utf-8"))}
rows, errors = [], []
for label in sorted(set(before) | set(after)):
    old, new = before.get(label), after.get(label)
    passed = old is not None and new is not None and old["path"] == new["path"] and old["state"] == new["state"]
    rows.append({
        "label": label,
        "path": old["path"] if old else new["path"],
        "before": old["state"] if old else {},
        "after": new["state"] if new else {},
        "passed": passed,
    })
    if not passed:
        errors.append(label)
output_path.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
if errors:
    raise SystemExit("ORDER124_BUILD_FAIL: protected before/after mismatch: " + ", ".join(errors))
PY

if [[ -n "$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)" ]]; then
  echo "ORDER124_BUILD_FAIL: source worktree changed during packaging" >&2
  git -C "$PROJECT_DIR" status --short >&2
  exit 1
fi

OUTPUT_DIR="$PROJECT_DIR/build/order124"
FINAL_APP_OUTPUT="$PROJECT_DIR/$APP_REL"
FINAL_ZIP="$PROJECT_DIR/$ZIP_REL"
FINAL_MANIFEST="$PROJECT_DIR/$MANIFEST_REL"
FINAL_CHECKSUM="$PROJECT_DIR/$CHECKSUM_REL"
mkdir -p "$(dirname "$FINAL_ZIP")" "$OUTPUT_DIR"
case "$FINAL_APP_OUTPUT" in
  "$PROJECT_DIR"/build/order124/macos/"$APP_STEM".app) ;;
  *)
    echo "ORDER124_BUILD_FAIL: resolved app output escaped the ORDER-124 macOS directory" >&2
    exit 1
    ;;
esac
if [[ -e "$FINAL_APP_OUTPUT" || -L "$FINAL_APP_OUTPUT" ]]; then
  rm -rf "$FINAL_APP_OUTPUT"
fi
ditto "$VERIFIED_APP" "$FINAL_APP_OUTPUT"
codesign --verify --deep --strict "$FINAL_APP_OUTPUT"
mv "$FINALIZED_ZIP" "$FINAL_ZIP"

export ORDER124_PROJECT_DIR="$PROJECT_DIR"
export ORDER124_STAGE_PROJECT="$STAGE_PROJECT"
export ORDER124_SOURCE_REF="$SOURCE_REF"
export ORDER124_SOURCE_COMMIT="$SOURCE_COMMIT"
export ORDER124_SOURCE_TREE="$SOURCE_TREE"
export ORDER124_GODOT_VERSION="$GODOT_VERSION"
export ORDER124_BUILD_STARTED_UTC="$BUILD_STARTED_UTC"
export ORDER124_FINAL_ZIP="$FINAL_ZIP"
export ORDER124_VERIFIED_APP="$FINAL_APP_OUTPUT"
export ORDER124_NATIVE_MARKER="$NATIVE_MARKER"
export ORDER124_KO_MARKER="$KO_MARKER"
export ORDER124_EN_MARKER="$EN_MARKER"
export ORDER124_PROTECTED_RESULT="$PROTECTED_RESULT"
export ORDER124_FINAL_MANIFEST="$FINAL_MANIFEST"
python3 - <<'PY'
from __future__ import annotations
import hashlib, json, os
from datetime import datetime, timezone
from pathlib import Path

root = Path(os.environ["ORDER124_PROJECT_DIR"])
stage = Path(os.environ["ORDER124_STAGE_PROJECT"])
zip_path = Path(os.environ["ORDER124_FINAL_ZIP"])
app = Path(os.environ["ORDER124_VERIFIED_APP"])
manifest_path = Path(os.environ["ORDER124_FINAL_MANIFEST"])
stem = "GangnamDream-ORDER124-M01M06-StoryChoicePlaytest"

def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()

def tree_digest(path: Path) -> tuple[str, int]:
    rows, count = [], 0
    for item in sorted(path.rglob("*"), key=lambda value: value.relative_to(path).as_posix()):
        relative = item.relative_to(path).as_posix()
        if item.is_symlink():
            rows.append(f"link\0{relative}\0{os.readlink(item)}\n".encode())
            count += 1
        elif item.is_file():
            rows.append(f"file\0{relative}\0{digest(item)}\n".encode())
            count += 1
    return hashlib.sha256(b"".join(rows)).hexdigest(), count

contract_paths = [
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
]
contract_files = []
for relative in contract_paths:
    data = __import__("subprocess").check_output([
        "git", "-C", str(root), "show", f"{os.environ['ORDER124_SOURCE_COMMIT']}:{relative}"
    ])
    contract_files.append({"path": relative, "sha256": hashlib.sha256(data).hexdigest(), "size_bytes": len(data)})

app_hash, app_files = tree_digest(app)
launcher = app / "Contents/MacOS" / stem
pck = app / "Contents/Resources" / f"{stem}.pck"
payload = {
    "schema_version": 1,
    "profile": "order124_m1m6_story_choice",
    "game_version": "0.1.0-dev",
    "build_id": "2026.08.24.2",
    "build_flavor": "order124_story_choice_playtest",
    "timestamps": {
        "started_utc": os.environ["ORDER124_BUILD_STARTED_UTC"],
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    },
    "source": {
        "requested_ref": os.environ["ORDER124_SOURCE_REF"],
        "revision": os.environ["ORDER124_SOURCE_COMMIT"],
        "tree": os.environ["ORDER124_SOURCE_TREE"],
        "status": "clean",
        "staging": "full_git_archive_outside_repository",
        "contract_files": contract_files,
        "staged_project_sha256": digest(stage / "project.godot"),
        "staged_export_presets_sha256": digest(stage / "export_presets.cfg"),
    },
    "engine": {"version": os.environ["ORDER124_GODOT_VERSION"]},
    "application": {
        "name": stem,
        "bundle_identifier": "dev.junheelee.gangnamdream.order124storychoice",
        "entry_scene": "res://playtests/order124/StoryChoiceM1M6Playtest.tscn",
        "custom_user_dir_name": "GangnamDream_ORDER124_StoryChoice_v1",
        "splash_enabled": False,
    },
    "package": {
        "zip": {"path": "build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.zip", "sha256": digest(zip_path), "size_bytes": zip_path.stat().st_size},
        "app": {"path": "build/order124/macos/GangnamDream-ORDER124-M01M06-StoryChoicePlaytest.app", "name": f"{stem}.app", "tree_sha256": app_hash, "file_count": app_files},
        "launcher": {"path": f"{stem}.app/Contents/MacOS/{stem}", "sha256": digest(launcher), "size_bytes": launcher.stat().st_size},
        "resource_pack": {"path": f"{stem}.app/Contents/Resources/{stem}.pck", "sha256": digest(pck), "size_bytes": pck.stat().st_size},
    },
    "protected": json.loads(Path(os.environ["ORDER124_PROTECTED_RESULT"]).read_text(encoding="utf-8")),
    "validation": {
        "source_import": {"passed": True},
        "targeted_story_choice": {"passed": True, "scene": "res://tools/StoryChoiceM1M6Check.tscn", "marker": "STORY_CHOICE_M1M6_CHECK_OK months=6 weeks=24 settlements=6 commitments=0 routes=2 save=1 m6=1"},
        "native_export": {"passed": True, "platform": "macOS", "preset": "ORDER-124 M01-M06 Story Choice Playtest"},
        "codesign": {"passed": True, "mode": "ad-hoc", "verification": "--deep --strict"},
        "native_no_argument": {"passed": True, "args": [], "marker": os.environ["ORDER124_NATIVE_MARKER"]},
        "package_smokes": [
            {"passed": True, "language": "ko", "size": "1280x800", "marker": os.environ["ORDER124_KO_MARKER"]},
            {"passed": True, "language": "en", "size": "960x600", "marker": os.environ["ORDER124_EN_MARKER"]},
        ],
    },
}
manifest_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

MANIFEST_HASH="$(python3 - "$FINAL_MANIFEST" <<'PY'
import hashlib, pathlib, sys
print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
)"
printf '%s  %s\n' "$MANIFEST_HASH" "$MANIFEST_REL" > "$FINAL_CHECKSUM"
python3 "$STAGE_PROJECT/tools/order124_package_audit.py" --manifest "$FINAL_MANIFEST"

echo "ORDER124_MACOS_BUILD_OK build=$BUILD_ID revision=$SOURCE_COMMIT tree=$SOURCE_TREE"
echo "  $APP_REL"
echo "  $ZIP_REL"
echo "  $MANIFEST_REL"
echo "  $CHECKSUM_REL"

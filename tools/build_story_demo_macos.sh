#!/bin/bash
## Build the public five-locale M01-M06 story demo from a fixed clean commit.

set -euo pipefail

readonly EXPECTED_BUILD_ID="2026.08.31.1"
readonly EXPECTED_GODOT="4.6.2.stable.official.71f334935"
readonly PRODUCT_REVISION="ce57751eb5555828dfb28af87ab6026e8ab93fb9"
readonly PRODUCT_TREE="0e1ad9a26cdef953d94308015d527080a718eea2"
readonly -a PRODUCT_RUNTIME_SCOPE=(
  project.godot
  export_presets.cfg
  icon.png
  icon.png.import
  icon.svg
  icon.svg.import
  assets
  autoloads
  content
  locale
  playtests
  scenes
  steam_input
  systems
  ui_components
)
readonly PROFILE="story_demo_rc"
readonly PRESET_NAME="Story Demo macOS"
readonly APP_STEM="GangnamDream-StoryDemo"
readonly BUNDLE_ID="dev.junheelee.gangnamdream.storydemo"
readonly ENTRY_SCENE="res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
readonly CHECK_SCENE="res://tools/StoryDemoFourLanguageCheck.tscn"
readonly CUSTOM_USER_DIR="GangnamDream_StoryDemo_v1"
readonly CANDIDATE_SAVE_NAME="story_demo_save.json"
readonly APP_REL="build/story_demo/macos/GangnamDream-StoryDemo.app"
readonly ZIP_REL="build/story_demo/macos/GangnamDream-StoryDemo.zip"
readonly MANIFEST_REL="build/story_demo/MANIFEST.json"
readonly CHECKSUM_REL="build/story_demo/MANIFEST.sha256"
readonly TARGET_MARKER="STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=30 weeks=120 settlements=30 ap_surface=0 save=5 story=10 build=2026.08.31.1"
readonly DENSITY_SELF_TEST_MARKER="STORY_DEMO_DENSITY_AUDIT_SELF_TEST_OK cases=29"
readonly DENSITY_MARKER="STORY_DEMO_DENSITY_AUDIT_OK source=ce57751eb5555828dfb28af87ab6026e8ab93fb9 tree=0e1ad9a26cdef953d94308015d527080a718eea2 build=2026.08.31.1 variants=14 choices=29 receipts_per_run={'clean': 9, 'restitution': 10, 'escalation': 10} signatures=1800 clean=360 restitution=720 escalation=720"
readonly DENSITY_HUMAN_GATE_MARKER="  HUMAN_GATE OPEN human_route_density=not_measured human_fun=not_measured automation_is_not_GO"
readonly NATIVE_MARKER_PREFIX="STORY_DEMO_NATIVE_ENTRY_OK"
readonly SMOKE_MARKER_PREFIX="STORY_DEMO_WRAPPER_SMOKE_OK"
readonly RETURN_MARKER_PREFIX="STORY_DEMO_RETURN_SMOKE_OK"
readonly RESUME_MARKER_PREFIX="STORY_DEMO_RESUME_SMOKE_OK"
readonly REAL_FLOW_MARKER_PREFIX="STORY_DEMO_REAL_FLOW_SMOKE_OK"
readonly SMOKE_TIMEOUT_TICKS=480

usage() {
  echo "usage: GODOT=/path/to/Godot $0 [--source <commit>] --build-id 2026.08.31.1" >&2
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
      echo "STORY_DEMO_BUILD_FAIL: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ "$BUILD_ID" != "$EXPECTED_BUILD_ID" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: --build-id must be $EXPECTED_BUILD_ID" >&2
  exit 2
fi
if [[ -z "${GODOT:-}" || ! -x "$GODOT" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: set GODOT to an executable Godot 4.6.2 binary" >&2
  exit 2
fi
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: native macOS export and codesign require a macOS host" >&2
  exit 1
fi
for command_name in git tar python3 mktemp ditto codesign plutil; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "STORY_DEMO_BUILD_FAIL: required command is unavailable: $command_name" >&2
    exit 1
  fi
done

EARLY_STORY_DEMO_BUILD_LOCK_DIR="$HOME/Library/Application Support/.GangnamDream_StoryDemo_v1.build-lock"
if [[ -e "$EARLY_STORY_DEMO_BUILD_LOCK_DIR" || -L "$EARLY_STORY_DEMO_BUILD_LOCK_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: another story-demo build holds the exclusive lock" >&2
  echo "STORY_DEMO_BUILD_LOCK_PATH lock=$EARLY_STORY_DEMO_BUILD_LOCK_DIR" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "STORY_DEMO_BUILD_FAIL: project is not a Git worktree" >&2
  exit 1
fi
SOURCE_STATUS="$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)"
if [[ -n "$SOURCE_STATUS" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: source worktree is dirty; build only from a fixed clean commit" >&2
  printf '%s\n' "$SOURCE_STATUS" | sed 's/^/  /' >&2
  exit 1
fi
SOURCE_COMMIT="$(git -C "$PROJECT_DIR" rev-parse --verify "$SOURCE_REF^{commit}")"
SOURCE_TREE="$(git -C "$PROJECT_DIR" rev-parse "$SOURCE_COMMIT^{tree}")"
if [[ ! "$SOURCE_COMMIT" =~ ^[0-9a-f]{40}$ || ! "$SOURCE_TREE" =~ ^[0-9a-f]{40}$ ]]; then
  echo "STORY_DEMO_BUILD_FAIL: source did not resolve to a full commit and tree" >&2
  exit 1
fi
RESOLVED_PRODUCT_REVISION="$(git -C "$PROJECT_DIR" rev-parse --verify "$PRODUCT_REVISION^{commit}")"
RESOLVED_PRODUCT_TREE="$(git -C "$PROJECT_DIR" rev-parse "$RESOLVED_PRODUCT_REVISION^{tree}")"
if [[ "$RESOLVED_PRODUCT_REVISION" != "$PRODUCT_REVISION" \
    || "$RESOLVED_PRODUCT_TREE" != "$PRODUCT_TREE" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: exact ORDER-140 product identity is unavailable" >&2
  exit 1
fi
if ! git -C "$PROJECT_DIR" merge-base --is-ancestor \
    "$PRODUCT_REVISION" "$SOURCE_COMMIT"; then
  echo "STORY_DEMO_BUILD_FAIL: package source is not a descendant of the exact product commit" >&2
  exit 1
fi
if ! git -C "$PROJECT_DIR" diff --quiet --no-ext-diff \
    "$PRODUCT_REVISION" "$SOURCE_COMMIT" -- "${PRODUCT_RUNTIME_SCOPE[@]}"; then
  echo "STORY_DEMO_BUILD_FAIL: package source changes the protected product/runtime scope" >&2
  git -C "$PROJECT_DIR" diff --name-only --no-ext-diff \
    "$PRODUCT_REVISION" "$SOURCE_COMMIT" -- "${PRODUCT_RUNTIME_SCOPE[@]}" \
    | sed 's/^/  /' >&2
  exit 1
fi
GODOT_VERSION="$($GODOT --version 2>&1 | head -n 1)"
if [[ "$GODOT_VERSION" != "$EXPECTED_GODOT" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: expected Godot $EXPECTED_GODOT, got $GODOT_VERSION" >&2
  exit 1
fi

archive_guard_preflight_status=0
python3 "$SCRIPT_DIR/story_demo_package_audit.py" --archive-state \
  --source-revision "$SOURCE_COMMIT" >/dev/null || archive_guard_preflight_status=$?
if [[ $archive_guard_preflight_status -ne 0 ]]; then
  echo "STORY_DEMO_BUILD_FAIL: BUILD 2026.08.24.2 is neither an exact physical archive nor canonical missing_with_loss_receipt evidence" >&2
  exit 1
fi

TEMP_PARENT="${TMPDIR:-/tmp}"
case "$(cd "$TEMP_PARENT" 2>/dev/null && pwd -P || true)" in
  "$PROJECT_DIR"|"$PROJECT_DIR"/*) TEMP_PARENT="/tmp" ;;
esac
WORK_DIR="$(mktemp -d "$TEMP_PARENT/gangnamdream-story_demo.XXXXXX")"
case "$(cd "$WORK_DIR" && pwd -P)" in
  "$PROJECT_DIR"|"$PROJECT_DIR"/*)
    echo "STORY_DEMO_BUILD_FAIL: staging directory must be outside the repository" >&2
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
FONT_LOG="$WORK_DIR/font-routing.log"
I18N_LOG="$WORK_DIR/i18n-infrastructure.log"
EXPORT_LOG="$WORK_DIR/export.log"
NATIVE_LOG="$WORK_DIR/native.log"
NATIVE_PROBE="$WORK_DIR/native-entry.marker"
KO_LOG="$WORK_DIR/smoke-ko.log"
EN_LOG="$WORK_DIR/smoke-en.log"
JA_LOG="$WORK_DIR/smoke-ja.log"
ZH_CN_LOG="$WORK_DIR/smoke-zh-cn.log"
ZH_TW_LOG="$WORK_DIR/smoke-zh-tw.log"
RETURN_LOG="$WORK_DIR/return-smoke.log"
RESUME_LOG="$WORK_DIR/resume-smoke.log"
COLD_RESTART_RESUME_LOG="$WORK_DIR/cold-restart-resume-smoke.log"
REAL_FLOW_CLEAN_LOG="$WORK_DIR/real-flow-clean-ko.log"
REAL_FLOW_RESTITUTION_LOG="$WORK_DIR/real-flow-restitution-en.log"
REAL_FLOW_ESCALATION_LOG="$WORK_DIR/real-flow-escalation-zh-cn.log"
DENSITY_SELF_TEST_LOG="$WORK_DIR/density-self-test.log"
DENSITY_LOG="$WORK_DIR/density.log"
RESUME_INPUT_STATE="$WORK_DIR/resume-input-state.json"
PROTECTED_BEFORE="$WORK_DIR/protected-before.json"
PROTECTED_AFTER="$WORK_DIR/protected-after.json"
PROTECTED_RESULT="$WORK_DIR/protected-result.json"
APPLICATION_SUPPORT_DIR="$HOME/Library/Application Support"
STORY_DEMO_USER_DATA_DIR="$APPLICATION_SUPPORT_DIR/$CUSTOM_USER_DIR"
STORY_DEMO_BUILD_LOCK_DIR="$APPLICATION_SUPPORT_DIR/.GangnamDream_StoryDemo_v1.build-lock"
STORY_DEMO_QA_USER_DATA_DIR="$APPLICATION_SUPPORT_DIR/GangnamDream_StoryDemo_RuntimeQA_build"
REAL_FLOW_CLEAN_QA_NAME="GangnamDream_StoryDemo_RuntimeQA_package_real_clean"
REAL_FLOW_RESTITUTION_QA_NAME="GangnamDream_StoryDemo_RuntimeQA_package_real_restitution"
REAL_FLOW_ESCALATION_QA_NAME="GangnamDream_StoryDemo_RuntimeQA_package_real_escalation"
REAL_FLOW_CLEAN_QA_DIR="$APPLICATION_SUPPORT_DIR/$REAL_FLOW_CLEAN_QA_NAME"
REAL_FLOW_RESTITUTION_QA_DIR="$APPLICATION_SUPPORT_DIR/$REAL_FLOW_RESTITUTION_QA_NAME"
REAL_FLOW_ESCALATION_QA_DIR="$APPLICATION_SUPPORT_DIR/$REAL_FLOW_ESCALATION_QA_NAME"
if [[ -L "$APPLICATION_SUPPORT_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: Application Support parent must not be a symlink" >&2
  exit 1
fi
if [[ ! -d "$APPLICATION_SUPPORT_DIR" ]]; then
  if mkdir -p "$APPLICATION_SUPPORT_DIR" && [[ -d "$APPLICATION_SUPPORT_DIR" ]]; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not create the Application Support parent" >&2
    exit 1
  fi
fi
if STORY_DEMO_RECOVERY_ROOT="$(mktemp -d "$TEMP_PARENT/gangnamdream-story_demo-recovery.XXXXXX")" \
    && [[ -d "$STORY_DEMO_RECOVERY_ROOT" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create the separate recovery root" >&2
  exit 1
fi
if STORY_DEMO_ORIGINAL_HOLD_ROOT="$(mktemp -d "$APPLICATION_SUPPORT_DIR/.GangnamDream_StoryDemo_v1.original-hold.XXXXXX")" \
    && [[ -d "$STORY_DEMO_ORIGINAL_HOLD_ROOT" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create the same-volume original hold" >&2
  exit 1
fi
if STORY_DEMO_QUARANTINE_ROOT="$(mktemp -d "$APPLICATION_SUPPORT_DIR/.GangnamDream_StoryDemo_v1.quarantine.XXXXXX")" \
    && [[ -d "$STORY_DEMO_QUARANTINE_ROOT" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create the same-volume quarantine" >&2
  exit 1
fi
STORY_DEMO_USER_DATA_BACKUP="$STORY_DEMO_RECOVERY_ROOT/original-backup"
STORY_DEMO_ORIGINAL_STATE="$STORY_DEMO_RECOVERY_ROOT/original-state.json"
STORY_DEMO_BACKUP_STATE="$STORY_DEMO_RECOVERY_ROOT/backup-state.json"
STORY_DEMO_CURRENT_STATE="$STORY_DEMO_RECOVERY_ROOT/current-state.json"
STORY_DEMO_VERIFY_STATE="$STORY_DEMO_RECOVERY_ROOT/verify-state.json"
STORY_DEMO_ORIGINAL_HOLD="$STORY_DEMO_ORIGINAL_HOLD_ROOT/original"
STORY_DEMO_RESTORE_TEMP_ROOT=""
STORY_DEMO_EXISTING_RESUME_TEMP_ROOT=""
STORY_DEMO_USER_DATA_EXISTED=0
STORY_DEMO_USER_DATA_SNAPSHOT_READY=0
STORY_DEMO_USER_DATA_RESTORED=0
STORY_DEMO_USER_DATA_MUTATION_STARTED=0
STORY_DEMO_RECOVERY_CLEANED=0
STORY_DEMO_BUILD_LOCK_ACQUIRED=0
OUTPUT_DIR="$PROJECT_DIR/build/story_demo"
FINAL_APP_OUTPUT="$PROJECT_DIR/$APP_REL"
FINAL_ZIP="$PROJECT_DIR/$ZIP_REL"
FINAL_MANIFEST="$PROJECT_DIR/$MANIFEST_REL"
FINAL_CHECKSUM="$PROJECT_DIR/$CHECKSUM_REL"
PUBLISH_STAGE_ROOT=""
PUBLISH_READY_SET=""
PUBLISH_PREVIOUS_SET=""
PUBLISH_FAILED_SET=""
PUBLISH_APP=""
PUBLISH_ZIP=""
PUBLISH_MANIFEST=""
PUBLISH_CHECKSUM=""
PUBLISH_PREVIOUS_STATE="$WORK_DIR/publish-previous-state.json"
PUBLISH_NEW_STATE="$WORK_DIR/publish-new-state.json"
PUBLISH_VERIFY_STATE="$WORK_DIR/publish-verify-state.json"
PUBLISH_SWAP_STARTED=0
PUBLISH_PREVIOUS_EXISTED=0
PUBLISH_ROLLBACK_COMPLETE=0
PUBLISH_COMMITTED=0
BUILD_SUCCEEDED=0
BUILD_STARTED_UTC="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

capture_exact_state() {
  local target_path="$1"
  local output_path="$2"
  local state_status=0
  python3 - "$target_path" "$output_path" <<'PY' || state_status=$?
from __future__ import annotations
import hashlib, json, os, stat, sys
from pathlib import Path

target, output = map(Path, sys.argv[1:])

def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()

def lexists(path: Path) -> bool:
    return os.path.lexists(path)

rows: list[bytes] = []
count = 0
if not lexists(target):
    rows.append(b"missing\0")
    payload = {
        "exists": False,
        "kind": "missing",
        "sha256": hashlib.sha256(b"".join(rows)).hexdigest(),
        "entry_count": 0,
    }
else:
    mode = target.lstat().st_mode
    if stat.S_ISLNK(mode):
        rows.append(f"link\0.\0{os.readlink(target)}\n".encode())
        kind = "symlink"
        count = 1
    elif stat.S_ISREG(mode):
        rows.append(f"file\0.\0{digest(target)}\n".encode())
        kind = "file"
        count = 1
    elif stat.S_ISDIR(mode):
        rows.append(b"dir\0.\n")
        kind = "directory"
        count = 1
        for item in sorted(target.rglob("*"), key=lambda value: value.relative_to(target).as_posix()):
            relative = item.relative_to(target).as_posix()
            item_mode = item.lstat().st_mode
            if stat.S_ISLNK(item_mode):
                rows.append(f"link\0{relative}\0{os.readlink(item)}\n".encode())
            elif stat.S_ISREG(item_mode):
                rows.append(f"file\0{relative}\0{digest(item)}\n".encode())
            elif stat.S_ISDIR(item_mode):
                rows.append(f"dir\0{relative}\n".encode())
            else:
                raise SystemExit(f"unsupported user-data entry type: {item}")
            count += 1
    else:
        raise SystemExit(f"unsupported user-data root type: {target}")
    payload = {
        "exists": True,
        "kind": kind,
        "sha256": hashlib.sha256(b"".join(rows)).hexdigest(),
        "entry_count": count,
    }
output.write_text(json.dumps(payload, sort_keys=True) + "\n", encoding="utf-8")
PY
  if [[ $state_status -ne 0 || ! -s "$output_path" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: could not inventory $target_path" >&2
    return 1
  fi
  return 0
}

exact_states_match() {
  local expected_path="$1"
  local actual_path="$2"
  local compare_status=0
  python3 - "$expected_path" "$actual_path" <<'PY' || compare_status=$?
import json, pathlib, sys
expected_path, actual_path = map(pathlib.Path, sys.argv[1:])
expected = json.loads(expected_path.read_text(encoding="utf-8"))
actual = json.loads(actual_path.read_text(encoding="utf-8"))
if expected != actual:
    raise SystemExit(f"state mismatch: expected={expected} actual={actual}")
PY
  if [[ $compare_status -ne 0 ]]; then
    echo "STORY_DEMO_BUILD_FAIL: user-data digest verification failed" >&2
    return 1
  fi
  return 0
}

exact_states_are_equal() {
  local expected_path="$1"
  local actual_path="$2"
  local compare_status=0
  python3 - "$expected_path" "$actual_path" >/dev/null 2>&1 <<'PY' || compare_status=$?
import json, pathlib, sys
expected_path, actual_path = map(pathlib.Path, sys.argv[1:])
expected = json.loads(expected_path.read_text(encoding="utf-8"))
actual = json.loads(actual_path.read_text(encoding="utf-8"))
raise SystemExit(0 if expected == actual else 1)
PY
  return "$compare_status"
}

acquire_story_demo_build_lock() {
  local lock_status=0
  case "$STORY_DEMO_BUILD_LOCK_DIR" in
    "$APPLICATION_SUPPORT_DIR/.GangnamDream_StoryDemo_v1.build-lock") ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: build lock escaped its exact Application Support namespace" >&2
      return 1 ;;
  esac
  mkdir "$STORY_DEMO_BUILD_LOCK_DIR" 2>/dev/null || lock_status=$?
  if [[ $lock_status -ne 0 ]]; then
    echo "STORY_DEMO_BUILD_FAIL: another story-demo build holds the exclusive lock" >&2
    echo "STORY_DEMO_BUILD_LOCK_PATH lock=$STORY_DEMO_BUILD_LOCK_DIR" >&2
    return 1
  fi
  STORY_DEMO_BUILD_LOCK_ACQUIRED=1
  if [[ ! -d "$STORY_DEMO_BUILD_LOCK_DIR" || -L "$STORY_DEMO_BUILD_LOCK_DIR" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: acquired build lock is not an exact directory" >&2
    echo "STORY_DEMO_BUILD_LOCK_PATH lock=$STORY_DEMO_BUILD_LOCK_DIR" >&2
    return 1
  fi
  return 0
}

release_story_demo_build_lock() {
  local release_status=0
  if [[ "$STORY_DEMO_BUILD_LOCK_ACQUIRED" != "1" ]]; then
    return 0
  fi
  if [[ "$STORY_DEMO_USER_DATA_MUTATION_STARTED" == "1" \
      && "$STORY_DEMO_USER_DATA_RESTORED" != "1" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: refusing lock release before verified user-data restoration" >&2
    return 1
  fi
  case "$STORY_DEMO_BUILD_LOCK_DIR" in
    "$APPLICATION_SUPPORT_DIR/.GangnamDream_StoryDemo_v1.build-lock") ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: refusing release of an unexpected build lock" >&2
      return 1 ;;
  esac
  if [[ ! -d "$STORY_DEMO_BUILD_LOCK_DIR" || -L "$STORY_DEMO_BUILD_LOCK_DIR" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: exclusive build lock was replaced or removed" >&2
    return 1
  fi
  rmdir "$STORY_DEMO_BUILD_LOCK_DIR" || release_status=$?
  if [[ $release_status -ne 0 \
      || -e "$STORY_DEMO_BUILD_LOCK_DIR" \
      || -L "$STORY_DEMO_BUILD_LOCK_DIR" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: could not release the exact exclusive build lock" >&2
    return 1
  fi
  STORY_DEMO_BUILD_LOCK_ACQUIRED=0
  return 0
}

report_recovery_paths() {
  echo "STORY_DEMO_RECOVERY_PATH recovery=$STORY_DEMO_RECOVERY_ROOT" >&2
  echo "STORY_DEMO_RECOVERY_PATH original_hold=$STORY_DEMO_ORIGINAL_HOLD_ROOT" >&2
  echo "STORY_DEMO_RECOVERY_PATH quarantine=$STORY_DEMO_QUARANTINE_ROOT" >&2
  if [[ -n "$STORY_DEMO_RESTORE_TEMP_ROOT" ]]; then
    echo "STORY_DEMO_RECOVERY_PATH restore_temp=$STORY_DEMO_RESTORE_TEMP_ROOT" >&2
  fi
  if [[ -n "$STORY_DEMO_EXISTING_RESUME_TEMP_ROOT" ]]; then
    echo "STORY_DEMO_RECOVERY_PATH existing_resume_temp=$STORY_DEMO_EXISTING_RESUME_TEMP_ROOT" >&2
  fi
  if [[ "$STORY_DEMO_BUILD_LOCK_ACQUIRED" == "1" ]]; then
    echo "STORY_DEMO_BUILD_LOCK_PATH lock=$STORY_DEMO_BUILD_LOCK_DIR" >&2
  fi
  if [[ -n "$PUBLISH_STAGE_ROOT" ]]; then
    echo "STORY_DEMO_RECOVERY_PATH publish_stage=$PUBLISH_STAGE_ROOT" >&2
  fi
}

remove_runtime_qa_dir() {
  local qa_path="$1"
  case "$qa_path" in
    "$STORY_DEMO_QA_USER_DATA_DIR"|"$REAL_FLOW_CLEAN_QA_DIR"|"$REAL_FLOW_RESTITUTION_QA_DIR"|"$REAL_FLOW_ESCALATION_QA_DIR") ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: refusing RuntimeQA cleanup outside an exact namespace: $qa_path" >&2
      return 1 ;;
  esac
  if [[ -e "$qa_path" || -L "$qa_path" ]]; then
    if rm -rf "$qa_path" && [[ ! -e "$qa_path" && ! -L "$qa_path" ]]; then
      :
    else
      echo "STORY_DEMO_BUILD_FAIL: could not remove exact RuntimeQA namespace: $qa_path" >&2
      return 1
    fi
  fi
  return 0
}

restore_candidate_user_data() {
  if [[ "$STORY_DEMO_USER_DATA_SNAPSHOT_READY" != "1" || "$STORY_DEMO_USER_DATA_RESTORED" == "1" ]]; then
    return 0
  fi
  case "$STORY_DEMO_USER_DATA_DIR" in
    "$HOME/Library/Application Support/$CUSTOM_USER_DIR") ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: candidate user-data restore target escaped its exact namespace" >&2
      return 1
      ;;
  esac
  case "$STORY_DEMO_RECOVERY_ROOT" in
    "$TEMP_PARENT"/gangnamdream-story_demo-recovery.*) ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: recovery root escaped its exact namespace" >&2
      return 1 ;;
  esac
  case "$STORY_DEMO_ORIGINAL_HOLD_ROOT" in
    "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.original-hold.*) ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: original hold escaped its exact namespace" >&2
      return 1 ;;
  esac
  case "$STORY_DEMO_QUARANTINE_ROOT" in
    "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.quarantine.*) ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: quarantine escaped its exact namespace" >&2
      return 1 ;;
  esac
  if [[ ! -s "$STORY_DEMO_ORIGINAL_STATE" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: original user-data inventory is unavailable" >&2
    return 1
  fi
  if [[ "$STORY_DEMO_USER_DATA_EXISTED" == "1" ]]; then
    if [[ ! -d "$STORY_DEMO_USER_DATA_BACKUP" || -L "$STORY_DEMO_USER_DATA_BACKUP" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: verified recovery backup is unavailable" >&2
      return 1
    fi
    if capture_exact_state "$STORY_DEMO_USER_DATA_BACKUP" "$STORY_DEMO_BACKUP_STATE"; then
      :
    else
      return 1
    fi
    if exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_BACKUP_STATE"; then
      :
    else
      return 1
    fi
  fi

  if capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_CURRENT_STATE"; then
    :
  else
    return 1
  fi
  if exact_states_are_equal "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_CURRENT_STATE"; then
    STORY_DEMO_USER_DATA_RESTORED=1
    return 0
  fi

  if [[ -e "$STORY_DEMO_USER_DATA_DIR" || -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
    local quarantine_target="$STORY_DEMO_QUARANTINE_ROOT/generated-at-final-restore"
    if [[ -e "$quarantine_target" || -L "$quarantine_target" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: final-restore quarantine target already exists" >&2
      return 1
    fi
    if mv "$STORY_DEMO_USER_DATA_DIR" "$quarantine_target"; then
      :
    else
      echo "STORY_DEMO_BUILD_FAIL: could not atomically quarantine generated demo data" >&2
      return 1
    fi
    if capture_exact_state "$quarantine_target" "$STORY_DEMO_VERIFY_STATE"; then
      :
    else
      return 1
    fi
    if exact_states_match "$STORY_DEMO_CURRENT_STATE" "$STORY_DEMO_VERIFY_STATE"; then
      :
    else
      return 1
    fi
  fi

  if [[ "$STORY_DEMO_USER_DATA_EXISTED" == "1" ]]; then
    if [[ -e "$STORY_DEMO_USER_DATA_DIR" || -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: restore target was recreated before atomic installation" >&2
      return 1
    fi
    if [[ -e "$STORY_DEMO_ORIGINAL_HOLD" && ! -L "$STORY_DEMO_ORIGINAL_HOLD" ]]; then
      if capture_exact_state "$STORY_DEMO_ORIGINAL_HOLD" "$STORY_DEMO_VERIFY_STATE"; then
        :
      else
        return 1
      fi
      if exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_VERIFY_STATE"; then
        :
      else
        return 1
      fi
      if [[ -e "$STORY_DEMO_USER_DATA_DIR" || -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
        echo "STORY_DEMO_BUILD_FAIL: original-hold restore target was recreated before atomic rename" >&2
        return 1
      fi
      if mv "$STORY_DEMO_ORIGINAL_HOLD" "$STORY_DEMO_USER_DATA_DIR"; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: could not atomically restore the original user-data hold" >&2
        return 1
      fi
    else
      if STORY_DEMO_RESTORE_TEMP_ROOT="$(mktemp -d "$APPLICATION_SUPPORT_DIR/.GangnamDream_StoryDemo_v1.restore.XXXXXX")" \
          && [[ -d "$STORY_DEMO_RESTORE_TEMP_ROOT" ]]; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: could not create same-volume restore temp" >&2
        return 1
      fi
      local restored_copy="$STORY_DEMO_RESTORE_TEMP_ROOT/restored"
      if ditto "$STORY_DEMO_USER_DATA_BACKUP" "$restored_copy"; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: could not copy verified backup to restore temp" >&2
        return 1
      fi
      if capture_exact_state "$restored_copy" "$STORY_DEMO_VERIFY_STATE"; then
        :
      else
        return 1
      fi
      if exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_VERIFY_STATE"; then
        :
      else
        return 1
      fi
      if [[ -e "$STORY_DEMO_USER_DATA_DIR" || -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
        echo "STORY_DEMO_BUILD_FAIL: restore-temp target was recreated before atomic rename" >&2
        return 1
      fi
      if mv "$restored_copy" "$STORY_DEMO_USER_DATA_DIR"; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: could not atomically install the verified restore temp" >&2
        return 1
      fi
    fi
  fi
  if capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_VERIFY_STATE"; then
    :
  else
    return 1
  fi
  if exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_VERIFY_STATE"; then
    :
  else
    return 1
  fi
  STORY_DEMO_USER_DATA_RESTORED=1
  return 0
}

cleanup_recovery_after_success() {
  if [[ "$STORY_DEMO_USER_DATA_RESTORED" != "1" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: refusing recovery cleanup before verified restoration" >&2
    return 1
  fi
  for cleanup_root in \
      "$STORY_DEMO_QUARANTINE_ROOT" \
      "$STORY_DEMO_ORIGINAL_HOLD_ROOT" \
      "$STORY_DEMO_RESTORE_TEMP_ROOT" \
      "$STORY_DEMO_EXISTING_RESUME_TEMP_ROOT"; do
    [[ -n "$cleanup_root" ]] || continue
    case "$cleanup_root" in
      "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.quarantine.*|\
      "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.original-hold.*|\
      "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.restore.*|\
      "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.existing-resume.*) ;;
      *)
        echo "STORY_DEMO_BUILD_FAIL: refusing cleanup of unexpected recovery path $cleanup_root" >&2
        return 1 ;;
    esac
    if [[ -e "$cleanup_root" || -L "$cleanup_root" ]]; then
      if rm -rf "$cleanup_root" && [[ ! -e "$cleanup_root" && ! -L "$cleanup_root" ]]; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: could not remove successful-build recovery path $cleanup_root" >&2
        return 1
      fi
    fi
  done
  case "$STORY_DEMO_RECOVERY_ROOT" in
    "$TEMP_PARENT"/gangnamdream-story_demo-recovery.*) ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: refusing cleanup of unexpected recovery root" >&2
      return 1 ;;
  esac
  if rm -rf "$STORY_DEMO_RECOVERY_ROOT" \
      && [[ ! -e "$STORY_DEMO_RECOVERY_ROOT" && ! -L "$STORY_DEMO_RECOVERY_ROOT" ]]; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not remove successful-build recovery root" >&2
    return 1
  fi
  STORY_DEMO_RECOVERY_CLEANED=1
  return 0
}

terminate_native_process_bounded() {
  local process_id="$1"
  local evidence_label="$2"
  local kill_status=0
  if [[ -z "$process_id" ]]; then
    return 0
  fi
  kill -TERM "$process_id" >/dev/null 2>&1 || true
  for _termination_grace_tick in $(seq 1 20); do
    if ! kill -0 "$process_id" >/dev/null 2>&1; then
      break
    fi
    sleep 0.25
  done
  if kill -0 "$process_id" >/dev/null 2>&1; then
    kill -KILL "$process_id" >/dev/null 2>&1 || kill_status=$?
    if [[ $kill_status -ne 0 ]]; then
      echo "STORY_DEMO_BUILD_FAIL: could not kill $evidence_label process $process_id" >&2
      return 1
    fi
  fi
  wait "$process_id" >/dev/null 2>&1 || true
  if kill -0 "$process_id" >/dev/null 2>&1; then
    echo "STORY_DEMO_BUILD_FAIL: $evidence_label process survived bounded termination" >&2
    return 1
  fi
  return 0
}

rollback_story_demo_publish() {
  local rollback_status=0
  if [[ "$PUBLISH_COMMITTED" == "1" ]]; then
    return 0
  fi
  if [[ "$PUBLISH_SWAP_STARTED" != "1" ]]; then
    PUBLISH_ROLLBACK_COMPLETE=1
    return 0
  fi
  case "$OUTPUT_DIR" in
    "$PROJECT_DIR/build/story_demo") ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: final publish set escaped its exact output path" >&2
      return 1 ;;
  esac
  case "$PUBLISH_STAGE_ROOT" in
    "$PROJECT_DIR"/build/.story_demo-publish.*) ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: publish stage escaped its exact same-volume namespace" >&2
      return 1 ;;
  esac
  if [[ "$PUBLISH_PREVIOUS_SET" != "$PUBLISH_STAGE_ROOT/previous-story_demo" \
      || "$PUBLISH_FAILED_SET" != "$PUBLISH_STAGE_ROOT/failed-new-story_demo" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: publish rollback paths drifted" >&2
    return 1
  fi
  if [[ ! -s "$PUBLISH_PREVIOUS_STATE" || ! -s "$PUBLISH_NEW_STATE" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: publish rollback inventories are unavailable" >&2
    return 1
  fi

  if [[ "$PUBLISH_PREVIOUS_EXISTED" == "1" ]]; then
    if [[ -e "$PUBLISH_PREVIOUS_SET" || -L "$PUBLISH_PREVIOUS_SET" ]]; then
      if [[ -e "$OUTPUT_DIR" || -L "$OUTPUT_DIR" ]]; then
        if [[ -e "$PUBLISH_FAILED_SET" || -L "$PUBLISH_FAILED_SET" ]]; then
          echo "STORY_DEMO_BUILD_FAIL: failed-new publish quarantine already exists" >&2
          return 1
        fi
        capture_exact_state "$OUTPUT_DIR" "$PUBLISH_VERIFY_STATE" || rollback_status=$?
        if [[ $rollback_status -ne 0 ]]; then
          return 1
        fi
        if exact_states_match "$PUBLISH_NEW_STATE" "$PUBLISH_VERIFY_STATE"; then
          :
        else
          echo "STORY_DEMO_BUILD_FAIL: refusing to quarantine an unrecognized final publish set" >&2
          return 1
        fi
        if mv "$OUTPUT_DIR" "$PUBLISH_FAILED_SET"; then
          :
        else
          echo "STORY_DEMO_BUILD_FAIL: could not quarantine the failed new publish set" >&2
          return 1
        fi
        capture_exact_state "$PUBLISH_FAILED_SET" "$PUBLISH_VERIFY_STATE" || rollback_status=$?
        if [[ $rollback_status -ne 0 ]]; then
          return 1
        fi
        if exact_states_match "$PUBLISH_NEW_STATE" "$PUBLISH_VERIFY_STATE"; then
          :
        else
          return 1
        fi
      fi
      if [[ -e "$OUTPUT_DIR" || -L "$OUTPUT_DIR" ]]; then
        echo "STORY_DEMO_BUILD_FAIL: final publish path was recreated before rollback" >&2
        return 1
      fi
      if mv "$PUBLISH_PREVIOUS_SET" "$OUTPUT_DIR"; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: could not atomically restore the previous publish set" >&2
        return 1
      fi
    else
      if [[ ! -e "$OUTPUT_DIR" && ! -L "$OUTPUT_DIR" ]]; then
        echo "STORY_DEMO_BUILD_FAIL: both previous and final publish sets are missing" >&2
        return 1
      fi
      capture_exact_state "$OUTPUT_DIR" "$PUBLISH_VERIFY_STATE" || rollback_status=$?
      if [[ $rollback_status -ne 0 ]]; then
        return 1
      fi
      if exact_states_are_equal "$PUBLISH_PREVIOUS_STATE" "$PUBLISH_VERIFY_STATE"; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: previous publish set is unavailable for rollback" >&2
        return 1
      fi
    fi
  else
    if [[ -e "$PUBLISH_PREVIOUS_SET" || -L "$PUBLISH_PREVIOUS_SET" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: unexpected previous publish set exists" >&2
      return 1
    fi
    if [[ -e "$OUTPUT_DIR" || -L "$OUTPUT_DIR" ]]; then
      if [[ -e "$PUBLISH_FAILED_SET" || -L "$PUBLISH_FAILED_SET" ]]; then
        echo "STORY_DEMO_BUILD_FAIL: failed-new publish quarantine already exists" >&2
        return 1
      fi
      capture_exact_state "$OUTPUT_DIR" "$PUBLISH_VERIFY_STATE" || rollback_status=$?
      if [[ $rollback_status -ne 0 ]]; then
        return 1
      fi
      if exact_states_match "$PUBLISH_NEW_STATE" "$PUBLISH_VERIFY_STATE"; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: refusing to remove an unrecognized final publish set" >&2
        return 1
      fi
      if mv "$OUTPUT_DIR" "$PUBLISH_FAILED_SET"; then
        :
      else
        echo "STORY_DEMO_BUILD_FAIL: could not quarantine the failed new publish set" >&2
        return 1
      fi
      capture_exact_state "$PUBLISH_FAILED_SET" "$PUBLISH_VERIFY_STATE" || rollback_status=$?
      if [[ $rollback_status -ne 0 ]]; then
        return 1
      fi
      if exact_states_match "$PUBLISH_NEW_STATE" "$PUBLISH_VERIFY_STATE"; then
        :
      else
        return 1
      fi
    fi
  fi

  capture_exact_state "$OUTPUT_DIR" "$PUBLISH_VERIFY_STATE" || rollback_status=$?
  if [[ $rollback_status -ne 0 ]]; then
    return 1
  fi
  if exact_states_match "$PUBLISH_PREVIOUS_STATE" "$PUBLISH_VERIFY_STATE"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: previous publish set digest was not restored" >&2
    return 1
  fi
  PUBLISH_ROLLBACK_COMPLETE=1
  return 0
}

cleanup_story_demo_publish_stage() {
  local stage_cleanup_status=0
  if [[ -z "$PUBLISH_STAGE_ROOT" ]]; then
    return 0
  fi
  case "$PUBLISH_STAGE_ROOT" in
    "$PROJECT_DIR"/build/.story_demo-publish.*) ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: refusing cleanup of an unexpected publish stage" >&2
      return 1 ;;
  esac
  if [[ "$PUBLISH_SWAP_STARTED" == "1" \
      && "$PUBLISH_COMMITTED" != "1" \
      && "$PUBLISH_ROLLBACK_COMPLETE" != "1" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: refusing publish-stage cleanup before verified rollback" >&2
    return 1
  fi
  if [[ -L "$PUBLISH_STAGE_ROOT" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: refusing cleanup of a replaced publish-stage symlink" >&2
    return 1
  fi
  if [[ -e "$PUBLISH_STAGE_ROOT" ]]; then
    rm -rf "$PUBLISH_STAGE_ROOT" || stage_cleanup_status=$?
    if [[ $stage_cleanup_status -ne 0 \
        || -e "$PUBLISH_STAGE_ROOT" \
        || -L "$PUBLISH_STAGE_ROOT" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: could not remove the resolved publish stage" >&2
      return 1
    fi
  fi
  PUBLISH_STAGE_ROOT=""
  return 0
}

cleanup_empty_pre_snapshot_recovery() {
  local empty_cleanup_status=0
  if [[ "$STORY_DEMO_USER_DATA_SNAPSHOT_READY" != "0" \
      || "$STORY_DEMO_USER_DATA_MUTATION_STARTED" != "0" ]]; then
    return 0
  fi
  for empty_root in \
      "$STORY_DEMO_QUARANTINE_ROOT" \
      "$STORY_DEMO_ORIGINAL_HOLD_ROOT" \
      "$STORY_DEMO_RECOVERY_ROOT"; do
    case "$empty_root" in
      "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.quarantine.*|\
      "$APPLICATION_SUPPORT_DIR"/.GangnamDream_StoryDemo_v1.original-hold.*|\
      "$TEMP_PARENT"/gangnamdream-story_demo-recovery.*) ;;
      *)
        echo "STORY_DEMO_BUILD_FAIL: refusing cleanup of unexpected pre-snapshot recovery root" >&2
        return 1 ;;
    esac
    if [[ -L "$empty_root" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: pre-snapshot recovery root was replaced by a symlink" >&2
      return 1
    fi
    if [[ -d "$empty_root" ]]; then
      rmdir "$empty_root" || empty_cleanup_status=$?
      if [[ $empty_cleanup_status -ne 0 || -e "$empty_root" || -L "$empty_root" ]]; then
        echo "STORY_DEMO_RECOVERY_PATH preserved_nonempty=$empty_root" >&2
        return 1
      fi
    fi
  done
  return 0
}

cleanup() {
  local exit_code=$?
  local restore_status=0
  local rollback_status=0
  local cleanup_status=0
  local release_status=0
  local termination_status=0
  trap - EXIT
  trap '' INT TERM
  set +e
  if [[ "$STORY_DEMO_BUILD_LOCK_ACQUIRED" == "1" ]]; then
    if [[ -n "${NATIVE_PID:-}" ]]; then
      terminate_native_process_bounded "$NATIVE_PID" "cleanup launcher"
      termination_status=$?
      if [[ $termination_status -eq 0 ]]; then
        NATIVE_PID=""
      else
        echo "STORY_DEMO_BUILD_FAIL: launcher termination failed before recovery" >&2
        restore_status=1
        exit_code=1
      fi
    fi
    if [[ $termination_status -eq 0 ]]; then
      restore_candidate_user_data
      restore_status=$?
    fi
    if [[ $restore_status -ne 0 ]]; then
      echo "STORY_DEMO_BUILD_FAIL: could not restore the pre-build candidate user-data namespace" >&2
      report_recovery_paths
      exit_code=1
    fi
    rollback_story_demo_publish
    rollback_status=$?
    if [[ $rollback_status -ne 0 ]]; then
      echo "STORY_DEMO_BUILD_FAIL: could not restore the pre-build publish set" >&2
      report_recovery_paths
      exit_code=1
    fi
    if [[ $termination_status -eq 0 ]]; then
      for qa_cleanup_path in \
          "$STORY_DEMO_QA_USER_DATA_DIR" \
          "$REAL_FLOW_CLEAN_QA_DIR" \
          "$REAL_FLOW_RESTITUTION_QA_DIR" \
          "$REAL_FLOW_ESCALATION_QA_DIR"; do
        remove_runtime_qa_dir "$qa_cleanup_path"
        cleanup_status=$?
        if [[ $cleanup_status -ne 0 ]]; then
          exit_code=1
        fi
      done
    fi
    if [[ "$BUILD_SUCCEEDED" != "1" && "$STORY_DEMO_USER_DATA_SNAPSHOT_READY" == "1" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: recovery evidence preserved because the build did not complete" >&2
      report_recovery_paths
    fi
    if [[ $restore_status -eq 0 && $rollback_status -eq 0 ]]; then
      cleanup_story_demo_publish_stage
      cleanup_status=$?
      if [[ $cleanup_status -ne 0 ]]; then
        report_recovery_paths
        exit_code=1
      fi
    fi
  else
    if [[ "$STORY_DEMO_USER_DATA_SNAPSHOT_READY" != "0" \
        || "$STORY_DEMO_USER_DATA_MUTATION_STARTED" != "0" \
        || "$PUBLISH_SWAP_STARTED" != "0" ]]; then
      echo "STORY_DEMO_BUILD_FAIL: unlocked process reached protected build state" >&2
      restore_status=1
      rollback_status=1
      exit_code=1
    fi
  fi
  if [[ "$STORY_DEMO_USER_DATA_SNAPSHOT_READY" == "0" ]]; then
    cleanup_empty_pre_snapshot_recovery
    cleanup_status=$?
    if [[ $cleanup_status -ne 0 ]]; then
      exit_code=1
    fi
  fi
  case "$WORK_DIR" in
    "$TEMP_PARENT"/gangnamdream-story_demo.*)
      if [[ $restore_status -eq 0 && $rollback_status -eq 0 ]]; then
        cleanup_status=0
        rm -rf "$WORK_DIR" || cleanup_status=$?
        if [[ $cleanup_status -ne 0 || -e "$WORK_DIR" || -L "$WORK_DIR" ]]; then
          echo "STORY_DEMO_BUILD_FAIL: could not remove the staging directory" >&2
          exit_code=1
        fi
      else
        echo "STORY_DEMO_RECOVERY_PATH staging=$WORK_DIR" >&2
      fi ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: refusing staging cleanup outside its exact namespace" >&2
      exit_code=1 ;;
  esac
  if [[ "$STORY_DEMO_BUILD_LOCK_ACQUIRED" == "1" ]]; then
    if [[ $restore_status -eq 0 && $rollback_status -eq 0 ]]; then
      release_story_demo_build_lock
      release_status=$?
      if [[ $release_status -ne 0 ]]; then
        echo "STORY_DEMO_BUILD_FAIL: exclusive build lock preserved" >&2
        report_recovery_paths
        exit_code=1
      fi
    else
      echo "STORY_DEMO_BUILD_FAIL: exclusive build lock preserved after recovery failure" >&2
      report_recovery_paths
    fi
  fi
  set -e
  exit "$exit_code"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

lock_acquire_status=0
trap '' INT TERM
acquire_story_demo_build_lock || lock_acquire_status=$?
trap 'exit 130' INT
trap 'exit 143' TERM
if [[ $lock_acquire_status -ne 0 ]]; then
  exit "$lock_acquire_status"
fi

# Hash only player data/config JSON under Godot's user root; engine logs and
# shader caches are not saves. Prior candidates and demo artifacts are hashed
# as complete file/symlink inventories.
capture_protected() {
  local output_path="$1"
  local capture_status=0
  local archive_guard_json=""
  if ! archive_guard_json="$(python3 "$SCRIPT_DIR/story_demo_package_audit.py" \
    --archive-state --source-revision "$SOURCE_COMMIT")"; then
    echo "STORY_DEMO_BUILD_FAIL: could not validate protected BUILD 2026.08.24.2 state" >&2
    return 1
  fi
  python3 - "$output_path" "$PROJECT_DIR" \
    "$HOME/Library/Application Support/Godot/app_userdata" \
    "$HOME/Library/Application Support/GangnamDream_ORDER103_M01M06_v1" \
    "$HOME/Library/Application Support/GangnamDream_ORDER124_StoryChoice_v1" \
    "$STORY_DEMO_USER_DATA_DIR" "$archive_guard_json" <<'PY' || capture_status=$?
from __future__ import annotations
import hashlib, json, os, sys
from pathlib import Path

output, root, user_root, order103_user, order124_user, story_demo_user = map(Path, sys.argv[1:7])
archive_guard_state = json.loads(sys.argv[7])

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
    ("retail_v2_user_save_files", user_root, True, "GangnamDream_StoryDemo_v1", "~/Library/Application Support/Godot/app_userdata"),
    ("order103_candidate_user_dir", order103_user, False, "", "~/Library/Application Support/GangnamDream_ORDER103_M01M06_v1"),
    ("order124_candidate_user_dir", order124_user, False, "", "~/Library/Application Support/GangnamDream_ORDER124_StoryChoice_v1"),
    ("story_demo_candidate_user_dir", story_demo_user, False, "", "~/Library/Application Support/GangnamDream_StoryDemo_v1"),
    ("build_order103", root / "build/order103", False, "", "build/order103"),
    ("build_demo", root / "build/demo", False, "", "build/demo"),
    ("build_playtest", root / "build/playtest", False, "", "build/playtest"),
]
payload = []
for label, path, save_only, exclude_top, manifest_path in specs:
    payload.append({"label": label, "path": manifest_path, "state": state(path, save_only, exclude_top)})
payload.append({
    "label": "story_demo_build2_archive",
    "path": "build/order124/archive/2026.08.24.2",
    "state": archive_guard_state,
})
output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
  if [[ $capture_status -ne 0 || ! -s "$output_path" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: could not capture protected inventory $output_path" >&2
    return 1
  fi
  return 0
}

case "$STORY_DEMO_USER_DATA_DIR" in
  "$HOME/Library/Application Support/$CUSTOM_USER_DIR") ;;
  *)
    echo "STORY_DEMO_BUILD_FAIL: candidate user-data target escaped its exact namespace" >&2
    exit 1
    ;;
esac
if [[ -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: candidate user-data namespace must not be a symlink" >&2
  exit 1
fi
if [[ -e "$STORY_DEMO_USER_DATA_DIR" && ! -d "$STORY_DEMO_USER_DATA_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: candidate user-data namespace must be a directory" >&2
  exit 1
fi
capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_ORIGINAL_STATE"
if [[ -e "$STORY_DEMO_USER_DATA_DIR" ]]; then
  if ditto "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_USER_DATA_BACKUP"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not create the separate recovery backup" >&2
    exit 1
  fi
  capture_exact_state "$STORY_DEMO_USER_DATA_BACKUP" "$STORY_DEMO_BACKUP_STATE"
  exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_BACKUP_STATE"
  STORY_DEMO_USER_DATA_EXISTED=1
fi
capture_protected "$PROTECTED_BEFORE"
STORY_DEMO_USER_DATA_SNAPSHOT_READY=1
STORY_DEMO_USER_DATA_MUTATION_STARTED=1
if [[ "$STORY_DEMO_USER_DATA_EXISTED" == "1" ]]; then
  if mv "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_ORIGINAL_HOLD"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not atomically move original user data into its hold" >&2
    exit 1
  fi
  capture_exact_state "$STORY_DEMO_ORIGINAL_HOLD" "$STORY_DEMO_VERIFY_STATE"
  exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_VERIFY_STATE"
fi
capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_CURRENT_STATE"
fresh_namespace_status=0
python3 - "$STORY_DEMO_CURRENT_STATE" <<'PY' || fresh_namespace_status=$?
import json, pathlib, sys
state = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
if state.get("exists") is not False:
    raise SystemExit("fresh namespace still exists")
PY
if [[ $fresh_namespace_status -ne 0 ]]; then
  echo "STORY_DEMO_BUILD_FAIL: fresh package namespace was not isolated from the original" >&2
  exit 1
fi
RESUME_SAVE_BACKUP="$STORY_DEMO_USER_DATA_BACKUP/$CANDIDATE_SAVE_NAME"
RESUME_APPLICABLE=0
if [[ -L "$RESUME_SAVE_BACKUP" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: existing candidate save must not be a symlink" >&2
  exit 1
elif [[ -f "$RESUME_SAVE_BACKUP" ]]; then
  python3 - "$RESUME_SAVE_BACKUP" "$RESUME_INPUT_STATE" "$PROFILE" <<'PY'
from __future__ import annotations
import hashlib, json, sys
from pathlib import Path

save_path, output_path = map(Path, sys.argv[1:3])
profile = sys.argv[3]
raw = save_path.read_bytes()
try:
    data = json.loads(raw)
except json.JSONDecodeError as exc:
    raise SystemExit(f"STORY_DEMO_BUILD_FAIL: existing candidate save is invalid JSON: {exc}")
if not isinstance(data, dict):
    raise SystemExit("STORY_DEMO_BUILD_FAIL: existing candidate save root must be an object")
if int(data.get("schema_version", 0)) != 1 or data.get("profile") != profile:
    raise SystemExit("STORY_DEMO_BUILD_FAIL: existing candidate save identity drifted")
if not isinstance(data.get("game_state"), dict):
    raise SystemExit("STORY_DEMO_BUILD_FAIL: existing candidate save lacks game_state")

def exact_int(key: str) -> int:
    value = data.get(key)
    if isinstance(value, bool) or not isinstance(value, (int, float)) or int(value) != value:
        raise SystemExit(f"STORY_DEMO_BUILD_FAIL: existing candidate save {key} is not an integer")
    return int(value)

month = exact_int("current_month")
weeks = exact_int("elapsed_weeks")
settlements = exact_int("monthly_pressure_count")
choices = data.get("choices")
phase = str(data.get("phase", ""))
if month < 1 or month > 7 or weeks < 0 or settlements < 0:
    raise SystemExit("STORY_DEMO_BUILD_FAIL: existing candidate save progress is out of range")
if not isinstance(choices, list) or phase not in {"story", "transition", "recap"}:
    raise SystemExit("STORY_DEMO_BUILD_FAIL: existing candidate save progress shape drifted")
payload = {
    "sha256": hashlib.sha256(raw).hexdigest(),
    "size_bytes": len(raw),
    "schema_version": 1,
    "profile": profile,
    "month": month,
    "weeks": weeks,
    "settlements": settlements,
    "choices": len(choices),
    "phase": phase,
    "screen": "recap" if phase == "recap" else "transition",
}
output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
  RESUME_APPLICABLE=1
else
  if printf '{}\n' > "$RESUME_INPUT_STATE" && [[ -s "$RESUME_INPUT_STATE" ]]; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not record not-applicable resume state" >&2
    exit 1
  fi
fi
if mkdir -p "$STAGE_PROJECT" "$PACKAGE_STAGE" "$VERIFY_STAGE" \
    && [[ -d "$STAGE_PROJECT" && -d "$PACKAGE_STAGE" && -d "$VERIFY_STAGE" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create staging directories" >&2
  exit 1
fi
if git -C "$PROJECT_DIR" archive --format=tar "$SOURCE_COMMIT" \
    | tar -xf - -C "$STAGE_PROJECT"; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not materialize the fixed source archive" >&2
  exit 1
fi

for required in \
  project.godot \
  export_presets.cfg \
  playtests/order124/StoryChoiceM1M6Playtest.gd \
  playtests/order124/StoryChoiceM1M6Playtest.gd.uid \
  playtests/order124/StoryChoiceM1M6Playtest.tscn \
  scenes/StoryMode.gd \
  autoloads/FontKit.gd \
  assets/fonts/NotoSansSC-Variable.ttf \
  assets/fonts/NotoSansSC-Variable.ttf.import \
  assets/fonts/NotoSansTC-Variable.ttf \
  assets/fonts/NotoSansTC-Variable.ttf.import \
  assets/fonts/OFL-NotoSansSC.txt \
  assets/fonts/OFL-NotoSansTC.txt \
  assets/fonts/FONT_LICENSE_LEDGER.md \
  content/meta/third_party_notices.json \
  content/events_ja/story_demo_events.json \
  content/events_zh-CN/story_demo_events.json \
  content/events_zh-TW/story_demo_events.json \
  locale/ui_ja.json \
  locale/ui_zh-CN.json \
  locale/ui_zh-TW.json \
  locale/catalog_ja.json \
  locale/catalog_zh-CN.json \
  locale/catalog_zh-TW.json \
  tools/StoryDemoFourLanguageCheck.gd \
  tools/StoryDemoFourLanguageCheck.gd.uid \
  tools/StoryDemoFourLanguageCheck.tscn \
  tools/FontRoutingCheck.gd \
  tools/FontRoutingCheck.gd.uid \
  tools/FontRoutingCheck.tscn \
  tools/I18nInfrastructureCheck.gd \
  tools/I18nInfrastructureCheck.gd.uid \
  tools/I18nInfrastructureCheck.tscn \
  tools/third_party_notice_audit.py \
  tools/story_demo_localization_audit.py \
  tools/story_demo_density_audit.py \
  tools/fixtures/story_demo_density_contract.json \
  docs/human_gates.json \
  tools/evidence/order124_build_2026.08.24.2/MANIFEST.json \
  tools/evidence/order124_build_2026.08.24.2/MANIFEST.sha256 \
  tools/evidence/order124_build_2026.08.24.2/LOSS_RECEIPT.json \
  tools/audit_scope.json \
  tools/build_story_demo_macos.sh \
  tools/story_demo_package_audit.py; do
  if [[ ! -f "$STAGE_PROJECT/$required" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: fixed source commit lacks $required" >&2
    exit 1
  fi
done
python3 "$STAGE_PROJECT/tools/story_demo_package_audit.py" --self-test
python3 "$STAGE_PROJECT/tools/story_demo_localization_audit.py" --self-test
python3 "$STAGE_PROJECT/tools/story_demo_localization_audit.py"
python3 "$STAGE_PROJECT/tools/third_party_notice_audit.py" --self-test
python3 "$STAGE_PROJECT/tools/third_party_notice_audit.py"
SOURCE_GIT_DIR="$(git -C "$PROJECT_DIR" rev-parse --absolute-git-dir)"
density_status=0
env GIT_DIR="$SOURCE_GIT_DIR" GIT_WORK_TREE="$STAGE_PROJECT" \
  python3 "$STAGE_PROJECT/tools/story_demo_density_audit.py" --self-test \
  >"$DENSITY_SELF_TEST_LOG" 2>&1 || density_status=$?
if [[ $density_status -ne 0 \
    || "$(grep -Fxc "$DENSITY_SELF_TEST_MARKER" "$DENSITY_SELF_TEST_LOG" || true)" != "1" \
    || "$(wc -l < "$DENSITY_SELF_TEST_LOG" | tr -d ' ')" != "1" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: exact density self-test evidence drifted" >&2
  sed -n '1,240p' "$DENSITY_SELF_TEST_LOG" >&2
  exit 1
fi
DENSITY_SELF_TEST_ACTUAL_MARKER="$(grep -Fx "$DENSITY_SELF_TEST_MARKER" "$DENSITY_SELF_TEST_LOG")"
density_status=0
env GIT_DIR="$SOURCE_GIT_DIR" GIT_WORK_TREE="$STAGE_PROJECT" \
  python3 "$STAGE_PROJECT/tools/story_demo_density_audit.py" \
  >"$DENSITY_LOG" 2>&1 || density_status=$?
if [[ $density_status -ne 0 \
    || "$(grep -Fxc "$DENSITY_MARKER" "$DENSITY_LOG" || true)" != "1" \
    || "$(grep -Fxc "$DENSITY_HUMAN_GATE_MARKER" "$DENSITY_LOG" || true)" != "1" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: exact density source evidence drifted" >&2
  sed -n '1,320p' "$DENSITY_LOG" >&2
  exit 1
fi
DENSITY_ACTUAL_MARKER="$(grep -Fx "$DENSITY_MARKER" "$DENSITY_LOG")"
DENSITY_ACTUAL_HUMAN_GATE_MARKER="$(grep -Fx "$DENSITY_HUMAN_GATE_MARKER" "$DENSITY_LOG")"

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
        raise SystemExit(f"STORY_DEMO_BUILD_FAIL: missing section [{section}]")
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
    ("config/name", '"GangnamDream-StoryDemo"'),
    ("run/main_scene", '"res://playtests/order124/StoryChoiceM1M6Playtest.tscn"'),
    ("config/use_custom_user_dir", "true"),
    ("config/custom_user_dir_name", '"GangnamDream_StoryDemo_v1"'),
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
    raise SystemExit("STORY_DEMO_BUILD_FAIL: product macOS export preset not found")
for key, value in (
    ("name", '"Story Demo macOS"'),
    ("export_path", '"build/story_demo/macos/GangnamDream-StoryDemo.zip"'),
):
    presets = set_section_value(presets, f"preset.{mac_number}", key, value)
for key, value in (
	("application/bundle_identifier", '"dev.junheelee.gangnamdream.storydemo"'),
	("application/short_version", '"0.1.0"'),
	("application/version", '"2026.8.31"'),
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
    echo "STORY_DEMO_BUILD_FAIL: Godot gate failed (exit=$exit_code, expected=$marker)" >&2
    sed -n '1,320p' "$log_path" >&2
    exit 1
  fi
}

if ! "$GODOT" --headless --path "$STAGE_PROJECT" --import >"$IMPORT_LOG" 2>&1; then
  echo "STORY_DEMO_BUILD_FAIL: full fixed-source import failed" >&2
  sed -n '1,320p' "$IMPORT_LOG" >&2
  exit 1
fi
if grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$IMPORT_LOG"; then
  echo "STORY_DEMO_BUILD_FAIL: fixed-source import contains engine/script errors" >&2
  sed -n '1,320p' "$IMPORT_LOG" >&2
  exit 1
fi

remove_runtime_qa_dir "$STORY_DEMO_QA_USER_DATA_DIR"
run_godot_exact_gate "$TARGET_LOG" "$TARGET_MARKER" \
  env STORY_DEMO_ALLOW_ISOLATED_QA=1 \
  STORY_DEMO_QA_BOOTSTRAP_NAME=GangnamDream_StoryDemo_RuntimeQA_build \
  "$GODOT" --headless --path "$STAGE_PROJECT" --quit-after 3600 "$CHECK_SCENE"
remove_runtime_qa_dir "$STORY_DEMO_QA_USER_DATA_DIR"
run_godot_exact_gate "$FONT_LOG" \
  "FONT_ROUTING_CHECK_OK ko_en=Pretendard ja=NotoSansJP zh_cn=NotoSansSC zh_tw=NotoSansTC weights=400,600,700 emoji=last" \
  "$GODOT" --headless --path "$STAGE_PROJECT" res://tools/FontRoutingCheck.tscn
run_godot_exact_gate "$I18N_LOG" \
  "I18N_INFRASTRUCTURE_CHECK_OK targets=3 ui_fallback=en content_fallback=en" \
  "$GODOT" --headless --path "$STAGE_PROJECT" res://tools/I18nInfrastructureCheck.tscn

if ! "$GODOT" --headless --path "$STAGE_PROJECT" --export-release \
    "$PRESET_NAME" "$RAW_ZIP" >"$EXPORT_LOG" 2>&1; then
  echo "STORY_DEMO_BUILD_FAIL: macOS release export failed" >&2
  sed -n '1,360p' "$EXPORT_LOG" >&2
  exit 1
fi
if [[ ! -s "$RAW_ZIP" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: macOS export did not create a ZIP" >&2
  exit 1
fi

if ditto -x -k "$RAW_ZIP" "$PACKAGE_STAGE"; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not extract the raw macOS export" >&2
  exit 1
fi
APP_COUNT="$(find "$PACKAGE_STAGE" -maxdepth 1 -type d -name '*.app' | wc -l | tr -d ' ')"
if [[ "$APP_COUNT" != "1" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: exported ZIP must contain exactly one top-level app" >&2
  exit 1
fi
SOURCE_APP="$(find "$PACKAGE_STAGE" -maxdepth 1 -type d -name '*.app' -print -quit)"
INFO_PLIST="$SOURCE_APP/Contents/Info.plist"
OLD_EXECUTABLE="$(plutil -extract CFBundleExecutable raw "$INFO_PLIST")"
OLD_LAUNCHER="$SOURCE_APP/Contents/MacOS/$OLD_EXECUTABLE"
OLD_PCK="$SOURCE_APP/Contents/Resources/$OLD_EXECUTABLE.pck"
if [[ ! -f "$OLD_LAUNCHER" || ! -f "$OLD_PCK" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: exported app launcher or resource pack is missing" >&2
  exit 1
fi
if [[ "$OLD_EXECUTABLE" != "$APP_STEM" ]]; then
  if mv "$OLD_LAUNCHER" "$SOURCE_APP/Contents/MacOS/$APP_STEM"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not rename the native launcher" >&2
    exit 1
  fi
  if mv "$OLD_PCK" "$SOURCE_APP/Contents/Resources/$APP_STEM.pck"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not rename the resource pack" >&2
    exit 1
  fi
fi
plutil -replace CFBundleExecutable -string "$APP_STEM" "$INFO_PLIST"
plutil -replace CFBundleName -string "$APP_STEM" "$INFO_PLIST"
plutil -replace CFBundleDisplayName -string "$APP_STEM" "$INFO_PLIST" 2>/dev/null \
  || plutil -insert CFBundleDisplayName -string "$APP_STEM" "$INFO_PLIST"
FINAL_APP="$PACKAGE_STAGE/$APP_STEM.app"
if [[ "$SOURCE_APP" != "$FINAL_APP" ]]; then
  if mv "$SOURCE_APP" "$FINAL_APP"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not rename the exported app" >&2
    exit 1
  fi
fi
codesign --force --deep --sign - --options runtime "$FINAL_APP"
codesign --verify --deep --strict "$FINAL_APP"
if ditto -c -k --sequesterRsrc --keepParent "$FINAL_APP" "$FINALIZED_ZIP" \
    && [[ -s "$FINALIZED_ZIP" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create the finalized ZIP" >&2
  exit 1
fi
if ditto -x -k "$FINALIZED_ZIP" "$VERIFY_STAGE"; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not extract the finalized ZIP for verification" >&2
  exit 1
fi
VERIFIED_APP="$VERIFY_STAGE/$APP_STEM.app"
codesign --verify --deep --strict "$VERIFIED_APP"
LAUNCHER="$VERIFIED_APP/Contents/MacOS/$APP_STEM"
PCK="$VERIFIED_APP/Contents/Resources/$APP_STEM.pck"
if [[ ! -x "$LAUNCHER" || ! -f "$PCK" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: finalized native launcher or PCK is missing" >&2
  exit 1
fi

# Finder-equivalent no-argument launch: only an environment probe is supplied.
STORY_DEMO_NATIVE_PROBE_PATH="$NATIVE_PROBE" "$LAUNCHER" >"$NATIVE_LOG" 2>&1 &
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
  echo "STORY_DEMO_BUILD_FAIL: native no-argument entry marker was not observed" >&2
  sed -n '1,280p' "$NATIVE_LOG" >&2
  exit 1
fi
NATIVE_MARKER="$(grep -E "^${NATIVE_MARKER_PREFIX}([[:space:]]|$)" "$NATIVE_PROBE" | tail -n 1)"
for identity_token in \
  "profile=$PROFILE" \
  "build=$BUILD_ID" \
  "scene=$ENTRY_SCENE" \
  "custom_user_dir=$CUSTOM_USER_DIR" \
  "language=en" \
  "path="; do
  if [[ "$NATIVE_MARKER" != *"$identity_token"* ]]; then
    echo "STORY_DEMO_BUILD_FAIL: native marker lacks identity token $identity_token" >&2
    exit 1
  fi
done
NATIVE_USER_DATA_DIR="${NATIVE_MARKER##* path=}"
case "$NATIVE_USER_DATA_DIR" in
  */"$CUSTOM_USER_DIR") ;;
  *)
    echo "STORY_DEMO_BUILD_FAIL: native marker resolved outside the isolated custom user dir" >&2
    exit 1
    ;;
esac
terminate_native_process_bounded "$NATIVE_PID" "native no-argument probe"
NATIVE_PID=""
if grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$NATIVE_LOG"; then
  echo "STORY_DEMO_BUILD_FAIL: native no-argument log contains engine/script errors" >&2
  sed -n '1,280p' "$NATIVE_LOG" >&2
  exit 1
fi

run_godot_prefix_gate() {
  local log_path="$1"
  local marker_prefix="$2"
  shift 2
  local exit_code=0
  local timed_out=0
  "$@" >"$log_path" 2>&1 &
  NATIVE_PID=$!
  for _smoke_tick in $(seq 1 "$SMOKE_TIMEOUT_TICKS"); do
    if ! kill -0 "$NATIVE_PID" >/dev/null 2>&1; then
      break
    fi
    sleep 0.25
  done
  if kill -0 "$NATIVE_PID" >/dev/null 2>&1; then
    timed_out=1
    kill -TERM "$NATIVE_PID" >/dev/null 2>&1 || true
    for _grace_tick in $(seq 1 20); do
      if ! kill -0 "$NATIVE_PID" >/dev/null 2>&1; then
        break
      fi
      sleep 0.25
    done
    if kill -0 "$NATIVE_PID" >/dev/null 2>&1; then
      kill -KILL "$NATIVE_PID" >/dev/null 2>&1 || true
    fi
  fi
  if wait "$NATIVE_PID"; then
    exit_code=0
  else
    exit_code=$?
  fi
  NATIVE_PID=""
  if [[ $timed_out -eq 1 ]]; then
    exit_code=124
  fi
  if [[ $exit_code -ne 0 ]] \
      || grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$log_path" \
      || ! grep -Eq "^${marker_prefix}([[:space:]]|$)" "$log_path"; then
    echo "STORY_DEMO_BUILD_FAIL: package smoke failed (exit=$exit_code, prefix=$marker_prefix)" >&2
    sed -n '1,320p' "$log_path" >&2
    exit 1
  fi
}

require_marker_tokens() {
  local marker="$1"
  local evidence_label="$2"
  shift 2
  local required_token
  for required_token in "$@"; do
    case " $marker " in
      *" $required_token "*) ;;
      *)
        echo "STORY_DEMO_BUILD_FAIL: $evidence_label marker lacks $required_token" >&2
        return 1 ;;
    esac
  done
  return 0
}

require_exact_marker_tokens() {
  local marker="$1"
  local evidence_label="$2"
  shift 2
  local marker_status=0
  python3 - "$marker" "$REAL_FLOW_MARKER_PREFIX" "$@" <<'PY' || marker_status=$?
import sys

marker, prefix, *expected_parts = sys.argv[1:]
parts = marker.split()
if not parts or parts[0] != prefix:
    raise SystemExit(1)
actual = {}
for part in parts[1:]:
    if "=" not in part:
        raise SystemExit(1)
    key, value = part.split("=", 1)
    if not key or not value or key in actual:
        raise SystemExit(1)
    actual[key] = value
expected = {}
for part in expected_parts:
    if "=" not in part:
        raise SystemExit(1)
    key, value = part.split("=", 1)
    if not key or not value or key in expected:
        raise SystemExit(1)
    expected[key] = value
raise SystemExit(0 if actual == expected else 1)
PY
  if [[ $marker_status -ne 0 ]]; then
    echo "STORY_DEMO_BUILD_FAIL: $evidence_label marker token contract drifted" >&2
    return 1
  fi
  return 0
}

run_godot_prefix_gate "$KO_LOG" "$SMOKE_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  -- --qa=story-demo --story-demo-smoke --story-demo-language=ko
# The producer smoke exits before this launcher starts. This is an unconditional
# cold-process resume of the exact M02 autosave created above, not an in-process
# continue and not the optional pre-build candidate-save check below.
run_godot_prefix_gate "$COLD_RESTART_RESUME_LOG" "$RESUME_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  -- --qa=story-demo --story-demo-resume-smoke --story-demo-language=ko
COLD_RESTART_RESUME_MARKER="$(grep -E "^${RESUME_MARKER_PREFIX}([[:space:]]|$)" \
  "$COLD_RESTART_RESUME_LOG" | tail -n 1)"
require_marker_tokens "$COLD_RESTART_RESUME_MARKER" "cold-restart resume" \
  "build=$BUILD_ID" \
  "month=2" \
  "weeks=4" \
  "settlements=1" \
  "choices=1" \
  "phase=transition" \
  "screen=transition" \
  "overlay=clear" \
  "input=clear"
run_godot_prefix_gate "$EN_LOG" "$SMOKE_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 960x600 \
  -- --qa=story-demo --story-demo-smoke --story-demo-language=en
run_godot_prefix_gate "$JA_LOG" "$SMOKE_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  -- --qa=story-demo --story-demo-smoke --story-demo-language=ja
run_godot_prefix_gate "$ZH_CN_LOG" "$SMOKE_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 960x600 \
  -- --qa=story-demo --story-demo-smoke --story-demo-language=zh-CN
run_godot_prefix_gate "$ZH_TW_LOG" "$SMOKE_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  -- --qa=story-demo --story-demo-smoke --story-demo-language=zh-TW
KO_MARKER="$(grep -E "^${SMOKE_MARKER_PREFIX}([[:space:]]|$)" "$KO_LOG" | tail -n 1)"
EN_MARKER="$(grep -E "^${SMOKE_MARKER_PREFIX}([[:space:]]|$)" "$EN_LOG" | tail -n 1)"
JA_MARKER="$(grep -E "^${SMOKE_MARKER_PREFIX}([[:space:]]|$)" "$JA_LOG" | tail -n 1)"
ZH_CN_MARKER="$(grep -E "^${SMOKE_MARKER_PREFIX}([[:space:]]|$)" "$ZH_CN_LOG" | tail -n 1)"
ZH_TW_MARKER="$(grep -E "^${SMOKE_MARKER_PREFIX}([[:space:]]|$)" "$ZH_TW_LOG" | tail -n 1)"

remove_runtime_qa_dir "$REAL_FLOW_CLEAN_QA_DIR"
remove_runtime_qa_dir "$REAL_FLOW_RESTITUTION_QA_DIR"
remove_runtime_qa_dir "$REAL_FLOW_ESCALATION_QA_DIR"
# These three accelerated real StoryMode runs compress six months into seconds.
# A fixed simulation delta keeps timed scene transitions inside the frame guard,
# while the default CoreAudio driver keeps teardown and leaked-resource checks real.
run_godot_prefix_gate "$REAL_FLOW_CLEAN_LOG" "$REAL_FLOW_MARKER_PREFIX" \
  env STORY_DEMO_ALLOW_ISOLATED_QA=1 \
  STORY_DEMO_QA_BOOTSTRAP_NAME="$REAL_FLOW_CLEAN_QA_NAME" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  --fixed-fps 60 \
  -- --story-demo-real-flow-smoke --story-demo-real-flow-route=clean \
  --story-demo-language=ko
if [[ ! -d "$REAL_FLOW_CLEAN_QA_DIR" || -L "$REAL_FLOW_CLEAN_QA_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: clean real-flow smoke did not create its exact RuntimeQA namespace" >&2
  exit 1
fi
REAL_FLOW_CLEAN_MARKER="$(grep -E "^${REAL_FLOW_MARKER_PREFIX}([[:space:]]|$)" \
  "$REAL_FLOW_CLEAN_LOG" | tail -n 1)"
if [[ "$(grep -Ec "^${REAL_FLOW_MARKER_PREFIX}([[:space:]]|$)" "$REAL_FLOW_CLEAN_LOG" || true)" != "1" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: clean real-flow smoke emitted a non-exact marker count" >&2
  exit 1
fi
require_exact_marker_tokens "$REAL_FLOW_CLEAN_MARKER" "clean real StoryMode roundtrip" \
  "build=$BUILD_ID" "language=ko" "route=clean" "m02=clean" \
  "months=6" "weeks=24" "settlements=6" "receipts=9" \
  "story=real" "manual_save=1" "cold_restart=1" "exact_resume=1" \
  "overlay=clear" "input=clear" "ap_ledger=0"

run_godot_prefix_gate "$REAL_FLOW_RESTITUTION_LOG" "$REAL_FLOW_MARKER_PREFIX" \
  env STORY_DEMO_ALLOW_ISOLATED_QA=1 \
  STORY_DEMO_QA_BOOTSTRAP_NAME="$REAL_FLOW_RESTITUTION_QA_NAME" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  --fixed-fps 60 \
  -- --story-demo-real-flow-smoke --story-demo-real-flow-route=restitution \
  --story-demo-language=en
if [[ ! -d "$REAL_FLOW_RESTITUTION_QA_DIR" || -L "$REAL_FLOW_RESTITUTION_QA_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: restitution real-flow smoke did not create its exact RuntimeQA namespace" >&2
  exit 1
fi
REAL_FLOW_RESTITUTION_MARKER="$(grep -E "^${REAL_FLOW_MARKER_PREFIX}([[:space:]]|$)" \
  "$REAL_FLOW_RESTITUTION_LOG" | tail -n 1)"
if [[ "$(grep -Ec "^${REAL_FLOW_MARKER_PREFIX}([[:space:]]|$)" "$REAL_FLOW_RESTITUTION_LOG" || true)" != "1" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: restitution real-flow smoke emitted a non-exact marker count" >&2
  exit 1
fi
require_exact_marker_tokens "$REAL_FLOW_RESTITUTION_MARKER" "restitution real StoryMode roundtrip" \
  "build=$BUILD_ID" "language=en" "route=restitution" "m02=fallout" \
  "months=6" "weeks=24" "settlements=6" "receipts=10" \
  "story=real" "manual_save=1" "cold_restart=1" "exact_resume=1" \
  "overlay=clear" "input=clear" "ap_ledger=0"

run_godot_prefix_gate "$REAL_FLOW_ESCALATION_LOG" "$REAL_FLOW_MARKER_PREFIX" \
  env STORY_DEMO_ALLOW_ISOLATED_QA=1 \
  STORY_DEMO_QA_BOOTSTRAP_NAME="$REAL_FLOW_ESCALATION_QA_NAME" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  --fixed-fps 60 \
  -- --story-demo-real-flow-smoke --story-demo-real-flow-route=escalation \
  --story-demo-language=zh-CN
if [[ ! -d "$REAL_FLOW_ESCALATION_QA_DIR" || -L "$REAL_FLOW_ESCALATION_QA_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: escalation real-flow smoke did not create its exact RuntimeQA namespace" >&2
  exit 1
fi
REAL_FLOW_ESCALATION_MARKER="$(grep -E "^${REAL_FLOW_MARKER_PREFIX}([[:space:]]|$)" \
  "$REAL_FLOW_ESCALATION_LOG" | tail -n 1)"
if [[ "$(grep -Ec "^${REAL_FLOW_MARKER_PREFIX}([[:space:]]|$)" "$REAL_FLOW_ESCALATION_LOG" || true)" != "1" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: escalation real-flow smoke emitted a non-exact marker count" >&2
  exit 1
fi
require_exact_marker_tokens "$REAL_FLOW_ESCALATION_MARKER" "escalation real StoryMode roundtrip" \
  "build=$BUILD_ID" "language=zh-CN" "route=escalation" "m02=fallout" \
  "months=6" "weeks=24" "settlements=6" "receipts=10" \
  "story=real" "manual_save=1" "cold_restart=1" "exact_resume=1" \
  "overlay=clear" "input=clear" "ap_ledger=0"
remove_runtime_qa_dir "$REAL_FLOW_CLEAN_QA_DIR"
remove_runtime_qa_dir "$REAL_FLOW_RESTITUTION_QA_DIR"
remove_runtime_qa_dir "$REAL_FLOW_ESCALATION_QA_DIR"

run_godot_prefix_gate "$RETURN_LOG" "$RETURN_MARKER_PREFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  -- --qa=story-demo --story-demo-return-smoke --story-demo-language=ko
RETURN_MARKER="$(grep -E "^${RETURN_MARKER_PREFIX}([[:space:]]|$)" "$RETURN_LOG" | tail -n 1)"
for identity_token in \
  "build=$BUILD_ID" \
  "screen=transition" \
  "month=2" \
  "overlay=clear" \
  "input=clear" \
  "choices=1" \
  "settlements=1"; do
  if [[ "$RETURN_MARKER" != *"$identity_token"* ]]; then
    echo "STORY_DEMO_BUILD_FAIL: story-return smoke marker lacks $identity_token" >&2
    exit 1
  fi
done

RESUME_STATUS="not_applicable"
RESUME_MARKER=""
if [[ "$RESUME_APPLICABLE" == "1" ]]; then
  case "$STORY_DEMO_USER_DATA_DIR" in
    "$APPLICATION_SUPPORT_DIR/$CUSTOM_USER_DIR") ;;
    *)
      echo "STORY_DEMO_BUILD_FAIL: resume-smoke user-data target escaped its exact namespace" >&2
      exit 1
      ;;
  esac
  if [[ ! -d "$STORY_DEMO_USER_DATA_DIR" || -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: fresh package namespace is unavailable before existing-save resume" >&2
    exit 1
  fi
  FRESH_BEFORE_EXISTING_STATE="$STORY_DEMO_RECOVERY_ROOT/fresh-before-existing-resume.json"
  FRESH_AFTER_EXISTING_STATE="$STORY_DEMO_RECOVERY_ROOT/fresh-after-existing-resume.json"
  FRESH_EXISTING_RESUME_HOLD="$STORY_DEMO_QUARANTINE_ROOT/fresh-during-existing-resume"
  EXISTING_RESUME_AFTER="$STORY_DEMO_QUARANTINE_ROOT/existing-resume-after"
  capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$FRESH_BEFORE_EXISTING_STATE"
  if mv "$STORY_DEMO_USER_DATA_DIR" "$FRESH_EXISTING_RESUME_HOLD"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not atomically hold fresh smoke data for existing-save resume" >&2
    exit 1
  fi
  capture_exact_state "$FRESH_EXISTING_RESUME_HOLD" "$STORY_DEMO_VERIFY_STATE"
  exact_states_match "$FRESH_BEFORE_EXISTING_STATE" "$STORY_DEMO_VERIFY_STATE"
  if STORY_DEMO_EXISTING_RESUME_TEMP_ROOT="$(mktemp -d "$APPLICATION_SUPPORT_DIR/.GangnamDream_StoryDemo_v1.existing-resume.XXXXXX")" \
      && [[ -d "$STORY_DEMO_EXISTING_RESUME_TEMP_ROOT" ]]; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not create same-volume existing-save test temp" >&2
    exit 1
  fi
  EXISTING_RESUME_COPY="$STORY_DEMO_EXISTING_RESUME_TEMP_ROOT/candidate"
  if ditto "$STORY_DEMO_USER_DATA_BACKUP" "$EXISTING_RESUME_COPY"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not copy the verified backup for existing-save resume" >&2
    exit 1
  fi
  capture_exact_state "$EXISTING_RESUME_COPY" "$STORY_DEMO_VERIFY_STATE"
  exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_VERIFY_STATE"
  if [[ -e "$STORY_DEMO_USER_DATA_DIR" || -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: existing-save test target was recreated before atomic installation" >&2
    exit 1
  fi
  if mv "$EXISTING_RESUME_COPY" "$STORY_DEMO_USER_DATA_DIR"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not atomically install the existing-save test copy" >&2
    exit 1
  fi
  capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$STORY_DEMO_VERIFY_STATE"
  exact_states_match "$STORY_DEMO_ORIGINAL_STATE" "$STORY_DEMO_VERIFY_STATE"
  run_godot_prefix_gate "$RESUME_LOG" "$RESUME_MARKER_PREFIX" \
    "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
    -- --qa=story-demo --story-demo-resume-smoke --story-demo-language=ko
  RESUME_MARKER="$(grep -E "^${RESUME_MARKER_PREFIX}([[:space:]]|$)" "$RESUME_LOG" | tail -n 1)"
  resume_verify_status=0
  python3 - "$RESUME_INPUT_STATE" "$RESUME_MARKER" "$RESUME_MARKER_PREFIX" "$BUILD_ID" <<'PY' || resume_verify_status=$?
from __future__ import annotations
import json, sys
from pathlib import Path

state_path = Path(sys.argv[1])
marker, prefix, build_id = sys.argv[2:]
state = json.loads(state_path.read_text(encoding="utf-8"))
parts = marker.split()
if not parts or parts[0] != prefix:
    raise SystemExit("STORY_DEMO_BUILD_FAIL: existing-save resume marker prefix drifted")
tokens = {}
for part in parts[1:]:
    if "=" in part:
        key, value = part.split("=", 1)
        tokens[key] = value
expected = {
    "build": build_id,
    "month": str(state["month"]),
    "weeks": str(state["weeks"]),
    "settlements": str(state["settlements"]),
    "choices": str(state["choices"]),
    "phase": state["phase"],
    "screen": state["screen"],
    "overlay": "clear",
    "input": "clear",
}
missing = [f"{key}={value}" for key, value in expected.items() if tokens.get(key) != value]
if missing:
    raise SystemExit("STORY_DEMO_BUILD_FAIL: existing-save resume marker drifted: " + ", ".join(missing))
PY
  if [[ $resume_verify_status -ne 0 ]]; then
    exit 1
  fi
  if mv "$STORY_DEMO_USER_DATA_DIR" "$EXISTING_RESUME_AFTER"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not quarantine the exercised existing-save test copy" >&2
    exit 1
  fi
  if [[ -e "$STORY_DEMO_USER_DATA_DIR" || -L "$STORY_DEMO_USER_DATA_DIR" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: fresh-smoke restore target was recreated before atomic installation" >&2
    exit 1
  fi
  if mv "$FRESH_EXISTING_RESUME_HOLD" "$STORY_DEMO_USER_DATA_DIR"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not restore fresh smoke data after existing-save resume" >&2
    exit 1
  fi
  capture_exact_state "$STORY_DEMO_USER_DATA_DIR" "$FRESH_AFTER_EXISTING_STATE"
  exact_states_match "$FRESH_BEFORE_EXISTING_STATE" "$FRESH_AFTER_EXISTING_STATE"
  RESUME_STATUS="passed"
fi
codesign --verify --deep --strict "$VERIFIED_APP"

restore_candidate_user_data
capture_protected "$PROTECTED_AFTER"
protected_verify_status=0
python3 - "$PROTECTED_BEFORE" "$PROTECTED_AFTER" "$PROTECTED_RESULT" <<'PY' || protected_verify_status=$?
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
    raise SystemExit("STORY_DEMO_BUILD_FAIL: protected before/after mismatch: " + ", ".join(errors))
PY
if [[ $protected_verify_status -ne 0 || ! -s "$PROTECTED_RESULT" ]]; then
  exit 1
fi

if [[ -n "$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: source worktree changed during packaging" >&2
  git -C "$PROJECT_DIR" status --short >&2
  exit 1
fi

if [[ -L "$PROJECT_DIR/build" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: build output parent must not be a symlink" >&2
  exit 1
fi
if mkdir -p "$PROJECT_DIR/build" && [[ -d "$PROJECT_DIR/build" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create the build output parent" >&2
  exit 1
fi
if PUBLISH_STAGE_ROOT="$(mktemp -d "$PROJECT_DIR/build/.story_demo-publish.XXXXXX")" \
    && [[ -d "$PUBLISH_STAGE_ROOT" && ! -L "$PUBLISH_STAGE_ROOT" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create the same-volume publish stage" >&2
  exit 1
fi
case "$PUBLISH_STAGE_ROOT" in
  "$PROJECT_DIR"/build/.story_demo-publish.*) ;;
  *)
    echo "STORY_DEMO_BUILD_FAIL: publish stage escaped its exact same-volume namespace" >&2
    exit 1
    ;;
esac
PUBLISH_READY_SET="$PUBLISH_STAGE_ROOT/build/story_demo"
PUBLISH_PREVIOUS_SET="$PUBLISH_STAGE_ROOT/previous-story_demo"
PUBLISH_FAILED_SET="$PUBLISH_STAGE_ROOT/failed-new-story_demo"
PUBLISH_APP="$PUBLISH_STAGE_ROOT/$APP_REL"
PUBLISH_ZIP="$PUBLISH_STAGE_ROOT/$ZIP_REL"
PUBLISH_MANIFEST="$PUBLISH_STAGE_ROOT/$MANIFEST_REL"
PUBLISH_CHECKSUM="$PUBLISH_STAGE_ROOT/$CHECKSUM_REL"
if mkdir -p "$(dirname "$PUBLISH_APP")" \
    && [[ -d "$(dirname "$PUBLISH_APP")" && ! -L "$(dirname "$PUBLISH_APP")" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not create publish-stage output directories" >&2
  exit 1
fi
case "$PUBLISH_APP" in
  "$PUBLISH_STAGE_ROOT"/build/story_demo/macos/"$APP_STEM".app) ;;
  *)
    echo "STORY_DEMO_BUILD_FAIL: staged app escaped the exact publish set" >&2
    exit 1 ;;
esac
if ditto "$VERIFIED_APP" "$PUBLISH_APP" \
    && [[ -d "$PUBLISH_APP" && ! -L "$PUBLISH_APP" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not copy the verified app to the publish stage" >&2
  exit 1
fi
codesign --verify --deep --strict "$PUBLISH_APP"
if ditto "$FINALIZED_ZIP" "$PUBLISH_ZIP" && [[ -s "$PUBLISH_ZIP" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not copy the verified ZIP to the publish stage" >&2
  exit 1
fi

export STORY_DEMO_PROJECT_DIR="$PROJECT_DIR"
export STORY_DEMO_STAGE_PROJECT="$STAGE_PROJECT"
export STORY_DEMO_SOURCE_REF="$SOURCE_REF"
export STORY_DEMO_SOURCE_COMMIT="$SOURCE_COMMIT"
export STORY_DEMO_SOURCE_TREE="$SOURCE_TREE"
export STORY_DEMO_PRODUCT_REVISION="$PRODUCT_REVISION"
export STORY_DEMO_PRODUCT_TREE="$PRODUCT_TREE"
export STORY_DEMO_GODOT_VERSION="$GODOT_VERSION"
export STORY_DEMO_BUILD_STARTED_UTC="$BUILD_STARTED_UTC"
export STORY_DEMO_FINAL_ZIP="$PUBLISH_ZIP"
export STORY_DEMO_VERIFIED_APP="$PUBLISH_APP"
export STORY_DEMO_NATIVE_MARKER="$NATIVE_MARKER"
export STORY_DEMO_KO_MARKER="$KO_MARKER"
export STORY_DEMO_EN_MARKER="$EN_MARKER"
export STORY_DEMO_JA_MARKER="$JA_MARKER"
export STORY_DEMO_ZH_CN_MARKER="$ZH_CN_MARKER"
export STORY_DEMO_ZH_TW_MARKER="$ZH_TW_MARKER"
export STORY_DEMO_RETURN_MARKER="$RETURN_MARKER"
export STORY_DEMO_COLD_RESTART_RESUME_MARKER="$COLD_RESTART_RESUME_MARKER"
export STORY_DEMO_REAL_FLOW_CLEAN_MARKER="$REAL_FLOW_CLEAN_MARKER"
export STORY_DEMO_REAL_FLOW_RESTITUTION_MARKER="$REAL_FLOW_RESTITUTION_MARKER"
export STORY_DEMO_REAL_FLOW_ESCALATION_MARKER="$REAL_FLOW_ESCALATION_MARKER"
export STORY_DEMO_DENSITY_SELF_TEST_MARKER="$DENSITY_SELF_TEST_ACTUAL_MARKER"
export STORY_DEMO_DENSITY_MARKER="$DENSITY_ACTUAL_MARKER"
export STORY_DEMO_DENSITY_HUMAN_GATE_MARKER="$DENSITY_ACTUAL_HUMAN_GATE_MARKER"
export STORY_DEMO_RESUME_STATUS="$RESUME_STATUS"
export STORY_DEMO_RESUME_MARKER="$RESUME_MARKER"
export STORY_DEMO_RESUME_INPUT_STATE="$RESUME_INPUT_STATE"
export STORY_DEMO_PROTECTED_RESULT="$PROTECTED_RESULT"
export STORY_DEMO_FINAL_MANIFEST="$PUBLISH_MANIFEST"
python3 - <<'PY'
from __future__ import annotations
import hashlib, json, os
from datetime import datetime, timezone
from pathlib import Path

root = Path(os.environ["STORY_DEMO_PROJECT_DIR"])
stage = Path(os.environ["STORY_DEMO_STAGE_PROJECT"])
zip_path = Path(os.environ["STORY_DEMO_FINAL_ZIP"])
app = Path(os.environ["STORY_DEMO_VERIFIED_APP"])
manifest_path = Path(os.environ["STORY_DEMO_FINAL_MANIFEST"])
stem = "GangnamDream-StoryDemo"

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
    "tools/evidence/order124_build_2026.08.24.2/MANIFEST.json",
    "tools/evidence/order124_build_2026.08.24.2/MANIFEST.sha256",
    "tools/evidence/order124_build_2026.08.24.2/LOSS_RECEIPT.json",
    "tools/audit_scope.json",
    "tools/build_story_demo_macos.sh",
    "tools/story_demo_package_audit.py",
]
product_runtime_scope = [
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
]
contract_files = []
for relative in contract_paths:
    data = __import__("subprocess").check_output([
        "git", "-C", str(root), "show", f"{os.environ['STORY_DEMO_SOURCE_COMMIT']}:{relative}"
    ])
    contract_files.append({"path": relative, "sha256": hashlib.sha256(data).hexdigest(), "size_bytes": len(data)})

app_hash, app_files = tree_digest(app)
launcher = app / "Contents/MacOS" / stem
pck = app / "Contents/Resources" / f"{stem}.pck"
resume_status = os.environ["STORY_DEMO_RESUME_STATUS"]
resume_applicable = resume_status == "passed"
resume_input = json.loads(Path(os.environ["STORY_DEMO_RESUME_INPUT_STATE"]).read_text(encoding="utf-8"))
resume_validation = {
    "passed": True,
    "status": resume_status,
    "applicable": resume_applicable,
    "source": "pre_build_candidate_snapshot",
    "save_path": "user://story_demo_save.json",
    "input_save": resume_input if resume_applicable else None,
    "marker": os.environ["STORY_DEMO_RESUME_MARKER"],
}
if not resume_applicable:
    resume_validation["reason"] = "no_existing_candidate_save"
payload = {
    "schema_version": 1,
    "profile": "story_demo_rc",
    "game_version": "0.1.0-dev",
    "build_id": "2026.08.31.1",
    "build_flavor": "story_demo_rc",
    "timestamps": {
        "started_utc": os.environ["STORY_DEMO_BUILD_STARTED_UTC"],
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    },
    "source": {
        "requested_ref": os.environ["STORY_DEMO_SOURCE_REF"],
        "revision": os.environ["STORY_DEMO_SOURCE_COMMIT"],
        "tree": os.environ["STORY_DEMO_SOURCE_TREE"],
        "product_revision": os.environ["STORY_DEMO_PRODUCT_REVISION"],
        "product_tree": os.environ["STORY_DEMO_PRODUCT_TREE"],
        "product_ancestor": True,
        "product_runtime_scope": product_runtime_scope,
        "product_runtime_diff": [],
        "status": "clean",
        "staging": "full_git_archive_outside_repository",
        "contract_files": contract_files,
        "staged_project_sha256": digest(stage / "project.godot"),
        "staged_export_presets_sha256": digest(stage / "export_presets.cfg"),
    },
    "engine": {"version": os.environ["STORY_DEMO_GODOT_VERSION"]},
    "application": {
        "name": stem,
        "bundle_identifier": "dev.junheelee.gangnamdream.storydemo",
        "version": "2026.8.31",
        "entry_scene": "res://playtests/order124/StoryChoiceM1M6Playtest.tscn",
        "custom_user_dir_name": "GangnamDream_StoryDemo_v1",
        "splash_enabled": False,
    },
    "package": {
        "zip": {"path": "build/story_demo/macos/GangnamDream-StoryDemo.zip", "sha256": digest(zip_path), "size_bytes": zip_path.stat().st_size},
        "app": {"path": "build/story_demo/macos/GangnamDream-StoryDemo.app", "name": f"{stem}.app", "tree_sha256": app_hash, "file_count": app_files},
        "launcher": {"path": f"{stem}.app/Contents/MacOS/{stem}", "sha256": digest(launcher), "size_bytes": launcher.stat().st_size},
        "resource_pack": {"path": f"{stem}.app/Contents/Resources/{stem}.pck", "sha256": digest(pck), "size_bytes": pck.stat().st_size},
    },
    "protected": json.loads(Path(os.environ["STORY_DEMO_PROTECTED_RESULT"]).read_text(encoding="utf-8")),
    "validation": {
        "source_import": {"passed": True},
		"targeted_story_choice": {"passed": True, "scene": "res://tools/StoryDemoFourLanguageCheck.tscn", "marker": "STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=30 weeks=120 settlements=30 ap_surface=0 save=5 story=10 build=2026.08.31.1"},
        "story_density_contract": {
            "passed": True,
            "scope": "structural_automation_only",
            "source_revision": os.environ["STORY_DEMO_PRODUCT_REVISION"],
            "source_tree": os.environ["STORY_DEMO_PRODUCT_TREE"],
            "build_id": "2026.08.31.1",
            "audit_path": "tools/story_demo_density_audit.py",
            "audit_sha256": digest(stage / "tools/story_demo_density_audit.py"),
            "fixture_path": "tools/fixtures/story_demo_density_contract.json",
            "fixture_sha256": digest(stage / "tools/fixtures/story_demo_density_contract.json"),
            "human_gates_path": "docs/human_gates.json",
            "human_gates_sha256": digest(stage / "docs/human_gates.json"),
            "self_test_marker": os.environ["STORY_DEMO_DENSITY_SELF_TEST_MARKER"],
            "marker": os.environ["STORY_DEMO_DENSITY_MARKER"],
            "human_gate_marker": os.environ["STORY_DEMO_DENSITY_HUMAN_GATE_MARKER"],
        },
        "native_export": {"passed": True, "platform": "macOS", "preset": "Story Demo macOS"},
        "codesign": {"passed": True, "mode": "ad-hoc", "verification": "--deep --strict"},
        "native_no_argument": {"passed": True, "args": [], "marker": os.environ["STORY_DEMO_NATIVE_MARKER"]},
        "package_smokes": [
            {"passed": True, "language": "ko", "size": "1280x800", "marker": os.environ["STORY_DEMO_KO_MARKER"]},
            {"passed": True, "language": "en", "size": "960x600", "marker": os.environ["STORY_DEMO_EN_MARKER"]},
            {"passed": True, "language": "ja", "size": "1280x800", "marker": os.environ["STORY_DEMO_JA_MARKER"]},
            {"passed": True, "language": "zh-CN", "size": "960x600", "marker": os.environ["STORY_DEMO_ZH_CN_MARKER"]},
            {"passed": True, "language": "zh-TW", "size": "1280x800", "marker": os.environ["STORY_DEMO_ZH_TW_MARKER"]},
        ],
        "story_return_black_overlay": {
            "passed": True,
            "language": "ko",
            "size": "1280x800",
            "args": ["--qa=story-demo", "--story-demo-return-smoke", "--story-demo-language=ko"],
            "marker": os.environ["STORY_DEMO_RETURN_MARKER"],
        },
        "cold_restart_resume": {
            "passed": True,
            "source": "fresh_package_smoke",
            "producer_language": "ko",
            "launcher_process": "separate",
            "save_path": "user://story_demo_save.json",
            "args": ["--qa=story-demo", "--story-demo-resume-smoke", "--story-demo-language=ko"],
            "marker": os.environ["STORY_DEMO_COLD_RESTART_RESUME_MARKER"],
        },
        "real_story_roundtrips": [
            {
                "passed": True,
                "language": "ko",
                "route": "clean",
                "m02": "clean",
                "months": 6,
                "weeks": 24,
                "settlements": 6,
                "receipts": 9,
                "cold_restart": True,
                "exact_resume": True,
                "runtime_qa_namespace": "GangnamDream_StoryDemo_RuntimeQA_package_real_clean",
                "args": ["--story-demo-real-flow-smoke", "--story-demo-real-flow-route=clean", "--story-demo-language=ko"],
                "marker": os.environ["STORY_DEMO_REAL_FLOW_CLEAN_MARKER"],
            },
            {
                "passed": True,
                "language": "en",
                "route": "restitution",
                "m02": "fallout",
                "months": 6,
                "weeks": 24,
                "settlements": 6,
                "receipts": 10,
                "cold_restart": True,
                "exact_resume": True,
                "runtime_qa_namespace": "GangnamDream_StoryDemo_RuntimeQA_package_real_restitution",
                "args": ["--story-demo-real-flow-smoke", "--story-demo-real-flow-route=restitution", "--story-demo-language=en"],
                "marker": os.environ["STORY_DEMO_REAL_FLOW_RESTITUTION_MARKER"],
            },
            {
                "passed": True,
                "language": "zh-CN",
                "route": "escalation",
                "m02": "fallout",
                "months": 6,
                "weeks": 24,
                "settlements": 6,
                "receipts": 10,
                "cold_restart": True,
                "exact_resume": True,
                "runtime_qa_namespace": "GangnamDream_StoryDemo_RuntimeQA_package_real_escalation",
                "args": ["--story-demo-real-flow-smoke", "--story-demo-real-flow-route=escalation", "--story-demo-language=zh-CN"],
                "marker": os.environ["STORY_DEMO_REAL_FLOW_ESCALATION_MARKER"],
            },
        ],
        "existing_save_resume": resume_validation,
    },
}
manifest_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

MANIFEST_HASH="$(python3 - "$PUBLISH_MANIFEST" <<'PY'
import hashlib, pathlib, sys
print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
)"
if printf '%s  %s\n' "$MANIFEST_HASH" "$MANIFEST_REL" > "$PUBLISH_CHECKSUM" \
    && [[ -s "$PUBLISH_CHECKSUM" ]]; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not write the publish-stage manifest checksum" >&2
  exit 1
fi
STORY_DEMO_AUDIT_SOURCE_ROOT="$PROJECT_DIR" python3 \
  "$STAGE_PROJECT/tools/story_demo_package_audit.py" --manifest "$PUBLISH_MANIFEST"

capture_exact_state "$OUTPUT_DIR" "$PUBLISH_PREVIOUS_STATE"
capture_exact_state "$PUBLISH_READY_SET" "$PUBLISH_NEW_STATE"
if [[ -e "$OUTPUT_DIR" || -L "$OUTPUT_DIR" ]]; then
  PUBLISH_PREVIOUS_EXISTED=1
fi
PUBLISH_SWAP_STARTED=1
if [[ "$PUBLISH_PREVIOUS_EXISTED" == "1" ]]; then
  if [[ -e "$PUBLISH_PREVIOUS_SET" || -L "$PUBLISH_PREVIOUS_SET" ]]; then
    echo "STORY_DEMO_BUILD_FAIL: previous-set publish hold already exists" >&2
    exit 1
  fi
  if mv "$OUTPUT_DIR" "$PUBLISH_PREVIOUS_SET"; then
    :
  else
    echo "STORY_DEMO_BUILD_FAIL: could not atomically hold the previous publish set" >&2
    exit 1
  fi
  capture_exact_state "$PUBLISH_PREVIOUS_SET" "$PUBLISH_VERIFY_STATE"
  exact_states_match "$PUBLISH_PREVIOUS_STATE" "$PUBLISH_VERIFY_STATE"
fi
if [[ -e "$OUTPUT_DIR" || -L "$OUTPUT_DIR" ]]; then
  echo "STORY_DEMO_BUILD_FAIL: final publish target was recreated before atomic installation" >&2
  exit 1
fi
if mv "$PUBLISH_READY_SET" "$OUTPUT_DIR"; then
  :
else
  echo "STORY_DEMO_BUILD_FAIL: could not atomically install the audited publish set" >&2
  exit 1
fi
capture_exact_state "$OUTPUT_DIR" "$PUBLISH_VERIFY_STATE"
exact_states_match "$PUBLISH_NEW_STATE" "$PUBLISH_VERIFY_STATE"
STORY_DEMO_AUDIT_SOURCE_ROOT="$PROJECT_DIR" python3 \
  "$STAGE_PROJECT/tools/story_demo_package_audit.py" --manifest "$FINAL_MANIFEST"

cleanup_recovery_after_success
trap '' INT TERM PIPE
BUILD_SUCCEEDED=1
PUBLISH_COMMITTED=1

echo "STORY_DEMO_MACOS_BUILD_OK build=$BUILD_ID revision=$SOURCE_COMMIT tree=$SOURCE_TREE" || true
echo "  $APP_REL" || true
echo "  $ZIP_REL" || true
echo "  $MANIFEST_REL" || true
echo "  $CHECKSUM_REL" || true
exit 0

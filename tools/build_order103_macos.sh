#!/bin/bash
## Build the isolated ORDER-103 M01-M06 macOS candidate from a fixed clean commit.

set -euo pipefail

readonly EXPECTED_BUILD_ID="2026.08.24.1"
readonly PRESET_NAME="ORDER-103 M01-M06 Playtest"
readonly APP_STEM="GangnamDream-ORDER103-M01M06-ChoicePlaytest"
readonly ZIP_REL="build/order103/macos/GangnamDream-ORDER103-M01M06-ChoicePlaytest.zip"
readonly MANIFEST_REL="build/order103/MANIFEST.json"
readonly CHECKSUM_REL="build/order103/MANIFEST.sha256"
readonly CUSTOM_USER_DIR="GangnamDream_ORDER103_M01M06_v1"
readonly AUTOSAVE_NAME="story_map_m1m6_playtest_autosave.json"
readonly TARGET_MARKER="STORY_MAP_M1M6_CHECK_OK months=6 margin=4 deferred=2 actor=2 save=2 ui=1 disclosure=2"
readonly SMOKE_SUFFIX="save_resume=m02,recap clips=0 scroll=0 auto_assign=0"

usage() {
  echo "usage: GODOT=/path/to/Godot $0 [--source <commit>] --build-id 2026.08.24.1" >&2
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
      echo "ORDER103_BUILD_FAIL: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ "$BUILD_ID" != "$EXPECTED_BUILD_ID" ]]; then
  echo "ORDER103_BUILD_FAIL: --build-id must be $EXPECTED_BUILD_ID" >&2
  exit 2
fi
if [[ -z "${GODOT:-}" || ! -x "$GODOT" ]]; then
  echo "ORDER103_BUILD_FAIL: set GODOT to an executable Godot 4.6.2 binary" >&2
  exit 2
fi
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ORDER103_BUILD_FAIL: native macOS export and codesign require a macOS host" >&2
  exit 1
fi
for command_name in git tar python3 mktemp ditto codesign plutil; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ORDER103_BUILD_FAIL: required command is unavailable: $command_name" >&2
    exit 1
  fi
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ORDER103_BUILD_FAIL: project is not a Git worktree" >&2
  exit 1
fi
SOURCE_STATUS="$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)"
if [[ -n "$SOURCE_STATUS" ]]; then
  echo "ORDER103_BUILD_FAIL: source worktree is dirty; commit or use a clean worktree" >&2
  printf '%s\n' "$SOURCE_STATUS" | sed 's/^/  /' >&2
  exit 1
fi
SOURCE_COMMIT="$(git -C "$PROJECT_DIR" rev-parse --verify "$SOURCE_REF^{commit}")"
SOURCE_TREE="$(git -C "$PROJECT_DIR" rev-parse "$SOURCE_COMMIT^{tree}")"
if [[ ! "$SOURCE_COMMIT" =~ ^[0-9a-f]{40}$ || ! "$SOURCE_TREE" =~ ^[0-9a-f]{40}$ ]]; then
  echo "ORDER103_BUILD_FAIL: source did not resolve to a full commit and tree" >&2
  exit 1
fi
GODOT_VERSION="$($GODOT --version 2>&1 | head -n 1)"
if [[ "$GODOT_VERSION" != "4.6.2.stable.official.71f334935" ]]; then
  echo "ORDER103_BUILD_FAIL: expected Godot 4.6.2.stable.official.71f334935, got $GODOT_VERSION" >&2
  exit 1
fi

TEMP_PARENT="${TMPDIR:-/tmp}"
case "$(cd "$TEMP_PARENT" 2>/dev/null && pwd -P || true)" in
  "$PROJECT_DIR"|"$PROJECT_DIR"/*) TEMP_PARENT="/tmp" ;;
esac
WORK_DIR="$(mktemp -d "$TEMP_PARENT/gangnamdream-order103.XXXXXX")"
case "$(cd "$WORK_DIR" && pwd -P)" in
  "$PROJECT_DIR"|"$PROJECT_DIR"/*)
    echo "ORDER103_BUILD_FAIL: staging directory must be outside the repository" >&2
    exit 1
    ;;
esac
SOURCE_SNAPSHOT="$WORK_DIR/source"
SOURCE_TEST_PROJECT="$WORK_DIR/source-test-project"
PACKAGE_PROJECT="$WORK_DIR/package-project"
PACKAGE_STAGE="$WORK_DIR/package-stage"
VERIFY_STAGE="$WORK_DIR/verify-stage"
RAW_ZIP="$WORK_DIR/raw.zip"
FINALIZED_ZIP="$WORK_DIR/$APP_STEM.zip"
SOURCE_IMPORT_LOG="$WORK_DIR/source-import.log"
TARGET_LOG="$WORK_DIR/target.log"
PACKAGE_IMPORT_LOG="$WORK_DIR/package-import.log"
EXPORT_LOG="$WORK_DIR/export.log"
NATIVE_LOG="$WORK_DIR/native.log"
NATIVE_PROBE="$WORK_DIR/native-entry.marker"
KO_LOG="$WORK_DIR/smoke-ko.log"
EN_LOG="$WORK_DIR/smoke-en.log"

cleanup() {
  local exit_code=$?
  if [[ -n "${NATIVE_PID:-}" ]]; then
    kill -TERM "$NATIVE_PID" >/dev/null 2>&1 || true
    wait "$NATIVE_PID" >/dev/null 2>&1 || true
  fi
  case "$WORK_DIR" in
    "$TEMP_PARENT"/gangnamdream-order103.*) rm -rf "$WORK_DIR" ;;
  esac
  exit "$exit_code"
}
trap cleanup EXIT INT TERM

mkdir -p "$SOURCE_SNAPSHOT" "$SOURCE_TEST_PROJECT" "$PACKAGE_PROJECT" \
  "$PACKAGE_STAGE" "$VERIFY_STAGE"
git -C "$PROJECT_DIR" archive --format=tar "$SOURCE_COMMIT" \
  | tar -xf - -C "$SOURCE_SNAPSHOT"

for required in \
  tools/build_order103_macos.sh \
  tools/order103_package_audit.py \
  tools/order103_export/project.godot \
  tools/order103_export/export_presets.cfg \
  tools/order103_export/Entry.tscn \
  tools/order103_export/Entry.gd \
  tools/order103_export/AudioManagerStub.gd \
  tools/order103_export/resources.txt; do
  if [[ ! -f "$SOURCE_SNAPSHOT/$required" ]]; then
    echo "ORDER103_BUILD_FAIL: fixed source commit lacks $required" >&2
    exit 1
  fi
done
python3 "$SOURCE_SNAPSHOT/tools/order103_package_audit.py" --self-test

run_godot_gate() {
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
      || grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource' "$log_path" \
      || ! grep -Fqx "$marker" "$log_path"; then
    echo "ORDER103_BUILD_FAIL: Godot gate failed (exit=$exit_code, expected=$marker)" >&2
    sed -n '1,260p' "$log_path" >&2
    exit 1
  fi
}

cp -p "$SOURCE_SNAPSHOT/tools/order103_export/project.godot" "$PACKAGE_PROJECT/project.godot"
cp -p "$SOURCE_SNAPSHOT/tools/order103_export/export_presets.cfg" "$PACKAGE_PROJECT/export_presets.cfg"
mkdir -p "$PACKAGE_PROJECT/order103"
cp -p "$SOURCE_SNAPSHOT/tools/order103_export/Entry.tscn" "$PACKAGE_PROJECT/order103/Entry.tscn"
cp -p "$SOURCE_SNAPSHOT/tools/order103_export/Entry.gd" "$PACKAGE_PROJECT/order103/Entry.gd"
cp -p "$SOURCE_SNAPSHOT/tools/order103_export/AudioManagerStub.gd" "$PACKAGE_PROJECT/order103/AudioManagerStub.gd"

while IFS= read -r resource_path || [[ -n "$resource_path" ]]; do
  [[ -z "$resource_path" || "$resource_path" == \#* ]] && continue
  case "$resource_path" in
    /*|*..*|*\\*)
      echo "ORDER103_BUILD_FAIL: unsafe resource list path: $resource_path" >&2
      exit 1
      ;;
  esac
  if [[ ! -f "$SOURCE_SNAPSHOT/$resource_path" || -L "$SOURCE_SNAPSHOT/$resource_path" ]]; then
    echo "ORDER103_BUILD_FAIL: resource is missing or a symlink: $resource_path" >&2
    exit 1
  fi
  mkdir -p "$PACKAGE_PROJECT/$(dirname "$resource_path")"
  cp -p "$SOURCE_SNAPSHOT/$resource_path" "$PACKAGE_PROJECT/$resource_path"
done < "$SOURCE_SNAPSHOT/tools/order103_export/resources.txt"

# Import and execute the exact target source in a minimal validation project.
# A fresh import of all 498 product assets is unrelated to ORDER-103 and can
# exhaust the editor process before this isolated gate is reached.
cp -R "$PACKAGE_PROJECT/." "$SOURCE_TEST_PROJECT/"
mkdir -p "$SOURCE_TEST_PROJECT/tools"
for validation_path in \
  tools/StoryMapM1M6Check.gd \
  tools/StoryMapM1M6Check.gd.uid \
  tools/StoryMapM1M6Check.tscn \
  tools/audit_scope.json; do
  if [[ ! -f "$SOURCE_SNAPSHOT/$validation_path" ]]; then
    echo "ORDER103_BUILD_FAIL: fixed source commit lacks $validation_path" >&2
    exit 1
  fi
  cp -p "$SOURCE_SNAPSHOT/$validation_path" "$SOURCE_TEST_PROJECT/$validation_path"
done
if ! "$GODOT" --headless --path "$SOURCE_TEST_PROJECT" --import >"$SOURCE_IMPORT_LOG" 2>&1; then
  echo "ORDER103_BUILD_FAIL: fixed target-source import failed" >&2
  sed -n '1,260p' "$SOURCE_IMPORT_LOG" >&2
  exit 1
fi
if grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource' "$SOURCE_IMPORT_LOG"; then
  echo "ORDER103_BUILD_FAIL: fixed target-source import contains engine/script errors" >&2
  sed -n '1,260p' "$SOURCE_IMPORT_LOG" >&2
  exit 1
fi
run_godot_gate "$TARGET_LOG" "$TARGET_MARKER" \
  "$GODOT" --headless --path "$SOURCE_TEST_PROJECT" --quit-after 3600 \
  res://tools/StoryMapM1M6Check.tscn

if ! "$GODOT" --headless --path "$PACKAGE_PROJECT" --import >"$PACKAGE_IMPORT_LOG" 2>&1; then
  echo "ORDER103_BUILD_FAIL: isolated package import failed" >&2
  sed -n '1,260p' "$PACKAGE_IMPORT_LOG" >&2
  exit 1
fi
if grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource' "$PACKAGE_IMPORT_LOG"; then
  echo "ORDER103_BUILD_FAIL: isolated package import contains engine/script errors" >&2
  sed -n '1,260p' "$PACKAGE_IMPORT_LOG" >&2
  exit 1
fi
if ! "$GODOT" --headless --path "$PACKAGE_PROJECT" --export-release \
    "$PRESET_NAME" "$RAW_ZIP" >"$EXPORT_LOG" 2>&1; then
  echo "ORDER103_BUILD_FAIL: macOS release export failed" >&2
  sed -n '1,320p' "$EXPORT_LOG" >&2
  exit 1
fi
if [[ ! -s "$RAW_ZIP" ]]; then
  echo "ORDER103_BUILD_FAIL: macOS export did not create a ZIP" >&2
  exit 1
fi

ditto -x -k "$RAW_ZIP" "$PACKAGE_STAGE"
APP_COUNT="$(find "$PACKAGE_STAGE" -maxdepth 1 -type d -name '*.app' | wc -l | tr -d ' ')"
if [[ "$APP_COUNT" != "1" ]]; then
  echo "ORDER103_BUILD_FAIL: exported ZIP must contain exactly one top-level app" >&2
  exit 1
fi
SOURCE_APP="$(find "$PACKAGE_STAGE" -maxdepth 1 -type d -name '*.app' -print -quit)"
INFO_PLIST="$SOURCE_APP/Contents/Info.plist"
OLD_EXECUTABLE="$(plutil -extract CFBundleExecutable raw "$INFO_PLIST")"
OLD_LAUNCHER="$SOURCE_APP/Contents/MacOS/$OLD_EXECUTABLE"
OLD_PCK="$SOURCE_APP/Contents/Resources/$OLD_EXECUTABLE.pck"
if [[ ! -f "$OLD_LAUNCHER" || ! -f "$OLD_PCK" ]]; then
  echo "ORDER103_BUILD_FAIL: exported app launcher or resource pack is missing" >&2
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
if [[ ! -x "$LAUNCHER" ]]; then
  echo "ORDER103_BUILD_FAIL: finalized native launcher is not executable" >&2
  exit 1
fi

# A real no-argument launch must reach the isolated entry and remain alive.
ORDER103_NATIVE_PROBE_PATH="$NATIVE_PROBE" "$LAUNCHER" >"$NATIVE_LOG" 2>&1 &
NATIVE_PID=$!
NATIVE_READY=0
for _attempt in $(seq 1 120); do
  if [[ -s "$NATIVE_PROBE" ]] \
      && grep -Eq '^ORDER103_NATIVE_ENTRY_OK([[:space:]]|$)' "$NATIVE_PROBE"; then
    NATIVE_READY=1
    break
  fi
  if ! kill -0 "$NATIVE_PID" >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done
if [[ "$NATIVE_READY" != "1" ]]; then
  echo "ORDER103_BUILD_FAIL: native no-argument entry marker was not observed" >&2
  sed -n '1,240p' "$NATIVE_LOG" >&2
  exit 1
fi
NATIVE_MARKER="$(grep -E '^ORDER103_NATIVE_ENTRY_OK([[:space:]]|$)' "$NATIVE_PROBE" | tail -n 1)"
for identity_token in \
  "scene=res://tools/StoryMapM1M6Playtest.tscn" \
  "custom_user_dir=$CUSTOM_USER_DIR" \
  "build=$BUILD_ID"; do
  if [[ "$NATIVE_MARKER" != *"$identity_token"* ]]; then
    echo "ORDER103_BUILD_FAIL: native marker lacks identity token $identity_token" >&2
    exit 1
  fi
done
kill -TERM "$NATIVE_PID" >/dev/null 2>&1 || true
wait "$NATIVE_PID" >/dev/null 2>&1 || true
NATIVE_PID=""

USER_DATA_DIR="${NATIVE_MARKER##* path=}"
if [[ -z "$USER_DATA_DIR" || "$USER_DATA_DIR" == "$NATIVE_MARKER" ]]; then
  echo "ORDER103_BUILD_FAIL: native marker did not report the resolved user data directory" >&2
  exit 1
fi
DEDICATED_SAVE="$USER_DATA_DIR/$AUTOSAVE_NAME"
if [[ -e "$DEDICATED_SAVE" ]]; then
  echo "ORDER103_BUILD_FAIL: dedicated playtest autosave already exists; refusing to overwrite it" >&2
  echo "  $DEDICATED_SAVE" >&2
  exit 1
fi

run_godot_gate "$KO_LOG" \
  "ORDER103_WRAPPER_SMOKE_OK language=ko size=1280x800 $SMOKE_SUFFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 1280x800 \
  -- --order103-smoke --order103-language=ko
run_godot_gate "$EN_LOG" \
  "ORDER103_WRAPPER_SMOKE_OK language=en size=960x600 $SMOKE_SUFFIX" \
  "$LAUNCHER" --rendering-driver opengl3 --resolution 960x600 \
  -- --order103-smoke --order103-language=en
if [[ -e "$DEDICATED_SAVE" ]]; then
  echo "ORDER103_BUILD_FAIL: package smoke left a dedicated autosave behind" >&2
  exit 1
fi
codesign --verify --deep --strict "$VERIFIED_APP"

if [[ -n "$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)" ]]; then
  echo "ORDER103_BUILD_FAIL: source worktree changed during packaging" >&2
  git -C "$PROJECT_DIR" status --short >&2
  exit 1
fi

OUTPUT_DIR="$PROJECT_DIR/build/order103"
FINAL_ZIP="$PROJECT_DIR/$ZIP_REL"
FINAL_MANIFEST="$PROJECT_DIR/$MANIFEST_REL"
FINAL_CHECKSUM="$PROJECT_DIR/$CHECKSUM_REL"
mkdir -p "$(dirname "$FINAL_ZIP")" "$OUTPUT_DIR"
mv "$FINALIZED_ZIP" "$FINAL_ZIP"

export ORDER103_PROJECT_DIR="$PROJECT_DIR"
export ORDER103_SOURCE_SNAPSHOT="$SOURCE_SNAPSHOT"
export ORDER103_SOURCE_REF="$SOURCE_REF"
export ORDER103_SOURCE_COMMIT="$SOURCE_COMMIT"
export ORDER103_SOURCE_TREE="$SOURCE_TREE"
export ORDER103_GODOT_VERSION="$GODOT_VERSION"
export ORDER103_FINAL_ZIP="$FINAL_ZIP"
export ORDER103_VERIFIED_APP="$VERIFIED_APP"
export ORDER103_NATIVE_MARKER="$NATIVE_MARKER"
export ORDER103_FINAL_MANIFEST="$FINAL_MANIFEST"
python3 - <<'PY'
from __future__ import annotations
import hashlib, json, os
from datetime import datetime, timezone
from pathlib import Path

root = Path(os.environ["ORDER103_PROJECT_DIR"])
source = Path(os.environ["ORDER103_SOURCE_SNAPSHOT"])
zip_path = Path(os.environ["ORDER103_FINAL_ZIP"])
app = Path(os.environ["ORDER103_VERIFIED_APP"])
manifest_path = Path(os.environ["ORDER103_FINAL_MANIFEST"])
stem = "GangnamDream-ORDER103-M01M06-ChoicePlaytest"

def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def tree_digest(path: Path) -> tuple[str, int]:
    rows, count = [], 0
    for item in sorted(path.rglob("*"), key=lambda p: p.relative_to(path).as_posix()):
        relative = item.relative_to(path).as_posix()
        if item.is_symlink():
            rows.append(f"link\0{relative}\0{os.readlink(item)}\n".encode())
            count += 1
        elif item.is_file():
            rows.append(f"file\0{relative}\0{digest(item)}\n".encode())
            count += 1
    return hashlib.sha256(b"".join(rows)).hexdigest(), count

copy_map = {
    "tools/order103_export/project.godot": "project.godot",
    "tools/order103_export/export_presets.cfg": "export_presets.cfg",
    "tools/order103_export/Entry.tscn": "order103/Entry.tscn",
    "tools/order103_export/Entry.gd": "order103/Entry.gd",
    "tools/order103_export/AudioManagerStub.gd": "order103/AudioManagerStub.gd",
}
wrapper = []
for src, dst in copy_map.items():
    path = source / src
    wrapper.append({
        "source_path": src, "destination_path": dst,
        "sha256": digest(path), "size_bytes": path.stat().st_size,
    })
resources = []
for raw in (source / "tools/order103_export/resources.txt").read_text(encoding="utf-8").splitlines():
    if not raw or raw.startswith("#"):
        continue
    path = source / raw
    resources.append({"path": raw, "sha256": digest(path), "size_bytes": path.stat().st_size})
payload_rows = []
for item in wrapper:
    payload_rows.append(f"wrapper\0{item['source_path']}\0{item['destination_path']}\0{item['sha256']}\n".encode())
for item in resources:
    payload_rows.append(f"resource\0{item['path']}\0{item['sha256']}\n".encode())
payload_hash = hashlib.sha256(b"".join(sorted(payload_rows))).hexdigest()
app_hash, app_files = tree_digest(app)
launcher = app / "Contents/MacOS" / stem
pck = app / "Contents/Resources" / f"{stem}.pck"
payload = {
    "schema_version": 1,
    "profile": "order103_m1m6_playtest",
    "game_version": "0.1.0-dev",
    "build_id": "2026.08.24.1",
    "build_flavor": "story_map_m1m6_playtest",
    "save_namespace": "story_map_m1m6_playtest_v1",
    "save_schema_version": 1,
    "source": {
        "requested_ref": os.environ["ORDER103_SOURCE_REF"],
        "revision": os.environ["ORDER103_SOURCE_COMMIT"],
        "tree": os.environ["ORDER103_SOURCE_TREE"],
        "status": "clean",
    },
    "engine": {"version": os.environ["ORDER103_GODOT_VERSION"]},
    "application": {
        "name": stem,
        "bundle_identifier": "dev.junheelee.gangnamdream.storymapm1m6",
        "entry_scene": "res://order103/Entry.tscn",
        "playtest_scene": "res://tools/StoryMapM1M6Playtest.tscn",
        "custom_user_dir_name": "GangnamDream_ORDER103_M01M06_v1",
        "autosave_path": "user://story_map_m1m6_playtest_autosave.json",
    },
    "inputs": {
        "resources_manifest": {
            "path": "tools/order103_export/resources.txt",
            "sha256": digest(source / "tools/order103_export/resources.txt"),
        },
        "wrapper": wrapper,
        "resources": resources,
        "payload_sha256": payload_hash,
    },
    "package": {
        "zip": {
            "path": "build/order103/macos/GangnamDream-ORDER103-M01M06-ChoicePlaytest.zip",
            "sha256": digest(zip_path), "size_bytes": zip_path.stat().st_size,
        },
        "app": {"name": f"{stem}.app", "tree_sha256": app_hash, "file_count": app_files},
        "launcher": {
            "path": f"{stem}.app/Contents/MacOS/{stem}",
            "sha256": digest(launcher), "size_bytes": launcher.stat().st_size,
        },
        "resource_pack": {
            "path": f"{stem}.app/Contents/Resources/{stem}.pck",
            "sha256": digest(pck), "size_bytes": pck.stat().st_size,
        },
    },
    "validation": {
        "source_import": {"passed": True},
        "targeted_story_map": {"passed": True, "marker": "STORY_MAP_M1M6_CHECK_OK months=6 margin=4 deferred=2 actor=2 save=2 ui=1 disclosure=2"},
        "package_import": {"passed": True},
        "codesign": {"passed": True, "mode": "ad-hoc", "verification": "--deep --strict"},
        "native_no_argument": {"passed": True, "args": [], "marker": os.environ["ORDER103_NATIVE_MARKER"]},
        "package_smokes": [
            {"passed": True, "language": "ko", "size": "1280x800", "marker": "ORDER103_WRAPPER_SMOKE_OK language=ko size=1280x800 save_resume=m02,recap clips=0 scroll=0 auto_assign=0"},
            {"passed": True, "language": "en", "size": "960x600", "marker": "ORDER103_WRAPPER_SMOKE_OK language=en size=960x600 save_resume=m02,recap clips=0 scroll=0 auto_assign=0"},
        ],
        "forbidden_product_resources": {"passed": True},
    },
    "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
manifest_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

MANIFEST_HASH="$(python3 - "$FINAL_MANIFEST" <<'PY'
import hashlib, pathlib, sys
print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
)"
printf '%s  %s\n' "$MANIFEST_HASH" "$MANIFEST_REL" > "$FINAL_CHECKSUM"
python3 "$SOURCE_SNAPSHOT/tools/order103_package_audit.py" --manifest "$FINAL_MANIFEST"

echo "ORDER103_MACOS_BUILD_OK build=$BUILD_ID revision=$SOURCE_COMMIT tree=$SOURCE_TREE"
echo "  $ZIP_REL"
echo "  $MANIFEST_REL"
echo "  $CHECKSUM_REL"

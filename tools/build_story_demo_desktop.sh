#!/bin/bash
## Build the public M01-M06 story demo for Windows or Linux/Steam Deck.
##
## Same fixed-source staging, project rewrite and Godot gates as
## build_story_demo_macos.sh, which stays the single owner of the build
## identity, product revision and gate markers (read below, never copied).
## A new platform package is a new candidate: the manifest records
## user_go=not_inherited until it gets its own review.

set -euo pipefail

usage() {
  echo "usage: GODOT=/path/to/Godot $0 --platform windows|linux --build-id <id> [--source <commit>]" >&2
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MAC_BUILDER="$SCRIPT_DIR/build_story_demo_macos.sh"

PLATFORM=""
BUILD_ID=""
SOURCE_REF="HEAD"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) [[ $# -ge 2 ]] || { usage; exit 2; }; PLATFORM="$2"; shift 2 ;;
    --build-id) [[ $# -ge 2 ]] || { usage; exit 2; }; BUILD_ID="$2"; shift 2 ;;
    --source) [[ $# -ge 2 ]] || { usage; exit 2; }; SOURCE_REF="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "STORY_DEMO_DESKTOP_FAIL: unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

case "$PLATFORM" in
  windows)
    BASE_PRESET="Windows"; BASE_PLATFORM="Windows Desktop"
    PRESET_NAME="Story Demo Windows"; BINARY_NAME="GangnamDream-StoryDemo.exe" ;;
  linux)
    BASE_PRESET="Linux / Steam Deck"; BASE_PLATFORM="Linux/X11"
    PRESET_NAME="Story Demo Linux"; BINARY_NAME="GangnamDream-StoryDemo.x86_64" ;;
  *) echo "STORY_DEMO_DESKTOP_FAIL: --platform must be windows or linux" >&2; usage; exit 2 ;;
esac

# Read the identity and gate contract from the macOS builder (single owner).
mac_constant() {
  local value
  value="$(sed -n "s/^readonly $1=\"\(.*\)\"\$/\1/p" "$MAC_BUILDER")"
  if [[ -z "$value" ]]; then
    echo "STORY_DEMO_DESKTOP_FAIL: $1 missing from $MAC_BUILDER" >&2
    exit 1
  fi
  printf '%s' "$value"
}
EXPECTED_BUILD_ID="$(mac_constant EXPECTED_BUILD_ID)"
EXPECTED_GODOT="$(mac_constant EXPECTED_GODOT)"
PRODUCT_REVISION="$(mac_constant PRODUCT_REVISION)"
PRODUCT_TREE="$(mac_constant PRODUCT_TREE)"
ENTRY_SCENE="$(mac_constant ENTRY_SCENE)"
CHECK_SCENE="$(mac_constant CHECK_SCENE)"
CUSTOM_USER_DIR="$(mac_constant CUSTOM_USER_DIR)"
APP_STEM="$(mac_constant APP_STEM)"
PROFILE="$(mac_constant PROFILE)"
TARGET_MARKER="$(mac_constant TARGET_MARKER)"
SMOKE_MARKER_PREFIX="$(mac_constant SMOKE_MARKER_PREFIX)"
mapfile -t PRODUCT_RUNTIME_SCOPE < <(
  sed -n '/^readonly -a PRODUCT_RUNTIME_SCOPE=(/,/^)/p' "$MAC_BUILDER" \
    | sed '1d;$d' | sed 's/^[[:space:]]*//')
if [[ ${#PRODUCT_RUNTIME_SCOPE[@]} -lt 5 ]]; then
  echo "STORY_DEMO_DESKTOP_FAIL: PRODUCT_RUNTIME_SCOPE could not be read" >&2
  exit 1
fi
FONT_MARKER="FONT_ROUTING_CHECK_OK ko_en=Pretendard ja=NotoSansJP zh_cn=NotoSansSC zh_tw=NotoSansTC weights=400,600,700 emoji=last"
I18N_MARKER="I18N_INFRASTRUCTURE_CHECK_OK targets=3 ui_fallback=en content_fallback=en"
QA_NAME="GangnamDream_StoryDemo_RuntimeQA_desktop_build"

if [[ "$BUILD_ID" != "$EXPECTED_BUILD_ID" ]]; then
  echo "STORY_DEMO_DESKTOP_FAIL: --build-id must be $EXPECTED_BUILD_ID" >&2
  exit 2
fi
if [[ -z "${GODOT:-}" || ! -x "$GODOT" ]]; then
  echo "STORY_DEMO_DESKTOP_FAIL: set GODOT to an executable Godot binary" >&2
  exit 2
fi
for command_name in git tar python3 mktemp sha256sum; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "STORY_DEMO_DESKTOP_FAIL: required command is unavailable: $command_name" >&2
    exit 1
  }
done
GODOT_VERSION="$("$GODOT" --version 2>&1 | head -n 1)"
if [[ "$GODOT_VERSION" != "$EXPECTED_GODOT" ]]; then
  echo "STORY_DEMO_DESKTOP_FAIL: expected Godot $EXPECTED_GODOT, got $GODOT_VERSION" >&2
  exit 1
fi

# Same source identity rules as the macOS builder.
if [[ -n "$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)" ]]; then
  echo "STORY_DEMO_DESKTOP_FAIL: source worktree is dirty; build only from a fixed clean commit" >&2
  exit 1
fi
SOURCE_COMMIT="$(git -C "$PROJECT_DIR" rev-parse --verify "$SOURCE_REF^{commit}")"
SOURCE_TREE="$(git -C "$PROJECT_DIR" rev-parse "$SOURCE_COMMIT^{tree}")"
if [[ "$(git -C "$PROJECT_DIR" rev-parse "$PRODUCT_REVISION^{tree}" 2>/dev/null)" != "$PRODUCT_TREE" ]]; then
  echo "STORY_DEMO_DESKTOP_FAIL: exact product identity $PRODUCT_REVISION is unavailable" >&2
  exit 1
fi
if ! git -C "$PROJECT_DIR" merge-base --is-ancestor "$PRODUCT_REVISION" "$SOURCE_COMMIT"; then
  echo "STORY_DEMO_DESKTOP_FAIL: package source is not a descendant of the exact product commit" >&2
  exit 1
fi
if ! git -C "$PROJECT_DIR" diff --quiet --no-ext-diff \
    "$PRODUCT_REVISION" "$SOURCE_COMMIT" -- "${PRODUCT_RUNTIME_SCOPE[@]}"; then
  echo "STORY_DEMO_DESKTOP_FAIL: package source changes the protected product/runtime scope" >&2
  git -C "$PROJECT_DIR" diff --name-only --no-ext-diff \
    "$PRODUCT_REVISION" "$SOURCE_COMMIT" -- "${PRODUCT_RUNTIME_SCOPE[@]}" | sed 's/^/  /' >&2
  exit 1
fi

case "$(uname -s)" in
  Linux) HOST=linux; USER_DATA_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
  MINGW*|MSYS*|CYGWIN*) HOST=windows; USER_DATA_ROOT="${APPDATA:?APPDATA is not set}" ;;
  Darwin) HOST=macos; USER_DATA_ROOT="$HOME/Library/Application Support" ;;
  *) HOST=other; USER_DATA_ROOT="" ;;
esac
QA_USER_DATA_DIR="$USER_DATA_ROOT/$QA_NAME"
remove_qa_dir() {
  if [[ -n "$USER_DATA_ROOT" && -e "$QA_USER_DATA_DIR" ]]; then
    rm -rf "$QA_USER_DATA_DIR"
  fi
}

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/story-demo-$PLATFORM.XXXXXX")"
trap 'rm -rf "$WORK_DIR"; remove_qa_dir' EXIT
STAGE_PROJECT="$WORK_DIR/project"
EXPORT_DIR="$WORK_DIR/export"
LOG_DIR="$WORK_DIR/logs"
mkdir -p "$STAGE_PROJECT" "$EXPORT_DIR" "$LOG_DIR"
git -C "$PROJECT_DIR" archive --format=tar "$SOURCE_COMMIT" | tar -xf - -C "$STAGE_PROJECT"

# Rewrite only the staged copy: same application keys as macOS, and a preset
# derived from the product platform preset (never the legacy "* Demo" ones).
python3 - "$STAGE_PROJECT" "$BASE_PRESET" "$BASE_PLATFORM" "$PRESET_NAME" \
    "$BINARY_NAME" "$APP_STEM" "$ENTRY_SCENE" "$CUSTOM_USER_DIR" "$PLATFORM" <<'PY'
import re, sys
from pathlib import Path

stage, base, base_platform, preset_name, binary, stem, entry, user_dir, platform = sys.argv[1:]
root = Path(stage)

def set_value(text, section, key, value):
    match = re.search(rf"(?ms)^\[{re.escape(section)}\]\s*$\n(.*?)(?=^\[|\Z)", text)
    if match is None:
        raise SystemExit(f"STORY_DEMO_DESKTOP_FAIL: missing section [{section}]")
    body = match.group(1)
    pattern = re.compile(rf"(?m)^{re.escape(key)}=.*$")
    line = f"{key}={value}"
    body = pattern.sub(line, body, count=1) if pattern.search(body) \
        else body.rstrip("\n") + "\n" + line + "\n\n"
    return text[:match.start(1)] + body + text[match.end(1):]

project = (root / "project.godot").read_text(encoding="utf-8")
for key, value in (
    ("config/name", f'"{stem}"'),
    ("run/main_scene", f'"{entry}"'),
    ("config/use_custom_user_dir", "true"),
    ("config/custom_user_dir_name", f'"{user_dir}"'),
    ("boot_splash/show_image", "false"),
    ("boot_splash/image", '""'),
):
    project = set_value(project, "application", key, value)
(root / "project.godot").write_text(project, encoding="utf-8")

presets = (root / "export_presets.cfg").read_text(encoding="utf-8")
number = None
for match in re.finditer(r"(?m)^\[preset\.(\d+)\]$", presets):
    body = re.search(rf"(?ms)^\[preset\.{match.group(1)}\]\s*$\n(.*?)(?=^\[|\Z)", presets).group(1)
    if re.search(rf'(?m)^name="{re.escape(base)}"$', body) \
            and re.search(rf'(?m)^platform="{re.escape(base_platform)}"$', body):
        number = match.group(1)
        break
if number is None:
    raise SystemExit(f"STORY_DEMO_DESKTOP_FAIL: product preset {base!r} not found")
presets = set_value(presets, f"preset.{number}", "name", f'"{preset_name}"')
presets = set_value(presets, f"preset.{number}", "export_path",
                    f'"build/story_demo/{platform}/{binary}"')
if platform == "windows":
    for key, value in (
        ("application/company_name", '"Junpac Games"'),
        ("application/product_name", '"Gangnam Dream Story Demo"'),
    ):
        presets = set_value(presets, f"preset.{number}.options", key, value)
(root / "export_presets.cfg").write_text(presets, encoding="utf-8")
PY

run_gate() {
  local log="$1" marker="$2"
  shift 2
  local code=0
  "$@" >"$log" 2>&1 || code=$?
  if [[ $code -ne 0 ]] \
      || grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$log" \
      || ! grep -Fq "$marker" "$log"; then
    echo "STORY_DEMO_DESKTOP_FAIL: gate failed (exit=$code, expected=$marker)" >&2
    sed -n '1,200p' "$log" >&2
    exit 1
  fi
}

if ! "$GODOT" --headless --path "$STAGE_PROJECT" --import >"$LOG_DIR/import.log" 2>&1 \
    || grep -Eq 'SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|^ERROR:' "$LOG_DIR/import.log"; then
  echo "STORY_DEMO_DESKTOP_FAIL: fixed-source import failed" >&2
  sed -n '1,200p' "$LOG_DIR/import.log" >&2
  exit 1
fi
remove_qa_dir
run_gate "$LOG_DIR/target.log" "$TARGET_MARKER" \
  env STORY_DEMO_ALLOW_ISOLATED_QA=1 STORY_DEMO_QA_BOOTSTRAP_NAME="$QA_NAME" \
  "$GODOT" --headless --path "$STAGE_PROJECT" --quit-after 3600 "$CHECK_SCENE"
remove_qa_dir
run_gate "$LOG_DIR/font.log" "$FONT_MARKER" \
  "$GODOT" --headless --path "$STAGE_PROJECT" res://tools/FontRoutingCheck.tscn
run_gate "$LOG_DIR/i18n.log" "$I18N_MARKER" \
  "$GODOT" --headless --path "$STAGE_PROJECT" res://tools/I18nInfrastructureCheck.tscn

EXPORTED="$EXPORT_DIR/$BINARY_NAME"
if ! "$GODOT" --headless --path "$STAGE_PROJECT" --export-release \
    "$PRESET_NAME" "$EXPORTED" >"$LOG_DIR/export.log" 2>&1 || [[ ! -s "$EXPORTED" ]]; then
  echo "STORY_DEMO_DESKTOP_FAIL: $PLATFORM release export failed" >&2
  sed -n '1,200p' "$LOG_DIR/export.log" >&2
  exit 1
fi

# Native smoke only when the host can run the exported binary.
NATIVE_SMOKE="not_run_host_$HOST"
if [[ "$HOST" == "$PLATFORM" ]]; then
  [[ "$PLATFORM" == "linux" ]] && chmod +x "$EXPORTED"
  LAUNCH=("$EXPORTED")
  if [[ "$PLATFORM" == "linux" && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    command -v xvfb-run >/dev/null 2>&1 || {
      echo "STORY_DEMO_DESKTOP_FAIL: no display for native smoke; install xvfb-run or run on a desktop" >&2
      exit 1
    }
    LAUNCH=(xvfb-run -a "$EXPORTED")
  fi
  for language in ko en ja zh-CN zh-TW; do
    remove_qa_dir
    run_gate "$LOG_DIR/smoke-$language.log" "$SMOKE_MARKER_PREFIX" \
      env STORY_DEMO_ALLOW_ISOLATED_QA=1 STORY_DEMO_QA_BOOTSTRAP_NAME="$QA_NAME" \
      "${LAUNCH[@]}" --rendering-driver opengl3 --resolution 1280x800 \
      -- --qa=story-demo --story-demo-smoke --story-demo-language="$language"
  done
  remove_qa_dir
  NATIVE_SMOKE="pass_ko_en_ja_zh-CN_zh-TW"
fi

OUT_DIR="$PROJECT_DIR/build/story_demo/$PLATFORM"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
cp "$EXPORT_DIR"/* "$OUT_DIR"/
ZIP_PATH="$PROJECT_DIR/build/story_demo/$APP_STEM-$PLATFORM.zip"
rm -f "$ZIP_PATH"
python3 - "$OUT_DIR" "$ZIP_PATH" <<'PY'
import sys, zipfile
from pathlib import Path
src, dst = Path(sys.argv[1]), Path(sys.argv[2])
with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(src.iterdir()):
        info = zipfile.ZipInfo(path.name, date_time=(2026, 1, 1, 0, 0, 0))
        info.external_attr = (0o755 if path.suffix != ".pck" else 0o644) << 16
        archive.writestr(info, path.read_bytes(), zipfile.ZIP_DEFLATED)
PY

MANIFEST="$PROJECT_DIR/build/story_demo/MANIFEST-$PLATFORM.json"
python3 - "$MANIFEST" "$ZIP_PATH" "$OUT_DIR" <<PY
import hashlib, json, sys
from pathlib import Path
manifest, zip_path, out_dir = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
manifest.write_text(json.dumps({
    "profile": "$PROFILE",
    "platform": "$PLATFORM",
    "preset": "$PRESET_NAME",
    "build_id": "$BUILD_ID",
    "godot": "$GODOT_VERSION",
    "product_revision": "$PRODUCT_REVISION",
    "source_commit": "$SOURCE_COMMIT",
    "source_tree": "$SOURCE_TREE",
    "files": {p.name: digest(p) for p in sorted(out_dir.iterdir())},
    "zip_sha256": digest(zip_path),
    "gates": ["target", "font_routing", "i18n_infrastructure"],
    "native_smoke": "$NATIVE_SMOKE",
    "user_go": "not_inherited",
}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
echo "STORY_DEMO_DESKTOP_BUILD_OK platform=$PLATFORM build=$BUILD_ID source=$SOURCE_COMMIT native_smoke=$NATIVE_SMOKE zip=${ZIP_PATH#$PROJECT_DIR/}"

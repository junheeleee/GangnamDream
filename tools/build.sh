#!/bin/bash
## build.sh — 강남드림 빌드 스크립트
## 사용법:
##   ./tools/build.sh web      → build/web/index.html
##   ./tools/build.sh macos    → build/macos/GangnamDream.zip
##   ./tools/build.sh windows  → build/windows/GangnamDream.exe (Steam용)
##   ./tools/build.sh demo     → legacy 데모 계약 + Win/macOS/Linux 데모 + 체크섬
##   ./tools/build.sh playtest → V2 계약 + Win/macOS/Linux playtest + 체크섬
##   ./tools/build.sh all      → 전부
##
## 전제조건:
##   Godot.app이 ~/Downloads/Godot.app 또는 /Applications/Godot.app에 있어야 함
##   Export Templates가 설치돼 있어야 함
##   → Godot 에디터 열기 > Editor 메뉴 > Manage Export Templates > Download
##     (버전: 4.6.2.stable)

set -euo pipefail

# GODOT=경로 환경변수가 있으면 우선 사용 (audit.sh와 동일)
GODOT="${GODOT:-}"
if [[ -z "$GODOT" ]]; then
  GODOT_PATHS=(
    "$HOME/Downloads/Godot.app/Contents/MacOS/Godot"
    "/Applications/Godot.app/Contents/MacOS/Godot"
    "/Applications/Godot_4.app/Contents/MacOS/Godot"
  )
  for p in "${GODOT_PATHS[@]}"; do
    if [[ -x "$p" ]]; then GODOT="$p"; break; fi
  done
fi

if [[ -z "$GODOT" || ! -x "$GODOT" ]]; then
  echo "❌ Godot 바이너리를 찾지 못했습니다."
  echo "   ~/Downloads/Godot.app 또는 /Applications/Godot.app에 설치하거나"
  echo "   GODOT=/경로/Godot ./tools/build.sh 로 지정하세요."
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "📂 프로젝트: $PROJECT_DIR"
echo "🔧 Godot:    $GODOT ($("$GODOT" --version 2>&1 | head -1))"
TARGET="${1:-web}"

require_clean_playtest_source() {
  if ! command -v git >/dev/null 2>&1 || \
      ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ 공개 플레이테스트 빌드는 Git 커밋에서만 만들 수 있습니다."
    exit 1
  fi

  local source_status
  source_status=$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all)
  if [[ -n "$source_status" ]]; then
    echo "❌ 플레이테스트 RC 빌드 거부: 작업트리가 깨끗하지 않습니다."
    echo "$source_status" | sed 's/^/   /'
    echo "   변경을 커밋하거나 별도 clean worktree에서 다시 실행하세요."
    exit 1
  fi
}

prepare_playtest_imports() {
  echo ""
  echo "📦 clean checkout 리소스·전역 클래스 import 준비..."
  local output
  local exit_code=0
  if output=$("$GODOT" --headless --path "$PROJECT_DIR" --import 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi

  local import_errors
  import_errors=$(echo "$output" | grep -E \
    "SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource" || true)
  if [[ "$exit_code" -ne 0 || -n "$import_errors" ]]; then
    echo "❌ clean checkout import 실패 (exit=$exit_code)"
    echo "$output"
    exit 1
  fi
  echo "✅ clean checkout import 완료"
}

# 템플릿 확인 (macOS / Linux 경로 모두 지원)
TEMPLATES_DIR="$HOME/Library/Application Support/Godot/export_templates"
if [[ ! -d "$TEMPLATES_DIR" ]]; then
  TEMPLATES_DIR="$HOME/.local/share/godot/export_templates"
fi
if [[ "$TARGET" != "demo-check" && "$TARGET" != "playtest-check" \
    && -z "$(ls "$TEMPLATES_DIR" 2>/dev/null)" ]]; then
  echo ""
  echo "⚠️  Export Templates가 설치되지 않았습니다."
  echo "   설치 방법:"
  echo "   1. Godot 에디터 실행"
  echo "   2. Editor 메뉴 → Manage Export Templates"
  echo "   3. Download (4.6.2.stable) 클릭"
  echo "   또는 수동 다운로드:"
  echo "   https://github.com/godotengine/godot/releases/download/4.6.2-stable/Godot_v4.6.2-stable_export_templates.tpz"
  echo "   → 다운로드 후 위 다이얼로그에서 'Install from File' 선택"
  exit 1
fi

build_web() {
  echo ""
  echo "🌐 Web 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/web"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "Web" "$PROJECT_DIR/build/web/index.html" 2>&1
  if [[ -f "$PROJECT_DIR/build/web/index.html" ]]; then
    SIZE=$(du -sh "$PROJECT_DIR/build/web" | cut -f1)
    echo "✅ Web 빌드 완료 → build/web/ ($SIZE)"
    echo "   로컬 테스트: python3 -m http.server 8000 --directory build/web"
  else
    echo "❌ Web 빌드 실패"
    exit 1
  fi
}

build_macos() {
  echo ""
  echo "🍎 macOS 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/macos"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "macOS" "$PROJECT_DIR/build/macos/GangnamDream.zip" 2>&1
  if [[ -f "$PROJECT_DIR/build/macos/GangnamDream.zip" ]]; then
    SIZE=$(du -sh "$PROJECT_DIR/build/macos/GangnamDream.zip" | cut -f1)
    echo "✅ macOS 빌드 완료 → build/macos/GangnamDream.zip ($SIZE)"
  else
    echo "❌ macOS 빌드 실패"
    exit 1
  fi
}

build_windows() {
  echo ""
  echo "🪟 Windows 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/windows"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "Windows" "$PROJECT_DIR/build/windows/GangnamDream.exe" 2>&1
  if [[ -f "$PROJECT_DIR/build/windows/GangnamDream.exe" ]]; then
    SIZE=$(du -sh "$PROJECT_DIR/build/windows/" | cut -f1)
    echo "✅ Windows 빌드 완료 → build/windows/GangnamDream.exe ($SIZE)"
    echo "   Steam 업로드: build/windows/ 폴더 전체 압축"
  else
    echo "❌ Windows 빌드 실패"
    echo "   Windows export template 필요:"
    echo "   Godot 에디터 > Editor > Manage Export Templates > Download"
    exit 1
  fi
}

build_linux() {
  echo ""
  echo "🐧 Linux / Steam Deck 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/linux"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "Linux / Steam Deck" "$PROJECT_DIR/build/linux/GangnamDream.x86_64" 2>&1
  if [[ -f "$PROJECT_DIR/build/linux/GangnamDream.x86_64" ]]; then
    chmod +x "$PROJECT_DIR/build/linux/GangnamDream.x86_64"
    SIZE=$(du -sh "$PROJECT_DIR/build/linux/" | cut -f1)
    echo "✅ Linux 빌드 완료 → build/linux/GangnamDream.x86_64 ($SIZE)"
    echo "   Steam Deck: Depots에 이 파일 업로드 (Linux 전용 depot 권장)"
  else
    echo "❌ Linux 빌드 실패"
    exit 1
  fi
}

run_demo_contract() {
  echo ""
  echo "🧪 데모 flavor·1~8주·24주 차단 계약 검사..."
  local output
  local exit_code=0
  if output=$("$GODOT" --headless --path "$PROJECT_DIR" --quit-after 3600 \
      res://tools/DemoBuildCheck.tscn -- --demo-build 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  local runtime_errors
  runtime_errors=$(echo "$output" | grep -E \
    "DEMO_BUILD_CHECK_FAIL|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|ERROR:" || true)
  echo "$output" | grep -E \
    "DEMO_BUILD_(CHECK_OK|CHECK_FAIL)|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|ERROR:" || true
  if [[ "$exit_code" -ne 0 || -n "$runtime_errors" ]] \
      || ! echo "$output" | grep -Eq '^DEMO_BUILD_CHECK_OK([[:space:]]|$)'; then
    echo "❌ 데모 계약 검사 실패 (exit=$exit_code)"
    echo "$output"
    exit 1
  fi
}

run_playtest_contract() {
  echo ""
  echo "🧪 V2 playtest flavor·진입·세이브 분리 계약 검사..."
  local output
  local exit_code=0
  if output=$("$GODOT" --headless --path "$PROJECT_DIR" --quit-after 3600 \
      res://tools/PlaytestFlavorCheck.tscn -- \
      --demo-build --core-loop-v2-playtest-build 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  local runtime_errors
  runtime_errors=$(echo "$output" | grep -E \
    "PLAYTEST_FLAVOR_CHECK_FAIL|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|ERROR:" || true)
  echo "$output" | grep -E \
    "PLAYTEST_FLAVOR_CHECK_(OK|FAIL)|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|Failed loading resource|ERROR:" || true
  if [[ "$exit_code" -ne 0 || -n "$runtime_errors" ]] \
      || ! echo "$output" | grep -Eq '^PLAYTEST_FLAVOR_CHECK_OK([[:space:]]|$)'; then
    echo "❌ V2 playtest 계약 검사 실패 (exit=$exit_code)"
    echo "$output"
    exit 1
  fi
}

build_windows_demo() {
  echo ""
  echo "🪟 Windows 데모 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/demo/windows"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "Windows Demo" \
    "$PROJECT_DIR/build/demo/windows/GangnamDreamDemo.exe" 2>&1
  if [[ ! -f "$PROJECT_DIR/build/demo/windows/GangnamDreamDemo.exe" ]]; then
    echo "❌ Windows 데모 빌드 실패"
    exit 1
  fi
  echo "✅ Windows 데모 → build/demo/windows/ ($(du -sh "$PROJECT_DIR/build/demo/windows" | cut -f1))"
}

build_macos_demo() {
  echo ""
  echo "🍎 macOS 데모 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/demo/macos"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "macOS Demo" \
    "$PROJECT_DIR/build/demo/macos/GangnamDreamDemo.zip" 2>&1
  if [[ ! -f "$PROJECT_DIR/build/demo/macos/GangnamDreamDemo.zip" ]]; then
    echo "❌ macOS 데모 빌드 실패"
    exit 1
  fi
  echo "✅ macOS 데모 → build/demo/macos/GangnamDreamDemo.zip ($(du -sh "$PROJECT_DIR/build/demo/macos/GangnamDreamDemo.zip" | cut -f1))"
}

build_linux_demo() {
  echo ""
  echo "🐧 Linux / Steam Deck 데모 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/demo/linux"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "Linux / Steam Deck Demo" \
    "$PROJECT_DIR/build/demo/linux/GangnamDreamDemo.x86_64" 2>&1
  if [[ ! -f "$PROJECT_DIR/build/demo/linux/GangnamDreamDemo.x86_64" ]]; then
    echo "❌ Linux 데모 빌드 실패"
    exit 1
  fi
  chmod +x "$PROJECT_DIR/build/demo/linux/GangnamDreamDemo.x86_64"
  echo "✅ Linux 데모 → build/demo/linux/ ($(du -sh "$PROJECT_DIR/build/demo/linux" | cut -f1))"
}

build_windows_playtest() {
  echo ""
  echo "🪟 Windows V2 playtest 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/playtest/windows"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "Windows V2 Playtest" \
    "$PROJECT_DIR/build/playtest/windows/GangnamDreamV2Playtest.exe" 2>&1
  if [[ ! -f "$PROJECT_DIR/build/playtest/windows/GangnamDreamV2Playtest.exe" ]]; then
    echo "❌ Windows V2 playtest 빌드 실패"
    exit 1
  fi
  echo "✅ Windows V2 playtest → build/playtest/windows/ ($(du -sh "$PROJECT_DIR/build/playtest/windows" | cut -f1))"
}

build_macos_playtest() {
  echo ""
  echo "🍎 macOS V2 playtest 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/playtest/macos"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release "macOS V2 Playtest" \
    "$PROJECT_DIR/build/playtest/macos/GangnamDreamV2Playtest.zip" 2>&1
  if [[ ! -f "$PROJECT_DIR/build/playtest/macos/GangnamDreamV2Playtest.zip" ]]; then
    echo "❌ macOS V2 playtest 빌드 실패"
    exit 1
  fi
  echo "✅ macOS V2 playtest → build/playtest/macos/GangnamDreamV2Playtest.zip ($(du -sh "$PROJECT_DIR/build/playtest/macos/GangnamDreamV2Playtest.zip" | cut -f1))"
}

build_linux_playtest() {
  echo ""
  echo "🐧 Linux / Steam Deck V2 playtest 빌드 시작..."
  mkdir -p "$PROJECT_DIR/build/playtest/linux"
  "$GODOT" --headless --path "$PROJECT_DIR" --export-release \
    "Linux / Steam Deck V2 Playtest" \
    "$PROJECT_DIR/build/playtest/linux/GangnamDreamV2Playtest.x86_64" 2>&1
  if [[ ! -f "$PROJECT_DIR/build/playtest/linux/GangnamDreamV2Playtest.x86_64" ]]; then
    echo "❌ Linux V2 playtest 빌드 실패"
    exit 1
  fi
  chmod +x "$PROJECT_DIR/build/playtest/linux/GangnamDreamV2Playtest.x86_64"
  echo "✅ Linux V2 playtest → build/playtest/linux/ ($(du -sh "$PROJECT_DIR/build/playtest/linux" | cut -f1))"
}

write_demo_manifest() {
  local manifest="$PROJECT_DIR/build/demo/MANIFEST.sha256"
  local revision="unknown"
  local tree="unknown"
  if command -v git >/dev/null 2>&1; then
    revision=$(git -C "$PROJECT_DIR" rev-parse HEAD 2>/dev/null || printf 'unknown')
    tree=$(git -C "$PROJECT_DIR" rev-parse 'HEAD^{tree}' 2>/dev/null || printf 'unknown')
  fi
  {
    echo "# Gangnam Dream legacy demo build"
    echo "# revision=$revision"
    echo "# tree=$tree"
    echo "# source_status=clean"
    echo "# godot=$($GODOT --version 2>&1 | head -1)"
    echo "# generated_utc=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    for artifact in \
      "$PROJECT_DIR/build/demo/windows/GangnamDreamDemo.exe" \
      "$PROJECT_DIR/build/demo/macos/GangnamDreamDemo.zip" \
      "$PROJECT_DIR/build/demo/linux/GangnamDreamDemo.x86_64"; do
      shasum -a 256 "$artifact" | sed "s|$PROJECT_DIR/||"
    done
  } > "$manifest"
  echo "✅ 체크섬 매니페스트 → build/demo/MANIFEST.sha256"
}

write_playtest_manifest() {
  local manifest="$PROJECT_DIR/build/playtest/MANIFEST.sha256"
  local revision="unknown"
  local tree="unknown"
  if command -v git >/dev/null 2>&1; then
    revision=$(git -C "$PROJECT_DIR" rev-parse HEAD 2>/dev/null || printf 'unknown')
    tree=$(git -C "$PROJECT_DIR" rev-parse 'HEAD^{tree}' 2>/dev/null || printf 'unknown')
  fi
  {
    echo "# Gangnam Dream Core Loop V2 playtest build"
    echo "# flavor=core_loop_v2_playtest"
    echo "# features=gangnam_demo,core_loop_v2_playtest"
    echo "# revision=$revision"
    echo "# tree=$tree"
    echo "# source_status=clean"
    echo "# godot=$($GODOT --version 2>&1 | head -1)"
    echo "# generated_utc=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    for artifact in \
      "$PROJECT_DIR/build/playtest/windows/GangnamDreamV2Playtest.exe" \
      "$PROJECT_DIR/build/playtest/macos/GangnamDreamV2Playtest.zip" \
      "$PROJECT_DIR/build/playtest/linux/GangnamDreamV2Playtest.x86_64"; do
      shasum -a 256 "$artifact" | sed "s|$PROJECT_DIR/||"
    done
  } > "$manifest"
  echo "✅ V2 playtest 체크섬 매니페스트 → build/playtest/MANIFEST.sha256"
}

build_demo() {
  require_clean_playtest_source
  prepare_playtest_imports
  require_clean_playtest_source
  run_demo_contract
  build_windows_demo
  build_macos_demo
  build_linux_demo
  require_clean_playtest_source
  write_demo_manifest
}

build_playtest() {
  require_clean_playtest_source
  prepare_playtest_imports
  require_clean_playtest_source
  run_demo_contract
  run_playtest_contract
  build_windows_playtest
  build_macos_playtest
  build_linux_playtest
  require_clean_playtest_source
  write_playtest_manifest
}

case "$TARGET" in
  web)     build_web ;;
  macos)   build_macos ;;
  windows) build_windows ;;
  linux)   build_linux ;;
  demo-check) run_demo_contract ;;
  playtest-check) run_demo_contract; run_playtest_contract ;;
  windows-demo) run_demo_contract; build_windows_demo ;;
  macos-demo) run_demo_contract; build_macos_demo ;;
  linux-demo) run_demo_contract; build_linux_demo ;;
  windows-playtest) run_demo_contract; run_playtest_contract; build_windows_playtest ;;
  macos-playtest) run_demo_contract; run_playtest_contract; build_macos_playtest ;;
  linux-playtest) run_demo_contract; run_playtest_contract; build_linux_playtest ;;
  demo)     build_demo ;;
  playtest) build_playtest ;;
  all)     build_web; build_macos; build_windows; build_linux ;;
  *)
    echo "사용법: $0 [web|macos|windows|linux|all|demo|demo-check|windows-demo|macos-demo|linux-demo|playtest|playtest-check|windows-playtest|macos-playtest|linux-playtest]"
    exit 1
    ;;
esac

echo ""
echo "🎉 빌드 완료"

#!/bin/bash
## build.sh — 강남드림 빌드 스크립트
## 사용법:
##   ./tools/build.sh web      → build/web/index.html
##   ./tools/build.sh macos    → build/macos/GangnamDream.zip
##   ./tools/build.sh windows  → build/windows/GangnamDream.exe (Steam용)
##   ./tools/build.sh all      → 전부
##
## 전제조건:
##   Godot.app이 ~/Downloads/Godot.app 또는 /Applications/Godot.app에 있어야 함
##   Export Templates가 설치돼 있어야 함
##   → Godot 에디터 열기 > Editor 메뉴 > Manage Export Templates > Download
##     (버전: 4.6.2.stable)

set -e

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

# 템플릿 확인 (macOS / Linux 경로 모두 지원)
TEMPLATES_DIR="$HOME/Library/Application Support/Godot/export_templates"
if [[ ! -d "$TEMPLATES_DIR" ]]; then
  TEMPLATES_DIR="$HOME/.local/share/godot/export_templates"
fi
if [[ -z "$(ls "$TEMPLATES_DIR" 2>/dev/null)" ]]; then
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

TARGET="${1:-web}"

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

case "$TARGET" in
  web)     build_web ;;
  macos)   build_macos ;;
  windows) build_windows ;;
  linux)   build_linux ;;
  all)     build_web; build_macos; build_windows; build_linux ;;
  *)
    echo "사용법: $0 [web|macos|windows|linux|all]"
    exit 1
    ;;
esac

echo ""
echo "🎉 빌드 완료"

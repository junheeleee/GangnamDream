#!/usr/bin/env bash
# 강남드림 통합 정적 감사 — 커밋 전에 돌린다.
#   ./tools/audit.sh
# 1) tools/audit.py  : dangling 호출, 폐기 키워드, 이벤트 JSON 무결성
# 2) Godot 헤드리스   : GDScript 파싱 에러
set -uo pipefail
cd "$(dirname "$0")/.."

GODOT="${GODOT:-/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot}"

echo "──────────────────────────────────────────"
python3 tools/audit.py
PY_EXIT=$?

echo "──────────────────────────────────────────"
python3 tools/surface_emoji_audit.py
SURFACE_EXIT=$?

echo "──────────────────────────────────────────"
python3 tools/balance_check.py
BAL_EXIT=$?

echo "──────────────────────────────────────────"
echo "● Godot 전체 스크립트 컴파일 체크 (씬 부팅 → 모든 .gd load 강제 컴파일)"
# 주의: --quit-after 2(메인씬 부팅)는 RaceTrack/MainGame 등 부팅 시 미로드 스크립트를
# 컴파일하지 않아 컴파일 버그를 놓친다(게다가 macOS엔 timeout 바이너리도 없어 헛돌았음).
# CompileCheck.tscn은 오토로드·class_name이 모두 등록된 상태에서 전체 .gd를 load()해
# 함수 본문까지 완전 컴파일한다 → 깨진 스크립트는 stderr에 'Failed to load script'.
if [ -x "$GODOT" ]; then
  # 1) 에디터 부팅으로 class_name 글로벌 캐시 최신화(스태일 캐시발 콜드 크래시 예방)
  command -v gtimeout >/dev/null 2>&1 && GT="gtimeout 150" || GT=""
  $GT "$GODOT" --headless --editor --quit-after 30 >/dev/null 2>&1
  # 2) 씬 부팅으로 전 스크립트 강제 컴파일
  RAW=$($GT "$GODOT" --headless res://tools/CompileCheck.tscn 2>&1)
  echo "$RAW" | grep -E "COMPILE_SCAN" | sed 's/^/  /'
  GD_OUT=$(echo "$RAW" | grep -v "COMPILE_SCAN" \
    | grep -iE "Failed to load script|Parse Error|Compile Error" \
    | grep -viE "Cannot open|No loader|\.png|\.ogg|\.mp3|AudioStream|texture|\.import")
  if [ -n "$GD_OUT" ]; then
    echo "  ✗ 컴파일 에러:"
    echo "$GD_OUT" | sed 's/^/    /' | head -20
    GD_EXIT=1
  else
    echo "  ✓ 전체 컴파일 깨끗 (모든 스크립트)"
    GD_EXIT=0
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 컴파일 체크 건너뜀. GODOT=경로 로 지정 가능."
  GD_EXIT=0
fi

echo "──────────────────────────────────────────"
if [ "$PY_EXIT" -ne 0 ] || [ "$SURFACE_EXIT" -ne 0 ] || [ "$BAL_EXIT" -ne 0 ] || [ "$GD_EXIT" -ne 0 ]; then
  echo "❌ 감사 실패 — 위 ERROR를 고치고 다시 돌리세요."
  exit 1
fi
echo "✅ 감사 통과"

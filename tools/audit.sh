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
echo "● Godot 헤드리스 파싱 체크"
if [ -x "$GODOT" ]; then
  GD_OUT=$(timeout 40 "$GODOT" --headless --quit-after 2 2>&1 \
    | grep -iE "SCRIPT ERROR|Parse Error|error\(|expected|Compile Error" \
    | grep -v "Cannot open\|No loader\|texture\|\.png\|\.ogg\|\.mp3\|AudioStream\|Identifier not found: GameState")
  if [ -n "$GD_OUT" ]; then
    echo "  ✗ 파싱 에러:"
    echo "$GD_OUT" | sed 's/^/    /'
    GD_EXIT=1
  else
    echo "  ✓ 파싱 깨끗"
    GD_EXIT=0
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 파싱 체크 건너뜀. GODOT=경로 로 지정 가능."
  GD_EXIT=0
fi

echo "──────────────────────────────────────────"
if [ "$PY_EXIT" -ne 0 ] || [ "$GD_EXIT" -ne 0 ]; then
  echo "❌ 감사 실패 — 위 ERROR를 고치고 다시 돌리세요."
  exit 1
fi
echo "✅ 감사 통과"

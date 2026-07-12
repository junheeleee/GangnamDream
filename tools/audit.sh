#!/usr/bin/env bash
# 강남드림 통합 정적 감사 — 커밋 전에 돌린다.
#   ./tools/audit.sh
# 1) tools/audit.py  : dangling 호출, 폐기 키워드, 이벤트 JSON 무결성
# 2) Godot 헤드리스   : GDScript 파싱 에러
set -uo pipefail
cd "$(dirname "$0")/.."

GODOT="${GODOT:-/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot}"

# macOS 기본 셸에는 GNU timeout이 없다. Godot가 결과를 출력한 뒤 종료를
# 놓치더라도 감사 프로세스가 몇 시간씩 남지 않도록 동일한 제한을 보장한다.
run_limited() {
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout 150 "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout 150 "$@"
  elif command -v perl >/dev/null 2>&1; then
    perl -e '$seconds = shift; alarm $seconds; exec @ARGV' 150 "$@"
  else
    "$@"
  fi
}

echo "──────────────────────────────────────────"
python3 tools/audit.py
PY_EXIT=$?

echo "──────────────────────────────────────────"
python3 tools/surface_emoji_audit.py
SURFACE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 첫 세션 입력 밀도/프롤로그 체인 검사"
python3 tools/first_session_pacing_audit.py
PACING_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 타이틀/IP 키아트 소유권·스토어 크롭 검사"
python3 tools/keyart_asset_check.py
KEY_ART_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 활성 CG 카메라·시선·연기 계약 검사"
python3 tools/cg_acting_contract_check.py
CG_ACTING_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 이벤트 장소·계절·의상 계약 검사"
python3 tools/event_visual_contract_check.py
EVENT_VISUAL_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 영어 표면/커버리지 검사"
python3 tools/english_hangul_audit.py
EN_HANGUL_EXIT=$?
python3 tools/en_coverage_check.py
EN_COVERAGE_EXIT=$?

echo "──────────────────────────────────────────"
python3 tools/balance_check.py
BAL_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 오디오 자산/엔딩 톤 회귀 검사"
python3 tools/audio_source_audit.py
AUDIO_SOURCE_EXIT=$?
python3 tools/generate_gangnam_ui_sfx.py --check
UI_SFX_EXIT=$?
if [ -x "$GODOT" ]; then
  AUDIO_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/AudioAssetCheck.tscn 2>&1)
  echo "$AUDIO_RAW" | grep -E "AUDIO_ASSET_CHECK_OK|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$AUDIO_RAW" | grep -q "AUDIO_ASSET_CHECK_OK"; then
    AUDIO_EXIT=0
  else
    AUDIO_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 오디오 체크 건너뜀."
  AUDIO_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● BGM 재시작/도덕 질감/장면 앰비언스 연속성 검사"
if [ -x "$GODOT" ]; then
  BGM_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/BGMContinuityCheck.tscn 2>&1)
  echo "$BGM_RAW" | grep -E "BGM_CONTINUITY_OK|BGM_CONTINUITY_FAIL|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$BGM_RAW" | grep -q "BGM_CONTINUITY_OK"; then
    BGM_EXIT=0
  else
    BGM_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — BGM 연속성 체크 건너뜀."
  BGM_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 튜토리얼 입력 포커스 회귀 검사"
if [ -x "$GODOT" ]; then
  TUTORIAL_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/TutorialInputCheck.tscn 2>&1)
  echo "$TUTORIAL_RAW" | grep -E "TUTORIAL_INPUT_CHECK_OK|TUTORIAL_INPUT_CHECK_FAIL|ERROR:|SCRIPT ERROR" | sed 's/^/  /'
  if echo "$TUTORIAL_RAW" | grep -q "TUTORIAL_INPUT_CHECK_OK"; then
    TUTORIAL_EXIT=0
  else
    TUTORIAL_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 튜토리얼 입력 체크 건너뜀."
  TUTORIAL_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 스토리 자동 재생 선택지 안전 검사"
if [ -x "$GODOT" ]; then
  STORY_PLAYBACK_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/StoryPlaybackCheck.tscn 2>&1)
  echo "$STORY_PLAYBACK_RAW" | grep -E "STORY_PLAYBACK_CHECK_OK|STORY_PLAYBACK_CHECK_FAIL|ERROR:|SCRIPT ERROR" | sed 's/^/  /'
  if echo "$STORY_PLAYBACK_RAW" | grep -q "STORY_PLAYBACK_CHECK_OK"; then
    STORY_PLAYBACK_EXIT=0
  else
    STORY_PLAYBACK_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 스토리 자동 재생 체크 건너뜀."
  STORY_PLAYBACK_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Godot 전체 스크립트 컴파일 체크 (씬 부팅 → 모든 .gd load 강제 컴파일)"
# 주의: --quit-after 2(메인씬 부팅)는 RaceTrack/MainGame 등 부팅 시 미로드 스크립트를
# 컴파일하지 않아 컴파일 버그를 놓친다(게다가 macOS엔 timeout 바이너리도 없어 헛돌았음).
# CompileCheck.tscn은 오토로드·class_name이 모두 등록된 상태에서 전체 .gd를 load()해
# 함수 본문까지 완전 컴파일한다 → 깨진 스크립트는 stderr에 'Failed to load script'.
if [ -x "$GODOT" ]; then
  # 1) 에디터 부팅으로 class_name 글로벌 캐시 최신화(스태일 캐시발 콜드 크래시 예방)
  run_limited "$GODOT" --headless --editor --quit-after 30 >/dev/null 2>&1
  # 2) 씬 부팅으로 전 스크립트 강제 컴파일
  RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/CompileCheck.tscn 2>&1)
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
if [ "$PY_EXIT" -ne 0 ] || [ "$SURFACE_EXIT" -ne 0 ] || [ "$PACING_EXIT" -ne 0 ] || [ "$KEY_ART_EXIT" -ne 0 ] || [ "$CG_ACTING_EXIT" -ne 0 ] || [ "$EVENT_VISUAL_EXIT" -ne 0 ] || [ "$EN_HANGUL_EXIT" -ne 0 ] || [ "$EN_COVERAGE_EXIT" -ne 0 ] || [ "$BAL_EXIT" -ne 0 ] || [ "$AUDIO_SOURCE_EXIT" -ne 0 ] || [ "$UI_SFX_EXIT" -ne 0 ] || [ "$AUDIO_EXIT" -ne 0 ] || [ "$BGM_EXIT" -ne 0 ] || [ "$TUTORIAL_EXIT" -ne 0 ] || [ "$STORY_PLAYBACK_EXIT" -ne 0 ] || [ "$GD_EXIT" -ne 0 ]; then
  echo "❌ 감사 실패 — 위 ERROR를 고치고 다시 돌리세요."
  exit 1
fi
echo "✅ 감사 통과"

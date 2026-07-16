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

make_isolated_home() {
  local prefix="$1"
  local temp_root="${TMPDIR:-/tmp}"
  while [ "${temp_root%/}" != "$temp_root" ]; do
    temp_root="${temp_root%/}"
  done
  mktemp -d "$temp_root/$prefix.XXXXXX"
}

# 감사용 격리 HOME만 정리한다. 사용자 HOME이나 예상 밖 경로가 들어오면
# 삭제를 거부해 테스트 정리 코드가 실제 사용자 데이터를 건드릴 수 없게 한다.
cleanup_isolated_home() {
  local target="${1:-}"
  local temp_root="${TMPDIR:-/tmp}"
  while [ "${temp_root%/}" != "$temp_root" ]; do
    temp_root="${temp_root%/}"
  done
  if [ -z "$target" ] || [ "$target" = "${HOME:-}" ] || [ ! -d "$target" ]; then
    echo "  ⚠ 격리 HOME 정리 거부: ${target:-<empty>}" >&2
    return 1
  fi
  case "$target" in
	  "$temp_root"/gangnam-achievements.*|"$temp_root"/gangnam-ending-route.*|"$temp_root"/gangnam-hidden.*|"$temp_root"/gangnam-housing-keepsake.*|"$temp_root"/gangnam-input-matrix.*|"$temp_root"/gangnam-story-audio.*|"$temp_root"/gangnam-story-tutorial.*)
      rm -rf -- "$target"
      ;;
    *)
      echo "  ⚠ 격리 HOME 경로 검증 실패, 정리 안 함: $target" >&2
      return 1
      ;;
  esac
}

echo "──────────────────────────────────────────"
python3 tools/audit.py
PY_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 서사 선행조건·배제 상태·장소·대화 채널 원장 검사"
python3 tools/story_consistency_audit.py
STORY_CONSISTENCY_EXIT=$?

echo "──────────────────────────────────────────"
python3 tools/surface_emoji_audit.py
SURFACE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 첫 세션 입력 밀도/프롤로그 체인 검사"
python3 tools/first_session_pacing_audit.py
PACING_EXIT=$?

echo "──────────────────────────────────────────"
echo "● Tier-1 정점 체인 길이·선택점·대화 왕복 래칫"
python3 tools/peak_scene_chain_audit.py --strict
PEAK_CHAIN_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 타이틀/IP 키아트 소유권·스토어 크롭 검사"
python3 tools/keyart_asset_check.py
KEY_ART_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 활성 CG·초상·배경 AI 증상 전수 판정 게이트"
python3 tools/art_ai_audit.py
ART_AI_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 활성 CG 카메라·시선·연기 계약 검사"
python3 tools/cg_acting_contract_check.py
CG_ACTING_EXIT=$?

echo "──────────────────────────────────────────"
echo "● A/B/C 배우 디테일·익명 군중 위계 검사"
python3 tools/cast_detail_contract_check.py
CAST_DETAIL_EXIT=$?

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
echo "● 다국어 오버레이 스키마·영어 안전 폴백 검사"
python3 tools/i18n_coverage_check.py
I18N_COVERAGE_EXIT=$?
python3 tools/multilingual_surface_audit.py
I18N_SURFACE_EXIT=$?
python3 tools/ja_translation_audit.py --scope ui
JA_UI_EXIT=$?
if [ -x "$GODOT" ]; then
  I18N_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/I18nInfrastructureCheck.tscn 2>&1)
  echo "$I18N_RAW" | grep -E "I18N_(INFRASTRUCTURE_CHECK_OK|INFRASTRUCTURE_CHECK_FAIL|FONT_COVERAGE)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$I18N_RAW" | grep -q "I18N_INFRASTRUCTURE_CHECK_OK"; then
    I18N_RUNTIME_EXIT=0
  else
    I18N_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 다국어 런타임 체크 건너뜀."
  I18N_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
python3 tools/balance_check.py
BAL_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 챕터·자산·직업·주거·관계 기반 랜덤 사건 편성 검사"
python3 tools/event_director_audit.py
EVENT_DIRECTOR_EXIT=$?
if [ -x "$GODOT" ]; then
  EVENT_DIRECTOR_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/EventDirectorCheck.tscn 2>&1)
  echo "$EVENT_DIRECTOR_RAW" | grep -E "EVENT_DIRECTOR_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$EVENT_DIRECTOR_RAW" | grep -q "EVENT_DIRECTOR_CHECK_OK"; then
    EVENT_DIRECTOR_RUNTIME_EXIT=0
  else
    EVENT_DIRECTOR_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 랜덤 사건 편성 런타임 체크 건너뜀."
  EVENT_DIRECTOR_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 엔딩 35종 제목·본문·비주얼·라우팅 구분성 검사"
python3 tools/ending_distinctness_audit.py
ENDING_DISTINCTNESS_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 창업·투자·정석·비정석·균형·직장 종결 라우팅 실행 검사"
if [ -x "$GODOT" ]; then
  ENDING_ROUTE_HOME=$(make_isolated_home "gangnam-ending-route")
  ENDING_ROUTE_RAW=$(run_limited env HOME="$ENDING_ROUTE_HOME" "$GODOT" --headless --quit-after 3600 res://tools/EndingRouteIdentityCheck.tscn 2>&1)
  cleanup_isolated_home "$ENDING_ROUTE_HOME"
  echo "$ENDING_ROUTE_RAW" | grep -E "ENDING_ROUTE_IDENTITY_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$ENDING_ROUTE_RAW" | grep -q "ENDING_ROUTE_IDENTITY_CHECK_OK"; then
    ENDING_ROUTE_EXIT=0
  else
    ENDING_ROUTE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 종결 라우팅 체크 건너뜀."
  ENDING_ROUTE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 오디오 자산/엔딩 톤 회귀 검사"
python3 tools/audio_source_audit.py
AUDIO_SOURCE_EXIT=$?
python3 tools/scene_audio_contract_check.py
SCENE_AUDIO_EXIT=$?
python3 tools/game_audio_contract_check.py
GAME_AUDIO_CONTRACT_EXIT=$?
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
echo "● 미니게임 물리음·장소 앰비언스 런타임 검사"
if [ -x "$GODOT" ]; then
  GAME_AUDIO_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/GameAudioContractCheck.tscn 2>&1)
  echo "$GAME_AUDIO_RAW" | grep -E "GAME_AUDIO_RUNTIME_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$GAME_AUDIO_RAW" | grep -q "GAME_AUDIO_RUNTIME_OK"; then
    GAME_AUDIO_RUNTIME_EXIT=0
  else
    GAME_AUDIO_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 게임 오디오 런타임 체크 건너뜀."
  GAME_AUDIO_RUNTIME_EXIT=0
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
echo "● 도덕 밴드 사람층 소거·무기질 장소 지속 검사"
if [ -x "$GODOT" ]; then
  MORAL_AMBIENCE_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/MoralAmbienceCheck.tscn 2>&1)
  echo "$MORAL_AMBIENCE_RAW" | grep -E "MORAL_AMBIENCE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$MORAL_AMBIENCE_RAW" | grep -q "MORAL_AMBIENCE_CHECK_OK"; then
    MORAL_AMBIENCE_EXIT=0
  else
    MORAL_AMBIENCE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 도덕 앰비언스 체크 건너뜀."
  MORAL_AMBIENCE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 주간 행동 에코·인과 프레임·비네트·예감·SFX 믹스 검사"
if [ -x "$GODOT" ]; then
  IMMERSION_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/ImmersionLoopCheck.tscn 2>&1)
  echo "$IMMERSION_RAW" | grep -E "IMMERSION_LOOP_CHECK_(OK|FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$IMMERSION_RAW" | grep -q "IMMERSION_LOOP_CHECK_OK"; then
    IMMERSION_EXIT=0
  else
    IMMERSION_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 몰입 루프 체크 건너뜀."
  IMMERSION_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 프롤로그 동기 3연타·수첩 재호출·아버지 데모 접점 검사"
if [ -x "$GODOT" ]; then
  MOTIVATION_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/MotivationImprintCheck.tscn 2>&1)
  echo "$MOTIVATION_RAW" | grep -E "MOTIVATION_IMPRINT_(OK|FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$MOTIVATION_RAW" | grep -q "MOTIVATION_IMPRINT_OK"; then
    MOTIVATION_EXIT=0
  else
    MOTIVATION_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 동기 각인 체크 건너뜀."
  MOTIVATION_EXIT=0
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
echo "● 프롤로그 결과·첫 AP 튜토리얼 배치 검사"
if [ -x "$GODOT" ]; then
  STORY_TUTORIAL_HOME=$(make_isolated_home "gangnam-story-tutorial")
  STORY_TUTORIAL_RAW=$(run_limited env HOME="$STORY_TUTORIAL_HOME" "$GODOT" --headless --quit-after 3600 res://tools/StoryTutorialPlacementCheck.tscn 2>&1)
  cleanup_isolated_home "$STORY_TUTORIAL_HOME"
  echo "$STORY_TUTORIAL_RAW" | grep -E "STORY_TUTORIAL_PLACEMENT_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$STORY_TUTORIAL_RAW" | grep -q "STORY_TUTORIAL_PLACEMENT_CHECK_OK"; then
    STORY_TUTORIAL_EXIT=0
  else
    STORY_TUTORIAL_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 프롤로그 튜토리얼 배치 체크 건너뜀."
  STORY_TUTORIAL_EXIT=0
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
echo "● 대면·전화·영상통화·메시지·기억 초상 공간 검사"
if [ -x "$GODOT" ]; then
  STORY_PRESENCE_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/StoryPresenceCheck.tscn 2>&1)
  echo "$STORY_PRESENCE_RAW" | grep -E "STORY_PRESENCE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$STORY_PRESENCE_RAW" | grep -q "STORY_PRESENCE_CHECK_OK"; then
    STORY_PRESENCE_EXIT=0
  else
    STORY_PRESENCE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 원격 대화 공간 체크 건너뜀."
  STORY_PRESENCE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Living Scene 날씨·기억·카메라·모랄·접근성 계약 검사"
if [ -x "$GODOT" ]; then
  LIVING_SCENE_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/LivingSceneCheck.tscn 2>&1)
  echo "$LIVING_SCENE_RAW" | grep -E "LIVING_SCENE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$LIVING_SCENE_RAW" | grep -q "LIVING_SCENE_CHECK_OK"; then
    LIVING_SCENE_EXIT=0
  else
    LIVING_SCENE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Living Scene 체크 건너뜀."
	LIVING_SCENE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 본문·제목·선택지·상태 텍스트 재질 계약 검사"
if [ -x "$GODOT" ]; then
  TEXT_MATERIAL_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/TextMaterialCheck.tscn 2>&1)
  echo "$TEXT_MATERIAL_RAW" | grep -E "TEXT_MATERIAL_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$TEXT_MATERIAL_RAW" | grep -q "TEXT_MATERIAL_CHECK_OK"; then
    TEXT_MATERIAL_EXIT=0
  else
    TEXT_MATERIAL_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 텍스트 재질 체크 건너뜀."
  TEXT_MATERIAL_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 이벤트 중 오디오 설정·패드 메뉴·재생 연속성 검사"
if [ -x "$GODOT" ]; then
  STORY_AUDIO_HOME=$(make_isolated_home "gangnam-story-audio")
  STORY_AUDIO_RAW=$(run_limited env HOME="$STORY_AUDIO_HOME" "$GODOT" --headless --quit-after 3600 res://tools/StoryAudioSettingsCheck.tscn 2>&1)
  cleanup_isolated_home "$STORY_AUDIO_HOME"
  echo "$STORY_AUDIO_RAW" | grep -E "STORY_AUDIO_SETTINGS_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$STORY_AUDIO_RAW" | grep -q "STORY_AUDIO_SETTINGS_CHECK_OK"; then
    STORY_AUDIO_EXIT=0
  else
    STORY_AUDIO_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 이벤트 오디오 설정 체크 건너뜀."
  STORY_AUDIO_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 입력·화면·글리프·접근성·Steam Input 계약 검사"
if [ -x "$GODOT" ]; then
  INPUT_MATRIX_HOME=$(make_isolated_home "gangnam-input-matrix")
  INPUT_MATRIX_RAW=$(run_limited env HOME="$INPUT_MATRIX_HOME" "$GODOT" --headless --quit-after 3600 res://tools/InputMatrixCheck.tscn 2>&1)
  cleanup_isolated_home "$INPUT_MATRIX_HOME"
  echo "$INPUT_MATRIX_RAW" | grep -E "INPUT_MATRIX_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$INPUT_MATRIX_RAW" | grep -q "INPUT_MATRIX_CHECK_OK"; then
    INPUT_MATRIX_EXIT=0
  else
    INPUT_MATRIX_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 입력·화면 매트릭스 체크 건너뜀."
  INPUT_MATRIX_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 업적 15종 카탈로그/번역/실제 해금 경로 검사"
if [ -x "$GODOT" ]; then
  ACHIEVEMENT_HOME=$(make_isolated_home "gangnam-achievements")
  ACHIEVEMENT_RAW=$(run_limited env HOME="$ACHIEVEMENT_HOME" "$GODOT" --headless --quit-after 3600 res://tools/AchievementPathCheck.tscn 2>&1)
  cleanup_isolated_home "$ACHIEVEMENT_HOME"
  echo "$ACHIEVEMENT_RAW" | grep -E "ACHIEVEMENT_PATH_CHECK_OK|ACHIEVEMENT_PATH_CHECK_FAIL|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$ACHIEVEMENT_RAW" | grep -q "ACHIEVEMENT_PATH_CHECK_OK"; then
    ACHIEVEMENT_EXIT=0
  else
    ACHIEVEMENT_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 업적 경로 체크 건너뜀."
  ACHIEVEMENT_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 유물 제시·히든 6경로 블랙박스 검사"
if [ -x "$GODOT" ]; then
  HIDDEN_HOME=$(make_isolated_home "gangnam-hidden")
  HIDDEN_RAW=$(run_limited env HOME="$HIDDEN_HOME" "$GODOT" --headless --quit-after 3600 res://tools/HiddenFeatureCheck.tscn 2>&1)
  cleanup_isolated_home "$HIDDEN_HOME"
  echo "$HIDDEN_RAW" | grep -E "HIDDEN_FEATURE_(CHECK_OK|CHECK_FAIL|EVIDENCE)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$HIDDEN_RAW" | grep -q "HIDDEN_FEATURE_CHECK_OK"; then
    HIDDEN_EXIT=0
  else
    HIDDEN_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 유물·히든 경로 체크 건너뜀."
  HIDDEN_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 이사 전 유물 보존·처분·후속 침묵 검사"
if [ -x "$GODOT" ]; then
  HOUSING_KEEPSAKE_HOME=$(make_isolated_home "gangnam-housing-keepsake")
  HOUSING_KEEPSAKE_RAW=$(run_limited env HOME="$HOUSING_KEEPSAKE_HOME" "$GODOT" --headless --quit-after 3600 res://tools/HousingKeepsakeCheck.tscn 2>&1)
  cleanup_isolated_home "$HOUSING_KEEPSAKE_HOME"
  echo "$HOUSING_KEEPSAKE_RAW" | grep -E "HOUSING_KEEPSAKE_(CHECK_OK|CHECK_FAIL|EVIDENCE)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$HOUSING_KEEPSAKE_RAW" | grep -q "HOUSING_KEEPSAKE_CHECK_OK"; then
    HOUSING_KEEPSAKE_EXIT=0
  else
    HOUSING_KEEPSAKE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 이사 유물 비트 체크 건너뜀."
  HOUSING_KEEPSAKE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 연차 정체성·실제 장면 큐레이션·시그니처 시스템 검사"
if [ -x "$GODOT" ]; then
  YEAR_IDENTITY_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/YearIdentityCheck.tscn 2>&1)
  echo "$YEAR_IDENTITY_RAW" | grep -E "YEAR_IDENTITY_(CHECK_OK|CHECK_FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$YEAR_IDENTITY_RAW" | grep -q "YEAR_IDENTITY_CHECK_OK"; then
    YEAR_IDENTITY_EXIT=0
  else
    YEAR_IDENTITY_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 연차 정체성 체크 건너뜀."
	YEAR_IDENTITY_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 데모 빌드 flavor·1~8주 정본 체인·24주 차단 검사"
if [ -x "$GODOT" ]; then
  DEMO_BUILD_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/DemoBuildCheck.tscn -- --demo-build 2>&1)
  echo "$DEMO_BUILD_RAW" | grep -E "DEMO_BUILD_(CHECK_OK|CHECK_FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if echo "$DEMO_BUILD_RAW" | grep -q "DEMO_BUILD_CHECK_OK"; then
    DEMO_BUILD_EXIT=0
  else
    DEMO_BUILD_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 데모 빌드 계약 체크 건너뜀."
  DEMO_BUILD_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 스토어 트레일러 30/60초·한영·자산 계약 검사"
if python3 tools/trailer/trailer_check.py; then
  TRAILER_EXIT=0
else
  TRAILER_EXIT=1
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
if [ "$PY_EXIT" -ne 0 ] || [ "$STORY_CONSISTENCY_EXIT" -ne 0 ] || [ "$SURFACE_EXIT" -ne 0 ] || [ "$PACING_EXIT" -ne 0 ] || [ "$PEAK_CHAIN_EXIT" -ne 0 ] || [ "$KEY_ART_EXIT" -ne 0 ] || [ "$ART_AI_EXIT" -ne 0 ] || [ "$CG_ACTING_EXIT" -ne 0 ] || [ "$CAST_DETAIL_EXIT" -ne 0 ] || [ "$EVENT_VISUAL_EXIT" -ne 0 ] || [ "$EN_HANGUL_EXIT" -ne 0 ] || [ "$EN_COVERAGE_EXIT" -ne 0 ] || [ "$I18N_COVERAGE_EXIT" -ne 0 ] || [ "$I18N_SURFACE_EXIT" -ne 0 ] || [ "$JA_UI_EXIT" -ne 0 ] || [ "$I18N_RUNTIME_EXIT" -ne 0 ] || [ "$BAL_EXIT" -ne 0 ] || [ "$EVENT_DIRECTOR_EXIT" -ne 0 ] || [ "$EVENT_DIRECTOR_RUNTIME_EXIT" -ne 0 ] || [ "$ENDING_DISTINCTNESS_EXIT" -ne 0 ] || [ "$ENDING_ROUTE_EXIT" -ne 0 ] || [ "$AUDIO_SOURCE_EXIT" -ne 0 ] || [ "$SCENE_AUDIO_EXIT" -ne 0 ] || [ "$GAME_AUDIO_CONTRACT_EXIT" -ne 0 ] || [ "$UI_SFX_EXIT" -ne 0 ] || [ "$AUDIO_EXIT" -ne 0 ] || [ "$GAME_AUDIO_RUNTIME_EXIT" -ne 0 ] || [ "$BGM_EXIT" -ne 0 ] || [ "$MORAL_AMBIENCE_EXIT" -ne 0 ] || [ "$IMMERSION_EXIT" -ne 0 ] || [ "$MOTIVATION_EXIT" -ne 0 ] || [ "$TUTORIAL_EXIT" -ne 0 ] || [ "$STORY_TUTORIAL_EXIT" -ne 0 ] || [ "$STORY_PLAYBACK_EXIT" -ne 0 ] || [ "$STORY_PRESENCE_EXIT" -ne 0 ] || [ "$LIVING_SCENE_EXIT" -ne 0 ] || [ "$TEXT_MATERIAL_EXIT" -ne 0 ] || [ "$STORY_AUDIO_EXIT" -ne 0 ] || [ "$INPUT_MATRIX_EXIT" -ne 0 ] || [ "$ACHIEVEMENT_EXIT" -ne 0 ] || [ "$HIDDEN_EXIT" -ne 0 ] || [ "$HOUSING_KEEPSAKE_EXIT" -ne 0 ] || [ "$YEAR_IDENTITY_EXIT" -ne 0 ] || [ "$DEMO_BUILD_EXIT" -ne 0 ] || [ "$TRAILER_EXIT" -ne 0 ] || [ "$GD_EXIT" -ne 0 ]; then
  echo "❌ 감사 실패 — 위 ERROR를 고치고 다시 돌리세요."
  exit 1
fi
echo "✅ 감사 통과"

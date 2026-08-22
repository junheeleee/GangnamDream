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
    gtimeout 720 "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout 720 "$@"
  elif command -v perl >/dev/null 2>&1; then
    perl -e '$seconds = shift; alarm $seconds; exec @ARGV' 720 "$@"
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
	  "$temp_root"/gangnam-achievements.*|"$temp_root"/gangnam-communication-phone.*|"$temp_root"/gangnam-controller-semantic.*|"$temp_root"/gangnam-core-loop-v2.*|"$temp_root"/gangnam-core-loop-v2-b.*|"$temp_root"/gangnam-core-loop-v2-c.*|"$temp_root"/gangnam-core-loop-v2-cycle-balance.*|"$temp_root"/gangnam-core-loop-v2-d.*|"$temp_root"/gangnam-core-loop-v2-e.*|"$temp_root"/gangnam-core-loop-v2-first-entry.*|"$temp_root"/gangnam-core-loop-v2-handoff.*|"$temp_root"/gangnam-ending-route.*|"$temp_root"/gangnam-first30.*|"$temp_root"/gangnam-hidden.*|"$temp_root"/gangnam-housing-keepsake.*|"$temp_root"/gangnam-immersion-loop.*|"$temp_root"/gangnam-input-matrix.*|"$temp_root"/gangnam-manual-save.*|"$temp_root"/gangnam-mod-layer.*|"$temp_root"/gangnam-money-integrity.*|"$temp_root"/gangnam-phone-system.*|"$temp_root"/gangnam-story-audio.*|"$temp_root"/gangnam-story-dialogue-history.*|"$temp_root"/gangnam-story-tutorial.*)
      rm -rf -- "$target"
      ;;
    *)
      echo "  ⚠ 격리 HOME 경로 검증 실패, 정리 안 함: $target" >&2
      return 1
      ;;
  esac
}

# A success marker alone is insufficient: Godot can print it and still exit
# non-zero or emit a late script error. Every captured runtime check rejects
# those failures. A1 checks pass "strict" to reject any ERROR line as well;
# several older isolated suites still emit known teardown-only resource noise.
godot_check_passed() {
  local output="$1"
  local exit_status="$2"
  local success_marker="$3"
  local error_mode="${4:-compiler}"
  if [ "$exit_status" -ne 0 ]; then
    echo "  ✗ Godot 종료코드: $exit_status"
    return 1
  fi
  if ! printf '%s\n' "$output" | grep -Fq "$success_marker"; then
    echo "  ✗ 성공 마커 없음: $success_marker"
    return 1
  fi
  local error_lines
  error_lines=$(printf '%s\n' "$output" \
    | grep -iE 'ERROR:|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script')
  if [ "$error_mode" != "strict" ]; then
    error_lines=$(printf '%s\n' "$error_lines" \
      | grep -viE 'ERROR: [0-9]+ resources still in use at exit')
  fi
  if [ -n "$error_lines" ]; then
    echo "  ✗ 성공 마커와 함께 Godot 오류가 출력됨"
    return 1
  fi
  return 0
}

if godot_check_passed $'AUDIT_GUARD_SELF_TEST_OK\nERROR: synthetic late failure' \
    0 "AUDIT_GUARD_SELF_TEST_OK" strict >/dev/null; then
  echo "❌ 내부 감사 오류 — Godot ERROR 동시 출력 감지가 작동하지 않습니다."
  exit 1
fi
if godot_check_passed "AUDIT_GUARD_SELF_TEST_OK" \
    7 "AUDIT_GUARD_SELF_TEST_OK" >/dev/null; then
  echo "❌ 내부 감사 오류 — Godot 비정상 종료코드 감지가 작동하지 않습니다."
  exit 1
fi

echo "──────────────────────────────────────────"
echo "● 장기 맥락 부팅 예산·정본 분류·내부 링크 검사"
python3 tools/context_manifest_check.py
CONTEXT_MANIFEST_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 실행 큐 상태·활성 사양 크기 검사"
python3 tools/queue_consistency_check.py
QUEUE_CONSISTENCY_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 출시 패키지·심의 콘텐츠 사실 원장 검사"
python3 tools/release_content_inventory.py
RELEASE_CONTENT_EXIT=$?
python3 tools/release_content_inventory.py --self-test
RELEASE_CONTENT_SELF_TEST_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 화면·세이브·빌드 매니페스트 식별자 검사"
python3 tools/build_identity_audit.py --self-test
BUILD_IDENTITY_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 엔진·서체·오디오 제3자 고지 원장·패키지 사본 검사"
python3 tools/third_party_notice_audit.py --self-test
THIRD_PARTY_NOTICE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● author-only 사건 생명주기·shipping corpus 분리 검사"
python3 tools/event_lifecycle.py
EVENT_LIFECYCLE_EXIT=$?
python3 tools/event_lifecycle.py --self-test
EVENT_LIFECYCLE_SELF_TEST_EXIT=$?

echo "──────────────────────────────────────────"
python3 tools/audit.py
PY_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 기회 선택 19개·15사건·현금 부족 대체 선택 정적 원장"
python3 tools/opportunity_money_audit.py
OPPORTUNITY_MONEY_AUDIT_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 서사 선행조건·배제 상태·장소·대화 채널 원장 검사"
python3 tools/story_consistency_audit.py
STORY_CONSISTENCY_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 60개월 스토리맵·원고 존재·기억 생산자/독자 정합 검사"
python3 tools/story_map_audit.py
STORY_MAP_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 마지막 해 career·startup reference-only exact route 계약 검사"
python3 tools/year5_reference_route_audit.py --self-test
YEAR5_REFERENCE_ROUTE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 마지막 해 M49~M55 dormant contract kernel 검사"
if [ -x "$GODOT" ]; then
  YEAR5_REFERENCE_ROUTE_R1_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/Year5ReferenceRouteR1Check.tscn 2>&1)
  YEAR5_REFERENCE_ROUTE_R1_STATUS=$?
  echo "$YEAR5_REFERENCE_ROUTE_R1_RAW" | grep -E "YEAR5_REFERENCE_ROUTE_R1_(CHECK_OK|CHECK_FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$YEAR5_REFERENCE_ROUTE_R1_RAW" \
      "$YEAR5_REFERENCE_ROUTE_R1_STATUS" \
      "YEAR5_REFERENCE_ROUTE_R1_CHECK_OK" strict; then
    YEAR5_REFERENCE_ROUTE_R1_EXIT=0
  else
    YEAR5_REFERENCE_ROUTE_R1_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 마지막 해 dormant kernel 체크 건너뜀."
  YEAR5_REFERENCE_ROUTE_R1_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 주요 인물 호칭·관계 단계별 말투 정본 검사"
python3 tools/speech_register_audit.py
SPEECH_REGISTER_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 랜덤 풀 수치-산문·모순·설교투 위생 검사"
python3 tools/random_pool_hygiene_audit.py
RANDOM_POOL_HYGIENE_EXIT=$?

echo "──────────────────────────────────────────"
python3 tools/surface_emoji_audit.py
SURFACE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 플레이어 표면 스탯·해금·배수·웨이브·등급 언어 검사"
python3 tools/player_surface_language_audit.py
PLAYER_SURFACE_LANGUAGE_EXIT=$?
python3 tools/player_surface_language_audit.py --self-test
PLAYER_SURFACE_LANGUAGE_SELF_TEST_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 화면 언어 분열 흔적 감사 (래칫)"
python3 tools/surface_coherence_audit.py
SURFACE_COHERENCE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 주연 6인 서명 강제 검사 (소품·모티프 명단, 래칫)"
python3 tools/identity_signature_audit.py
IDENTITY_SIGNATURE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 진입점 없는 스크립트 감사 (래칫)"
python3 tools/feature_liveness_audit.py
FEATURE_LIVENESS_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 현황 문서 신선도 (docs/STATUS.md가 저장소와 같은가)"
python3 tools/project_dashboard.py --md docs/STATUS.md --check
STATUS_DOC_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 사람 판정 원장 (자동 검사가 대신할 수 없는 것)"
python3 tools/human_gates.py
HUMAN_GATES_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 첫 세션 입력 밀도/프롤로그 체인 검사"
python3 tools/first_session_pacing_audit.py
PACING_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 정상 독해 체험 프로파일 계산·회귀 자체 검사"
python3 tools/demo_experience_audit.py --self-test
DEMO_EXPERIENCE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 외부 정상 독해 세션 무결성·표본 판정 집계기"
python3 tools/playtest_report.py --self-test
PLAYTEST_REPORT_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 장편 서사 연속성·챕터 밀도·고립 단편 장부"
python3 tools/narrative_continuity_audit.py
NARRATIVE_CONTINUITY_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 240주 직접 결정·환불선·랜덤 사건 노출 구조 추정"
python3 tools/full_run_pacing_audit.py
FULL_RUN_PACING_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 5장 대서사 척추·복선·데모 시퀀스 계약 검사"
python3 tools/narrative_spine_audit.py
NARRATIVE_SPINE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● Tier-1 정점 체인 길이·선택점·대화 왕복 래칫"
python3 tools/peak_scene_chain_audit.py --strict
PEAK_CHAIN_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 타이틀/IP 키아트 소유권·스토어 크롭 검사"
python3 tools/keyart_asset_check.py
KEY_ART_EXIT=$?
if [ -x "$GODOT" ]; then
  FIRST30_HOME=$(make_isolated_home "gangnam-first30")
  FIRST30_RAW=$(run_limited env HOME="$FIRST30_HOME" "$GODOT" --headless --quit-after 1200 res://tools/First30SecondsCheck.tscn 2>&1)
  FIRST30_STATUS=$?
  cleanup_isolated_home "$FIRST30_HOME"
  echo "$FIRST30_RAW" | grep -E "FIRST_30_SECONDS_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$FIRST30_RAW" "$FIRST30_STATUS" \
      "FIRST_30_SECONDS_CHECK_OK"; then
    FIRST30_EXIT=0
  else
    FIRST30_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 첫 30초 런타임 체크 건너뜀."
  FIRST30_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 활성 CG·초상·배경 AI 증상 전수 판정 게이트"
python3 tools/art_ai_audit.py
ART_AI_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 활성 CG·초상·배경 1080p·4K 확대율/저해상도 회귀 게이트"
python3 tools/art_resolution_audit.py
ART_RESOLUTION_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 승격 원화 재현·출처·100% A/B 검수 게이트"
python3 tools/art_master_audit.py
ART_MASTER_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 활성 CG 카메라·시선·연기 계약 검사"
python3 tools/cg_acting_contract_check.py
CG_ACTING_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 스토리·엔딩 CG 실제 경로·소유권·해상도 런타임 검사"
if [ -x "$GODOT" ]; then
  CG_RUNTIME_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/CGRuntimeCheck.tscn 2>&1)
  CG_RUNTIME_STATUS=$?
  echo "$CG_RUNTIME_RAW" | grep -E "CG_RUNTIME_CHECK_OK|SCRIPT ERROR|Parse Error|Compile Error|missing .*cg|cg mismatch|shared by|must use" | sed 's/^/  /'
  if godot_check_passed "$CG_RUNTIME_RAW" "$CG_RUNTIME_STATUS" \
      "CG_RUNTIME_CHECK_OK"; then
    CG_RUNTIME_EXIT=0
  else
    CG_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — CG 런타임 체크 건너뜀."
  CG_RUNTIME_EXIT=0
fi

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
python3 tools/english_hangul_audit.py --self-test
EN_HANGUL_SELF_TEST_EXIT=$?
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
python3 tools/ja_translation_pipeline.py --scope demo --inventory
JA_DEMO_INVENTORY_EXIT=$?
python3 tools/ja_translation_pipeline.py --self-test
JA_DEMO_PIPELINE_SELF_TEST_EXIT=$?
python3 tools/ja_translation_audit.py --scope demo
JA_DEMO_AUDIT_EXIT=$?
python3 tools/zh_translation_audit.py
ZH_DEMO_AUDIT_EXIT=$?
python3 tools/zh_translation_audit.py --self-test
ZH_DEMO_SELF_TEST_EXIT=$?
python3 tools/demo_localization_scope.py
DEMO_I18N_SCOPE_EXIT=$?
python3 tools/demo_localization_scope.py --self-test
DEMO_I18N_SELF_TEST_EXIT=$?
python3 tools/demo_prose_style_audit.py --self-test
DEMO_PROSE_STYLE_EXIT=$?
if [ -x "$GODOT" ]; then
  I18N_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/I18nInfrastructureCheck.tscn 2>&1)
  I18N_STATUS=$?
  echo "$I18N_RAW" | grep -E "I18N_(INFRASTRUCTURE_CHECK_OK|INFRASTRUCTURE_CHECK_FAIL|FONT_COVERAGE)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$I18N_RAW" "$I18N_STATUS" \
      "I18N_INFRASTRUCTURE_CHECK_OK"; then
    I18N_RUNTIME_EXIT=0
  else
    I18N_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 다국어 런타임 체크 건너뜀."
  I18N_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● KO/EN Pretendard·JA Noto Sans JP 웨이트·이모지 폰트 라우팅 검사"
if [ -x "$GODOT" ]; then
  FONT_ROUTING_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/FontRoutingCheck.tscn 2>&1)
  FONT_ROUTING_STATUS=$?
  echo "$FONT_ROUTING_RAW" | grep -E "FONT_ROUTING_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$FONT_ROUTING_RAW" "$FONT_ROUTING_STATUS" \
      "FONT_ROUTING_CHECK_OK" strict; then
    FONT_ROUTING_EXIT=0
  else
    FONT_ROUTING_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 폰트 라우팅 체크 건너뜀."
  FONT_ROUTING_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 커뮤니티 번역·에셋·데이터 모드 안전성 검사"
python3 tools/mod_layer_audit.py
MOD_LAYER_AUDIT_EXIT=$?
if [ -x "$GODOT" ]; then
  MOD_LAYER_HOME=$(make_isolated_home "gangnam-mod-layer")
  MOD_LAYER_RAW=$(run_limited env HOME="$MOD_LAYER_HOME" "$GODOT" --headless --quit-after 1200 res://tools/ModLayerCheck.tscn 2>&1)
  MOD_LAYER_STATUS=$?
  cleanup_isolated_home "$MOD_LAYER_HOME"
  echo "$MOD_LAYER_RAW" | grep -E "MOD_LAYER_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$MOD_LAYER_RAW" "$MOD_LAYER_STATUS" \
      "MOD_LAYER_CHECK_OK"; then
    MOD_LAYER_RUNTIME_EXIT=0
  else
    MOD_LAYER_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 모드 계층 런타임 체크 건너뜀."
  MOD_LAYER_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
python3 tools/balance_check.py
BAL_EXIT=$?

echo "──────────────────────────────────────────"
echo "● 챕터·자산·직업·주거·관계 기반 랜덤 사건 편성 검사"
python3 tools/event_director_audit.py
EVENT_DIRECTOR_EXIT=$?
python3 tools/exposed_state_consistency_audit.py
EXPOSED_STATE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● Core Loop V2 6개월 서울 사이클·월간 약속·관계 주도권 설계 계약"
python3 tools/demo_core_loop_v2_audit.py
CORE_LOOP_V2_EXIT=$?
python3 tools/chapter1_core_loop_v2_causal_ledger_check.py --self-test
CHAPTER1_CAUSAL_LEDGER_SELF_TEST_EXIT=$?
python3 tools/chapter1_core_loop_v2_causal_ledger_check.py
CHAPTER1_CAUSAL_LEDGER_EXIT=$?
python3 tools/core_loop_v2_balance_sim.py
CORE_LOOP_V2_BALANCE_EXIT=$?

echo "──────────────────────────────────────────"
echo "● Core Loop V2 1~8주 공통 계획·저장·지연 결과·관계 주도권 런타임"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_HOME=$(make_isolated_home "gangnam-core-loop-v2")
  CORE_LOOP_V2_RUNTIME_RAW=$(run_limited env HOME="$CORE_LOOP_V2_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2Check.tscn 2>&1)
  CORE_LOOP_V2_RUNTIME_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_HOME"
  echo "$CORE_LOOP_V2_RUNTIME_RAW" | grep -E "CORE_LOOP_V2_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_RUNTIME_RAW" \
      "$CORE_LOOP_V2_RUNTIME_STATUS" "CORE_LOOP_V2_CHECK_OK" strict; then
    CORE_LOOP_V2_RUNTIME_EXIT=0
  else
    CORE_LOOP_V2_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Core Loop V2 런타임 체크 건너뜀."
  CORE_LOOP_V2_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 B 9~12주 이관·typed 인과·행동·관계·포기 런타임"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_B_HOME=$(make_isolated_home "gangnam-core-loop-v2-b")
  CORE_LOOP_V2_B_RUNTIME_RAW=$(run_limited env HOME="$CORE_LOOP_V2_B_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2BCheck.tscn 2>&1)
  CORE_LOOP_V2_B_RUNTIME_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_B_HOME"
  echo "$CORE_LOOP_V2_B_RUNTIME_RAW" | grep -E "CORE_LOOP_V2_B_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_B_RUNTIME_RAW" \
      "$CORE_LOOP_V2_B_RUNTIME_STATUS" "CORE_LOOP_V2_B_CHECK_OK" strict; then
    CORE_LOOP_V2_B_RUNTIME_EXIT=0
  else
    CORE_LOOP_V2_B_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Core Loop V2 B 런타임 체크 건너뜀."
  CORE_LOOP_V2_B_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 C 13~16주 인과·면접·관계·행동·월5 계속 런타임"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_C_HOME=$(make_isolated_home "gangnam-core-loop-v2-c")
  CORE_LOOP_V2_C_RUNTIME_RAW=$(run_limited env HOME="$CORE_LOOP_V2_C_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2CCheck.tscn 2>&1)
  CORE_LOOP_V2_C_RUNTIME_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_C_HOME"
  echo "$CORE_LOOP_V2_C_RUNTIME_RAW" | grep -E "CORE_LOOP_V2_C_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_C_RUNTIME_RAW" \
      "$CORE_LOOP_V2_C_RUNTIME_STATUS" "CORE_LOOP_V2_C_CHECK_OK" strict; then
    CORE_LOOP_V2_C_RUNTIME_EXIT=0
  else
    CORE_LOOP_V2_C_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Core Loop V2 C 런타임 체크 건너뜀."
  CORE_LOOP_V2_C_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 D 17~20주 포기 회수·인물 충돌·행동·6개월차 계속 런타임"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_D_HOME=$(make_isolated_home "gangnam-core-loop-v2-d")
  CORE_LOOP_V2_D_RUNTIME_RAW=$(run_limited env HOME="$CORE_LOOP_V2_D_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2DCheck.tscn 2>&1)
  CORE_LOOP_V2_D_RUNTIME_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_D_HOME"
  echo "$CORE_LOOP_V2_D_RUNTIME_RAW" | grep -E "CORE_LOOP_V2_D_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_D_RUNTIME_RAW" \
      "$CORE_LOOP_V2_D_RUNTIME_STATUS" "CORE_LOOP_V2_D_CHECK_OK" strict; then
    CORE_LOOP_V2_D_RUNTIME_EXIT=0
  else
    CORE_LOOP_V2_D_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Core Loop V2 D 런타임 체크 건너뜀."
  CORE_LOOP_V2_D_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 E 21~24주 선행 신호·지연 회수·의무 충돌·실제 데모 종료 런타임"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_E_HOME=$(make_isolated_home "gangnam-core-loop-v2-e")
  CORE_LOOP_V2_E_RUNTIME_RAW=$(run_limited env HOME="$CORE_LOOP_V2_E_HOME" "$GODOT" --headless --quit-after 1800 res://tools/CoreLoopV2ECheck.tscn 2>&1)
  CORE_LOOP_V2_E_RUNTIME_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_E_HOME"
  echo "$CORE_LOOP_V2_E_RUNTIME_RAW" | grep -E "CORE_LOOP_V2_E_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_E_RUNTIME_RAW" \
      "$CORE_LOOP_V2_E_RUNTIME_STATUS" "CORE_LOOP_V2_E_CHECK_OK" strict; then
    CORE_LOOP_V2_E_RUNTIME_EXIT=0
  else
    CORE_LOOP_V2_E_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Core Loop V2 E 런타임 체크 건너뜀."
  CORE_LOOP_V2_E_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 1~6개월 서울 사이클·4여력·4노드·세계시계·영수증·구 저장 런타임"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_CYCLE_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2CycleCheck.tscn 2>&1)
  CORE_LOOP_V2_CYCLE_STATUS=$?
  echo "$CORE_LOOP_V2_CYCLE_RAW" | grep -E "CORE_LOOP_V2_CYCLE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_CYCLE_RAW" \
      "$CORE_LOOP_V2_CYCLE_STATUS" \
      "CORE_LOOP_V2_CYCLE_CHECK_OK" strict; then
    CORE_LOOP_V2_CYCLE_EXIT=0
  else
    CORE_LOOP_V2_CYCLE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 서울 사이클 계약 체크 건너뜀."
  CORE_LOOP_V2_CYCLE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 서울 사이클 실제 24주 5경로 수치·사망 경계"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_CYCLE_BALANCE_HOME=$(make_isolated_home "gangnam-core-loop-v2-cycle-balance")
  CORE_LOOP_V2_CYCLE_BALANCE_RAW=$(run_limited env HOME="$CORE_LOOP_V2_CYCLE_BALANCE_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2CycleBalanceCheck.tscn -- --core-loop-v2-playtest-build --qa-isolated-user-data 2>&1)
  CORE_LOOP_V2_CYCLE_BALANCE_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_CYCLE_BALANCE_HOME"
  echo "$CORE_LOOP_V2_CYCLE_BALANCE_RAW" | grep -E "CORE_LOOP_V2_CYCLE_BALANCE_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_CYCLE_BALANCE_RAW" \
      "$CORE_LOOP_V2_CYCLE_BALANCE_STATUS" \
      "CORE_LOOP_V2_CYCLE_BALANCE_OK" strict; then
    CORE_LOOP_V2_CYCLE_BALANCE_EXIT=0
  else
    CORE_LOOP_V2_CYCLE_BALANCE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 서울 사이클 수치 체크 건너뜀."
  CORE_LOOP_V2_CYCLE_BALANCE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 첫 진입 프롤로그·챕터·서울의 네 주·튜토리얼 순서와 저장·입력 경계"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_FIRST_ENTRY_HOME=$(make_isolated_home "gangnam-core-loop-v2-first-entry")
  CORE_LOOP_V2_FIRST_ENTRY_RAW=$(run_limited env HOME="$CORE_LOOP_V2_FIRST_ENTRY_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2FirstEntryCheck.tscn 2>&1)
  CORE_LOOP_V2_FIRST_ENTRY_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_FIRST_ENTRY_HOME"
  echo "$CORE_LOOP_V2_FIRST_ENTRY_RAW" | grep -E "CORE_LOOP_V2_FIRST_ENTRY_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_FIRST_ENTRY_RAW" \
      "$CORE_LOOP_V2_FIRST_ENTRY_STATUS" \
      "CORE_LOOP_V2_FIRST_ENTRY_CHECK_OK" strict; then
    CORE_LOOP_V2_FIRST_ENTRY_EXIT=0
  else
    CORE_LOOP_V2_FIRST_ENTRY_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Core Loop V2 첫 진입 체크 건너뜀."
  CORE_LOOP_V2_FIRST_ENTRY_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● Core Loop V2 24→48주 실제 스케줄러·현수/도시 결과·1년 결산 인계"
if [ -x "$GODOT" ]; then
  CORE_LOOP_V2_HANDOFF_HOME=$(make_isolated_home "gangnam-core-loop-v2-handoff")
  CORE_LOOP_V2_HANDOFF_RAW=$(run_limited env HOME="$CORE_LOOP_V2_HANDOFF_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CoreLoopV2HandoffCheck.tscn 2>&1)
  CORE_LOOP_V2_HANDOFF_STATUS=$?
  cleanup_isolated_home "$CORE_LOOP_V2_HANDOFF_HOME"
  echo "$CORE_LOOP_V2_HANDOFF_RAW" | grep -E "CORE_LOOP_V2_HANDOFF_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_LOOP_V2_HANDOFF_RAW" \
      "$CORE_LOOP_V2_HANDOFF_STATUS" \
      "CORE_LOOP_V2_HANDOFF_CHECK_OK" strict; then
    CORE_LOOP_V2_HANDOFF_EXIT=0
  else
    CORE_LOOP_V2_HANDOFF_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Core Loop V2 24→48주 인계 체크 건너뜀."
  CORE_LOOP_V2_HANDOFF_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 연락폰 schema 3·기종 구매 폐기·유효 구 저장 18만원 1회 환불 계약"
if [ -x "$GODOT" ]; then
  PHONE_SYSTEM_HOME=$(make_isolated_home "gangnam-phone-system")
  PHONE_SYSTEM_RAW=$(run_limited env HOME="$PHONE_SYSTEM_HOME" "$GODOT" --headless --quit-after 1200 res://tools/PhoneSystemCheck.tscn 2>&1)
  PHONE_SYSTEM_STATUS=$?
  cleanup_isolated_home "$PHONE_SYSTEM_HOME"
  echo "$PHONE_SYSTEM_RAW" | grep -E "PHONE_SYSTEM_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$PHONE_SYSTEM_RAW" \
      "$PHONE_SYSTEM_STATUS" "PHONE_SYSTEM_CHECK_OK" strict; then
    PHONE_SYSTEM_EXIT=0
  else
    PHONE_SYSTEM_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 연락폰 저장 이관 체크 건너뜀."
  PHONE_SYSTEM_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 현금 1원 정산·0원 기회·구 저장·거래 영수증 런타임 검사"
if [ -x "$GODOT" ]; then
  MONEY_INTEGRITY_HOME=$(make_isolated_home "gangnam-money-integrity")
  MONEY_INTEGRITY_RAW=$(run_limited env HOME="$MONEY_INTEGRITY_HOME" "$GODOT" --headless --quit-after 1200 res://tools/MoneyIntegrityCheck.tscn 2>&1)
  MONEY_INTEGRITY_STATUS=$?
  cleanup_isolated_home "$MONEY_INTEGRITY_HOME"
  echo "$MONEY_INTEGRITY_RAW" | grep -E "MONEY_INTEGRITY_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$MONEY_INTEGRITY_RAW" \
      "$MONEY_INTEGRITY_STATUS" "MONEY_INTEGRITY_CHECK_OK" strict; then
    MONEY_INTEGRITY_EXIT=0
  else
    MONEY_INTEGRITY_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 현금 정합성 체크 건너뜀."
  MONEY_INTEGRITY_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 세로 연락폰 대화·연락처 필터·Deck 해상도·모달 포커스 계약"
if [ -x "$GODOT" ]; then
  COMMUNICATION_PHONE_HOME=$(make_isolated_home "gangnam-communication-phone")
  COMMUNICATION_PHONE_RAW=$(run_limited env HOME="$COMMUNICATION_PHONE_HOME" "$GODOT" --headless --quit-after 1200 res://tools/CommunicationPhoneCheck.tscn 2>&1)
  COMMUNICATION_PHONE_STATUS=$?
  cleanup_isolated_home "$COMMUNICATION_PHONE_HOME"
  echo "$COMMUNICATION_PHONE_RAW" | grep -E "COMMUNICATION_PHONE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$COMMUNICATION_PHONE_RAW" \
      "$COMMUNICATION_PHONE_STATUS" \
      "COMMUNICATION_PHONE_CHECK_OK" strict; then
    COMMUNICATION_PHONE_EXIT=0
  else
    COMMUNICATION_PHONE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 세로 연락폰 체크 건너뜀."
  COMMUNICATION_PHONE_EXIT=0
fi

if [ -x "$GODOT" ]; then
  EVENT_DIRECTOR_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/EventDirectorCheck.tscn 2>&1)
  EVENT_DIRECTOR_STATUS=$?
  echo "$EVENT_DIRECTOR_RAW" | grep -E "EVENT_DIRECTOR_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$EVENT_DIRECTOR_RAW" "$EVENT_DIRECTOR_STATUS" \
      "EVENT_DIRECTOR_CHECK_OK"; then
    EVENT_DIRECTOR_RUNTIME_EXIT=0
  else
    EVENT_DIRECTOR_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 랜덤 사건 편성 런타임 체크 건너뜀."
  EVENT_DIRECTOR_RUNTIME_EXIT=0
fi

echo "─────────────────────"
echo "● 첫 8주 계획·Boss 선택·지연 결과 수직 단면 검사"
if [ -x "$GODOT" ]; then
  CORE_CHOICE_RAW=$(run_limited "$GODOT" --headless --quit-after 1200 res://tools/CoreChoiceSliceCheck.tscn 2>&1)
  CORE_CHOICE_STATUS=$?
  echo "$CORE_CHOICE_RAW" | grep -E "CORE_CHOICE_SLICE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CORE_CHOICE_RAW" "$CORE_CHOICE_STATUS" \
      "CORE_CHOICE_SLICE_CHECK_OK"; then
    CORE_CHOICE_EXIT=0
  else
    CORE_CHOICE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 코어 선택 수직 단면 검사 건너뜀."
  CORE_CHOICE_EXIT=0
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
  ENDING_ROUTE_STATUS=$?
  cleanup_isolated_home "$ENDING_ROUTE_HOME"
  echo "$ENDING_ROUTE_RAW" | grep -E "ENDING_ROUTE_IDENTITY_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$ENDING_ROUTE_RAW" "$ENDING_ROUTE_STATUS" \
      "ENDING_ROUTE_IDENTITY_CHECK_OK"; then
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
python3 tools/scene_audio_catalog.py
SCENE_AUDIO_CATALOG_EXIT=$?
python3 tools/full_run_audio_audit.py
FULL_RUN_AUDIO_EXIT=$?
python3 tools/scene_direction_catalog.py
SCENE_DIRECTION_CATALOG_EXIT=$?
python3 tools/full_run_direction_audit.py
FULL_RUN_DIRECTION_EXIT=$?
python3 tools/game_audio_contract_check.py
GAME_AUDIO_CONTRACT_EXIT=$?
python3 tools/generate_gangnam_ui_sfx.py --check
UI_SFX_EXIT=$?
python3 tools/generate_launch_audio.py --check
LAUNCH_AUDIO_EXIT=$?
if [ -x "$GODOT" ]; then
  AUDIO_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/AudioAssetCheck.tscn 2>&1)
  AUDIO_STATUS=$?
  echo "$AUDIO_RAW" | grep -E "AUDIO_ASSET_CHECK_OK|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$AUDIO_RAW" "$AUDIO_STATUS" \
      "AUDIO_ASSET_CHECK_OK"; then
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
  GAME_AUDIO_STATUS=$?
  echo "$GAME_AUDIO_RAW" | grep -E "GAME_AUDIO_RUNTIME_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$GAME_AUDIO_RAW" "$GAME_AUDIO_STATUS" \
      "GAME_AUDIO_RUNTIME_OK"; then
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
  BGM_STATUS=$?
  echo "$BGM_RAW" | grep -E "BGM_CONTINUITY_OK|BGM_CONTINUITY_FAIL|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$BGM_RAW" "$BGM_STATUS" \
      "BGM_CONTINUITY_OK"; then
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
  MORAL_AMBIENCE_STATUS=$?
  echo "$MORAL_AMBIENCE_RAW" | grep -E "MORAL_AMBIENCE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$MORAL_AMBIENCE_RAW" "$MORAL_AMBIENCE_STATUS" \
      "MORAL_AMBIENCE_CHECK_OK"; then
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
  IMMERSION_HOME=$(make_isolated_home "gangnam-immersion-loop")
  IMMERSION_RAW=$(run_limited env HOME="$IMMERSION_HOME" "$GODOT" --headless --quit-after 3600 res://tools/ImmersionLoopCheck.tscn 2>&1)
  IMMERSION_STATUS=$?
  cleanup_isolated_home "$IMMERSION_HOME"
  echo "$IMMERSION_RAW" | grep -E "IMMERSION_LOOP_CHECK_(OK|FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$IMMERSION_RAW" "$IMMERSION_STATUS" \
      "IMMERSION_LOOP_CHECK_OK"; then
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
  MOTIVATION_STATUS=$?
  echo "$MOTIVATION_RAW" | grep -E "MOTIVATION_IMPRINT_(OK|FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$MOTIVATION_RAW" "$MOTIVATION_STATUS" \
      "MOTIVATION_IMPRINT_OK"; then
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
  TUTORIAL_STATUS=$?
  echo "$TUTORIAL_RAW" | grep -E "TUTORIAL_INPUT_CHECK_OK|TUTORIAL_INPUT_CHECK_FAIL|ERROR:|SCRIPT ERROR" | sed 's/^/  /'
  if godot_check_passed "$TUTORIAL_RAW" "$TUTORIAL_STATUS" \
      "TUTORIAL_INPUT_CHECK_OK"; then
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
  STORY_TUTORIAL_STATUS=$?
  cleanup_isolated_home "$STORY_TUTORIAL_HOME"
  echo "$STORY_TUTORIAL_RAW" | grep -E "STORY_TUTORIAL_PLACEMENT_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$STORY_TUTORIAL_RAW" "$STORY_TUTORIAL_STATUS" \
      "STORY_TUTORIAL_PLACEMENT_CHECK_OK"; then
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
  STORY_PLAYBACK_STATUS=$?
  echo "$STORY_PLAYBACK_RAW" | grep -E "STORY_PLAYBACK_CHECK_OK|STORY_PLAYBACK_CHECK_FAIL|ERROR:|SCRIPT ERROR" | sed 's/^/  /'
  if godot_check_passed "$STORY_PLAYBACK_RAW" "$STORY_PLAYBACK_STATUS" \
      "STORY_PLAYBACK_CHECK_OK"; then
    STORY_PLAYBACK_EXIT=0
  else
    STORY_PLAYBACK_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 스토리 자동 재생 체크 건너뜀."
  STORY_PLAYBACK_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 대화 기록 노출·타이머·포커스·저장 경계 검사"
if [ -x "$GODOT" ]; then
  STORY_DIALOGUE_HISTORY_HOME=$(make_isolated_home "gangnam-story-dialogue-history")
  STORY_DIALOGUE_HISTORY_RAW=$(run_limited env HOME="$STORY_DIALOGUE_HISTORY_HOME" "$GODOT" --headless --resolution 1280x720 --quit-after 1200 res://tools/StoryDialogueHistoryCheck.tscn 2>&1)
  STORY_DIALOGUE_HISTORY_STATUS=$?
  cleanup_isolated_home "$STORY_DIALOGUE_HISTORY_HOME"
  echo "$STORY_DIALOGUE_HISTORY_RAW" | grep -E "STORY_DIALOGUE_HISTORY_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$STORY_DIALOGUE_HISTORY_RAW" \
      "$STORY_DIALOGUE_HISTORY_STATUS" "STORY_DIALOGUE_HISTORY_CHECK_OK"; then
    STORY_DIALOGUE_HISTORY_EXIT=0
  else
    STORY_DIALOGUE_HISTORY_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 대화 기록 체크 건너뜀."
  STORY_DIALOGUE_HISTORY_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 10슬롯·스토리 문단/선택/결과/타이머 수동 저장 검사"
if [ -x "$GODOT" ]; then
  MANUAL_SAVE_HOME=$(make_isolated_home "gangnam-manual-save")
  MANUAL_SAVE_RAW=$(run_limited env HOME="$MANUAL_SAVE_HOME" "$GODOT" --headless --resolution 960x600 --quit-after 3600 res://tools/ManualSaveCheck.tscn 2>&1)
  MANUAL_SAVE_STATUS=$?
  cleanup_isolated_home "$MANUAL_SAVE_HOME"
  echo "$MANUAL_SAVE_RAW" | grep -E "MANUAL_SAVE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$MANUAL_SAVE_RAW" "$MANUAL_SAVE_STATUS" \
      "MANUAL_SAVE_CHECK_OK" strict; then
    MANUAL_SAVE_EXIT=0
  else
    MANUAL_SAVE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 수동 저장 체크 건너뜀."
  MANUAL_SAVE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 대면·전화·영상통화·메시지·기억 초상 공간 검사"
if [ -x "$GODOT" ]; then
  STORY_PRESENCE_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/StoryPresenceCheck.tscn 2>&1)
  STORY_PRESENCE_STATUS=$?
  echo "$STORY_PRESENCE_RAW" | grep -E "STORY_PRESENCE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$STORY_PRESENCE_RAW" "$STORY_PRESENCE_STATUS" \
      "STORY_PRESENCE_CHECK_OK"; then
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
  LIVING_SCENE_STATUS=$?
  echo "$LIVING_SCENE_RAW" | grep -E "LIVING_SCENE_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$LIVING_SCENE_RAW" "$LIVING_SCENE_STATUS" \
      "LIVING_SCENE_CHECK_OK"; then
    LIVING_SCENE_EXIT=0
  else
    LIVING_SCENE_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — Living Scene 체크 건너뜀."
	LIVING_SCENE_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 전 구간 장면 전환·활동·엔딩·Reduce Motion 런타임 검사"
if [ -x "$GODOT" ]; then
  SCENE_DIRECTION_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/SceneDirectionCheck.tscn 2>&1)
  SCENE_DIRECTION_STATUS=$?
  echo "$SCENE_DIRECTION_RAW" | grep -E "SCENE_DIRECTION_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$SCENE_DIRECTION_RAW" "$SCENE_DIRECTION_STATUS" \
      "SCENE_DIRECTION_CHECK_OK"; then
    SCENE_DIRECTION_RUNTIME_EXIT=0
  else
    SCENE_DIRECTION_RUNTIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 장면 연출 런타임 체크 건너뜀."
  SCENE_DIRECTION_RUNTIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 본문·제목·선택지·상태 텍스트 재질 계약 검사"
if [ -x "$GODOT" ]; then
  TEXT_MATERIAL_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/TextMaterialCheck.tscn 2>&1)
  TEXT_MATERIAL_STATUS=$?
  echo "$TEXT_MATERIAL_RAW" | grep -E "TEXT_MATERIAL_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$TEXT_MATERIAL_RAW" "$TEXT_MATERIAL_STATUS" \
      "TEXT_MATERIAL_CHECK_OK"; then
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
  STORY_AUDIO_STATUS=$?
  cleanup_isolated_home "$STORY_AUDIO_HOME"
  echo "$STORY_AUDIO_RAW" | grep -E "STORY_AUDIO_SETTINGS_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$STORY_AUDIO_RAW" "$STORY_AUDIO_STATUS" \
      "STORY_AUDIO_SETTINGS_CHECK_OK"; then
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
  INPUT_MATRIX_STATUS=$?
  cleanup_isolated_home "$INPUT_MATRIX_HOME"
  echo "$INPUT_MATRIX_RAW" | grep -E "INPUT_MATRIX_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$INPUT_MATRIX_RAW" "$INPUT_MATRIX_STATUS" \
      "INPUT_MATRIX_CHECK_OK"; then
    INPUT_MATRIX_EXIT=0
  else
    INPUT_MATRIX_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 입력·화면 매트릭스 체크 건너뜀."
  INPUT_MATRIX_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 패드 의미 버튼·trigger edge·모달 누수·진동 설정 검사"
if [ -x "$GODOT" ]; then
  CONTROLLER_SEMANTIC_HOME=$(make_isolated_home "gangnam-controller-semantic")
  CONTROLLER_SEMANTIC_RAW=$(run_limited env HOME="$CONTROLLER_SEMANTIC_HOME" "$GODOT" --headless --quit-after 3600 res://tools/ControllerSemanticCheck.tscn 2>&1)
  CONTROLLER_SEMANTIC_STATUS=$?
  cleanup_isolated_home "$CONTROLLER_SEMANTIC_HOME"
  echo "$CONTROLLER_SEMANTIC_RAW" | grep -E "CONTROLLER_SEMANTIC_CHECK_(OK|FAIL)|ERROR:|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CONTROLLER_SEMANTIC_RAW" "$CONTROLLER_SEMANTIC_STATUS" \
      "CONTROLLER_SEMANTIC_CHECK_OK" strict; then
    CONTROLLER_SEMANTIC_EXIT=0
  else
    CONTROLLER_SEMANTIC_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 패드 의미 입력 체크 건너뜀."
  CONTROLLER_SEMANTIC_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 업적 15종 카탈로그/번역/실제 해금 경로 검사"
if [ -x "$GODOT" ]; then
  ACHIEVEMENT_HOME=$(make_isolated_home "gangnam-achievements")
  ACHIEVEMENT_RAW=$(run_limited env HOME="$ACHIEVEMENT_HOME" "$GODOT" --headless --quit-after 3600 res://tools/AchievementPathCheck.tscn 2>&1)
  ACHIEVEMENT_STATUS=$?
  cleanup_isolated_home "$ACHIEVEMENT_HOME"
  echo "$ACHIEVEMENT_RAW" | grep -E "ACHIEVEMENT_PATH_CHECK_OK|ACHIEVEMENT_PATH_CHECK_FAIL|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$ACHIEVEMENT_RAW" "$ACHIEVEMENT_STATUS" \
      "ACHIEVEMENT_PATH_CHECK_OK"; then
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
  HIDDEN_STATUS=$?
  cleanup_isolated_home "$HIDDEN_HOME"
  echo "$HIDDEN_RAW" | grep -E "HIDDEN_FEATURE_(CHECK_OK|CHECK_FAIL|EVIDENCE)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$HIDDEN_RAW" "$HIDDEN_STATUS" \
      "HIDDEN_FEATURE_CHECK_OK"; then
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
  HOUSING_KEEPSAKE_STATUS=$?
  cleanup_isolated_home "$HOUSING_KEEPSAKE_HOME"
  echo "$HOUSING_KEEPSAKE_RAW" | grep -E "HOUSING_KEEPSAKE_(CHECK_OK|CHECK_FAIL|EVIDENCE)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$HOUSING_KEEPSAKE_RAW" \
      "$HOUSING_KEEPSAKE_STATUS" "HOUSING_KEEPSAKE_CHECK_OK"; then
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
  YEAR_IDENTITY_STATUS=$?
  echo "$YEAR_IDENTITY_RAW" | grep -E "YEAR_IDENTITY_(CHECK_OK|CHECK_FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$YEAR_IDENTITY_RAW" "$YEAR_IDENTITY_STATUS" \
      "YEAR_IDENTITY_CHECK_OK"; then
    YEAR_IDENTITY_EXIT=0
  else
    YEAR_IDENTITY_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 연차 정체성 체크 건너뜀."
	YEAR_IDENTITY_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 1·3·5년 인물 외형·상황복 잠금·관계 stage 비간섭 검사"
if [ -x "$GODOT" ]; then
  CAST_VISUAL_TIME_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/CastVisualTimeCheck.tscn 2>&1)
  CAST_VISUAL_TIME_STATUS=$?
  echo "$CAST_VISUAL_TIME_RAW" | grep -E "CAST_VISUAL_TIME_(CHECK_OK|CHECK_FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$CAST_VISUAL_TIME_RAW" "$CAST_VISUAL_TIME_STATUS" \
      "CAST_VISUAL_TIME_CHECK_OK"; then
    CAST_VISUAL_TIME_EXIT=0
  else
    CAST_VISUAL_TIME_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 인물 시간 외형 체크 건너뜀."
  CAST_VISUAL_TIME_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● 데모 빌드 flavor·1~8주 정본 체인·24주 차단 검사"
if [ -x "$GODOT" ]; then
  DEMO_BUILD_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 res://tools/DemoBuildCheck.tscn -- --demo-build 2>&1)
  DEMO_BUILD_STATUS=$?
  echo "$DEMO_BUILD_RAW" | grep -E "DEMO_BUILD_(CHECK_OK|CHECK_FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$DEMO_BUILD_RAW" "$DEMO_BUILD_STATUS" \
      "DEMO_BUILD_CHECK_OK"; then
    DEMO_BUILD_EXIT=0
  else
    DEMO_BUILD_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — 데모 빌드 계약 체크 건너뜀."
  DEMO_BUILD_EXIT=0
fi

echo "──────────────────────────────────────────"
echo "● V2 release playtest 진입·표식·게임 쓰기 데이터 격리 검사"
if [ -x "$GODOT" ]; then
  PLAYTEST_FLAVOR_RAW=$(run_limited "$GODOT" --headless --quit-after 3600 \
    res://tools/PlaytestFlavorCheck.tscn -- \
    --demo-build --core-loop-v2-playtest-build 2>&1)
  PLAYTEST_FLAVOR_STATUS=$?
  echo "$PLAYTEST_FLAVOR_RAW" | grep -E \
    "PLAYTEST_FLAVOR_(CHECK_OK|CHECK_FAIL)|SCRIPT ERROR|Parse Error|Compile Error" | sed 's/^/  /'
  if godot_check_passed "$PLAYTEST_FLAVOR_RAW" "$PLAYTEST_FLAVOR_STATUS" \
      "PLAYTEST_FLAVOR_CHECK_OK" strict; then
    PLAYTEST_FLAVOR_EXIT=0
  else
    PLAYTEST_FLAVOR_EXIT=1
  fi
else
  echo "  ⚠ Godot 실행파일 없음 ($GODOT) — V2 playtest flavor 체크 건너뜀."
  PLAYTEST_FLAVOR_EXIT=0
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
  GD_STATUS=$?
  echo "$RAW" | grep -E "COMPILE_SCAN" | sed 's/^/  /'
  GD_OUT=$(echo "$RAW" | grep -v "COMPILE_SCAN" \
    | grep -iE "ERROR:|SCRIPT ERROR|Failed to load script|Parse Error|Compile Error" \
    | grep -viE "Cannot open|No loader|\.png|\.ogg|\.mp3|AudioStream|texture|\.import")
  if [ "$GD_STATUS" -ne 0 ] || [ -n "$GD_OUT" ]; then
    echo "  ✗ 컴파일 에러:"
    if [ "$GD_STATUS" -ne 0 ]; then
      echo "    Godot 종료코드: $GD_STATUS"
    fi
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
# 게이트가 모든 검사 플래그를 모으므로, 실패 시 어떤 검사가 걸렸는지 이름으로
# 알려 준다. 검사마다 ✗를 찍지 않는 경로가 있어 이름 없이는 추적이 어렵다.
AUDIT_EXIT_FLAGS="
  CONTEXT_MANIFEST_EXIT QUEUE_CONSISTENCY_EXIT RELEASE_CONTENT_EXIT RELEASE_CONTENT_SELF_TEST_EXIT BUILD_IDENTITY_EXIT THIRD_PARTY_NOTICE_EXIT EVENT_LIFECYCLE_EXIT EVENT_LIFECYCLE_SELF_TEST_EXIT PY_EXIT OPPORTUNITY_MONEY_AUDIT_EXIT STORY_CONSISTENCY_EXIT STORY_MAP_EXIT YEAR5_REFERENCE_ROUTE_EXIT YEAR5_REFERENCE_ROUTE_R1_EXIT SPEECH_REGISTER_EXIT RANDOM_POOL_HYGIENE_EXIT SURFACE_EXIT
  PACING_EXIT DEMO_EXPERIENCE_EXIT PLAYTEST_REPORT_EXIT NARRATIVE_CONTINUITY_EXIT FULL_RUN_PACING_EXIT NARRATIVE_SPINE_EXIT PLAYER_SURFACE_LANGUAGE_EXIT PLAYER_SURFACE_LANGUAGE_SELF_TEST_EXIT
  PEAK_CHAIN_EXIT KEY_ART_EXIT FIRST30_EXIT ART_AI_EXIT ART_RESOLUTION_EXIT ART_MASTER_EXIT CG_ACTING_EXIT
  CG_RUNTIME_EXIT CAST_DETAIL_EXIT EVENT_VISUAL_EXIT EN_HANGUL_EXIT EN_HANGUL_SELF_TEST_EXIT EN_COVERAGE_EXIT I18N_COVERAGE_EXIT I18N_SURFACE_EXIT JA_UI_EXIT JA_DEMO_INVENTORY_EXIT JA_DEMO_PIPELINE_SELF_TEST_EXIT JA_DEMO_AUDIT_EXIT ZH_DEMO_AUDIT_EXIT ZH_DEMO_SELF_TEST_EXIT DEMO_I18N_SCOPE_EXIT DEMO_I18N_SELF_TEST_EXIT DEMO_PROSE_STYLE_EXIT I18N_RUNTIME_EXIT FONT_ROUTING_EXIT
  MOD_LAYER_AUDIT_EXIT MOD_LAYER_RUNTIME_EXIT BAL_EXIT EVENT_DIRECTOR_EXIT EXPOSED_STATE_EXIT PHONE_SYSTEM_EXIT MONEY_INTEGRITY_EXIT COMMUNICATION_PHONE_EXIT
  CORE_LOOP_V2_EXIT CHAPTER1_CAUSAL_LEDGER_SELF_TEST_EXIT CHAPTER1_CAUSAL_LEDGER_EXIT CORE_LOOP_V2_BALANCE_EXIT CORE_LOOP_V2_RUNTIME_EXIT CORE_LOOP_V2_B_RUNTIME_EXIT CORE_LOOP_V2_C_RUNTIME_EXIT
  CORE_LOOP_V2_D_RUNTIME_EXIT CORE_LOOP_V2_E_RUNTIME_EXIT CORE_LOOP_V2_CYCLE_EXIT CORE_LOOP_V2_CYCLE_BALANCE_EXIT CORE_LOOP_V2_FIRST_ENTRY_EXIT CORE_LOOP_V2_HANDOFF_EXIT
  EVENT_DIRECTOR_RUNTIME_EXIT CORE_CHOICE_EXIT ENDING_DISTINCTNESS_EXIT ENDING_ROUTE_EXIT AUDIO_SOURCE_EXIT SCENE_AUDIO_EXIT
  SCENE_AUDIO_CATALOG_EXIT FULL_RUN_AUDIO_EXIT SCENE_DIRECTION_CATALOG_EXIT FULL_RUN_DIRECTION_EXIT GAME_AUDIO_CONTRACT_EXIT UI_SFX_EXIT
  LAUNCH_AUDIO_EXIT AUDIO_EXIT GAME_AUDIO_RUNTIME_EXIT BGM_EXIT MORAL_AMBIENCE_EXIT IMMERSION_EXIT
  MOTIVATION_EXIT TUTORIAL_EXIT STORY_TUTORIAL_EXIT STORY_PLAYBACK_EXIT STORY_DIALOGUE_HISTORY_EXIT MANUAL_SAVE_EXIT SURFACE_COHERENCE_EXIT IDENTITY_SIGNATURE_EXIT FEATURE_LIVENESS_EXIT STATUS_DOC_EXIT HUMAN_GATES_EXIT
  STORY_PRESENCE_EXIT LIVING_SCENE_EXIT SCENE_DIRECTION_RUNTIME_EXIT TEXT_MATERIAL_EXIT STORY_AUDIO_EXIT INPUT_MATRIX_EXIT CONTROLLER_SEMANTIC_EXIT
  ACHIEVEMENT_EXIT HIDDEN_EXIT HOUSING_KEEPSAKE_EXIT YEAR_IDENTITY_EXIT CAST_VISUAL_TIME_EXIT DEMO_BUILD_EXIT PLAYTEST_FLAVOR_EXIT
  TRAILER_EXIT GD_EXIT
"
AUDIT_FAILED=""
for _flag in $AUDIT_EXIT_FLAGS; do
  eval "_value=\${$_flag}"
  if [ -z "$_value" ]; then
    echo "  ⚠ $_flag 미설정 — 해당 검사가 실행되지 않았습니다."
  elif [ "$_value" -ne 0 ]; then
    AUDIT_FAILED="$AUDIT_FAILED $_flag"
  fi
done
if [ -n "$AUDIT_FAILED" ]; then
  echo "❌ 감사 실패 — 아래 검사가 실패했습니다:"
  for _flag in $AUDIT_FAILED; do echo "   - $_flag"; done
  exit 1
fi
echo "✅ 감사 통과"

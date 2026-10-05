# ORDER-470 — 선택 사실에 맞는 재혁·다은 회수와 고정 파일 후속 계약

#### [~] ORDER-470 [P0·사용자 지시] 경로명 노출·과거 선택 발명·헤어진 관계 응답을 수리한다

**착수 선언 — 2026-10-06.** ORDER-469 최종 표적 회귀 뒤 사용자 최신 A지시를
최우선 별도 단위로 등록한다. 선언 커밋·push 뒤 구현하며 현재 구현/검증 완료가 아니다. PR31 문장 들이기와 4장 지연6개 분리는 재실행하지 않는다.

## 근거와 한 단위의 경계

사용자 7k, DECISIONS 2026-10-01과 CODEX_RETURN_PLAN_2026-09-30의 같은 고정 파일
수리를 따른다. `arc_jaehyuk_aftermath`, `arc_daeun_later_echo`,
`arc_jaehyuk_04b_counter` 세 원고와 실제 선택 가능성만 소유한다.
공개 BUILD/패키지를 교체하지 않는다. five-locale `arc_events.json`은 이전 고정
계약을 덮어쓰지 않고 정확한 새 제품 커밋/부모/경로/잎 역상과 함께 들인다.

### 깊이 3문

1. 수리를 빼면 플레이어가 고르지 않은 신고/협박/피해자 이력과 헤어진 상대의 응답을 선택할 수 있다.
2. 기존 상태 변화·후속 독자는 보존하고, 현재 확인된 사실만 같은 결과를 생산할 수 있게 한다.
3. 동일 화면에서 확인된 재혁 이력 선택끼리 경쟁하며, 이력 없는 구저장은 중립적으로만 다음 장면에 간다.

## 실제 입력 계약

- 공통 소유 `GameState.choice_available`에 닫힌 `requires_story_fact` 계약을 추가한다.
  StoryMode 표시와 GameState.apply_choice가 이미 같은 함수를 소비한다.
  다른 사건의 일반 flag expression이나 범용 자동 fallback 엔진은 만들지 않는다.
- exact event/choice index에만 허용한 enum이다. 알려지지 않은 enum/잘못된 타입/다른 슬롯은
  실패 닫힘이다. 계약이 없는 다른 사건·requires_item·기회 비용/fallback은 그대로다.
- 대상 사건에서는 선택의 실제 소속 슬롯을 확인한다. 필수 marker 누락, detached choice,
  모호한 중복 선택, 잘못된 choices 구조도 표시·직접 적용에서 거절한다. 관련 flag의
  비불리언 값은 참으로 강제 변환하거나 '사실 없음'으로 바꿔 중립 선택을 열지 않는다.
  비대상 사건의 소속 판정을 이번 수리에서 새로 제한하지 않는다.
- aftermath0: jaehyuk_reported 또는 took_high_road. aftermath1: jaehyuk_exploited 또는
  jaehyuk_partnered. aftermath2: jaehyuk_scammed. 일반 crossed_line은 근거가 아니다.
- 사용자 지시의 take_high_road는 실제 생산자 took_high_road로 연결하며 새 별칭을 만들지 않는다.
  crossed_line은 다른 인물 선택도 생산하고 동업은 쓰지 않으므로 재혁의 구체 사실을 쓴다.
- 기존0~2의 인덱스·효과·후속은 보존한다. 라벨의 내부 경로명과 무조건 선택을 없앤다.
  본문은 피해자/기록 없는 저장에도 참인 표현으로 정렬한다.
- 과거 사실5개가 모두 없는 저장에만 새 index3 중립 응답을 연다. 과거 결정을 발명하거나
  보상/관계/도덕 플래그를 주지 않고 aftermath_seen과 기존 mirror 지연1만 이어 준다.
- later_echo0의 양성은 사용자 작업표가 명시한 daeun_romance_started다. close_bond/
  together_path/married/affinity/stage 단독으로 확대하지 않는다. 명시적 단절은 양성보다 우선:
  daeun_let_her_go, daeun_breakup_accepted, daeun_breakup_begged, daeun_let_drift,
  daeun_asked_finally, daeun_romance_blocked, daeun_divorced,
  arc_daeun_year3_apart_seen, arc_daeun_ghost_seen, arc_daeun_year5_apart_seen.
  daeun_ended는 양 경로가 쓰므로 단절 판정에 쓰지 않는다.
- additive flag와 잔존 close/together 사실로 이별 뒤 Y5고백이 열릴 수 있다는 소스 결함은
  별도 남긴다. 이번에는 본문 수리와 later_echo의 producer gate만 소유하며 연애 시스템 전체를
  재설계하지 않는다. 기존 원어민/실제 플레이 증거를 새로 발급하지 않는다.
- F9는 실제 첫 만남의 삼각김밥 회수로, 04b_counter는 서술자 도덕 판정 대신 현재 행동으로
  수리한다. 기사의 피해액23억·문단/큐 시점·대가·배경·출연·선택 결과 효과는 보존한다.
  신고 결과의 미투자 손실/추가23억 피해 방지 단정은 실제 생산자와 맞는 행동으로 수리한다.
  counter의 기존 선택 라벨·효과·플래그는 사용자 보존 지시를 따른다.
  '내 돈 세 배' 라벨과 후속 callback의 원금/피해자 오인은 별도 사실 수리로 남기며
  이번 세 장면 GO를 그 인접 콜백이나 재혁 전체 서사 GO로 확대하지 않는다.
- 갤러리는 이미 저장된 visible_choice_indices를 읽는다. 현재 flag로 옛 기록을 재판정하지 않는다.

## 선언 파일 소유

- 원고/공식수용(root): `content/events/arc_events.json`, `content/events_en/arc_events.json`,
  `content/events_ja/arc_events.json`, `content/events_zh-CN/arc_events.json`,
  `content/events_zh-TW/arc_events.json`, `content/meta/full_game_localization.json`.
- 런타임/스키마(order469_main에서 인계): `autoloads/GameState.gd`, `autoloads/DataRegistry.gd`, `tools/audit.py`,
  `tools/mod_pack_validator.py`, `tools/convergence_sim.py`, `tools/arc_flow_sim.py`,
  신규 `tools/StoryChoiceFactCheck.gd/.tscn`, `tools/story_choice_fact_audit.py`.
  DataRegistry는 기존 mod 텍스트 override가 원본 선택 사실 gate를 잃지 않게
  원래 스케줄 키와 같은 보존 경계에 연결한다. 유효한 예전 mod도 진행을 막거나 우회하지 않는다.
- 정확한 후속 증명(order469_history에서 인계): 신규 `tools/order470_source_compat.py`,
  `tools/order470_source_compat_self_test.py`,
  `tools/demo_localization_scope.py`, `tools/main_game_locale_history.py`,
  `tools/ja_translation_pipeline.py`, `tools/pr31_intake_history.py` 및 자체검사,
  `tools/ui_translation_append.py`, `tools/full_body_translation_scope.py`,
  `tools/order469_source_compat.py` 및 자체검사. 기존469의 current7파일 검증은
  다음 release inventory 변화도 거부하므로 새 exact 전이를 역상하는 연결이 필요하다.
  기존 핀·음성검사를 덮어쓰지 않는다.
  GameState와 DataRegistry의 실제 raw/기존 UI collector 핀도 같은 exact 역상으로 잇는다.
- root: `docs/CHOICE_CONSEQUENCE_SYSTEM.md`의 지속 choice fact 규칙,
  `content/meta/release_content_inventory.json`, 생성 `docs/CONTENT_RATING_INVENTORY.md`,
  `tools/audit_scope.json`, 큐/사양/CLAUDE현재/WORK_LOG/생성STATUS/에이전트 판정 원장.
- 독립 검수자(order469_review에서 인계): `docs/agent_reviews/ORDER-470.json`만 작성. 저작과 검수 분리.
- StoryMode/EventManager/MetaProgression/기존 demo manifest·모든 이전 핀은 read-only.
  project.godot·공개 패키지·사용자 저장·인간 원장·외부 출시/스토어/지출 금지.
  새로 발견한 소유 파일은 수정 전에 별도 선언한다.

## 저작·공식 수용 순서

기존 장면의 사실/문장 수리다. 계층을 올리거나 링크·자산을 새로 늘리지 않는다.
새 중립 선택도 기존 회수 비트에서 나오며 다른 장소/참가자/과거를 발명하지 않는다.
계층·원고·연출/오디오 실제 계약을 먼저 확인하고 5언어를 원문 기준으로 독립 작성한다.

KO index3만 먼저 늘리면 공식 export 이전 overlay 길이 검사가 막힌다. 따라서 5언어의
index3 완성 초안 구조를 먼저 맞추되 기존 목표어0~2는 보존한다. 새 제품 후보를 고정한 뒤
정확한 변경 잎을 공식 export → check --replace-existing → import --accept --replace-existing로
수용한다. 새 index3 선기입은 수용이 아니라 초안이다. 기존 배치/영수증은 지우지 않는다.

## 표적 검증과 완료 경계

필수 도구: `en_coverage_check.py`, `english_hangul_audit.py`,
`narrative_continuity_audit.py`, `scene_audio_contract_check.py`, `speech_register_audit.py`,
`release_content_inventory.py`, `demo_localization_scope.py` 정상/자체,
`ja_translation_audit.py --scope demo`, `ja_translation_pipeline.py --scope demo --inventory`/자체,
`zh_translation_audit.py` 정상/자체, `story_demo_localization_audit.py` 정상/자체.
새 실패0 이전에는 완료하지 않는다. 기존 실패는 실제 baseline 대조와 함께 남긴다.


- 신고/협박/동업/피해자/기록 없음/일반 crossed_line/혼합·잘못된 flag·잘못된 계약.
- started 양성, 단절10개 각각의 우선, married/close/together-only 음성, all-unknown.
- 실제 StoryMode 노출 인덱스, 직접 apply_choice 거절·상태불변, original0~2 resume/
  gallery 기억 보존, index3→mirror 한번, 기존 item/opportunity/fallback 회귀.
- DataRegistry의 text-only mod 재구성에서 원래 gate 보존, marker 누락/위조·타입 오류 실패 닫힘,
  Python mod 검사와 실제 런타임 정책 일치·5언어 로드 후 같은 게이트를 확인한다.
- pre-autoload 격리·현재/seed/공개/사용자 저장 및 source 전후 동일·marker와 모든 engine오류0.
- 기존 공개14사건 및 legacy72사건/467잎 불변 실제 collector, 5언어 선택수/토큰/문단 패리티,
  경로명0, source/target 새불일치0·공식 변경 잎 전수수용, exact successor 음성검사.
- 공유 이력 검증은 동결 후 한 호출 안에서 공통 admission을 공유한다. 개별 검사 예외는
  실패로 저장하고 독립 소비자 검사는 계속해, 한 자체검사 오류로 후속 증거를 잃지 않는다.
  검사 코드·모든 대상 입력/의존성·증거 기준점이 같은 완료 검사는 반복하지 않는다.
  입력이 바뀐 소비자는 검사 코드가 그대로여도 재실행한다.
- 화면 접근이 가능한 경우 이3장면의 실제 표적 렌더/입력. 준비 상태 시험·자연플레이·
  원어민/물리패드 관찰은 구분하고 미관찰을 숨기지 않는다. 전체240주/출시 GO는 아니다.

그다음 별도 단위: `_person_deal`의 다은/야간진료 DIK, 준비된2장 수첩·5장 기간 초안.

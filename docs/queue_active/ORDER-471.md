# ORDER-471 — 놓친 다은 약속과 야간진료를 실제 조건으로 구분한다

#### [~] ORDER-471 [사용자 지시] 4장 person_deal 본문 사실·중립 결과 수리

**착수 선언 — 2026-10-06.** 사용자 B와 DECISIONS 2026-10-03,
CODEX_RETURN_PLAN_2026-09-30 7k의 후속 한 단위다. 선언 커밋 뒤 구현한다.
이 선언은 구현/공식 수용/완료 증거가 아니다.

## 경계와 깊이 3문

- 대상은 `arc_36_unexpected_hand_person_deal` 한 회수 사건이다.
  `_father_deal`과 합치지 않으며 제목·선택1 라벨·인덱스·플래그·효과·라우팅·자산은 보존한다.
- 수리를 빼면 자기 야간진료를 놓친 플레이어에게 사람의 연락창을 열었다고 말한다.
- 원래 선택의 생산자/독자·상태 변화는 그대로다. 아버지 통화를 지킨 뒤 놓친 두 일정 중
  사람/진료를 다시 잡거나 계약 검토를 다시 잡는 기존 경쟁과 대가를 명확히 한다.
- 선택 하나가 나머지 하나의 이번 주 가능 시각을 닫는 기존 비용을 유지한다.

## 실제 본문 선택 계약

Main의 기본 three_promises 선택 사실 `daeun_romance_started && !daeun_divorced`와 같다.
기존 StoryMode의 첫 일치 DIK 소비를 쓰며 새 문법/공통 관계 판정을 만들지 않는다.
`description_if_known`은 `daeun_divorced` 먼저, `daeun_romance_started` 다음의 정확한 두 키다.
divorced 값은 기본 야간진료 본문과 동일해 두 flag가 동시에 참이어도 진료 본문을 쓴다.
다은 우선·지연 중첩·married-only·기존 truthiness를 실제 Main과 대조한다.
470의 이별10조건을 이 다른 경로에 가져오지 않는다.

- 기본: 놓친 야간진료 접수 안내/마감과 취소된 계약 검토 좌석.
- 다은: 선행 장면에서 받은 편의점 냉장고 사진과 처음 만난 편의점 앞 토요일 다섯 시 약속.
- 선택0/결과0/결과1은 양 경로 모두에 참인 가능 시각 확인·이동 여유로 정렬한다.
  연락창·'언제든'·시각을 보낸다는 일방 전제를 제거한다.
  야간진료는 본인 도착·신분 확인 뒤 접수되는 원래 조건을 보존한다. 달력의 재방문 시각을
  정한 것을 진료 예약이나 접수 완료로 바꾸어 쓰지 않는다.
- 기존 두 문단, 식은 커피/버스/환불 불가/경쟁 일정, 실제 가능한 한 자리의 비용을 유지한다.
- 초기 독립 사실 검수: 실제 W153→W157은4턴 간격이므로 수정 잎의 '지난 주말'은
  '그날 놓친 일정'으로 정렬한다. 토요일의 원래 시각은 회상으로 보존하며
  주차·라우팅은 바꾸지 않는다. 사용자 지시의 중립화 범위 안 시간 오인 수리다.

## 선언 파일·역할

- root 원문/공식 수용: `content/events/arc_chapter_themes.json`,
  `content/events_en/arc_chapter_themes.json`, `content/events_ja/arc_chapter_themes.json`,
  `content/events_zh-CN/arc_chapter_themes.json`, `content/events_zh-TW/arc_chapter_themes.json`,
  `content/meta/full_game_localization.json`, `content/meta/release_content_inventory.json`,
  생성 `docs/CONTENT_RATING_INVENTORY.md`.
- 별도 검사 저자: `tools/ChapterFourRelationshipCheck.gd`, `tools/chapter4_causal_route_audit.py`.
- 이력 지원: `tools/order470_source_compat.py`, `tools/order470_source_compat_self_test.py`,
  `tools/pr31_intake_history.py`, `tools/pr31_intake_history_self_test.py`,
  `tools/full_body_translation_scope.py`.
  새 프레임워크 없이 기존 typed Git/JSON span/fresh 경계를 재사용한다.
  470 R4의 42수용 끝점을 보존하고 이번 18수용은 별도 단계로 검증한다.
  제품 source 단계는 themes5경로, 공식 수용은 목표어3+ledger4경로다.
  초기 계획의 inventory/rating2경로는 실제 지문·정상 검사에서 변화가 없어 보존한다.
  사건수/분류/모든 축 지문이 같으므로 새 해시나 임의 메타를 만들어7경로를 채우지 않는다.
  실제 commit/부모/changed-set/현재 디스크로 봉인하며 과거 핀을 덮어쓰지 않는다.
- root 운영: `tools/audit_scope.json`, CLAUDE현재, CODEX_QUEUE, 이 사양/완료 보관본,
  WORK_LOG, 생성STATUS, agent_review_decisions 및 `docs/agent_reviews/ORDER-471.json`.
- 독립 검수자는 제품·초안·공식 영수증·실제 증거를 전수 읽고 보고 한 파일만 쓴다.

Main/StoryMode/DataRegistry/GameState, arc_events5, 공개 데모 계약과 project.godot,
사용자 저장·seed·인간 판정은 수정하지 않는다. 새 지원 파일 필요 시 먼저 별도 범위를 선언한다.

## 번역·검증

KO/EN 기존4잎 수정+DIK2잎 추가. JA/zh-CN/zh-TW는 각6잎, 합계18잎이며
교정12+최초수용6을 공식 export/check/import로 처리한다. 기존 수용 기록을 삭제하지 않는다.
사전 구조/번역 초안은 공식 수용이 아니다. 원문·목표어 해시/토큰/문단·해당 원장 영수증과
현재 release inventory를 같은 작업에서 결속한다.

첫 공식 시도는 수량표현 검사에서 import 전에 중단했다. 중국어 두 곳/버스 두 번은
의미를 보존한 `两处/兩處`·`先後兩次`로 명확히 한다. 기존 source5의 목표어 DIK 초안은
역사 그대로 두고 공식 수용 때 함께 교정한다. 영수증18(최초6/교정12)은 같으며
실제 목표어 문자열 교체는 JA4/CN6/TW6으로 좁혀 증명한다.

- 실제 Main 선택기/StoryMode 본문·5언어: 기본/started/divorced/둘 다/지연 중첩/married-only/
  기존 truthiness, DIK순서 역전·키 누락/추가·기본≠divorced 음성. 기존 준비64사례 보존.
- 대상 외 raw와 모든 선택 gameplay 불변, 공개14/legacy72·467잎 불변.
- exact5 source/4 receipt 전이, 이전 원문·이웃 잎·위조 영수증/census·warm후변경 거절.
- en_coverage, english_hangul, narrative_continuity, scene_audio_contract, speech_register,
  chapter4_causal_route, release inventory 및 새 이력 자체검사.
- 실제 본문/UI collector·365/469/470 후속 소비, fullbody 정상/변경 음성 및 데모 표적 검사.
  같은 입력의 완료 검사를 이유 없이 반복하지 않고, 변경된 입력을 읽는 소비자는 재검증한다.
- 현재/과거/seed/공개 보호 스냅샷을 가진 pre-autoload 격리 준비 런타임.
  정확한 성공 marker와 stdout/Godot log 오류0을 함께 요구한다.
- context/queue/증거 원장/감사 매핑/diff를 확인한다. 새 실패0과 독립 판정 전 완료하지 않는다.

L2 증거 양식은 실제 실행 뒤 채운다. 준비 상태 검사와 자연 플레이/렌더/원어민/물리패드
관찰을 구분하며, 이번 장면의 한정 GO를 4장 전체·본편 출시 GO로 확대하지 않는다.
과거 YEAR5/노출계약 실패와 인간 OPEN은 보존한다.

## 현재 검증과 남은 직접 결함 — 2026-10-06

공식18잎 수용 뒤 clean `19cab1c`의 준비 런타임129(기존64+새65), 빠른 검사11,
최종 표적13은 정상 종료·새 실패0이다. final1은 실제 fresh 입장·두 outer 정상 종료와
원문/실행기/로그 보존까지 확인했다. 정확한 결과 SHA와 시간은 WORK_LOG에 남긴다.

독립 읽기에서 `arc_y4_body_witness`와 `_hyunsu`의 repaired_person 기억이 새 중립 결과에
없는 두 시각 전송/일정 확정을 회수하는 불일치를 확인했다. 진료 예약 단정은 기존 부채이고,
전송/확정 불일치는 이번 생산자 수정의 새 파급이므로 자동 PASS만으로 완료하지 않는다.
별도 [472](ORDER-472.md)의 첫 두 잎으로 두 실제 생산자가 함께 보장하는 달력/이동 시간만
회수하도록 맞춘 뒤 연결 검수한다. 지연 author_only 독자와 인간 판정은 보존한다.

그다음 지정 수첩/기간 초안6사건도472의 분리된 모집단으로 함께 처리해 공식 이력 검증을 공유한다.

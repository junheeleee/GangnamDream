# ORDER-705 — M36 자산 전진 단정의 source 사실 수리

#### [~] ORDER-705 [C2 source-only] 착수 — 만지는 제품 파일: story_events KO/EN 두 파일

## 확인 근거와 범위

701/702 실제 플레이의 보존 final W141은 money−10973976/portfolio{}/loans0다.
`GameState.get_total_asset_value`는 money+portfolio−loans이며 시작500000보다
30억 목표까지의 거리가 늘었다. 그런데 `story_three_year.description` 3문단은
자산별 조건 없이 “처음보다 가까워졌다/The numbers said it was closer”를 단정한다.
독립 사전 진단도 actual 저장·본문 선택기와 계산을 직접 대조해 이 반대 사실을
확인했다. 후반 본문을 실제 화면에서 관측한 증거는 아니며 M36 선택은 0이다.
미선택 결과의 “출근/work”는 무직 경로의 승인된 단기 생계와 양립하므로 이번에
고치거나 허위 직장 결함으로 등록하지 않는다. 과거 복원 HOLD·문체 오더 재개0.

root 저작 소유: `content/events/story_events.json` 및
`content/events_en/story_events.json`의 `story_three_year.description` 3문단만.
아래 문안으로 각1잎의 해당 문단만 바꾸고 다른3문단·{name}·title/id·선택/결과·
flags/effects/조건·순서·라우팅은 exact 보존한다.

- KO: 강남은 아직 멀었다. 집들이 사진을 넘기던 손끝이 매끈한 화면 위에서 멈췄다. 그런데 목표를 접는 장면을 상상하면 이상하게 숨이 더 막혔다.
- EN: Gangnam was still far away. His fingertip stopped over a housewarming photo, resting against the smooth screen. Yet imagining himself folding up the goal made it harder to breathe.

기존 SCENE_TIER 공통 산문 계약의 현재 행동/감각을 적용한다. 앞 문단에 이미
있는 집들이 사진·화면·손끝이며 새 과거·직업·관계·기간·거래0. 신규 장면/계층
상승·방향/자산/시스템/밸런스/정본 변경은 아니다. 703 첫문단 수리도 보존한다.

root metadata 소유: 이사양/archive·CODEX_QUEUE/L3순번·CLAUDE 현재행·WORK_LOG;
private `.git/order705-progress-20261016/` 원본2파일/before/after/표적raw/root검증.
비저자 `/root/m32_path_review`는 source·보존final·진단 함수·선언·raw를 읽고
위 private의 independent-review.{md,json}만 쓴다. Git/engine/UI/실사용자path0.
두잎 전수·전체raw역산·비소유content/runtime/원장 지문을 독립 검수한다.
선언commit/push 먼저, 구현/표적/독립검수 뒤 한 마감commit이다.

JA/zh384event파일·번역원장·사용자16.2앱/설정/저장·원16.4앱/저장·rootproject/
BuildInfo·공개demo·Human/agent판정원장·제품검사/CI/KNOWN_FAILURES는 비소유다.
CJK description 영수증3은 703에서 이미 stale다. 승인hash를 재결속하거나
번역을 새로 수용하지 않는다. 새후반실화면/실제월·새빌드/엔진/앱 접근0.

## 판정과 표적

깊이3문: 제거하지 않으면 실제 자산 궤적과 본문이 반대; 새선택/24주상태0;
현재 채팅사진 안의 감각으로 대체하며 사용자테스트 UI/저장과 경쟁0.
증거 양식: 보존actual final↔자산계산/무조건본문; before→after text2잎;
생산자↔StoryMode description reader; 선택독자/포기비용·3장M36/원계층 불변;
닫는 것=해당 KO/EN 자산 전진 단정 source만.

기존 en_coverage/english_hangul/story_consistency/narrative_continuity/
narrative_spine/event_lifecycle/audit/mod_layer/release_content_inventory 및
문서표적5·diff를 실행한다. 새tool/전체audit/240주/engine/빌드/앱0.
파생 inventory가 실제 달라지면 별도 판단하며 검사/원장을 넓히지 않는다.
현재 main8e79acc CI 진행≠녹색. 이전388db78 CI38851221082 success는 현재
head의 GO가 아니다. 새월은 수정main CI 녹색 후 새source 후보로 원W141부터다.
일회성/승격0. 독립source GO≠미관측실화면/전체C2/사람/청취/원어민/물리패드/
최종5언어/M60/Steam/출시GO. 자동 게이트는 도달 가능성과 계약 충족의
증거이지 재미·깊이·문체의 증거가 아니다.

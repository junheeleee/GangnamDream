# Active Queue Spec: ORDER-138

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-138 [P0·5장 일반 종막 밀도] M51의 사람선을 W224 전에 다시 잇고, 마지막 다섯 장면의 행동을 서로 다르게 만든다

**[~] 2026-08-29 Codex 착수 · 기준선 `66718fd54916acf43f0247902255ab464b3202b0` · main HOLD:**
2026-08-29 재판정에서 property는 CONDITIONAL, `general_near_goal_father_passed`는
REJECT였다. ORDER-137이 고친 W207 결과 연출, W230 민서 입장, W237 오늘의 30분,
W240 실제 삭제·같은 턴 선발신은 모두 통과했으므로 **이 오더는 그것들을 다시
쓰지 않는다.** 남은 두 결함만 소유한다. 판정 원문은
[`docs/DEMO_FIXLOG.md`](../DEMO_FIXLOG.md) 2026-08-29 항목과
[`docs/human_gates.json`](../human_gates.json)의 두 `delegated_reviews`가 소유한다.

**[~] 2026-08-30 L1/L2 후보 발급 · 제품 `9b294d5ab9333cba217f396de96bbc52b5dfee7c` · main HOLD:**
W211 이름 경계가 M51의 실제 대답을 공동명의·보증인 질문으로 되돌리고, W220은
그 선택을 비공개 음성메모 또는 별도 메모·혼자 앉는 카페 행동으로 잇는다. W224는
각주형 회수를 장면 안의 사진·약봉지·빈 의자 행동으로 바꾸고, W229 보관·폐기,
W234 몸의 문턱, W237 삼십 분의 기회비용, W240 실제 삭제·선발신이 서로 다른
동사를 소유한다. property의 선두 영수증은 장면 첫 이미지에 융합했다.

제품 tree는 `ebaf799e1bca32fe4f02d7c15501bda95d591e0e`, source manifest SHA-256은
`9927a87509bd66f804f40972fb83c84d77ab5b7ba0d8fd41b503f9cbe99a2565`다.
KO/EN × 960×600·1280×800·1920×1080 일반 156장과 property 72장, 총 228장의
PNG manifest digest는 `3a5842d30750026b5eeaea50eaa6b0b1b82d453ee419cf74e965279f18ce1aab`다.
전체 감사에서 나온 공용 SHA·감독 기대값·연출 catalog stale을 재고정한 뒤 대상
Godot/Python 게이트가 GREEN이다. 자동 작성 선택기 프로브는 네 general 조합과
property 보호 경로를 통과했지만 매 실행 `HUMAN_REPLAY_REQUIRED`를 남긴다.
두 정상 속도 사람 게이트와 사용자 최종 GO는 OPEN이고 `main`은 HOLD다.

**착수 소유권:** `content/events{,_en}/arc_year3_drama.json`,
`content/events{,_en}/arc_pre_ending.json`, `content/events{,_en}/arc_drama.json`,
`systems/Chapter5FinaleRoute.gd`, `autoloads/GameState.gd`, `scenes/MainGame.gd`,
`content/meta/chapter5_general_finale_ledger.json`, 이 사양의 연출·제품 계약 파일,
`tools/{L3ReplayM49M60,Chapter5FinaleRouteCheck,chapter5_general_finale_route_audit,chapter5_finale_route_audit,full_run_pacing_audit,narrative_continuity_audit,ScreenshotQA,audit}.*`,
그리고 선언·마감 문서다. `scenes/StoryMode.gd`는 읽기 제시 변경이 실제로 필요하다는
증거가 생길 때만 범위 확장 선언 뒤 만진다. `project.godot`은 소유하지 않는다.

**2026-08-29 구현 중 실제 저장·선택기 대조에 따른 사양 정정:** 앞서 적은
`general 28/48주`, 구현 중 보고한 `29/48주·최장 공백 4주`는 한 사람의 실제
경로가 아니었다. 축약 픽스처가 이미 닫힌 1년차 투자 사건과 다은 연애 갈래를
다시 열고, 서로 양립할 수 없는 제네릭·랜덤 주차를 합집합한 값이었다. 이 수치는
제품·L2·사람 플레이 증거로 사용하지 않는다. 하네스는 이제 **작성 전경 선택기
프로브**라고만 부르며, 전체 주간 플레이를 재현한다고 주장하지 않는다.

실제 반려는 숫자 공백보다 M51 민서 도착에서 W224 아버지 기일까지 사람·부채·
기억의 인과가 플레이 표면에서 끊긴 데 있다. 숫자를 맞추는 장면을 여러 개 넣지
않고 W211에 T2 뿌리 `arc_y5_general_name_boundary_exact` 하나를 둔다. M51의
실제 대답을 현재의 공동명의·보증인 질문으로 되돌리고, 다른 사람 이름을 담보로
쓰지 않는 행동을 확정한다. W220은 이를 선택별로 회수한다.

general 원장 v2 자체는 총 8뿌리·17선택, 한 런 6뿌리·13선택을 유지한다. 원장
밖의 W211·W220 연결 장면까지 포함한 작성 종막 표면은 총 10뿌리·21선택, 한 런
8뿌리·17선택이다. W224 진입 스냅샷은 M51·W211·W220의 정확한 선택 영수증 세
개를 읽는다. `scenes/StoryMode.gd`는 실측 결과
현재 `prepend`만으로 property W240의 네 선택 사실을 장면 첫 이미지에 융합할 수
없음이 확인돼, 토큰 누락·중복·잔류 때 fail-closed하는 `inline_slots` 최소 확장만
소유한다. 언어 전환 때 현재 언어 사건이 사라지면 5장 소유 장면을 닫고
`read_surface_invalid`로 실패시키며, 이전 언어 본문을 새 언어 표면에 남기지 않는다.
이에 따라 `tools/year5_reference_route_audit.py`,
`content/meta/exposed_event_state_contracts.json`, `docs/CONTENT_RATING_INVENTORY.md`와
해당 lifecycle/inventory 검사도 착수 범위에 포함한다.

**2026-08-30 검사 범위 확장 선언:** 핵심 선택·저장·엔딩 검사, 공용 W193 fixture,
등록·보호 해시 감사, chapter1 audited-source SHA와 `EventDirectorCheck`의 5장
direct-decision 30→31 기대값을 소유한다. 아래 정확한 검사 목록 밖 기능은 넓히지
않으며 1장 원장 의미와 편성 로직은 바꾸지 않는다.

## 판정 증거와 보호선

- 실제 사람 플레이에서 M51 `arc_minseo_03_arrival` 뒤 W224
  `arc_father_legacy`까지 일반·랜덤 사건이 여러 번 나왔지만, 민서·아버지·상환을
  잇는 작성 장면은 없었다. 장면 수가 아니라 중심 인과선이 23주 끊긴 것이
  REJECT의 핵심이다.
- 같은 실제 저장의 주간 사건열은 축약 하네스가 재현하지 못하는 랜덤·앰비언트·
  경제 상태를 포함한다. 자동 검사는 M51→W211→W220→W224→W229→W234→W237→W240
  작성 척추의 도달·순서·영수증만 증명한다.
- W224 `arc_father_legacy`의 `description_memory_if_known`은 선택별로 정확히
  발화하지만, 장면의 닫는 이미지("빈 의자를 사진 맞은편에 두고 한참 앉아
  있었다") **뒤에** 한 문단으로 덧붙고 "…와 이어졌다"로 연결을 해설한다.
  선택 3개는 기존 제네릭 그대로여서 회수를 읽되 그 회수로 행동할 수 없다.
  선택 2의 결과는 65자다.
- property 종막 뿌리는 전부 `chapter5_finale_reads` 한 줄 문단 더미로 열린다.
  W240은 본 장면 전에 넉 줄이 먼저 놓인다.
- **보호선:** W207 선택별 결과 presentation, W230 민서 입장 순서, W217 다은
  블레이저, W220 `arc_y5_room_consent_receipt` 무초상, W237 두 선택, W240 서명
  2선택과 같은 턴 outbound 3선택, general 원장 `4 roots / 9 choices`, property
  `11/30`·한 런 `9/24`, career/startup `32/86`, `instant_legend` 순서,
  `project.godot`은 바꾸지 않는다.
- **사실 경계:** 민서 무답장·미성사, 아버지 별세 단조성과 사진·약봉지·빈 의자·
  기록 봉투 한정 존재, 미소유·무이체·무경제 효과를 새 장면이 깨지 않는다.

## 깊이 3문

1. **이걸 지우면 무엇이 깨지는가?** M51에서 시작한 도착·부채의 질문이 W224까지
   실제 행동 없이 사라져, 아버지 기일이 앞선 사람선의 결과가 아니라 갑자기 끼어든
   회상으로 돌아간다.
2. **고른 플레이어와 안 고른 플레이어가 뒤에 다른가?** M51의 두 대답은 W211의
   질문을 서로 다르게 읽고, W211의 두 행동은 W220의 현재 선택과 W224 진입
   스냅샷에 각각 정확한 영수증으로 남는다.
3. **같은 자리에서 무엇과 경쟁하는가?** W211은 공동명의·보증인을 써서 가능한
   범위를 넓히는 유혹과 경쟁한다. 신규 선택은 범위를 좁히거나 상담을 멈추며,
   민서 연락·계약·예약·대출 신청·이체·소유를 만들지 않는다.

## 배치 A — 제품

1. W211에 general profile 전용 T2 작성 뿌리 하나를 둔다. M51 선택별 문장을
   장면 안에 넣고, 중개사의 공동명의·보증인 질문에 `내 이름과 내 돈만으로 범위를
   다시 본다` 또는 `다른 이름을 넣지 않고 상담을 멈춘다`를 실제로 선택시킨다.
2. W220은 W211의 두 갈래를 서로 다르게 회수한 뒤, 비공개 음성메모 또는 혼자
   카페에 앉는 **매체**만 선택한다. 가격 알림과 삼십 분의 기회비용은 W237만
   소유한다.
3. 신규 뿌리는 민서에게 답장·수락·만남을, 아버지에게 부활·응답을, 부동산에
   계약·예약·대출 신청·소유·이체를 만들지 않는다. 남길 수 있는 것은 자기 쪽
   행동과 그 시각뿐이다.
4. W238~W239의 2주 공백은 W237에서 실제로 포기한 삼십 분을 다른 작성 사건으로
   즉시 보상하지 않고 W240 삭제까지 들고 가는 정지다. 그대로 두고 실플레이에서
   공백이 아니라 압력으로 느껴지는지 다시 판정한다.
5. W224 `arc_father_legacy`의 회수를 각주에서 장면 안으로 옮긴다. 회수 문단은
   닫는 이미지 뒤가 아니라 그 앞에 놓이고, "…와 이어졌다" 같은 연결 해설 대신
   두 물건을 같은 프레임에 둔다.
6. W224에 general profile 전용 선택을 준다. 기존 제네릭 3선택은 다른 profile을
   위해 보존하고, 이 profile에서는 W220 갈래를 실제로 이어받는 선택이 열린다.
7. W224 각 갈래의 결과 분량을 이 해의 다른 종막 비트와 같은 대역으로 올린다.
   65자 결과를 남기지 않는다.
8. W229는 남긴 물성을 보관·폐기하거나 들고 감·남겨 둠만, W234는 문턱 앞의
   몸의 행동만 소유한다. W237은 가격 확인과 사람의 흔적에 쓰는 삼십 분의
   기회비용, W240은 실제 삭제와 무응답 선발신을 각각 유일하게 소유한다.
9. property 종막 뿌리의 `chapter5_finale_reads` 제시를 고친다. W240은 넉 줄을
   먼저 나열하지 않고 최소 두 줄을 장면 자기 첫 이미지에 융합한다. 읽는 사실
   자체는 하나도 줄이지 않는다.
10. KO/EN 원고·이름표·배경·앰비언스·초상 계약을 같은 커밋에서 맞춘다.

## 배치 B — 증거

1. `tools/L3ReplayM49M60.tscn`은 이름을 유지하되 결과를 사람 플레이가 아닌
   **작성 전경 선택기 프로브**로 표기한다. M51→W211→W220→W224→W229→W234→
   W237→W240의 도달 순서와 같은 턴 큐, KO/EN 선택 영수증을 실행한다. 전체 48주
   장면 수·랜덤 사건·체감 공백을 증명했다고 쓰지 않는다.
2. M51 두 갈래가 W211에서, W211 두 갈래가 W220에서 서로 다른 원고를 받는지
   네 조합을 실행한다.
3. W224 신규 선택의 exact receipt가 write-once·idempotent이고 W237·W240·엔딩
   후일담 읽기를 깨지 않음을 Python·Godot으로 실행한다.
4. 신규 뿌리가 wrong profile·아버지 생존·property/career/startup에서 fail-closed임을
   byte-exact로 거절한다.
5. 허위 읽음·답장·수락·만남·부활·동석·매수·소유·이체를 KO/EN 전수 탐지한다.
6. property 종막 뿌리의 읽는 사실 개수가 배치 A 9번 전후로 동일함을 대조한다.
7. KO/EN × 960×600·1280×800·1920×1080으로 신규 W211 뿌리와 W220·W224·W229,
   property W240을 렌더해 검은 화면·잘림·이름표·초상·언어 누출 0을 확인한다.
8. 전체 `tools/audit.sh`와 `python3 tools/en_coverage_check.py`가 GREEN이다.

## 선행 화면 픽스처 수리 (2026-08-29 완료)

달력 월·HUD와 후반 임차 주거 상태를 실제 런과 맞췄고 이번 228장 세트로
재발급했다. 결함 원문과 이전 134장 폐기 근거는 `docs/WORK_LOG.md`와
`docs/DEMO_FIXLOG.md` 2026-08-29 항목이 보존한다.

## 정확한 파일 소유권

**KO/EN 사건:** `content/events{,_en}/arc_year3_drama.json`(W224),
`content/events{,_en}/arc_pre_ending.json`, `content/events{,_en}/arc_drama.json`.
W211 신규 뿌리의 파일은 기존 등록 배치와 일치하는 곳으로 구현 시 확정하되
KO/EN을 같은 커밋에서 바꾼다.

**런타임·원장:** `systems/Chapter5FinaleRoute.gd`, `scenes/MainGame.gd`,
`content/meta/chapter5_general_finale_ledger.json`, `autoloads/GameState.gd`.
`scenes/StoryMode.gd`는 기존 read/transaction을 재사용하고, 배치 A 9번을 데이터
만으로 정직하게 구현할 수 없음이 증명됐으므로 `inline_slots` 치환과 fail-closed
검증만 최소 수정한다.

**연출·제품 계약:** `assets/event_visual_contracts.json`,
`assets/scene_audio_manifest.json`, `assets/scene_direction_manifest.json`,
`content/meta/event_lifecycle.json`, `content/meta/event_director.json`,
`content/meta/story_map.json`, `content/meta/story_rules.json`,
`content/meta/narrative_spine.json`, `content/meta/release_content_inventory.json`,
`docs/STORY_BIBLE.md`, `docs/SCENE_TIER.md`, `docs/QA_CHECKLIST.md`.

**검사:** `tools/ScreenshotQA.gd`,
`tools/chapter5_general_finale_route_audit.py`,
`tools/chapter5_finale_route_audit.py`, `tools/Chapter5FinaleRouteCheck.gd`,
`tools/CoreChoiceSliceCheck.gd`, `tools/ManualSaveCheck.gd`,
`tools/EndingRouteIdentityCheck.gd`, `tools/L3ReplayM49M60.gd`,
`tools/fixtures/chapter5_history_base_w193.json`,
`tools/full_run_pacing_audit.py`, `tools/narrative_continuity_audit.py`,
`tools/event_director_audit.py`, `tools/event_lifecycle.py`,
`tools/exposed_state_consistency_audit.py`, `tools/story_consistency_audit.py`,
`tools/story_map_audit.py`, `tools/year5_reference_route_audit.py`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`,
`tools/EventDirectorCheck.gd`,
`tools/audit.py`, `tools/audit.sh`.

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양, `docs/human_gates.json`,
`CLAUDE.md`, `docs/DEMO_FIXLOG.md`, `docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`.

`project.godot`, 밸런스 밴드, 기존 endings JSON, career/startup reference roots,
`GameState.check_game_over()`와 즉시 실패→finale hold→`instant_legend` 순서는
수정하지 않는다.

## 완료 판정

- **L1 기계:** 신규 뿌리의 profile·turn·source 게이트, receipt write-once,
  save/load, KO/EN parity, fail-closed, 보호 경로 회귀 0이 GREEN이다.
- **L2 자가:** 작성 전경 선택기 프로브와 KO/EN 세 해상도 화면으로 M51에서
  W240까지 지정 척추의 도달·정확한 회수와 장면화를 보인다. 전체 주간 밀도와
  체감 공백은 L3 사람 플레이에 남긴다.
- **L3 사람:** 새 exact 후보에서 `general_near_goal_father_passed` M49~M60을
  건너뛰기 없이 정상 속도로 다시 전체 플레이한다. property는 배치 A 9번의
  범위에 한해 W235~W240 재확인으로 족하다. **자동·화면 증거는 이 판정을
  대체하지 않으며, 두 L3와 사용자 최종 GO 전에 완성·main 병합을 선언하지 않는다.**

## 정본 승격 예정

- 계속 유효한 규칙: "선택 회수 문단은 장면의 닫는 이미지 뒤에 붙이지 않는다"와
  "연속 종막 장면은 서로 다른 플레이어 행동을 소유한다"를
  `docs/STORY_BIBLE.md` 5장과 `docs/SCENE_TIER.md`에 승격 판정한다.
- 일회성: exact 해시·후보 ID·주차 목록·배치 수·검사 순서.

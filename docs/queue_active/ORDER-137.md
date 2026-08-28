# Active Queue Spec: ORDER-137

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-137 [P0·5장 실플레이 반려 수리] W207·W230 연출 불일치를 닫고, 일반 경로의 W220→W240을 사람·포기·책임으로 다시 올린다

**[~] 인간 L3 반려를 수리 중 · `chapter5_finale_rc` waiting_rebuild · main HOLD:**
선언 기준선은 문서 래퍼 `9909437d538ef5ebd7389211e6364449b8561fe4`,
제품 후보 `b375af26f48668c68ec5bda05b25aedf064fe043`, tree
`840016b61bceab6368ef79ea145b32a02730ba00`다. 두 커밋 사이 런타임 diff는
0이지만, 실제 Godot 4.6.2·Studio Display·1280×800·KO·정상 독해 속도
M49~M60 전체 플레이에서 property는 `CONDITIONAL`,
`general_near_goal_father_passed`는 `REJECT`를 받았다. 따라서 현 후보는
승격하지 않고 재작업 상태로 내린다. 예전 `771d0e7…`는 사용하지
않는다.

## 판정 증거와 보호선

- property W207 `arc_y5_final_offer` 선택 2 결과는 산문은 카페·다은으로
  이동하지만 화면은 회의실·상철·`\uc784\uc0c1\ucca0`을 유지한다.
- property W230 `arc_y5_people_verdict_daeun_exact`는 민서의 입장·전화·
  원격 인계 없이 민서의 현장 필기를 만든다.
- general W203→W224의 20주 간격은 W215·W220의 계산 일반론으로
  민서·아버지·상환확인서의 선을 되살리지 못했다.
- general W237은 색인·첨부·목록·봉인·순서가 주동사고, W240은
  그 사실을 다시 설명해 새 결단과 실제 포기가 없다.
- W217 다은 블레이저와 W220 `arc_y5_room_consent_receipt` 무초상은
  실플레이 통과점이므로 byte·화면 보호한다.
- property의 사람 압박·선택 수렴·W240 상승과 두 경로의 검은 화면 0,
  잘림 0, 허위 이체·소유·답장 0을 후보 기준선으로 보호한다.
- 일반 W240에는 민준만 있다. 민서는 실제 연락 채널에만, 아버지는
  사진·약봉지·빈 의자·기록 봉투에만 존재한다. 읽음·답장·용서·
  약속 성립·만남·부활을 만들지 않는다.

## 깊이 3문

1. **이걸 지우면 무엇이 깨지는가?** W207은 화자와 화면이 분리되고,
   W230은 존재하지 않던 민서를 현장에서 행동시킨다. 일반 경로는
   민서와 아버지가 끝에서 파일 항목으로만 돌아와 종막의 밀도가 무너진다.
2. **고른 플레이어와 안 고른 플레이어가 뒤에 다른가?** W220에서 녹음한
   흔적과 카페에 혼자 앉은 30분은 W224가 서로 다르게 회수한다.
   W237의 이번 밤 포기와 W240에서 지운 주소/목표는 exact receipt와
   엔딩 후일담에 다르게 남는다.
3. **같은 자리에서 무엇과 경쟁하는가?** W220은 기존
   `arc_endgame_sixmonths`, W237은 가격 알림과 사람에게 쓸 오늘 30분,
   W240은 남은 세 주소와 30억 목표의 우선권과 경쟁한다. 신규 정지를
   더하지 않고 실패한 정지의 기능을 교체한다.

## 배치 A — 제품 18단위

1. W207 선택 2에 `result_background=cafe`, `result_ambience=cafe`,
   `result_portrait=daeun_normal`을 주고, StoryMode의 live·재개·언어 전환이 같은
   결과 초상·이름표를 읽게 한다.
2. W207 선택 0·1의 meeting·상철 결과와 선택 전 기본 presentation은
   바꾸지 않는다.
3. 선택 결과 초상 필드를 유효한 초상 ID만 받는 공통 계약으로 검증한다.
4. W230을 cafe·무초상 대면으로 바꾸고, 두 custody 분기에서 민서가
   문을 열고 빈 의자를 당겨 앉은 뒤에만 현장 행동을 한다.
5. W230의 다은·민서·민준 in-person 참가자, 3선택, 문서 상태,
   finale receipt, W235 경제 0을 보존한다.
6. KO·EN W207/W230 원고·이름표·배경·앤비언스·초상 계약을 같이 맞춘다.
7. W220의 기존 계산 정지를 신규 exact
   `arc_y5_general_debt_memory_reconnect` 2선택으로 교체한다.
8. W220 선택 0은 1장 마지막 상환확인서와 M51에서 실제로 한 대답을
   자기 음성메모에 남기고, 선택 1은 그 사본을 들고 카페에 혼자
   30분 앉는다. 둘 다 민서에게 보내지 않고 민서를 등장시키지 않는다.
9. W220은 가격 확인에 쓸 오늘 30분을 실제로 놓친 비용을 보이고,
   `arc_endgame_sixmonths_seen`을 남겨 같은 런의 중복 정지를 막는다.
10. W224 `arc_father_legacy`는 W220의 녹음 시각 또는 혼자 앉은 30분을
    선택별로 회수하고, 아버지는 사진·약봉지·빈 의자로만 남긴다.
11. 기존 W229 색인 root는 제거하고 새 W220이 finale source를 소유한다.
12. W237을 오늘 가격 알림을 끌지, 사람의 흔적을 덩고 끝까지 볼지의
    2선택으로 다시 쓴다. 색인·첨부·목록·봉인·순서 정리를 제거한다.
13. W240 signature를 세 주소·가격 알림을 모두 지우기와 수첩 첫 장의
    30억 목표를 두 줄로 지우기의 2선택으로 다시 쓴다.
14. 두 W240 선택은 지운 시각·자기 이름·exact receipt를 남기지만
    매수·주문·취소·소유·이체·경제·스탯·AP 효과를 만들지 않는다.
15. 같은 턴 outbound 3선택은 신규 포기 receipt를 읽되, 화요일 19:30·
    그 카페·30분·자기 쪽 전송 시각만 남는 선택을 보존한다.
16. general finale 원장을 `record_disposition → sacrifice → outbound`,
    `2/2/3 = 7 choices`로 바꾸고 W220 소스를 포함한 총 4 roots/9 choices로
    고정한다. `10`에 맞추기 위한 선택은 더하지 않는다.
17. EndingSystem은 general signature exact receipt 2종을 첫 후일담으로,
    outbound exact receipt 3종을 둘째 후일담으로 읽고 property coda는 보존한다.
18. 스토리 맵·룰·스파인·디렉터·라이프사이클·시각·오디오·저장
    계약을 실제 제품 모양과 KO/EN 동일성에 맞춘다.

## 배치 B — 증거 18단위

1. W207 선택 2 live·결과 저장 재개·KO↔EN 전환의 cafe·다은·이름표·
   cafe ambience를 실행한다.
2. W207 선택 0·1은 meeting·상철을 유지하고 잘못된 선택 인덱스·
   초상 ID·필드 삭제를 mutation으로 거절한다.
3. W230 두 custody 분기 모두에서 민서 입장이 최초 민서 행동보다
   먼저 보이고, cafe·무초상·in-person이 일치함을 검증한다.
4. W217 다은 블레이저와 W220 회의 무초상을 KO/EN 화면과 exact
   계약으로 재검증한다.
5. W220 진입은 exact turn 220, 민서 M51 1/2, 아버지 별세, general
   profile, property entry 미성립을 모두 만족할 때만 성립한다.
6. wrong turn/profile, father alive, source missing·multiple·non-bool, old W229 receipt,
   property/career/startup은 W220 exact root를 보지 못한다.
7. W220 exact root→W224 선택별 callback→M59→W237 entry를 두 W220 선택
   모두에서 실행한다.
8. W220 exact root와 generic sixmonths가 같은 런에서 중복 발화하지 않는다.
9. general 원장 3 roots/7 choices의 read·order·write-once·idempotent·tamper·
   pending→ready→consumed를 Python·Godot으로 실행한다.
10. W237 entry·partial, W240 signature·outbound ready·consumed를 disk save/restart에서
    정확히 복원한다.
11. general signature coda 2종과 outbound coda 3종이 consumed exact receipt에서만
    나오고, property 3종을 바꾸지 않는다.
12. 허위 읽음·답장·수락·만남·부활·동석·매수·소유·이체·계약·
    열쇠·접수번호 증폭을 KO/EN 전수 탐지한다.
13. property finale 11/30·active 9/24, causal 19/47, career/startup reference
    32/86, instant legend 순서를 보존한다.
14. Year5 과거 계층 해시를 덮어쓰지 않고 `9909437`을 기준으로 하는
    additive 수리 계층과 역투영 self-test를 만든다.
15. `project.godot`, W217/W220 통과 root, 자산·부채·스탯·AP, 기존 엔딩
    라우팅의 보호 해시를 남긴다.
16. KO/EN×960×600·1280×800·1920×1080 W207·W217·W220(property)·W230·
    W220(general)·W224·W237·W240 signature·outbound·ending을 렌더한다.
17. 검은 화면·잘림·이름표·초상·배경·앤비언스·초점·언어 누출·
    중복 정지·same-turn ending handoff를 전수 확인한다.
18. 새 exact 제품 commit·tree·manifest와 문서 검토 HEAD를 발급하되
    `chapter5_finale_rc`는 L3 전에 GO로 올리지 않고, 두 경로 M49~M60
    정상 속도 실플레이를 새 후보에서 다시 요청한다.

## 정확한 파일 소유권

**런타임·원장:** `scenes/StoryMode.gd`, `scenes/MainGame.gd`,
`autoloads/GameState.gd`, `systems/Chapter5FinaleRoute.gd`,
`systems/EndingSystem.gd`, `content/meta/chapter5_general_finale_ledger.json`.

**KO/EN 사건:** `content/events{,_en}/arc_pre_ending.json`,
`content/events{,_en}/arc_drama.json`, `content/events{,_en}/arc_year3_drama.json`.
W220 신규 root는 기존 등록 배치와 일치하는 파일을 구현 시 확정하되,
KO/EN을 같은 커밋에서 바꾸는다.

**연출·제품 계약:** `assets/event_visual_contracts.json`,
`assets/scene_audio_manifest.json`, `assets/scene_direction_manifest.json`,
`content/meta/event_lifecycle.json`, `content/meta/event_director.json`,
`content/meta/story_map.json`, `content/meta/story_rules.json`,
`content/meta/narrative_spine.json`, `content/meta/exposed_event_state_contracts.json`,
`content/meta/release_content_inventory.json`, `docs/STORY_BIBLE.md`,
`docs/SCENE_TIER.md`, `docs/CHOICE_CONSEQUENCE_SYSTEM.md`,
`docs/ENDING_CONTRACT.md`, `docs/QA_CHECKLIST.md`.

**검사:** `tools/audit.py`, `tools/event_visual_contract_check.py`,
`tools/chapter5_causal_route_audit.py`, `tools/chapter5_finale_route_audit.py`,
`tools/chapter5_general_finale_route_audit.py`, `tools/year5_reference_route_audit.py`,
`tools/Chapter5FinaleRouteCheck.gd`, `tools/CoreChoiceSliceCheck.gd`,
`tools/ManualSaveCheck.gd`, `tools/EndingRouteIdentityCheck.gd`,
`tools/ScreenshotQA.gd`, lifecycle/director/map/spine/continuity/pacing/i18n/full audit 상위 검사,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`의 shared runtime 보호 해시.

**선언·마감:** `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-135.md`,
이 사양, `docs/human_gates.json`, `CLAUDE.md`, `docs/DEMO_FIXLOG.md`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`. 마감 시 큐·사양을 아카이브한다.

`project.godot`, 배런스 밴드, W217 `arc_y5_three_in_room`, W220 property
`arc_y5_room_consent_receipt`, 부동산 finale 원장/선택, career/startup reference,
`GameState.check_game_over()`와 `instant_legend` 순서는 수정하지 않는다.

## 완료 판정

- **L1 기계:** 표적 root·원장·저장·라우팅·KO/EN·A/V·화면·금지 사실과
  보호 경로가 전용·전체 검사에서 GREEN이다.
- **L2 자가:** 실제 화면에서 W207 다은/카페, W230 민서 입장,
  W220→W224 회수, W237 오늘의 비용, W240 실제 포기·same-turn outbound·
  엔딩 2카드를 KO/EN·세 해상도에서 확인한다.
- **L3 사람:** 새 exact 후보에서 property와
  `general_near_goal_father_passed` M49~M60을 각각 건너뛰기 없이 정상
  속도로 전체 재플레이한다. 이 재플레이와 사용자 최종 GO 전에
  완성·main 병합을 선언하지 않는다.

## 정본 승격 예정

- 계속 유효한 규칙은 `docs/STORY_BIBLE.md` 5장의 W220→W240 일반 경로·
  인물 존재·무응답·미소유 계약과 결과 presentation 스키마 소유자에 승격한다.
- exact 해시·증거 경로·후보 ID·배치 수·검사 순서는 이 오더에만 남는 일회성이다.

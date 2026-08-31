# Active Queue Spec: ORDER-143

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-143 [P0·story graph] 월경계 사건 소유권과 Ch2 보스의 상태 guard를 typed contract로 고친다

**[~] 2026-08-31 Codex 착수 · 기준선 `06277c30e61ed54c99069e16fd591ec0ef26c388`:**
ORDER-142 정적 감사가 찾은 cross-month overlap 8개를 원고·story map·실제
`StoryMode` 큐 동작으로 재판정했다. 공개 `story_demo_rc` M01~M06 사용자 GO와
제품 신원은 보호한다. 이 오더는 M08 이후 제품 그래프만 소유하며 AP/월간 행동판을
되살리지 않는다.

**2026-08-31 원고 소유권 확장 선언:** M34를 M33 선택의 재실행이 아닌 실제
`cost_of_knowing` 후폭풍으로 고치려면 그 제품 원고 owner인
`content/events{,_en}/arc_year3_drama.json`이 필요함을 대조 중 확인했다. 이 두
파일을 아래 소유권에 추가한다. 다른 Year 3 root는 바꾸지 않는다.

**2026-08-31 검사 문법 확장 선언:** M14 network의 typed prerequisite가 정적
원장에서 `player.total_asset_value`를 읽으므로 이 경로를 허용·검증하는
`tools/story_consistency_audit.py`를 검사 소유권에 추가한다. 다른 prerequisite
문법은 넓히지 않는다.

**2026-08-31 생명주기 self-test 확장 선언:** M10 생활 beat, M14 bank fallback,
M22 unattached fallback 세 root를 author-only에서 실제 제품 ingress로 승격하면
`event_lifecycle.json`의 정확한 집합뿐 아니라 그 현재 집합 크기를 반례로 잠그는
`tools/event_lifecycle.py` self-test도 함께 바뀐다. 이 검사 파일을 소유권에
추가하되 면제 규칙이나 다른 event의 생명주기는 넓히지 않는다.

**2026-08-31 시각 계약 확장 선언:** 위에서 활성화한 M10·M14 배경과 M33
same-location chain은 이벤트 JSON만 바꾸면 `story_consistency_audit`의 실제 시각
대조가 실패한다. 따라서 그 exact background/portrait 쌍을 소유하는
`assets/event_visual_contracts.json`을 추가한다. 새 그림을 만들거나 M01~M06
계약을 바꾸지 않는다.

## 깊이 3문

1. **다른 달 root로 이어진다고 항상 끊어야 하는가?** 아니다. 퇴실→새 방,
   정산→다음 날처럼 한 장면의 authored closure는 앞 beat가 소유한다. 다음 달
   지도에서 같은 root를 다시 여는 중복만 제거하고 실제 후속 beat를 둔다.
2. **원고의 `follow_up_event`가 왜 위험한가?** `StoryMode`가 MainGame의 주차·직업·
   자산·선행 사건 guard를 거치지 않고 즉시 큐에 넣기 때문이다. 독립 월과 조건부
   사건은 raw edge가 아니라 typed scheduler contract가 소유해야 한다.
3. **연결을 끊으면 사람선도 끊기는가?** 기능은 삭제하지 않는다. 같은 장면 chain은
   closure로, 독립 장면은 정상 주차로, 조건부 장면은 사실을 만족한 미래 주차로
   옮긴다. 직업 없음·아버지 미입원/별세 같은 경로에는 사실에 맞는 fallback이
   열려야 한다.

## 23단위 구현

1. 신규 `story_graph_contract.json`에 8 edge의 class, source/target owner month,
   정상 주차, 선행·금지 flag, recovery 정책을 선언한다.
2. 신규 graph contract 감사기와 synthetic self-test를 만든다.
3. M01~M06 제품 root·closure와 `story_demo_rc` 보호 hash가 불변임을 먼저 잠근다.
4. M08 `goshiwon_goodbye→housing_new_life`를 M08 same-scene closure로 귀속한다.
5. M10에는 첫날 재방송이 아닌 이사 뒤 실제 생활 beat를 둔다.
6. M13 `year_one_mark→money_attracts_money`를 M13 same-scene closure로 귀속한다.
7. `money_attracts_money→sangchul_03_network` raw edge를 제거한다.
8. M14 network는 상철 선행·100만원 조건을 만족할 때만 열고 route-safe fallback을 둔다.
9. M20 `doors_open→parents_visit` raw edge를 제거한다.
10. `doors_open` 정상 창을 W77~80으로 맞춘다.
11. 부모 방문은 W89~92, father02+medication+alive에서만 열린다.
12. 부모 방문→나흘째 병원 전화는 M23 one-shot `time_cut`으로 보존한다.
13. W82 병원 선발화를 없애고 손상 저장 recovery에만 제한한다.
14. M22 `daeun_fork→father_medication` 시간 역전 edge를 제거한다.
15. 다은 갈림길 정상 창을 W85~88로 맞춘다.
16. M15 약 장면의 지연 raw `jiyeon_offer` edge를 제거한다.
17. 지연은 M22 다은 불성립+store seen+offer unseen일 때만 scheduler가 연다.
18. M33 confrontation/buried/stairwell/reckoning 전체를 한 table-chain으로 선언한다.
19. M33 위치를 `cafe`, 내부 transition을 authored same-location으로 통일한다.
20. M34는 M33 선택을 재실행하지 않는 실제 지연 후폭풍/cost-of-knowing beat를 쓴다.
21. M49 reckoning→final-year-start는 M49 closure로 귀속하고 M50 중복을 없앤다.
22. Ch2 `sangchul_mirror→career_ceiling→father_04_visit` raw chain을 끊고 직업·입원·
    생존별 typed ingress/fallback 및 M23 실제 decision owner를 고친다.
23. 생성 연출 원장·KO/EN topology·기존 검사 기대값을 갱신하고, 8 overlap 해소 뒤
    full-volume baseline을 의도적으로 재발급한다.

## 필수 반례와 보호선

- W52 상철02 없음·자산 0에서 network가 열리면 실패한다.
- W74에는 doors/parents 모두, W77에는 parents가 열리면 실패한다.
- W82에 병원이 선발화하면 실패하고, W89 정상 부모 방문 뒤 병원은 정확히 한 번이다.
- father passed에서 부모 방문·병원·병실 방문이 열리면 실패한다.
- 이미 약 장면을 본 W85 다은 경로에서 돈·호감·효과가 재적용되면 실패한다.
- W58 약 선택 직후 지연이 열리면 실패하고, M22 조건부 창에서만 열린다.
- 무직이면 career ceiling의 사무실, 미입원/별세면 father visit이 열리면 실패한다.
- M33 다섯 종결의 기존 효과·flag와 W193 `chapter card→reckoning→final year start`
  순서를 보존한다.
- M01~M06 출시 데모, M55 다은 복장, 5장 무답장·무이체·미소유·아버지 단조 사실,
  instant legend 이스터에그, `project.godot`은 바꾸지 않는다.

## 정확한 파일 소유권

신규 `content/meta/story_graph_contract.json`, 신규
`tools/story_graph_contract_audit.py`; `content/meta/story_map.json`,
`content/meta/story_rules.json`, `content/meta/event_lifecycle.json`,
`content/events{,_en}/{arc_midgame,arc_chapter_themes,arc_daeun,arc_drama,arc_events,arc_year3_drama}.json`,
`scenes/MainGame.gd`, `assets/{event_visual_contracts,scene_direction_manifest}.json`,
`tools/{peak_scene_chain_audit,arc_flow_sim,scene_direction_catalog}.py`,
`tools/{story_consistency_audit,event_lifecycle}.py`,
`tools/{HiddenFeatureCheck,CoreChoiceSliceCheck}.gd`,
`tools/full_game_volume_baseline.json`, `tools/audit_scope.json`과 선언·마감 문서만
소유한다. 범위 밖 제품 파일은 증거 없이 넓히지 않는다.

## L1 / L2 / L3

- **L1:** graph contract normal/self-test, KO/EN topology, full-volume baseline이 새
  overlap·guard 우회·재생을 거부한다.
- **L2:** 위 반례를 실제 selector/StoryMode transaction으로 재생하고 M01~M06
  보호 hash와 기존 5장 안전선을 확인한다. Godot 부재 시 통과 처리하지 않는다.
- **L3:** ORDER-144 fresh-title trace에서 정상 profile이 W240까지 같은 exact 제품을
  지나간 뒤 정상 속도 사람 플레이를 요청한다. 자동 GREEN은 제품 GO가 아니다.

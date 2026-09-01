# Active Queue Spec: ORDER-149

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-149 [P0·human REJECT repair] 5장 실제 플레이에서 깨진 주거·시간·원격 사실·화자·legacy ingress·크레딧을 봉인한다

**[~] 2026-09-02 Codex 착수 · 반려 제품
`83d3f350de0900ce050277d6da1331940d1872a3` · 검토 wrapper
`84b6498d7f1b69e8bcef5bc51880b3ed9b726435`:** 실제 Studio Display·Godot
4.6.2·1280×800·KO 정상 속도에서 property와
`general_near_goal_father_passed`가 모두 M49→M60→후일담→크레딧 6/6까지
완주했지만 둘 다 REJECT였다. 지속 검은 화면·잘림·crash는 없었고 기존 M49
수동 저장 두 개의 hash도 불변이다. 이 오더는 실제 재현된 결함만 수리하며 새
제품 commit/tree/manifest를 봉인하기 전까지 `chapter5_finale_rc`는
`waiting_rebuild`, 두 사람 게이트는 `open`, full·main·product는 HOLD다.

공개 출시 데모는 사용자가 GO한 exact `story_demo_rc` M01~M06 BUILD
`2026.08.31.1`이다. 이 오더는 공개 데모 범위·제품 바이트를 바꾸지 않는다.

## 깊이 3문

1. **결함 장면만 문장으로 덮으면 되는가?** 아니다. 결혼 뒤 경제 housing scalar와
   신혼집 presentation, 원격 인물과 physical cast, 후기 장과 수명 제한 없는 legacy
   pool이 서로 다른 정본을 읽는다. 저장·eligibility·표현이 같은 사실을 읽게 한다.
2. **W240을 더 세게 다시 쓰면 일반 경로 정점이 살아나는가?** 아니다. W237의
   실제 30분 비용과 W240 삭제→같은 턴 선발신은 사람 플레이에서 통과했다. 앞선
   SNS 삭제·허위 답장·과거 장면 재진입을 제거해 이미 작동하는 정점을 보호한다.
3. **크레딧 1/6이 input skip인가?** 아니다. page 0의 세 finale beat는 모두
   보였지만 내부 `장면 n/3` 표기가 전체 `1/6`을 덮었다. 입력 흐름은 유지하고 두
   진행도를 함께 보여 준다.

## 20단위 구현·검증

1. 결혼식 완료 뒤 다은과 사는 작은 서울 신혼집을 경제 소유권과 분리된 presentation home으로 저장·복구한다.
2. `current_housing` 배경과 주간 주거 문장은 같은 effective home을 읽고 결혼 뒤 고시원으로 회귀하지 않는다.
3. 신규 자산·현금·부채·월세·등기·소유권을 발명하지 않고 기존 경제 housing 값과 계산은 보존한다.
4. `final_last_winter`의 eligibility와 12월·마지막 달 산문을 실제 달력에 맞춰 December→September 역전을 막는다.
5. W193→W240과 cold reload에서 HUD·월명·남은 기간의 단조 진행을 표적 검사한다.
6. W193 이후 저장에서는 33세·50만원 신규게임 tutorial을 재노출하지 않고 W1 onboarding은 유지한다.
7. 20억·25억 milestone의 고정 현재형을 실제 자산·도달 시점에 안전한 동적/회고 문장으로 바꾼다.
8. `anxiety_pension_crisis`의 2055년 나이를 현재 나이와 모순 없이 고치고 후기 진입 계약을 잠근다.
9. property의 의사·재혁 메시지·재혁 통화가 민준 명패로 보이지 않도록 channel/participants/nameplate를 명시한다.
10. general의 상사·카지노 지배인·중개사 등 직접 인용이 민준 발화로 오인되지 않도록 같은 표현 계약을 적용한다.
11. `arc_minseo_03_arrival`을 원격 채널로 바꾸고 M51·W220·W240의 민서 회수를 모두 무동석·무초상으로 정렬한다.
12. `callback_hoesik_left_early_office`의 읽음·답장을 제거하고 민준의 단방향 발신까지만 남긴다.
13. `cb_grace_echo`의 상대 시간 선택·달력 확정을 제거하고 민준이 제안 가능한 시각까지만 남긴다.
14. `shadow_old_promise`의 자동 SNS 답장을 제거하고 `sns_detoxed` 뒤 DM 재진입을 막는다.
15. `hyunsu_study_together`가 현수의 실패·전환 뒤 5장 고시원 첫 장면으로 재진입하지 않게 lifecycle을 닫는다.
16. `casino_chip_exchange`와 `amb_credit_steal_00`의 초기 장면이 5장에서 처음 열리지 않게 수명·해결 조건을 닫는다.
17. 실제 leverage가 없는 `debt_invest_margin_call`을 5장 pool에서 제외하고 합법 초기 상태 도달은 보존한다.
18. `sns_detoxed` 뒤 `godsaeng_start`·SNS 피드·DM이 재등장하지 않게 하여 W240 실제 삭제의 고유성을 보존한다.
19. 반복 압박 제목과 `이번 주는 그 선택의 모양으로 닫혔다`를 현재 물리 결과에 맞는 KO/EN 표면으로 교정한다.
20. 결말 page 0의 세 beat에 `1/6 · 장면 n/3`을 함께 표시하고 2/6→6/6·뒤로 가기 순서를 잠근다.

## 반드시 보존할 통과점

- property의 W207 다은/카페 동기화, M53 보증, M55 네 사람·다은 블레이저,
  M57 물성·제한 접수·민준 단독 서명, W230 민서 입장 연출, M59 무이체·무소유,
  M60 책임→서명→같은 턴 다은 선발신·무답장을 object-level로 보존한다.
- general의 W211 단독 통화, W220 원격·새 메시지 없음, W224 아버지 사진/기록만,
  W229/W234 무구매·무이전, W237 실제 30분 비용, W240 실제 삭제·서명·같은 밤
  민서 선발신·무읽음·무답장·무만남을 보존한다.
- 두 경로 후일담과 크레딧 6/6, 검은 화면·잘림·crash 0을 보존한다.
- 공개 M01~M06, 30억 `instant_legend`, AP 행동판 0, 경제식·엔딩 threshold,
  원본 slot 01·02 hash, `project.godot`은 변경하지 않는다.

## 정확한 파일 소유권

런타임은 `autoloads/{GameState,ImageRegistry,EventManager,BGMPlayer}.gd`,
`scenes/{MainGame,StoryMode}.gd`의 위 함수·표면만 소유한다. 콘텐츠는 KO/EN 쌍의
`arc_new_characters.json`, `arc_pre_ending.json`, `arc_drama.json`,
`arc_midgame.json`, `arc_year3_drama.json`, `life_events.json`, `anxiety_events.json`,
`callback_events_2.json`, `callback_chapter_themes.json`, `shadow_events.json`,
`social_independence.json`, `arc_hyunsu.json`, `gambling_narrative.json`,
`amb_scenarios6.json`, `viral_events.json`에서 위 exact root만 소유한다.
presentation 사실은 `content/meta/story_rules.json`, 필요한 기존 연출·배경 계약만
함께 갱신한다.

검증은 신규 `tools/chapter5_human_reject_audit.py`,
`tools/Chapter5HumanRejectCheck.{gd,tscn}`와 필요한 기존 표적 검사만 소유한다.
프로토콜은 이 사양, `docs/CODEX_QUEUE.md`, `docs/human_gates.json`,
`docs/{DEMO_FIXLOG,WORK_LOG,STATUS}.md`, `CLAUDE.md`를 소유한다.

**[scope expansion 선언 · 제품 커밋 전]:** 실제 수정이 원격 민서의 map/state
노출 계약과 기존 visual/audio 래칫까지 함께 읽으므로
`content/meta/{story_map,exposed_event_state_contracts}.json`,
`assets/{event_visual_contracts,scene_direction_manifest}.json`,
`tools/{BGMContinuityCheck.gd,year5_reference_route_audit.py,audit.py,audit.sh,audit_scope.json}`를
검증 동반 범위로 명시한다. `audit.py`는 현재 런이 더는 생산하지 않지만 기존 저장이
소유할 수 있는 `startup_collab_joined`를 exact 단일 legacy reader에만 허용하며,
임의 producerless flag나 새 reader를 허용하지 않는다. 이는 save adapter·제품 상태
변경이 아니라 검사기의 좁은 호환 예외다.

같은 JSON에 통과점이 있으면 exact root/field만 수정한다. 공개 M01~M06 사건·자산,
`content/meta/demo_core_loop_v2.json`, `project.godot`, full 경제·밸런스, 엔딩
라우팅, save handoff adapter는 비소유다.

## L1 / L2 / L3

- **L1:** KO/EN·story consistency·event lifecycle·context·human ledger와 신규
  mutation 검사가 주거·시간·원격·외부 반응·legacy ingress·credits 및 통과점
  object hash를 검증한다.
- **L2:** 보고서와 같은 두 profile을 실제 MainGame/StoryMode에서 M49→M60→
  후일담→credits까지 실행하고 W193/M51/M57/W237/W240 cold reload, 1280×800
  KO/EN 화면, 1/6→6/6, strict teardown을 확인한다. 자동·정적 GREEN은 GO가 아니다.
- **L3:** 새 exact product commit/tree/manifest와 review HEAD를 발급한 뒤 같은
  후보에서 두 경로 M49~M60 정상 속도 실제 플레이를 다시 받는다. 하나라도 실패하면
  candidate는 `waiting_rebuild`, gate는 `open`, 제품은 HOLD다. 최종 사용자의
  `user_final: GO` 전에는 gate를 `done`으로 바꾸지 않는다.

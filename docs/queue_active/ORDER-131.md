# Active Queue Spec: ORDER-131

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-131 [P0·4장 제품 연결] M39~M48의 오프스크린 선택을 StoryMode 행동으로 바꾸고 아버지 마지막 연락을 단일 시간선으로 잇는다

**사용자 승인·착수 선언 (2026-08-26):** 사용자는 게임을 최종까지 완성하고,
처음부터 끝까지 스토리와 게임성이 빽빽하며 후반으로 갈수록 치밀하고 격동적인지
직접 판단해 진행하라고 했다. ORDER-130에서 사용자의 “10까지도 갈 수 있다”는
예시를 exact 문단 수로 강제한 오류를 철회했으므로, 이 오더는 숫자 길이가 아니라
플레이어가 실제로 고른 행동·놓친 사람·후속 비용·시간선 사실로 4장을 연결한다.

**착수 기준선:** `2a96675119c5dab10b1728470b18b4537cb1033d` / tree
`e5591f6ca9ab1e45a3c5492aaf72aa5397661f68`의 exact clean 전체 감사
`✅ 감사 통과`. ORDER-131 선언 전 원격 branch에도 같은 기준선을 push했다.

**정확한 파일 범위:** `scenes/MainGame.gd`, `autoloads/EventManager.gd`,
`content/events/arc_chapter_themes.json`,
`content/events_en/arc_chapter_themes.json`,
`content/events/arc_drama.json`, `content/events_en/arc_drama.json`,
`content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`,
`content/events/arc_addiction_recovery.json`,
`content/events_en/arc_addiction_recovery.json`,
`content/events/life_events.json`, `content/events_en/life_events.json`,
`content/events/arc_year_close.json`, `content/events_en/arc_year_close.json`,
`content/events/callback_chapter_themes.json`,
`content/events_en/callback_chapter_themes.json`,
`content/meta/story_map.json`, `content/meta/story_rules.json`,
`content/meta/event_director.json`, `content/meta/event_lifecycle.json`,
`content/meta/exposed_event_state_contracts.json`,
`content/meta/release_content_inventory.json`,
`content/meta/year5_reference_routes.json`,
`assets/event_visual_contracts.json`, `assets/scene_audio_manifest.json`,
`tools/chapter4_causal_route_audit.py`, `tools/event_director_audit.py`,
`tools/event_lifecycle.py`, `tools/exposed_state_consistency_audit.py`,
`tools/arc_flow_sim.py`, `tools/narrative_spine_audit.py`,
`tools/peak_scene_chain_audit.py`, `tools/year5_reference_route_audit.py`,
`tools/full_run_pacing_audit.py`, `tools/EventDirectorCheck.gd`,
`tools/CoreChoiceSliceCheck.gd`, `tools/ScreenshotQA.gd`,
`tools/audit_scope.json`, `tools/audit.sh`,
`docs/CONTENT_RATING_INVENTORY.md`, `docs/STORY_BIBLE.md`,
`docs/DECISIONS.md`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`,
`docs/CODEX_QUEUE.md`, 이 사양과 완료 시
`docs/queue_archive/ORDER-131.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, `CLAUDE.md`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`. 선언 범위 중 실물 변경이 불필요한
감사·자산 원장은 byte 불변 재검증 대상으로 남길 수 있다. `StoryMode.gd`,
`GameState.gd`, `EndingSystem.gd`, `project.godot`, AP/UI·저장 schema는 범위 밖이다.

**선언 보강 (2026-08-26):** 새 Chapter 4 보호 주차가 기존 exact 리듬
기준을 바꾸므로, 그 수치를 소유하는 기존 감사 4파일을 위 범위에
추가한다. 실물 선택 엔진·저장 schema는 계속 byte 불변이며,
same-turn 재진입·중복 효과는 전용 인과 감사와 `CoreChoiceSliceCheck`의
저장 왕복으로 검증한다.

**연출 원장 보강 (2026-08-26):** author-only에서 shipping으로 승격한 장면은
기존 배경 필드만으로는 전체 경로 검사의 이동·원격·시간 전환 소유자가 되지 않는다.
새 제품 장면의 시각 전환을 분류하기 위해 `assets/scene_direction_manifest.json`을
정확한 파일 범위에 추가한다. 검사 도구의 기준은 바꾸지 않고 원장 누락만 채운다.

**정본 시간축 보강 (2026-08-26):** M39~M48 exact 주차와 W193 인계가 확정되면서
기존 `content/meta/narrative_spine.json`의 6주·12주·5주 deferred 설명은 실제
8주·11주 receipt 연결과 W193 1주 인계에 어긋난다. 이 정본 원장을 범위에 추가해
런타임 예약을 다시 만들지 않고, StoryMode의 exact 행동·기억 독자 시간축을 적는다.

**1장 증거 지문 보강 (2026-08-26):** `MainGame.gd`, 등급 원장, story rules,
`arc_midgame.json`은 1장 인과 감사가 파일 전체 SHA-256으로도 잠그는 공용 소스다.
이번 오더의 4장 변경 때문에 그 네 바이트 지문만 달라졌으므로
`tools/chapter1_core_loop_v2_causal_ledger_check.py`를 정확한 파일 범위에 추가한다.
구현 커밋 뒤 현재 파일 SHA-256 네 개만 갱신하며, 1장 frozen audited maps·행동 ID·
증거 pointer·debt baseline·48주 계약은 byte 불변으로 재검증한다.

**정본 문서 보강 (2026-08-26):** 독립 완료 감사에서 현재 런타임의 W193
1주 인계·안정화/사망 이중 의료 경과와 기존 정본 문서의 W197 5주 인계·사망 단일
설명이 충돌함을 확인했다. 최신 제품 시간축을 거짓 없이 기록하기 위해
`docs/STORY_BIBLE.md`, `docs/DECISIONS.md`를 정확한 파일 범위에 추가한다. 과거 결정
기록은 지우지 않고 W193 결정이 이전 W197 설명을 대체했음을 새 결정으로 명시한다.

**M40 후속 독자 보강 (2026-08-26):** M40을 막연한 수습 방식이 아니라 실제로
다시 연 대상별 영수증으로 교정하자 기존 `accepted_grace` 생산자가 사라졌고,
5장의 `cb_grace_echo`가 거짓 원인과 함께 고립됐다. 대상이 사람·진료 창구인
선택에서만 그 호환 플래그를 쓰고, 후속도 “누군가가 민준을 구했다”가 아니라
“민준이 닫힌 창구에 다시 실제 시각을 보냈다”는 사실을 읽게 하기 위해 한·영
`callback_chapter_themes.json`을 정확한 파일 범위에 추가한다.

**분산 정점 문서 보강 (2026-08-26):** `arc_36_trust_crack`의 즉시 후속을 제거하고
M39 영수증을 읽는 W157의 세 표적 장면으로 분리했으므로, 옛 2링크 체인을 현재
구조라고 적은 `docs/PEAK_SCENE_CHAIN_AUDIT.md`를 정확한 파일 범위에 추가한다.
과거 수치를 새 숫자 목표로 바꾸지 않고, 같은 주 즉시 연결이 아니라 여러 주에
걸친 선택→비용 구조임을 기록한다.

**사망 뒤 생활 장면 보강 (2026-08-26):** 별세 뒤 늦게 5천만·1억·25억을
달성한 정상 런과 terminal receipt만 남은 옛 저장에서, 기존 자산 이정표·중독
바닥·부모 통장·초기 아버지 아크가 살아 있는 통화와 식탁을 다시 만들 수 있음을
독립 전수 감사가 확인했다. 사망 경로용 이정표 원고와 random event의
`requires_living_father` 편성 계약을 추가하기 위해 한·영
`arc_addiction_recovery.json`, `life_events.json`, 공용
`autoloads/EventManager.gd`를 정확한 파일 범위에 추가한다. 과거 회상은 유지하되
현재 통화·병동·식탁만 차단하며, `GameState.gd`와 저장 schema는 계속 불변이다.

## 깊이 3문

1. 왜 완성된 25편에 ingress만 붙이지 않는가? 현재 원고는 대부분 월간 행동판에서
   이미 약속을 골랐다고 가정한 결과 장면이다. 그 판을 폐기한 제품에서 그대로
   재생하면 행동 결정이 화면 밖에서 일어난다. 각 장면의 선택이 약속·진료·식탁·
   이름·청구·연락을 직접 소유해야 한다.
2. 왜 AP 행동판을 다시 만들지 않는가? StoryMode의 실제 선택이 그 주의 행동이며,
   `commitment_event_owners`가 결과까지 한 번만 기록하고 AP를 0으로 닫는다. 새
   저장 필드나 숫자 여력판은 필요 없다.
3. 왜 아버지를 찾아가면 살고 안 가면 죽는 구조를 금지하는가? 위기 연락 방식은
   관계 영수증이고 생사는 의료 경과다. 약물 확인, 실제 임상 접근, M46의 병동
   의료 조정 중 2개 이상인지를 W188이 읽으며 M47의 방문·통화·놓침은 제외한다.

## 배치 A — M39~M43 사람·몸·가족 인과 13단위

1. M39 다은 경로가 아버지·다은·거래 중 이번 주 실제로 보호할 행동 하나를 고른다.
2. M39 지연 경로도 같은 세 비용을 지연의 부산 장거리 위치와 호칭에 맞게 고른다.
3. M39 무연애 경로는 존재하지 않는 연인·현수·상철을 발명하지 않고 실제 창구만 고른다.
4. M40은 M39에서 놓친 actor/창구를 exact flag로 읽어 취소비·이동·관계 반응을 보인다.
5. M40 수습 선택은 사과 문구가 아니라 찾아가기·재예약 실행·창구 포기 중 행동이다.
6. M41 다은 경로에서 문을 열어 진료받기·마감으로 가기·혼자 버티기를 직접 고른다.
7. M41 지연 경로는 부산 장거리에서 가능한 전화·이동·진료만 말한다.
8. M41 무연애 경로는 현수 재연결 receipt가 없으면 혼자/의료진 표면으로 fail-closed한다.
9. M42 다은 경로에서 함께 참석·혼자 참석·유급 일정 불참을 직접 고른다.
10. M42 지연 경로도 서울 식탁 동석을 자동 가정하지 않고 실제 이동 비용을 쓴다.
11. M42 무연애 참석 경로는 파트너 identity를 새로 만들지 않는다.
12. M42 불참 경로는 비워진 자리와 재약속 여부를 실제 결과로 남긴다.
13. M43은 M39·M41·M42의 실제 영수증을 읽어 속도와 방향의 비용을 다음 달로 넘긴다.

## 배치 B — M44~M48 이름·청구·마지막 연락·연말 10단위

14. M44는 정본인 창원→서울 KTX 방향을 유지하고 terminal에서 실제 통화 연결 또는
    걸지 않음을 한 번만 쓴 뒤 answered/missed 후속으로 잇는다.
15. M45 다은 경로는 공동생활의 시간·책임 비용으로 이름 요청을 직접 고른다.
16. M45 지연 경로는 소유·통제·계급 비용으로 분리하며 서명을 자동 동의시키지 않는다.
17. M45 자기 이름 경로는 자기 범위 축소 또는 철회를 실제 문서 행동으로 남긴다.
18. M45 자료 빈칸 경로는 대주·원금·만기·담보가 없으면 타인 이름 사용을 막는다.
19. M46 다은 경로는 긴급 청구·자기 몸·아버지 의료 조정 중 먼저 실행할 일을 고른다.
20. M46 지연 경로도 같은 세 청구를 원격 위치와 실제 공개 범위에 맞게 고른다.
21. M46 무연애 경로는 파트너 도착을 만들지 않고 미선택 청구의 만료·악화를 남긴다.
22. M47은 present/called/missed 위기 연락을 생사와 분리한다. W188은 약물 확인·
    임상 접근·M46 병동 조정 2-of-3으로 `father_crisis_stabilized` 또는 passing을
    단조 처리한다. passed 증거가 하나라도 있는 손상 저장은 절대 부활시키지 않고,
    의료 receipt가 모순·누락된 저장은 어느 결과도 발명하지 않는 중립 복구로 닫는다.
23. M48의 실제 남은 사람·몸·가족 경계 선택을 W190에 두고 W192 결산이 읽게 한다.
    `arc_37_reckoning`은 M49와 충돌하지 않게 Chapter 5 첫 경계에서 한 번만 이어진다.

## 완료 증거

- 기존 author-only 25편은 KO/EN 같은 위치·인물·행동·선택 순서로 shipping이 되며,
  신규 gateway/경과 사건도 lifecycle·visual·audio·등급 원장에 정확히 반영된다.
- 보호 주차마다 StoryMode의 non-expression 선택 하나만 weekly commitment를 소유하고,
  같은 주 AP 행동판·중복 적용·달력 이중 전진이 0이다.
- M39 protected/missed, M41 care/witness, M42 partner, M44 call, M45 name,
  M46 triage/medical, M47 crisis-contact/life, M48 boundary receipt가 상호배타·
  저장·복구된다.
- KTX는 창원→서울, 지연은 부산 장거리, 빈 병실은 사망 뒤 narration이며 살아 있는
  아버지 대면으로 쓰이지 않는다. 위기 방문·통화·놓침은 생사 writer가 아니며,
  생존 경과는 완치가 아니라 병동에서 급성 악화를 잡은 입원 지속 상태다.
- `father_passed`는 단조이며 damaged 0/2 receipt, 중단 저장, terminal 재진입이
  fail-closed한다. 정상 새 런에서 stable/passed 두 의료 경과가 모두 도달 가능하다.
- 33세·1장의 30억 `instant_legend`, startup 우선순위, 34세 이후 final-week 대기,
  엔딩 35 ID·CG·15 route와 종막 서명 coda 72/33은 불변이다.
- 표적 direct/self-test, 영향 selector, JSON·KO/EN·diff, exact clean 전체 감사가
  failure flag 0과 `✅ 감사 통과`로 끝난다.

## 다음 경계

이 오더는 Chapter 4 M39~M48의 제품 경로만 소유한다. M49~M59의 계약 상승곡선,
마지막 남은 actor/문서/대화 receipt, M60·`arc_final_week` actor binding과 손상
signature 복구는 다음 Chapter 5 오더가 소유한다. 자동 GREEN은 사람 재미 GO가 아니다.

## 규범 판정

- **승격 후보:** 폐기한 월간 행동판이 선행 선택을 소유하던 후반 원고는 StoryMode
  장면의 실제 선택과 weekly commitment receipt 없이는 shipping하지 않는다는 규칙.
  완료 시 기존 story-first 정본에 이미 포함되는지 대조한 뒤 중복 없이 한 곳만 갱신한다.
- **일회성:** 정확한 보호 주차, 사건 ID, lifecycle count/hash, baseline commit,
  mutation 수는 ORDER-131 증거이며 다른 장의 장면 수·선택 수 목표가 아니다.

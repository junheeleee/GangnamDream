# Active Queue Spec: ORDER-148

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-148 [P0·public demo truth] 공개 데모 M01~M06과 legacy V2 W1~W24를 모든 현재 출시 문서에서 분리한다

**[~] 2026-09-01 Codex 착수 · 기준선
`9996952aded09b0b53b94af2e2b47fe033ba68d4`:** 사용자는 exact
`story_demo_rc` BUILD `2026.08.31.1`의 M01~M06 범위와 StoryMode 중심 구조에
최종 GO했다. `CLAUDE.md`와 완료 사람 게이트는 이를 반영하지만, 일부 현재 출시
문서와 legacy `demo_rc` 사람 게이트는 아직 W1~W24 V2를 공개 데모로 부른다.
제품 바이트를 바꾸지 않고 현재 주장과 역사·호환 증거를 분리한다.

## 깊이 3문

1. **M01~M06이 24주라는 계측도 지울 것인가?** 아니다. 한 달 네 주인 전용
   story demo의 `weeks=24`, 정산 6회, 저장 영수증은 정확한 내부 계측이다.
2. **옛 W1~W24 V2를 삭제할 것인가?** 아니다. `runtime_default=false` 저장 호환,
   회귀 검사, 과거 후보와 내부 실험 증거로 보존하되 공개 출시 claim에서만 뺀다.
3. **사용자 GO로 일본어·중국어 출시 claim도 닫을 것인가?** 아니다. 구조·범위 GO와
   원어민 자연스러움은 별개다. M01~M06 JA·zh-CN·zh-TW 게이트는 OPEN으로 둔다.

## 20단위 구현·검증

1. 큐의 W9~24 공개 `demo_rc` 재출시 대기선을 legacy V2 보존선으로 바꾼다.
2. 컨텍스트 라우팅에서 public story demo와 legacy V2를 분리한다.
3. 핸드오프의 현재 후보·GO·HOLD 문장을 최신 사용자 판정에 맞춘다.
4. 마스터 출시 감사의 공개 데모 기본 패키지를 `story_demo_rc`로 바꾼다.
5. QA 체크리스트의 공개 데모 사람·플랫폼 표본을 M01~M06 후보에 묶는다.
6. 빌드 파이프라인의 W24 bridge를 legacy/internal로 명시한다.
7. 플레이테스트 키트의 외부 기본 진입을 M01~M06 StoryMode 후보로 바꾼다.
8. Next Fest 제출 체크리스트의 후보 신원을 M01~M06으로 바꾼다.
9. Steam 페이지의 공개 데모 준비 상태를 active M01~M06 후보에 맞춘다.
10. CORE_LOOP_V2 헤더를 현재 공개 데모가 아닌 저장·회귀 기준선으로 한정한다.
11. AP_REDESIGN 헤더를 legacy/internal 호환 설계로 한정한다.
12. i18n·입력·컨트롤러·scene tier 문서의 24주 증거에 legacy 표지를 붙인다.
13. `demo_rc` 후보 note를 공개 후보가 아닌 legacy/internal 후보로 명시한다.
14. `story_demo_rc` note에서 구조 GO와 원어민 OPEN을 정확히 분리한다.
15. `demo_rc`의 열린 사람 게이트를 삭제·거짓 완료하지 않고 legacy V2 scope로 옮긴다.
16. 공개 데모에는 완료된 M01~M06 사용자 GO와 세 원어민 OPEN만 연결한다.
17. release content inventory에 staged `story_demo_rc` 범위를 별도 등록한다.
18. 기존 retail/export preset 수와 legacy V2 package 증거는 바꾸지 않는다.
19. 현황판을 생성기로 재발급하고 공개/legacy 표면을 대조한다.
20. context·human gate·release inventory·선택 감사와 전체 감사를 clean exact에서 실행한다.

## 반드시 보존할 경계

- 공개 데모 제품·사건·번역·패키지 hash는 byte-exact다.
- 출시 데모는 M01~M06에서 끝나며 M07~M24를 새 데모 범위로 만들지 않는다.
- M01~M06의 내부 `weeks=24` 표식은 범위 모순이 아니다.
- 본편은 M01~M60 전체, `product_go=HOLD`, `human_density_gate=OPEN`이다.
- Chapter 5 두 정상 속도 사람 게이트와 새 exact 후보 요구를 유지한다.
- JA·zh-CN·zh-TW 원어민 출시 claim은 OPEN이다.
- legacy V2 런타임·저장·검사·역사 기록은 삭제하지 않는다.
- 월간 AP/행동판을 복구하거나 `project.godot`을 바꾸지 않는다.

## 정확한 파일 소유권

현재 주장 문서인 `docs/{CODEX_QUEUE,CONTEXT_INDEX,HANDOFF,MASTER_RELEASE_AUDIT,
QA_CHECKLIST,BUILD_PIPELINE,PLAYTEST_KIT,NEXTFEST_CHECKLIST,STEAM_PAGE,
CORE_LOOP_V2,AP_REDESIGN,I18N_GLOSSARY,INPUT_MATRIX,CONTROLLER_UX_STRATEGY,
SCENE_TIER,AUDIO_QA,I18N_GLOSSARY_ZH}.md`, `docs/human_gates.json`, 생성본 `docs/STATUS.md`,
`content/meta/release_content_inventory.json`, 그 원장을 검증·렌더하는
`tools/release_content_inventory.py`, 생성본 `docs/CONTENT_RATING_INVENTORY.md`,
문서·원장 해시 ratchet `tools/chapter1_core_loop_v2_causal_ledger_check.py`,
마감용 `CLAUDE.md`, `docs/WORK_LOG.md`,
이 사양만 소유한다. 제품 코드·사건·번역·패키지·`project.godot`은 read-only다.

## L1 / L2 / L3

- **L1:** current-doc 검색, human gate schema, release inventory, context, diff 검사가
  공개 `story_demo_rc`와 legacy `demo_rc`를 혼동하지 않음을 증명한다.
- **L2:** 생성 STATUS/출시 문서의 공개 후보·GO·원어민 OPEN·본편 HOLD를 서로 대조한다.
- **L3:** M01~M06 제품 사용자 GO는 기존 exact 증거를 보존한다. 새 플레이 판정은
  만들지 않으며 원어민 세 언어 게이트는 계속 OPEN이다.

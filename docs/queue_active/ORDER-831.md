# ORDER-831 — 체험판 2차 평가 최종 수리

#### [~] ORDER-831 · C2/C3/C4 · ORDER-829 동결 예외의 마지막 수정

2026-11-13 사용자 승인. 직접 진행 두 장면의 민준 발화, 월말·최종 회고의 기존
가까운 재정 목표, 4월의 실제 매물 금액 계산, 지정된 반복·소품·시각·M6 추가
인계의 부담 및 영어 문장만 고친다. 반장의 문자·3월 계산대·6월 확인 전화와
잔여 50만 원·문의 직전 컷·1월 도입과 상철 핵심 대사 보존. M11 첫 돈의 문,
선택 효과·플래그·아이템·연출·저장·새 시스템과 장면은 변경하지 않는다.

### [~] 착수 — 만지는 파일

- 본문: `content/events/arc_events.json`, `content/events/core_loop_v2_events.json`,
  `content/events_en/{arc_events,arc_daeun,core_loop_v2_events}.json`,
  `content/events_{ja,zh-CN,zh-TW}/story_demo_events.json`. 공유 독자의 문구가
  원문에 정확 결속된 경우 `content/meta/demo_core_loop_v2.json`의 해당 추적문만.
- 표면: `playtests/order124/StoryChoiceM1M6Playtest.gd`, 기존 키 재사용을 우선하는
  `locale/ui_{ja,zh-CN,zh-TW}.json`의 해당 보호 키. 재정 사다리의 `GameState`
  기존 소비만 사용하고 기준·스폰 가중치·경제는 수정하지 않는다.
- 검사: `tools/{StoryChoiceM1M6Check,StoryDemoFourLanguageCheck,ScreenshotQA}.gd`,
  `tools/{demo_localization_scope,full_body_translation_scope,demo_core_loop_v2_audit,zh_translation_audit,english_hangul_audit}.py`의 해당 소스 결속 및 표적 회귀만.
- 문서: 이 사양, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `CLAUDE.md`. 본편 직접
  진행 발화와 M01~M10 돈 판단은 여기서 목록으로만 남기고 수정하지 않는다.

상철 4월 사무실 체인(T2, 기존 두 응답의 결합과 소품/방 구하기 현실성), 6월 연락
및 종막(T1 체인의 해당 링크)만 수정한다. 기존 방·초상·연출·소리·문단 경계를
유지하며 발화는 인물 소유 지식 안에서, 비용은 새 차감 없이 행동/시간으로 쓴다.

5언어 보호 차선·공유 독자·별도 소스 RC·실제 5언어 화면으로 확인한다. 8.31과
11.13.1은 덮지 않고 역사 판정을 이월하지 않는다. AI 블라인드 평가 재실행0.
다음은 사람 1명 1시간 테스트, 이후 상점 A안. Steam 업로드0.

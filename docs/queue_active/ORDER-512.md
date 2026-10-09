# ORDER-512 — 민서의 무회신 뒤 이름 칸 회상의 주체 정합

#### [~] ORDER-512 [서사 인과·5언어] 삭제된 민서 회신의 기억 소비자 수리

**착수 — 2026-10-10.** 457의 source d418772 실제 W200→W215 EN 독해 중
`arc_y5_general_name_boundary_exact`에서 삭제된 민서 회신을 회상하는 결함을 확인했다.
비저자 phone_tw_author가 현재 producer/flag/StoryMode consumer와 과거9b294d5a를
직접 대조했다. 현재 `arc_minseo_03_arrival` 선택01은 발신시각만 남고 읽음/회신/
다음 약속이 없으며, 강남이 다음 문장의 시작일 수 있다는 생각은 민준 혼자 한다.
후속 기억0만 옛 민서 발언을 유지한다. 새 관계 사실이나 약속을 만들지 않는다.

## 한 단위·깊이

- 지우면: 플레이어에게 없던 민서의 답장을 뒤 장면이 사실로 돌려준다.
- 24주 뒤: 새 상태는 생기지 않으며 실제 선택 영수증의 지식 범위를 끝까지 지킨다.
- 경쟁: producer의 무회신과 민준의 생각을 보존하며, 명의/보증인 기준 선택의
  인과는 유지한다. 기억 문단1개×5언어·1배치다. M60 진행 완료와 별개다.

## 파일 소유·배치

- root: `content/events/arc_pre_ending.json`와 `content/events_en/arc_pre_ending.json`의
  `arc_y5_general_name_boundary_exact.description_memory_if_known.chapter5_general_minseo_arrival_0`
  한 잎만. 민서의 발언을 민준의 실제 혼자 한 생각으로 정정하며 기억1/기본본문/
  선택·결과·조건·효과·flags·routing은 불변이다.
- root 공식 import: `content/events_ja/arc_pre_ending.json`,
  `content/events_zh-CN/arc_pre_ending.json`, `content/events_zh-TW/arc_pre_ending.json`의
  같은 잎만. CN/TW 별도 저자가 KO에서 직접 작성한 private response만 소유하고,
  root가 JA 직접 저작·공식 export/check/import `--replace-existing`를 수행한다.
- root 원장: `content/meta/full_game_localization.json`의 해당3잎 영수증/교정 이력,
  `content/meta/release_content_inventory.json` current 지문과 생성
  `docs/CONTENT_RATING_INVENTORY.md`. 공개 frozen source는 바꾸지 않는다.
- root 운영: 본 사양/완료archive·CODEX_QUEUE·CLAUDE 마지막 갱신·WORK_LOG 원문
  예산롤링·생성STATUS. phone_independent_review는 변경5잎/실제 producer/consumer/
  공식 원영수증/actual Git 범위를 독립 전수대조한다. 새 형식보고/도구/검사는0이다.

## 검증·완료

선언 commit/push 뒤 KO/EN 한 잎 정정, 세 언어의 공식 export/check/import와 원장
수용. 기존 full-game-localization-overlays lane·EN coverage/EN Hangul·서사 연속성·
장면음악·speech register·release inventory·데모 영향/context/queue/diff를 표적으로
실행한다. 새 실패0·비저자 전수 인과/토큰/두 문단·무회신 보존 판단 뒤 한정 닫는다.
기존 표시 검증 도구만 쓸 수 있고, 준비 표본은 정상 실제 재플레이로 부르지 않는다.
실제 폭/전체 경로/원어민/패드 미관찰은 분리해 남긴다.

project.godot·원본/사용자 저장·공개 M01~M06·과거 인간 판정·shipping languages·
경제·엔딩 라우팅은 변경0. 검수 절차/정본 규칙 신설0·작업 절차는 일회성이다.

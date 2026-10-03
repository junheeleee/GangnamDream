# ORDER-393 — 투자·인물 패드 안내의 지역 글꼴 연결

#### [~] ORDER-393 [P0·UI] 투자·인물 패드 안내의 지역 글꼴 연결

**[~] 착수 — 2026-10-03.** 사용자 계속 개발·검수 위임, Claude PR31
`ab6f52fe`의 두 hint만 분리 수용한다. 원격의 다른 전역font/원고 작업은 비포함.
ORDER-391 원장 복구는392 GO이며 번역8값을 다시 작성하지 않는다.

## 문제·깊이3문

- `MainGame._open_cat_people`·`_open_investments`의 RichTextLabel은 bold_font만
  지정한다. 실제 normal_font를 격리 측정하고 프로젝트 역할 객체가 아니면
  기존 `_font_regular` 연결 각2줄을 수리한다. FontKit·새 자산 변경0.
- 제거하면 일반 안내문이 OS fallback에 의존한다. 장기 선택·경쟁 선택 작업이
  아니며 돈/AP/거래/저장/사건 변화0을 보존한다. 두 소비자를 함께 검증해 같은
  MainGame source successor 검사와 5언어 런타임 부팅을 중복하지 않는다.

## 파일 소유

- Root: `scenes/MainGame.gd` 위 두 normal_font override4줄만. 제품 변경은
  별도 단일파일 commit으로 고정한다. 아래 기록 및 private `order393-static-*`.
- `/root/receipt_bridge392`: `tools/main_game_locale_history.py`,
  `tools/ui_translation_append.py`, `tools/ui_translation_append_self_test.py`,
  `tools/audit_scope.json`. 실제 새 Git parent/tree/blob/raw와 정확한 역삭제4줄만
  허용하는 successor·focused 반례. 기존 핀·원형 검증·split392 전이 보존,
  임의 source 대체·범용 면제·mutable PASS cache 금지.
- `/root/receipt_tests392`: private `.git/full-game-localization/order393-*`
  화면 helper/관측만(위 static 및 independent 파일 제외). 검증된
  StoryNameplateBootstrap pre-autoload 격리 재사용. 제품·tracked 편집0.
- `/root/independent392`: 읽기 전용 독립 검수, private
  `order393-independent-review.json`만. 실제 코드·도구·helper·PNG를 직접 읽고 판정.
- 기록: 이 사양, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/queue_active/ORDER-391.md`, `CLAUDE.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  필요시 기존 `docs/history/WORK_LOG_2026-09-07_localization.md` 손실없는 이동,
  `docs/agent_reviews/ORDER-393.json`, `docs/agent_review_decisions.json`,
  완료 시 `docs/queue_archive/ORDER-393.md`.391 마감은 별도 단위 판정 전 금지.

## 검증·완료 경계

- before 실제 두 hint normal/bold 역할과 glyph 측정; after CN/TW 투자4상태
  (비자산페이지/자산없음/거래불가/거래가능) + 인물, KO/EN/JA 두 hint 최소회귀.
  실제 MainGame1280×800, 같은 런타임 언어 변경과 JP/SC/TC 우선순위, 문구·
  BBCode·인수 순서·경계/잘림 확인. 사전/cache/font/theme 주입0.
- helper 원본·로그·PNG/hash/source identity, 실제 사용자 저장파일 전후불변,
  준비 상태 typed복원, raw input/거래/콜백0을 기록한다. prepared 화면은
  자연진입/실입력/물리패드가 아니다. 과거 실패를 지우거나 새PASS로 덮지 않는다.
- 표적 normal consumer5·UI receipt/JA UI/ZH/ENcoverage·context/queue/diff,
  새 source focused 반례·차선조회. Chapter1만720초 상한, 가능한 검사 병렬.
  변경 없는 역사self·전체감사·240주0. 기존392 검사결과를 재실행으로 대체하지 않는다.
- 인물 CN/TW 영어fallback·전역theme·11px 안내크기·기존focus 약3px잘림·
  동적자산명·다른 UI 번역은 후속이다. 이4줄을 전체font/현지화 완료로 부르지 않는다.
- GameState/경제/저장/project.godot/사전/수용원장/공개데모/사람원장 불변.
  기존155판정/133보고 보존. 공개GO1·인간OPEN45·본편/새package HOLD.
  native_reader/human_playtest/physical_controller_feel 미관측; 외부출시·지출0.
- 규범: 기존 I18N·UI·WORK_UNIT 재사용, 새 상시규범0. 분담·모집단·검사는
  일회성. 자동PASS는 계약 증거이며 재미·깊이·문체·원어민/인간/출시GO가 아니다.

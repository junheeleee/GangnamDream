# ORDER-742 — 서른다섯 생활·선택의 JA/zh 정합

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-742 · 서른다섯 생활·선택의 JA/zh 정합

2026-11-03 root 착수, 부모157·C5. 여섯 장면×세 언어=18 장면-언어 단위,
현재 KR20 leaf/JA·CN·TW60개 기존 번역을 독립 직접 대조한다.

## 정확한 소유권 (일회성)

`content/events_{ja,zh-CN,zh-TW}/arc_midgame.json`:
- arc_35_alone: description, choices/2/result_text (2).
- arc_35_birthday: title, description, choices/0/result_text, choices/1/text (4).
- arc_35_habit_check: description, description_if_known의 broke_routine/
  godsaeng_paradox_seen/kept_routine, choices/1·2의 text/result_text (8).

같은 세 언어의 `arc_chapter_themes.json`:
- arc_35_orthodox_weight: description, choices/0·2/result_text (3).
- arc_35_path_cost: description, choices/1/result_text (2).
- arc_35_unorthodox_weight: choices/1/result_text (1).

`content/meta/full_game_localization.json`은 이60개 수용/correction 및
원 batch·수용·이전 target 지문 보존만. 큐·157·이 사양·CLAUDE·11-03 WORK_LOG,
독립 보고/판정만 추가 소유한다. 기타 번역/선택은 비소유.

## 깊이 3문·검증

1. 제거하면: 설날/떡국, 고정 투자 루틴, 반년 만의 운동, 자산 이동·수익률/
   수면 성취, 연락/건강검진을 미뤘다는 과거를 원문 없이 확정하는 번역이 남는다.
2. 선택 대가: 현재 연락/세탁기·빈 시간·운동 감각·지출 확인·위험 메모가
   소유하며, 선택 의미·효과·과거 관계와 성과를 새로 만들지 않는다.
3. 경쟁: 현재 shipping에서 검출한 서로 독립적인 여섯 장면을 한 배치로 묶어
   반복 선언·검사 비용을 줄이되 각 조건 변형의 직접 대조는 생략하지 않는다.

fresh export/check → 독립 전독 → 명시 replace import. 숫자/나이/원화/
기간/토큰/개행/지역 문자와 HEAD 대비 소유60값만 변경인지 역대조한다.
현재 수용·공개데모/EN·scope 진단 변화·context/queue/diff를 검사한다.
불변 도구 self-test와 완료738~741은 반복하지 않는다.
KO/EN·gameplay·공개데모·project.godot·저장·allowlist 비소유.
전체차선/전체5언어·렌더/원어민·외부출시 완료는 판정하지 않는다.

도달 경로: 실제 source hash 불일치20과 현재 KR/목표 장면 대조.
생산자↔독자: 두 KR 파일의 여섯 root → 기존 built-in overlay consumer.
바꾸는 상태: stale60 → current60; 신규 커버리지0.
포기 시 잃는 것: 현재 선택과 과거의 사실·주말/나이·루틴의 열린 의미.
서사 위치/계층: 기존 여섯 사건·원본 계층 불변.
닫는 것: source60 정합만. 규범은 기존 I18N 정본 적용·승격0.

## 검사 실물·범위 판정

2026-11-03 완료. 독립 KR20/목표60 전독에서 JA 지루함 비교의 부정범위1곳을
수리했고 CN/TW 한줄씩 검사 실패는 一行行 명시로 수리했다. 원초안/실패3로그
보존·검사완화0. 최종 공식check/import20×3·stderr0, delta60/6파일,
기존336배치/원수용/이전target/비소유값 불변. scope1173→1113
(stale1110=언어별370+요약3), 공개데모5언어14사건100leaf122UI·EN1813/35 clean.
원자료 `.git/localization-life35-20261103/`, 불변self-test 반복0.
제품 `91f5029`의 [독립 보고](../agent_reviews/order742-life35-cjk.md)는 이60정정만 판정한다.
새커버리지/전체번역/차선·실화면·원어민·최신CI·사람/출시 GO는 아니다.

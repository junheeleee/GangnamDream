# ORDER-535 — 월초 경제 재진입 중복 방지

#### [~] ORDER-535 [P1·저장 정합] 같은 월 재개는 시장·현금·위기를 다시 적용하지 않는다

**착수 — 2026-10-10 / 구현 전 선언.** 534 정상 입구 조사에서 확인한
MainGame 재생성의 시장 재추첨과 월초 경제 중복을 수리한다. 본편 입구 완성이나
M07 실제 플레이 완료가 아니며 534의 REWORK/HOLD를 유지한다.

## 깊이 3문·근거

1. 없으면 같은 저장을 열 때 시장 국면·가격·배당·위기 효과가 달라질 수 있다.
2. 플레이어의 기존 포트폴리오·현금을 보존한다. 새로운 선택/보상/밸런스를 만들지 않는다.
3. 재개는 시간 진행이 아니다. 실제 다음 달 첫 주만 원래 경제 처리를 한 번 소비한다.

## 소유·금지

- root: scenes/MainGame.gd의 _run_week_start_economy와 필요한 작은 판별 함수,
  이 사양·큐/연속번호·WORK_LOG·CLAUDE 현재행·독립보고/판정 원장.
- phone_cn_author: systems/InvestmentSystem.gd의 초기화·국면 countdown 보존.
- cjk_wrap_diagnosis: 기존 tools/ManualSaveCheck.gd의 실제 v4 저장/재개 회귀.
- phone_independent_review: 비저자 전수 검수, 제품 파일 편집0.
- 기존 flags/market_context v4 직렬화만 이용한다. GameState/SaveManager/스키마,
  기본 진입/월말 정산/원문·번역/project.godot/공개 데모/사용자 저장/인간 판정 비소유.
  새로운 runner·도구 최적화·종료 ObjectDB 추가 탐침0.

## 구현 계약 (일회성 범위)

- 월초 경제는 legacy/full의 week_of_month=1, V2 requested=false에서만 적용한다.
  flags의 monthly_economy_turn을 실제 처리 turn으로 기록하고 같은 turn 재진입은
  RNG·위기·뉴스·가격·배당·마진콜을 반복하지 않는다. 동기 signal 재진입도 막는다.
- 새 marker 없는 구저장은 같은 year/month의 실제 news_log가 있을 때만 이미 처리한
  월로 받아들인다. 이전 달 뉴스/잘못된 타입은 처리 근거가 아니다. 다음 달/연도는 정상 진행한다.
- InvestmentSystem 초기화는 기존 국면/가격을 다시 추첨하지 않는다. cycle_timer는
  기존 market_context에 보존하며 실제 process_month와 시장충격이 갱신한다.
  새 게임의 미초기화 시장은 원래 5~11개월 추첨을 한 번 한다.
- 구저장에 countdown이 없으면 현재 국면·가격·로그를 보존하고 잔여0으로 이관한다.
  다음 실제 경제월에 정상 재추첨한다. 잃어버린 과거 잔여기간을 발명하지 않는다.
  숫자형 정수값만 허용하고 JSON float 정수는 수용한다. 손상값도 잔여0으로 이관한다.

## 검증·완료

- 기존 ManualSaveCheck에서 실제 가격/뉴스/현금 변화를 첫 처리 한 번만 확인하고,
  중복 호출·실제 v4 save/load·새 MainGame 재생성·다음 달/연도·구저장·V2/주중 제외,
  countdown/충격 저장과 잘못된 타입 경계를 확인한다. synthetic fixture는 검증용이며
  정상 M07 플레이 증거로 쓰지 않는다.
- proven pre-autoload bootstrap + fresh HOME/XDG/고유 namespace로 실행한다.
  exact success marker와 stdout/stderr/Godot 전체 오류 scan, user 저장 불변을 확인한다.
- 영향 검사·EN 한글·저장 호환·diff/context/queue, 독립 source+raw 전수 검수를 결속한다.
  완성 범위는 경제 재진입 정합 한정이다. 기본 full story-only 입구·M07·전체 출시 HOLD.
  자동 계약은 재미·깊이·문체나 인간·원어민·물리 패드 관찰을 증명하지 않는다.

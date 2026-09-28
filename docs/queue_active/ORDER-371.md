# Active Queue Spec: ORDER-371

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-371 [P0·실제 관측] 중국어 취업 결과의 화면과 키 입력 경로를 분리 검증한다

**[~] 2026-09-28 Codex 착수.** 365~370에서 수용한 CN/TW 결과22키씩은
아직 새 실제 렌더·입력 관측이 없다. 기존 ScreenshotQA의 직접 handler 경로를
정상 입력 완료 증거로 재명명하지 않고 실제 JobHuntMiniGame 단독 소비자를 검사한다.

## 깊이 3문

1. 없으면: 번역44개의 배치·글리프·잘림 및 확인 버튼을 실제로 보지 못한다.
2. 장기 상태: 검증만 추가하며 점수·스트레스·AP·원문·저장은 바꾸지 않는다.
3. 경쟁: 준비된 결과48상태와 정상 문항 선택4세션의 서로 다른 증거를 구분한다.

## 소유·비소유

- root: 큐2파일, 이 사양→archive, CLAUDE 현재행, WORK_LOG, 생성STATUS,
  `docs/agent_review_decisions.json` 신규1행, `docs/agent_reviews/ORDER-371.json`.
  private `.git/full-game-localization/order371-run.py`, `order371-oracle.json`,
  `order371-screen-*`의 독립 실행·원본 로그/관측/PNG·보존 증거 및 정리 helper.
- `/root/screen_path_probe`: private `order371-check.gd`, `order371-check.tscn`만 저작.
- `/root/r3_route_probe`: 비저자 검수. private `order371-independent-review.json`만 소유.
- runtime·번역·등록된 공용 검사·project.godot·인간 원장·과거 증거는 비소유.
  확인된 제품 결함이 있으면 별도 exact 수리 범위를 선언한다.

## 한 배치·표적 검증

- CN/TW 각각 resume/interview×등급0..3×최종 stress −1/0/+1 = 준비24, 합48.
  준비 경로만 score/stress/result handler를 직접 설정하며 정상 도달성 주장은 하지 않는다.
- 1280×800 실제 PNG20장: locale별 mode×grade 8장 및 zero-stress2장.
  44번역의 실제 Label text를 frozen locale JSON oracle과 전수 대조하고
  glyph·visible node identity·content/viewport bounds·font/line·default focus를 기록한다.
- locale×mode 합4세션은 실제 open 뒤 문항4/5개·좌우/Enter press-release를 보낸다.
  결과함수·선택함수 직접 호출 및 점수/문항/타이머 조작은 이 경로에서 금지한다.
  press/release 양 edge·button action_mode·질문 진행·결과·closed signal을 기록하며
  한 쌍당 선택/종료1회, 종료 뒤 추가입력에 중복0을 확인한다.
- 기존 pre-autoload bootstrap의 새 namespace로 원래 저장을 격리한다.
  시작/끝 HEAD/tree·source census·helper SHA·실제 사용자 파일맵을 결속한다.
  Godot 종료0 + exact marker + stdout/stderr/Godot log error0 + 개수/정체성/PNG
  검증 모두 필요하다. 실패 원본은 보존하고 기존 증거를 지우지 않는다.
- 비저자 검수는 fixture 전체, 48상태/4입력 보고, PNG20장을 직접 본다.
  queue/context/decision·diff·생성STATUS만 표적 검사한다. 이미 끝난 번역검사와
  전체 감사·240주·역사 대규모 self-test는 이유 없이 반복하지 않는다.

## 판정 경계·규범

정상 MainGame 진입/AP정산·전체 화면/해상도·JA·물리 키보드/패드·원어민·인간
플레이·상품/새package 완성은 미관측이다. 공개GO1·인간OPEN45와 본편 HOLD 유지.
검사는 도달성·계약 증거이지 재미·깊이·문체 판정이 아니다. 이48/20/4·파일 범위와
관측 방식은 **일회성**이며 기존 입력·검증·권한 정본을 바꾸지 않는다.

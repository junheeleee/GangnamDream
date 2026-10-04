# ORDER-431 — 스캘핑 결과와 수익·손실 기록을 중국어로 읽는다

#### [~] ORDER-431 [P1·현지화] 결과3·정산로그2의 CN/TW10값

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·효율적 검수·main 커밋/푸시 위임.
429/430의 준비·거래 표면 다음으로 확인된 결과/로그 누락만 처리한다.
정산을 관측하는 이 묶음과 Holdem 입장/첫 테이블11은 서로 독립이며 별도 선언한다.

## 범위와 소유

- KO 정확5키: `세션 종료`, `거래 %d회`, `다시하기`,
  `스캘핑으로 %s 벌었다. (%d회 거래)`, `스캘핑에서 %s 잃었다.`.
- root: `locale/ui_zh-TW.json` 저작·양지역 수입·
  `content/meta/full_game_localization.json` append·새 private431 교환/normal·기록.
- claude_handoff_review: private431 CN 초안만. root가 공식 수입한다.
- receipt_tests392: 새 `.git/full-game-localization/order431-*` runtime Python/GD/scene.
  과거 helper를 읽기 재사용하되 고치지 않는다. 엔진 실행은 root만 한다.
- independent392: 비저자 10값 전수 의미·실제8PNG/입력·상태복원·normal 최종 검수.
- 추적 제품 변경은 두 locale와 수용원장3파일뿐이다. 큐/431 active/archive·
  CLAUDE·WORK_LOG·생성STATUS·agent 보고/판정은 기록 범위다.
  KO/EN/JA·Scalp/Main/Holdem/Font/GameState/Meta·돈/확률/조건/효과·save 변경0.
- 삭제하면 결과 제목/거래횟수/재시도/손익로그가 영어 폴백으로 돌아간다.
  24주 상태 차이·선택 경쟁은 해당 없음: 기존 행동의 번역이며 새 선택/보상은 없다.
- 목표 accepted41602/b205→41612/b207·CN/TW1706→1711·JA3044불변.
  shared `세션 종료`의 Holdem 결과 소비자는 미관측으로 남긴다.
  직접영문·패드힌트·자연진입·실시간 매매·전체게임 번역 완료는 이 범위가 아니다.

## 검수 설계

- 한국어에서 CN/TW 별도 저작, 공식 source-bound export/check/import 각각5값/2batch.
  원래 header·source digest·기존4파일 raw역상과 기존 수용값을 보존한다.
- 언어 설정→새게임→Main/Scalp의 proven pre-autoload 격리, 실제 player34 원본 보호.
  CN/TW 각각 승리/손실 독립2case, RESULT+Main 기록창 총8PNG,1280×800.
- actual start 직후 tick 전에 process false. 준비값 money5M/skill15/mental60,
  gambling/addiction0·trades2·비보유·realized±100k·meta plays0를 fixture로 명시한다.
  actual `_end_game`을 각case 단1회 실행한다. 거래결과 준비와 자연 BUY/SELL을 혼동하지 않는다.
- 독립 expected: 승리 money5.1M/skill16/gambling2, 손실4.9M/mental56.
  공통 runs1/session_trades2/RESULT/processfalse/log1/meta plays1·addiction0/AP불변.
  실제 GameState 전체 typed·alias/direct fields·숨은수치·Meta data/파일존재/bytes와
  signals를 비교하고 case마다 원래 상태로 완전복원한다. BUY/SELL/closed/확정/다음턴0.
- RESULT 제목20px·횟수12px·손익26px·Retry/Leave13px는 실제노드/폰트/경계를 측정.
  활성 결과버튼2개에만 안전한 방향·Tab·합성Dpad, confirm0·helper focus주입0.
- 로그는 실제 정산 생성자→GameState.add_log→Main._render_log를 통과한다.
  Scalp 숨김/실제 정보창 토글/첫탭/스크롤을 prepared reader 진입으로 명시하며
  Leave나 closed.emit으로 AP정산을 추가하지 않는다. UI 가시성/탭/스크롤/텍스트도 복원한다.
  기존 로그의 언어변경 재번역을 주장하지 않는다.
- log_box 실제 normal13px font resource/base/variation/SC·TC fallback을 기록한다.
  UIStyle ThemeDB fallback을 확인하되 override 유무만으로 결함/PASS를 추정하지 않는다.
  실제 쓰인 normal role와 조회만 한 bold role를 구분하며 OS/JP 우선 폰트를 허용하지 않는다.
- 같은 clean 후보 실제표적 검수 뒤 공통normal1회. 새제품/공통스키마/스케줄러/엔딩
  변경 없으므로 과거focused·전체감사·240주·429/430완료화면 반복0.
  실패는 원본 보존하고 원인한정 수리/재검수하며 기존 성공증거를 새실행으로 부르지 않는다.

일회성 번역·검수 절차이고 새 상시규범0. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다.
본편/새packageHOLD·B3/B4·원어민/인간/물리 미관측·공개GO1/인간OPEN45를 유지한다.


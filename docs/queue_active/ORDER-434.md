# ORDER-434 — 홀덤의 잔액·팟·베팅 금액을 원 단위로 정확히 표시

#### [~] ORDER-434 [P1·숫자 표시] 홀덤 formatter 절삭·중국어 폴백 단위 수리

**[~] 착수 — 2026-10-04.** 사용자 위임의 내부 개발·품질 수리다.
다음 홀덤 번역 화면을 준비하다 실제 `_fmt`의 기존 결함을 확인했다.
12,500원은 KO에서 `1만`, 준비 CN/TW에서는 없는 `%d만`의 영어 폴백과
10,000 나눗셈이 결합해 `₩1K`가 된다. 화면 정밀도 수리를 번역보다 먼저 한다.

## 범위·소유

- root: `scenes/HoldemClub.gd`의 `_fmt` 본문만
  `LocaleManager.format_whole_won(int(amount))`로 교체한다.
  같은 정수화·KRW 가치·부호를 보존하며 EN도 축약하지 않은 won 표기다.
  `_signed_fmt`, 베팅·승패·덱·AI·정산·AP·저장·수치는 바꾸지 않는다.
- claude_handoff_review: 새 `tools/holdem_money_history.py`의 독립 Git 전이 증명,
  `tools/ja_translation_pipeline.py`와 `tools/ja_translation_audit.py`의
  정확한 소스 3키 퇴역/기존 JA 3값 보존 경계와 새
  `tools/holdem_money_receipt_check.py`만 소유한다.
- root: `tools/ui_translation_append.py`의 EOF successor 증명만 추가한다.
  기존 15개 실제 Main/Scalp/Aruba 조합과 새 현재 Holdem 조합 하나만 허용한다.
  가상 조합·임의 raw/HEAD·비소유 경로 변경은 거부한다. 원래 본문/pin 불변.
- receipt_tests392: `tools/audit_scope.json`의 새 명시 차선,
  private434 격리 화면 helper만. 집중검사는 화면 helper와 병렬화를 위해
  선언 후 claude_handoff_review로 소유만 이관했으며 파일 범위는 같다.
  private434 normal helper와 실제 실행은 root가 맡는다.
  independent392는 비저자 전수/원본 최종 검수다.
- 기록: CLAUDE, 큐/L3, active/archive434, WORK_LOG, 생성STATUS, agent 보고/판정.
  원문/번역·수용원장·공개 데모·인간 판정·과거 증거·실제 player 파일은 불변이다.

## 소스·수용 경계

- 사라지는 유일 `_tr` 소스는 `%.1f억`, `%d만`, `%d원` 세 개다.
  현재 collector는 실제 calls/keys에서만 이 3개를 빼고, 남은 entry ID를 보존한다.
  과거 census/계약 비교에만 exact predecessor를 사용하며 새 source를 옛 숫자로
  위장하지 않는다. 기존 pipeline/audit 비교 본문·pin을 넓히지 않는다.
- 기존 JA 3값은 삭제·재번역하지 않는다. immutable JA Git blob의 그 값과
  실제 소스 퇴역·accepted 부재를 결속하는 retained 경계만 추가한다.
  CN/TW/JA dictionary와 원장 바이트는 모두 그대로다. accepted41612/b207 유지.
- 새 shared proof는 실제 선언부모→제품단독 commit/tree/blob, 단일 경로 diff,
  `_fmt` 한 함수 전체 역상·현재 raw·HEAD/ancestry를 검증한다.
  Main 14단계 증명과 기존 47경로를 바꾸거나 fake dead formatter를 남기지 않는다.

## 표적 검수

- 새 집중검사: 실제 Git 전이/전체바이트 역상, 단독 합성 fault의
  commit/parent/tree/blob/path/raw/HEAD/manifest 거부, collector 실제 -3과
  나머지 entry ID 보존, JA retained 3값/accepted 부재, old 본문/선행 증거 불변.
  mock/replay 경계와 실제 fresh current collector를 구분한다.
- proven pre-autoload 격리 bootstrap으로 KO/EN/JA/CN/TW 각각 SETUP·첫 PREFLOP
  2화면, 총10PNG를 실제 관측한다. formatter의 원 단위·쉼표·부호를 경계값과
  실제 소비자에서 대조한다. 5M 현금/100k buy-in의 실제 첫손은 player95k,
  상대100k/90k·pot15k·call5k·half-pot12.5k·pot20k·all-in95k다.
- 첫손은 준비한 진입/RNG에서 실제 ui_accept로 시작한다. seed 준비와 자연
  스토리 진입을 구분한다. 52장 고유·배분6/잔여46과 플레이어 첫 차례를 확인한다.
  SETUP 금액/테이블 행동의 실제 semantic cursor와 키보드·합성 D-pad를 본다.
  테이블 confirm/cancel/Leave·실제 베팅/정산·AP 소비는0이다.
- 실제 금액 label/button의 regular/bold 역할·지역 primary·font size·줄바꿈·
  폭/높이·겹침을 관측한다. queued-free 이전 화면과 일시적 배너를 제외한다.
  준비 사례의 폭만 승인하며 모든 가능한 거액/해상도를 관측했다고 하지 않는다.
- 각 사례의 GameState·Holdem 필드/RNG·Main UI/overlay·Meta 메모리/파일·
  Tutorial·ControllerHints/마우스·BGM을 복원하고 실제 player34 파일을 보존한다.
- collector와 source 증명을 바꾸므로 새 focused, 현재 receipt/fullbody,
  storygraph/Chapter1/Chapter5/Year5, JA/ZH/EN, context/queue/diff/등록검증을
  최종 clean 후보에서 각1회 수행한다. 명시 차선 조회는 별도이며 과거 focused,
  전체감사/240주·기존433 화면이나 성능 비교를 다시 실행하지 않는다.

## 경계·다음 작업

- actual source28aeb902/tree f0983fa는 독립 REWORK다. 최초 helper parse 실패는
  원본119파일·root 종료 기록으로 보존했다. 수리한 r1은5지역 실제10PNG/130raw/65tap/
  첫손5를 남겼으나 canvas48px에서 접미사5개가 잘려 KO 외4지역 strict validator 실패다.
- 정적14검증+조회1은776.762초 PASS, focused49case/11.708초다. 원본 normal
  SHA199073014eee6c428689591a20a8010e074554847143e6dbe5d500395aaf7b6e의
  all_pass는 L1 한정이며 runtime_quality_pass=false/REWORK를 바꾸지 않는다.
  tracked3043·선행2795·private4·r1증거161·실제player34 전후 불변이다.
- [별도436](ORDER-436.md)이 canvas draw 폭을 수리한 뒤 새 후보/실제 재관측으로
  이 잘림을 해소한다. 과거434 후보 판정·실패 원본을 덮어쓰지 않는다.

- 이 수리를 지우면 같은 금액이 다른 값으로 보인다. 새로운 선택/24주 상태/
  경쟁을 추가하는 작업이 아니라 기존 경제 표시의 사실성을 고치는 작업이다.
- 기존 소스의 상대 블라인드 주석, direct POT/BOARD/STACK/BET/NEW HAND,
  영어 폴백·작은 글자와 이후 라운드/정산은 별도 채무다. 이 수리로 닫지 않는다.
- 뒤이어 홀덤 첫 화면 신규22키/중문44값을 별도435로 선언한다. 동일 SETUP/
  PREFLOP의 차례·EV3·행동6·준비 입력힌트를 함께 번역하며 기존 table hint는
  새 번역으로 세지 않는다. 변경 없는 서사 검사는 명시 NOT_RUN인 좁은 번역
  차선을 쓰고 fresh receipt/fullbody와 실제 바뀐 화면은 유지한다.
- 일회성 수리·검수. 새 상시 규범0. 원어민/인간/물리 패드 관측은 미발급,
  공개GO1/인간OPEN45와 본편/새package HOLD를 보존한다. 외부 출시 권한은 아니다.

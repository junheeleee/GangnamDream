# ORDER-418 — 연락 뒤 남는 말과 기록의 중국어 번역

#### [x] ORDER-418 [P1·현지화] 아버지·상철의 반응과 연락 기록을 중국어로 읽는다

**완료 — 2026-10-04.** source b8ff97a / tree7ec013f 범위한정 독립 GO.
[독립 보고](../agent_reviews/ORDER-418.json)가 원문·수용·실패·화면·검사·SHA를 소유한다.
CN/TW 각19값·38receipt/2batch, accepted41322/b189. 실제연락10·추가표시14·4PNG PASS.
최초51.335초 FAIL은 lazy Hyunsu 기본값 기대 누락이며 원본을 보존한다.
r1은 실제상태를 바꾸지 않고 독립기대만 보완해51.948초 PASS, player34 불변.
공통normal13/788.415초 PASS. 본편/새packageHOLD·원어민/인간/물리미관측 유지.
규범 판정: 아래 착수/검수 지시는 일회성. 기존 정본 적용, 상시규범 추가/승격 없음.

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·효율적 검수·main 커밋/푸시 위임.
기존 KO 키 19개를 CN/TW 각각 직접 번역하는 한 배치다.

## 판정 단위·정확 모집단

- 누락 시 연락을 마친 본문/기록이 영어 폴백으로 바뀐다. 표현만 추가하며
  선행 사건·관계·행동 비용·시간·선택·회수·수치·플래그를 바꾸지 않는다.
- MainGame::_contact_result_text의 call/failed_call/drink/meet/default 5키,
  _contact_action_log_text의 같은5키, _contact_flavor의 father5/sangchul4키.
  exact KO 키는 공식 export의 owner와 source hash로 봉인하며 총19개를 요구한다.
- CN/TW 각각19값·총38값/receipt38/batch2. 기존415/413 키와 교집합0.
  accepted41284/b187→41322/b189, CN/TW1547→1566키씩을 목표로 한다.
- 아버지 우선순위: reconciled→visited_father→arc_father_02_done→자산5억이상→기본.
  상철: jiyeon_reveal_seen→arc03→arc02→기본. 과거 병문안/화해/지연 진실을
  번역이 새로 발명하지 않는다. meet의 헤어짐은 연애 결별이 아니다.
  failed_call은 통화 성공이 아니며 Roman 이름·{name}·%s·✓를 유지한다.

## 파일 소유

- Root: private418 CN/TW 한국어 직접초안·공식 export/check/import 및
  locale/ui_zh-CN.json, locale/ui_zh-TW.json,
  content/meta/full_game_localization.json의 위38값/receipt38/checksum/batch2.
  큐·이사양·CLAUDE·WORK_LOG·생성STATUS·완료archive·agent report/판정원장.
- /root/receipt_tests392: 새 private418 실제소비자 helper3개만.
- /root/independent392: 원문·두지역38값·수용·원본화면/상태·검사 독립읽기,
  최종 private418-independent-review.json 한 번 작성/봉인.
- MainGame·GameState·KO/EN/JA·폰트·가격·조건·기존proof/test·공개demo·
  인간원장·project.godot·출시manifest 비소유. 새시스템/범용검사0.

## 효율적 검수

- 지역별 별도 직접저작·전수 의미/말투/사실 대조, 공식1batch씩과 raw역상보존.
- proven pre-autoload 격리 1280×800. 공통5채널과 father5/sangchul4 getter 전량.
  실제연락은 언어당5회: father(call), sangchul(drink), jaehyuk(사기 뒤 failed_call/
  기본 meet), jiyeon(호감50미만 check_in). prepared pending{}·AP1·met/reachable.
- 실제 _ap_contact_person의 AP1→0·contact/affinity+4·human축/place/log 변화를
  정확 대조한다. mental은 +5와 legacy stress(-3)의 mental(+3)이 합산되는 실제
  경로를 검사하며 clamp 전 값과 형식을 보존한다. 별도 stress 필드 변화를 발명하지 않는다.
- 준비된 실제연락10회로5종 결과·5종 짧은기록을 확인하며 깊은 typed 복원.
  father/sangchul 기본반응 대표4PNG·실제SC/TC19px·자연타이핑/본문fit.
  나머지7 선행플래그 반응은 getter+실제본문표시로 확인하되 자연도달로 세지 않는다.
  다른인물의 미번역 flavor는 대상 밖이며 전체화면번역 완료로 부르지 않는다.
- getter-only rich분기는 실제 연락으로 milestone을 유발하지 않는다.
  confirm/raw/다음턴/주간finalize/자연진입/패드물리0, 플레이어파일 불변.
- 사전확인한 같은-source fast lane의 normal receipt/fullbody/storygraph/Ch5/
  Year5/Ch1/ZH/EN/context/queue/diff/목록만 최대3병렬1회.
  기존417 focused·5언어서체 화면·기존JA검사·전체감사·240주 반복0.
  실패원본 보존 후 실패영향만 재검사한다.

일회성 번역/표적사양·상시규범추가0. 자동PASS는 계약증거이지 재미·문체·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측,
지연 연애전 선물호칭·B3/B4 등 기존 위험을 보존한다.

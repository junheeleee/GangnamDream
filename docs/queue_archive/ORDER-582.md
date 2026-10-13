# ORDER-582 — 바카라 내추럴 도움말의 잘못된 무승부 안내

#### [x] ORDER-582 [정합·현지화] 도움말 source/receipt 수용 — 2026-10-13

기준 main c5371ece56dd8d023222ac33b14ecdb9720302e9. ORDER-578가 남긴
카지노 내추럴 오류는 blackjack 배당 문제가 아니라 바카라 설명의 오류다.
JeongseonCasino._show_glossary:862는 양쪽 내추럴을 모두 무승부라고 쓰지만
Baccarat.play:49–79는 추가 드로우 없이 점수를 비교한다. 9 대 8은 승패,
8 대 8·9 대 9만 무승부다. 기존 게임 규칙·배당·입력·저장은 바꾸지 않는다.

## 깊이·범위

잘못된 설명을 남기면 플레이어가 실제 정산을 오류로 이해한다. KO/EN 한 쌍을
첫 두 장의 8/9, 추가 드로우 없음, 높은 점수 승리·동점만 무승부로 맞춘다.
JA도 기존 오설명을 새 KO키로 수리하고 고아 옛키1만 제거한다. CN/TW는
같은 설명과 현재 누락된 제목 `내추럴 (바카라)`을 KO에서 각각 직접 작성한다.
실측2 source단위/번역5만 처리하고 15~25를 채우려고 관련 없는 UI를 섞지 않는다.
구저장 카지노 용어 소비 경로의 source 증거이며 정상 본편·실제 화면 증거가 아니다.

## 파일 소유·순서

- root: scenes/JeongseonCasino.gd 해당 KO/EN literal 한 쌍;
  locale/ui_ja.json 설명의 old키1/new키1;
  locale/ui_zh-CN.json·locale/ui_zh-TW.json 제목/설명 각2;
  content/meta/full_game_localization.json 새 accepted5/checksum/batch/source-change만.
- root: 큐2·이 사양/마감 archive·WORK_LOG·CLAUDE 현재행, KO/EN/JA/CN 저작.
- mod_layer_ci: 새 .git/order582-20261013/tw.response.jsonl만 KO 직접 저작.
- manual_save_ci: 같은 private의 비저자 source/공식receipt 검토 보고서만.
- rework_batch_plan: 같은 private before/final·보존 보고서만.

선언 commit/push → source literal만 local commit → 실제 Git source manifest에
fresh JA1/CN2/TW2 export → KO 직접 응답·비저자 전수 검토 → 공식 check/import
--accept → oldJA orphan 제거·portable 원장 추가 → 표적검증·독립 보존 → 마감/push.
소스 변경은 append-only proof로 수용하지 않는다. 원official header/digest와
기존 accepted/batch를 보존한다. 새 helper/checker/selftest/등록·479/481 작업0.

## 검증·경계

기존 audit_select --list로 영향 조회만 한다. EN coverage·EN 한글·JA UI·ZH all·
i18n coverage·demo scope all·story demo·locale inventory3·context/queue/diff와
정확한 runtime literal inverse/사전·원장 비소유 보존을 확인한다. 규칙/스키마/장면
변경0인 텍스트 수리이므로 엔진·전체 audit·240주·변경 없는 selftest 반복0이다.
새 실패0·비저자 의미/receipt/보존 GO 전에 완료하지 않는다.

project.godot·사용자 저장·공개 M01~M06/데모 pin·retail언어·과거 인간 판정·
옛 raw/seed/app은 비소유다. c5371ec CI는 조회 당시 in_progress/결론null,
M17/562 OS잠금 HOLD 하나이며 새 월/실제 화면/해제 재요청0이다.
gangnamdream-dev/I18N의 직접저작·정확소유·source/실관찰 분리를 적용한다.
일회성 오더 범위·새 규범 승격0. 렌더/원어민/인간/물리패드 OPEN·전체
INCOMPLETE·출시 HOLD를 보존하고 내부 수리를 출시 승인으로 확대하지 않는다.

## 마감 — 바카라 도움말 source/receipt5 한정

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame.gd:10578 FullStoryFlow 조기반환·:16142 legacy gate → :18107 casino → JeongseonCasino.gd:381–383/:831/:862/:874–880; 정상 본편·실제 ingress0 |
| 생산자 ↔ 독자 | JeongseonCasino._show_casino_glossary:831–880 ↔ _tr:63/LocaleManager.ui:212·lookup:475; 선언의 _show_glossary는 축약 오기이며 실제 함수는 _show_casino_glossary |
| 바꾸는 상태 | KO/EN literal 한 쌍·JA 설명1 교체/옛키1 제거·CN/TW 제목/설명 각2; Baccarat 규칙·배당·입력·저장0 |
| 포기 시 잃는 것 | 양쪽 natural의 9 대8 승패를 무승부라고 잘못 이해하는 도움말; CN/TW 해당 제목/설명의 EN fallback4 |
| 서사 위치 | 기존 legacy/AP 카지노 용어 UI; FullStoryFlow 신규 노출/주차/인물/서사 효과0 |
| 장면 계층 | 기존 UI 텍스트 정합; 신규 T1/T2/T3 장면·원문 장면 저작0 |
| 닫는 것 | repaired 공식 check3/import3 actual0·표적10 actual0·독립 source/receipt5 GO·보존24/24; rendered/native/Human/controller OPEN |

선언181268f6ff3c7b3d1a4359f0dd7ff3d9bb38ccea/tree
a69921c8851810463ae75ffecbcf3cd139537dd3를 먼저 commit/push했다.
source-only 실제 Git9e31ba16941157d95476a32ee258a05f2161cafc/tree
08bf660b49dc10157b8781fa50647a07b78f3386에 fresh JA1/CN2/TW2를 export했다.
source manifest는 기존9680f4d4e3106b6df3628f6796deba8a156ebe5323f3ac30c45c34abd374fb5d에서
fb4b5874205d2ae0b78872fef31e52f5ce221b6764e7e6093d6e3643823ffb83으로 바뀐다.
owned KO/EN 한 줄 역복원과 나머지 source bytes exact로 이 전이를 증명하며
옛 manifest 불변·append-only proof 수용으로 기록하지 않는다.

KO/EN은 첫 두 장 8/9·추가 드로우 없음·높은 점수 승리·동점만 무승부로 맞췄다.
Baccarat.play:48–51/:79–82 및 BaccaratTable.gd:361/:397–422가 근거이며
실제 라운드를 실행한 증거는 아니다. JA/CN/TW는 KO에서 직접 작성하고 인접 EN
노출은 공개했다. 중역/간번변환0이다. 비저자5 전수 의미 GO 후 첫 공식 JA check가
numeric actual1이었다. 원응답·원실패를 보존하고 2枚만 의미 등가 二枚로 수리해
JA 단독 재검수/recheck actual0 후 import했다. CN/TW 원check는 actual0이며
변경 없는 재실행0이다. import가 정규화한 JA 비소유 탭5는 원bytes로 복원했다.

JA 옛 설명은 unreceipted였으며 새 설명1만 첫 source-bound accepted다. 기존 제목은
불변이다. CN/TW 제목/설명 각2만 append했다. 원장 기존324batch/모든oldaccepted/
기타metadata·field order exact, accepted1/2/2와 source_change를 가진 batch325만 추가했다.
accepted JA13173/CN·TW14788씩·checksum
8a809a07127f951e571f11b0acb6341048c6314a0d8d6d33978a382e26447387이다.
원official header는 locale 선택1/2/2를 그대로 갖고 portable roots는 union2다.

표적10은 EN coverage·EN 한글·JA UI·ZH all·i18n coverage·demo scope all·
story demo·after inventory3이며 각각 실제 exit0다. before inventory3도 기존
9680 manifest에 결속했다. JA invalid57→56은 옛 natural1만 제거·나머지 exact,
UI2980/present2980·receipted480→481이다. CN/TW static2043→2045/2980·
missing937→935·receipted1963→1965·invalid[] 외 inventory exact다. source17504/
unsupported466 불변이며 ZH bypass11/shipping0·전체 INCOMPLETE/native OPEN을 유지한다.

독립 보존24/24: 제품5 전체 byte-exact inverse, 보호60그룹1152항목·비소유3363의
실제 mode/Gitblob/SHA·old581raw44 exact다. frozen final은 source9e31/dirty4/index0
시점이며 이후 마감 metadata·최종 commit/push/CI 판정과 구분한다.

원자료는 새 .git/order582-20261013/에 있으며 최종 핀은 다음과 같다.

| 원자료/제품 | Bytes | SHA256 |
|---|---:|---|
| before.json |43647|06480f37ecbf6e5c7fe9a7ca084a594955efb9e3b1d634ea8a957852db806568|
| independent-review.md |10115|f3143ac4ffddcdfbfbf11e44d5423b11cfe4acc86e1aca4e6eb33b7dde0973f3|
| final.json |32797|6e193d7fff4abf20a97c977cc3f149ed0a8354737998bc510bddce39c6473ea1|
| preservation-review.md |5902|1258a7ecbf276ef00cdb2e0a3576f25b2356b94f3d16f93198f55ede6cd7eeac|
| scenes/JeongseonCasino.gd |38993|46fb27732189940da23b3d63f52ee00db4b9adfd4a4dc3f12d711965a5551d3b|
| locale/ui_ja.json |303382|315468b3688f2de4a236008627351da8fabd38991d5dc5f4341f065c0b1b8833|
| locale/ui_zh-CN.json |197850|590bbe49c406ab5ce60f83f72dbf1d71b185ae624d2ea97fd00666ae3a1136ff|
| locale/ui_zh-TW.json |198446|04353c21e8866dc11592caf0d57706d1d424f384448c528cafcc8b88817233a2|
| content/meta/full_game_localization.json |11768698|fa20cdcdf13d45ca5a84755fc87cba1606babbde8ffebd9e338eee121d87790f|

원official receipts3는 .git/full-game-localization/{ja,zh-CN,zh-TW}/
full-ko-direct-2026-09-07.1/<각 source batch_id>.accepted.json에 있다.
canonical receipt digest JA cf58e044bd04000e6920c82fde6217a523473030638512065ffd4ffde9f6edf3,
CN a133245625f3d549edfbb5c17244e22304361c1b502cf1b489e68918836919e4,
TW 260fae5fea692e13a74035f4b096a6372aaa1ca6f54fb0400de463e8a515af37은
raw file SHA와 구분한다. full header·source/response/target·원raw SHA는 final에 결속했다.

첫 합산 읽기 잘림/없는 ui경로·private 조회·inventory group ui_static 오독/
notes patch 거부는 execution-notes에 원관찰/복구를 남겼다. 보존 검수의 TW 응답
파일명 오독은 snapshot/manifest 이전 actual1이며 메모리 경로만 정정했고 원traceback을
final에 보존했다. 성공으로 원실패를 덮지 않았다. 새 helper/checker/selftest/등록·
479/481 후속0·게임 규칙/사용자 저장/project.godot/공개데모/과거인간 불변이다.

gangnamdream-dev/I18N 직접저작·소유 보존·source/실관찰 경계를 적용했다.
일회성/승격0·자동계약은 재미/깊이/문체/사람 GO가 아니다. 실제 화면/엔진/새월/
해제 재요청0·M17/562 OS잠금 HOLD 하나·원559 W68 재개점 유지다. 렌더/원어민/
인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD·resource/Presence 잔여 유지,
기준c537 CI38322624849는 조회당시 in_progress/null이고 새push CI와 별개다.
현황판 단독후속0. 별도 진단 TutorialOverlay의 딜러17 안내와 soft17-hit 차이는
이 오더에서 고치지 않았으며 별도 후속 범위로 남긴다.

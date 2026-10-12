# ORDER-578 — 본편 10억 달성 안내의 목표 비율 오류

#### [x] ORDER-578 [정합·현지화] source 수리·번역 수용 완료 — 2026-10-13

clean main360f7c6b591fda642b04d1a11ca76ed2be536088/tree
ba814822e4b36909ecef311fcf0c298bb3269433에서 확인한 실제 표면 오류다.
사용자 위임 개발·품질 검수 및 ORDER-157의 KO 직접 현지화 원칙 안에서 처리한다.
CI38295629046 attempt1 조회는 in_progress/결론null, M17/562 OS잠금 HOLD 하나다.
새 월·엔진·실제 화면·잠금 우회/해제 재요청0이다.

## 깊이 3문·정확 범위

1. MainGame.gd:23377의 자산10억 알림은 30억 목표에 `절반 왔다`고 잘못 말한다.
   정상 _ready:398 → _refresh_all:9647 → _check_milestones:23362 경로이며
   total≥1,000,000,000·milestone1b 미수령 때 log/toast로 표시한다(:23382–23385).
   이를 빼면 거짓 진행률과 CN/TW 영어 fallback이 남는다. 실제 화면 관찰은0이다.
2. KO를 `⚡ 자산 10억 달성!`, EN을 `⚡ Assets reached 1 billion won!`으로 고친다.
   특정 목표 비율을 새로 고정하지 않고 달성 사실만 알린다. amount/id/순서/색/
   이미 받은 milestone·영수증·저장·24주 결과는 바꾸지 않는다.
3. JA 기존 `半分来た`도 같은 오류다. 새 KO키의 JA/CN/TW 각1만 직접 작성한다.
   기존 JA키는 고아 방지를 위해 제거하되 Git 원문/값·과거 원장을 보존한다.
   old key의 accepted는 세 언어 모두0, batch root0이다. 정상 도달이 확인된
   실제1쌍만 처리하며 추정15~25를 채우려고 legacy/V2 문구를 섞지 않는다.

## 소유·병렬 분리

- root: scenes/MainGame.gd 위 _tr 한 쌍만; locale/ui_ja.json 기존키 제거/새키1,
  locale/ui_zh-CN.json·ui_zh-TW.json 새키1씩;
  content/meta/full_game_localization.json 새 accepted3/checksum/UI batch1만.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, JA/CN KO 직접 저작.
- mod_layer_ci: 새 .git/order578-20261013/tw.response.jsonl·tw-draft-review.md만.
- manual_save_ci: 같은 private의 독립 source/공식receipt 전수 review만.
- rework_batch_plan: 같은 private before/final·정확 역치환/보존 review만.

기존 source와 인접 EN을 읽은 것은 공개하며 번역은 KO에서 직접 쓴다.
간번 변환0·EN 중역0. 다른 원문/값·게임상태·source code·project/presets·사용자/
공개 저장/설정·Human/과거 판정·공개데모/pin·retail언어·옛 raw/seed/app은 비소유다.
새 영구 tool/helper/checker/self-test/등록·479/481 비용최적화0이다.

## 순서·표적 검증

선언 commit/push → source 한 쌍만 별도 local commit → 실제 Git source manifest에
묶인 fresh JA/CN/TW exact1 export → 각 KO 직접 응답 → 비저자 전수 의미 GO →
공식 check/import --accept → JA old orphan 제거/원장 receipt 추가 순서다.
기존 accepted/batch 전부 보존, 원official header/digest를 portable 원장에 둔다.
source 변경은 독립 대조하고 번역 append-only/history gate로 대신 통과시키지 않는다.
현재 JSON span reader로 사전3/원장4 raw inverse, MainGame 정확1줄 inverse,
실제 source Gitmanifest·비소유/공개/사용자/옛577raw 불변을 검수한다.

audit_select --list로 영향만 조회한다. EN coverage·EN 한글·JA UI·ZH all·
i18n coverage·demo scope all·story demo·공식 locale inventory·context/queue/diff만
수행한다. source literal만 바뀌므로 엔진/컴파일/전체 audit/240주/변경 없는
self-test0이다. 새 제품 실패0·비저자 source/receipt/보존 GO 뒤 닫는다.
source/새 UI키의 hash 전이를 실제 수리로 기록하고 기존JA58를 전수오역으로 세지 않는다.

## 판정 경계

gangnamdream-dev/I18N의 직접 저작·비소유 보존·source/실관찰 분리를 적용한다.
일회성 모집단/소유/순서·새 규범 승격0. 자동 계약은 재미·깊이·문체·인간 관찰 GO가
아니다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD를 보존한다.
현재 앱에 수리가 반영됐다는 주장0이며 새 push CI는 실제 commit 뒤 따로 확인한다.
현황판 단독 후속0. 카지노 내추럴 도움말-모델 불일치는 유효 구경로의 별도 후속이며
이번 source/번역 수리에 섞지 않는다.

## 마감 — 정상 본편 달성 안내 source/receipt 한정

선언ce5dbc6a8eb639dc63d0897e2fd32ed768963b91/tree
8ef5acfb938067b61cfa62b5fbf5aa076ad9022b를 먼저 commit/push했다.
source만 local00688ab99a3ada49b0cec985cfa9a784061bcc4e/tree
ac46af7fcc59e23d6787c467b3893ee26c3b3cd6에 결속한 뒤 공식3 export했다.
불완전한 source만의 중간 push0, 번역/마감과 함께 최종 push한다.

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame.gd:398 → :9647 → :23362; source만·실제화면0 |
| 생산자 ↔ 독자 | MainGame.gd:23377 → :23382 로그/:23383 toast; locale/ui_ja.json:3063·ui_zh-CN.json:2226·ui_zh-TW.json:2226 |
| 바꾸는 상태 | KO/EN 거짓절반1쌍→달성사실; JA source이전1/CN·TW 신규1씩; gameplay delta0 |
| 포기 시 잃는 것 | milestone1b·total≥1,000,000,000·미수령 시의 정확한 금액 안내; 고정 발화주차 없음 |
| 서사 위치 | 본편 자산 보조 toast/log; chapter.beat 신규0 |
| 장면 계층 | T1/T2/T3 저작0·기존 보조UI1 |
| 닫는 것 | 정상 사용경로의 잘못된 목표비율·지역번역/영수증3; 화면/출시 GO0 |

KO `⚡ 자산 10억 달성!` / EN `⚡ Assets reached 1 billion won!`,
JA `⚡ 資産10億ウォン達成！` / CN `⚡ 资产达到10亿韩元！` /
TW `⚡ 資產達到10億韓元！`다. 기존 JA 고아키1은 제거했고 옛값은 Git와
새source_change 기록에서 복구 가능하다. old accepted3 null·batch root0이며
기존320 batch·모든 accepted를 변경하지 않았다. JA는 새coverage로 세지 않는다.

source manifest는 c13d…e19b에서 실제 Git
9680f4d4e3106b6df3628f6796deba8a156ebe5323f3ac30c45c34abd374fb5d로
전이한다. MainGame 한쌍 raw inverse/다른sourcefile exact로 독립 수리 검수했으며
append-only/history/current_proof0이다. fresh3 check/import 각1 actual0/marker1·
원official header/digest portable 보존, sourceleaf
dcd7aa5edcfc8f22673e0268c705dd465c7fbd37440c32eea9038ac0af73596f다.
receipt semantic digest는 JA de9c2f29…3684/CN ad888c5d…91a1/TW aa942f46…5794,
전체 원raw/semantic 핀은 private official-receipts.json·독립 보고서에 결속한다.
accepted JA13170→13171/CN·TW14763→14764·batch320→321, checksum
761818be532424f2a2b73eb6665cf1faa97fbfa244707f9d60d3f9d4ec2f7ebe다.

EN coverage/한글·JA UI·ZH all·i18n·demo scope all·story demo·locale별 inventory3,
표적10 명령 actual0이다. JA UI2980/2980·기존default invalid58(event10/UI48) 목록
exact·receipted478→479, CN/TW static2020→2021/2980·missing960→959·invalid[]다.
source17504/unsupported466·전체 INCOMPLETE/OPEN을 보존한다. inventory 명령0을
완료/원어민 GO로 바꾸지 않는다. 영향 selector99/named11은 목록조회만 했다.
source literal 한쌍이라 엔진/컴파일/전체audit/240주0·새 제품 게이트 실패0이다.

독립 source/receipt GO·blocker0 보고서는64줄10832B/SHA
ea2495f6356bb57438742e6644c1156aa1c6ea224b48fb974940c1dc8ddc1df0,
보존20/20 final19198B/SHA5886ca74208b06be397bc1befd8a2db77c9769e7a412e3ddf960cefa3e429c11,
보존review4344B/SHA31a3396077e03b63befb93af5b6f7112097cf69ad442552d3916cae314419ba1다.
root가 보고서2와 final 전문을 읽었다. before34534B/SHA
bc4e9f7a4b3c3548f0cb4d73bd5b0640e0e3c832b115fc55d5b8a58f46dfead1,
보호56그룹/997개·비소유3359·old577raw17·제품5 전체raw역치환 exact다.
최종 Main b95cf88d…c205/JA3a37c117…3f6/CN3a1eaf9a…8010/TW118220a0…74cc/
ledger f0f1b93f…3174의 전체 SHA·바이트는 final/review에 결속했다.

원자료는 새 .git/order578-20261013/이며 기존raw/before/helper를 덮지 않았다.
탐색 경로 오류1·준비중 보고서 읽기2·응답 patch형식 거부1(적용0)·선언전환
before assert1은 보존했다. 잘못 실행한 변경 없는 queue 자체검사1회(25/4 actual0)는
불필요 실행으로 기록하고 반복하지 않았다. queue_index 직접실행은 검사로 세지
않으며 실제 queue_consistency를 썼다. import 비소유JA 탭5는 원바이트 복원했다.
실행/오류 경계는 execution-notes.md, 실제 tool return은 *.actual.json에 보존한다.
마감 metadata의 context/queue/diff와 실제 commit/push는 이 dirty4 보존 뒤 별도로
확인하고 원최종보고서를 덮지 않는다. 현황판 단독 후속0이다.

일본어 숫자 경고58의 일부 원문 대조에서는 자연스러운 수량/공유배수 오탐을
확인했으며 전58 오역 판정0·이번수리0이다. +지원금 부호/legacy 체크카드 번역과
카지노 내추럴 도움말-모델 불일치는 별도 후속으로 남긴다. 새 범위 추가0이다.
M17 OS잠금 HOLD 하나·새월0·기존 앱 수리반영/화면0·인간OPEN45/공개GO1·
렌더/원어민/물리패드 OPEN·출시 HOLD다. gangnamdream-dev/I18N 직접저작·보존·
source/실관찰 경계를 적용했으며 일회성/승격0, 자동계약은 인간/작품성 GO가 아니다.

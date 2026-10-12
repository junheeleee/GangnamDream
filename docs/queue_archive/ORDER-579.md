# ORDER-579 — 일본어 정착 지원금의 양의 부호·임시 생존 의미

#### [x] ORDER-579 [정합·현지화] 기존값 교정·source/receipt 한정 완료 — 2026-10-13

clean main9d3ae5bb1dfb246793db2628b2fe26d153a47349에서 실제 JA 값의
`+30만원` 양의 부호 누락을 확인했다. ORDER-157/사용자 전체 번역 위임 안이다.
CI38303839800은 in_progress/결론null, OS잠금 True·M17/562 HOLD 하나다.
새 월·native·엔진·잠금 우회/해제 재요청0, source/저장/공개데모 변경0이다.

## 깊이 3문·실제 범위

1. KO `정착 지원금 +30만원이 이번 달 생존을 잠시 밀어줬다.`의 JA1399 값은
   `定着支援金 30万ウォンが、今月の生存を少しだけ先送りしてくれた。`다.
   +부호를 잃고 임시 생계 도움도 어색하다. 기존값을 방치하면 이 결함이 남는다.
2. MainGame.gd:22937 `_show_month_summary`의 subsidy 조건 :22935 뒤 label이다.
   실제 생산자는 :9015 claim → :9029 snap.subsidy → :9052 show_summary guard다.
   정상 FullStoryFlow:710은 false로 호출하므로 이 모달을 열지 않는다. legacy
   월말 모달의 표면 교정이며 정상 본편 노출·신규 번역 coverage로 세지 않는다.
3. 경제/주차/선택·24주 상태 차이0. 플레이어 결정이 아닌 기존 안내의 의미 수리다.
   한 키만 고치며 체크카드·나머지 invalid57개/카지노 도움말을 섞지 않는다.

## 소유·비소유

- root: locale/ui_ja.json 위 기존 값1만, content/meta/full_game_localization.json
  첫 accepted1/공식 receipt를 보존한 UI batch1/checksum만; 큐2/이 사양/마감
  WORK_LOG·CLAUDE 현재행. KO 직접 번역이며 인접 EN/옛JA를 읽은 사실을 공개한다.
- manual_save_ci: 새 .git/order579-20261013/의 비저자 원문/응답/receipt/delta 검수만.
- rework_batch_plan: 같은 private before/final·정확 역치환/비소유 보존 검수만.
- mod_layer_ci: 읽기전용 선행 조사. 저작/제품/검사0이다.

KO/EN/runtime·CN/TW·기존 원장/배치·project/presets·사용자/공개 저장설정·Human/
과거판정·공개demo/pin·retail언어·기존578raw/seed/app은 비소유다. 새helper/tool/
checker/self-test/등록·479/481 비용최적화0, 숫자 검증 완화0이다.

## 순서·검증

선언 commit/push → fresh official JA exact1 export(기존 target hash) → KO 직접
응답 → 비저자 전수 검수 → check/import --replace-existing --accept → 원official
header/digest/accepted1 별도 기록. 옛 값은 실제Git로 보존하고 source는 불변이다.
기존 UI3+원장4파일 raw inverse·실제Gitmanifest·옛batch/accepted·보호/비소유를
기존 pure-reader로 직접 확인한다. 기존값 수리를 append-only gate로 수용하지 않는다.

audit_select --list 영향만; JA UI·i18n·ZH all(CN/TW 비소유 보존)·demo scope all·
story demo·공식JA inventory·context/queue/diff를 표적으로 수행한다. EN 검사는
KO/EN/runtime exact와 직전578 actual0로 귀속한다. 변경 없는 self-test/엔진/
컴파일/전체audit/240주 반복0이다. 기존JAinvalid58 중 해당 부호1만 줄어야 하며
나머지 목록을 그대로 보존한다. source/receipt/보존 독립 GO 전에는 닫지 않는다.

## 판정 경계

위 파일 소유/단위/순서는 일회성·새규범 승격0이다. gangnamdream-dev/I18N의
KO 직접 저작·비소유 보존·기계/실관찰 분리를 따른다. 자동 계약은 재미·깊이·
문체·인간 관찰 GO가 아니다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·
출시 HOLD·M17 OS잠금 HOLD 하나를 유지한다. 실제 commit/새 CI는 마감 뒤
별도 private 신원으로 확인하며 현황판 단독 후속 commit0이다.

## 마감 — 기존 일본어 값1과 첫 source-bound 영수증

선언 ab4f04686615fd961a81fb19f9d5a00234634a94/tree
216ea564dab00a8ef348ba8138916be9d6cdd942를 먼저 commit/push했다.
이 source에 fresh JA exact1 export, KO 직접 저작·독립 의미 GO 뒤 공식
check/import --replace-existing --accept를 수행했다. 기존값이므로 신규 coverage0다.

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame.gd:9015 → :9029 → :9052 → :22935; legacy 정적 대조·실제화면0 |
| 생산자 ↔ 독자 | GameState.gd:2728–2736 ↔ MainGame.gd:22937 ↔ locale/ui_ja.json:1399 |
| 바꾸는 상태 | 기존 JA 부호누락1→+30万ウォン/임시도움; 첫 acceptedJA1·gameplay delta0 |
| 포기 시 잃는 것 | claim_initial_settlement_subsidy·turn≤4/미수령·subsidy 결산표시의 정확한 금액 설명 |
| 서사 위치 | legacy 월말 보조UI·새 chapter.beat0; 정상 FullStoryFlow:710 show_summary=false |
| 장면 계층 | T1/T2/T3 저작0·기존 보조UI1 |
| 닫는 것 | 기존JA1 의미/양의 부호·source-bound receipt1; 신규coverage/정상노출/화면GO0 |

새 JA는 `定着支援金 +30万ウォンが、今月をひとまずしのぐ助けになった。`다.
KO/EN·경제/라우팅/주차·CN/TW 불변이며 옛 JA 값은 실제9d3 Git에 보존했다.
export batch c098248d8da72c121ccddeb419a4d5a6283b910fca2f22dcb668ca0a088f2859,
source manifest9680f4d4e3106b6df3628f6796deba8a156ebe5323f3ac30c45c34abd374fb5d
불변이다. source SHA8cc22350…9df222/oldtarget35174466…7de56/newtarget41369f9a…0f591,
전체 header/leaf/hash는 공식 source/response·portable batch와 독립 보고에 결속했다.
원official receipt raw SHA498af6cee1b3adfc083d7493504acea2b63bc6e9c60f9cbe1a731a2fc05435a1,
semantic digest8d7c17748dd0dcce466b838cf524567b101cf511b0fd1a96f6322e3eb25fadf5다.
acceptedJA13171→13172/CN·TW14764 unchanged·batch321→322, checksum
ee39446371b7cf1e6d021fb1b1f034f7b9909bcf1a76c2c4dc3c5255c03e7bce다.

check/import 각1 actual0·marker1, 제품 표적6(JA UI·i18n·ZH all·demo scope all·
story demo·공식JA inventory) actual0다. default JA invalid58→57은 지원금1만 제거,
UIstatic present2980 불변/machinevalid2932→2933/receipted479→480다. 직전578와
전체 inventory exact compare에서 이 변화 외 모든 값 exact·source17504/unsupported466
불변이다. remaining57을 전수오역으로 판정0·INCOMPLETE/OPEN 유지다. KO/EN/runtime
exact와 직전578 EN2 actual0로 귀속하고 변경 없는 EN/엔진/전체audit/self-test 재실행0다.

독립 source/receipt 보고32줄7966B/SHA
12b26e04ec9ee12d62ff7e8626f0beaab7aee1e90cf5cc8709cca536f3e33ff7,
preimport21줄4092B/SHA46116f5f…bc9013 prefix exact다. 보존19/19 final13573B/SHA
28a0a43ebe592dc20c4302195a143f98cdd15de7eb9a8200ce22a3a92451f007,
보존review5022B/SHAe571a95862f72d6c4928962c562515a595108369dd2733e873f6ea6645e27205다.
root가 보고서2 전문과 final JSON 모든 필드를 파싱해 체크/경계/핀을 확인했다.
before40432B/SHAb8200a6b87f067c1b65b29e61159adebf7c92e9482e4b8eb4598d90421fe6016,
보호57그룹/1037개·old578raw40·비소유3363 actual Git mode/blob/digest exact다.
JA303332B/SHA295822f096a7981fe921d284aec5c1959e356e3c92302d02ea29967760187c8d,
ledger11742770B/SHA38ac5631d8a1dd82a4e3266eea4021b6a2a2afada7aa6e0cd7b5e5a69bad1189,
CN/TW 전체raw unchanged·4원본 exact inverse·옛321batch/모든accepted exact다.

원자료는 새 .git/order579-20261013/다. check는 독립 preimport 작성과 병렬로
실행한 비변이 검사이고 import는 실제 GO 메시지 뒤였다. capture에는 실행시각이
없으므로 독립 시계 계측으로 쓰지 않는다. import의 비소유 JA 탭5는 원복했다.
ledger patch형식 거부1(적용0) 뒤 header만 고쳤고, 독립 private 판독문 괄호누락1은
Python 실행 전 종료·원출력 final에 보존했다. 잘못된 탐색 경로/준비중 보고 조회는
검사 통과로 세지 않았다. 기존 raw/helper/도구 변경0·append-only/history 수용0다.
마감 metadata는 이 dirty2 보존 이후 별도로 context/queue/diff와 실제 Git를 확인한다.

규범 문장은 일회성·승격0이다. gangnamdream-dev/I18N의 KO 직접 저작·비소유 보존·
source/실관찰 경계를 적용했다. 자동계약은 재미·깊이·문체·인간관찰 GO가 아니다.
CI38303839800은 기준9d3 조회 당시 in_progress/null, 새 push CI는 별도 확인한다.
M17 OS잠금 HOLD 하나·새월/실제화면/엔진/잠금해제 요청0·인간OPEN45/공개GO1·
원어민/렌더/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD·현황판 단독후속0이다.

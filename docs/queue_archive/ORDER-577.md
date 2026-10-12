# ORDER-577 — 일본어 경마 전적의 출전·승리 의미 교정

#### [x] ORDER-577 [현지화·UI] source 교정 완료 — 2026-10-13

ORDER-157의 전체 번역 위임 안에서 KO `0전 0승`의 기존 JA 값 하나만 고친다.
기준 clean main b8021277db6a7791901fd399967193e6f762930a/tree
856eb38b25f4e69b663c5c776b53b6e0e6d82c6d다. CI38289392492 attempt1은
조회 시 in_progress·결론 null이다. M17/562는 OS잠금 HOLD 하나, 새 월0이다.

## 깊이 3문·범위

1. RaceTrack.gd:456의 `horse.record` 부재 fallback은 출전0/승리0인데
   ui_ja.json:150의 `0勝0敗`는 승리0/패배0을 말한다. KO에서 `0戦0勝`으로
   직접 교정한다. HorseWorld.gd:119의 `%d전 %d승`/`%d戦 %d勝`는 이미 맞다.
2. 선택·효과·가격·정산·24주 결과·저장은 바꾸지 않는다. 현재 상태 설명이다.
3. 정상 HorseWorld는 record를 생성하므로 방어적 대체 문구 수리 한정이다.
   실제 정상 노출·새 번역 coverage·월별 실제 관측으로 세지 않는다.
   하나의 확인된 의미 결함을 15~25 추정에 맞춰 늘리지 않는다.

## 소유·비소유

- root: locale/ui_ja.json 위 기존 값1개, content/meta/full_game_localization.json
  해당 첫 accepted 또는 기존 receipt 교정·checksum·별도 ui_correction batch1만.
  기존319 batch/공식 receipt는 보존하고 previous target hash를 새 기록에 결속한다.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, KO 직접 저작.
- manual_save_ci: 새 .git/order577-20261013/의 독립 의미·공식 영수증 보고만.
- rework_batch_plan: 같은 새 private before/final 보호·정확 역치환 검수만.

KO/EN/CN/TW·runtime·source manifest·조건/효과/플래그/가격·project/presets·
사용자/공개 저장/설정·Human/옛 판정·공개데모/pin·retail 언어·옛 raw/seed/app은
비소유다. 새 영구 tool/helper/checker/self-test/등록·479/481 비용최적화·전체
audit/240주·엔진/컴파일/native/새 월0이다. OS잠금 우회/해제 재요청0이다.

## 수용·검증

선언 commit/push → fresh 공식 exact1 export → KO 직접 응답 → 비저자 의미 검수 →
check/import --accept --replace-existing 한다. 이전 target hash·source/새 target·
원official header/digest를 별도 correction 기록으로 묶고 기존 이력은 보존한다.
기존키 수정은 append-only proof로 통과시키지 않는다. 기존 JSON span parser와
Git blob로 정확1값+원장 owned delta만 역치환했을 때 before 전체 바이트 복원을
독립 검수하고 비소유/보호/옛576 raw 불변을 확인한다. 새 helper는 만들지 않는다.

named full-game-localization-overlays 차선은 목록만 조회한다. 영향 표적은 JA UI·
i18n coverage·demo scope all·story demo·공식 JA inventory·context/queue/diff다.
ZH 및 EN/한글은 직전576/575 actual0와 CN/TW/KO/EN/runtime byteexact로 귀속한다.
기존 verifier·collector 불변이므로 변경 없는 self-test/전체 감사는 반복하지 않는다.
새 실패0·비저자 source/receipt/보존 GO 뒤 source 교정만 닫는다.

## 판정 경계

원어민·렌더·인간·물리패드 OPEN·전체 번역 INCOMPLETE·출시 HOLD 유지.
현재 앱에 이 교정이 들어갔다고 주장하지 않는다. 실제 commit/push CI는 별도
확인하고 현황판 단독 후속0이다. gangnamdream-dev/I18N 직접 저작·비소유 보존·
source/실관찰 분리를 적용한다. 모집단/소유/검증 일회성·새 규범/승격0이다.
자동 계약은 재미·깊이·문체·인간 관찰 GO가 아니다.

## 마감 — 기존 JA1 의미·공식 영수증·보존 한정

선언78a0a252ea5af460626993354c0a43ffa464901b/tree
775e8bf29d99080976c43c0efef3b265adf4ae07을 먼저 commit/push했다.
기존 `0勝0敗` → `0戦0勝`만 KO 직접 교정했다. 인접 EN과 기존 중국어 노출은
공개하며 중역0이다. 정상 HorseWorld record는 이미 생성되므로 정상 노출·
화면 개선·새 번역 coverage로 세지 않는다. runtime·KO/EN/CN/TW 불변이다.

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | JA_UI scope ui actual0·legacy2951/2951/context29/29/errors0; 실제 렌더0 |
| 생산자 ↔ 독자 | locale/ui_ja.json:150 ↔ scenes/RaceTrack.gd:456 → :459; _tr:84–85 |
| 바꾸는 상태 | JA 기존값 0勝0敗 → 0戦0勝; accepted13169→13170/batch319→320; 게임 상태 변화0 |
| 포기 시 잃는 것 | RaceTrack.record 부재 fallback 출전/승리 의미; 발화 주차 고정 없음 |
| 서사 위치 | 본편 경마 보조 UI; chapter.beat 신규0 |
| 장면 계층 | T1/T2/T3 장면 저작0·기존 방어적 UI1 |
| 닫는 것 | JA 전적 의미 결함1·첫 source-bound receipt1; 화면/native/출시 GO0 |

fresh exact1 export → 비저자 의미/header/response GO → 공식
check/import --accept --replace-existing 각 actual0/marker1을 마쳤다.
체크/import 응답은 stdout/stderr 별도 스트림이나 전체 실행시간을 보존하지 않아
별도 stderr0/시간 주장0이다. import가 정규화한 비소유 탭5는 원래 바이트로
되돌린 뒤 정확1값 diff·4파일 raw inverse로 확인했다.

기존 accepted exact ID는 없었다. 원legacy commit
aaeba142d08278c310505000bcc126a699493479과 이전 target SHA
dbf842667ffa4803bbbc5eb2b9360b3e32703d442e1868db5cdb113e4291d93f를
별도 ui_correction batch에 보존했다. 새 target SHA
0c15c1d5da6d9b1c357ec69326ec255669b69307075ba4a4e9025014f52251fc,
source SHA084306613ad63eea22eee5981b0ba6429cd72d270bf11d0ebdca37333b4a8c23다.
원batch 6f7ba207faee532935af65d28fee9775641bb2a910bb8914152f27669fbf3b8a의
header/source_revision을 그대로 보존하고 원official accepted raw SHA
a0d8a05fc2dfcc8f199c4277f797b35ebb21e8b195561b16849ed5ffc3b4ab77 /
semantic receipt SHA5f75cd54c0a96013df3073b5548233f3c3a6ec9b3b754e0d35c3fd63da64668b다.
CN/TW accepted14763씩 불변, checksum
16f894881d757d0d64a23462dc6f85613e4de24c7bd9a9ec75b0dbfe506a374f다.

표적 JA UI·i18n coverage·demo scope all·story demo·공식 JA inventory 5명령
actual0이다. fresh 전후 inventory invalid58(event10/UI48) 전체 목록 exact,
UIstatic2980·valid2932/invalid48 불변·receipted477→478이다.
전체 INCOMPLETE/OPEN을 명령 성공으로 숨기지 않는다. EN coverage/한글 및 ZH는
직전575/576 actual0와 KO/EN/runtime/CN/TW byteexact로 귀속·재실행0이다.
named lane11은 목록 조회만 했으며 self-test/전체 audit/엔진/컴파일/새 월0이다.

비저자 source/receipt GO·blocker0, review40줄8616B/SHA
45705cab756d774e026758eca9f9ca3914c6a24d1561f377fea1a04325a47e01다.
독립 보존은 제품2 dirty 시점 캡처17/18에서 보조 source-hash 기대값 false1을
남겼다. KO문자열 단독 digest 대신 기존 Leaf.source_sha256의
{path,field,ko} 정의로 pure read 정정PASS, 제품/원receipt/검사 변경이나
snapshot/collector 재실행0이다. 탐색 중 없는 선택 파일 경로의 읽기 오류도
성공으로 바꾸지 않는다. 새 제품 게이트 실패0이다.

JA1값+원장 owned3span 역복원 시 4원본 전체 바이트 exact·old319batch/
oldaccepted/order/다른 metadata exact, 보호55그룹980개·비소유3361·old576raw29
불변이다. 실제 Git source manifest
c13d47f56851ab9f26567d53a53db1f13e39d5931881f8f1bd2c7ab91a71e19b와
source17504/unsupported466 불변이다. append-only validate_append/current_proof0다.
before37647B/SHA114f372284281a73ab94c23dfc1e41df85dfe68f932dd952d1c98a18cf9ef877,
final14081B/SHAd5c55f5e8f4e0f71f355af3964b46abfeff365417c4c3d8627d22e99d772be88,
preservation review3804B/SHA995d146937fd98acb77142a7191559b717b828030eb640438f56a04ff302e643다.
root가 두 review와 final 전체를 읽었다. 원자료는 새 .git/order577-20261013/다.
최종 JA303345B/SHA96eb48194eddd4487488b784a2eb6703f1063390a8ea6fe6868771ae66a04f8a,
원장11735380B/SHA866b19ff450deb7706ae7e3aaad8095aa4469da99752a54990a57ea8e05d22fd다.

마감 metadata context/queue/diff와 실제 commit/push 신원은 root가 별도로
확인하며 제품시점 보존 보고를 덮어쓰지 않는다. 기준b8021277 CI38289392492는
조회 시 in_progress/결론null·새 push CI와 별개다. M17/562 OS잠금 HOLD 하나·
해제 재요청0·수정 앱 빌드/화면0·인간 OPEN45/공개GO1·렌더/원어민/물리패드 OPEN·
전체 INCOMPLETE·출시 HOLD를 보존한다. gangnamdream-dev/I18N 직접 저작·보존·
source/실관찰 경계를 적용, 일회성/새 규범 승격0·현황판 단독 후속0이다.

# ORDER-580 — 첫 월급·투자 거래 조건 안내 중국어

#### [x] ORDER-580 [현지화] 조건부 안내 CN/TW 수용 완료 — 2026-10-13

clean main01140a9cd51e1e4aa78c3f65af82811524ef1c93/tree
bbd98ab0c05e6ae8b9d6c9256fb0a2aeabe17545의 실제 CN/TW 누락1키다.
ORDER-157/사용자 전체 번역 위임 범위다. CI38309378791은 조회 당시
in_progress/null·OS잠금 True·M17/562 HOLD 하나다. 새월/엔진/native0다.

## 깊이 3문·소비자

1. KO `첫 월급 수령! 투자 거래 조건을 갖췄습니다`의 CN/TW 값·accepted는
   모두 없다. 방치하면 해당 조건에서 준비언어 UI가 EN fallback으로 표시된다.
2. FullStoryFlow 소유 MainGame:709–710의 월말 → :9032 이전급여 여부 →
   GameState:1690–1691 payable_income>0 → MainGame:9042 false→true 및 :9044
   guidance true → :9045 _tr/:9046 toast → :6505–6508 → NotificationToast:27–28
   label이다. show_summary=false는 모달만 건너뛴다. guidance 생산3은
   arc_events:512/527/539, MainGame:7839–7843 직접선택과 :6952–6955 full-run
   비압축 경로다. random draw 비활성 표식과 직접선택을 혼동하지 않는다.
3. 급여 이후 guidance를 봐도 이 toast가 소급되지 않는다. 실제 시점/빈도/
   후속장면과 화면 겹침은 미관찰이다. 투자 실행·이익·순현금 증가를 보장하지
   않는다. 선택/효과/24주 결과 차이0·실제 안내 번역이며 새 행동이 아니다.

## 정확한 소유·비소유

- root: locale/ui_zh-CN.json·locale/ui_zh-TW.json에 위 신규1씩, content/meta/full_game_localization.json
  accepted CN/TW각1·공식 receipt header/digest의 UI batch1·checksum만.
- mod_layer_ci: 새 .git/order580-20261013/tw.response.jsonl·tw-draft-review.md만.
  KO에서 독립 작성한다. root가 공식 export 뒤 파일 소유를 넘긴다.
- root: 같은 private CN response/draft와 큐2/이 사양/마감 WORK_LOG·CLAUDE 현재행.
- manual_save_ci: 새 private 독립 KO/응답/공식receipt 전수검수만.
- rework_batch_plan: 새 private before/final·4원본 exact inverse/비소유 보존만.

KO/EN/runtime·기존JA·CN/TW옛값/원장/배치·project/presets·사용자/공개 저장설정·
Human/과거판정·공개demo/pin·retail언어·옛579raw/seed/app은 비소유다. CN/TW는
KO에서 각각 작성·중역/간번변환0, 인접 EN/JA/기존CN/TW 노출은 숨기지 않는다.
검사/helper/tool/self-test/등록 변경·479/481 비용최적화0다.

## 순서·검증·판정

선언 commit/push → immutable before → fresh official CN/TW exact1 export →
독립 KO 직접 저작·비저자 전수 GO → official check/import --accept → 원official
header/digest/accepted의 portable 원장 추가다. 기존 ui_translation_append의
4파일 pure validate_append·raw inverse와 실제Git source census를 쓴다.
기존 helper 재사용·새 영구 도구0, 기존322batch/모든accepted를 exact 보존한다.

audit_select --list 영향조회만; ZH all·JA UI(비소유)·i18n·demo scope all·story demo·
공식CN/TW inventory·context/queue/diff 표적이다. EN은 KO/EN/runtime exact와
직전578 actual0로 귀속한다. CN/TW static2021→2022/2980·missing959→958·invalid0,
JA57 unchanged·source17504/unsupported466/manifest9680…fb5d 불변이어야 한다.
새실패0·독립 의미/receipt/보존 GO 전 완료0·전체audit/240주/엔진/self-test 반복0다.

규범·소유·단위·순서는 일회성/승격0이다. gangnamdream-dev/I18N 직접저작·
비소유 보존·기계/실관찰 경계를 따른다. 조건부 소스소비자와 실제노출 GO는
별도다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD·M17 OS잠금
HOLD 하나를 유지하고 실제 commit/CI는 마감 후 별도 private에 기록한다.
현황판 단독후속0·자동계약은 재미/깊이/문체/인간관찰 GO가 아니다.

## 마감 — 첫 월급·거래 조건 안내2의 source/receipt 한정

선언9d8f8ec95276d76f53e9aa6f4f835d1c6567c918 뒤 제품변이 전에 사양의
TW 제품파일명 누락만 b82958d8d2e0cf7fd0c80e0efd5a582926291907로 명시했다.
같은 source/targethash의 fresh export2를 유지·원문변경/재export0다.

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame.gd:710 → :9032/:9042/:9044 → :9045/:9046; 조건부source·실제겹침/화면0 |
| 생산자 ↔ 독자 | GameState.gd:1690–1691·arc_events.json:512/527/539 ↔ MainGame.gd:9045 → NotificationToast.gd:28 |
| 바꾸는 상태 | CN/TW 누락각1→수령/거래조건충족 각1·accepted각1·gameplay delta0 |
| 포기 시 잃는 것 | first-paycheck false→true + guidance true 때 해당 준비언어 안내; 고정 발화주차 미확정 |
| 서사 위치 | 정상 월말 조건부 보조toast·새chapter.beat0·선택/효과0 |
| 장면 계층 | T1/T2/T3 저작0·기존 보조UI1 |
| 닫는 것 | 조건부source UI1×2locale/receipt2; 실제노출·렌더·전체번역·출시 GO0 |

CN `领到第一笔工资！已满足投资交易条件`, TW `領到第一筆薪水！已符合投資交易條件`
는 locale/ui_zh-CN.json:2227·ui_zh-TW.json:2227이다. guidance 이후의 급여가 아니라
첫 급여 당시 guidance=true인 조건만 말한다. 뒤에 guidance를 봤다고 소급 안내하지
않으며 계좌 입금/순현금 증가/실제 투자/수익/미래 성과를 보장하지 않는다.
최초 CN `到账` 지급수단 과잉한정 REWORK1을 수리한 뒤 2/2 의미 GO를 받았다.
원response865B/SHA92a7e601…e25b와 최초HOLD/수리이력은 보존했다.

official CN/TW check/import 각1 actual0·marker1, 원receiptheader/digest/accepted2를
UI batch1에 portable 보존했다. source9d8f8ec·manifest9680…fb5d·leaf source SHA
bcf1712d1a25e2bf53c455b61cda400f9dc196a9b706001fe5868c77b4be5495 불변이다.
원semantic receipt CN cff374ded336a24459098b1261d7c022016cbfbe568ca2e6d25d077437d831b0,
TW9a9f6f89a1cab2b362c42daee86303fa5ae22ea49eb0a1cb9ea1817fa7a1539c다.
rawSHA/전체header/targetSHA는 official-receipts.json과 독립 보고에 결속했다.
acceptedJA13172 unchanged/CN·TW14764→14765·batch322→323, checksum
 a38e81448d914ad2153830c3fccad69ebea3e182bb6c8628cfd2a7b0eaae4009다.

표적8(ZH all·JA UI·i18n·demo scope all·story demo·CN/TW officialinventory·
기존4file validate_append) actual0·새제품실패0다. 기존appendproof는JA0/CN1/TW1·
receipt2/batch1·4raw exact inverse다. 각 static2021→2022/2980·missing959→958·
receipted1941→1942·invalid[] 외 전체inventory exact, source17504/unsupported466
불변이다. JA전체raw/KO/EN/runtime exact·직전578 EN2 actual0로 귀속·재실행0다.
영향목록31은 조회만·전체audit/엔진/240주/self-test 반복/새helper·tool·등록0다.

독립 source/receipt 보고44줄10743B/SHA
2b75d322a9c638b7fc376128bd673c36239e48c2af22a6d8068ee465b8ea4d23,
preimport7036B/SHA25c061c0644eaba615b4e0a26dec8d98a7a9ea66bb254d3d270bb997d65713c9
prefix exact다. 보존24/24 final28382B/SHA
1f1c980539469cb6a7561664199f0bd70ae1cf277dacdbe4b06601e2b5f6f549,
보존review6768B/SHAde05c354721c3a6d965b7fd842469852d2992f9a3b2c21b33992b92b1c95ad47다.
root가 보고서2 전문과 final JSON 모든 필드를 파싱·체크/경계/핀을 확인했다.
before38023B/SHA2283c2afcceefb6bf31bb00e1465bbaab89239b60675a08a03bb6d3d7a67d7ea,
보호58그룹/1068개·old579raw31·비소유3363 actualmode/blob/filedigest exact다.
옛322batch/모든accepted·JA raw를 보존하고 4원본을 byte-exact로 역복원했다.
최종 CN195752B/SHA39bef78c604d50d3f28fba6142420c59d5dac28975e36e6db66ddade7d995209,
TW196328B/SHA9228026e2201b599302733b5fb206ab64f9d7e0b55d2011dd324c192eb5c57bc,
ledger11746175B/SHAd9cba0294ec4a42a69028376ffd504a325c0e2f8d40f2310860de5b900f8e47b다.
Git source 결속은 sealed579 실제manifest와 실제Git source외delta·current source exact·
root census로 확인했으며 독립 collector/별도manifest 재계산0이다.

원자료는 새 .git/order580-20261013/다. 초기합산 부팅출력 잘림은 작은 청크로
완독복구했다. 독립판독 completion:null 처리 실수1은 snapshot 전에 종료했고,
메모리 size요약 TextEncoder 오류1은 file I/O 전에 종료했다. 보조 old579 비교false1은
relative+kind 대 absolute/kind없음의 스키마 차이였다. 같은 실제snapshot 지문과
31개 모집단/58그룹 결합지문 exact로 정정·원false/스키마/사유를 final에 보존했다.
새스냅/기존도구/옛raw 수정·제품결함 은폐0다. 마감metadata/실제Git/새CI는 이
frozen dirty3 관찰 뒤 별도 확인하며 현황판 단독후속0이다.

일회성/승격0·gangnamdream-dev/I18N KO 직접저작·비소유 보존·source/실관찰 경계를
적용했다. 자동계약은 재미·깊이·문체·인간관찰 GO가 아니다. 실제 첫급여/guidance
겹침·시점·지속·줄바꿈/원어민/인간/물리패드 OPEN, 전체 INCOMPLETE·출시 HOLD다.
M17 OS잠금 HOLD 하나·새월/native/엔진/해제 재요청0·인간OPEN45/공개GO1 유지다.
기준01140a9 CI38309378791은 조회당시in_progress/null·새push CI와 구분한다.

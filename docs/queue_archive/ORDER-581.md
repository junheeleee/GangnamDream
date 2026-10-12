# ORDER-581 — 구저장 주간 도입의 시간·거처 중국어

#### [x] ORDER-581 [현지화] 주간 시간·거처 CN/TW 수용 — 2026-10-13

ORDER-157/사용자 전체 번역 위임. 기준 clean main377606e540ce9f4dc70ad490566a70188697b4f2.
MainGame.gd의 `_week_scene_anchor`(11711–11767) 21키(시간4·거처소리16·조립1),
CN/TW 각각 누락21·기존accepted0만 번역한다. 실제 본편 새 월/원문 저작이 아니다.

## 깊이 3문·소비자

- 방치하면 구저장 주간 도입 시간·거처 묘사가 EN fallback이다.
- `_render_ap_actions`:10578의 full-story 조기반환 및 scene_first:10601–10607
  뒤의 legacy 본문:10615 → `_week_opening_line`:11690 → anchor:11711,
  :10646 `_type_text`다. 정상 FullStoryFlow 노출로 세지 않는다.
- 주차1~4와 presentation housing이 기존처럼 시간/소리 한 쌍을 선택한다.
  gangnam→apartment/unknown→gosiwon 폴백 유지. 새 선택·상태·24주 효과0이다.

## 소유·순서·검증

- root: locale/ui_zh-CN.json·locale/ui_zh-TW.json 신규21씩,
  content/meta/full_game_localization.json accepted42/UI batch1/checksum만.
- root: 이 사양·큐2·마감 WORK_LOG/CLAUDE 현재행, 새 .git/order581-20261013/
  CN source/response·공식교환/검사 원자료. TW source는 root export 뒤 전달한다.
- mod_layer_ci: 새 private tw.response.jsonl·tw-author.md만 KO 직접 저작.
- manual_save_ci: 새 private independent-review.md만 비저자 전42 의미/receipt 검수.
- rework_batch_plan: 새 private before.json·final.json·preservation-review.md만 보존 검수.

선언 commit/push → immutable before → 공식 exact21 export2 → 독립 KO 저작/
비저자 전수 GO → check/import --accept → 원receipt header/digest 원장 추가 →
기존4파일 validate_append(raw inverse)·ZH all·JA UI·i18n·demo scope all·story demo·
CN/TW inventory·context/queue/diff. 영향목록은 audit_select --list만 쓴다.
원문/런타임 불변으로 EN은 직전578 actual0에 귀속하며 불필요 재실행0이다.

KO/EN/runtime/JA/기존값·원장·저장·project.godot·공개demo/pin·인간/옛판정·
옛raw/앱/seed 비소유. 새helper/tool/checker/self-test/등록·479/481 후속0이다.
템플릿 {moment}/{detail} 순서·소리 원인/횟수·집 종류 의미를 보존한다.
15~25단위의 자연스러운 기존 함수 묶음21이며 표본 대신 전수 검수한다.

규범/파일소유/단위/검증은 일회성·승격0. 자동계약은 재미/깊이/문체/인간 GO가
아니다. source/receipt만 닫고 렌더/원어민/인간/패드 OPEN·전체 INCOMPLETE·출시
HOLD 유지. CI38315970393은 조회당시 in_progress/null, Mac잠금true/M17 HOLD1·
새월/엔진/native/해제 재요청0. 새실패0/독립 GO 전 완료0·현황판 단독커밋0이다.

## 마감 — legacy source/receipt42 한정

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame.gd:10578/10601 조기반환·:10615 legacy → :11690/:11711 → :10646; append actual0/raw_inverse4 PASS·실제 ingress0 |
| 생산자 ↔ 독자 | MainGame.gd:11711–11767 ↔ LocaleManager.gd:212–250/461–500; 공식21×2 response=사전=receipt42 |
| 바꾸는 상태 | CN/TW static2022→2043/2980·missing958→937·receipted1942→1963·invalid[]; 선택/효과/상태0 |
| 포기 시 잃는 것 | _week_scene_anchor 시간4/거처16/조립1×CN/TW; week index0..3; EN fallback42·실제 발화 미관찰 |
| 서사 위치 | MainGame.gd:11689–11767 legacy 주간 도입; FullStoryFlow/scene_first 신규 노출0 |
| 장면 계층 | 기존 UI; 신규 T1/T2/T3 장면·원문 저작0 |
| 닫는 것 | 공식 repaired check2/import2 actual0·표적8 actual0·독립 의미/receipt42 GO·보존24/24; rendered/native/Human/controller OPEN |

선언352ec4c 뒤 큐 펼침 순번 오류를4a4f671로 제품변이 전에 정정했다.
source revision4a4f6713fe12f1f767d972a8bdf9511749de17e4/tree
89bb36ed7b8afd04c34465dc44f1c613d8b872f7, manifest
9680f4d4e3106b6df3628f6796deba8a156ebe5323f3ac30c45c34abd374fb5d 불변이다.

CN/TW는 KO21을 각각 직접 작성했다. 인접 EN 노출 공개·중역/간번변환0이다.
독립 전42 검수에서 일요일 저녁의 해질녘 좁힘2를 REWORK했고, 최초 CN GO철회/
HOLD 및 원응답을 보존했다. 첫 공식 check2 actual1(엘리베이터 一声/一聲 미인식)은
그대로 보존하고 CN1/TW2를 의미 등가 一次로 수리했다. 체커 변경0이며 전42
재검수 GO 뒤 repaired check/import4 actual0다. 성공으로 원실패를 덮지 않았다.

기존323batch/모든accepted/사전원값·JA 전체raw 불변, 4원본 byte-exact inverse다.
accepted CN/TW각14786/JA13172 unchanged·batch324·checksum
dbb0bba38256e132eed75afc395e777b361e7ed73fa485dc6c7d35343ef27358이다.
CN/TW inventory는 static+21 외 전체 exact, source17504/unsupported466 불변이다.
ZH skeleton의 direct_english_bypass11/shipping0을 전체판 준비 완료로 바꾸지 않는다.

원자료는 새 .git/order581-20261013/이며 핀은 다음과 같다.

| 원자료/제품 | Bytes | SHA256 |
|---|---:|---|
| before.json |52089|10ea64a4cebab679cc856b6da3ae08af3509825190ba8bcea4e76cf5975268c0|
| independent-review.md |17941|280cb44f39d2b7d07774d515a6830d9108b7c7ca4ec36acaac640878835a5d98|
| final.json |35240|d683d85a1e4aec3fecf0d91f0a2611a6c657abae5f36db1fa2b6ad778fd9e3e7|
| preservation-review.md |6030|4839cd3266117c257c1604fb42f0612e929b187ad1c69bec494664e785966cbb|
| locale/ui_zh-CN.json |197489|fb1b64d8b1c6f389ef1249f295d0a106975afa55630fd54a7e88b52994eb1ec8|
| locale/ui_zh-TW.json |198080|5a9a4be500b10114d35a049acc74c54ab78f22d3471108a82fa488439a9d0c61|
| content/meta/full_game_localization.json |11762174|7376b8eed935133528bebe0ff1e6b953a91ee70dcdcfcbc818e56cf2e111a17b|

원공식 receipt2는 .git/full-game-localization/{zh-CN,zh-TW}/full-ko-direct-2026-09-07.1/
아래 각 source batch_id.accepted.json이다. 원raw SHA CN3f36ac5a…23cc74/
TW20665934…21bc9e와 semantic digest CN6b0e4d52…991747/TWcb3ed073…86e77c를
구분하며 전체핀은 final.json에 있다. 보호59그룹1108/비소유3364/old580raw40 exact다.
final은 metadata 이전 frozen dirty3이며 이후 마감문서·실제commit/push/CI는 별도다.

합산 읽기 잘림·없는 파일명 조회·OS잠금 조회/JSON field 오독·미생성final 조회는
새 execution-notes에 원관찰/복구를 남겼다. 독립 string hash의 jq raw오독과 inventory
record wrapper오독도 각 보고에 보존·기존 정의로 정정했다. 제품결함/검사수리0이다.

일회성/승격0. gangnamdream-dev/I18N KO 직접저작·비소유 보존·source/실관찰
경계 적용, 자동계약은 재미/깊이/문체/인간관찰 GO가 아니다. 렌더/원어민/인간/
패드 OPEN·전체 INCOMPLETE·출시 HOLD·M17 OS잠금 HOLD 하나다. 엔진/새월/native/
해제 재요청0·공개GO1/인간OPEN45 보존·현황판 단독후속0이다. 기준377 CI는
조회당시 in_progress/null이고 이번 새push CI와 구분한다.

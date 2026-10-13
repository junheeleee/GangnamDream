# ORDER-583 — 블랙잭 소프트17 튜토리얼 오안내

#### [x] ORDER-583 [정합] KO/EN 도움말 source 수용 — 2026-10-13

기준 clean main1effdf283de766e05bfbd0d432ab67a2041e8994/tree
bd9fdcee3675c85a9fcec5bbcbb2d6af6a3a05ef. 582의 실제 소스 진단을 잇는다.
TutorialOverlay:126/139가 17 이상 항상 정지를 안내하지만 Blackjack.dealer_play:
69–75는 soft17 hit·hard17/18+ stop이며 BlackjackTable:543도 같은 H17 규칙이다.
사용자 위임의 확인된 정합 결함 수리이지 밸런스/정본 규칙 변경이 아니다.

## 깊이·소비자·정확 소유

1. 방치하면 A+6에서 딜러가 더 받는 실제 동작을 플레이어가 오류로 이해한다.
2. BlackjackTable:94/237/597 → TutorialOverlay._get_slides(blackjack) →
   _localized_slide:45–50의 전체 raw body lookup → _show_slide 본문 라벨이다.
   현재 입구는 legacy/AP 카지노이며 정상 FullStoryFlow/실제 화면 GO가 아니다.
3. 선택/효과/24주 상태는 불변이다. 설명만 기존 H17 정산과 일치시킨다.

- root 제품: scenes/TutorialOverlay.gd 해당 KO/EN 안내 literal 한 줄씩만.
- root metadata: 큐2·이 사양/마감 archive·WORK_LOG·CLAUDE 현재2행.
- manual_save_ci: 새 .git/order583-20261013/의 비저자 source/review만.
- rework_batch_plan: 같은 새 private before/final/보존 보고만.
- mod_layer_ci: 같은 새 private의 전체본문 키·CJK/collector 경계 검토만.

KO는 A를11로 세는 soft17에서 더 받고 그 밖의17 이상 정지, EN은 같은 의미다.
BBCode pair/행·문단/기타 본문·슬라이드·아이콘/표시 흐름·모델·배당은 불변이다.
실측 안내1단위이며 15~25를 채우려고 다른 미니게임을 섞지 않는다.

전체본문이 lookup key다. 현재 JA/CN/TW에는 해당 옛 body가 없고 기존 provider는
Holdem4키만 등록한다. 이 source-only 수리에서 지역 번역·원장 수용·coverage 증가를
주장하지 않는다. 미등록 Blackjack 본문/지역 번역은 별도 후속이다. 사전3/원장은
전부 exact로 보존하고 새 source변경을 append-only proof로 수용하지 않는다.

## 순서·검증·한계

선언 commit/push → immutable before → KO/EN2 literal 수정 → 비저자 전수 source
대조/같은 모델 반례 → EN coverage/EN 한글/i18n/JA UI/ZH all/demo scope all/
story demo·공식 JA inventory 전후 → exact2 inverse·나머지 tracked/저장/옛증거
독립 보존 → context/queue/diff·마감 commit/push. 영향 조회는 기존 --list만이다.
동적 core_loop_v23장·Holdem4키·public M01~M06/pin은 바꾸지 않는다.
새 실패0·독립 GO 전 완료0. 텍스트2줄만이므로 엔진/전체 audit/240주/
변경 없는 selftest/새 helper·checker·등록·479/481 후속0이다.

project.godot·사용자 저장·옛앱/seed/raw·human/공개 GO·retail언어는 비소유다.
skill/I18N의 소유 보존·source/실관찰 분리를 적용한다. 일회성/승격0,
자동 계약은 재미/깊이/문체/사람 GO가 아니다. Maclocktrue·M17/562 HOLD 하나·
새월/해제 재요청0·기준 CI38327756051은 조회당시 in_progress/null이다.
렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD·종료resource/Presence
잔여 유지, 새push CI 별도 확인·현황판 단독후속0이다.

## 마감 — KO/EN 도움말 source2줄 한정

| 완료 증거 | 측정값 또는 file:line |
|---|---|
| 도달 경로 | MainGame:16142/:18107 legacy/AP → JeongseonCasino:705–715 → BlackjackTable:94/:237/:597 → TutorialOverlay:24–50/:822–829; 정상 FullStoryFlow/실제 ingress GO0 |
| 생산자 ↔ 독자 | TutorialOverlay:126/:139 raw body ↔ LocaleManager.ui:212–221/lookup:475–482 → cleanup → body label; 조각 번역 아님 |
| 바꾸는 상태 | KO/EN literal 한 줄씩만; 규칙·모델·배당·선택·저장·사전3·번역 원장 불변 |
| 포기 시 잃는 것 | A+6 soft17에서 실제로 더 받는 딜러를 무조건17+정지라고 오해시키던 안내 |
| 서사 위치 | 기존 legacy/AP 블랙잭 도움말; 정상 본편 노출·주차·인물·서사 효과 추가0 |
| 장면 계층 | 기존 UI 텍스트 정합; 신규 T1/T2/T3 장면·산문 저작0 |
| 닫는 것 | 표적8 actual0·비저자 source2/2/locale경계 GO·독립 보존25/25; 렌더/원어민/인간/패드·출시 GO0 |

선언08a2dde447dd7eb5d5fc3c111ea272729cb20d7d/tree
8f1826b94d3ec05be3ac898d8ed8112155f93e4d를 먼저 commit/push했다.
immutable before 뒤 KO126/EN139만 바꿨으며 frozen TutorialOverlay는
39507B/SHA e6f267dc8d5fd3057fffe026344f739161fef440db1f33a7505e4646562feb7b다.
두 literal 역치환 시 원39388B/SHA2e2d7be146ab124f2ee076e70a694510240b641c813e06dd2a3a71e2c5cf2b4d가
전체 byte-exact다. A+6 draw·10+7 stop·A+7 stop은 Blackjack:35–49/:69–75와
BlackjackTable:402/:543의 source 반례이며 라운드를 실행한 증거가 아니다.
BBCode pair/newline·주변 본문·슬라이드·lookup/cleanup/display는 불변이다.

표적8은 EN coverage·EN 한글·i18n coverage·JA UI·ZH all·demo scope all·
story demo·공식 JA after inventory로 각각 actual0다. before inventory도 actual0다.
selector --list는25개를 조회만 했고 실행0이며 변화 없는 selftest/엔진/240주0이다.
공식 inventory 전후는 source manifest만
fb4b5874205d2ae0b78872fef31e52f5ce221b6764e7e6093d6e3643823ffb83 →
98664e3985186e7173cfa8cde576aec6136f41f756cf185699d5020cd81177cb로 바뀐다.
나머지 모든 JSON값·17504잎/unsupported466/JA invalid56·target 결과는 exact다.
manifest를 역치환하면 inventory 원12850259B도 exact다. 전역 source 불변이나
append-only 번역 수용으로 기록하지 않는다.

수정 전후 전체 KO body/title은 built-in JA/CN/TW에서 모두 부재다. collector는
Holdem4키만 명시 지원하므로 Blackjack 본문을 새 잎/영수증/coverage로 세지 않는다.
새 EN fallback은 규칙에 맞지만 지역 번역 수용0·provider/body 번역은 별도 후속이다.
사전3/원장325batch·accepted JA13173/CN·TW14788씩·checksum은 exact로 보존했다.
community pack/실제 표시 언어는 관찰하지 않았다.

독립 보존25/25는 제품2줄 inverse·보호61그룹1196항목·비소유3368의 실제mode/blob/SHA·
old582raw44·사전3/원장/모든 accepted·inventory 전이를 확인한다. final 실측은
01:16:18Z의 선언HEAD08a2/tree8f18·source/CLAUDE/queue2 dirty4/index0이며
소유 metadata·최종 commit/push/새 CI와 구분한다. 큐2는 기준1eff bytes로 복원한다.

원자료는 새 .git/order583-20261013/에만 보존했다. before.json은40885B/
SHA6da493aed89a551773bcb56ca5501bb6faa7a31eec18fed76ad39e8bf74b504f,
source-review.md는3031B/SHA1b904714fec97004c12c3c974c886515a1c098fd301af08db3b702124efa0f1c,
locale-consumer-review.md는13531B/SHA0255e7eebad65ef5fab164f0df60de22c5680e97b697f6b4a6c105eb135ebb3d다.
final.json은17312B/SHA1bfffc86f59103f66924d1c45b2e0020e4f74d1cd4b4f3e46064da2b2680f9bc,
preservation-review.md는5343B/SHA293e79db7342143c947f1fdf376be0944a8ed81258cae629576255880f2feeb4다.
공식 before/after inventory raw SHA는 c554f6885f16b55f24bd1ec8b27a85da9f3fae1279d253a4f44f11e0837db63a /
d10e170ea6b32588d83ef025c95439ad96d7dd81d656b80d2f7e1925dae0ddad다.
targeted.actual.json에 실제 exit/output, execution-notes와 각 보고서에 잘못된 경로/
출력 잘림/조기 미생성 보고 조회/보조 판독 오류 및 정정 근거를 남겼다.
오류를 제품 실패나 통과로 바꾸거나 옛 raw를 덮어쓰지 않았다.

gangnamdream-dev/I18N의 파일 소유 보존·source/실관찰 분리를 적용했다.
일회성/승격0·새helper/checker/등록/엔진/월0·project.godot/저장/공개데모/사람 이력 불변이다.
긴 문장 줄바꿈·렌더·원어민·인간·물리패드 OPEN, 전체 번역 INCOMPLETE·출시 HOLD,
M17/562 OS잠금 HOLD 하나·해제 재요청0·종료resource/Presence 잔여를 유지한다.
기준1eff CI38327756051은 조회당시 in_progress/결론null이다. 새push CI는 별도로
한 번 확인하며 같은 head 재조회/취소/재실행·STATUS 단독후속0이다.

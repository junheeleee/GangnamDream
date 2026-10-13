# ORDER-583 — 블랙잭 소프트17 튜토리얼 오안내

#### [~] ORDER-583 [정합] KO/EN 도움말 착수 — 2026-10-13

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

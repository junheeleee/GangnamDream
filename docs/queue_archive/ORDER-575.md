# ORDER-575 — 구저장 현황 화면 중국어 누락

#### [x] ORDER-575 [현지화·호환 UI] 번역 수용 — 2026-10-13

ORDER-157의 전체 번역 위임 안에서 아래 KO18키의 CN/TW 누락36개만 채운다.
기준 clean main ed4448d8fb45e39ba9824fca35217f120a7068f9/tree
49143938bf525280043970cac18f2e47acaf5205다. 해당 push CI38249242676
attempt1은 2026-10-12T17:11:05Z 조회에서 두 job/모든 step success다.
MANUAL_SAVE/MOD_LAYER/compile/KO·EN input/SimRun/Smoke marker를 확인했지만
종료 resource ERROR4줄(2/3/1/1)을 보존하며 strict-clean/출시 GO로 쓰지 않는다.
원자료 .git/heartbeat-20261012-1653/ci-status.json SHA
46f4ae203d50492fe6215aa4ca9c4ec0442bb8efc413f108e774ec47bc81f21b다.
M17/562 하나만 OS잠금 HOLD·새 월0·잠금 해제 재요청0이다.

## 깊이 3문·소비자

1. 번역을 빼면 유효한 구저장 V2 확정계획의 현황 화면이 EN으로 폴백한다.
   Continue/compatible load→persisted enabled W1~24→non-Seoul/non-episode
   saved plan→CoreLoopPlanner 현황 버튼→_open_info_view(0)→tab0→
   _build_status_surface→LocaleManager.ui라는 현재 표시 독자가 있다.
2. 기존 재정·보유·발견 상태를 설명할 뿐 선택/24주 결과/저장을 바꾸지 않는다.
   투자 gate와 발견 flag, 미보유·미체납을 번역에서 새 사실로 만들지 않는다.
3. 같은 현황의 label/empty/place18키만 묶는다. 공유 키의 다른 기존 caller도
   regional hit가 되므로 공식 원문 문맥을 함께 본다. 정상 본편 노출 누락,
   새 월 플레이·공개 story_demo_rc 변경이나 휴면 기능 부활로 세지 않는다.

| exact KO key | CoreLoopPlanner.gd caller |
|---|---:|
| 현황 | 767 |
| 지금 상태 | 1751 |
| 현재 날짜 | 1761 |
| 계좌 잔액 | 1764 |
| 다음 고정비 | 1767 |
| 체납 | 1770 |
| 없음 | 1772/1776 |
| 대출 원금 | 1774 |
| 월 수입 | 1778 |
| 투자 현황 | 1783 |
| 보유 내역 | 1791 |
| 현재 시세 | 1794 |
| 발견한 장소 | 1800 |
| 알게 된 곳 | 1802 |
| 확인할 시세 없음 | 1848 |
| 경마장 | 1855 |
| 홀덤 클럽 | 1857 |
| 카지노 | 1859 |

## 소유·비소유

- root: locale/ui_zh-CN.json·ui_zh-TW.json 위 신규키와
  content/meta/full_game_localization.json accepted/checksum/UI batch1.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, CN KO 직접 저작.
- mod_layer_ci: TW KO 직접 초안/private response만, tracked 편집0.
- manual_save_ci: KO18↔target36/공식 receipt/공유 caller 독립 전수 검수.
- rework_batch_plan: before/final 비소유 보존·4파일 exact inverse 검수.

KO/EN/JA·runtime/조건/효과/플래그·검사/collector·source manifest·project/
presets·공개 데모/pin·출시언어·사용자/공개 저장·설정·Human/과거 판정·
옛 raw/seed/app 비소유다. 새 tool/checker/self-test/등록·479/481 검증비용/
재사용 최적화·엔진/컴파일/실제입력·전체 audit/240주·새 월0이다.

## 수용·마감 게이트

선언 commit/push 뒤 공식 export/check/import --accept로 신규 잎만 처리한다.
JA 존재·CN/TW previous null·protected=false를 확인한다. KO에서 지역별 독립
저작하며 root의 인접 EN 노출은 공개하고 중역·간번 자동변환0이다. 원receipt의
header/digest를 portable batch에 보존한다. 기존 accepted/batch/사전 prefix,
JA 포함4파일 exact inverse와 실제 source manifest를 기존 verifier로 대조한다.
표적 ZH/JA UI·i18n·EN coverage/한글·데모·원장·context/queue/diff를 검증한다.
동일 source의 선행 검사 귀속은 기록하고 변경 없는 자체검사를 반복하지 않는다.
새 실패0·독립 의미/receipt/보존 GO 뒤 번역 수용만 닫는다. 실제 화면/원어민/
인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD를 보존한다.

강남드림 개발 스킬과 I18N 정본을 적용한다. 이 모집단·소유·검증은 일회성,
새 규범/승격0이다. 자동 계약 통과는 재미·깊이·문체·인간 관찰 GO가 아니다.
## 마감 — 구저장 호환 현황 UI source 번역 한정

선언2cbbc389b760159f5507b1ab647c2a22d67c2f9b/tree
1fe3012f1a2a4128f7d1198ca7d2a71b56cb1afb를 먼저 commit/push했다.
KO18키를 CN/TW 각각 독립 직접 저작해 공식 export/check/import --accept했다.
각 check/import actual0·비저자 의미/receipt36 GO·blocker/수정권고0이다.
중역/간번 변환0이며 root의 인접 EN 노출은 공개한다.

| 완료 증거 칸 | 실제 값 / 소비자 |
|---|---|
| 도달 경로 | 유효한 legacy V2 saved-plan → MainGame:1533 → CoreLoopPlanner:2448 → :1739 → :1749; native0 |
| 생산자 ↔ 독자 | locale/ui_zh-CN.json:2206 / ui_zh-TW.json:2206 ↔ CoreLoopPlanner:767 / :1751~1859; 체납·경마장 공유 caller도 source 검수 |
| 바꾸는 상태 | 선택 KO18의 CN/TW target null36 → 문자열36; accepted14743→14761씩·JA13169 불변 |
| 포기 시 잃는 것 | 현황·재정·투자·발견 장소18키의 지역어 lookup; 구저장 호환 화면 한정 |
| 서사 위치·계층 | 기존 상태의 읽기 전용 요약; 새 장면/선택/조건/효과/플래그0 |
| 닫는 것 | 번역36/원receipt2/UI batch1; 렌더/원어민/인간/물리패드 OPEN |

실제 source manifest는
c13d47f56851ab9f26567d53a53db1f13e39d5931881f8f1bd2c7ab91a71e19b 불변이다.
원receipt의 header와 semantic digest(CN
03afffef172c7f7e69be55f057e348b957cffa0234d1e5bbe737e397813b5280 /
TW 53361099ffded1f64004974c881b9e5cfa187fdefdd7c4cc22f3a6a4c7e378a9)를
portable batch에 그대로 보존했다. accepted checksum은
b15db709879ec0dbab1bc80f132d2c578f1bf3fde0e63ece9a10410736c45209다.
기존 accepted/317batch prefix·JA·원장 다른 metadata는 불변이며 batch318이다.

| 제품 파일 | bytes | SHA256 |
|---|---:|---|
| locale/ui_zh-CN.json | 195510 | 5ff942829abaeebd6d48715730a661b9103847ff66a540b7dc459fbee85d7b39 |
| locale/ui_zh-TW.json | 196077 | eedc6785455e99f9cedb78f629f24c6618a744fccae3679d8246f81828c7623b |
| content/meta/full_game_localization.json | 11729270 | f0cf1db8ced366146f190ffacec12baeede925ac23792d263fcf29148fec6e18 |

표적9명령 actual0: ZH all skeleton·JA UI·i18n coverage·demo localization all·
story demo·공식 CN/TW inventory·EN coverage·English zero-Hangul이다.
CN/TW inventory 각각 invalid0, UIstatic2018/2980·missing962·receipted1938이다.
전역 INCOMPLETE/OPEN·dynamic missing549는 남으며, 이 분모는 정상 본편 노출률이 아니다.
EN2는 CN import 시점 actual0 뒤 KO/EN/runtime 불변으로 귀속한다.
변경 없는 자체검사·전체 audit/240주·엔진/컴파일·실제 입력·새 월0이다.

비저자 source/receipt 보고는 .git/order575-20261013/independent-review.md
11579B/SHA0d05e80a33859a95badf41091f8d285772f5c5907cfdcf996d8024c6dd94616e다.
기존 validate_append로 JA 포함4파일 exact inverse·receipt36·batch1 PASS,
fresh 보호53/915·old574raw27·비소유3358 실제 Git mode/blob exact다.
before의 queue2 dirty 상태를 clean으로 쓰지 않았고 제품4의 Git exact와 구분한다.
선언 큐 순번0으로 최초 queue_consistency FAIL1을 냈으며, 새 항목 포함 연속
순번으로 고쳐 actual0(active79) 후 마감에서575를 제거해 기존 순번을 복원했다.
원장 첫 apply_patch는 표준 hunk header 형식 오류로 적용0, 형식 정정 뒤 적용했다.
미생성 private 검토파일 조회 오류는 생성 뒤 전문 판독으로 해결했다.
보존 보조 비교의 옛 기대 SHA/JA count·행 순서 false는 실제 before SHA·counts·
같은 Git3358 집합으로 정정했다. 제품/receipt/helper 수정·게이트 재실행0이다.
도구/metadata 오류를 숨기거나 제품 실패·strict-clean으로 바꾸지 않는다.

공식 batch/response·check/import log·targeted-start/completions2·inventory2·
독립 의미/보존 원자료는 .git/order575-20261013/와 공식 private receipt에 보존한다.
선행 CI38249242676/ed4448d는 두 job/모든 step success지만 resource ERROR4줄
(2/3/1/1)을 보존한다. 이번 push CI와 구분하고 재실행/취소·현황판 단독 커밋0이다.
강남드림 개발 스킬/I18N의 직접 저작·비소유 보존·source/실관찰 분리를 적용했다.
모집단/소유/검증은 일회성·새 규범/승격0이다. 원문/runtime/저장/데모/Human
보존, 실제 M17/562 OS잠금 HOLD 하나·새 월0·해제 재요청0·전체 출시 HOLD다.

root는 독립 의미 보고91줄과 preservation-review.md 전문3557B(SHA
8d647b016337fc5fbc1513827a78f0133f27eba6bb7b99a8c66a1925f3bf015e),
preservation-final.json 전문14990B(SHA
6d65101fc73612bdc8cff1c24b18e2b11a30a768cf10610749d1d8b907ad821b)를 읽었다.
보조 false3의 원값/정정과 dirty capture·후속 metadata 경계를 확인했다.
마감 metadata는 선언 소유 파일만 직접 diff로 검수하며 context/queue/diff를
최종 확인한다. 실제 commit/tree·first-parent·push·새 CI는 private 신원으로
별도 확인하며, 본 증거를 새 CI·실제 관찰 GO로 확대하지 않는다.

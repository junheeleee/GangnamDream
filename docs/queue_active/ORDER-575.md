# ORDER-575 — 구저장 현황 화면 중국어 누락

#### [~] ORDER-575 [현지화·호환 UI] 착수 — 2026-10-13

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

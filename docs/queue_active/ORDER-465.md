# ORDER-465 — 투자 시장 탭의 중국어 안내

#### [~] ORDER-465 [P1·현지화] 시장 상태·계좌·가격 움직임16키를 읽는다

**[~] 착수 — 2026-10-05.** 부모157. JA16키는 존재하고 CN/TW 사전·accepted에는
모두 없다. 한국어에서 간체·번체 각각 직접저작16값, 합32값의 한 배치다.
이전464 허브와 교집합0이며 신규원문/게임규칙/collector/source adapter 변경0이다.

## 정확한 원문·소비자

모두 `scenes/MainGame.gd`의 기존 `_tr`이다.

| KO key | 줄/의미 |
|---|---|
| 상승장 / 하락장 / 횡보장 | 18839 / bull·bear·neutral 각1키 |
| 급락 경보 켜짐 / 급락 경보 없음 | 18884 / crash_risk>0.08 분기 각1키 |
| 공포 / 탐욕 | 18897·18898 / draw_string·fallback_font·11px 각1키 |
| 내 계좌 | 18916 / 계좌 요약 제목 |
| 평가 %s | 18919 / 보유의 현재평가액, 원금 아님 |
| 수익률 %+.1f%% | 18920 / 현재평가액 대 매입원가 비율 |
| 보유 자산 없음 | 18925 / total_now≤0 분기 |
| 소액 분산부터 | 18926 / 기존 문안, 신규 투자조언 추가0 |
| 시장 움직임 | 19193 / market 탭 제목 |
| 변동폭이 큰 자산 4개 | 19194 / 절대변동폭 내림차순 최대4개 |
| 가격 기록 축적 중입니다. | 19206 / 적어도2기록이 있는 자산 없음 |
| 보유 %s | 19329 / 그 자산의 보유평가액, 수량 아님 |

실제경로 pressure invest→_ap_invest→_open_investments→시장탭→market reader.
처음은 안내와 '투자 데스크 열기'를 거친다. cash%s/공통탭은 기수용·비소유이며
MARKET BOARD/NEWS 고정영문은 별도채무다. 화면전체중국어완료로 세지 않는다.
없으면 상태·평가액·기록 안내가 영어폴백이다. 선택/24주상태는 불변이며 간결함과
부호/정밀도/금액·수량 구분이 경쟁한다. `%s`, `%+.1f%%`, 숫자4를 보존한다.

## 소유·순서

- root 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 정확16키씩,
  `content/meta/full_game_localization.json` 신규32accepted/공식receipt2batch만.
- claude_handoff_review: private `order465-cn-draft.json`만; receipt_tests392는
  `order465-tw-draft.json`만. KO직접 저작이며 상대초안을 중역하지 않는다.
- independent392: 전수32값·실제reader·수용/기준선증거 읽기와
  `docs/agent_reviews/ORDER-465.json`만. root만 공식교환/검사를 실행한다.
- root 기록: 이사양→archive·큐/L3순번·CLAUDE현재행·WORK_LOG·생성STATUS·판정원장.
  WORK_LOG 예산을 위해 기존전체를
  `docs/history/WORK_LOG_2026-10-05_pre_order465.md`에 byte-exact 보존한 후 새로그를
  시작한다. private `.git/full-game-localization/order465-*` 교환/helper/증거만 추가.
- 공식 export→check→독립KO대조→import의 writer만 apply_patch출력으로 연결한다.
  원검증은 그대로이며 원header/selection/receipt digest를 수용원장에 복사한다.
  예상CN/TW1785→1801·accepted41773→41805·batch233→235·JA3053불변.

## 이번 append만 표적 검증하는 조건

기준선은 실제464 clean `dd1c3915f7cb6c9e9c609ee35dc071269893ad99`와
`.git/full-game-localization/order464-normal1/result.json` SHA
`32cac4131de86ecb8b5b3b1cc0f83fb3b98c457a98ced7ee4fa773ab56aa446b`다.
그안의 exit/marker/logSHA·입출력 전체3141파일/코드/50 admission과 보호맵을 봉인한다.
과거365는 이때 PASS의 재사용이며 **465에서 현재365/전체history는 NOT_RUN**이다.

1. baseline4raw를 실제Git에서 읽고 recorded SHA와 결속한다. baseline부터 새후보까지
   first-parent 계보와 실제diff를 확인한다. 비소유3138의 원문·code·collector/provider·
   source census는 모두불변, 문서변경은 위 정확소유경로/464마감기록만 허용한다.
2. 새16키는 baselineCN/TW와accepted에 없고, `validate_append`로 현재4raw의 전체
   역상·member/order·옛batch·신규32source/target·2공식header/selection/null prior를
   검증한다. validation helper를 수정하지 않는다. correction/기존값변경이면중지한다.
3. 공식export revision의 실제ancestor/Git census를 `_source_manifest`로 확인하고
   fresh `collect`의 hash전체/digest·464의9f4e35c5 manifest와 결속한다. append검사만으로
   source_revision의 실제원문 증명을 대신하지 않는다. 최종disk=Git·전후동결도 확인한다.
4. ZH 기본1회·신규32전수검수·context/queue/human/STATUS/diff로 마감한다. provider/
   코드/원문/기존번역이 달라지면 이경로는 적용불가이며 새검증범위를 선언한다.
5. 기존365/전체selftest/full-body/JA·EN/엔진/240주/패키지는 반복하지 않는다.
   이전PASS를 새명령실행으로 적지 않으며 근거파일/SHA/후보를 분리한다.

실제렌더·물리입력·원어민은 NOT_RUN. 특히 공포/탐욕은 draw_string이므로 Label
문자 수집만으로 글리프·잘림을 판정하지 않는다. Mac잠금중GUI0, 과거화면GO상속0.
완료는32값 의미·공식수용만; 149/457/302runtime·본편/출시HOLD 유지.
자동통과는 재미/문체/사람/출시GO가 아니다. 기존I18N/WORK_UNIT 적용이며 위16키와
정확불변baseline 재사용 조건은 이번 한배치 지시다. 새정본 규칙·허용완화0이다.

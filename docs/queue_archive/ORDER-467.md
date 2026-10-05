# ORDER-467 — 투자 AP 부족 안내의 잘못된 월 단위 제한 수리

#### [x] ORDER-467 [P1·정합] 현재 행동력 부족을 월간 거래 금지로 안내하지 않는다

## 2026-10-06 완료 — 기존 수리의 누락 표적 검수

- 제품3쌍은 `621f559` 그대로다. 이번 변경은 focused 검사1개·안전한 검사 등록·운영 기록뿐이다. 사전/수용원장·GameState·거래규칙·project·저장·공개·과거 판정 변경0.
- private `.git/order467-20261006.TvAKAz/runtime1/result.json` SHA `332fa036f6094cb3200c12556d3126bf667dfeaac99b19dbf31b9b50f5615083`: clean `c53acfc`/tree `ac315ea1`에서 fresh pre-autoload 준비30+주복원5, 실제 exit0/7.030720375초. 두 로그 exact 모집단/오류0·보호57·tracked3194 전후동일.
- `checks2/result.json` SHA `e4a077c9c5344037cabc8ef3031fcc334386d7532908718df15d2bec465e7f66`: clean `1d03209`/tree `f331f4cc`, actual7/7 exit0/stderr0/714.8963725초. focused80/0·JA UI2981 beta 오류0·EN/한글누출0·scope208·context·queue. 실제 fresh 종료와 source/runner/log/보호/재사용원본 전후동일이다.
- 472 final1의 실제 fresh365/현재 UI수용결속/ZH는 입력3181개와 결과·원로그30의 SHA 동일성을 확인해 재사용했다. 472의 JA demo를 JA UI로 바꾸지 않았으며 위 JA UI는 이번 실제 실행이다. 전체365/240주 재실행 주장은 없다.
- 최초 `checks1`은80중2 실패/실제exit1이며 result SHA `ecee1a665aaf436016761fa400673ff62259f2bf122fbd0162b7362e0370db77`로 보존한다. CN/TW 영수증의 raw UTF8 기대값을 기존 canonical JSON digest로 맞췄다. 전체 과거행 equality/검사 모집단은 유지했다. 비격리 `.tscn` 자동등록1개를 제거하고 root 사전격리 실행만 남겼다. 긴 부팅 주석의 예산 실패도 짧은 현재행으로 수리했다.
- 독립 [보고](../agent_reviews/ORDER-467.json)의 한정 GO는 source `1f4a84d91bc1f2de2fd6bcf6409a101f585d4f8d`/tree `19c6f1b2fec0fd84730f0b33a3ef278d83a046d0`다. 마지막 검사 후보 이후 CLAUDE 현재행 외 제품/검사 입력 변경0. 이후 고정 metadata wrapper만 붙인다.
- L2 도달: `INVESTMENT_AP_COPY_CHECK_OK cases=30 locales=5 weekly_restores=5`; 생산자 `GameState:2397`↔독자 `MainGame:18279,19821,19867`; AP0 거부15/상태7 불변→같은2026/M03 W1→W2/AP0→2 복원5→거래 probe 도달15. 새 선택·포기 비용·서사 장면/계층은 N/A(UI 피드백), 닫는 것은 월간 금지 오안내3쌍이다.
- TradeProbe는 실제 체결이 아니며 toast/modal도 관찰용 대체다. fixture는 언어만 되돌리며 전체 GameState 복원을 주장하지 않는다. 새 격리 공간에서만 실행했다. 자연진입/화면/원어민/물리패드/본편 출시 GO는 아니다. 472 화면0/6·기존 인간 HOLD는 보존한다. 자동 통과는 재미·깊이·문체·사람 승인이 아니다.
- 규범 승격0: 기존 WORK_UNIT/I18N/격리 계약 적용, 본 오더의 선언·증거 재사용·마감 절차는 일회성이다. 아래는 원래 착수/계획 이력이다.

**[~] 착수 — 2026-10-05.** 466 소비자 검수에서 확인한 별도 결함이다.
제품은 `scenes/MainGame.gd`의 일반매수·매도·레버리지 매수 안내3쌍만 바꾼다.
동작·숫자·키/저장 스키마를 바꾸지 않고 기존 다국어 안내를 재사용한다.

## 2026-10-06 재개 — 구현 보존, 누락 검증 마감

현재 clean `7fa758b`에서 제품3쌍은 `621f559`에 이미 반영되어 있다. 뒤 PR31/469의
Main 후계와 기존 지원4파일·준비 fixture2파일도 보존한다. 같은 수리를 다시 쓰지 않는다.
이번 파일 소유는 root가 이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING(순번만)·audit_scope·CLAUDE현재행·WORK_LOG·STATUS·판정원장,
order469_main이 새 `tools/investment_ap_copy_self_test.py`, order469_review가 새
`docs/agent_reviews/ORDER-467.json`이다. order469_history는 기존 이력/증거의 읽기 검수만 한다.
기존 제품·지원·fixture·사전·수용원장의 변경은0이다. private runner/결과는 root만 작성/실행한다.

이력 소비자 검증은 최근472의 실제 `c9130be` final1 기본365 입장·JA/ZH 결과를
입력 집합과 원로그 SHA가 현재와 일치하는 범위에서 재사용한다. 새 검사/등록과 운영문서 외
제품·collector 입력은 불변이어야 하며, 과거 결과를 현재 재실행이라고 부르지 않는다.
일치하지 않는 검사는 좁혀 실제 실행한다. EN은 가벼운 현재 검사를 실행한다.
누락 focused static/반례와 fresh pre-autoload 30거래 probe·5주복원은 이번에 직접 실행하고,
기존 fixture의 고정 성공문구뿐 아니라 두 로그의 exact 모집단·실제 exit·보호57/입력 전후맵을
확인한다. 실제화면/자연입력/체결·원어민·물리패드·출시 HOLD는 그대로다.
이 절은 아래의 이전 담당명과 기본검사 재실행 계획만 갱신하는 일회성 마감 지시다.

## 원인과 정확한 범위

- `_on_leverage_buy:18287`, `_on_buy_asset:19829`, `_on_sell_asset:19875`의
  nonpending `spend_ap()` 실패 안내가 `행동력이 없습니다. 이번 달 거래 불가` /
  `No Action Points. No trading this month.`다.
- GameState:2349는 현재AP<1만 검사한다. MainGame:8730→6298 및 GameState:1428,
  :3627은 주 전진/같은 달의 AP 복원이 가능함을 보인다. 별도 월간거래금지 상태는 없다.
- 새문구는 기존 `_tr("행동력이 없습니다", "No Action Points")`다. JA사전은 존재하지만
  accepted는 없고, CN/TW는 사전·accepted가 이미 있다. 새 번역/영수증을 발급하지 않는다.
- 옛 긴 JA키는 사전 바이트 그대로 남기되 제품 consumer는0이 된다. 기존 retained 패턴으로
  정확한 한 값만 역사 보존한다. 다른 미사용키를 포괄 허용하지 않는다.
- AP0 투자 진입/패드목록은 차단되고 마우스 거래버튼은 현금/보유로 활성화된다.
  따라서 준비된 AP0 방어 분기 검증을 자연 플레이 도달이나 실제 입력 관찰로 부르지 않는다.

깊이3문: 잘못된 기간 안내는 같은 달의 다음 주 거래 가능성을 오해하게 한다.
선택 결과/24주 상태는 불변이다. 짧은 실패 피드백은 원인 전달과 경쟁하므로 확인하지 않은
월간 제한·성공·회복 시점을 덧붙이지 않는다. 별도 금융/밸런스 설계는 하지 않는다.

## 파일 소유와 순서

선언 commit/push 뒤에만 구현한다. 실제 Main3쌍 제품commit을 먼저 만들어 불변 Git 핀을
얻고, 이에만 결속한 기존 현지화 provenance/consumer 후계를 지원한다. 지원 미완료 후보를
완료 또는 출시 GO로 부르지 않으며 실제 검증 완료 묶음만 원격 main에 정리한다.

- root 제품: `scenes/MainGame.gd` exact3쌍. 나머지 파일전체 역상 일치가 필수다.
- claude_handoff_review: `tools/main_game_locale_history.py`, `tools/ui_translation_append.py`.
  실제 currentGit/Main 핀과 exact3 역상·부모/나무/객체·옛 단계 불변을 증명한다.
- receipt_tests392: `tools/ja_translation_pipeline.py`, `tools/ja_translation_audit.py`.
  실제 함수3 selector 재결속·호출수 동일/고유키−1·JA exactretained1만 지원한다.
  과거 pipeline 바이트 seal·기존 inventory 의미와 snapshot을 보존한다.
- root 표적 검사: 새 `tools/investment_ap_copy_self_test.py`,
  `tools/InvestmentAPCopyCheck.gd`, `.tscn`, 필요시 그 `.gd.uid`, `tools/audit_scope.json`.
  테스트만을 위한 분기나 예외를 제품에 넣지 않는다.
- independent392: `docs/agent_reviews/ORDER-467.json`만 비저자 전수·실행증거 판정.
- root 기록: 큐·이사양→archive·CLAUDE현재행·WORK_LOG·생성STATUS·신규판정행.
  private `.git/full-game-localization/order467-*`의 runner/결과는 root만 실행한다.

사전3개와 full_game_localization 원장/기존receipt 전체, Gameplay/GameState/가격/AP/거래,
project.godot·export preset·player/public/seed·과거 보고/판정·인간 원장을 바꾸지 않는다.
비슷한 '다음 달' 문구는 별도 조사 대상이며 이3쌍에 몰래 추가하지 않는다.

## 검증 계획

1. old/new 세 소비자의 문구·조건·호출 순서·다른 바이트 전체를 비교한다. 기존 짧은 문구
   다국어 값·LeafID/hash/CN·TW수용핀과 사전/원장 전체 bytes가 변하지 않아야 한다.
2. 새 focused 검사로 exact3 역상, 비소유 변경·누락/중복·잘못된 KO/EN/함수·핀 거부,
   실제 selector/current inventory·JA retained 및 기존 4raw 보존을 검증한다.
   새 검사 등록/diff/context/queue/human/생성STATUS도 포함한다.
3. root가 실제 pre-autoload `StoryNameplateBootstrap`의 fresh namespace에서만 headless
   fixture를 실행한다. 실제 Main handler와 GameState를 쓰되 toast/modal 관찰부와 거래
   mutation은 test probe로 분리한다. KO/EN/JA/CN/TW의 AP0 세거래 거부·상태/자산 불변,
   같은 달 W1→W2/AP복원 뒤 거래함수 도달을 확인한다. probe는 실제 체결/화면 증거가 아니다.
   pending 분기는 전체원문 불변으로 묶으며 새로운 pending 시나리오를 발명하지 않는다.
4. source/collector 지원이 바뀌므로 이번에는 clean 현재후보에서 기본365 admission1회와
   JA/ZH 기본·한영 커버리지를 각각 실행한다. exact marker/exit/두로그 오류·tracked/보호57
   전후맵을 확인한다. 과거 fullhistory/selftests전체/240주/전체audit/패키지는 반복하지 않는다.
   현재full365와 과거466의 append증거를 서로 대신하지 않는다.

오류와 실패 산출물은 보존한다. 원문/code 차이가 생긴466기준선의 전체SHA 불변을 가장하지
않고 새 actualGit source census를 기록한다. 새로운 범용 우회·화이트리스트·영수증 재발급0.
Mac잠금중GUI0, 실제toast/잘림/물리패드/원어민/자연진입/출시 미관찰·HOLD는 유지한다.
자동PASS는 계약증거이며 재미·깊이·사람승인은 아니다. 기존I18N/WORK_UNIT 적용,
새규범 승격0·exact3 교정과 이번 검증 조건은 일회성이다.

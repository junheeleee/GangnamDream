# ORDER-383 — 중국어 투자 첫 안내·공용 상단

[x] 2026-09-28. 독립 work_unit 한정 GO. 본편/새package GO가 아니다.

- 최종 source `453eeb4bd0911c21fc4f18107e268bf2f7d25b89`, tree `869285e7aee15532aa22e70aa0b6add3d340be48`. [독립 보고](../agent_reviews/ORDER-383.json) SHA `5a34278ec21a8cb26f41d638acf9ec488160a7b308bcfbef23ad10561bab5c81`.
- KO 직접 간체27·번체27 새값과 공식 영수증54. JA/원문/runtime 불변. 공식40,886·b152는 후속384 교정batch1을 포함한다. 첫 검사에서 번체 제목의 일본어 구분점1을 중점으로 바꿔 번체 check만 재시도했다. 첫6PNG 전체FAIL은 보존하고 후속384의 중립포커스6PNG로 안내·상단·용어 제목54 binding만 수용했다.
- 383 static11검사/조회1 PASS. 384 static12검사/조회1 PASS (330.564s), UI_TRANSLATION_APPEND_FEE_CORRECTION_OK cases=46. 격리 실제화면 14.469s·6PNG·54lookup/binding·raw입력0. 소스/실사용자34파일 보존. 원래383 전체FAIL과 실패 관측은 그대로 남는다. 빈 카드8개는 비표시컨테이너로 font/glyph N/A·자식문자/경계 엄격검사 유지. 중립focus는 fixture일 뿐이며 CN선택CTA 약3px 테두리 잘림은 미수리다.
- 기존145판정/123보고·공개GO1·인간OPEN45·원어민/물리OPEN을 보존했다. 본편/새package HOLD, 외부출시/스토어/지출/법률행위0. 자연 AP 진입·정산·새입력·전체플레이 관측0이다.
- 승격 없음: 기존 I18N 규칙 재사용. 모집단·소유·표적계획은 일회성이다. gangnamdream-dev의 선행선언·파일분리·독립검수·격리실행을 적용했다.

## 최초 선언 원문 보존

# Active Queue Spec: ORDER-383

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-383 [P0·전체 현지화] 중국어 투자 첫 안내와 공용 상단 27키를 읽게 한다

2026-09-28 착수. 부모157, 기준 main `a0b0d9d`. 선언 커밋 뒤 구현한다.
302는 source GO 뒤 별도 package 범위이고352는5장 수리 선행 대기다. 남은 번역 저작을 우선한다.

## 깊이 3문·한 배치
1. 지우면 중국어 사용자는 첫 투자 안내·비용·청산 경고를 영어로 읽게 된다.
2. 24주·매매·경제 변화0, 조회 무료와 주문 확정 행동력1의 기존 차이를 그대로 알린다.
3. 원문을 줄이거나 UI/글꼴을 바꾸지 않고 기존 지역 사전에 직접 번역만 추가한다.
현재 투자 후보78키 중 아래27키×간체/번체54값만 소유한다. 일본어와 시장·현금 %s 기존값은 보존한다.

## 정확한 파일·역할 소유
- 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 아래 누락 키만 append.
- 원장: `content/meta/full_game_localization.json` 신규54receipt/2batch만 공식 export/check/import 후 append.
- root: 이 사양·완료 archive·큐2·CLAUDE 현재행·WORK_LOG/허용 history·생성 STATUS·새 독립 보고/판정 원장·private383 교환/실행 증거.
- compat357은 CN private 초안, screen_path_probe는 TW private 초안과 private383 화면 관찰기/실행기.
  r3_route_probe는 비저자 전수54 의미/소스/화면 독립 검수. root만 수용·격리 엔진을 실행한다.
- 다른 사전·기존 키/receipt·원문·runtime·도구·공개데모·project·사람 원장은 비소유.
  확인된 새 runtime 결함은 별도 선언한다. CN/TW는 각각 한국어에서 독립 작성하며 서로 변환하지 않는다.
- WORK_LOG 예산이 필요하면 오래된 완결 항목만 `docs/history/WORK_LOG_2026-09-07_localization.md`로 바이트 보존 이동한다.

## 정확한 키
- `거래`
- `보유`
- `은행`
- `AP`
- `현금`
- `순자산`
- `대출`
- `용어`
- `투자 용어`
- `투자 / 매수·매도`
- `투자 데스크`
- `거래/보유/시장/은행을 페이지로 나눴습니다. 조회는 무료, 매수·매도만 행동력 1을 씁니다.`
- `투자 화면 읽는 법`
- `거래 전에 알아둘 것`
- `조회는 무료입니다. 매수·매도 주문을 확정할 때만 행동력 1을 씁니다.`
- `현재가`
- `자산 1단위가 지금 거래되는 가격입니다. 보유 수량과는 별개입니다.`
- `위험 등급 1-5`
- `가격 변동폭의 상대 등급입니다. 손실 확률이나 수익을 보장하지 않습니다.`
- `변동`
- `거래 수수료`
- `매수 기본 수수료는 0.3%입니다. 컨디션이 나쁠수록 매수 비용이 높아질 수 있고, 매도 수수료는 0.5%입니다.`
- `비용`
- `레버리지`
- `수익·손실 모두 2배입니다. 포지션 가치가 노출액의 35% 아래로 떨어지면 강제 청산됩니다.`
- `ui.investment.warning_badge`
- `투자 데스크 열기`
문맥 키 `ui.investment.warning_badge`의 한국어 원문은 `주의`다.
은행/용어/AP는 기존 다른 공용 소비자도 사용하는 동일 키이며 중복 수용하지 않는다.

## 검증·판정 경계
- 공식 각27 export/check/import, current append guard·중국어 normal·변경 영향 소비자·context/queue/diff.
  변경 없는 verifier self·전체감사·역사 corpus 재생성·240주 반복0.
- 1280x800의 CN/TW 첫 안내·거래 상단·Terms 콜백 제목 각3화면(총6PNG)에서 신규54값을 전수 관측한다.
  투자 용어 제목은 별도 glossary 콜백에서만 표시되어 실행 전 표본을 정정했다. glossary 본문 전체 번역/검수 주장은 없다.
  준비 fixture·직접 표시 호출이며 새 raw 입력/거래0. 기본 실물 폰트/글리프/줄바꿈/가시 경계 확인,
  아이콘 버튼은 실제 아이콘/간격/스타일 여백을 뺀 문구 폭을 사용한다.
- 첫 안내의 investment_first_visited 변경은 예상되는 준비 상태 변화로 기록한다.
  수용문구가 공용 은행 제목/용어/AP에도 사용됨은 실제 호출 대조로 확인하며 해당 별도 화면 완료로 확대하지 않는다.
- 실제 source 및 실사용자 파일 전후 불변·정확 성공 marker·stdout/엔진 로그 오류를 함께 확인한다.
- 숫자 1/1-5/0.3%/0.5%/2배/35% 및 아래로 떨어질 때의 엄격 부등 의미를 보존한다.
  위험 등급을 손실 확률이나 수익 보장으로 바꾸지 않는다.
- 원어민·인간·물리 패드·자연 진입/복귀·공개 출시 판정이 아니다.
  공개GO1/인간OPEN45·본편/새package HOLD, 외부 출시/스토어/지출/법률 권한 행사0.
범위·역할·정확 표본·검사계획은 일회성이며 새 상시규범0.

# ORDER-496 — 중국어 금액 파서 수사 뒤 경계

#### [x] ORDER-496 [오탐 수리] 월 이자·한글 수사의 접두어 오독 — 2026-10-09

착수 — 만지는 파일: tools/zh_translation_audit.py의 기존
SOURCE_COLLOQUIAL_MANWON 경계와 기존 embedded self-test. 운영 파일은
큐/L3·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
495 문안/원문/원장·런타임·저장·새 도구/검수보고/판정원장은 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 기존 검사에서 금리가 담긴 월 이자를 월 이=2만원으로 읽어 정상
  은행 번역2잎의 공식 check가 실패한다. 번역에 가짜 금액을 넣어야 하는 오탐이다.
- 독자: SOURCE_COLLOQUIAL_MANWON→_source_money_amounts→중국어 숫자/통화
  검사→full_game_localization check/import. 비저자가 같은 오탐을 독립 재현했다.
  수사 뒤 경계를 세우되 실제 월 천의/천도/천에·구어 금액은 그대로 검출한다.
- 경쟁: 제품 금액 검사를 유지하고 고친다. 월 칠십,의 쉼표 앞 되감기도 같은
  수사 경계 증상으로 다룬다. 검사 삭제/skip/KNOWN 예외·원문/번역 수리는 아니다.

## 실행 / 검증 / 경계

한글 수사 가지와 숫자 가지의 끝 경계를 분리한다. 월 이자/즉시 일어났다 같은
단어 접두어는 돈이 아니며, 실제 월 이·월 이만원·월 칠십,·보증금 천에 등의
금액과 조사·원화 단위·부호·수량 검사는 보존한다. 현재 소스에서 달라지는
파싱을 직접 대조하고 기존 self-test에 정상/금액 추가·변조 반례를 넣는다.
기존 ZH self-test/현재 audit·495 공식 check·context/queue·diff 검증만 실행한다.

저자와 분리된 비저자가 원인/경계/반례와 실제 최종 Git diff를 메시지로 확인한다.
새 도구/비용 계측/재사용 후속/형식 보고0·절차 일회성·새규범0이다.
게임원문·번역·원장·선택·경제·저장·project.godot·공개 데모·인간판정은 불변이다.
현재 정적 검사의 오탐만 닫으며 화면/원어민/물리패드 OPEN·본편 출시 HOLD다.

## 수용 결과 — 2026-10-09 / 제품 금액 검사 수리만 GO

선언735752a → 제품69c75c4d450efb4f34ae771d082078ffe48d1e4d를 main commit/push했다.
기존 validator1파일31+/1-만 수리했다. 한글 수사는 단어의 접두어로 잡지 않고,
숫자 가지의 쉼표 guard를 분리해 수사 끝을 되감지 않는다. 검사 삭제/예외 추가0이다.
현재 소스 raw매치5잎·금액 변화4잎: 은행 금리2잎의 가짜2만원 제거와 상철
주거 본문2잎의 보증금천/월칠십 쉼표 금액 회복. 일부 callback은 금액 불변이다.
해당 기존 사건3잎×CN/TW 번역 errors0, source manifest b7d4a4… 불변이다.

ZH self-test12659·현재audit·full localization265·body scope54·등록179·i18n·
공개demo·context/queue/diff PASS. 495 공식 check16×2도 정상 문안 그대로 통과했다.
비저자 phone_independent_review가 별도 구코드/현재 소스·경계·정상/추가금액/변조·
음수 반례·기존 번역과 실제 최종Git을 확인해 blocking0·scope GO다.
content/locale/원장/runtime/project 변화0·새 도구/보고/규범0·절차 일회성이다.
직전492 마감ef97d8c의 실제 CI37889060971 녹색을 확인했다. 현재 후보 전체CI와
실제화면/원어민/물리패드·본편출시 GO는 별개다. 495 번역 수용으로 복귀한다.
운영 마감의 부팅 예산 초과는 마지막 갱신 문구 축약과 WORK_LOG의 484~490
기록을 history/WORK_LOG_2026-10-09_pre_order491.md로 원문 바이트 보존해 해소한다.
새 검수보고가 아니라 기존 기록의 보관 이동이며 과거 제품/인간 판정은 불변이다.

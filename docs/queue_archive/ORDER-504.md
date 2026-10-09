# ORDER-504 — 중국어 월간 통화 빈도 검사 오탐 수리

#### [x] ORDER-504 [현지화 검사 수리] 월마다 두 번과 한 달 기간 구분 — 2026-10-09

착수 — 제품 소유는 tools/zh_translation_audit.py의 기존 monthly_frequency
원문 분류와 같은 파일 embedded self-test뿐이다. 운영 파일은 큐/L3·본 사양/
완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS다. 502 번역/영수증은
502가 계속 소유한다. 게임원문·번역·원장·runtime·저장·project.godot 비소유.

## 판정 단위 / 깊이3문

- 지우면: 정상 후일담의 매달 두 통화를 한 달 기간으로 오독해 올바른
  每个月/每個月를 거부한다. 번역을 검사기 오류에 맞춰 왜곡하지 않는다.
- 생산자/독자: MainGame._ending_cast_epilogue의 월2통화 원문 → 공식
  full_game_localization.translation_errors → 기존 ZH 수량 판독이다.
  502 정상16응답 중 이1잎만 두 언어에서 재현 실패했다.
- 경쟁: 이미 한 달에 한 번을 읽는 monthly_frequency를 명시 빈도 수사에도
  적용한다. 수량 번과 월간 간격은 별개로 검사하며 일반 한 달 기간은 유지한다.
  새 시스템/효과/수치/라우팅·검사 삭제·전체 잎 예외·allowlist·새 도구0이다.

## 실행 / 표적 검증

선언commit/push 뒤 기존 분류만 수리한다. 정상 월2통화·한/세/숫자 빈도와
잘못된 월간 간격/횟수/누락·일반 기간·기존 월1빈도 반례를 embedded test에서
확인한다. 현재 source counter/money 전후 전수대조로 의도한 빈도 외 변화를
확인한다. 비저자는 코드/실제 정상32응답/독립 반례/actual Git scope를 읽는다.
ZH self-test/current ZH·full localization/body scope·i18n·공개/legacy demo와
context/queue/diff만. 전체 local audit/240주·계측/검수 재사용 작업0이다.
502를 재개하며 생성STATUS는 502 마감과 함께 최신화한다.

실제화면/원어민/물리패드 OPEN·전체출시 HOLD다. 공개M01~M06·과거 인간판정·
shipping language·사용자 저장 불변. 개발 스킬의 원인수리·독립 반례·표적검증을
적용한다. 새규범0/절차와 이번 배치 범위는 일회성이다.

## 수용 결과 — 2026-10-09 / 기존 검사 한정 GO

선언7dbf84a → 제품fa57a72 main commit/push. tool1파일18+/2-만이며 기존
monthly_frequency 분류1곳·embedded 정상6/음성8을 바꿨다. 정상502 공식check
16×2 PASS. ZH self-test12725·currentZH·full localization265·body54·i18n·
공개/legacy demo·구조audit ERROR0/WARNING0·context/queue/diff PASS다.

비저자 phone_cn_author의 독립40표본(정상16/음성24) 예상불일치0이다.
source16957종 counter/money 전수대조 변화는 실제 월2통화와 월4회여력의
2잎 duration_month1→monthly_frequency1뿐이다. 각각 occurrence2/4와 모든
money 불변·manifest b7d4 불변이다. 실제Git 선언→제품 tool-only와 검수blob
fc4c343ebe954ca585fdff2f01b68977464f18ae 동일GO·blocking0·clean/origin동기다.
일반 기간/횟수/통화 검사를 완화하지 않았고 번역/원장/게임원문 변경0이다.
새규범0/절차 일회성. 502를 재개하며 생성STATUS는 그 마감에 최신화한다.
현재 main CI 진행 중·실제화면/원어민/물리패드 OPEN·출시 HOLD다.

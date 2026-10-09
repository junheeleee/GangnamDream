# ORDER-501 — 중국어 엔딩 수량 검사 오탐 수리

#### [x] ORDER-501 [현지화 검사 수리] 구독자 수·양자 표현 — 2026-10-09

착수 — 만지는 제품 파일: tools/zh_translation_audit.py의 기존 수량 판독과
같은 파일 embedded self-test만. 운영 파일은 큐/L3·본 사양/완료archive·WORK_LOG·
CLAUDE 마지막 갱신·생성STATUS다. 500 문안/공식수용은 500이 계속 소유한다.
게임원문·번역·원장·runtime·저장·project.godot·새 검사/도구는 비소유다.

## 실제 결함 / 깊이3문

- 지우면: 정상 중국어 엔딩 요약의 구독자100만이 100만원으로 잘못 분류되어
  가짜 통화를 요구한다. 강남과 가족을 모두 지킨다는 양자 표현을 두 사람으로
  오독해 올바른 CN 都/TW 兩者도 거부한다. 번역을 검사에 맞춰 왜곡하지 않는다.
- 생산자/독자: MainGame._ending_run_summary의 실제 두 반환문 → 공식
  full_game_localization.translation_errors → zh_translation_audit.validate_text의
  money/counter 판독이다. 정상20응답 중18만 통과하는 CN/TW 재현이 있다.
- 경쟁/파급: 새 시스템·효과·수치·라우팅이 아니다. 관찰된 구독자 초과 수량과
  명시된 두 대상/보존 술어만 타입으로 결속한다. 일반 만=금액·둘=entity·
  원화 표기/숫자 변조/잘못된 단위 거부를 유지하고 전체 잎 무검사 예외는 없다.

## 한정 구현과 검증

기존 audience/counter 타입 경로로 구독자 초과를 검출하고 명시된 강남과 가족의
양자 표현만 인식한다. 원문 predicate·target 역할/수량/부호/단위를 유지한다.
원문 변형에 대한 기존 금액·사람 수 검사는 약화하지 않는다. 새 allowlist0이다.

수정 전 현재 source/500정상응답 실패를 재현한다. 수정 후 같은 정상응답40·
구독자 수 변경/누락/다른 단위/반대 범위/중복/가짜 원화·잘못된 양자 수/대상/
부정·일반 두 사람/명시 원화 반례를 같은 embedded self-test에서 검증한다.
현재 코퍼스의 source counter/money 전후 차이를 전수 대조해 실제 두 잎 외
변화가 없는지 확인한다. 기존 ZH self-test·현재 ZH·full localization/body scope·
i18n·공개/legacy 데모 및 등록/context/queue/diff 영향 검사만 실행한다.
비저자가 실제 코드 diff·실패재현·정상/음성 표본·Git scope를 읽고 판단한다.

전체 local audit/엔진240주·계측/검수 재사용 작업·형식 보고/판정원장0이다.
과거 인간판정·공개 M01~M06·shipping language 불변, 실제화면/원어민/
물리패드 OPEN·전체출시 HOLD. 새규범0/절차 일회성이다.

## 수용 결과 — 2026-10-09 / 기존 검사 한정 GO

선언c1902b3 → 제품5aa6de3bf6da0c33d1787222ec3a48f4f7a8e7c0 main commit/push.
tool1파일65+/3-, source16957종 counter/money 필드 전수대조의 변화2잎만이다.
구독자100만 money1,000,000→creator_subscriber_over_count1,000,000;
강남과 가족 entity2→kept_gangnam_family_pair2, source manifest b7d4 불변.
500 공식check20×2·현재 정상40 PASS. 일반만=원화·일반둘=entity 불변이다.

독립 phone_cn_author의78표본(기본74+삼자/정상 혼합4) 예상불일치0.
양자 중복 누락 발견/기존 unmatched 경로 등록 수리 후 GO·blocking0이며,
실제Git c1902b3→5aa6de3의 tool-only scope와 검수blob
68db73ac2d9de51ba4995e42c94db0b9c34cbc30 일치·clean/origin 동기를 확인했다.
ZH self-test12711·currentZH·full localization265·body scope54·i18n·
공개/legacy demo·등록179/context/queue/diff PASS. 새검사/도구/전체잎 예외0이다.
원문·번역·원장·runtime·저장·공개 M01~M06·인간판정은 그대로다.
개발 스킬의 현지화 프로필·선선언·원인 수리·독립 반례 검수를 적용했다.
새규범0/절차 일회성. 500을 재개하고 생성STATUS는 그 마감과 함께 갱신한다.
현재 전체 CI/실제화면·원어민·물리패드·본편출시 GO가 아니다.

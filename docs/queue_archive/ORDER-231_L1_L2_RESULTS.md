# ORDER-231 — 남은 초기 코어22종 번역 증거

상태: 420문구 수용·회귀 완료. 정확 C2 비저자 단위 최종 판정 전이다.
공개 데모·인간 원장 원형을 유지하며 본편 HOLD다. 실제 원어민·화면·플레이 관찰0.

## 모집단·구현

- 기준 clean main `1a9799ed7a0b3166d8ae2b065596509b83cb0d2d`.
- 선언4c1f840/표시82062fd, 제품 C1 `d494351dd2af6d1623ef6337edb41534e06f9386`. 초기/final source420·검수 map을 분리했다.
- KO `content/events/core_loop_v2_events.json`82380B/SHA30ce137faf06437e131d297efa7ab3fc82806534e77c53bea33af0b01a750b87.
- locale별22title+22description+40choice+40result+16memory=140, LF215/name73/동적7.
- JA Plato/CN Rawls/TW Poincare가 KO에서 직접 작성. 비저자 Rawls→JA/Poincare→CN/Plato→TW 전량140.
- 기존12객체68문구/언어의 raw prefix 및 파일 전체 역복원 exact. 신규22는 KO 상대 순서.
- 보호1,901파일/603,554,085B·KO/EN/gameplay/runtime/project/공개/human 원형 exact.
- 수용37,522→37,942(JA12,646/CN·TW12,648), b90→91/meta9 유지. 기존 accepted raw 역제거 exact.
- 비보호 shipping 사건 텍스트 결손0. 보호·author-only·UI·동적 producer·표시 소비자는 별도다.
  선택22는 weight0/hidden/min_turn9999이며 이번 번역은 활성화·현재 도달 증거가 아니다.

## 의미 대조·수리

- 필수2/권고3를 채택해 JA1/CN2/TW2 정밀화. JA 대타근무 번역투, CN 대리 답변/면접 취소 암시,
  TW 강사 대신 플레이어의 야근 기억/아버지 매번 목격 암시를 바로잡았다.
- 각 비저자 첫 전량140 대조와 수정 JA1/CN2/TW2 재독을 분리했다. 나머지139/138/138 exact.
- 한빛 수락/미수락과 미래 급여, 다은 실제 상호 응답/별개 약속, 아버지 생존·전화 미응답 뒤 SMS,
  면접 전 불합격·가상 작업표, 시험까지6일, 재고4일36만원/11↔12/반품1/다섯 기억을 보존했다.
- 실제 노동 수령/몸 비용, 구매9000원/10분, 미납 가능성과 미수령 급여, 장부 계산≠납부,
  주거 기준≠계약·이사, 원문 밖 회신·진단·근무·관계 진전0.
- CN 기존choices 들여쓰기 준비오류는 첫 L1 전에 raw 복원했다. 과거 원문 의미 수리0.

## 첫 실패와 국소 검사 수리

- 첫140 L1: JA139clean/1leaf1진단, CN117clean/23leaf27진단, TW120clean/20leaf25진단.
  원형 실패·source/target/hash를 보존했고 산문을 검사기에 맞춰 바꾸지 않았다.
- JA: 도담6월 둘째 주·4월 지원서의 complete source1에만 달력/서수/오전/문단 역할 결속.
  ROOT22 B0 4/22→B1/B2 22/22. 비저자 사전봉인14 B1 12/14→같은 B2 14/14.
  四月 정상 오탐과 잘못된5월의 국소 역할 거부를 수리했다. fixture/기대 변경0.
- ZH: complete source24에만 요일/시각 경계, 수량/소유자/단위/문단, Choi/Dodam 이름 결속.
  자체128(실물48/정상24/변조32/OFF24) B0 정상5/48·6/24, 최종128 기대충족.
  원형과 별도 최종TW2 정상도 통과했다. ROOT 사전봉인46(정상14/변조27/OFF5) 첫완료46/46.
  괄호 준비실패 및 중간 실물3/정상1 오탐을 보존했다. ROOT runner의 memory-key colon 준비실패는
  완료 blind 실패와 구분했으며 corpus/제품 변경0으로 runner만 고쳤다.
- 새 고정 등록212 = JA36(정상8/변조22/OFF6)+ZH176(정상88/변조59/OFF29).
  각 변조는 정상 base PASS를 확인하고, OFF는 새 API 비적용만 요구한다.
  기존248 tests/269메서드 원형을 유지하고 단독 새2tests PASS. 전체250 실행 결과는 아래에 별도 기록한다.
- blanket 면제·전역 완화0. JA pipeline 변경0; 기존 full/zh 코드의 새 helper·hook 역제거 raw/AST exact.
- 비저자 정적 검수: 본문 검수 JSON 내부 records와 승인 manifest의 직접 결속을 보강했다.

## 교환·회귀 상태

- clean C1 공식 final export/check/import 각3, leaves140/changed_files0/INCOMPLETE/인간OPEN.
- 첫 helper check/import의 locale 인자 누락으로 JA PASS 뒤 CN은 검증 전 거부됐다.
  원형을 보존하고 helper에 명시 locale만 추가해 같은 C1/batch/response로 재실행했다.
  초기 JA private receipt는 중복 수용하지 않으며 제품/본문/기대/portable 변경0이었다.
- 초기 previous-null420와 final current-target420, private receipt 및 portable hash를 구별했다.
- 전체수용37,942 hash/L1 한 번: ERROR0, 입력738 전후 exact, 70.006초.
  이후 테스트 literal 형식만 바뀌어 현재737 raw exact + self1 전체 AST exact로 재결속했다.
  L1 검사함수·본문·원장 변경0이며 전체수용 검사를 다시 했다고 쓰지 않는다.
- 명시12 첫 실행은 self CLI 해석 실패로 exit1(57.263초); 나머지11은 PASS였다.
  Python3.9.6 직접 실행은169887B literal 한 줄 경계에서 Non-UTF-8을 보고했지만 UTF8 decode/
  decoded AST/단독 import는 통과했다. 176 payload를 인접 문자열로 나눠 최대2961B/줄로만 바꿨다.
  전체 AST/176값·기대/등록250 exact, 원형 실패 보존. 데이터·검사 기대·언어 환경 변경0.
- 같은 명시12 재실행 PASS(64.281초), 입력743 전후 exact, self250(8.244초),
  source52/JA88/ZH12407/공개5언어 UI121/구조·coverage·등록·context·queue PASS.
  audit.py는 등록상 두 번 포함된12이며,11개 고유 명령이다. 기존 font blocked는 실제 렌더 판정이 아니고 유지했다.
- CLI 해석만 확인하려던 --help는 이 저장소 runner가 인자를 무시해250을 추가 실행했다
  (8.327초 PASS). 불필요 추가실행1로 분리 기록하며 named12나 독립 판정에 중복 합산하지 않는다.
- 위 실제 결과를 기록한 뒤 바뀐 named 입력은 CLAUDE/report2뿐이며 나머지741은 raw exact다.
  이 문서 변경 뒤 context/queue/diff 표적 검증만 한다. code/source-like 문서는 C2에 포함한다.
- Godot/full/240주/원어민/실제렌더/인간플레이/원격CI 실행0. 자동 검사는 계약 회귀 증거이며 재미·깊이·문체 GO가 아니다.

## 작업 단위 증거

| 항목 | 범위/근거 |
|---|---|
| 도달 경로 | events collector → locale overlay → final exchange140×3. 실제 제품 ingress 변경/조사0 |
| 생산자 ↔ 독자 | KO22 root/140 source leaf ↔ locale별 동일 owner/path140, source/target map exact |
| 바꾸는 상태 | 번역 수용37,522→37,942/b91; 게임 상태 변경0 |
| 포기 시 잃는 것 | 미번역 초기 일·관계·비용 문구420; 원문 선택 비용 보존, 새 소비자0 |
| 서사 위치 | 초기 코어22 source; 월·주차·숨김 조건 변경0 |
| 장면 계층 | 원문 유지, 번역만. T1/T2/T3 신규 승격0 |
| 닫는 것 | 텍스트 수용420만. 본편 HOLD/원어민·렌더·인간OPEN 유지 |

## 손실 없는 이력·규범

WORK_LOG raw33818:39278의 과거4절5460B를 history EOF76217에 LF1+exact로 이동했다.
block SHA8f60a3f39bfa1eefe8e689ac8bae305dbdbedf65fd66e0ba4f4a9176b8e1758a,
history81678B/SHA3b997fb5b28eed6db1b10d143c3a3e7760eb0fdcbc67b4374118774a57744a7b.
요약/삭제/다른 절 이동0. 최종 WORK 새 항목은 별도 추가한다.
현지화/사실/판정은 기존 I18N·WORK_UNIT 정본을 유지한다. 이번 선택·파일·마감·국소 fixture는 일회성.

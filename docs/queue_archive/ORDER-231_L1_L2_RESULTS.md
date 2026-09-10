# ORDER-231 — 남은 초기 코어22종 번역 증거

상태: 420문구 수용·회귀 완료. 정확 C2 work_unit231 한정 내부 GO다.
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

## 최종 독립 판정·후속

Poincare 비저자 통합: source `20560eb52411ea522275c284dd35a3fde8d9dd74` / tree `05bd9f69aa830316d4e4d32ffb00c18792ed40e4`의 ORDER-231만 GO, 필수0.
JA 의미는 Rawls, CN은 Poincare, TW는 Plato의 KO 직접 전량 대조에 의존하며
통합 검수자의 TW 자가 승인을 만들지 않았다. 실제 본문420·기존수용37522·meta9·
공개/원문/사람 원형·agent17과 이력5460B 원형을 보존했다. 전체판 HOLD다.
내부 검수는 자동 PASS를 재미·원어민·실플레이 판정으로 바꾸지 않는다.
다음 UI 기록 불러오기24키는 read-only scope 사전조사이며 이 단위 수용에 미포함이다.
JA기존24/CN·TW각24누락·템플릿3·공유용례4를 별도 선언한다. 저장 삭제/불러오기 실행0.
아래 private 증거는 해당 파일 SHA로 결속했다. 문서 래퍼는 이 C2에만 연결한다.

최종 검수에서 C1/C2 WORK의 끝 LF1이 추가로 빠진 사실을 확인했다. 초기 이동 proof의
전체 raw 보존 주장은 이 지점에서 틀렸다. history 원형은 처음부터 exact였고,
WORK33,817B를33,818B/e310f9f781443b8ebc7688d074248370e5cbd8665359b7b6211c1a58f677b51e로
복원했다. 검토 HEAD `e24a5c59514b7323d74ebbfd11a48903b9397ebb`는 WORK만+LF1인 metadata wrapper이며 실제 resolver는 C2를 유지한다.
복원 직전 diff 검사의 유일한 EOF 빈 줄 경고는 선언한 원문 separator의 byte-exact 보존이다.
본문/코드/기대/원장 변화0이며, 최종 신규 WORK 항목을 역제거해 이 prefix를 다시 확인한다.

| 증거 파일 | bytes | SHA256 |
|---|---:|---|
| .git/full-game-localization/order231-initial-seal.json | 310958 | 4d10ae021490f868f9b72d4c680ea271dce29d5946549c342f384635425403c1 |
| .git/full-game-localization/order231-ja-author.json | 115779 | 4897df53f243eac560e561d502939dc2650569cdda7d703badbc6989b2ad9d5f |
| .git/full-game-localization/order231-ja-first-l1.json | 120408 | 08f8f9d899e708b1da2ad019939f878eb93058caca1d574df792bdcaa0e2e773 |
| .git/full-game-localization/order231-cn-first-l1.json | 178430 | 7523e19a8334fef56a2c2c42cdb12d3c625743c2894a4cd21f3f514cc063c944 |
| .git/full-game-localization/order231-tw-first-l1.json | 164627 | 5b856b4fe0124eea019f81c01635035817f953979ea7db22f5b847edede2f406 |
| .git/full-game-localization/order231-ja-independent-l2.json | 52737 | 871b6dfdde46410e53c5414a7a33a66857a816f7cf91425a1cdde6999db2eb9f |
| .git/full-game-localization/order231-cn-independent-l2-final.json | 53763 | c08826ebed9b4e7c2e1b785674fdd0b67a9fe201ef6c3d5164c790c15a9a646b |
| .git/full-game-localization/order231-tw-independent-l2-final.json | 47285 | 728132eca5ea241a2ba60229a354e4f581a68935db8c6c9fef23618aef8b476a |
| .git/full-game-localization/order231-ja-root-B0.json | 5720 | 196ad857ff6d3caf2579c0eadf4575de110faf98d11594c5e264c1181ff88e98 |
| .git/full-game-localization/order231-ja-root-B2.json | 6231 | a0a9b333cd91b21b9bc4cf8d2421843483909145ed5018d3ba09874e22020974 |
| .git/full-game-localization/order231-ja-blind-B1.json | 4669 | 2294ea990d6ea6ac652585369732f4aad20a2954bfbcaec7111e33fa49fb09eb |
| .git/full-game-localization/order231-ja-blind-B2.json | 4902 | 645aafaf76b79318557aab6a92c57725d379a3dfe6d0bfa6765248347958bfda |
| .git/full-game-localization/order231-independent-helper-ja-static.json | 11787 | 588dd30553a7f2f3e0690d896556e197e5aa9af32d29c90a9d3145e24b1c7450 |
| .git/full-game-localization/order231-independent-helper-body-addendum.json | 1509 | 13431e28ed66ce6b4ab5576ee961e922804d5762502b22d7ff2aa60e39da4de7 |
| .git/full-game-localization/order231-zh-root-blind-B1.json | 15107 | 5d2dbf47d63555172e3b7a496e8be8aa46951ed005aff59ea2ce4fa77e8f7e8c |
| .git/full-game-localization/order231-independent-zh-static-final.json | 8873 | edce056f325d0ebfedd5015246ca1c8f3617cd777929c851b89235fa26203b27 |
| .git/full-game-localization/order231-final-body-preacceptance.json | 3119 | c1df5d805c5b46fa4a522a420d8de57f942900f5997496f264707de667872a99 |
| .git/full-game-localization/order231-independent-preacceptance.json | 19620 | ea8b604939e6256a97b63f8d4f2d6e62a32331bff3bf876bf99ed3e22c4e3d5e |
| .git/full-game-localization/order231-final-source-response.json | 1696 | 2e5c1f1a5e72648fa4929ed374ad6db400a0439acbbfd67ec217656bc9aaa57f |
| .git/full-game-localization/order231-official-check-cli-initial.json | 820 | f225a34ddb446696501e5c0fd86ba3f012cd083b9535c994224a50def43c1b48 |
| .git/full-game-localization/order231-official-import-cli-initial.json | 884 | db5253bafb08aeea790883b7113f52dc0516f1cd08ac59c26a84851928b74eb0 |
| .git/full-game-localization/order231-official-check-final.json | 1398 | 3ad8c122ee1a3b5f888d2c990c9b119b3646065b3d122969df29f4e663d81af5 |
| .git/full-game-localization/order231-official-import-final.json | 1441 | dcebdfb9627809986e67a2a82c6d458902051fbe466a3ce5924f77950c4d5a49 |
| .git/full-game-localization/order231-portable-acceptance.json | 1209 | a1dbe6975b221c5266d4540024e4c431afbd9b851adea4184f56622e326911ed |
| .git/full-game-localization/order231-independent-receipts.json | 23931 | a15c9f1c9d3ff4ccf0527936996bd0421ab278113621dbced1b157ef43bc9b29 |
| .git/full-game-localization/order231-all-accepted-l1-final.json | 81707 | c5410becb5a27a03165cde468f0771e48b620569c71b073b837a7d974adf2fd8 |
| .git/full-game-localization/order231-named-qa-initial-failed.json | 167850 | 680a185b4ace7a2224f8461592cdbabc0d8100e9f5a1eefdefae1cab3f9fdce0 |
| .git/full-game-localization/order231-self-format-repair.json | 1039 | cca1a3562d9d43dcb5af0cc3f1b425cac707b78c0e5709c85c1a2f8a66dd9e07 |
| .git/full-game-localization/order231-self-cli-repair-extra-run.json | 923 | d556b858b720f1b69cfe0b657076a340a2ab798a529e37f2e8a73972d85ab86d |
| .git/full-game-localization/order231-independent-self-format-addendum.json | 6189 | f981cdfb60aa89aee92b83763fc019e64dfb70ed4b4b2a09a53073866f296119 |
| .git/full-game-localization/order231-named-qa-final.json | 167700 | 93e8385e12c48bf4165bd8e32123915ed2f0a2897d9d3463ee440f5a8b6ab6ad |
| .git/full-game-localization/order231-qa-source-rebinding.json | 502 | 5f575c5406b485d9066a1319a73b0d4e50efaef8f58d80e1fb57d4a73cd22f37 |
| .git/full-game-localization/order231-history-move.json | 735 | 4816d46fdbaf609f18ca2367d2ff0acacfc50ee89f3d494132ebc950d6407c5a |
| .git/full-game-localization/order231-poincare-c2-final.json | 24540 | 4e44f7cf9dae5b9808e7b4571041a505d1f96481b1ea6130187a2be7af9397b7 |
| .git/full-game-localization/order231-next-ui-load-panel-preflight.json | 31371 | 70c531320096438047cb6340dbbefd62e4164bf9588ff091986d29f139bdf8c1 |
| .git/order231-zh-guard-controls.json | 148831 | 92f163ca409532efcbf05e79d55d679b70ead5273cdb0cb63f4589207024a0f8 |
| .git/order231-zh-final-tw2-controls.json | 2432 | ee28a9a9223cadc4a1f98d64e58d86f17b3c482d039406322a3368364a3dcd20 |
| .git/order231-zh-own-baseline.json | 50500 | c9b4f222fcf93687cc8dec61c2a6a021f644a72cbdb1606d9faab45dead08b79 |
| .git/order231-zh-own-B1.json | 58380 | 9e904ba79072e670de6a86350ca11205e02ac09413f92383e2a1b4d0f6f1d202 |
| .git/order231-zh-guard-B1-final.json | 2905 | cbcc190da3dfc011f96509ceb7b3ee4e98d2b6e934cea97939a504f002a72252 |

## 선언 사양 원형

아래 예측·수용 전·착수 상태는 역사 원형이다. 실제 마감 결과는 위 기록이 소유한다.

# Active Queue Spec: ORDER-231

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-231 [전체 현지화] 남은 초기 코어22종·140문구/언어

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. 기준은 clean main `1a9799ed7a0b3166d8ae2b065596509b83cb0d2d`,
tree `30dbc3d009f4736fa67049252b576bf1525f5893`이다.

## 깊이 3문·판정 대상

1. 없으면 무엇이 빠지는가? 세 언어에서 아직 없는 일·관계·주거비22종의 원문140문구다.
2. 미래 상태를 바꾸는가? 선택·기억의 의미만 보존한다. 조건·효과·일정 변화는0이다.
3. 무엇과 경쟁하는가? 원문이 가진 돈·몸·사람에게 쓰는 시간의 선택을 번역하며,
   별도 행동판이나 새 플레이 기능을 더하지 않는다.

한국어 전체22객체는 ROOT가 읽었다. 22title+22description+40choice+40result+
16memory=140, LF215, `{name}`73와 다른 동적 토큰7이다. 원문 파일
`content/events/core_loop_v2_events.json`은82380B,
SHA `30ce137faf06437e131d297efa7ab3fc82806534e77c53bea33af0b01a750b87`이다.
선택 source records SHA는
`b074632322a8fcd23337c59ecb596801c13aa8f7666884d3cdfeabbd25027a0e`다.
모두 shipping 분류지만 weight0/hidden/min_turn9999다. 분류는 현재 도달 증거가 아니다.

## 정확한 선택

```text
v2_hanbit_offer_message
v2_daeun_small_commitment
v2_daeun_third_greeting
v2_jiyeon_second_crossing
v2_sangchul_demo_echo
v2_jaehyuk_plain_reunion_echo
v2_father_health_signal
v2_dodam_result_message
v2_city_service_work_sample_message
v2_city_service_result_message
v2_daeun_tuesday_followthrough
v2_hyunsu_exam_eve
v2_hyunsu_exam_morning_echo
v2_gangnam_receipt_walk
v2_convenience_trial_shift
v2_inventory_count_nights
v2_logistics_class_session
v2_moving_crew_days
v2_empty_sunday
v2_demo_first_bill_opening
v2_m3_room_ledger_anchor
v2_m4_housing_consultation_anchor
```

## 파일 소유권·병렬 분담

- Plato: `content/events_ja/core_loop_v2_events.json` 신규22만 append.
- Rawls: `content/events_zh-CN/core_loop_v2_events.json` 신규22만 append.
- Poincare: `content/events_zh-TW/core_loop_v2_events.json` 신규22만 append.
- 세 저자는 각각 KO에서 직접 작성한다. 영어 중역·지역 간 변환0. 기존12객체/68문구의
  raw prefix·순서·값을 보존하며 신규부분 역제거가 기존 파일 전체와 byte-exact여야 한다.
  비저자 전량 대조: Rawls→JA, Poincare→CN, Plato→TW. ROOT는 통합·증거를 소유한다.
- ROOT: `content/meta/full_game_localization.json`에 검수420와 batch1만 추가.
  기존37522/b90/retained metadata9를 역제거로 보존한다.
- 조건부: `tools/ja_translation_pipeline.py`, `tools/zh_translation_audit.py`,
  `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`.
  첫140 L1의 실제 정상 오탐이 생겼을 때만 exact source·역할 단위의 수리를 한다.
  코드 전에 actual/다른 정상/유효 변조/source-OFF와 비저자 대조를 봉인하고 같은 입력으로
  재검사한다. 전체 leaf 면제·전역 예외·과거 기대 완화0. 좋은 산문을 검사에 맞추지 않는다.
- 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  이 사양, `docs/queue_archive/ORDER-231_L1_L2_RESULTS.md`, `tools/audit_scope.json`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-231.json`.
  사적 source/response/receipt/증거/QA helper는 `.git/full-game-localization/order231-*`다.
- **손실 없는 이력 이동:** WORK_LOG의 byte33818~EOF39278(5460B), 시작 제목
  `## 2026-08-31 (Codex — 전체 볼륨 자식 배치 선언)`부터 마지막 완료 절까지를
  과거 완결 이력4절을 그대로 `docs/history/WORK_LOG_2026-09-07_localization.md`의 EOF76217 뒤에 newline1+
  exact block으로 옮긴다. block SHA
  `8f60a3f39bfa1eefe8e689ac8bae305dbdbedf65fd66e0ba4f4a9176b8e1758a`,
  history SHA `9af473ea70cd45b34ec0c01b21906864a8e490b00040067f3d8e0ad9c042e6a1`.
  다른 절 이동·요약·삭제0. 앞쪽 새 완료 기록은 별도 삽입한다.

KO/EN·gameplay·인과 원장·runtime/ingress 조사·활성화·저장·project.godot·공개 데모·
인간 원장·언어 선택기·폰트·UI 사전/동적 producer는 비소유다.

## 사실 경계

- 한빛 c0만 수락/회신. 월요일 출근과3주168만원/온전한 달224만원은 미래 급여다.
- 다은 세 번째 인사와 화요일 약속을 합치지 않는다. 6월2일01시의 어제와 상호 응답은
  유지하되 연애를 앞당기지 않는다. 지연 커피/한 블록 걷기/이탈은 별도다.
- 상철·재혁은 원문에 있는 실제 만남만 유지하고 빠진 일정 조율 대사를 발명하지 않는다.
- 아버지는 생존, 전화 미응답 뒤11분 후 실제 문자. 남성 최씨 이웃, 열흘간 두 목격,
  병원 미확인·세 기억을 유지한다. 플래그 done을 진단/통화/방문 완료로 읽지 않는다.
- 도담/도시시설은 면접 전 불합격. 6월17일 샘플 요청·26일18시 마감과 가상 지하1층/
  비상등2개는 실제 근무가 아니다. 현수6월21일22시→27일09시는6일 간격이며 제목은
  시험 전 마지막 문제다. internal exam_eve를 전날로 오역하지 않는다.
- 커피9000원/10분은 구매 선택만. 하루 대타 실제 수령은 금액을 발명하지 않는다.
  재고4일/36만원,11↔12/반품1/미확인 인계/야근의 기억5, 공식3회·처음2회 오류,
  이사4일·상자6중1+5·동시 들기·몸값, 일요일 미회신/공허함을 각각 보존한다.
- 첫 고지서17:52→선택17:53, 미납 조건부 비용/미수령 급여를 지킨다. 문자 재독은
  전화가 아니고 잔액 계산은 납부가 아니다. 장부/주거 기준 선택은 계약·이사가 아니다.

동적7은 `{v2_hyunsu_exam_eve_memory}`, `{cash_position}`, `{expense}`,
`{v2_first_bill_body}`, `{v2_first_bill_trace}`, `{v2_first_bill_evidence}`,
`{v2_first_bill_after_bills}`다. 토큰은 보존하되 생산 문자열·grant_job_display와
선택 밖 후속 v2_demo_first_bill은 이번140에 포함하지 않는다. 원문 연출 채무는
기존 corrected preflight에 남기며 번역으로 몰래 수리하지 않는다.

## 검증·마감

1. 선언 커밋/동기화 뒤 공식 initial export140×3, previous-null420 및 기존 raw를 봉인한다.
2. 직접 저작·자가 전량 대조, 첫 L1 한 번과 모든 실패 원형 보존, 비저자420 전량 검수.
3. 필요 국소 검사 수리만 고정 대조로 닫고 clean C1의 final export/check/import3쌍을
   current target에 결속해 changed_files0을 확인한다. 기존 수용과 보호 입력 역제거 exact.
4. 전체수용 hash/L1 한 번, 명시 `full-game-localization-overlays`12 한 번을 전후 입력으로
   봉인한다. context/queue/diff 표적 검사, Godot/full/240주 재실행0.
5. source-like 문서까지 exact C2로 묶고 비저자 work_unit231 판정 뒤 metadata wrapper만
   추가한다. STATUS는 clean 원장에서 생성·검사한다. 본편 HOLD·인간 원형을 보존한다.

성공 시에만37942(JA12646/CN·TW12648), b91/meta9, 비보호 shipping 사건 결손0이다.
UI·author_only·보호 원고·현재 노출·native/render는 별도다. 자동 검사는 재미·깊이·
문체 증거가 아니다. 기존 I18N/WORK_UNIT 정본을 따른다. 이 선택·소유·마감은 일회성이다.

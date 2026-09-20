# ORDER-279 — 슬롯 중국어 UI·일본어 패배 수리

[x] 2026-09-20. 비저자 Poincare work_unit 한정GO, 필수 결함0.

- 제품 `9860e2b3290dbff1837d8f2e96f0ca7c4944c5b4`, tree `bd3e7bb16d2aeb46e68c7253e81afe35515e65e1`; clean 검토 `fb6127faee104f242fbd5cd4d328380b87949bc9`, STATUS-only wrapper.
- 기존 슬롯21키를 한국어에서 CN/TW 각각 직접 번역했다. 일본어 실제 패배2호출의 한 키를 대박에서 패배로 바로잡았다. 원문21·대상43 전수 독립 검수, 공유3키의 다른7호출도 같은 의미다.
- 총지급·순익·near miss/패배·원화·배수·BBCode·패드6인자 보존. KO/EN·런타임·효과·확률·checker·collector는 불변이다.
- 지역별 실제 check/export/import21/21/1, 공식39972/b124/meta9. old39929 hash·UI/portable raw 역복원·다른JA행 보존, 과거보류72 유지.
- JA 최초 check는 기존 값 교체의 명시 옵션 누락으로 거부됐다. 실패 원형을 보존하고 같은 원문/초안에 --replace-existing을 지정해 다시 확인했다. 원고·checker 수리가 아닌 실행 옵션 보정이다.
- 명명12 PASS. 조건부 legacy/AP 정적 소비자와 fresh-story 도달/화면/입력은 다르다. 동적 win_type4·직행영문 기계 라벨 비포함이며 전체 슬롯/전체판 번역완료가 아니다.
- [독립 보고](../agent_reviews/ORDER-279.json) SHA `8594d8dcf542bc1341087fb8975d7ffba83ac79505d02f717a2f96595926d21c`. 실제화면·원어민·인간플레이·물리패드 미관찰, 공개GO1·인간OPEN45·본편HOLD 유지.
- 선정·소유·배치·검증은 일회성. 기존 WORK_UNIT/I18N 재사용, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 최초 실제 캡처

git-private에 stdout/stderr bytes·SHA·exit·입력핀을 원형 보존한다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order279-accept-cn-first.json | 377824 | 8f4849424a87cd54876171311d440b055eb5cb674d445e0bdcb2a9f7dcdaf862 | 0 | PASS |
| order279-accept-ja-first.json | 377833 | 3ba4bd0ca80e7c04293784a05d3611816c967200044f4b4473ec99996f5052d7 | 0 | PASS |
| order279-accept-tw-first.json | 377824 | 04abe67ca6256d5dc3e8b794f31c77ddc3aab62905fda445a55580656c53fff9 | 0 | PASS |
| order279-applied-export-cn-first.json | 377895 | 21b74f040f602b6a782bac92db4ac30def27a5a766f22e4947fad64738771a7c | 0 | PASS |
| order279-applied-export-ja-first.json | 377867 | 205a4cb5b3fd5a659443def7c278bd460684238f33512ed7a7e8dc12bf780923 | 0 | PASS |
| order279-applied-export-tw-first.json | 377895 | 428cc028191ebd5b6776108cdef00dbff0c7e604c5932c65f380d1d50ab74bf5 | 0 | PASS |
| order279-export-cn-first.json | 377885 | 1b8bf23b9352edf46c9fd404aab373aaecc58d972005adeed42104b5937f1b35 | 0 | PASS |
| order279-export-ja-first.json | 377867 | 62c2f1cc20471aa93a632793f69fd394acb75c3903caee96f2dfd4229556cf84 | 0 | PASS |
| order279-export-tw-first.json | 377885 | ec9d502feabf492cbb13d78d9db418c441143141bc9f6f74720ec9f02ca75b2f | 0 | PASS |
| order279-named-envelope-first.json | 379947 | 02c615e8a41989df0a4387a87f369a7901e04a291b72bd564af8b3cbd9f188cb | 0 | PASS |
| order279-named-first.json | 1697083 | 3c92978fdc78023fc8cd7e898b1aa2bbf65acf7cae3b2597a5e8e855a8a81139 | 0 | PASS |
| order279-preflight-cn-first.json | 377813 | bb5d18567921f16326bfb616c493a9390590eb2f90815d16d7445300309d971b | 0 | PASS |
| order279-preflight-ja-first.json | 377699 | 5113db19b2051c610ec20343f23cf552e9e2af71b5152bc2eabe53857c9d999f | 1 | FAIL preserved |
| order279-preflight-ja-replace-first.json | 377825 | 79f0b7d579d3597cce1b296b29a2da536478fab1c6cc404bcc19b8c2415077da | 0 | PASS |
| order279-preflight-tw-first.json | 377813 | a34c88d89635f29c84fc87ba1a2b447225806ada94b5741ba4949e188a5ebbc9 | 0 | PASS |
| order279-preservation-first.json | 378160 | 334dd431668df6e29410ffe426c06291fb9efdd7f2524dcf4ad7ac295c45df12 | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [278 보존본](queue_archive/ORDER-278.md)에 있다.

## 2026-09-20 (Codex — 중국어 경마 착순8값 복구)

- [278](queue_archive/ORDER-278.md): 제품fc4e68e·검토eca37ef, 독립 Poincare 한정GO/필수0.
- 기존 베팅설명4키×CN/TW8값을 복구했다. 순위를 인원 수로 읽던 오탐6을 정확한 원문·ID의 착순 구절에서만 수리했고, 선택 말 수·순위·순서·배당은 바꾸지 않았다.
- 공식39929/b123/meta9. 기존39921 source/target hash·UI/portable raw 역복원·JA·원문 manifest 보존. 고정 정상8·변이24·OFF11 및 명명12 PASS.
- 실제 화면·원어민·인간·물리패드 미관찰. 공개GO1·인간OPEN45·본편HOLD 유지. 기존보류80중8복구·72미수용, 과거 보고 원형 보존.

## 다음 안전한 범위

- 남은 UI와 동적인자·직행EN은 전체 번역완료와 별개다. UI사전3016 중 CN/TW각2129키 부재는 전체 live UI 분모가 아니다.
- ROOT가 post278-next-slot-ui-scope.json 12015B/SHA12ff8abdbc940a5fbc1862b45e5351c038c6c2943f6c5845c9cd205cdb2b9a30를 전량 읽었다. 다음 후보는 슬롯21키×CN/TW42값과 JA 손실표시를 대박으로 옮긴 오역1이다. 별도 선언 뒤 저작하며 공유3키의 다른7호출도 포함한다. 조건부 legacy/AP 진입·정적 소비자와 fresh-story 도달/실제화면은 다르다. 동적 win_type4와 직행영문 기계 라벨은 별도여서 패널 전체완료로 세지 않는다.
- 남은 보류72는268의62·270의10이다. 270의 자산 안내5키×2는 KO `3분의 1`을 분 단위로 읽는 오탐2와 같은 단위의 나머지8이다. 새 범위를 선언하기 전에 실제 원고·원형 진단·소비자를 확인한다.
- 월말 흑자1의 net==0 원문 경계·첫 월급2의 투자접근 약속·시장 동적인자와 AP효과·자산10억 절반·저자산 초기판정·고지의 잠/식사 묘사는 별도 원문 정합 대상이다.
- 비보호 shipping 사건11578 세 언어 수용 완료, 잔여843은 참고741·보호102다. 공개판과 역사 인간 판정은 유지한다.

## 활성 사양 원문

# Active Queue Spec: ORDER-279

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-279 [P0·전체 현지화] 슬롯 중국어 21키와 일본어 패배 표시를 바로잡는다

**[~] 2026-09-20 Codex 착수 — 아래 파일만 소유한다.** 부모157 후속,
기준 `9cad07832b6e4eb686d629ea6e75a255e2525620`.
RO 계획 `.git/full-game-localization/post278-next-slot-ui-scope.json`
SHA `12ff8abdbc940a5fbc1862b45e5351c038c6c2943f6c5845c9cd205cdb2b9a30`의
`selected_rows` 21개 전량이 선정 원문이다. main agent가 계획·현지화3정본과
실제 손실/총지급/순익 소비자를 직접 읽었다.

## 깊이 3문

1. 지우면 무엇이 깨지는가: 중국어에서 슬롯 안내21키가 영어 폴백으로 남고,
   일본어의 실제 패배2호출이 `大当たり`로 표시되는 의미 역전이 남는다.
2. 24주 뒤 무엇이 다른가: 금액·확률·상태·플래그 불변, 같은 결과를 정확한
   대상언어로 읽는다. 번역 키 추가로 도박 진입/AP를 활성화하지 않는다.
3. 무엇과 경쟁하는가: 기존 본문 재검사 대신 확인된 UI 결손과 의미 역전을
   고친다. 실제화면과 원어민 판정을 사전 키 수로 대체하지 않는다.

## 한 배치 / 21 원문 단위

- CN/TW를 KO에서 각각 독립 작성해21씩42값을 추가한다. 한국어
  `[color=#4a4a6a]— 꽝 —[/color]`의 JA 한 값만 실제 패배로 수리한다.
- 총지급 `gain`과 누적 순익 `gain-stake`, near miss와 실제 패배, 원화 인자,
  200/50/20/15/1.5배, BBCode·%s6·%d/%s 순서를 유지한다. 손실을 보상이나
  다음 당첨 약속으로 옮기지 않는다. 공유3키의 다른7호출도 전수 대조한다.
- 실제 source-bound export로 비보호·정적 소비자·accepted 충돌을 재확인하고,
  비저자 전수 검수와 기존 check를 거친 뒤 append/JA1수리한다. 새 target hash
  export/import receipt로만 원장에 기록한다. 새 checker 예외는 비소유다.
- 정상 수용 목표43: 공식39929→39972/b124/meta9. 원형 보류72는 별도다.
  원고나 기계 결함은 원형을 보존해 같은 원문 모집단에서 수리하며 수용 수를
  목표에 맞추어 조작하지 않는다.

## 정확한 파일 소유권

- `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`: 위21키씩 append만.
- `locale/ui_ja.json`: 위 색상 패배 키의 한 값만.
- `content/meta/full_game_localization.json`: 실제43 receipt 및 한 배치만.
- `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`, 이 사양과 `docs/queue_archive/ORDER-279.md`,
  `docs/agent_reviews/ORDER-279.json`, `docs/agent_review_decisions.json`.

원문·런타임·입력·효과·확률·checker·collector·project.godot·저장·공개 데모·
인간 원장·다른 JA행·보류72는 비소유다. `.git/full-game-localization/order279-*`에
KO/source/초안/검수/최초 실제 결과를 보존한다. 저자와 독립 검수자 파일 소유를 나눈다.

## 검증과 한계

3지역 실제 check/import·old39929 hash·UI/portable 역복원·한영/게임소스·공개/인간
보존 뒤, clean source와 STATUS-only 검토 HEAD를 결속한다. 기존 명명
`news-panel-locale-only`12검사 목록만 재사용하고 기준부터 전체 diff가 위13경로
안인지 별도 확인한다. 독립 비저자가 실제43값·의미·공유호출·receipt·보존·명명12를
전수 검토한 한정 work_unit 판정 뒤 metadata6으로 닫는다. 전체 감사·엔진·240주 없음.
조건부 legacy/AP hub→slot 소비자는 존재하나 fresh-story 진입·화면/입력 미관찰이다.
동적 win_type4와 직행영문 기계 라벨은 비포함이라 슬롯 전체 번역완료로 세지 않는다.
공개GO1·인간OPEN45·본편HOLD·원어민/인간/물리패드 미관찰 유지.
자동 통과는 계약 증거이지 재미·깊이·문체의 증거가 아니다. 기존 WORK_UNIT/I18N
규칙 재사용, 새 규범 없음. 선정·소유·검증은 일회성이다.

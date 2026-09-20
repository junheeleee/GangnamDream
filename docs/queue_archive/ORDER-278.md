# ORDER-278 — 중국어 경마 착순 설명 복구

[x] 2026-09-20. 비저자 Poincare work_unit 한정GO, 필수 결함0.

- 제품 `fc4e68e9e2c94afcb444b485b9f20751a7c5071a`, tree `281a89a29dba6ec2797cde88b1b557177edf9b50`. clean 검토 `eca37efd7d67f1e0fde0670807543c68fd7981ae`, STATUS-only wrapper.
- 기존269의 베팅설명4키×CN/TW8값을 재저작 없이 전량 KO/consumer 대조하고 수용했다.
- 정확한 KO/ID·두 지역의 착순 span만 숫자 비교 view에서 구별했다. 원 target 및 실제 순위·선택수·배당·순서규칙은 불변이다. 기존 정보상 원화 수리와 전체 이전 checker 기대값을 보존했다.
- 수정 전 정상8 중6 FAIL·2 PASS 원형과43direct/41full 결과를 보존했다. 수정 뒤 정상8 PASS 선행·변이24 거부·OFF11 각 API baseline 배열 불변이다. 빈 ID는 direct2만 가능하여 full로 발명하지 않았다. 진단 수집 exit0은 원고 전체PASS가 아니다.
- 명명12 PASS. 실제 수용39929/b123/meta9, 기존39921 해시·UI/portable raw 역복원·JA·원문 manifest 보존. 과거 보류80중8복구·72미수용, 원형 보고 유지.
- [독립 보고](../agent_reviews/ORDER-278.json) SHA `aca84a8d5aa19a4bf51b2f444768b4e8896b5d3d37964b1503dd8355a4a4f4c5`. 원어민·실제화면·인간플레이·물리패드 미관찰. 공개GO1·인간OPEN45·본편HOLD 유지.
- 소유·선정·배치·검증은 일회성. 기존 WORK_UNIT/I18N 규칙 재사용, 새 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 최초 실제 캡처

git-private에 원 stdout/stderr bytes·SHA·exit·입력핀을 보존한다. baseline PASS는 예상 진단 수집 완료일 뿐 수정 전 원고 전체PASS가 아니다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order278-accept-cn-first.json | 377820 | fd4e356e6fd1623d49b73b3997ec6a0ad9870588fd49f891e096ab4dc2d7833a | 0 | PASS |
| order278-accept-tw-first.json | 377829 | 62c09bfbdda59a7a82cfbdc51dd87cd78931c494a377d5b919071312b7792e9c | 0 | PASS |
| order278-applied-export-cn-first.json | 377884 | d0a6805e1d966979e48737cb712983f727753f714762868b2d3b0199898079a8 | 0 | PASS |
| order278-applied-export-tw-first.json | 377890 | 28aaf7fad0f3cc9a2cb4829593ed20ba3c1531009b1d2e9451480aef682b85ae | 0 | PASS |
| order278-cases-baseline-first.json | 485757 | 76d6c628de14fbd5939adcfe32819bf4391af002f6949e4173b44a0fb8b5e637 | 0 | PASS |
| order278-cases-post-first.json | 490775 | dfabc850006afd59117c199b544516419c2d7b5911cbcd4459b3c2638829e608 | 0 | PASS |
| order278-export-cn-first.json | 377891 | 3543726773e9f870b248395ca6c748f9d8017fbd35ca55539dac4930c83a6365 | 0 | PASS |
| order278-export-tw-first.json | 377884 | aebf3d8bb20817c27dcb846d4fd9d9ccec835aab37b5cfef15002ecef4b17e08 | 0 | PASS |
| order278-named-envelope-first.json | 379934 | ca56a1b0d65d59fad6d70058e65cd3227c8489408997c3fc23833dd58e9e0ef6 | 0 | PASS |
| order278-named-first.json | 1696326 | 041837bf91c8d5a46984a343ce444bce4458b7453ce758c7926539ff7c8a1446 | 0 | PASS |
| order278-preflight-cn-first.json | 377808 | 99ca46269e421baf8bc3e187d1f200a9b0a4a4e0b85be803187c4547843b1968 | 0 | PASS |
| order278-preflight-tw-first.json | 377808 | 4641e36da16728b46c860671eb867cede6f539b634857a0de67752c10037b3a8 | 0 | PASS |
| order278-preservation-first.json | 378129 | c214d68d9e4614df4c5b93daa3614ece305b763dc30860317258bc6baf8cb3c2 | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·선언·검증 원문은 [277 보존본](queue_archive/ORDER-277.md)에 있다.

## 2026-09-20 (Codex — 정보상 중국어10값 복구)

- [277](queue_archive/ORDER-277.md): 제품9f16504·검토8720193, 독립 Poincare 한정GO/필수0.
- 기존 원고5키×CN/TW10을 다시 쓰지 않고 복구했다. 정상 원화 비용2의 검사 오탐만 exact KO/ID·비용 슬롯 source-view로 수리했으며 지출3,000원·돈 부족·신뢰도·확률은 불변이다.
- 공식39921/b122/meta9. 기존39911 source/target hash·UI/portable 역복원·JA·원문 manifest 보존. 수리 전 진단과 고정 정상/변이/OFF 보존, 명명12 PASS.
- 이번10값 실제화면·원어민·인간·물리패드는 미관찰. 공개GO1·인간OPEN45·본편HOLD 유지. 기존보류90중10복구·80미수용, 과거 보고 원형 보존.

## 다음 안전한 범위

- 남은 UI와 동적인자·직행EN은 전체 번역완료와 별개다. UI사전3016 중 CN/TW각2133키 부재는 전체 live UI 분모가 아니다.
- ROOT가 RO 메모 order277-next-ui-scope.json 12186B/SHAf41ec6241e00eeac881cd18f42da614a04174aeff6ded2065573bdd2bcd21f24를 전량 읽었다. 조사한 설정/기록/StoryMode 직접 UI는 이미 중국어가 있고, 나머지는 미호출/AP/직행EN 또는 발화조건 미확정이었다. 새 즉시선정0은 이 제한된 조사 결과이지 전체 UI완료가 아니다. 월말 개선문장2는 실제 양수 변화 producer 확인 전 번역수량으로 채우지 않는다.
- 다음 보류 수리 후보는 착순6오탐의 베팅설명4키×2=8값이다. 정보구매 비용 수리를 순위나 전역 숫자 예외로 확장하지 않는다. 기존 RO메모 post276-held-repair-plan.json의 deferred_alternative와 원형269보고를 재확인하고 별도 선언한다.
- 보류80은 268의62·269의8·270의10이다. 원어민·전체화면·미번역 동적값을 채웠다고 세지 않는다.
- 월말 흑자1의 net==0 원문 경계·첫 월급2의 투자접근 약속·시장 동적인자와 AP효과·자산10억 절반·저자산 초기판정·고지의 잠/식사 묘사는 별도 원문 정합 대상이다.
- 비보호 shipping 사건11578 세 언어 수용 완료, 잔여843은 참고741·보호102다. 공개판과 역사 인간 판정은 유지한다.

## 활성 사양 원문

# Active Queue Spec: ORDER-278

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-278 [P0·전체 현지화] 경마 착순의 중국어 수량 오탐 수리와 보류 설명 8값 복구

**[~] 2026-09-20 Codex 착수 — 아래 파일만 소유한다.** 부모157의 후속이며
기준은 `1447e4eb0fbbd630126108559914981a9e4446a7`이다. 269 원형 보고의
`bet_type_explanations` 4키×CN/TW8값 전량이 모집단이다. 새 번역을 만들거나
보류 모집단을 줄이지 않는다. 지난277의 정보상 비용 수리는 그대로 보존한다.

## 깊이 3문

1. 지우면 무엇이 깨지는가: 정확한 착순 `第1·2名` 등을 인원 수로 오독하여
   올바른 경마 설명6값이 거부되고 같은 단위의 단승2값도 수용되지 못한다.
2. 24주 뒤 무엇이 다른가: 상태·경제·도박 규칙은 불변이며 해당 중국어 UI는
   영어 폴백에서 KO 직접 번역으로 바뀐다. 새 선택이나 재미의 증거가 아니다.
3. 무엇과 경쟁하는가: 전역 `名` 예외나 검사 맞춤 원고 개작 대신, 정확한
   KO/ID·지역의 실제 착순 span만 구분하고 잘못된 순위·수량 검사는 유지한다.

## 하나의 판정 단위

- `scenes/RaceTrack.gd::_bet_desc`의 연승·단승·복승·삼쌍승4키와
  `systems/HorseRace.gd` 지급 규칙을 원형8값과 전수 대조한다.
- 선언 뒤, 구현 전 정상8·착순 누락/추가/교체/재배열·말 수 변경·분류사
  교체·여분 수량·KO/ID/locale 경계 OFF의 유한 사례와 드라이버를 봉인한다.
  현 checker의 실제 direct/full API 오류 배열을 보존한다. 정상 통과 전 음성
  거부를 수리 성공으로 세지 않는다. OFF는 각 API의 baseline 배열과 같아야 한다.
- checker만 exact source-bound span 구분을 더하며 토큰·줄바꿈·문자·통화·
  용어 검사와 이전 self 기대값을 바꾸지 않는다. 전역 ordinal/名 면제 금지.
- 기존8값을 원문 직접 독립 검수하고 source-bound export/check 뒤 append한다.
  새 target hash export/import receipt로만 공식 원장을 갱신한다.
- 기존39921 수용 hash·UI 및 원장 역복원·JA·원문 manifest·공개판·인간 판정을
  보존한다. 정상 수용 시39929/b123/meta9, 기존보류80→72이며 검수 GO 전 수량은
  목표이지 완료가 아니다.

## 정확한 파일 소유권

- `tools/zh_translation_audit.py`: 위 착순 오탐의 helper·hook·표적 self-test만.
- `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`: 원형4키×2 append만.
- `content/meta/full_game_localization.json`: 실제 신규8 receipt 및 한 배치만.
- `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`, 이 사양과 `docs/queue_archive/ORDER-278.md`,
  `docs/agent_reviews/ORDER-278.json`, `docs/agent_review_decisions.json`.

원문·런타임·collector·full_game_localization.py·JA·게임 효과·확률·저장·
project.godot·공개 데모·인간 원장·다른 보류72값은 비소유다. 사설 증거는
`.git/full-game-localization/order278-*`에 최초 출력과 실제 실패를 보존한다.

## 검증·판정

고정 direct/full 사례→지역별 실제4값 check/import→39921 보존을 수행한다.
clean 제품과 STATUS-only 검토 HEAD를 결속하고 기존 `news-panel-locale-only`
명명12 검사 목록을 재사용한다. 목록은 검사 선택용일 뿐 과거 오더 소유권을
상속하지 않으며 기준부터 전체 diff가 위13경로 안인지 별도 확인한다.
독립 비저자가 실제8값·checker diff·정상/변이/OFF·수용·보존·명명12를 전수
검토한 뒤 `work_unit` 한정 GO/HOLD를 기록한다. 폐쇄 문서 뒤 metadata6만 확인한다.
전체 감사·240주·엔진·화면/입력 검사는 실행하지 않는다. 이8값의 렌더·원어민·
인간 플레이·물리패드는 미관찰이며 본편HOLD·공개GO1·인간OPEN45를 유지한다.
자동 게이트는 도달 가능성과 계약 증거이지 재미·깊이·문체의 증거가 아니다.
새 규범은 없고 원문 직접 번역·증거/권한 분리는 기존 정본을 적용한다. 일회성.

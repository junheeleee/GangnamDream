# 칭호 도감·해금 안내 세 언어 현지화

#### [~] ORDER-253 칭호 도감 안내 번역

[~] 착수 — 2026-09-13, Codex.252 수리·최종 검증 동안 private 저작만 병렬로
진행한다.250/251/252 독립 마감 전 제품 UI·fixture·수용 원장은 변경하지 않는다.
사전 UI/원장 source는4cda91a이며 현재252의 ZH 검사 hook 적용과 혼동하지 않는다.
실제 적용 전 clean HEAD와 원형 핀을 다시 결속한다. 현재38818/b102/meta9다.

## 하나의 화면 계약

칭호 도감의 등급·획득 상태·분류·제목·요약과 해금 toast/log의 기존20키다.
JA20은 존재하지만 아직 이20의 정식 수용은 없고 CN/TW는 각각20키가 없다.
KO에서 직접60표면을 검토하며 JA uncommon/rare가 모두「レア」인 혼동을 구분한다.
JA는 필요한 선택 행만 정밀화하며 원형5개 tab행과 비선택 값·서식을 보존한다.
CN/TW 각20 추가, 정식20×3 수용 뒤에만38878/b103(meta9),
JA12958·CN/TW12960으로 센다. 사전 수치이며 공식 collector/export로 확인한다.

키20: `칭호 해금: 「%s」`, `칭호 해금: %s`, `획득`, `미발견`, `칭호 도감`,
`해금 %d / %d  —  플레이를 거듭할수록 칭호가 늘어납니다.`, `일반`, `희귀`,
`레어`, `전설`, `주거`, `ui.meta.career_category`, `투자`, `성향`,
`ui.meta.lifestyle_category`, `자산`, `메타`, `미니게임`, `이야기`, `미발견 칭호`.
context2의 원문은 직업/생활이며 기존 식별자·등록을 유지한다. printf3키4토큰의
순서·타입과 요약 수량을 보존한다. 구분자가 있는ID는 공식 owner/path로 읽는다.
없으면 중국어 칭호와 주변 영어 안내가 섞인다. 선택·1년/5년·게임 효과는 변경0이다.

## 소유권·보존

- Rawls: 세 언어60 private 저작·JA 정밀화 근거. ROOT만 `locale/ui_ja.json`,
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 승인된 값에 적용한다.
- Plato: `tools/MetaTitleLocaleCheck.tscn`, `tools/run_meta_title_locale_qa.sh`의
  기존405 부모 기대 갱신과 신규 도감 안내5그룹 private 저작. ROOT가 검토 후 적용한다.
- ROOT: `tools/audit_scope.json` 명시 영향 차선, `content/meta/full_game_localization.json`
  공식 수용, 실제 실행·Git·큐·WORK_LOG·STATUS·CLAUDE·현지화 backlog·본 active/archive·
  agent_review_decisions·agent_reviews/ORDER-253.json.
- Poincare: 비저자60 전량 언어·fixture·실제 결과·최종source 독립 검토.

제품7파일만 소유한다. MainGame/MetaProgression/GameState/LocaleManager,
KO/EN·원문 ID·조건·희귀도 코드/색·보너스·캐시·저장·source-history helper·
audit.sh·검사기252·project·공개 데모·인간 원장은 변경0이다.
공유 투자6호출(INV/Invest/Investment), 자산3·주거2의 동일 legacy 값을 고려한다.
미선택 top버튼의 언어 갱신, bonus8, 이미 번역된 ending부모5·관계/닫기,
나머지11칭호 원문/조건은 별도다. 이 묶음으로 전체UI나AP 도달을 완료로 세지 않는다.

## 검증 계약

승인표를 실제 UI 출력으로 역작성하지 않는다. 독립 승인 부모20 기대표와 작은 조회
hook3으로 기존405 ID·칭호/조건 기대를 유지한다. CN/TW 부모 영향40그룹과 JA등급
정밀화 시12그룹은 새 기대를 검증하며 옛 영어 기대를 통과했다고 하지 않는다.
true log의 message만 승인 template로 달라지고 날짜/turn/type/count/order·
게임 상태 전체·실제 delta·저장 비교는 유지한다. false log는 계속0이다.
KO/EN 및 비선택 기대 변경0이며 실제부모를 역사 영어로 바꿔 통과시키지 않는다.

신규5는 언어별 `title_parent/collection_chrome` 1그룹이다. 각 그룹의 잠김0/50,
기존SELECTED9 해금9/50 두 상태에서 실제 제목·요약·분류9를 확인한다.
11×2×5=110 라벨 비교는 nested이며 새110실행으로 더하지 않는다. 관계 분류·
순서/구조·상태도 보존한다. 기존405+신규5=410의 격리 component 검사다.
통과가 화면 잘림·원어민·사람 실플레이 증거는 아니며 실제 저장에 접근하지 않는다.

공식 source/export20→승인60 L1→UI 적용/actual410→같은exact export/check/import와
이전38818 raw역복원→전체수용L1·명시 영향 검사→독립 단위판정으로 마감한다.
첫 실패를 보존하고 새 원인이면 별도 좁은 단위로 다룬다. 로컬 full audit·240주와
불필요한 과거 재실행은 하지 않는다. 규범은 기존 원문/상태 보존 정본을 따르는
일회성 번역 지시다. 공개GO1·인간OPEN45·본편HOLD·원격후보별 증거 경계를 유지한다.

## 첫 언어·수집 관측

250/251/252는source37fdd2e·검토35ad63a의 독립 단위GO로 닫았다. metadata6 통과 뒤
검토a88e5c8을 main/원격mirror에 atomic FF했고 새CI34705778523/34705778222는 실행 중이다.
새253의 통과로 해석하지 않으며 손상된 로컬mirror/사용자저장 변경0이다.
언어60 전량 독립검토 필수0. 승인표4837B/SHA02cc0df72be5b22389a75f1b319077b4ca225e0e8c55d2e9908c736c678dc5ec.
공식20×3 source export와 같은60 L1 오류0, 각각1194입력 불변이다. 신규수용은 아직0이다.
JA18유지·희귀/요약2정밀화, CN/TW각20을 적용했고 세UI 모두 이전raw 역복원exact다.
격리 actual410·final export/check/import·전체 수용 회귀·최종 단위판정은 후속이다.

독립 runtime 사전검토9809B/SHAf4e36067fe369cbc5974f3de393d050d84d216dac4d83c525193fe3b5547e5ff,
필수0이다. 원형405 ID/26상수/99함수와 새5/110중첩·상태/저장 경계를 확인했다.
ROOT가 승인 비트와 승인표/언어/런타임 검토SHA만 결속해 runtime2를 적용했다.
실행 성공을 미리 기록하지 않으며 첫410은 이 적용본을 clean commit한 뒤 수행한다.

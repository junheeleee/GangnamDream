# 주사위 칭호의 세 언어 수량 검사 오탐 수리

#### [~] ORDER-251 주사위 수량 검사

[~] 착수 — 2026-09-13, Codex. source `d56c991ba6649f6f379ab0b4116dd92de90528ea`.
첫54 L1은51PASS/3FAIL이며 `order250-l1-first.json` 401447B,
SHA `8720d4046a43e9b30077f04d66f11eb397563d1f425679394bb9be0ac1ac1a0c`에 보존했다.
대상은 “다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.”의
JA `3個のサイコロ`, CN `三颗骰子`, TW `三顆骰子`다. 수량은 원문과 같지만
JA 숫자열 검사와 중국어 entity 분류기가 동등한 표현을 인식하지 못한다.

## 범위·소유

- Rawls: `tools/full_game_localization.py`의 exact UI leaf/source/locale에 한정한
  `_ui_dice_title_numbers` 및 JA 숫자 비교·ZH validate_text의 작은 연결만 저작한다.
- Plato: `tools/full_game_localization_self_test.py`의 한 메서드와 독립 pre-code
  literal 대조를 준비한다. 기존261 메서드·기대 원형을 보존한다.
- ROOT: `tools/audit_scope.json`의 명시 차선과
  `tools/meta_title_locale_successor_self_test.py`의 새 MG9 단계에서 검사기2개 의존 핀만
  실제 변경 바이트로 재결속한다. 고정23·구19/24/18·원형 역변환 기대는 변경0이다.
- ROOT 운영: 큐2·본 active/archive·WORK_LOG·STATUS·CLAUDE·현지화 backlog·
  `agent_review_decisions.json`·`agent_reviews/ORDER-251.json`.
- Poincare: 비저자 독립 코드·대조·실행 증거·최종 source 검토.

제품 소유4파일이다. 일반 중국어 counter 규칙·기존249 helper·JA parser·원문·번역54·
UI3·MetaProgression·조건·producer·보너스·실제405 fixture·project·인간 원장은 변경0이다.
없으면 올바른 세 번역을 정식 수용하지 못한다. 게임 선택·시간·1년/5년 상태는 영향0이다.
새 판정 가능한 결함이므로250의 정상 기대를 완화하지 않고 별도 단위로 처리한다.

## 고정 대조와 정규화 경계

helper 구현 전에 실제 정상3과 자연 수 표기, 숫자·부호·소수·횟수/주사위 소유 교환,
잘못된 단위·위치·추가/누락·중복 수량, 독립 placeholder 진단, 원문/키/locale OFF를
독립 검수자가 literal로 고정한다. ROOT는 기존 검사기에서 같은 모집단의 첫 결과를
전량 보존한다. 정상 기반 실패 때 부정 검출 효력을 PASS로 부풀리지 않는다.
새 함수는 exact 원문·UI 식별자·세 locale 이외에는 None이다. 원문15회와3개의 역할을
구별하고, 원래 텍스트는 토큰·문체·script·화폐 등 기존 검사를 계속 통과해야 한다.
오류가 있으면 원래 쌍을 반환하고, 성공 때만 소유 숫자/단위 span을 동등하게 정규화한다.
문장 전체 강제 치환이나 임의 숫자 삭제·전역 카운터 확장·원화 변환은 금지한다.

## 검증·마감

첫 대조·수리 뒤 같은 대조·원래54 L1을 분리한다. 모든 첫 실패와 실제 오류를 보존한다.
새 helper가 현재 source23의 검사기 의존 핀을 바꾸므로 MG9 현재 단계의 그 두 핀만
재결속하고 이유와 전후 SHA를 남긴다. 기존 source4와 whole old self 역복원은 그대로다.
250의 실제405는 입력19가 불변일 때만 그 component 증거로 재사용하고 재실행하지 않는다.
동일54 공식 export/check/import·수용38,764 보존·전체 수용 L1은250이 소유한다.
두 작업의 중복 영향11 검사는 최종 깨끗한 source에서 고유 차선 한 번으로 공유하되,
각 작업의 검토 보고에 실제 코드·입력 신원과 적용 범위를 별도로 결속한다.
로컬 full audit·240주·새 CI 반복을 추가하지 않는다. 독립 단위 판정 뒤에만 마감한다.
본 단위 지시는 일회성이며 기존 수량·원문 안전선 규범을 바꾸지 않는다.
공개GO1·인간OPEN45·본편HOLD와 native/render/인간 관찰 미실시를 유지한다.

## 첫 고정 대조 관측

독립 PRECODE40은 정상9/숫자·역할변조22/독립진단변조4/OFF5다.
`order251-dice-controls.json` 64185B/c2806e4d2c431f280460603d3ac98081357c50bf2c557cbdf8318b95a02e48ab.
ROOT는 구현 전 같은40을 전량 실행했다. `order251-baseline-first.json`
452565B/d211a3f1be9b3ba592a84a1f1c9d516ac80c6b9a83eff7de58d54a49e80f616e,
0.493초/입력1193 불변/예외0. 정상 full0/9·유효변조0이며 baseline 기록 성공을
수리 통과로 세지 않는다. 잘못된 JA 주사위 개수 누락은 기존 검사가 놓쳤다.
원문 script·placeholder·BBCode·돈·LF 진단도 별도 캡처했다. cross-script 2는
정확한 수량을 helper에서 허용해도 원문 `_script_errors`를 보존하여 full은 거부해야 한다.
이후 동일40·원형261을 바꾸지 않는 helper/self 저작을 병렬 진행한다.

## 수리 뒤 첫 대조

exact helper1과 self 메서드1을 적용했다. 기존261 tests/21 helper 및 검사기49함수는
raw 역복원으로 보존했다. MG9_SPEC 의존핀만 full `90b2f806…→9aa3e45c…`,
self `0dc399b9…→7c6619c4…`로 재결속했다. source23·역사19/24/18 기대 변경0이다.
`order251-post-first.json` 501219B/daaf5cb2ecb9cd96040b77b0507c0f8b4a31ca85415761faf0d4aec60fe39897,
exit0/0.554초/입력1193·내부10 불변. 정상9·유효변조26·OFF5가 전부 기대대로다.
원래54 L1 재검사도 오류0, 401351B/0a58464e9e415c2c8f037b65c85e3cd76335f5634b6ab08b3329d56ada506dcf.
원형 첫 실패3·baseline40을 보존했다. 정식 수용·최종 공통11·독립 단위판정은 아직이다.

후속 named11에서 fullself262는 통과했지만 직접 ZH 감사가 같은 문구2를 거부했다.
이 직접 소비자 hook은 본 소유권 밖이므로252로 별도 선언했다. 기존40·코드·번역은
그대로 두며 첫 named 실패를 지우거나251 최종 GO로 기록하지 않는다.

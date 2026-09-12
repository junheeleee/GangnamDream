# 중국어 칭호 ‘두 길 사이’ 수량 검사의 오탐 수리

#### [~] ORDER-246 칭호 수량 검사 정합

[~] 착수 — 2026-09-12, Codex. 기준 제품 main `ea7bf23`.
일회성 원인1/고정24대조군/1배치다. 245의 추가60 수용과 별도 판정한다.

## 실측과 깊이

첫60 L1에서 CN/TW 두 문구만 `unmatched target entity quantity invented: 2`다.
한국어 ‘두 길 사이’는 두 갈래 길을 명시하고 两条路之间/兩條路之間는 정확하다.
기존 한국어 추출기는 관형 수사+길을 세지 않지만 중국어 条/條는 수량2로 읽는다.
기준 증거 c538abdd608004309280c3dbae51a2e0d1d257d8858c4da53137d4517d08c891.

깊이3문: 없으면 정확한 두 표제를 공식 수용할 수 없다. 선택/24주 상태 변화는
없으며 수량 오역 차단만 바꾼다. 일반 수사 파서를 넓히는 것과 경쟁하므로,
두 locale·전체 leaf ID·원문 exact인 한 표제에만 제한한다. 1년/5년 서사·숫자·
획득 조건·저장·번역60·공개 데모·인간 원형 변경0, 본편HOLD 유지.

## 파일 소유권

- Root: `tools/zh_translation_audit.py`의 신규 exact 표제 숫자 어댑터와
  `validate_text`의 numeric_pair 연결, `tools/audit_scope.json`의 영향 차선.
- Plato: `tools/full_game_localization_self_test.py`의 신규 고정24 검사1개.
  기존 함수/기대/표본을 변경하지 않는다. private baseline runner는 같은24다.
- Root 운영: CLAUDE, 큐2, active/archive246, WORK_LOG, STATUS, localization backlog,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-246.json`.
- Rawls: 원인·사전 고정24 저자, 제품 수정0. Poincare: 비저자 전체 검수.

`tools/full_game_localization.py`는 기존 CN/TW 위임 경로 그대로이며 수정하지 않는다.
245 source/self/actual/UI·portable·옛 Chapter/map/원장/원형 pin과 손상 local mirror는
이 단위의 수정 범위가 아니다. 원격41e06cd CI는 243/244의 별도 증거다.

## 먼저 고정할 검사와 구현

private `order246-two-paths-precode-spec.json` 15,527B,
SHA704408926322a8c61f13c6d170e3621260905414954878823c08c868bbb98aae.
24는 정상6·유효 정상base가 필요한 변조14·OFF4다. 첫 관측은 실제2뿐이고
나머지는 실행 전 기대다. 먼저 같은24의 direct ZH/full wrapper 원형 결과와
source/test/UI/첫실패 핀을 저장한다. OFF는 그 원형 오류목록과 동일해야 한다.

새 어댑터는 전체 source/key/locale exact로만 적용한다. 표제 전체가
선택적 在 + 부호 없는 수사 + 条/條路 + 之间/之間이며 값2여야 한다.
수사 부분만 NFKC·기존 cardinal 해석을 쓰고, 틀린1/3/0·부호·중복·추가 수량·
다른 명사/관계·무관 접두/접미·돈·token을 정상값으로 감추지 않는다.
성공한 대응 수량 부분만 numeric 비교에서 제거하며 나머지 원문 검사는 유지한다.
숫자 검사 오류문자열 삭제, 일반 두/길 파서 확대, validate_text 조기 성공 금지.

## 닫는 조건과 재사용 경계

baseline24 → 좁은 수리·독립 전체 코드검수 → 같은24 실검 → 245 같은60 L1 →
공식 수용/전체수용L1 및 두 단위에 공통인 영향 검사1회 → 각 단위 독립 판정.
원래 테스트 population은 보존하고 새 unittest1 안의24를 구분해 보고한다.
245 source24/history18·actual200은 입력 원형 보존을 결속하며 재실행하지 않는다.
새 실패는 첫 기록을 남기고 정상base가 실패한 mutant를 유효 PASS로 세지 않는다.
원어민/화면/인간 실플레이·실제 출시 판정으로 확대하지 않는다. 새 규범 없는
일회성 좁은 검사 수리이며 잔여31칭호 번역은 다음 작업이다.

## 구현 전 관측과 수리 후보

- baseline24 원형57119B/SHA15e6f6de: helper 부재24, direct/full 각24,
  입력14 전후exact. 정상6 전부 실패라 변조11의 기존 거부는 유효 통과0이다.
  OFF4의 direct/full 오류목록을 각각 고정했고, 돈2·token1 진단도 보존한다.
- 새 helper와 numeric 연결만 ZH에27줄 추가했다. 역제거하면 기존
  ef58e32b 전체 raw exact이며 후보7e57de05다. 기존 full wrapper 수정0.
- 신규 unittest1 안의 같은24를 추가(80c5aaf0), 제거하면 기존129091d6
  전체 raw exact이다. 기존259개 테스트는 수정0, 후보 전체260개다.
- actual200의 입력19개는 현재도 전부 동일하여 엔진 재실행0이다.
  이 단위 영향7은 245 영향11의 진부분집합으로, 최종 동일 후보에서11만 실행한다.
  아직 수리 후24·공식수용·최종영향검사·단위판정 전이다. 본편HOLD 유지.

후속 첫 post f8b70a0e는 같은24 전량PASS/입력11exact, 독립 c56d919a 필수0이다.
다만 ROOT가 제시된 선택 실행 명령의 main을 확인하지 않아, 인자가 무시되고
실제 전체260이17.95초에 실행·통과했다. 기존259는 통합 결과, 새24만 전량 trace다.
새24 내부 collector0/engine0을 전체260의 관측으로 확대하지 않는다. 첫 결과를
보존하고 별도 선택 재실행은 하지 않았다. 245의 같은60도 오류0·공식수용 완료다.
최종 공통11과 각 단위 독립 판정은 아직 남아 있으며 기존 인간 증거는 변경0이다.

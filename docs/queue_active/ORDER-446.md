# ORDER-446 — 일본어 포카드를 폴드와 구분한다

#### [~] ORDER-446 [P1·오역 수리] 기존 일본어 패 이름 한 값 정정

**[~] 착수 — 2026-10-05.** 실제 `TexasHoldem.rank_name(7)`이 읽는
`locale/ui_ja.json`의 `포카드` 값이 `フォールド`여서 행동 Fold와 혼동된다.
한국어/영어 원문과 이미 수용된 규칙 설명의 `フォーカード`로 정렬한다.

## 범위·소유

- root: `locale/ui_ja.json`, `content/meta/full_game_localization.json`,
  private446 공식 export/response/check/import·normal 집계, CLAUDE·큐/L3·
  이 사양/보관·WORK_LOG·생성STATUS·새 보고/판정만.
- claude_handoff_review: `tools/ui_translation_append.py`의 exact446 dispatcher와
  EOF first-receipt correction proof/comparison, 새 `tools/holdem_rank_ja_receipt_check.py`.
- receipt_tests392: private446 GD/scene·Python oracle/runtime, `tools/audit_scope.json` 표적 차선.
- independent392: 비저자 한국어/JA 의미·정정/보존 proof·실제3PNG·최종 근거 검수.
  root만 공식 교환·collector·검사·엔진을 실행한다. 파일 소유는 겹치지 않는다.

## 정정 계약

- 기존 값 `フォールド` → `フォーカード` 하나만 고친다. 정상 Fold 버튼/문장과
  규칙 설명·중국어·KO/EN·게임 코드·UiCall/source manifest는 변경0이다.
- 이 JA 키의 과거 공식 receipt는 absent이며 legacy origin
  `aaeba142d08278c310505000bcc126a699493479`를 실제 Git으로 확인한다.
  공식 export를 먼저 보존하고 `check/import --replace-existing --accept`로
  previous-target hash와 현 한국어1leaf를 결속한다. check에는 accept가 필요 없다.
- 선언 직후 JA 사전+수용 원장 두 파일만 제품 커밋한다. 실제 전후 commit/tree·
  사전3개/원장4파일 raw·blob을 결속한 exact correction으로만 기존 값 정정을 허용한다.
  원장에 첫 receipt1·별도 correction batch1을 추가하고 과거 receipt/batch를 바꾸지 않는다.
- accepted41736→41737/b216→217, JA accepted13134→13135이며 사전 JA3048 키는
  그대로다. 새 UI키/새 번역 coverage0, 기존 오역 정정1/첫 official receipt1로 구분한다.
  기존 generic append·414 proof·memo·collector·Holdem 전이 소유 코드는 바꾸지 않는다.

## 표적 검증

- exact4파일 raw 역상·실제 Git/leaf/legacy provenance·이전 JA receipt 부재·새 official
  header/receipt와 주변 값/과거 raw·token·batch·다른 locale 변형 거부를 새 focused로 확인한다.
  역사 focused/engine/전체 교차곱을 재실행하지 않는다.
- JA 실제3PNG: 준비 FLOP 포카드 현재 패, 준비 SHOWDOWN 플레이어 포카드 승리,
  준비 SHOWDOWN 상대 포카드 승리. 합법52장 partition·실제 rank_name/_tr/_fmt와
  표시 builder를 쓴다. 돈 지급·dispatcher·AI·첫딜·입력·Close0이다.
- 실제 승패문구/정산 요약은 준비 reader 값이고 자연 정산 증거가 아니다.
  히스토리 원값은 전체 `フォーカード`, 원래3글자 표시 `フォー`를 각각 검증한다.
  정상 폴드의 `フォールド`까지 금지하지 않는다. 기존 summary pulse는 자연 완료 후
  font/glyph/fit/global bounds를 보고 whole typed/RNG/Meta bytes/semantic focus1회 복원한다.
- fresh focused·receipt·JA UI·EN·context·queue·diff·등록8검증+차선조회1.
  CN/TW/fullbody·완료 규칙 설명/배너/베팅·과거 focused/runtime·서사4종·전체감사/
  240주·성능 A/B는 NOT_RUN 참조다. 실패 원본 보존·원인만 수리한다.

## 한계·일회성

- 패 이름을 읽는 기존 소비자 수리이며 선택/돈/24주 결과를 새로 만들지 않는다.
  직접 영어 배너·다른 오역·자연 진행/후속라운드·다른 해상도는 별도 범위다.
- 기존206판정/184보고·인간OPEN45/DONE1·공개GO1·본편/새package HOLD와
  실제player34·사용자 변경을 보존한다. 자동 PASS는 계약 증거이며 원어민·인간·
  물리패드·출시 GO가 아니다. 지시는 일회성, 기존 I18N 정정 계약을 적용한다.

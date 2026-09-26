# Active Queue Spec: ORDER-290

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-290 [P0·전체 현지화] 블랙잭 현금·손익·승률 중국어 HUD

[~] 착수 — 2026-09-26. 만지는 파일은 아래 정확 소유만.

## 목적·분모·깊이 3문

사용자 ‘순서대로 진행해’의 첫 단계다. 기준 `4bbcb6e155854bcd8756b291eac44cf93817fc15`.
`scenes/BlackjackTable.gd:_refresh_hud`의 한국어 2키를 CN/TW 각각 직접 번역한다.
기존 JA2는 보존한다. 삭제하면 현금·손익·누적 승률 HUD가 영어로 남는다.
새 선택이나 24주 상태 변화가 아니며, 같은 고정 HUD 행의 공간과 경쟁한다.
2키는 분리할 수 없는 부모·fragment 소비자 묶음이므로 수량을 늘리지 않는다.

1. `  승률 %d%% (%dW/%dL/%dP)` — 해결된 hand의 W/L/P, 미래 승률 보장 아님.
2. `[b]현금 %s[/b]   |   블랙잭%s   손익 [b]%s[/b]` — 현금·누적 손익, gross 아님.

## 정확 소유·분업

- ROOT: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 위 2키 append만.
- ROOT: `content/meta/full_game_localization.json` 공식 4값·batch1 append, 기존40129/b130/meta9 보존.
- ROOT: CLAUDE 현재 한 줄, CODEX_QUEUE 및 L3 이어보기 순번, 이 사양/종료 archive290,
  WORK_LOG·STATUS·agent_review_decisions append1·agent_reviews/ORDER-290.json.
- QA 저자: git-private `order290-blackjack-observer.gd`, `order290-render.py`만. 기존287
  격리 부트스트랩·캡처·경계 검사 축소 재사용. 실행은 ROOT만 담당.
- 독립 검수자: git-private `order290-language-review*.json`, `order290-independent-review*.json`만.
- ROOT git-private `order290*` 배치/응답/수용/검사/증거 helper. 기존 증거 overwrite 없음.

런타임·KO/EN·JA·project·사용자 저장·공개 데모·human_gates·기존 검사와 래칫 불변.
다른 금융/규칙/EV·직행 영어·동적 결과·AA/정산은 제외한다. 보류72는 그대로다.

## 순서·표적 검증

1. 선언 commit·동기화 후 exact leaf export, CN/TW 독립 초안·비저자 4값 전수 검수.
2. check→append→현재 target으로 새 export/check/import --accept. portable4값·batch1.
3. 기존40129 source/target과 사전·portable raw 역복원, JA/공개·인간 바이트 보존.
4. 기존 `news-panel-locale-only` 명명12 목록만 재사용, 전체 baseline diff 소유권 별도 검사.
5. 1280×800 언어당4 준비된 HUD 상태: W/L/P 0/0/0 net0; 2/1/1 +150000;
   1/2/1 -250000; 1/1/1 net0. 각각 rounds0/3/3/2로 hand 분모와 구분한다.
   실제 `_refresh_hud` 완성 문자열·중첩 fragment·RichTextLabel 내용과 행/viewport 경계,
   8PNG를 확인한다. 딜/정산/합성 입력0, 준비된 표시 fixture임을 명시한다.
6. 매 실행 새 StoryNameplateBootstrap namespace·43 원본 사용자파일 보존·raw stdout/
   Godot log 오류 검사·정확 성공 표식을 확인한다. 첫 실패도 그대로 남긴다.
7. 비저자 최종 검수는 clean source commit/tree와 raw 증거·PNG·4값을 직접 읽고
   work_unit 한정 판정한다. 종료 metadata 관련 검사만 하고 전체감사/240주 생략.

증거: 생산자 위2키→LocaleManager.ui→BlackjackTable HUD; UI/공식 각4값 신규,
서사 위치/계층 해당없음(카지노 HUD), 새 선택/닫힌 경로 없음. 정확 측정은 종료 보고.
규범 승격 없음: 기존 I18N/WORK_UNIT 적용, 이번2키·준비상태·도구 범위는 일회성.
원어민·인간 플레이·물리 패드·패키지·다른 해상도는 미관찰. 공개GO1·인간OPEN45·본편HOLD 유지.

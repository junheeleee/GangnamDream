# ORDER-444 — 홀덤 규칙 설명 두 화면을 일본어·중국어로 읽는다

#### [~] ORDER-444 [P1·현지화] 동적 제목·본문 4키의 일본어·간체·번체 12값

**[~] 착수 — 2026-10-05.** 442 실제 화면에서 영어 fallback인 두 설명 슬라이드를
확인했다. 최신 계속 개발·main 커밋/푸시 위임에 따라 정확한4키만 별도 처리한다.

## 범위·소유

- claude_handoff_review: 새 `tools/holdem_tutorial_ui.py`,
  `tools/full_game_localization.py`, `tools/ja_translation_audit.py`,
  `tools/zh_translation_audit.py`의 provider 연결과 이4키의 실제 검증만.
- receipt_tests392: 새 `tools/holdem_tutorial_ui_self_test.py`,
  `tools/audit_scope.json` 명시 차선, private444 GD/scene·일본어4값 초안만.
- root: private444 한국어 목록·간체/번체 각각 직접 초안·공식 export/check/import·
  append/normal 및 Python runtime runner, `locale/ui_ja.json`, `locale/ui_zh-CN.json`,
  `locale/ui_zh-TW.json`, `content/meta/full_game_localization.json`,
  `docs/I18N_INFRASTRUCTURE.md` provider 소유 계약, CLAUDE·큐/L3·이 사양/보관·
  WORK_LOG·생성STATUS·새 agent 보고/판정.
- independent392: 비저자4키/12값 전수·provider/검사·실제 화면/입력·최종 근거 검수.
  공식 교환·collector·검사·engine 실행은 root만. 이전 helper/증거는 불변이다.

## 정확한 소비자와 수용

- `scenes/TutorialOverlay.gd::_get_slides("holdem")`의 2개 `_localized_slide`
  호출에서 title/body KO/EN 각각을 얻는다. 한국어 원문·런타임 변경0이다.
- title은 `텍사스 홀덤 — 기본 규칙`, `홀덤 — 패 순위 (강한 순)`이며 body는
  각 호출의 literal concatenation 전체다. LF·BBCode·💡·숫자·+EV를 보존한다.
  lookup은 정리 전 raw body이고 표시 body는 `_clean_body_for_surface` 결과다.
- 새 pure provider가 정확2슬라이드·5인자·4고유키와 실제 lookup/표시 소비자를
  확인하고 비literal·중복·추가·잘못된 분기·기존 static/demo/story 중복을 거부한다.
  기존 demo provider/701분모·UiCall·source manifest·append/history는 변경하지 않는다.
  full-game/JA/ZH가 동일 provider를 읽고 허용목록뿐 아니라 실제 문장을 검사한다.
- 세 언어는 한국어에서 직접 별도 저작한다. 공식 export를 먼저 보존하고 실제
  check/import·4파일 raw append 역상으로 accepted41724/b213→41736/b216,
  JA3044→3048·CN/TW1767→1771을 목표로 한다. 이전 receipts/headers/보호 행 불변.
- 실제 정상 번역이 수량 오탐을 만나면 실패를 보존하고 이4개 UI주소·원문·정확한
  패 이름/순위 위치에만 한정한 의미 검증으로 수리한다. 숫자 일반 면제·틀린 동의어
  우회·판정 완료의 소급 적용은 금지한다. 원문 script/token/수량 검사는 유지한다.

## 표적 검증·한계

- 새 focused 검사에서 실제 collector4leaf·기존 leaf/source identity 불변·701분모
  보존·malformed source/unknown/empty/marker/수량 반례·세 언어 audit 연결을 확인한다.
- 공식 receipt 검증·JA UI/ZH normal·EN·context/queue/diff/등록 및 차선조회,
  새 focused와 실제3언어×2페이지6PNG만 fresh 실행한다. 비변경 fullbody·과거
  focused/runtime·전체감사/240주·성능 A/B는 NOT_RUN이다.
- proven pre-autoload 격리에서 실제 Next와 완료/취소 입력·seen/focus·font/glyph/
  fit/bounds·typed 상태/원래 Meta bytes·player34 보존을 확인한다. 게임 베팅 재검사0.
  실제 양언어 카드/베팅/정산 증거는442·443 참조이며 새 실행으로 세지 않는다.
- 이 번역이 없으면 규칙과 패 순위를 영어로 읽어야 한다. 새 선택/경제/24주 결과를
  만들지 않는 기존 선택 설명의 수리다. 사람 관찰·원어민·물리패드 증거는 아니다.
- 중앙 배너/POT 겹침·직접 영어 배너 및 기존 JA `포카드→フォールド` 오역은
  별도 후속 결함이다. 새 본문에는 그 오역을 복사하지 않고 기존 행은 여기서 건드리지 않는다.
- 기존204판정/182보고·인간OPEN45/DONE1·공개GO1·본편/새package HOLD 보존.
  지시는 일회성, 재사용 provider 계약만 I18N_INFRASTRUCTURE의 소유 절에 기록한다.

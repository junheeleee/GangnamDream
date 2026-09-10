#### [~] ORDER-237 — 중국어 폰트 경로 감사 정합성

상태: [~] 착수 — 만지는 파일: 아래 exact 12개. 2026-09-10 Codex.
부모: [전체 현지화](../queue_backlog/FULL_GAME_LOCALIZATION.md).
기준: clean main `fe9b6e4d359903d5e96e1f6bff5a6091af5552c8`, tree
`dfb9902998f74259d2af1932fdcf6303964c7f93`. 앞236은 독립 wrapper PASS로 종료했다.

## 문제와 1단위

FontKit은 정규화한 locale의 SC/TC를 공유 UI 역할의 primary로 쓰는데,
감사는 과거 attach_locale_fallbacks(font, language)의 append-before-JP만 찾는다.
이 인식 실패를 실제 JP-first로 혼동하는 정적 오탐 1종을 고친다.
번역·UI 파일을 수량에 맞춰 섞지 않는 단일 감사 수리다. 번역 수용 증분0.

- 지우면: 현재 구현된 지역 폰트 계약의 readiness를 정확히 판정하지 못한다.
- 상태 차이: 게임 상태·24주·선택은 N/A. 잘못된 SC/TC·JP 연결과 정상 연결의
  정적 판정을 구별한다. runtime·픽셀·폰트 자원을 바꾸지 않는다.
- 경쟁: 알려진 정상 구조, 미인식 구조, 실제 순서·지역 불일치, 자원 부재를
  같은 성공으로 묶지 않는다. wholefile hash나 현재 파일 자체를 정답으로 쓰지 않는다.

## 소유권

- `tools/zh_translation_audit.py`
- `tools/audit_scope.json`
- `CLAUDE.md`
- `docs/CODEX_QUEUE.md`
- `docs/CODEX_QUEUE_L3_PENDING.md`
- `docs/queue_active/ORDER-237.md`
- `docs/queue_archive/ORDER-237_FONT_ROUTE_RESULTS.md`
- `docs/WORK_LOG.md`
- `docs/history/WORK_LOG_2026-09-07_localization.md`
- `docs/STATUS.md`
- `docs/agent_review_decisions.json`
- `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`

제품은 ZH 감사 1파일뿐이다. full_game_localization.py·그 self·JA pipeline,
모든 KO/EN/JA/CN/TW 문자열·portable 원장·runtime·assets/fonts/OFL·license ledger,
LocaleManager/SHIPPING_LANGUAGES·FontRoutingCheck·project.godot·사용자 save/settings,
공개 demo·human_gates 원형은 비소유다. 수용38,437/b96/meta9·인간OPEN45/공개GO1,
본편HOLD를 보존한다. 코드4 중 나머지3은 raw 불변이다.

WORK 완료절은 1,500B 이내로 예약한다. 현재 WORK39,301B/EOF2에서 완결된
225→224 두 절의 연속 원문1,203B만 기존 history 맨 앞에 이동한다.
블록 SHA `a914880c75b9dd6d55a4ed16f55e4596fe660b9450daa5b57ea84e05750bbda8`.
시작 `## 2026-09-10 (Codex — 첫 생활·가족·우정 번역)`부터 다음 CI 설치 절 직전.
history83,864B/EOF1 원형 위에 prepend하며 기대85,067B/EOF1,
SHA `bb13f2a5058074894fe814a4d50b94afd5311b6f475d20960e412a038dcf80b5`.
WORK는38,098B/EOF2가 되고 완료 후 최대39,598B다. 압축·정규화·기존223/222 재이동0.
적용 후 양쪽 raw 역복원·EOF를 다시 확인한다. 작업 이력은 삭제하지 않는다.

## 구현 계약

1. 승인 SC/TC 지역과 실제 요청 primary를 결속한다. JP override, 지역 교환,
   빈 값·res 밖·누락 자원은 거부한다. source 상수와 일치만으로 허용하지 않는다.
2. 알려진 modern 함수의 normalize→path/load→shared FontVariation.base_font,
   400/600/700 weight, Pretendard→JP→emoji 실행 관계를 한정 인식한다.
   주석·문자열·다른 함수·죽은 분기·뒤 JP 덮어쓰기는 정상 witness가 아니다.
3. 기존 legacy helper와 good/bad fixture의 raw·기대는 유지한다. 잘못된 modern을
   unrelated legacy로 통과시키지 않는다. 미지원 구조는 fail closed한다.
   helper의 ja/ko/unknown OFF와 상위 API의 지원 경계를 보존한다.
4. cmap·OFL/ledger/resource 확인은 계속 별도 필수다. 새 인식 성공이 이를 면제하지
   않는다. 역사 shared_han_jp_first 필드는 보수적 위험 지표로 유지하고 진단에서
   정적 미인식/지역 불일치를 실제 engine 관측처럼 쓰지 않는다.
5. 새 focused self와 --self-test-font-route 조기 CLI를 같은 파일에 추가한다.
   기존 전체 self에 작은 hook만 허용하며 번역 숫자·문자·의미·token 검사는 불변이다.

## 검증·독립 판정

저자와 비저자가 각각 정상/정상base 연결 mutant/locale OFF를 코드 전 private 봉인한다.
고정 FontKit 원형·변형·기대·glyph 집합으로 baseline/post 각1회, 실패와 같은 입력
재검을 별도 보존한다. 24는 초안 참고 수일 뿐 목표가 아니다. 정상base가 통과해야
mutant 거부로 센다. 현재 CN/TW의 FONT_SAMPLES만 고정하며 UI collector는 실행하지 않는다.

- 새 focused route regression + 기존 legacy good/bad·empty/JP override 재생.
- 현재 CN/TW 실제 resource·고정 sample cmap·license 정적 readiness 기록.
- `python3 tools/audit_select.py --lane chinese-font-route-recognizer`:
  focused self, queue-index self, agent-ledger self, audit_select --verify와 always 검사.
- 비저자 전수 코드 검토, 변경 함수/추가 hook 역제거로 기존 raw/AST 복원,
  비소유·보호 입력·원장 불변, diff/context/queue/dashboard 확인.

전체 ZH12k self·전체수용38k L1·full localization12차선·audit.sh·Godot·240주·
실제 화면 실행0이 기본이다. 관측한 static readiness만 주장한다. 신규 결함이 실제
runtime 수리를 요구하면 별도 선언한다. native/render/human/physical/다른 플랫폼은
미관찰이며 새 원어민·플레이·출시 GO를 만들지 않는다.

독립 검수는 실제 exact source commit/tree와 증거 SHA에 결속해 work_unit237만
GO/HOLD/REWORK 판정한다. 자동 검사는 계약 증거이지 재미·깊이·문체 증거가 아니다.
사양·pin·WORK 이동은 일회성이다. 지속 인식 계약은 새 helper docstring/회귀가 소유하며
현재 구현을 이미 설명하는 I18N 정본은 복제하거나 변경하지 않는다.

결과: [표적 수리·최초 실패·독립 검수](../queue_archive/ORDER-237_FONT_ROUTE_RESULTS.md).

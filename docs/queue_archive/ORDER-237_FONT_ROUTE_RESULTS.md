# ORDER-237 FONT ROUTE RESULTS

Status: 구현·표적 검증 완료. 최종 위임 판정과 exact source는 별도 [판정 원장](../agent_review_decisions.json)의 ORDER-237 기록을 함께 읽는다. 이 보고서 자체는 본편·폰트 전체 준비·사람 GO가 아니다.

## 범위·신원

기준 main `fe9b6e4d359903d5e96e1f6bff5a6091af5552c8`.
선언 `30b7120`, WORK 정확 EOF 복구 `9945888`, 선언 dashboard `f6173eb`.
제품은 `tools/zh_translation_audit.py` 한 파일의 지역 폰트 인식·readiness 연결이다.
`tools/audit_scope.json`에 collector 없는 명시 차선·focused command를 등록했다.
번역 수용 증분0: 38,437(JA12,811·CN/TW각12,813), b96/meta9 그대로다.

최종 코드 1,680,463B, SHA
`6794c988c900d2d65d83261ba1ba2d0589281eca33b8ae23abb1737bef608fc6`.
원형 1,615,386B, SHA
`913c8ec8e23661848eb55b6ed9354bced8542ce9b5a2595f746612ed8c5b8064`.
코드 변경 commit은 `b2faed2205d97ddefa75fe3041ba80a8ad6df9eb`이다. 이는 최종
source 신원과 다르다. 이 보고서 이름은 resolver의 metadata 예외에 포함되지 않아
문서1줄 정밀화 `fc1e8d4`도 새 source였다. ROOT의 최초 C1 유지 추정을 철회했으며,
현재 최종 보고서·선언 원문을 먼저 커밋한 뒤 Git에서 관측한 source에 독립 판정을
결속한다. 이후 이 파일은 동결하고 마감은 기존 허용 metadata만 변경한다.

## 생산자·소비자·수리

- `FontKit.configure_language` → 공유 `FontVariation` 400/600/700 →
  `UIStyle`의 세 role·locale callback은 runtime 원형이다. SC/TC가 실제 primary인
  현대 구조를 과거 attach-only regex가 알아보지 못했다.
- 새 `_font_route_source_contract`는 유한 문법에서 정규화·지역 path/load·cache·
  공유 객체 동일성·후속 할당·Pretendard/JP/emoji 순서를 따라간다. 코드 문자열
  검색이나 현재 전체 파일 hash를 성공 기준으로 삼지 않는다. 미지원 구문은 차단한다.
- 기존 `_locale_font_precedes_jp`와 역사 good/bad fixture는 그대로이며 새 legacy
  guard가 활성 직선 append·동일 font·alias를 확인한다. 잘못된 modern을 legacy로
  구제하지 않고 literal·죽은 분기·early return·뒤 덮어쓰기를 막는다.
- `font_route.ready`는 이제 긍정 경로 증명을 직접 AND한다. JP 자원이 없다는 이유만으로
  미인식 경로가 ready가 되던 연결 결함도 닫았다. cmap/OFL/원장 조건은 면제하지 않는다.
- 나머지 기존 top-level 정의200개(함수196·클래스4) raw 불변. 허용 변경함수3은 font_route, main의 early CLI,
  run_self_test의3줄 hook뿐이다. 신규 구간/ast import/이3함수를 역복원하면 원형
  전체 raw·AST가 exact다. 나머지 번역 코드3·runtime·문구·폰트·인간 원형은 불변이다.

## 최초 실패와 동일 입력 재검

서로 다른 대조군의 수를 전체 unique coverage처럼 합산하지 않는다.

| 고정 대조 | 첫 결과 | 동일 입력 최종 |
|---|---|---|
| 독립 source30(Rawls): 정상5/변조22/OFF3 | 정상2만 성공, 유효거부2; 현대 정상 차단으로 변조20은 판별 불가. 잘못된 modern+legacy 미끼 허용1 | 정상5 PASS, 정상base가 통과한 변조22 거부, OFF3 None |
| 저자 source32(Plato): 정상6/변조23/OFF3 | 정상 legacy2만 성공, 유효거부1 | 정상6 PASS, 유효거부23, OFF3 None |
| 별도 legacy 활성7: 정상2/변조5 | ROOT 코드 검토 뒤 사전 봉인; dead/return/alias overwrite3을 실제 허용 | 새 guard 뒤 정상2 PASS·유효거부5 |
| 독립 readiness 연결5(Poincare, 명시 mock) | 정상1·거부3 성공, 미인식+JP 부재1이 ready=True | 같은5 전부 성공, 정상base1·유효거부4 |

각 묶음 baseline/post는 각1회다. 원래 기대·실패·정상base를 지우지 않았다.
독립 legacy 두 정상은 상수가 없는 역사 snippet이므로, 봉인된 외부 SC/TC path를
component 입력으로 쓴다. 실제 legacy application 전체 dataflow 증거는 아니다.
OFF의 pre는 새 helper 부재이고 post는 None이다. 기존 지원 언어 범위를 넓히지 않았다.
readiness 연결5는 source/cmap/ledger/resource의 명시 mock이고 실제 라이선스 관측이 아니다.

## 실제 정적 관측과 남은 차단

독립 pre/post는 실제 CN/TW 각각 기존 FONT_SAMPLES의 고정6글자만 한 번씩 확인했다.
pre: 각6/6, shared_han_jp_first=true, ready=false, 경로오인식+원장 SHA 진단2.
post: 각6/6, shared_han_jp_first=false, ready=false, 다음 진단 하나만 남았다.

`font full SHA-256 is absent from the font ledger`

이는 실제 화면·JP-first 렌더 관측이 아니다. TTF/OFL은 I18N 정본의 승인 full SHA와
같지만 FONT_LICENSE_LEDGER 채택표에는 앞16자리만 있고 감사는 전체64자리를 요구한다.
현재 notices는 원장 SHA와 일치하므로 stale이라고 부르지 않는다. 이 원장 결손은
237의 비소유 보호선을 유지한 채 별도 후속으로 넘긴다. 검사 완화·폰트 교체·허가 위반
추정0이다. 다음 별도 작업은 기존16자리표/OFL과 역사 공개 package를 보존하면서
승인 full2 기록과 notices source 지문을 보강하는 것이다. 아직 미선언·미적용이다.

## 표적 QA

`python3 tools/audit_select.py --lane chinese-font-route-recognizer`

첫 실제 명시6 검사 PASS, 23.982045초, 입력142 전후 exact.
focused self39(저자32+별도7), 실제 CN/TW 각6glyph 관측, empty/JP override2는
같은 CLI에 포함한다. 전체 ZH self/전체수용 L1/collector/Godot/240주/full audit 실행0.
selector는 child 출력 끝3줄만 보존하므로 기록에 보이는 실제 route는 TW와 override다.
CN/TW 전체 결과는 별도 독립 post에 있으며, 보이지 않는 marker를 인용하거나 재실행하지 않았다.
등록141, queue self25+fence4, agent self222/HOLD/인간 원형, context/queue PASS다.

준비 실패도 보존한다. 첫 queue 헤더 형식이 parser와 달라 실패해 기존 형식으로 고쳤다.
apply_patch가 WORK EOF2를 EOF1로 줄였고 첫 blank 복구도 효과가 없었다. raw assert 실패 후
선언 커밋이 진행된 사실을 보존하고, 구현 전에 별도 커밋으로 정확1LF를 복구·역검증했다.
명시 차선 첫 목록은 새 command의 checks 등록이 없어5개였다. 실행 전에 등록을 보완해
6개 선택을 확인했다. 이 준비 오류를 제품 검사 PASS처럼 세지 않는다.

## 증거 지문

경로 접두부는 `.git/full-game-localization/`이며 원형 JSON·출력을 보존한다.

| 증거 파일 | SHA-256 |
|---|---|
| order237-initial-seal.json | 0831aa1237c74b59e37240d8d505e1c725120415c6e2c701414401159f5dd7f3 |
| order237-declaration-binding.json | c645e1682ff5027dfd1b1da6948f072fd6811b9a7e7ec88f612ddb79dc645b89 |
| order237-independent-font-controls.json | 92a9153c4288467dfe61ee83b8d2933f95bfd64430dbf7f2357efd1cb4c8e55f |
| order237-independent-font-pre-code-result.json | e9d7605ffdad8993c52ac2b6bcfda6b8418a487adc1a940f1e5d1d7dcce7fcd9 |
| order237-independent-font-post-code-result.json | a68a368806c579d5094a07ae6411157fca06e5a705303f7f060ff609fee335e5 |
| order237-author-font-controls.json | a835a3829cf9c2672821720f409b449fad498812397b4478e460997731c842f6 |
| order237-author-font-pre-code-result.json | be40f68f754f393c64898259a3a96bf7631cb73846565c7df17cb8552de5f334 |
| order237-author-font-post-code-result.json | b4bf3becf93c378604bc70c768fa501bd08374eedde1df0fa5809f8f4db736b5 |
| order237-author-legacy-active-controls.json | 61d208ae909d1106f29a6b1e4e3fa394097a54b3a285417ad2f38d293e85dbed |
| order237-author-legacy-active-pre.json | 9c0a97d19872c0e2d9980956761a83cb7d37f96af5a3f7548111448c9412b3f4 |
| order237-author-legacy-active-post.json | 4f72e188affc903aaeccc1f5c1375febd23b7010d2e12806a5673fbd1b0a56c0 |
| order237-independent-ready-chain-controls.json | e7738b655ec23ab838670e2b0b50675e05e3fd64eb58d64213ab5ce987350fb4 |
| order237-independent-ready-chain-pre-code-result.json | 3619c719df1b26dd48e66e01922687db4b437dfd30e6d3bcdcead5888792aa06 |
| order237-independent-ready-chain-post-code-result.json | 18954c985d310623973237c8ada1bae164a4e2ba8a3883cd224a7352fe35f4f2 |
| order237-author-code-freeze.json | 4b494549f833d495e266532674875c3d3cf39b98764fc92024003de2eb35ac35 |
| order237-named-qa-first.json | ae2d1838e1b16ffd9ce870610b3690727ae8d6e33590938f63386d2a06aeda14 |
| order237-next-font-ledger-scope.md | aa4779965e208e5f64fcfc88c832ff75c5642eb55f1faf39d5b76e2fc3e33ccc |

## 정본 처리·한계

새 인식 모델·엄격 실패·레거시 활성 witness의 지속 계약은 해당 helper docstring과
회귀가 소유한다. 현재 SC/TC 배선을 이미 소유한 I18N 정본은 복제·변경하지 않았다.
사양·입력 봉인·표본·WORK raw이동·명시 차선·마감은 이번 한정 절차다.
완료된225/224 원문1,203B는 history로 손실 없이 이동했다. WORK38,098B/EOF2,
history85,067B/EOF1의 역복원 exact를 확인했고 완료절은1,500B 이내만 더한다.
자동 검사는 계약 증거이지 재미·깊이·문체 증거가 아니다. 공개 M01~M06 GO와
인간 원형 OPEN45는 유지하며, 본편HOLD·native/render/물리·외부 출시·현재원격CI는
별도 미관찰이다. 실제 중국어 준비 전체 GO나 새 사람 GO를 발급하지 않는다.

## 독립 코드 검토와 최종 결속 절차

Poincare는 새 코드 전량과 기존 정의 보존을 직접 읽고 필수 코드 지적0을 기록했다.
독립 코드 검토의 원형은 `order237-independent-code-review-initial.json`,
7,294B / `ff672f5c9ced8e2cec3c3538c1cd20f41db1d8bd2ec0f6cf0313618b4829efb1`.
그 뒤 보고서의 함수/클래스 분모를 위와 같이 정밀화했다. 사적 저자 proof의
unchanged_existing_function_count 이름이 센 것은 정의200이며 함수200이 아니다.
QA 입력142 중 코드·자원 등139는 그대로이고 결과 문서3개의 주석만 후속 변경됐다.
Poincare의 RO 비교에서 C1과 이후 문서 wrapper를 혼용한 assert도 보존하며,
QA→C1 Git blob→후속 보고서 diff로 분리했다. 이것은 제품 QA 재실행/실패가 아니다.

이 최종 본문과 아래 선언 원문을 커밋한 후, 비저자는 실제 resolver commit/tree와
QA·보호 입력을 다시 결속해 work_unit237만 판정한다. 이후 최종 private proof의
경로·SHA는 WORK_LOG 마감절에, 해당 source·이 보고서의 고정 SHA·판정은 위 원장에
남긴다. 같은 파일을 다시 고쳐 새로운 source로 만드는 순환을 피하며, 원장은 후보를
선택하지 않고 Git의 관측 신원을 기록한다. 이 결속 절차는 이번 오더에 한정한다.

## 착수 사양 원문 보존

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

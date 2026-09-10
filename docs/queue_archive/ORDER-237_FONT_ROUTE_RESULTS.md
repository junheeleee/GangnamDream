# ORDER-237 FONT ROUTE RESULTS

Status: implementation and targeted QA complete; exact-source independent final review pending.

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
현재 source commit/tree는 독립 최종 판정 때 Git에서 직접 결속한다.

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
- 나머지 기존 함수200개 raw 불변. 허용 기존변경3은 font_route, main의 early CLI,
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

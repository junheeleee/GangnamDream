# ORDER-274 — 첫 실행 안내 세 언어·수집 누락 수리

[x] 2026-09-20. 독립 Poincare work_unit GO, 필수 결함0. 본편 출시 GO가 아니다.

- 제품 `dffae2524215ac63f9321b213e3f07e56e0dc45b`, tree `08ad7a25c46184281726e149a9c72fcad93e3659`. clean 검토 `a44cf78c8c728aa07badc388ca8fbeba8a7d4f17`, 제품 뒤 STATUS-only wrapper.
- KO/EN 7조각을 해독값 동일한 단일 literal로 변경. 7LF·4bullet·단락·나머지 StartMenu 원형 보존. collector 현재3466호출/2949키(+1/+1), 역사 핀은 그대로.
- JA/CN/TW 본문1값씩 직접 저작·전량 독립 검토·실제 수용. 공식39895/b119/meta9, 기존39892 source/target hash와 UI/portable 역복원 확인. 신규 원문 manifest `2af00468b62e7f0cc61541770c57900424135e5c9e7de12e8dc087fd74f3f15a`; 옛 manifest 동일 주장0.
- 명명17 전부PASS, 새 source14(유효음성12), 옛 source/gift/meta/CI 각1회. clean 검토 HEAD에서 실제1634입력 불변.
- 실제 Godot4.6.2/OpenGL/1280×800 KO/EN/JA/CN/TW 5PNG를 ROOT와 독립 검수자가 직접 확인. 본문·두 버튼 잘림/겹침0. 합성 Left→Enter의 Back5회 뒤 game/meta 불변; 실제 사용자 파일43개 불변. 인간 정상속도 플레이·원어민·물리패드가 아니다.
- 최초 화면 probe는 private 변수명 namespace의 파서 오류로 실패했다. 원형 GD/로그/실패 envelope 보존 후 qa_namespace만 바꾸어 같은 제품 재실행PASS. 제품 코드 실패로 바꾸거나 첫 실패를 지우지 않았다.
- 최초 설치 helper는 기존 JA 5행의 탭 들여쓰기를 canonical JSON으로 가정해 patch 출력 전에 멈췄다. 실패 원문은 transcript 인용 메모이며 재캡처 stdout이 아니다. fail-fast 없는 shell에서 이어진 formal-export3은 미사용으로 보존한다. raw 한 행 append 수리 후 applied-export3/실제 accept3만 수용 증거다.
- 보존 capture는 실제 d48ca4d HEAD의 CLAUDE/portable dirty 상태에서 실행했다. 최종 clean a44cf78 실행이라고 바꾸지 않으며 최종 실물 입력핀과 독립 대조했다.
- 기존 보류90·공개 M01~M06/GO1·인간OPEN45·과거60agent판정·본편HOLD 유지. Understood start/save 입력·Esc/East·다른 해상도/플랫폼은 이 관찰 범위 밖이다.
- [독립 보고](../agent_reviews/ORDER-274.json) SHA `c9ab3ea1f7b8aa837d6c63e8fed43eb2b9e77b033fefb3a5023a7e0ac760ba92`. 선정·파일 소유·표적 수용·화면 probe 절차는 일회성; 기존 WORK_UNIT/I18N 규범 재사용, 신규 규범 승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 실제 캡처

git-private 원형은 stdout/stderr bytes·SHA·exit·실제 입력핀을 보존한다. 미사용 export나 진단의 exit0를 제품 통과로 합산하지 않는다.

| 파일 | 바이트 | SHA256 | exit | 결과 |
|---|---:|---|---:|---|
| order274-accept-ja-first.json | 377807 | 2a6b766d49aeed392a934b7e75bac106daaa974a863cbbf469777c0d704a866c | 0 | PASS |
| order274-accept-zh-cn-first.json | 377826 | 9592d7c1724118c4b998f2ba1755b8bb7af5a1cd4b284d35e595f556ec28a42f | 0 | PASS |
| order274-accept-zh-tw-first.json | 377833 | 7b11dc0702b4109d5dce92bdbb620fd6a3c608bd4b5a635fa98f5a742668d809 | 0 | PASS |
| order274-applied-export-ja-first.json | 377888 | 2e5e216fa3a6ac3f8f6b8e1b96d386c7b701f5f22bda547d50ce8f848a71ae60 | 0 | PASS |
| order274-applied-export-zh-cn-first.json | 377918 | cbcdc333d06d261c3240780209745cc7b852e5c85042dbba595f59c24ec25f5f | 0 | PASS |
| order274-applied-export-zh-tw-first.json | 377911 | f1ab2cc2055729d1a6bf1249998783d58ab7a6e935947b42f76210a1328a2c5a | 0 | PASS |
| order274-export-ja-first.json | 377888 | 841f37c6d36515fced2c95a3d473a2d523aacb7aa9d3eb36987e362a86a0c6b1 | 0 | PASS |
| order274-export-zh-cn-first.json | 377918 | ddba63920cde087fdc18f40b4b2fe25fc0b973077c45c9a4564acf0d0180e66d | 0 | PASS |
| order274-export-zh-tw-first.json | 377909 | fcec0620ad3387263f0660d344ac80c0f2a175d7af32352dd222c8696d9ddb12 | 0 | PASS |
| order274-formal-export-ja-first.json | 377885 | ddcd79913634e09fd1979cf748643b52e935d86142215db6ca7e6fc9bf03f148 | 0 | UNUSED early export; not acceptance |
| order274-formal-export-zh-cn-first.json | 377908 | d0796a975564e7c4f66fceb6286a46e8f7f80194d9385cb619a7f7827bb9e59e | 0 | UNUSED early export; not acceptance |
| order274-formal-export-zh-tw-first.json | 377908 | 75a8e96e8dea1353d3f74304b9d83b766dcd2e8500e809a7a7853c6fe7a22b00 | 0 | UNUSED early export; not acceptance |
| order274-named-envelope-first.json | 380820 | 95e652fbaaef60cbd53e6dbd18b204e5d5e3165627e38a338c2050a7e0001fd8 | 0 | PASS |
| order274-named-first.json | 141668450 | a972d4c2c366ce9e42d6432cd4446518e6daa0b739fc8f6658171e49373e3399 | 0 | PASS |
| order274-preflight-ja-first.json | 377792 | ec19ae814fa8ab74f33f083b4aebc57dd1d160d980d05d78b735762461a54f25 | 0 | PASS |
| order274-preflight-zh-cn-first.json | 377811 | 1934a0017c70b953e0d61f08e12f6a4ef5312e0d90e8c04cc3489c01d73727fb | 0 | PASS |
| order274-preflight-zh-tw-first.json | 377817 | 1c0d19ad4148c47acccff3d5e6b1ddd976cf641ef1327742cc3d8888b4ff5ee1 | 0 | PASS |
| order274-preservation-first.json | 378110 | 43f5e018b886183d7bbde623b6a9142657e4dc0e0c0ba93a2cabd25f4966c166 | 0 | PASS |
| order274-render-envelope-first.json | 378772 | 18699086425a5e537fe861dd74b726467f7056915230dbbe5eeb313420e11d72 | 1 | FAIL preserved |
| order274-render-envelope-retry-first.json | 378032 | d8592618466285739c19d90901948dab736a42f78db352521972be75fb966613 | 0 | PASS |

## WORK 마감 전 원문

# Gangnam Dream Work Log

> 이전 WORK·현재 선언·실패 원문은 [273 보존본](queue_archive/ORDER-273.md)에 있다.

## 2026-09-20 (Codex — 경마 정보 중국어 20 복구)

- [273](queue_archive/ORDER-273.md): 제품6b000a1·검토a7da931, 독립 Poincare 한정GO/필수0.
- 기존20원고 전수 언어재검토 뒤 실제20복구수용·신규0보류. 상세 실패·의미·원고는 독립보고에 보존.
- 공식39892/b118/meta9. 기존39872·KO/EN/JA·runtime·공개판·인간원장/과거59판정 보존.
- 거리 slot/unit 검사 수리와 정상4/변이14/OFF2 확인, 명명12 PASS. 원형 수리 전 증거 보존; 원어민·화면 완료가 아니다. 공개GO1·인간OPEN45·본편HOLD.
- 작업자 실수로 최초check2에 --locale를 빠뜨려 실패했다. 정확locale의 같은batch 재검사2는PASS. 원형은273 보존본에 남겼다. check/import에도 locale를 명시한다.

## 다음 안전한 범위

- 첫고지본문1의 JA/CN/TW누락과 수집 미노출은 별도 수리 대상이다.
  `.git/full-game-localization/post270-first-warning-repair-scope.json` 7257B/SHA66a21413b144447af3b99671907bb058b5892aca1962df3a07bc29fef438c6ba.
  ROOT가 RO메모 전량을 읽었다. 기존KO/EN7literal씩을 같은완성값의 단일literal로 펴는 방향이며, 새1key의 현재/역사 collector경계와 JA누락을 별도선언으로 검증한다. 새collector대형화0.
- 이전보류110중 경마헤더/말기록20을 복구했다. 나머지90(268의62·269의18·270의10)은 기존독립보고 원형 보존, 아직 미수용이다.
- 시장 부모1은 수용했지만 neutral/bear/bull 동적인자와 AP효과 원문 정합은 별도다.
- 다음 작은 검사 수리 후보는 착순6오탐의 베팅설명8값 또는 비용2오탐의 정보구매10값이다. 거리수리를 다른 원문으로 확대하지 않는다. 원형복구메모 post271-held-recovery-scope.json SHA16336cd78cd93041d2c061a3abdccb2ffbdb2a80c3e1b638777e79d2892bf546를 따른다.
- 현재 원문 `자산10억! 절반`, 저자산만 본 `아직 초반`, 투자확인 없는등급, 경고의잠/식사묘사는 별도정합 수리후보다.
- 비보호 shipping 사건11578 세 언어 수용 완료.843은 참고741·보호102이며 신규 활성 사건 공백이 아니다. 실제화면·동적표시명·직행EN·원어민 검수는 별도다.

## 활성 사양 원문

# Active Queue Spec: ORDER-274

#### [~] ORDER-274 첫 실행 콘텐츠 안내 본문을 세 언어로 표시한다

2026-09-20 착수. 기준 main `dc4a435330474af62eabae7638a276dc976a2dc2`.
부모 ORDER-157, 사용자 전체 현지화·내부 검수 위임 안의 단일 UI 수리다.

## 깊이 3문

1. 없으면: 새 게임의 첫 콘텐츠 안내 본문이 JA/CN/TW에서 영어로 남는다.
2. 상태: 번역 표시만 바뀌며 새 게임·뒤로·고지 확인·저장 상태는 그대로다.
3. 경쟁: 같은 본문의 영어 fallback을 해당 언어로 대체한다. 새 선택은 없다.

## 정확한 소유

- `scenes/StartMenu.gd`: `_show_content_warning`의 KO/EN 7개 연결 literal을
  각각 단일 literal로 펴되 해독한 두 문자열·그 밖의 바이트는 보존한다.
- `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`:
  해당 본문 정확히 1키씩. 한국어에서 세 언어를 각각 직접 저작한다.
- `tools/ja_translation_pipeline.py`: 실제 collector가 새 1호출/1키를 수집하고
  기존 역사 모집단을 그대로 검증하도록 이 정확한 owner/pair만 경계 처리한다.
  기존 inventory 숫자·hash를 새 값으로 덮어 통과시키지 않는다.
- 필요한 `tools/first_start_notice_self_test.py`: 원문 해독 동일성·정확한
  owner/API/호출수·현재/역사 분리와 변이 거부만. 새 범용 수집기는 만들지 않는다.
- `tools/new_run_log_locale_self_test.py`: 현행 notice 계약을 먼저 검사한 뒤
  기존 역사 검사에 원형 view를 제공하는 최소 entry hook만. 옛 핀·기대값 불변.
- `tools/audit_scope.json`: 위 파일의 표적 검사 등록/명명 차선만.
- `content/meta/full_game_localization.json`: 기존 39,892 수용 보존 + 새 3값만.
- 이 사양, CODEX_QUEUE와 이어보기 순번, CLAUDE 현재 상태, WORK_LOG, 생성 STATUS,
  `docs/agent_reviews/ORDER-274.json`, `docs/agent_review_decisions.json`,
  `docs/queue_archive/ORDER-274.md`: 선언·검증·독립 판정·완료 기록만.
- `.git/full-game-localization/order274-*`: 원문 export·독립 번역/리뷰·원형
  실행 출력·기존 bootstrap을 쓰는 격리 화면 probe와 캡처. 기존 증거 덮기 금지.

## 검증과 보존

사전 메모 `post270-first-warning-repair-scope.json` SHA
`66a21413b144447af3b99671907bb058b5892aca1962df3a07bc29fef438c6ba`.
KO/EN 완료값·7LF·4bullet·단락·일곱 조각 경계와 non-body 역패치를 비교한다.
현재 전체 collector에서 새 owner/pair 1만 증가하고 나머지 source leaf/hash는
그대로인지 확인한다. 새 원문 파일 manifest는 달라지므로 옛 identity를 주장하지 않는다.
원문-bound export→check/import→portable 수용, 기존 receipt/hash 보존을 확인한다.
JA UI/pipeline, ZH self, full localization self, EN, public-demo 구조,
등록·큐·문서·agent 원장 검사를 표적 차선으로 1회 실행한다. 실패는 원형 보존 후
원인만 수리하고 같은 게이트를 재검사한다. 전체 감사·240주 재실행은 비범위다.

실제 Godot 1280×800 다섯 언어의 이 패널을 격리 user-data에서 렌더하고
본문·버튼 잘림, 번역 lookup 및 뒤로 입력을 확인한다. 직접 호출은 정상 속도
인간 플레이로 세지 않는다. 관찰한 화면만 보고하며 native/물리 패드는 OPEN이다.
독립 비저자 에이전트가 source·세 번역·검증·화면을 전량 검수하고 exact source와
clean review HEAD에 work_unit 한정 판정을 결속한다.

공개 M01~M06 원고·121 UI·패키지, 인간 GO1/OPEN45, 기존 60 agent 판정,
게임플레이·아트·저장·언어 allowlist·project.godot·원어민/외부 출시 권한은 비소유다.
등급·법률 문구를 새로 만들지 않으며 기존 안내의 내용·의미를 바꾸지 않는다.
자동 검사는 계약 증거이지 재미·깊이·원어민 판정이 아니다. 본편 HOLD 유지.
규범: 기존 I18N/WORK_UNIT을 재사용하며 이 소유·표적 증거 절차는 일회성이다.

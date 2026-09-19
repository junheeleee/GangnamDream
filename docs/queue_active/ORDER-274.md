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

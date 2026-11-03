# ORDER-738 — 본편 JA/zh 사실 불일치 정합

상태: [~] 2026-11-03 root 착수. 부모 [157](ORDER-157.md), 기여 C2/C5.
사용자 일본어·중국어 본편 완성 지시의 첫 실행 범위다.

## 범위와 깊이 3문

1. 제거하면 무엇이 깨지는가: KO/EN에서 수리한 네 장면이 JA/zh에서 거짓 과거·
   아버지 사망을 계속 말한다. 오래된 번역을 현재 원문과 결속한다.
2. 선택의 대가는 무엇인가: 기존 선택·결과·효과는 그대로이며 번역이 새 사건을
   만들지 않는다. 실제 함께 투자하지 않은 경로에도 공동운용 과거를 부여하지 않는다.
3. 무엇과 경쟁하는가: 전체 번역 중 실제 반대 사실 15문구를 UI 빈칸보다 우선한다.

## 정확한 소유권 (일회성)

- `content/events_{ja,zh-CN,zh-TW}/arc_events.json`:
  `arc_father_03_hospital:/choices/0/result_text`,
  `arc_father_04_visit:/description`,
  `arc_father_04_visit:/description_if_known/arc_sangchul_03_seen`만.
- 같은 세 언어의 `arc_drama.json`:
  `arc_sangchul_reckoning:/choices/1/result_text`만.
- 같은 세 언어의 `arc_chapter_themes.json`:
  `arc_36_trust_crack:/description`만.
- `content/meta/full_game_localization.json`의 이 15개 source/target 수용과
  별도 correction batch만. 원 수용 이력·다른 번역은 보존한다.
- 이 사양·부모157·큐·CLAUDE·11-03 WORK_LOG, 독립 검수 보고/판정만.

현재 한국어 원문 직접 대조, fresh export/check/import --replace-existing와
이전 target hash 결속, 줄바꿈/토큰/숫자/지역 문자 검사, 비소유 JSON 값 불변을
검증한다. 독립 검수자는 원문5개·번역15개 전독한다.
기존 full-game-localization-overlays 차선과 diff 검사를 사용한다.
KO/EN·런타임·공개 데모·project.godot·SHIPPING_LANGUAGES·사용자 저장 비소유.
화면·원어민·본편5언어·출시 완료는 이 범위에서 판정하지 않는다.

## 증거 (진행 중)

도달 경로: 현재 원문5문구/기존 target15개 직접 확인, 실제 앱 미실행.
생산자↔독자: 한국어 사건 → 기존 built-in locale overlay loader.
바꾸는 상태: 오래된 번역15 → 현재 사실과 정합인 번역15 (신규 커버리지 아님).
포기 시 잃는 것: W89/W96/W132/W152의 선택·생사 일치.
서사 위치/계층: 기존 사건의 주차·계층 불변.
닫는 것: 이 사실수리의 source/자동/독립 에이전트 대조만; 실제 화면·전체 완성 미완.

규범: 언어·호칭·통화·수용 경계는 기존 I18N 정본 적용, 새 규칙 승격 없음.

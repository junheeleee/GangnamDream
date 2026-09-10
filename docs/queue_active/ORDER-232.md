# Active Queue Spec: ORDER-232

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-232 [전체 현지화] 기록 불러오기 UI24키 번역

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. clean main `0c81af28dc5abf1267ff2697d7334c193475fb62` / tree `41c17903edfdeba62feaa7da8af882feb9ccf0de` 기준이다.
이전420 수용·독립 GO는 ORDER-231 결과가 소유하며 이 UI72에 합산하지 않는다.

## 깊이 3문·판정 대상

1. 없으면 무엇이 빠지는가? 시작 메뉴에서 슬롯/저장 출처/호환/삭제 확인을 읽는24문구다.
2. 바뀌는 미래 상태는? 텍스트만 바뀐다. 저장·호환 정책·실제 삭제·시간 흐름 변화0이다.
3. 무엇과 경쟁하는가? 이어갈 기록의 식별과 취소/삭제 판단을 명료하게 옮긴다.
   새로운 기능이나 저장 슬롯을 추가하지 않는다.

ROOT는 사전조사의24 KO/EN/기존JA값을 전량 읽었고 LocaleManager 전체를 읽었다.
사전조사 SHA70c531320096438047cb6340dbbefd62e4164bf9588ff091986d29f139bdf8c1.
source records SHAc94e75ace304933d329c02d461b404c2a51ce1b1c15d82cebc142e6e92a9fc1f, 순서 SHA182a2378e4441fa32107d27a21de5be17c1d0b4ce45d7a35afe4344c7f26876b.
24 source leaf/언어, JA기존24·CN/TW누락각24·선택수용0, LF0·name0·템플릿3/printf5다.

## 정확한24키

```text
자동저장
슬롯 %d
정식판
24주 데모
V2 테스트
이전 버전
다른 빌드에서 저장됨
데모 기록 · 정식판에서 이어갈 수 있음
이전 저장 형식 · 호환 모드
더 최신 버전의 저장 파일이라 열 수 없음
24주 데모에서는 이 기록을 열 수 없음
다른 테스트판의 분리된 기록
호환되지 않거나 손상된 기록
기록 불러오기
이어갈 시간을 선택하세요.
‹  슬롯 1–5
슬롯 6–10  ›
뒤로
비어 있음
챕터 %d · %d주차  ·  %s
취소
페이지 %d / 2
삭제 확인
저장 삭제
```

## 파일 소유·병렬 분담

- Plato: `locale/ui_ja.json`의 위24값만 KO 직접 재검수/필요 정밀화. 정확한 기존값은 유지한다.
- Rawls: `locale/ui_zh-CN.json` 신규24만 직접 저작.
- Poincare: `locale/ui_zh-TW.json` 신규24만 직접 저작. 간체에서 변환하지 않는다.
- 비저자 전량 대조: Rawls→JA, Poincare→CN, Plato→TW. ROOT는 통합을 소유한다.
- ROOT: `content/meta/full_game_localization.json`에 검수72/batch1만 추가. 기존37942/b91/meta9
  및 선택 밖 UI 모든 key/value/order/raw를 역제거로 보존한다. JA변경은 승인24 안에서만 기록한다.
- 조건부: `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`,
  `tools/ja_translation_pipeline.py`, `tools/zh_translation_audit.py`.
  첫24 L1 실제 오탐에만 국소 수리한다. 코드 전에 actual/다른 정상/유효 변조/source-OFF와
  비저자 대조를 봉인하고 같은 입력으로 재실행한다. 전체 leaf 면제·전역 완화·기대 변경0.
- 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  이 사양, `docs/queue_archive/ORDER-232_L1_L2_RESULTS.md`, `tools/audit_scope.json`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-232.json`.
  사적 source/response/receipt/검수/QA helper는 `.git/full-game-localization/order232-*`.
- 감사 등록은 기존 `full-game-localization-overlays` 명시 차선의 owned_paths에 UI3와 사양/보고만
  추가한다. 자동 선택 paths를 넓혀 일반 UI 변경의 기존 Godot 차선을 우회하지 않는다.

KO/EN source·source/context manifests·gameplay·SaveManager·StartMenu·MainGame·LocaleManager·
저장 파일/설정/커스텀 이름·SHIPPING_LANGUAGES·project.godot·폰트·공개 데모·인간 원장은 비소유다.
이 단위는 텍스트 수용이다. 실제 component·해상도·원어민·consumer 수리는 별도 단위로 남긴다.

## 의미·표시 경계

- 같은 화면의 보호키 `불러오기`/`닫기`와 기존 공개 UI121은 바꾸지 않는다.
- 과거 저장의 `24주 데모`/`V2 테스트`/정식판은 저장 출처 이름이다. 현재 공개 M01~M06
  승인/제품 버전을 새로 선언하거나 다른 저장을 호환 가능으로 바꾸지 않는다.
- `비어 있음`은 MainGame 사람 상태에도 쓰인다. '빈 저장칸'으로 의미를 좁히지 않는다.
  `슬롯 %d`/`취소`/`뒤로`의 다른 소비자도 같은 의미를 보존한다.
- 슬롯1–5/6–10, 페이지총2, 챕터→주차→원화의 printf 순서5개를 보존한다.
  저장 요약 %s는 현재언어 원화와 영어 폴백 인자를 분리하는 기존 ui_format 경로다.
- '삭제 확인'은 두 번째 실제 삭제 직전의 질문이다. 실제 저장 삭제/로드 테스트0,
  label/BUILD ID/세이브 버전·사용자 설정을 임의 번역·수정하지 않는다.
- UI 선택기/패키지·폰트·실제 화면을 번역 완료로 합산하지 않는다. 공개 GO와 인간45OPEN,
  본편HOLD를 유지한다. UI포착3556+미확정329는 최종 전체 UI 분모가 아니다.

## 검증·마감

1. 선언·동기화 뒤 공식 initial export24×3. JAprevious기존24와 CN/TWprevious-null48을 구분한다.
2. 직접 저작/기존값 재검수, 첫 L1 각1회·실패 원형 보존, 비저자72 전량 대조.
3. 선택key/source/printf/공유 의미/기존raw/보호121 보존. 필요 국소 수리만 고정 대조로 닫는다.
4. clean C1의 final export/check/import3쌍을 current target에 결속, changed_files0. 수용72를
   새 원장에 추가하며 원형37942/b91/meta9 역복원을 확인한다. check/import도 locale를 명시한다.
5. 전체수용 hash/L1 한 번과 명시12 한 번을 전후 입력으로 봉인한다. 실패 시 원형을 보존하고
   영향 범위 같은 입력만 재실행한다. context/queue/diff 표적검사. Godot/full/240주 실행0.
6. source-like 문서까지 exact C2에 묶고 비저자 work_unit232 판정 뒤 metadata wrapper만 추가한다.
   WORK 새 항목 역제거로 기존35,070B·EOF LF2도 실제 적용 뒤 확인한다. 이력 이동0.
   STATUS는 clean 원장에서 생성·검사하며 main/번역 브랜치를 비파괴 동기화한다.

성공 때만38014(JA12670/CN·TW각12672)/b92/meta9다. 새UI수용72=기존JA24검수+CN/TW신규48이며
72개를 모두 새로 쓴 번역이라고 하지 않는다. 자동 검사는 계약 회귀이지 재미·깊이·문체 GO가 아니다.
현지화·권한 정본은 기존 I18N/WORK_UNIT을 유지한다. 이번 키/파일/마감은 일회성이다.

# Active Queue Spec: ORDER-378

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-378 [P0·현지화] 조건식 배달 제목 두 개의 수집·세 언어 표시를 닫는다

**[~] 2026-09-28 Codex 착수 — 아래 파일만 소유한다.** 부모 ORDER-157,
사용자의 계속 개발·효율적인 검수 위임. 기준 f539989978d61e0f83277a563ec1af22d4cd98ab.

## 깊이 3문·크기
1. 지우면: Aruba 실제 header의 두 날씨 상태가 세 언어에서 영어로 남는다.
2. 24주 차이: 선택/경제/진행 변경 없음. 한국어 같은 제목의 지역 언어 이해만 바뀐다.
3. 경쟁: 전체 번역보다 작은 두 문자열이지만 수집 누락을 수리하지 않으면 공식 수용이 불가능하다.
한 결함의 두 제목×세 언어 6값이다. 임의의 15단위 채우기는 하지 않는다.
기존 collector·append 경계 보완은 이 결함의 직접 의존이며 새 호환 모듈은 만들지 않는다.

## 정확한 소유권
- compat357: `tools/ja_translation_pipeline.py`, `tools/first_start_notice_self_test.py`,
  `tools/ui_translation_append.py`, `tools/ui_translation_append_self_test.py`,
  `tools/order365_ui_receipt_compat.py`, `tools/audit_scope.json`.
- root: `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`에
  한국어 `배달 루트 설정`, `비 오는 저녁 배달` 두 키만 추가,
  `content/meta/full_game_localization.json` 공식 receipt·batch 추가.
- root 기록: 이 사양/완료 archive, CODEX_QUEUE 두 인덱스, CLAUDE 현재행,
  WORK_LOG, 생성 STATUS, I18N_INFRASTRUCTURE append 경계 단락,
  agent_review_decisions 및 agent_reviews/ORDER-378.json.
- screen_path_probe: git-private order378 화면 helper·runner만. root만 엔진 실행.
- r3_route_probe: 독립 원문6값·도구 diff·검증 증거·6PNG 검수와 private 보고만.
공유 파일 동시 저작 금지. 실사용자 저장·공개 demo·runtime 전체·기존 번역값·KO/EN·
demo scope·인간 원장·출시 언어·기존 역사 7모듈·5consumer는 비소유.

## 구현·검증 경계
- 동일 조건의 두 명확한 KO/EN literal pair만 비포맷 수집한다. 실제 collector에서
  신규 집합을 한 번 비교하고 예상 밖 추가는 본 범위에 섞지 않는다. 옛 ID/hash 불변.
- collector 자체 봉인과 역사 census는 exact inverse로 보존. 현재 raw를 과거로 위장하지 않는다.
- 기존 append를 JA/CN/TW로 확장하되 immutable365의 기존 3파일 증명은 유지한다.
  JA baseline은 같은 실제 Git commit/blob에 결속한다. 기존 값/순서/바이트 변경,
  누락·위조·rollback·보호 키는 계속 거절한다. UI3+원장은 같은 제품 commit에 묶는다.
- 한국어에서 언어별 직접 작성6값 → 독립 전수 대조 → 공식 export/check/import.
- 변경된 두 verifier의 새/영향 self 1회, 실제 collector·current receipt guard·영향 consumer만.
  기존 self 본문·핀 보존을 검사하고 전체 역사/240주/전체 감사/직전68상태를 재실행하지 않는다.
- pre-autoload 격리 bootstrap, MainGame 생성 Aruba에서 clear/rain ×3언어 6준비 화면,
  실제 header·locale font/glyph·1280×800 경계와 6PNG. source/helper/실사용자 파일 전후 동일.
  새 raw 입력·자연 전체 shift·공개 정상도달·원어민·물리패드 증거로 부르지 않는다.
- context/queue/registry/diff, 영향 선택 목록, 최종 source 결속 독립 work_unit GO 후 마감.
- 본편/새 package HOLD, 공개 GO1/인간 OPEN45 및 과거 판정/실패 보존.

## 규범 판정
이 제목·파일·표적실행 범위는 일회성. 3언어 append의 지속 사용법만
I18N_INFRASTRUCTURE 기존 단락을 갱신하고 다른 정본에는 복제하지 않는다.


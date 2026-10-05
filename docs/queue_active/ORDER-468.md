# ORDER-468 — PR31 문장 수리와 검증 이력 통합

#### [~] ORDER-468 [P1·사용자 지시] Claude의 B3/B4 문장 수리를 main에 들인다

**[~] 착수 — 2026-10-05.** 사용자 지시가 기존 순서보다 우선한다.
정본 작업표는 PR31의 `docs/queue_backlog/PR31_INTAKE_RUNBOOK.md`이며
2026-10-03 갱신부터 확인했다. 현재 로컬에는 없고 PR 브랜치에 있다.
관측 PR head `b9284e3`는 지시의 `fe2bb4c4`에 심의 목록 gambling/violence 지문
보정 1커밋만 더했다. 새 출시·심의 인증을 뜻하지 않는다.

## 순서와 단위

1. `english_hangul_audit.py`의 Holdem 한국어 전용 조사 교정 오탐을 수리한다.
   실제 영어 누출을 허용하지 않는 양성/음성 검사와 현재 기본 검사를 한다.
2. B3 `b0efea56`과 B4 `3643da2b`~`446eab5d`를 하나의 문장 수리 묶음으로 들인다.
   이미 main에 있는 B2 영수증·패드 폰트는 중복 적용하지 않는다.
3. 같은 범위에서 MainGame exact6줄 승인/호출 좌표, release inventory 실제 전이,
   `arc_father_legacy` description·memory 2개(총3잎)의 JA/CN/TW 영수증을 맞춘다.
4. 작업표 CI 귀속을 현재 후보와 비교한다. 새 실패0을 확인하기 전 완료하지 않는다.

깊이3문: 살아 있는 아버지에게 사망 문장을 보여 주는 사실 오류와 장면을 대신하는
해설을 수리한다. 분기·경제·효과는 추가하지 않는다. 정확한 인물 상태와 장면이
플레이어가 이미 선택한 삶의 결과를 전달해야 한다. 새 장면 집필은 아니다.

## 소유 파일과 보존

- root 통합: `content/events*/` 중 PR B3/B4 변경 파일과 `content/endings*.json`,
  `content/meta/full_game_localization.json`, `content/meta/release_content_inventory.json`,
  `docs/CONTENT_RATING_INVENTORY.md`, `scenes/MainGame.gd`의 `_resolved_ending_description` exact6줄.
- root 지원: `tools/english_hangul_audit.py`, `tools/main_game_locale_history.py`,
  `tools/ja_translation_pipeline.py`, `tools/ja_translation_audit.py`, `tools/ui_translation_append.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py` 및 그 실제 inventory history 소유 도구,
  `tools/audit_scope.json`, 신규 `tools/pr31_intake_check.py`.
  소유 도구의 정확한 추가 경로는 실행 전 이 사양에 좁혀 기록한다.
- PR B1 근거 문서: DECISIONS·I18N_GLOSSARY의 PR 변경, PR의 queue_backlog 문서와
  역사 기록. 기존 WORK_LOG는 덮어쓰지 않고 이력 링크/이번 항목만 보탠다.
  `tools/prose_signal_report.py`는 제품 들이기에 필요하지 않으므로 제외한다.
- root 기록: 이 사양/큐/CLAUDE 현재행/WORK_LOG/생성STATUS 및 독립 판정 원장.
  비저자 검수 보고 `docs/agent_reviews/ORDER-468.json`; private 증거 `.git/pr31-intake-*`.
- 이전467 미완료 변경4도구와 InvestmentAPCopyCheck2파일은 지우지 않는다.
  AP3문구 수리와 실제 Git 핀을 보존하고 이번 Main6줄과 연결한다.
  기존467의 미실행 검사를 실행한 것으로 기록하지 않는다.

**금지:** 모든 언어의 `arc_events.json`, `project.godot`, 공개 데모/사용자 저장,
과거 인간 판정과 실제 GO를 변경하지 않는다. 7k·수첩/5년 초안은 후속 별도 오더다.
PR 전체 파일을 덮어써 main의 새 번역·AP 수리를 되돌리지 않는다.

## 검증과 완료 경계

- 실제 merge-base/두 부모/제품 경로·전후 원문을 기록한다. 영어 한글 오탐 수리부터
  확인하고, JSON 의미 diff와 main 신규 영수증 보존을 검증한다.
- 기본 JA_UI, JA_DEMO_PIPELINE_SELF_TEST, ZH_DEMO_AUDIT/SELF_TEST,
  CHAPTER1_INVENTORY_HISTORY, full_game_localization inventory와 관련 기존
  source/receipt/서사 검사를 귀속표에 따라 실행한다. 과거 실패를 새 PASS로 바꾸지 않는다.
- 새 exact successor는 부모/객체/전체 역상을 검증하며 범용 예외를 추가하지 않는다.
  아버지 생사·empty_house 분기를 준비된 회귀로 확인한다. 실제 화면·자연 플레이와 구분한다.
- context/queue/생성STATUS/등록/diff를 확인하고 검증된 변경만 main에 푸시한다.
  병합 또는 검사 진행 중에는 완료·출시 GO가 아니다. 원어민/인간 플레이/물리패드
  미관찰은 그대로다. 기존 규범 적용, 이번 통합 지시와 exact 핀은 일회성이다.

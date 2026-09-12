# 주거·직업 칭호의 실제 세 언어 표시

#### [~] ORDER-242 주거·직업 칭호 세 언어

[~] 착수 — 2026-09-12, Codex. 사용자 전체판 현지화·내부 검수 위임의 후속이다.
기준선 `c2cc7fd5fe8658f59301b3a1bce7f5966dc1e3c6` main, source `ad7ff36b`.
공개 M01~M06 GO1·인간 OPEN45·본편 HOLD는 그대로다. 이 사양은 일회성이다.

## 실물·범위

`MetaProgression._localized_title`는 KO 외 모든 언어에 TITLE_EN을 덮어써
칭호 도감·해금 알림·엔딩 보상이 JA/CN/TW 사전을 거치지 않는다.
실제 MainGame Title 버튼→도감의 unlocked 카드, 월 정산→새 칭호,
엔딩의 `_ending_add_unlocks`가 소비자다. 휴면 helper를 번역 실적으로 세지 않는다.

선택은 기존 9칭호의 name/desc 18표면, 1배치다. 크기는 독립 판정 가능한 기존
표면18 기준이며 새 선택·장면이 아니다. 원문과 해금 조건은 그대로 둔다.

- 주거5: gosiwon_survivor, first_move, apartment_life, gangnam_resident, long_gosiwon.
- 직업4: first_paycheck, one_year_worker, three_year_worker, long_unemployed.
- raw KO18을 재사용한다. 아파트 입성은 기존 수용1을 유지하고 나머지17×3의
  신규 수용51만 목표다. 실제 수집·공식 수용으로 확정하기 전에는 완료 숫자가 아니다.
- 기존 영어 `Apartment Life`와 MainGame milestone의 `Entered an apartment`는
  둘 다 보존한다. 새 shared-translation 충돌1은 현재 delta로 분리 검증하며
  옛 collision/hash/문맥 registry를 덮어쓰거나 영어를 맞춰 바꾸지 않는다.
- cat/rare, 잠긴 카드의 미발견 칭호/빈 설명, 나머지41칭호, unknown/empty/custom 입력의
  기존 동작, ALL_TITLES/TITLE_EN·해금 조건·저장ID·보너스·게임 상태는 보호한다.
  연속 거주·연속 무직·주택 소유·새 만남 등 원문에 없는 사실을 번역에 넣지 않는다.

## 만지는 파일 — 선언된 소유권

- source2 (Plato): `autoloads/MetaProgression.gd`, `tools/ja_translation_pipeline.py`.
  선택18 literal lookup과 exact owner/KO/EN/field 계약, 실제 collector는 현재
  호출을 그대로 수집한다. 역사 투영은 옛 계약 비교에만 적용한다. 기존 self를
  지우거나 현재 통계로 기대값을 자동 생성하지 않는다.
- 번역3 (ROOT): `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`.
  KO 직접 지역별 저작·전량54 독립 검토. 기존 수용 apartment3은 byte 보존한다.
- test2 (Rawls): `tools/MetaTitleLocaleCheck.tscn`, `tools/run_meta_title_locale_qa.sh`.
  프로젝트 autoload 전에 격리한 storage로 실제 함수/Control 검사를 수행한다.
- 수용·검증 (ROOT): `content/meta/full_game_localization.json`, `tools/audit_scope.json`.
- 운영 (ROOT): `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  이 사양과 `docs/queue_archive/ORDER-242.md`, `docs/agent_reviews/ORDER-242.json`,
  `docs/agent_review_decisions.json`.
- 다른 제품·검사 파일 변경은 이 사양에 끼워 넣지 않는다. `project.godot`,
  실제 사용자 save/meta, human 원장, 공개 demo 제품·manifest, KO/EN 원문은 변경0.

## 착수 질문과 검증

- 없애면 무엇이 깨지는가: 실제 unlocked 칭호 소비자는 번역 사전을 우회해 영어를 낸다.
- 24주 뒤 상태·같은 자리 경쟁: 새 선택이 아니며 상태/경쟁/비용을 만들지 않는다.
  기존 조건을 만족한 플레이어만 기존 칭호를 얻는다. 화면의 언어만 수리한다.
- source 검증 기대/정상·변조 모집단을 구현 전에 고정한다. owner/함수/KO/EN,
  중복/누락/예상 밖 pair, shared apartment 양쪽 영어 및 역사 역복원을 검사한다.
- runtime 모집단은 실행 전에 고정한다. KO/EN/JA/CN/TW의 선택9 전량,
  미선택41 보존, 실제 도감 unlocked/locked, 새 해금 반환/알림·엔딩 카드,
  조건 경계·중복 해금·언어 변경·unknown과 원본 Dictionary/저장ID 불변을 포함한다.
  성공 marker와 exit뿐 아니라 stdout·Godot log 오류, 입력/격리 storage를 확인한다.
  실패는 원형 보존하고 같은 모집단을 수리 재검한다. headless는 실제 렌더가 아니다.
- 공식 export/check/import는 clean checkpoint에서 locale을 명시하고 신규17×3만
  수용한다. 기존38,587/b98/meta9와 공유 apartment3은 raw 역복원·hash로 보존한다.
- 새54의 L1·독립 언어 전량, 최종 수용 전체 hash/L1, 실제 component 및 source
  고정 회귀를 실행한다. 공동 최종 named 차선은 fullself/JAself/ZHself/EN leak/
  registry/queue/agent/context/queue 정합만 포함한다. 변경 없는 녹색 검사는 반복하지 않는다.
- 전체 audit·240주·공개 패키지·원어민·인간·물리 입력 검사는 이번에 실행하지 않는다.
  새 공개 출고, 전체 칭호/UI 완료, 전체판 GO를 주장하지 않는다.

## 닫기

소스·운영 입력을 먼저 freeze하고 비저자 Poincare가 직접 원문/번역/코드/증거를
검토한다. 실제 Git에서 관측한 source commit/tree와 검토 HEAD를 결속한 scoped
GO만 기록하며 사용자 재판정을 기다리지 않는다. 자동 검사는 재미·깊이·문체
판정이 아니다. 실제 렌더·원어민·인간 플레이·물리 감각은 미관찰로 남긴다.
필수 잔여가 있으면 원형 모집단을 축소하지 않고 수리한다. 새 발견은 다음 오더다.

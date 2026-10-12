# ORDER-570 — 본편 엔딩 후일담 8문구의 현지화 소비자 등록

#### [~] ORDER-570 [P0·전체 현지화] 착수 — 2026-10-12

전체 번역 위임/ORDER-157의 미확정 consumer 수리에 따라 기존 정상 본편 엔딩이
읽는 후일담 8키만 `ui_unverified`에서 검증된 `ui`로 등록한다. 번역·원문·
라우팅을 바꾸는 작업이 아니다. 선행569/ad3ed3e CI38218711500은 아직 진행 중,
M17/562 하나만 OS잠금 HOLD다. 새 월을 열지 않는다.

## 깊이 3문·확인된 결함

1. 현재 실제 `_ending_build_people_page`가 EndingSystem의 두 resolver 반환값을
   `_tr(text,text_en)`로 읽는데, collector는 같은 8키를 미확정으로 분류하여
   공식 import/append 수용을 막는다. 등록 없이는 안전한 번역 수용이 안 된다.
2. 이 수리는 선택·24주 상태를 바꾸지 않는다. exact W240 sacrifice/outbound
   영수증을 읽는 기존 resolver·플래그·효과·저장은 그대로다.
3. 같은 후일담 페이지의 최종 서명 3문구와 구별한다. 이번 모집단은 아래
   3+3+2뿐이며 나머지 미확정 UI나 휴면 함수에 blanket 수용을 주지 않는다.

| EndingSystem 상수 | 선택 index / kind |
|---|---|
| CHAPTER5_FINALE_OUTBOUND_CODA_BY_CHOICE | 0 meal / 1 apology / 2 distance |
| CHAPTER5_GENERAL_OUTBOUND_CODA_BY_CHOICE | 0 minseo_answer_forward / 1 father_envelope_action / 2 minseo_meeting_request |
| CHAPTER5_GENERAL_SACRIFICE_CODA_BY_CHOICE | 0 addresses / 1 target |

실제 source: `systems/EndingSystem.gd:64~117`; reader: 같은 파일의
`chapter5_general_sacrifice_coda`, `chapter5_finale_outbound_coda` →
`scenes/MainGame.gd:_ending_build_people_page` → `_tr` → LocaleManager.ui.
실제 화면 실행 증거는 아니다. JA/CN/TW 사전은 모두 이8키가 없다.

## 정확한 소유

- root: `tools/full_game_localization.py`에 narrow source/consumer helper와 collect
  등록만, `tools/ja_translation_audit.py`·`tools/zh_translation_audit.py`의 같은
  helper 재사용·present target 검증/unknown-extra 판별만.
- manual_save_ci: `tools/full_game_localization_self_test.py`의 이8 source/reader
  양성·누락/중복/미지원변경·충돌 음성 회귀만. 다른 파일 편집0.
- rework_batch_plan: 비저자 실제diff/source/원자료 독립 검수만, private 보고서.
- mod_layer_ci: 선행 CI·기존 보존 snapshot 비교만, 제품 편집0.
- root: `docs/I18N_INFRASTRUCTURE.md`의 현재 provider 경계, 큐 두 파일/이 사양
  (마감 archive)/WORK_LOG·CLAUDE 현재행만.

새 도구·러너·검사종/등록·성능계측·검증비용 최적화0. 기존 모듈/검사를 쓴다.
정적 JA collector/self-seal·UI append verifier·audit_scope·게임/KO/EN/JA/CN/TW
번역·portable 원장·project/presets·데모 pin/공개 원문·사용자/공개 저장/설정·
Human/과거 판정·기존 raw/seed/app은 비소유다.

## 검증·완료

- 실제 collector 호출에서 exact8가 검증된 ui이고 같은8 unverified가 사라지는지
  확인한다. source manifest와 나머지 leaf/source/unsupported가 보존되어야 한다.
- helper는 source constants의 exact3+3+2 역할과 실제 resolver→UI lookup/표시를
  읽고 fail-closed한다. target나 cache로 source를 추정하지 않는다.
- 신규 source는 기존 정적/데모 분모 밖이다. 현재 누락8은 full INCOMPLETE로
  남기고 JA 기존검사의 신규 필수누락8 회귀를 만들지 않는다. 없는 번역을
  coverage로 세거나 unknown 전체를 허용하지 않는다.
- 기존 full-game-localization-overlays lane을 먼저 preview 후 실행하고, 변경된
  JA UI/ZH 실제 감사·context/queue/diff를 더한다. 전체audit/240주/엔진/native0.
- 비저자 검수·새 실패0·비소유 byte 보존 뒤 한정 source 계약으로 마감한다.
  실제 번역은 공식 export/check/import가 가능한 다음 별도 오더에서 한다.
  전체 INCOMPLETE·원어민/렌더/인간/물리패드 OPEN·출시 HOLD다.
- provider의 지속 경계만 I18N_INFRASTRUCTURE가 소유한다. 이8 모집단·소유·
  실행순서/검증은 일회성이다. 사람 승인이나 외부 출시 권한을 발급하지 않는다.

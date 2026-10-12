# ORDER-571 — 엔딩 후일담 8키 일본어·간체·번체 직접 번역

#### [~] ORDER-571 [P0·전체 현지화] 착수 — 2026-10-12

사용자의 전체 번역 위임/ORDER-157과 완료570의 검증된 후일담 consumer를 따른다.
기준5013159b/tree a43eb5ea에서 아직 없는 8키×3언어=24 target만 채운다.
M17/562 하나는 OS잠금 HOLD이며 새 월을 열지 않는다. 선행570 push CI는 미확정이다.

## 깊이 3문·표적

1. 이 추가가 없으면 EndingSystem 후일담의 정상 `_tr` reader가 준비 언어에서
   영어 fallback을 쓴다. 이미 등록된 8키를 공식 파이프라인으로 수용한다.
2. 선택·24주 상태는 바꾸지 않는다. 기존 W240 sacrifice/outbound receipt와
   그 reader·조건·효과·저장 그대로, 제목+본문 한 줄바꿈을 각각 번역한다.
3. 같은 엔딩 page2에 보이는 3+3+2 후일담을 대상으로 한다. 최종 서명3키나
   다른 미확정 UI를 추가하지 않는다. 미답·미읽음·미화해·미소유의 사실을 보존한다.

| source 상수 | index / kind |
|---|---|
| CHAPTER5_FINALE_OUTBOUND_CODA_BY_CHOICE | 0 meal / 1 apology / 2 distance |
| CHAPTER5_GENERAL_OUTBOUND_CODA_BY_CHOICE | 0 minseo_answer_forward / 1 father_envelope_action / 2 minseo_meeting_request |
| CHAPTER5_GENERAL_SACRIFICE_CODA_BY_CHOICE | 0 addresses / 1 target |

`systems/EndingSystem.gd:64~117` → 두 coda resolver →
`scenes/MainGame.gd:_ending_build_people_page` → `_tr` → LocaleManager.ui.
실제 source 경로이며 화면 실행 증거가 아니다.

## 정확한 소유

- root: `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`
  각각 위 신규8키, `content/meta/full_game_localization.json` accepted24/checksum/UI batch1.
- root: 큐 두 파일 행/순번, 이 사양(마감 archive), WORK_LOG·CLAUDE 현재행.
- manual_save_ci: JA KO 직접 초안만 `.git/order571-20261012/ja.draft.json`.
- mod_layer_ci: TW KO 직접 초안만 `.git/order571-20261012/tw.draft.json`.
- root: CN KO 직접 초안·공식 export/check/import와 receipt 편입.
- rework_batch_plan: 비저자 KO8↔target24 전수·공식receipt·4파일 역치환·비소유 보존
  검수만, 같은 private 디렉터리에 별도 보고. 저작·tracked 편집0.

원문/KO/EN·runtime·collector/검사·source manifest·SHIPPING_LANGUAGES·project/presets·
데모 pin/공개 원문·사용자/공개 저장/설정·Human/과거 판정·옛 raw/seed/app은 비소유.
새 도구·검사/등록·전체 audit·240주·엔진/native·비용 계측/최적화0이다.

## 수용·완료

- 선언 commit/push 뒤 source-bound export8/locale을 먼저 만든다. protected=false/
  이전값null과 exact8을 확인하고 KO에서 세 언어를 독립 작성한다. 중역·문자 변환0.
- 비저자 전24 대조 뒤 공식 check/import --accept. 원공식 receipt header/digest를
  portable batch1에 보존하고 기존 accepted/metadata/batch prefix·사전값/순서를 유지한다.
- 기존 append verifier와 실제 Git source manifest를 사용해 4파일 additions inverse를
  확인한다. named full-game-localization-overlays lane preview/실행, context/queue/diff.
  수정하지 않은 append self-test나 옛 전체 suite를 반복하지 않는다.
- 새 실패0·독립 GO·비소유 byte 보존 뒤 source/영수증 한정 마감한다.
  렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·본편/출시 HOLD를 유지한다.
- 기존 I18N 정본을 적용한다. 모집단·소유·순서/검증은 일회성·새 규범/승격0이다.

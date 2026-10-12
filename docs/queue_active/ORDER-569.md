# ORDER-569 — 엔딩 몸·밤 관찰 UI 중국어 누락 8키

#### [~] ORDER-569 [P0·전체 현지화] 착수 — 2026-10-12

전체 현지화 위임과 공식 inventory의 확인된 누락에 따라 정상 본편 엔딩 기록의
몸·밤 관찰문 8개를 KO에서 CN/TW로 각각 직접 작성한다. M17/562는 OS잠금
HOLD이며 새 월은 열지 않는다. 선행568 CI38208386928은 exact f5989124에서 success다.

## 깊이 3문·소비자

1. 이 추가가 없으면 CN/TW 기본 사전에 없는 8키가 community override도 없을 때
   영어로 폴백한다. 엔딩 기록의 몸·밤 관찰이 언어와 어긋난다.
2. 선택·수치·24주 상태를 바꾸는 기능이 아니다. 기존 health/mental 값을
   읽는 같은 네 구간(70/45/25/그 미만)의 관찰문만 번역한다.
3. 같은 기록 페이지의 몸/밤 라벨·수치와 경쟁하므로 짧은 관찰 톤을 유지한다.
   새 진단·완치·도덕 판정·정확 시각을 더하지 않는다.

`MainGame.gd:_full_story_resume_ending:763` → 엔딩 page4:21209 →
`_ending_build_record_page:21565` → `_ending_stat_grid:22765` →
`_core_loop_v2_condition_metric:3265~3303` → `_tr:476`/`LocaleManager.ui:212`.
함수 이름의 V2와 달리 실제 정상 본편 엔딩 consumer다. native 실행은 아니다.

## 정확한 소유·8키

- root: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각각 아래 신규8키만,
  `content/meta/full_game_localization.json` accepted16/checksum/UI batch1만.
- root: 큐 두 파일의 행/순번, 이 사양(마감 시 archive), WORK_LOG·CLAUDE 현재행.
- manual_save_ci: TW KO 직접 초안만; root는 CN 직접 초안/공식 교환 담당.
- rework_batch_plan: `.git/order569-20261012/` 비저자 전16문구·영수증·역치환 검수만.
- mod_layer_ci: 선행568 최종 CI 실제 step 증거만, 제품/번역 편집 없음.

| KO exact key | 기존 source 행 |
|---|---:|
| 숨이 고르게 돌아왔다 | 3281 |
| 하루 끝엔 몸이 무거웠다 | 3283 |
| 계단에서 숨이 찼다 | 3285 |
| 잠 뒤에도 떨림이 남았다 | 3287 |
| 잠이 제때 왔다 | 3290 |
| 생각은 남아도 잠은 왔다 | 3292 |
| 생각이 오래 남았다 | 3294 |
| 새벽까지 잠이 오지 않았다 | 3296 |

8키×2지역=16독립 target leaf 한 묶음이다. 추정 배치 수를 맞추려고 다른 UI를
추가하지 않는다. KO/EN/JA·코드·임계값·라우팅·project/presets·게임/공개 원문·
저장·설정·Human/과거 판정·공개 GO·retail allowlist·옛 raw/seed/app은 비소유다.

## 수용·검증·완료 경계

- 선언 commit/push 후 공식 bounded export8/locale, protected=false·이전값 없음을
  확인한다. 독립 저작/비저자 KO 대조 뒤 check/import --accept 한다.
- 원공식 receipt header/digest·source/target hash를 portable 원장에 추가한다.
  JA/CN/TW UI+원장 네 파일의 기존값/순서/bytes는 additions inverse로 보존한다.
- 기존 full-game-localization-overlays 차선 목록을 먼저 읽고 실행한다.
  unchanged verifier self-test·전체 audit·240주·엔진·새검사/등록/도구0이다.
  기존 append validator와 source manifest 검증을 재사용하고 context/queue/diff를 확인한다.
- source/영수증 한정 수용이며 렌더/원어민/인간/물리패드 OPEN·전체 번역
  INCOMPLETE·본편/출시 HOLD다. 잠긴 Mac의 실제 화면을 관찰했다고 하지 않는다.
  기존앱 미반영·M17 하나·새 월0이며 현황판 단독 커밋0이다.
- 기존 I18N 정본을 적용한다. 위 파일 범위·8키·순서/검증은 일회성, 새 규범/승격0.

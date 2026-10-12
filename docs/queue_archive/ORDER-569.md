# ORDER-569 — 엔딩 몸·밤 관찰 UI 중국어 누락 8키

#### [x] ORDER-569 [P0·전체 현지화] source·영수증 한정 완료 — 2026-10-12

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
  unchanged UI append verifier self-test·전체 audit·240주·엔진·새검사/등록/도구0이다.
  기존 append validator와 source manifest 검증을 재사용하고 context/queue/diff를 확인한다.
- source/영수증 한정 수용이며 렌더/원어민/인간/물리패드 OPEN·전체 번역
  INCOMPLETE·본편/출시 HOLD다. 잠긴 Mac의 실제 화면을 관찰했다고 하지 않는다.
  기존앱 미반영·M17 하나·새 월0이며 현황판 단독 커밋0이다.
- 기존 I18N 정본을 적용한다. 위 파일 범위·8키·순서/검증은 일회성, 새 규범/승격0.

## 마감 실측 — 새 언어 출시/실제 화면 GO 아님

- 선언 af60ac9dbf8b1213d4c98e0ce75295864227768d/tree3cc30e35c82586216f65d0b5acec2bcf20955cc4를 먼저 commit/push했다. 공식 export 각8은 전부 protected=false/이전값null이다. source manifest8231e096…00e452와 실제 선언 Git source census가 일치한다.
- CN root/TW manual_save_ci가 KO에서 독립 저작했다. 비저자 rework_batch_plan이 KO8↔target16 전량 대조 후 import 전 초안 GO, import 뒤 source/receipt GO·blocker0을 냈다. 원어민 판정이 아니다.
- 공식 check2/import2 실제exit0·각 leaves8, CN/TW UI2157→2165·JA3055 불변이다. 원장 accepted CN/TW14696→14704·JA13161 불변, 기존313 batch+UI1=314다. 기존 metadata/accepted/batch prefix/사전값·순서 보존, source/target16·공식 header2/digest2 결속이다.
- checksum0bbe426c2cd850309b664dd8b6a26554b71ca9e6d972a0aeccd436aaa69697da. 추가 역치환은 JA/CN/TW+원장 네 파일 전체를 선언 Git bytes로 복원한다. 기존 append verifier/실제 Git source manifest 기능으로 검증했으며 새 검사/도구0이다.
- product SHA256: CN de44448334406291bbf1829cf6a3c727c95d621b32bfb64f84e5e166dcff28cc; TW f39221c593c810bd4a2457157720f36e74c8c7b3abdfb4ab7fd5815d924642cd; 원장1c76146309eec2d2a89e5778f080fd9e88abd25f950379acc2566643cbb1afa1. source 후보는 선언 commit+이 exact3파일로 결속하며 독립 보고에 없는 새 후보 GO를 추정하지 않는다.
- 기존 named lane11 실제exit0/stderr0, stdout4088B/SHA093e11870ca1d4a870da300fbd7bf579e7da2aa4f2670375d597042c65add416. 새 실패0이며 prepared 언어 skeleton PASS를 전체판 번역 완료로 바꾸지 않는다. context/queue/diff는 마감 metadata 뒤 한 번 더 확인한다.
- 원자료 `.git/order569-20261012/`: batch/response 각2, check-results/import-results, append-proof, lane.stdout/stderr/result, source-review 및 preservation-before/final. before SHA8f35ed4b621adb8465506140faf5465d99a2eedf0080108ff4e7dad5936bdd24, 기존46그룹776항목·비소유3352파일·앞568봉인14파일에 결속한다.
- 비저자 `source-review.md` 79줄/9518B·SHA8562277b674002d87afc861a08270510fda21c14e8ae605fcd86a8fc4c8fabfd를 root가 전량 읽었다. 언어16/공식receipt/원자료/네 파일 inverse 한정 GO·blocker0이며, 모든 metadata/외부 보호와 commit 뒤 history/CI는 이 보고의 판정 범위가 아니다.
- 선행568 CI38208386928은 jobs2/22step success, `.git/order568-20261012/ci-final.json` SHA9f5c68c1c743512633938ef7aa1542456d0bbb7f9693a91f85d7497c15002df3다. 이번 push의 CI는 별도이며 pending을 녹색으로 재사용하지 않는다.
- 강남드림 개발 스킬의 원문/데모/저장 보존과 정적/관찰 증거 분리를 적용했다. game/runtime/KO/EN/JA/임계값/라우팅·저장·Human·project·기존 앱 수정0, 엔진/native/전체audit/240주/새월0이다. M17/562 하나만 OS잠금 HOLD, 이번 번역의 수정화면/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·본편/출시 HOLD를 유지한다. 모든 배치 지시는 일회성·승격0이다.

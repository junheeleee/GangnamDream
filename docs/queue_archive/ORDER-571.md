# ORDER-571 — 엔딩 후일담 8키 일본어·간체·번체 직접 번역

#### [x] ORDER-571 [P0·전체 현지화] source·영수증 한정 완료 — 2026-10-12

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

## 마감 실측 — 실제 화면·원어민·출시 GO 아님

- 선언69c768b7806257a04c3d3eee9918324d25a951c4/tree cf67f39d98b66b831f35e66e274503cfcc05a7a3를 먼저 commit/push했다. 아래 제품4핀으로 미커밋 후보를 결속했고, 구현 commit/tree·first-parent 증명은 commit 뒤 private postcommit에 실제 관측한다.
- JA는 manual_save_ci, CN은 root, TW는 mod_layer_ci가 KO8에서 각각 저작했다. JA는 EN/CN/TW를 참조하지 않았고 root/TW는 필수 원문 열람에서 인접 EN을 보았다. EN 중역·간번 문자 변환0을 저자가 진술했으며 EN 노출0이나 사적 저작 경로의 독립 증명을 주장하지 않는다. 비저자 rework_batch_plan이 KO8↔응답24↔실제 사전24를 전수 읽어 의미 결함0으로 판정했다.
- 공식 export8×3의 exact source/locale/header/protected=false/previous=null을 확인했다. 최종 check3 actual0·import3 actual0, 원공식 receipt3 header/semantic digest를 portable UI batch1에 그대로 넣었다. 사전 각8/accepted24만 추가, JA13161→13169·CN/TW14704→14712, batch314→315/checksum b0decb765ba959ac6e1f122f18795202706204642bbdb91e149d13d0bb5b3da4다.
- 최초 CN v1/v2는 두 획의 숫자 대조 checkFAIL, TW v1은 원문에 없는 explicit兩人으로 checkFAIL이었다. CN은 첫 장/금액 다음에 두 획이 오도록 자연스러운 어순을 고쳤고 TW는 兩人만 제거했다. 같은 사실을 보존해 최종 actual0이며 checker 원인 가설을 확정/수리로 주장하지 않는다. 초안/실패/응답 원자료는 덮지 않았다.
- 공식 JA writer가 기존 탭5를 space로 정규화해 첫 inverse가 actual1이었다. 해당 과거 들여쓰기만 복원해 기존 사전/원장 4파일 exact inverse actual0을 얻었다. target/hash는 불변, 검사 완화0이다. 실제 선언 Git source manifest8231e096a45b716f8c6ee30d82641eac77900a213afced2173334b888200e452도 일치한다.
- named full-game-localization-overlays를 preview 후 실제 실행해 11통과/outer exit0, full self-test271/75.796s OK 포함이다. 전체 audit/240주/엔진/실제 앱 검사가 아니다. wrapper가 보고한 결과로 한정하며 개별 검사별 lossless raw 로그를 새로 확보했다고 주장하지 않는다. 기존 EXTRA 등록 advisory2는 그대로다.
- 독립 source/receipt/preservation GO·blocker0. source-freeze09:32:28Z의 dirty4/선언HEAD/tree stable, 보호49그룹819항목·비소유3353 blob/mode·기존568/569/570 raw43 exact다. 이 관측은 이후 root 마감 metadata/commit/CI GO로 확대하지 않는다. root가 독립 보고78줄/11106B 전량을 읽었다.

| 최종 제품 파일 | SHA256 |
|---|---|
| locale/ui_ja.json | 1531f2decbdce74f418543044d1f6879317267d92a14fcd63da83793d9564fa5 |
| locale/ui_zh-CN.json | 047f4d722ac3a8a591a397cf392ad94ad9dcf5990f29be9ed5e3ede6b66588d1 |
| locale/ui_zh-TW.json | 9b6e3af3ab2e06d2fb9979c30550401353f53b3a51c5af4335cce89cd71924fb |
| content/meta/full_game_localization.json | aaff0f19e532af927710eb5aaf0ffd23eb7a175afef4526bd72bd69484e61bc2 |

원자료: `.git/order571-20261012/`. 아래 파일은 기존 실제 도구 반환/독립 관측을 결속하며 재구성한 성공 출력이 아니다.

| 증거 | SHA256 |
|---|---|
| export-proof.json | 09f378b2a98a6c1fc76df4fe5ac43928991cf379018d7f02a71d8084da06bf0c |
| checks-initial.json (실패 보존) | 15f6ea733e7db8357bec3de06b53cde4ab1e18d5468d7ae66d2d569ad839d8fa |
| checks-second.json (CN v2·TW 초기 실패 보존) | 766e8608a4b51f8923475ef5e4a58b308e5a6b1444c3ad6d697efd9d7b3becbc |
| checks-final.json | 3845786bc535fd92669a38e0ed34659a1118e5f99383abf41ddc73a39a6fab27 |
| import-results.json | 4b4d3154449e03eb993e9a8bd5ade5a13e21c669d1219a5cd3b0360f8efb4201 |
| append-proof-initial.json (JA 탭 실패 보존) | 952aef719f4274c500bf15bad6d19abf14161c55825f93c330d8fad80a0f74e4 |
| append-proof.json | ea57ce4a4cfa62f9c66a6f0de8c7218c1dfd267e5d42eaff04db4577910f8b0d |
| lane-result.json | 7615006cfdca61d88fbed92da295f2bff1ac2c51cc49302291a3abd974ea2772 |
| preservation-before.json | f6dae169f2ffd2e1608b89829f9d7546f1eb4ed034ae55d12ba67b76e4d0a0f2 |
| preservation-final.json | 99e46b775a2377b172700de041411beb88a831a38a7502efda098e8a73c1dccb |
| source-review.md | 3a5021a07424daf77c2f541d4fc82d9d8e49ee1fd9978b5b4424ef4fb97ee3b8 |

승격0: 이8키 모집단·파일 소유·수용 순서/검증은 일회성이다. 기존 I18N 정본을 적용했으며 새 규범·도구·검사/등록·최적화 작업은 없다.

gangnamdream-dev의 원문/데모/저장 보존과 source/실관찰 경계를 적용했다. 원문/KO/EN·runtime/선택/효과/플래그·project/presets·공개/사용자 저장/설정·Human/과거 판정·옛 raw/seed/app 수정0이다. M17 하나·OS잠금 HOLD/native0·새 월0, CJK 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·본편/출시 HOLD를 보존한다. 선행570 CI38227953025는09:23:42Z에도 in_progress/null이며 이번 push CI와 별개다. root 메타마감·diff 확인 뒤 구현을 main에 commit/push하고 새 CI는 실제 조회 결과만 보고한다.

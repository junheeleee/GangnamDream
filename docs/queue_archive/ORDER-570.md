# ORDER-570 — 본편 엔딩 후일담 8문구의 현지화 소비자 등록

#### [x] ORDER-570 [P0·전체 현지화] source 소비자 한정 완료 — 2026-10-12

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

## 마감 실측 — 번역 수용/실제 화면 GO 아님

- 선언6fca7e6727d77f780f7edd5334bb6930993fe80d/tree e5ac4fbf45dafe820fa008fb3d61f06281b34bb8를 먼저 commit/push했다. 후보는 이 선언과 아래 exact 소유 파일 핀으로 결속한다. 구현 commit/tree는 commit 뒤 private postcommit에 실제 관측한다.
- 최종 actual collector exit0: 전체17505 불변, exact8 `ui_unverified`→`ui_ending_coda`/`ui`, 같은8 미확정0, unsupported474→466. 나머지 leaf451637d9…3fe4·unsupported2d9c5f58…53c8·source manifest8231e096…00e452는 선언 전과 exact다. static2981/demo701/notice12/Holdem4 불변이며 source_counts의 coda8만 추가했다. 초기 helper606ce6 census는 덮지 않고 최종6b88 census를 별도로 남겼다.
- source literals3+3+2·consumed receipt resolver·page2→raw KO `_tr`→사전 lookup→후처리→카드 text/부착을 기존 collector와 JA/ZH 감사가 같은 helper로 읽는다. 값/종류/소비자 오류·중복·provider 충돌은 fail-closed다. 정적/데모 분모와 기존 필수 번역 게이트는 불변, 신규 누락8은 각 언어 전체 inventory에서 계속 missing이다. 새 source 등록을 번역 수용으로 세지 않는다.
- 비저자 검수에서 selector 입력/출력 덮기와 빈 후처리/카드 text를 놓치는 반례를 찾았다. 실제 게임 코드 결함이 아니라 최초 provider 모델의 결함이었다. 모델을 수리하고 독립16 pure source 반례/양성 모두 기대값을 확인했다. 원문·heading prose·카드 색/크기의 불필요한 옛 값 고정은 제거했다.
- named lane11을 preview했으나 JA 감사 파일은 그 차선 허용 경로 밖이었다. 등록을 넓히거나 생략하지 않고 일반 영향21과 기존 차선11의 합집합27명령을 실제 실행했다. 기존 모듈/검사만 사용했고 신규 도구·검사종·등록/성능계측 작업은 없다. 전체audit/240주/엔진/native0이다.
- 초기 원26명령은25 actual0/카지노 glossary1 actual1이었다. 그 검사만 whole-tracked snapshot이 self-test 동시 편집 전후 a34d48e9…2332b→a1315da8…4d74로 달라졌고, 모든 사례는 valid였다. 초기 부분 raw/실패는 보존했다. tracked 편집 종료 뒤 같은 기존 카지노 명령만 다시 실행해 actual0/stderr0·global21/21·direct260/full248/isolated static238/valid negatives220·OK를 확인했다. 새 실패0이며 검사/보존 guard는 완화하지 않았다. whole-tracked 검사는 편집 종료 뒤 실행한다는 이번 실행순서는 일회성이다.
- 기존 full self-test actual0/271·stderr `Ran 271 tests ... OK`와 marker를 확보했다(검수본09a6cb72). stdout 중간은 도구 반환 한도로 유실되어 strict complete-raw로 세지 않는다. 최종9b5f64d2는 epilogue min-height 양성 치환 범위 한 곳만 고친 것이며 그 positive1을 actual0/완전 stdout·stderr로 재확인했다. 그 외 본문 변경0을 역치환으로 확인했고 최종본 전체271 재실행 주장은 하지 않는다.
- 카지노 fresh stdout1303694B/SHA c9a7510da668f9f18828f3bf16905e71f899028446bacf411bd03b2b7495aa5c는 lossless base64/zlib로 봉인했다. wrapper의 첫 JSON 파싱 오류는 접두어를 처리하지 못한 오류였으며 실제 exit/stdout을 그대로 보관해 올바로 읽었다. 추가 감사 재실행이나 raw 재구성은 없다.
- 비저자 보존15/15 GO·blocker0: 비소유3351파일,46그룹776항목, 기존568/569 각14봉인·사전/원장/runtime7·569공식receipt2가 exact다. 프로젝트·원문·번역·원장·저장/설정·공개 데모·Human/과거 판정·기존 seed/app은 수정하지 않았다. 마감 metadata/commit은 별도 root 확인이며 이 보존 보고의 GO에 포함하지 않는다.

| 최종 소유 파일 | SHA256 |
|---|---|
| tools/full_game_localization.py | 6b88b497e8d5954eed38cee52c24bdf8a45cac60290ea580e3e350df7b71289f |
| tools/full_game_localization_self_test.py | 9b5f64d2f155c4ef0287f1848f9e67e581799fcc819c0a5b60c129732169d16c |
| tools/ja_translation_audit.py | d5a7b513a9fdd0e7b7d8ee00cd49ee61bbbba312e58528b622b5fec7de4b5d0f |
| tools/zh_translation_audit.py | 6b466982f70bd69fe156fc4c7121b3505c57ae5e5972e8a510aa7c2020de594e |
| docs/I18N_INFRASTRUCTURE.md | 4b90e9c39abcfcbd4fc52f0355fe94098fb531e5d7b4ac07bcfd3085b2bf56ac |

원자료 디렉터리: `.git/order570-20261012/`.

| 증거 | SHA256 |
|---|---|
| targeted-audits-initial.json (원26/실패 보존) | e8d46c91d91d5d0d40bb9cbf51f05df49e385e7446c0fdfacd5cb9baec02a8d3 |
| source-census-final.json (최종 actual collect) | 292c6c308fc5811a5172bc2ec8093e6b0f26db0e995987bac707c2837ccf10d8 |
| full-self-test-final.json (271/부분 stdout) | 0f32e9dcc62fa4420502163fe4755c7406b8314efdbd09788b7cbcf23b1a37f2 |
| ending-coda-positive-final.json (최종 positive1) | 41e963f6d0ebe44f48925abbd8d5b50865f420a44a1f3cc0da197f7bb7d4d69c |
| casino-retry.json (fresh actual0) | f4444f6342b941b5db1f3d069a3ace1eb74b1913d4bfecce99a28baed64f15e4 |
| casino-retry.stdout.zlib.b64 (lossless stdout) | 380f07af139df2c6f077edb6c65c9ba91124043dc392a7080cb37c2fc21601ba |
| preservation-final.json (비소유 exact) | 56482269080142c5adbf8bff752ecb00fcfff9d289f190b396384d52ad900f94 |
| source-review.md (최초 독립 source GO) | e2e13f45ecd0551defd2e8110ebc49219a5a4a9a96c4fa82d19f8d6b02860b61 |
| source-review-final.md (최종 source/실행 증거 보완 GO) | 7a640e7e70219e2d74fe0f5945d94870cc2440d645d568d13c11c1c6c20a0cd9 |

root가 최종 독립 보완 보고66줄/10012B를 전량 읽었다. source provider/회귀/원자료 한정 GO·blocker0이며 최종 metadata/commit/CI·번역/실제관찰 GO는 포함하지 않는다. root 마감 context/queue/diff actual0: boot30220/docs684, active78/in_progress76/max_batches2다.

승격: `I18N_INFRASTRUCTURE.md:Full-game ending aftermath cards`의 지속 provider/감사 경계만. 이8 모집단·소유·수용 전 준비·검증/일회성 실행순서는 archive 이력이며 새 release 규범이 아니다.

강남드림 개발 스킬의 원문/데모/저장 보존과 source/실관찰 경계를 적용했다. M17/562 하나·OS잠금 HOLD/native0·새 월0, CJK8×3 실제 번역 미수용·전체 INCOMPLETE·원어민/렌더/인간/물리패드 OPEN·본편/출시 HOLD다. 선행569 CI38218711500/ad3ed3e는08:54:19Z에도 in_progress/null이며 이번 push의 CI와 별개다. 자동 게이트는 계약 증거이지 재미·문체·실제 화면 또는 출시 GO가 아니다.

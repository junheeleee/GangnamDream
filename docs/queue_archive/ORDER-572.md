# ORDER-572 — 월말·마지막 기록 간체·번체 직접 번역

#### [x] ORDER-572 [P0·전체 현지화] 완료 — 2026-10-12

사용자 전체 번역 위임/ORDER-157의 후속이다. 기준7a6cbc72/tree b43a3012의
아래 표시용8키×CN/TW=16 target만 채운다. 선행571 CI는 미확정이며
M17/562 OS잠금 HOLD 하나·새 월0을 유지한다.

## 깊이 3문·exact 모집단

1. 없으면 준비 중국어의 월말 변화·최종 기록/legacy 종료 안내가 EN fallback이다.
   기존 `_tr`→LocaleManager.ui→label/카드/버튼 소비자로 번역할 수 있다.
2. 선택·24주/5년 상태는 바꾸지 않는다. UI8의 부호/의미·6개월·시점·강도와
   미명명/부분 회복을 보존한다. 완료·건강 회복·후속 플레이 가능성을 발명하지 않는다.
3. 같은 기록 표면의 누락을 채우며 새 카드·행동·비교 키를 만들지 않는다.
   원문의 기존 legacy 6개월 안내를 공개 story_demo_rc 교체로 주장하지 않는다.

| KO source key | MainGame.gd 소비자 |
|---|---|
| 최종 기록 | _add_ending_mood_card / _build_time_ledger_card |
| 마지막 거처 | _add_ending_mood_card |
| 도시는 이 결말에 아직 이름을 붙이지 못했다. | _ending_card_signal_line → mood card |
| 6개월 기록 | _build_time_ledger_card의 is_demo 분기 |
| 아침에 일어날 때 몸이 지난달보다 덜 굳어 있었다. | _show_month_summary의 health 증가 분기 |
| 방 안의 작은 소리들이 다시 하나씩 들리기 시작했다. | _show_month_summary의 mental 증가 분기 |
| 데모는 여기까지입니다. 지난 6개월의 기록을 확인하고 풀버전에서 이어질 선택을 살펴보세요. | _show_month_summary의 legacy demo-limit 안내 |
| 6개월 기록 보기  › | 같은 분기의 _show_demo_ending 버튼 |

실제 source/표시 경로를 읽은 것이며 렌더/native 실행 증거는 아니다.
탐색에서 찾은 `현실`은 _ending_add_unlocks의 번역값 비교용이라 제외한다.
그 기존 코드의 언어 의존성은 별도 수리 후보, 이 오더의 runtime 변경0이다.

## 정확한 소유·병렬

- root: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각 신규8키 및
  `content/meta/full_game_localization.json` accepted16/checksum/UI batch1만.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, CN KO 직접 초안·
  공식 export/check/import와 원receipt 편입, private 원출력 보관.
- mod_layer_ci: TW KO 직접 초안만 `.git/order572-20261012/tw.draft.json`.
- manual_save_ci: 같은 private 경로의 fresh 보존 before 자료만, tracked 편집0.
- rework_batch_plan: 비저자 KO8↔target16/공식receipt·역치환·비소유 보존 최종 검수만.

원문/KO/EN/JA·runtime/선택/조건/효과/플래그·collector/검사·source manifest·
project/presets·SHIPPING_LANGUAGES·공개 demo121/원문/pin·사용자/공개 저장/설정·
Human/과거 판정·옛 raw/seed/app은 비소유다. 새 도구/검사/등록·최적화·엔진/
전체 audit/240주/새 월0이다. 기존 helper/validator/named lane만 재사용한다.

## 수용·완료

- 선언 commit/push 뒤 exact8 source-bound export/locale, protected=false/
  이전값null을 확인하고 두 언어를 KO에서 독립 작성한다. 중역/간번 변환0.
- 비저자16 전수 대조 후 공식 check/import --accept. 원공식receipt header/digest를
  portable batch에 보존하며 기존 accepted/batch prefix/사전값·순서 불변이다.
- 기존 4파일 append inverse와 실제 선언 Git source manifest, named
  full-game-localization-overlays preview/실행, context/queue/diff를 확인한다.
  verifier를 바꾸지 않아 그 self-test나 옛 전체 suite를 반복하지 않는다.
- 새 실패0·독립 source/영수증 GO·비소유 byte 보존 뒤 마감한다. 실제 렌더/
  원어민/인간/물리패드 OPEN·전체 번역 INCOMPLETE·본편/출시 HOLD는 그대로다.
- 기존 I18N 정본/강남드림 개발 스킬을 적용한다. 이 모집단·소유·순서와 검증은
  일회성, 새 규범/승격0이며 자동 검사는 재미·문체·인간 또는 출시 GO가 아니다.

## 마감 실측 — source·영수증 한정, 화면·출시 GO 아님

- 선언71400a662b1ff0332107650640c851642a4befd5/tree ed2bdf5a1d7b873125e88b17f3b02fd7c7e7129d를 먼저 commit/push했다. 아래 제품 핀으로 검증 후보를 결속했으며 구현 commit/tree·first-parent 증명은 commit 뒤 private postcommit에 실제 관측한다.
- root CN·mod_layer_ci TW가 KO8에서 각각 직접 저작했다. root는 소비자 열람에서 인접 EN을 봤으며 TW 저자는 KO만 참조했다고 진술한다. 중역/간번 변환0이고 저작 경로의 독립 증명이나 EN 노출0을 주장하지 않는다. 비저자가 KO8↔최종응답16을 전수 읽어 의미 결함0으로 preimport GO했다.
- 공식 export/check/import는 각8×2 actual0. 최초 CN check는 --locale 누락으로 CLI mismatch actual1이었고 원실패를 보존한 뒤 올바른 locale로 actual0이다. 제품·checker 수리나 번역FAIL로 바꾸어 적지 않는다. 공식receipt2의 원header/semantic digest를 portable UI batch1에 그대로 편입했다.
- 사전 각8/accepted16만 추가, JA13169 불변·CN/TW14712→14720·batch315→316/checksum6573b1363685d1b07b05fc24f08625dd419a9585cc082d06afafaeed584133cb다. 기존 사전/원장 4파일 exact inverse actual0·실제 선언 Git source manifest8231e096a45b716f8c6ee30d82641eac77900a213afced2173334b888200e452 불변이다.

| 최종 제품 파일 | bytes | SHA256 |
|---|---:|---|
| locale/ui_ja.json | 303367 | 1531f2decbdce74f418543044d1f6879317267d92a14fcd63da83793d9564fa5 |
| locale/ui_zh-CN.json | 191548 | 92a4bc0e3d48e3e2a37c90a0c636339860c03dd28ac4817aa33f69ff91bedaf4 |
| locale/ui_zh-TW.json | 192098 | 499a88ad4de3cfa5e5f3f21c66d481a66e2d78a4c580302cacd458a13747a2ae |
| content/meta/full_game_localization.json | 11696502 | b0cc3ee2f6d59dd1448ea5d5d8fe467cf3bdb3e7c6d8cd6f0b5ab117eedd57d3 |

승격0: 이8키·소유·수용 순서와 검증은 일회성이다. 기존 I18N/강남드림 개발 스킬의 KO 직접 저작·원문/저장/데모 보존·자동/실관찰 구분을 적용했으며 새 규범·도구·검사/등록·최적화0이다.
부분 회복·미명명·6개월·버튼 공백2+›를 보존했고 legacy 안내는 공개 story_demo_rc 갱신이 아니다. 비교 전용 현실 키는 제외했다. 원문/KO/EN/JA/runtime/선택/효과/플래그·project/presets·저장/설정·Human·옛 raw/seed/app 수정0, 엔진/새 월0·M17 OS잠금 HOLD 하나·렌더/원어민/인간/물리패드 OPEN·전체 번역 INCOMPLETE·본편/출시 HOLD다.

- named full-game-localization-overlays를 preview 후 실행해11통과/outer exit0, full self-test271/75.466s OK다. 전체 audit/240주/엔진/실제 앱 검사가 아니며 wrapper결과 한정이다. 기존 EXTRA advisory2를 유지하고 개별 검사별 lossless raw 신규 확보를 주장하지 않는다.
- 독립 source/receipt/preservation GO·blocker0. 10:01:52Z의 선언HEAD/tree stable/dirty3에서 보호50그룹853항목·비소유3355 blob/mode·봉인571 raw34·JA exact다. root가 최종 source-review 전문9571B를 읽었다. 독립 관측 이후 root 마감 metadata·commit/CI는 별도 확인한다.

원자료: `.git/order572-20261012/`. 실제 도구 반환·독립 관측을 보존한 파일이며 성공 출력을 재구성하지 않았다.

| 증거 | SHA256 |
|---|---|
| export-results.json | d46119572545f71399474103d894c2fb941199e93735e27fa2c26019880b1c56 |
| cn.check-invocation-fail.json | 9751281d91c04d0186be4aa38314c1a8dbe3fbe67b98d03aa3dc0134beb0df30 |
| checks-final.json | dbdcd1ccd0f695cf5ea5efc6a27cb209e30ff7c0f56034f347ec34150cff482f |
| import-results.json | 126b09cf9511f561dd0ec1e2797f54f3692a9c03b3428432a5cd1a5ec2f66469 |
| official-receipts.json | e5a3629779cd39f1d6f7301bb5c1a4ecf2d36c62142399f43836b9651d210269 |
| append-proof.json | c3d33142d7e68bede264d697e907077fd2e639ed685dbd9bd2daa9ba6f3e42a0 |
| lane-result.json | b5cebd97822b8dc13b165ddaf0799fd13a54c9643e09b3cafe9e6bcdbe3543fb |
| preservation-before.json | ea507b55cf01ed6694cb378f674f57dbff9899d007e8f644af930e2df5a17b94 |
| preservation-final.json | 6228122900a3ec8d7d27f3b1e4d53ab1affebebd14af0aa923d45bf1f5f27e88 |
| source-review.md | b1f6b1f344d31a8d305dad09b18b17ef750f130def8a4f4a72f9236ba8312f80 |

선행571 CI38231573505는09:52:52Z에 exact7a6cbc72/tree b43a3012에서 in_progress/null이었다. 이번 구현 push CI와 별개이며 완료·녹색을 추정하지 않는다. 마감 metadata/context/queue/diff 확인 뒤 main에 commit/push하고 실제 first-parent 및 새 CI 관측은 private postcommit에 남긴다. 현황판 단독 후속 커밋0이다.

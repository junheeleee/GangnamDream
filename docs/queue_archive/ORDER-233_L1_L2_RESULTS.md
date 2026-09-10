# ORDER-233 — 갤러리 UI27키 번역 증거

상태: 수용·회귀 완료, 정확 C2 work_unit233 한정 내부 GO.
텍스트 내부 검수이며 실제 화면·회상 동작·원어민 관찰은 없다. 본편 HOLD다.

## 신원·범위

- 선언 기준84b611f668eb3bb84db0f7671da611e47e607297.
- 선언77759f4, initial6d00bab59b710c046760bb5f3b587aef8c5d272a.
- 본문 C1 `ff65c625ed4fce360894e49ef6a86aae7ac97b4f` / tree `ecac07d3f01bc52c4756538d4dfbef2caab808d1`.
- 갤러리20판정단위·27원문×3=81 수용. 기존JA27 검수와 CN/TW 직접 신규54를 구분한다.
- 누적38014→38095(JA12697/CN·TW12699)/b92→93/meta9 불변.
  언어별 사건11578/1694root·엔딩234·catalog834 불변, UI51/53/53.
  비보호 shipping 사건 텍스트 결손0은 전체 UI·실제 도달·표시 완료가 아니다.
- 코드4/KR·EN/런타임/저장/폰트/project/공개 UI121/인간 원장/보호1901파일 변경0.
  선택 밖 JA2874키·CN/TW 기존148키와 JA5행의 탭 들여쓰기까지 raw 역복원 exact.

## 직접 저작·교차 검수

Plato→JA 저작 검수 / Rawls→CN 직접 저작 / Poincare→TW 직접 저작.
비저자는 Rawls→JA, Poincare→CN, Plato→TW의27문구 전량 KO/현재값/용례를 대조했다.
ROOT도 최종81개 값을 원문과 대조했다. 자동 L1은 언어 품질 판단을 대신하지 않는다.

- ja: 3개 값 변경,27개 대조·수용.
- zh-CN: 27개 값 변경,27개 대조·수용.
- zh-TW: 27개 값 변경,27개 대조·수용.
- 일본어 名物麺(면요리)→名場面으로 명장면 탭 오역을 닫았다.
- 아직 발견한 비밀이 없는 빈 상태를 ‘미발견 기록이 없다’로 뒤집지 않도록 고쳤다.
- 기존 일본어 재열람 문장의 기계적인 표현을 정밀화했다. 과거 장면 보존과 현재 불변만 뜻한다.
- TW 최초 L1은27개 중4개에서 지역 자형 秘를 지적했다. 동일 단어의 대만 표기 祕密로
  4자만 정밀화하고 같은27개를 재검사했다. 의미·printf 변화나 검사기 면제는 없다.
  [대만 교육부 간편사전의 祕密](https://dict.concised.moe.edu.tw/dictView.jsp?ID=4471&la=0&powerMode=0)을
  대조했으며 원어민 실독해를 대신하지 않는다.
- context3은 owner/path로 현재값에 결속했다. 두 ‘기록’과 페이지 ‘이전’ 문맥을 구분한다.
- printf %d5개/%02d2개 순서·패딩, 잠금/해금 방향과 스포일러 경계를 유지했다.
- StartMenu604/968 navigation,974 열람,991–1038 탭/힌트/페이지,
  1173/1182/1188 진행,1235/1255 잠김CG,1288/1331/1332 회상안내,
  1367/1389 비밀,1408–1414 CG제목,1462–1467 분류를 직접 읽었다.
  _replay_archive_scene는 replay mode를 설정하지만 실제 실행 검증을 했다는 뜻은 아니다.
- 동적 DataRegistry 제목/업적·이미지·controller글리프와 닫기/돌아가기 보호값은 비소유다.

## 교환·원형·회귀

initial27×3의 기존JA27/previous-null54와 새값을 구분했다. 쉼표 포함 원문은
공식 --leaf-ids JSON으로 정확 선택했다. final C1의 source/current/비저자 proof·records·
언어집합3/수량81 결속을 response 생성 전에 검증했다. 공식 check/import6회는
각 locale 명시·changed_files0/full_status INCOMPLETE/human_gate OPEN이다.
새81/batch1을 역제거하면 기존38014/b92/meta9 portable raw가 exact다.

- 전체수용 L1:1회,38095/오류0,71.327초,입력746 전후 exact.
- 명시 차선12(고유11명령):1회 PASS,67.053초,입력751 전후 exact.
- 첫 언어별 L1 각27/1회 결과와 교차 검수는 아래 원형에 결속한다.
- 명시 회귀 self250/8.470초·source52·JA88·ZH12407, 공개5언어UI121 패리티,
  감사ERROR0/WARNING0·context/queue PASS. 동일 audit.py가 기존 등록상2회 호출된다.
- Godot/full/240주·실제 렌더·원어민 재실행0. 기존 ZH font readiness blocked는 미해제다.
- 결과 기록은 사후 문서 변경으로 분리하고, QA의 모든 코드/원문/target 입력은 C2에서 재결속한다.
- 최초 선언 준비에서 queue 번호 치환을 적용 전후 확인해 수정했다. 존재하지 않는 경로조회와
  dashboard --check의 --md 누락은 실제 제품 검사 실패가 아니며 올바른 경로/인자로 완료했다.
  번역 검사 기대 완화·제품 코드 변경은 없다.
- 독립 receipt helper의 첫 실행은 UI source_path인 runtime:static_ui를 파일로 취급해
  중단됐다. sentinel 계약 조회만 고쳐 같은81 결속을 확인했다. 첫 traceback 원형을
  보존했고 collector/L1/QA/공식 교환은 추가 실행하지 않았다.

## 확정한27문구

| key / KO | JA | zh-CN | zh-TW |
|---|---|---|---|
| ui.navigation.archive / 기록 | アーカイブ | 记录 | 紀錄 |
| 지나온 장면은 남지만, 다시 보는 선택은 현재를 바꾸지 않습니다. | これまでの場面は残りますが、見返すときの選択で現在が変わることはありません。 | 经历过的场景会留存，但回看时的选择不会改变现在。 | 過往的場景會留下，但回顧時做出的選擇不會改變現在。 |
| CG | CG | CG | CG |
| 명장면 | 名場面 | 名场面 | 精彩場景 |
| 비밀 기록 | シークレット記録 | 秘密记录 | 祕密紀錄 |
| 탭 이동 | タブ移動 | 切换标签页 | 切換分頁 |
| 페이지 | ページ | 翻页 | 頁面 |
| ui.archive.previous_page / 이전 | 前へ | 上一页 | 上一頁 |
| 다음 | 次へ | 下一页 | 下一頁 |
| CG  %d / %d | CG  %d / %d | CG  %d / %d | CG  %d / %d |
| 회상  %d / %d | 回想  %d / %d | 回忆  %d / %d | 回想  %d / %d |
| 발견된 비밀  %d | 発見したシークレット  %d | 已发现的秘密  %d | 已發現的祕密  %d |
| 아직 보지 못한 장면 | まだ見ていないシーン | 尚未看过的场景 | 尚未看過的場景 |
| 미해금 | 未解放 | 未解锁 | 未解鎖 |
| ui.archive.record_fallback / 기록 | 記録 | 记录 | 紀錄 |
| 열람 전용 · 선택은 현재 기록을 바꾸지 않음 | 閲覧専用 · 選択は現在の記録を変更しない | 仅供回看 · 选择不会改变当前记录 | 僅供回顧 · 選擇不會改變目前紀錄 |
| 이 장면을 본 뒤 열립니다. | このシーンを見た後に解放されます。 | 看过此场景后解锁。 | 看過這個場景後即可解鎖。 |
| 비밀 기록 %02d | シークレット記録 %02d | 秘密记录 %02d | 祕密紀錄 %02d |
| 아직 드러난 비밀 기록이 없습니다. | シークレット記録はまだ見つかっていません。 | 尚未发现任何秘密记录。 | 目前還沒有發現任何祕密紀錄。 |
| 엔딩 기록 | エンディング記録 | 结局记录 | 結局紀錄 |
| 장면 기록 | シーン記録 | 场景记录 | 場景紀錄 |
| 시작의 기록 | 開始の記録 | 起点的记录 | 開始的紀錄 |
| 장면 기록 %02d | シーン記録 %02d | 场景记录 %02d | 場景紀錄 %02d |
| 계절의 기록 | 季節の記録 | 季节的记录 | 季節的紀錄 |
| 첫 키스 | 最初のキス | 初吻 | 初吻 |
| 그 밤 | あの夜 | 那一夜 | 那一夜 |
| 특별한 이야기 | 特別な物語 | 特别的故事 | 特別的故事 |

## 증거 지문

원문/실행/대조 자료는 .git/full-game-localization 아래 SHA에 결속한다.
제품의 최종 번역은 위 표와 UI 파일이다.

| 파일 | bytes | SHA256 |
|---|---:|---|
| order233-predeclare-inputs.json | 4495 | 4ed42b2e6ae8a6049687754101fdb151cb3ff1b33186071c134e66b6364bb5f1 |
| order233-leaf-ids.json | 1426 | 90b401a5dcd507b61dac573f2753913e01b8880788ac97e54c1a09c1df19ec7e |
| order233-initial-export-proof.json | 2017 | a45342eff7c37551f4af06a11ea1ae056006e082809a901a771937bebd5e0103 |
| order233-initial-seal.json | 486538 | fc6d9b0ce33e4d2e9ba33d98a2272a80c893f45a3b2d618f2c2d6c8fabc00ab4 |
| order233-ja-author.json | 33008 | 93e6ff8fa8715de2769170ec5070f665e83fd13bc8c8c5346a29f274c3df89cd |
| order233-cn-author.json | 19042 | 7907c03141cae15fc732c7f4df6d111237dfa8dcf9f4930456efb9f2020c1193 |
| order233-tw-author.json | 24212 | 8f234bb4c285ffbc194f57626bbf73d7c4b04eaf9ce9c9a633e8892740e7bb32 |
| order233-ja-first-l1.json | 26980 | 05427eae4307fc9d2ae5efa0cb10431dec55d72633db9d70b9126e6ee705bcb7 |
| order233-cn-first-l1.json | 19636 | 1412c36655ded219c42fb4e9b9354084b0957ede22fb0e6256d7040db07d21ef |
| order233-tw-first-l1.json | 18058 | 8b4739cb8023b2086d4f276830ac8fef5ae3903b71ff9380d16078f315d84dfe |
| order233-tw-author-final.json | 25186 | 738ed56c53c62e75fdae78763a1b7a845129b7a111bc95afda16fd38421b06e6 |
| order233-tw-author-orthography-closure.json | 19393 | 4657b338ed2d7f051f981929ed28fe68aae59bccb117cecc0f5710e18066eeca |
| order233-root-semantic-review.json | 1499 | 4006d960cea6edf5088039b1ab7c6127bfe97e097441ee8645b04a47b0d5e7f5 |
| order233-ja-independent-l2.json | 23787 | f9e99e38fb5de88ad09ce2bdf87ec5eb4f0014d50488d44f1fd1169ca29085e0 |
| order233-cn-independent-l2.json | 21431 | 7193f4fa381f2e3152edee66b5edd7298350063c779898f41dee129bec69faf1 |
| order233-tw-independent-l2.json | 27933 | 50797ddd965117d8fe4d457ad6b24cca7df5fda85b79660b918367ad37a357e7 |
| order233-final-body-preacceptance.json | 30301 | d203085a7b768d4b602a5802cfcaa181064e086fac1e6bf80e23fa515dfc999a |
| order233-independent-preacceptance.json | 1421 | 747c7f0ee93b3e8475746bee9877c2a60ba329e60b865e83d49de6ced3b37b16 |
| order233-independent-helper-static.json | 7482 | 0f2c2a723d73e8152bef2a1e1b7809ae63f6e3dfd4389b35c4b63cd3e10d80fb |
| order233-final-source-response.json | 1690 | c55217621c11f001ef77eda66d8eba56e6a2d11e9ab341b74e92d2f0ed9de4ff |
| order233-official-export-final.json | 2008 | 64a8d5646831d20f48597b9837c431ffebb508e23ba340238b613cb6b7ba5b25 |
| order233-official-check-final.json | 1767 | c54ab2411c27b3113343c4c7eeedca8d585f0cb901532dd7a183d409dd4961dd |
| order233-official-import-final.json | 1834 | d46cff6760ec9837ffdad31c34a8b20a719184af320503a9ff05d434dad96077 |
| order233-portable-acceptance.json | 1208 | 58dbf7dd5e3bd3a76b8543ebd7ea1edab0c40c4f17f7e6ed037810f51e93890e |
| order233-independent-receipts-first-helper-error.json | 706 | 264656215d948b7af91a67ef2a67a6c4317c0ded25f83e5f111c131e4a03e923 |
| order233-independent-receipts.json | 22157 | b4d3e2efc11d88c2927ce7cbfb95475498fcd9520e9bc33a5bb3a3067a4b89c3 |
| order233-all-accepted-l1-final.json | 86068 | af4c0587f4de0ca8bf4ca1de31cefc0c531cedb10a7c626c3a30def6dafa76f3 |
| order233-named-qa-final.json | 174592 | 750803c916820e1d1e9d476c161df63c6789fb72a74b5fba7c04cc293be99bfb |

## 다음·판정 경계

공개 데모 GO·인간45OPEN 원형·본편 HOLD 유지. 남은 UI/표시 소비자/보호·author-only/
실제 화면·원어민·정상속도 본편 검수는 계속한다. 이번 텍스트 수용은 전체게임 GO가 아니다.
승격: 지속 규칙은 기존 I18N_INFRASTRUCTURE/WORK_UNIT 정본. 이번 키/소유/마감은 일회성.

## 최종 독립 판정

Poincare의 ORDER-233 한정 GO/필수0. source `10cc6800e6e034d91225f83fcc765a9fc725ed0e` / tree `cf7769879f79e872c6655f0f95ba9bad087f91cb`.
JA는 Rawls, CN은 Poincare, TW는 Plato의 전량 KO 대조에 결속했다.
통합 검수자의 TW 자가 승인을 만들지 않았다. 원어민/인간 실플레이 관찰은 발급하지 않는다.
최종 검수 `.git/full-game-localization/order233-poincare-c2-final.json` / SHA `f043adb02705dc956ce50e179c9e6fb8118c3d024be259ea287b2e6c6b28f517`.
QA→C2 입력결속 order233-qa-source-binding.json /
SHA `62214798667cc11f845e65ffaf95adae1c4a96628d82e5eef057eb9999884d38`.
기존 WORK36125B/EOF2와 기존 판정19건은 신규항목을 역제거하면 raw exact다.
이후 큐·WORK·판정·보고·STATUS metadata wrapper만 위 source에 연결한다.
본편 HOLD·native/render OPEN. 새 번역 수용81은 게임 완성률/제품 GO가 아니다.

## 선언 사양 원형

아래 착수·예측 문구는 당시 원형이며 실제 결과는 위 기록이 소유한다.

# Active Queue Spec: ORDER-233

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-233 [전체 현지화] 갤러리20단위·UI27키 번역

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. clean main84b611f668eb3bb84db0f7671da611e47e607297 /
tree e63c8a5eee68d83387e52ae012878e155b269984 기준이다. 이전 ORDER-232의72 수용·
독립 GO를 새81의 검수에 합산하지 않는다.

## 깊이 3문·판정 대상

1. 없으면 무엇이 빠지는가? 시작 메뉴 갤러리의 CG/명장면/비밀 기록과 열람·해금 안내다.
2. 바뀌는 미래 상태는? 텍스트만 바뀐다. 실제 회상·해금·저장 정책은 바꾸지 않는다.
3. 무엇과 경쟁하는가? 다시 보는 기록의 식별과 현재 진행을 바꾸지 않는다는 경계를 명료하게 한다.

ROOT는27 KO/EN/기존JA와 StartMenu955–1485 소비자를 직접 읽었다.
사전조사26311B/SHA4d0b7b9a18ad74cd94a4073bedc223d958940e8bbf04019faa26b24b670ca2c9,
현재 재결속4495B/SHA4ed42b2e6ae8a6049687754101fdb151cb3ff1b33186071c134e66b6364bb5f1.
source records SHA049fed8643a58dcea79a9207f9329002c3f522a8d1b11e0103a6cf0cdcc2a37d.
context ID3·템플릿5/printf7·LF0/name0, 보호0/기수용0이다. JA기존27과 CN/TW누락각27.

## 정확한20판정 단위·27키

1. 탐색 제목: ui.navigation.archive
2. 재열람 안내: 지나온 장면은 남지만, 다시 보는 선택은 현재를 바꾸지 않습니다.
3. CG 탭: CG
4. 회상 탭: 명장면
5. 비밀 탭: 비밀 기록
6. 이동 힌트: 탭 이동 / 페이지
7. 페이지 버튼: ui.archive.previous_page / 다음
8. 수집 진행: CG  %d / %d ; 회상  %d / %d ; 발견된 비밀  %d
9. 잠긴 CG: 아직 보지 못한 장면 / 미해금
10. 기록 제목 fallback: ui.archive.record_fallback
11. 회상 안내: 열람 전용 · 선택은 현재 기록을 바꾸지 않음 / 이 장면을 본 뒤 열립니다.
12. 비밀 일련번호: 비밀 기록 %02d
13. 비밀 빈 상태: 아직 드러난 비밀 기록이 없습니다.
14. 엔딩 fallback: 엔딩 기록
15. 장면 fallback: 장면 기록 / 장면 기록 %02d
16. 시작 CG: 시작의 기록
17. 계절 분류: 계절의 기록
18. 첫 키스 분류: 첫 키스
19. 밤 분류: 그 밤
20. 특별 분류: 특별한 이야기

27 exact leaf IDs는 .git/full-game-localization/order233-leaf-ids.json,
1426B/SHA90b401a5dcd507b61dac573f2753913e01b8880788ac97e54c1a09c1df19ec7e.
쉼표 포함 원문이 있으므로 공식 export는 --group ui --leaf-ids <JSON> --limit27을 쓴다.
context3은 KO source가 아니라 owner/path로 현재 번역값을 결속한다.

## 파일 소유·분담

- Plato: locale/ui_ja.json 위27 기존값 KO 직접 검수·필요 정밀화.
- Rawls: locale/ui_zh-CN.json 신규27 직접 저작.
- Poincare: locale/ui_zh-TW.json 신규27 직접 저작. 간체 변환이 아니다.
- 비저자 전량81: Rawls→JA / Poincare→CN / Plato→TW. ROOT 통합.
- ROOT: content/meta/full_game_localization.json에 검수81/batch1만 추가.
  기존38014/b92/meta9 및 선택 밖 모든 UI key/value/order/raw를 역제거 보존한다.
- 조건부 코드4: tools/full_game_localization.py, tools/full_game_localization_self_test.py,
  tools/ja_translation_pipeline.py, tools/zh_translation_audit.py. 첫27 L1의 실제 오탐만
  actual/다른 정상/유효 변조/source-OFF와 비저자 증거를 먼저 봉인해 국소 수리한다.
  전역 완화·전체 leaf 면제·기대 변경0.
- 운영: CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md,
  docs/WORK_LOG.md, docs/STATUS.md, docs/queue_backlog/FULL_GAME_LOCALIZATION.md,
  이 사양, docs/queue_archive/ORDER-233_L1_L2_RESULTS.md, tools/audit_scope.json,
  docs/agent_review_decisions.json, docs/agent_reviews/ORDER-233.json.
  사적 helper/원문/receipt/검수/QA는 .git/full-game-localization/order233-*.
- 감사는 기존 명시 full-game-localization-overlays 차선 owned_paths에 사양/보고만 추가한다.
  기존 UI3 소유 등록을 재사용하며 자동 paths/Godot 선택 규칙을 넓히지 않는다.

KO/EN/source manifests·gameplay·StartMenu·LocaleManager·SaveManager·저장/설정/커스텀 이름·
폰트·SHIPPING_LANGUAGES·project.godot·공개 데모·인간 원장은 비소유다.
같은 화면 닫기/돌아가기·보호UI121·직전 저장UI72를 포함해 선택 밖은 보존한다.

## 의미·검수 경계

- 명장면의 기존 일본어 名物麺은 음식 오역이다. 비밀 빈 상태는 미발견이 없다는 뜻이 아니라
  아직 발견한 기록이 없다는 뜻이다. 두 결함을 수리하며 나머지25도 실제 KO와 대조한다.
- ui.navigation.archive=기록(갤러리), ui.archive.record_fallback=기록(제목 fallback),
  ui.archive.previous_page=이전은 다른 문맥이다. ID/호출/원문/해금 조건을 바꾸지 않는다.
- %d 다섯 개·%02d 두 개의 개수/순서/제로 패딩을 보존한다. 원문 CG는 그대로 가능하다.
- 잠긴 제목·미발견/해금 안내는 스포일러나 완료 사실을 새로 만들지 않는다.
  다시 보는 선택이 현재 기록을 바꾸지 않는다는 문장은 열람 안내의 번역이지 실행 증명이 아니다.
- 동적 DataRegistry 제목/업적·이미지·controller 글리프·회상 handler는 번역 범위 밖이다.
  실제 플레이·저장·삭제·해금·회상 실행0. UI 배치·component·해상도·원어민은 미관찰.
- 공개 GO/인간45OPEN·본편 HOLD 유지. 포착 UI3556+미확정329는 최종 전체 UI 분모가 아니다.

## 검증·마감

1. 선언 커밋·동기화 뒤 공식 initial27×3, 기존JA27/null54와 원형 입력 봉인.
2. 세 언어 직접 저작·첫 L1 각1회(실패 원형 보존)·비저자81 전량 대조.
3. context-aware source/현재값/비저자 records digest 결속을 final response 생성 전에 검증한다.
4. clean C1 official final export/check/import3쌍, 각 locale 명시·changed_files0.
   81 수용 후 기존38014/b92/meta9 raw 역복원, 보호 입력 원형을 확인한다.
5. 전체수용 hash/L1 1회·명시12 차선1회를 전후 입력 봉인. 실패면 실제 원형과 영향 재실행을
   기록한다. context/queue/diff 검사, Godot/full/240 실행0. 자동 통과는 재미·문체 GO가 아니다.
6. source-like 문서까지 exact C2에 묶고 비저자 work_unit233 판정 뒤 metadata wrapper만 추가.
   WORK 기존36125B·EOF2 원형을 실제 적용 후 확인하며 이력 이동0.
   STATUS clean 생성·검사, main/번역 브랜치 비파괴 동기화.

성공 때만38095(JA12697/CN·TW12699)/b93/meta9. 81=JA기존27검수+CN/TW신규54이며
81을 모두 신규 저작이라 하지 않는다. 기존 I18N/WORK_UNIT 정본 유지, 이번 키/소유/마감은 일회성.

# ORDER-566 — 일본어 경마 주행 방식 두 용어 교정

#### [x] ORDER-566 [P0·현지화 정합] source 교정 완료 — 2026-10-12

최신 사용자 `이어서 진행해`와 전체 현지화 위임 아래, 잠금 중 읽기전용 조사에서
확인한 일본어 경마 두 기존값만 고친다. 월별 실제 플레이를 추가하지 않는다.
선행62f44021 구현 CI38188149161은 아직 진행 중이며 성공으로 재사용하지 않는다.

## 깊이 3문·도달

1. `HorseWorld.style_name`의 `선행/추입`은 경마 주행 방식이다. 기존
   `善行/追加入金`은 도덕행위/추가입금으로 읽혀 출전마의 선호 정보가 잘못된다.
2. `HorseWorld.gd:71` 저장 style0/1 → `style_name:43` →
   `RaceTrack.gd:455~458` 선호 줄의 실제 `LocaleManager.ui` 소비다.
   이번 수리는 선택/경기 확률/저장/장기 결과를 바꾸지 않는다.
3. 경쟁 대상은 같은 줄의 거리·마장 정보다. 두 단어를 바로잡고 새 규칙이나
   다른 경기/언어/장면 묶음으로 넓히지 않는다.

## 정확한 소유

- root: `locale/ui_ja.json` 기존 `선행`, `추입` 값 두 개만.
  KO 직접 `先行`, `追い込み`로 교정한다. 신규 사전키0이다.
- root: `content/meta/full_game_localization.json` 새 첫 accepted2·checksum 및
  별도 `ui_correction` batch1만. 기존312 batch·모든 기존 accepted/metadata 보존.
  두 기존값에 portable accepted가 없는 사실과 export의 previous-target 해시를 남긴다.
- root: 큐2/이 사양(마감 시 archive)/WORK_LOG/CLAUDE 현재행만.
- manual_save_ci: 새 `.git/order566-20261012/` 독립 언어·영수증 검수 보고만.
- rework_batch_plan: 같은 새 디렉터리의 fresh before/final 보호 증거만.
- mod_layer_ci: 확인된 소비자·공식 수집 leaf의 읽기전용 판독만.

원문·EN/CN/TW·source/runtime/게임 규칙·project·사용자/공개 저장·설정·원seed/raw/
app·Human/과거 판정·공개 GO·retail 언어 allowlist는 비소유다. 기존565/564 봉인은
편집하지 않는다. 기존 앱에 이번 수리가 들어갔다고 주장하지 않는다.

## 공식 수용·표적 검증

- 선언 commit/push 뒤 exact2 UI leaf를 공식 export → KO 직접 응답 →
  비저자 검수 → check → import --accept --replace-existing 한다.
- 기존 원값 해시/새 target/source hash·원공식 receipt header/digest를 결속한다.
  기존값 수정이므로 append-only 검증으로 통과시키지 않고 정확2변경/나머지
  bytes·portable prefix 불변을 독립 대조한다.
- 기존 `ja_translation_audit --scope ui`, `ja_translation_audit --scope demo`,
  `ja_translation_pipeline --self-test`, `full_body_translation_scope --self-test`,
  `story_demo_localization_audit`, `en_coverage_check`, `english_hangul_audit`,
  `release_content_inventory`, context/queue/diff를 표적으로 실행한다.
  verifier가 불변이므로 새 도구/self-test/등록·전체 audit·240주·엔진·UI 실행0이다.
- JRA의 [공식 경마 용어 사전](https://www.jra.go.jp/kouza/yougo/c10180_list.html)이
  `先行/追い込み`를 脚質로 구분하는 용례를 보조 근거로 삼는다. 한국어 source의
  두 분류 자체를 일본 경마의 네 분류로 바꾸지 않는다.

## 판정·재개 경계

source/영수증 교정만 마감하며 실제 수정 화면·원어민·물리패드·청취 OPEN,
전체 번역 INCOMPLETE·본편/출시 HOLD를 유지한다. OS 잠금이면 native0/해제재요청0,
새 월0이고 기존 M17/562 한 월만 열린다. push 뒤 실제 CI를 확인하며 pending을
성공으로 쓰지 않고 현황판 단독 커밋0이다. 모든 지시는 일회성·정본승격0이다.

## 마감 실측 — 제품 source·수용 영수증 한정

- 선언7de38592a24e5b20b9d05bf30393b79fea74ce67/tree5ca90059 commit/push 뒤
  공식 exact2 export/check를 했고, fresh before44그룹710entries 봉인과
  root KO 직접 응답의 manual_save_ci 비저자 수용 뒤 import했다. check는 비저자 수용보다
  먼저였으며 actual0/3.66311825s, import actual0/3.650512625s다.
  반환 출력은 `check.actual.json`/`import.actual.json`에 보존하며 stderr 별도파일은 없다.
- JA 3055키 그대로·기존값2만 변경, 비소유3053값·CN/TW UI bytes 불변이다.
  공식 import의 비소유5행 tab 정규화는 원바이트로 되돌렸다. 정확2값 역치환의
  전체 bytes가 선언 Git blob와 같음을 비저자가 확인했다. 경기/코드/저장 변경0이다.
- 원장 ui_correction1·첫accepted JA2만 추가했다. 기존312 batch prefix·모든 기존
  accepted·기타metadata·역사 census를 보존하며 새키/번역표면 증량0이다.
  JA13161/CN14696/TW14696·batch313, accepted SHA
  `2567a9cabeed17704125bb94a4c9325b0ae847405789df8cab0b42a50657ba26`.
  공식 header4면·receipt digest8bb2644a…79fc·source/target/이전값 해시가 결속됐다.
- 표적8종 actual0: JA UI/demo(skeleton), JA pipeline76, fullbody54,
  story-demo5언어, EN/한글0, release inventory. 영향31개는 목록조회만 했다.
  비저자가 원장 검수 순서 문구 `before check/import`를 지적해 `before import`로
  고쳤고, final fullbody54 actual0/2.459505209s를 별도 보존했다. 기존 원출력 덮어쓰기0.
- 독립 source 보고117행/9110B, SHA
  `282fd6f54c0c3cd5fc79fca9a16de90465d30c0013be9447e620b1d225d60243`.
  root가 전량 읽었으며 exact2/312prefix/oldaccepted/metadata/receipt PASS·blocker0이다.
  UI 최종SHAf9bc5473…ae559·원장b20f44a4…20a25와 결속했다.
- 최초 WORK_LOG41286B contextFAIL은 새 entry만8줄/39717B로 압축해 풀었다.
  과거본문·예산·검사기·history 변경0, raw는 `context-budget.actual.json`에 보존한다.
  queue index selftest25/4 PASS, 최종 context/queue/diff는 마감 뒤 확인한다.
- 원자료와 두 독립 보고는 `.git/order566-20261012/`에 있다. 사용자/공개 저장·설정·
  project·Human·seed/raw/app·앞565 봉인 불변이다. gangnamdream-dev에 따라
  source 판독/자동검사는 실제화면·원어민·물리패드·청취/재미·깊이 판정이 아니다.
  원어민/화면 OPEN·전체 INCOMPLETE·본편/출시 HOLD·기존앱 미반영을 유지한다.
  선행565 CI38188149161은 정적job 성공/전체job 진행 중이지 녹색이 아니다.
  새 월/엔진/전체audit/240주/새영구검사/비용최적화/STATUS 단독후속0이다.
  새 규범0·일회성으로 닫으며 M17/562 한 월만 열린다.
- 독립 보존 final `.git/order566-20261012/independent-preservation-final.json` 26057B/SHA `04acd5c31e03a7fd86d03400ce1449731e9e6ad49443f547c8fbdffded2b203b`, root 전량 판독·35/35 PASS·비소유3349/보호44·710 exact·source 한정GO다.

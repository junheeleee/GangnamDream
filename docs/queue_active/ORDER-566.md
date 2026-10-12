# ORDER-566 — 일본어 경마 주행 방식 두 용어 교정

#### [~] ORDER-566 [P0·현지화 정합] 착수 — 2026-10-12

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

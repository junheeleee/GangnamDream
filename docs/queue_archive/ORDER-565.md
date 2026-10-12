# ORDER-565 — 1년 반 회고의 고용 상태 문장 수리

#### [x] ORDER-565 source·번역 수리 완료 — 2026-10-12

562의 읽기전용 후속에서 확인한 `story_one_half_year`만 수리한다.
현재 MainGame `_next_milestone_id`는 경과18개월/미독으로 직접 진입하며
고용 조건이 없다. 다섯 언어의 통근·이직·현재 직장 전제는 무직과 충돌한다.
564 마감 main c6ed0b807bec79c5e373ccbdf4e79bf4f84cbd90/tree36f9ebed8c04895a046089bc08087b68dfa1d67c,
CI38170779752 jobs114562747582·114562747705 전steps 성공을 직접 확인했다.
맥 잠금으로 native/새 월 입력0, M17은 기존562 HOLD로 남긴다.

## 깊이 3문·경계

1. 수리를 빼면 무직도 읽는 장면/선택/결과가 현재 직장을 발명한다.
2. 기존 효과·flags·선택 순서·seen·저장/24주 상태는 바꾸지 않는다.
   이것은 새 결정/직업 feature가 아니라 기존 선택의 사실 정합 수리다.
3. 새 일자리를 알아보기/익숙한 생활 유지/생각 미루기라는 기존 대비를
   고용 중립적으로 유지한다. 새 취업 성공·수입·미래 결과를 약속하지 않는다.

## 소유·만지는 파일

- root: `content/events/story_events.json`, `content/events_en/story_events.json`의
  해당event `description`, `choices/0/text`, `choices/0/result_text`,
  `choices/1/text`, `choices/1/result_text`만. 큐2/이 사양/마감 archive·WORK_LOG·
  CLAUDE 현재행 및 필요시 `content/meta/release_content_inventory.json`의
  current-source 지문/`docs/CONTENT_RATING_INVENTORY.md` 생성영역만 소유한다.
- manual_save_ci: `content/events_ja/story_events.json`,
  `content/events_zh-CN/story_events.json`, `content/events_zh-TW/story_events.json`의
  같은5잎만 한국어에서 각각 번역한다. `content/meta/full_game_localization.json`의
  해당15잎 source-bound 교정·새 batch/receipt만 소유한다. 기존 batch/receipt 보존.
- mod_layer_ci: 원문·5언어·실제diff/공식영수증·검사출력 독립 전수판독만.
- rework_batch_plan: 새 private `.git/order565-20261012/`의 fresh 보존/독립판독만.

선언commit/push 후 구현한다. 공식 export/check/import `--replace-existing`로
변경잎만 처리하고, 임시 exchange는 private에 둔다. title/choice2와 다른event,
게임플레이 key·코드·효과·조건·flags·라우팅·장소/자산·오디오·저장 schema 불변.
project.godot·사용자/공개 저장과 설정·Human·원seed/raw/app·M01~M06 원문 불변.
새selector·분기·직업/투자 기능·영구tool/checker·KNOWN 확대0이다.

## 표적 검증·완료

- 실제 구조diff: 5잎×5언어만, title/choice2/게임플레이/다른event 동일.
- 공식15잎 export/check/import·accepted source/target hash와 이전receipt 보존.
- en_coverage·english_hangul·narrative_continuity·scene_audio_contract_check·
  speech_register·번역 원장/오버레이 표적 검사·story_demo locale·
  release_content_inventory·queue/context·diff. 영향 목록은 조회만 한다.
- source 정합/번역 검수는 비저자가 전수 판단한다. 자동검사는 도달성과 계약
  증거이지 재미·깊이·문체 또는 인간 품질 증거가 아니다.
- 실제 화면/원어민/물리패드/청취·M18 정상노출/전본편·출시 HOLD는 유지한다.
  맥 해제 재요청/잠금우회·native 실행·새 월 시작·재빌드0이다.
- 새 실패0 뒤 구현/마감을 main에 함께 정리한다. STATUS 단독후속0,
  전체audit/240주·종료누수 탐침·비용최적화0. 이 사양은 일회성·새규범0이다.

## 실제 결과·한계

- 원문5잎×5언어만 수리, title/choice2·게임플레이·코드/저장 불변이다.
- 공식 CJK15잎 export/check/import·새 correction1, 이전311 batch/개수 보존.
  CN 초안 하루 누락 check1은 v2 수리, 원자료 보존/검사 완화0이다.
- 등록 정적 source/번역 구성15종 actual0, 초기 stale fullbody1→교정 뒤54case PASS.
  명시 overlay lane은 KO/EN 범위를 거부했으며 lane 자체PASS로 기록하지 않는다.
- 독립 전수 source·번역/보존 판독과 실제raw는 private565에 결속한다.
  source report SHA4d6d0885…98bae/blocker0, preservation SHA74b03385…b0b4f/23checks exact.
- inventory/report 지문 변경 불필요, native/engine0·새 월0·M17 OS잠금 HOLD.
  기존 앱에는 이번 두 source 수리가 없다. 화면/원어민/전체판·출시 HOLD다.
- 자동검사는 도달성과 계약 증거이지 재미·깊이·문체/인간 품질 증거가 아니다.
  승격0·모두 일회성, STATUS 단독후속/전체audit/240주/비용도구/누수탐침0이다.

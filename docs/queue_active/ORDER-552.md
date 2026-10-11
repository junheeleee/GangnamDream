# ORDER-552 — M12 회고의 완료기간 표현 수리

#### [~] ORDER-552 [P1·확인된 시간 결함] 열두 번째 달과 완료한 1년을 구분한다

**착수 — 2026-10-11.** 실제551 W45/완료44주에서 관측한 시간 정합 REWORK만
고친다. 선언을 main에 commit/push한 뒤 구현한다.551의 원관측/packageREWORK는 불변이다.

## 판단·깊이 3문

1. 달력12번째 달 입구에서 이미12개월/1년을 마쳤다고 하는 산문을 남기면
   정상 시간·연말 결산과 충돌한다. `MainGame.gd:8813/:8837`의 W45 도달은 보존한다.
2. 새 선택·24주 효과가 아니다. title/description/choices[1].text 3잎×5언어만
   바꾸고 기존6문단/토큰·선택0·결과2개·효과/flags/id를 그대로 둔다.
3. W49로 미루면 챕터 카드와 경쟁하고 주차 효과가 달라진다. DECISIONS의
   ‘연말의 정확한 날짜’대로 W48 결산/올해의 장면 같은 큐·W49 챕터2 시작은
   유지하며, 현재 일정에 맞춰 ‘열두 번째 달/올해 초/여기까지 버텨왔다’로 고친다.

## 소유·범위

- root: `content/events/story_events.json`, `content/events_en/story_events.json`의
  exact3잎, `content/meta/full_game_localization.json`의9교정 영수증/새batch/현재
  source지문, `content/meta/release_content_inventory.json`의 영향 지문과 필요시
  생성 `docs/CONTENT_RATING_INVENTORY.md`; 큐/사양/WORK_LOG/agent원장과 private552 자료.
- phone_cn_author: `content/events_ja/story_events.json`, `content/events_zh-CN/story_events.json`,
  `content/events_zh-TW/story_events.json`의 exact3잎만 공식 export/check/import로 교정.
  각 언어는 KO에서 직접 작성, 영어 중역·간번 변환0. private552 exchange만 별도 소유한다.
- phone_independent_review: `docs/agent_reviews/ORDER-552.json` 및 새 private 검수 자료만.
  KO/EN/JA/zh 전체15변경잎과 나머지 사건/효과/조건/원장 영수증 불변을 직접 대조한다.
- cjk_wrap_diagnosis: 읽기 전용 일정/소비자·메타데이터 검수. 새 영구체커/등록/engine0.
- `project.godot`, MainGame/StoryMode/LocaleManager 코드, 저장·사용자 설정/Human,
  공개demo14장면/원package, arc_events.json, 자산/음악, 기존판정/보고/raw는 비소유다.
  기존 주거 판단/결과문 문체 등 별도 결함으로 범위를 늘리지 않는다.

## 검증

- 변경 전 KO/EN/JA/zh 대상·원장·공개demo/Human·실제seed/사용자33파일은 읽기
  snapshot으로 보존한다. 엔진을 실행하지 않으므로 새HOME/앱/build/UI 입력은 없다.
- 공식 도구로 정확3leaf ID만 locale별 export→check→import --accept --replace-existing.
  이전targetSHA·공식batch header/digest를 남기고 과거batch를 지우거나 새coverage로 세지 않는다.
- audit_select --list는 목록만. 기존 en_coverage/english_hangul/narrative_continuity/
  scene_audio_contract/speech_register와 full localization inventory3언어,
  release_content_inventory/context/queue를 한 번씩 실행한다. 관련 demo 정적 검사는
  보호 바이트 exact 대조로 먼저 범위를 판단하며 변경 없는 전체pipeline/8·12·240주0이다.
- raw stdout/stderr·실제 exit를 기존 run_command/write_json로 보존한다.
  표적 기존 실패는 귀속을 분리하고 새 실패0 전에는 완료하지 않는다.
  기계 PASS는 재미/깊이/문체/인간 품질 증거가 아니다.
- 비저자가 정확15잎·6문단·{name}/줄바꿈·W45/연말/카드 소비자·원장 current-source
  receipt9개를 전수 읽는다. source 한정GO와 실제 새앱/렌더/원어민 관측은 구분한다.
  새 source는 새 commit/tree에 결속한다. 옛551REWORK/550sourceGO/기타HOLD/사고 불변이다.
- 이번 source수리에서 새게임시스템/규범/번역coverage/출시언어 추가0. 실행·소유 지시는
  일회성이다. STATUS비차단·단독현황판커밋0, 종료누수탐침·479/481 비용작업0이다.

## 완료 증거 슬롯

- 도달 경로: 기존551 실제W45 증거; 새 실행/재플레이0.
- 생산자↔독자: `story_events.json:444` ↔ `MainGame.gd:8837`/기존DataRegistry overlay.
- 바꾸는 상태: 시간 표현15잎만; gameplay/serialize/효과/영수증상태 불변.
- 포기 시 잃는 것: 선택0/1 원결과·효과 그대로, 새분기0.
- 서사 위치: 첫해M12 입구→W48연말회수→W49Ch2 입력 전, 일정 불변.
- 장면 계층: 기존milestone, 추가scene/tier/자산0.
- 닫는 것: PENDING 독립 source 검수. 실제 새패키지/화면·전체제품/출시HOLD는 별도다.

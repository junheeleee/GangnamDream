# ORDER-547 — 다은의 오후 만남·결과 그림 정합 수리

#### [~] ORDER-547 [P1·확인 시각 수리] W35 한 장면 — 전용 6점·기존 문단/결과 CG 배선

**착수 — 2026-10-11.** 546의 실제 W35 시각 REWORK를 별도 구현으로 수리한다.
선언 기준은 clean main source4fe119a다. root가 이 선언을 먼저 커밋·push한 뒤
제품 저작을 시작한다. 월별 관측 기록 예외가 아니라 확인 결함의 구현 오더다.

## 깊이 3문

1. 그대로 두면 일요일16시·남색 사복·편의점 밖/분식집 원문에 밤 계산대·근무복이
   계속 나온다. 새 장면을 발명하지 않고 확인된 원문↔그림 불일치를 없앤다.
2. 세 선택의 원문·비용·효과·관계·예약·꿈 후속은 그대로다. 이미 고른 행동의 장소,
   시간, 참가자만 정확히 보여 주며 새 플래그·게임플레이·저장 체계를 만들지 않는다.
3. 전역 다은 기본 초상이나 다른 만남/밤 가게를 바꾸지 않는다. 이번 한 장면 전용
   자산·기존 문단 배경·지연 결과 CG로 처리하고 화면 확인까지 같은 두 배치로 닫는다.

## 범위·소유 — 명시 파일 외 변경0

### root: 제품 자산·배선·현재 기록

신규 자산은 아래 **6점 및 각 PNG의 .import**뿐이다.

| 종류 | 신규 파일 | 장면 책임 |
|---|---|---|
| 투명 초상 | assets/characters/npc_daeun_regular_offduty_v1.png | 동일 다은 얼굴·빛바랜 남색 카디건/사복, 근무복 아님 |
| 내부 배경 | assets/backgrounds/convenience_store_afternoon_v1.png | 일요일 오후 편의점 내부·계산대 다른 직원, 다은은 배경에 중복하지 않고 별도 초상 |
| 외부 배경 | assets/backgrounds/convenience_store_exterior_afternoon_v1.png | 같은 가게 자동문 밖·빨간 의자·정류장/하천 방향, 오후 연속 |
| 결과 CG | assets/cg/romance/daeun_regular_bunsik_v1.png | 선택0의 분식집 창가 두 사람, 물컵 아래 계산서·부담을 숨기는 절제된 연기 |
| 결과 CG | assets/cg/romance/daeun_regular_walk_v1.png | 선택1의 알람/하천 모퉁이 작별 두 사람·장바구니·같은 가게 원경, 오후 연속 |
| 결과 CG | assets/cg/romance/daeun_regular_night_wait_v1.png | 선택2 마지막 문단의 밤 가게 문밖에서 기다리는 민준 혼자, 다은 동석 발명0 |

root 추가 소유:

- content/events/arc_daeun.json: arc_daeun_02_regular의 visual key만.
- autoloads/ImageRegistry.gd: 위 6점의 기존 registry 방식 신규 등록만.
- assets/event_visual_contracts.json, assets/cg_acting_manifest.json,
  assets/scene_direction_manifest.json, assets/scene_audio_manifest.json:
  이 장면/신규 자산의 기존 계약 배선·생성물 정렬만. 신규 오디오 원음0.
- assets/CHARACTER_VISUAL_BIBLE.md, assets/CONVENIENCE_STORE_VISUAL_BIBLE.md:
  이번 사복·같은 가게 오후/밤 연속성의 기존 원칙을 구체화한다.
- tools/art_resolution_baseline.json: 신규 6경로의 실제 산출값 및 파생 집계만 추가.
  기존 자산 행·목표·밴드·부채를 완화하거나 신규 저해상도를 개선으로 위장하지 않는다.
- content/meta/release_content_inventory.json, docs/CONTENT_RATING_INVENTORY.md:
  실제 자산/시각 키 변경으로 필요한 현재 본편 지문·사실 집계만.
  frozen 공개 데모 후보·패키지 지문·범위·과거 내용 판정을 바꾸지 않는다.
- docs/agent_reviews/ORDER-547-assets.json: 6점 각각의 생성/교정 prompt,
  참조·출처·원본/채택 산출 SHA·채택/반려 이력. 독립 판정 보고와 구분한다.
- CLAUDE.md 현재행, docs/WORK_LOG.md, docs/agent_review_decisions.json,
  이 사양의 결과/마감 archive와 큐 상태, 신규 private raw·격리 산출물/일회성 helper.
  기존 보고·원자료·원장 판정을 덮지 않는다. commit/push는 root만 한다.

### 분리 저작·독립 검수

- cjk_wrap_diagnosis: 착수 시 docs/queue_active/ORDER-547.md,
  docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md만 작성한다.
  기존80행의 문구·상태·링크·우선순위는 exact, 전순번+1과 새547행만.
  149는 제자리에 둔다. 단일 이어보기 source 순서를 바꾸거나 파서를 고치지 않는다.
- phone_cn_author: 위 root 통합 범위 중 content/events/arc_daeun.json의 대상 visual
  key, autoloads/ImageRegistry.gd의 신규6키, assets/event_visual_contracts.json·
  cg_acting_manifest.json·scene_direction_manifest.json·scene_audio_manifest.json,
  assets/CHARACTER_VISUAL_BIBLE.md·CONVENIENCE_STORE_VISUAL_BIBLE.md의 배선 저작을
  분리 소유한다. root는 이 파일을 동시에 저작하지 않고 통합·검증을 맡는다.
  tools/scene_direction_catalog.py는 INDOOR_BACKGROUNDS의 신규
  convenience_afternoon 한 키 등록만 소유한다. generator 동작/검사 범위/최적화
  변경0이며 manifest는 기존 generator로 재생성하고 기존 행의 변경 유형을 대조한다.
- phone_independent_review: 신규6점 원본·연속성·prompt/채택 이력과 제품 diff·raw·
  보호 입구/종료를 전수 읽는다. docs/agent_reviews/ORDER-547.json,
  docs/agent_reviews/ORDER-547-manifest.json 및 신규 private 독립 봉인만 작성한다.
  저자 제품·prompt 원장·기존 보고를 수정하지 않는다.

**비소유:** 모든 KO/EN/JA/zh 문장, 다른 사건과 선택의 gameplay key/효과/조건/
예약/라우팅, scenes/StoryMode.gd·공통 schema/SaveManager, 기존 이미지, 기존 공개
데모/package/pin, project.godot·presets·사용자 저장/설정·과거 인간 판정/보고/raw.
영구 runner·ScreenshotQA·audit 등록·검수 비용/도구 단축 작업은 추가하지 않는다.
다른 파일이 실제로 필요하면 해당 변경 전에 별도 범위를 선언한다.

## 장면 소비 계약 — 기존 기능 재사용

- intro background/portrait는 이 장면의 오후 내부·사복으로만 바꾼다.
  기존 paragraph_backgrounds로 본문 순서 [오후 내부, 오후 내부, 오후 외부]를
  결속한다. 관계 기억 삽입이 있는 경우에도 실제 문단 인덱스/장소를 확인한다.
- 선택0: 기존 result_cg / result_cg_reveal_paragraph=1로 첫 문단은 가게 밖
  오후 문맥을 유지하고 둘째 문단부터 분식집 CG를 보여 준다.
- 선택1: 같은 지연 CG 기능의 reveal=1로 알람·하천/모퉁이 작별을 보여 준다.
  두 사람·장바구니·가게 원경과 오후 빛을 유지한다.
- 선택2: reveal=2로 마지막 문단의 민준 혼자 밤 문밖 기다림을 보여 준다.
  기존 arc_daeun_02b_dream로 넘어가면 원래 밤 가게/계산대·다은 근무 상태로
  복귀한다. 낮부터 꿈 후속까지 같은 사복·장소로 덮지 않는다.
- CG의 실제 시선·손·거리·의상·배경은 문장에 있는 참가자/행동만 그린다.
  비싼 식당·낮의 야간 조명·같은 프레임의 부재 인물을 발명하지 않는다.
- 시각 key를 제외한 사건 JSON semantic diff0, 전 언어 텍스트 leaf exact,
  선택·관계·비용·예약·후속 exact를 각각 대조한다. 번역 export/import0이다.
  저장 schema/호환과 실제 사용자 파일은 불변이며 기존 시각 소비자만 사용한다.

## 배치1 — 6점 제작·계약·독립 전수 검수

- root는 생성 전 아트 방향·연속성 checklist·두 visual bible·기존 사건/CG 계약을
  읽고 채택된 얼굴·가게 구조를 참조한다. imagegen skill로 생성/교정하며
  투명 초상·장소 배경·사건 CG의 서로 다른 소유를 지킨다. 유료 조달/외주0이다.
- 비저자는 6점 전량에서 얼굴·카디건·시간대·가게 구조·참가자·연기·손·시선·
  반사·readability를 읽는다. 반려 원본/prompt는 보존하고 해당 동일 모집단을 고친다.
  자산 단독 계약 통과를 장면 화면/전체 게임 GO로 쓰지 않는다.
- 기존 event_visual_contract_check, cg_acting_contract_check, art_resolution_audit,
  scene_direction_catalog·scene_audio_contract_check와 선택된 영향 정적 검사만
  사용한다. 기존 baseline 빚/실패는 원형 기록하고 새 실패0을 요구한다.
  새 asset 경로의 등록 누락을 빚 증가 승인이나 기존 검사 삭제로 해결하지 않는다.

## 배치2 — 격리 import·기존 소비자·실제 수정 화면

- 엔진 시작 전에 root/비저자가 tracked·원문/번역·공개/player 비로그 파일·기존
  패키지/seed/raw/Human·helper와 source/spec를 독립 입구 봉인한다.
  기존 pre-autoload bootstrap·fresh HOME/XDG·고유 user namespace·안전 runner를
  재사용한다. 실제 user://가 격리 경로임을 확인하며 late _ready 덮어쓰기0이다.
- 새 자산 import는 별도 격리 checkout/환경에서 하고 source project.godot/
  실제 사용자 저장을 쓰지 않는다. 실제 import/export/실행 명령·engine·후보
  commit/tree·app/PCK/manifest/hash·stdout/stderr/Godot·actual exit를 결속한다.
  기존 발급앱·공개 데모·옛 export·package를 덮거나 재분류하지 않는다.
- 기존 ScreenshotQA event-visuals KO/EN·해당 해상도는 주변 회귀다. 고정 cases에
  이번 사건이 없으므로 이것만으로 대상 PASS라 쓰지 않는다. 기존 Story 소비자를
  private 일회성 helper로 재사용한 표적 렌더는 fixture 관측으로 표시한다.
  3본문·세 선택 결과의 reveal 전/후·꿈 후속 복귀를 KO/EN에서 직접 대조한다.
- 실제 제품 재관측은 새 발급 격리 앱에서 실제 W34 seed를 byteexact 이월하여
  무인자 normal Continue→W35 수정 장면을 개별 완독·선택0/결과→W36 첫 문단에서
  추가 선택 없이 종료한다. seed는 실제 W34 후상태이며 fresh W1/무주입 저장이
  아니다. turn/flags/경제 편집·함수진입·AUTO/skip/연타0이다.
- 선택1/2는 격리 fixture 렌더이며 자연 경로 실제 관측으로 부르지 않는다.
  실제 관측 언어/해상도/문단·선택·결과와 prepared KO/EN 표본을 구분한다.
  native 시작부터 비저자 fresh final까지 source/docs/helper를 동결한다.
- CmdQ는 단독 마지막 UI 호출이다. 종료 뒤 getApp/getAXState/getScreenshot을
  다시 호출하지 않고 read-only process/log로 종료 확인한다. 과거544 로그 사고를
  보존하며 현재 보호 exact를 사고 이전 전량 보존으로 확대하지 않는다.

## 완료·판정 경계

- 수정6점·배선/원문/게임효과 불변·표적 계약·fixture·위 실제 수정 화면과 독립
  final 보호가 모두 확인되기 전 [x]로 닫지 않는다. 실패/미관측은 그대로 HOLD/
  REWORK로 남긴다. 기존546/544/534 판정·원자료는 소급 수정하지 않는다.
- source assets/배선 검수는 source commit/tree와 unit scope에, 실제 앱 검수는
  새 package/manifest/evidence SHA에 별도 결속한다. 전량 읽은 모집단·검수 방법·
  결함/수리·미관측을 보고에 적고 work_unit ORDER-547 한정 판정만 추가한다.
- 메타데이터 영향 검사·diff/byte예산은 마지막에만 정렬한다. 선언 때 기존80행
  원문·상태·순서를 보존한 채 순번+1, primary13000/L3·사양16000B 예산을 지킨다.
- 전체 audit/240주·479/481 최적화·STATUS-only commit·후속 월 진행·외부 출시/
  스토어 변경/지출/법률 인증0이다. 인간/원어민/물리패드/연속청취·다른 경로·
  전게임/출시 HOLD는 유지한다. 자동 계약은 재미·깊이·문체의 증거가 아니다.
  새 정본 규범0이며 이번 실행 지시는 일회성, 기존 아트 정합 원칙만 적용한다.

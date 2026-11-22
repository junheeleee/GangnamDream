# ORDER-833 — 아버지 사망 통보·애도 P0 증거

## [~] 2026-11-22 · 첫 단위 선언

기준 main `43ff314f0a7ec609a8507736d8d210a34d5fc0fd`, tree
`c9a9dbfdf70f8e19a47fe7d3b1360c90601aab03`. 830 구현은 마감했고 그 사양의
실청취/사람/전수 관찰 OPEN은 그대로다. 이 파일은833의 첫 단위만 소유한다.

### 정확한 파일 소유권 — 34경로

- `content/events{,_en,_ja,_zh-CN,_zh-TW}/{arc_drama,arc_year_close,callback_events_42}.json` 15개.
  W188 root 우선 known2·사망 통보와 terminal2의 시간·결과, 두 콜백의 해당 사실,
  W190 `arc_y4_year_close_daeun/unattached.description_if_known.father_passed`만.
  다른 사건·선택효과·순서·종류·사망flag/writer·후속edge는 보존한다.
- `scenes/MainGame.gd`는 엔딩 아버지 후일담의 '그날 떠나던 밤/한 시간 늦음'
  두 KO/EN UI문장만. `locale/ui_{ja,zh-CN,zh-TW}.json` 3개는 그 두 새 표면만.
  교체된 옛 UI두 key는 활성 locale에서만 은퇴시키고 원문/이전 번역/수용을 같은
  correction batch에 보존한다. 다른 UI/ORDER818 오프닝·JA exact `いい1か月`·라우팅/저장 변경0.
- `content/meta/{full_game_localization,exposed_event_state_contracts,story_rules}.json`은
  공식 source/이전target 결속 수용과 해당 생사/주거·콜백 사실만.
- `assets/scene_audio_manifest.json`은 병실 회상을 현재 집에서 읽는 해당 콜백만.
  재사용 가능한 현행 실내 원음/무관 층 억제, 새음원/전역Audio/BGM 변경0.
- `assets/event_visual_contracts.json`은 같은 콜백의 현재집/혼자인 민준 한 계약만.
  새 story presentation의 expected_background에 실제 시각 계약이 필요하다는
  서사검사1실패를 관측해 추가 선언한다. 기대값 삭제/감사 완화로 피하지 않는다.
- `tools/{chapter4_causal_route_audit.py,ChapterFourRelationshipCheck.gd,scene_audio_contract_check.py}`는
  새 사실/생사 변형/실제 상태 토큰/원래3선택과 terminal효과 보존을 강화한다.
  옛 시간 모순을 유지시키는 기대값은 사실 경계로 정렬하되 검사 완화0.
- `content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md`는
  바뀐 실제 원문의 현행 지문/생성 보고서만. 분류·강도·역사 패키지/설문 변경0.
- `CLAUDE.md`, `docs/WORK_LOG.md` 같은KST날짜 한항목,
  `docs/queue_active/ORDER-833.md`, 이 파일.
- `docs/queue_archive/ORDER-833-Y1-Y2-COMPLETED.md`는 활성 사양16,000B 예산을
  넘겨 기존 완료 문단 두 개만 바이트 그대로 이관한다. 새 완료/재검증으로 세지 않는다.

### 장면/검증 계약

W188 전체 체인은 기존 가족 전환점 T1이다. 실제 현재집→겨울 승강장/회의실→
빈 병실/회의실 통화의 전용 자산·초상/기존grief·direction을 유지한다. 통보 전에
이미 숨을 거둔 사실과 도착/거래 뒤 시간을 구분하며, 500만원 효과는 바꾸지 않는다.
현재 순자산 비교는 기존 `{assets}` 실값 formatter만 쓴다. 생사 확정 writer는
두 terminal만이며 root에서 앞당겨 후속이 차단되게 만들지 않는다.

W190은 새로운 주간slot/scene ID가 아닌 기존 한 장면의 생사 변형 T1이다. 실제
다은이 있는 카페 또는 혼자 있는 현재집에서 발인 뒤 유품을 정리한다. 수첩·본인
후속진료 안내·가족 청구를 남겨 원래3선택/보호flags/W192 세 독자를 보존한다.
새 영구flag·아이템·새 인물/장소·강점 장면 재작성0. 각 런에서는 한 변형만 읽는다.

초기 T2 분류는 `narrative_spine.json:739–744`의 boss 지정과 충돌해 철회했다.
`SCENE_TIER.md:253–265`가 우선한다. 현재 전용 유품 CG·direction/cue 부재는
OPEN이며, 본문 초안/언어 정합을 장면 출시GO로 세지 않는다. 다음 자산 단위의
정확한 파일 선언·실제 자산·배선·검수 전까지 W190 정점 완성 판정은 HOLD다.

깊이3문: 잘못된 사망/예방가능 시각과 후일담 인과를 제거한다; 두 terminal의
기존 비용/후속 grief·scar·엔딩 독자는 그대로다; 병동 대 거래는 현재 중복이므로
호환 단위 뒤 한 번으로 줄인다. 이번 단위만으로 중복선택 수리 완료를 주장하지 않는다.

QA는 KO원문에서 각각 독립 번역한5언어·숫자/토큰/문단·known 우선순위·생사,
W190 실제 Main 선택과 상태/3결과, 기존 의료2-of-3·terminal효과·콜백·후일담,
서사/EN/한글/JA/zh·공식 check/import·보호demo·정본/큐·차분·독립 검수다.
최종 exit와 전체 로그가 있어야 엔진 통과로 세며 namespace는 pre-autoload 격리한다.
미관측 native/실청취/원어민/사람/물리패드/출시GO는 남긴다. 검증기 불변 self-test와
수용 완료된 옛 export를 이유 없이 다시 돌리지 않는다. 루트 돈 설계·다른833 P0/P1은
별도 단위이며 공개RC·project.godot·실제 사용자 저장·외부업로드 변경0.

### 현재 수리 중 — 공식 교환 준비

첫 inventory는 교체된 엔딩UI 옛 source ID 두 개가 current accepted에 남아 거절됐다.
검사기 대신 현재 UI수용2×3만 pending retirement로 분리했다. 원래6영수증은 기존
batch와 외부 `gangnam-833-father-p0.EgftT7/retired-ui-receipts.before.json`에 보존,
accepted 전 지문 `b08180d69961feb64a22ca24f8f2d4dd53a9c1537c051b83fb9821f1f7e63702`.
새 UI수용 뒤 같은 correction batch의 superseded_acceptance_by_locale에 결속한다.
새 UI수용은 교체 표면이며 새기능coverage로 세지 않는다. 이전6수용과 실제 옛 번역은
최종 correction batch에 보존했다. 아래 공식 import51은 완료, 장면최종은 별도다.

공식6 import는 events15/UI2×3 모두 exit0이다. 이후 JA/zh UI감사에서 활성
옛 key 두 개씩이 unknown extra로 거절됐다. 도구 대신 이6키의 실제 옛 번역을
수용 원장의 `retired_target_text_by_locale`에 지문과 함께 보관하고 활성 사전에서만
뺀다. 과거batch·6수용·원문은 보존하며 새2UI를 새기능coverage로 세지 않는다.

### 다음 단위의 확인 위험 — 아직 제품 변경0

중간 choice kind를 expression으로 바꾸면 과거 read_receipt가 깨진다
(`FullStoryFlow.gd:1011–1035`). 새 후속 고정은 구 platform1→deal_morning,
deal_room0→hospital_room의 pending/closed_results와 충돌한다(1038–1079).
원래 적용 결과·terminal을 좁게 보존하는 호환/실제fixture가 먼저이며 일반 검증을
느슨하게 만들지 않는다. StoryMode의 choice0-only KTX컷도 함께 맞춰야 한다.

## 2026-11-22 첫 단위 결과 — 사실/언어 정합, P0 전체 미완

| 증거 | 실제 결과 |
|---|---|
| 도달/상태 | 격리 `CHAPTER_FOUR_FATHER_P0_CHECK_OK`: known15·money10·medical10·terminal10·W190본문20/기억10/선택30/Main route2, RESTORED=true |
| 생산자 ↔ 독자 | `arc_drama.json:902,926` ↔ `callback_events_42.json`·`MainGame.gd:22751,22753`; W190 `arc_year_close.json:451,548` ↔ 기존W192 보호3flags |
| 바꾸는 상태 | 사망/효과/writer/edge/choice_kind 불변; 선통보 뒤 도착/거래·발인 뒤 유품 본문과 source-bound 번역만 |
| 포기 시 잃는 것 | 기존 `tried_to_go_to_father` / `chose_money_over_father`와 +12주 콜백, 의료2-of-3 보존 |
| 서사/계층 | Chapter4 boss W188/W190 T1; W190 전용 자산·direction/cue OPEN |
| 닫는 것 | 시간모순/오역·콜백 현재집 오음만. 중복 딜레마·유품 완성·사람 검수는 닫지 않음 |

- 공식 source15event+2UI×3=51 import exit0. 사건39개는 기존번역정정, 6개는
  새 사망 전용 유품 leaf, UI6개는 옛2표면 교체다. 전체 본편 완성/원어민GO 아님.
- 독립 검수: a1_test_tools KO/EN17 전수, w209_route_recon JA/TW34 전수,
  root CN17 전수. EN 방 정리를 사람 제거로 번역한1곳·목적어/질문/시제3곳 수정 뒤
  재대조GO. CJK 첫 token/횟수 실패 초안과 최종은 외부 교환 폴더에 그대로 보존.
- 표적: audit ERROR0/WARNING0·EN/hangul0·JA UI3005/errors0·zh skeleton PASS,
  서사1813/미분류0·노출531·시각413·정점31·chapter4 self-test73·보호demo5언어
  14사건/100leaf/125UI·정본/큐 통과. 목록137검사를 모두 실행했다고 세지 않는다.
- 최종 격리 engine `gangnam-833-father-p0-ch4-final.7D08ne`: exit0/stderr0,
  stdout=godot SHA `ac82e1ebd1fc45180c231a69ac422bbb01ed9b97d45149913992a0c6065c6b7d`.
  compile `gangnam-833-father-p0-compile-final.bwZuzk`: 69/exit0/stderr0,
  stdout=godot SHA `6b0ccd20f1cd4a44fd361d75ab5a876b51915982517cd4e15ec8917457cc0615`.
  세 로그 전체 오류/경고/누수0. 첫 fixture 실패 `.51fCAJ` 보존: 실제 flags 주입과
  JSON float 타입만 수리, 제품 수치/기대 사실 완화0.
- 출시 내용은 현재 지문만 동기화. fear 후보140→142, crime73→74 중 새범죄는0:
  콜백의 ‘열차표를 **사기** 전’ 검색 노이즈를 실제 확인해 noise 목록에 보존했다.
  sexuality는 후보125 불변/해당 병실 본문 지문만 변경. 정식 고지·공개RC/역사 불변.
- 기존 UI6 활성키 은퇴로 JA/zh unknown-key 실패를 수리; 텍스트/이전 수용은 같은
  batch에 모두 보관한다. 검사 도구 완화0, 보호 오프닝과 JA exact-canon 불변.
- w211_asset_recon 독립 역복원: source/response/header/이전target/private수용6 및
  실제target51 일치. event9/UI3·KOEN6/Main2줄을 소유값만 역치환해 HEAD 전체동일.
  기존459batch·비소유수용·retained9 불변, 원장2batch만 추가/옛45수용 보존.
  검수 원장SHA `068488fdfa8d2cc08cfba2ba79e6855c37dcdd733aea19a2617970ac99a126dd`.
- 자동 통과는 계약 증거이지 재미·깊이·문체·사람 GO가 아니다. 이 단위는 시간 사실과
  언어 정합만 검수했으며 W190 그림·연출/cue, 중복 선택과 구 저장, native/청취/원어민/
  사람/물리패드/전체CI는 미완·미관측이다. 830의 OPEN도 그대로다.

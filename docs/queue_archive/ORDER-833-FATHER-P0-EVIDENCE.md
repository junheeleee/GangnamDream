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
  기존 UI/ORDER818 오프닝·JA exact `いい1か月`·라우팅/저장 변경0.
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

W190은 새로운 주간slot/scene ID가 아닌 기존 한 장면의 생사 변형 T2다. 실제
다은이 있는 카페 또는 혼자 있는 현재집에서 발인 뒤 유품을 정리한다. 수첩·본인
후속진료 안내·가족 청구를 남겨 원래3선택/보호flags/W192 세 독자를 보존한다.
새 영구flag·아이템·새 인물/장소·강점 장면 재작성0. 각 런에서는 한 변형만 읽는다.

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

### 다음 단위의 확인 위험 — 아직 제품 변경0

중간 choice kind를 expression으로 바꾸면 과거 read_receipt가 깨진다
(`FullStoryFlow.gd:1011–1035`). 새 후속 고정은 구 platform1→deal_morning,
deal_room0→hospital_room의 pending/closed_results와 충돌한다(1038–1079).
원래 적용 결과·terminal을 좁게 보존하는 호환/실제fixture가 먼저이며 일반 검증을
느슨하게 만들지 않는다. StoryMode의 choice0-only KTX컷도 함께 맞춰야 한다.

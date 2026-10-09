# ORDER-488 — 4장 기본 회수 선택지의 모호한 장소 표현 수리

#### [x] ORDER-488 [사용자 문장 지시] 놓친 일정의 재방문 시각 — 2026-10-09

## 근거와 경계

- 최신 사용자 지시의 기본 arc_36_unexpected_hand 선택지 추가를 실행한다.
  선행487은 실제 main00eec859/CI37858051278의 전체 success를 확인해 닫았다.
  DECISIONS 2026-10-03의 person_deal 중립 표현과 2026-10-08 표적 검증 상한을 따른다.
- 지정 2장 수첩·5장 기간 초안은 완료472에서 KO/EN40·JA/zh120과 화면6건을
  처리했다. 이번에 중복 적용하지 않는다. 새 계측/재사용/이력 검사 도구는 만들지 않는다.
- exact 모집단: arc_36_unexpected_hand의 choices[1].text 한 잎만.
  한국어/영어 각1과 JA/CN/TW 각1의 기존값 교정이다. 본문·결과문·조건·효과·
  플래그·라우팅·장면 자산·선택 개수/순서는 불변이며 새 번역 coverage가 아니다.

## 깊이 3문 / 제품 의미

- 지우면: 다은 약속과 무연애 야간 진료에 공통인 행동을 이름 없는 ‘곳’과
  시각 전송으로 뭉개는 선택지가 남는다. 실제 할 일은 놓친 일정을 다시 잡는 것이다.
- 24주 뒤: 기존 arc_y4_missed_cost_repaired_person/accepted_grace와 후속 독자를
  유지한다. 이번 문구 교정은 새 상태/성공/예약/관계 회복을 만들지 않는다.
- 경쟁: 같은 사건의 아버지 병동 약 확인 시각 확정 선택을 보존한다.
  놓친 사람/진료를 돌보는 기존 결정만 분명하게 쓴다. 숨은 경로·도덕 해설0.

## 선언 파일과 소유

- root: content/events/arc_chapter_themes.json, content/events_en/arc_chapter_themes.json.
  exact choices[1].text만 수정한다.
- root 공식 수용: content/events_ja/arc_chapter_themes.json,
  content/events_zh-CN/arc_chapter_themes.json, content/events_zh-TW/arc_chapter_themes.json,
  content/meta/full_game_localization.json. 세 지역은 확정 KO에서 독립 저작한
  exchange를 기존 full_game_localization export/check/import --accept로 수용한다.
- 지문이 실제 변할 때만 content/meta/release_content_inventory.json과
  생성 docs/CONTENT_RATING_INVENTORY.md를 기존 생성기로 갱신한다.
- 운영: docs/CODEX_QUEUE.md·CODEX_QUEUE_L3_PENDING.md 순번,
  이 사양/완료 archive, docs/WORK_LOG.md, CLAUDE현재, 생성docs/STATUS.md.
- 독립 번역 저자는 private exchange만 소유한다. 비저자는 실제5언어 한 잎과
  결과/두 경로/영수증·변경 diff를 읽고 메시지로 검수한다. 새 오더별 보고/원장0.

project.godot·사용자 저장·공개 데모/arc_events·과거 인간/에이전트 판정은 불변.
본문·결과에 남은 다른 사실/연출 부채를 이번 선택지 한 잎의 완료로 덮지 않는다.

## 검증 / 종료

1. 선언 commit/push 뒤 KO/EN1씩 반영. 게임플레이·비소유 잎 raw 변화0을 대조한다.
2. 바뀐 잎만 각 locale 공식 export/check/import --accept·source/target 영수증.
3. en_coverage, english_hangul, narrative_continuity, scene_audio_contract_check,
   speech_register, 현재 원장/overlay와 release inventory, 데모·context/queue/diff 표적 검증.
   스케줄러/저장/엔딩 변경0이므로 전체 감사·24주/240주 반복0이다.
4. 독립5언어 전수독해에서 선택지가 일정 재방문이며 수신/예약/치료/재결합을
   보장하지 않는지 확인. 새 실패0 전에는 완료하지 않는다.
   원어민·인간 플레이·물리 패드·출시 GO는 별개다.

규범은 기존 I18N/WORK_UNIT/DECISIONS 소유, 파일 소유·한 잎·검증 순서는 일회성.

## 실제 산출·검증 (2026-10-09)

- 선언9b4cb67 → KO/EN f13fcd1 → 최종 EN/JA/zh·원장1442deb.
  KO/EN/JA/CN/TW 각각 choices[1].text 한 값만 바뀌었다. 다섯 파일의 JSON
  literal 역상은 비소유 잎·게임플레이 raw 변화0을 확인했다. release inventory
  현재 검사도 PASS여서 지문/심의 문서는 불필요하게 갱신하지 않았다.
- 도달 경로: CHAPTER4_CAUSAL_ROUTE_AUDIT_OK promoted19/direct15.
  생산자↔독자: content/events/arc_chapter_themes.json:297 ↔
  scenes/MainGame.gd:7092; 기존 repaired_person 독자는 같은 원문파일:1073/1183.
  바꾸는 상태: choices[1] 모호한 ‘곳/시각 전송’ → 놓친 일정의 재방문 시각 잡기;
  flags/effects/choice 순서/라우팅 변화0. 포기 시 잃는 것: W157 기존
  arc_y4_missed_cost_repaired_person/accepted_grace, 경쟁 choices[0] 아버지 약 확인.
  서사 위치: 기존4장 W157. 장면 계층: 새 장면0·기존 계층 변경0.
  닫는 것: 한 잎5언어 의미/공식 수용만; 본문·결과 사실 부채/본편 품질은 안 닫음.
- JA/CN/TW 각 공식 export/check/import --accept --replace-existing leaves1·files1
  PASS. 잘못된 초기 response의 extra field는 실제 strict FAIL로 거절한 뒤 올바른
  exchange3만 수용했다. 원 source_revision=f13fcd1b9060114b33e6fa3a9c033f49c24102c2.
  source 잎 SHA=fa73e300872d10641a3e66c5a0e36ca409f1b2fb39b333a0d282fe8991f5c6fe.
  private 원 receipt SHA JA4f99a917ce0f0eb757deb04bbcf19eaaf4adcadebb185ab1e928f4db3354a6ef,
  CN660b1266bb77634d890f9a635c157152fc0caed6882a28e6716a65bb2b0bb826,
  TW81966834cfaafe631dfd18ab0e2cca5ad52d514faf29e9c4f41b051540f33ff6.
  committed accepted41887 불변/기존3교정/batch282→285, 다른41884·이전batch·
  metadata raw 불변. 원 collector/overlay/committed receipts의 current source/target3
  모두 일치·translation_errors0; accepted SHA35cd7804134ec57480476f9ae9fcfba78dab3aafe93d7519f27d4dc06a4156ca.
- EN coverage/EN 한글(issues0·format52), NARRATIVE_CONTINUITY_AUDIT_OK,
  SCENE_AUDIO_CONTRACT_OK, SPEECH_REGISTER_AUDIT_OK, PROSE_RECALL_OK,
  RELEASE_CONTENT_INVENTORY_OK, DEMO_I18N_SCOPE_OK, JA demo errors0·ZH skeleton
  PASS. 전체 inventory는 INCOMPLETE/보수적 기존 invalid·unsupported를 보존하며
  현재 교정3 외의 미완료를 완료로 세지 않는다. context/queue/diff 표적 PASS.
  한 문구/번역 영향만 검사했고 새 검사/계측/재사용/전체 감사·엔진 재실행0이다.
- 자동 게이트는 도달·계약 증거이지 재미·깊이·문체·인간 GO가 아니다.
  공개 데모·이전 인간 판정·저장·project.godot 불변. native_reader/human_playtest/
  physical_controller_feel/실제 화면 미관찰, 본편 출시 HOLD/known5 만료10-16 유지.
  본문·결과의 ‘연락창/지난 주말’은 이번 한 잎의 범위 밖이며 수리됐다고 하지 않는다.
  일회성 실행 절차이며 새 규범0; 정본은 기존 I18N/WORK_UNIT/DECISIONS가 소유한다.
- 비저자 choice_copy_review가 source1442deb/기준9b4cb67의 실제5값·두 경로·
  변경 diff와 원 exchange/accepted receipts3를 전수 읽었다. 한 잎 교정 범위 GO,
  blocking0·새 coverage0. 자신의 방문 가능 시간 정하기이며 수신/예약/치료/
  재결합을 보장하지 않는다. 오더별 formal 보고/판정 원장/새 도구는 만들지 않았다.

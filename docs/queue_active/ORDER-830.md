# ORDER-830 — 장면 감각 정합

#### [~] ORDER-830 · C2/C3/C5 · 2026-11-20 KST까지 한정

같은 플레이로 M60 엔딩·크레디트 도달 뒤 사용자 재지정: [829](ORDER-829.md)가 먼저다.
수리는 M01~M06, 각 장 핵심 장면, 엔딩에만 하며 나머지는 발견 목록만 남긴다.
11-20 KST까지 완료·미해결을 나눠 기록한다. 장면 글(장소·시간·행동)과 그림·음악·
환경음·효과를 함께 보고 적합한 에셋이 없으면 만든다. 실화면, 실청취, 정적 후보,
격리 재현은 별도다. 신규 번역 오더/공개 데모/저장/Steam 업로드0.

## 배치 1 — W200–201 결혼식·신혼집

- W200 소형식 입장 원본 얼굴/질감 결함: 확정 앵커와 클로즈업으로 새 후보 제작.
  채택 시 `cg_romance_wedding_daeun_small` ID 유지, 별도 버전 PNG와 import,
  `autoloads/ImageRegistry.gd`, `assets/{COMMITMENT_VISUAL_BIBLE.md,ASSET_INDEX.md,
  IMAGE_PROMPTS.md,cg_acting_manifest.json,mod_asset_manifest.json}`, `tools/art_resolution_baseline.json`,
  `docs/{ART_AI_AUDIT.md,MODDING.md}`의 해당 항목만. 828의 기존 머리말은 별도 보존.
  원본 보존. 신부 시선·짧은 머리·왼쪽 클립·작은 홀/빈자리·대사 안전 영역을 검사.
- W201 `arc_daeun_wedding_night{,_tea,_honest,_choice}`: `assets/scene_audio_manifest.json`
  네 행과 필요 시 `tools/BGMContinuityCheck.gd` 표적 검증. 이전 식장음 종료 수리 유지.
  실내에 비 추가0. 마지막 분기의 원문 속 순간 냉장고 소리와 상시 윙윙거림을 구별.
  현장음과 음악은 독립 판정하고 새 빌드 실청취 전에는 청취 승인0.
- M54 같은 생활음 수리: `assets/scene_audio_manifest.json`에서 실제 어머니 집
  `arc_daeun_hometown_2{,_father_passed}`·`arc_daeun_hometown_table_{hands,daughter,decision}`
  다섯 행. 결과 두 갈래가 버스 CG로 바뀌는 정확한 문단에만 음향도 이행한다.
  `autoloads/BGMPlayer.gd`, `tools/{BGMContinuityCheck.gd,scene_audio_contract_check.py}`에
  명시 CG 한정 결속·실내 계절음 차단·오류 입력 검사를 추가 가능. 검증기 완화0.

- W202 ‘같이 계산하는 저녁’: `content/events/callback_events_2.json`의
  `callback_daeun_committed_gangnam_eve`만. 연락·거절은 실내, 수락 결과에만 실제
  국밥집을 표시하고 환경음도 함께 맞춘다. `assets/event_visual_contracts.json`과
  `assets/scene_direction_manifest.json`, `tools/StoryBackgroundContextCheck.gd` 해당
  표적 검사. 원문과 선택 효과 유지. 기존 식당 환경음이 맞지 않으면 새 녹음을
  구할 때까지 시각과 음향 판정을 구별한다.

## 배치 2 — M60 마지막 책상

실화면 ‘마지막 서명’·‘마지막 주’: 책상·실내 문장과 젖은 실외 대로가 동시 노출.
`arc_final_countdown`과 `arc_final_week`만 `content/events/{arc_pre_ending,arc_drama}.json`,
`assets/{event_visual_contracts,scene_audio_manifest,scene_direction_manifest}.json`에서
주거별 실내 그림과 냉장고 루프를 별도 합성하지 않은 방 환경음으로 결속.
`tools/{SceneDirectionCheck,ScreenshotQA}.gd` 해당 회귀만 확장 가능.
원문·선택·효과·기억·음악/타이밍·실제 실외 변형 보존. 렌더에서 밝기/책상/창을 다시
보고 틀린 주거 그림이면 해당 주거만 새 에셋으로 확장한다. 단순 대체만으로 합격0.

상점 준비물: 기존 725/727 파이프라인을 로컬 실행. 실제 소스에서 8번 회고 실패,
영상 회고 두 장 중복과 정리 오류를 발견했다. `tools/ScreenshotQA.gd`의 해당 두
촬영 범위만 소유(실제 회고 페이지·중복·격리 정리). 가짜/대체 PNG·검사 완화0.
후보에서 결함과 엔딩 스포일러 제외; 사람·물리패드·원어민·출시 GO는 별도다.
16:9 직접 촬영의 초기 상태와 출시 서사 UI를 다시 맞춘다. 트레일러의 옛 AP·결말
화면은 출시 도달 가능한 스포일러 없는 장면으로 교체한다. `tools/trailer/`의
편집·렌더·검사에 한해 최종 AAC를 디코딩해 true peak와 의도적 무음을 검증한다.

2026-11-13 실제 수정:
- `1cd26f5` W200 소형 와이드 v2만. 독립 원화 판정, KO/EN 1280×800 입장·결과 및
  기존 근접 4컷 확인. 기존 commitment 전체 fixture의 사망 부친 기대 ID는 별도 실패.
- `f90f95f`→`a075789` W201 군중 종료 보존과 상시 냉장고 믹스 교체. 새 빌드 실청취0.
- `917f076` M60 두 실내 장면·조용한 환경음; 격리 StoryMode 주거7종, 실외 분기 보존.
- `38cecb4` W202 수락 결과만 국밥집, 미루면 방. KO/EN 36경로 표적 검사.
  국밥집 소리는 기존 바 녹음 기반이라 임시; 한국 소형 식당 녹음 후보/청취가 남음.
- `9eeb07c` M54 가족집·버스 환경음 동기화. 격리 실장면 16경로에서 전환 문단·음악
  연속성과 여름/겨울 실내 계절음 차단 확인; 마이크 청취0.
- `ba44f6d` 상점 회고 촬영과 트레일러 원본 촬영 수리. 격리 8장 수집 성공 뒤 기존
  크롭 출력 상하단 잘림 발견, 별도 16:9 직접 렌더로 후보를 다시 검수 중.

## 완료 기록 — W1 창원 회상과 W6 카페 퇴장

`699622c` 창원 네 컷과 분기별 음향, `86c381f` 카페 퇴장 세 분기의 장소·빗소리.
둘 다 새 구현 범위에서 닫고 아래에는 이전 작업의 exact 범위를 보존한다.

W1 창원에서 무릎을 꿇은 아버지를 문틈으로 보는 문장에 정면 흉상만 표시된다.
2020년의 57세 아버지 앵커와 창원 거실을 근거로 실제 자세·서류·시점을 담은
`assets/cg/story/knee_*.png` 후보를 만든다. 원고·효과·인물 지식·대사 순서·공개 역사
패키지는 변경하지 않는다. 채택은 `content/events/story_events.json`, 해당 그림
등록·출처/크기/연기 원장과 `content/meta/story_rules.json`, 관련 연출 계약·QA에
한정한다. 문틈/붙잡기/등 돌린 뒤 계단은 다른 화면이며 미완 분기를 합격 처리하지 않는다.
`assets/scene_audio_manifest.json`의 무릎 목격 결과와 3선택에서 종이·옷감·걸음을
행동 문단에만 배치하고, 계단에서만 가족 거실 환경음을 분리한다. 가족 선율 연속 유지.
회귀 파일은 `tools/{StoryPresenceCheck,StoryTutorialPlacementCheck,ScreenshotQA}.gd`의
무릎 구간만. 설정·저장 키·분기 효과 변경0.

W6 `cafe_00`(2), `cafe_bluff_caught`(0), `cafe_mind_01`(1)은 퇴장 결과만 민준과
창밖에 이미 보이던 젖은 골목·실외 빗소리로 바꾼다. 자리에 남는 분기는 카페를 보존한다.
`content/events/scenario_cafe.json`,
`assets/event_visual_contracts.json`, `tools/StoryBackgroundContextCheck.gd`만 해당.
W8 반납/보관함의 장소 전환은 ORDER-829 원고와 겹치므로 별도 착수 전 조율한다.

### [x] M04 · 상철 사무실에서 실제 행동만 들린다 (배선)

`assets/scene_audio_manifest.json`, `tools/scene_audio_contract_check.py`, 이 사양만.
첫 만남 0의 차량음, 계산기를 돌리는 measure 0의 컵음, 펜을 내려놓는 answer 6의
종이음만 제거한다. 첫 만남 4의 컵을 꺼내는 동작과 answer 3의 창밖 타이어는 유지한다.
coffee의 긁힘은 맞는 녹음이 없으므로 임의 대체0. 사무실 룸톤·음악/군중 차단·본문·
결과·ID·저장·기존 RC 불변. 네 링크 exact cue map으로 추가·누락·잘못된 시각을 막는다.
격리 Godot 4.6.2에서 5언어×4링크 20건: 수정 전 추가 소리 15건, 수정 후 0건.
같은 문단 재진입 중복 없음, 표준 오류·엔진 로그 오류0, 변조 4건 거부. 실제 청취·
다음 체험판 재패키징은 별도이며 2026.11.13.1 ZIP은 덮어쓰지 않는다.

## 범위 밖 발견 목록 — 수정하지 않음

- W222: 실제 계약이 아직 잠기지 않은 분기에서 공통 ‘최종 계약 집행 시각’ 문구.
- W224·W234: 원룸의 상시 기계음 후보. 두 장면 각각 실제 소리·문장의 추가 확인 필요.
- W234: 눈을 언급하는 실내 화면에서 창밖에 눈이 보이지 않는 후보. 시점·창 위치 확인 필요.

# ORDER-830 — 장면 감각 정합

#### [~] ORDER-830 · C2/C3/C5 · 전구간 에셋 정합 우선

11-14 사용자 재지정: [결정](../DECISIONS.md#2026-11-14-모든-플레이-가능-장면의-에셋-정합을-먼저-끝낸다--사용자-지시).
본편·체험판 모든 장면·분기의 글/그림/소리 정합. 에셋 뒤 사람 테스트. 구 RC·저장·업로드0.
완료 증거: [W4·M14·W234](../queue_archive/ORDER-830-ART-EVIDENCE.md). 직접 청취 미완.
M03 [~] [사고 전·접촉 직후·하차·퇴장](../queue_archive/ORDER-830-ART-EVIDENCE.md#m03-사고-전후). 바퀴 마찰 녹음·실청취 미완.
재회 [~] [비 그친 신촌 정류장](../queue_archive/ORDER-830-ART-EVIDENCE.md#신촌역-재회). 실청취 미완.

## 배치 1 — W200–201 결혼식·신혼집

- W200 소형식 입장 원본 얼굴/질감 결함: 확정 앵커와 클로즈업으로 새 후보 제작.
  채택 시 `cg_romance_wedding_daeun_small` ID 유지, 별도 버전 PNG와 import,
  `autoloads/ImageRegistry.gd`, `assets/{COMMITMENT_VISUAL_BIBLE.md,ASSET_INDEX.md,
  IMAGE_PROMPTS.md,cg_acting_manifest.json,mod_asset_manifest.json}`, `tools/art_resolution_baseline.json`,
  `docs/{ART_AI_AUDIT.md,MODDING.md}`의 해당 항목만. 828의 기존 머리말은 별도 보존.
  원본 보존. 신부 시선·짧은 머리·왼쪽 클립·작은 홀/빈자리·대사 안전 영역을 검사.
- W201 [x] `assets/scene_audio_manifest.json` 다은 신혼집 네 행·`autoloads/BGMPlayer.gd`,
  `tools/BGMContinuityCheck.gd`, 이 사양·증거 이관본·`CLAUDE.md`·WORK_LOG만. 집에서
  남는 겨울음과 빠른 월 전환에 되살아나는 입장곡 차단. [내부 믹스 증거](../queue_archive/ORDER-830-ART-EVIDENCE.md#결혼식과-신혼집-연속-믹스); 실제 청취는 미완.
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

### [x] M02 장소 전환 · W202 국밥집 수락 환경음

[원화·경로·저장·음향 격리 증거 보존](../queue_archive/ORDER-830-ART-EVIDENCE.md)
— W8 배경 3장·5언어/2해상도·컷 경계 저장 복원, W202 수락 결과만 바 소리 제거.
새 빌드 실화면·연속 청취·사람 승인과 별도다.

### [x] M04 · 상철 사무실에서 실제 행동만 들린다 (배선)

`assets/scene_audio_manifest.json`, `tools/scene_audio_contract_check.py`, 이 사양만.
첫 만남 0의 차량음, 계산기를 돌리는 measure 0의 컵음, 펜을 내려놓는 answer 6의
종이음만 제거한다. 첫 만남 4의 컵을 꺼내는 동작과 answer 3의 창밖 타이어는 유지한다.
coffee의 긁힘은 맞는 녹음이 없으므로 임의 대체0. 사무실 룸톤·음악/군중 차단·본문·
결과·ID·저장·기존 RC 불변. 네 링크 exact cue map으로 추가·누락·잘못된 시각을 막는다.
격리 Godot 4.6.2에서 5언어×4링크 20건: 수정 전 추가 소리 15건, 수정 후 0건.
같은 문단 재진입 중복 없음, 표준 오류·엔진 로그 오류0, 변조 4건 거부. 실제 청취·
다음 체험판 재패키징은 별도이며 2026.11.13.1 ZIP은 덮어쓰지 않는다.

## 추가 확인 후보 — 발견 이력 보존

- W222: 실제 계약이 아직 잠기지 않은 분기에서 공통 ‘최종 계약 집행 시각’ 문구.
- W224·W234: 원룸의 상시 기계음 후보. 두 장면 각각 실제 소리·문장의 추가 확인 필요.
- W234: 눈을 언급하는 실내 화면에서 창밖에 눈이 보이지 않는 후보. 시점·창 위치 확인 필요.

### [x] 원격 감사 재현: W8·W201·W202 및 모딩 표 — 표적 검증

`scenes/StoryMode.gd`와 `assets/w8_fallout_result_cuts.tres`에서 다섯 언어의
기존 W8 전환 경계만 표시 문구와 분리한다. W202 상태 원장의 누락된 `housing`만
`content/meta/exposed_event_state_contracts.json`에 등록한다. `docs/MODDING.md`의
생성 표 순서만 복구하고 828 머리말을 섞지 않는다. `tools/StoryNameplateCheck.gd`는
W201 네 장면의 정확한 룸톤을 종전 `oneroom`이 아닌 현재 `apartment`로 고정 검사한다.
영어 감사기·저장·번역·원화·음원·기존 RC 변경0. 기록은 이 사양과 `docs/WORK_LOG.md`.

2026-11-14 KST 제품 `4800558c0f084c53544a088c29e8c4c231a90e88`, tree
`871948cc1bfc10a0db5bbc6afb271fce1b2ecd08`. 영어 표면 후보 0·노출 상태 원장·모딩 270/142·
장면 연출 107배경·데모 5언어 14사건/100잎/125UI 통과. Godot 1280×800에서 W8
10경로·30쪽·경계 직전 저장 재개 10건·언어 전환 8건, W202 무음 2건 및 공유 유지,
기존 48경로 통과. 별도 검수는 신혼집 8/8 포함 이름표 24건·격리 저장 재개 4건,
기존 검증 조건과 828 머리말 보존 확인. 두 stderr 0, stdout SHA-256은 각각
`824f3f304fd6d9aaa94a5c95ca9da7e1be0022b9a2ebf1fe874bdc1b6a6e077d`,
`f59ba9e058cde55917ae42c0d09317130864a09d0c92229cfc423d73bd8671a2`.
[직전 W202 원격 검사](https://github.com/junheeleee/GangnamDream/actions/runs/43448464767)는
정적 성공/엔진 실패(11개). 수리판 전체 CI·새 빌드 실청취·사람 승인은 별도이며,
출시 원장의 심의 문구/분류와 범위 밖 실패는 임의 수정하지 않았다.

### [x] 출시 콘텐츠 사실 원장 동기화 — C3 표적 검증

만지는 파일: `content/meta/release_content_inventory.json`,
`docs/{ART_AI_AUDIT,CONTENT_RATING_INVENTORY,WORK_LOG}.md`, `CLAUDE.md`, 이 사양과
[완료 증거 이관본](../queue_archive/ORDER-830-ART-EVIDENCE.md)만. 실제 반영된 829·830 원고/그림의
현행 소스 수치·해시·확인 통화 근거만 대조한다. 교체된 결혼식 원본은 패키지 포함 대상인
역사본으로 명시한다. 승인된 공개 8.31 원장/팩, 사실 분류·강도·등급·설문·필터·검사기·제품 코드
변경0. 이관은 완료 증거 원문 유지이며 828의 미커밋 머리말/정렬 변경을 섞지 않는다.

2026-11-14 KST: 격리 스테이징 검사에서 정본/큐·출시 원장·변이 45건 통과. 현재
활성 270/원본 327/패키지 대상 319 이미지. 공개 8.31 원장·보고 구역은 바이트 동일.
독립 검수는 4축 사건 집합/강도 불변, 실제 문장과 원화, 교체 v1의 등록 해제와
패키지 대상 유지, 생성 보고서 일치 확인. 새 패키지·연령 등급·사람 승인 아님.

[직전 전체 CI](https://github.com/junheeleee/GangnamDream/actions/runs/43459229842)의
실패 8개 중 이 변경은 문서 예산과 출시 원장 두 항목만 처리한다. 나머지는 채권자 배우
계약, 무릎 CG 연속, 6월 분 단위 계약, 구 V2 캡처 문장, 상철 저장 검사, 프롤로그
결과 전환 검증이다. 재실행 전체 결과는 별도. 2월 거절 분기 EN에서 4:20 상하차를
종료가 아닌 시작으로 읽게 하는 별도 현지화 불일치도 관찰했으나 이번 원장에서는 변경0.

### [x] W1 무릎 장면 — 배우·연속 컷·다음 전환 검증

`assets/cast_detail_manifest.json`, `tools/{CGRuntimeCheck,StoryPlaybackCheck}.gd`, 이 사양과
`CLAUDE.md`·`docs/WORK_LOG.md`만. 채권자는 휴대폰·보증서 행동이 있는 B급 장면 배우다.
무릎 CG 3장의 실제 소유자 집합과 같은 팜 컷이 이어지는 한 연결만 고정한다. 결과
컷의 실제 전환이 끝나고 나서 다음 장면을 누르며, 다음 전환의 출발 그림까지 확인한다.
원화·원고·런타임·저장·다른 CG 소유 계약·예외 목록·기존 RC 변경0.

2026-11-14 KST: B 배우 20(앵커 7/엑스트라 9), W1 3CG 소유 전수 독립 대조.
격리 Godot에서 `CG_RUNTIME_CHECK_OK`, `STORY_PLAYBACK_CHECK_OK`(연출 3,
직접 진행 8, 5장 기존 156/1044쪽). 팔꿈치를 받치는 결과 컷 전환 중 입력 차단과
전환 완료 뒤 그 컷에서 다음 시간 전환을 시작하는 것을 분리 확인. stderr 0, stdout
`dec3fedd0e32c9017c7e98fb9344795651784f0ad5763af7c912f5bd3cae5a64` /
`7dcf775e029e6161efe8ac60086a080f211a81a5e64e564734b0b713a7fa496a`.

### [x] 승인 원고와 4·6월 회귀검사 대조 — C3 표적 검증

`content/meta/demo_localization_scope.json`, `tools/{CoreLoopV2ECheck,ManualSaveCheck,
StoryDemoFourLanguageCheck}.gd`, `tools/demo_localization_scope.py`의 현행 원장 해시 한 줄,
이 사양·`CLAUDE.md`·`docs/WORK_LOG.md`만. 이전 6월
휴식 분기의 당일 18:00 시각 계약 한 행을 폐기하고 다음 날 아침 알람 한 개를 5언어
실제 데모 선택에서 확인한다. 현재 18:00 업무 마감과 분 단위 제한은 유지한다.
모집책 캡처는 발신 시각과 번호를, 상철은 벽시계/종이컵의 현재 영어 문장만 정합한다.
원고·선택 효과·저장·검사 예외·과거 RC 변경0.

2026-11-14 KST: 원문 7→데모 4번 휴식 선택 5언어/120주/30정산, 옛 V2의 2×2
수신/캡처·정확 영수증/저장, 상철 15변형·5언어·정상 디스크/기록 검사 통과. 분 단위
검사 24개와 소스 결속 16+71 통과. 독립 검수에서 휴식 계약 한 행·현재 지문만 변경했고
되살린 18:00은 불허. 짧은 전체 저장 로컬 실행은 175초 한도로 중단되어 CI 규격으로
재실행 중이다. 상철 표적 통과를 전체 저장/원격 CI 성공으로 세지 않는다.

[완료 증거: W1 결과 저장 — 전환 중 잠금과 이후 복원](../queue_archive/ORDER-830-ART-EVIDENCE.md#w1-결과-저장--전환-중-잠금과-이후-복원).

[완료 증거: 신혼집 결과 컷 재촬영](../queue_archive/ORDER-830-ART-EVIDENCE.md#신혼집-결과-컷-재촬영).

### [x] 신혼집 밤 소등

`scenes/StoryMode.gd`, `tools/ScreenshotQA.gd`, `assets/FIRST_MORNING_VISUAL_BIBLE.md`,
이 사양·증거 이관본·`CLAUDE.md`·`docs/WORK_LOG.md`만. 다은·지연 각 두 분기의 밤
마지막 문장이 끝날 때 그림만 소등. 아침 컷은 기존 공개 시점, 복원은 기존 문단 위치.
글·저장 키·음향·공개 RC 변경0.

KO/EN 2해상도 36컷·복원·독립 검수 통과. [증거](../queue_archive/ORDER-830-ART-EVIDENCE.md#신혼집-밤-소등). 연속 청취는 별도.

### [x] W8 은행·보관함 실화면과 믹스 녹음

`tools/StoryBackgroundContextCheck.gd`, 이 사양·증거 이관본·`CLAUDE.md`·`docs/WORK_LOG.md`만.
기존 exact 두 갈래를 같은 StoryMode에서 재생해 전환 직전·직후 그림과 실제 게임 믹스를
새 외부 폴더에 저장한다. 기존 검사·제품·저장·공개 RC 변경0. 녹음과 실제 청취는 별도다.

[실화면·녹음 증거](../queue_archive/ORDER-830-ART-EVIDENCE.md#w8-은행보관함-실화면과-믹스). 밖의 말소리 출처는 청취 후보.

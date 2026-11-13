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

### M02 · 은행 창구와 지하철 보관함 — 최초 원화 후보 검수

후보 제작은 `assets/backgrounds/{bank_service_counter_rainy_day,subway_station_coin_lockers}.png`
두 파일과 이 사양만. 원문 `arc_temptation_fallout`의 도입 빗길은 유지하고,
반환의 지점 창구와 추가 인계의 지하철 역사 무인 보관함을 각각 그린다. 어느
후보에도 인물·상호·인식 가능한 번호·거래 물품을 굽지 않는다. 시간대가 확정되지 않은
보관함은 창 없는 실내로 그린다. 기존 인터뷰 사무실·분실물 센터·전동차는 대체 금지.
후보가 통과한 뒤에만 문단·분기·음향·저장 복원 배선을 별도 선언한다. 기존 RC 보존.

2026-11-13 KST: `~/Documents/GangnamDream-Release-Assets/m02-location-art.d8zT0G/1280x800/`
두 RGB PNG를 비작성 에이전트가 전수 확인했다. `all_resources`가 미등록 자산도
포함할 수 있어 채택 전까지 프로젝트 밖에 둔다. 8.31·11.13.1·11.13.2 RC,
런타임·저장·사건·언어 변경0. 자동 배선·실화면·실청취0.

| 후보 | 원화 검수 및 SHA-256(1280×800) |
|---|---|
| `bank_service_counter_rainy_day.png` | 겨울 가로수·유리 너머 빗길, 창구 두 곳과 무표기 번호표 단말, 인물·거래 물품 없음. 여름 잎이 보인 첫 후보 반려·보존. `6013624b5aa9c52c7c930f6364506fee2508ad8c42b2afa2df993c5126af8eb6` |
| `subway_station_coin_lockers.png` | 창 없는 역사 통로, 닫힌 보관함과 단말, 무표기·인물/소지품 없음. 강제 날씨·시간대 없음. `583d3270f61d4c2607b666f7869047b762be239edfa975a545aa447665cad8fd` |

프롬프트 요약: 강남잉크 저채도·매트 종이·잉크 윤곽과 하단 대사 여백. 은행은 기존
면접실을 질감 참고로만 삼아 동네 은행의 고객 동선과 바깥 비를 그렸다. 두 번째 생성에서
나뭇잎·번호표 단말·창구 홈만 수리했다. 보관함은 역 계단 그림을 질감 참고로만 삼아
타일·금속 문·통로를 그렸으며 전동차나 분실물 센터를 넣지 않았다. 원본·반려본은 같은
외부 폴더에 있다.

다음 배선 전 확인: `arc_temptation_fallout` 5언어 모두 도입 4/결과 각 2문단.
반환 0번은 바로 창구에 도착하지만 두 번째 문단 도중 은행을 나선다. 추가 인계 1번은
첫 결과 문단 도중 사흘 뒤 보관함으로 간다. `StoryMode.gd`의 결과 배경은 선택 직후부터
결과 전체에 적용되므로 그대로 붙이면 시각이 어긋난다. 도입 빗소리 보존, 실내에 기존
냉장고/전기음·열차·군중 루프 임의 대체0. 저장 복원·언어별 이동 경계를 함께 검증한다.

W202 수락의 `hoesik`은 바 녹음과 영국 펍 대화층을 겹친다. 공용 국밥집 배경의
음향 프로필은 현수 재회도 읽으므로 공용 교체0. [서울 소형 국숫집 녹음 후보](https://freesound.org/people/ultradust/sounds/167733/)는
평일 점심 원음으로 저녁 장면에 그대로 쓰지 않는다. 원본 청취·장면 적합성·출처 표시를
확인하기 전 후보이며, 다운로드·채택0.

### [x] W202 국밥집 수락 결과의 바 소리 제거 — 소스·격리 검증

`content/events/callback_events_2.json`의 `callback_daeun_committed_gangnam_eve`
0번 결과 환경음 한 키, `scenes/StoryMode.gd`, `autoloads/BGMPlayer.gd`,
`tools/{audit.py,StoryBackgroundContextCheck.gd}`, 이 사양과 `CLAUDE.md`·`WORK_LOG.md`만.
명시적 무음은 장소 환경음·군중·계절음만 즉시 종료하며 음악·효과음은 유지한다.
원문·5언어·선택 효과·저장·사진·미루는 분기·현수 재회의 공유 프로필 변경0.

2026-11-14 KST `0feeabade3de086705d6e05e4f24b657b34a295b`, tree
`17fb655a43429c6af2d7cc17bc51132a2198bb7b`. 수락 0번의 환경음 한 값만 바꾸고
다른 두 국밥집 독자와 공유 프로필을 보존했다. 독립 검수에서 원 JSON 역복원 및
나머지 4언어 파일 불변 확인. KO/EN 실제 StoryMode 격리에서 수락 결과 2건은
세 환경음 재생기를 같은 프레임에 멈추고 음악 키를 유지했다. 미루기와 기존 48경로,
W8 10경로도 통과. stdout SHA-256
`7135e0dedc08a72277bd0577cf9dd430aea4c3c5fd2cd2f8ebaacda13e3e3178`, stderr 0.
의도적 환경음 무음이며 한국 식당 녹음 채택·실청취·RC 재빌드·출시 승인 아님.

### [x] M02 두 결과의 정확한 장소 전환 — 소스·격리 검증

만지는 파일: 이 사양, `scenes/StoryMode.gd`, `autoloads/{ImageRegistry,BGMPlayer}.gd`,
`assets/{scene_audio_manifest,scene_direction_manifest,mod_asset_manifest}.json`,
`assets/backgrounds/{bank_service_counter_rainy_day,subway_station_coin_lockers}.png`
및 두 `.import`, `assets/{ASSET_INDEX,IMAGE_PROMPTS}.md`, `docs/{ART_AI_AUDIT,MODDING,WORK_LOG}.md`,
`tools/{art_resolution_baseline.json,scene_direction_catalog.py,StoryBackgroundContextCheck.gd}`, `CLAUDE.md`.
같은 은행에서 나서는 컷에는 기존 거리의 낮/밤·마른 노면 불일치를 피하도록 별도
`assets/backgrounds/bank_exterior_wet_day.png`와 `.import` 한 쌍을 같은 원장에 추가한다.
같은 젖은 보도·겨울 나무만 이어가며 실제 비가 계속 내린다고 단정하지 않는다.
검수한 원화 세 장만 채택. 저장 형식·텍스트/현지화 파일·효과·갈래·사건 ID·과거 RC 변경0.
정확한 5언어 기존 문장 경계를 페이지 단위로 나누되 저장에서 쓰는 기존 2개 원문 문단
ID는 유지한다. 반환은 창구에서 시작해 은행을 나설 때 바깥으로, 추가 인계는 답신을
보낸 뒤 사흘 후 보관함으로 이동한다. 등록된 두 실내는 전기음·군중·실외 비를 넣지
않고 기존 음악은 건드리지 않는다. 진행·복원·언어 전환에서 같은 장소를 확인한다.

- 제품 `046459aee20c4e4ec9d4c064c0e61d849bd25b5b`, tree `7bc63369395fce48c510e5bca4c34564e06368b9`.
  은행 외부 1280×800 `b70a3f1bc6d08826ed085b12d0acc9872268cc6fecedfaf28bdc316b6ff08c52`.
  별도 검수자가 동일 은행 창구·문·젖은 보도·겨울빛 확인. 외부에는 일반 거리 환경음만,
  낙우 효과·빗소리는 초기 실외와 거절 답신까지. 두 실내는 환경음만 즉시 정지, 음악 보존.
- 격리 Godot 4.6.2: 1280×800과 960×600 각각 W8 5언어×2갈래·결과 30쪽,
  컷 첫 글자 전 v4 디스크 저장/재개 10건, 전환 전후 KO↔EN 8회, 효과 재적용0.
  기존 48경로·도입160/결과120쪽 통과. stderr·엔진 오류0. 로그 stdout SHA-256은
  `17a80b39af9f45d7ef567ce2a13ade74abd039be88e48ff3f8d93a8e068cc084` (1280),
  `5dbe574aee2c84f6c8a0d8b193f27664eac8b86c7759ef34414efc6f27169bca` (960).
- 아트/모딩 267→270 이미지·기존 등록 불변, 장면 음향/연출 107배경, 공개 데모 5언어
  14사건·100잎·125UI/보호 scope·밀도 및 정적 감사 통과. 원문·사건 데이터 변경0.
  오래된 저장을 다른 언어로 열 때 문단 안의 상대 진행률을 안전하게 추정할 수 없어
  해당 문단 앞에서 다시 읽는다. 독립 확인은 소스·원화·격리 상태이며 게임 실화면,
  연속 청취, 사람 테스트, 재패키징, Steam 반영은 하지 않았다.

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

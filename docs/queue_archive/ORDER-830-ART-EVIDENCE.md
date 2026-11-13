# ORDER-830 — 완료된 M02·W202 증거 보존

[활성 사양](../queue_active/ORDER-830.md)에서 이관한 원문. 상태와 산출물은 당시의 기록이다.

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

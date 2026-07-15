# ART_AI_AUDIT.md — 활성 이미지 품질 감사

> `autoloads/ImageRegistry.gd`에서 파생한 출시 활성 에셋만 다룬다. 삭제·미등록 원화는 런타임 품질 판정에 포함하지 않는다.

## 판정 규칙

- `PASS-A`: 키 비주얼·CG 기준 통과. 얼굴, 손, 시선, 소품, 크롭을 원본 해상도로 재검수했다.
- `PASS-B`: 게임 화면 기준 통과. 정체성·공간 논리·뭉개진 글자·그레이딩을 확인했다.
- `PASS-S`: 작은 보조 표면 기준 통과.
- `REPAIRED-A/S`: 이번 감사에서 수리 후 재검수했다.
- `FAIL`/`PENDING`: 출시 게이트 미통과. 최종 감사에서는 허용하지 않는다.
- 각 행의 12자리 `Hash`는 사람이 판정한 정확한 파일을 고정한다. 같은 경로의 픽셀이 바뀌면 자동 감사가 실패하며 원본 재검수 뒤에만 해시를 갱신한다.

## 감사 결과

- 활성 인벤토리: **186장** (`CG 57 / Portrait 54 / Background 75`). 세 레지스트리의 중복 ID는 같은 파일 한 번으로 집계했다.
- 전수 방법: 종류별 콘택트시트 22장으로 얼굴·실루엣·그레이딩·공간을 1차 비교하고, 손·반사·차량·카운터·정류장처럼 오독 위험이 있는 컷과 키 비주얼 10장은 원본 해상도로 다시 열었다.
- 런타임 수리: 배경이 구워진 `main_character_50s.png`를 본편의 `player_hollow` 슬롯에서 제외하고 같은 민준의 투명 피로 초상으로 통합했다. 현재 이벤트가 없는 박재원의 죽은 초상 등록도 제거했다.
- 이미지 수리: `ending_crypto_ghost.png`의 비현실적인 6면 모니터 벽을 정본 고시원 안의 휴대폰 1대·낡은 노트북 1대로 교체했다. 방 크기, 작은 불투명창, 침대/책상 방향, 민준 신원, 다섯 손가락, 무문자 차트를 원본에서 재검수했다.
- 특별 정합: 사고 컷은 검은 장축 세단·한국식 왼쪽 운전석·운전석 문·자전거 두 바퀴를 유지한다. 정류장은 카메라가 벤치 등받이 뒤를 보며 좌석이 도로를 향한다. 편의점 CG는 다은이 카운터 안, 민준이 출입문 쪽에 있다. 다은 결혼식 9종은 한 프레임에 가족 상태를 과적하지 않고 `다은 어머니 반응 1 → 신랑석 상태 4 → 커플 와이드 2 → 커플 근접 2`로 분리한다. 어머니는 혼주 한복과 딸을 향한 시선, 아버지는 혼주 정장과 통로를 향한 시선, 별세 경로는 완전히 빈 예약석, 현수 재회 경로는 배우자·아이 없는 현수 단독을 지킨다. 커플 컷의 식별 인물은 민준·다은뿐이며 민준 선입장/다은 후입장·소형/풀 의상·상호 시선을 유지한다.
- 글자 게이트: 전경 핵심 소품에는 판독을 요구하는 AI 글자가 없다. 투자 차트·포장지·책등의 작은 표식은 언어처럼 읽히지 않는 비서사 질감이며, 실제 UI 카피를 대신하지 않는다.
- 최종 판정: **FAIL 0 / PENDING 0**. 비활성 원화는 향후 다시 등록할 때 새 감사 대상이 된다.

### 이번 수리 이력

- 모드: OpenAI 내장 ImageGen 이미지 편집.
- 입력 참조: 이전 `ending_crypto_ghost.png`, 정본 `goshiwon_room.png`, 투명 `main_character_tired.png`.
- 최종 프롬프트: “정본 고시원 구조와 동일한 좁은 방, 동일한 33세 민준, 휴대폰 1대와 낡은 노트북 1대만 있는 코인 손실 후 장면. 모니터 벽·추가 화면·텍스트·로고를 제거하고, 자연스러운 다섯 손가락과 휴대폰/노트북을 향한 시선, Gangnam Ink 반사실 애니메이션 질감을 유지한다.”
- 생성 원본: `$HOME/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-6a8364f4-5f1f-4b68-b5b3-d1ee3f35bf20.png`.
- 출시 경로: `assets/cg/ending_crypto_ghost.png` (중앙 16:10 크롭 후 1280x800).

## 키 비주얼 상위 10컷

일반 CG보다 2배 엄격하게 얼굴 동일성, 손, 시선, 장면 동사, 스토어 크롭, 작은 캡슐 축소를 함께 확인했다.

| Surface | Asset | Strict result | Evidence |
|---|---|:---:|---|
| 타이틀·캡슐 원본 | `assets/keyart/gangnam_dream_keyart_cast_v1.png` | PASS-A | 민준·다은·지연 정체성, 세 인물 분리, 실제 타이포 오버레이 여백 통과. |
| 데모 첫 면접 | `assets/cg/demo/first_interview_v1.png` | PASS-A | 낮 시간 사무실, 상호 시선, 이력서 손, 양측 좌석 동선 통과. |
| 데모 다은 첫 친절 | `assets/cg/demo/daeun_first_kindness_v2.png` | PASS-A | 직원/손님 카운터 경계, 삼각김밥 두 개, 손과 출입문 방향 통과. |
| 지연 첫 사고 | `assets/cg/jiyeon_crash_day_v3.png` | PASS-A | 왼쪽 운전석 문, 검은 세단, 자전거 두 바퀴, 상호 시선 통과. |
| 지연 불꽃놀이 | `assets/cg/romance/fireworks_jiyeon.png` | PASS-A | 맞잡은 두 손의 구조, 지연 정체성, 렌즈 아닌 민준 시선 통과. |
| 다은 바다 | `assets/cg/romance/sea_daeun_v3.png` | PASS-A | 머리/신체 비율, 산호색 휴양복, 자연스러운 보행 손 통과. |
| White 엔딩 | `assets/cg/ending_gangnam_dream_white_v1.png` | PASS-A | 창의 희미한 상은 의도된 자기 인식이며 민준이 실제 반사를 응시하는 단일 배우 계약과 일치. |
| Full Circle 엔딩 | `assets/cg/ending_full_circle_v1.png` | PASS-A | 전화 손, 이삿짐 1개, 아버지 비등장, 맑은 오전 크롭 통과. |
| 지연 엔딩 | `assets/cg/ending_jiyeon_man_v2.png` | PASS-A | 두 인물 모두 거울 안에만 한 번 등장하며 중복 몸·역반사 없음. |
| 다은 엔딩 | `assets/cg/ending_with_daeun_v1.png` | PASS-A | 라면/물 정확히 2인분, 상호 시선, 가까운 손, 작은 집의 존엄 통과. |

## 전수 판정표

| Kind | Asset | Registry IDs | Raster | Alpha | Hash | Verdict | Review |
|---|---|---|---:|:---:|:---:|:---:|---|
| CG | `assets/cg/demo/daeun_first_kindness_v2.png` | `cg_demo_daeun_first_kindness` | 1280x800 | no | `f3e0f629c069` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/demo/father_first_call_v1.png` | `cg_demo_father_first_call` | 1280x800 | no | `974db28ea9ac` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/demo/first_interview_v1.png` | `cg_demo_first_interview` | 1280x800 | no | `47f49936c3b9` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_bankruptcy_v1.png` | `cg_ending_bankruptcy` | 1280x800 | no | `8931fa42b953` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_crypto_ghost.png` | `cg_ending_crypto_ghost` | 1280x800 | no | `31e42005c154` | REPAIRED-A | 모니터 벽 제거. 정본 고시원·휴대폰 1대·노트북 1대·민준 손/시선 확인. |
| CG | `assets/cg/ending_debt_spiral_v1.png` | `cg_ending_debt_spiral` | 1280x800 | no | `df7eb173aeb6` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_empty_house.png` | `cg_ending_empty_house` | 1280x800 | no | `d21de2b8eb78` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_father.png` | `cg_ending_father` | 1280x720 | no | `1987aa893662` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_full_circle_v1.png` | `cg_ending_full_circle` | 1280x800 | no | `58bc9c644542` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_gambling_recovery_v1.png` | `cg_ending_gambling_recovery` | 1280x800 | no | `2bdea7f0532a` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_gangnam_dream.png` | `cg_ending_gangnam_dream` | 1280x800 | no | `ade2697c386b` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_gangnam_dream_white_v1.png` | `cg_ending_gangnam_dream_white` | 1280x800 | no | `501b97acf34a` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_guardian_v1.png` | `cg_ending_guardian` | 1280x800 | no | `738f36f22848` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_instant_legend_v1.png` | `cg_ending_instant_legend` | 1280x800 | no | `5519859a8a46` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_jaehyuk_way_v1.png` | `cg_ending_jaehyuk_way` | 1280x800 | no | `dd0b29858a63` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_jiyeon_man_v2.png` | `cg_ending_jiyeon_man` | 1280x800 | no | `62a7f17d4aec` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_late_call_v1.png` | `cg_ending_late_call` | 1280x800 | no | `662ff3e36b30` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_lonely_rich_v1.png` | `cg_ending_lonely_rich` | 1280x800 | no | `91932fd75d7d` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_sangchul_reckoning_v1.png` | `cg_ending_sangchul_reckoning` | 1280x800 | no | `f25fbb0f1004` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_second_love_v1.png` | `cg_ending_second_love` | 1280x800 | no | `2b554360182d` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_startup_exit_v1.png` | `cg_ending_startup_exit` | 1280x800 | no | `be7c29d8d495` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_with_daeun_v1.png` | `cg_ending_with_daeun` | 1280x800 | no | `9c4af6de306d` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/jaehyuk_reveal.png` | `cg_jaehyuk_reveal` | 1280x800 | no | `18243d73b73f` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/jiyeon_crash_day_v3.png` | `cg_jiyeon_crash` | 1280x800 | no | `a714c2c2bc7e` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/amusement_lost_child_daeun_v1.png` | `cg_romance_amusement_lost_child_daeun` | 1280x800 | no | `6651c8b0569e` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/amusement_photo_strip_jiyeon_v1.png` | `cg_romance_amusement_photo_strip_jiyeon` | 1280x800 | no | `2269261438ca` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/breakup_daeun_v1.png` | `cg_romance_breakup_daeun` | 1280x800 | no | `c0ab501e6bef` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/breakup_jiyeon_v1.png` | `cg_romance_breakup_jiyeon` | 1280x800 | no | `cb61e2c4c854` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/cherry_daeun.png` | `cg_romance_cherry_daeun` | 1280x800 | no | `4488bcb12fcf` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/cherry_jiyeon.png` | `cg_romance_cherry_jiyeon` | 1280x800 | no | `bad749c24970` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/fireworks_daeun.png` | `cg_romance_fireworks_daeun` | 1280x800 | no | `55a23dd2f660` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/fireworks_jiyeon.png` | `cg_romance_fireworks_jiyeon` | 1280x800 | no | `1354cbbac3cb` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/first_kiss_daeun.png` | `cg_romance_first_kiss_daeun` | 1280x800 | no | `18b029318d6c` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/first_kiss_jiyeon.png` | `cg_romance_first_kiss_jiyeon` | 1280x800 | no | `70a40ca2ac9c` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/first_snow_daeun_v1.png` | `cg_romance_first_snow_daeun` | 1280x800 | no | `39d748fbba46` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/first_snow_jiyeon_v1.png` | `cg_romance_first_snow_jiyeon` | 1280x800 | no | `f474bbd4ec09` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/hometown_night_bus_daeun_v1.png` | `cg_romance_hometown_night_bus_daeun` | 1280x800 | no | `bfe4d667e0f6` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/namsan_lock_daeun_v1.png` | `cg_romance_namsan_lock_daeun` | 1280x800 | no | `20be22c6b179` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/namsan_lock_jiyeon_v1.png` | `cg_romance_namsan_lock_jiyeon` | 1280x800 | no | `8ab14e6a6df1` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/narrow_room_jiyeon_v1.png` | `cg_romance_narrow_room_jiyeon` | 1280x800 | no | `d54190b71791` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/proposal_daeun_v1.png` | `cg_romance_proposal_daeun` | 1280x800 | no | `43dd3019f278` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/sea_daeun_v3.png` | `cg_romance_sea_daeun` | 1280x800 | no | `ab8f1fc8ff17` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/sea_jiyeon_v2.png` | `cg_romance_sea_jiyeon` | 1280x800 | no | `66255a056e3d` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/wedding_daeun_father_reaction_hyunsu_v1.png` | `cg_romance_wedding_daeun_father_reaction_hyunsu` | 1280x800 | no | `5bd1b635fa1b` | REPAIRED-A | 신랑석 반응. 혼주 정장의 아버지는 통로를 보고, 현수는 정본의 넓고 부드러운 얼굴·웨이브·원형 안경을 유지한 채 배우자·아이 없이 한 줄 뒤에 단독 착석하며 두 사람 모두 렌즈를 보지 않는다. |
| CG | `assets/cg/romance/wedding_daeun_father_reaction_passed_hyunsu_v1.png` | `cg_romance_wedding_daeun_father_reaction_passed_hyunsu` | 1280x800 | no | `c6e1465d86a6` | REPAIRED-A | 아버지 예약석은 완전히 비어 있고 정본 얼굴과 통로 시선을 유지한 현수만 한 줄 뒤에 단독 착석한다. 대체 혼주·배우자·아이·영정이 없다. |
| CG | `assets/cg/romance/wedding_daeun_father_reaction_passed_v1.png` | `cg_romance_wedding_daeun_father_reaction_passed` | 1280x800 | no | `624d3649c593` | REPAIRED-A | 신랑석 앞줄 통로측 예약석이 완전히 비어 있으며 이름 있는 대체 하객·영정·유령 표현이 없다. |
| CG | `assets/cg/romance/wedding_daeun_father_reaction_v1.png` | `cg_romance_wedding_daeun_father_reaction` | 1280x800 | no | `267dbbb868ff` | REPAIRED-A | 아버지 단독 반응. 혼주 정장, 자연스러운 착석 자세, 화면 왼쪽 통로를 향한 시선, 손·좌석 원근 통과. |
| CG | `assets/cg/romance/wedding_daeun_full_v1.png` | `cg_romance_wedding_daeun_full` | 1280x800 | no | `9f5802b4cdd7` | REPAIRED-A | 풀 패키지 커플 와이드. 식별 인물은 민준·다은뿐이며 긴 베일·비즈 드레스·상호 시선·꽃다발 손과 후입장 동선 통과. |
| CG | `assets/cg/romance/wedding_daeun_full_close_v1.png` | `cg_romance_wedding_daeun_full_close` | 1280x800 | no | `44cf880b8e84` | REPAIRED-A | 풀 패키지 커플 근접. 같은 얼굴·정장·드레스·베일, 자연스러운 눈맞춤과 해부학적 손, 낮은 대화창 안전 크롭 통과. |
| CG | `assets/cg/romance/wedding_daeun_mother_reaction_v1.png` | `cg_romance_wedding_daeun_mother_reaction` | 1280x800 | no | `e2565e08f7f7` | REPAIRED-A | 다은 어머니 단독 반응. 분홍 저고리·아이보리 동정·짙은 자주 치마의 혼주 한복, 무릎 위 두 손, 딸을 향한 비렌즈 시선 통과. |
| CG | `assets/cg/romance/wedding_daeun_small_v1.png` | `cg_romance_wedding_daeun_small` | 1280x800 | no | `1ca0ee918da7` | REPAIRED-A | 소형식 커플 와이드. 식별 인물은 민준·다은뿐이며 단순 드레스·짧은 베일·작은 꽃다발·후입장 동선과 상호 시선 통과. |
| CG | `assets/cg/romance/wedding_daeun_small_close_v1.png` | `cg_romance_wedding_daeun_small_close` | 1280x800 | no | `6f7858061cf4` | REPAIRED-A | 소형식 커플 근접. 정본 얼굴·머리핀·성인 체형·민준과의 눈맞춤·양손 꽃다발과 안전 크롭 통과. |
| CG | `assets/cg/romance/wedding_gap_jiyeon_v1.png` | `cg_romance_wedding_gap_jiyeon` | 1280x800 | no | `cfc057f42309` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/wedding_morning_daeun_v1.png` | `cg_romance_wedding_morning_daeun` | 1280x800 | no | `2ef8ad7e7552` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/romance/wedding_morning_jiyeon_v1.png` | `cg_romance_wedding_morning_jiyeon` | 1280x800 | no | `a6407b70c350` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/seollal_sebae_family_v1.png` | `cg_seollal_sebae_family` | 1280x800 | no | `35aa01cae632` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/start.png` | `cg_start` | 1280x720 | no | `ad731564a6fe` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| Portrait | `assets/characters/main_character_cold_snap.png` | `player_cold_snap` | 512x768 | yes | `360c41abe06e` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_corporate.png` | `player_corporate`, `player_suit` | 512x768 | yes | `6227f9bca2fd` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_determined.png` | `player_determined`, `player_moral_black` | 512x768 | yes | `60bb8ad42d3d` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_happy.png` | `player_happy`, `player_moral_white` | 512x768 | yes | `a27c702ee031` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_heatwave.png` | `player_heatwave` | 512x768 | yes | `a56eaa417459` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_monsoon.png` | `player_monsoon` | 512x768 | yes | `d0eefc17bbce` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_neutral_goshiwon.png` | `player_moral_gray`, `player_normal`, `player_offduty_neutral` | 512x768 | yes | `9080eb3a812d` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_office.png` | `player_office` | 512x768 | yes | `8ed1dd5e17f2` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_part_time.png` | `player_part_time` | 512x768 | yes | `75fe48972ea7` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_shocked.png` | `player_shocked` | 512x768 | yes | `1253c6e5204e` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_tired.png` | `player_hollow`, `player_sad`, `player_tired` | 512x768 | yes | `4a5980b1497b` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_unemployed.png` | `player_romance_casual`, `player_unemployed` | 512x768 | yes | `cb6f640c2d92` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_boss.png` | `sangchul_normal` | 512x768 | yes | `33348d66a94c` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_cafe_broker_kim.png` | `cafe_broker_kim` | 512x768 | yes | `68ffd6b2068c` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_cafe_investor.png` | `cafe_investor` | 512x768 | yes | `e1da7d0bfb81` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_close_friend.png` | `hyunsu`, `hyunsu_normal` | 512x768 | yes | `9bcef117393e` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_amusement.png` | `daeun_amusement` | 512x768 | yes | `e3aa8ca6922b` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_cherry.png` | `daeun_cherry` | 512x768 | yes | `b2ba0a209f30` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_fireworks.png` | `daeun_fireworks` | 512x768 | yes | `6c361beddc48` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_first_snow.png` | `daeun_first_snow` | 512x768 | yes | `7bbf4fa470a2` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_hometown_warm.png` | `daeun_hometown_warm` | 512x768 | yes | `94795d54ea43` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_hometown_worried.png` | `daeun_hometown_worried` | 512x768 | yes | `635ba1882608` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_namsan.png` | `daeun_namsan` | 512x768 | yes | `bfac0b7f75b0` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_proposal.png` | `daeun_proposal` | 512x768 | yes | `b6a9563b240b` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_sad.png` | `daeun_sad` | 512x768 | yes | `fd17a68a8110` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_sea_v2.png` | `daeun_sea` | 512x768 | yes | `ca33b0f7a63b` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_smile.png` | `daeun_smile` | 512x768 | yes | `4b2a7a626482` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_daeun_wedding_night.png` | `daeun_wedding_night` | 512x768 | yes | `311a9a02444a` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_father.png` | `father_normal`, `father_proud` | 512x768 | yes | `a7c592cba2c8` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_father_weak.png` | `father_weak` | 512x768 | yes | `a90451dde6bc` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_goshiwon_owner.png` | `goshiwon_owner` | 512x768 | yes | `0c8657261a92` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_hyunsu_accounting.png` | `hyunsu_accounting` | 512x768 | yes | `f7e8db534c04` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_hyunsu_civil_service.png` | `hyunsu_civil_service` | 512x768 | yes | `f065573d0092` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jaehyuk.png` | `jaehyuk_charisma`, `jaehyuk_cornered`, `jaehyuk_friendly` | 512x768 | yes | `94ba32553013` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jaehyuk_shadow.png` | `jaehyuk_shadow` | 512x768 | yes | `cb28436a0a03` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_amusement.png` | `jiyeon_amusement` | 512x768 | yes | `c4b783d88992` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_cherry.png` | `jiyeon_cherry` | 512x768 | yes | `257625b00998` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_cold.png` | `jiyeon_cold` | 512x768 | yes | `55aee896a744` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_fireworks.png` | `jiyeon_fireworks` | 512x768 | yes | `fbd1a99d07ae` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_first_snow.png` | `jiyeon_first_snow` | 512x768 | yes | `cc52884a6d99` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_namsan.png` | `jiyeon_namsan` | 512x768 | yes | `a43d2d0a31ee` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_narrow_door.png` | `jiyeon_narrow_door` | 512x768 | yes | `29c7b2e96459` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_narrow_room.png` | `jiyeon_narrow_room` | 512x768 | yes | `017cf4b1161d` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_sea_v2.png` | `jiyeon_sea` | 512x768 | yes | `9543a813ef2b` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_warm.png` | `jiyeon_warm` | 512x768 | yes | `9d09b4c52ccc` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_jiyeon_wedding_night.png` | `jiyeon_wedding_night` | 512x768 | yes | `befbef49d00a` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_mentor.png` | `jiyeon_normal` | 512x768 | yes | `d0b0fd4c0956` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_minseo.png` | `minseo`, `minseo_normal` | 512x768 | yes | `3f402386bae0` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_mother.png` | `mother` | 512x768 | yes | `c84b6204b4b9` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_romantic_interest.png` | `daeun_normal` | 512x768 | yes | `f79d2c89dafb` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_sangchul_serious.png` | `sangchul_serious` | 512x768 | yes | `6cd4c705e3c1` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_seongjun.png` | `seongjun` | 512x768 | yes | `2cab47234ec6` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_team_lead.png` | `boss` | 512x768 | yes | `2abc6ffd61c2` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_tip_seller.png` | `tip_seller` | 512x768 | yes | `761d08cf8b2a` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Background | `assets/backgrounds/amusement_park_parade_day.png` | `amusement_park_parade` | 1280x800 | no | `d7077312283e` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/amusement_photo_booth_evening.png` | `amusement_photo_booth` | 1280x800 | no | `b343c106c888` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/amusement_roller_coaster_day.png` | `amusement_roller_coaster` | 1280x800 | no | `9629d6993f4b` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/aruba_delivery_street.png` | `aruba_delivery` | 1280x800 | no | `82f9531e9aff` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/burnout_hospital_room.png` | `burnout` | 1280x800 | no | `958398df156a` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/cafe_seoul.png` | `cafe` | 1280x800 | no | `a8e34c6e5f11` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/casino_interior.png` | `casino` | 1280x800 | no | `b8a8b18fa8fc` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/cherry_blossom_path.png` | `cherry_blossom_path` | 1672x941 | no | `a721f10fb5a7` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/chuseok_highway.png` | `chuseok_highway` | 1672x941 | no | `4ac567c34bdb` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/community_center.png` | `community_center` | 1672x941 | no | `220622b0f60b` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/company_dinner_restaurant.png` | `company_dinner_restaurant` | 1672x941 | no | `9471dbec617d` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/convenience_store_exterior_first_snow.png` | `convenience_first_snow_exterior` | 1280x800 | no | `40bff4511687` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/convenience_store_night_v2.png` | `convenience_night`, `convenience_store` | 1280x800 | no | `b0d81368510f` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/daeun_mother_home_dining_summer.png` | `daeun_mother_home_dining` | 1280x800 | no | `e7e916f7292f` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/daeun_newlywed_home_night.png` | `daeun_newlywed_home` | 1280x800 | no | `92fd4356827a` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/family_living_room.png` | `dad_house` | 1280x800 | no | `f9e2325b10f6` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/fine_dust_sky.png` | `fine_dust_sky` | 1672x941 | no | `760852144b1a` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/gangnam_apartment.png` | `gangnam_apartment` | 1280x800 | no | `8457faa568e9` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/gangnam_day.png` | `gangnam_day` | 1280x800 | no | `602f13f63566` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/gangnam_night_street.png` | `gangnam_night` | 1280x800 | no | `1aa140c6abe8` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/gangnam_station_exit.png` | `gangnam_station` | 1280x800 | no | `76b8b9f30054` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/goshiwon_hallway.png` | `goshiwon_hallway` | 1280x800 | no | `76961efc3908` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/goshiwon_room.png` | `goshiwon`, `goshiwon_room` | 1280x800 | no | `10caf8f946cd` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/gym_interior.png` | `exercise`, `gym` | 1280x800 | no | `0a35a04d00b8` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hagwon_street.png` | `hagwon_street` | 1672x941 | no | `e3700c446b37` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hangang_riverside_walk.png` | `hangang_riverside` | 1280x800 | no | `a33579563891` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/heatwave_city.png` | `heatwave_city` | 1672x941 | no | `f1bd780a20d9` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/holdem_club_interior.png` | `holdem_club` | 1280x800 | no | `88906def8eb0` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hometown_train_station.png` | `hometown_train_station` | 1280x800 | no | `23055ac86c5b` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hospital_clinic.png` | `hospital_clinic` | 1280x800 | no | `b3bf477bde01` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hospital_corridor.png` | `hospital` | 1280x800 | no | `093c49491ff5` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/investment_meeting.png` | `meeting` | 1280x800 | no | `be5850434ab5` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/investment_phone.png` | `investment`, `investment_phone`, `trading` | 1280x800 | no | `aab6cac64486` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jeongseon_casino_entrance.png` | `jeongseon_casino_entrance` | 1280x800 | no | `f6f89679781e` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jeongseon_casino_exterior.png` | `jeongseon_casino_exterior` | 1280x800 | no | `9a75a100f407` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jiyeon_newlywed_home_night.png` | `jiyeon_newlywed_home` | 1280x800 | no | `12d80a5fd425` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jiyeon_sedan_first_snow_interior.png` | `jiyeon_sedan_first_snow` | 1280x800 | no | `7c94031a0536` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jjimjilbang.png` | `jjimjilbang` | 1672x941 | no | `bfc44b61d4c4` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/late_night_room.png` | `late_night` | 1280x800 | no | `0555c89b0480` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/library.png` | `library` | 1280x800 | no | `481604b1b302` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/military_base_gate.png` | `military_base_gate` | 1672x941 | no | `2953edc1022e` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/military_training_ground.png` | `military` | 1280x800 | no | `2b0b094c0068` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/namsan_cable_car_night.png` | `namsan_cable_car` | 1280x800 | no | `e1b2e1060d24` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/namsan_observation_deck_night.png` | `namsan_observation_deck` | 1280x800 | no | `06cc636a9026` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/namsan_tonkatsu_restaurant_night.png` | `namsan_tonkatsu_restaurant` | 1280x800 | no | `2aa09e3a4d0f` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/namsan_tower_view.png` | `namsan_tower` | 1280x800 | no | `c2a359611d16` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/office_desk.png` | `office` | 1280x800 | no | `aee5532e04e8` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/office_interview_day.png` | `office_interview_day` | 1280x800 | no | `cb0fd6d1bbe6` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/oneroom_apartment.png` | `apartment`, `apartment_balcony` | 1280x800 | no | `02ad719e013e` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/open_chat_screen.png` | `open_chat_screen` | 1672x941 | no | `0bef20ba2bdd` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/pc_bang_interior.png` | `pc_bang` | 1280x800 | no | `952b5aece3f5` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/penthouse_view.png` | `gangnam_penthouse`, `penthouse` | 1280x800 | no | `9f60451b3797` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/pojangmacha.png` | `pojangmacha` | 1280x800 | no | `1153cf3405a8` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/racetrack_betting_hall.png` | `racetrack_betting` | 1280x800 | no | `f9c63951e221` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/racetrack_track_view.png` | `racetrack_track` | 1280x800 | no | `c227e7e5b95d` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/realestate_office.png` | `realestate_office` | 1280x800 | no | `6812946f1d84` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/regional_train_window_summer.png` | `ktx_window`, `regional_train_window` | 1280x800 | no | `72b77ff89bdb` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/restaurant_korean.png` | `restaurant` | 1280x800 | no | `6bfbb44882d4` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/rooftop_daytime.png` | `rooftop_day` | 1280x800 | no | `dae74239d78c` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/rooftop_night.png` | `rooftop_night` | 1280x800 | no | `4afecc8f14ce` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/saju_cafe.png` | `saju_cafe` | 1672x941 | no | `f7a1ec7fbcd1` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/sangchul_private_dining.png` | `sangchul_private_dining` | 1280x800 | no | `101f90adb67f` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/scalping_trading_room.png` | `scalping_room` | 1280x800 | no | `bdc205e3ad1b` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/seoul_bus_stop_wallet.png` | `street_rainy_bus_stop_wallet` | 1280x800 | no | `445ce4fce87c` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/seoul_bus_terminal_night.png` | `seoul_bus_terminal_night` | 1280x800 | no | `4d0fdbd04d29` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/seoul_cold_snap_street.png` | `cold_snap_street` | 1280x800 | no | `9864aa265d41` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/seoul_rainy_street.png` | `street_rainy` | 1280x800 | no | `6b4909a89eb3` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/seoul_subway.png` | `subway` | 1280x800 | no | `e0dee873fcdf` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/street_seoul_day.png` | `street`, `street_day` | 1280x800 | no | `c7730fce4f73` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/suneung_test_hall.png` | `suneung_test_hall` | 1672x941 | no | `4b72655552ff` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/trading_screen_night.png` | `trading_room` | 1280x800 | no | `9bebd361a8e1` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/winter_bungeoppang_stall.png` | `winter_street_bungeoppang` | 1280x800 | no | `ff57cae9f68a` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/year2_winter_last_night.png` | `year2_winter_street_night` | 1280x800 | no | `f9f019f44357` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/year3_hangang_winter_night.png` | `year3_hangang_winter_night` | 1280x800 | no | `b8387ccb4707` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/year4_winter_rooftop.png` | `year4_winter_rooftop` | 1280x800 | no | `46803837d191` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |

Inventory: 54 CG / 54 portraits / 75 backgrounds / 183 total.

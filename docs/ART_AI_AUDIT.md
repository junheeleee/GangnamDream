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

- 활성 인벤토리: **256장** (`CG 75 / Portrait 92 / Background 89`). 세 레지스트리의 중복 ID는 같은 파일 한 번으로 집계했다.
- 전수 방법: 종류별 콘택트시트 24장으로 얼굴·실루엣·그레이딩·공간을 1차 비교하고, 손·반사·차량·카운터·정류장처럼 오독 위험이 있는 컷과 키 비주얼 10장은 원본 해상도로 다시 열었다.
- 런타임 수리: 배경이 구워진 `main_character_50s.png`를 본편의 `player_hollow` 슬롯에서 제외하고 같은 민준의 투명 피로 초상으로 통합했다. 현재 이벤트가 없는 박재원의 죽은 초상 등록도 제거했다.
- 이미지 수리: `ending_crypto_ghost.png`의 비현실적인 6면 모니터 벽을 정본 고시원 안의 휴대폰 1대·낡은 노트북 1대로 교체했다. 방 크기, 작은 불투명창, 침대/책상 방향, 민준 신원, 다섯 손가락, 무문자 차트를 원본에서 재검수했다.
- 아버지 의상 정합: 작업복 하나를 집·병원·통화에 돌려 쓰지 않는다. 같은 얼굴을 작업/외출, 세대감 있는 집 생활복, 쇠약 생활복, 입원 환자복으로 분리하고 피부색·투명 가장자리·의상 장소 계약을 원본 해상도에서 재검수했다.
- 1·3·5년 외형 정합: 민준·다은·지연·현수·재혁·상철·아버지의 32개 `y3`/`y5` 초상을 중립/표정 콘택트시트와 1280x800 한국어·960x600 영어 실제 StoryMode 프레임으로 비교했다. 얼굴·헤어·체형·대표 복식은 같은 사람으로 유지되고, 시간 차이는 자세·눈의 피로·정돈 정도로만 읽힌다. 병원·결혼·계절·2020년 아버지 회상 초상은 자동 교체되지 않는다.
- 안정적인 성공 엔딩: `ending_stable_success_v1.png`를 원본과 1280x800 실제 엔딩 모달에서 재검수했다. 38세 민준, 소형 서울 집, 뒤집힌 휴대폰 한 대, 안도하는 비렌즈 시선, 비강남·비럭셔리 공간, 손·창·침대 원근과 중앙 크롭을 확인했다.
- 특별 정합: 사고 컷은 검은 장축 세단·한국식 왼쪽 운전석·운전석 문·자전거 두 바퀴를 유지한다. 정류장은 카메라가 벤치 등받이 뒤를 보며 좌석이 도로를 향한다. 편의점 CG는 다은이 카운터 안, 민준이 출입문 쪽에 있다. 다은 결혼식 9종은 한 프레임에 가족 상태를 과적하지 않고 `다은 어머니 반응 1 → 신랑석 상태 4 → 커플 와이드 2 → 커플 근접 2`로 분리한다. 어머니는 혼주 한복과 딸을 향한 시선, 아버지는 혼주 정장과 통로를 향한 시선, 별세 경로는 완전히 빈 예약석, 현수 재회 경로는 배우자·아이 없는 현수 단독을 지킨다. 커플 컷의 식별 인물은 민준·다은뿐이며 민준 선입장/다은 후입장·소형/풀 의상·상호 시선을 유지한다.
- 글자 게이트: 전경 핵심 소품에는 판독을 요구하는 AI 글자가 없다. 투자 차트·포장지·책등의 작은 표식은 언어처럼 읽히지 않는 비서사 질감이며, 실제 UI 카피를 대신하지 않는다.
- 최종 판정: **FAIL 0 / PENDING 0**. 비활성 원화는 향후 다시 등록할 때 새 감사 대상이 된다.

### M01-M06 독립 선택판 UI 장면

아래 9장은 `ImageRegistry` 출시 인벤토리 250장에는 포함하지 않는 독립 체험판
직접 로드 자산이다. 원본 해상도와 KO/EN 960x600·1280x800 실제 카드 크롭을
별도로 확인했다. 선택 전 표면이므로 인물, 판독 문자, 상표, 합격/거절, 계약 완료,
통화 응답, 미래 관계 결과가 없는지를 `PASS-S` 기준으로 판정했다.

| Asset | Size | Hash | Result | Evidence |
|---|---:|---|:---:|---|
| `assets/ui/m1m6_promises/survival_shift.png` | 1536x640 | `6a30225fa029` | PASS-S | 무인 서비스 카운터·앞치마·기록지·영수 프린터만 있고 고용주·임금·성과가 없다. |
| `assets/ui/m1m6_promises/father_call.png` | 1536x640 | `152b1c1398a4` | PASS-S | 정본 고시원 방향, 휴대폰 1대, 무응답·질환·화자 선취 0. |
| `assets/ui/m1m6_promises/account_risk.png` | 1536x640 | `ecaef851aac9` | PASS-S | 무문자 서류·봉투·계산기·꺼진 휴대폰만 있고 잔액·승인·거래 화면이 없다. |
| `assets/ui/m1m6_promises/job_result_notice.png` | 1536x640 | `c412ebc82981` | PASS-S | 창·스카이라인 없는 고시원 호환 책상에 중립 알림광·닫힌 지원 폴더만 있고 합격/거절 색·기호·직장이 없다. |
| `assets/ui/m1m6_promises/family_signal.png` | 1536x640 | `f65e06106852` | PASS-S | 정본 고시원 방향, 휴대폰·접힌 무문자 약봉지 1개, 진단·사망·응답 선취 0. |
| `assets/ui/m1m6_promises/room_viewing.png` | 1536x1024 | `6b15ee9304b4` | PASS-S | 낡은 빈 방·줄자·열쇠만 있고 계약·입주·주거 성공이 없다. |
| `assets/ui/m1m6_promises/livelihood_next.png` | 1536x1024 | `ad495cd2d2b8` | PASS-S | 무인 직원 통로·작업화·빈 보드·폴더만 있고 채용·복귀 결과가 없다. |
| `assets/ui/m1m6_promises/work_deadline.png` | 1536x1024 | `6ea9fa5cf911` | PASS-S | 무문자 봉투·무눈금 시계·카드·펜만 있고 제출 결과가 없다. |
| `assets/ui/m1m6_promises/sangchul_field_door.png` | 1536x1024 | `28eb6c9dbeee` | PASS-S | 무인 현장 입구·흐린 쪽지·장갑만 있고 만남·거래·위험 결과가 없다. |

프롬프트와 생성 원본은 `assets/IMAGE_PROMPTS.md`, 사용 범위와 재사용 금지는
`assets/ASSET_INDEX.md`가 소유한다. 체험판이 제품 경로로 승격되면 이 9장을
출시 인벤토리와 해시 게이트에 편입해 다시 감사한다.

서로 다른 생성 배치의 표면 차이는 카드 런타임의 공통
`gangnam_ink_card_v1` 그레이드로 정리한다. 이는 명도·채도·종이 결·잉크 번짐만
통일하며 장면의 인물·문자·결과 정보를 새로 만들지 않는다.

### 이번 수리 이력

- 모드: OpenAI 내장 ImageGen 이미지 편집.
- 입력 참조: 이전 `ending_crypto_ghost.png`, 정본 `goshiwon_room.png`, 투명 `main_character_tired.png`.
- 최종 프롬프트: “정본 고시원 구조와 동일한 좁은 방, 동일한 33세 민준, 휴대폰 1대와 낡은 노트북 1대만 있는 코인 손실 후 장면. 모니터 벽·추가 화면·텍스트·로고를 제거하고, 자연스러운 다섯 손가락과 휴대폰/노트북을 향한 시선, Gangnam Ink 반사실 애니메이션 질감을 유지한다.”
- 생성 원본: `$HOME/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-6a8364f4-5f1f-4b68-b5b3-d1ee3f35bf20.png`.
- 출시 경로: `assets/cg/ending_crypto_ghost.png` (중앙 16:10 크롭 후 1280x800).

### Chapter 5 저작 장소·시간 배경

- 모드: OpenAI 내장 ImageGen 생성/참조 편집. `hospital_clinic_day`는 기존 야간 외래 진료실의 구조를 보존해 오전광으로 교정했고, 나머지 다섯 장소는 사건별 기능 구조와 Gangnam Ink 표면을 고정해 생성했다.
- 출시 경로: `assets/backgrounds/{hospital_clinic_day,subway_station_stairs,subway_station_lost_found,hanjeongsik_restaurant_day,concert_hall_night,villa_renovation_day}.png` (각 1280x800).
- 검수: 오전 외래 진료실, 역 계단·개찰구, 역무실·분실물 접수대, 토요일 낮 한정식 2인석, 무상표 야간 콘서트 홀, 화곡동 노후 빌라 보수 현장의 시간·동선·가구/설비·무문자·무주연 대역·UI 크롭을 원본 해상도에서 확인했다. 콘서트 홀의 관객과 무대 인물은 식별 불가능한 C-tier 공공장소 질감만 허용했다.
- 등급 한계: 생성 원본은 P1 반복 배경의 2560x1600 중간 마스터 계약보다 작다. 현재 파일은 B+/`PASS-B` 런타임 후보이며 A급 또는 출시 마스터가 아니다.

### 아버지 별세 공간 분리 배경

- 모드: OpenAI 내장 ImageGen 신규 생성. 기존 `hospital_corridor.png`와 `regional_train_window_summer.png`는 화풍 참조로만 사용했다.
- 공통 프롬프트 축: 확정된 `STYLE_SUMMARY`와 Gangnam Ink 가이드, 반사실 한국 만화형 디지털 페인팅, 저채도 차콜·슬레이트, 절제된 실용광, 무인 재사용 배경, 무상표·무문자·1280x800 안전 구도.
- 생성 원본: `$HOME/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-999b0bbe-fd05-4554-a394-679852313c2c.png`, `$HOME/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-3f31fb84-10d9-408b-ba71-d0284ac25493.png`.
- 출시 경로: `assets/backgrounds/seoul_station_ktx_platform_winter.png`, `assets/backgrounds/changwon_hospital_room_empty.png` (중앙 16:10 크롭 후 1280x800).

### 지연 첫 키스 무인 세단 배경

- 모드: OpenAI 내장 ImageGen 편집. 정본 `first_kiss_jiyeon.png`의 두 인물만 제거하고 차체 시점과 실내 구조를 보존했다.
- 출시 경로: `assets/backgrounds/jiyeon_sedan_night_interior.png` (1280x800).
- 검수: 왼쪽 운전대·검은 가죽·수평 대시보드·동일 차급, 인물/반사/상표/문자 부재, CG 전후 KO/EN 게임 크롭을 확인했다.

### 현수 재회 전용 국밥집 배경

- 모드: OpenAI 내장 ImageGen 편집. 기존 `restaurant_korean.png`는 화풍과 실내 밀도만 참조하고 고깃집 구조는 계승하지 않았다.
- 생성 원본: `$HOME/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-d9718f8d-5cc7-4b24-b31d-8da461d7cb04.png`.
- 출시 경로: `assets/backgrounds/gukbap_restaurant_night.png` (1280x800).
- 검수: 전경 빈 두 사람 식탁·금속 물컵 2개·수저통, 열린 탕 주방, 젖은 옛 고시원 골목, 무그릴·무고기·무음식·무상표·무문자·무주연 대역을 원본 해상도에서 확인했다. 배경 손님은 저대비 익명 인물로만 남는다.

### 데모 생계 authored 백필 배경

- 모드: OpenAI 내장 ImageGen 신규 생성 2건과 이삿짐 배경 계절·수량 정합 편집.
- 신규 생성 프롬프트 축: Gangnam Ink 저채도 한국 VN/만화 현실감, 무인 재사용 장소, 무상표·무문자, 1280x800 하단 대화 안전영역. 야간 재고조사는 선반·상자·핸드카트·바코드 스캐너가 실제 동선으로 이어지는 형광등 창고, 이삿짐 대타는 소형 트럭·적재함·램프·현관·손수레가 작동하는 서울 주거 골목을 요구했다.
- 생성 원본: `$HOME/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-20e914c5-f9f1-40f0-9858-4d3323ea8c0b.png`, `$HOME/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-26ea5f3b-4a79-4b1d-91d2-8671d6ef3e58.png`.
- 계절 수리 프롬프트: “트럭·램프·현관·상자·담요·손수레·카메라와 하단 여백은 유지하고, 잎 없는 식생만 서울 5월의 절제된 회녹색 잎과 늦봄 해질녘으로 바꾼다. 인물·문자·상표·새 물체는 추가하지 않는다.” 이후 외부 대기 상자가 산문의 여섯 개와 정확히 맞도록 한 개 추가와 한 개 제거를 각각 단일 변경으로 수행했다.
- 편집 원본: `$HOME/.codex/generated_images/019fc52b-842a-7ab0-b34d-eef40762a296/exec-0d2b3a58-2abf-47c7-be24-018134c5c34e.png`, `$HOME/.codex/generated_images/019fc52b-842a-7ab0-b34d-eef40762a296/exec-db098ba6-5e76-483e-87f7-cb2b15bdd656.png`, 최종 `$HOME/.codex/generated_images/019fc52b-842a-7ab0-b34d-eef40762a296/exec-21e91576-9470-40be-9b16-1c2a45f7aa30.png`.
- 출시 경로: `assets/backgrounds/warehouse_inventory_night.png`, `assets/backgrounds/moving_truck_loading_dusk.png` (1280x800).
- 검수: 창고는 선반·핸드카트·스캐너·셔터/출입문 원근과 무인·무문자·하단 안전영역을 확인했다. 이삿짐은 5월 식생, 외부 대기 상자 정확히 6개, 적재함 안의 기적재 상자, 접힌 담요, 트럭 램프·현관·손수레·도로/보도 동선, 무인·무상표·무문자와 하단 안전영역을 확인했다.

### 24주 첫 결산 전용 배경·연기 초상

- 모드: OpenAI 내장 ImageGen 신규 생성 2건. 원 호출 프롬프트 기록이
  유실되어 `assets/IMAGE_PROMPTS.md`에는 결과물·정본·참조 입력에서
  복원한 재현 프롬프트로 명시했다. 정확한 원문으로 취급하지 않으며,
  민준 나이는 2026년 시작 정본인 33세로 정합성 교정했다.
- 배경 생성 원본: `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-25d687d2-d0bf-46c0-89d0-0c3712e485b9.png`
  (1586x992 RGB, SHA-256 `c33af17a136820a8bc3547d97902ab660ade010c7056be927477ea1964acd3f0`).
  최초 후처리본은 은행 앱을 열었다는 산문과 달리 휴대폰 화면이
  완전히 꺼져 있어 정합 검수에서 폐기했다.
- 배경 교정 원본: `/Users/junheelee/.codex/generated_images/019fc841-af3c-7442-b2bc-971d6c553cd4/exec-62dbbbde-2fcb-4d0b-ad41-fe4c59f9523b.png`
  (1586x992 RGB, SHA-256 `3d9db6b4b24e3c24196da86eb35b4fa62bb4dadefcb4a1bb2119ecc742b42312`).
  원 배경을 정밀 편집 대상으로 삼아 단일 휴대폰 화면만 아주 어두운
  무상표·무문자 모바일 뱅킹 상태로 켰다. 교정 원본을 1280x800 RGB로
  리사이즈했으며 전체 편집 프롬프트는 `assets/IMAGE_PROMPTS.md`에 보관한다.
- 초상 생성 원본: `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-8c08e2c4-ac4b-448b-a61d-7ee283bc5bc9.png`
  (1024x1536 RGB, SHA-256 `334475989c71bde8be8390ee6cc736773955b3b199a20053ce9ef02f87d00d14`).
  단색 마젠타 크로마를 제거하고 512x768 RGBA로 리사이즈했다.
- 출시 경로/해시: `assets/backgrounds/v2_first_bill_desk_closeup.png`
  `bddf7fe462c6b46ab4b9a7d1ff3d02225e59c1e18c61ea2d291c02d03344883b`,
  `assets/characters/main_character_first_bill_decision.png`
  `3a0a0dc3ea0ca92964aba4f3de245313ef40d96957fbf55b39af4166da648339`.
- 시각 검수: 배경은 정본 고시원의 왼쪽 침대·낮은 책상·검은 스탠드·오른쪽
  스위치를 유지하고, 휴대폰·펼친 수첩·펜·영수증·물컵이 중복 없이
  물리적으로 연결된다. 휴대폰은 낮은 청회색 빛으로 켜져 있어 은행 앱 상태가
  읽히지만 실제 앱 UI·잔액·숫자·문자·은행명·상표는 판독되지 않는다. 하단 30%는
  대사 안전 영역으로 남았다. 초상은 정본 33세 민준의 얼굴·검은 크루넥·마른
  체형을 유지하고 수첩 방향 하향 시선·다문 입·읽히는 어깨로 영웅적 결의,
  분노, 악역 눈빛, 붕괴를 피했으며 투명 가장자리와 실제 게임 크롭을 확인했다.
- 실행 검수: Godot 4.6.2 전용 `core-loop-v2` ScreenshotQA로 한국어
  960x600과 영어 1280x800에서 opening, 세 후보별 decision, 세 ledger 상태,
  편의점 choice 3 및 창고 choice 6 결과를 실제 StoryMode 프레임으로 출력했다.
  신규 배경 cover 크롭과 투명 초상 합성에는 잘림·겹침이 없었고, 영어 창고
  결과의 금액 배지도 `+KRW 280K`로 줄여 최종 재렌더에서 잘림 없이 통과했다.
  이 전용 렌더는 전체 24주 `demo-experience` 완주가 아니다. 해당 입력 자동화는
  Week 1 V2 planner에서 멈추므로 별도 열린 게이트로 기록한다.

### 4월 주거복지 상담사 초상

- 모드: OpenAI 내장 ImageGen 신규 생성. 전체 프롬프트와 금지 조건은
  `assets/IMAGE_PROMPTS.md`에 보관한다.
- 생성 원본: `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-3d90daf2-2cf3-459f-a420-80f06add1f73.png`.
- 출시 경로/해시: `assets/characters/npc_housing_counselor.png`
  `47fa4926baa149933ddf824fc908976f5405dfafcaeed118a76ebe398c65779d`
  (1023x1537 RGBA). 단색 녹색 크로마를 소프트 매트·디스필·1px 가장자리
  수축으로 제거했고, 인물 내부의 종이·펜·명찰은 불투명하게 보존했다.
- 원본 검수: 49세 한국인 여성, 짙은 남색 카디건과 무지 목걸이 명찰, 종이와
  펜을 든 두 손, 상담 상대를 향한 차분한 시선, 무문자·무상표·투명 가장자리를
  원본 해상도로 확인했다.
- 실행 검수: Godot 4.6.2 전용 `core-loop-v2` ScreenshotQA로 한국어 960x600과
  영어 1280x800의 선택·결과 프레임을 출력했다. 주민센터 배경과의 크기·광원,
  이름표, 의도적 우측 bleed, 선택지 안전영역, 영어 최장 선택지 줄바꿈에서
  잘림·녹색 테두리·종이/손 겹침이 없음을 확인했다.

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
| White 엔딩 | `assets/cg/ending_gangnam_dream_white_v2.png` | REPAIRED-A | 불가능한 유리 반사를 제거했다. 맑은 오전, 38세 민준, 등기 폴더, 도시를 향한 비렌즈 시선과 단일 신체를 확인했다. |
| Full Circle 엔딩 | `assets/cg/ending_full_circle_v1.png` | PASS-A | 전화 손, 이삿짐 1개, 아버지 비등장, 맑은 오전 크롭 통과. |
| 지연 엔딩 | `assets/cg/ending_jiyeon_man_v2.png` | PASS-A | 두 인물 모두 거울 안에만 한 번 등장하며 중복 몸·역반사 없음. |
| 다은 엔딩 | `assets/cg/ending_with_daeun_v1.png` | PASS-A | 라면/물 정확히 2인분, 상호 시선, 가까운 손, 작은 집의 존엄 통과. |
| 안정적인 성공 엔딩 | `assets/cg/ending_stable_success_v1.png` | PASS-A | 38세 민준·소형 서울 집·뒤집힌 휴대폰 1대·조용한 안도·비럭셔리 공간과 실제 엔딩 크롭 통과. |

## 전수 판정표

| Kind | Asset | Registry IDs | Raster | Alpha | Hash | Verdict | Review |
|---|---|---|---:|:---:|:---:|:---:|---|
| CG | `assets/cg/demo/daeun_first_kindness_v2.png` | `cg_demo_daeun_first_kindness` | 1280x800 | no | `f3e0f629c069` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/demo/father_first_call_v1.png` | `cg_demo_father_first_call` | 1280x800 | no | `974db28ea9ac` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/demo/first_interview_v1.png` | `cg_demo_first_interview` | 1280x800 | no | `47f49936c3b9` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_balanced_life_v1.png` | `cg_ending_balanced_life` | 1280x800 | no | `3bdee2ac4c5d` | PASS-A | 집 식탁의 주간 수첩·닫힌 노트북·퇴근 가방·한 끼가 서로 겹치지 않고, 펜 손과 비렌즈 시선을 확인했다. |
| CG | `assets/cg/ending_bankruptcy_v2.png` | `cg_ending_bankruptcy` | 1280x800 | no | `ed941d84cb69` | REPAIRED-A | 계산기와 추심 전화 거절 동작을 분리하고, 정본 고시원 구조·양손·통화 화면 무문자·하단 안전 크롭을 확인했다. |
| CG | `assets/cg/ending_burnout_v1.png` | `cg_ending_burnout` | 1280x800 | no | `cc9cfdcbf19b` | PASS-A | 1인칭 침상 시점, 한 손·다섯 손가락, 테이프 고정 캐뉼라와 연결된 링거, 닿지 않은 뒤집힌 휴대폰, 형광등·커튼·침상 축을 확인했다. |
| CG | `assets/cg/ending_career_burnout_v1.png` | `cg_ending_career_burnout` | 1280x800 | no | `5ecf981c5271` | PASS-A | 종점 버스 출구, 일어서는 자세, 좌석 지지 손·휴대폰 손, 젖은 터미널 동선과 비렌즈 시선을 확인했다. |
| CG | `assets/cg/ending_career_climber_v1.png` | `cg_ending_career_climber` | 1280x800 | no | `ea4ee81ecc56` | PASS-A | 기업 로비, 전화와 제안 봉투 손, 유리면 자기 시선이라는 카메라 근거, 타인 실루엣·개찰 동선을 확인했다. |
| CG | `assets/cg/ending_creator_success_v1.png` | `cg_ending_creator_success` | 1280x800 | no | `988720cbdcfe` | PASS-A | 촬영 카메라 전원 손, 실재 카메라 렌즈를 향한 동기 있는 시선, 편집 화면·방음재·택배 소품의 무문자 상태를 확인했다. |
| CG | `assets/cg/ending_crypto_ghost.png` | `cg_ending_crypto_ghost` | 1280x800 | no | `31e42005c154` | REPAIRED-A | 모니터 벽 제거. 정본 고시원·휴대폰 1대·노트북 1대·민준 손/시선 확인. |
| CG | `assets/cg/ending_debt_spiral_v2.png` | `cg_ending_debt_spiral` | 1280x800 | no | `21ed7e971945` | REPAIRED-A | 정본 고시원 바닥에 주저앉은 자세, 무릎을 감싼 두 손, 테이블 위 추심 서류·닫힌 기기와 자해 없는 연출을 확인했다. |
| CG | `assets/cg/ending_early_retirement_v1.png` | `cg_ending_early_retirement` | 1280x800 | no | `3c027e77dc83` | PASS-A | 알람 없는 아침, 물줄기·드리퍼·서버가 연결된 양손 동작, 접은 출근 셔츠와 잠든 휴대폰을 확인했다. |
| CG | `assets/cg/ending_empty_house.png` | `cg_ending_empty_house` | 1280x800 | no | `d21de2b8eb78` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_father.png` | `cg_ending_father` | 1280x720 | no | `1987aa893662` | PASS-A | 병실 방문 사건용 CG이며 엔딩 35종에는 재사용하지 않는다. |
| CG | `assets/cg/ending_full_circle_v1.png` | `cg_ending_full_circle` | 1280x800 | no | `58bc9c644542` | PASS-A | 전화 손, 이삿짐 1개, 아버지 비등장, 맑은 오전 크롭 통과. |
| CG | `assets/cg/ending_gambling_recovery_v2.png` | `cg_ending_gambling_recovery` | 1280x800 | no | `3a8814ddf87c` | REPAIRED-A | 정본 고시원, 달력 동그라미를 닫는 마커 손, 상자 안에 치운 휴대폰, 식사와 비렌즈 옆얼굴을 확인했다. |
| CG | `assets/cg/ending_gangnam_dream.png` | `cg_ending_gangnam_dream` | 1280x800 | no | `ade2697c386b` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_gangnam_dream_white_v2.png` | `cg_ending_gangnam_dream_white` | 1280x800 | no | `bcdea4c07678` | REPAIRED-A | 불가능한 반사를 제거하고, 맑은 오전·등기 폴더·단일 신체·도시를 향한 시선과 열린 이삿짐 상자를 확인했다. |
| CG | `assets/cg/ending_guardian_v1.png` | `cg_ending_guardian` | 1280x800 | no | `738f36f22848` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_healthy_retirement_v1.png` | `cg_ending_healthy_retirement` | 1280x800 | no | `b3dd747f4325` | PASS-A | 한강 보행·자전거 동선, 운동복, 허리 손·수건 손, 숨을 고르며 강을 보는 비렌즈 시선을 확인했다. |
| CG | `assets/cg/ending_instant_legend_v1.png` | `cg_ending_instant_legend` | 1280x800 | no | `5519859a8a46` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_investment_master_v1.png` | `cg_ending_investment_master` | 1280x800 | no | `21963858daeb` | PASS-A | 노트와 노트북을 분리하고, 화면을 닫는 오른손·쉬는 왼손·기기를 보는 시선과 생활형 작업실을 확인했다. |
| CG | `assets/cg/ending_jaehyuk_way_v1.png` | `cg_ending_jaehyuk_way` | 1280x800 | no | `dd0b29858a63` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_jiyeon_man_v2.png` | `cg_ending_jiyeon_man` | 1280x800 | no | `62a7f17d4aec` | PASS-A | 두 인물 모두 거울 안에만 한 번 등장하며 중복 몸·역반사 없음. |
| CG | `assets/cg/ending_late_call_v1.png` | `cg_ending_late_call` | 1280x800 | no | `662ff3e36b30` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_lonely_rich_v1.png` | `cg_ending_lonely_rich` | 1280x800 | no | `91932fd75d7d` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_mental_break_v1.png` | `cg_ending_mental_break` | 1280x800 | no | `5c19a097cb32` | PASS-A | 상담실 낮빛, 깍지 낀 두 손, 아래로 떨어진 민준 시선, 기록 중인 상담자 손과 빈 메모지를 확인했다. |
| CG | `assets/cg/ending_ordinary_life_v1.png` | `cg_ending_ordinary_life` | 1280x800 | no | `85e8b626c905` | PASS-A | 비 오는 외곽 방, 한 그릇 라면, 내려놓기 전 휴대폰 손, 자기 방의 침대·창·조명 축을 확인했다. |
| CG | `assets/cg/ending_orthodox_hollow_v2.png` | `cg_ending_orthodox_hollow` | 1280x800 | no | `708587d8832d` | REPAIRED-A | 잘못된 38세 사무실 장면을 55세 플래시포워드 거실로 교체하고, 흰머리·닫힌 계좌 폴더·뒤집힌 휴대폰·도시 시선을 확인했다. |
| CG | `assets/cg/ending_orthodox_pinnacle_v1.png` | `cg_ending_orthodox_pinnacle` | 1280x800 | no | `e7b4396db619` | PASS-A | 민준과 후배의 얼굴·헤어·복식이 1초 안에 구분되고 시선은 후배→민준·민준→물잔으로 맞는다. |
| CG | `assets/cg/ending_political_fix_v1.png` | `cg_ending_political_fix` | 1280x800 | no | `53cb98f05b4f` | PASS-A | 의원 사무실 문턱, 닫힌 서류철 손, 복도 인물과 한강·여의도 방향, 비렌즈 시선을 확인했다. |
| CG | `assets/cg/ending_reputation_legend_v1.png` | `cg_ending_reputation_legend` | 1280x800 | no | `bde290c5272c` | PASS-A | 업계 행사에서 상대가 먼저 건네는 빈 명함, 상대→민준·민준→상대 시선과 구분되는 배경 인물을 확인했다. |
| CG | `assets/cg/ending_sangchul_reckoning_v1.png` | `cg_ending_sangchul_reckoning` | 1280x800 | no | `f25fbb0f1004` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_second_love_v1.png` | `cg_ending_second_love` | 1280x800 | no | `2b554360182d` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_stable_success_v1.png` | `cg_ending_stable_success` | 1280x800 | no | `40c622e0e9e5` | PASS-A | 38세 민준의 얼굴·양손·비렌즈 시선, 뒤집힌 휴대폰 1대, 비강남 소형 서울 집을 확인했다. |
| CG | `assets/cg/ending_startup_exit_v1.png` | `cg_ending_startup_exit` | 1280x800 | no | `be7c29d8d495` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/ending_unorthodox_legend_v1.png` | `cg_ending_unorthodox_legend` | 1280x800 | no | `a3d8d5cce51b` | PASS-A | 출근 인파와 교차하는 진행축, 수첩을 잡은 손·메신저백 손, 젖은 횡단보도와 비렌즈 시선을 확인했다. |
| CG | `assets/cg/ending_with_daeun_v1.png` | `cg_ending_with_daeun` | 1280x800 | no | `9c4af6de306d` | PASS-A | 라면/물 정확히 2인분, 상호 시선, 가까운 손, 작은 집의 존엄 통과. |
| CG | `assets/cg/ending_writer_v1.png` | `cg_ending_writer` | 1280x800 | no | `b8f6de4cadbc` | PASS-A | 정본 고시원 구조, 원고 위 손, 작은 창을 보는 38세 민준, 책·봉투·휴대폰의 무문자 상태를 확인했다. |
| CG | `assets/cg/jaehyuk_reveal.png` | `cg_jaehyuk_reveal` | 1280x800 | no | `18243d73b73f` | PASS-A | 원본 프레임의 손·눈·시선·동작·소품·안전 크롭 확인. |
| CG | `assets/cg/y5_three_in_room_v2.png` | `cg_y5_three_in_room` | 1280x800 | no | `d18a9c38300e` | PASS-A | 민준·다은·재혁·상철 신원·나이·시선, 다은의 무상표 차콜 재킷·청회색 블라우스, 별도 제안서/PDF/미서명 사본, 놓인 빨간 펜, 단일 계산기, 네 개 종이컵, 자연스러운 손·회의실 동선·하단 안전 크롭·무서명을 원본에서 확인. |
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
| Portrait | `assets/characters/main_character_first_bill_decision.png` | `player_first_bill_decision` | 512x768 | yes | `3a0a0dc3ea0c` | PASS-B | 33세 y1 민준·검은 크루넥·수첩 방향 하향 시선·절제된 결정 연기, 무소품 투명 분리와 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_happy.png` | `player_happy`, `player_moral_white` | 512x768 | yes | `a27c702ee031` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_heatwave.png` | `player_heatwave` | 512x768 | yes | `a56eaa417459` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_monsoon.png` | `player_monsoon` | 512x768 | yes | `d0eefc17bbce` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_neutral_goshiwon.png` | `player_moral_gray`, `player_normal`, `player_offduty_neutral` | 512x768 | yes | `9080eb3a812d` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_office.png` | `player_office` | 512x768 | yes | `8ed1dd5e17f2` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_part_time.png` | `player_part_time` | 512x768 | yes | `75fe48972ea7` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_shocked.png` | `player_shocked` | 512x768 | yes | `1253c6e5204e` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/main_character_tired.png` | `player_hollow`, `player_sad`, `player_tired` | 512x768 | yes | `8882315c4a63` | PASS-B | 동일 민준·검은 크루넥·투명 분리 유지. 두 눈을 분명히 뜬 하향 시선, 병색·충혈 없는 피로, 척추는 세우고 어깨만 이완한 실루엣을 원본과 실제 화면에서 확인. |
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
| Portrait | `assets/characters/npc_father_past.png` | `father_past` | 512x768 | yes | `07f2ea3cd19e` | PASS-B | 2020년 57세 상태. 현재 63세 정본과 얼굴·작업복을 유지하고 흰머리·깊은 주름만 줄였으며, 채무 굴욕 장면의 하향 시선과 투명 가장자리를 원본 및 실제 화면에서 확인. |
| Portrait | `assets/characters/npc_father_home.png` | `father_home` | 512x768 | yes | `4293759b1355` | PASS-B | 정본 얼굴·세대감 있는 생활복·정상 피부색·불투명 내부와 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_father_home_weak.png` | `father_home_weak` | 512x768 | yes | `acb090dd4689` | PASS-B | 동일 생활복·쇠약 연기·정상 피부색·녹색 가장자리 제거 확인. |
| Portrait | `assets/characters/npc_father_hospitalized.png` | `father_hospitalized` | 512x768 | yes | `558cfd71b022` | PASS-B | 정본 얼굴·청회색 환자복·병동 전용 의상·투명 분리 확인. |
| Portrait | `assets/characters/npc_father_weak.png` | `father_weak` | 512x768 | yes | `a90451dde6bc` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_goshiwon_owner.png` | `goshiwon_owner` | 512x768 | yes | `0c8657261a92` | PASS-B | 투명 분리·얼굴 정체성·의상 실루엣 확인. |
| Portrait | `assets/characters/npc_housing_counselor.png` | `housing_counselor` | 1023x1537 | yes | `47fa4926baa1` | PASS-B | 49세 주민센터 주거복지 상담사, 남색 카디건·무지 명찰·종이·펜·두 손·차분한 시선·투명 가장자리와 KO 960x600/EN 1280x800 게임 크롭 확인. |
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
| Portrait | `assets/characters/main_character_corporate_y3.png` | `player_corporate_y3` | 1024x1536 | yes | `de8f79f4892f` | PASS-B | 투명 분리·민준 정체성·중간 연차 정장/자세와 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_corporate_y5.png` | `player_corporate_y5` | 1024x1536 | yes | `75828e903919` | PASS-B | 투명 분리·민준 정체성·최종 연차 정장/자세와 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_office_y3.png` | `player_office_y3` | 1024x1536 | yes | `72c139076b44` | PASS-B | 투명 분리·민준 정체성·중간 연차 사무복과 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_office_y5.png` | `player_office_y5` | 1024x1536 | yes | `bb06a64fcecb` | PASS-B | 투명 분리·민준 정체성·최종 연차 사무복과 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_part_time_y3.png` | `player_part_time_y3` | 1024x1536 | yes | `a48fc4e8032d` | PASS-B | 투명 분리·민준 정체성·중간 연차 생존복과 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_part_time_y5.png` | `player_part_time_y5` | 1024x1536 | yes | `d0ee67bc3cfc` | PASS-B | 투명 분리·민준 정체성·최종 연차 생존복과 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_unemployed_y3.png` | `player_unemployed_y3` | 1024x1536 | yes | `9d9e6189a969` | PASS-B | 투명 분리·민준 정체성·중간 연차 피로/자세와 게임 크롭 확인. |
| Portrait | `assets/characters/main_character_unemployed_y5.png` | `player_unemployed_y5` | 1024x1536 | yes | `148e2d8d2712` | PASS-B | 투명 분리·민준 정체성·최종 연차 피로/자세와 게임 크롭 확인. |
| Portrait | `assets/characters/npc_daeun_normal_y3.png` | `daeun_normal_y3` | 1024x1536 | yes | `40b5a42168ca` | PASS-B | 다은 얼굴·단발·왼쪽 핀·중간 연차 자세와 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_daeun_normal_y5.png` | `daeun_normal_y5` | 1024x1536 | yes | `16d810da57ea` | PASS-B | 다은 얼굴·단발·왼쪽 핀·최종 연차 자세와 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_daeun_sad_y3.png` | `daeun_sad_y3` | 1024x1536 | yes | `0a3425fcc131` | PASS-B | 다은 정체성·억제된 슬픔·중간 연차 표정과 게임 크롭 확인. |
| Portrait | `assets/characters/npc_daeun_sad_y5.png` | `daeun_sad_y5` | 1024x1536 | yes | `f084fcb64342` | PASS-B | 다은 정체성·억제된 슬픔·최종 연차 표정과 게임 크롭 확인. |
| Portrait | `assets/characters/npc_daeun_smile_y3.png` | `daeun_smile_y3` | 1024x1536 | yes | `5b4189348834` | PASS-B | 다은 정체성·자연스러운 미소·중간 연차 표정과 게임 크롭 확인. |
| Portrait | `assets/characters/npc_daeun_smile_y5.png` | `daeun_smile_y5` | 1024x1536 | yes | `6a3b2efdec45` | PASS-B | 다은 정체성·자연스러운 미소·최종 연차 표정과 게임 크롭 확인. |
| Portrait | `assets/characters/npc_father_home_y3.png` | `father_home_y3` | 1024x1536 | yes | `88192f37088c` | PASS-B | 아버지 얼굴·세대감 있는 생활복·중간 연차 노화와 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_father_home_y5.png` | `father_home_y5` | 1024x1536 | yes | `5c1d65242400` | PASS-B | 아버지 얼굴·세대감 있는 생활복·최종 연차 노화와 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_hyunsu_normal_y3.png` | `hyunsu_normal_y3` | 1024x1536 | yes | `26afe50c8c60` | PASS-B | 현수 둥근 안경·통통한 체형·올리브/버건디 실루엣과 중간 연차 확인. |
| Portrait | `assets/characters/npc_hyunsu_normal_y5.png` | `hyunsu_normal_y5` | 1024x1536 | yes | `25eb07f7209d` | PASS-B | 현수 둥근 안경·통통한 체형·올리브/버건디 실루엣과 최종 연차 확인. |
| Portrait | `assets/characters/npc_jaehyuk_normal_y3.png` | `jaehyuk_normal_y3` | 1024x1536 | yes | `23b8268d444d` | PASS-B | 재혁 날카로운 얼굴·정장·중간 연차 절제와 상철 비유사성 확인. |
| Portrait | `assets/characters/npc_jaehyuk_normal_y5.png` | `jaehyuk_normal_y5` | 1024x1536 | yes | `3e32baf8cd39` | PASS-B | 재혁 날카로운 얼굴·정장·최종 연차 절제와 상철 비유사성 확인. |
| Portrait | `assets/characters/npc_jaehyuk_shadow_y3.png` | `jaehyuk_shadow_y3` | 1024x1536 | yes | `3f186a2c641a` | PASS-B | 재혁 정체성·압박 표정·중간 연차와 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_jaehyuk_shadow_y5.png` | `jaehyuk_shadow_y5` | 1024x1536 | yes | `b832e7ee21ca` | PASS-B | 재혁 정체성·압박 표정·최종 연차와 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_jiyeon_cold_y3.png` | `jiyeon_cold_y3` | 1024x1536 | yes | `3cc09f6e047b` | PASS-B | 지연 긴 흑발·고급 재단·차가운 표정의 중간 연차와 게임 크롭 확인. |
| Portrait | `assets/characters/npc_jiyeon_cold_y5.png` | `jiyeon_cold_y5` | 1024x1536 | yes | `3726690585c6` | PASS-B | 지연 긴 흑발·고급 재단·차가운 표정의 최종 연차와 게임 크롭 확인. |
| Portrait | `assets/characters/npc_jiyeon_normal_y3.png` | `jiyeon_normal_y3` | 1024x1536 | yes | `21233649eba4` | PASS-B | 지연 얼굴·긴 웨이브·중간 연차의 위험한 침착과 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_jiyeon_normal_y5.png` | `jiyeon_normal_y5` | 1024x1536 | yes | `a3ba834aa091` | PASS-B | 지연 얼굴·긴 웨이브·최종 연차의 위험한 침착과 투명 가장자리 확인. |
| Portrait | `assets/characters/npc_jiyeon_warm_y3.png` | `jiyeon_warm_y3` | 1024x1536 | yes | `d1fef67da360` | PASS-B | 지연 정체성·절제된 온기·중간 연차 표정과 게임 크롭 확인. |
| Portrait | `assets/characters/npc_jiyeon_warm_y5.png` | `jiyeon_warm_y5` | 1024x1536 | yes | `d2c0789ba714` | PASS-B | 지연 정체성·절제된 온기·최종 연차 표정과 게임 크롭 확인. |
| Portrait | `assets/characters/npc_sangchul_normal_y3.png` | `sangchul_normal_y3` | 1024x1536 | yes | `d9f1ef735095` | PASS-B | 상철 백발 섞인 머리·중년 체형·중간 연차 자세와 재혁 비유사성 확인. |
| Portrait | `assets/characters/npc_sangchul_normal_y5.png` | `sangchul_normal_y5` | 1024x1536 | yes | `2cb1362297c9` | PASS-B | 상철 백발 섞인 머리·중년 체형·최종 연차 자세와 재혁 비유사성 확인. |
| Portrait | `assets/characters/npc_sangchul_serious_y3.png` | `sangchul_serious_y3` | 1024x1536 | yes | `8b4ab6c5c733` | PASS-B | 상철 정체성·무거운 표정·중간 연차와 게임 크롭 확인. |
| Portrait | `assets/characters/npc_sangchul_serious_y5.png` | `sangchul_serious_y5` | 1024x1536 | yes | `9b64b5dc1a69` | PASS-B | 상철 정체성·무거운 표정·최종 연차와 게임 크롭 확인. |
| Background | `assets/backgrounds/amusement_park_parade_day.png` | `amusement_park_parade` | 1280x800 | no | `d7077312283e` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/amusement_photo_booth_evening.png` | `amusement_photo_booth` | 1280x800 | no | `b343c106c888` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/amusement_roller_coaster_day.png` | `amusement_roller_coaster` | 1280x800 | no | `9629d6993f4b` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/aruba_delivery_street.png` | `aruba_delivery` | 1280x800 | no | `82f9531e9aff` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/burnout_hospital_room.png` | `burnout` | 1280x800 | no | `958398df156a` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/cafe_seoul.png` | `cafe` | 1280x800 | no | `a8e34c6e5f11` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/casino_interior.png` | `casino` | 1280x800 | no | `b8a8b18fa8fc` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/changwon_hospital_room_empty.png` | `changwon_hospital_room_empty` | 1280x800 | no | `2f6125ab80ed` | PASS-B | 아버지 별세 뒤 비워진 병상·정돈된 시트·IV 스탠드·창원 야경, 인물·시신·문자·로고 없음 확인. |
| Background | `assets/backgrounds/cherry_blossom_path.png` | `cherry_blossom_path` | 1672x941 | no | `a721f10fb5a7` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/chuseok_highway.png` | `chuseok_highway` | 1672x941 | no | `4ac567c34bdb` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/community_center.png` | `community_center` | 1672x941 | no | `220622b0f60b` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/company_dinner_restaurant.png` | `company_dinner_restaurant` | 1672x941 | no | `9471dbec617d` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/concert_hall_night.png` | `concert_hall_night` | 1280x800 | no | `880d4b341eed` | PASS-B | 야간 콘서트 홀·무대/좌석/통로 원근, 식별 불가능한 관객/공연자 질감, 무상표·무문자와 하단 안전 크롭 확인. P1 마스터 아님. |
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
| Background | `assets/backgrounds/goshiwon_hallway.png` | `goshiwon_hallway` | 3840x2400 | no | `bc2192e633c4` | REPAIRED-A | 전체 프레임 3x 마스터. 배전함·문틀·중앙 원근·바닥 반사·신발 선반 100% A/B와 타일 이음새 없음 확인. |
| Background | `assets/backgrounds/goshiwon_room.png` | `goshiwon`, `goshiwon_room` | 1280x800 | no | `10caf8f946cd` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/goshiwon_shared_kitchen.png` | `goshiwon_shared_kitchen` | 1280x800 | no | `b166a892e8c8` | PASS-B | 같은 건물 재질, 싱크대·2구 조리기·건조대·선반·공용 냉장고 동선, 무인·무문자, 현수 우측 초상과 하단 대화창 실제 합성 확인. |
| Background | `assets/backgrounds/gym_interior.png` | `exercise`, `gym` | 1280x800 | no | `0a35a04d00b8` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hagwon_street.png` | `hagwon_street` | 1672x941 | no | `e3700c446b37` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hangang_riverside_walk.png` | `hangang_riverside` | 1280x800 | no | `a33579563891` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hanjeongsik_restaurant_day.png` | `hanjeongsik_restaurant_day` | 1280x800 | no | `d10ef79ed318` | PASS-B | 토요일 12:30 낮빛·한정식 2인석·절제된 선행 반찬·식당 통로, 무그릴·무고기·무완식 흔적·무인·무문자 확인. P1 마스터 아님. |
| Background | `assets/backgrounds/heatwave_city.png` | `heatwave_city` | 1672x941 | no | `f1bd780a20d9` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/holdem_club_interior.png` | `holdem_club` | 1280x800 | no | `88906def8eb0` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hometown_train_station.png` | `hometown_train_station` | 1280x800 | no | `23055ac86c5b` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hospital_clinic.png` | `hospital_clinic` | 1280x800 | no | `b3bf477bde01` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/hospital_clinic_day.png` | `hospital_clinic_day` | 1280x800 | no | `250f9aee9639` | PASS-B | 금요일 오전 9:20 서울 동네 외래 진료실, 책상·환자 의자·진찰대·커튼·진단기기와 무인·무문자·비입원실 확인. P1 마스터 아님. |
| Background | `assets/backgrounds/hospital_corridor.png` | `hospital` | 1280x800 | no | `093c49491ff5` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/investment_meeting.png` | `meeting` | 1280x800 | no | `be5850434ab5` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/investment_phone.png` | `investment`, `investment_phone`, `trading` | 1280x800 | no | `aab6cac64486` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jeongseon_casino_entrance.png` | `jeongseon_casino_entrance` | 1280x800 | no | `f6f89679781e` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jeongseon_casino_exterior.png` | `jeongseon_casino_exterior` | 1280x800 | no | `9a75a100f407` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jiyeon_newlywed_home_night.png` | `jiyeon_newlywed_home` | 1280x800 | no | `12d80a5fd425` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jiyeon_sedan_first_snow_interior.png` | `jiyeon_sedan_first_snow` | 1280x800 | no | `7c94031a0536` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/jiyeon_sedan_night_interior.png` | `jiyeon_sedan_night` | 1280x800 | no | `68473f8a5062` | PASS-B | 왼쪽 운전대·검은 가죽·수평 대시보드·무인/무상표와 첫 키스 CG 전후 크롭 확인. |
| Background | `assets/backgrounds/jjimjilbang.png` | `jjimjilbang` | 1672x941 | no | `bfc44b61d4c4` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/late_night_room.png` | `late_night` | 1280x800 | no | `0555c89b0480` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/library.png` | `library` | 1280x800 | no | `481604b1b302` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/military_base_gate.png` | `military_base_gate` | 1672x941 | no | `2953edc1022e` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/military_training_ground.png` | `military` | 1280x800 | no | `2b0b094c0068` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/moving_truck_loading_dusk.png` | `moving_truck_loading_dusk` | 1280x800 | no | `b88cfae60078` | PASS-B | 5월 회녹색 식생·외부 대기 상자 6개·기적재 상자·담요·트럭 램프·현관·손수레·도로/보도 동선과 무인·무문자·하단 안전 크롭 확인. |
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
| Background | `assets/backgrounds/gukbap_restaurant_night.png` | `gukbap_restaurant_night` | 1280x800 | no | `b11e247d4bb9` | PASS-B | 빈 두 사람 식탁·물컵 2개·수저통, 열린 탕 주방, 옛 고시원 골목, 무그릴·무고기·무음식·무문자·무주연 대역 확인. |
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
| Background | `assets/backgrounds/seoul_station_ktx_platform_winter.png` | `seoul_station_ktx_platform_winter` | 1280x800 | no | `35b6f9957c36` | PASS-B | 겨울 서울 고속철 승강장·열린 무상표 열차 문·촉지도·레일 원근, 인물·상표·문자 없음 확인. |
| Background | `assets/backgrounds/seoul_subway.png` | `subway` | 1280x800 | no | `e0dee873fcdf` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/street_seoul_day.png` | `street`, `street_day` | 1280x800 | no | `c7730fce4f73` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/subway_station_lost_found.png` | `subway_station_lost_found` | 1280x800 | no | `eaca16aa8259` | PASS-B | 역무실 분실물 접수대·보안 유리·보관 선반·인접 개찰구와 공용 동선, 무인·무문자 확인. P1 마스터 아님. |
| Background | `assets/backgrounds/subway_station_stairs.png` | `subway_station_stairs` | 1280x800 | no | `ba8585a9abf4` | PASS-B | 퇴근 뒤 역 계단·손잡이·개찰구·대합 공간의 물리 동선, 열차 객실 오독 없음과 무인·무문자 확인. P1 마스터 아님. |
| Background | `assets/backgrounds/suneung_test_hall.png` | `suneung_test_hall` | 1672x941 | no | `4b72655552ff` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/trading_screen_night.png` | `trading_room` | 1280x800 | no | `9bebd361a8e1` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/v2_first_bill_desk_closeup.png` | `v2_first_bill_desk_closeup` | 1280x800 | no | `bddf7fe462c6` | PASS-B | 정본 고시원 책상/침대/스위치 기하, 휴대폰·수첩·펜·영수증·물컵 단일성, 어두운 뱅킹 화면의 무판독 문자·하단 안전 크롭 확인. |
| Background | `assets/backgrounds/villa_renovation_day.png` | `villa_renovation_day` | 1280x800 | no | `9286b4d25aee` | PASS-B | 토요일 이른 시간 노후 빌라 실내, 사다리·벽 철거·바닥 보양·작업등·공구·폐기물과 문/복도 동선, 무인·무문자 확인. P1 마스터 아님. |
| Background | `assets/backgrounds/warehouse_inventory_night.png` | `warehouse_inventory_night` | 1280x800 | no | `b3d45d908fd4` | PASS-B | 선반·상자·핸드카트·바코드 스캐너·셔터/출입문 원근, 무인·무상표·무문자와 하단 안전 크롭 확인. |
| Background | `assets/backgrounds/winter_bungeoppang_stall.png` | `winter_street_bungeoppang` | 1280x800 | no | `ff57cae9f68a` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/year2_winter_last_night.png` | `year2_winter_street_night` | 1280x800 | no | `f9f019f44357` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/year3_hangang_winter_night.png` | `year3_hangang_winter_night` | 1280x800 | no | `b8387ccb4707` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |
| Background | `assets/backgrounds/year4_winter_rooftop.png` | `year4_winter_rooftop` | 1280x800 | no | `46803837d191` | PASS-B | 동선·문/창/가구·간판/인쇄물·게임 크롭 확인. |

Inventory: 75 CG / 92 portraits / 89 backgrounds / 256 total.

# 엔딩 아트 점검 & 컷신 우선순위

Updated: 2026-07-12

## 목적

엔딩 화면은 플레이어가 5년짜리 런을 끝낸 뒤 가장 오래 기억하는 표면이다.
그래서 "그럴듯한 이미지"보다 "이 엔딩의 의미와 정확히 맞는 이미지"가 우선이다.

원칙:

- 애매한 엔딩에 기존 CG를 억지로 끼우지 않는다.
- 전용 CG가 없으면 정합성 있는 배경 또는 모노톤 엔딩 카드로 처리한다.
- S/A급 엔딩과 서사적으로 중요한 B급 엔딩만 먼저 컷신화한다.
- C/F급 엔딩은 반복 실패 화면이므로, 개별 CG보다 강한 공통 실패 연출과 일부 상징 CG가 효율적이다.
- 모든 신규 엔딩 CG는 `docs/GANGNAM_INK_ART_DIRECTION.md`와 `docs/PRODUCTION_ASSET_PIPELINE.md`의 A/S 등급 게이트를 통과해야 한다.

## 현재 런타임 정책

- 엔딩 데이터의 `cg` 키가 있으면 `ImageRegistry.CG`에서 경로를 찾아 배경과 모달 내부 와이드 프리뷰에 함께 사용한다.
- `cg`가 없으면 엔딩별 `background`가 있더라도 전용 컷신으로 간주하지 않는다.
- `cg`가 없는 엔딩은 무작위 배경 이미지를 끼우지 않고, 런타임 `Gangnam Ink` 엔딩 카드로 마감한다.
- 엔딩별 `background`는 향후 전용 배경/CG 제작 기준으로만 사용한다.
- 영어판 엔딩도 동일한 `id`를 쓰므로, CG 키는 `content/endings.json`에만 둔다.

현재 보유 CG:

| cg key | file | 현재 용도 | 주의 |
|---|---|---|---|
| `cg_start` | `assets/cg/start.png` | 시작 CG | 고시원 정본 기준 유지 |
| `cg_jiyeon_crash` | `assets/cg/jiyeon_crash.png` | 지연 사고 CG | 지연 얼굴/차량 정합성 계속 확인 |
| `cg_jaehyuk_reveal` | `assets/cg/jaehyuk_reveal.png` | 재혁 폭로 CG | 재혁/성준 유사성 주의 |
| `cg_ending_father` | `assets/cg/ending_father.png` | `arc_father_04_visit` 병실 CG | 엔딩에는 아직 연결하지 않는다. 병실 방문 장면이라 `full_circle`/`guardian`과 맥락이 다름 |
| `cg_ending_gangnam_dream` | `assets/cg/ending_gangnam_dream.png` | `gangnam_dream` | 아버지 생존 조건과 본문에 맞는 부자 야경. White 엔딩과 공유 금지 |
| `cg_ending_empty_house` | `assets/cg/ending_empty_house.png` | `empty_house` | 유지 |
| `cg_ending_crypto_ghost` | `assets/cg/ending_crypto_ghost.png` | `crypto_ghost` | 유지 |
| `cg_ending_full_circle` | `assets/cg/ending_full_circle_v1.png` | `full_circle` | 전화·청산·새 집의 첫날을 한 프레임에 고정 |
| `cg_ending_gangnam_dream_white` | `assets/cg/ending_gangnam_dream_white_v1.png` | `gangnam_dream_white` | 맑은 아침·등기 폴더·자기 인식 |
| `cg_ending_with_daeun` | `assets/cg/ending_with_daeun_v1.png` | `with_daeun` | 외곽 작은 집·라면 두 그릇·상호 시선 |
| `cg_ending_second_love` | `assets/cg/ending_second_love_v1.png` | `second_love` | 강남 야경·두 번째 커피·함께 도착 |
| `cg_ending_jiyeon_man` | `assets/cg/ending_jiyeon_man_v1.png` | `jiyeon_man` | 현실/반사 동일 좌우·어깨·팔 자세의 물리적으로 맞는 거울 |
| `cg_ending_guardian` | `assets/cg/ending_guardian_v1.png` | `guardian` | 창원 퇴원 날·아버지 짐·나란한 걸음 |
| `cg_ending_jaehyuk_way` | `assets/cg/ending_jaehyuk_way_v1.png` | `jaehyuk_way` | 반쯤 친 커튼·Deep Black에서도 읽히는 고립 |
| `cg_ending_sangchul_reckoning` | `assets/cg/ending_sangchul_reckoning_v1.png` | `sangchul_reckoning` | 열린 창·내린 전화·빈 서류와 펜 |

프로포즈·결혼 과정 CG인 `cg_romance_proposal_daeun`, `cg_romance_wedding_daeun_small`, `cg_romance_wedding_daeun_full`, `cg_romance_wedding_gap_jiyeon`과 T2 결별 결과인 `cg_romance_breakup_daeun`, `cg_romance_breakup_jiyeon`은 2026-07-12에 완성됐지만 **엔딩 CG가 아니다**. 선택의 실제 순간과 비용을 시각화할 뿐 `with_daeun`, `jiyeon_man`, `lonely_rich`, `ordinary_life`의 최종 생활을 대신하지 않는다.

## 컷신 연결 금지 규칙

다음 조건 중 하나라도 걸리면 `cg`에 연결하지 않는다.

- 장면 속 인물의 나이, 얼굴, 헤어, 의상, 관계가 엔딩과 다르다.
- 고시원/가족집/병원/차량/회사처럼 정본 구조가 중요한 공간을 임의로 바꾼다.
- 배경에 주연 인물이 함께 박혀 있어 포트레이트/다른 장면과 충돌한다.
- 실제 브랜드, 실제 카지노명, 워터마크, 읽히는 로고/상표가 보인다.
- 엔딩 본문은 강남이 아닌데 이미지가 펜트하우스/럭셔리 강남을 주장한다.
- 엔딩 본문은 화해/보존인데 이미지가 임종/상실처럼 읽힌다.
- 영어권 플레이어가 캐릭터를 구분하기 어려울 정도로 실루엣이 비슷하다.

## 34개 엔딩 현황

| id | 등급 | 현재 CG | 현재 배경 | 판정 |
|---|---:|---|---|---|
| `gangnam_dream` | S | `cg_ending_gangnam_dream` | `gangnam_apartment` | 유지. 단, 최종 S급 페인트오버 후보 |
| `empty_house` | A | `cg_ending_empty_house` | `gangnam_apartment` | 유지 |
| `with_daeun` | A | `cg_ending_with_daeun` | `convenience_night` | P0 완료. 결혼 여부를 손 각도로 숨긴 최종 생활 컷 |
| `jiyeon_man` | A | `cg_ending_jiyeon_man` | `gangnam_day` | P0 완료. 현실/반사 인물 순서·시선·자세 1:1 잠금 |
| `jaehyuk_way` | B | `cg_ending_jaehyuk_way` | `gangnam_night` | P0 완료. 핵심 moral collapse 엔딩 |
| `late_call` | B | 없음 | `ktx_window` | P1 신규 CG 후보 |
| `stable_success` | B | 없음 | `rooftop_day` | P2. 전용 안정 배경이 있으면 좋음 |
| `ordinary_life` | C | 없음 | 없음 | 공통 모노톤 실패/일상 카드 |
| `burnout` | F | 없음 | 없음 | P1 공통 실패 CG 후보 |
| `mental_break` | F | 없음 | 없음 | 정신건강의학과 진료실 장면. 응급실 `burnout` CG 공유 금지 |
| `bankruptcy` | F | 없음 | 없음 | P1 빚/파산 실패 CG 후보 |
| `crypto_ghost` | F | `cg_ending_crypto_ghost` | `trading_room` | 유지 |
| `startup_exit` | A | 없음 | 없음 | P1 신규 CG 후보 |
| `political_fix` | B | 없음 | 없음 | P3. 출시 후 후보 |
| `lonely_rich` | A | 없음 | 없음 | P1 신규 CG 후보 |
| `investment_master` | A | 없음 | 없음 | P2. 투자 시스템 성취 컷 후보 |
| `reputation_legend` | A | 없음 | 없음 | P2. 텍스트로도 버틸 수 있음 |
| `healthy_retirement` | B | 없음 | 없음 | P3. 한강 산책 배경과 연결 가능 |
| `debt_spiral` | F | 없음 | 없음 | `bankruptcy`와 공통 실패 CG 공유 가능 |
| `orthodox_pinnacle` | A | 없음 | `restaurant` | P1 신규 CG 후보 |
| `orthodox_hollow` | C | 없음 | 없음 | 공통 모노톤 성공-공허 카드 |
| `balanced_life` | B | 없음 | 없음 | P3. 텍스트/배경 중심 |
| `unorthodox_legend` | A | 없음 | 없음 | P2 신규 CG 후보 |
| `early_retirement` | A | 없음 | 없음 | P2 신규 CG 후보 |
| `creator_success` | A | 없음 | 없음 | P2 신규 CG 후보 |
| `instant_legend` | ? | 없음 | `gangnam_apartment` | P1. 히든 엔딩이라 한 장의 강한 CG 가치 높음 |
| `full_circle` | S+ | `cg_ending_full_circle` | `gangnam_penthouse` | P0 완료. 아버지는 전화 상대이며 방 안에 중복 등장하지 않음 |
| `gangnam_dream_white` | S+ | `cg_ending_gangnam_dream_white` | `gangnam_night` | P0 완료. 일반 강남 CG와 공유하지 않는 전용 White 컷 |
| `second_love` | A+ | `cg_ending_second_love` | `gangnam_night` | P0 완료. 두 번째 커피 동작으로 관계를 결산 |
| `guardian` | A+ | `cg_ending_guardian` | `hospital` | P0 완료. 기존 병실 방문 CG와 구분되는 퇴원 컷 |
| `gambling_recovery` | B | 없음 | `goshiwon_room` | P1 신규 CG 후보. 도박 아크 결산 |
| `career_climber` | A | 없음 | `office` | P2 신규 CG 후보 |
| `career_burnout` | B | 없음 | `ktx_window` | P3. `burnout` 실패 연출과 구분 필요 |
| `sangchul_reckoning` | B | `cg_ending_sangchul_reckoning` | `cafe` | P0 완료. 경찰/직접 청산 변주가 공유 가능한 통화 직후 컷 |
| `writer` | A | 없음 | `library` | P2 신규 CG 후보 |

## 제작 우선순위

### P0 — Next Fest/상점 스크린샷 후보 (8/8 완료, 2026-07-12)

이 그룹은 데모 이후 기대감을 만들고, 리뷰어에게 "이 게임이 감정적으로 끝나는 게임"임을 보여주는 핵심 엔딩이다.

| 새 cg key | 연결 엔딩 | 장면 스펙 |
|---|---|---|
| `cg_ending_full_circle` | `full_circle` | 강남 펜트하우스 또는 거실 창가. 민준이 아버지에게 상철 빚을 청산했다고 전화/고백한 직후. 돈의 승리가 아니라 이름을 돌려받는 장면 |
| `cg_ending_gangnam_dream_white` | `gangnam_dream_white` | 강남 야경 앞의 민준. 화려함보다 차갑고 맑은 공기, 흰 빛, 아무도 밟지 않고 도착했다는 고요함 |
| `cg_ending_with_daeun` | `with_daeun` | 외곽 빌라나 작은 주방. 다은과 민준이 라면/커피를 사이에 두고 웃는다. 강남은 아니지만 실패처럼 보이면 안 됨 |
| `cg_ending_second_love` | `second_love` | 강남 아파트 베란다. 다은은 야경을 보고, 민준은 커피를 탄다. 사랑이 보상처럼 보이지 않고 함께 도착한 느낌 |
| `cg_ending_jiyeon_man` | `jiyeon_man` | 강남 고급 욕실/복도 거울. 지연은 아름답고 위험하며 고혹적, 민준은 행복과 공허 사이. 지연 얼굴은 포트레이트 정본과 일치 |
| `cg_ending_guardian` | `guardian` | 창원 병원 퇴원 날 주차장/복도. 민준이 아버지 짐을 든다. 기존 `ending_father` 병실 방문 이미지와 구분 |
| `cg_ending_jaehyuk_way` | `jaehyuk_way` | 강남 아파트 거실, 커튼을 치는 민준. 돈은 닿았지만 표면은 Black moral tint로 무너짐 |
| `cg_ending_sangchul_reckoning` | `sangchul_reckoning` | 경찰서 진술서 또는 밤 카페 테이블. 펜, 서류, 떨리는 손. 강남 사다리를 스스로 치우는 장면 |

### P1 — 정식 출시 전 A급 보강

| 새 cg key | 연결 엔딩 | 장면 스펙 |
|---|---|---|
| `cg_ending_late_call` | `late_call` | KTX 창가, 폰을 쥔 손, 빗방울. 얼굴을 크게 안 보여줘도 됨 |
| `cg_ending_instant_legend` | `instant_legend` | 너무 이른 강남 도착. 넓은 거실이 오히려 비현실적으로 비어 보임 |
| `cg_ending_startup_exit` | `startup_exit` | 작은 사무실/회의실, 계약서와 노트북. 벼락부자보다 숨 돌리는 창업자 |
| `cg_ending_lonely_rich` | `lonely_rich` | 고급 거실에서 혼자 배달앱을 닫는 장면. 돈과 외로움의 대비 |
| `cg_ending_orthodox_pinnacle` | `orthodox_pinnacle` | 회식 자리/회사 로비. 정장 차림 민준, 후배의 부러움, 본인은 확신 없음 |
| `cg_ending_gambling_recovery` | `gambling_recovery` | 고시원 책상 달력의 동그라미. 카지노가 아니라 회복의 일상 |
| `cg_ending_bankruptcy` | `bankruptcy`, `debt_spiral` | 계산기, 독촉 문자, 비 오는 방. 실패 공통 컷 가능 |
| `cg_ending_burnout` | `burnout` | 응급실 형광등/천장/링거와 보호자 연락 질문. 정신건강의학과 `mental_break`와 공유 금지 |

노출·감정 회수·상점 스크린샷 가치를 함께 보면 다음 실제 제작 순서는 `late_call` → `lonely_rich` → `gambling_recovery` → `bankruptcy/debt_spiral`이다. `startup_exit`, `instant_legend`, `orthodox_pinnacle`은 강한 성취 컷이지만 조건부 경로라 그다음이다. `mental_break`는 전용 진료실 컷을 만들기 전까지 정합한 엔딩 카드로 남긴다.

### P2 — 있으면 고급스러운 엔딩

`investment_master`, `reputation_legend`, `unorthodox_legend`, `early_retirement`,
`creator_success`, `career_climber`, `writer`, `stable_success`.

이 그룹은 전용 CG가 없어도 엔딩 품질이 무너지지는 않는다. 대신 배경과 엔딩 카드 연출,
엔딩 스팅, 텍스트 타이포그래피가 먼저 좋아야 한다.

### P3 — 공통 엔딩 카드 우선

`ordinary_life`, `orthodox_hollow`, `balanced_life`, `healthy_retirement`,
`political_fix`, `career_burnout`.

개별 CG보다 `MORAL_TINT` 기반 엔딩 카드의 색, 질감, 페이드, 짧은 스팅이 효율적이다.

## 신규 CG 입고 절차

1. 이 문서에 `cg key`, 파일명, 연결 엔딩, 장면 스펙을 먼저 추가한다.
2. `assets/cg/ending_*.png`로 입고한다.
3. `autoloads/ImageRegistry.gd`의 `CG`에 키를 추가한다.
4. `content/endings.json`의 해당 엔딩에 `cg`를 추가한다.
5. `tools/CGRuntimeCheck.gd`에 주요 CG 경로 검증을 추가한다.
6. `ScreenshotQA --qa=ending-p0 --lang=ko/en`에서 전용 CG와 첫 화면 크롭을 캡처한다.
7. A/S 등급이 아니면 상점/트레일러/Next Fest 스크린샷에 사용하지 않는다.

## 오디오 우선순위

엔딩 BGM은 `BGMPlayer.on_ending()`이 good/bad 계열로 분기한다.
정식 출시 전에는 엔딩별 풀 BGM보다 짧은 스팅 5종이 효율적이다.

| key 후보 | 사용처 | 느낌 |
|---|---|---|
| `ending_stinger_white` | `gangnam_dream_white`, `full_circle`, `guardian` | 맑고 차가운 여백 |
| `ending_stinger_gangnam` | `gangnam_dream`, `instant_legend` | 승리지만 과장되지 않음 |
| `ending_stinger_love` | `with_daeun`, `second_love`, `jiyeon_man` | 따뜻함/위험함을 엔딩별로 약간 변주 |
| `ending_stinger_black` | `jaehyuk_way`, `empty_house`, `lonely_rich` | 돈만 남은 어두운 잔향 |
| `ending_stinger_failure` | `bankruptcy`, `debt_spiral`, `burnout`, `mental_break`, `crypto_ghost` | 짧고 건조한 실패음 |

## 체크리스트

- [x] `gangnam_dream` 전용 CG 연결
- [x] `empty_house` 전용 CG 연결
- [x] `crypto_ghost` 전용 CG 연결
- [x] `gangnam_dream_white`의 일반 강남 CG 임시 공유 제거
- [x] `gangnam_dream_white` 전용 White CG 제작 후 연결
- [x] P0 신규 CG 8종 제작/보정/연결
- [ ] P1 신규 CG 8종 제작/보정/연결
- [ ] P2 엔딩은 CG보다 엔딩 카드/스팅/배경 정합성 먼저 보강
- [ ] 엔딩 스팅 5종 제작 및 `AudioManager`/`BGMPlayer` 연결

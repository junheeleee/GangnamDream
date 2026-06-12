# 강남드림 — 비주얼·오디오 업그레이드 브리프

> **이 파일은 이미지 생성 + 로컬 PC 접근 가능한 AI 에이전트가 읽고 실행하는 종합 업무 지시서입니다.**  
> 위에서 아래 순서대로 진행하세요. P1 → P2 → P3 순.

---

## 0. 프로젝트 이해 (필독)

- **게임**: 강남드림 — 33세 백수 김민준이 통장 50만원으로 시작해 5년 안에 강남 입성(자산 30억)을 노리는 한국 리얼리티 비주얼노벨
- **톤**: 한국 웹툰 × 로파이 리얼리즘. 서울 2020년대 청년의 생존기. 화려하지 않고, 절제되고, 무겁되 감동적.
- **금지 스타일**: SF UI, 빛나는 링/오브, 추상 파티클, 마법 효과, 판타지 요소, 밝고 채도 높은 애니메이션풍
- **허용 스타일**: 고시원, 원룸, 서울 골목, 편의점, 사무실, 지하철, 병원, 카페, 포장마차, 강남 야경
- **팔레트**: 차콜(#1a1a26), 먹빛 네이비(#0d0d18), 따뜻한 골드(#f0b429), 차가운 블루포인트(#5b9cf6). 전반적으로 어둡고 절제됨.
- **레퍼런스 파일** (읽어서 톤 파악):
  - `assets/backgrounds/goshiwon_room.png` — 배경 톤/무드 레퍼런스
  - `assets/characters/main_character_neutral_goshiwon.png` — 주인공 스타일 레퍼런스
  - `assets/characters/main_character_tired.png` — 주인공 표정 레퍼런스

---

## 1. 저장 경로 규칙

```
assets/
├── backgrounds/      ← 배경 이미지  1280×800 PNG
├── characters/       ← 초상화       512×768 PNG (세로형)
├── cg/               ← CG 장면     1280×720 PNG (전체화면)
├── keyart/           ← Steam/마케팅  각 spec 참조
└── audio/            ← BGM .ogg / SFX .wav
```

**Godot import**: 파일 교체 후 Godot 에디터에서 해당 파일 우클릭 → Reimport 필요.

---

## P1 — 즉시 교체 (데모 출시 전 필수)

### P1-A. 주인공 초상화 (7장) `512×768 PNG`

**공통 조건**: 김민준, 한국 남성, 30대 초반, 약간 마른 체형, 짧은 흑발, 피곤해 보이는 눈. 배경은 흐릿하게 (boke). 웹툰 + 사실주의 혼합 화풍. 어두운 톤.

---

#### `assets/characters/main_character_neutral_goshiwon.png`
**상태**: 평범한 하루 — 특별한 감정 없음, 약간 멍한 표정  
**복장**: 낡은 후드티 또는 민소매에 얇은 셔츠  
**배경**: 고시원 벽 (노란 형광등 빛, 좁은 공간 암시)  
**프롬프트 키워드**: `Korean man early 30s, tired neutral expression, gosiwon room atmosphere, fluorescent light, worn hoodie, melancholy realistic style, dark muted tones`

---

#### `assets/characters/main_character_tired.png`
**상태**: 탈진, 번아웃 직전  
**복장**: 구겨진 셔츠, 넥타이 풀린 상태 또는 후드  
**배경**: 야근 후 어두운 사무실 또는 늦은 밤 방  
**프롬프트 키워드**: `Korean man early 30s, exhausted expression, dark circles, slouched posture, late night office or gosiwon, burnout, dim lighting, photorealistic webtoon style`

---

#### `assets/characters/main_character_determined.png`
**상태**: 결심, 눈빛이 살아있음  
**복장**: 깔끔한 캐주얼 (흰 셔츠 또는 얇은 니트)  
**배경**: 서울 야경 창가  
**프롬프트 키워드**: `Korean man early 30s, determined focused gaze, slight tension in jaw, clean casual outfit, Seoul night city window background, resolve, realistic webtoon`

---

#### `assets/characters/main_character_happy.png`
**상태**: 진짜 기쁨 — 크게 웃지 않고, 입꼬리가 올라가고 눈빛이 따뜻함  
**복장**: 평상복  
**배경**: 흐릿한 밝은 실내  
**프롬프트 키워드**: `Korean man early 30s, genuine warm smile, relieved happy expression, bright but not overdone, soft background, realistic Korean art style`

---

#### `assets/characters/main_character_shocked.png`
**상태**: 충격, 눈이 크게 뜨이고 입이 살짝 열림  
**복장**: 평상복  
**배경**: 어두운 실내  
**프롬프트 키워드**: `Korean man early 30s, shocked surprised expression, wide eyes, mouth slightly open, unexpected news reaction, dark interior, Korean webtoon realistic`

---

#### `assets/characters/main_character_30s.png`
**상태**: 30대 중반 — 성장한 모습, 묵직한 결의  
**복장**: 단정한 비즈니스 캐주얼 (네이비 재킷 또는 슬랙스)  
**배경**: 사무실 또는 도심 창가  
**프롬프트 키워드**: `Korean man mid 30s, mature confident expression, business casual, Seoul office or city window, weathered but resilient, slightly older than previous portraits`

---

#### `assets/characters/main_character_50s.png`  ← **NEW: 아직 없음**
**상태**: 많은 것을 겪은 50대 — 담담하고 차분  
**복장**: 정장 또는 깔끔한 셔츠  
**배경**: 황혼 빛 창가  
**프롬프트 키워드**: `Korean man early 50s, weathered wise face, slight grey hair, calm neutral expression, formal shirt, golden hour window light, realistic Korean portrait`

---

### P1-B. NPC 초상화 (14장) `512×768 PNG`

---

#### `assets/characters/npc_romantic_interest.png` → **김다은 (normal)**
한국 여성, 20대 후반, 편의점 알바생 느낌. 무표정이지만 따뜻한 눈. 편의점 유니폼 또는 단순한 캐주얼. 야간 편의점 빛.  
`Korean woman late 20s, quiet warm eyes, convenience store worker, night shift lighting, understated beauty, realistic Korean style`

#### `assets/characters/npc_daeun_smile.png`  ← **NEW: 아직 없음**
다은, 미소 — 수줍은 듯 진심이 담긴 미소. 같은 인물 연속성 중요.  
`Same character as npc_romantic_interest.png, shy genuine smile, warmer lighting`

#### `assets/characters/npc_daeun_sad.png`  ← **NEW: 아직 없음**
다은, 슬픔 — 눈이 촉촉, 입술 꼭 다문  
`Same character, sad expression, glistening eyes, suppressed emotion`

---

#### `assets/characters/npc_father.png` → **아버지 (normal)**
한국 남성, 60대 초반, 무뚝뚝하지만 속 깊은 아버지. 낡은 점퍼 또는 등산복. 지방 느낌.  
`Korean man early 60s, stern but warm father figure, worn jacket, provincial Korean background, realistic`

#### `assets/characters/npc_father_weak.png`  ← **NEW: 아직 없음**
아버지, 병약한 상태 — 창백하고 수척해진 얼굴, 병원 가운  
`Same character as npc_father.png, pale sick face, hospital gown, vulnerable expression`

---

#### `assets/characters/npc_close_friend.png` → **강현수**
한국 남성, 30대 초반, 주인공의 오랜 친구. 편하고 친근한 인상. 캐주얼 옷.  
`Korean man early 30s, friendly relaxed expression, casual outfit, trustworthy old friend vibe`

---

#### `assets/characters/npc_boss.png` → **임상철 (normal)**
한국 남성, 50대, 인맥 브로커/부동산 큰손. 여유 있고 계산적인 눈빛. 고급 정장.  
`Korean man 50s, expensive suit, calculating yet friendly expression, real estate broker aura, silver hair optional`

#### `assets/characters/npc_sangchul_serious.png`  ← **NEW: 아직 없음**
상철, 진지한 상태 — 경고하거나 충고할 때. 표정이 굳어짐.  
`Same character as npc_boss.png, serious stern expression, warning pose, darker mood`

---

#### `assets/characters/npc_mentor.png` → **한지연 (normal)**
한국 여성, 40대 초반, 냉철한 비즈니스 멘토/투자자. 단정한 정장, 날카롭지만 신뢰가 가는 눈.  
`Korean woman early 40s, sharp intelligent eyes, business suit, mentor investor, cool professional demeanor`

#### `assets/characters/npc_jiyeon_warm.png`  ← **NEW: 아직 없음**
지연, 따뜻한 상태 — 드물게 보이는 진심 어린 표정  
`Same character as npc_mentor.png, rare warm genuine expression, slight smile`

#### `assets/characters/npc_jiyeon_cold.png`  ← **NEW: 아직 없음**
지연, 차가운 상태 — 실망하거나 거리를 두는 표정  
`Same character as npc_mentor.png, cold disappointed expression, withdrawn`

---

#### `assets/characters/npc_jaehyuk.png` → **최재혁 (friendly)**
한국 남성, 30대 초반, 카리스마 있는 사기꾼/기회주의자. 잘생기고 자신감 넘치는 미소.  
`Korean man early 30s, charismatic charming smile, well-dressed, salesman confidence, slight ambiguity — could be trustworthy or not`

#### `assets/characters/npc_jaehyuk_shadow.png`  ← **NEW: 아직 없음**
재혁, 어두운 면 — 진짜 의도가 드러나는 냉혹한 표정  
`Same character as npc_jaehyuk.png, cold calculating expression, shadows on face, true nature revealed`

---

#### `assets/characters/npc_mother.png` → **어머니**
한국 여성, 50대 후반, 전형적인 한국 어머니. 걱정스럽고 따뜻한 눈.  
`Korean woman late 50s, warm worried mother expression, apron or modest clothing, Korean mother archetype, loving but anxious`

---

### P1-C. 핵심 배경 (10장) `1280×800 PNG`

#### `assets/backgrounds/goshiwon_room.png` ← **교체**
고시원 방 내부. 1.5평 남짓. 접이식 책상, 창문 없거나 환풍구만. 형광등. 이 게임의 시작점.  
`Korean gosiwon (tiny single room) interior, 1.5 pyeong, foldable desk, no window or only ventilation slot, harsh fluorescent light, worn linoleum floor, melancholy confined space, 2020s Seoul, photorealistic`

#### `assets/backgrounds/office_desk.png` ← **교체**
한국 대기업/중소기업 사무실. 모니터, 키보드, 서류더미. 늦은 오후 또는 야근 시간대.  
`Korean office cubicle desk, monitor with spreadsheet, papers stacked, late afternoon or late night, Seoul corporate atmosphere, overhead fluorescent, muted tones`

#### `assets/backgrounds/cafe_seoul.png` ← **교체**
서울 홍대/연남 스타일 인디 카페 내부. 나무 테이블, 핸드드립 커피, 흐릿한 창밖 골목. 낮 또는 저녁.  
`Seoul indie cafe interior, Hongdae or Yeonnam style, wooden tables, hand drip coffee, blurred street outside window, warm ambient lighting, cozy intimate atmosphere`

#### `assets/backgrounds/pojangmacha.png` ← **교체**
서울 포장마차. 비닐 처마, 낡은 테이블과 플라스틱 의자, 소주병. 비 오거나 습한 밤.  
`Seoul pojangmacha (street food tent), vinyl awning, plastic stools, soju bottles, rainy night atmosphere, orange warm light inside, dark street outside`

#### `assets/backgrounds/convenience_store_night.png` ← **교체**
편의점 내부. 야간. 삼각김밥 진열대, 라면 코너, 차가운 형광등. 새벽 2시 느낌.  
`Korean convenience store interior at night, triangle kimbap display, ramen shelf, bright white fluorescent, empty aisles, 2am atmosphere, GS25 or CU style`

#### `assets/backgrounds/late_night_room.png` ← **교체**
원룸 자정. 노트북 화면만 켜있고 방은 어두움. 빈 라면 컵, 충전기.  
`Korean studio apartment late night, only laptop screen lit, dark room, empty ramen cup on desk, charger cables, blurred city lights through curtain gap, solitude`

#### `assets/backgrounds/hospital_corridor.png` ← **교체**
병원 복도. 흰 벽, 차가운 형광등, 플라스틱 의자 줄. 대기실 또는 외래 복도.  
`Korean hospital corridor, white walls, cold fluorescent lighting, plastic waiting chairs, quiet anxiety, clinical atmosphere, late afternoon`

#### `assets/backgrounds/gangnam_night_street.png` ← **교체**
강남 야경. 테헤란로 또는 강남역 일대. 빌딩들, 네온사인, 택시들.  
`Gangnam district Seoul night street, Teheranno avenue, glass skyscrapers with lights, neon signs, taxis and pedestrians, aspirational but distant, blue-gold palette`

#### `assets/backgrounds/restaurant_korean.png`  ← **NEW: 신규**
한국 식당 내부. 고깃집 또는 국밥집. 낮 또는 저녁. 가족 모임 또는 회식 장소.  
`Korean BBQ or soup restaurant interior, wooden tables with gas burners, metal chopsticks, paper napkins, warm lighting, family gathering or work dinner atmosphere`

#### `assets/backgrounds/library.png`  ← **NEW: 신규**
공공 도서관 열람실. 줄지어선 책상, 독서등, 공부하는 사람들 흐릿하게. 조용하고 집중된 분위기.  
`Korean public library reading room, rows of study desks with individual lights, blurred background studiers, quiet focused atmosphere, subdued lighting, 2020s Seoul`

---

### P1-D. CG 장면 (2장) `1280×720 PNG`

#### `assets/cg/start.png` ← **교체 (타이틀 스플래시)**
서울 스카이라인 + 고시원 창문 대비. 아래는 고시원 방, 위는 강남 빌딩들. 게임의 핵심 대비.  
`Korean visual novel opening CG, split composition: bottom half — gosiwon room window at night, top half — Gangnam skyline with lit skyscrapers, dramatic contrast, aspirational mood, dark cinematic style, 16:9`

#### `assets/cg/ending_father.png` ← **교체 (아버지 엔딩 CG)**
아들이 아버지 손을 잡는 장면. 병원 또는 집. 감정적. 수천 런 중 가장 많이 도달하는 엔딩 CG.  
`Emotional Korean visual novel CG, son holding elderly father's hand, hospital or simple home setting, warm low light, bittersweet moment, 50s father and 30s son, tender realistic style, cinematic 16:9`

---

## P2 — 풀 퀄리티 업그레이드

### P2-A. 나머지 배경 (20장 교체) `1280×800 PNG`

| 파일 | 장소/상황 | 핵심 분위기 |
|---|---|---|
| `goshiwon_hallway.png` | 고시원 복도 | 좁고, 형광등, 낡은 벽 |
| `oneroom_apartment.png` | 원룸 내부 | 고시원보다 넓음, 창문 있음, 밤 |
| `gangnam_apartment.png` | 강남 아파트 내부 | 고급, 넓은 창, 야경 |
| `seoul_subway.png` | 서울 지하철 내부 | 2호선 초록, 출퇴근 혼잡 |
| `seoul_rainy_street.png` | 서울 비 오는 거리 | 우산들, 반사광, 우울한 아름다움 |
| `hometown_train_station.png` | 지방 기차역 | 무궁화호, 낡은 역사, 회색 하늘 |
| `family_living_room.png` | 지방 부모님 거실 | 낡은 가구, 따뜻한 조명, 나무 티비장 |
| `rooftop_daytime.png` | 서울 옥상 낮 | 한강 원경, 주변 빌딩, 바람 느낌 |
| `rooftop_night.png` | 서울 옥상 밤 | 야경, 별, 혼자 생각하는 공간 |
| `realestate_office.png` | 부동산 중개소 | 매물 사진 가득한 유리창, 모니터 |
| `investment_meeting.png` | 투자 미팅룸 | 고급 회의실, 화이트보드, 도시 전망 |
| `investment_phone.png` | 주식 차트 모니터 | 다중 모니터, HTS 차트, 새벽 |
| `hospital_clinic.png` | 동네 내과 | 번호표, 대기 의자, 차가운 흰 벽 |
| `burnout_hospital_room.png` | 입원실 | 링거, 병상, 창밖 서울 |
| `penthouse_view.png` | 강남 펜트하우스 | 전면 유리, 최상층 야경, 도달의 상징 |
| `trading_screen_night.png` | 야간 트레이딩 | 빨강/초록 차트, 새벽 3시, 긴장 |
| `gangnam_day.png` | 강남 낮 거리 | 코엑스 인근, 인파, 명품샵 |
| `gangnam_station_exit.png` | 강남역 출구 | 지하철 출구, 사람들, 서울 대표 랜드마크 |
| `street_seoul_day.png` | 서울 일반 거리 낮 | 평범한 주택가 골목, 낮 |
| `pc_bang_interior.png` | PC방 내부 | 어두운 조명, 모니터 빛, 의자들 |

### P2-B. 나머지 CG (2장) `1280×720 PNG`

#### `assets/cg/jiyeon_crash.png`
지연 멘토와의 충돌 장면. 냉정하게 관계를 끊는 순간.  
`Korean VN CG, tense confrontation between professional woman 40s and man 30s, office or cafe, cold emotional distance, dramatic lighting`

#### `assets/cg/jaehyuk_reveal.png`
재혁의 정체가 드러나는 순간. 충격과 배신감.  
`Korean VN CG, dramatic betrayal reveal scene, man 30s charismatic smile turning cold, shadowed face, moment of deception exposed`

### P2-C. 키아트 `각 규격`

| 파일 | 규격 | 용도 |
|---|---|---|
| `keyart/steam_capsule_main.png` | 616×353 | Steam 메인 캡슐 |
| `keyart/steam_capsule_small.png` | 231×87 | Steam 소형 캡슐 |
| `keyart/steam_header.png` | 460×215 | Steam 헤더 |
| `keyart/gangnam_dream_keyart_rooftop.png` | 1920×1080 | 게임 타이틀/홍보 |

**키아트 방향**: 서울 야경을 바라보는 주인공 뒷모습. 고시원과 강남 빌딩의 대비. 게임 타이틀 "강남드림" 한자+영문. 어둡고 영화적.

---

## P3 — 오디오 업그레이드

> **포맷**: BGM → `.ogg`, SFX → `.wav`  
> **기존 `AUDIO_PROMPTS.md` 파일에 Suno/jsfxr 프롬프트 상세 기재되어 있음**  
> 그 파일을 읽고 생성 후 `assets/audio/`에 저장.

### BGM 7트랙 교체/신규

| 파일 | 상황 | Loop |
|---|---|---|
| `bgm_menu.ogg` | 시작 메뉴 — 서울 야경, 설렘과 긴장 | ✅ |
| `bgm_gosiwon.ogg` | 고시원 생활 — 새벽 형광등, 막막함 | ✅ |
| `bgm_main.ogg` | 원룸 생활 — 로파이 서울 루프 | ✅ |
| `bgm_apartment.ogg` | 아파트 생활 — 자신감 상승 | ✅ |
| `bgm_crisis.ogg` | 위기 (건강/정신 ≤30) | ✅ |
| `bgm_victory.ogg` | 마일스톤 달성 (8초 단발) | ❌ |
| `bgm_ending.ogg` | 엔딩 화면 — 한국 드라마 OST × 로파이 | ✅ |

### SFX 14종 교체

| 파일 | 역할 |
|---|---|
| `sfx_click.wav` | 버튼 클릭 (짧고 날카롭게) |
| `sfx_close.wav` | 모달 닫기 |
| `sfx_open_modal.wav` | 모달 열기 |
| `sfx_month.wav` | 다음 달 전환 (페이지 넘기는 느낌) |
| `sfx_money_gain.wav` | 수입/돈 획득 |
| `sfx_money_loss.wav` | 손실/지출 |
| `sfx_money_big.wav` | 대형 수익/마일스톤 (임팩트 있게) |
| `sfx_stat_up.wav` | 스탯 상승 |
| `sfx_stat_down.wav` | 스탯 하락 |
| `sfx_event_new.wav` | 이벤트 등장 알림 |
| `sfx_choice_made.wav` | 선택지 결정 |
| `sfx_housing_up.wav` | 이사 업그레이드 |
| `sfx_game_over.wav` | 게임오버 |
| `sfx_success.wav` | 강남드림 달성 |

**SFX 톤**: 과하지 않게. 시스템 비프 수준이 아닌, 실제 소리 레이어(동전 소리, 종이 넘기는 소리, 키보드 클릭 등)을 변형. `AUDIO_PROMPTS.md` jsfxr 설정 참고.

---

## 완료 체크리스트

```bash
# P1 완료 확인
ls assets/characters/main_character_neutral_goshiwon.png
ls assets/characters/main_character_tired.png
ls assets/characters/main_character_determined.png
ls assets/characters/main_character_happy.png
ls assets/characters/main_character_shocked.png
ls assets/characters/main_character_30s.png
ls assets/characters/main_character_50s.png      # NEW
ls assets/characters/npc_daeun_smile.png          # NEW
ls assets/characters/npc_daeun_sad.png            # NEW
ls assets/characters/npc_father_weak.png          # NEW
ls assets/characters/npc_sangchul_serious.png     # NEW
ls assets/characters/npc_jiyeon_warm.png          # NEW
ls assets/characters/npc_jiyeon_cold.png          # NEW
ls assets/characters/npc_jaehyuk_shadow.png       # NEW
ls assets/backgrounds/restaurant_korean.png       # NEW
ls assets/backgrounds/library.png                 # NEW
ls assets/cg/start.png
ls assets/cg/ending_father.png
```

### ImageRegistry 업데이트 (NEW 파일 추가 후 필수)

`autoloads/ImageRegistry.gd` PORTRAITS 딕셔너리에 신규 파일 추가:

```gdscript
"player_sad":         "res://assets/characters/main_character_neutral_goshiwon.png",  # 임시 → 별도 파일 생성 권장
"daeun_smile":        "res://assets/characters/npc_daeun_smile.png",
"daeun_sad":          "res://assets/characters/npc_daeun_sad.png",
"father_weak":        "res://assets/characters/npc_father_weak.png",
"sangchul_serious":   "res://assets/characters/npc_sangchul_serious.png",
"jiyeon_warm":        "res://assets/characters/npc_jiyeon_warm.png",
"jiyeon_cold":        "res://assets/characters/npc_jiyeon_cold.png",
"jaehyuk_shadow":     "res://assets/characters/npc_jaehyuk_shadow.png",
```

BACKGROUNDS 딕셔너리에 신규 파일 추가:
```gdscript
"restaurant":         "res://assets/backgrounds/restaurant_korean.png",
"library":            "res://assets/backgrounds/library.png",
"street":             "res://assets/backgrounds/street_seoul_day.png",
```

---

## 참고: 이벤트-초상화 매핑 (교체 우선순위 근거)

가장 많이 등장하는 portrait 기준:
1. `player_normal` — 전체 이벤트 40% 이상
2. `player_tired` — 번아웃/스트레스 이벤트
3. `daeun_normal/smile/sad` — 다은 아크 9개 이벤트 (리뷰어 호평 3위)
4. `father_normal/weak` — 아버지 씬 (리뷰어 호평 2위)
5. `jaehyuk_*` — 재혁 아크 5개 이벤트
6. `jiyeon_*` — 지연 아크 5개 이벤트
7. `sangchul_*` — 상철 아크 다수

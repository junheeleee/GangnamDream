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
  - `assets/characters/main_character_neutral_goshiwon.png` — 레거시 주인공 표정 레퍼런스 (배경은 추종 금지)
  - `assets/characters/main_character_tired.png` — 레거시 주인공 표정 레퍼런스 (배경은 추종 금지)

### 0-A. 에셋 레이어 분리 원칙 (최우선)

아래 개별 프롬프트보다 이 원칙이 우선한다.

- **주연/반복 인물 초상화는 배경 없는 투명 PNG로 제작한다.**
  - 대상: 김민준, 김다은, 한지연, 최재혁, 임상철, 아버지, 어머니, 강현수, 반복 등장 조연.
  - 크기: 512×768 PNG, 알파 채널 포함.
  - 생성 시 배경이 필요하면 플랫 크로마키로 만들고 제거한다. 실제 방/거리/사무실 배경을 초상화 안에 넣지 않는다.
- **배경 이미지는 반복 인물이 없는 재사용 장소 이미지로 제작한다.**
  - 고시원, 사무실, 투자 책상, 병원, 가족집처럼 정합성이 민감한 장소는 사람 없이 장소만 담는다.
  - PC방, 경마장, 홀덤 클럽, 식당, 역, 도서관처럼 비어 있으면 부자연스러운 공공장소는 작고 어두운 익명 실루엣/뒷모습/군중 텍스처를 허용한다.
  - 반복 배경에는 주인공/주연/조연처럼 읽히는 얼굴, 전경 인물, 자세가 뚜렷한 사람, 상세한 손을 넣지 않는다.
- **CG만 인물+배경 합성을 허용한다.**
  - `start.png`, `ending_father.png`, `jiyeon_crash.png`처럼 특정 장면용 1회성 연출 컷만 예외다.
  - CG는 해당 장면의 공간/경제상태/인물 위치 정합성을 통과해야 한다.
- **단발 엑스트라만 예외적으로 배경 포함 가능하다.**
  - 고시원 원장, 팀장, 성준, 정보상처럼 이름/ID로 반복 호출되는 조연은 투명 포트레이트 대상이다.
  - 정말 한 번만 지나가는 군중/엑스트라성 인물만 제작 효율상 배경 포함 초상화를 임시 허용한다.
  - 같은 인물이 반복 등장하거나 표정 파생이 생기면 즉시 투명 포트레이트 대상으로 승격한다.
- **경제 상태와 장소 정합성은 필수다.**
  - 초반 고시원 생활 투자 이미지는 폰/노트북/작은 책상 스케일이어야 한다.
  - 멀티모니터 트레이딩룸은 스캘핑 미니게임, 퀀트/프로 트레이더, 후반 전문 투자 장면 전용이다.
- **정합성 > 화려함.**
  - 예뻐도 방 구조, 소품, 인물 나이, 생활수준, 한국 현실성이 틀리면 폐기한다.

---

## 1. 저장 경로 규칙

```
assets/
├── backgrounds/      ← 재사용 장소 배경        1280×800 PNG
├── characters/       ← 투명 배경 초상화       512×768 PNG (세로형, 반복 인물)
├── cg/               ← CG 장면     1280×720 PNG (전체화면)
├── keyart/           ← Steam/마케팅  각 spec 참조
└── audio/            ← BGM .ogg / SFX .wav
```

**Godot import**: 파일 교체 후 Godot 에디터에서 해당 파일 우클릭 → Reimport 필요.

---

## P1 — 즉시 교체 (데모 출시 전 필수)

### P1-A. 주인공 초상화 `512×768 PNG`

**공통 조건**: 김민준, 한국 남성, 30대 초반, 약간 마른 체형, 짧은 흑발, 피곤해 보이는 눈. **반복 주연 초상화이므로 배경 없는 투명 PNG로 제작한다.** 아래 개별 항목의 배경 문구는 감정/조명 참고만 하고 실제 초상화 안에 방 배경을 넣지 않는다. 런타임 평상시 포트레이트는 `ImageRegistry.get_player_context_portrait()`가 현재 직업/주거/자산 상태를 보고 무직·알바·사무직·대기업 정장 의상 중 선택한다.

---

#### `assets/characters/main_character_neutral_goshiwon.png`
**상태**: REGENERATED 2026-06-12. 평범한 하루 — 특별한 감정 없음, 약간 멍한 표정
**복장**: 낡은 검은 티/스웨트셔츠
**배경**: 없음 — 투명 PNG
**프롬프트 키워드**: `Korean man age 33, tired neutral expression, worn dark sweatshirt, transparent background, Korean manhwa VN portrait`

---

#### `assets/characters/main_character_tired.png`
**상태**: REGENERATED 2026-06-12. 탈진, 번아웃 직전
**복장**: 낡은 검은 티/스웨트셔츠
**배경**: 없음 — 투명 PNG
**프롬프트 키워드**: `Same Kim Minjun, age 33, exhausted expression, dark circles, worn dark sweatshirt, transparent background`

---

#### `assets/characters/main_character_determined.png`
**상태**: REGENERATED 2026-06-12. 결심, 눈빛이 살아있음
**복장**: 낡은 검은 티/스웨트셔츠
**배경**: 없음 — 투명 PNG
**프롬프트 키워드**: `Same Kim Minjun, age 33, determined focused gaze, slight tension in jaw, worn dark sweatshirt, transparent background`

---

#### `assets/characters/main_character_happy.png`
**상태**: REGENERATED 2026-06-12. 진짜 기쁨 — 크게 웃지 않고, 입꼬리가 올라가고 눈빛이 따뜻함
**복장**: 낡은 검은 티/스웨트셔츠
**배경**: 없음 — 투명 PNG
**프롬프트 키워드**: `Same Kim Minjun, age 33, genuine warm smile, relieved happy expression, worn dark sweatshirt, transparent background`

---

#### `assets/characters/main_character_shocked.png`
**상태**: REGENERATED 2026-06-12. 충격/불안 — 폰이나 손 소품 없이 얼굴 표정만으로 표현
**복장**: 낡은 검은 티/스웨트셔츠
**배경**: 없음 — 투명 PNG
**프롬프트 키워드**: `Same Kim Minjun, age 33, shocked anxious expression, wide eyes, mouth slightly open, worn dark sweatshirt, transparent background`

---

#### `assets/characters/main_character_unemployed.png`
**상태**: ADDED 2026-06-12. 무직/초반 기본 상태
**복장**: 낡은 검은 스웨트셔츠, 고시원 생활감
**배경**: 없음 — 투명 PNG
**런타임 조건**: 직업 없음 + 상승 마일스톤 없음

---

#### `assets/characters/main_character_part_time.png`
**상태**: ADDED 2026-06-12. 알바/생존 노동 상태
**복장**: 어두운 캐주얼 작업 재킷 또는 배달/편의점 생존복 느낌
**배경**: 없음 — 투명 PNG
**런타임 조건**: `job_01`, `job_02`, survival 카테고리

---

#### `assets/characters/main_character_office.png`
**상태**: ADDED 2026-06-12. 일반 사무직/교육/기술직 상태
**복장**: 흰 셔츠, 느슨한 넥타이, 저렴한 가디건 또는 네이비 재킷
**배경**: 없음 — 투명 PNG
**런타임 조건**: 일반 저·중티어 office/education/tech 직업

---

#### `assets/characters/main_character_corporate.png`
**상태**: ADDED 2026-06-12. 대기업/금융/고티어 직업 상태
**복장**: 네이비 또는 차콜 정장, 절제된 넥타이
**배경**: 없음 — 투명 PNG
**런타임 조건**: `job_08`, finance, sales, tier 3+ 직업 또는 상승 마일스톤 이후 무직 상태

---

#### `assets/characters/main_character_30s.png`
**상태**: LEGACY/REVIEW. 현재 파일은 배경이 박힌 과거 상승 컷이라 반복 런타임 포트레이트로 쓰지 않는다.
**복장**: 단정한 비즈니스 캐주얼
**배경**: 현재 레거시 파일에는 배경이 있으므로 신규 재생성 시 반드시 없음 — 투명 PNG
**대체 런타임 자산**: `main_character_corporate.png`
**프롬프트 키워드**: `Same Kim Minjun, mid-to-late 30s, mature confident expression, business casual, transparent background, Korean manhwa VN portrait`

---

#### `assets/characters/main_character_50s.png`
**상태**: REVIEW/LOW PRIORITY. 현 5년 루프에서는 핵심 컷이 아니며 에필로그 전용으로만 사용한다.
**복장**: 정장 또는 깔끔한 셔츠
**배경**: 신규 재생성 시 없음 — 투명 PNG
**프롬프트 키워드**: `Same Kim Minjun, early 50s, weathered wise face, slight grey hair, calm neutral expression, formal shirt, transparent background, Korean manhwa VN portrait`

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
한국 남성, 26-27세, 고시원 옆방의 9급 공시 4년차 후배. 통통하지만 호감형, 둥근 안경, 부스스한 검은 머리, 올리브색 후드와 버건디 줄무늬 티셔츠. 민준을 형이라 부르는 따뜻하고 조금 어색한 인상.
`Korean man age 26-27, chubby but likable civil-service-exam student, round glasses, messy black hair, olive-gray hoodie, muted burgundy striped shirt, awkward warm half-smile, transparent VN portrait`

---

#### `assets/characters/npc_boss.png` → **임상철 (normal)**
한국 남성, 50대, 인맥 브로커/부동산 큰손. 여유 있고 계산적인 눈빛. 고급 정장.
`Korean man 50s, expensive suit, calculating yet friendly expression, real estate broker aura, silver hair optional`

#### `assets/characters/npc_sangchul_serious.png`  ← **NEW: 아직 없음**
상철, 진지한 상태 — 경고하거나 충고할 때. 표정이 굳어짐.
`Same character as npc_boss.png, serious stern expression, warning pose, darker mood`

---

#### `assets/characters/npc_mentor.png` → **한지연 (normal) — REGENERATED 2026-06-12**
한지연, 31세. 강남 금수저 투자자이자 위험한 로맨스 히로인. 예쁘고 고혹적이지만 쉽게 믿으면 안 될 듯한 얼굴. 긴 검은 머리 또는 짙은 흑갈색 웨이브, 날카로운 눈, 크림/블랙 테일러드 수트. 배경 없는 투명 PNG.
`Korean woman early 30s, wealthy Gangnam heiress investor, beautiful dangerous alluring heroine, long black hair, sharp intelligent eyes, cream or black tailored suit, elegant old-money aura, transparent background, no room or office background`

#### `assets/characters/npc_jiyeon_warm.png`  ← **REGENERATED 2026-06-12**
지연, 따뜻한 상태 — 드물게 보이는 진심 어린 표정. 정본 얼굴/나이/긴 머리 유지, 배경 없는 투명 PNG.
`Same canon Han Jiyeon, early 30s, long black hair, rare warm genuine expression, slight controlled smile, alluring but sincere, transparent background`

#### `assets/characters/npc_jiyeon_cold.png`  ← **REGENERATED 2026-06-12**
지연, 차가운 상태 — 실망하거나 거리를 두는 표정. 아름답지만 위험하고 계산적인 압박감. 정본 얼굴/나이/긴 머리 유지, 배경 없는 투명 PNG.
`Same canon Han Jiyeon, early 30s, long black hair, cold disappointed expression, beautiful but dangerous, calculating status pressure, transparent background`

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
편의점 내부. 야간. 삼각김밥 진열대, 라면 코너, 차가운 형광등. 새벽 2시 느낌. **반복 배경이므로 직원/손님/실루엣 없이 비어 있어야 한다.**
`Korean convenience store interior at night, triangle kimbap display, ramen shelf, bright white fluorescent, empty aisles, empty checkout counter with no cashier, 2am atmosphere, Korean convenience store style`

#### `assets/backgrounds/late_night_room.png` ← **교체**
**REGENERATED 2026-06-12.** `goshiwon_room.png`의 구조를 그대로 보존한 4am 색보정 변형이다. 원룸이 아니라 정본 고시원 야간 변형이어야 한다: 작은 높은 불투명 환기창, 침대, 침대 발치/화면 하단 낮은 책상, 큰 창문/도시 전망 없음.
`Canonical Korean goshiwon room at 4am, same layout as goshiwon_room, tiny high frosted ventilation window, narrow bed, low desk at bed foot, laptop blue light, empty ramen cup, charger cables, no city view, no large window`

#### `assets/backgrounds/hospital_corridor.png` ← **교체**
병원 복도. 흰 벽, 차가운 형광등, 플라스틱 의자 줄. 대기실 또는 외래 복도.
`Korean hospital corridor, white walls, cold fluorescent lighting, plastic waiting chairs, quiet anxiety, clinical atmosphere, late afternoon`

#### `assets/backgrounds/gangnam_night_street.png` ← **교체**
강남 야경. 테헤란로 또는 강남역 일대. 빌딩들, 네온사인, 택시들.
`Gangnam district Seoul night street, Teheranno avenue, glass skyscrapers with lights, neon signs, taxis and pedestrians, aspirational but distant, blue-gold palette`

#### `assets/backgrounds/restaurant_korean.png`  ← **P2 REGENERATED 2026-06-13**
한국 식당 내부. 고깃집 또는 국밥집. 낮 또는 저녁. 가족 모임 또는 회식 장소. 공공장소라 배경 손님 실루엣은 허용하지만, 얼굴/전경 인물/직원 주연화는 금지.
`Korean BBQ or soup restaurant interior, wooden tables with gas burners, metal chopsticks, paper napkins, warm lighting, distant faceless diner silhouettes only, no foreground people`

#### `assets/backgrounds/library.png`  ← **P2 REGENERATED 2026-06-13**
공공 도서관 열람실. 줄지어선 책상, 독서등, 책 더미와 좌석. 조용하고 집중된 분위기. 작고 어두운 배경 학생 실루엣은 허용하지만, 현수/민준처럼 읽히는 인물은 금지.
`Korean public library reading room, rows of study desks with individual lights, books and seats, quiet focused atmosphere, subdued lighting, 2020s Seoul, small faceless distant student silhouettes only`

---

### P1-D. CG 장면 (2장) `1280×720 PNG`

#### `assets/cg/start.png` ← **교체 (타이틀 스플래시)**
고시원 정본 구조를 그대로 쓰는 시작 CG. 큰 창문/전망 금지. 작은 높은 불투명 환기창, 침대, 침대 발치 낮은 책상. 강남은 폰 화면·노트·작은 목표 오브제로만 암시.
`Korean visual novel opening CG, cramped goshiwon room, tiny high frosted ventilation window, narrow bed, low foldable desk at bed foot, phone and notebook implying Gangnam dream, no skyline view through window, dark cinematic style, 16:9`

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
| `seoul_rainy_street.png` | 서울 비 오는 거리 | P2 REGENERATED: 중앙 인물 없는 비 오는 골목, 반사광, 우울한 아름다움 |
| `hometown_train_station.png` | 지방 기차역 | P2 REGENERATED: 중앙 여행자 없는 지방 플랫폼, 무궁화호/낡은 역사/회색 하늘 |
| `family_living_room.png` | 민준 아버지의 창원/지방 노동자 가정 거실 | 낡은 가구, 조용한 부재감, 작은 오래된 가족사진 1개 이하; 대가족 단체사진·화목한 큰집 분위기 금지 |
| `rooftop_daytime.png` | 서울 옥상 낮 | 한강 원경, 주변 빌딩, 바람 느낌 |
| `rooftop_night.png` | 서울 옥상 밤 | 야경, 별, 혼자 생각하는 공간 |
| `realestate_office.png` | 부동산 중개소 | 매물 사진 가득한 유리창, 모니터 |
| `investment_meeting.png` | 투자 미팅룸 | 고급 회의실, 화이트보드, 도시 전망 |
| `investment_phone.png` | 초반/일반 투자 | 폰 또는 작은 노트북, 고시원/원룸 책상, 현실적인 개인투자 |
| `hospital_clinic.png` | 동네 내과 | 번호표, 대기 의자, 차가운 흰 벽 |
| `burnout_hospital_room.png` | 입원실 | 링거, 병상, 창밖 서울 |
| `penthouse_view.png` | 강남 펜트하우스 | 전면 유리, 최상층 야경, 도달의 상징 |
| `trading_screen_night.png` | 전문 트레이딩 | 후반/퀀트/전문 투자자 전용, 멀티모니터, 초반 고시원 투자 금지 |
| `gangnam_day.png` | 강남 낮 거리 | 코엑스 인근, 인파, 명품샵 |
| `gangnam_station_exit.png` | 강남역 출구 | 지하철 출구, 사람들, 서울 대표 랜드마크 |
| `street_seoul_day.png` | 서울 일반 거리 낮 | 평범한 주택가 골목, 낮 |
| `pc_bang_interior.png` | PC방 내부 | P2 REGENERATED: 모니터 뒤 익명 게이머 실루엣, 어두운 조명, 모니터 빛 |

추가 P2 public venue pass 완료: `restaurant_korean.png`, `library.png`, `racetrack_betting_hall.png`, `holdem_club_interior.png`도 익명 배경 실루엣 원칙에 맞춰 교체 완료. 홀덤은 전경 손/팔 없이 카드·칩·테이블만 보이게 유지한다.

### P2-B. 나머지 CG (2장) `1280×720 PNG` — **DONE / CROP QA 2026-06-13**

#### `assets/cg/jiyeon_crash.png`
한지연 첫 접촉 사고 CG. 비 오는 강남 야간 도로, 검은 메르세데스 벤츠 S클래스급 세단, 쓰러진 자전거 두 바퀴, 운전석에서 내린 31세 지연. 투명 포트레이트 정본과 같은 긴 웨이브 흑발, 날카로운 눈매, 크림 수트/블랙 이너, 위험하게 아름답고 당황한 얼굴.
`Korean VN CG, rainy Sinchon backstreet bicycle accident, black Mercedes-Benz S-Class luxury sedan, Korean woman early 30s with long black hair and cream tailored suit stepping from driver's seat, beautiful dangerous alluring heroine, fallen bicycle with two visible wheels, dramatic wet pavement lighting`

#### `assets/cg/jaehyuk_reveal.png`
재혁의 정체가 드러나는 순간. 충격과 배신감.
`Korean VN CG, dramatic betrayal reveal scene, man 30s charismatic smile turning cold, shadowed face, moment of deception exposed`

### P2-C. 키아트 `각 규격` — **DONE 2026-06-13**

| 파일 | 규격 | 용도 |
|---|---|---|
| `keyart/steam_capsule_main.png` | 616×353 | Steam 메인 캡슐 — local-font title overlay |
| `keyart/steam_capsule_small.png` | 231×87 | Steam 소형 캡슐 — compact local-font title overlay |
| `keyart/steam_header.png` | 460×215 | Steam 헤더 — local-font title overlay |
| `keyart/gangnam_dream_keyart_rooftop.png` | 1920×1080 | 텍스트 없는 마스터 키아트 |

**키아트 방향**: 서울 야경을 바라보는 주인공 뒷모습. 낡은 옥상과 강남 빌딩의 대비. 마스터 키아트에는 텍스트를 넣지 않고, Steam 캡슐/헤더에만 `GANGNAM DREAM` + `강남드림`을 로컬 폰트로 합성한다. 이미지 생성 모델에 타이틀 텍스트를 맡기지 않는다.

---

## P3 — 오디오 업그레이드 — **DONE 2026-06-13**

> **포맷**: BGM → `.ogg`, SFX → `.wav`
> `tools/generate_audio_assets.py`로 deterministic local synthesis를 수행했다. 외부 Suno/jsfxr 결과물이 들어오면 같은 파일명으로 교체하되, `tools/AudioAssetCheck.tscn`과 `docs/AUDIO_QA.md` 기준을 통과해야 한다.

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

### SFX 17종 교체

| 파일 | 역할 |
|---|---|
| `sfx_click.wav` | 버튼 클릭 (짧고 날카롭게) |
| `sfx_close.wav` | 모달 닫기 |
| `sfx_open_modal.wav` | 모달 열기 |
| `sfx_tab_open.wav` | 탭/미니게임 패널 열기 |
| `sfx_month.wav` | 다음 달 전환 (페이지 넘기는 느낌) |
| `sfx_money_gain.wav` | 수입/돈 획득 |
| `sfx_money_loss.wav` | 손실/지출 |
| `sfx_money_big.wav` | 대형 수익/마일스톤 (임팩트 있게) |
| `sfx_buy.wav` | 매수/구매 |
| `sfx_sell.wav` | 매도 |
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
ls assets/characters/main_character_unemployed.png
ls assets/characters/main_character_part_time.png
ls assets/characters/main_character_office.png
ls assets/characters/main_character_corporate.png
ls assets/characters/main_character_30s.png      # LEGACY/REVIEW only
ls assets/characters/main_character_50s.png      # epilogue/review only
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
"player_sad":         "res://assets/characters/main_character_tired.png",
"player_suit":        "res://assets/characters/main_character_corporate.png",
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

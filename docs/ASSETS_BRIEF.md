# 강남드림 — Complete Asset Brief for Codex
# 이 파일 하나가 전체 에셋 제작의 단일 소스다. 기존 assets/ 폴더의 IMAGE_PROMPTS.md / CODEX_IMAGE_REQUEST.md / IMAGE_GENERATION_TASK.md는 무시하고 이 파일을 따른다.

> 상용 출시용 이미지/오디오 제작은 먼저 `docs/PRODUCTION_ASSET_PIPELINE.md`의 등급/Gate/라이선스/QA 기준을 따른다. 이 문서는 개별 에셋 내용과 프롬프트를 정의하고, production pipeline 문서는 산출물이 출시 자격을 얻는 과정을 정의한다.

---

## Step 0 — 작업 전 필독 파일

```
CLAUDE.md                                              ← 게임 전체 설계 이해
assets/ASSET_INDEX.md                                  ← 기존 에셋 스타일 레퍼런스
assets/backgrounds/goshiwon_room.png                   ← 배경 분위기 기준
assets/backgrounds/gangnam_night_street.png            ← 야경 분위기 기준
assets/characters/main_character_neutral_goshiwon.png  ← 캐릭터 스타일 기준 (얼굴형, 조명)
assets/characters/main_character_tired.png             ← 표정 강도 기준
```

> ⚠️ 기존 캐릭터 이미지들은 **33세 백수**가 아닌 중년 정장 이미지로 잘못 생성되었다.
> 아래 새 프롬프트로 전부 교체한다.

---

## Master Style Guide

- **장르**: 한국 현대 로파이 리얼리즘 + 느와르. 서울 2026년 청년 생존기.
- **팔레트**: 차콜 베이스, 먹빛 네이비, 따뜻한 골드 포인트, 차가운 블루 하이라이트. 전체적으로 어둡고 절제됨.
- **조명**: 드라마틱한 저키 조명 (창문 빛, 형광등, 모니터 빛, 네온). 강한 명암대비.
- **금지**: 공상과학 UI, 빛나는 링, 추상 노드, 마법 효과, 애니 과장, 밝은 채도 과다.
- **캐릭터 배경 해상도**: 1280×800 PNG
- **캐릭터 초상화 해상도**: 512×768 PNG (세로형)
- **Steam 에셋**: 각 항목별 별도 지정

---

## Part 1 — 주인공 초상화 (7종 교체)

> 김민준, 33세 한국 남성. 백수. 캐주얼 옷차림 (크루넥 맨투맨 or 후드티 + 청바지). 다크서클, 약간 야윈 얼굴, 단발~중간 길이 헤어. 지쳐 보이지만 눈빛에 야망이 남아 있음. 고시원 배경.

> 📁 **저장 경로**: 모든 캐릭터 이미지는 `assets/characters/` 플랫 구조 (서브폴더 없음)

### 1. `assets/characters/main_character_neutral_goshiwon.png` ← 교체

```
Portrait of a Korean man in his early 30s, lean face, short-to-medium dark hair, dark circles under his eyes. Wearing a dark crewneck sweatshirt and jeans. Neutral expression — tired but quietly observing. Background is a cramped goshiwon room: bare wall, a small desk lamp, a single power strip. Half-body portrait, 512x768 vertical. Dramatic side-lighting from the desk lamp. Dark charcoal palette, warm amber desk lamp glow. Lo-fi realism, painterly illustration. No anime style. No suit, no tie, no middle-aged appearance.
```

### 2. `assets/characters/main_character_tired.png` ← 교체

```
Same Korean man in his early 30s as the neutral portrait — same face, same crewneck sweatshirt. Exhausted expression: eyes half-closed, slight slouch, hand on face or chin resting on hand. Background: same goshiwon room, even dimmer. Dark circles more prominent. The feeling of a sleepless night. Same style, same lighting, 512x768 vertical. Lo-fi realism, painterly.
```

### 3. `assets/characters/main_character_determined.png` ← 교체

```
Same Korean man in his early 30s — same face, same casual clothing, now with a focused and resolute expression. Eyes sharp and forward-looking. Slightly straighter posture. Could be holding a phone or looking at something off-screen with intensity. Same goshiwon room background but lit slightly brighter — as if dawn is breaking. 512x768 vertical. Lo-fi realism, painterly.
```

### 4. `assets/characters/main_character_happy.png` ← 교체

```
Same Korean man in his early 30s — same face, same casual clothing. Genuine surprised happiness: a rare real smile, eyes crinkled. Holding a smartphone screen-out showing something exciting (no readable text). Background: same room but with warmer, slightly brighter light. The joy feels earned and unexpected. 512x768 vertical. Lo-fi realism, painterly.
```

### 5. `assets/characters/main_character_shocked.png` ← 교체

```
Same Korean man in his early 30s — same face, same casual clothing. Wide-eyed shock: mouth slightly open, eyes fully open, both hands gripping the phone. Ambiguous shock — could be good or terrible news. Background: same goshiwon room in the dark. 512x768 vertical. Lo-fi realism, painterly.
```

### 6. `assets/characters/main_character_30s.png` ← 교체

```
Same Korean man now looking slightly more polished — a year or two later. Still lean, same face, now wearing a simple button-up shirt (not a suit — more like a 편의점 or office casual). Hair slightly neater. Expression: cautious confidence. Mid-game look. Background: a nicer one-room apartment glimpsed behind. 512x768 vertical. Lo-fi realism, painterly.
```

### 7. `assets/characters/main_character_50s.png` ← 교체

```
The same man but now in his 50s — same facial structure, now with grey at the temples, slight crow's feet. Wearing a well-fitted dark jacket. Expression: bittersweet wisdom. Background: floor-to-ceiling window with Seoul skyline night view — success but also solitude. 512x768 vertical. Lo-fi realism, painterly.
```

---

## Part 2 — NPC 초상화 (신규)

### 8. `assets/characters/npc_romantic_interest.png` ← 교체 (김다은)

```
Portrait of a Korean woman in her late 20s. 김다은, a first-love figure. Bright but slightly melancholy eyes. Wearing a casual oversized coat or turtleneck sweater. Hair: shoulder-length, natural black. Expression: warm half-smile with a hint of worry — someone who cares but holds back. Background: blurred Seoul street at dusk, warm shop lights behind her. 512x768 vertical. Lo-fi realism, painterly. Not overly glamorous — real and grounded.
```

### 9. `assets/characters/npc_boss.png` ← 교체 (임상철 — 인맥 브로커)

```
Portrait of a Korean man in his late 30s to early 40s. 임상철, a network broker and fixer. Slightly greasy confidence — not villainous but visibly opportunistic. Well-dressed but not quite trustworthy: a slim-fit blazer, an expensive watch glimpsed. Hair slicked back. Expression: a wide, practiced smile that doesn't reach the eyes. Background: dim bar or private room interior. 512x768 vertical. Lo-fi realism, painterly.
```

### 10. `assets/characters/npc_close_friend.png` ← 교체 (강현수 — 고시원 옆방 공시생 후배)

```
Transparent visual novel portrait of a Korean man age 26-27. 강현수, Minjun's goshiwon neighbor and fourth-year civil-service-exam student. Chubby but likable, round wire-frame glasses, messy medium black hair, soft round face, gentle tired eyes, olive-gray hoodie over a muted burgundy striped shirt. Expression: awkward warm half-smile, a younger friend trying to encourage Minjun. No background, no room, no props. 512x768 vertical, Korean manhwa VN style.
```

### 11. `assets/characters/npc_mentor.png` ← 교체 (한지연 — 위험한 히로인)

```
Transparent-background portrait of Han Jiyeon, a Korean woman age 31. Wealthy Gangnam heiress and dangerous romance heroine, not a mentor figure. Beautiful, alluring, and slightly unsafe: long black or very dark brown hair, sharp intelligent eyes, composed mouth, tailored cream or black suit, subtle old-money jewelry. No office or cafe background. No short bob, no middle-aged look, no reading glasses. 512x768 vertical.
```

### 12. `assets/characters/npc_coworker.png` (선택)

```
Portrait of a Korean man in his late 20s to early 30s. A generic workplace colleague — neither a villain nor a close friend. Office casual clothes, slightly stressed expression. Background: office desk blurred behind. 512x768 vertical. Lo-fi realism, painterly.
```

---

## Part 3 — 배경 이미지 25종

### 기존 19종 (재생성 또는 검토 후 교체)

#### 1. `assets/backgrounds/goshiwon_room.png`
```
Interior of a Korean goshiwon (고시원) single room, night. Canon layout: narrow bed, low foldable desk at the bed foot / screen-bottom foreground, tiny high frosted ventilation window only, no scenic city view. One desk lamp as main light source. Personal items scattered: instant noodles cup, phone charger, notebooks. Oppressive and claustrophobic but lived-in. Dark charcoal palette, amber desk lamp glow. 1280x800. Lo-fi realism.
```

#### 2. `assets/backgrounds/oneroom_apartment.png`
```
Interior of a Korean one-room apartment (원룸), late evening. Small kitchen counter merged with the living area, a single bed frame, a modest desk, curtains half-open showing Seoul buildings across the street. Slightly more space than a goshiwon — a small improvement but still humble. Warm light from a single ceiling lamp. 1280x800. Lo-fi realism, dark and restrained palette.
```

#### 3. `assets/backgrounds/gangnam_apartment.png`
```
Interior of an upscale Gangnam apartment living room, night. Large sofa, clean modern furniture, floor-to-ceiling windows with Seoul skyline visible. Not ostentatious — tasteful and cold. The lived-in quality is minimal — it feels like a showroom. A single floor lamp is on. The feeling of arriving but not quite belonging. Dark palette with warm interior light against cold city outside. 1280x800. Lo-fi realism.
```

#### 4. `assets/backgrounds/seoul_rainy_street.png`
```
A Seoul alleyway at night in the rain. Wet asphalt reflecting neon and streetlights. A pojangmacha (포장마차) tent glowing amber in the background. Rain streaks in the foreground. Nobody close — just a lone back-view figure or empty. The unnamed side street of Seoul that nobody photographs. Navy and amber palette, rain highlights in cool blue. 1280x800. Lo-fi realism.
```

#### 5. `assets/backgrounds/office_desk.png`
```
A Korean office desk late at night, long after everyone else has gone home. Monitor glow illuminating a sea of documents and coffee cups. City lights visible through the floor-to-ceiling window behind the desk. Empty chairs at other desks in the background. The loneliness of mandatory overtime. Cool monitor blue, warm desk lamp, dark office shadows. 1280x800. Lo-fi realism.
```

#### 6. `assets/backgrounds/seoul_subway.png`
```
Interior of a late-night Seoul metro car. Empty plastic orange seats, fluorescent strip lighting, advertisements on the walls. Through the window, darkness of the tunnel. One or two distant silhouettes seated far away. The rattling silence of the last train. Cold fluorescent white and grey palette with orange seat accents. 1280x800. Lo-fi realism.
```

#### 7. `assets/backgrounds/convenience_store_night.png`
```
Interior of a Korean convenience store (편의점) at 2am. Refrigerator aisles glowing white-blue. Rows of triangle kimbap, cup ramen, energy drinks. A drowsy part-time worker silhouette barely visible at the counter. Rain on the window outside, a streetlight on wet asphalt. Lonely hollow atmosphere. Cold fluorescent light, dark outside. 1280x800. Lo-fi realism.
```

#### 8. `assets/backgrounds/cafe_seoul.png`
```
Interior of a small Seoul café, late afternoon. A two-person wooden table by the window, one Americano on the table, an empty chair across from the viewer. Outside the rain-streaked window: blurred Seoul alley, a few umbrellas. Warm amber café lighting against the grey-blue light outside. Cozy but quietly lonely. 1280x800. Lo-fi realism.
```

#### 9. `assets/backgrounds/investment_phone.png`
```
Close-up of a smartphone on a cramped desk showing a stock or crypto candlestick chart app. Red and green candles clearly visible. A cold coffee cup nearby. Dark room — the phone screen is the only significant light source. A hand hovering over the screen. The anxiety of a 3am investment decision. Screen glow in cool blue, red and green data. 1280x800. Lo-fi realism.
```

#### 10. `assets/backgrounds/hospital_corridor.png`
```
Long corridor of a Korean general hospital at night. Fluorescent lights stretching far into the distance along white walls. A nurse silhouette far away. An IV stand and empty wheelchair visible. Nobody close. Cold and silent — the feeling of life having come to a halt. Pale cold white and charcoal palette. 1280x800. Lo-fi realism.
```

#### 11. `assets/backgrounds/late_night_room.png`
```
REGENERATED 2026-06-12 as a 4am color-grade of goshiwon_room.png. Keep the exact same canonical goshiwon layout: narrow bed, low foldable desk at bed foot / screen-bottom foreground, tiny high frosted ventilation window only, no scenic city view, no different room layout. Laptop/phone glow may add blue light, but the structure must not change. 1280x800. Lo-fi realism.
```

#### 12. `assets/backgrounds/hometown_train_station.png`
```
A small provincial Korean train station platform, early morning. A single KTX or mugunghwa train visible on the track. Mountains in the background, autumn or winter. A few waiting passengers with luggage silhouettes. Leaving or returning — bittersweet. Muted ochre and grey palette, cold morning light. 1280x800. Lo-fi realism.
```

#### 13. `assets/backgrounds/rooftop_daytime.png`
```
Rooftop of an old Seoul villa (빌라) building in daytime under an overcast grey sky. A water tank, laundry rack with clothes hanging. Seoul's dense mid-rise cityscape visible in the distance under hazy air. POV as if someone climbed up to breathe. Muted grey, warm ochre and dusty rooftop tones. 1280x800. Lo-fi realism.
```

#### 14. `assets/backgrounds/gangnam_night_street.png`
```
Gangnam Station (강남역) exit at night in the rain. Neon signs reflecting on wet sidewalks. Luxury storefronts, cars, umbrellas, dense urban texture. No clear foreground protagonist figure and no single back-view lone man; distant anonymous crowd silhouettes only if needed. Glamorous and alienating — a city for people who have already made it. Dark navy, neon accent highlights (red, blue, white). 1280x800. Lo-fi realism.
```

#### 15. `assets/backgrounds/penthouse_view.png`
```
Floor-to-ceiling window of a Gangnam high-rise penthouse at night. The full Seoul skyline spread below. Minimal luxury interior, empty room, no person or silhouette. Reached the top — but feels hollow through the emptiness of the room itself. Soft warm interior light against glittering cold city lights outside. 1280x800. Lo-fi realism.
```

#### 16. `assets/backgrounds/burnout_hospital_room.png`
```
A hospital patient room, single bed, IV drip bag hanging, white curtain partition, pale daylight through a small window showing grey Seoul rooftops. Phone face-down on the bedside table. A water cup. Nobody else. Everything has stopped. Cold white, pale grey palette. 1280x800. Lo-fi realism.
```

#### 17. `assets/backgrounds/family_living_room.png`
```
A modest older working-class living room in Changwon, Korea, tied to Kim Minjun's father. Old sofa, scuffed wooden TV cabinet, cheap wall clock, folding table with two tea cups, worn wallpaper, quiet absence and guilt. At most one small faded photo of young father, mother, and Minjun or father alone. No extended-family portrait, no happy large household signal, no luxury apartment, no scenic window. Warm but muted evening light. 1280x800.
```

#### 18. `assets/backgrounds/military_training_ground.png`
```
Korean military training ground, overcast afternoon. Rows of barracks in the background, a parade ground with a flagpole. Green military tones, grey sky, dry earth. Sparse and austere. Muted olive, grey, brown palette. 1280x800. Lo-fi realism.
```

#### 19. `assets/backgrounds/trading_screen_night.png`
```
A dark room dominated by multiple monitor screens showing stock market charts, cryptocurrency data, candlestick graphs. The screens are the only light source. Red and green numbers cascade. The desk is messy with notes and empty coffee cups. Day trading obsession at midnight. Cool monitor blue, red-green data glow. 1280x800. Lo-fi realism.
```

---

### 신규 6종

#### 20. `assets/backgrounds/racetrack_betting_hall.png`
```
Interior of a Korean horse racing track (경마장) betting hall. A large screen showing horse statistics and odds. Long queue counters with betting terminals. A few gamblers studying racing forms, cigarette smoke implied. Worn linoleum floor, harsh overhead fluorescent lighting. The desperate hope of the working class gambler. Yellowed fluorescent light, grey walls, green racing form papers. 1280x800. Lo-fi realism.
```

#### 21. `assets/backgrounds/racetrack_track_view.png`
```
View of a Korean horse racing track from the grandstand, just before the race starts. The sandy oval track stretching into the distance. A few horses with jockeys visible far away at the starting gate. Grey overcast sky above. Sparse winter crowd in the blurred stands behind. Wide empty horizon feeling. Muted grey-green track, dark stands, overcast sky. 1280x800. Lo-fi realism.
```

#### 22. `assets/backgrounds/holdem_club_interior.png`
```
Interior of a dim underground Korean poker room (지하 홀덤 클럽). A single poker table under a hanging lamp — the only bright spot in the room. Green felt table, poker chips stacked, playing cards dealt. Shadowy figures seated around — faces mostly obscured. Cigarette smoke haze. Dark wood walls, exposed brick. The private, slightly illegal atmosphere of underground gambling. Very dark palette, single lamp warm glow, cool shadows. 1280x800. Lo-fi realism, noir.
```

#### 23. `assets/backgrounds/scalping_trading_room.png`
```
A private trading room or a home setup used for rapid stock scalping. Multiple screens arranged on a wide desk showing real-time candlestick charts, orderbooks, stock tickers. A headset, a Red Bull can, sticky notes on the monitor bezels. Night outside the window. Intense concentration implied by the setup. Cool monitor blue dominant, small warm lamp accent. 1280x800. Lo-fi realism.
```

#### 24. `assets/backgrounds/pc_bang_interior.png`
```
Interior of a Korean PC방 at night. Rows of high-spec gaming setups in individual booths with low partition walls. Neon LED strip lighting under the desks — purple and blue tones. A few silhouettes of players hunched over keyboards. The menu smells of instant food. The background hum of keyboards and cooling fans. Dark purple-blue neon palette, individual screen glows. 1280x800. Lo-fi realism.
```

#### 25. `assets/backgrounds/gangnam_station_exit.png`
```
Gangnam Station exit number 11, daytime. The famous Gangnam intersection — luxury cars, business towers, advertising screens. Crowds of office workers and young professionals. Looking up from street level. The wealth gap visible in the clothing and posture of passersby. Sharp contrast: someone arriving from a cramped commute. Cool grey daylight, splashes of brand color from storefronts. 1280x800. Lo-fi realism.
```

---

## Part 4 — 미니게임 전용 에셋

### 경마장 (RaceTrack)

#### `assets/ui/horse_silhouette.png`
```
Eight distinct horse silhouettes arranged in a row on a transparent background. Each horse is a simple but recognizable side-view thoroughbred silhouette, numbered 1-8 from left to right (numbers not visible — just silhouettes). Each slightly different in build: some leaner, some stockier, some with different head/tail positions. Clean black silhouette on transparent PNG. Flat illustration. 1024x128, 8 horses each 128x128.
```

#### `assets/characters/npc_tip_seller.png`
```
Portrait of a middle-aged Korean man in his 50s. A 경마장 tipster — wearing a worn padded jacket, holding a wrinkled racing form newspaper. Shifty eyes and an ingratiating smile. The "inside info" guy who may or may not be trustworthy. Background: blurred betting hall. 512x768 vertical. Lo-fi realism, painterly.
```

### 홀덤 클럽 (HoldemClub)

#### `assets/ui/card_back.png`
```
Playing card back design. Dark navy background with a subtle geometric Korean traditional pattern (단청-inspired, not ornate). A thin gold border. Simple, elegant, slightly underground aesthetic. 256x358 PNG.
```

#### `assets/ui/poker_chip_icon.png`
```
A single poker chip icon, top-down view. Dark red and gold color scheme. Simple graphic, clean edges. 128x128 PNG on transparent background.
```

### 아르바이트 (ArubaGame)

#### `assets/backgrounds/aruba_delivery_street.png`
```
A Seoul street at night from the perspective of a delivery rider. A smartphone mounted on handlebars showing a delivery app map. Blurred apartment buildings and streetlights ahead. The cold, lonely urgency of gig work at 11pm. Dark with sodium streetlight orange and app screen blue-white. 1280x800. Lo-fi realism.
```

---

## Part 5 — Steam 스토어 에셋

### 캡슐 이미지들 (텍스트 없이 생성 → Canva/Photoshop에서 로고 얹기)

#### `assets/keyart/steam_capsule_main.png` (616×353)
```
Key art for a Korean noir life-sim game. A lone Korean man in his early 30s (same character as portrait series — casual clothing, dark circles) standing at the edge of a Seoul rooftop at night, back to the viewer. The sprawling Seoul city lights stretch below — Gangnam's illuminated towers in the distance. The gap between where he stands and where he wants to be is visually vast. Mood: determined, lonely, cinematic. Dark charcoal and navy with warm city lights below. No text. 616x353. Painterly lo-fi realism.
```

#### `assets/keyart/steam_capsule_small.png` (231×87)
```
Cropped/zoomed version of the above key art focusing on the character silhouette against the Seoul skyline. Very dark with the city lights as the main visual element. No text. 231x87. Same style.
```

#### `assets/keyart/steam_header.png` (460×215)
```
Wider cinematic version of the key art. Korean man on the rooftop silhouetted. Seoul skyline wider and more panoramic. The distance to Gangnam towers emphasized. No text. 460x215. Same painterly noir style.
```

### 스크린샷용 배경 (실제 게임 스크린샷을 찍을 장면)
```
1. 시작 화면 — 직업 선택 카드 5종 (StartMenu)
2. 이벤트 화면 — 강남 야경 배경 + 선택지
3. 경마장 미니게임 화면
4. 인포 패널 — 📖 아크 탭
5. 엔딩 화면 — 강남드림 달성
```

---

## Part 6 — 기술 스펙 요약

| 카테고리 | 해상도 | 포맷 | 저장 경로 |
|---|---|---|---|
| 배경 이미지 | 1280×800 | PNG | `assets/backgrounds/` |
| 캐릭터 초상화 | 512×768 | PNG | `assets/characters/` |
| UI 아이콘 | 128×128 or 256×256 | PNG (투명) | `assets/ui/` |
| Steam 캡슐 메인 | 616×353 | PNG | `assets/keyart/` |
| Steam 캡슐 소형 | 231×87 | PNG | `assets/keyart/` |
| Steam 헤더 | 460×215 | PNG | `assets/keyart/` |
| 앱 아이콘 | 1024×1024 | PNG | 프로젝트 루트 `icon.png` |

### Godot import 주의
- 새 파일 저장 후 Godot 에디터에서 **FileSystem → Reimport** 필요
- 또는 기존 `.import` 파일이 있으면 PNG만 교체해도 자동 재임포트됨

---

## Part 7 — 우선순위

| 순위 | 항목 | 이유 |
|---|---|---|
| **1** | 주인공 초상화 7종 교체 | 현재 이미지가 완전히 잘못됨 (중년 정장) |
| **2** | NPC 4종 신규 | 대화/관계 이벤트에 얼굴 없음 |
| **3** | 배경 신규 6종 | 미니게임 배경 없음 |
| **4** | 기존 배경 19종 재생성 | 품질 개선 |
| **5** | 미니게임 UI 에셋 | 카드, 칩, 말 실루엣 |
| **6** | Steam 키아트 3종 | 스토어 등록용 |

---

## Part 8 — Godot 코드 연동 참고

```gdscript
# scenes/MainGame.gd 에서 배경 매핑 (추가 필요)
# _get_bg_for_event() 함수 참고

# 신규 배경 매핑 예시:
"racetrack_betting_hall" → RaceTrack 미니게임 베팅 화면
"racetrack_track_view"   → RaceTrack 미니게임 레이스 화면
"holdem_club_interior"   → HoldemClub 미니게임 배경
"scalping_trading_room"  → ScalpingGame 미니게임 배경
"pc_bang_interior"       → PC방 관련 이벤트

# scenes/RaceTrack.gd → 배경 이미지 적용 위치 확인 필요
# scenes/HoldemClub.gd → 배경 이미지 적용 위치 확인 필요
```

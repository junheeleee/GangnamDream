# Gangnam Dream — AI 이미지 생성 프롬프트

> Legacy prompt collection. For production work, first apply `docs/CANON_MAP.md`, `docs/ASSET_CONTINUITY_CHECKLIST.md`, `docs/ASSET_QA.md`, and `assets/VISUAL_AUDIO_UPGRADE_BRIEF.md`. If an older prompt below conflicts with those files, the newer canon wins.

## 스타일 가이드 (모든 이미지에 공통 적용)

**Base Style Suffix** (모든 프롬프트 끝에 붙이기):
```
Korean webtoon-inspired semi-realistic digital illustration, dark desaturated palette, 
moody urban Seoul atmosphere, cinematic lighting, slightly overcast or night-time feel, 
subtle neon reflections, melancholic yet sharp tone, no text, no watermark, 
high detail, atmospheric depth
```

**배경 이미지 규격**: 1920×1080 (16:9 landscape)  
**캐릭터/NPC 초상화 규격**: 512×768 또는 768×1024 (portrait)  
**저장 위치**: `assets/backgrounds/`, `assets/characters/`

---

## 배경 이미지 (신규 10종)

### 1. `convenience_store_night.png`
**용도**: `comedy`, `disaster`, `late_night` 태그 이벤트  
**저장**: `assets/backgrounds/convenience_store_night.png`

```
Interior of a Korean convenience store at 2AM, bright fluorescent lighting, 
rows of ramen cups and triangle kimbap, lone young Korean man at a standing table 
eating alone, rain visible through large glass windows, empty streets outside, 
GS25 or CU aesthetic without logos, warm yellow-white light inside contrasting 
cold blue night outside
```

---

### 2. `cafe_afternoon.png`
**용도**: `romance`, `social_life` 소개팅/만남 이벤트  
**저장**: `assets/backgrounds/cafe_afternoon.png`

```
Cozy Korean specialty coffee shop interior, afternoon natural light through large 
windows, wooden furniture, plants, two empty chairs across a small table with 
two coffee cups, soft golden hour light casting long shadows, Seoul urban street 
visible through window, quiet and intimate atmosphere
```

---

### 3. `hospital_waiting_room.png`
**용도**: `health` 카테고리 이벤트  
**저장**: `assets/backgrounds/hospital_waiting_room.png`

```
Korean hospital waiting room, rows of blue plastic chairs, fluorescent overhead 
lighting, a number display screen showing queue numbers, a few blurred 
silhouettes of patients waiting, clean sterile white walls, antiseptic atmosphere, 
slightly cold and anxious feel
```

---

### 4. `family_living_room.png`
**용도**: 민준 가족/아버지 고향집 전용 배경. 2026-06-12 재생성 후 production 가족 배경에 재연결됨.
**저장**: `assets/backgrounds/family_living_room.png`

```
Modest older working-class living room in Changwon, Korea, belonging to
Kim Minjun's father. Small old sofa, scuffed wooden TV cabinet, cheap wall clock,
folding table with two tea cups, worn wallpaper, quiet absence and guilt.
At most one small faded photo of young father, mother, and Minjun; no extended
family portrait, no happy large household, no luxury apartment, no scenic window.
Warm but muted evening light, restrained Korean visual novel background art.
```

---

### 5. `trading_screen_night.png`
**용도**: 스캘핑/퀀트/후반 전문 투자 장면 전용. 일반 투자/초반 고시원 투자는 `investment_phone.png` 사용.
**저장**: `assets/backgrounds/trading_screen_night.png`

```
Dark room lit only by the glow of multiple monitor screens showing stock charts 
and cryptocurrency price graphs, red and green candles on charts, Korean financial 
app interfaces, coffee cup on desk, smartphone showing trading app, 
late night trading atmosphere, blue-green monitor glow on face of empty chair, 
tense focused atmosphere
```

---

### 6. `gangnam_street_night.png`
**용도**: `drama` 대형 이벤트, `class`, `opportunity` 태그  
**저장**: `assets/backgrounds/gangnam_street_night.png`

```
Gangnam district Seoul street at night, wide boulevard with luxury car dealerships 
and high-rise apartment buildings, neon signs and bright storefronts, 
well-dressed pedestrians blurred in motion, wet pavement reflecting city lights, 
aspirational yet alienating atmosphere, cold blue and warm orange contrast, 
cinematic wide shot
```

---

### 7. `pc_bang_interior.png`
**용도**: `gambling`, `comedy`, 심야 이벤트  
**저장**: `assets/backgrounds/pc_bang_interior.png`

```
Korean PC room interior at night, rows of gaming chairs and high-spec monitors, 
blue-purple RGB lighting, empty chairs at most stations, one or two blurred 
silhouettes playing games, food smell and energy drinks on desk, 
slightly dingy fluorescent overhead lights mixed with colorful monitor glow, 
late night atmosphere
```

---

### 8. `rooftop_dawn.png`
**용도**: `hidden` 레전더리 이벤트, 결정적 순간  
**저장**: `assets/backgrounds/rooftop_dawn.png`

```
Seoul rooftop at dawn, low-rise older buildings surrounding, distant skyscrapers 
in the horizon, soft pink and orange sunrise sky, city just waking up, 
laundry lines and satellite dishes visible on nearby rooftops, 
water tower in distance, melancholic hopeful atmosphere, 
thin morning mist over the city
```

---

### 9. `subway_platform_rush.png`
**용도**: `disasters`, `commute`, `jobs` 아침 출근 이벤트  
**저장**: `assets/backgrounds/subway_platform_rush.png`

```
Seoul subway platform during morning rush hour, line 2 green aesthetic, 
crowds of commuters in suits and masks waiting for train, yellow safety line 
on platform edge, bright fluorescent station lighting, departure board showing 
Korean station names, train arriving with lit windows, overwhelming density 
of people, slightly claustrophobic atmosphere
```

---

### 10. `military_training_ground.png`
**용도**: `military` 카테고리 이벤트  
**저장**: `assets/backgrounds/military_training_ground.png`

```
South Korean military training ground at dusk, row of barracks in background, 
Korean flag visible, empty parade ground with faded white lines, 
mountains visible in distance, overcast sky, khaki and gray color palette, 
distant sound of bugle implied by atmosphere, nostalgic and slightly oppressive mood
```

---

## NPC 초상화 (신규 6종)

초상화 스타일: 상반신 위주, 배경 흐림 또는 단색, 표정이 성격을 드러내도록.

---

### NPC-1. `npc_close_friend.png`
**관계 타입**: `friends` — 고시원 옆방 공시생 후배
**저장**: `assets/characters/npc_close_friend.png`

```
Transparent visual novel portrait of a Korean man age 26-27, chubby but
likable civil-service-exam student, round wire-frame glasses, messy medium
black hair, olive-gray hoodie over a muted burgundy striped shirt, awkward
warm half-smile with a hint of exam fatigue, no background, no props,
Korean manhwa VN style, no text
```

---

### NPC-2. `npc_romantic_interest.png`
**관계 타입**: `romantic` — 연애 상대  
**저장**: `assets/characters/npc_romantic_interest.png`

```
Portrait of a young Korean woman in her mid-20s, neat office casual attire, 
guarded but curious expression, subtle makeup, hair slightly windswept, 
background blurred to warm amber bokeh suggesting a cafe, 
semi-realistic Korean webtoon style, no text
```

---

### NPC-3. `npc_coworker.png`
**관계 타입**: `coworkers` — 직장 동료  
**저장**: `assets/characters/npc_coworker.png`

```
Portrait of a young Korean woman in her late 20s, business casual attire 
(blazer over white shirt), politely professional expression with eyes that 
suggest she knows more than she lets on, neat tied-back hair, 
background blurred to cold office fluorescent blue-white, 
semi-realistic Korean webtoon style, no text
```

---

### NPC-4. `npc_mentor.png`
**관계 타입**: `jiyeon` — 한지연 legacy path / 위험한 로맨스 히로인
**저장**: `assets/characters/npc_mentor.png`

```
Transparent-background portrait of Han Jiyeon, a Korean woman age 31,
wealthy Gangnam heiress and dangerous romance heroine, beautiful and alluring
but slightly unsafe, long black or very dark brown hair, sharp intelligent eyes,
tailored cream or black suit, subtle old-money jewelry, no office or cafe background,
no short bob, no middle-aged look, semi-realistic Korean webtoon style, no text
```

---

### NPC-5. `npc_chaebol.png`
**관계 타입**: `business` — 재벌 인맥  
**저장**: `assets/characters/npc_chaebol.png`

```
Portrait of a young Korean man in his late 20s to early 30s, clearly wealthy 
without being flashy, high-end minimal clothing, handsome but slightly cold 
expression, perfect posture, background blurred to dark luxury interior 
(marble and dim lighting), semi-realistic Korean webtoon style, no text
```

---

### NPC-6. `npc_boss.png`
**관계 타입**: `authority` — 팀장/상사  
**저장**: `assets/characters/npc_boss.png`

```
Portrait of a Korean man in his early 40s, slightly tired-looking but 
commanding, ill-fitting department store suit, receding hairline, 
reading glasses pushed up on forehead, expression of permanent mild disappointment, 
background blurred to office fluorescent lighting, 
semi-realistic Korean webtoon style, no text
```

---

## 추가 캐릭터 (주인공 확장)

현재 4종 → 추가 2종 권장:

### CHAR-5. `main_character_broke.png`
**조건**: `money < 500,000` 또는 `housing == "gosiwon"` + 초반
```
Young Korean man in his early 20s, worn casual clothes (faded t-shirt), 
hollow cheeks, tired eyes with dark circles, slight unshaven stubble, 
sitting posture suggests exhaustion and worry, background goshiwon room 
(bare white wall), semi-realistic Korean webtoon style
```

### CHAR-6. `main_character_wealthy.png`
**조건**: `money > 500,000,000` 또는 milestone 달성
```
Young Korean man in his late 20s to early 30s, clean fitted clothing 
(quality but not flashy), healthy complexion, calm confident expression 
with a subtle distance in the eyes, suggests success but also isolation, 
background blurred to luxury apartment interior, semi-realistic Korean webtoon style
```

---

## 코드 연동 계획

새 배경 추가 후 `MainGame.gd`의 `_get_bg_for_event()` 수정:

```gdscript
# 추가할 태그 매핑
if "health" in tags or "medical" in tags:
    return "res://assets/backgrounds/hospital_waiting_room.png"
if "romance" in tags:
    return "res://assets/backgrounds/cafe_afternoon.png"
if "family" in tags:
    return "res://assets/backgrounds/restaurant_korean.png" # temporary until canon family home exists
if "finance" in tags or "investment" in tags or "gambling" in tags:
    return "res://assets/backgrounds/investment_phone.png"
if "scalping" in tags or "pro_trading" in tags:
    return "res://assets/backgrounds/trading_screen_night.png"
if "military" in tags:
    return "res://assets/backgrounds/military_training_ground.png"
if "comedy" in tags or "disaster" in tags:
    return "res://assets/backgrounds/convenience_store_night.png"
if "opportunity" in tags or "class" in tags:
    return "res://assets/backgrounds/gangnam_street_night.png"
if "hidden" in tags and ev.get("rarity") in ["legendary", "rare"]:
    return "res://assets/backgrounds/rooftop_dawn.png"
```

NPC 초상화 연동은 `RelationshipSystem.gd` 또는 관계 패널 UI에서  
`type` 필드 기반으로 초상화 경로를 리턴하는 함수 추가.

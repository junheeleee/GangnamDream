# Gangnam Dream Image Prompts

GPT(DALL-E / GPT-4o)에 아래 프롬프트를 순서대로 전달해서 이미지를 생성한다.
생성 후 해당 경로에 저장한다.

---

## 공통 스타일 가이드 (모든 이미지에 적용)

- **장르**: Korean modern-life, lo-fi realism, Seoul youth anxiety aesthetic
- **팔레트**: dark charcoal base, muted navy, warm gold accent, cool-blue highlights. No bright oversaturation.
- **금지**: sci-fi UI, glowing orbit rings, magical effects, anime-style exaggeration, vibrant oversaturated colors
- **해상도**: 배경 1280×800 / 캐릭터 초상화 400×600 / 아이콘 1024×1024

---

## 배경 이미지 (Backgrounds)

### convenience_store_night.png
**저장 경로**: `assets/backgrounds/convenience_store_night.png`

```
Interior of a Korean convenience store at midnight. Rows of triangle kimbap, cup ramen, and lunchboxes in a cold fluorescent-lit refrigerator aisle. A drowsy part-time worker silhouette barely visible behind the counter. Rain streaking the window outside, a single streetlight glowing on wet asphalt. No customers or only a back-view silhouette. Lonely and hollow 4am atmosphere. Dark charcoal palette with cold white fluorescent light. Lo-fi realism, Seoul youth, no anime style.
```

**용도**: `comedy`, `health`, `night` 태그 이벤트 배경

---

### cafe_seoul.png
**저장 경로**: `assets/backgrounds/cafe_seoul.png`

```
Interior of a small Seoul café near Hongdae. A two-person wooden table by the window, one Americano, an open laptop or empty chair. Outside the window, blurred Seoul alley and rain. Warm amber lighting mixed with cool daylight. Cozy but slightly lonely solo afternoon. Dark and restrained palette, warm amber tones with navy shadows. Lo-fi realism, no anime style.
```

**용도**: `social`, `relationship`, `date` 태그 이벤트 배경

---

### investment_phone.png
**저장 경로**: `assets/backgrounds/investment_phone.png`

```
Close-up of a smartphone on a desk showing a stock or crypto candlestick chart app. Red and green percentage figures clearly visible on the screen. A cold coffee cup and blurred city night skyline reflected on the desk surface. A finger hovering over the screen about to tap. The phone screen glow is the only light source in a dark room. Feeling of investment anxiety and late-night obsession. Dark background, screen glow in cool blue and red-green accents. Lo-fi realism, no anime style.
```

**용도**: `investment`, `finance` 카테고리 이벤트 배경

---

### hospital_corridor.png
**저장 경로**: `assets/backgrounds/hospital_corridor.png`

```
Long corridor of a Korean general hospital at night or early morning. Fluorescent lights stretching into the distance along white walls. A nurse silhouette hurrying far away. An IV stand and empty wheelchair visible. Nobody close by. Cold and silent. The feeling of life coming to a halt. Pale cold white and charcoal palette. Lo-fi realism, no anime style.
```

**용도**: `health`, `disaster` 태그 이벤트 배경

---

### rooftop_daytime.png
**저장 경로**: `assets/backgrounds/rooftop_daytime.png`

```
Rooftop of an old Seoul villa building during the day under an overcast grey sky. A water tank, a laundry rack with a shirt hanging. Seoul's dense cityscape of buildings visible in the distance under hazy air. Wind implied by slight motion. First-person POV as if someone climbed up to take a break. The same rooftop as the keyart but daytime, exhausted but beautiful Seoul. Muted grey and warm ochre palette. Lo-fi realism, no anime style.
```

**용도**: 기존 rooftop keyart의 낮 변형. `politics`, `romance`, `break` 이벤트

---

### gangnam_night_street.png
**저장 경로**: `assets/backgrounds/gangnam_night_street.png`

```
Gangnam Station night street. Neon signs, crowds with umbrellas, rain-soaked asphalt reflecting neon light. Luxury building facades, taxis, suited office workers. The player's POV or a lone back-view figure in the crowd feeling like an outsider. Glamorous but alienating — a city for people who have already made it. Dark navy with neon accent highlights. Lo-fi realism, no anime style.
```

**용도**: 후반 이벤트, `reputation`, `finance` 고급 분기

---

### penthouse_view.png
**저장 경로**: `assets/backgrounds/penthouse_view.png`

```
Floor-to-ceiling window of a Gangnam high-rise penthouse at night. The full Seoul skyline spread below. Minimal luxury interior — a single sofa edge, a wine glass, or a lone silhouette standing with their back to us. Reached the top but feels empty. Bittersweet triumph. Dark background with soft warm interior light and glittering city lights outside. Lo-fi realism, no anime style.
```

**용도**: `gangnam_dream` 엔딩 배경

---

### burnout_hospital_room.png
**저장 경로**: `assets/backgrounds/burnout_hospital_room.png`

```
A hospital patient room, single bed. An IV drip bag hanging, white curtain partitioning, pale daylight through a small window showing a grey Seoul sky. Nobody else in the room. Personal belongings on the side table — phone face-down, a water cup. The feeling of everything having stopped. Cold white and pale grey palette. Lo-fi realism, no anime style.
```

**용도**: `burnout`, `mental_break` 엔딩 배경

---

## 캐릭터 초상화 (Character Portraits)

### main_character_shocked.png
**저장 경로**: `assets/characters/main_character_shocked.png`

```
Portrait of a Korean male in his mid-20s, same character as the existing neutral/tired/determined/happy series. He is holding a smartphone with both hands, eyes wide open in shock, mouth slightly open. Could be terrible news or an unexpected windfall — ambiguous. Goshiwon room background consistent with the existing character portrait series. Same art style as the existing four portraits. 400x600 vertical format. Lo-fi realism Korean webtoon style, no anime exaggeration.
```

**용도**: 크리티컬 이벤트, 히든 이벤트, 대형 손실/수익 발생 시

---

## 앱 아이콘

### icon.png
**저장 경로**: `icon.png` (프로젝트 루트)

```
App icon for a Korean mobile roguelike game called 강남드림 (Gangnam Dream). Dark charcoal background. Seoul building skyline silhouette at the bottom. The Korean text 강남드림 in a bold clean font centered. Warm gold and cool blue accent colors. Minimalist and clean enough to read at small sizes. No people, no characters — just the title and cityscape. 1024x1024. Modern Korean indie game aesthetic.
```

**용도**: Godot 프로젝트 아이콘, 스토어 아이콘

---

## Godot 연동 메모

배경 이미지 추가 후 `scenes/MainGame.gd`의 `_get_bg_for_event()` 함수에 태그 매핑 추가:

```gdscript
if "convenience" in tags or ("night" in tags and "food" in tags):
    return "res://assets/backgrounds/convenience_store_night.png"
if "social" in tags or "date" in tags or "cafe" in tags:
    return "res://assets/backgrounds/cafe_seoul.png"
if "investment" in tags or (category == "finance" and "stock" in tags):
    return "res://assets/backgrounds/investment_phone.png"
if "hospital" in tags or "health" in tags:
    return "res://assets/backgrounds/hospital_corridor.png"
```

캐릭터 초상화 추가 후 `_get_portrait_path()` 함수에 조건 추가:

```gdscript
if GameState.flags.get("just_critical_event", false):
    return "res://assets/characters/main_character_shocked.png"
```

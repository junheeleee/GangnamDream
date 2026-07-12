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
Floor-to-ceiling window of a Gangnam high-rise penthouse at night. The full Seoul skyline spread below. Minimal luxury interior, empty room, no person, no silhouette, no back-view figure. Reached the top but feels empty through the absence of people. Bittersweet triumph. Dark background with soft warm interior light and glittering city lights outside. Lo-fi realism, no anime style.
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
App icon for a Korean interactive drama / life sim called 강남드림 (Gangnam Dream). Dark charcoal background. Seoul building skyline silhouette at the bottom. The Korean text 강남드림 in a bold clean font centered. Warm gold and cool blue accent colors. Minimalist and clean enough to read at small sizes. No people, no characters — just the title and cityscape. 1024x1024. Modern Korean indie game aesthetic.
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

---

## 2026-07-12 카페 인물 분리 초상

두 초상은 Codex 내장 ImageGen으로 각각 생성한 뒤, 단색 `#00ff00` 배경을 알파로 제거하고 512x768로 축소했다. 외부 사진이나 실존 인물 레퍼런스는 사용하지 않았다.

### npc_cafe_investor.png

- **최종 경로**: `assets/characters/npc_cafe_investor.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-6b02368e-da19-4fa3-b426-665c2fa9dccc.png`
- **용도**: 카페에서 민준이 폴더를 보다가 마주치는 익명의 투자자. 폴더 속 `김 부장`과 다른 사람이다.
- **최종 프롬프트**:

```text
Use case: illustration-story
Asset type: transparent Korean visual-novel character portrait, recurring minor NPC
Primary request: a distinctive 39-year-old Korean male property investor who owns the black folio in the Gangnam cafe scene
Subject: lean build, angular face, narrow monolid eyes, swept-back natural black hair, composed and perceptive expression; charcoal micro-check suit over a deep teal open-collar knit polo; holding one blank black document folio at waist level
Style/medium: serious Korean modern-life VN/manhwa illustration in the Gangnam Ink house style; restrained realism, clean controlled linework, painterly cel shading, believable anatomy, mature proportions, no photorealism
Composition/framing: transparent portrait cutout, head to upper thighs, body on screen right and gaze directed screen-left toward Minjun, full hair and both hands visible, generous padding
Lighting/mood: cool Seoul cafe light with a restrained warm rim; quietly intimidating, observant rather than villainous
Color palette: charcoal, muted deep teal, neutral Korean skin tones, low saturation
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background with no shadow, gradient, texture, reflection, or floor plane
Constraints: one person only; identity must be clearly different from Team Lead, Sangchul, Jaehyuk, and Manager Kim; blank folio with no writing or logo; crisp silhouette; no cast shadow; no text; no watermark; do not use #00ff00 on the subject
Avoid: generic handsome lead, broad stocky body, glasses, tie, phone, smile, deformed fingers, extra limbs, fake lettering
```

### npc_cafe_broker_kim.png

- **최종 경로**: `assets/characters/npc_cafe_broker_kim.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-ef0f535b-622b-4a84-bbb2-f8453ad17d20.png`
- **용도**: 폴더에 적힌 번호의 부동산 브로커 `김 부장 / Manager Kim`. 폴더 주인과 다른 사람이다.
- **최종 프롬프트**:

```text
Use case: illustration-story
Asset type: transparent Korean visual-novel character portrait, recurring minor NPC
Primary request: a distinctive 45-year-old Korean male property broker called Manager Kim, the man reached through the phone number inside another investor's folio
Subject: broad stocky build, round-square face, short close side-parted black hair, small mole on one cheek, practiced sales smile that does not reach the eyes; taupe blazer over an oxblood knit shirt; holding one blank black smartphone naturally near his torso
Style/medium: serious Korean modern-life VN/manhwa illustration in the Gangnam Ink house style; restrained realism, clean controlled linework, painterly cel shading, believable anatomy, mature proportions, no photorealism
Composition/framing: transparent portrait cutout, head to upper thighs, body on screen right and gaze directed screen-left toward Minjun, full hair and both hands visible, generous padding
Lighting/mood: neutral indoor light with a restrained warm edge; commercially friendly but calculating
Color palette: taupe, muted oxblood, charcoal, neutral Korean skin tones, low saturation
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background with no shadow, gradient, texture, reflection, or floor plane
Constraints: one person only; identity must be clearly different from the lean cafe investor, Team Lead, Sangchul, and Jaehyuk; phone screen blank with no UI, writing, or logo; crisp silhouette; no cast shadow; no text; no watermark; do not use #00ff00 on the subject
Avoid: angular lean body, teal shirt, document folio, glasses, tie, exaggerated grin, deformed fingers, extra limbs, fake lettering
```

### 후처리 기록

```text
remove_chroma_key.py --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill --edge-contract 1
sips -z 768 512
```

- 두 최종 PNG는 RGBA, 512x768이며 네 모서리 alpha=0을 확인했다.
- 폴더 주인은 키 컬러 잔류 0픽셀, 김 부장은 완전 투명에 가까운 alpha=1 잔류 2픽셀만 있어 실제 합성에서 프린지가 보이지 않는다.
- 상용 배포 전에는 사용한 생성 서비스의 당시 이용 약관과 계정 권리 범위를 별도 출시 증빙에 보관한다.

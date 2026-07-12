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

---

## 2026-07-12 strict 이벤트 비주얼 부채 0 패스

세 자산은 Codex 내장 ImageGen으로 제작했다. 외부 사진은 사용하지 않았고, 설날 CG만 프로젝트의 정본 배경/인물 파일을 입력 레퍼런스로 사용했다. 최종 출력은 중앙 1536x960 크롭 후 1280x800 PNG로 정규화했다.

공통 스타일 문장:

```text
Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, controlled linework with painterly cel shading, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood.
```

### seoul_bus_stop_wallet.png

- **최종 경로**: `assets/backgrounds/seoul_bus_stop_wallet.png`
- **최종 생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-3ddf43b2-a2c0-4499-8341-8f6ebd28e894.png`
- **이전 교정 원본**:
  - `exec-59f2a10b-a2d4-4e68-b74b-5c4154ecd8cf.png`: 벤치가 도로 옆을 향해 물리 구조 탈락.
  - `exec-d5ae909c-2686-41c2-94f8-f080defff7d2.png`: 도로 방향은 합격했지만 지갑이 대사창 아래로 내려가 크롭 탈락.
  - `exec-68b702f0-6cad-4e09-b75d-b3e048135dee.png`: 좌석면이 카메라 쪽으로 읽혀 도로 반대 방향처럼 보이는 시각적 모호성으로 탈락.
  - `exec-3de8df09-9f81-4efa-bab5-d78103f13d67.png`: 등받이 뒤/좌석면 구분이 여전히 약해 방향 판독이 모호해 탈락.
- **최종 프롬프트 체인**:

```text
Create a modern Seoul neighborhood bus shelter at player eye level after light rain. The road, curb, bus lane, tactile paving, front glass windbreak, and open boarding doorway must form one physically usable axis. The three-seat bench runs parallel to the curb and its occupants would face the road; show the back of the bench from a rear-left interior camera position. Exactly one small worn black wallet lies under the bench. No people, bus, CCTV, route map, readable sign, text, brand, logo, or watermark.

Then reframe without changing the corrected geometry: pull the camera farther back and slightly higher. Keep the complete bench and wallet in the upper-middle, with the wallet entirely above 62% image height, and leave the lower 35% as noncritical empty shelter floor for the visual-novel dialogue panel. Preserve the rainy Seoul exterior and the bench's road-facing direction.

Finally make the orientation physically unmistakable: show the bench from behind and slightly from its left rear corner. The broad wooden backrest must sit between the camera and the seat; no sitting surface may project toward the camera. The seat plane projects only toward the road-facing glass/open boarding side, visible as a narrow side-profile sliver beyond the right/front edge of the backrest. Keep the wallet visible under the rear side of the bench.
```

- **합격 기준**: 카메라가 등받이의 뒷면을 보고 좌석면은 도로 쪽으로만 뻗는다. 벤치 등받이→전면 유리→열린 승차구→점자블록→연석→차로가 한 시선축에 있고, 실제 1280x800 도입/선택지 화면에서 지갑 전체가 UI 위에 남는다.

### winter_bungeoppang_stall.png

- **최종 경로**: `assets/backgrounds/winter_bungeoppang_stall.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-5cdc2cea-293d-4f4c-bfee-5f112aa6ce34.png`
- **최종 프롬프트**:

```text
Create a modest low-rise Seoul alley at winter blue hour. On the screen-left corner, a compact wheeled bungeoppang cart clearly shows cast-iron fish-shaped pastry molds, several finished red-bean pastries, brown paper bags, a steaming fish-cake broth pot, and plain paper cups. A bundled anonymous vendor remains a dark side/back-view silhouette with face obscured by hat and steam. Sparse snow and salt stay at the curb; one or two distant back-view silhouettes may appear far down the alley. Keep the cart, food hardware, steam, and vendor in the upper-safe left/center and reserve the right third for Minjun's separate winter portrait. No protagonist, clear recurring face, readable menu, prices, text, brand, logo, or watermark. Avoid a Japanese festival stall, food truck, Christmas decoration, fake lettering, or empty abandoned cart.
```

- **합격 기준**: 붕어빵 틀·완성 빵·어묵 국물·김이 1초 안에 읽히며, 상인은 배경 인물로만 남고 실제 도입/선택지 화면에서 민준 초상과 충돌하지 않는다.

### seollal_sebae_family_v1.png

- **최종 경로**: `assets/cg/seollal_sebae_family_v1.png`
- **입력 레퍼런스**:
  - `assets/backgrounds/family_living_room.png`: 창원 집 구조/계급 신호.
  - `assets/characters/main_character_neutral_goshiwon.png`: 민준 얼굴·헤어·검은 크루넥.
  - `assets/characters/npc_father.png`: 아버지 얼굴·작업복.
- **최종 생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-a0fc71df-3735-48ac-8bc7-b9db16d1dacb.png`
- **이전 교정 원본**:
  - `exec-ff2a1e4d-45f9-4e20-84a9-108dafa8934c.png`: 민준의 두 손이 벌어진 일반 엎드림이라 세배 동작 탈락.
  - `exec-54bc9b0d-236e-43da-9290-ca072b779f62.png`: 겹친 손은 합격했지만 핵심 동작이 대사창 아래로 내려가 크롭 탈락.
- **최종 프롬프트 체인**:

```text
Using the canonical Changwon living room as the exact layout reference and the supplied Minjun/Father images as identity references, stage Seollal morning with exactly four people. Minjun wears the worn black crewneck and performs a formal Korean male sebae; Father sits on the worn screen-left sofa, one older paternal aunt and one older paternal uncle sit on floor cushions at screen-right, and all three look toward Minjun. Mother is not present. A small plain cream money envelope and modest Seollal dishes sit on the low table. Preserve the sofa, low table, TV, rear entry, cramped proportions, old wallpaper, and working-class tier. No hanbok, Chinese red envelope, large intact-family portrait, luxury furniture, text, logo, or watermark.

Correct Minjun's deepest bow so both knees are grounded, the two hands are neatly stacked/overlapped directly before his head, elbows bend naturally, and his forehead lowers toward the back of the stacked hands. It must not read as crawling, a push-up, or Islamic prostration.

Finally pull the camera farther back and slightly higher without changing identities or the bow. Place Minjun's head, stacked hands, elbows, the low table, and envelope entirely above 62% image height; leave the bottom 32% as quiet empty wooden floor for the dialogue panel. Keep faces readable and all gazes off-lens.
```

- **합격 기준**: 기존 집·민준·아버지 동일성, 어머니 부재, 정확히 네 사람, 한국식 세배 손/무릎/이마, 세 어른의 민준 향한 시선, 하단 UI 안전 영역을 모두 만족한다.

### 후처리와 검증

```text
sips --cropToHeightWidth 960 1536
sips --resampleHeightWidth 800 1280
```

- Godot 4.6.2 재임포트 후 KO/EN `--qa=event-visuals` 각 41장으로 도입/선택지 크롭을 확인했다.
- `event_visual_contract_check.py --strict`는 54개 잠금, 부채 0으로 통과했다.
- `cg_acting_contract_check.py`는 활성 CG 29장과 배우 계약 54개를 누락/고아 0으로 통과했다.
- 상용 배포 전에는 사용한 생성 서비스의 당시 이용 약관과 계정 권리 범위를 별도 출시 증빙에 보관한다.

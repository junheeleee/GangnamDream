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

## 2026-08-04 ORDER-83 — 주거복지 상담사 초상

- **최종 경로**: `assets/characters/npc_housing_counselor.png`
- **생성 방식**: Codex 내장 ImageGen
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-3d90daf2-2cf3-459f-a420-80f06add1f73.png`
- **원본/최종**: 1023x1537 RGB chroma-key 원본 → 1023x1537 RGBA 초상
- **최종 SHA-256**: `47fa4926baa149933ddf824fc908976f5405dfafcaeed118a76ebe398c65779d`

최종 프롬프트:

```text
Use case: stylized-concept
Asset type: visual-novel game character portrait cutout for Gangnam Dream
Primary request: create one original Korean public housing welfare counselor for a grounded contemporary Seoul drama, an unnamed woman in her late 40s whose practical attentiveness feels credible rather than glamorous
Subject: Korean woman, late 40s, calm observant face with ordinary skin texture and faint age lines, neat short-to-medium dark hair, understated navy-gray cardigan over a pale blouse, simple municipal-style lanyard with a completely blank card, holding a pen and two unmarked housing consultation sheets at waist level; no readable text or logos
Style/medium: high-quality semi-realistic Korean webtoon/manhwa character render with restrained ink lines, natural anatomy, realistic fabric folds, subtle painterly shading, everyday human imperfections; serious literary film tone, not anime-cute and not a stock-photo look
Composition/framing: single person, three-quarter body portrait from head to below hips, near-front three-quarter pose, gaze slightly toward screen-left as if listening to Minjun across a desk, hands fully visible, generous padding, centered silhouette suitable for a visual novel portrait
Lighting/mood: soft neutral fluorescent public-office light, compassionate but professionally reserved expression, muted cool palette
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for local background removal; one uniform color only, no floor plane
Constraints: crisp complete silhouette, no crop at hair or hands, no cast shadow, no contact shadow, no reflection, no background objects, no words, no logos, no watermark; the background must have no gradients, texture, shadows, or lighting variation; do not use #00ff00 anywhere in the person, clothing, papers, pen, or lanyard
Avoid: glamorous fashion styling, youthful idol face, hospital uniform, corporate executive suit, police uniform, exaggerated smile, melodramatic pose, fantasy elements, extra people, readable badge text
```

내장 도구의 chroma-key 원본을 설치된 `remove_chroma_key.py`로 변환했다.
`--soft-matte --despill --edge-contract 1`을 적용해 머리카락과 옷 가장자리의
녹색 번짐을 줄였고, 최종본은 투명 모서리·완전한 손·빈 명찰·무문자 서류를
원본 해상도에서 확인했다.

---

## 2026-08-04 ORDER-75 — 24주 첫 결산 전용 연출

> 주의: 이 두 문장은 원 ImageGen 호출 기록이 유실된 뒤 결과물·정본·참조
> 입력에서 복원한 **재현 프롬프트**다. 정확한 원문이라고 주장하지 않으며,
> 민준 나이는 2026년 시작 정본인 33세로 정합성 교정했다.

### `v2_first_bill_desk_closeup.png`

- **최종 경로**: `assets/backgrounds/v2_first_bill_desk_closeup.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-25d687d2-d0bf-46c0-89d0-0c3712e485b9.png`
- **최종 편집 원본**: `/Users/junheelee/.codex/generated_images/019fc841-af3c-7442-b2bc-971d6c553cd4/exec-62dbbbde-2fcb-4d0b-ad41-fe4c59f9523b.png`
- **원본/최종**: 1586x992 RGB 편집 원본 → 1280x800 RGB 리사이즈
- **최종 SHA-256**: `bddf7fe462c6b46ab4b9a7d1ff3d02225e59c1e18c61ea2d291c02d03344883b`

재현 프롬프트:

```text
Use case: stylized-concept. Asset type: reusable 16:10 visual-novel event
background, final 1280x800. Use the supplied canonical goshiwon_room as the
exact reference for spatial geometry, materials, class signal, and restrained
color. At 17:52 on Friday, June 26, 2026, show Kim Minjun's goshiwon desk in a
near-frontal close shot from slightly above eye level. On the low desk place
exactly one unbranded smartphone with a bank app open but no legible interface,
one open blank lined notebook, one pen, a few receipts, one water glass, and the
small black task lamp. A strip of the narrow left-wall bed and worn room continues
behind the desk so this is unmistakably the same canonical room. Keep every
object, desk edge, wall switch, bed, and walking path physically coherent.

Gangnam Ink visual language: desaturated Korean social-reality manhwa / visual-
novel realism, concrete gray and charcoal, matte paper grain, restrained ink-
wash contrast, controlled cinematic light. Mix cool late-afternoon window light
with the small warm task lamp. The moment is quiet, pressured, and reckoning-
focused, not spectacular. Reserve the lower 30% as a calm dialogue-safe region.
No person, readable number, legible app UI, handwriting, receipt text, brand,
logo, or watermark. No duplicated phone, pen, or notebook. No exaggerated poverty,
cyberpunk finance imagery, glossy mobile-game finish, or aspirational luxury.
```

최초 출력은 산문에서 이미 열어 둔 은행 앱과 달리 휴대폰이 완전히 꺼진
화면으로 보여 상황 정합 검수에서 탈락했다. 원 프레임을 편집 대상으로
다시 넣고 휴대폰 화면만 다음 프롬프트로 교정했다. 새 편집 원본의
SHA-256은 `3d9db6b4b24e3c24196da86eb35b4fa62bb4dadefcb4a1bb2119ecc742b42312`다.

```text
Use case: precise-object-edit.
Asset type: reusable 16:10 visual-novel event background, final 1280x800.
Input image: the supplied image is the exact edit target.
Primary request: Change only the screen of the single smartphone on the
lower-left side of the desk. Turn that currently black/off screen on and show
an extremely dim, generic, unbranded Korean mobile-banking app state. The
display should emit only a restrained cool gray-blue glow and contain a few
soft abstract interface blocks or dividers that read as a bank app at game
scale, but absolutely no legible letters, numbers, balances, icons, bank name,
brand, logo, or symbol.
Invariants: Preserve every other pixel-level scene fact as closely as possible:
exact 16:10 composition and camera, phone body/position/charging cable, open
notebook, pen, receipt stack, water glass, black task lamp, bed, wall, basket,
wall switch, room geometry, object count, late-afternoon plus lamp lighting,
Gangnam Ink texture/color, and lower dialogue-safe area. Do not move, add,
remove, duplicate, relight, redraw, crop, rotate, or restyle anything except the
phone display surface. Keep exactly one phone, one notebook, and one pen.
Avoid: readable UI or text, numbers, currency, balance, brand, logo, watermark,
bright neon, cyberpunk glow, sci-fi UI, glossy mobile-game styling, changed
receipt marks, changed wall texture, changed lamp light, new props, people.
```

최종본은 휴대폰 단일성·충전선·왼쪽 침대·중앙 수첩·오른쪽 영수증·스탠드·
벽 스위치의 구도를 유지한다. 화면은 켜져 있지만 게임 크롭에서도 읽히는
문자·숫자·잔액·은행명·상표가 없다.

### `main_character_first_bill_decision.png`

- **최종 경로**: `assets/characters/main_character_first_bill_decision.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-8c08e2c4-ac4b-448b-a61d-7ee283bc5bc9.png`
- **참조 정본**: `main_character_neutral_goshiwon.png`,
  `main_character_determined.png`
- **원본/최종**: 1024x1536 RGB 마젠타 크로마 → 크로마 제거 및
  512x768 RGBA 리사이즈
- **최종 SHA-256**: `3a0a0dc3ea0ca92964aba4f3de245313ef40d96957fbf55b39af4166da648339`

재현 프롬프트:

```text
Use case: character-concept/edit. Use the supplied canonical
main_character_neutral and main_character_determined portraits as exact identity
references. Create Kim Minjun, a 33-year-old Korean man in 2026, wearing the same
plain worn black crewneck. Chest-up three-quarter frontal composition. His eyes
look downward toward a notebook outside the portrait; mouth closed, jaw quietly
set, deciding without performance. He is not heroic, angry, villainous, or
despairing. Preserve the existing face shape, eye shape, nose, mouth, short messy
black hair, lean build, age, and clothing silhouette exactly.

Match Gangnam Ink's desaturated gray-charcoal palette, matte paper grain,
restrained ink line, and the existing in-game portrait lighting, saturation, and
line weight. Prepare for a final 512x768 transparent RGBA portrait by using one
perfectly flat #ff00ff chroma field outside the subject. No full body, hands,
prop, room, text, logo, watermark, jewelry, new accessory, glossy mobile-game
rendering, or photoreal DSLR treatment.
```

`assets/FIRST_BILL_VISUAL_BIBLE.md` 가 최종 프레임·소품·연기·크롭 판정을
소유한다. 출시 전에는 생성 서비스의 당시 이용 약관과 계정 권리 범위를
별도 증빙에 보관한다.

---

## 2026-07-24 정본 보충 — 1·3·5년 인물 외형

아래 보충은 이 문서의 초기 `no anime style` 메모보다 우선한다. 현재
출시 정본은 `assets/CHARACTER_VISUAL_BIBLE.md`와
`assets/CAST_TIME_VISUAL_BIBLE.md`의 절제된 반실사 한국 만화/VN 화풍이다.

### 공통 제작 프롬프트

```text
Create a transparent 1024x1536 recurring-character portrait for Gangnam Dream.
Preserve the supplied y1 identity exactly: facial proportions, eye shape, nose,
mouth, hairline, body type, signature silhouette, and social-class signal.
Match the current restrained semi-realistic Korean manhwa / premium visual-novel
painting: controlled linework, visible soft brush texture, natural anatomy,
muted neutral color, no glossy mobile-game finish.

This is the same person at the requested y3 or y5 anchor, only two or four years
later. Show time through grooming, posture, eye clarity or fatigue, clothing
maintenance, and practiced confidence. Do not use dramatic wrinkles, sudden gray
hair, weight loss, beauty surgery, a new hairstyle, a different face, or a
twenty-year age jump. Preserve the requested relationship expression.

Full transparent-background portrait, head through hips, generous hair and
shoulder padding, no room, prop, cast shadow, text, logo, or watermark.
```

### 배리에이션 계약

- 민준: 무직/생존 알바/일반 사무직/대기업 정장 각각 `y3`, `y5`.
- 다은: normal/smile/sad 각각 `y3`, `y5`; 짧은 머리와 왼쪽 핀 고정.
- 지연: normal/warm/cold 각각 `y3`, `y5`; 긴 흑발 웨이브와 고급 재단 고정.
- 현수: normal `y3`, `y5`; 둥근 안경·통통한 체형·올리브/버건디 고정.
- 재혁: normal/shadow `y3`, `y5`; 상철과 닮지 않는 날카로운 실루엣.
- 상철: normal/serious `y3`, `y5`; 과장된 노인화 금지.
- 아버지: home `y3`, `y5`; 작업복·환자복·2020년 회상은 자동 교체 금지.

### `ending_stable_success_v1.png`

```text
Dedicated 1280x800 visual-novel ending CG. At age 38, the canonical year-five
Kim Minjun sits on the edge of a low bed in a believable modest Seoul studio at
night. He has just closed the finance app and released exactly one unbranded
phone face-down onto a compact bedside table. His other hand rests naturally,
shoulders ease, and his gaze lifts away from the balance for the first time.
Quiet relief, no grin or victory pose.

The home is clearly safer than a goshiwon but ordinary and outside Gangnam:
plain curtains, compact shelf, modest furniture, dense everyday apartment lights
outside. Restrained hand-painted semi-realistic Gangnam Dream CG style, cool
blue-gray and charcoal with neutral skin and one practical lamp. No penthouse,
marble, panoramic luxury glazing, landmark, cash, chart, trophy, champagne,
readable balance, extra person, reflection, duplicate phone, malformed hand,
warm sepia, logo, or watermark.
```

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

**용도**: 일반 병원 장면과 `burnout`의 저우선 배경 폴백. `mental_break`는 정신건강의학과 진료실이므로 공유 금지

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

## 2026-07-17 현수 재회 전용 국밥집 배경

- **최종 경로**: `assets/backgrounds/gukbap_restaurant_night.png`
- **생성 방식**: OpenAI 내장 ImageGen 편집
- **화풍 참조**: `assets/backgrounds/restaurant_korean.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-d9718f8d-5cc7-4b24-b31d-8da461d7cb04.png`
- **최종 SHA-256**: `b11e247d4bb91730e42f2c10858886d9d107c535fde017c6b0c959756ae5d`
- **용도**: `hyunsu_reunion_meet`. 현재 주거에서 이어진 메시지 장면이 실제 대면으로 전환됐음을 공간 자체로 증명한다.
- **프롬프트 잠금**:

```text
Serious full-anime Korean manhwa visual-novel illustration with believable adult proportions, controlled clean linework, painterly cel shading, matte paper grain, desaturated charcoal and concrete-gray palette, restrained warm practical light, subtle cool-blue Seoul-night reflections, quiet social-reality atmosphere, high environmental detail without photoreal DSLR rendering.

Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, controlled linework with painterly cel shading, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood.

Edit the reference into a modest independent gukbap soup restaurant at night in an old Seoul goshiwon alley. Preserve the grounded mature illustration language, but remove every built-in charcoal grill, meat dish, barbecue hood, and upscale restaurant cue. Show a physically coherent open stainless soup kitchen, worn walls, simple square tables and chairs, and a wet narrow alley visible through the entrance. Reserve the foreground as an empty two-person table before the meal arrives: exactly two plain metal water cups, one utensil caddy, and an optional tissue box only. Do not place soup, food, menu cards, receipts, phones, bags, or personal belongings on that table. Keep screen-right usable for Hyunsu's portrait and the lower third safe for dialogue. Distant patrons may appear only as low-contrast anonymous back-view or profile silhouettes with no readable faces. No Minjun, Hyunsu, named-character proxy, waiter in the foreground, readable Korean or English text, brand, logo, watermark, camera-facing person, deformed furniture, grill, meat, or already-served gukbap. 16:10 composition for a final 1280x800 background.
```

- **후처리**: 생성 원본 1586x992를 `sips -z 800 1280`으로 1280x800 정규화했다.
- **합격 기준**: 전경 식탁에 음식이 아직 없고, 내장 그릴·고기·판독 문자·상표·주연 대역이 없다. 현수 초상과 하단 대화창을 합성한 KO/EN 실제 게임 화면에서 주방·골목·빈 두 자리의 공간 동사가 유지돼야 한다.

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

## 2026-07-25 고시원 공용 주방 정합 배경

- **최종 경로**: `assets/backgrounds/goshiwon_shared_kitchen.png`
- **생성 방식**: Codex built-in ImageGen
- **입력 레퍼런스**:
  - `assets/backgrounds/goshiwon_room.png`: 같은 건물의 벽 재질·저채도
    야간 팔레트·회화 렌더링.
  - `assets/backgrounds/goshiwon_hallway.png`: 노후 배관·형광등·복도
    구조. 생성 안정성을 위해 1280×800 참조본으로만 축소해 입력했다.
- **최종 생성 원본**:
  `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/call_0cjpvU2utx7zltPDsldBRnyJ.png`
- **후처리**: 1586×992 비알파 PNG를 1280×800으로 리샘플했다.

```text
Create the 2 AM shared kitchen in the exact same old Sinchon goshiwon as the
room and hallway references. Match their mature Korean digital-painted realism,
subtle ink edges, matte worn surfaces, low saturation, cool charcoal shadows,
restrained amber spill, and realistic perspective.

At eye level from the doorway, show a genuinely cramped two-meter-wide
communal kitchen: one coherent stainless counter, small sink and drying rack,
one or two cheap induction burners, modest hood, one neutral steaming pot,
sparse mismatched communal cookware, one old shared refrigerator, narrow clear
aisle, peeling gray-beige walls, exposed utilities, worn tile, cheap cabinets,
small high frosted window, and fluorescent ceiling light. Keep the location
evidence in the left/center 70% and above the lower dialogue-safe 30%; reserve
the darker right edge for Hyunsu's transparent portrait.

No people, silhouettes, bed, bedroom desk, laptop, private-room props, dining
set, apartment island, luxury finish, restaurant equipment, large window,
skyline, brand, logo, watermark, poster, menu, or readable text. No blocked
appliance, duplicated sink, floating cookware, malformed fixture, or impossible
reflection. It must read as a shared goshiwon kitchen, not an apartment, cafe,
restaurant, or private room.
```

- **합격 기준**: 개인실 침대·책상 0, 인물·판독 문자 0, 싱크대·조리기·
  냉장고·통로가 한 원근 안에서 물리적으로 연결된다. 실제 StoryMode에서
  오른쪽 현수 초상과 하단 대화창을 합성해도 공용 주방이 즉시 읽혀야 한다.

---

## 2026-07-24 아버지 6년 전 연령 정합

### npc_father_past.png

- **최종 경로**: `assets/characters/npc_father_past.png`
- **입력 레퍼런스**: `assets/characters/npc_father.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/call_7UxWTa8rJogncumdbvLhPfbE.png`
- **최종 프롬프트 요약**:

```text
Using the supplied canonical 63-year-old Father portrait as a strict identity and wardrobe reference, create the same Korean man six years earlier at age 57 for the 2020 guarantor-debt flashback. Preserve his long narrow face, hairline, deep-set eyes, restrained mouth, lean working-life shoulders, worn navy work jacket, and dark checked shirt. Make only believable six-year age changes: darker salt-and-pepper hair, fewer deep forehead and eye wrinkles, and slightly firmer skin. His eyes and head angle turn down toward screen-left with quiet humiliation; no smile or lens contact. Match the desaturated Korean visual-novel/manhwa realism, matte texture, controlled linework, painterly cel shading, and restrained lighting of the reference. Upper-body transparent portrait composition, no props, room, text, logo, extra person, or wardrobe change. Use a flat chroma-green background for clean extraction.
```

- **후처리**: border auto-key·soft matte·despill로 투명 분리한 뒤 중앙 크롭하여 512x768 PNG로 정규화했다.
- **합격 기준**: 현재 63세 아버지와 동일 인물·동일 작업복으로 읽히되 57세의 어두운 머리와 완화된 노화 흔적이 보이고, 2020년 회상 외 장면에는 사용하지 않는다.

---

## 2026-07-17 지연 첫 키스 무인 세단 배경

- **출시 경로**: `assets/backgrounds/jiyeon_sedan_night_interior.png`
- **생성 방식**: OpenAI 내장 ImageGen 편집
- **참조 이미지**: `assets/cg/romance/first_kiss_jiyeon.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-3addc9a4-9522-43dc-ae6a-6bedcb5df0eb.png`
- **출시 해시**: `68473f8a5062cb9705ca867b531321156d7650ace0de64b2fa374d7420356f74`

```text
Unified Gangnam Dream art direction: full anime / Korean manhwa visual novel art for a serious 2026 Seoul noir life-sim. Use expressive clean linework, clearly illustrated faces, cel shading with soft gradient shadows, simplified skin, sharp readable silhouettes, and cinematic anime background painting. The mood comes from the existing asset set: late-night Seoul, class anxiety, cramped rooms, rain, empty transit, offices, hospitals, rooftops, and lonely city lights. Palette stays restrained and dark: charcoal, ink navy, graphite gray concrete, muted brown wood, pale hospital gray, restrained olive, warm amber practical lamps, city-window gold, cold blue monitor/window glow, fluorescent white, and subdued purple PC-bang neon. Lighting is motivated and low-key: desk lamps, ceiling fluorescents, refrigerators, subway fixtures, monitors, rain reflections, shop lights, and skyline windows create dramatic value separation, but all surfaces remain anime-rendered rather than photographic. Characters should be serious seinen/manhwa-style VN portraits, not cute chibi and not real actors. Backgrounds should be anime painted game backgrounds with clean perspective, simplified readable forms, atmospheric shadows, and UI-friendly negative space. Absolutely avoid photorealism, DSLR portraits, visible pores, camera bokeh, hyperreal skin texture, celebrity-photo lighting, raw-photo textures, sci-fi UI, magic effects, glowing abstract rings, and oversaturated colors.

Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, controlled linework with painterly cel shading, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood.

Edit the referenced first-kiss image into a reusable, completely empty nighttime sedan interior background. Remove both people and every human trace while preserving the exact recurring vehicle: a black S-Class-level long-wheelbase executive sedan, left-hand-drive steering wheel and driver cluster on image left, right front passenger position, broad black leather cabin, restrained metallic trim, and low horizontal dashboard. Keep the same nighttime Gangnam side-street lights through the windshield and the same camera height and perspective so the later two-person CG reads as the identical car. No person, body, reflection, hand, face, readable instrument text, emblem, model badge, logo, license plate, watermark, right-hand drive, tan or red upholstery, sports bucket seat, autonomous lounge, rain, or snow. Compose at 16:10 with the lower 30 percent safe for the dialogue panel.
```

- **검수**: 1280×800, 무인, 무문자·무상표, 왼쪽 운전대, 검은 가죽, 수평 대시보드, 첫 키스 CG와 동일 차급·시점, KO/EN 실제 게임 크롭을 확인했다.

---

## 2026-07-12 프로포즈·결혼 선택 비주얼 패스

다섯 자산은 Codex 내장 ImageGen으로 제작했다. 외부 사진이나 실존 인물 이미지는 사용하지 않았고, `CHARACTER_VISUAL_BIBLE.md`와 기존 프로젝트 초상의 얼굴·헤어·계급 신호를 프롬프트 정본으로 사용했다. 장면별 선택 결과를 미리 보여주지 않는 것이 1차 계약이며, 전체 연속성은 `assets/COMMITMENT_VISUAL_BIBLE.md`가 소유한다.

공통 스타일 문장:

```text
Gangnam Ink Korean adult visual-novel illustration: restrained manhwa realism, controlled linework, painterly cel shading, matte paper grain, limited but readable color, natural Korean anatomy and age, deliberate Japanese VN camera blocking, quiet Seoul social-reality mood. No photoreal DSLR rendering, mobile-game gloss, readable text, logos, watermarks, brown/sepia moral grade, lens-facing gaze, or critical object below the lower 34% dialogue-safe area.
```

### npc_daeun_proposal.png

- **최종 경로**: `assets/characters/npc_daeun_proposal.png`
- **최종 생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-7b3b3b98-4280-470a-8dc3-b0eeda5f1fb3.png`
- **탈락 원본**: `exec-ba444160...`은 투명 배경 대신 가짜 체크무늬를 그려 탈락.
- **최종 프롬프트**:

```text
Create one transparent-style Korean VN portrait of Kim Daeun, age 33: the same short layered dark-brown hair, wispy bangs, left-temple clip, warm brown eyes, narrow nose bridge, soft jaw, and slim adult proportions as her canonical portrait. Dress her for a late-game cafe date in a deep muted berry-red fine-knit dress with a modest square neckline and a soft charcoal cropped cardigan. Give her a quiet unaware smile and screen-left eye line toward Minjun. Head to upper thighs, full hair, clean hands outside the crop, one person only. Use a perfectly flat solid #08ef0f chroma-key background with no floor, shadow, texture, or gradient. No ring, bridal clothing, convenience-store uniform, long hair, glamour makeup, lens gaze, text, logo, or extra limbs.
```

### proposal_daeun_v1.png

- **최종 경로**: `assets/cg/romance/proposal_daeun_v1.png`
- **최종 생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-048cc948-4d53-4b4b-b28f-e302ca9093a2.png`
- **탈락 원본**: `exec-eda4753e...`, `exec-3d9fa433...`, `exec-af287f6d...`은 반지 상자 또는 핵심 손동작이 하단 StoryMode UI 아래로 내려가 탈락.
- **최종 프롬프트**:

```text
Stage the accepted proposal in a rainy Seoul cafe from a restrained over-Minjun-shoulder wide camera. Daeun wears the exact berry-red dress and charcoal cardigan, keeps her short hair and left-temple clip, looks screen-left at Minjun through restrained tears, and covers her mouth with one anatomically clear five-finger hand. Exactly one open ring box with one ring sits visibly on the upper table; her other hand rests naturally beside it. Minjun is only a cropped black-crewneck shoulder/forearm at lower-left. Keep Daeun's face, hand, and ring box above the lower 34% dialogue-safe area. No kneeling, ring already worn, lens gaze, duplicate hands, luxury restaurant, wedding dress, text, logo, or extra people.
```

### wedding_daeun_mother_reaction_v1.png

- **최종 경로**: `assets/cg/romance/wedding_daeun_mother_reaction_v1.png`
- **최종 생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-1abd5964-5847-4395-bbe2-43be82f7d36a.png`
- **최종 프롬프트**:

```text
Isolate Daeun's mother in a bride-side reaction shot inside one contemporary Seoul wedding hall. She sits naturally in the screen-left front aisle chair, wears a muted dusty-rose jeogori with a crisp ivory collar and deep muted raspberry chima, rests both hands on her lap, and watches her unseen daughter enter with restrained emotion. Unnamed guests behind her are varied low-contrast faceless silhouettes. Keep chair perspective altar-facing and her face and hands above the dialogue-safe zone. No bride, groom, extra named face, paper, phone, lens gaze, text, logo, or duplicated hands.
```

### wedding_daeun_father_reaction_v1.png 계열

- **최종 경로/원본**:
  - `wedding_daeun_father_reaction_v1.png` — `exec-2899fc0a-f2f3-4b48-b43f-13708bb6cbb9.png`
  - `wedding_daeun_father_reaction_hyunsu_v1.png` — `exec-592d5ad6-d99e-4e73-bcba-d6510e097ad8.png`
  - `wedding_daeun_father_reaction_passed_v1.png` — `exec-c3f5a5b0-efcd-4071-824d-8ab1ff7f4bc8.png`
  - `wedding_daeun_father_reaction_passed_hyunsu_v1.png` — `exec-8b20a907-d551-4fec-b3dd-c656ae19ad8b.png`
- **최종 프롬프트**:

```text
Isolate the screen-right groom-side front row. In the living-Father state, Minjun's father sits in a dark charcoal formal honju suit and looks screen-left toward the unseen aisle without lens contact. The reconnected state adds only canonical Hyunsu one full row behind Father: youthful stocky build, broad soft round face, full cheeks, low gentle almond eyes, rounded jaw, medium tousled wavy black hair, thin round metal glasses, navy guest suit, white shirt, and muted burgundy tie. His head and pupils turn screen-left toward the unseen bride rather than the lens. In father-passed states, Father's reserved front-row aisle chair is completely empty; the combined state keeps it empty while Hyunsu remains alone behind it. All unnamed guests are low-contrast faceless silhouettes. No generic stocky substitute, sharp or middle-aged face, mother, couple, spouse, child, memorial portrait, ghost, replacement guest, text, logo, or mismatched chair axis.
```

### wedding_daeun_small_v1.png / wedding_daeun_full_v1.png

- **최종 경로**: `assets/cg/romance/wedding_daeun_small_v1.png`, `assets/cg/romance/wedding_daeun_full_v1.png`
- **최종 생성 원본**: `exec-8b055007-da44-434a-9d1e-1e25dfe126e7.png`, `exec-d4f6beaf-5428-4606-a366-e100120e5b28.png`
- **최종 프롬프트**:

```text
Show only Minjun and Daeun as identifiable people in an altar-to-rear-door wedding entrance wide. Minjun has entered first and waits at the altar in a fitted charcoal suit; Daeun enters later and walks toward him, meeting his gaze without looking at the lens. Lock Daeun's attractive adult face, short layered dark-brown hair, wispy bangs, left-temple clip, natural two-hand bouquet grip, and route-specific dress. Small route: modest plausible Seoul hall, simple ivory A-line dress, short veil, restrained flowers. Full route: polished Seoul hall, refined beaded ivory A-line gown, longer veil, coherent flowers and warm professional lighting. Any distant guests are anonymous low-contrast silhouettes. No readable parent, Hyunsu, extra named face, oversized head, text, or logo.
```

### wedding_daeun_small_close_v1.png / wedding_daeun_full_close_v1.png

- **최종 경로**: `assets/cg/romance/wedding_daeun_small_close_v1.png`, `assets/cg/romance/wedding_daeun_full_close_v1.png`
- **최종 생성 원본**: `exec-01a977e1-ee83-4e62-b691-1fa0040adb72.png`, `exec-deae033e-5b9a-44b7-8a56-4f55158f06b8.png`
- **최종 프롬프트**:

```text
Move into a restrained medium-close wedding shot containing only Minjun and Daeun as identifiable people. Daeun has reached Minjun; they look naturally at each other rather than the lens. Lock her canonical attractive 33-year-old face, short layered dark-brown hair, wispy bangs, left-temple clip, warm almond eyes, adult proportions, clear bouquet hands, and small/full dress tier. Minjun retains the same lean face, short tousled black hair, and charcoal formal suit. Keep both heads, eye lines, hands, and bouquet above the lower dialogue-safe area. No parent, Hyunsu, extra named guest, oversized head, idol/teenage face, distorted hands, text, logo, or watermark.
```

### wedding_gap_jiyeon_v1.png

- **최종 경로**: `assets/cg/romance/wedding_gap_jiyeon_v1.png`
- **최종 생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-2d977509-6eb6-47c6-86af-a7537e947cf3.png`
- **탈락 원본**: `exec-6a829914...`은 하객 명단/카드 대비가 하단 UI에 가려져 탈락.
- **최종 프롬프트**:

```text
Stage a pre-decision wedding-scale negotiation in an empty prepared five-star Seoul hotel ballroom, not a proposal or completed ceremony. From behind Jiyeon's older navy-suited father, show Jiyeon in a tailored ivory planning suit and black silk inner layer watching him with controlled tension; her long black waves, sharp eyes, and geometric earrings preserve her canonical identity. Minjun stands beside her in an inexpensive fitted charcoal suit, looking down at exactly three blank groom-side invitation cards. Contrast those with a visibly larger group of blank bride-side cards and the grand aisle beyond. Keep all faces, hands, and unequal card groups above the lower 34% UI-safe area. No bridal gown, choice outcome, readable names, brands, villain gesture, lens gaze, extra named person, or text.
```

### 후처리와 검증

```text
remove_chroma_key.py --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill --edge-contract 1
sips -z 768 512
```

- 초상은 RGBA 512x768, 본 섹션의 CG는 RGB 1280x800으로 확인했다.
- Godot 4.6.2 재임포트 후 KO/EN `--qa=commitment` 각 38장으로 제안 선택 전·수락/보류 결과, 다은 어머니·신랑석 상태·소형/풀 커플 와이드·근접, 지연 3링크 협상 크롭과 양 결과를 확인한다.
- `event_visual_contract_check.py --strict`, `cg_acting_contract_check.py`, `cast_detail_contract_check.py`, `peak_scene_chain_audit.py`가 분리된 9개 다은 결혼식 CG의 라우팅·배우·시선·빈자리 계약을 함께 강제한다.
- 상용 배포 전에는 사용한 생성 서비스의 당시 이용 약관과 계정 권리 범위를 별도 출시 증빙에 보관한다.

---

## 2026-07-12 P0 final-life ending CG package

All eight images were produced with Codex built-in ImageGen. `assets/ENDING_P0_VISUAL_BIBLE.md` is the exact scene/crop contract; the common final prompt prefix was:

```text
Create a 1280x800 final-life ending CG in Gangnam Dream's cinematic 2D Korean manhwa / Japanese visual-novel language: believable Korean adult anatomy, controlled linework, painterly cel shading, matte paper grain, restrained contrast, practical Korean architecture, and a charcoal/concrete-gray base with scene-specific natural color. Preserve the canonical recurring identities. Keep every face, gaze target, meaningful hand, and story prop inside the central vertical 72% for the 950x430 ending preview. No text, logo, watermark, brand, invented named person, DSLR photorealism, or glossy 3D render.
```

Final shot prompts and built-in source outputs:

- `assets/cg/ending_full_circle_v1.png` — `exec-b0f13b8d-2075-4bb8-b087-a5a08fb32ec6.png`. Newly occupied Gangnam room in clear daylight; Minjun holds one phone to his ear after telling Father Sangchul's debt is cleared; one moving box and one blank envelope remain secondary. Father is audio-only.
- `assets/cg/ending_gangnam_dream_white_v1.png` — `exec-d2e5bbf5-70ab-44f0-83e3-60b3209de139.png`. Clear morning window; Minjun holds a blank cream deed folder and quietly meets one faint physically coherent reflection. Relief, not conquest.
- `assets/cg/ending_with_daeun_v1.png` — `exec-24db2176-799d-4a80-b4a7-923a5b549e3a.png`. Modest outer-Seoul home; exactly two ramyeon bowls, two chopstick sets, and two water cups; Daeun and Minjun share mutual eye contact and near-touching hands. Rings hidden by angle.
- `assets/cg/ending_second_love_v1.png` — `exec-379fc274-9d3e-4f01-acea-e3da97276af1.png`. Gangnam night window and compact coffee counter on one axis; Daeun holds one mug and turns toward Minjun while he prepares the second mug with coherent pour-over hands.
- `assets/cg/ending_jiyeon_man_v2.png` — final reflection-only source `exec-cfc94269-318d-4e7b-986b-618f64b6cee8.png`; SHA-256 `62a7f17d4aec7268e318194c91b2c1932dd208e00a6b71269552a85c6df3024a`. The camera sees exactly one Minjun at screen-left and one Jiyeon at screen-right, both only inside the same off-axis mirror. The illuminated frame, reflected bathroom depth, and vanity edge establish the optical surface; no real-world backs, duplicate faces, extra limbs, or camera appear. Minjun looks toward his own mirrored eyes while Jiyeon looks toward him, and both hands remain below the crop. This replaces the `v1` family after repeated generations preserved actor order but still gave the foreground bodies and reflections independently staged head, shoulder, torso, or arm poses. The reliable rule is now not “draw four perfectly matched bodies,” but “never draw the duplicate pair.”
- `assets/cg/ending_guardian_v1.png` — `exec-85c50d6a-c635-4b5c-980d-ff17cb835e9c.png`. Modest Changwon hospital discharge exterior; Father walks independently and looks at Minjun while Minjun carries one duffel and one folded jacket.
- `assets/cg/ending_jaehyuk_way_v1.png` — `exec-44a82c54-9458-453e-8060-b2b59c22d745.png`. Expensive empty Gangnam room at night; Minjun's narrow profile and one clear hand stop on a half-drawn curtain while the city remains partly visible.
- `assets/cg/ending_sangchul_reckoning_v1.png` — `exec-e2eb0ad5-4673-4c53-b1d7-3e57a0e17a51.png`. Modest room at blue hour; visibly open window, lowered phone, still writing hand, blank papers, and one pen. No police form or guaranteed police location.

Post-processing:

```text
All sources: center crop 1586x992 -> 1584x990, then resample to 1280x800.
Jiyeon mirror `v2`: center crop 1586x992 -> 1584x990, then resample to 1280x800.
Jaehyuk source exposure: RGB gamma 0.68, contrast 0.93, brightness 1.06.
Sangchul source exposure: RGB gamma 0.74, contrast 0.95, brightness 1.04.
```

The two exposure lifts preserve every pixel position and exist only so Deep Black/White runtime grading can damage or recover the print without hiding faces, hands, the curtain, open window, or documents. KO/EN `--qa=ending-p0` owns the final modal crop and exact-texture gate.

---

## 2026-07-13 P1 ending CG — The Late Call

The image was produced with Codex built-in ImageGen. Its invariant scene and crop contract lives in `assets/ENDING_P1_VISUAL_BIBLE.md`.

- `assets/cg/ending_late_call_v1.png` — accepted source `exec-f7f29490-a3d1-4f42-997f-4be132387e0e.png`. Late-30s canonical Minjun sits in a physically coherent KTX window seat in winter rain, holds one unbranded phone to his right ear, and raises the removed earbud in his left hand. Father remains voice-only; one earbud case rests on Minjun's lap. The earlier `exec-efc65021-bac7-4f79-a8ad-40df10660347.png` was rejected because the removed-earbud hand fell below the centered 950x430 ending preview.

Prompt lock:

```text
Create a restrained-color Gangnam Ink final-life ending CG aboard a KTX bound for Changwon. Preserve canonical 38-year-old Kim Minjun: lean Korean face, short messy black hair, tired eyes, charcoal travel coat over a worn black crewneck. Aisle-side three-quarter camera, coherent forward-facing two-seat row, rain-streaked window and moving winter landscape. His right hand holds one phone to his right ear; his raised left hand holds exactly one removed earbud; one case rests on his lap. He looks only at the rain as his shoulders quietly release. Father is voice-only. Keep the face, gaze, both hands, phone, earbud, and rain inside the centered ending crop. No other named person, station platform, readable route display, logo, luxury first class, lens gaze, broad smile, duplicated device, or malformed hand.
```

Post-processing: center crop 1586x992 to 1584x990, then resample to 1280x800. KO/EN `--qa=ending-p1` locks the base and Jaehyuk-memory variant; KO/EN `--qa=transport` separately proves that `ktx_window` is an interior and `hometown_train_station` remains a platform.

---

## 2026-07-13 P1 ending CG — Rich and Alone

The image was produced with Codex built-in ImageGen. Its invariant scene, object count, distinction from `empty_house`, and crop contract live in `assets/ENDING_P1_VISUAL_BIBLE.md`.

- `assets/cg/ending_lonely_rich_v1.png` — accepted first source `exec-3426d54b-5d3e-49e9-9dd5-33d8934cfe77.png`. Canonical late-30s Minjun sits upright at the screen-left end of one rectangular Gangnam dining table. Exactly four chairs exist: his occupied chair and three readable empty chairs. One plain paper delivery bag, one single-person container, and one face-down phone remain inside the centered preview. The scene avoids `empty_house`'s sofa, two cups, envelope, keys, and collapsed bereavement pose.

Prompt lock:

```text
Create a restrained-color Gangnam Ink final-life ending CG in a Gangnam high-rise dining area at night. Preserve canonical 38-year-old Kim Minjun: lean angular Korean face, short messy black hair, narrow tired eyes, charcoal at-home knit and dark trousers. Use one rectangular table and exactly four chairs total; Minjun occupies the screen-left short-end chair and exactly three empty chairs remain visible. One natural hand rests beside exactly one plain paper delivery bag and at most one single-person container; the other has just placed exactly one unbranded phone face-down. He looks toward the nearest empty chair, never the lens, skyline, phone, or food. Keep his face, both hands, the one meal, phone, and all three empty chairs inside the centered 950x430 crop. Preserve readable source midtones for Deep Black. No other person, second meal, paired cup, second place setting, deed, envelope, keys, flowers, legal papers, moving box, readable receipt/UI, logo, brand, delivery worker, sofa grief pose, triumphant wealth pose, fake lettering, malformed hand, extra chair, or duplicate phone.
```

Post-processing: center crop 1586x992 to 1584x990, then resample to 1280x800. KO/EN `--qa=ending-p1` locks the base, Daeun-divorce variant, and the no-CG Gangnam-shortfall divorce result.

---

## 2026-07-13 P1 ending CG — One More Circle

The image was produced with Codex built-in ImageGen using the canonical goshiwon background and late-30s Minjun references. Its room, acting, crop, and variant contract lives in `assets/ENDING_P1_VISUAL_BIBLE.md`.

- `assets/cg/ending_gambling_recovery_v1.png` — accepted corrected source `exec-19b288f9-5cc9-465b-b646-c3c2e067b5f5.png`; SHA-256 `2bdea7f0532a421d5b3405443f5ff871001bf7b2b8b8f81fed9d8da1a9fae949`. The first source `exec-ccac9c10-7104-47e5-8886-87b16a1c4266.png` was rejected because its shortened grid made the recovery passage look briefer than the guaranteed first month. The accepted monthly page shows recovery continuing into another ordinary month without readable dates or a false exact total.

Prompt lock:

```text
Create the gambling-recovery final-life CG in the exact canonical goshiwon: one left-wall bed, far-left shelf/mini-fridge, one high frosted back window, right-front desk, right-wall hooks/switch, and one door. Preserve canonical 38-year-old Kim Minjun in his worn black crewneck. Seated low at the desk, he looks only at one plain monthly wall calendar while his clear right hand completes today's muted-red circle with one pen; his open left hand rests beside one face-down unbranded phone. Use a physically plausible blank grid with many imperfect circles continuing after the first clean month, but no month name, date numbers, letters, slogans, or exact hundred-day claim. Keep Minjun's face, pen hand, calendar, and current circle inside the centered 950x430 crop. Quiet cool dawn plus one task lamp; no casino, cards, chips, betting UI, neon, money, helper character, lens gaze, broad victory grin, malformed hand, extra object, fake text, logo, or changed room geometry.
```

Post-processing: center crop 1586x992 to 1584x990, then resample to 1280x800. KO/EN `--qa=ending-p1` locks the base and Father-memory variants; `CGRuntimeCheck` locks the 1+3+1-week recovery chain and prevents relapse from scheduling the clean payoff.

---

## 2026-07-17 P1 ending CG — Pinnacle of the Orthodox

The image was produced with Codex built-in ImageGen using `main_character_corporate.png` for Minjun identity, `ending_startup_exit_v1.png` for late-30s ending treatment, and `company_dinner_restaurant.png` for Korean restaurant architecture. Its scene, actor hierarchy, color, and crop contract lives in `assets/ENDING_P1_VISUAL_BIBLE.md`.

- `assets/cg/ending_orthodox_pinnacle_v1.png` — accepted repo final SHA-256 `e7b4396db619f324e1614a30bfbd000eb1d204982c7fe88420506b5df24c8a79`. The first source `exec-e5bd9698-0cfb-4720-a7f8-47cb0c1a03b1.png` was rejected because Minjun and the junior shared nearly the same hair/face silhouette and the whole restaurant leaned brown-sepia. `exec-aa385e5e-ec3f-4313-beaa-b62d66e334ce.png` established the glasses/cardigan distinction; later passes restored a visibly younger face and the accepted repo final keeps the junior's glasses/cardigan silhouette, Minjun's lowered gaze, and his resting hand beside one water glass.

Final prompt lock:

```text
Preserve the physically coherent Korean company-dinner composition: one table, one built-in grill, one aligned exhaust hood, and canonical 38-year-old Minjun screen-right in a charcoal suit. Minjun lowers his eyes to exactly one plain water glass beside one clear resting hand, caught before answering how he lived so diligently. Screen-left, make the speaking junior unmistakably different: late 20s, softer round Korean face, tidy side-parted hair, thin rectangular glasses, pale desaturated blue open-collar shirt, and charcoal cardigan; his head and eyes point only toward Minjun with sincere admiration. Anonymous diners remain varied low-contrast C-tier figures. Use Gangnam Ink Korean adult manhwa/VN realism with neutral concrete gray, blue-charcoal cloth, cool steel, muted natural skin, and faint rainy blue-gray air. Keep both faces, eye-lines, Minjun's hand/water glass, and one grill edge inside the centered 950x430 cover crop. No lens gaze, smiles, toast, celebration, phone, money, fake text, logo, cloned faces, extra people or props, malformed hands, warm sepia, orange-brown wash, DSLR photo, glossy 3D, or watermark.
```

Post-processing: center crop 1536x1024 to 1536x960, then resample to 1280x800, followed by RGB gamma 0.78, contrast 0.95, and brightness 1.03. This preserves both faces, Minjun's hand, and the water glass under the neutral runtime grade without changing geometry. KO/EN `--qa=ending-p1` owns the base and salary-memory variant; `CGRuntimeCheck`, `cg_acting_contract_check.py`, and `cast_detail_contract_check.py` own its exact path and A/B/C actor hierarchy.

---

## 2026-07-17 P1 ending CG — Burnout

The image was produced with Codex built-in ImageGen using `burnout_hospital_room.png` for the Korean hospital language and `ending_debt_spiral_v1.png` for the restrained failure-ending treatment. The prompt began with the required aggregate style description before the Master Style Guide.

- `assets/cg/ending_burnout_v1.png` — accepted repo final SHA-256 `cc9cfdcbf19b3bfede47f9cd89e1417a8891cf79b1af978d611ca282757317aa`; generated source `exec-e31c9a25-7db4-44ba-8d32-268b887a9680.png`. The 1672x941 source was center-cropped to 1506x941 and resampled to 1280x800. The accepted frame keeps one coherent hand, taped cannula, connected IV line, face-down phone, fluorescent ceiling, and observation-bay curtain in the centered ending crop without inventing a visible caregiver.

Final prompt lock:

```text
Serious full-anime Korean manhwa visual-novel illustration with clean controlled linework, softly painterly cel rendering, restrained facial modeling, matte rather than glossy surfaces, and high environmental detail. The palette is predominantly desaturated charcoal, concrete gray, muted navy, weathered beige, and cold Seoul blue, with warm practical light used only as a localized emotional accent. Lighting is cinematic but grounded: soft window or street light, reflected city light, rain or atmospheric haze when story-appropriate, readable silhouettes, and no photographic depth-of-field gimmicks. The atmosphere is adult, socially realistic, intimate, and slightly weary rather than cute, heroic, or fashion-editorial.

Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood.

Create a first-person supine POV from Minjun's eyes on a Korean emergency observation bed before dawn. Center one fluorescent ceiling fixture; place one hanging IV bag screen-left and show one continuous line physically connected to a taped cannula on exactly one relaxed left hand with five coherent fingers above the blanket. Place exactly one unbranded matte-black phone face-down just beyond his fingertips. Keep the bed rail, white privacy curtain, ceiling tracks, and distant gray Seoul window physically coherent. The offscreen nurse has just asked whether there is anyone to call, but no nurse, doctor, family member, heroine, or face appears. Keep the fluorescent light, full hand/cannula, phone, and enough IV connection inside the centered 950x430 ending preview. Cold pre-dawn blue-gray, pale hospital white, muted skin, quiet physical exhaustion. No psychiatric office, self-harm implication, blood, ECG spectacle, extra limbs, duplicate bags or phones, detached tubing, readable chart or label, logo, brand, watermark, warm sepia, glossy medical ad, DSLR photo, or 3D render.
```

KO/EN `--qa=ending-p1` owns the exact texture and centered crop. `CGRuntimeCheck` locks the dedicated ending owner and explicitly forbids `mental_break` from reusing it; acting and scene-audio manifests lock the first-person body grammar and hospital-only room tone.

---

## 2026-07-12 T2 romance rupture result CGs

Both images were produced with Codex built-in ImageGen and normalized to 1280x800. Their exact scene, wardrobe, architecture, acting, and reveal contracts live in `assets/BREAKUP_VISUAL_BIBLE.md`.

- `assets/cg/romance/breakup_daeun_v1.png` — accepted source `exec-b167dd0f-4005-4475-b81c-62a2459ec86b.png`. In the canonical modest Daeun home, she wears the dusty-mauve married-home outfit and presses exactly one red seal onto one blank separation agreement while Minjun remains withdrawn in the rear foreground. Her face, both hands, seal, and paper stay above the dialogue-safe lower area. `exec-5d6c0b74-e63f-4dc3-85ab-cc749db30db7.png` was rejected because the decisive hand/document action fell below the runtime dialogue crop.
- `assets/cg/romance/breakup_jiyeon_v1.png` — accepted source `exec-9a8d1a4b-e8e0-46d2-9ac5-847b18c0fc5a.png`. In the canonical Jiyeon high-rise, the front door opens to an indoor corridor/elevator lobby. Jiyeon crosses the threshold in her ivory/black outfit with one structured handbag and does not turn back; Minjun stays seated and does not reach.

Shared prompt lock:

```text
Create a quiet choice-result rupture CG in Gangnam Dream's restrained-color Gangnam Ink visual-novel language. Preserve the canonical heroine identity, home architecture, outfit, and exact prose action. Keep the face, gaze target, decisive hand or threshold, and relationship blocking above the lower 30% dialogue-safe area. No readable legal text, brand, logo, watermark, revenge glamour, screaming, lens gaze, invented witness, wedding spectacle, or generic breakup stock pose. This image appears only after the separating choice reaches the depicted result paragraph.
```

Post-processing: center crop 1586x992 to 1584x990, then resample to 1280x800. KO/EN `--qa=breakup` owns the pre-choice location, no-leak branches, exact reveal paragraph, and final crop.

---

## 2026-07-12 strict 이벤트 비주얼 부채 0 패스

세 자산은 Codex 내장 ImageGen으로 제작했다. 외부 사진은 사용하지 않았고, 설날 CG만 프로젝트의 정본 배경/인물 파일을 입력 레퍼런스로 사용했다. 최종 출력은 중앙 1536x960 크롭 후 1280x800 PNG로 정규화했다.

공통 스타일 문장:

```text
Gangnam Ink visual language: desaturated Korean visual novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contrast, controlled linework with painterly cel shading, restrained cinematic lighting, no glossy mobile-game colors, no photoreal DSLR look, no text, no logos, no UI, quiet Seoul social-reality mood.
```

### seoul_bus_stop_wallet.png

- **최종 경로**: `assets/backgrounds/seoul_bus_stop_wallet.png`
- **최종 생성 원본**: `/Users/junheelee/.codex/generated_images/019ea951-048b-7770-a3e3-ff333c6843da/exec-8feb6088-144b-4956-a5a5-c324e1c2d5fe.png`
- **이전 교정 원본**:
  - `exec-59f2a10b-a2d4-4e68-b74b-5c4154ecd8cf.png`: 벤치가 도로 옆을 향해 물리 구조 탈락.
  - `exec-d5ae909c-2686-41c2-94f8-f080defff7d2.png`: 도로 방향은 합격했지만 지갑이 대사창 아래로 내려가 크롭 탈락.
  - `exec-68b702f0-6cad-4e09-b75d-b3e048135dee.png`: 좌석면이 카메라 쪽으로 읽혀 도로 반대 방향처럼 보이는 시각적 모호성으로 탈락.
  - `exec-3de8df09-9f81-4efa-bab5-d78103f13d67.png`: 등받이 뒤/좌석면 구분이 여전히 약해 방향 판독이 모호해 탈락.
  - `exec-3ddf43b2-a2c0-4499-8341-8f6ebd28e894.png`: 벤치 방향은 맞았지만 이후 교정 과정에서 최종본이 다시 반대로 뒤집혀 대체됨.
  - `exec-7a0d2b57-e115-418c-a0dc-29c4c12b8249.png`: 카메라에 좌석면이 보여 승객이 도로를 등지고 앉는 구조라 탈락.
- **최종 프롬프트 체인**:

```text
Rotate only the wooden bus-stop bench 180 degrees so the seating side faces the glass wall and the road outside. The camera must see the BACK of the bench backrest, not the seating/front side. A passenger sitting on the bench would look straight through the glass toward approaching buses on the road. Keep the bench in the same footprint and scale, keep the lost black wallet clearly visible on the floor, and preserve the rainy road, curb, tactile paving, shelter, architecture, lighting, and camera angle. No people, bus, text, logos, extra furniture, or architectural changes.
```

- **합격 기준**: 카메라에는 등받이 뒷면과 후면 지지대가 보이고 좌판은 도로 쪽에 숨는다. 승객의 시선은 유리 너머 도로를 향하며, 실제 1280x800 도입/선택지 화면에서 지갑 전체가 UI 위에 남는다.

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

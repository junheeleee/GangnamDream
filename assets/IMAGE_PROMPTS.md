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

### 2026-11-14 · W234 건조한 강남대로 저녁

내장 이미지 생성으로 `gangnam_day.png`의 도시 구조만 참고했다. 11월 저녁의 강남대로,
마른 차도·연결된 횡단보도·점자 경사로·앙상한 가로수·절제된 사무실 불빛. 읽을 수 있는
신호, 인물·문자·거래 소품·비·눈 없음. 원본 `exec-0687241f-e540-4e84-b72a-2a694fbd8210.png`
(1586×992), 1584×990 중앙 크롭 뒤 1280×800. P1 마스터 아님.

### 2026-11-14 · M14 한도 상담 창구와 퇴장

내장 이미지 생성: W8 은행은 화풍만 참고. 오후 4:40 은행의 낮은 상담 창구 하나,
작은 프린터, 무표기 흐린 유리·건조한 겨울 도로, 인물·거래 문서·비·눈 없음.
퇴장 컷은 은행을 등지고 길 건너 건물을 보도록 요청했다. 외관을 돌아보는 첫 두
후보는 유리 띠/손잡이가 맞지 않아 제외했다. 1586×992 내장 원본
`exec-5f3efe2c-f79f-4cf0-813a-6d72065d14fb.png` 및 `exec-33184b0e-4f87-4cdd-932e-c8ecf750881c.png`.
1584×990 중앙 크롭 후 1280×800 RGB; 신규 P1 마스터로 세지 않는다.

### 2026-11-13 · 2월 은행 창구·퇴장과 지하철 보관함

**은행**: `assets/backgrounds/bank_service_counter_rainy_day.png`. 기존
`office_interview_day.png`는 화풍 참고뿐이다. 동네 은행의 고객 쪽 시점과 두 창구,
창구까지 이어지는 동선, 번호표 단말, 유리 바깥의 빗방울과 젖은 거리를 요청했다.
첫 원본 `exec-790b1f23-047f-4343-9704-221522c3c4ca.png`은 가로수 잎 때문에
반려했고, 은행 배치를 유지한 채 바깥의 앙상한 겨울 가지와 무표기 번호표 단말·창구 홈만
수정한 `exec-d1069f9b-e0ea-4fd0-9387-2ba1fba5469e.png` (1585×992)를 채택했다.
창구에는 신분증·현금·서류·도장·글자·인물을 굽지 않는다.

**은행 밖**: `assets/backgrounds/bank_exterior_wet_day.png`. 확정된 은행 실내
원화를 위치·화풍 기준으로, 같은 유리문·창구·외부 가로수가 보이는 보도 쪽 시점을
요청했다. 흐린 겨울 낮·젖은 보도·유리의 남은 물방울만 보이고, 떨어지는 빗줄기나
인물·간판 글자·거래 물품은 넣지 않는다. `exec-097875eb-0386-4a76-8771-c19518370382.png`
(1586×992)에서 추출. 최종 SHA-256
`b70a3f1bc6d08826ed085b12d0acc9872268cc6fecedfaf28bdc316b6ff08c52`.

**보관함**: `assets/backgrounds/subway_station_coin_lockers.png`. 기존
`subway_station_stairs.png`는 화풍 참고뿐이다. 창 없는 역사 보행 통로, 닫힌
무표기 보관함과 꺼진 단말, 회색 테라조·차콜 타일·저채도 주황 띠를 요청했다.
`exec-16d3c5e3-77eb-4fa3-ab56-5d3f3dcc1096.png` (1586×992) 채택. 열차·개찰구·
분실물 창구·인물·카드·봉투·비밀번호·시각 표시는 넣지 않는다.

세 원본은 내장 ImageGen 출력이며 `m02-location-art.d8zT0G` 외부 검수 폴더에
반려본과 함께 보존했다. 1584×990 중앙 크롭 후 1280×800 RGB로 축소했다.
최종 PNG의 SHA-256은 은행 `6013624b5aa9c52c7c930f6364506fee2508ad8c42b2afa2df993c5126af8eb6`,
보관함 `583d3270f61d4c2607b666f7869047b762be239edfa975a545aa447665cad8fd`다.

### convenience_store_night.png
**저장 경로**: `assets/backgrounds/convenience_store_night.png`

**밤 꿈 대화 전용 `convenience_store_night_dry_v1.png`**: 기존 실내 v2를 편집 원본으로, `daeun_regular_night_wait_v1.png`를 마른 외관의 연속성 참고로 사용. 계산대·냉장고·문 배치, 빈 실내와 형광등, 잉크 윤곽·무광 종이 질감은 유지하고 창의 물방울·외부 물반사만 없앤다. 밤의 마른 포장과 작은 가로등. 인물·글씨·로고·사진 질감 없음.

**W224 `convenience_rear_{comparison,table_clear}_v1.png`**: 같은 편의점의 타일·어두운 띠·플라스틱 의자, Gangnam Ink 질감을 참고. 계산대가 아니라 건물 뒤 차양 아래 작은 탁자, 닫힌 무표기 문과 작은 조명. 비교본 한 부는 대사창 위에 읽히지 않는 얇은 종이 묶음으로 보이고, 두 갈래 모두 파일에 들어간 다음에만 같은 구도의 빈 자리를 표시. 다른 장소·인물·날씨·새 소리 없음. 생성·국소 제거 후보 SHA-256 `54b901d00976792e9b4a2e4fb58cf0a0060e47991ed758fc26bad283c10d41e5`/`3aef5d97f3d0d415779dc057709ee23389ca3ffa144f2e75b780d6a808e619ed`, 무크롭 1584×990 마스터 `c1023b6f7ff35e3297986a6018b51b81d80980e42c912ea60c806df18dc1ddc7`/`0cde758a60c322bd3274e78ba4aa03709f8318357d6779ce9363d43630e9927e`.

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

### gangnam_boulevard_final_notebook_v1.png

W240 property-not-executed opening, Minjun POV looking down at his worn spiral notebook and loose private papers on a flat exterior stone edge. Dry Gangnam-daero at full night, restrained warm lamps and empty lanes behind him. One dark-coated hand steadies the page before writing. Existing indistinct marks and a blank next line; no readable words, executed contract, rain, umbrellas, other actors, phone, or keys. Matte Gangnam Ink with safe room for the lower dialogue box. References: `gangnam_boulevard_winter_dusk.png` (place), `seoul_station_visitor_sticker.png` (hand/ink), `v2_first_bill_desk_closeup.png` (notebook only). The focused edit added only very faint non-script traces to distinguish used pages from virgin paper.

Source candidate SHA-256 `d91a13fbf24b8c93250053bafefb5acb44cf9cb0cd6052223777556d4af5da03`; uncut opaque 1584×990 master `ee5751975e76309862fb98035c2d99b61860ce82658d1a112dea46c3a5a16474`. Exact background `gangnam_boulevard_final_notebook`; street identity and next home cut remain `gangnam_night` → `current_housing`.

### finale_intake_blue_pen_v1.png

W227, from the visitor side of a modest anonymous reception counter. A single muted blue ballpoint with a continuous short steel tether and fixed counter anchor, ordinary laminate and a low privacy partition. Gangnam Ink linework and matte tonal planes; no institution marks, people, signatures, stamps, or paperwork deciding the outcome. Keep the pen above dialogue and away from the portrait zone. Texture and line references: `police_evidence_reception.png` and `convenience_rear_comparison_v1.png`, not the same locations.

First candidate SHA-256 `5c036392ec8cb2e742c311f2d22f33bd7e7b06985ac1fb890401f7275f64cf31`; the four choices at 960×600 covered part of the pen. Revised framing candidate `54e18c39c5eb076563ccfee449e95303b022f089232d9e924321368cd7bb0a5d` keeps the entire pen and tether above the buttons. Opaque 1584×990 master `0086fa29171237bb1fda56c03fdef364cae9c2616166adb3dc62f72141ae7328`. The story still identifies the location as `office`; the common illustration depicts no completed choice.

### finale_cafe_rear_papers_v1.png

W230, a small table toward the back of a quiet Seoul cafe. A blank thin comparison stack and a separate blank counter sheet sit beside the empty chair and approach aisle, in warm matte Gangnam Ink. No storefront window, weather, people, signatures, filing marks, open notebook or finished result. Paper groups were reframed upward for the small-window choices. Cafe tones and linework references only: `sinchon_offer_cafe_two_coffees.png` and `convenience_rear_comparison_v1.png`.

Revised source SHA-256 `bff7520a22e3890dd4b44318d82e98051e5a5523236eda2eb70cbef7d118748a`; opaque 1584×990 master `82c55b547814a9f67b5230075763f8b445172959e6928c4fb1f1cd4247474361`. The logical location stays `cafe`; the illustration is not a filing receipt or result CG.

### finale_notice_desk_v1.png

W235, a near view of a plain table in Minjun's current home: an unmarked black-screen phone, a separate plain intake sheet and note papers. Top-left prop grouping clear of the local portrait and dialogue area. Matte ink, no known housing tier, readable marks, transaction, or reply. A physical prop detail on the present gathering paragraph only, not an illustration of the phone display.

Source SHA-256 `d2b42a12a2996f034cc573355b4ec97c4dcdd12ec8e4a38dcfe9cf900704ea28`; opaque 1584×990 master `4aae01bafb3a164cc1170a15fedbf3ddfe793935d8b5266c500656ec6392fe09`. The logical location and room audio stay `current_housing`.

### hyunsu_exam_room_v1.png

Different modest room in the same Sinchon goshiwon, seen past the door only after it opens. A partly lit open workbook on the floor, single narrow bed, worn walls and study shelf. Building-class reference `goshiwon_room.png` (not Minjun's floor plan); matte Gangnam Ink reference `convenience_rear_comparison_v1.png`. No named actor, cans, readable test marks, result, other resident or weather. Low-contrast right side and lower dialogue area.

Source SHA-256 `059798ae899bbcdc3dc2eb12663b1dbd18b6f31d2bc09f91e52635cd9d1aee77`; opaque 1584×990 master `cb0cf1fe2032dcd8cb8eec983669e59371af8b8185b10667694f0095fcd96516`.

### hyunsu_exam_room_v2.png

Active replacement for `hyunsu_exam_room`; v1 is preserved as the previous drawing. Same building as `goshiwon_hallway.png` and `goshiwon_room.png`: old plaster, plain blue-gray doorway and round knob, worn floor, narrow adult single-bed proportions. Hyunsu's own layout, seen from an adult's eye height at the threshold. A compact study desk with a lamp and a backless stool tucked beneath it; the existing story beat still has an ordinary A4-sized open workbook on the floor between desk and bed. No person, roll of cans, identifiable print or test result; matte illustration.

Source SHA-256 `45a993dac21495370970c97fbafaf39ae9ba78ffed6cf4337e9864a5777a6e41`; opaque 1584×990 master `13b60f15ac903452904c07a63943b1b3a48f7d5f4859a58f4a8bdb1366e1844e`.

### goshiwon_moveout_wet_street_v1.png

First move-out choice, only after the entrance closes. The sheltered automatic doorway gives way to an unremarkable Sinchon road, old plaster and brick with damp asphalt. No active rain, sign, pedestrian, box or visible destination. The sound of a car may be heard off-screen once; the scene does not introduce a crowd or a new music track.

Source SHA-256 `1d78fa42280d2758c4536aefb5d154e3fcdc587fb9870f2ab17147de488178e2`; opaque 1584×990 master `ae7b95b3dd9d57aa21601bd33bc5971c1020b5ba707d0c1511dab7f9a984d380`.

### first_savings_bank_overview_v1.png

FullStoryFlow savings milestone lead-in: one adult hand holding a modest used black smartphone over an anonymous table, in the matte Gangnam Ink style. Simple generic deposit/expense layout with no letters, funds, exact amount, trades or brand. No fixed housing layout, other objects or time shown. Lower and right sections stay quiet for dialogue, choice and character layers; all results return to the actual residence.

Source SHA-256 `39e7336915db0da3b5c712635c93cd42486157cfb0fc19257b10a1a9fdc49602`; opaque 1584×990 master `ad6fc6c7aac90c275690b3dc4e1627ccd1ba8744096d2b60552e1662f9bb64fc`.

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

## 2026-11-14 — 신촌 커피 제안 (ORDER-830)

- 비 그친 신촌역의 정류장 구조는 참고하되, 흐린 하늘과 계속 내리는 비로 다른 날을 그렸다. 빈 정류장 → 같은 위치의 검은 세단(왼쪽 운전석 문 열림) → 밖에서 지하철 입구로 향하는 보도를 연결했다.
- 카페는 정류장 쪽 거리와 나무를 창밖에 이어 놓고, 탁자에 라테와 검은 커피를 놓았다. 안에는 비·행인·상표를 그리지 않았다.
- 기존 지연의 따뜻한 초상을 기준으로 머리·옷·금색 장신구를 유지하고, 젖은 색조와 검은 우산을 더해 투명 배경에 분리했다. 카페에는 이 초상을 들이지 않는다.

## 2026-11-14 — 부모님 서울 방문 (ORDER-830)

- 17시 서울역 합류는 유리 너머 늦가을 빛과 넓은 동선, 늦은 밤 배웅은 같은 재질의 역사와 표 확인 단말 하나. 열차나 인물, 비·눈·가짜 안내 문자를 그리지 않았다.
- 이동 컷은 어머니의 무릎과 닫힌 반찬 가방만 가까이 잡는다. 창·차량·얼굴 없이 원문이 말하지 않은 이동수단과 의상을 단정하지 않는다. 대사창 안에 가방 전체가 묻히지 않게 위·왼쪽에 배치했다.

## M03 신촌 이면도로 — 사고 전과 퇴장

`assets/cg/jiyeon_crash_day_v3.png`의 따뜻한 상점 유리·차가운 저녁 하늘·젖은 도로를 기준으로 별도 배경 두 장을 생성했다. 사고 전은 인물·세단·자전거만 제거한 접근 시점, 퇴장은 같은 블록의 다음 골목을 보는 시점이다. 인식 가능한 글자나 사고 물품을 넣지 않는다. 원 CG는 변경하지 않고, 배경만 1280×800 RGB로 축소했다.

접촉 직후 삽입 컷은 같은 세단·자전거·인도 조명, 낮은 시점의 휘어진 앞바퀴와 물보라를 잡는다. 닫힌 차 문, 지연·얼굴·상처 없음. 다음 하차 장면을 앞당기지 않는다.

## 신촌역 정류장 — 비가 막 그친 밤

지갑 정류장 원화는 쉼터 구조만 참고. 밤의 빈 쉼터, 정지한 물방울과 젖은 노면, 판독 불가 도착 안내판을 먼저 그린다. 두 번째 컷에만 같은 방향·구조에 정본 검은 세단, 비어 있고 열린 왼쪽 운전석, 상표·번호·인물 없음. 마지막 도로 시점은 정류장과 세단을 프레임 밖으로 두고 먼 전조등 두 점만 비춘다. 빗줄기·정차한 버스 없음. 기존 차량·건물은 덮어쓰지 않는다.

---

## 2026-08-27 M55 네 사람 회의 다은 복장 교정

- **모드:** OpenAI 내장 ImageGen 정밀 편집.
- **편집 대상:** `assets/cg/y5_three_in_room_v1.png`.
- **생성 원본:** `$CODEX_HOME/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-714436d2-4463-4b19-b8d0-3373afca4190.png`.
- **출시 경로:** `assets/cg/y5_three_in_room_v2.png` (1586×992 원본을
  1280×800으로 정규화).
- **최종 프롬프트:**

```text
Use case: precise-object-edit
Asset type: production visual-novel event CG for Gangnam Dream, M55 late-night contract meeting
Input image: Image 1 is the edit target.
Primary request: Change only Kim Daeun's clothing, the woman seated on the far right. Replace her convenience-store navy polo and beige knit cardigan with modest, situation-appropriate off-duty meeting clothes: a simple charcoal single-breasted jacket over a muted pale blue-gray blouse, with ordinary inexpensive fabric and no luxury styling.
Identity lock: Preserve Daeun's exact face, age 37–38, short black bob, left-temple hair clip, restrained expression, gaze toward Minjun, body proportions, seated pose, and both hands.
Scene invariants: Preserve Minjun in rear three-quarter view, Sangchul at far left, Jaehyuk at far center, every face and gaze, all four poses and hands, exact table and document ownership, laid-down red pen, one calculator, four paper cups, glass-walled night meeting room, clock, city background, 16:10 framing, lower dialogue-safe composition, lighting, palette, and Gangnam Ink Korean adult manhwa/VN realism.
Constraints: Change only Daeun's outfit. Her new clothes must read as practical serious civilian meeting attire, not executive luxury, not romance/date wear, and not a uniform. No logos, badge, lanyard, text, jewelry, signature, handshake, money, celebration, extra people, extra props, anatomy changes, or watermark.
```

- **판정:** 편의점 근무복 신호가 사라지고 평범한 계약 당사자 복장으로 읽힌다.
  다은의 신원·시선·손과 네 사람의 서류 소유·무서명 상태·크롭은 보존됐다.

---

## 2026-08-21 M01-M06 약속 선택 장면

아래 9개 이미지는 Codex built-in ImageGen으로 각각 별도 생성했다. 외부 사진이나
실존 인물 레퍼런스는 사용하지 않았다. 모두 선택 전 표면이므로 인물·브랜드·
판독 가능한 문자·합격/거절·계약/통화 완료·미래 결과를 넣지 않았다.

### survival_shift.png

- **최종 경로**: `assets/ui/m1m6_promises/survival_shift.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-4def-7c32-8e37-423453fd117f/exec-6857bd3b-18a6-4acf-9049-fc253291e3ac.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip — neutral survival shift
Primary request: An empty, modest late-night Korean service-work counter that communicates taking a survival shift without identifying any specific job or employer.
Scene/backdrop: A cramped anonymous back counter in contemporary Seoul at night, with a plain dark apron hanging from one hook, an unbranded timecard resting partly under the apron, and a small receipt printer on a worn laminate-and-stainless counter. The workspace is functional, humble, and quiet; no storefront signage and no recognizable chain layout.
Subject: The apron, timecard, and receipt printer form one clear still-life silhouette; nothing indicates whether the shift succeeds or what it pays.
Style/medium: Gangnam Ink visual language: desaturated Korean visual-novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contour, restrained cinematic lighting, quiet Seoul social-reality mood; contemporary illustrated environment, not a photograph.
Composition/framing: Wide horizontal UI-card scene, crop-safe at approximately 2.4:1. Props grouped left-of-center with layered counter depth; the right third falls into clean charcoal negative space suitable for white interface copy. No UI frame.
Lighting/mood: One tired cool fluorescent practical with a restrained warm spill from outside frame; low-key but readable.
Constraints: no people, no hands, no faces, no human silhouettes; no readable text, numbers, logos, brands, signage, price labels, UI, borders, title, or watermark; no future result, wage, success, or failure; no glossy mobile-game colors; no photoreal DSLR look.
Avoid: convenience-store-specific floor plan, restaurant food, hotel bell, corporate office, luxury props, cash, coins, celebratory lighting, sepia.
```

### father_call.png

- **최종 경로**: `assets/ui/m1m6_promises/father_call.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-4def-7c32-8e37-423453fd117f/exec-fe16c322-f949-4c9a-93e0-a82027e4fd4f.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip — father voice call
Primary request: A phone waiting for an ordinary scheduled voice call on Minjun's cramped goshiwon desk, with no person present and no response shown.
Scene/backdrop: The canonical economic starting-point language of a tiny Sinchon goshiwon: worn gray-beige wall, low desk at the foot of a narrow bed, black task lamp, a small high frosted ventilation window only, and a narrow sliver of bedding. One unbranded phone lies on the desk with a soft ordinary call glow; its screen contains only indistinct abstract light shapes, no caller identity.
Subject: The waiting phone under the task lamp; the empty room carries distance and responsibility without implying illness, death, reconciliation, or an answered call.
Style/medium: Gangnam Ink visual language: desaturated Korean visual-novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contour, restrained cinematic lighting, quiet Seoul social-reality mood; contemporary illustrated environment, not a photograph.
Composition/framing: Wide horizontal UI-card scene, crop-safe at approximately 2.4:1. Phone and lamp occupy the left-center foreground; the right third is restrained dark negative space for white interface copy. No UI frame.
Lighting/mood: Late-night cool room tone, soft phone glow, quiet and unresolved.
Constraints: no people, hands, faces, portraits, reflections, or human silhouettes; no pharmacy packet, medicine, hospital object, diagnosis clue, family photograph, large skyline window, trading workstation, readable text, numbers, caller name, logos, brands, UI, borders, title, or watermark; no answered-call icon; no future result; no glossy mobile-game colors; no photoreal DSLR look.
Avoid: dramatic emergency red, funeral implication, warm reunion image, split screen, multiple phones, luxury furniture, sepia.
```

### account_risk.png

- **최종 경로**: `assets/ui/m1m6_promises/account_risk.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-4def-7c32-8e37-423453fd117f/exec-d17cf328-6c89-4f4d-b9c7-1538737331c4.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip — account-risk check
Primary request: A tense but neutral account-risk review still life before a decision, not a trading scene and not an outcome.
Scene/backdrop: A modest cramped Seoul room desk with one unbranded phone beside a plain sealed bank envelope, a basic calculator whose keys and display show no legible numbers, and several account-freeze review sheets represented only by blank blocks, lines, and a single clipped corner. No official seal or institution identity.
Subject: Phone, envelope, calculator, and paperwork form a practical risk-check workspace; the account state and outcome remain hidden.
Style/medium: Gangnam Ink visual language: desaturated Korean visual-novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contour, restrained cinematic lighting, quiet Seoul social-reality mood; contemporary illustrated still life, not a photograph.
Composition/framing: Wide horizontal UI-card scene, crop-safe at approximately 2.4:1. The paperwork diagonals and calculator sit left-of-center; an empty charcoal desk plane and shadow create clean negative space on the right for white interface copy. No UI frame.
Lighting/mood: Restrained cool desk light, procedural tension, sober and unresolved.
Constraints: no people, hands, faces, human silhouettes, readable text, numbers, account balance, currency symbol, logo, bank brand, government seal, signature, stamp, UI, borders, title, or watermark; no result, approval, rejection, success, or failure; no glossy mobile-game colors; no photoreal DSLR look.
Avoid: stock charts, candlesticks, trading app, cryptocurrency, coins, banknotes, money bundles, laptop trading station, luxury desk, emergency red, sepia.
```

### job_result_notice.png

- **최종 경로**: `assets/ui/m1m6_promises/job_result_notice.png`
- **초기 생성 원본(폐기)**: `/Users/junheelee/.codex/generated_images/01a02209-4def-7c32-8e37-423453fd117f/exec-586dfd44-aa2c-4eb7-a45b-c2bfa6127038.png`
- **최종 교정 원본**: `/Users/junheelee/.codex/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-716b2946-ed84-4b48-9c4a-894de528e9d2.png`
- **스타일 참조**: `assets/ui/m1m6_promises/work_deadline.png`
- **최종 프롬프트**:

```text
Edit the FIRST image only. Preserve its neutral pre-result still life: one unbranded phone showing only an abstract pale notification rectangle, one closed worn application folder with blank papers, and one pen. Remove the large window, curtains, skyline, and any identifiable study-room location; replace them with a close, windowless, worn charcoal wall and desk so the setting remains canon-neutral and compatible with a cramped Sinchon goshiwon. Use the SECOND image only as the exact visual-style reference: clearly illustrated Korean adult manhwa/VN linework, dry ink contours, matte paper grain, controlled gray-beige painterly fill, restrained cinematic light, not photoreal, not 3D. Keep a wide horizontal composition with the props readable and generous dark negative space. No people, hands, faces, silhouettes, readable text, numbers, letters, checkmark, cross, colored acceptance/rejection cue, logos, brands, UI, border, title, watermark, employer, job outcome, celebration, or future result.
```

### family_signal.png

- **최종 경로**: `assets/ui/m1m6_promises/family_signal.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-4def-7c32-8e37-423453fd117f/exec-760fa66a-8a26-4308-9baa-34ea03b253fb.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip — family signal
Primary request: A distinct appointed-call moment on Minjun's cramped goshiwon desk, marked by an ordinary folded pharmacy paper packet beside the phone, without showing any person, answered call, or medical diagnosis.
Scene/backdrop: The same economic class language as a tiny Sinchon goshiwon but in a tighter alternate desk angle: worn wall, edge of a black task lamp base, low desk at the foot of a narrow bed, and only a faint high frosted ventilation-window glow. One unbranded phone rests beside one small, folded, plain pharmacy paper packet with no printing; the phone has a quiet neutral call glow made only of abstract light.
Subject: The phone and folded paper packet create a restrained family-health signal at the exact moment before a scheduled call; they do not identify a condition, medicine, caller, or result.
Style/medium: Gangnam Ink visual language: desaturated Korean visual-novel/manhwa realism, concrete gray and charcoal palette, matte paper grain, subtle ink-wash contour, restrained cinematic lighting, quiet Seoul social-reality mood; contemporary illustrated environment, not a photograph.
Composition/framing: Wide horizontal UI-card scene, crop-safe at approximately 2.4:1. The folded packet and phone form a compact foreground group left-of-center; the right third is clean charcoal negative space for white interface copy. No UI frame.
Lighting/mood: Cool late-night room tone, faint neutral phone glow, contained worry without melodrama.
Constraints: no people, hands, faces, portraits, reflections, or human silhouettes; no answered-call symbol, caller image, hospital equipment, pill bottle, loose pills, syringe, medical chart, diagnosis clue, emergency condition, death implication, readable text, numbers, pharmacy logo, brand, prescription label, UI, borders, title, or watermark; no future result; no glossy mobile-game colors; no photoreal DSLR look.
Avoid: duplicating the father-call composition, open medicine packaging, dramatic red alarm, funeral mood, family photo, large skyline window, luxury room, sepia.
```

### room_viewing.png

- **최종 경로**: `assets/ui/m1m6_promises/room_viewing.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-ac54-7c02-bfa9-246a021351c6/exec-d28e5175-b00b-4af1-b387-bb25445a1f91.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip for the Gangnam Dream game UI
Primary request: an early cheap-room viewing scene: a visibly modest, narrow, empty Korean one-room rental, adjacent in feeling to a goshiwon but clearly an unfurnished room being considered; a simple measuring tape and one plain key rest on the worn threshold; the scene must convey inspection and uncertainty only, never a completed contract or housing success
Scene/backdrop: cramped Seoul rental interior with a narrow doorway, scuffed floor, plain wall, small high window or weak ceiling light, no personal belongings
Subject: empty room, measuring tape, key on the threshold
Style/medium: Gangnam Ink visual language; desaturated Korean visual-novel/manhwa realism; charcoal and concrete-gray palette; matte paper grain; subtle ink-wash contours; restrained cinematic illustration, not photoreal DSLR
Composition/framing: wide horizontal 3:2 UI-card scene; low eye-level from the doorway; strong readable silhouette at thumbnail size; keep substantial dark negative space suitable for white UI copy overlay; no decorative UI border or frame
Lighting/mood: cool restrained evening light, quiet Seoul social-reality mood, modest and unresolved
Materials/textures: worn vinyl floor, chipped paint, brushed metal key, cloth measuring tape, subtle print grain
Constraints: no people, no hands, no faces, no readable text, no readable numbers, no logos, no brands, no watermark, no UI, no contract papers, no celebratory cue, no future result, no property success implication
Avoid: glossy mobile-game colors, cozy luxury, bright real-estate marketing photography, neon cyberpunk, exaggerated anime, staged glamour, legible signage
```

### livelihood_next.png

- **최종 경로**: `assets/ui/m1m6_promises/livelihood_next.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-ac54-7c02-bfa9-246a021351c6/exec-751e031f-91c8-4ba3-8c68-3fc387eb9eb4.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip for the Gangnam Dream game UI
Primary request: a livelihood-next-step scene that remains deliberately ambiguous among taking another shift, going back to work, or submitting another application: an empty Korean staff locker corridor with worn work shoes, a plain unlabeled application folder, and a shift board whose paper is entirely blank and unreadable; no outcome is shown
Scene/backdrop: modest employee back corridor in Seoul, narrow metal lockers, scuffed linoleum, a dim service-door light
Subject: empty staff passage, practical work shoes, closed plain application folder, blank shift board
Style/medium: Gangnam Ink visual language; desaturated Korean visual-novel/manhwa realism; charcoal and concrete-gray palette; matte paper grain; subtle ink-wash contours; restrained cinematic illustration, not photoreal DSLR
Composition/framing: wide horizontal 3:2 UI-card scene; corridor perspective; objects readable at thumbnail size; preserve substantial dark negative space for white UI copy overlay; no decorative UI border or frame
Lighting/mood: subdued fluorescent spill and faint cool daylight, quiet Seoul social-reality mood, unresolved but practical
Materials/textures: scratched painted steel, worn rubber soles, kraft-paper folder, soft paper grain
Constraints: no people, no hands, no faces, no silhouettes, no readable text, no readable numbers, no logos, no brands, no watermark, no UI, no job acceptance, no completed application, no future result
Avoid: glossy mobile-game colors, triumphant employment imagery, corporate office luxury, celebratory cue, neon cyberpunk, exaggerated anime, legible schedules or signage
```

### work_deadline.png

- **최종 경로**: `assets/ui/m1m6_promises/work_deadline.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-ac54-7c02-bfa9-246a021351c6/exec-4ae9fd89-8c00-48a8-b287-aed5132ca03d.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip for the Gangnam Dream game UI
Primary request: a Friday work-deadline still life: one plain sealed submission envelope, a generic round wall clock suggesting late afternoon through its hands but with a completely blank face and no digits or tick labels, a generic unbranded transit card, and a pen on a worn desk; the scene shows time pressure and the act of submitting only, never a job result
Scene/backdrop: modest shared-workspace desk in Seoul near the end of a gray weekday, anonymous wall behind it
Subject: blank submission envelope, blank-face late-afternoon clock, plain transit card, pen
Style/medium: Gangnam Ink visual language; desaturated Korean visual-novel/manhwa realism; charcoal and concrete-gray palette; matte paper grain; subtle ink-wash contours; restrained cinematic illustration, not photoreal DSLR
Composition/framing: wide horizontal 3:2 UI-card scene; slightly oblique tabletop view with the clock high in frame; all props readable at thumbnail size; preserve substantial dark negative space for white UI copy overlay; no decorative UI border or frame
Lighting/mood: muted late-afternoon window light crossing a worn desk, quiet Seoul social-reality mood, controlled urgency without melodrama
Materials/textures: creased kraft paper, scratched laminate, matte plastic transit card, used ballpoint pen, print grain
Constraints: no people, no hands, no faces, no readable text, no readable numbers, no digits or tick labels on clock, no logos, no brands, no watermark, no UI, no acceptance or rejection, no completed career outcome, no future result
Avoid: glossy mobile-game colors, celebratory office imagery, success stamp, checkmark, notification screen, smartphone display, neon cyberpunk, exaggerated anime, legible documents
```

### sangchul_field_door.png

- **최종 경로**: `assets/ui/m1m6_promises/sangchul_field_door.png`
- **생성 원본**: `/Users/junheelee/.codex/generated_images/01a02209-ac54-7c02-bfa9-246a021351c6/exec-53301f40-f83c-47ff-b6f8-6b01ee84b2cb.png`
- **최종 프롬프트**:

```text
Use case: stylized-concept
Asset type: M01-M06 promise-card scene strip for the Gangnam Dream game UI
Primary request: Sangchul's field-address scene: an anonymous aging Korean mixed-use building entrance at the edge of a narrow Seoul alley, with a small folded address note whose marks are entirely blurred and unreadable and a pair of used work gloves resting near the threshold; the scene represents arriving at an uncertain field address, not a meeting, deal, or result
Scene/backdrop: modest older neighborhood commercial-residential alley, concrete stair entrance, weathered metal door, utility pipes, muted street edge
Subject: empty building entrance, unreadable folded address note, used work gloves
Style/medium: Gangnam Ink visual language; desaturated Korean visual-novel/manhwa realism; charcoal and concrete-gray palette; matte paper grain; subtle ink-wash contours; restrained cinematic illustration, not photoreal DSLR
Composition/framing: wide horizontal 3:2 UI-card scene; oblique alley view aimed at the entrance; props readable at thumbnail size; preserve substantial dark negative space for white UI copy overlay; no decorative UI border or frame
Lighting/mood: cloudy late-day light with one restrained warm entrance spill, quiet Seoul social-reality mood, cautious and unresolved
Materials/textures: aged concrete, scratched metal, faded paint, fabric work gloves, folded paper, subtle print grain
Constraints: no people, no hands, no faces, no silhouettes, no readable text, no readable numbers, no address digits, no logos, no brands, no watermark, no UI, no handshake, no contract, no sale, no business success, no future result
Avoid: glossy mobile-game colors, noir crime danger, horror, luxury redevelopment, celebratory cue, neon cyberpunk, exaggerated anime, legible building or street signage
```

### 후처리와 검수

- `survival_shift`, `father_call`, `account_risk`, `job_result_notice`,
  `family_signal`은 각각 최종 생성·교정 원본을 1536x640 RGB로 정규화했다.
  `father_call`과 `family_signal`만 정본 고시원의 침대=왼쪽·책상=오른쪽을
  맞추기 위해 수평 반전했다.
- 나머지 4장은 생성 원본과 동일한 1536x1024 RGB PNG다.
- 아홉 장 모두 원본 해상도에서 인물·판독 문자·상표·결과 선취가 없음을 확인하고,
  Godot 4.6.2의 KO/EN 960x600·1280x800 M01/M06 실제 선택판에서 cover 크롭,
  잉크막, 포커스 확대, 텍스트 가독성을 확인했다.

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

2026-11-13 `assets/cg/story/knee_{witness,palm,help}_v1.png`와
`assets/backgrounds/changwon_family_stairwell_v1.png`는 57세 초상과 창원 거실을
참조해 생성했다. 민준 1인칭·무릎/서류·손바닥과 종이·팔꿈치/시선·실내 계단을
각각 분리하고, 맞은편 외부 현관이 시점을 뒤집던 세 원화를 재편집했다.
채택 원본 `exec-b56cb15c-c7f0-4bd8-b330-1ff776a384d5`,
`exec-7a59e4c5-a365-473c-8b2d-1fec58e0c42f`,
`exec-faff122f-fdce-4e8f-a90b-c0800c5bb55d`,
`exec-3bcdbbdb-27c7-4bde-8187-554a8c631ce8` (각 PNG). 1280×800 RGB 출력.

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

### daeun_regular_night_wait_v2.png — 2026-11-14

- 입력: v1 야간 외관은 편집 원본, `assets/characters/npc_romantic_interest.png`는 다은 얼굴·복식 참고만. 내장 이미지 편집 원본 1586×992 `9c31598fb2e9a5b8b30f684f2c2f3865708e96bf1f070a90249ab583a2656acf`; 배포 RGB 1280×800 `2424bb667cfc86e3f75415f1e3dd6b89a2dbcef60ebb2f7ac5b4277a0030d843`.
- 지시: 같은 마른 밤·같은 창과 매대, 외부에서 수첩을 주머니에 넣고 기다리는 민준 고정. 유리 안 직원 공간에 짧은 머리와 베이지 카디건/남색 근무복의 다은만 작게 넣고 POS를 내려다보게 한다. 눈맞춤·대화·손님·젖은 반사·로고·사진풍 없음. 기존 무광 잉크 톤과 구조를 보존한다. v1 파일 보존.

### wedding_daeun_small_v2.png — 2026-11-13

- **활성 1280×800**: `assets/cg/romance/wedding_daeun_small_v2.png`. 원본 `exec-5207e74d-4dd9-46d5-ad15-c23ba119122e.png` (1586×992). 이전 v1과 근접 컷은 보존.
- **편집 입력**: 이전 small wide는 공간과 시점, small close는 드레스·부케·조명, `npc_daeun_smile_y5.png`와 `npc_daeun_proposal.png`는 다은 얼굴·짧은 머리·왼쪽 클립의 기준.
- **제작 지시**: 제단에서 민준 너머 후문을 보는 한 단계 가까운 와이드. 소형 예식장과 빈 오른쪽 좌석, 왼쪽 익명 하객은 유지한다. 다은의 따뜻한 갈색 눈·자연스러운 성인 얼굴·작은 미소가 민준을 향하게 한다. 얼굴과 꽃다발을 쥔 양손은 하단 대사 영역 위에 둔다. 매트한 한국 성인 만화풍, 얼굴·드레스 경계 선명, 전체 세피아·인형 피부·글자·로고 없음.

### wedding_daeun_small_v1.png (보존) / wedding_daeun_full_v1.png

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

## 2026-11-14 — W57 지하철 환승 통로

- `assets/backgrounds/seoul_subway_transfer_passage_v1.png`, 1584×990 RGB, SHA-256 `cf2ff1c14e0da90af11fee268987837c3edc92cc1fa8e48bdc4714b705939229`.
- 생성 원본 `exec-f0dfbecd-301b-4cfd-b2ff-9cfadc570556.png`, SHA-256 `5628f26809523a5c80c3ac33199dadde6109d76e21481ee4f57fac9f1faf4370`; 테두리 1px씩만 잘라 16:10. `subway_station_stairs.png`와 `subway_station_coin_lockers.png`는 재질·그림체 참조, 같은 역 단정 없음.

> Use case: illustration-story. Create one brand-new 16:10 wide opaque background illustration for Gangnam Dream, a contemporary Korean social-reality visual novel. Both reference images are STYLE AND MATERIAL references ONLY, not edits, and not the same identifiable station; do not reuse their stairs, gates or lockers. Scene: 7 p.m. in a Seoul subway interchange, viewed from adult eye height standing just outside the flow at the edge of a windowless underground passenger transfer passage. Distinct shallow wall-side recess with one squared column, a clearly navigable central walking lane that turns into another part of the station in the far middle distance; not a dead end. Two or three far anonymous commuters pass in different directions, small, unidentifiable, naturally proportioned and not posed, with 2-3 tonal planes only; no front figures or main cast, no phone or gesture baked into the frame. Concrete charcoal-gray tile walls, slightly worn cool gray matte terrazzo, brushed metal trim only where architecture physically uses it, modest overhead rectangular fluorescent panels. Subtle restrained gray-brown architectural accent (does not identify a line); no puddles, no active weather. Non-photographic Korean manhwa realism; clearly hand-inked controlled edge contour, matte paper grain, layered ink-wash tones, stylized reduced reflected highlights, no DSLR depth blur and zero photographic gloss. Preserve legibility in dim grayscale; no crushed black void, no flashy spotlight, no warm sepia. The transfer lane is readable above a lower dialogue panel; right side quiet and not high-contrast to allow a separate character portrait, but do not put any portrait, UI, borders or text in the supplied art. No track, vehicle, carriage interior, platform edge, stair flight, ticket gate, locker bank, mall, shop, signage letters, numbers, logos, watermark, or outdoor view. Medium-wide eye-level perspective with physically solid tile and column alignment, like a painted dramatic establishing frame instead of real estate photography.

## 2026-11-14 — W57 승차 뒤 객차

- `assets/backgrounds/seoul_subway_commuters_w57_v1.png` SHA-256 `5f2051da41bedf0ab3cebf5dbb504588d2843374632c3ba5caabc6caa4bf54a5`. `seoul_subway.png`를 구조·재질·구도의 편집 원본으로 사용했다.
- 생성 원본 `exec-efe5af97-587f-440e-b39b-795de80c68e3.png` SHA-256 `4a5e91e0fc3eb0b16af973477d65f5b72f28a1c8cafd15c067122bc6665658bd`. 네 가장자리 1px씩 크롭해 1584×990. 기존 빈 객차 원화는 보존.

> Use case: precise-object-edit; game background for a contemporary Korean social-reality visual novel. Input Image 1 is the exact approved Seoul subway cabin, edit it without changing the viewpoint, structure or existing design. Keep original subdued inked contours, orange-brown benches, stainless poles fixed to floor and ceiling, smooth closed side doors without text, dark tunnel through the windows, floor and ceiling perspective, crop and light. Only change the population: add a modest weekday 7 p.m. group of anonymous Korean adult commuters, some seated in natural proportions and two or three standing deeper in the aisle holding existing poles or triangle straps at plausible heights. A few figures visible from quarter-back or profile, not looking at camera; varied dark gray/brown everyday coats and couple of muted bags, different heights and realistic silhouettes; no recurring characters, no foreground faces or main cast, no crowd drama. Place the visible heads and standing shapes mostly in the left/mid depth and above the dialogue-safe bottom third; leave the rightmost quarter and immediate foreground clear for a separately rendered portrait. Enough people to read as a real small evening group, not a deserted car, nor jam-packed. Preserve moderate illustrated Korean manhwa realism, restrained matte grain, no glossy camera feel, no text, fake signage, brand, UI, extra glass reflection of people, outdoors or visible platform. Landscape 16:10.

## 2026-11-14 — W57 창원역·약봉투 식탁

- `assets/backgrounds/changwon_station_arrival_gate_v1.png` SHA-256 `a0254f1e490a50c3939199c8e2296e530844caf6bc6402b6ec1ae165cda81c51`, 생성 원본 `exec-f3f7244c-8af9-448f-8ac4-ff1980dde2a2.png` SHA-256 `e50f68882dc91223fe56ed8705e1bd89e4cdc8ab74bed3f06e2fa4f24c32d792`. 서울 역사와 지방 역은 각각 동선/재질과 지역 규모 참조만.
- `assets/backgrounds/changwon_home_medication_table_v1.png` SHA-256 `2eb77acc0df88ac411a58eec5b34223ba18ba3332749896429e100013242e0e0`, 생성 원본 `exec-d07e2b18-212f-4bf8-b0fe-71d5e00c1090.png` SHA-256 `8749a06f3ceda480d1d77fa7feace5af3bcef14c9963f6766119c29b1307f20b`. `family_living_room.png`의 소파·현관·가구 배치를 이어 그렸다. 첫 두 후보는 약봉투가 하단 대화창과 겹치거나 너무 가까워 미채택.
- 두 최종본은 생성 원본의 네 가장자리에서 1px씩만 잘라 1584×990으로 맞췄다. P1 고해상도 마스터 아님.

> Use case illustration-story. Landscape 16:10 for Korean social-reality visual novel Gangnam Dream: a modest Changwon regional railway station interior, from the public waiting side immediately outside the access checkpoint to the platform. Reference image 1 (Seoul concourse) is ONLY a circulation/checkpoint and art-style reference; reference image 2 (provincial station) is ONLY regional scale and materials, do not show its platform. A three-quarter adult eye-height view from the public waiting hall, one clearly legible simple brushed steel ticket-check pedestal and waist-high rail gate connected to a plausible passage behind, modest gray metal frames, muted buff stone, gray terrazzo, a practical row of old seats on the public side, a little diffused light entering through high frosted windows without time/weather specificity. No outdoor view, tracks, train, metro turnstile bank, cavernous tower, logos, station text, readable signage, photographic blur, no foreground character, nobody holding a bag; two tiny layered anonymous travelers far left if needed. Reserve right third as quiet layered wall for separately rendered Father. Keep ticket-control silhouette above bottom third. Desaturated Korean manhwa architectural realism, decisively painted with clean ink contours and matte grain; soft restrained lighting, no DSLR look, no glossy real-estate render, no UI.

> Use case illustration-story. One wide 16:10 Korean visual-novel scene background, W57 in a working-class Changwon father's home. The supplied family_living_room reference is the EXACT home continuity anchor: same modest cramped proportions, old warm-gray worn floral wallpaper, deep dark worn sofa visible on the left, tall narrow recessed front doorway to the far rear-right with small rectangular frosted transom, worn timber, and modest TV furniture at the far right if seen. Do not move or redesign that layout, faint background only. New low seated eye-height view across the existing plain worn wooden family table. Above the bottom third where dialogue will sit, at center-left is exactly one ordinary palm-sized folded white Korean pharmacy paper envelope with an abstract tiny printed grid of dosage markings that cannot be read, and immediately next to it one small plain clear tumbler of water. View is physically plausible low seated, gently tilted toward the tabletop. Everything modest and ordinary; no labels, numerical dose, brand, capsules, pill bottles, newspaper, remote control, food, flowers, extra place settings, extra furniture or electronics, person, hands, portrait, UI, text, or outdoor view. No overhead or floor camera. Use game’s distinct hand-inked manhwa matte realism, thin ink contour and layered dry brush, restrained cool-brown neutral interiors, plausible values, no DSLR realism, no glossy surfaces. Leave the right and lower third unobstructed; place the recognizable envelope and drinking glass between 37 and 60 percent height so both remain visible above a game dialogue overlay.

> Create a distinctly NEW closer angle of this exact scene from higher seated human eye height, keeping the same room and tabletop but tilting the view downward. This is an illustration composition with the TOP HALF showing the far end of the low table and the featured two very ordinary small objects, and the BOTTOM HALF showing empty worn wooden tabletop flowing all the way to the lower edge. Put both palm-sized folded pharmacy envelope and 200 ml glass near x=45% and y=43% from top, completely inside the middle band from 33% to 55% canvas height. Make them both legible but physically small, with a true 10 cm medicine envelope and 9 cm glass proportional to the furniture. Reducing the wall/ceiling area is the priority: show NO ceiling, NO full-height doorway; the upper frame can show largely the lower couch and lower far doorway. Preserve identical sofa on left and entry rear right, modest exact Changwon studio house style/wood/wall material. Do not add a chair or change the room. No new print, no legible numbers, no people, no doily, no UI. Hand-inked Korean manhwa VN, NOT a photograph. 16:10 landscape.

## 2026-11-14 — M07 공용 세면대

- 최종: `assets/backgrounds/goshiwon_shared_washbasin_v1.png`, 1584×990, SHA-256 `52e30cbb8e5e046877e7dcb522e2427156a679643b0be0e7ee499fcc147ec815`.
- Codex 내장 생성. 원본 `exec-a3ffbbe2-0596-4f37-b61d-baa1144503dc.png`, SHA-256 `8e4f2e1b0a02ac3535971955ef449eacdbc44b7f8358c87f8cf0fbaedef91293`. 비율 정합은 네 가장자리 1px 크롭만.
- 입력 순서: `assets/backgrounds/{goshiwon_hallway,hyunsu_exam_room_v2,goshiwon_shared_kitchen}.png`. 각각 복도 재질, 눈높이·회화 질감, 공용부 재료를 참조.
- 프롬프트:

```text
Use case: illustration-story. Asset type: one 16:10 visual-novel reusable fullscreen background, no UI. Generate a new person-free view of the shabby communal FACE-WASH BASIN alcove in the same modest Sinchon goshiwon, seen by an adult standing just outside the open wash alcove, 1.60m eye height, moderate lens, not a floor view. Image 1: canon corridor, use its dark slate painted steel doorframe, surface-mounted pipework, worn charcoal floor tile and desaturated plaster, not its floor plan. Image 2: reference only for the hand-painted style, adult door-scale and texture in this same goshiwon; do NOT copy any bedroom props. Image 3: reference only for matching communal aged surfaces and ordinary local fluorescents, do NOT copy kitchen fixtures. Main subject: a real, modest, wall-mounted OFF-WHITE glazed ceramic face-washing basin, only about 50 cm wide and 80 cm high, with one plain chrome tap releasing a quiet, very thin clear stream directly into the bowl; make the basin rim and tap visible on the left-center above the lower 34% reserved for dialogue. One modest plain rectangular slightly worn mirror above with geometrically correct empty wall reflection, no person or false doorway; simple ivory wall tiles only in the backsplash, painted worn gray-beige plaster and exposed small functional plumbing. A clear adult-width doorway with familiar dark gray steel jamb and a glimpse of the corridor wall/charcoal tile; tiled floor continues through the threshold. Rightmost quarter subdued and unbusy. Older functional cramped Seoul indoor architecture—not a kitchen, toilet-stall view, private bathroom, fancy spa or abandoned ruin. No beds, desks, books, stove, fridge, visible people, reflection silhouettes, text, logos, UI, rain, city view or implied hour. Match Gangnam Ink contemporary Korean manhwa: clear restrained ink contours on architecture, dry-brush matte paper grain, legible shaded muted cool grey and warm grey—not a photograph, 3D render, slick anime or overly dark horror. Familiar low-key fluorescent light, no spotlight or luxury polish. Wide landscape full bleed, straight natural architectural lines, avoid bevelled black border or framing ornament. Composition must survive a small vertical center crop to 16:10.
```

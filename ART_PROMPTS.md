# 강남드림 — AI 아트 & 음악 프롬프트 가이드

---

## 스타일 가이드 (공통)

- **스타일**: 한국 웹툰 + 로우파이 일러스트 혼합. 깔끔한 선화에 플랫 컬러.
- **컬러 팔레트**: 다크 배경 (#0c0c10), 골드 액센트 (#f0b429), 블루 (#5b9cf6), 청록 (#00c896)
- **분위기**: 현실적이지만 약간 낭만적. 서울 야경의 차갑고 아름다운 느낌.
- **레퍼런스 게임**: Citizen Sleeper, 80 Days, Neo Cab

---

## 1. 메인 캐릭터 일러스트

### GPT / DALL-E 프롬프트

**기본 (중립 표정)**
```
Korean webtoon illustration style, young Korean male in his early 20s,
short dark hair, wearing a plain white t-shirt and jeans,
standing against a dark city background,
flat color style with clean linework, slightly melancholic expression,
lo-fi aesthetic, dark blue and gold color palette,
game character portrait, waist-up shot,
no background clutter, simple dark background (#0c0c10)
```

**표정 2 — 결의 (취업 성공 시)**
```
Same young Korean male character, determined and motivated expression,
slight upward gaze, clean webtoon linework,
soft golden light on face, dark background,
game character portrait illustration
```

**표정 3 — 피로 (스트레스 높을 때)**
```
Same young Korean male character, tired and stressed expression,
slightly disheveled hair, under-eye shadows,
cool blue tones, webtoon illustration style,
dark atmospheric background
```

**표정 4 — 성취 (자산 마일스톤)**
```
Same young Korean male character, surprised and joyful expression,
looking at smartphone screen with light reflecting on face,
golden warm tones, webtoon style, dark background
```

### Midjourney 프롬프트
```
young Korean man, early 20s, webtoon illustration, flat color,
clean linework, dark background, lo-fi aesthetic, city night vibes,
character portrait, waist-up, slight melancholy, simple clothing
--style raw --ar 2:3 --q 2
```

---

## 2. 배경 아트 (4종)

### 고시원 방 (시작 배경)
```
Tiny Korean goshiwon room interior, 1.5 pyeong (5 sqm),
single bed, small desk, small window showing only a brick wall,
dim warm light, slightly cramped but lived-in,
webtoon/illustration style, lo-fi aesthetic,
dark warm color palette, realistic but stylized,
no character, establishing shot
```

### 원룸 (중반 업그레이드)
```
Small Korean one-room apartment, cozy but simple,
window showing Seoul cityscape at night,
desk with laptop, some plants, city lights visible outside,
webtoon illustration style, warm evening light,
slightly better quality than goshiwon, hopeful atmosphere
```

### 강남 아파트 (후반 목표)
```
Modern Korean apartment living room, large windows,
stunning Seoul night skyline view, Gangnam district visible,
clean minimal furniture, city lights, aspirational atmosphere,
webtoon illustration style, golden and blue tones,
luxury but not ostentatious
```

### 서울 거리 (이벤트 배경)
```
Seoul street scene at night, neon signs in Korean,
convenience store (편의점) visible, pedestrians silhouettes,
rainy night, reflections on wet pavement,
lo-fi illustration style, moody atmosphere,
warm neon lights against dark blue night sky
```

---

## 3. Steam 키아트 / 로고

### 키아트 프롬프트
```
Korean mobile game key art, young Korean man standing on a Seoul rooftop,
looking at the glittering Gangnam skyline in the distance,
small figure vs vast city, conveying ambition and loneliness,
webtoon illustration style, dramatic lighting,
gold skyscrapers in background, dark foreground,
title text space at bottom: "강남드림"
--ar 16:9
```

### 로고 프롬프트 (GPT)
```
Logo design for Korean indie game "강남드림" (Gangnam Dream),
Korean text 강남드림 in bold stylized font,
gold color (#f0b429) on dark background,
small Gangnam skyline silhouette integrated into letterforms,
clean minimal game logo style, no excessive decoration
```

---

## 4. BGM 프롬프트 (Suno / Udio)

### 메인 테마 — 서울 상경기
```
[Suno prompt]
lo-fi hip hop, gentle piano melody, soft drums,
nostalgic and slightly melancholy mood,
Seoul city vibes, late night studying alone,
Korean indie atmosphere, hopeful undertone,
instrumental only, 2-3 minutes loop
```

### 긴장 테마 — 위기 상황 (건강/멘탈 위험)
```
[Suno prompt]
tense ambient electronic music, minimal drums,
slightly unsettling but not horror,
building pressure feeling, urban stress,
low bass hum, occasional piano notes,
instrumental, 90 second loop
```

### 승리/성취 테마 — 마일스톤 달성
```
[Suno prompt]
uplifting lo-fi with triumphant feeling,
celebratory but understated, not over-the-top,
soft piano + warm synth pads,
Korean indie pop influence, hopeful and bright,
instrumental, 60-90 second loop
```

### 엔딩 테마 — 강남드림 달성
```
[Suno prompt]
emotional orchestral lo-fi hybrid,
bittersweet triumph feeling, like reaching a long-sought goal,
piano lead with strings, gentle beat,
reflective and moving, Korean drama OST influence,
instrumental, 2-3 minutes
```

---

## 5. UI 아이콘 (선택사항)

```
Minimal flat icons for Korean life sim game:
- 💼 briefcase for job
- 📈 chart for investment  
- 🏠 house for housing
- ❤️ heart for health
- 🧠 brain for mental
Style: minimal line icons, gold (#f0b429) on dark background,
32x32 pixel-friendly, clean and readable at small sizes
```

---

## 제작 우선순위

1. **메인 캐릭터 기본 표정** — 게임 내 이벤트 창 좌측에 배치
2. **고시원 + 강남 배경** — 시작/엔딩 화면에 사용
3. **키아트** — Steam 스토어 페이지 메인 이미지
4. **메인 BGM** — 게임 전반 분위기 설정
5. 나머지 표정/배경/음악

---

*이 프롬프트들은 DALL-E 3, Midjourney v6, Suno v3/v4에 최적화됨*
*생성 후 game/assets/ 폴더에 저장하고 Godot에서 TextureRect로 로드할 것*

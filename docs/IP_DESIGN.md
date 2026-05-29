# 강남드림 — IP 설계 & 세계관 완성 로드맵

> 작성일: 2026-05-22  
> 목적: 게임 IP로서의 정체성 확립, 필요 에셋 전량 분석, 코드/AI 작업 분담 정의

---

## 1. IP 정체성 정의

### 한 줄 콘셉트
> "100만원 들고 서울에 올라온 당신. 강남드림은 꿈인가 착각인가."

### 장르 & 톤
- **장르**: 한국형 라이프 시뮬레이터 로그라이크
- **톤**: 현실적이되 약간 과장된 서울 청년의 삶. 냉소적이지만 포기하지 않는 에너지.
- **레퍼런스 분위기**: 미생 (직장 현실) + 오징어 게임 (생존 구조) + 슬램덩크 (청춘의 열기)
- **아트 방향**: 웹툰 감성 세미리얼. 어둡고 습한 서울 밤거리 + 형광등 아래 고시원.

### 타깃 유저
- 20~35세 한국 청년 (혹은 한국 도시문화에 공감하는 해외 유저)
- "벼락거지" "영끌" "번아웃" 같은 단어가 익숙한 사람들
- Balatro, Hades 같은 로그라이크 팬 + 가벼운 경영 시뮬 팬

### 핵심 감정 루프
```
희망 → 현실직시 → 포기 직전 → 반전 → 다시 희망
```
플레이어가 매 런마다 이 사이클을 반복하며 "한 번 더"를 누르게 만드는 것이 목표.

---

## 2. 컬러 시스템 (의미 있는 팔레트)

현재 색은 랜덤에 가깝다. 아래와 같이 **의미 기반**으로 통일한다.

| 역할 | 헥스 | 의미 |
|------|------|------|
| 배경 기본 | `#0a0a12` | 서울의 밤, 고시원의 어둠 |
| 배경 패널 | `#12121e` | 형광등 아래 책상 |
| 테두리 기본 | `#1e1e32` | 낡은 철제 서랍 |
| 강조 Gold | `#f0b429` | 강남드림, 야망, 목표 |
| 긍정 Green | `#00c896` | 돈, 성장, 가능성 |
| 정보 Blue | `#5b9cf6` | 데이터, 시황, 지식 |
| 위험 Red | `#ff4d4d` | 스트레스, 위기, 실패 |
| 중립 Gray | `#8892a4` | 평범한 일상, 무직 상태 |
| 고급 Purple | `#a78bfa` | 금수저, 엘리트 루트 |
| 생존 Orange | `#fb923c` | 번아웃 직전, 경고 |

**적용 원칙**: 모든 버튼, 라벨, 아이콘은 이 팔레트에서만 선택. 임의의 색 사용 금지.

---

## 3. 타이포그래피

현재 시스템 기본 폰트 사용 중. 아래로 교체 필요.

| 용도 | 폰트 | 크기 범위 |
|------|------|-----------|
| 타이틀 / 로고 | Noto Sans KR Black 또는 Pretendard ExtraBold | 32~48px |
| 본문 / 이벤트 | Pretendard Regular / Medium | 14~16px |
| 수치 / 스탯 | JetBrains Mono (영문 숫자) | 12~14px |
| 미니 라벨 | Pretendard Light | 10~11px |

> **코드 작업**: Godot에서 커스텀 폰트 로드 (`.ttf` → import → `add_theme_font_override`)

---

## 4. 현재 에셋 현황 및 누락 목록

### 4-1. 보유 이미지 (12개)

| 파일 | 상태 | 비고 |
|------|------|------|
| `backgrounds/goshiwon_room.png` | ✅ 있음 | 품질 미확인 |
| `backgrounds/oneroom_apartment.png` | ✅ 있음 | |
| `backgrounds/gangnam_apartment.png` | ✅ 있음 | |
| `backgrounds/seoul_rainy_street.png` | ✅ 있음 | |
| `backgrounds/office_desk.png` | ✅ 있음 | |
| `backgrounds/seoul_subway.png` | ✅ 있음 | |
| `characters/main_character_neutral_goshiwon.png` | ✅ 있음 | |
| `characters/main_character_tired.png` | ✅ 있음 | |
| `characters/main_character_determined.png` | ✅ 있음 | |
| `characters/main_character_happy.png` | ✅ 있음 | |
| `keyart/gangnam_dream_keyart_rooftop.png` | ✅ 있음 | 스타트 화면용 |
| `logos/gangnam_dream_logo_concept.png` | ✅ 있음 | 로고 초안 |

### 4-2. 필요하지만 없는 이미지 (GPT 생성 필요)

#### 캐릭터
| 파일명 | 설명 |
|--------|------|
| `characters/main_character_stressed.png` | 스트레스 80+ 상태, 다크서클, 헝클어진 머리 |
| `characters/main_character_rich.png` | 후반 고자산 상태, 깔끔한 정장 |
| `characters/rival_character.png` | 라이벌. 비슷한 나이, 약간 더 여유있어 보임 |
| `characters/npc_boss.png` | 직장 상사. 40대, 피곤한 눈빛 |
| `characters/npc_friend.png` | 고시원 이웃 친구. 편안한 인상 |

#### 배경
| 파일명 | 설명 |
|--------|------|
| `backgrounds/cafe_interior.png` | 동네 카페. 따뜻한 조명, 창가 자리 |
| `backgrounds/startup_office.png` | 스타트업 오피스. 오픈형, 맥북들 |
| `backgrounds/gangnam_street.png` | 낮의 강남 거리. 빌딩숲, 인파 |
| `backgrounds/rooftop_night.png` | 옥상에서 본 서울 야경. 아파트 불빛들 |
| `backgrounds/stock_market_screen.png` | 투자 화면 배경. 여러 모니터, 차트 |
| `backgrounds/hospital.png` | 병원 대기실. 번아웃/건강 이벤트용 |

#### UI & 로딩
| 파일명 | 설명 |
|--------|------|
| `ui/loading_screen_bg.png` | 로딩 화면 배경. 서울 실루엣 + 새벽빛 |
| `ui/logo_final.png` | 최종 로고. 金+한글 강남드림 조합 |
| `ui/ending_screen_bg.png` | 엔딩 화면 공통 배경 |
| `ui/card_texture.png` | 아이템/이벤트 카드 배경 텍스처 |

---

## 5. 오디오 방향

### 현재 상태
- BGM: 프로그래매틱 sine wave 4바 루프 (Cm7→Ab→Eb→Bb)
- SFX: 프로그래매틱 tone 생성

### 목표 오디오 방향

#### BGM 트랙 목록 (필요)
| 트랙 | 분위기 | 장면 |
|------|--------|------|
| `main_theme` | lo-fi + 국악기 혼합. 서울의 새벽 | 스타트메뉴 |
| `daily_grind` | 미니멀 재즈, 약간의 긴장감 | 평상시 게임플레이 |
| `pressure` | 현악기, 점점 쌓이는 느낌 | 스트레스 60+ 상황 |
| `breakthrough` | 업비트, 피아노 + 전자음 | 성공적인 달 결산 |
| `burnout_theme` | 느리고 무거운, 단조 | 번아웃/위기 상황 |
| `gangnam_dream` | 웅장한 오케스트라 | 강남드림 엔딩 |

> **현실적 해결**: Godot의 프로그래매틱 BGM을 여러 버전으로 분기하거나, 무료 라이선스 음악 사용 (Pixabay, FreeMusicArchive)

#### SFX 추가 필요
| 사운드 | 용도 |
|--------|------|
| `notification` | 이벤트 등장 시 |
| `relationship_up` | 관계 호감도 상승 |
| `level_up` | 스탯 큰 폭 상승 |
| `rent_paid` | 월세 납부 |
| `job_get` | 취직 성공 |
| `stock_crash` | 시장 폭락 |
| `page_turn` | 이벤트 선택지 등장 |

---

## 6. 코드로 해결 가능한 것 (내가 작업)

### 6-1. 로딩 화면
```
- 스플래시: 로고 이미지 + 페이드인 (SceneTransition 활용)
- 로딩 바: 자산 로딩 진행률 표시
- 배경: loading_screen_bg.png 또는 프로그래매틱 서울 스카이라인
```

### 6-2. UI 폴리시
```
- 버튼: 모서리 gradient + hover 애니메이션
- 카드 컴포넌트: 아이템/이벤트 카드에 그림자 효과
- 스탯 바: 텍스트 수치 대신 게이지 바로 시각화
- 이벤트 패널: 좌측 테두리 컬러 코딩 (카테고리별)
- 숫자 팝업 애니메이션: +100만원, -스트레스 등 플로팅 텍스트
- 파티클: 강남드림 달성 시 골드 파티클
```

### 6-3. 씬 연출
```
- 배경 전환: 크로스페이드 (현재 즉시 전환)
- 초상화 감정 전환: 부드러운 페이드
- 이벤트 등장: 슬라이드인 애니메이션
- 결산 화면: 숫자 카운팅 애니메이션 (0 → 실제 값)
```

### 6-4. 추가 오디오 (프로그래매틱)
```
- BGM 분위기 분기: 스트레스 수치에 따라 템포/음색 변화
- 상황별 스팅어: 짧은 효과음 레이어링
```

---

## 7. GPT 이미지 생성 프롬프트

아래 프롬프트는 ChatGPT (DALL-E 4) 또는 Midjourney에 그대로 사용 가능.  
**공통 스타일 태그**: `korean webtoon style, semi-realistic, dark urban aesthetic, muted color palette, cinematic lighting`

---

### [P01] 로딩 화면 배경
```
A cinematic wide-angle view of Seoul at dawn seen from a rooftop.
City skyline silhouette with warm golden sunrise breaking through dark blue-grey sky.
Foreground: a young man's silhouette standing alone looking at the city.
Style: korean webtoon illustration, painterly, slightly desaturated, melancholic but hopeful mood.
Color palette: deep navy (#0a0a12), gold (#f0b429), pale dawn orange.
Format: 16:9 landscape, 1920x1080.
No text. No UI elements.
```

---

### [P02] 메인 캐릭터 — 스트레스 상태
```
Korean male in his early 20s, sitting alone in a tiny gosiwon room (3x2m room).
Expression: exhausted, dark circles under eyes, slight despair.
Wearing: wrinkled casual t-shirt, messy hair.
Background: dim fluorescent light, small desk with ramen cup, phone showing stock market red.
Style: korean webtoon semi-realistic character portrait, full body visible, vertical format.
Color tone: desaturated, cold blue-green tint.
Format: portrait 9:16, transparent or dark background.
```

---

### [P03] 메인 캐릭터 — 부자 상태
```
Same Korean male, now late 20s, standing confidently.
Expression: calm, self-assured, slight smile.
Wearing: clean fitted business casual — navy slacks, white shirt, no tie.
Background: modern Gangnam office building lobby, glass and marble.
Style: korean webtoon semi-realistic, polished, warm lighting.
Color tone: warmer, more saturated than early game.
Format: portrait 9:16.
```

---

### [P04] 라이벌 캐릭터
```
Korean male, early 20s, similar age to main character.
Expression: confident, slightly competitive smirk, not villainous — just ahead.
Wearing: trendy streetwear, expensive sneakers, casual flex.
Background: neutral dark.
Style: korean webtoon illustration, distinct silhouette from main character.
Format: portrait 9:16, transparent background.
```

---

### [P05] 배경 — 카페 인테리어
```
Small Korean neighborhood café interior, warm and cozy.
Large window showing rainy Seoul street outside.
Wooden furniture, hanging plants, soft warm light.
Empty seat by the window with a coffee cup.
Style: korean webtoon background art, slightly stylized, detailed.
Color palette: warm amber and green, contrasting with grey Seoul rain outside.
Format: 16:9 landscape, no characters.
```

---

### [P06] 배경 — 스타트업 오피스
```
Modern Korean startup office interior.
Open layout with MacBooks, sticky notes on glass walls, standing desks.
Late evening — city lights visible through floor-to-ceiling windows.
Slightly chaotic but energetic atmosphere.
Style: korean webtoon background art, semi-realistic.
Color palette: cool blue and white, warm desk lamp highlights.
Format: 16:9 landscape, no characters.
```

---

### [P07] 배경 — 강남 거리 (낮)
```
Busy Gangnam-gu street in Seoul, daytime.
Wide boulevard with brand flagship stores, luxury car, well-dressed pedestrians.
Slightly overwhelming scale — the protagonist feels small here.
Style: korean webtoon background illustration, detailed, urban.
Color palette: bright but slightly harsh noon light, grey concrete, glass reflections.
Format: 16:9 landscape, no characters.
```

---

### [P08] 배경 — 옥상 서울 야경
```
Seoul rooftop at night.
View of endless apartment lights stretching to the horizon.
Han River faintly visible in the distance. Neon signs below.
Lone plastic chair and empty soju bottle in foreground.
Style: painterly korean webtoon, contemplative mood, beautiful but lonely.
Color palette: dark navy sky, warm orange apartment windows, cold blue streetlights.
Format: 16:9 landscape.
```

---

### [P09] 로고 파이널
```
Logo design for a Korean mobile/PC game called "강남드림" (Gangnam Dream).
Concept: Korean ambition, social climbing, urban hustle.
Design: Bold Korean typography "강남드림" with a stylized golden apartment building or coin integrated.
Style: Clean, modern, game logo aesthetic. Works on dark background.
Color: Gold (#f0b429) on dark navy (#0a0a12), with subtle gradient.
Format: Square 1:1 for icon + wide 4:1 for banner variant.
No English text needed.
```

---

### [P10] 엔딩 화면 — 강남드림 달성
```
Celebratory illustration for "Gangnam Dream" game ending.
Korean young man standing on penthouse balcony, hands in pockets, looking at Seoul night panorama.
Golden sparkle/confetti falling.
Mood: triumphant, earned, slightly bittersweet.
Style: cinematic korean webtoon, rich colors, detailed.
Color palette: gold, deep navy, warm city lights.
Format: 16:9 landscape.
```

---

### [P11] 엔딩 화면 — 번아웃
```
Illustration for burnout ending.
Empty gosiwon room, morning light through thin curtains.
Scattered papers, dead phone, untouched meal.
No person visible — implied absence.
Mood: quiet, heavy, sad but not dramatic.
Style: korean webtoon background, muted, desaturated.
Format: 16:9 landscape.
```

---

## 8. 추가 컨텐츠 필요 목록 (세계관 완성)

### 이벤트 추가 필요 (코드 작업)
| 카테고리 | 필요 이벤트 수 | 현재 |
|----------|---------------|------|
| 스토리 (메인 서사) | 12개 | ~8개 |
| 직장 생활 | 15개 | ~6개 |
| 관계 (로맨스 포함) | 20개 | ~10개 |
| 투자/경제 | 20개 | ~12개 |
| 사회적 사건 (뉴스 연계) | 10개 | ~5개 |
| 숨겨진 이벤트 | 8개 | ~4개 |

### 뉴스 헤드라인 (시황 탭 몰입도 향상)
- 현재: 템플릿 기반 생성
- 목표: 실제 한국 경제 뉴스 패러디 50개 추가
- 예시: "한강변 아파트 전세가 역대 최고치", "코스피 개인투자자 '물렸다' 반응 폭주"

### 관계 시스템 확장
- 로맨스 이벤트 체인 (5단계: 첫만남 → 썸 → 사귀기 → 갈등 → 결말)
- 멘토 관계 (선배 직장인, 재테크 고수)
- 라이벌 관계 업데이트 (현재 라이벌 로직은 기본적)

---

## 9. 작업 우선순위 (IP 완성도 로드맵)

### Phase 1 — 코드 작업 (즉시 가능)
1. 로딩 화면 구현 (프로그래매틱 or 기존 keyart 활용)
2. 숫자 팝업 애니메이션 (+돈, -스트레스 플로팅 텍스트)
3. 이벤트 패널 카테고리별 좌측 컬러 바
4. 스탯 게이지 바 (텍스트 수치와 병행)
5. BGM 스트레스 연동 분기 (긴장감 증폭)
6. 배경 크로스페이드 전환
7. 커스텀 폰트 적용 (Pretendard)

### Phase 2 — AI 이미지 생성 후 적용
1. 로딩 화면 배경 [P01]
2. 추가 캐릭터 표정 [P02, P03]
3. 추가 배경 6종 [P05-P08]
4. 로고 파이널 [P09]
5. 엔딩 전용 일러스트 [P10, P11]

### Phase 3 — 컨텐츠 확장
1. 이벤트 20개 추가 (직장/관계 중심)
2. 뉴스 헤드라인 50개 추가
3. 로맨스 이벤트 체인
4. BGM 외부 음원 적용 (무료 라이선스)

---

## 10. 폴더 구조 (목표)

```
assets/
├── backgrounds/
│   ├── goshiwon_room.png         ✅
│   ├── oneroom_apartment.png     ✅
│   ├── gangnam_apartment.png     ✅
│   ├── seoul_rainy_street.png    ✅
│   ├── office_desk.png           ✅
│   ├── seoul_subway.png          ✅
│   ├── cafe_interior.png         ❌ GPT 생성 필요
│   ├── startup_office.png        ❌
│   ├── gangnam_street.png        ❌
│   ├── rooftop_night.png         ❌
│   ├── stock_market_screen.png   ❌
│   └── hospital.png              ❌
├── characters/
│   ├── main_character_neutral_goshiwon.png  ✅
│   ├── main_character_tired.png             ✅
│   ├── main_character_determined.png        ✅
│   ├── main_character_happy.png             ✅
│   ├── main_character_stressed.png          ❌ GPT 생성 필요
│   ├── main_character_rich.png              ❌
│   ├── rival_character.png                  ❌
│   ├── npc_boss.png                         ❌
│   └── npc_friend.png                       ❌
├── ui/
│   ├── loading_screen_bg.png     ❌
│   ├── logo_final.png            ❌
│   ├── ending_screen_bg.png      ❌
│   └── card_texture.png          ❌
├── keyart/
│   └── gangnam_dream_keyart_rooftop.png  ✅
├── logos/
│   └── gangnam_dream_logo_concept.png    ✅
└── audio/
    ├── bgm/                      ❌ 외부 음원 필요
    └── sfx/                      ❌ 외부 음원 필요
```

---

*총 필요 이미지: 15개 (GPT 생성) + 폰트 2종 + BGM 6트랙 + SFX 8종*

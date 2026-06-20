# 강남드림 — 오디오 에셋 가이드 (v4)

Updated: 2026-06-19 — Audio P1 ambience + ending stinger pass complete.

## 파일 구조

이 폴더(`assets/audio/`)에 아래 파일을 넣으면 게임이 자동으로 감지해서 사용합니다.  
파일이 없으면 **런타임 합성음(프로시저럴)**으로 자동 폴백되므로 없어도 게임은 동작합니다.

```
assets/audio/
├── BGM (상황별 자동 전환)
│   ├── bgm_menu.ogg        ← 시작 메뉴 (서울 네온 밤, 여정 시작 전)
│   ├── bgm_gosiwon.ogg     ← 고시원 생활 (새벽 형광등, 막막함)
│   ├── bgm_main.ogg        ← 원룸 생활 (로파이 서울 루프)
│   ├── bgm_apartment.ogg   ← 아파트/강남 생활 (올라가는 중, 자신감)
│   ├── bgm_crisis.ogg      ← 위기 BGM (건강/정신 30 이하)
│   ├── bgm_victory.ogg     ← 마일스톤 달성 BGM (8초, 자동 복귀)
│   └── bgm_ending.ogg      ← 엔딩 BGM
├── Ambience (BGM 아래 낮게 깔리는 장소 레이어)
│   ├── amb_goshiwon_room.wav      ← 고시원/원룸 방 공기, 형광등/도시 저음
│   ├── amb_seoul_rain.wav         ← 비 오는 서울 거리/강남 야경
│   ├── amb_hangang_riverside.wav  ← 한강 산책/바람/수면감
│   ├── amb_office_room.wav        ← 사무실/회사 장면
│   └── amb_casino_floor.wav       ← 정선 카지노 플로어 루프
└── SFX
    ├── sfx_click.wav       ← 버튼 클릭
    ├── sfx_close.wav       ← 모달 닫기
    ├── sfx_open_modal.wav  ← 모달 열기
    ├── sfx_tab_open.wav    ← 탭/미니게임 패널 열기
    ├── sfx_month.wav       ← 다음 달 전환
    ├── sfx_money_gain.wav  ← 수입/돈 획득
    ├── sfx_money_loss.wav  ← 손실/지출/매도
    ├── sfx_money_big.wav   ← 대형 수익/마일스톤
    ├── sfx_buy.wav         ← 매수/구매
    ├── sfx_sell.wav        ← 매도
    ├── sfx_stat_up.wav     ← 스탯 상승
    ├── sfx_stat_down.wav   ← 스탯 하락
    ├── sfx_event_new.wav   ← 이벤트 등장
    ├── sfx_choice_made.wav ← 선택지 결정
    ├── sfx_housing_up.wav  ← 이사
    ├── sfx_game_over.wav   ← 게임오버
    ├── sfx_success.wav     ← 성공/강남드림 달성
    ├── sfx_ending_stinger_good.wav   ← 일반 성공/긍정 엔딩
    ├── sfx_ending_stinger_bad.wav    ← 실패/파산/번아웃 엔딩
    └── sfx_ending_stinger_legend.wav ← S/S+/전설급 엔딩
```

## BGM 자동 전환 로직

```
시작 메뉴          → bgm_menu.ogg
게임 중 고시원     → bgm_gosiwon.ogg
게임 중 원룸       → bgm_main.ogg
게임 중 아파트/강남 → bgm_apartment.ogg
건강 또는 정신 ≤ 30 → bgm_crisis.ogg (주거 BGM 위에 덮임)
마일스톤 달성      → bgm_victory.ogg (8초 후 주거 BGM 복귀)
엔딩 화면          → bgm_ending.ogg
```

---

## BGM 생성 프롬프트 (Suno / Udio)

> **공통 주의사항**  
> - 모든 BGM: **no vocals, instrumental only**  
> - BGM Loop 설정: bgm_victory 제외 모두 Loop ON  
> - 파일 형식: `.ogg` (Suno에서 MP3로 받으면 ffmpeg으로 변환)

---

### 1. bgm_menu.ogg — 시작 메뉴

**분위기**: 서울 야경, 여정이 시작되기 직전의 설렘과 긴장감. 네온사인 빛이 창문에 반사되는 늦은 밤. "이제 시작이야."

```
lo-fi instrumental, Seoul night city atmosphere, distant traffic hum,
slow ethereal piano melody over sparse lo-fi beats, neon-lit anticipation,
dreamy and introspective mood, soft reverb on keys,
city ambience in background (rain optional), hopeful but nervous undertone,
Korean indie game title screen feeling, no vocals,
tempo around 70 BPM, seamless 2-minute loop
```

**Suno 태그 추천**: `#lofi #ambient #korean #cinematic #instrumental`

---

### 2. bgm_gosiwon.ogg — 고시원 생활

**분위기**: 새벽 2시 고시원 방. 형광등이 미묘하게 깜빡인다. 옆 방 소리가 벽을 타고 들린다. 막막하지만 포기하지 않는다. 이 게임에서 가장 어두운 일상 BGM.

```
ultra minimal lo-fi hip hop instrumental, single muted piano loop,
dusty vinyl crackle, soft kick drum barely present,
cramped and tired mood but with quiet resilience,
Seoul late night gosiwon (tiny single room) atmosphere,
fluorescent hum texture, distant city sounds, melancholy undertone,
sparse arrangement — mostly silence with occasional notes,
no vocals, 72 BPM, seamless 2-minute loop
```

**Suno 태그 추천**: `#lofi #melancholy #minimal #ambient #study`

---

### 3. bgm_main.ogg — 원룸 생활 (기본 메인)

**분위기**: 작지만 내 공간이 생겼다. 늦은 밤 서울 원룸, 노트북 화면 빛. 힘들지만 리듬이 있는 일상. 이 게임의 대표 BGM.

```
lo-fi hip hop instrumental, gentle piano melody, soft dusty drums,
warm bass groove, nostalgic and slightly melancholy mood,
Seoul late-night studio apartment atmosphere,
Korean indie game feeling, hopeful undertone beneath financial anxiety,
warm tape texture, subtle city ambience,
no vocals, 82 BPM, seamless 2-3 minute loop
```

**Suno 태그 추천**: `#lofi #hiphop #chillhop #korean #instrumental`

---

### 4. bgm_apartment.ogg — 아파트 생활 (상승 국면)

**분위기**: 아파트 창문 너머로 서울 야경이 펼쳐진다. 뭔가 되어가고 있다. 여전히 로파이지만, 더 밝고 자신감 있다. "나 이제 좀 올라왔다."

```
upbeat lo-fi hip hop instrumental, brighter piano chords,
confident warm groove, city success vibe,
Seoul apartment window with city lights mood,
uplifting but still chill, more prominent beat than usual lo-fi,
synth pads underneath piano, feeling of upward mobility and confidence,
Korean drama OST meets lo-fi, no vocals,
90 BPM, seamless 2-minute loop
```

**Suno 태그 추천**: `#lofi #upbeat #confident #korean #instrumental`

---

### 5. bgm_crisis.ogg — 위기 (건강/정신력 30 이하)

**분위기**: 몸도 정신도 한계. 번아웃. 서울 새벽 거리, 가로등만 켜진 골목. 구급차 소리가 멀리서 들린다. "더 이상 못 버티겠다."

```
tense dark ambient electronic instrumental, deep low bass drone,
irregular minimal percussion, sparse dissonant piano stabs,
urban burnout and exhaustion mood, Seoul 4am empty street atmosphere,
unsettling but not horror — psychological pressure, inner voice breaking,
distant siren texture optional, dark Korean city night,
no rhythm you can tap to — fractured and unstable,
no vocals, seamless 90-second loop
```

**Suno 태그 추천**: `#ambient #dark #tense #electronic #psychological`

---

### 6. bgm_victory.ogg — 마일스톤 달성 (단발 8초)

**분위기**: "해냈다!" 짧지만 진짜 느껴지는 한 순간. 과하지 않게, 로파이 감성으로. 8초 후 원래 BGM으로 자동 복귀.

```
short triumphant lo-fi instrumental burst, warm uplifting chord progression,
soft brass stab or synth fanfare, gentle piano resolution,
Korean indie game milestone feeling, small victory after long struggle,
NOT overly flashy — understated triumph, warm and genuine,
no vocals, exactly 8-10 seconds, NO loop (play once only)
```

**Suno 태그 추천**: `#lofi #victory #short #jingle #uplifting`

---

### 7. bgm_ending.ogg — 엔딩 / 결말 화면

**분위기**: 달렸던 모든 시간이 스쳐 지나간다. 성공이든 실패든, 그 여정은 진짜였다. 눈물이 날 수도 있는 BGM. 한국 드라마 OST × 로파이.

```
emotional orchestral lo-fi hybrid instrumental, bittersweet and reflective,
solo piano lead with soft string arrangement, gentle lo-fi beat underneath,
Korean drama OST influence — the feeling of a journey ending,
both triumph and loss at the same time, warm but sad,
remembering all the hard months, the choices made, the dreams chased,
gradually builds then softly resolves, cinematic but intimate,
no vocals, 2-3 minutes, seamless loop
```

**Suno 태그 추천**: `#emotional #orchestral #lofi #korean #cinematic #bittersweet`

---

## SFX 생성 — jsfxr.me 설정 가이드

[jsfxr.me](https://sfxr.me) 에서 생성 후 `.ogg`로 익스포트:

| 파일 | jsfxr 프리셋 | 조정 포인트 |
|------|-------------|------------|
| sfx_click.ogg | BLIP | Duration 0.04s, Freq high |
| sfx_money_gain.wav | COIN | 기본 그대로 |
| sfx_stat_up.ogg | POWERUP | Duration 0.15s |
| sfx_stat_down.ogg | HIT | Pitch 낮게, Duration 0.18s |
| sfx_money_big.wav | POWERUP | Duration 0.45s, multiple notes |
| sfx_housing.ogg | POWERUP | Bright, Duration 0.3s |
| sfx_game_over.wav | HIT | Very low pitch, Duration 0.6s |
| sfx_success.ogg | POWERUP | Long, triumphant, Duration 0.5s |

---

## Suno → 게임 파일 변환 방법

Suno에서 MP3/WAV로 다운로드 후:

```bash
# MP3 → OGG 변환 (ffmpeg 필요)
ffmpeg -i bgm_menu.mp3 -c:a libvorbis -q:a 5 bgm_menu.ogg

# 배치 변환 (downloads 폴더의 모든 mp3)
for f in ~/Downloads/bgm_*.mp3; do
  ffmpeg -i "$f" -c:a libvorbis -q:a 5 "${f%.mp3}.ogg"
done
```

**대상 폴더**: `/Users/junheelee/Documents/GitHub/GangnamDream/assets/audio/`

---

## Godot 임포트 설정 (중요)

BGM `.ogg` 파일은 Godot 에디터에서 임포트 후 아래 설정 확인:

| 파일 | Loop | 비고 |
|------|------|------|
| bgm_menu.ogg | ✅ ON | |
| bgm_gosiwon.ogg | ✅ ON | |
| bgm_main.ogg | ✅ ON | |
| bgm_apartment.ogg | ✅ ON | |
| bgm_crisis.ogg | ✅ ON | |
| bgm_victory.ogg | ❌ OFF | 코드에서 8초 후 자동 복귀 |
| bgm_ending.ogg | ✅ ON | |

SFX `.ogg`는 Loop 체크 해제.

현재 production SFX는 `.wav`이며 Loop 체크 해제 상태를 유지한다.

## 현재 production 생성 방식 (2026-06-19)

외부 음악 생성 서비스 없이 `tools/generate_audio_assets.py`로 deterministic local synthesis를 수행했다.

- BGM: `.ogg`, stereo 44100 Hz, Ogg Vorbis
- SFX: `.wav`, mono 44100 Hz
- Ambience/stinger P1: `tools/generate_audio_p1_assets.py`, `.wav`, mono 44100 Hz
- 검증: `res://tools/AudioAssetCheck.tscn`
- 상세 QA: `docs/AUDIO_QA.md`

---

## 파일이 없을 때 (프로시저럴 폴백)

`BGMPlayer.gd` — bgm 파일 없으면 Cm7→Ab→Eb→Bb 사인파 루프 재생  
`AudioManager.gd` — 각 SFX 파일 없으면 사인파 합성음 재생

→ **파일 없어도 게임 동작에 지장 없음**

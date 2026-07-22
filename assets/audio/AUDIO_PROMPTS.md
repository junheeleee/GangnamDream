# 강남드림 — 오디오 에셋 가이드 (v12)

Updated: 2026-07-22 — six-month demo dramaturgy, audible room tone, and story foley pass.

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
│   ├── bgm_ending.ogg      ← 엔딩 BGM
│   ├── bgm_family.ogg      ← 아버지·가족·빚의 기억 모티프
│   ├── bgm_survival.ogg    ← 구직·생계·첫 월급 모티프
│   ├── bgm_hyunsu.ogg      ← 현수와 고시원 동료애 모티프
│   ├── bgm_ambition.ogg    ← 강남·비교·상승 욕망 모티프
│   ├── bgm_daeun.ogg       ← 다은의 생활 온기 모티프
│   ├── bgm_jiyeon.ogg      ← 지연의 위험한 끌림 모티프
│   ├── bgm_theme_neutral.ogg ← 선택적 출시용 대표 테마 중립 변주
│   ├── bgm_theme_dark.ogg    ← 선택적 출시용 대표 테마 어둠 변주
│   └── bgm_theme_white.ogg   ← 선택적 출시용 대표 테마 밝음 변주
├── Ambience (BGM 아래 낮게 깔리는 장소 레이어)
│   ├── amb_goshiwon_room.wav      ← 고시원/원룸 방 공기, 형광등/도시 저음
│   ├── amb_family_home.wav         ← 창원 가족집, 냉장고·벽시계·희미한 TV 생활감
│   ├── amb_seoul_rain.wav         ← 비 오는 서울 거리/강남 야경
│   ├── amb_hangang_riverside.wav  ← 한강 산책/바람/수면감
│   ├── amb_office_room.wav        ← 사무실/회사 장면
│   ├── amb_casino_floor.wav       ← 정선 카지노 플로어 루프
│   ├── amb_subway_platform.wav    ← 지하철/출퇴근 플랫폼
│   ├── amb_racetrack_crowd.wav    ← 경마장 관중/트랙 공기
│   ├── amb_cafe_room.wav          ← 카페/커피 대화 공간
│   ├── amb_pc_bang.wav            ← PC방 팬/키보드/전자음
│   ├── amb_gym_room.wav           ← 헬스장/운동 장면
│   ├── amb_convenience_store.wav  ← 편의점 냉장고/야간 매장
│   ├── amb_hagwon_street.wav      ← 대치동 학원가/밤거리
│   ├── amb_school_hall.wav        ← 수능 시험장/학교 복도
│   ├── amb_public_office.wav      ← 주민센터/공공 민원 창구
│   ├── amb_jjimjilbang.wav        ← 찜질방/사우나 휴식 공간
│   ├── amb_cherry_blossom.wav     ← 벚꽃길/봄바람/꽃잎
│   ├── amb_saju_cafe.wav          ← 사주카페/촛불/작은 종
│   ├── amb_military_gate.wav      ← 예비군 훈련장 정문/젖은 아스팔트
│   ├── amb_seoul_street.wav       ← 일반 서울 거리/교통/횡단보도 공기
│   ├── amb_company_dinner.wav     ← 회식/삼겹살집/잔 부딪힘/그릴 소리
│   ├── amb_heatwave_city.wav      ← 폭염 도심/냉방기/건조한 도시 열기
│   ├── amb_fine_dust_city.wav     ← 미세먼지 도심/답답한 교통/탁한 공기
│   ├── amb_highway_traffic.wav    ← 명절 고속도로 정체/브레이크/차량 저음
│   ├── amb_open_chat_room.wav     ← 방 안 휴대폰 채팅/작은 진동/조용한 실내
│   └── amb_library_room.wav       ← 도서관/열람실/형광등/책장 넘김/낮은 키보드
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
    ├── sfx_door_latch.wav / sfx_paper_handle.wav / sfx_document_stamp.wav ← 프롤로그 물리 행동
    ├── sfx_phone_vibrate.wav / sfx_phone_notification.wav ← 전화·메시지
    ├── sfx_footsteps_hall.wav / sfx_keyboard_short.wav / sfx_register_scan.wav ← 구직·생계
    ├── sfx_cup_set.wav / sfx_kettle_pour.wav / sfx_bus_arrival.wav ← 대화·이동
    ├── sfx_bicycle_impact.wav / sfx_traffic_pass.wav / sfx_queue_chime.wav ← 사고·거리·민원실
    ├── sfx_choice_made.wav ← 선택지 결정
    ├── sfx_result_ledger.wav ← Black 결과에서 돈/성과에 먼저 닿는 마른 장부 접점음
    ├── sfx_result_human.wav  ← White 결과에서 사람/몸/마음에 먼저 닿는 천·호흡음
    ├── sfx_housing_up.wav  ← 이사
    ├── sfx_game_over.wav   ← 게임오버
    ├── sfx_success.wav     ← 성공/강남드림 달성
    ├── sfx_civil_defense_siren.wav ← 민방위 사이렌 이벤트 큐
    ├── sfx_monsoon_rain.wav ← 장마 이벤트 진입 빗소리 큐
    ├── sfx_ending_stinger_good.wav   ← 일반 성공/긍정 엔딩
    ├── sfx_ending_stinger_bad.wav    ← 실패/파산/번아웃 엔딩
    └── sfx_ending_stinger_legend.wav ← S/S+/전설급 엔딩
```

## 6개월 데모 드라마투르기

- `story_knee_door` → `story_knee_witness` → `story_knee_choice`는 `family_home`과 `family`를 공유한다. 링크 사이에 룸톤이나 음악을 다시 시작하지 않는다.
- 무릎 장면은 현관 래치와 서류 마찰만 물리적으로 강조한다. 울음, 충격음, 비극 스팅, 심박, 알아들을 수 있는 TV 대사는 금지한다.
- 가족·생존·현수·야망·다은·지연은 인물/주제 모티프다. 장소를 설명하는 앰비언스와 역할을 섞지 않는다.
- 의미 있는 물체가 실제로 움직이는 문단에만 폴리를 둔다. 모든 문단에 알림음을 붙이는 방식은 금지한다.
- 핵심 장소음 10종은 18초 이상, 사람 기척 9종은 16초 이상을 유지한다. 중립 상태에서는 들려야 하며 Black 경로에서 사람층만 단계적으로 멀어진다.
- 현재 파일은 타이밍과 소유권을 고정하는 프로젝트 원본이다. 출시 승인 전에는 헤드폰·노트북·TV에서 이미지와 함께 청취하고, 합성 질감이 드러나는 파일만 같은 semantic key 뒤에서 전문 폴리/작곡 마스터로 교체한다.

재생성:

```bash
python3 tools/generate_audio_p1_assets.py --demo-audio-only
```

## BGM 자동 전환 로직

```
시작 메뉴          → bgm_menu.ogg
게임 초반          → bgm_gosiwon.ogg
취업 후 1년 이상   → bgm_main.ogg
36세 이후          → bgm_apartment.ogg
건강 ≤35 또는 정신 ≤25 → bgm_crisis.ogg (최우선)
마일스톤 달성      → bgm_victory.ogg (8초 후 주거 BGM 복귀)
엔딩 화면          → bgm_ending.ogg
```

## MORAL_TINT 음악 전이

- 현재 런타임 폴백은 BGM 전용 버스에서만 작동한다. Gray/White는 전대역, Black 1단계는 4.8kHz, Black 2단계는 1.45kHz low-pass로 2.4초 동안 서서히 변한다.
- 앰비언스와 SFX는 필터 대상이 아니며, 밴드가 바뀌어도 현재 곡은 처음부터 재생되지 않는다.
- 결과 주의음은 보상/벌칙 징글이 아니다. Black의 `result_ledger`는 계산기·장부 접점처럼 건조하고, White의 `result_human`은 천과 숨이 움직이는 정도로만 들린다. Gray에는 별도 주의음을 넣지 않는다.
- 출시용 `bgm_theme_neutral/dark/white.ogg` 세 파일이 모두 존재하면 자동으로 3변주 팩을 사용한다. 한두 파일만 들어온 상태는 QA 실패다.

### 3변주 제작 게이트

- 세 곡은 같은 작곡, BPM, 마디 수, 전체 길이, 루프 지점과 첫 박자를 공유해야 한다. 서로 다른 신곡 3개가 아니다.
- 48kHz, stereo, OGG Vorbis, 약 -16 LUFS-I, true peak -1dB 이하, 최소 2분 seamless loop.
- `neutral`: 차가운 서울의 회색. 감정 결론을 내리지 않는 피아노/로파이 리듬.
- `dark`: 공포 음악 금지. 같은 멜로디의 음을 덜어내고, 불안정한 테이프 피치·마른 저역·끊긴 퍼커션으로 인간적인 온기만 사라지게 한다.
- `white`: 승리 팡파르 금지. 같은 멜로디에 호흡, 현의 배음, 맑은 공간감을 되돌려 세상이 선명해진 느낌을 만든다.
- 세 변주를 DAW 한 세션의 공통 stem에서 export해 크로스페이드 시 박자와 위상이 무너지지 않게 한다.

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
- Ambience/stinger P1: `tools/generate_audio_p1_assets.py`, `.wav`, stereo 22050 Hz
- 검증: `res://tools/AudioAssetCheck.tscn`
- 상세 QA: `docs/AUDIO_QA.md`

---

## 파일이 없을 때 (프로시저럴 폴백)

`BGMPlayer.gd` — bgm 파일 없으면 Cm7→Ab→Eb→Bb 사인파 루프 재생  
`AudioManager.gd` — 각 SFX 파일 없으면 사인파 합성음 재생

→ **파일 없어도 게임 동작에 지장 없음**

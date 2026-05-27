# 강남드림 — 오디오 에셋 가이드

## 파일 구조

이 폴더(`assets/audio/`)에 아래 파일을 넣으면 게임이 자동으로 감지해서 사용합니다.  
파일이 없으면 **런타임 합성음(프로시저럴)**으로 자동 폴백되므로 없어도 게임은 동작합니다.

```
assets/audio/
├── bgm_main.ogg        ← 메인 BGM (로파이 서울 루프)
├── bgm_crisis.ogg      ← 위기 BGM (건강/정신 30 이하)
├── bgm_victory.ogg     ← 마일스톤 달성 BGM (8초, 자동 복귀)
├── bgm_ending.ogg      ← 엔딩 BGM
├── sfx_click.ogg       ← 버튼 클릭
├── sfx_close.ogg       ← 모달 닫기
├── sfx_modal.ogg       ← 모달 열기
├── sfx_month.ogg       ← 다음 달 전환
├── sfx_coin.ogg        ← 수입/돈 획득
├── sfx_loss.ogg        ← 손실/매도
├── sfx_big_win.ogg     ← 대형 수익/마일스톤
├── sfx_stat_up.ogg     ← 스탯 상승
├── sfx_stat_down.ogg   ← 스탯 하락
├── sfx_event.ogg       ← 이벤트 등장
├── sfx_choice.ogg      ← 선택지 결정
├── sfx_housing.ogg     ← 이사
├── sfx_gameover.ogg    ← 게임오버
└── sfx_success.ogg     ← 성공/강남드림 달성
```

---

## BGM 생성 프롬프트 (Suno / Udio)

### bgm_main.ogg — 메인 루프
```
lo-fi hip hop instrumental, gentle piano melody, soft dusty drums,
nostalgic and slightly melancholy mood, Seoul late-night study room atmosphere,
Korean indie game feeling, hopeful undertone beneath financial anxiety,
warm tape texture, subtle city ambience, no vocals, seamless 2-3 minute loop
```

### bgm_crisis.ogg — 위기 테마 (건강/정신 위험)
```
tense ambient electronic instrumental, minimal drums, low bass hum,
occasional sparse piano notes, urban stress and pressure,
unsettling but not horror, dark Korean city night mood,
restrained tension, no vocals, seamless 90 second loop
```

### bgm_victory.ogg — 마일스톤 달성
```
uplifting lo-fi instrumental with understated triumph, soft piano,
warm synth pads, gentle beat, Korean indie pop influence,
hopeful but not flashy, feeling of reaching a small life milestone after hardship,
no vocals, 8-12 seconds or seamless short loop
```

### bgm_ending.ogg — 엔딩 테마
```
emotional orchestral lo-fi hybrid instrumental, bittersweet triumph,
piano lead with soft strings and gentle beat,
reflective Korean drama OST influence,
feeling of finally reaching a long-sought goal but remembering the cost,
no vocals, 2-3 minutes
```

---

## SFX 생성 및 추천 소스

### 생성 도구
- **Suno / Udio**: BGM에 최적
- **ElevenLabs Sound Effects**: 프롬프트로 단발 SFX 생성
- **jsfxr** (https://sfxr.me): 레트로/픽셀 SFX 무료 생성 (coin, stat up 등에 잘 맞음)
- **Freesound.org**: CC 라이선스 무료 SFX 다수

### 각 SFX 특성
| 파일 | 느낌 | 길이 |
|------|------|------|
| sfx_click.ogg | 짧고 깔끔한 UI 클릭 | ~0.05s |
| sfx_coin.ogg | 동전 획득 느낌 (jsfxr COIN 프리셋) | ~0.2s |
| sfx_big_win.ogg | 팡파르/짧은 상승 코드 | ~0.5s |
| sfx_stat_up.ogg | 레벨업 느낌 (jsfxr POWERUP) | ~0.15s |
| sfx_stat_down.ogg | 낮은 하강음 | ~0.2s |
| sfx_housing.ogg | 상쾌한 이사/업그레이드 음 | ~0.3s |
| sfx_gameover.ogg | 낮고 무거운 하강 | ~0.6s |
| sfx_success.ogg | 강남드림 달성 팡파르 | ~0.5s |

---

## Godot 임포트 설정 (중요)

BGM `.ogg` 파일은 Godot 에디터에서 임포트 후 아래 설정 확인:
- **Loop**: ✅ 체크
- **Loop Offset**: 0 (크로스페이드 없는 경우)

SFX `.ogg`는 Loop 체크 해제.

---

## 파일이 없을 때 (프로시저럴 폴백)

`BGMPlayer.gd` — `bgm_main.ogg` 없으면 Cm7→Ab→Eb→Bb 사인파 루프 재생  
`AudioManager.gd` — 각 SFX 파일 없으면 사인파 합성음 재생

→ **파일 없어도 게임 동작에 지장 없음**

# Image Generation Task — Gangnam Dream

## 개요

이 파일은 Codex(GPT-4o)에게 전달하는 이미지 생성 작업 지시서다.
아래 순서대로 파일을 읽고, 기존 이미지를 스타일 레퍼런스로 참조해서
새 이미지를 생성한 뒤 지정 경로에 저장한다.

---

## Step 1 — 컨텍스트 파일 읽기

작업 전 반드시 아래 두 파일을 읽어서 프로젝트 스타일과 금지사항을 파악한다:

- `assets/ASSET_INDEX.md` — 기존 에셋 목록, 스타일 가이드라인, 금지 사항
- `assets/IMAGE_PROMPTS.md` — 생성할 이미지 목록, 프롬프트, 저장 경로

---

## Step 2 — 기존 이미지 스타일 레퍼런스 확인

아래 기존 이미지들을 열어서 스타일, 팔레트, 분위기를 파악한다.
새 이미지는 이 시리즈와 **시각적으로 일관성**이 있어야 한다:

**배경 레퍼런스:**
- `assets/backgrounds/goshiwon_room.png` — 기존 배경 스타일 기준
- `assets/backgrounds/seoul_rainy_street.png` — 기본 이벤트 배경 분위기
- `assets/backgrounds/office_desk.png` — 야근·긴장감 배경 분위기

**캐릭터 레퍼런스:**
- `assets/characters/main_character_neutral_goshiwon.png` — 기본 초상화 스타일
- `assets/characters/main_character_tired.png` — 감정 표현 강도 기준
- `assets/characters/main_character_happy.png` — 캐릭터 디자인 일관성 기준

**키아트 레퍼런스:**
- `assets/keyart/gangnam_dream_keyart_rooftop.png` — 전체 게임 무드 기준

---

## Step 3 — 이미지 생성 및 저장

`assets/IMAGE_PROMPTS.md`에 정의된 각 이미지를 순서대로 생성한다.

각 이미지마다:
1. 해당 프롬프트 텍스트로 이미지 생성
2. 지정된 **저장 경로**에 파일 저장
3. 생성 완료 확인 후 다음으로 넘어감

생성 대상 목록 (총 9개):

| 파일명 | 저장 경로 | 해상도 |
|---|---|---|
| convenience_store_night.png | `assets/backgrounds/convenience_store_night.png` | 1280×800 |
| cafe_seoul.png | `assets/backgrounds/cafe_seoul.png` | 1280×800 |
| investment_phone.png | `assets/backgrounds/investment_phone.png` | 1280×800 |
| hospital_corridor.png | `assets/backgrounds/hospital_corridor.png` | 1280×800 |
| rooftop_daytime.png | `assets/backgrounds/rooftop_daytime.png` | 1280×800 |
| gangnam_night_street.png | `assets/backgrounds/gangnam_night_street.png` | 1280×800 |
| penthouse_view.png | `assets/backgrounds/penthouse_view.png` | 1280×800 |
| burnout_hospital_room.png | `assets/backgrounds/burnout_hospital_room.png` | 1280×800 |
| main_character_shocked.png | `assets/characters/main_character_shocked.png` | 400×600 |

아이콘은 별도 작업: `icon.png` (프로젝트 루트, 1024×1024)

---

## Step 4 — ASSET_INDEX.md 업데이트

모든 이미지 생성 완료 후 `assets/ASSET_INDEX.md`의 **Use These Assets** 섹션에
새로 생성된 이미지 항목을 추가한다. 형식은 기존 항목과 동일하게:

```
- `assets/backgrounds/convenience_store_night.png`
  - 자정 편의점 내부 배경.
  - Use for comedy, health, night 태그 이벤트.
```

---

## 참고 — Godot 연동 (이미지 생성 후 별도 작업)

이미지 생성 완료 후 `scenes/MainGame.gd`의 `_get_bg_for_event()` 함수에
아래 태그 매핑을 추가하면 인게임에서 자동으로 배경이 전환된다:

```gdscript
if "convenience" in tags or ("night" in tags and "food" in tags):
    return "res://assets/backgrounds/convenience_store_night.png"
if "social" in tags or "date" in tags or "cafe" in tags:
    return "res://assets/backgrounds/cafe_seoul.png"
if "investment" in tags or (category == "finance" and "stock" in tags):
    return "res://assets/backgrounds/investment_phone.png"
if "hospital" in tags or ("health" in tags and GameState.health < 40):
    return "res://assets/backgrounds/hospital_corridor.png"
```

그리고 `_get_portrait_path()` 함수에:

```gdscript
if GameState.flags.get("just_critical_event", false):
    return "res://assets/characters/main_character_shocked.png"
```

# 강남드림 커뮤니티 모딩 가이드

강남드림은 **데이터 기반 커뮤니티 번역**, **이미지·오디오 교체**, **커스텀 랜덤 이벤트**, **밸런스 프리셋**, **색 테마**를 지원한다. 게임 실행 파일이나 GDScript를 불러오는 방식은 제공하지 않는다. 스크립트 모딩은 지원하지 않습니다.

> Community translations and data-only mods supported.

## 원칙

- 모드는 게임 설치 폴더가 아니라 Godot 사용자 데이터 폴더의 `user://` 아래에 둔다.
- 번역팩은 표시 텍스트만 바꾼다. 조건, 수치, 효과, 배경, 후속 이벤트 등 게임플레이 데이터는 바꿀 수 없다.
- 에셋은 내장 파일과 **완전히 같은 상대경로**에 둔 파일만 교체한다.
- 새 이벤트가 만드는 상태 플래그는 반드시 `mod_`로 시작한다.
- 밸런스 프리셋은 존재하는 내장 ID의 값만 병합한다. 새 직업·자산·아이템을 추가하지 않는다.
- 색 테마는 어둡/회색/밝음 세 밴드의 구조를 유지하고 정해진 색값만 바꾼다.
- 파일이 없거나 읽을 수 없으면 게임은 내장 데이터와 에셋으로 자동 복귀한다.
- 감지된 모드가 있으면 타이틀에 작은 `MODDED` 표기가 나타나고, 세이브에도 `mod_active` 정보가 기록된다.
- 타이틀의 `설정 > 모드 관리`에서 개별 활성화와 로드 순서를 바꾼다. 변경은 다음 실행부터 적용된다.

## 사용자 데이터 폴더

Godot의 `user://` 실제 위치는 운영체제마다 다르다. 게임을 한 번 실행한 뒤 다음 폴더를 사용한다.

- Windows: `%APPDATA%/Godot/app_userdata/GangnamDream/`
- macOS: `~/Library/Application Support/Godot/app_userdata/GangnamDream/`
- Linux: `~/.local/share/godot/app_userdata/GangnamDream/`

## 커뮤니티 언어팩

언어팩 루트는 `user://lang/<code>/`다. 언어 코드는 영문·숫자·하이픈으로 된 2~24자 코드여야 한다. 예를 들어 일본어 팩 `ja`의 구조는 다음과 같다.

```text
user://lang/ja/
├── pack.json
├── ui_ja.json
├── endings_ja.json
└── events_ja/
    ├── main_events.json
    └── additional_events.json
```

`pack.json`은 선택 사항이다.

```json
{
  "name": "Japanese",
  "native_name": "日本語",
  "author": "Translator name",
  "version": "1.0.0"
}
```

### UI 번역

`ui_<code>.json`은 한국어 원문을 키로, 번역문을 값으로 갖는 문자열 객체다.

```json
{
  "새 게임": "New Game",
  "계속하기": "Continue"
}
```

### 이벤트 번역

`events_<code>/` 안의 각 JSON 파일은 이벤트 객체 배열이다. 내장 이벤트와 같은 `id`를 지정하고 필요한 텍스트만 쓴다. 선택지는 원본과 같은 순서로 작성한다.

```json
[
  {
    "id": "intro_001",
    "title": "Translated title",
    "description": "Translated body",
    "choices": [
      {
        "text": "First choice",
        "result_text": "First result"
      }
    ]
  }
]
```

허용되는 이벤트 필드는 `id`, `title`, `description`, `subtitle`, `description_orthodox`, `description_unorthodox`, `description_low_mental`, `description_long_gosiwon`, `description_long_apartment`, `description_if_known`, `description_memory_if_known`, `description_if_moral`, `choices`다.

선택지에는 `text`, `result_text`, `tooltip`, `text_if_moral`만 허용된다. `description_*`와 `text_if_moral`의 조건 키는 원본과 동일하게 유지한다.

### 엔딩 번역

`endings_<code>.json`은 엔딩 객체 배열이다. 내장 엔딩과 같은 `id`를 사용한다.

```json
[
  {
    "id": "ending_example",
    "title": "Translated ending",
    "description": "Translated ending text",
    "epilogue": "Translated epilogue"
  }
]
```

허용되는 필드는 `id`, `title`, `subtitle`, `description`, `detailed_description`, `epilogue`, `condition`, `description_if_known`다. 여기서 `condition`은 번역할 수 있는 표시 문자열일 뿐 실제 엔딩 조건을 바꾸지 않는다.

### DIK 패리티

번역은 원문의 데이터·조건·선택지 구조를 바꾸면 안 된다. 다음 규칙을 지킨다.

- 이벤트와 엔딩 `id`는 원본과 정확히 일치시킨다.
- 선택지 개수와 순서를 원본과 동일하게 유지한다.
- `{money}`, `{player_name}` 같은 자리표시자와 `[b]...[/b]` 같은 BBCode 태그를 빠뜨리지 않는다.
- `description_if_moral` 같은 조건부 문장의 딕셔너리 키를 원본과 동일하게 유지한다.
- `effects`, `conditions`, `follow_up_event`, `background` 등 게임플레이 키는 넣지 않는다. 로더가 무시하며 검증기는 오류로 판정한다.

팩을 배포하기 전에 다음 명령으로 검사한다.

```bash
python3 tools/mod_layer_audit.py --pack "/path/to/user/lang/ja"
```

## 데이터 모드

데이터 모드 루트는 `user://mods/`다.

```text
user://mods/
├── assets/       # 이미지·오디오 교체
├── events/       # 커스텀 랜덤 이벤트 팩
├── presets/      # 밸런스·시나리오 프리셋
└── themes/       # Moral UI 색 테마
```

로드 순서는 위에서 아래다. 같은 catalog 값을 여러 프리셋이 바꾸면 나중에 로드된 값이 남는다. 모드 파일은 JSON만 읽힌다. `.gd`, `.tscn`, `.pck`, 네이티브 라이브러리는 발견해도 로드하지 않는다.

### 커스텀 이벤트 팩

`user://mods/events/*.json`은 배열 또는 `events` 배열을 가진 팩 객체다.

```json
{
  "id": "night_shift_stories",
  "name": "Night Shift Stories",
  "version": "1.0",
  "events": [
    {
      "id": "mod_night_shift_regular",
      "title": "매일 오는 손님",
      "description": "오늘도 같은 시간에 문이 열렸다.",
      "category": "daily_life",
      "rarity": "common",
      "weight": 1.0,
      "hidden": false,
      "conditions": {"job": "job_01"},
      "tags": ["daily", "work"],
      "cooldown": 8,
      "choices": [
        {
          "text": "먼저 인사한다",
          "effects": {"mental": 1},
          "flags": ["mod_night_shift_greeted"],
          "result_text": "손님이 처음으로 이름을 말했다."
        }
      ]
    }
  ]
}
```

- 신규 ID는 비어 있지 않은 `title/description`, 양수 `weight`, `story`가 아닌 `category/rarity`, 하나 이상의 선택지를 갖춰야 한다. 로더가 이를 랜덤 풀로만 보내므로 정본 `_next_arc_id` 스케줄에 개입할 수 없다.
- 새로 쓰는 `flags`, `opportunity.win_flag/lose_flag`, `cast_effects.*.flags`는 모두 `mod_`로 시작한다.
- 후속 사건은 같은 파일의 이벤트 ID만 가리킨다. 다른 팩이나 내장 아크로 새는 우회를 막는다.
- 내장 ID와 충돌하면 내장 사건이 이긴다.

내장 사건을 개작하려면 `"override": true`를 명시한다. 원본과 선택지 수가 같아야 하며, 이벤트 조건·가중치·쿨다운·타이머와 선택지의 `follow_up_event/deferred_follow_up/deferred_delay`는 원본으로 고정된다. 대사·선택 문구·표현 에셋·효과는 개작할 수 있지만, 원본 후속을 여는 기존 플래그는 제거되지 않는다.

### 밸런스·시나리오 프리셋

`user://mods/presets/*.json`은 `jobs`, `assets`, `items`, `news_templates` 배열을 가진다. 각 행은 내장 `id`를 지정하고 바꿀 필드만 쓴다.

```json
{
  "id": "hard_times",
  "name": "Hard Times",
  "version": "1.0",
  "jobs": [
    {"id": "job_01", "base_salary": 1180000}
  ],
  "assets": [
    {"id": "bitcoin", "volatility": 0.42}
  ],
  "news_templates": [
    {"id": "news_001", "misleading_chance": 0.3}
  ]
}
```

알 수 없는 ID, 내장 행에 없는 필드, 기존 값과 자료형이 다른 값은 무시된다. 중첩 객체와 배열도 내장 스키마를 유지해야 한다. 이 계층은 데이터 밸런스를 바꾸지만, `finish_run`·아크 스케줄·저장 스키마는 바꾸지 못한다.

### Moral UI 색 테마

`user://mods/themes/*.json`은 `content/themes/moral_ui_default.json`과 같은 스키마를 쓴다. `main/story` 표면, `black/gray/white` 밴드, 고정된 색 키를 하나도 늘리거나 줄일 수 없다. 값은 `#RRGGBB` 또는 `#RRGGBBAA`다. 테마를 켜고 `설정 > 색각 접근성`에서 선택한다.

게임에는 다음 공식 테마가 포함된다.

- `default`: 기본 Gangnam Ink 팔레트
- `colorblind`: 파랑·황색 구분과 명도 차를 키운 색각 보정
- `high_contrast`: 텍스트·경계·포커스 명도 차를 최대화한 고대비

### 배포 전 검증

전체 모드 루트나 JSON 파일 하나를 검사할 수 있다.

```bash
python3 tools/mod_pack_validator.py "/path/to/user/mods"
python3 tools/mod_pack_validator.py "/path/to/user/mods/events/my_pack.json"
```

검증기는 JSON 스키마, 내장 ID 충돌, `override` 선택지 수, `mod_` 플래그, 후속 사건 범위, catalog ID, 테마 색 키, 실행 가능 파일 포함 여부를 검사한다.

## 이미지·오디오 교체

교체 루트는 `user://mods/assets/`다. 아래 예처럼 매니페스트에 적힌 상대경로를 그대로 재현한다.

```text
user://mods/assets/
├── characters/
│   └── minjun_neutral.png
├── backgrounds/
│   └── goshiwon_room.png
└── audio/
    ├── bgm/
    │   └── main_theme.ogg
    └── sfx/
        └── ui_confirm.wav
```

- 이미지 형식: PNG, JPG/JPEG, WebP, SVG
- 오디오 형식: WAV, OGG, MP3
- 파일명과 확장자를 포함한 상대경로가 내장 에셋과 정확히 같아야 한다.
- 권장 해상도는 아래 표의 원본 해상도와 같다. 다른 비율은 잘리거나 늘어날 수 있다.
- 오디오 루프 여부는 게임의 원래 사용 방식이 유지된다.
- 잘못된 파일은 무시되고 내장 에셋이 표시되거나 재생된다.
- `content/meta/cast_visual_years.json`은 1·3·5년 초상 선택을 결정하는 코어 계약이므로 데이터 모드로 바꿀 수 없다. 대신 아래 매니페스트의 y3/y5 초상 상대경로를 그대로 재현하면 해당 연차 원화만 안전하게 교체할 수 있다.

전체 오디오 경로와 기계 판독용 정보는 `assets/mod_asset_manifest.json`에 함께 생성된다. 레지스트리를 바꾼 개발자는 다음 명령으로 표와 JSON을 갱신한다.

```bash
python3 tools/generate_mod_manifest.py
python3 tools/generate_mod_manifest.py --check
```

## 시각 에셋 매니페스트

아래 구간은 도구가 자동 생성한다. 직접 편집하지 않는다.

<!-- BEGIN GENERATED ASSET MANIFEST -->
| Type | Runtime ID(s) | Relative path | Resolution |
|---|---|---|---:|
| background | `amusement_park_parade` | `backgrounds/amusement_park_parade_day.png` | 1280x800 |
| background | `amusement_photo_booth` | `backgrounds/amusement_photo_booth_evening.png` | 1280x800 |
| background | `amusement_roller_coaster` | `backgrounds/amusement_roller_coaster_day.png` | 1280x800 |
| background | `aruba_delivery` | `backgrounds/aruba_delivery_street.png` | 1280x800 |
| background | `burnout` | `backgrounds/burnout_hospital_room.png` | 1280x800 |
| background | `cafe` | `backgrounds/cafe_seoul.png` | 1280x800 |
| background | `casino` | `backgrounds/casino_interior.png` | 1280x800 |
| background | `changwon_hospital_room_empty` | `backgrounds/changwon_hospital_room_empty.png` | 1280x800 |
| background | `cherry_blossom_path` | `backgrounds/cherry_blossom_path.png` | 1672x941 |
| background | `chuseok_highway` | `backgrounds/chuseok_highway.png` | 1672x941 |
| background | `community_center` | `backgrounds/community_center.png` | 1672x941 |
| background | `company_dinner_restaurant` | `backgrounds/company_dinner_restaurant.png` | 1672x941 |
| background | `convenience_first_snow_exterior` | `backgrounds/convenience_store_exterior_first_snow.png` | 1280x800 |
| background | `convenience_night`, `convenience_store` | `backgrounds/convenience_store_night_v2.png` | 1280x800 |
| background | `daeun_mother_home_dining` | `backgrounds/daeun_mother_home_dining_summer.png` | 1280x800 |
| background | `daeun_newlywed_home` | `backgrounds/daeun_newlywed_home_night.png` | 1280x800 |
| background | `dad_house` | `backgrounds/family_living_room.png` | 1280x800 |
| background | `fine_dust_sky` | `backgrounds/fine_dust_sky.png` | 1672x941 |
| background | `gangnam_apartment` | `backgrounds/gangnam_apartment.png` | 1280x800 |
| background | `gangnam_day` | `backgrounds/gangnam_day.png` | 1280x800 |
| background | `gangnam_night` | `backgrounds/gangnam_night_street.png` | 1280x800 |
| background | `gangnam_station` | `backgrounds/gangnam_station_exit.png` | 1280x800 |
| background | `goshiwon_hallway` | `backgrounds/goshiwon_hallway.png` | 3840x2400 |
| background | `current_housing`, `goshiwon`, `goshiwon_room` | `backgrounds/goshiwon_room.png` | 1280x800 |
| background | `gukbap_restaurant_night` | `backgrounds/gukbap_restaurant_night.png` | 1280x800 |
| background | `exercise`, `gym` | `backgrounds/gym_interior.png` | 1280x800 |
| background | `hagwon_street` | `backgrounds/hagwon_street.png` | 1672x941 |
| background | `hangang_riverside` | `backgrounds/hangang_riverside_walk.png` | 1280x800 |
| background | `heatwave_city` | `backgrounds/heatwave_city.png` | 1672x941 |
| background | `holdem_club` | `backgrounds/holdem_club_interior.png` | 1280x800 |
| background | `hometown_train_station` | `backgrounds/hometown_train_station.png` | 1280x800 |
| background | `hospital_clinic` | `backgrounds/hospital_clinic.png` | 1280x800 |
| background | `hospital` | `backgrounds/hospital_corridor.png` | 1280x800 |
| background | `meeting` | `backgrounds/investment_meeting.png` | 1280x800 |
| background | `investment`, `investment_phone`, `trading` | `backgrounds/investment_phone.png` | 1280x800 |
| background | `jeongseon_casino_entrance` | `backgrounds/jeongseon_casino_entrance.png` | 1280x800 |
| background | `jeongseon_casino_exterior` | `backgrounds/jeongseon_casino_exterior.png` | 1280x800 |
| background | `jiyeon_newlywed_home` | `backgrounds/jiyeon_newlywed_home_night.png` | 1280x800 |
| background | `jiyeon_sedan_first_snow` | `backgrounds/jiyeon_sedan_first_snow_interior.png` | 1280x800 |
| background | `jiyeon_sedan_night` | `backgrounds/jiyeon_sedan_night_interior.png` | 1280x800 |
| background | `jjimjilbang` | `backgrounds/jjimjilbang.png` | 1672x941 |
| background | `late_night` | `backgrounds/late_night_room.png` | 1280x800 |
| background | `library` | `backgrounds/library.png` | 1280x800 |
| background | `military_base_gate` | `backgrounds/military_base_gate.png` | 1672x941 |
| background | `military` | `backgrounds/military_training_ground.png` | 1280x800 |
| background | `namsan_cable_car` | `backgrounds/namsan_cable_car_night.png` | 1280x800 |
| background | `namsan_observation_deck` | `backgrounds/namsan_observation_deck_night.png` | 1280x800 |
| background | `namsan_tonkatsu_restaurant` | `backgrounds/namsan_tonkatsu_restaurant_night.png` | 1280x800 |
| background | `namsan_tower` | `backgrounds/namsan_tower_view.png` | 1280x800 |
| background | `current_workplace`, `office` | `backgrounds/office_desk.png` | 1280x800 |
| background | `office_interview_day` | `backgrounds/office_interview_day.png` | 1280x800 |
| background | `apartment`, `apartment_balcony` | `backgrounds/oneroom_apartment.png` | 1280x800 |
| background | `open_chat_screen` | `backgrounds/open_chat_screen.png` | 1672x941 |
| background | `pc_bang` | `backgrounds/pc_bang_interior.png` | 1280x800 |
| background | `gangnam_penthouse`, `penthouse` | `backgrounds/penthouse_view.png` | 1280x800 |
| background | `pojangmacha` | `backgrounds/pojangmacha.png` | 1280x800 |
| background | `racetrack_betting` | `backgrounds/racetrack_betting_hall.png` | 1280x800 |
| background | `racetrack_track` | `backgrounds/racetrack_track_view.png` | 1280x800 |
| background | `realestate_office` | `backgrounds/realestate_office.png` | 1280x800 |
| background | `ktx_window`, `regional_train_window` | `backgrounds/regional_train_window_summer.png` | 1280x800 |
| background | `restaurant` | `backgrounds/restaurant_korean.png` | 1280x800 |
| background | `rooftop_day` | `backgrounds/rooftop_daytime.png` | 1280x800 |
| background | `rooftop_night` | `backgrounds/rooftop_night.png` | 1280x800 |
| background | `saju_cafe` | `backgrounds/saju_cafe.png` | 1672x941 |
| background | `sangchul_private_dining` | `backgrounds/sangchul_private_dining.png` | 1280x800 |
| background | `scalping_room` | `backgrounds/scalping_trading_room.png` | 1280x800 |
| background | `street_rainy_bus_stop_wallet` | `backgrounds/seoul_bus_stop_wallet.png` | 1280x800 |
| background | `seoul_bus_terminal_night` | `backgrounds/seoul_bus_terminal_night.png` | 1280x800 |
| background | `cold_snap_street` | `backgrounds/seoul_cold_snap_street.png` | 1280x800 |
| background | `street_rainy` | `backgrounds/seoul_rainy_street.png` | 1280x800 |
| background | `seoul_station_ktx_platform_winter` | `backgrounds/seoul_station_ktx_platform_winter.png` | 1280x800 |
| background | `subway` | `backgrounds/seoul_subway.png` | 1280x800 |
| background | `street`, `street_day` | `backgrounds/street_seoul_day.png` | 1280x800 |
| background | `suneung_test_hall` | `backgrounds/suneung_test_hall.png` | 1672x941 |
| background | `trading_room` | `backgrounds/trading_screen_night.png` | 1280x800 |
| background | `winter_street_bungeoppang` | `backgrounds/winter_bungeoppang_stall.png` | 1280x800 |
| background | `year2_winter_street_night` | `backgrounds/year2_winter_last_night.png` | 1280x800 |
| background | `year3_hangang_winter_night` | `backgrounds/year3_hangang_winter_night.png` | 1280x800 |
| background | `year4_winter_rooftop` | `backgrounds/year4_winter_rooftop.png` | 1280x800 |
| cg | `cg_demo_daeun_first_kindness` | `cg/demo/daeun_first_kindness_v2.png` | 1280x800 |
| cg | `cg_demo_father_first_call` | `cg/demo/father_first_call_v1.png` | 1280x800 |
| cg | `cg_demo_first_interview` | `cg/demo/first_interview_v1.png` | 1280x800 |
| cg | `cg_ending_balanced_life` | `cg/ending_balanced_life_v1.png` | 1280x800 |
| cg | `cg_ending_bankruptcy` | `cg/ending_bankruptcy_v2.png` | 1280x800 |
| cg | `cg_ending_burnout` | `cg/ending_burnout_v1.png` | 1280x800 |
| cg | `cg_ending_career_burnout` | `cg/ending_career_burnout_v1.png` | 1280x800 |
| cg | `cg_ending_career_climber` | `cg/ending_career_climber_v1.png` | 1280x800 |
| cg | `cg_ending_creator_success` | `cg/ending_creator_success_v1.png` | 1280x800 |
| cg | `cg_ending_crypto_ghost` | `cg/ending_crypto_ghost.png` | 1280x800 |
| cg | `cg_ending_debt_spiral` | `cg/ending_debt_spiral_v2.png` | 1280x800 |
| cg | `cg_ending_early_retirement` | `cg/ending_early_retirement_v1.png` | 1280x800 |
| cg | `cg_ending_empty_house` | `cg/ending_empty_house.png` | 1280x800 |
| cg | `cg_ending_father` | `cg/ending_father.png` | 1280x720 |
| cg | `cg_ending_full_circle` | `cg/ending_full_circle_v1.png` | 1280x800 |
| cg | `cg_ending_gambling_recovery` | `cg/ending_gambling_recovery_v2.png` | 1280x800 |
| cg | `cg_ending_gangnam_dream` | `cg/ending_gangnam_dream.png` | 1280x800 |
| cg | `cg_ending_gangnam_dream_white` | `cg/ending_gangnam_dream_white_v2.png` | 1280x800 |
| cg | `cg_ending_guardian` | `cg/ending_guardian_v1.png` | 1280x800 |
| cg | `cg_ending_healthy_retirement` | `cg/ending_healthy_retirement_v1.png` | 1280x800 |
| cg | `cg_ending_instant_legend` | `cg/ending_instant_legend_v1.png` | 1280x800 |
| cg | `cg_ending_investment_master` | `cg/ending_investment_master_v1.png` | 1280x800 |
| cg | `cg_ending_jaehyuk_way` | `cg/ending_jaehyuk_way_v1.png` | 1280x800 |
| cg | `cg_ending_jiyeon_man` | `cg/ending_jiyeon_man_v2.png` | 1280x800 |
| cg | `cg_ending_late_call` | `cg/ending_late_call_v1.png` | 1280x800 |
| cg | `cg_ending_lonely_rich` | `cg/ending_lonely_rich_v1.png` | 1280x800 |
| cg | `cg_ending_mental_break` | `cg/ending_mental_break_v1.png` | 1280x800 |
| cg | `cg_ending_ordinary_life` | `cg/ending_ordinary_life_v1.png` | 1280x800 |
| cg | `cg_ending_orthodox_hollow` | `cg/ending_orthodox_hollow_v2.png` | 1280x800 |
| cg | `cg_ending_orthodox_pinnacle` | `cg/ending_orthodox_pinnacle_v1.png` | 1280x800 |
| cg | `cg_ending_political_fix` | `cg/ending_political_fix_v1.png` | 1280x800 |
| cg | `cg_ending_reputation_legend` | `cg/ending_reputation_legend_v1.png` | 1280x800 |
| cg | `cg_ending_sangchul_reckoning` | `cg/ending_sangchul_reckoning_v1.png` | 1280x800 |
| cg | `cg_ending_second_love` | `cg/ending_second_love_v1.png` | 1280x800 |
| cg | `cg_ending_stable_success` | `cg/ending_stable_success_v1.png` | 1280x800 |
| cg | `cg_ending_startup_exit` | `cg/ending_startup_exit_v1.png` | 1280x800 |
| cg | `cg_ending_unorthodox_legend` | `cg/ending_unorthodox_legend_v1.png` | 1280x800 |
| cg | `cg_ending_with_daeun` | `cg/ending_with_daeun_v1.png` | 1280x800 |
| cg | `cg_ending_writer` | `cg/ending_writer_v1.png` | 1280x800 |
| cg | `cg_jaehyuk_reveal` | `cg/jaehyuk_reveal.png` | 1280x800 |
| cg | `cg_jiyeon_crash` | `cg/jiyeon_crash_day_v3.png` | 1280x800 |
| cg | `cg_romance_amusement_lost_child_daeun` | `cg/romance/amusement_lost_child_daeun_v1.png` | 1280x800 |
| cg | `cg_romance_amusement_photo_strip_jiyeon` | `cg/romance/amusement_photo_strip_jiyeon_v1.png` | 1280x800 |
| cg | `cg_romance_breakup_daeun` | `cg/romance/breakup_daeun_v1.png` | 1280x800 |
| cg | `cg_romance_breakup_jiyeon` | `cg/romance/breakup_jiyeon_v1.png` | 1280x800 |
| cg | `cg_romance_cherry_daeun` | `cg/romance/cherry_daeun.png` | 1280x800 |
| cg | `cg_romance_cherry_jiyeon` | `cg/romance/cherry_jiyeon.png` | 1280x800 |
| cg | `cg_romance_fireworks_daeun` | `cg/romance/fireworks_daeun.png` | 1280x800 |
| cg | `cg_romance_fireworks_jiyeon` | `cg/romance/fireworks_jiyeon.png` | 1280x800 |
| cg | `cg_romance_first_kiss_daeun` | `cg/romance/first_kiss_daeun.png` | 1280x800 |
| cg | `cg_romance_first_kiss_jiyeon` | `cg/romance/first_kiss_jiyeon.png` | 1280x800 |
| cg | `cg_romance_first_snow_daeun` | `cg/romance/first_snow_daeun_v1.png` | 1280x800 |
| cg | `cg_romance_first_snow_jiyeon` | `cg/romance/first_snow_jiyeon_v1.png` | 1280x800 |
| cg | `cg_romance_hometown_night_bus_daeun` | `cg/romance/hometown_night_bus_daeun_v1.png` | 1280x800 |
| cg | `cg_romance_namsan_lock_daeun` | `cg/romance/namsan_lock_daeun_v1.png` | 1280x800 |
| cg | `cg_romance_namsan_lock_jiyeon` | `cg/romance/namsan_lock_jiyeon_v1.png` | 1280x800 |
| cg | `cg_romance_narrow_room_jiyeon` | `cg/romance/narrow_room_jiyeon_v1.png` | 1280x800 |
| cg | `cg_romance_proposal_daeun` | `cg/romance/proposal_daeun_v1.png` | 1280x800 |
| cg | `cg_romance_sea_daeun` | `cg/romance/sea_daeun_v3.png` | 1280x800 |
| cg | `cg_romance_sea_jiyeon` | `cg/romance/sea_jiyeon_v2.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_father_reaction_hyunsu` | `cg/romance/wedding_daeun_father_reaction_hyunsu_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_father_reaction_passed_hyunsu` | `cg/romance/wedding_daeun_father_reaction_passed_hyunsu_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_father_reaction_passed` | `cg/romance/wedding_daeun_father_reaction_passed_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_father_reaction` | `cg/romance/wedding_daeun_father_reaction_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_full_close` | `cg/romance/wedding_daeun_full_close_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_full` | `cg/romance/wedding_daeun_full_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_mother_reaction` | `cg/romance/wedding_daeun_mother_reaction_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_small_close` | `cg/romance/wedding_daeun_small_close_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_daeun_small` | `cg/romance/wedding_daeun_small_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_gap_jiyeon` | `cg/romance/wedding_gap_jiyeon_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_morning_daeun` | `cg/romance/wedding_morning_daeun_v1.png` | 1280x800 |
| cg | `cg_romance_wedding_morning_jiyeon` | `cg/romance/wedding_morning_jiyeon_v1.png` | 1280x800 |
| cg | `cg_seollal_sebae_family` | `cg/seollal_sebae_family_v1.png` | 1280x800 |
| cg | `cg_start` | `cg/start.png` | 1280x720 |
| portrait | `player_cold_snap` | `characters/main_character_cold_snap.png` | 512x768 |
| portrait | `player_corporate`, `player_suit` | `characters/main_character_corporate.png` | 512x768 |
| portrait | `player_corporate_y3` | `characters/main_character_corporate_y3.png` | 1024x1536 |
| portrait | `player_corporate_y5` | `characters/main_character_corporate_y5.png` | 1024x1536 |
| portrait | `player_determined`, `player_moral_black` | `characters/main_character_determined.png` | 512x768 |
| portrait | `player_happy`, `player_moral_white` | `characters/main_character_happy.png` | 512x768 |
| portrait | `player_heatwave` | `characters/main_character_heatwave.png` | 512x768 |
| portrait | `player_monsoon` | `characters/main_character_monsoon.png` | 512x768 |
| portrait | `player_moral_gray`, `player_normal`, `player_offduty_neutral` | `characters/main_character_neutral_goshiwon.png` | 512x768 |
| portrait | `player_office` | `characters/main_character_office.png` | 512x768 |
| portrait | `player_office_y3` | `characters/main_character_office_y3.png` | 1024x1536 |
| portrait | `player_office_y5` | `characters/main_character_office_y5.png` | 1024x1536 |
| portrait | `player_part_time` | `characters/main_character_part_time.png` | 512x768 |
| portrait | `player_part_time_y3` | `characters/main_character_part_time_y3.png` | 1024x1536 |
| portrait | `player_part_time_y5` | `characters/main_character_part_time_y5.png` | 1024x1536 |
| portrait | `player_shocked` | `characters/main_character_shocked.png` | 512x768 |
| portrait | `player_hollow`, `player_sad`, `player_tired` | `characters/main_character_tired.png` | 512x768 |
| portrait | `player_romance_casual`, `player_unemployed` | `characters/main_character_unemployed.png` | 512x768 |
| portrait | `player_unemployed_y3` | `characters/main_character_unemployed_y3.png` | 1024x1536 |
| portrait | `player_unemployed_y5` | `characters/main_character_unemployed_y5.png` | 1024x1536 |
| portrait | `sangchul_normal` | `characters/npc_boss.png` | 512x768 |
| portrait | `cafe_broker_kim` | `characters/npc_cafe_broker_kim.png` | 512x768 |
| portrait | `cafe_investor` | `characters/npc_cafe_investor.png` | 512x768 |
| portrait | `hyunsu`, `hyunsu_normal` | `characters/npc_close_friend.png` | 512x768 |
| portrait | `daeun_amusement` | `characters/npc_daeun_amusement.png` | 512x768 |
| portrait | `daeun_cherry` | `characters/npc_daeun_cherry.png` | 512x768 |
| portrait | `daeun_fireworks` | `characters/npc_daeun_fireworks.png` | 512x768 |
| portrait | `daeun_first_snow` | `characters/npc_daeun_first_snow.png` | 512x768 |
| portrait | `daeun_hometown_warm` | `characters/npc_daeun_hometown_warm.png` | 512x768 |
| portrait | `daeun_hometown_worried` | `characters/npc_daeun_hometown_worried.png` | 512x768 |
| portrait | `daeun_namsan` | `characters/npc_daeun_namsan.png` | 512x768 |
| portrait | `daeun_normal_y3` | `characters/npc_daeun_normal_y3.png` | 1024x1536 |
| portrait | `daeun_normal_y5` | `characters/npc_daeun_normal_y5.png` | 1024x1536 |
| portrait | `daeun_proposal` | `characters/npc_daeun_proposal.png` | 512x768 |
| portrait | `daeun_sad` | `characters/npc_daeun_sad.png` | 512x768 |
| portrait | `daeun_sad_y3` | `characters/npc_daeun_sad_y3.png` | 1024x1536 |
| portrait | `daeun_sad_y5` | `characters/npc_daeun_sad_y5.png` | 1024x1536 |
| portrait | `daeun_sea` | `characters/npc_daeun_sea_v2.png` | 512x768 |
| portrait | `daeun_smile` | `characters/npc_daeun_smile.png` | 512x768 |
| portrait | `daeun_smile_y3` | `characters/npc_daeun_smile_y3.png` | 1024x1536 |
| portrait | `daeun_smile_y5` | `characters/npc_daeun_smile_y5.png` | 1024x1536 |
| portrait | `daeun_wedding_night` | `characters/npc_daeun_wedding_night.png` | 512x768 |
| portrait | `father_normal`, `father_proud` | `characters/npc_father.png` | 512x768 |
| portrait | `father_home` | `characters/npc_father_home.png` | 512x768 |
| portrait | `father_home_weak` | `characters/npc_father_home_weak.png` | 512x768 |
| portrait | `father_home_y3` | `characters/npc_father_home_y3.png` | 1024x1536 |
| portrait | `father_home_y5` | `characters/npc_father_home_y5.png` | 1024x1536 |
| portrait | `father_hospitalized` | `characters/npc_father_hospitalized.png` | 512x768 |
| portrait | `father_past` | `characters/npc_father_past.png` | 512x768 |
| portrait | `father_weak` | `characters/npc_father_weak.png` | 512x768 |
| portrait | `goshiwon_owner` | `characters/npc_goshiwon_owner.png` | 512x768 |
| portrait | `hyunsu_accounting` | `characters/npc_hyunsu_accounting.png` | 512x768 |
| portrait | `hyunsu_civil_service` | `characters/npc_hyunsu_civil_service.png` | 512x768 |
| portrait | `hyunsu_normal_y3` | `characters/npc_hyunsu_normal_y3.png` | 1024x1536 |
| portrait | `hyunsu_normal_y5` | `characters/npc_hyunsu_normal_y5.png` | 1024x1536 |
| portrait | `jaehyuk_charisma`, `jaehyuk_cornered`, `jaehyuk_friendly` | `characters/npc_jaehyuk.png` | 512x768 |
| portrait | `jaehyuk_normal_y3` | `characters/npc_jaehyuk_normal_y3.png` | 1024x1536 |
| portrait | `jaehyuk_normal_y5` | `characters/npc_jaehyuk_normal_y5.png` | 1024x1536 |
| portrait | `jaehyuk_shadow` | `characters/npc_jaehyuk_shadow.png` | 512x768 |
| portrait | `jaehyuk_shadow_y3` | `characters/npc_jaehyuk_shadow_y3.png` | 1024x1536 |
| portrait | `jaehyuk_shadow_y5` | `characters/npc_jaehyuk_shadow_y5.png` | 1024x1536 |
| portrait | `jiyeon_amusement` | `characters/npc_jiyeon_amusement.png` | 512x768 |
| portrait | `jiyeon_cherry` | `characters/npc_jiyeon_cherry.png` | 512x768 |
| portrait | `jiyeon_cold` | `characters/npc_jiyeon_cold.png` | 512x768 |
| portrait | `jiyeon_cold_y3` | `characters/npc_jiyeon_cold_y3.png` | 1024x1536 |
| portrait | `jiyeon_cold_y5` | `characters/npc_jiyeon_cold_y5.png` | 1024x1536 |
| portrait | `jiyeon_fireworks` | `characters/npc_jiyeon_fireworks.png` | 512x768 |
| portrait | `jiyeon_first_snow` | `characters/npc_jiyeon_first_snow.png` | 512x768 |
| portrait | `jiyeon_namsan` | `characters/npc_jiyeon_namsan.png` | 512x768 |
| portrait | `jiyeon_narrow_door` | `characters/npc_jiyeon_narrow_door.png` | 512x768 |
| portrait | `jiyeon_narrow_room` | `characters/npc_jiyeon_narrow_room.png` | 512x768 |
| portrait | `jiyeon_normal_y3` | `characters/npc_jiyeon_normal_y3.png` | 1024x1536 |
| portrait | `jiyeon_normal_y5` | `characters/npc_jiyeon_normal_y5.png` | 1024x1536 |
| portrait | `jiyeon_sea` | `characters/npc_jiyeon_sea_v2.png` | 512x768 |
| portrait | `jiyeon_warm` | `characters/npc_jiyeon_warm.png` | 512x768 |
| portrait | `jiyeon_warm_y3` | `characters/npc_jiyeon_warm_y3.png` | 1024x1536 |
| portrait | `jiyeon_warm_y5` | `characters/npc_jiyeon_warm_y5.png` | 1024x1536 |
| portrait | `jiyeon_wedding_night` | `characters/npc_jiyeon_wedding_night.png` | 512x768 |
| portrait | `jiyeon_normal` | `characters/npc_mentor.png` | 512x768 |
| portrait | `minseo`, `minseo_normal` | `characters/npc_minseo.png` | 512x768 |
| portrait | `mother` | `characters/npc_mother.png` | 512x768 |
| portrait | `daeun_normal` | `characters/npc_romantic_interest.png` | 512x768 |
| portrait | `sangchul_normal_y3` | `characters/npc_sangchul_normal_y3.png` | 1024x1536 |
| portrait | `sangchul_normal_y5` | `characters/npc_sangchul_normal_y5.png` | 1024x1536 |
| portrait | `sangchul_serious` | `characters/npc_sangchul_serious.png` | 512x768 |
| portrait | `sangchul_serious_y3` | `characters/npc_sangchul_serious_y3.png` | 1024x1536 |
| portrait | `sangchul_serious_y5` | `characters/npc_sangchul_serious_y5.png` | 1024x1536 |
| portrait | `seongjun` | `characters/npc_seongjun.png` | 512x768 |
| portrait | `boss` | `characters/npc_team_lead.png` | 512x768 |
| portrait | `tip_seller` | `characters/npc_tip_seller.png` | 512x768 |
<!-- END GENERATED ASSET MANIFEST -->

## 지원 범위

이 기능은 커뮤니티 번역과 개인용 에셋 교체를 기술적으로 지원한다. 특정 모드의 품질·호환성·업데이트 지속성을 보증하지 않으며, 모드 사용 중 발생한 문제를 신고할 때는 타이틀과 세이브의 `MODDED` 정보를 함께 알려야 한다.

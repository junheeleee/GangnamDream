# Codex Image Generation Task — 강남드림 (Gangnam Dream) — ARCHIVED

## 이 파일의 용도
이 파일은 과거 이미지 생성 요청서 보존본입니다. 현재 production 작업에는 실행하지 마세요.

현재 에셋 작업은 `assets/VISUAL_AUDIO_UPGRADE_BRIEF.md`, `docs/CANON_MAP.md`, `docs/ASSET_CONTINUITY_CHECKLIST.md`, `docs/ASSET_QA.md`를 먼저 확인합니다. 이 파일의 구 요청에는 `investment_monitor`, 구 로맨스 인물, 구 배경 매핑 등 현재 정본과 충돌할 수 있는 내용이 남아 있었습니다.

---

## Step 0 — 먼저 읽어야 할 파일들

```
assets/ASSET_INDEX.md                         ← 스타일 가이드 (필독)
assets/backgrounds/goshiwon_room.png          ← 배경 톤/무드 레퍼런스
assets/backgrounds/office_desk.png            ← 배경 스타일 레퍼런스
assets/characters/main_character_neutral_goshiwon.png  ← 캐릭터 스타일 레퍼런스
assets/characters/main_character_tired.png    ← 캐릭터 표정 레퍼런스
scenes/MainGame.gd                            ← 이미지가 연결되는 코드 (lines 34-46, 2466-2496)
```

---

## Step 1 — 스타일 원칙 (ASSET_INDEX.md 요약)

- **장르**: 한국 웹툰 + 로파이 리얼리즘. 서울 2026년 청년 생존기
- **팔레트**: 차콜, 먹빛 네이비, 따뜻한 골드, 차가운 블루 포인트. 전체적으로 어둡고 절제됨
- **금지**: 공상과학 UI, 빛나는 링, 추상 노드, 오브 모양, 마법 효과
- **허용**: 고시원, 원룸, 서울 골목길, 편의점, 사무실, 지하철, 병원, 카페, 기차역
- **배경 해상도**: 기존 파일 기준 ~1920×1080 또는 동등 품질 PNG
- **캐릭터 해상도**: 기존 portrait ~512×768 세로형 PNG

---

## Step 2 — 생성할 이미지 7개

### 배경 5개

---

#### 1. `assets/backgrounds/hospital_clinic.png`

**사용처**: 건강검진 이벤트, 번아웃 상담, 부모님 건강 이벤트, 정신건강 이벤트
(life_events.json: `health_checkup_results`, `mental_health_realization`, `burnout_age_29`, `parent_health_concern`)

**이미지 설명**:
한국 동네 내과 또는 대학병원 외래 대기실. 
형광등 빛이 차갑게 내리쬐는 흰 복도 또는 대기 의자 줄.
벽에는 건강 관련 포스터, 번호표 기계.
늦은 오후 또는 저녁 시간대. 환자 몇 명이 마스크를 쓰고 앉아 있음.
분위기: 조용하고 무겁고 약간 불안함. 생의 취약함이 느껴지는 공간.
팔레트: 차가운 흰색, 연한 민트, 형광 노랑, 그림자가 짙음.

---

#### 2. `assets/backgrounds/investment_phone.png`

**사용처**: 초반/일반 투자 이벤트, 주식 관련 선택지
(investment_events.json 전체, `invest_big_win_first`, `invest_daytrade_catastrophe`, `drama_crypto_allin`)

**이미지 설명**:
고시원 또는 원룸의 작은 책상 위 스마트폰/작은 노트북에 주식 차트가 떠 있음.
초반 김민준의 현실적인 개인투자 스케일. 멀티모니터 금지, 전문 트레이딩룸 금지.
옆에는 편의점 커피, 낡은 노트, 충전 케이블, 월세 고지서.
폰/노트북 빛만이 어두운 방을 밝히는 새벽 3-4시 느낌.
분위기: 긴장, 도박과 이성 사이, 고독한 집중.
팔레트: 딥 블랙, 차가운 화면빛, 낮은 생활감.

---

#### 3. `assets/backgrounds/cafe_meetup.png`

**사용처**: 소개팅, 친구 만남, 사회 이벤트, 인맥 관리
(life_events.json: `romance_sumin_meet`, `marriage_pressure_28`, `old_friend_diverging`, `peer_comparison_anxiety`)

**이미지 설명**:
서울 홍대 또는 연남동 스타일 작은 카페 내부.
나무 테이블, 핸드드립 커피, 흐릿한 창밖으로 서울 골목.
낮이지만 따뜻한 조명으로 아늑함. 손님 2-3명이 흐릿하게 보임.
분위기: 평범한 일상이지만 약간의 긴장과 설렘이 공존.
팔레트: 따뜻한 나무색, 아이보리, 연한 골드 조명, 창밖 차가운 블루.

---

#### 4. `assets/backgrounds/late_night_room.png`

**상태**: REGENERATED 2026-06-12. `goshiwon_room.png` 기반 4am 색보정 변형이며 runtime에 연결되어 있다.
**사용처**: 번아웃, 야근 후 귀가, 정신력 위기, 고독한 밤
(life_events.json: `mental_health_realization`, `burnout_age_29`, story_events.json: `story_late_night_grind`, `story_rainy_night`)

**이미지 설명**:
정본 고시원 방의 4am 야간 변형. 큰 창문/도시 전망/다른 침대·책상 배치 금지.
책상 위 노트북 화면만 켜져 있고, 방은 어두움.
침대 위 쌓인 옷가지, 빈 라면 컵, 핸드폰 충전기.
커튼 사이로 서울 야경이 희미하게 보임.
분위기: 외로움, 탈진, '이게 맞나'라는 자기 의심.
팔레트: 딥 차콜, 노트북 차가운 블루 빛, 희미한 도시 오렌지 빛.

---

#### 5. `assets/backgrounds/hometown_train_station.png`

**사용처**: 고향 방문, 부모님 관련 이벤트, 명절, 귀성
(life_events.json: `parent_health_concern`, story_events.json: `story_hometown_nostalgia`)

**이미지 설명**:
지방 소도시 기차역 플랫폼 또는 역사 대합실.
무궁화호 또는 KTX가 서 있거나 떠난 후의 빈 플랫폼.
낡은 역 시계, 나이 든 승객들, 플라스틱 의자.
늦가을 또는 겨울 느낌. 흐린 하늘.
분위기: 그리움, 거리감, 서울로 돌아가야 한다는 복잡한 감정.
팔레트: 회색, 낡은 흰색, 차가운 하늘색, 형광등 노랑.

---

### 캐릭터 초상화 2개

---

#### 6. `assets/characters/main_character_30s.png`

**사용처**: turn 120+ (30대 이후) 안정적이거나 성장한 상태
(`_get_portrait_path()`에서 나이 30+이고 스트레스 보통일 때)

**이미지 설명**:
기존 `main_character_determined.png` 와 동일 인물, 동일 화풍.
나이가 30대 초중반으로 보임. 약간 더 성숙한 얼굴, 짧아진 헤어.
직장인 느낌의 깔끔한 캐주얼 셔츠 또는 슬랙스.
표정: 지쳤지만 포기하지 않은 30대의 결의. 20대처럼 날카롭지 않고 묵직함.
배경: 사무실 창가 또는 원룸 창가, 서울 야경 흐릿하게.
팔레트: 기존 캐릭터 시리즈와 동일한 어두운 톤 + 따뜻한 피부색.

**중요**: 기존 `main_character_neutral_goshiwon.png`를 레퍼런스로 삼아 동일 인물임이 느껴지게.

---

#### 7. `assets/characters/main_character_50s.png`

**사용처**: turn 360+ (50대 이후) 은퇴 앞둔 상태
(`_get_portrait_path()`에서 나이 50+일 때)

**이미지 설명**:
기존 캐릭터 시리즈와 동일 인물, 동일 화풍.
50대 초반. 세월의 흔적이 있는 얼굴, 약간의 흰머리.
정장 재킷 또는 단정한 셔츠. 안경 선택적.
표정: 많은 것을 겪고 살아남은 사람의 차분함. 슬프지도 행복하지도 않은 복잡한 담담함.
배경: 회사 복도 또는 창가. 황혼 빛.
팔레트: 기존 시리즈 동일 톤.

**중요**: 6번과 동일 인물의 20년 후 모습으로 느껴져야 함.

---

## Step 3 — 파일 저장 경로

```
assets/backgrounds/hospital_clinic.png
assets/backgrounds/investment_phone.png
assets/backgrounds/cafe_meetup.png
assets/backgrounds/late_night_room.png
assets/backgrounds/hometown_train_station.png
assets/characters/main_character_30s.png
assets/characters/main_character_50s.png
```

---

## Step 4 — MainGame.gd 코드 반영

이미지 생성 후 `scenes/MainGame.gd` 를 다음과 같이 수정하세요.

### 4-A. 상수 추가 (기존 라인 39-46 근처에 추가)

```gdscript
# 기존 코드 아래에 추가
const BG_HOSPITAL   = "res://assets/backgrounds/hospital_clinic.png"
const BG_INVESTMENT = "res://assets/backgrounds/investment_phone.png"
const BG_CAFE       = "res://assets/backgrounds/cafe_meetup.png"
const BG_NIGHT_ROOM = "res://assets/backgrounds/late_night_room.png"  # canonical 4am variant of goshiwon_room
const BG_HOMETOWN   = "res://assets/backgrounds/hometown_train_station.png"

const PORTRAIT_30S = "res://assets/characters/main_character_30s.png"
const PORTRAIT_50S = "res://assets/characters/main_character_50s.png"
```

### 4-B. `_get_bg_for_event()` 수정 (기존 함수 교체)

```gdscript
func _get_bg_for_event(ev: Dictionary) -> String:
    var tags = ev.get("tags", [])
    var category = str(ev.get("category", ""))

    # 병원/건강
    if "health" in tags or category == "health":
        return BG_HOSPITAL
    # 투자/주식/도박
    if "investment" in tags or "gambling" in tags or category in ["investment", "gambling"]:
        return BG_INVESTMENT
    # 카페/로맨스/소셜 만남
    if "romance" in tags or ("social" in tags and not "commute" in tags):
        return BG_CAFE
    # 야간/번아웃/정신
    if "night" in tags or "mental" in tags or "anxiety" in tags:
        return BG_NIGHT_ROOM
    # 가족/고향
    if "family" in tags or "hometown" in tags:
        return BG_HOMETOWN
    # 직장/사무실
    if "jobs" in tags or "work" in tags or "office" in tags or category == "jobs":
        return BG_OFFICE
    # 출퇴근/지하철
    if "commute" in tags or "subway" in tags:
        return BG_SUBWAY
    # 이벤트 없을 때 — 주거 기반
    return BG_PATHS.get(GameState.housing, BG_DEFAULT)
```

### 4-C. `_get_portrait_path()` 수정 (기존 함수 교체)

```gdscript
func _get_portrait_path() -> String:
    # 자산 마일스톤 달성 직후 — 기쁨
    if GameState.flags.get("just_hit_milestone", false):
        return PORTRAIT_HAPPY
    # 스트레스 높거나 건강/정신 위험 — 피로
    if GameState.stress >= 65 or GameState.health <= 35 or GameState.mental <= 35:
        return PORTRAIT_TIRED
    # 50대 이상
    if GameState.age >= 50:
        return PORTRAIT_50S
    # 30대 이상, 안정적
    if GameState.age >= 30 and GameState.stress < 55:
        return PORTRAIT_30S
    # 직장 있고 안정적 — 결의
    if not GameState.current_job.is_empty() and GameState.stress < 45 and GameState.health >= 60:
        return PORTRAIT_DETERMINED
    return PORTRAIT_NEUTRAL
```

---

## Step 5 — 검증

모든 작업 완료 후:

```bash
# 파일 존재 확인
ls assets/backgrounds/hospital_clinic.png
ls assets/backgrounds/investment_phone.png
ls assets/backgrounds/cafe_meetup.png
ls assets/backgrounds/late_night_room.png
ls assets/backgrounds/hometown_train_station.png
ls assets/characters/main_character_30s.png
ls assets/characters/main_character_50s.png

# assets/ASSET_INDEX.md 에 새 항목 추가 (기존 형식 유지)
```

---

## 참고: 이벤트-배경 매핑 요약

| 배경 | 주요 이벤트 태그 | 예시 이벤트 ID |
|---|---|---|
| hospital_clinic | health, anxiety | health_checkup_results, burnout_age_29, mental_health_realization |
| investment_phone | investment, gambling | invest_big_win_first, invest_daytrade_catastrophe, drama_crypto_allin |
| cafe_meetup | romance, social | romance_sumin_meet, marriage_pressure_28, peer_comparison_anxiety |
| late_night_room | night, mental, anxiety | story_late_night_grind, story_rainy_night, mental_health_realization |
| hometown_train_station | family, hometown | parent_health_concern, story_hometown_nostalgia |

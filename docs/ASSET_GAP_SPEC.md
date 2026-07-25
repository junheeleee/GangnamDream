# 강남드림 — AI 에셋 생성 명세서
> AI 아트/음악 생성 의뢰 시 사용. 우선순위 순서대로 생성 권장.

---

## 스타일 가이드 (모든 에셋 공통)

| 항목 | 명세 |
|---|---|
| **아트 스타일** | `Gangnam Ink`: 저채도 한국 비주얼노벨/만화 리얼리즘, 콘크리트 회색과 차콜 UI에 잘 붙는 matte paper grain |
| **캐릭터 톤** | 사실적이되 약간 스타일화. 사진사실주의 raw AI 느낌 금지, 배경 없는 투명 포트레이트 우선 |
| **배경 팔레트** | 회색/진회색/검정/연회색/흰색 moral axis. 골드·초록·파랑은 카지노/시장 등 좁은 의미 신호로만 사용 |
| **해상도** | 포트레잇 512×512 이상 / 배경 1920×1080 / CG 1920×1080 |
| **파일 형식** | PNG (투명 배경은 포트레잇만) |
| **네이밍** | `{캐릭터}_{감정}.png` / `{장소}_{시간}.png` |

---

## PHASE 1 — 핵심 (릴리즈 블로커)

### 1-A. 포트레잇 감정 변형

> **현재 문제:** 대부분의 캐릭터가 모든 감정 변형을 **동일한 이미지 파일 1개**로 공유 중.
> 실제 게임에서 `daeun_sad`와 `daeun_smile`이 같은 그림으로 나옴.

#### 김다은 (연인, 33세 여성)
| ID | 표정 | 사용 장면 |
|---|---|---|
| `daeun_smile` | 환하게 웃는 | 편의점 만남, 데이트 성공 |
| `daeun_normal` | 자연스러운 일상 | 일반 대화 |
| `daeun_sad` | 슬프거나 눈물 | 이별 장면, 갈림길 |
| `daeun_determined` ⭐새로 필요 | 단호하고 강한 눈빛 | 다은이 먼저 선택하는 장면 |

**캐릭터 설명:** 편의점 야간 아르바이트생. 수수하지만 따뜻한 인상. 화장기 없음. 편의점 앞치마 착용 가능.

#### 한지연 (위험한 히로인/로맨스, 31세 여성)
| ID | 표정 | 사용 장면 |
|---|---|---|
| `jiyeon_normal` | 세련되고 차분한 | 처음 만남, 일반 대화 |
| `jiyeon_warm` | 부드럽고 진심 어린 미소 | 신뢰 쌓인 후 대화 |
| `jiyeon_cold` | 차갑고 거리감 있는 | 갈등 장면 |
| `jiyeon_surprised` ⭐새로 필요 | 놀란 표정 | 민준이 예상 밖 선택할 때 |

**캐릭터 설명:** 강남 재벌가 딸이자 투자 세계의 문턱. 단순 멘토가 아니라 빠른 상승의 유혹과 로맨스를 동시에 가진 위험한 히로인. 긴 검은 머리, 날카로운 눈, 크림/블랙 테일러드 수트. 예쁘고 고혹적이지만 계산적인 긴장감이 있어야 한다. 배경 없는 투명 포트레이트로 제작.

#### 강현수 (고시원 옆방 공시생 후배, 26-27세 남성)
| ID | 표정 | 사용 장면 |
|---|---|---|
| `hyunsu` / `hyunsu_normal` | 피곤하지만 선한 눈빛 | 현재 모든 장면 (동일 이미지) |
| `hyunsu_happy` ⭐새로 필요 | 환하게 웃는 | 합격/좋은 소식 |
| `hyunsu_worried` ⭐새로 필요 | 걱정스럽게 보는 | 재혁 경고 장면 |

**캐릭터 설명:** 고시원 옆방 청년. 공무원 시험 4년차. 민준을 형이라 부르는 통통한 후배. 둥근 안경, 부스스한 검은 머리, 올리브색 후드와 버건디 줄무늬 티셔츠. 피곤하지만 선하고 정 붙는 인상이어야 하며, 중년/아저씨 느낌이나 개그성 비호감 체형으로 가면 안 된다.

#### 주인공 (김민준, 33세)
| ID | 표정 | 사용 장면 |
|---|---|---|
| `player_normal` | 무표정/평상시 | 현재 OK — `ImageRegistry`가 직업/주거 상태에 따라 무직·알바·사무직·정장 의상을 동적 선택 |
| `player_tired` | 지침 | 현재 OK |
| `player_determined` | 결의에 찬 | 현재 OK — 평상시 결의 표시는 직업별 의상 우선, 위기 감정은 별도 표정 우선 |
| `player_happy` | 기쁨 | 현재 OK |
| `player_shocked` | 충격/놀람 | 현재 OK |
| `player_suit` | 양복 입은 직장인 | 현재 OK — 배경 없는 `main_character_corporate.png` 사용, 레거시 `main_character_30s.png` 금지 |
| `player_hollow` | 공허한 눈빛 (50대풍) | 현재 OK |
| `player_outfit_variants` | 무직/알바/사무직/대기업 정장 | 생성 완료 — `main_character_unemployed`, `main_character_part_time`, `main_character_office`, `main_character_corporate` |

#### 상사/팀장 (boss)
| ID | 표정 | 사용 장면 |
|---|---|---|
| `boss` | 무표정 평가하는 눈빛 | 현재 OK — `npc_team_lead.png` 투명 포트레이트 |
| `boss_angry` ⭐새로 필요 | 화난/질책 | 직장 갈등 이벤트 |
| `boss_pleased` ⭐새로 필요 | 만족스러운 | 승진 이벤트 |

---

### 1-B. 배경 (핵심 누락 장소)

> **현재:** 이벤트에서 직접 참조하지만 ImageRegistry에 없는 배경들.
> 없으면 `goshiwon_room.png` 폴백으로 대체됨.

| ID | 장소 | 분위기/시간대 | 사용 이벤트 수 |
|---|---|---|---|
| `back_alley_night` ⭐ | 서울 골목길 (밤) | 어둡고 음산한 뒷골목 | 불법 대포통장/지하 거래 이벤트 |
| `luxury_restaurant` ⭐ | 고급 레스토랑 (저녁) | 강남 프라이빗 다이닝룸, 어두운 조명 | 상철 네트워크 모임, 지연 저녁 |
| `park_bench_day` | 공원 벤치 (낮) | 서울 도심 공원, 평범한 날 | 야외 데이트, 혼자 생각하는 장면 |
| `police_station` | 경찰서 내부 | 차갑고 형광등 빛, 조서 작성 책상 | 재혁 신고 장면 |
| `gym_interior` | 헬스장 내부 | 운동기구, 땀 냄새 나는 분위기 | 건강 이벤트 |
| `bar_interior` | 일반 술집 (밤) | 편한 분위기, 병맥주, 나무 테이블 | 음주 사교 이벤트 |

---

### 1-C. CG (풀스크린 클라이맥스 일러스트)

> 상세 엔딩 기준은 `docs/ENDING_ART.md`가 정본이다.
> CG는 주연 인물과 배경을 합성해도 되는 예외 영역이지만, 그래서 더 엄격하게 정합성을 본다.

현재 보유:

| CG ID | 상태 | 구도/내용 |
|---|---|---|
| `cg_start` | ✅ 있음 | 오프닝 고시원. 큰 창문/전망 금지 |
| `cg_jiyeon_crash` | ✅ 있음 | 자전거 접촉 사고. 지연 얼굴/차량/운전석 정합성 유지 |
| `cg_jaehyuk_reveal` | ✅ 있음 | 호텔 라운지 최종 피치. 민준·재혁 사이 서류와 술잔, 잠적 발견 장면 사용 금지 |
| `cg_ending_father` | ✅ 있음 | 병실 방문 장면. 현재는 `arc_father_04_visit`용이며 엔딩 CG로 억지 연결 금지 |
| `cg_ending_gangnam_dream` | ✅ 있음 | 강남 입성/아버지 초대 |
| `cg_ending_empty_house` | ✅ 있음 | 강남 입성 후 상실 |
| `cg_ending_crypto_ghost` | ✅ 있음 | 코인 중독 실패 |

릴리즈 블로커급 신규 P0:

| CG ID | 연결 엔딩 | 구도/내용 |
|---|---|---|
| `cg_ending_full_circle` | `full_circle` | 상철 빚을 청산하고 아버지 이름을 돌려받는 S+ 진엔딩 |
| `cg_ending_gangnam_dream_white` | `gangnam_dream_white` | 도착한 뒤에도 자기 손을 돌아보는 White route 전용 컷 |
| `cg_ending_with_daeun` | `with_daeun` | 작은 주방/외곽 빌라, 다은과 민준의 평온 |
| `cg_ending_second_love` | `second_love` | 강남 아파트 베란다, 다은과 같이 도착한 엔딩 |
| `cg_ending_jiyeon_man` | `jiyeon_man` | 강남 거울 앞, 위험하고 고혹적인 지연과 공허한 민준 |
| `cg_ending_guardian` | `guardian` | 병원 퇴원 날, 아버지 짐을 드는 민준 |
| `cg_ending_jaehyuk_way` | `jaehyuk_way` | 커튼을 치는 민준, Black moral collapse |
| `cg_ending_sangchul_reckoning` | `sangchul_reckoning` | 진술서/서류/떨리는 손, 강남 사다리를 스스로 치우는 장면 |

---

## PHASE 2 — 높은 우선순위

### 2-A. 포트레잇 추가

| ID | 캐릭터 | 상황 |
|---|---|---|
| `sangchul_angry` | 임상철 (화남) | 거짓말 들켰을 때 |
| `jaehyuk_shadow` | 최재혁 (어둡고 위협적) | 사기 본색 드러날 때 |
| `father_sad` | 아버지 (슬픔/자책) | 병상 장면 |
| `father_ashamed` | 아버지 (부끄러움) | 과거 실수 고백 |
| `mother_worried` | 어머니 (걱정) | 연락 이벤트 |

### 2-B. 배경 추가

| ID | 장소 | 분위기 |
|---|---|---|
| `nightclub_inside` | 나이트클럽 (밤) | 강남 클럽, 컬러풀 조명, 축하 장면 |
| `library_study` | 도서관/독서실 | 조용하고 집중된 분위기 |
| `clothing_store` | 의류매장 | 외모 업그레이드 이벤트 |
| `airport_terminal` | 공항 터미널 | 해외여행, 고향 귀성 |
| `rooftop_day` | 옥상 (낮) | 건물 옥상, 서울 전경 |

### 2-C. CG 추가

| CG ID | 장면 |
|---|---|
| `cg_first_big_win` | 첫 투자 대박 — 휴대폰 화면에 수익 알람 |
| `cg_jaehyuk_confrontation` | 재혁 대면 — 호텔 라운지, 긴장감 |

---

## PHASE 3 — BGM (배경음악)

> **현재 트랙 (4개):**  
> - `menu` — 메인 메뉴  
> - `early` (`bgm_gosiwon.ogg`) — 초반 고시원 시절  
> - `hustle` (`bgm_main.ogg`) — 중반 열심히 살기  
> - `crisis` (`bgm_crisis.ogg`) — 위기 상황  

> **구현 위치:** `autoloads/BGMPlayer.gd` TRACKS 딕셔너리에 추가 후 `_pick_track()` 로직 수정

| 트랙 ID | 분위기 | 발동 조건 (예시) |
|---|---|---|
| `romance` ⭐ | 따뜻하고 설레는 | 다은/지연 아크 이벤트 |
| `tense_invest` ⭐ | 긴박한 주식 분위기 | 투자 이벤트, 스캘핑 미니게임 |
| `minigame` ⭐ | 경쾌하고 위험한 | 경마/홀덤/스캘핑 공통 미니게임 BGM |
| `late_hustle` | 후반 마지막 스퍼트 | 턴 45+ 고강도 |
| `hometown` | 향수, 가족 | 아버지 아크, KTX 귀성 |
| `celebration` | 축하/환희 | 큰 자산 달성 마일스톤 |
| `confrontation` | 긴장된 대결 | 재혁 대면, 갈등 장면 |

**포맷:** `.ogg` (Godot 권장) / 루프 가능 / 1분 이상 권장

---

## PHASE 4 — SFX (효과음)

> **현재 SFX (13개):**  
> `click`, `close`, `open_modal`, `month`, `money_gain`, `money_loss`, `money_big`,  
> `stat_up`, `stat_down`, `event_new`, `choice_made`, `housing_up`, `game_over`, `success`

> **구현 위치:** `autoloads/AudioManager.gd` `_SFX_FILES` 딕셔너리에 추가

| SFX ID | 소리 | 우선순위 |
|---|---|---|
| `relationship_up` | 따뜻한 짧은 차임 | HIGH |
| `relationship_down` | 차갑게 꺾이는 음 | HIGH |
| `investment_profit` | 주식 수익 — 기쁘지만 긴박한 | HIGH |
| `investment_loss` | 주식 손실 — 슬프고 묵직한 | HIGH |
| `reputation_gain` | 사회적 인정 — 밝고 짧은 | HIGH |
| `job_promotion` | 직급 상승 — 작은 팡파레 | HIGH |
| `health_warning` | 건강 위험 경보 — 낮은 경고음 | MED |
| `stress_warning` | 스트레스 한계 — 심장박동 느낌 | MED |
| `phone_ring` | 전화 오는 소리 | MED |
| `kakaotalk` | 카카오톡 알림음 느낌 | MED |
| `door_knock` | 문 두드리는 소리 | LOW |
| `crowd_cheer` | 환호/박수 | LOW |

**포맷:** `.wav` / 0.5~3초 / 모노 또는 스테레오

---

## 구현 체크리스트

### 새 포트레잇 추가 시
```gdscript
# autoloads/ImageRegistry.gd - PORTRAITS 딕셔너리에 추가
"daeun_determined": "res://assets/characters/npc_daeun_determined.png",
```

### 새 배경 추가 시
```gdscript
# autoloads/ImageRegistry.gd - BACKGROUNDS 딕셔너리에 추가
"luxury_restaurant": "res://assets/backgrounds/luxury_restaurant.png",
```

### 새 BGM 추가 시
```gdscript
# autoloads/BGMPlayer.gd - TRACKS 딕셔너리에 추가
"romance": "res://assets/audio/bgm_romance.ogg",
# _pick_track() 함수에 조건 추가 필요
```

### 새 SFX 추가 시
```gdscript
# autoloads/AudioManager.gd - _SFX_FILES 딕셔너리에 추가
"relationship_up": "res://assets/audio/sfx_relationship_up.wav",
# 사용처에서 AudioManager.play("relationship_up") 호출
```

---

## 총 갭 요약

| 카테고리 | 현재 | 부족분 | Phase 1 | Phase 2+ |
|---|---|---|---|---|
| 포트레잇 | 35 ID (실제 이미지 ~13개) | 감정 변형 부재 | 8개 신규 | 5개 신규 |
| 배경 | 29 정의 (16 실사용) | 핵심 장소 누락 | 6개 신규 | 5개 신규 |
| CG | 4개 | 클라이맥스 미커버 | 4개 신규 | 2개 신규 |
| BGM | 4트랙 | 장면별 음악 없음 | 3트랙 | 4트랙 |
| SFX | 13개 | 관계/투자/직업 없음 | 6개 | 6개 |
| **합계** | | | **27개** | **22개** |

> Phase 1 (27개) 완료 시 게임의 75% 장면이 적절한 비주얼/오디오를 가지게 됨.

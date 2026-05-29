# 강남드림 — 1차 베타 점검 리포트

> 작성일: 2026-05-22  
> 분석 범위: 전체 코드베이스 (GDScript 23개, JSON 13개)

---

## 🚨 P0 — 게임 플레이 자체가 불가능한 버그

### [P0-1] `story_job_unlocked` 플래그가 절대 설정되지 않음 → 구직활동 영구 잠금
- **위치**: `scenes/MainGame.gd` L866, L890
- **증상**: `[💼 구직활동 🔒 스토리 진행 후 해금]` 버튼이 영원히 잠긴 채 유지됨
- **원인**: `story_pressure` 이벤트 선택지에 `"flags": ["story_job_unlocked"]` 항목이 없음. 또한 `story_arrival` 선택지 중 어느 것도 `follow_up_event: "story_pressure"`를 지정하지 않아 `story_pressure`는 사실상 0.01% 확률로만 랜덤 등장함
- **결과**: 모든 플레이어가 직업을 가질 수 없음 → 수입 0 → 게임 내 진행 불가
- **수정**: `story_arrival` 모든 선택지에 `"follow_up_event": "story_pressure"` 추가, `story_pressure` 양쪽 선택지에 `"flags": ["story_job_unlocked"]` 추가

---

### [P0-2] 초반 생존 밸런스 붕괴 — 직업 없이 약 6턴 안에 사망
- **위치**: `autoloads/GameState.gd` L213~248
- **증상**: 시작 스탯 (health 70, mental 70)에서 직업 없이 매달:
  - health -3 (기본) 
  - mental -4 (기본) -3 (무직) = **매달 -7**
  - stress +4 (기본) +5 (무직) = **매달 +9**
  - stress 40 돌파 → mental 추가 -1, stress 60 → health/mental 각 -2 추가
  - 5~6턴에 mental이 0에 근접 → 게임오버
- **P0-1과 연동**: 직업 잠금 + 빠른 사망 = 완전히 플레이 불가
- **수정**: 무직 패널티 완화 (mental -2, stress +3), 또는 시작 체력 상향 (health/mental 80), 또는 첫 3턴 무적 구간 설정

---

## ⚠️ P1 — 게임이 돌아가지만 심각하게 손상된 기능

### [P1-1] `startup_exit` / `political_winner` 플래그를 설정하는 이벤트가 없음
- **위치**: `content/endings.json`, `autoloads/GameState.gd`
- **증상**: `startup_exit` (A등급), `political_fix` (B등급) 엔딩 도달 불가
- **원인**: 해당 플래그를 `"flags": [...]`로 설정하는 이벤트가 컨텐츠 전체에 없음
- **수정**: `drama_events.json`에 스타트업 엑싯 이벤트, 테마주 이벤트 선택지에 해당 플래그 추가

---

### [P1-2] 아이템 효과가 설명과 불일치하는 데이터 버그 다수
- **위치**: `content/items.json`
- **오류 목록**:
  | ID | 이름 | 현재 effect | 올바른 effect |
  |----|------|------------|--------------|
  | item_12 | 심야 독서실 | stress +4 | stress -4 (설명에 "스트레스 쌓인다" 표현이지만 +4는 너무 큰 패널티) |
  | item_17 | 자기관리 코칭 | stress +2 | appearance +5 또는 social_skill +3 |
  | item_20 | 해외 ETF 투자 세미나 | **health +6** | investment_skill +5 |
  | item_24 | 홈트레이닝 장비 | stress +2 | health +8 |
  | item_25 | 강남 부동산 임장 투어 | **appearance +6** | investment_skill +5 |
  | item_26 | 럭셔리 스킨케어 | **intelligence +1** | appearance +6 |
  | item_28 | 해외 주식 투자 마스터 클래스 | **social_skill +2** | investment_skill +6 |

---

### [P1-3] 튜토리얼이 사실상 없음
- **위치**: `scenes/MainGame.gd` L866~884
- **증상**: tutorial_step 3→0으로 줄어드는 구조지만 힌트 텍스트가 너무 작고, AP가 뭔지 / 월급이 어디서 나오는지 / 이사를 왜 해야 하는지 설명이 없음
- **수정**: 첫 달 시작 시 모달 또는 오버레이로 핵심 3줄 안내 팝업 ("⚡ AP 3개로 행동 → 💼 구직 → 💰 월급 → 🏠 이사 → 강남드림")

---

### [P1-4] 관계 탭이 초반 내내 비어있음
- **위치**: `systems/RelationshipSystem.gd`, `content/events/relationship_events.json`
- **증상**: 관계는 이벤트 choice의 `relationship_effects`로만 생성되는데, 관계 이벤트 15개 대부분이 `min_turn`, `has_job` 등 조건이 있어 초반에 거의 안 나옴
- **수정**: 초반 2-3달 내 무조건 관계 1개 생성되는 story 이벤트 추가 ("룸메이트", "편의점 단골")

---

## 🔧 P2 — 완성도/폴리시 문제

### [P2-1] 게임 내에서 내 배경/트레이트 확인 불가
- **위치**: `scenes/MainGame.gd` 스탯 탭
- **증상**: 시작 시 선택한 출신 배경(지방 상경 / 명문대 중퇴 / 금수저)과 트레이트가 게임 시작 후 어디서도 보이지 않음
- **수정**: 📊 스탯 탭 최상단에 "배경: 지방 상경 | 트레이트: 흙수저 생존본능" 1줄 추가

### [P2-2] 메타 진행 트레이트 5개뿐, 재플레이 동기 약함
- **위치**: `content/meta/traits.json`, `autoloads/MetaProgression.gd`
- **증상**: 트레이트가 5개 (기본 포함)이고 해금 조건이 획일적 (자산 기준). 런 기록도 총런/최고자산만 저장
- **수정**: 트레이트 2-3개 추가 + 엔딩별 해금 조건 다양화

### [P2-3] 종료 버튼 없음
- **위치**: `scenes/MainGame.gd` 상단바, `scenes/StartMenu.gd`
- **수정**: 메뉴(≡) 버튼에 "게임 종료" 항목 추가 (`get_tree().quit()`)

### [P2-4] `_slot_button()` 개행 렌더링 확인 필요
- **위치**: `scenes/StartMenu.gd` L369
- **증상**: `btn.text = "%s\n%s"` — Godot 4 Button의 기본 폰트는 `\n` 처리가 설정에 따라 안 될 수 있음
- **수정**: autowrap 또는 Label 2개 가진 커스텀 컨테이너로 대체

### [P2-5] 저장 슬롯 삭제 기능 없음
- **위치**: `scenes/StartMenu.gd` 우측 컬럼
- **수정**: 각 슬롯 버튼에 우클릭 또는 ✕ 버튼으로 삭제 기능 (SaveManager.delete_save 이미 구현됨)

---

## 💡 P3 — 있으면 좋은 것 (베타 후)

| 항목 | 설명 |
|------|------|
| 볼륨 설정 | BGM/SFX 슬라이더, 설정 모달 |
| 씬 전환 효과 | 페이드인/아웃 |
| 정보 탭 기억 | 마지막 선택된 탭 유지 |
| 가격 스파크라인 6점→12점 | 히스토리 더 풍부하게 |
| 업적 시스템 UI | `unlock_achievement`가 구현됐지만 보여주는 화면 없음 |

---

## 📋 수정 순서 (권장)

| 순서 | 항목 | 예상 소요 |
|------|------|-----------|
| **1** | P0-1: story_arrival → story_pressure 연결 + story_job_unlocked 플래그 설정 | 5분 |
| **2** | P0-2: 초반 밸런스 조정 (무직 패널티 완화) | 5분 |
| **3** | P1-2: 아이템 effects 오류 7개 수정 | 10분 |
| **4** | P1-1: startup_exit / political_winner 플래그 이벤트 추가 | 20분 |
| **5** | P1-3: 첫 달 튜토리얼 팝업 | 20분 |
| **6** | P1-4: 초반 관계 생성 이벤트 | 15분 |
| **7** | P2-1: 스탯 탭에 배경/트레이트 표시 | 5분 |
| **8** | P2-3: 종료 버튼 | 5분 |
| **9** | P2-4: 슬롯 버튼 개행 수정 | 5분 |
| **10** | P2-2: 메타 진행 보강 | 30분 |

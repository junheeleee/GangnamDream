# Gangnam Dream — 개발 로드맵

> **세션 시작 시 `CLAUDE.md` 현재 상태 블록 → 이 파일 순으로 읽는다.**
> 완료: `[x]` / 진행 중: `[~]` / 미착수: `[ ]`

---

## 핵심 원칙 (변경 불가)

**이 게임의 코어 재미:**
> "사회가 원하는 길(정석)을 따를 것인가, 나만의 길(비정석)을 갈 것인가  
> — 그 선택이 쌓여서 결과로 돌아오는 이야기."

**기능 추가 기준:**
> "이게 없으면 다른 시스템이 재미없어지는가?"  
> YES → 추가. NO → 다음 단계로 미룬다.

**단계 진행 기준:**
> 각 단계 완료 후 테스터가 "재밌다"는 반응이 나와야 다음 단계로 간다.  
> 안 나오면 기능 추가 전에 재미 원인 분석이 먼저.

---

## Phase 1: 핵심 루프 완성  ← **현재 단계**

> 목표: 테스터가 "재밌다"는 말을 하게 만드는 최소 구조.

### 1-A. 행동 시스템 개편 ✅ 완료 (2026-05-28)
- [x] 월별 `month_focus` 라벨 표시 (첫 행동이 month_focus로 기록)
- [x] 행동 카테고리 2그룹 분리 (정석 / 비정석)
  - 정석: 📚 스펙/공부, 💼 취업·직장, 🤝 인맥 관리, 💰 저축/절약
  - 비정석: 📈 투자, ⚡ 레버리지, 🎨 부업/사이드, ❤️ 연애/관계, 🌊 자유시간
- [x] `month_focus` 조건 이벤트 구조
- [x] 이사 버튼 AP 소비 제거
- [x] 정석/비정석 라우트 포인트 자동 적립 (람다 래퍼)

### 1-B. 루트 & 칭호 시스템 ✅ 완료 (2026-05-28)
- [x] `route_orthodox` / `route_unorthodox` 누적 카운터 (GameState)
- [x] `get_route_identity()` / `get_route_label()` — 성향 문자열 반환
- [x] 루트 성향 UI 표시 (행동 버튼 위)
- [x] `get_current_title()` — 동적 현재 칭호 (상황 기반 실시간 계산)
- [x] 초상화 패널 하단 「현재 칭호」 표시
- [x] `MetaProgression.ALL_TITLES` 29개 수집 칭호 정의
- [x] `check_and_unlock_titles()` — 매달 결산 후 조건 체크 & 토스트
- [x] 🏆 도감 버튼 + `_open_title_collection()` 모달 (카테고리/희귀도별)
- [x] 루트 조건 이벤트 10개 (min_route_orthodox, min_route_unorthodox, month_focus)
- [x] 루트별 이벤트 풀 가중치 차등화 (2026-05-28)
  - route_orthodox/unorthodox 차이 6+ 시 해당 방향 이벤트 최대 ×1.5 부스트
  - month_focus 태그 일치 이벤트 ×1.25 보너스

### 1-C. 하우징 시스템 ← **다음 작업**
- [x] 거주지 단계 정의 (gosiwon/oneroom/apartment/gangnam) — GameState.HOUSING_DATA
- [x] 거주지별 패시브 효과 매달 적용
  - 고시원: 스트레스 +2, 정신 -1
  - 원룸: 패시브 없음
  - 아파트: 평판 +1
  - 강남: 스트레스 -1, 평판 +2
- [x] 이사 버튼 개편 (주거 업그레이드 섹션, AP 없이 자금으로)
- [x] **거주지별 전용 이벤트 각 2-3개** (2026-05-28)
  - 고시원: gosiwon_wall_noise, gosiwon_bathroom_morning, gosiwon_long_stay_blues
  - 원룸: oneroom_first_night, oneroom_empty_fridge
  - 아파트: apartment_floor_noise, apartment_guard_greeting
  - 강남: gangnam_consumption_trap, gangnam_class_pressure

### 1-D. 선택의 연결 (기억되는 선택) ✅ 완료 (2026-05-28)
- [x] 이벤트 `flags` 배열 → 이후 `flag` / `no_flag` 조건으로 연결
- [x] "N달 전 선택 참조" 이벤트 5세트
  - late_night_job_ran_into → convenience_regular_bond (야근 알바 → 편의점 단골)
  - bragged_about_gains → colleague_wants_investment_tips (투자 자랑 → 동료 조언 요청)
  - vented_to_senior → senior_life_wisdom (하소연 → 선배 인생 이야기)
  - ignored_body_warning → body_forced_rest (건강 무시 → 쓰러짐)
  - romance_sumin 체인 (5단계 만남→고백)

### 1-E. 핵심 캐릭터 완성 ✅ 완료 (2026-05-28)
- [x] 라이벌 캐릭터 (RivalSystem.gd 구현 완료 — 매달 근황, FOMO 유발)
- [x] 연인 후보 이수민: 5단계 아크
  - romance_sumin_meet → number → first_date → crisis → confession
- [x] 멘토/압박 박 과장: 5단계 아크
  - mentor_park_meets_you → spec_lecture → weekend_request → burnout_mirror → promotion_offer

---

## Phase 2: 콘텐츠 깊이

> 전제: Phase 1 테스터 통과 후 진행.  
> 목표: 2회 이상 플레이해도 새로운 경험이 나오는 구조.

### 2-A. 취준생 페이즈 ✅ 완료 (2026-05-28)
- [x] 취업 전 단계 정의 — 구직활동 모달 + 준비도 패널
- [x] 전용 행동: 자소서 작성, 면접 준비, 스펙 쌓기 (이미 구현 + 이번 세션 연동 완료)
- [x] 취업 성공/실패 분기 이벤트 — job_rejection_blues, job_interview_wait + 준비 보너스 시스템

### 2-B. 비정석 세부 루트 2개 ✅ 완료 (2026-05-28)
- [x] 창업 루트: 아이디어 → 팀 구성 → 런칭 → 피벗 → 인수/엑싯 (5단계 + 중간 이벤트 2개)
- [x] 크리에이터 루트: 첫 업로드 → 바이럴 → 수익화 → 브랜드딜 → 풀타임 (5단계 + 중간 이벤트 3개)

### 2-C. 엔딩 강화 ✅ 완료 (2026-05-28)
- [x] 루트별 엔딩 분기: startup_exit, creator_success, unorthodox_legend, orthodox_pinnacle 등
- [x] "의외의 엔딩": orthodox_hollow (정석 완벽히 따랐지만 공허)
- [x] 총 엔딩 20개 (목표 15개+ 초과 달성)
- [x] creator_success 엔딩 발동 조건 수정 (age 65 블록에서 꺼내어 자산 3억+ 시 즉시 발동)

### 2-D. 이벤트 품질 패스 ✅ 완료 (2026-05-28)
- [x] 연결 없는 이벤트들 follow_up 추가 (investment, relationship, life 전반)
- [x] 루트별 이벤트 풀 30개+ 정비 (정석 38개, 비정석 61개 확인)
- [x] 한국적 유머 강화 — 카카오 단체방, 치맥, 2호선 통잠, 1+1, 노래방, 찜질방

---

## Phase 3: 완성도

> 전제: Phase 2 테스터 통과 후 진행.  
> 목표: 반복 플레이해도 중독성 있는 구조.

### 3-A. 인생 전체 단계
- [ ] 대학생 페이즈
- [ ] 군대 페이즈 (남성 캐릭터 선택 시)
- [ ] 직장인 → 중간 관리자 → 퇴직/창업 분기

### 3-B. 메타 진행 강화
- [ ] 런 반복 시 해금되는 비정석 루트 (해외 이민, 예술가 등)
- [ ] 이전 런 결과가 다음 런 시작 조건에 영향

### 3-C. 밸런스 & 폴리시 ✅ 완료 (2026-05-28)
- [x] 전체 수치 밸런스 패스 — 직업/투자/하우징/엔딩 수치 검증; 2B 달성 age 47 시뮬레이션
- [x] 한국어 문체 통일 패스 — 이벤트 텍스트 샘플링; 전반적으로 양호
- [x] UI/UX 다듬기
  - _ap_study 모달: AP를 선택 전 소비하던 버그 수정 (선택 후 소비로 변경)
  - 주거 마일스톤 힌트: 실제 이사 가능 자산 수준으로 수정 (8만/35만/120만 기준)
  - 월간 조언: 고시원 탈출 가능 시점에 이사 안내 추가
  - CLAUDE.md: 주거별 고정 지출 정확한 값으로 수정

### 3-D. 출시 준비
- [x] 에셋 생성 스크립트 준비 (`tools/generate_assets.py`, gpt-image-2 기본)
- [~] 실제 이미지 에셋 생성 및 Godot Reimport
  - [x] 주인공 7종 / 핵심 NPC / 배경 주요 세트 애니풍 교체
  - [x] 주요 조연 6종 독립 포트레이트 추가
  - [x] 실사용 스토리 CG 3종 추가
  - [x] 인게임 스플래시 키아트 교체
  - [x] 홀덤 카드/칩 UI 초안은 실제 포커 카드/칩 디자인으로 교체
  - [ ] 경마 UI 이미지는 실제 코드 연결 여부 결정 후 재작업
- [ ] QA 체크리스트 완료
- [ ] 저장 호환성 검증
- [x] 빌드/배포 설정 (2026-06-10) — export_presets.cfg 커밋(Win/macOS/Web), build.sh GODOT 환경변수·Linux 지원, Windows/Web export 실제 검증
- [x] 데스크톱 폴리시 (2026-06-10) — DisplayManager(전체화면 영속화 + F11/Alt+Enter + 창 닫기 자동저장), 설정 UI 전체화면 토글, ESC 시스템 메뉴

---

## 현재 구현된 시스템 (참고용)

| 시스템 | 상태 |
|---|---|
| 기본 턴 루프 (월별 진행) | ✅ |
| 스탯 시스템 (건강/정신/스트레스/지력 등) | ✅ |
| 스탯 임계값 해금 | ✅ |
| 이벤트 시스템 (360개, 쿨다운, 가중치, follow_up 체인) | ✅ |
| 루트 조건 이벤트 (month_focus, route_orthodox 등) | ✅ |
| 투자 시스템 (매수/매도, 레버리지, 마진콜) | ✅ |
| 직업 시스템 (취업/퇴직/승진) | ✅ |
| 관계 시스템 (추상 수치, 패시브) | ✅ |
| 하우징 패시브 효과 | ✅ |
| 정석/비정석 루트 시스템 | ✅ |
| 동적 현재 칭호 (초상화 패널) | ✅ |
| 수집 칭호 29개 + 도감 모달 | ✅ |
| 라이벌 시스템 (RivalSystem) | ✅ |
| 월별 크라이시스/호재 시스템 | ✅ |
| BGM/SFX, 저장/불러오기 | ✅ |
| 메타 진행 (업적, 런 히스토리) | ✅ |

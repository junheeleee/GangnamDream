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
- [x] 실제 이미지 에셋 생성 및 Godot Reimport
  - [x] 주인공 7종 / 핵심 NPC / 배경 주요 세트 애니풍 교체
  - [x] 주요 조연 6종 독립 포트레이트 추가
  - [x] 실사용 스토리 CG 3종 추가
  - [x] 인게임 스플래시 키아트 교체
  - [x] 홀덤 카드/칩 UI 초안은 실제 포커 카드/칩 디자인으로 교체
  - [x] 경마 UI 이미지 코드 연결 확인 — horse_silhouette.png 1024×128 8프레임 아틀라스 정상 연결
  - [x] VISUAL_AUDIO P1 신규 누락 에셋 10종 생성 및 ImageRegistry 연결 (2026-06-12)
  - [x] VISUAL_AUDIO P1 `goshiwon_room.png`/`start.png` 고시원 구조 통일 (2026-06-12)
  - [x] VISUAL_AUDIO P1 `ending_father.png` 아버지 병실 CG 교체 (2026-06-12)
  - [x] VISUAL_AUDIO 에셋 레이어 분리 원칙 확정 — 반복 인물 투명 포트레이트 / 배경 무인 장소 / CG 예외 (2026-06-12)
  - [x] 일반 투자 배경을 `investment_phone.png` 스케일로 격리, 멀티모니터는 전용 장면으로 분리 (2026-06-12)
  - [x] 한지연 캐릭터 정본 확정 및 구 첫 만남 랜덤 체인 비활성화 (2026-06-12)
  - [x] 운영용 정본 맵 및 DLC/주기 업데이트 확장 게이트 문서화 (2026-06-12)
  - [x] `family_living_room.png` 대가족 액자 정합성 실패로 production 기본 가족 배경에서 격리 (2026-06-12)
  - [x] 에셋 정합성 체크리스트 추가 — 배경/포트레이트/CG별 canon QA 기준 문서화 (2026-06-12)
  - [x] 한지연 3표정 투명 포트레이트 교체 (`npc_mentor`, `npc_jiyeon_warm`, `npc_jiyeon_cold`) (2026-06-12)
  - [x] 민준 가족 정본에 맞는 창원/지방 노동자 가정 거실 배경 재생성 및 재연결 (2026-06-12)
  - [x] 김민준 핵심 5표정 투명 포트레이트 교체 (`neutral`, `tired`, `determined`, `happy`, `shocked`) (2026-06-12)
  - [x] 반복 주연/핵심 인물 투명 포트레이트 교체 패스 — 다은/재혁/상철/아버지/어머니/현수 (2026-06-12)
  - [x] 해외/초견 유저용 캐릭터 구분성 보강 — 현수 재디자인 및 cast readability lock 추가 (2026-06-12)
  - [x] 현수 호감형 재교정 — 26-27세 통통한 공시생 후배 정본으로 투명 포트레이트 교체 (2026-06-12)
  - [x] 김민준 직업·상태별 의상 포트레이트 추가 — 무직/알바/사무직/대기업 정장 등 (2026-06-12)
  - [x] 반복 보조 NPC 투명 포트레이트 교체 패스 — 고시원 원장/팀장/성준/정보상 등 (2026-06-12)
  - [x] 전체 배경 이미지 2차 정합성 감사 — 가족사진/경제수준/방 구조/인물 포함 여부 기준 (2026-06-12)
  - [x] 배경 실패컷 재생성 — convenience / Gangnam day-night-station / penthouse / late_night_room (2026-06-12)
  - [x] 플레이어 체감 표면 QA 1차 — ScreenshotQA/AudioAssetCheck/CGRuntimeCheck 실행, 카지노 SFX 8종 추가, 위기 비네팅 축소, `PLAYER_FACING_POLISH_AUDIT.md` 작성 (2026-06-19)
  - [~] UI 스킨 P1 — 이모지 기반 HUD/버튼을 SVG/Texture 기반 Godot Theme로 교체
    - [x] MainGame 상단 HUD 상태칩화 및 직접 행동 액션 카드화 (2026-06-19)
    - [x] 첫 시작 안내 모달을 문서형 안내에서 규칙 카드형 모달로 축소 (2026-06-19)
    - [x] 정선 카지노 허브 이모지 아이콘 제거, 카드/칩 Texture 기반 게임 카드 적용 (2026-06-19)
    - [x] StartMenu 난이도/런 테마 카드 SVG 아이콘화 및 시작/설정/삭제 버튼 문구 정리 (2026-06-19)
    - [x] TutorialOverlay 중앙 아이콘 Texture화 및 ScreenshotQA StartMenu/미니게임 본체 캡처 추가 (2026-06-19)
    - [x] StoryMode 배경 covered scaling 및 상단 VN HUD 텍스트 상태바 정리 (2026-06-19)
    - [x] 정보 패널/행동 모달/세부 카지노 테이블 버튼 이모지·텍스트 버튼 정리 (2026-06-19)
    - [x] 투자/은행/상점/시스템 모달을 SVG/Icon 버튼·섹션 헤더 기반으로 정리하고 ScreenshotQA 보조 모달 3장 추가 (2026-06-19)
    - [x] 영어 시작 표면 P1 — StartMenu/Splash/OpeningCinematic 영어 문구 연결, `LocaleSurfaceCheck`, ScreenshotQA 영어 시작 화면 추가 (2026-06-20)
    - [x] Gangnam Ink 무채색 표면 정본 — 배경/표면 셰이더와 이미지 생성 prompt prefix를 `MORAL_TINT`에 연결 (2026-06-28)
    - [x] 데모 첫 흐름 표면 QA — `ScreenshotQA --qa=demo-flow` 추가, 챕터 카드 HUD 겹침 제거, 초반 고시원/복도 배경-지문 정합성 보정 (2026-06-28)
    - [x] 데모 AP 루프/종료 CTA 표면 패스 — 주차 기준 AP 화면 포커스 카드, 데모 완료/위시리스트 primary CTA, demo-flow QA 확장 (2026-06-28)
    - [x] StoryMode/VN Gangnam Ink 표면 패스 — 배경 셰이더·MORAL_TINT 팔레트·번호 선택지·초상화 후퇴·영어 선택지 QA 캡처 추가 (2026-06-29)
    - [x] 데모 AP 포커스 표면 패스 — Steam Deck/영어 기준 AP 슬롯, 직접 행동 카드 reveal, 추천 문구/목표 압박 문장 정리 (2026-06-29)
    - [x] 데모 오프닝 약속 강화 — 스플래시 핵심 목표 문구, 오프닝 최종 START/GOAL/TIME 스탯 칩, 한영 blackbox QA (2026-06-29)
    - [x] 오프닝 카피 스포일러 가드 — 초반에는 돈 목표만 제시하고 도덕 붕괴/UI 이상화는 플레이 중 체감되도록 문구 정리 (2026-06-29)
    - [x] 데모 종료 기록창 표면 패스 — 이모지 섹션 헤더 제거, 영어 직업/목표 진행 문구 정리, 한영 blackbox QA (2026-06-29)
    - [x] 시작 메뉴 저장 슬롯 표면 패스 — 삭제 액션을 기본 상태에서 무채색 보조 버튼으로 낮추고 확인 상태에서만 위험색 표시 (2026-06-29)
    - [x] 주간 AP 슬롯 표면 패스 — `This Week` 카드의 남은 행동 슬롯을 전체폭 막대에서 고정폭 소형 슬롯으로 교체 (2026-06-29)
  - [~] 미니게임 물체 에셋 P1 — 카드 앞면, 칩 denomination, 룰렛 휠/볼, 슬롯 심볼, 경마 말/기수 스프라이트 확장
    - [x] 슬롯 릴 심볼 텍스트 타일화 및 니어미스 런타임 오류 수정 (2026-06-19)
    - [x] 룰렛 휠/볼 Canvas 드로잉 추가 및 ScreenshotQA 본체 캡처 추가 (2026-06-19)
    - [x] 경마 말/기수 스프라이트 런타임 SmokeRace 검증 경고 제거 (2026-06-19)
    - [x] 카드 앞면/칩 denomination을 실제 테이블용 고해상도 Texture로 확장하고 블랙잭/바카라/홀덤 렌더 경로에 연결 (2026-06-19)
    - [x] 칩 denomination Texture를 슬롯/룰렛/빅휠 베팅 버튼까지 확장하고 빅휠 QA 캡처 추가 (2026-06-20)
  - [x] 오디오 P1 — 장소 ambience 5종, 카지노 플로어 loop, 엔딩 stinger 3종 추가 및 `BGMPlayer` ambience 레이어 연결 (2026-06-19)
  - [x] BGM 연속성 + 첫 면접 시각 정합성 패스 — 같은 트랙 재시작 방지, 낮 면접실 배경 추가, StoryMode/MainGame 초상화 크기·위치 보정 (2026-06-19)
  - [x] 엔딩 시각 보상 P1 — 전용 CG가 없는 엔딩도 엔딩별 배경을 와이드 컷신 프리뷰로 표시하고, 전용 CG 우선순위 문서 갱신 (2026-06-20)
  - [x] 전용 엔딩 CG P1 — gangnam_dream / empty_house / crypto_ghost 3종 CG 생성·연결 및 QA 케이스 추가 (2026-06-20)
  - [x] 바카라 가독성 패스 — 테이블 배경 불투명 베이스 추가로 뒤 MainGame UI 비침 차단 (2026-06-20)
  - [x] VISUAL_AUDIO P1 잔여 교체 대상(주인공/핵심 배경) 인게임 크롭 QA (2026-06-12)
  - [x] VISUAL_AUDIO P1 CG 런타임 표시 연결 QA — 이벤트/엔딩 `cg` 키가 실제 StoryMode/Ending 화면에 표시되는지 확인 (2026-06-12)
  - [x] VISUAL_AUDIO P2 배경/CG/키아트 품질 교체
    - [x] Public venue 배경 리뷰/교체 — library / restaurant / PC방 / 경마장 / 홀덤 / 지방역 / 비 오는 서울 거리 (2026-06-13)
    - [x] 남은 CG 최종 크롭 확인 및 Steam key art / capsule 소재 정리 (2026-06-13)
  - [x] VISUAL_AUDIO P3 BGM/SFX 품질 교체 (2026-06-13)
    - [x] BGM 7종 Ogg Vorbis 재생성 및 import loop 설정 정리
    - [x] SFX 17종 WAV 재생성, `buy`/`sell`/`tab_open` 누락 매핑 추가
    - [x] `tools/AudioAssetCheck` 추가 및 통과
  - [x] 실제 화면 배경-지문 semantic mismatch 1차 수정 — `집들이`/방안 지문 카페 배경, 운동/헬스장 지문 병원 배경 방지 (2026-06-13)
  - [x] 이미지 의미 매핑 2차 + 게임감 연출 패스 — 카페/편의점/회사/지하철/부동산/홀덤/경마 추론 보강, MainGame/RaceTrack/HoldemClub 플래시·흔들림·펄스 피드백 추가 (2026-06-15)
  - [x] 경마 미니게임 프레젠테이션 2차 — 베팅홀/트랙 배경 전환, 기수 오버레이, 흙먼지/속도선, 선두 실황 콜 추가 (2026-06-15)
  - [x] 홀덤 미니게임 프레젠테이션 2차 — 팟 표시, 칩 버스트, 페이즈/액션 배너, 카드 공개 펄스 추가 (2026-06-15)
  - [x] 투자 미니게임 프레젠테이션 1차 — 스캘핑 캔들/매수·매도 마커/손익 배너, TradingFloor 평단선/체결 플래시 추가 (2026-06-15)
  - [x] 정선 카지노 카지노 프리미엄 연출 1차 — 블랙잭/바카라 액션·결과 배너, 플래시, 펄스, 흔들림 추가 (2026-06-15)
  - [x] 2만원급 미니게임 품질 패스 — 카지노 SFX 8종 추가, 슬롯 릴 순차정지, 룰렛 3단계 감속, 바카라 내추럴 배너, 빅휠 포인터 펄스·카운트업, 블랙잭 card/jackpot SFX (2026-06-15)
  - [~] 2만원급 미니게임 품질 패스 — 정선 카지노 블랙잭·바카라·향후 카지노 게임, 경마/홀덤/투자 전용 SFX·스프라이트·레이아웃 고도화 계속
    - [x] 정선 카지노 블랙잭/바카라 공통 `casino_interior.png` 배경 추가 및 `casino` ImageRegistry ID 등록 (2026-06-15)
    - [x] 정선 카지노 외관 `jeongseon_casino_exterior.png` 추가 및 사후 이벤트 배경 명시 연결 (2026-06-15)
    - [x] 정선 카지노 입구 `jeongseon_casino_entrance.png` 추가 및 재입장/중독 자각 이벤트 배경 분리 (2026-06-15)
    - [x] 정선 카지노 허브 첫 화면에 `casino_interior.png` 배경 적용 — 평면 메뉴에서 카지노 장소감 있는 진입 화면으로 개선 (2026-06-15)
    - [x] 운동/헬스장 이벤트 전용 `gym_interior.png` 배경 추가 및 `gym`/`exercise` alias 연결 (2026-06-15)
    - [x] 블랙잭/바카라 카드 비주얼 1차 — 실제 `card_back.png` 뒷면 연결, 랭크/무늬/코너 인덱스 카드 앞면 적용 (2026-06-15)
    - [x] 카드/칩 UI 중심축 교정 — `card_back.png` 중앙 패턴 재정렬, `poker_chip_icon.png` 중앙 심볼 제거 및 실제 칩형 인레이 적용 (2026-06-15)
    - [x] 서울 랜드마크 배경 추가 — 한강 산책/남산타워 등 외국인에게 즉시 읽히는 서울 신호를 이벤트 라우팅에 연결 (2026-06-15)
- [ ] QA 체크리스트 완료
- [x] 저장 호환성 검증 (2026-06-10) — SaveManager v3, run_theme·unlocked_stat_thresholds 직렬화 추가, 구 세이브 compat 로직
- [x] 빌드/배포 설정 (2026-06-10) — export_presets.cfg 커밋(Win/macOS/Web), build.sh GODOT 환경변수·Linux 지원, Windows/Web export 실제 검증
- [x] 데스크톱 폴리시 (2026-06-10) — DisplayManager(전체화면 영속화 + F11/Alt+Enter + 창 닫기 자동저장), 설정 UI 전체화면 토글, ESC 시스템 메뉴

---

## 현재 구현된 시스템 (참고용)

| 시스템 | 상태 |
|---|---|
| 기본 턴 루프 (월별 진행) | ✅ |
| 스탯 시스템 (건강/정신/스트레스/지력 등) | ✅ |
| 스탯 임계값 해금 | ✅ |
| 이벤트 시스템 (395개, 쿨다운, 가중치, follow_up 체인) | ✅ |
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
| 엔딩 25종 활성화 (finish_run 전부 연결) | ✅ |
| 아크 베팅 결과 내러티브 (임상철·한지연 win/lose follow-up) | ✅ |
| 세이브 호환성 v3 (run_theme·stat_threshold 직렬화) | ✅ |

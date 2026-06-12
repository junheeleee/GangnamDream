# Gangnam Dream Work Log

## 2026-06-12 (비주얼+오디오 업그레이드 준비)

### 추가된 것
- **VISUAL_AUDIO_UPGRADE_BRIEF.md** (`assets/`): 이미지/오디오 에이전트용 전체 교체 스펙
  - P1 크리티컬: 주인공 7포즈 + NPC 14장 + 핵심 배경 10장 + CG 2장
  - P2 완전 품질: 나머지 배경 20장 + CG 2장 + 키아트 4장
  - P3 오디오: BGM 7트랙 + SFX 14종
  - 장면별 영문 프롬프트, 기술 스펙(1280×800 배경 / 512×768 초상화 / 1280×720 CG)
  - ImageRegistry 업데이트 가이드 포함
- **ImageRegistry.gd**: 누락 배경 5개 추가 (library, restaurant, street, apartment, convenience_store)

### 배경
- 단순 파일 누락만이 아닌 플레이스홀더 수준의 모든 이미지를 교체 대상으로 결정
- 오디오도 동일하게 전체 재생성 대상

---

## 2026-06-12 (100명 리뷰어 분석 기반 게임 폴리시)

### 추가된 것
- **새 이벤트 54개** — KO 베이스 4파일 + EN 오버레이 4파일 (총 이벤트 500개 달성)
  - `life_events2.json` (19개): 일상 마이크로 모먼트 (SNS 비교, 빈 냉장고, 동창회, 월세 인상, 건강검진, 첫 월급, 도서관, 새벽 편의점 등)
  - `amb_scenarios7.json` (10개): 야망 딜레마 (진급 누락, 창업 합류 제안, 헤드헌터, 연봉 노출 사고, 사내 파벌, 퇴직 충동 등)
  - `drama_events2.json` (15개): 드라마 일상 (결혼 독촉, 명절 식탁, 소개팅, 야근, 폭염, 한파, 정전, 윗집 소음 등)
  - `relationship_events2.json` (10개): 관계 심화 (다은 먼저 문자, 현수 돈 부탁, 아버지의 침묵, 어머니의 고백, 친구 이별 등)
- **콘텐츠 경고 모달** (`StartMenu.gd`): 첫 실행 시 재정 어려움·가족 압박·번아웃 경고 표시 (KO/EN 양방)
- `DataRegistry.gd`: 4개 신규 이벤트 파일 `EVENT_PATHS` 등록

### 수정된 것
- `rel_daeun_first_text`: daeun stage "friend" → ["warm", "close", "interest"] (cast_stages 정합)
- `rel_hyunsu_loan`: hyunsu cast_stage 제거 → `flag: arc_intro_hyunsu_seen` 조건으로 대체
- `first_paycheck_00`: 존재하지 않는 `first_job_taken` 플래그 조건 제거

### 100명 리뷰어 시뮬레이션 주요 개선 근거
- 평균 평점 8.2/10; 가장 많이 언급된 장면: 카페 시나리오(28회), 아버지(24회), 다은(19회)
- 공통 요청: 더 많은 "조용한 고통" 일상 모먼트 → life_events2 + drama_events2로 반영
- 접근성 요청: 콘텐츠 경고 → StartMenu 모달 반영
- 이벤트 다양성: 450→500개 달성

## 2026-06-11 (영어 이벤트 번역 전체 완료 — 150개)

### 번역 파일 추가 (content/events_en/) — 이번 세션
- **arc_events.json** (16개): 인트로 4개·상철 2개·지연 5개·재혁 5개
- **arc_daeun.json** (9개): 다은 편의점 로맨스 아크
- **arc_specialization.json** (9개): 엘리트/퀀트/투기/창업 전문화 분기
- **scenario_cafe.json** (10개): 강남 카페 시나리오 전체 체인
- **scenario_cafe_callback.json** (8개): 카페 콜백 (정보 훔친/솔직했던/굴욕당한 각 분기)
- **amb_scenarios.json** (6개): 전세 사기 아크 + 회식 아크
- **amb_scenarios2.json** (4개): 코인 팁 + 명절 아크
- **amb_scenarios3.json** (4개): 다단계 함정 + 건강 붕괴 + 카드값 후폭풍
- **amb_scenarios4.json** (4개): 잃어버린 지갑 + 이직 베팅 아크
- **amb_scenarios5.json** (2개): 지갑 인연 콜백 + 부모님 수술 동의서
- **amb_scenarios6.json** (3개): 보증 보험 + 직장 내 공 가로채기
- **investment_events.json** (43개): 전체 투자 이벤트 라이브러리

### 번역 현황
- **전체 17개 파일 / 150개 이벤트 번역 완료** — EN 오버레이 시스템 완전 활성
- 미번역 이벤트 0개 (KO 폴백 없음)

### 번역 특이사항
- 투자 용어 표준화: gap investment, LTV, jeonse, circuit breaker, DCA, REITs, PB(Private Banking)
- 전문화 레이블 괄호 표기 통일: [Elite Track], [Quant], [Speculator], [Tech Founder] 등
- 캐릭터 대사 스타일 유지: 상철의 「」 직접 인용 방식 EN에서도 동일하게

## 2026-06-11 (영어 이벤트 번역 확대 — 30개)

### 번역 파일 추가 (content/events_en/)
- **life_events.json** (15개): 부모님 통장·집들이·대리기사·명함·편의점 야간·친구 투자 자랑·강남 전 동료·알고리즘·고향 친구·서울살이 5년·월급날·리딩방·수면 부족·마지막 겨울·아버지의 전화
- **drama_events.json** (5개): 코인 한 방·스타트업 제안·재벌 2세 접촉·청약 당첨·직장 내 암투
- **relationship_events.json** (4개): 지연 첫 만남·다은의 말·병원 대기실·사진 한 장
- **hidden_events.json** (3개): 엘리베이터·건강검진·강남 오픈하우스

### 번역 방향
- 한국 사회 맥락(고시원, 청약, 명함 문화 등)은 최대한 원문 분위기 유지 — 외국 플레이어에게 낯섦이 진정성
- 대화체·감정 리듬 우선 — 직역보다 같은 감정을 영어로 재구성
- 문화 주석 최소화 (청약은 "housing lottery" 한 단어로)

## 2026-06-11 (영어 로컬라이제이션 인프라)

### 구현 내역
- **LocaleManager autoload** — 언어 상태(ko/en) 관리, `set_language()` 호출 시 DataRegistry.reload() 자동 트리거
- **DataRegistry EN 오버레이** — `_apply_en_overlay()`: `content/events_en/*.json`을 스캔해 ID 일치 KO 이벤트를 EN 버전으로 교체 (KO 기반 위에 EN 패치 방식 → 미번역 이벤트는 자동으로 KO 유지)
- **project.godot**: LocaleManager를 DataRegistry 앞에 등록 (의존성 순서)
- **StartMenu 설정 팝업**: 🌐 언어 / Lang 토글 행 추가 — 한국어 / EN 버튼, 언어 변경 시 팝업 닫기
- **content/events_en/story_events.json**: 오프닝 5개 이벤트 영어 번역
  - story_arrival (고시원 장면), story_prologue_dad (아버지 전화), story_prologue_goal (30억 목표 설정),
    story_prologue_meal (편의점 첫 끼니), story_pressure (구직 시작)

### 설계 결정
- EN 이벤트 파일은 KO 전체 이벤트 배열 복사 없이 "변경된 ID만" 포함 — 유지보수 부담 최소화
- `locale` 조건은 이벤트 JSON에 넣지 않음 — overlay 방식으로 투명하게 처리

## 2026-06-11 (이벤트 카테고리 정규화 + 감사 10번째 검사)

### 문제 발견
- `job` (18개), `social_life` (18개), `drama`/`opportunity`/`life`/`hidden_rare_events` (9개) 비표준 카테고리 사용
- 결과: 런 테마 보너스(×1.35) 누락 — 청렴런/직장런에서 직장 이벤트 18개, 인맥런에서 소셜 이벤트 18개가 보너스를 못 받음

### 수정 내역
- `job` → `jobs`, `social_life` → `social` (총 38개 이벤트, 4개 파일)
- `drama`/`opportunity`/`life`/`hidden_rare_events` → 의미에 맞는 표준 카테고리 (9개)
- EventManager: romance 카테고리 이벤트가 relationship 테마(인맥런) 보너스도 받도록 별칭 매핑
- audit.py: 카테고리 화이트리스트 검사 추가 (검사 10번째) — 비표준 카테고리 즉시 WARNING

### 에셋 완비 확인
- 이미지 44종(+조연/CG 보너스), BGM 7트랙, SFX 14종 전부 존재
- ImageRegistry 경로 전수 검증 OK

## 2026-06-11 (감사 체계 확장 — 검사 9종 + CI)

### 신설 검사 4종 (유지보수성 대응: "버그 클래스 단위 기계화")
- **5) serialize 완전성**: GameState var vs serialize() 키 대조, SERIALIZE_EXEMPT로 transient 관리
- **6) 이벤트 키 화이트리스트**: effects/conditions/opportunity/cast_effects 키를
  apply_effects·_check_conditions 코드에서 동적 파싱한 목록과 대조 (코드가 진실 — 자동 동기화)
- **7) 인물 stage 상태기계**: content/meta/cast_stages.json 정본 신설, JSON set/read + GD 비교 리터럴 검증
- **8) 밸런스 회귀 밴드**: tools/balance_check.py — 핵심 정책 3종 시드 고정 시뮬, 밴드 이탈 시 실패 (1.3초)
- **CI**: .github/workflows/ci.yml — 감사 + Godot 4.6.2 헤드리스 컴파일 + SimRun/SmokeRace (로컬 Godot 부재 보완)

### 도입 즉시 검출·수정한 실버그 9건
- work_performance 효과 3건 죽음 (apply_effects 미처리 → 처리 추가) — 엘리트 전문화 보상 복구
- addiction 효과 2건 죽음 (addiction_tendency로 리네임)
- month 조건 2건 미처리 (시즌 이벤트가 아무 달에나 등장 → EventManager에 month 조건 추가)
- jiyeon "together" 죽은 비교 (jiyeon_man 엔딩 게이트 → honest_together로 교정)
- events_seen serialize 누락 (로드 시 이벤트 카운트 리셋 → 추가)
- stage 이름 분열: daeun acquaint/acquaintance, sangchul trust/trusted → acquaintance/trusted로 통일


## 2026-06-11 (아이템 AP 소모 — 밸런스 홀 수정)

- InventorySystem.use_item: GameState.spend_ap() 게이트 추가 (실패 시 메시지 반환)
- MainGame._on_use_item: 성공/실패 토스트 분기, 사용 버튼 "사용 ⚡1" + AP 0 시 비활성
- 근거: QA 감사 발견 홀 — 심리상담 3회권(18만원=22pt) 무한 사용으로 스트레스 시스템 무력화 가능했음

## 2026-06-11 (난이도 모드 + 스토어 포지셔닝)

### 난이도 모드 3종 (전략 결정: "니치 정공 + 보는 재미 증폭")
- GameState.DIFFICULTY_DATA: 드라마/현실/지옥고 — 시작 자금·스트레스, 월간 압박 계수, opp 성공률 보정
- start_new_game 6번째 인자 chosen_difficulty / serialize·구세이브 호환("현실" 기본)
- StartMenu: 런 테마와 같은 카드 UI로 난이도 선택 행 추가
- 엔딩 화면·런 공유 카드에 비현실 모드 표기
- 시뮬 검증: 30억 도달 드라마 27%/현실 15%/지옥고 8% (약 2배 간격), 시뮬 봇 취업 우선순위 수정

### 스토어 포지셔닝 (STORE_PAGE.md 전면 갱신)
- 구 itch.io 초안 폐기 (엔딩 10개·인물 4명·박지연 오기 등 옛 설계)
- 원칙: VN 워딩 배제, "인생역전 드라마 시뮬레이션", 방송각 중심 소재, 현지화 中→日→英


## 2026-06-11 (QA 밸런스 감사 → 파산 정렬 + 대출 시스템)

### QA 감사 (tools/balance_sim.py 신규 — Godot 없이 경제 척추 시뮬)
- 정책별 3,000런: 무베팅 9,600만(테마 확인) / 공격 베팅 30억 60% / 인연 패시브 +4~8pp
- 발견: ①money<0 분기 도달 불가 버그 ②아이템 무제한 사용 홀(미수정, 보류) ③문서-코드 파산 기준 불일치

### 파산 임계값 정렬 (유저: "3천 빚졌다고 파산은 심해")
- bankruptcy -3천만→-1억, debt_spiral -1억→-2억 (문서/UI/엔딩 텍스트와 정렬)
- 판정 기준 현금 → 순자산(현금+포트폴리오-대출원금)
- money<0 우선 검사로 분기 순서 수정 — 빚 압박(스트레스+12/정신-5) 복구
- 시뮬 재검증: 무직 방치가 파산 대신 mental_break로 종료 (빚이 마음을 먼저 무너뜨림)

### 대출 시스템 (유저: "대출기능을 넣어서 판을 키우던지" → "자산·직장 따라 신용등급")
- GameState: get_credit_score(1~100)/get_credit_grade(1~10)/get_loan_rate/get_loan_limit
  — 고용+15, 근속 최대+12, 소득 최대+14, 순자산 최대+20, 평판 최대+5, 부채비율 최대-25, 바닥이력-8
- 1금융: 7등급 이내+직장, 월 0.4~0.88%, 한도 소득×(20-2g) / 2금융: 누구나, 월 1.28~2.0%, 한도 1,000만+400만×(10-g)
- 변동금리: 매달 현재 등급으로 이자 계산 — 등급 하락 시 보유 빚 이자도 상승 (빚의 악순환)
- borrow/repay, 월 이자 자동 차감+스트레스 2, serialize·구세이브 호환
- MainGame: 투자 모달에 🏦 은행 버튼 → 은행 모달 (등급 배지/점수/상품별 한도·금리/대출·상환)
- 시뮬: 신용 기반 풀레버리지 30억 +4.0~7.3pp, 실패엔딩 증가 없음. 대표 곡선 BALANCE.md 기록

## 2026-06-11 (아크-게임플레이 연결 — 에필로그·패시브·정보 이벤트)

### 설계: "엔딩의 크기는 숫자가, 표정은 관계가 정한다"
- 아크 선택지에 엔딩 게이트 무게를 더 두면 플레이어가 아크만 파고, 안 두면 선택 체감이 없는 딜레마 해소
- 엔딩 티어 = 자산/스탯 (현행 유지), 아크 = 에필로그 변형 + 런 중 경제 환류 보상

### 인연 에필로그 (`_ending_cast_epilogue`)
- 엔딩 화면에 "👥 그 사람들은" 섹션 추가 — 아버지/지연/다은/상철/재혁 최종 stage별 결말 직후 한 장면
- 성공/실패/중립 엔딩 티어에 따라 같은 관계도 다른 문장 (예: 화해한 아버지 — 성공 시 집들이, 실패 시 「내려와서 밥이나 먹자」)
- 아버지는 항상 1줄 보장 (방치 시 "창원에는 끝내 한 번도 내려가지 못했다")

### 인연 월간 패시브 (`apply_monthly_pressure`)
- 아버지 화해(reconciled/connected/hopeful/close) → 매월 정신력 +1
- 연인 단계(지연 lover/honest_together, 다은 lover/together/committed/dating) → 매월 스트레스 -2
- 상철 신뢰(trusted/mentoring/guardian) → 4턴마다 투자감각 +1

### 상철 투자 정보 이벤트 2종 (investment_events.json 41→43)
- `sangchul_tip_redev`: 급매 정보 — opportunity 메커니즘 (성공률 0.62, 배수 1.8, 손실비율 0.5 = 시장 베팅보다 유리한 EV)
- `sangchul_tip_warning`: 시장 과열 경고 — 수용 시 투자감각 +3/스트레스 -3 (보호형 정보)

### AP 행동 vignette 전환 마무리
- `_ap_save_money` / `_ap_network`: toast → vignette (SAVE 11종 / NETWORK 10종 풀)
- 저축 절약 보너스(현금 0.5%, 상한 8만)와 network_count 플래그는 vignette 안에서 유지

---

## 2026-06-11 (캐릭터 아크 완성 + 온보딩 강화)

### Priority 5: 온보딩/첫 10분
- `_show_tutorial()`: 정석/비정석 루트 시스템 설명 섹션 추가 (Modal 580×560으로 확장)
- `_open_investments()`: 첫 방문 시 투자 가이드 표시 (시장 사이클, 레버리지 리스크, 스킬 효과)
- `investment_first_visited` flag로 초회만 표시

### Priority 6: 캐릭터 아크 마지막 단계 검증 → 신규 작성
- 기존 arc 이벤트 (romance_sumin, mentor_park) JSON에 없음 확인 → 재설계
- **한지연 로맨스 아크 5단계**: jiyeon_meet→jiyeon_coffee→jiyeon_date→jiyeon_crisis→jiyeon_confession
  - BMW 접촉사고 첫 만남 / 강남 카페 커피 / 파인다이닝 데이트 / 전남친 위기 / 한강 고백
  - cast_effects로 stage(interest→warm→lover/distant) + affinity 추적
- **임상철 멘토 아크 5단계**: sangchul_meet→sangchul_amb_call→sangchul_amb_lunch→sangchul_why_gangnam→sangchul_past
  - 부동산 카페 첫 만남 / 안부 전화 / 국밥집 / "강남 왜 가고 싶어요?" / 과거 고백
  - 기존 sangchul_amb_call 조건 수정 (cast_met→flag: sangchul_met)
- **아버지 아크 4단계**: father_wedding_call(기존)→father_health_call→father_first_visit→father_missed_chance(기존)
  - 목소리가 달라진 전화 / 오랜만의 귀향+된장찌개
- 총 이벤트: life 153개, relationship 42개

---

## 2026-06-11 (90점 공략 — 이벤트/엔딩 전면 리라이트)

### 1단계: 이벤트 라이팅 패스 2차 (38개)
- life(10) / investment(6) / relationship(8) / hidden(14) 전면 리라이트
- 중복 테마 해소: hidden_011→헤드헌터, hidden_012→잊혀진 통장, hidden_013→지하철 전 상사
- 앵글 분리: 월세인상(생활 vs 투자), 전세사기(개인공포 vs 시장반응), 퇴사브이로그(동료 vs 낯선 사람)

### 2단계: 엔딩 20종 전면 리라이트
- 씬 기반 서술로 전환 — 감각 디테일, 구체적 장면, 열린 결말
- orthodox_hollow: "55년을 살았는데 내가 원하는 게 뭔지 모르겠다" — 게임 핵심 테마
- gangnam_dream: 아버지 "좋구나, 아들" 씬 강화
- reputation_legend, creator_success, balanced_life 등 단편 소설 수준으로 확장

---

## 2026-06-11 (90점 라이팅 패스 — 이벤트 글쓰기 품질 강화)

### 목표
메타크리틱 90점 달성을 위한 글쓰기 품질 강화 — 시그니처 이벤트, 챕터 브레이크, 이벤트 리라이트

### 구현 내용

**시그니처 모멘트: `father_wedding_call` (아버지의 전화)**
- Papers Please 스타일 도덕적 딜레마: 투자 마감 vs 아버지 결혼식 귀향
- 비정석 선택 결과문 마지막 줄: "최적의 선택이었다." — 게임이 스스로를 아이러니하게 평가
- weight 18.0, cooldown 9999, 6-14턴 창 (조기에 플레이어 가치관 검증)
- 플래그: `went_home_for_father` / `skipped_father_wedding`

**챕터 브레이크 3종 (스토리 구조 뼈대)**
- `chapter_break_turn15` (15턴±2): "15개월째, 서울" — 청약 FOMO, 남의 속도와 내 속도
- `chapter_break_turn30` (30턴±2): "반환점" — 절반 지점 성찰, 전략 재검토
- `chapter_break_turn45` (45턴±2): "15개월 남았다" — 마지막 스퍼트, 이 5년의 의미
- 모두 weight 20.0, cooldown 9999 (각 창에서 1회만 발화)

**이벤트 11종 산문체 리라이트**
- family_002, family_013, military_007, disasters_009, finance_011
- comedy_043, social_life_048, romance_078, gambling_072, comedy_021, comedy_032
- 구어체 설명 → 감각 디테일 + 짧은 문장 리듬, 선택지 result_text 구체화

### 총계
138 → 142 이벤트 (시그니처 1 + 챕터 브레이크 3)

### 감사 결과
ERROR 0, WARNING 0 — 신규 플래그 2개(`went_home_for_father`, `skipped_father_wedding`) 깨끗

---

## 2026-06-10 (Steam Deck 컨트롤러 지원 — Verified 대응)

### 구현 내용
- **project.godot**: `gd_tab_next`(RB = button 5) / `gd_tab_prev`(LB = button 4) 입력 액션 추가
- **ControllerHints**: `shoulder_l()` / `r3()` 메서드 추가; LB 레이블 컬럼 추가;
  패드 조작 시 마우스 커서 자동 숨김 (joypad 이벤트 → MOUSE_MODE_HIDDEN, 마우스 이동 → 복원)
- **StoryMode** (가장 중요):
  - `_unhandled_input` 추가 — A버튼으로 텍스트 진행, B버튼 실수 방지 흡수
  - 선택지 표시 시 첫 버튼 `grab_focus()` → 패드로 즉시 D패드/스틱 탐색 + A 선택
  - 포커스 스타일박스 시각적 구분 (파란 왼쪽 테두리 4px + 밝은 배경)
  - `_continue_hint` 텍스트 동적 반영 — 패드 연결 시 "[A] 또는 클릭"
  - 튜토리얼 팝업 패드 버튼으로 닫기 지원
- **MainGame**: `gd_tab_next/prev` 탭 순환 처리; 패드 힌트 R3/LB/RB로 수정

### Steam Deck Verified 체크리스트 업데이트
- ✅ Input (컨트롤러 전용 플레이 가능): StoryMode A버튼 진행 + 선택지 D패드 탐색, 메인게임 탭 LB/RB
- ✅ Display (1280×800, 9px+): 기존 구현 유지
- ✅ Seamlessness (커서 자동 숨김): ControllerHints._input 구현
- ⬜ System Support (Linux 빌드): 로컬 Godot 필요

---

## 2026-06-10 (QA 전 전체 게임 분석 + 발견 사항 수정)

### 분석 범위
- 콘텐츠 인벤토리(이벤트 398·엔딩 25·직업 15·자산 18), 월간 턴 루프 순서,
  엔딩 발동 경로 25종 교차 검증, 아크 라우팅 가드 플래그 전수 검사(무한루프 위험),
  밸런스 몬테카를로 시뮬레이션(저축·투자·기회 베팅 경로)

### 분석 결과 요약
- **아크 무한루프 검사 전부 통과**: _next_arc_id() 라우팅 대상 전체의 모든 선택지가
  가드 플래그를 set (follow_up 경유 포함) — StoryMode 무한 재생 위험 없음
- **밸런스**: 저축만으로 60개월 최대 ~6.3억(목표의 21%) — 투자 강제 구조 확인.
  승리 경로는 불장 사이클 + 버블 자산(+vol×0.6/월) + 레버리지 + 기회 베팅 조합
- **발견 문제 2건** → 즉시 수정 (아래)

### 수정 사항
1. **political_fix 엔딩 발동 연결** — 25개 중 유일한 죽은 엔딩.
   political_winner(보좌관→당선) 시 check_game_over에서 즉시 발동.
   엔딩 텍스트도 옛 "정치 테마주" → 실제 경로에 맞는 "여의도行"으로 재작성
2. **story_arrival_elite/rich 삭제** — 옛 설계(서른 살 시작·루트 선택) 잔재, 미라우팅
3. CLAUDE.md 아이템 표기 30→28 교정

### QA 플레이스루 중점 항목 (로컬 Godot)
- 세이브/로드 후 같은 턴 상황 이벤트 중복 재생 여부 (month_event_turn)
- 30억 도달 가능성 실측 (버블+레버리지+기회 베팅 풀활용)
- 마진콜·이벤트 동시 발생 시 잔액 정산
- 이벤트로 퇴직한 달의 월급/지출 정산
- audit.sh의 Godot 컴파일 체크는 원격 환경에서 스킵됨 — 로컬에서 먼저 실행할 것

---

## 2026-06-10 (아크 패널 완성 + warned 분기 신설)

### 작업 내용
1. **arc_jiyeon_truth_warned 신설** — `warned_about_jiyeon` 플래그 실질 파장 구현
   - 임상철 경고를 들은 플레이어는 진실 씬에서 다른 묘사(미리 알고 있었던 관점)
   - 기존 3가지 선택지를 유지하되 description 과 result_text 를 재구성
   - `_next_arc_id()` 라우팅 분기 추가: warned_about_jiyeon → truth_warned, 아닌 경우 → truth_moment
2. **arc 패널 아버지 · 재혁 추가** — 두 주요 아크가 패널 목록에서 누락됐음
3. **임상철 패널 힌트 수정** — "직장 경험 후" → "10개월차 이후 자동 만남"

### 결과
- 아크 패널: 7개 항목 (다은/임상철/현수/지연/아버지/재혁/성향전문화)
- audit ERROR 0 · WARNING 0 유지

---

## 2026-06-10 (플래그 교차 검증 도입 — 잠재 버그 15개 일괄 수정)

### 왜: "아크 볼 때마다 수정거리가 나온다"의 근본 원인
게임 전체가 문자열 플래그(JSON set ↔ GDScript read)로 연결돼 있는데
둘의 일치를 검증하는 장치가 없었다. 오타·이름 불일치는 Godot 파싱을 통과하고
"패널이 안 뜸 / 이벤트가 영영 안 뜸 / 엔딩이 안 나옴"으로 조용히 죽는다.

### audit.py 4번 검사 신설: 플래그 교차 검증
- 게임 플래그: JSON(choices.flags / effects.flag / opportunity win·lose_flag) +
  GD(`flags["x"]=`) 의 SET 풀 ↔ GD(`f.get`/`flags.get`/`f.has`) + JSON(`flag`/`no_flag`) READ 대조
- cast 플래그: cast_effects.<pid>.flags ↔ cast_has_flag(pid, flag) 대조
- 읽기만 하고 set 없는 플래그 → ERROR

### 검출된 15개 전부 수정
- **엔딩 게이트 2종 (GameState)**: `late_call` 엔딩이 한 번도 set 안 되는
  cast 플래그(father.reconciled)를 읽고 있었음 → `father_reconciled` 게임 플래그로.
  `empty_house`는 존재하지 않는 father.passed_away 의존 → "관계 전무 + 아버지 비화해"로 재정의.
- **아크 패널 2종 (MainGame)**: 현수 패널(met_hyunsu/arc_hyunsu_0X_seen 전부 미존재) →
  실제 플래그(arc_intro_hyunsu_seen/arc_jaehyuk_hyunsu_warning_seen)로 재구성.
  다은 패널 done(arc_daeun_together_done 미존재) → arc_daeun_04_seen.
- **죽은 플래그 읽기 4종**: creator_success_unlocked→creator_viral(5곳),
  political_career_started→political_candidate, romance_sumin_confession 분기 2곳 제거(구 캐릭터),
  free_time_count → _ap_free_time에 카운터 구현(칭호 "자유로운 영혼" 해금 복구).
- **이벤트 조건 3종**: startup_team_conflict(flag: startup_team 미존재→startup_founded),
  startup_first_user_traction(no_flag: startup_growing 미설정→본인이 set, 1회성화),
  story_gosiwon_neighbor(반복 방지 플래그 미설정→choices에 추가).

### 옛 설계 잔재 이벤트 11종 제거 + 마일스톤 라우팅 정비
- story_events 7종 삭제: pre_retirement_decision(마흔다섯/55세 은퇴), age_40/50/55/60,
  story_five_year(스물다섯), midlife_30s_reflection — 전부 시작 20세/은퇴 65세 옛 설계
- life_events 4종 삭제: arc_father_01~04 구버전 체인 — arc_events 신버전 5단계와
  같은 스토리를 중복 진행(아버지가 두 번 아프고 두 번 화해하는 버그)
- 마일스톤 라우팅: t48이 옛 pre_retirement_decision을 호출하던 버그 → story_four_year로.
  고아 상태였던 story_six_months(t6)/story_one_half_year(t18)/age_35_checkpoint(t30) 라우팅 추가
- 텍스트 수정: story_four_year 스물넷→서른일곱, story_six_months 100만원→50만원,
  age_39_final 서른아홉/마지막 1년→서른여덟 직전/마지막 반년

## 2026-06-10 (아크 깊이 작업 3차 — 다은·한지연 콘텐츠 + 패널 버그 수정)

### 다은 아크 콘텐츠 추가 (arc_daeun.json + MainGame 라우팅)
- arc_daeun_03b_date (t≥28, together path): 편의점 밖 첫 외출 — 관계에 질감 추가
- arc_daeun_04b_future (t≥42, together_path): "강남 가면 나는?" 관계 긴장 장면
- arc_daeun_regret_draft (t≥47, let_her_go path): 보내지 못한 문자 — 이별 후 여운
- arc panel 표시 버그 수정: arc_daeun_02_seen / arc_daeun_03_seen → arc_daeun_regular_seen / arc_daeun_fork_seen

### 한지연 아크 콘텐츠 추가 + 패널 수정 (arc_events.json + MainGame)
- arc_jiyeon_03b_lunch (t≥27, after offer): 청담 점심 — 투자 파트너 vs 감정 분기
- arc_jiyeon_05_epilogue (t≥50, after truth): 고백 다음 날 — 관계 방향 결말 선택 3종
- arc panel 이름 수정: "박지연 (멘토)" → "한지연 (투자·로맨스)"
- arc panel 플래그 수정: met_jiyeon / arc_jiyeon_01/02/03_seen → 실제 이벤트 플래그

### 임상철 아크 패널 버그 수정 (MainGame)
- met_sangchul / arc_sangchul_01_seen → arc_sangchul_met_seen

### audit ERROR 0 / WARNING 0 통과

## 2026-06-10 (아크 깊이 작업 2차 — 재혁 아크 깊이 강화)

### 재혁 아크 3개 이벤트 추가 (arc_events.json + MainGame 라우팅)
- arc_jaehyuk_01b_real_face (t≥29): 포장마차 취중 고백 — 재혁도 처음엔 피해자
- arc_jaehyuk_02b_favor (t≥34): 조건 없는 인맥 도움 — 배신을 더 아프게 만드는 장치
- arc_jaehyuk_04c_stand_up (t≥44): 사기 당한 후 재기 선택 — t42~t50 빈 공간 채움
- arc_jaehyuk_aftermath: 피해자 경로 3번째 선택지 추가 (jaehyuk_scammed)

## 2026-06-10 (아크 깊이 작업 1차 — 아버지 아크 신설 + 다은 아크 수정)

### 아버지 아크 5단계 신설 (arc_events.json + MainGame._next_arc_id)
- arc_father_01_call (t≥11): 어색한 23초 첫 전화
- arc_father_02_signal (t≥22): 이웃 카톡 — 아버지 병원 다닌다는 소식
- arc_father_03_hospital (t≥35): 어머니 전화 — 뇌혈관 경고 증상
- arc_father_04_visit (t≥43): 창원 병원 방문, "미안하다" 감정 클라이맥스
- arc_father_05_after_visit (t≥52): 화해 이후 날씨 이야기 전화

### 다은 아크 플래그 수정 (arc_daeun.json)
- arc_daeun_01_meet: met_daeun / arc_daeun_01_seen 플래그 누락 추가
  (arc 패널 표시 조건 및 _next_arc_id 분기 정상화)
- arc_daeun_02_regular: 빈 result_text 채움

### 이미지 ID 오류 수정
- hospital_corridor → hospital, npc_father → father_weak, ending_father → cg_ending_father

### audit: ERROR 0 / WARNING 0 통과

## 2026-06-10 (QA 패스 6차 — 엔딩·세이브·아크 결과 수정)

### 세이브 호환성 버그 2건
- run_theme 직렬화 누락 → 로드 후 런 테마 UI 오표시
- unlocked_stat_thresholds 누락 → 스탯 알림 중복 발생
- 구버전 세이브 역추론 로직(run_theme_categories → run_theme), SaveManager 버전 2→3

### 미사용 엔딩 9종 활성화 (check_game_over)
- lonely_rich, creator_success, reputation_legend, orthodox_pinnacle, unorthodox_legend
- early_retirement, investment_master, balanced_life, orthodox_hollow

### 아크 베팅 결과 내러티브 4종 (arc_events.json + _next_arc_id)
- sangchul 기회 이벤트에 win_flag/lose_flag 추가
- arc_opp_sangchul_win/lose, arc_opp_jiyeon_win/lose 이벤트 작성
- 베팅 결과(win/lose)에 따른 인물 관계·루트 분기

## 2026-06-10 (난이도 조정 5차 — 30억 달성률 목표 5~8%)

### 투자 수익 개선
- InvestmentSystem: 월 드리프트 0.35% → 0.6%(연 7.2%), 크래시 피해 축소(-18~45% → -12~38%)

### 기회 이벤트 버프 (arc_events.json)
- 임상철 부동산 올인: 성공률 0.32→0.42, 배수 1.6→2.8
- 임상철 신중 투자: 성공률 0.32→0.44, 배수 1.6→2.0
- 한지연 분양권 올인: 성공률 0.28→0.38, 배수 2.4→4.0, 손실 0.8→0.75

### 신규 투자 이벤트 2종 (investment_events.json)
- `inv_ipo_hot_tip` (12턴+, 1천만 이상): 공모주 대박 예고 — 배수 3.5~2.5×
- `inv_redev_zone_tip` (28턴+, 1억 이상, rare, cooldown 9999): 재개발 예정지 정보 — 배수 7.0~5.0×

### SimRun 업데이트
- 음의 기댓값 OPP 2종(코인투기 -9%, 레버리지 -7%) 제거 및 버프된 실제 이벤트 파라미터로 대체
- 고자산(2억+, 28턴+) 재개발 메가베팅 OPP_MEGA 추가 (mode 4 전용)

## 2026-06-10 (UX 감사 기반 개선 1~3차 — 신규 유저 경험)

### 4방향 감사 (병렬 에이전트)
- 첫 30분 UX / 오디오·비주얼 커버리지 / 난이도·콘텐츠 볼륨 / NPC 생동감·개연성
- 핵심 발견: 승률 1.3~3.6%(신규 좌절), 이벤트 77.7% 텍스트만(StoryMode 한정),
  NPC 고정 대사, 무직 3턴 사망 나선, 미니게임 SFX 빈약

### 1차 — 개연성·NPC·안전망
- 개연성: drama_job_offer_dilemma(no_job), gangnam_coffee(max_money), arc_temptation_01(잔고 하드코딩 제거)
- _contact_flavor() 신설: 연락하기 대사가 스토리 플래그(재혁 신고/동업/사기, 다은 분기, 아버지 화해, 상철 네트워크, 지연 진실)에 반응
- GameState.apply_choice에 grant_job 지원 + arc_rescue_job(턴5+ 무직 안전망, 고시원 주인 소개)
- 엔딩 상위 N% 표시(_ending_percentile_line) — 30억 실패를 정상으로 리프레이밍
- 효과 플로팅 1.3→2.2초

### 2차 — 비주얼·오디오
- ImageRegistry.infer_background_id() + StoryMode 폴백 — 배경 잔존/공백 해소
- 미니게임 SFX: 홀덤 쇼다운, 스캘핑 정산, 경마 출발, 알바 결과

### 3차 — 콘텐츠 공백
- 상철 일상 2종(sangchul_amb_call/lunch) — 아크 사이 생동감
- 마지막 10턴 2종(final_stretch_check 50~54턴 / final_last_winter 56~59턴)
- apply_choice에 choice "route" 키 지원 (선택지가 정석/비정석 포인트 적립)

### 4차 — 칭호 재설계
- 이야기의 선택 칭호 5종: 그날 밤의 선택(kept_clean_hands), 선을 지킨 사람(took_high_road),
  마지막 봄(father_reconciled), 사랑을 택한 사람(daeun_chose_her), 의심하는 자(started_investigating)
- 칭호 보유 → 다음 런 시작 보너스: PERK_RULES 카테고리별 누적+상한
  (투자→투자감각, 직업→지력, 관계→사교력, 주거→스트레스↓, 성향→운, 이야기→정신력, 메타/미니게임→자금)
- GameState._apply_title_perks() — start_new_game에서 적용+로그, 도감에 보너스 표시
- 버그: 도감 카테고리 루프에 미니게임 누락 → 마스터리 칭호 3종 미표시 문제 수정
- 런테마(8번 항목)는 기존 구현 확인됨 — EventManager 가중치 부스트 + 청렴런 도박 차단 (감사 오탐)

### 남은 항목 (우선순위)
- 영어 로컬라이제이션(대형), 미니게임 전용 BGM(에셋 필요), CG 추가(에셋 필요)

## 2026-06-10 (인게임 폴리시 — 저장/불러오기, 승진 UI, 목표 속도)

### 중간 저장/불러오기 (시스템 메뉴)
- `_build_save_load_section()` 추가: ≡ 시스템 메뉴에 슬롯 1–3 저장/불러오기 패널 삽입
- 슬롯별 [저장] + [불러오기] 버튼, 저장된 경우 연도·월·총자산 표시
- `_save_to_slot(slot)` / `_load_from_slot(slot)` 함수 신설

### 직업 승진 현황 UI (_open_cat_work)
- 취업 상태일 때 "월급과 승진은 자동 처리" 메시지를 대체:
  - 근속/임계치 ProgressBar (N/M개월)
  - 업무 성과 60+ 게이트 (색상 구분)
  - 승진 가능/불가/N개월 후 판정 상태 표시
  - 다음 직급 예시 표기

### 목표 달성 속도 표시 (_render_ap_actions)
- `_months_to_goal_estimate()` 신설: 현재 수입 기준 달성까지 몇 개월 필요한지, 잔여 시간과 비교
- 상황판 마일스톤 힌트 아래 매달 표시

## 2026-06-10 (스팀 출시 준비 — 데스크톱 폴리시 + 빌드 파이프라인 검증)

### DisplayManager autoload 신설
- 전체화면 설정 영속화 (`user://gangnam_dream_display.json`, AudioManager 설정 파일과 분리해 키 덮어쓰기 충돌 방지)
- F11 / Alt+Enter 전역 전체화면 토글 (`_input`에서 처리, 스플래시/시네마틱 키 디스미스와 충돌 없음)
- 창 최소 크기 960×600 적용
- 창 X 버튼 닫기 시 MainGame 진행 중(게임오버 아님)이면 자동저장
- 웹 빌드(`OS.has_feature("web")`)에서는 전부 비활성

### 설정 UI 보강
- StartMenu ⚙️ 설정 모달 + MainGame ≡ 시스템 메뉴에 🖥️ 전체화면 CheckButton 추가 (F11/Alt+Enter 힌트 표기, 웹에선 숨김)
- MainGame `_unhandled_input`: ESC → 시스템 메뉴 열기 / 시스템 메뉴 닫기. 이벤트·결산 모달은 ESC 비대상 (흐름 보호 — DECISIONS.md 참고)

### 빌드 파이프라인 완성
- `export_presets.cfg` 생성 + 커밋 (기존엔 gitignore 상태라 `build.sh`가 참조하는 프리셋이 아예 없어 빌드 불가였음)
  - Windows Desktop: x86_64, embed_pck(단일 exe), modify_resources=false(rcedit 불필요)
  - macOS: universal, ad-hoc 서명, 번들 ID `dev.junheelee.gangnamdream`
  - Web: nothreads, canvas resize policy=adaptive
  - 공통 exclude: `tools/*, docs/*, build/*`
- `tools/build.sh`: `GODOT=경로` 환경변수 지원 + Linux 템플릿 경로(`~/.local/share/godot`) 지원 + windows 사용법 추가

### 헤드리스 QA (Godot 4.6.2 Linux, 원격 환경에서 실제 실행)
- `GODOT=… ./tools/audit.sh` 전체 통과 — 컴파일 체크 38개 스크립트 깨끗 (신규 DisplayManager 포함)
- `tools/SimRun.tscn` 12,000런: 데드락 0 / 크래시 0 / 승리 도달률 1.3~3.6% (밸런스 의도 범위)
- `tools/SmokeRace.tscn` 전체 통과 (단승/삼쌍승/연승/복승/정보상/전적)
- Windows export 실제 성공 → `GangnamDream.exe` 196MB 단일 파일
- Web export 실제 성공 → index.html/wasm/pck 정상 생성
- `./tools/build.sh windows` 엔드투엔드 검증 완료

### 남은 일 (로컬 필요)
- 로컬에서 인게임 화면 크롭·톤 검수 (Start/Splash/MainGame/Story CG/Holdem/RaceTrack)
- Windows exe 실제 실행 테스트 (헤드리스 환경에선 GUI 실행 불가)
- macOS export는 로컬 macOS에서 검증 권장 (서명/공증 경로)

## 2026-06-09 (에셋 생성 파이프라인 준비)

### 스타일 분석
- 기존 배경 3종(`goshiwon_room`, `gangnam_night_street`, `convenience_store_night`)과 이후 전체 이미지 세트(배경/캐릭터/키아트/로고)를 기준으로 공통 스타일 편차 확인.
- 기존 에셋은 여러 세대가 섞여 있어 “있는 그림체를 그대로 추종”하기보다 새 기준으로 통일하는 편이 낫다고 판단.
- 최종 기준: 완전 애니/한국 만화풍 비주얼노벨 아트. 배경은 애니 배경 미술, 캐릭터는 serious manhwa/VN 포트레이트. 실사/DSLR/피부 모공/카메라 보케 금지.

### 도구 추가
- `tools/generate_assets.py` 신규 추가.
- 기본 이미지 모델: `gpt-image-2` (`--model`로 변경 가능).
- 총 44개 에셋 프롬프트 내장: 주인공/NPC 초상화, 신규/기존 배경, 미니게임 UI, Steam 키아트.
- `STYLE_SUMMARY` → `Master Style Guide` → 카테고리별 규칙(캐릭터/배경) → 개별 프롬프트 순서로 모든 프롬프트 구성.
- `--force` 없으면 기존 파일 스킵, API/IO 에러는 경고 후 다음 이미지 계속 진행, 완료 시 `assets/ASSET_INDEX.md` 생성 체크리스트 갱신.
- `openai` SDK가 있으면 SDK를 사용하고, 없으면 `requests` 기반 Images API 호출로 fallback.

### 검증/상태
- `python3 -m py_compile tools/generate_assets.py` 통과.
- `python3 tools/generate_assets.py --dry-run`으로 44개 작업 목록 확인.
- Codex 내장 이미지 생성으로 애니풍 주인공/고시원 샘플 생성 후 `/tmp/gangnamdream_style_samples/anime_style_pair.png`에 비교 시트 저장.
- 주인공 포트레이트 7종을 애니풍으로 생성해 `assets/characters/main_character_*.png`에 512×768 저장.
- `/tmp/gangnamdream_style_samples/main_character_7_anime_sheet.png`로 7종 시트 검수 완료.
- NPC 포트레이트 5종(`npc_romantic_interest`, `npc_boss`, `npc_close_friend`, `npc_mentor`, `npc_tip_seller`)을 애니풍으로 생성해 512×768 저장.
- 신규 배경 6종(`racetrack_betting_hall`, `racetrack_track_view`, `holdem_club_interior`, `scalping_trading_room`, `aruba_delivery_street`, `gangnam_station_exit`)을 애니풍으로 생성해 1280×800 저장.
- `/tmp/gangnamdream_style_samples/npc_5_anime_sheet.png`, `/tmp/gangnamdream_style_samples/new_backgrounds_6_anime_sheet.png`로 묶음 검수 완료.
- 스크립트 기반 실제 실행은 현재 환경에 `OPENAI_API_KEY`가 없어 중단됨. 대량 일괄 생성은 미실행.

### 게임 전체 에셋 재감사 및 실사용 보강
- 유저 피드백에 따라 카드/칩 UI 에셋을 재검토. 현재 `HoldemClub.gd`는 카드/칩을 코드로 직접 그리므로 `assets/ui/card_back.png`, `assets/ui/poker_chip_icon.png`는 실사용 에셋이 아님. 실제 홀덤 카드/칩으로 재작업하거나 코드 연결 전까지 보류.
- 주인공 초상화 로직 수정: 시작 나이 33세라는 이유만으로 `main_character_30s`가 초반부터 뜨지 않도록, 아파트/강남 주거 또는 총자산 1억 이상일 때만 중후반 상승 컷 사용.
- 주요 조연 독립 포트레이트 6종 추가: `npc_father`, `npc_mother`, `npc_jaehyuk`, `npc_team_lead`, `npc_goshiwon_owner`, `npc_seongjun`.
- `ImageRegistry` alias 정리: 부모님/재혁/팀장/고시원 원장/성준을 기존 범용 NPC 이미지에서 독립 파일로 연결.
- 실제 JSON 콘텐츠가 직접 참조하는 CG 3종(`ending_father`, `jaehyuk_reveal`, `jiyeon_crash`)을 1280×800 애니풍으로 추가.
- 인게임 스플래시에서 실제 사용되는 `assets/keyart/gangnam_dream_keyart_rooftop.png`를 새 애니풍 rooftop-to-Gangnam 키아트로 교체.
- `main_character_happy` 교정: 폰 화면을 관객에게 보이는 부자연스러운 포즈와 40대처럼 보이는 인상을 제거하고, 33세 김민준에 가까운 자연스러운 고시원 미소 컷으로 교체.
- `jiyeon_crash` 교정: 자전거 두 바퀴가 명확히 보이고, 한지연이 좌핸들 외제 고급 세단(벤츠/포르쉐급)의 앞 운전석에서 내리는 구도로 교체.

### 에셋 QA
- `/tmp/gangnamdream_asset_qa_characters.png`, `/tmp/gangnamdream_asset_qa_backgrounds.png`, `/tmp/gangnamdream_asset_qa_cg_key_ui.png` 검수 시트 생성.
- `docs/ASSET_QA.md` 추가: 통과/재검토/보류/미사용 PNG 후보 목록 정리.
- `ImageRegistry` 누락 파일 0개 확인.
- QA 결론: 추가 대량 생성보다 실제 UI 크롭 검수 후 개별 실패 에셋만 재생성하는 단계로 전환.
- `assets/ui/card_back.png`, `assets/ui/poker_chip_icon.png` 교체: 기존 판타지/메달 느낌을 제거하고 실제 홀덤용 카드 백(256×358)과 투명 포커 칩 아이콘(128×128)으로 재작성. 아직 `HoldemClub.gd`에는 미연결.

## 2026-06-08 (선택지 밸런스 전수 감사 + 수정)

### 190개 이벤트 / 578개 선택지 밸런스 전수 점검
- Python 스크립트로 전 선택지 정규화 점수(5만원=1점, 스탯1=1점) 계산
- 3가지 문제 유형 발굴 및 수정: A. 데이터 오류 / B. 인센티브 역전 / C. 순손해 선택지
- 4차에 걸쳐 총 **95개 선택지** 수정 (life/investment/relationship/hidden 전 파일)

#### A. 데이터 오류 수정 (15건)
- 수면 루틴 잡기 -12만원 → 0원 + 체력/정신/스트레스 개선
- 의사 상담 -15만원 + 지능-5 → -5만원 + 체력/지능 상승
- 술 한 잔 -24만원 → -2만원
- AI 관상 앱 보기 -16만원+투자감각-5 → 0원
- 통계 공부 -21만원 → 0원 + 지능/투자감각 상승
- 인스타 앱 끄기 -17만원 → 0원 등

#### B. 인센티브 역전 수정 (6건)
- "그냥 버틴다"가 수면 이벤트 최선 → 건강/스트레스 손해로 수정
- "서랍에 넣고 잊기"가 건강검진 최선 → 건강 장기 손해 추가
- "도박 머릿속 맴돌기"가 최선 → 중독 수치 추가
- "잘 사는 척 연기"가 동창회 최선 → 스트레스/정신 타격 추가
- "구조조정 무시"가 최선 → 평판 손해 추가
- "사직서 쓰기" stress -15 과도 → -8로 조정

#### C. 순손해 선택지 해소 (42건+)
- "속상해한다", "참는다", "삭인다" 류 모든 선택지에 최소 하나의 전략적 이유 추가
- 예: 깨진 폰 그대로 사용 → 돈 절약 반영, 동창회 거짓말 불참 → 돈 절약+휴식 반영

#### 최종 분포 (교육적 이벤트 제외)
- ✅ 격차 <5 (긴장감 없음): 32개 18%
- 🟢 격차 5-10 (적절한 트레이드오프): 58개 33%
- ⚠️ 격차 10-18 (한쪽이 더 나음): 84개 47%
- ❌ 격차 18+ (지배 전략): 3개 2% (부동산·정치 고위험 이벤트 — 의도된 설계)

## 2026-06-08 (StartMenu 프로필 선택 제거 — 드라마 모드 정리)

### 출발점 선택 UI 완전 제거
- `STARTING_PROFILES` const 삭제 — 드라마 모드는 항상 "백수"(김민준 33세) 고정
- 클래스 변수 `_selected_profile`, `_profile_row`, `_profile_desc_label` 제거
- 함수 `_build_profile_cards()`, `_select_profile()`, `_update_profile_desc()` 삭제
- `_start_new_run()`: `_selected_profile` → `"백수"` 하드코딩
- 이유: 대기업 직장인 선택해도 고시원 시작 + 동일 플레이 — 구색만 갖춘 UI였음

### StartMenu 레이아웃 재구성
- 왼쪽 컬럼: 스토리 패널(gold 좌측 border) + 런 테마 선택 + spacer + 시작 버튼
- 런 테마 헤더에 힌트 문구 추가: "(2회차 이상 추천 — 처음이라면 자유런)"
- 테마 설명 라벨: 3줄(tagline+diff+desc) → 1줄(tagline+diff) compact

## 2026-06-08 (military_040 데이터 오류 수정)

### 군대 선임 연락 이벤트 전체 효과 재설계
- `[0]` 안부만 끊기: money+20000·investment_skill+5 → stress-2·mental+1 (데이터 오류)
- `[1]` 장시간 통화: stress-1 → stress+3·social_skill+1·mental+1 (싫은 통화 스트레스 방향 반전)
- `[2]` 술 약속: investment_skill-1 → social_skill+2·reputation+1·stress+1 (소셜 이벤트에 무관한 투자감각 제거)
- `[3]` 문자만 답장: health-2 → stress-4·mental+1·reputation-1 (건강 손해 제거, 냉담한 인상 추가)
- 트레이드오프 구조: [0](따뜻한 탈출) vs [3](차가운 탈출+reputation-1) vs [2](소셜 투자) vs [1](단기 고통+social gain)

## 2026-06-07 (#8~#13 완료: 스캘핑·런테마·알바·마스터리·퀘스트·칭호)

### #8 주식 스캘핑 아케이드 (완료 ✅)
- `scenes/ScalpingGame.gd` 신규 — 60초 실시간 캔들 차트, BUY/SELL 타이밍 게임
- 판돈 선택(10만~300만), 투자감각↑ = 노이즈↓ + 추세 힌트(감각40+)
- `investment_skill >= 25 and money >= 100k` 조건으로 버튼 노출

### #9 런 테마 선택 (완료 ✅)
- StartMenu에 테마 선택 UI 추가 (4개 카드)
- 자유런(랜덤)/투자런/인맥런/청렴런 — 각각 초기 보너스 + 이벤트 가중치 차등
- 청렴런: `no_gambling` 플래그 → EventManager가 gambling 카테고리 완전 차단
- `GameState.run_theme` 저장, `finish_run()` summary에 포함

### #10 아르바이트 미니게임 (완료 ✅)
- `scenes/ArubaGame.gd` 신규 — 3~4개 상황카드 시프트 게임
- 직업 카테고리별 시나리오 풀 3종 (편의점/배달/일반), 시나리오 총 17개
- 각 선택 → 즉각 피드백 + 수입 변동, 시프트 결산 화면
- 기존 `_ap_side_job()` 완전 교체 (단순 +40만 → 미니게임)

### #11 미니게임 마스터리 트랙 (완료 ✅)
- `MetaProgression.record_minigame_play(game_id)` — 플레이 카운터 + 등급 반환
- 등급 0~3 (5/15/30판): 숙련·고급·마스터
- 홀덤: 마스터리에 따라 AI 공격성 상승 / 경마: 고급2+는 정보상 함정 없음
- 스캘핑: 숙련1+는 힌트 임계치 하향 / 알바: 마스터3은 시나리오 5개
- MainGame 버튼에 마스터리 배지 표시 (★숙련/★★고급/★★★마스터)

### #12 퀘스트 트래커 UI (완료 ✅)
- 인포 패널에 "📖 아크" 탭 추가 (4번째)
- 5개 아크 진행도: 김다은/임상철/강현수/박지연/성향자각 — 체크박스 단계별 표시
- 아크 미발동 시 진입 힌트 표시
- 런 테마·투자감각·사교력·마스터리 등급 한눈에 확인 가능

### #13 칭호/업적 + 메타 진행 강화 (완료 ✅)
- 신규 칭호 8개 추가 (홀덤무법자/경마귀신/스캘퍼/엘리트의길/퀀트마인드/창업가정신/청렴한강남행/서울인맥왕)
- `_check_title_condition()` — 미니게임 플레이수·전문화플래그·런테마+결과 조건
- `finish_run()` summary에 `run_theme`, `tendency_realized` 포함
- 엔딩 화면: 이번 런 새 해금 칭호 목록 표시 + 런 테마·마스터리 요약

---

## 2026-06-07 (시작 직업 다양화 + 다은 결말 + 분기형 스킬 트리)

### #7 지하 홀덤 클럽 (완료 ✅)
- `systems/TexasHoldem.gd` — 순수 수학 모델: 52장 덱, 셔플, 핸드 평가(0~8랭크), 핸드 강도 추정(0-1), AI 행동 결정 (aggression 파라미터)
- `scenes/HoldemClub.gd` — 뷰 레이어: 바이인 선택(5만~50만), 3인 홀덤, 프리플랍→플랍→턴→리버→쇼다운 5단계, 폴드/체크/콜/레이즈/올인 전 액션 지원
- MainGame.gd에 `entered_network` 플래그 확인 후 "지하 홀덤 클럽" 버튼 노출

### #4 시작 직업 다양화 (완료 ✅)
5가지 출발점 선택 UI — StartMenu.gd 프로필 카드 그리드, GameState `_apply_starting_profile()`, MetaProgression `is_starting_profile_unlocked()`.

| 프로필 | 변화 |
|---|---|
| 무직 백수 | 기본 (변화 없음) |
| 편의점 알바 | job_01 시작, 월급 132만, health-8, stress+8, social+5 |
| 대기업 직장인 | job_08 시작, 저축 200만, intel+8, stress+15 |
| 유튜버 지망생 | social+15, appearance+8, luck+8, 월수입 30만 |
| 코인 폐인 (히든) | 1런 이상 완주 후 해금, addiction 30, money 500만, mental-15 |

### #5 김다은 아크 결말 (완료 ✅)
- `arc_daeun_04_morning` — T33+, daeun_chose_her 경로. 새벽 아침 장면. together 단계 진입. 2갈래.
- `arc_daeun_ghost` — T40+, daeun_let_her_go 경로. SNS 목격 에필로그. 2갈래.
- MainGame `_next_arc_id()` 트리거 추가.

### #6 분기형 스킬 트리 (완료 ✅)
성향 자각(tendency_realized) 시점에 1회 전문화 분기 선택:

| 성향 | 선택지 A | 선택지 B |
|---|---|---|
| 직장형 | 엘리트 코스 (spec_elite) | 처세술 전문가 (spec_social_climber) |
| 투자형 | 퀀트형 (spec_quant) | 투기형 (spec_speculator) |
| 창업형 | 기술창업형 (spec_tech_founder) | 소셜창업형 (spec_social_entrepreneur) |

월간 패시브: spec별 3~5턴마다 관련 스탯 +1. `arc_specialization.json` 신규 파일.

---

## 2026-06-07 (중독 시스템 서사 이벤트 + 우선순위 갱신)

### 중독 시스템 — drama_events.json 3개 추가 (항목 3번 완료 ✅)

| 이벤트 ID | 발동 조건 | 핵심 역할 |
|---|---|---|
| `drama_addiction_mirror` | addiction 50~69 | 새벽 거울 앞 자기 직면. 인정/외면 2갈래. |
| `drama_addiction_debt` | addiction 70+ | 통장 확인 후 멈춤/만회/현수전화 3갈래. |
| `drama_addiction_warning` | addiction 65+, 1회성 | 아버지가 눈치채는 장면. told_dad_truth 플래그. |

EventManager.gd (min/max_addiction 조건) + GameState.gd (월간 압박) + drama_events.json 3개 → 중독 시스템 서사 루프 완성.

---

### 우선순위 전체 목록 (리플레이성 항목 반영)

| # | 항목 | 분류 | 상태 |
|---|---|---|---|
| 1 | SimRun 시뮬 검증 | 밸런스 | ✅ 완료 |
| 2 | 아이템 리워크 | 콘텐츠 | ✅ 완료 |
| 3 | 중독 시스템 서사 | 콘텐츠+시스템 | ✅ 완료 |
| **4** | **시작 직업 다양화** | **리플레이성** | ⬜ |
| 5 | 김다은 아크 결말 | 스토리 | ⬜ |
| 6 | 분기형 스킬 트리 | RPG | ⬜ |
| 7 | 지하 홀덤 클럽 | 미니게임 | ⬜ |
| 8 | 주식 스캘핑 아케이드 | 미니게임 | ⬜ |
| **9** | **런 테마 선택 (플레이어 선택)** | **리플레이성** | ⬜ |
| 10 | 아르바이트 미니게임 | 미니게임 | ⬜ |
| **11** | **미니게임 마스터리 트랙** | **리플레이성** | ⬜ |
| 12 | 퀘스트 트래커 UI | UX | ⬜ |
| 13 | 칭호/업적 + 메타 진행 강화 | 폴리시+리플레이성 | ⬜ |

#### 리플레이성 항목 설계 메모

**#4 시작 직업 다양화**
- 5가지 출발점: 無職 백수(기본) / 편의점 알바(월 80만, 시간↓) / 대기업 회사원(월 250만, 스트레스↑) / 유튜버 지망생(social+10, 수입 불안정) / 코인 폐인(히든 해금: addiction 30 시작, 초기 자산 +500만, 이미 구멍 있음)
- StartMenu에 선택 UI, GameState.start_new_game()에 starting_profile 파라미터 추가
- 각 프로필마다 초기 스탯·자금·플래그 다름 → 같은 이벤트가 다르게 느껴짐

**#9 런 테마 선택**
- 기존 run_theme_categories는 랜덤. 이걸 플레이어가 선택하게.
- 청렴 런 / 투자 올인 런 / 인맥왕 런 / 스피드런(40턴 내)
- 선택한 테마가 제약이자 고유 엔딩 조건이 됨

**#11 미니게임 마스터리 트랙**
- 경마: 플레이 횟수에 따라 정보 레이어 해금 (현재도 존재), 명마 라이벌리 심화
- 홀덤(#7): 플레이할수록 상대방 패턴 해금
- 스캘핑(#8): 차트 패턴 인식 스킬 쌓이면 힌트 UI 해금

---

## 2026-06-06 (인물 아크 교차 연결 — 5개 신규 이벤트)

### 작업 내용
인물 아크가 독립적으로 존재하던 문제를 해결. 임상철-한지연-최재혁-현수가 교차하는 영화식 시나리오 구조 추가.

### 신규 이벤트 (arc_events.json: 18 → 23개)

| 이벤트 ID | 발동 조건 | 핵심 역할 |
|---|---|---|
| arc_sangchul_02_coffee | T18+ · sangchul_01_met | 임상철 멘토링 2차, 네트워크 초대 복선 |
| arc_sangchul_03_network | T28+ · 자산 2천만+ | 강남 모임, 한PD건설 이름 첫 등장 |
| arc_sangchul_jiyeon_reveal | T35+ · jiyeon_offer+sangchul_03 | **핵심 교차점**: 임상철이 한PD건설=한지연 가족 연결 |
| arc_jaehyuk_hyunsu_warning | T39+ · pitch · 투자한 경우 | 현수의 경고 — "너무 늦은" 드라마 |
| arc_jiyeon_truth_moment | T44+ · offer+reveal | 한지연이 세 가지 동기 고백 |

### 트리거 업데이트 (scenes/MainGame.gd → _next_arc_id)
- 지연 3구간 뒤에 sangchul_02/03/jiyeon_reveal 삽입
- jaehyuk_03_pitch 뒤, ghost 앞에 hyunsu_warning 삽입
- opp 구간 뒤에 jiyeon_truth 삽입

### 나레이티브 설계 원칙 (준수 여부)
- ✅ "왜 하필 민준에게?" 충족 — 모든 이벤트에 인연 축적 근거
- ✅ 뜬금없는 OP 기회 없음 — 자산 20M 조건, 임상철 소개 조건
- ✅ 선택의 파장 — dismissed_sangchul_warning → jiyeon_truth 에서 다른 무게감

---

## 2026-06-06 (Opportunity EV 밸런스 패치)

### 문제
척추 시뮬 결과: "공격 올인" 경로의 30억 도달률이 57%로 수학적으로 최우선 선택이 됨.
원인: 모든 opportunity의 성공률이 과도하게 높아 평균 EV +63%/회 → 복리로 자산 폭발.

### 수정 내용
- `tools/SimRun.gd`: OPPS 4개 전면 재조정 (평균 EV +63% → ~0%)
- `content/events/arc_events.json`: arc_opp_sangchul_realty, arc_opp_jiyeon_bunyang 성공률 하향
- `content/events/amb_scenarios2.json`: amb_coin_00 (코인 투기) EV -6%로 조정
- `content/events/scenario_cafe_callback.json`: stole_allin/stole_smart/honest_in 전면 재조정

### 수치 결과

| 이벤트 | 수정 전 EV | 수정 후 EV |
|---|---|---|
| arc_opp_jiyeon_bunyang | +130% | +8% |
| cafe_cb_stole_smart | +64% | +8% |
| cafe_cb_stole_allin | +62% | -6% |
| cafe_cb_honest_in | +60% | +6% |
| arc_opp_sangchul_realty (올인) | +57% | +10% |
| amb_coin_00 | +41% | -6% |
| arc_opp_sangchul_realty (소극) | +25% | +4% |

### 설계 원칙
- 도박·투기(코인, 올인): 살짝 음수 EV → 장기적으론 손해지만 운이 좋으면 30억 가능
- 정보 투자(부동산 팁, 검증된 기회): 소폭 양수 EV (+5~+10%) → 보상은 있지만 실패도 아픔
- "좋기만 한 선택지는 없다" 원칙 적용

## 2026-06-01 (죽은 트레이트 시스템 완전 제거)

### 배경
드라마 피벗 때 StartMenu의 트레이트(특성) 선택이 사라지면서 `current_trait`은 항상
"none"(StartMenu) 또는 "흙수저 생존본능"(폴백)으로만 설정됐다. 그런데 패시브 분기는
"야근 면역자/번아웃 생존자/안정 지향형/인맥왕/강남 토박이/강남드림 계승자/리스크 중독자"
같은 **존재하지 않는** 트레이트만 체크 → 모든 트레이트 패시브가 죽은 코드였다.

### 처리 (option A — 완전 제거)
- `autoloads/GameState.gd`: `current_trait` 변수 삭제. `start_new_game()`에서 `selected_trait`
  파라미터 제거(시그니처 단순화). `_apply_trait_bonus()` 함수·호출 삭제. `apply_monthly_pressure()`
  의 `match current_trait` → 기본값으로 단순화(스트레스 +3 / 건강 -2 / 정신 -3). 무직 압박·
  스트레스 극한(80+) 분기도 상수화. `upgrade_housing()`의 "강남 토박이" 이사비 20% 할인 제거.
  `record_run`의 `trait` 필드 → `""`. `serialize()`에서 `current_trait` 제거.
- `autoloads/MetaProgression.gd`: `get_unlocked_traits()`·`get_trait_bonus()`·`unlock_trait()`
  삭제. `_check_progression_unlocks()`의 `unlock_trait(...)` 호출 7개 제거(업적 해금은 유지).
  `_new_this_run`에서 `"traits"` 키 제거.
- `autoloads/DataRegistry.gd`: `TRAITS_PATH`·`traits`·`traits_by_id` 및 로딩 제거.
- `systems/InvestmentSystem.gd`: 매수 수수료 "강남드림 계승자" 할인, 매도 "리스크 중독자"
  ×1.15 증폭 제거.
- `scenes/MainGame.gd`: 스탯 패널 트레이트 라벨 제거(배경만 표시). 엔딩 화면 "트레이트 해금"
  표시 제거(업적 해금은 유지).
- `scenes/StartMenu.gd`: `start_new_game()` 호출에서 트레이트 인자 제거.
- `content/meta/traits.json` 삭제. `default_meta.json`에서 `unlocked_traits` 제거.

### 대체
캐릭터성은 성향(직장/투자/창업) 자각 시스템(`tendency`)이 담당. 행동 누적 → 임계점에서
자각 → 1회 패시브 보상. 트레이트처럼 "선택"이 아니라 "행동"이 정체성을 만든다.

### 검증
`./tools/audit.sh` 통과 (ERROR 0 / WARNING 0, Godot 헤드리스 파싱 깨끗).

## 2026-05-27 (엔딩 배경 전환 + CLAUDE.md 정리)

### 엔딩 화면 배경 전환 (`scenes/MainGame.gd`)
- `_show_ending()` 최상단에 엔딩 ID → 배경 매핑 테이블 추가 (13개 엔딩 전부 커버)
- S급/성공 엔딩: `BG_PENTHOUSE` (penthouse_view.png)
- 정치/명성: `BG_GANGNAM_NIGHT`, 건강은퇴: `BG_ROOFTOP_DAY`
- 번아웃/정신붕괴: `BG_BURNOUT` (burnout_hospital_room.png)
- 배경 불투명도 0.25 → 0.35 (엔딩 화면에서 더 선명하게)
- BG_PENTHOUSE, BG_BURNOUT 상수가 처음으로 실제 사용됨

### CLAUDE.md 미구현 목록 정리
- 기존 TODO 6개 → 전부 ✅ 완료 표시
- 남은 항목: QA 플레이스루, Export 패키징, 스토어 소재 (로컬 Godot 필요)

## 2026-05-27 (이미지 에셋 연동 완료)

### Codex 생성 이미지 9종 + 캐릭터 포트레이트 연동
- `assets/backgrounds/` 신규 8종: convenience_store_night, cafe_seoul, investment_phone,
  hospital_corridor, rooftop_daytime, gangnam_night_street, penthouse_view, burnout_hospital_room
- `assets/characters/main_character_shocked.png` 추가
- `icon.png` (Godot 프로젝트 아이콘) 교체
- 총 19개 에셋 경로 검증 완료 (누락 0)

### `scenes/MainGame.gd` — 이미지 연동 코드 완성
- `_get_bg_for_event()` 태그 매핑 6개 신규 추가:
  - `hospital/health` → `BG_HOSPITAL`
  - `convenience` / `night+food` → `BG_CONVENIENCE`
  - `investment` / `finance+stock` → `BG_INVESTMENT`
  - `social/date/cafe/relationship/romance` → `BG_CAFE`
  - `rooftop/break` → `BG_ROOFTOP_DAY`
  - `politics / reputation+late_game` → `BG_GANGNAM_NIGHT`
- `_get_portrait_path()` — `PORTRAIT_SHOCKED` 연결 (`just_critical_event` 플래그)
- `_choose()` — 충격 이벤트 감지: 건강·정신 -15이상 / 돈 -100만이상 시 1.2초간 shocked 포트레이트 표시

## 2026-05-27 (한국어 톤 패스 — hidden_events.json)

### hidden_events.json 20개 전면 패치
- 타이틀 접두사 제거: "비밀 이벤트: [제목]" → "[제목]" (20개)
- description 19개 플레이스홀더 교체 (기존: "서울의 속도는 멈추지 않고..." 반복구)
  - 각 이벤트 상황에 맞는 개별 장면 묘사로 교체
  - 새벽 가슴 두근거림, 군대 선임 연락, 폰 파손, 퇴사 브이로그, 건강검진 결과,
    병무청 우편, 팀장님 한마디, 강남역 도믿맨, 인스타 비교 지옥, 친구 투자 자랑 등
- 중복 타이틀 구분: hidden_011 "또 폰이 박살났다", hidden_014 "또 카드값 폭탄"으로 분리
- investment_events.json / relationship_events.json: 이미 개별 묘사 완료 확인 (패치 불필요)

## 2026-05-27 (특수 엔딩 트리거 구현)

### 엔딩 발동 조건 전면 재정비 (`GameState.gd`)
- `investment_master` 스킬 조건 85 → **75** (기존 값은 사실상 도달 불가)
- `stable_success` / `lonely_rich` 자산 기준 1B → **800M** (달성 가능 범위 조정)
- `healthy_retirement` 최소 자산 5,000만 조건 추가 (건강만 좋고 파산 직전인 케이스 차단)
- `political_fix` 조건 정비: age 65 fallback → **자산 1억+ AND 플래그** 로 격상, 순서 최우선으로 이동
- 모든 age 65 분기에 `return` 명시 추가 (이전엔 elif 체인이라 fall-through 버그 가능)

### 특수 엔딩 도달 경로 신규 구현

#### 스타트업 엑싯 경로 (`life_events.json` 이벤트 2개)
- `startup_opportunity` — 스타트업 공동창업 제안
  - 조건: 자금 500만+, 투자감각 35+, 평판 30+, Turn 12+
  - 수락 시 300만원 투입 + `startup_founded` 플래그 세팅
- `startup_acquisition_offer` — M&A 인수 제안 (4억원)
  - 조건: `startup_founded` 플래그, Turn 24+
  - 수락 시 +4억 + `startup_exit` 플래그 → 즉시 `startup_exit` 엔딩 발동

#### 정치인 경로 (`life_events.json` 이벤트 2개)
- `political_recruitment` — 정치권 영입 제안 (보좌관)
  - 조건: 평판 55+, 사회성 40+, Turn 18+
  - 수락 시 `political_candidate` 플래그 세팅
- `political_election_victory` — 선거 당선
  - 조건: `political_candidate` 플래그, 평판 70+, Turn 30+
  - 수락 시 -1,000만원 + `political_winner` 플래그 → 65세에 `political_fix` 엔딩

#### 코인 망령 경로 (`investment_events.json` 6개 선택지)
- `gambling_002` 레버리지 풀베팅 → `addiction_tendency` +15
- `gambling_007` 소액 질러보기 / 링크 클릭 → +10 / +8
- `gambling_020` 전 재산 몰아넣기 / 흔들림 → +25 / +5
- `inv_crypto_mania` 소액 참여 → +8
- `addiction_tendency` 90 도달 시 `crypto_ghost` 엔딩 발동

## 2026-05-27 (스플래시 화면 추가)

### 타이틀 스플래시 씬 신규 구현
- `scenes/SplashScreen.gd` / `SplashScreen.tscn` 신규 생성
- `project.godot` 메인씬: `StartMenu.tscn` → `SplashScreen.tscn`
- 연출 시퀀스 (총 ~4.5초):
  1. 검정 → 페이드인 (SceneTransition)
  2. 옥상 키아트 배경 서서히 등장 (38% 불투명)
  3. 로고 이미지 페이드인
  4. "강남드림" 한글 타이틀 (64px)
  5. "GANGNAM DREAM" 영문 부제 + 구분선
  6. "서울에서 살아남아라" 태그라인
  7. "― 2030년대 서울, 당신의 이야기 ―" 컨텍스트
  8. "아무 키나 눌러 계속" 힌트 (깜빡임 3회)
  9. 자동 전환 / 키·마우스 클릭으로 스킵

## 2026-05-27 (UI 대시보드 개선 — 바이탈 HUD + 진행 바)

### 탑바 바이탈 HUD 추가 (Football Manager 스타일)
- `_build_top_bar()`: AP 레이블 우측에 `vitals_row` HBoxContainer 삽입
  - `vital_health` (❤ + 숫자 + 6칸 블록바), `vital_mental` (🧠), `vital_stress` (😤)
  - 세퍼레이터 `│` 로 AP / 바이탈 / 머니 시각적 구분
  - 건강/정신: 30↓ 빨강, 50↓ 노랑, 정상 초록/파랑
  - 스트레스: 80↑ 빨강, 60↑ 노랑, 정상 민트
- `_refresh_vitals()` 신규 메서드: `_refresh_all()` 호출 시 바이탈 갱신
- `_bar_str(value, max_val, bars)` 신규 헬퍼: `"█".repeat(filled) + "░".repeat(empty)` 블록 진행 바 생성

### 스탯 패널 진행 바 표시
- `_set_stat_value()`: 건강/정신/스트레스 항목에 10칸 블록 진행 바 추가 (`63  ██████░░░░`)
- 기타 스탯(지력, 사회성 등)은 기존 숫자 표시 유지

## 2026-05-27 (Polish Beta — 투자 차트 히스토리 + 한국어 톤 패스)

### 투자 차트 히스토리 시각화
- `MainGame._open_investments()`:
  - 포트폴리오 보유 시 전체 수익률 요약 헤더 추가 (원금 → 현재가치, 수익률 %)
  - 자산별 2줄 표시: ①자산명·리스크·현재가 ②스파크라인 + 1개월/3개월/12개월 변동률
- `MainGame._render_sidebars()` 시황 티커: 6개월 미니 스파크라인 추가

### 한국어 톤 패스
- `life_events.json` 플레이스홀더 설명 35개 → **전부 제거** (0개 남음)
  - 교체 대상: family, social_life, politics, gambling, military, health, disasters, comedy, finance, romance 카테고리 전반
  - 톤: 2030 서울 청년의 자조적·관찰적 시선. 과장 없이 담백한 일상 문장

## 2026-05-27 (Polish Beta — 관계/직업/엔딩 3종 개선)

### 관계 패널 능동 상호작용
- `MainGame.gd`: `_ap_network()` → `_ap_socialize()` + `_open_relationship_manager()` 모달로 교체
  - 관계 유형별 전용 행동: 친구=커피, 연인=데이트(친밀도 60+ 기준), 멘토=조언/근황보고(신뢰 50+ 기준), 비즈니스=파트너 미팅, 가족=통화
  - "새 인연 만들기" 선택지: 사회성 +3, 50% 확률 인연 생성 (이름 풀 16개)
  - 각 행동 후 turn_action_log, add_log, toast 피드백 연동

### 직업별 이벤트 조건 강화
- `EventManager.gd`: `min_job_tier`, `max_job_tier`, `job_category` 조건 추가
- `life_events.json`: 12개 이벤트 조건 패치
  - 직업 없이 뜨던 이벤트 5개에 `has_job: true` 추가 (첫 회식, 업무 카톡, 연차, 피드백, 험담)
  - 이직/퇴사 이벤트 3개: `has_job: true` + 설명 교체 (플레이스홀더 제거)
  - 야근/성과/프로젝트 이벤트 3개: `min_job_tier: 2` 추가 (T2+ 직장에서만)

### 엔딩 화면 메타 진행도 표시
- `MetaProgression.gd`: `_new_this_run` 딕셔너리 추가, `record_run()` 시작 시 초기화
  `unlock_trait()` / `unlock_achievement()` 호출 시 신규 해금이면 목록에 추가
  `get_new_unlocks()` 메서드 추가
- `MainGame.gd `_show_ending()`: 새 해금 트레이트/업적 표시 (🔓 섹션, 업적 ID→한글명 매핑)

## 2026-05-27 (밸런스 패스 — 초반 생존성 개선)

### 수치 조정
- **고시원 월세**: 800,000원 → **650,000원** — 설계 기준(CLAUDE.md) 불일치 수정. 신규 플레이어가 Turn 2에 현금위기(-30만)로 즉시 패닉하던 문제 해소. 1개월 여유 버퍼 확보.
- **무직 스트레스 이중계산 제거**: `JobSystem.process_monthly_job()` 무직 시 +2 스트레스 제거. `apply_monthly_pressure()`에서 이미 +6/월 처리 중. 총 무직 스트레스 +8 → **+6/월**으로 정상화.
- **T3 직업 스트레스 곡선**: 공공기관 계약직(+2→+3), 부동산 중개보조(+3→+4). T3 직업이 T1 직업과 동일한 스트레스를 가지면서 월급은 훨씬 높던 우열 구도 해소.

### 분석 내용
- 15개 직업 전체 스트레스·급여 커브 검토
- `InvestmentSystem.gd` 수익 구조 분석: drift +0.3%/월, 크래시 확률 및 위험도 밸런스 적절 — 조정 불필요
- `assets.json` 18개 자산 변동성·최소 투자금 검토 — 현행 유지

## 2026-05-27 (이벤트 확충 — Content Alpha 달성)

### 콘텐츠 추가
- 투자 이벤트 14 → **30개** (+16): 리밸런싱, 단톡방 주식 정보, 시장 폭락 경보, 배당금 입금, 손절 결정, 공모주 청약, ETF 공부, 부동산 버블 공포, 경기침체 우려, 투자 서적, 선배 내부 정보, 금융소득 과세, 적립식 투자, 코인 광풍, 해외 주식, 1년 수익률 점검
- 관계 이벤트 15 → **30개** (+15): 멘토 커피, 동료 갈등, 소개팅, 친구 이별 위로, 부모님 상경, 전 연인 연락, 사무실 뒷담화, 썸 진전, 사업 파트너 제안, SNS 비교, 멘토 쓴소리, 가족 대출 부탁, 팀 회식, 네트워킹 세미나, 새벽 통화

### 품질 개선
- 기존 투자 14개 + 관계 15개 설명 전면 개선: 동일한 플레이스홀더 텍스트를 이벤트별 개별 장면 묘사로 교체

### Content Alpha 달성 현황
| 콘텐츠 | 목표 | 현재 | 상태 |
|--------|------|------|------|
| 일반 생활 이벤트 | 100개+ | 106개 | ✅ |
| 투자 이벤트 | 30개 | 30개 | ✅ |
| 관계 이벤트 | 30개 | 30개 | ✅ |
| 히든 이벤트 | 20개 | 20개 | ✅ |
| 직업 | 15개 | 15개 | ✅ |
| 아이템 | 30개 | 30개 | ✅ |
| 엔딩 | 10개 | 14개 | ✅ |

## 2026-05-27 (첫 30분 몰입도 개선)

### 버그 수정 (Critical)
- `story_arrival_elite`, `story_arrival_rich` → `follow_up_event: "story_pressure"` 누락 수정.
  명문대/금수저 배경에서 구직 해금(`story_job_unlocked`)이 永久 잠겼던 문제.
- `story_first_workday`, `story_first_paycheck_feel`, `story_first_savings_milestone`, `story_six_months`, `story_one_year` → `seen` 플래그 누락 수정.
  매 턴 무한 반복 트리거 방지 (`flags: ["...seen"]` 형식으로 통일).
- story 이벤트가 random pool에 노출되지 않도록 `conditions: {min_turn: 9999}` 추가.

### 신규 콘텐츠
- `first_job_rejection` (life_events.json): 구직 해금 후 무직 상태 단발 이벤트. 첫 취업 전 긴장감 서사 추가.
- `convenience_midnight_snack` (life_events.json): 자정 편의점 도시락 딜레마. 초반 6개월 이내 한정.
- `small_unexpected_win` (life_events.json): 5만원 발견 행운 이벤트. luck≥40, 초반 한정.

### 튜토리얼/UX 개선
- `MainGame.gd`: `tutorial_step >= 3` 조건 추가 — Turn 1 액션 단계에서 "서울 첫 달!" 힌트 표시.
- `MainGame.gd`: 첫 취업 시 🎉 특별 토스트 피드백 (housing_up SFX + 초록 강조색). 이직 시 기존 노란 토스트 유지.

### 라이벌 시스템
- `RivalSystem.gd`: Turn 2에 라이벌 첫 소개 메시지 자동 표시. 이름·나이·출발선 공개, 경쟁 의식 조기 형성.

## 2026-05-16 (Meta-Progression First Pass)

### 기능 구현
- `content/meta/traits.json` 신규 생성 — 5종 트레이트 정의 (id, unlock 조건, description, bonus).
- `DataRegistry.gd` — `TRAITS_PATH` 상수, `traits` 배열 및 `traits_by_id` 딕셔너리 추가. `reload()`에 로드 로직 포함.
- `MetaProgression.gd`:
  - `get_trait_bonus()` — `data["trait_bonuses"]` 딕셔너리 하드코딩 방식 → `DataRegistry.traits` 룩업으로 교체.
  - `_check_progression_unlocks()` — 엔딩 기반 언락 추가: `stable_success`/`ordinary_life` → 안정 지향형, `gangnam_dream` → 강남드림 계승자.
- `StartMenu.gd` — `trait_desc_label` 추가. 트레이트 선택 시 `_on_trait_selected()` 콜백으로 설명 + 보너스 요약 실시간 표시.

## 2026-05-16 (Init)
- Standardized project management around an independent GitHub Desktop repository.
- Published the Godot project to GitHub.
- Added documentation structure for future requirements, roadmap, decisions, and release notes.

## 2026-05-16 (Prototype Improvement Pass)

### 버그 수정
- `GameState.check_game_over()` 엔딩 ID 불일치 수정 (`health_collapse` 등 → `burnout` 등).
- 65세 도달 시 자산 기준으로 `stable_success` / `ordinary_life` 분기 추가.
- `_set_stat_value()` warn/danger 파라미터 순서 역전 버그 수정 (건강/정신력 색상 기준 정상화).

### UI 개선 (MainGame.gd)
- 모달 `ScrollContainer` 추가.
- 모달 타이틀 + X 닫기 버튼 구조로 개편.
- 메인메뉴 복귀 버튼 추가 (자동저장 후 이동).
- 인벤토리 "사용" 버튼 추가 → `InventorySystem.use_item()` 연결.
- 투자 모달: 매수 금액 선택(10만/50만/100만), 분할 매도(25%/50%/전량), 수익률 표시.
- 시장 티커: 전달 대비 등락률(%) + 리스크 점 표시.
- 로그 BBCode 활성화, 타입별 색상 구분.
- 스탯 패널 색상 경고 (건강/정신력/스트레스).
- 이벤트 선택 후 `result_text` 결과 화면 추가.
- 엔딩 화면: 등급 색상, 새 런 / 메뉴 버튼 추가.
- 뉴스 루머 표시 (`[루머]` 접두사).
- 관계 패널 한국어 유형 표기, 친밀도 레이블.

### 콘텐츠 교체
- `items.json` 30개 플레이스홀더 → 실제 한국 생활 아이템.
- `jobs.json` 15개 설명 교체, 카테고리 정정.
- `endings.json` 10개 설명 전면 교체.
- 이벤트 `result_text` 584개 전체 생성.

### 문서화
- `CLAUDE.md` 생성 (Codex 세션 컨텍스트).
- `docs/` 전체 오늘 세션 반영.

## 2026-05-16 (QA & Toast Integration)

### 버그 수정
- `EndingSystem.evaluate_current_ending()` 엔딩 ID 불일치 수정 — `health_collapse` → `burnout`, `mental_burnout` → `mental_break`, `debt_spiral` → `bankruptcy`, `ordinary_retirement` → `ordinary_life`, `upper_middle` → `stable_success`. (`GameState.check_game_over()`는 이전 패스에서 수정됐으나 이 함수는 누락됐었음.)

### UI 개선
- `NotificationToast` 연결 완료 — `MainGame.gd`에 `_toast_container` 및 `_show_toast()` 추가.
- 저장, 직업 변경, 매수, 매도, 아이템 구매/사용 시 토스트 피드백 표시.

## 2026-05-16 (Appearance Stat Implementation)

### 기능 구현
- `appearance` 스탯 효과 전면 구현.
  - **UI**: 스탯 패널에 `외모` 항목 추가 (기존에 저장만 되고 미표시였음).
  - **직업 요건**: `유튜브 크리에이터`(min 55), `보험 영업직`(min 48), `외국계 세일즈`(min 52)에 `min_appearance` 요건 추가.
  - **JobSystem**: `_check_requirements()`에 `min_appearance` 케이스 추가.
  - **RelationshipSystem**: 외모 60 이상일 때 연애 관계(`romantic`) 호감도 월간 감소 차단.

## 2026-05-16 (Save/Load Validation)

### 버그 수정
- `GameState.load_from_dict()` — JSON 역직렬화 시 int 필드가 float으로 복원되는 버그 수정. `age`, `health`, `mental` 등 14개 필드에 명시적 `int()` 변환 추가. (미수정 시 UI에 `"50.0"` 등으로 표시됨)
- `SaveManager.load_game()` — 저장 파일 버전 불일치 시 경고 없이 로드하던 문제 수정. `push_warning()` 추가 및 미래 마이그레이션 훅 위치 확보.
- `SaveManager.save_game()` — `action_log`/`news_log`/`event_log` 무한 증가 방지. 각각 최근 100/60/100개로 캡 적용.


## 2026-06-08 (UI 대수술 + 버그 수정)

### RaceTrack / HoldemClub 버그 수정
- `RaceTrack.gd`: `Color("#0a0d12", 0.75 if ...)` → `Color()` 후 `.a` 별도 대입 (GDScript 불안정 생성자 우회)
- `HoldemClub.gd`: bg ColorRect alpha 0.8 고정 → 이미지 없으면 1.0 (불투명)으로 수정
- 두 오버레이 모두 `mouse_filter = MOUSE_FILTER_IGNORE` 명시

### 목표 진행바 추가
- `_build_goal_bar(parent)` — 상단 바 아래 24px 얇은 바
- 현재 자산 / 30억 달성률 실시간 표시 (0.01% 단위)
- 진행도 색상: 파랑(초반) → 녹색 → 금색 → 주황(60%+)
- 잔여 시간 1년 이하면 % 색상 경고

### 첫 런 튜토리얼 모달
- `_maybe_show_tutorial()` — `GameState.flags["tutorial_shown"]` 1회 체크
- 첫 AP 화면 진입 시 자동 표시 (프롤로그 이후)
- 목표/진행방식/주의사항/첫 달 추천 4섹션

### 월별 추천 행동 표시
- `_recommend_action()` — 상태 기반 이번 달 최우선 행동 제안
- 경고 없을 때 `event_body` 마지막에 "💡 이번 달 추천" 표시
- 상태 우선순위: 무직 → 스트레스 높음 → 첫 월급 전 → 투자 가능 → 자기계발

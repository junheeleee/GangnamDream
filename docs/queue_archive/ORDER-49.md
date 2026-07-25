# Active Queue Spec: ORDER-49

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. 근거 원장은
> [`docs/SCRIPT_REVIEW_2026-07-24.md`](../SCRIPT_REVIEW_2026-07-24.md).
> ⚠ 이 오더는 **밸런스 밴드·설계 판단**을 건드린다 — 착수 전 유저/활성 오더 근거 필요
> (`docs/CODEX_QUEUE.md` 운영 프로토콜: 밸런스 밴드 밖 수치·정본 규칙 변경은 사전 승인).

#### [x] ORDER-49 [P2·설계/밸런스] 선택의 고민 장부화 — 유혹·사랑이 수치에도 존재하게

> **착수 2026-07-26 — 만지는 파일:** `autoloads/GameState.gd`,
> `scenes/MainGame.gd`, `content/events/arc_daeun_married.json`,
> `content/events_en/arc_daeun_married.json`, `content/events/arc_drama.json`,
> `content/events_en/arc_drama.json`, `content/events/callback_events.json`,
> `content/events_en/callback_events.json`, `content/endings.json`,
> `content/endings_en.json`, `tools/peak_scene_chain_audit.py`,
> `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-49.md`, `CLAUDE.md`,
> `docs/WORK_LOG.md`.
>
> 이번 착수는 활성 오더가 선제 허용한 **무수치 산문 정렬과 기존 인과 배선**만
> 수행한다. 결혼 비용·재혁 판돈 등 수치 재배치는 외부 망설임 표본과 별도 승인 전까지
> 변경하지 않는다.

## 진단 (전 게임 최대 약점)

각본 리뷰 7기준에서 **"선택의 고민"이 전 스레드 최저**(다은 2/5, 랜덤풀 2/5). 산문은
딜레마를 잘 세우지만 **수치가 거의 항상 정직·사랑 경로의 상위호환**이라 고민이 성립하지
않는다. 데모 스크리닝의 R1(태도 선택 문제)과 동일 축이 전체 게임에서 재확인됐다.

**중요:** 이 오더는 P0가 아니다. 수치 재배치는 밸런스·엔딩 분포를 흔들 수 있고, 일부는
"산문에서 기계적 이득 주장을 걷어내는" 무수치 대안이 있다. **외부 정상 독해 표본의
'어느 선택에서 실제로 망설였는가' 데이터와 합쳐서** 판정하는 것이 옳다. 표본 전에는
③산문 정렬(무수치)만 먼저 하고, ①②수치 변경은 유저 승인 후.

## 항목

### A. 다은 돈vs사랑 딜레마 무력화 — 산문 우선, 수치는 승인 후
1. **`arc_daeun_final_choice_decision`** — 배신 선택 "서명한다. 강남이 한 걸음 앞이다"의
   effects에 돈·자산 이득이 0(mental-15·tint-12뿐). **[무수치 기본]** 산문에서 "강남이
   한 걸음 앞" 류 기계적 이득 주장을 걷어내 순수 서사적 유혹으로 남김. **[수치 옵션·승인
   필요]** 서명에 산문이 주장하는 실제 자산 효과 연결(BALANCE.md 밴드 재검).
2. **`arc_daeun_wedding_prep`** — 작은 결혼식(-800만·mental+10·aff+12)이 풀패키지
   (-3100만·mental-4·aff+2)를 완전 지배. `the_test` 거절도 비용 0. 두 선택이 실제 트레이드가
   되도록 수치 재조정(승인 필요) 또는 산문에서 우열 단정 제거.
3. **`arc_daeun_the_test` 상실 회랑** — 배신 후 이혼이 자산 18억~30억 창에서만 발동
   (30억 조기 달성 시 daeun_married→gangnam_dream 진엔딩, 18억 미달 시 무발동). 게이트
   상·하한 완화 또는 `used_daeun_as_means`를 finish_run 캐스케이드/기존 이별·에코 조건에
   연결(정본 ⑥ 결혼 상실 규칙 집행). **배선 우선, 신규 불요.**
4. **`arc_daeun_05_uncertain` 이별 변주 고아** — `daeun_let_drift`/`daeun_breakup_begged`가
   year3_apart 조건에 안 걸려 다은이 서사에서 무단 증발. year3_apart 조건에 두 플래그 추가
   (배선만, 기존 산문이 회수).

### B. 재혁 유혹의 장부 반영 — 산문 우선
5. **`arc_jaehyuk_03_pitch`** — 판돈 -300만 고정이라 2년차 "가진 거의 전부"가 거짓,
   crossed_line 보상(500~800만)이 30억 대비 토큰. **[무수치]** "가진 거의 전부" 단정을
   비율 중립 서술로. **[수치 옵션]** 판돈을 자산 비례로(밴드 재검, 승인 필요).
6. **`arc_jaehyuk_mirror_decision` — vouched_jaehyuk_guarantee 후폭풍 0** — 보증 서명
   (아버지 파멸 모티프 재연)에 mirror 재발화 방지 게이트 외 독자가 전무. 기존 협박 콜백
   조건이나 aftermath crossed_line 선택지에 이 플래그를 연결하고 엔딩 dik에 키 추가해
   기존 문장으로 회수(플래그 연결만).

### C. 상철 공정 추리 강화 — 배선 우선
7. **`arc_sangchul_deduction` 사전 단서 부재** — 결정적 전제 "빚 뒤에 소개인이 있었다"가
   추론 씬 전에 0회 노출. `arc_father_06`의 트리거 하한을 추론 창(t104) 이전으로 재배치
   하거나 `arc_father_06`에도 `clue_father_broker`를 지급해 아버지 고백 루트에서도
   `thought_whole_picture`가 완성되게 연결. (상철 진실 증발 자체는 ORDER-44 항목10에서 처리.)

## 검증

- 수치 변경분 전부 `docs/BALANCE.md` 밴드 기록 + `python3 tools/balance_sim.py`·
  `tools/convergence_sim.py`로 5아키타입 자산·엔딩·tint 분포 재검(발산 유지 확인).
- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과", `en_coverage_check.py`.
- **판정 경계:** 이 오더의 GO는 자동 게이트가 아니라 외부 표본의 망설임 데이터 + 유저
  승인이다. 산문 정렬분(무수치)만 선제 착수 가능.

## 완료 보고 (2026-07-26)

- 다은 최종 배신 선택의 허위 자산 이득 문구를 제거하고, 결혼 준비 두 경로는
  수치 우열을 정답처럼 설명하지 않도록 각각 가족 사진의 실제 기억과 줄어든 하객
  관계의 상처를 함께 남겼다. 결혼 비용·정신력·호감도 수치는 변경하지 않았다.
- `daeun_married + used_daeun_as_means` 상태에서는 30억에 먼저 도달해도 다은 최종
  대면을 건너뛰지 않는다. 기존 이혼·잔류 선택 뒤에만 엔딩 캐스케이드가 다시 열린다.
  이 계약은 실제 `game_over` 신호 회귀 검사로 고정했다.
- `daeun_let_drift`와 `daeun_breakup_begged`를 3년차 이별 후 회수에 연결했고,
  재혁의 300만원 판돈을 “거의 전부”라 부르던 허위 스케일을 한영에서 제거했다.
- 재혁 보증 서명은 기존 `jaehyuk_exploited` 후폭풍과 `jaehyuk_way` 엔딩 기억이
  실제로 읽는다. 아버지의 소개인 고백은 t102부터 열려 t104 상철 추리보다 먼저
  단서를 줄 수 있다.
- 단일 선택 연결 장면을 화면 QA가 다음 사건까지 과진행하던 검사기 결함도 함께
  수리했다. 요청 이벤트 ID와 실제 열린 이벤트 ID가 다르면 즉시 실패한다.
- 한국어·영어 결별 56면과 약혼·결혼 76면을 1280×800에서 렌더했고,
  정점 체인 32개, 대표 아크 2경로, 엔딩 35종 구분성·12개 실제 라우팅,
  밸런스·전략 발산, 한영 1,565개, Godot 54개 스크립트를 포함한 전체 감사가
  `✅ 감사 통과`로 끝났다.

### 수치 재배치 판정

현재 자동 지표와 서사 배선만으로는 결혼 비용·재혁 판돈의 추가 수치 변경 근거가
부족하다. 따라서 이 오더는 **무수치 대안으로 완료**한다. 외부 정상 독해 표본에서
해당 선택이 여전히 전혀 망설여지지 않는다는 증거가 생길 때만 별도 밸런스 오더로
재개하며, 그 전에는 안정된 경제 밴드를 추측으로 흔들지 않는다.

# CODEX_QUEUE.md — Codex 작업 대기열·실행 스펙 (2026-07-07 Claude 작성)

> **Codex 세션 시작 시 이 파일을 CLAUDE.md 직후에 읽는다.** 위에서부터 우선순위순.
> 전략 맥락: Steam "압도적으로 긍정적"이 목표 지표, 5레버는 `CLAUDE.md` 현재 상태 참조.
> 신규 정본 선독: `docs/DECISIONS.md` 2026-07-07 5건(Godot 네이티브 완성 / 외부 파이프라인 / 설교 방지 5원칙 / AP 축 / EN 표기).
> **앵커 주의**: 아래 파일:라인은 2026-07-07 HEAD 기준 — 라인은 ±30 오차 허용, 함수명으로 찾을 것.

---

## 병합 프로토콜 (필독 — 이중 구현 사고 방지)

- 2026-07-07 `claude/game-polish-steam-uh6ldg`에서 **큰 병합**: Codex act-rail·축 표면과 Claude 축 엔진 정합 통합(카운터 `action_axis_this_week` dict 단일화, 등록은 각 `_ap_*` 함수 내부 1회, 드립 캡 -20, 인맥/VIP=돈축). **main으로 가져갈 때 이 정합을 되돌리지 말 것.**
- Claude 브랜치의 신규 대형 기능: 몽타주 시간 압축, H2 데드존 비트 9종(계단식 턴 게이트), 플래시포워드 콜드오픈, 시간의 기록(연락 원장), 문서 아카이브 21종 이동.
- 설계 문서의 "구현 예정" 항목은 **담당 명시** 확인, 없으면 WORK_LOG로 중복 여부 확인 후 착수.

## 표면 용어 원칙 (2026-07-07 사고 사례)

- 내부 시스템 용어(자유런/현실 모드/런/몽타주/tint/moral/축/axis)는 **플레이어 화면 노출 금지**.
- "없는 것을 해명하는 문구" 금지("고르는 설정은 없다"류 삭제 대상).
- 모든 신규 카피는 **설교 방지 5원칙**(DECISIONS) 검수 통과 — 서술자 판단 금지 / 어둠의 문장 품질 / 대가 대칭 / 기록>지시 / 진짜 유혹.

## 공통 함정 (전 항목)

- 유저 표면 문자열은 `_tr(kr,en)` 필수 — 한글 리터럴이 `_tr` 밖이면 `english_hangul_audit.py`가 감사를 실패시킨다. 어순 다르면 `.format({"p": x})` 네임드 플레이스홀더.
- 새 GameState var는 serialize() 또는 `tools/audit.py` SERIALIZE_EXEMPT(~381행) 등록.
- MainGame은 StoryMode 다녀오면 **재생성**된다 — 인스턴스 변수로 턴 상태 추적 불가, GameState 경유(주석 MainGame.gd ~1935 근처 참고).
- 이벤트 JSON 루트에 새 키를 넣으면 `tools/audit.py` `EVENT_ROOT_KEYS`(410행) 화이트리스트에 먼저 추가해야 감사 통과.
- UI 노드에 `moral_role` 메타를 달면 moral 팔레트가 색을 관리한다 — `_moral_ui_palette()`(MainGame.gd:480, moral 틴트 반영 dict). 하드코딩 색보다 이 문법 우선.
- 공용 헬퍼(실증): `_open_modal(title, cancelable, kind)` MainGame.gd:10102(모달 초기화, 기본 760×610) / `_label(text,size,color)` 12073(NO랩·클립) / `_wrap_label` 12084(워드랩+EXPAND) / `_essential_btn(title,subtitle,icon_id,accent,fn,disabled,...)` 5866(레일 카드+`_run_ap_action_from_button` 배선).

---

## 🎖 운영 프로토콜 v2 (2026-07-13 유저 지시 — Claude=지휘·판정 / Codex=실행 전부)

> 유저 결정: Codex 토큰은 상시 가용, Claude 토큰은 희소. **Claude는 오더 발행·diff/카피 판정·병합 정합·정본 수호만** 하고,
> 구현·산문·QA·이미지·번역·리서치·반복 작업은 전부 Codex가 수행한다.

**루프**: ①Claude가 아래 "활성 오더"에 스펙 발행 → ②Codex가 위에서부터 실행, 완료 시 `[x]`+보고 단락+WORK_LOG 기록+main 커밋 → ③Claude가 다음 세션에서 diff 감사·카피 스팟체크로 판정(불합격=REWORK 오더) → ④상태 블록 갱신.
**착수 선언 (2026-07-13 추가)**: Codex는 오더/큐 항목에 **착수하는 순간** 해당 항목을 `[~] 착수 — 만지는 파일: <목록>`으로 바꾸는 선언 커밋을 먼저 푸시한다(작업 커밋과 분리). 완료 시 `[x]`+보고로 전환. 이 마킹이 실시간 작업판이다 — Claude는 `[~]` 항목의 파일을 건드리지 않고, Codex는 선언 없이 큰 작업을 시작하지 않는다.
**Codex 사전 승인 대기 항목**(오더 없이 착수 금지): 정본 규칙 변경 / finish_run·엔딩 라우팅 / 밸런스 밴드 밖 수치 / 오더에 없는 신규 시스템. 그 외(표면·아트·QA·기존 큐 항목)는 기존처럼 자율.
**Tier1 정점 산문**(§8 레지스트리)은 Codex가 초안 작성까지, 커밋 후 Claude 판정·리터치를 받는다(불합격 시 리라이트).

### 활성 오더 (Claude 발행 — 위에서부터)

#### [x] ORDER-01 [P0] 컴파일 게이트 복구 실행
**완료 보고 (2026-07-13 Codex):** Godot 4.6.3으로 최신 `main`의 `GODOT=<로컬 경로> ./tools/audit.sh`를 풀 실행했다. 정적 감사 ERROR 0/WARNING 0, 밸런스 3정책, 오디오·BGM 연속성, 튜토리얼 입력, 스토리 자동 재생, 영어 zero-Hangul/커버리지, 활성 CG 50장/배우 계약 86개가 모두 통과했고 57개 GDScript 강제 로드 컴파일도 깨끗했다. `--qa=ap-en`은 영어 AP·루틴·구직·관계·정보 모달 25컷을 완주했으며 대표 화면의 1280x800 잘림·한글 누출이 없었다. 종료 시 기존 OpenGL Texture/RID 정리 경고만 재현됐고 실행 결과는 `SCREENSHOT_QA_DONE`이다. 수리할 컴파일 오류가 없어 소스 범위 확장은 없었다.

Claude 컨테이너가 Godot 바이너리를 잃어(2026-07-13) 최근 Claude 커밋들(간직한 것들 리캡·서랍 속의 진실·새벽의 사람들)이 **GDScript 컴파일 검증 없이** main에 반영됐다(정적 검증만 통과). 최신 main에서 `GODOT=<로컬 경로> ./tools/audit.sh` 풀 실행(컴파일 포함)+`--qa=ap-en` 스모크 1회. 컴파일 에러 발견 시 즉시 수리 커밋. **이후 상시**: Claude 커밋이 main에 들어올 때마다 컴파일 게이트는 Codex 몫.

#### [x] ORDER-02 [P1] Tier2 산문 패스 M — 미드게임 스파인
**완료 보고 (2026-07-13 Codex):** 지정된 일반 스토리 14종과 미드게임 아크 15종의 KO/EN 산문을 감각 근거·내면·여운이 있는 Tier2 장면으로 동시 격상했다. 첫 월급의 임의 고정액, 첫 저축 이정표의 실제 300만원 트리거, 최종 반년의 24주, 한국 주식 UI와 충돌하던 `Red Numbers`, 다은 편의점 카운터 동선을 함께 바로잡았다. HEAD 대비 자동 불변 검사가 정확히 29개 이벤트의 산문 필드만 변경했고 id·flags·effects·cast_effects·conditions·dik 키·선택지 수는 동일함을 확인했다. EN coverage/zero-Hangul과 첫 세션 밀도, 전체 audit, 밸런스 3정책, Godot 57스크립트 컴파일이 모두 통과했다.

`docs/ROMANCE_SYSTEM.md` §8(6요소 루브릭)·§8-A(Tier2 바닥선: 감각 근거 1+/내면 1+/여운 1줄, 요약 금지, 200~300자대) 선독. **산문만 수정**(id/flags/effects/cast_effects/conditions/dik 키 불변), KR+EN 동시.
대상: `story_events.json` 14종(story_prologue_dad·six_months·rainy_night·compare_friend·first_paycheck_feel·late_night_grind·weekend_choice·gosiwon_neighbor·payday_morning·hometown_nostalgia·first_savings_milestone·three_year·four_year·age_39_final) + `arc_midgame.json` 서사 하중 상위 15종(goshiwon_goodbye·money_loneliness·goal_vertigo·father_medication·quit_job·first_real_win·career_ceiling·social_comparison·daeun_trace·invest_first_loss·year_three_crossroads·endgame_sixmonths·35_alone·37_reckoning·37_burn_or_light). 결 레퍼런스=arc_hyunsu(패스 H 완료본)·arc_father_passing. 검증: audit ✅+en_coverage clean.

#### [x] ORDER-03 [P1] Tier2 산문 패스 D — 로맨스 주변 아크
**완료 보고 (2026-07-13 Codex):** 다은 주변 6종, 지연 부산 표준 라인 7종, 전문화 3종, 공통 투자·생활·챕터1 아크 13종 등 지정 29개 장면을 KO/EN Tier2 산문으로 동시 격상했다. 다은은 편의점 카운터 동선과 `민준씨` 존댓말을 유지했고, 지연은 부산 편도 이주→부산 사무소→서울 2일 연수→부산 복귀→부산 사무소를 유지한 서울 지점 확장으로 위치 연속성을 고정했다. 연애 확정 전 지연 선택지·대사도 전부 존댓말이며, 확정 선택 결과에서만 처음 반말이 열린다. 초기 자산 장면의 `한 달 전 50만원`은 실제 정본인 `서울에 올라왔을 때 50만원`으로 교정했다. HEAD 대비 자동 비교에서 정확히 29개 ID의 산문 필드만 변경됐고 id·flags·effects·cast_effects·conditions·DIK 키·선택지 수는 모두 불변이었다. EN 문단 상한 240자, coverage, zero-Hangul, 첫 세션 밀도, 정적 ERROR 0/WARNING 0, 밸런스 3정책, 오디오·CG 계약, Godot 57개 스크립트 컴파일을 포함한 전체 audit가 통과했다.

**착수 기록 — 만진 파일:** `content/events/arc_daeun_extension.json`, `content/events_en/arc_daeun_extension.json`, `content/events/arc_year3_drama.json`, `content/events_en/arc_year3_drama.json`, `content/events/arc_specialization.json`, `content/events_en/arc_specialization.json`, `content/events/arc_romance_y5.json`, `content/events_en/arc_romance_y5.json`, `content/events/arc_daeun.json`, `content/events_en/arc_daeun.json`, `content/events/arc_events.json`, `content/events_en/arc_events.json`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.

같은 규율. 대상: `arc_daeun_extension.json` 4종 + `arc_year3_drama.json` 지연 부산 라인 7종(원거리 정합 주의 — 그녀는 부산에 있다) + `arc_specialization.json` 3종 + `arc_romance_y5.json` arc_daeun_y5_feelings + `arc_daeun.json` arc_daeun_02b_dream + `arc_events.json` 잔여 얇은 씬(arc_opp_* 4종·money_check 3종·ch1 테마 5종·gosiwon_wall). 호칭 정본 필수(다은 존댓말/지연 반말은 연애 확정 후만).

#### [x] ORDER-04 [P1] 회상 갤러리 (7-I 풀스택)
**완료 보고 (2026-07-13 Codex):** 영구 메타 저장에 `seen_scenes`/`unlocked_cgs`를 추가하고 일반 StoryMode 씬 재생·실제 CG 공개·엔딩 CG 노출 시점에만 해금을 기록한다. 메인 메뉴 `기록 / Archive`는 50개 CG의 해금/실루엣 도감과 전체화면 감상, 특별·계절·첫 키스·첫날밤 19개 명장면의 무스크롤 회상, 해금된 항목만 존재하는 비밀 기록을 KO/EN·패드 포커스로 제공한다. `four_seasons`·`kept_evidence`·`drawer_truth`·`dawn_people`는 미해금 시 이름·힌트·개수 흔적이 전혀 나오지 않는다. 회상 선택은 산문·연출·후속 장면만 재생하고 GameState 효과·플래그·결과 수치 카드·MetaProgression을 모두 불변으로 유지한다. 전용 `--qa=gallery`가 무스크롤·화면 경계·히든 이름 비노출·직렬화 상태/메타 완전 불변을 자동 판정하며 KO/EN 5컷씩, 960x600·1280x720·1280x800을 통과했다. 전체 audit도 정적 ERROR 0/WARNING 0, 밸런스·오디오/BGM·입력·57스크립트 컴파일까지 통과했다.

**착수 기록 — 만진 파일:** `autoloads/MetaProgression.gd`, `autoloads/GameState.gd`, `content/meta/default_meta.json`, `scenes/StoryMode.gd`, `scenes/MainGame.gd`, `scenes/StartMenu.gd`, `tools/audit.py`, `tools/ScreenshotQA.gd`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
`docs/ROMANCE_SYSTEM.md` 7-I 정본. 데이터 계층: MetaProgression에 `seen_scenes`/`unlocked_cgs`(영구 저장, 씬 id·CG id 해금 기록 — StoryMode 재생 시·CG 노출 시 기록 훅). UI: 메인 메뉴 "기록" 갤러리 — ①CG 갤러리(미해금 실루엣) ②명장면 회상(특별 스토리·계절·첫 키스·첫날밤 재생 — pending_story_queue 재사용, 재생 중 효과/플래그 적용 금지=열람 전용 가드 필수) ③히든 업적(해금 후에만 표시 — four_seasons·kept_evidence·drawer_truth·dawn_people는 해금 전 이름도 숨김). 검증: audit+갤러리 ScreenshotQA 스코프 추가.

#### [x] ORDER-05 [P1] 업적 전수 감사 (15종)
**완료 보고 (2026-07-13 Codex):** 카탈로그·`achievements_by_id`·영어 사전·엔딩 해금 명패를 정확히 같은 15개 ID로 통합하고, 명패는 별도 하드코딩 표가 아니라 현 언어의 카탈로그 이름을 직접 사용한다. 존재하지 않던 `white_gangnam`·`clean_gangnam` 유령 업적은 신규 해금을 제거했으며, 기존 메타의 유령·미지·중복 ID는 로드 시 안전하게 정리한다. `white_gangnam_title`은 실제 `gangnam_dream_white` 엔딩 발견 기록을 본다. `AchievementPathCheck`는 자산/엔딩/런 횟수 11종, `beat_addiction`·사계절·유물 제시 플래그, 새벽 5회·서랍 컷 직접 경로를 실제 실행하고 계절/제시 플래그의 serialize 전달과 이벤트 선택지 생산자까지 검증한다. 검사 전 메타 원문을 항상 복원하며 audit도 격리 HOME으로 실행한다. 최종 결과 `catalog=15 paths=15 hidden=4`, 정적 ERROR 0/WARNING 0, EN 누출 0, 밸런스·오디오/BGM·입력·CG 계약·Godot 57스크립트 컴파일을 포함한 전체 audit 통과.

**착수 기록 — 만진 파일:** `autoloads/MetaProgression.gd`, `autoloads/DataRegistry.gd`, `content/meta/achievements.json`, `scenes/MainGame.gd`, `tools/AchievementPathCheck.gd`, `tools/AchievementPathCheck.gd.uid`, `tools/AchievementPathCheck.tscn`, `tools/audit.sh`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
15종 각각 해금 경로 실증(코드 추적+가능하면 헤드리스 시뮬): 트리거 조건→unlock_achievement 도달 여부, 도감 카운트/엔딩 이름표/EN 사전 3자 정합. 특히 신규 4종(four_seasons — record_run rf 스냅샷에 last_*_date_year가 실제로 담기는지 / kept_evidence — presented_artifact_correct rf 전달 / drawer_truth·dawn_people — 직접 unlock 경로). 누락·불일치는 수리 커밋, 보고서를 WORK_LOG에.

#### [x] ORDER-06 [P2] 유물 제시·히든 QA 패스
**완료 보고 (2026-07-13 Codex):** StoryMode가 실제로 쓰는 원본 선택지 인덱스·유물 노출·후속 이벤트 판정을 단일 헬퍼로 고정하고, 엔딩 재독 문구·서랍 발동 조건·보유 유물 이름도 MainGame의 실제 렌더 경로와 검사 경로가 공유하게 했다. `HiddenFeatureCheck`는 KO/EN에서 재혁·지연·다은의 유물 미보유 2개/보유 3개 선택지를 확인하고, 재혁 사진 후속 씬과 제시 플래그, 지연 `jiyeon_man` 라우팅 및 `jiyeon_stayed_as_selves` DIK, 다은 거절/포스트잇의 동일 `with_daeun` 비이혼 라우팅을 실제 `apply_choice()`·`check_game_over()`로 실행한다. 실제 OS 새벽은 QA 시간 오버라이드로 4개 비중복 대사와 5회 최심부·업적을 검증한다. 서랍은 조건 부정 2종과 실제 암전 레이어·전체 Tween·업적·완료 콜백을 실행하며, 엔딩 시간의 기록 카드는 KO/EN 여섯 유물 이름과 `WHAT HE KEPT` 표면을 렌더한다. 최종 결과 `HIDDEN_FEATURE_CHECK_OK artifact_choices=3 follow_up=1 jiyeon_dik=1 daeun_route=1 dawn=5 drawer=1 keepsakes=6`, 전체 audit ERROR 0/WARNING 0·EN 누출 0·57스크립트 컴파일 통과.

**착수 기록 — 만진 파일:** `scenes/StoryMode.gd`, `scenes/MainGame.gd`, `tools/HiddenFeatureCheck.gd`, `tools/HiddenFeatureCheck.gd.uid`, `tools/HiddenFeatureCheck.tscn`, `tools/audit.sh`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
신기능 블랙박스: ①재혁 ghost — 사진 미보유 시 2선택지/보유 시 3번째 "(주머니 속…)" 노출+follow_up 사진 씬 ②지연 verdict 제3의 길 — 첫 문자 보유 시만, 선택 후 jiyeon_man 엔딩에 stayed_as_selves dik 발화 ③다은 이혼 담판 포스트잇 — 라우팅이 거절과 동일(이혼 아님) ④새벽의 사람들 — `_is_real_dawn()` 임시 오버라이드로 새벽 대사 4종 순환·5회 최심부·업적 ⑤서랍 속의 진실 — 조건 충족 엔딩 후 암전 컷 재생·업적 ⑥간직한 것들 — 유물 보유 런 엔딩 리캡에 목록 노출. 각각 캡처 or 로그 증적, 발견 버그 수리 커밋.

#### [x] ORDER-07 [P2] 이사 "두고 간다" 비트
**완료 보고 (2026-07-13 Codex):** 주거 상승 직전에 보유 유물 중 가장 오래된 하나를 실제 런 이벤트로 꺼낸다. 이벤트는 고정 방 이미지를 갖지 않고 이사 전 현재 주거 배경을 추론하므로 고시원·원룸·빌라 어느 단계에서도 공간이 바뀌지 않는다. `가져간다`는 주거 이동 외 모든 상태를 보존하고, `두고 간다`는 해당 유물 하나만 제거해 이후 유물 장면·DIK·제시를 자연스럽게 침묵시키며 정신력 +2·Moral Tint -2를 적용한다. 두 선택 모두 엔딩 라우팅과 돈에는 영향이 없다. KO/EN 이름·선택지·결과, 가장 오래된 유물 선택, 저장 직렬화, 현재 주거 배경, 이후 선택지 소거를 `HousingKeepsakeCheck`가 실제 `apply_choice()` 경로로 검증한다. `tools/audit.sh`의 세 격리 HOME 정리는 허용된 임시 접두사만 삭제하도록 함께 경화했다. 최종 전체 audit는 ERROR 0/WARNING 0, 두 대표 아크 흐름 무잼, 밸런스 3정책, EN 누출 0, Godot 57개 GDScript 컴파일을 통과했다.

**착수·완료 파일:** `autoloads/GameState.gd`, `autoloads/DataRegistry.gd`, `scenes/MainGame.gd`, `content/events/arc_housing_keepsake.json`, `content/events_en/arc_housing_keepsake.json`, `tools/audit.py`, `tools/HousingKeepsakeCheck.gd`, `tools/HousingKeepsakeCheck.gd.uid`, `tools/HousingKeepsakeCheck.tscn`, `tools/audit.sh`, `docs/QA_CHECKLIST.md`, `docs/BALANCE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
주거 사다리 상승 전환(HOUSING_DATA 상승 이동 처리 지점)에 1회성 비트: 보유 유물이 1개 이상이면 "짐을 싸다가, 그것이 나왔다" 스토리 이벤트 — 선택: 가져간다(변화 없음) / 두고 간다(유물 1개 제거 — 제거 유물의 유물 씬·dik·제시가 이후 침묵, mental+2 tint-2 "가벼워진 짐"). 유물 다수면 가장 오래된 것 하나를 지목. 신규 이벤트 KR+EN, 플래그 독자 확보, 아크 규약 준수. **이건 '간직함을 선택으로 만드는' 설계라 라우팅 영향 0이어야 함.**

#### [x] ORDER-19 [P1] 연차 정체성 패키지 — 다섯 해에 이름을 (유저 지시 2026-07-13) ⚠ 동결 전 마지막 콘텐츠 신규 기능
**완료 보고 (2026-07-13 Codex):** 챕터 1~5를 `생존/확장/진실/무게/결산`으로 명명하고, 현재 런에서 실제 본 장면만 연차별로 분리해 최대 4개의 서로 다른 연말 기억 후보로 만든다. 선택한 `year_scene_1..5`는 세이브에 남고 현재 언어로 다시 해석되어 엔딩 시간의 기록 위 `5년, 다섯 장면` 가로 리캡에 표시된다. 장면이 세 개 미만이면 의식은 조용히 생략한다. 실제 아크가 사용하는 StoryMode에 12~15초 타이머와 장면별 안전 기본 선택을 연결했고, Y2 세 투자 기회를 t49~96에 잠갔으며, Y4 몽타주를 최대 3주와 접히는 시간 카피로 바꾸고, Y5 t193+ HUD를 48주부터 줄어드는 주 카운트다운과 월말 결산 한 줄로 전환했다. `YearIdentityCheck`와 KO/EN 1280x800 ScreenshotQA 11컷이 챕터·4지선다·타이머·Y4 3주 결과·HUD·직렬화·리캡을 검증한다. 최종 전체 audit는 정적 ERROR 0/WARNING 0, EN 누출 0, 두 대표 아크 잼 0, 밸런스 1,200런 x 3정책, Godot 57스크립트 컴파일을 통과했다.

**착수·완료 파일:** `autoloads/GameState.gd`, `scenes/StoryMode.gd`, `scenes/MainGame.gd`, `content/events/chapter_cards.json`, `content/events_en/chapter_cards.json`, `content/events/arc_year_close.json`, `content/events_en/arc_year_close.json`, `content/events/scenario_cafe.json`, `content/events/arc_events.json`, `content/events/investment_events.json`, `tools/audit.py`, `tools/audit.sh`, `tools/YearIdentityCheck.gd`, `tools/YearIdentityCheck.gd.uid`, `tools/YearIdentityCheck.tscn`, `tools/ScreenshotQA.gd`, `docs/QA_CHECKLIST.md`, `docs/BALANCE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
> 원칙: 새 기믹 금지 — 그 해의 주제가 기존 시스템으로 새어나오게. 정체성: Y1 생존 / Y2 확장 / Y3 진실 / Y4 무게 / Y5 결산.
1. **챕터 카드 강화**: 연차 진입 카드(chapter_card_33~37)에 그 해의 이름+한 줄 규칙 감각을 명시(설교 금지 — "올해는 시간이 없다" 같은 체감 문장). KR/EN.
2. **올해의 장면 (연말 큐레이션 의식)**: 각 year_close에서 그 해 실제로 본 명장면 3~4개(회상 갤러리 seen_scenes 재사용, 연차 필터)를 제시 → 플레이어가 1개 선택 → `year_scene_<n>` 기록(메타 아님, 런 저장) → **엔딩 리캡에 "5년, 다섯 장면" 블록**(시간의 기록 카드 위). 선택지 효과 없음(순수 기억 큐레이션 — inert 예외 승인: 효과가 아니라 기록이 차등). 미선택/장면 부족 시 우아한 생략.
3. **시그니처 스포트라이트 (게이팅 조정, 신규 콘텐츠 최소)**: Y1=타이머 긴박 이벤트 2~3개 Y1 창에 배치(기존 타이머 메커니즘 재사용) / Y2=버블·기회 이벤트 Y2 게이팅 강화(investment_events 연차 조건) / Y3=단서 부여 이벤트의 Y3 밀도 확인(이미 몰려 있음 — 부족분만) / Y4=몽타주 카드 제안 문구·빈도 연차 반응("시간이 접히기 시작했다") / Y5=t193+ 상시 D-카운트다운 HUD(남은 주 수, 위압적이지 않게) + 월말 결산에 한 줄 나레이션.
4. **오디오·팔레트 연차 레이어(선택)**: moral band와 직교하는 연차 질감(Y1 소음 많음→Y5 정적) — 기존 앰비언스 재배치 우선, 신규 자산 최소.
5. 검증: audit+arc_flow_sim(게이팅 변경)+밸런스 밴드 재검(Y2 시장 게이팅이 도달률 건드리면 BALANCE.md). **이 오더 완료+13 완료 = 콘텐츠 동결 선언 조건 충족.**

#### [x] ORDER-08 [P0] 외부 플레이테스트 키트 (유저 결정 2026-07-13 — "성공은 절반이 게임 밖")
**완료 보고 (2026-07-13 Codex):** 코드에 고정돼 있던 상시 데모 모드를 제거하고 `gangnam_demo` export feature를 정본으로 삼아 Windows/macOS/Linux·Steam Deck의 정식판과 데모판을 분리했다. `DemoBuildCheck`는 실제 아크 선택 효과와 follow-up을 적용하며 W1~W8 정본 체인, W24 허용/W25 차단, 여섯 export preset의 flavor 격리를 영구 검사한다. 세 데모 패키지를 Godot 4.6.2 공식 템플릿으로 실제 생성했고 macOS 패키지는 새 HOME에서 첫 언어 선택→JUNPAC→콜드오픈→영문 시작 메뉴→W1~W8→AP 복귀를 실제 입력으로 완주했다. KO/EN `demo-blackbox` 각 17컷과 전체 audit·57스크립트 컴파일도 통과했다. 무설명 30분, 5~10명 혼합 표본, 정량 5+정성 3+아트 스팟체크, 관찰/집계 시트와 7/10 판정 기준은 `docs/PLAYTEST_KIT.md`, 재현 가능한 빌드·해시·플랫폼 스모크 절차는 `docs/BUILD_PIPELINE.md`에 고정했다. Windows와 Linux/Deck은 교차 export만 끝났으므로 각 실제 기기 실행은 외부 배포 전 별도 통과해야 한다.

**착수·완료 파일:** `autoloads/GameState.gd`, `scenes/MainGame.gd`, `export_presets.cfg`, `tools/build.sh`, `tools/DemoBuildCheck.gd`, `tools/DemoBuildCheck.gd.uid`, `tools/DemoBuildCheck.tscn`, `tools/audit.sh`, `tools/ScreenshotQA.gd`, `docs/BUILD_PIPELINE.md`, `docs/PLAYTEST_KIT.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
> 내부 QA는 "깨지지 않음"을 보장하지 "재밌음"을 보장하지 않는다. 실제 사람 5~10명의 무설명 플레이가 출시 GO의 첫 도장.
1. **데모 빌드 절차 확립**: Windows/Linux export 프리셋 구성 + 실제 export 1회 스모크(부팅→콜드오픈→t=8 통과). 절차를 `docs/BUILD_PIPELINE.md`로 문서화.
2. **플레이테스트 프로토콜** `docs/PLAYTEST_KIT.md`: 대상 5~10명(서사 게임 경험자 절반+비경험자 절반), **무설명 30분**, 관찰자 개입 금지. 측정 3문(30분 후): ①"다음 세 주에 뭘 할 계획이었나" ②"기억에 남는 선택 하나" ③"계속 하고 싶은 이유/멈춘 이유". 통과 기준: 7/10이 ①에 구체적 답.
3. **피드백 양식 초안**: 설문 문항(정량 5 + 정성 3), 세션 기록 시트.
4. **사람 모집·실행은 유저 몫** — Codex는 키트까지.

#### [x] ORDER-09 [P1] 스토어 페이지 3초 전달력 — 완료: 숏 설명 3축·태그 전략·실제 인게임 스크린샷 8장 큐레이션 — 만진 파일: `docs/STEAM_PAGE.md`, `docs/STORE_PAGE.md`, `docs/STORE_SHOTLIST.md`, `assets/store/screenshots/`, `tools/store_shot_check.py`, `tools/ScreenshotQA.gd`, `tools/StoreScreenshotExport.gd`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`
**완료 보고 (2026-07-13 Codex):** 월 단위·27엔딩·로그라이트·영어 후출시가 섞인 옛 스토어 초안을 폐기하고 `STEAM_PAGE.md` 하나를 정본으로 통합했다. 돈의 절박함·도덕 붕괴·로맨스 상실을 각각 훅으로 한 KR/EN 숏 설명 3안, `Choices Matter / Life Sim / Visual Novel / Romance / Multiple Endings / Story Rich` 상위 태그, 35엔딩·1,400+ 사건·24주 데모·KR/EN 동시 출시의 실제 상품 계약을 고정했다. 전용 `--qa=store --lang=en` 스코프는 콜드오픈, 대포통장 12초 타이머, 3주 몽타주, 시간 원장, 같은 다은 카페의 밝음/어둠 쌍, 벚꽃 데이트 CG, 5년 다섯 장면 리캡을 실제 인게임 상태로 재현한다. 중앙 16:9 크롭 8장을 `assets/store/screenshots/`에 고정했고 `.gdignore`로 빌드 패키지에서는 제외했다. `STORE_SHOT_CHECK_OK count=8 size=1280x720 unique=8`, 전체 audit ERROR 0/WARNING 0·EN 누출 0·밸런스 3정책·오디오 64개·Godot 57스크립트 컴파일이 통과했다.
1. `docs/STEAM_PAGE.md` 현행화(신기능 반영: 유물 제시·히든·계절 데이트·회상 갤러리 예정).
2. **숏 설명 3안**(KR/EN 각): 3초 테스트 기준 — 첫 문장+캡슐만으로 "한국 사회 리얼리즘 인생 시뮬 + 색으로 무너지는 영혼 + 잃을 수 있는 결혼"이 전달되는가. 서로 다른 훅(①돈의 절박함 ②도덕 붕괴 ③로맨스 상실)으로 차별화해 유저가 고르게.
3. **스크린샷 8장 큐레이션**: 기존 ScreenshotQA 산출물에서 후보 추출(콜드오픈·대포통장 타이머·몽타주 카드·시간의 기록·tint 밝/어둠 대비 한 쌍·CG 1·엔딩 리캡·데이트) — 각 장이 "다른 시스템 하나"를 말해야 함. `docs/STORE_SHOTLIST.md`.
4. 태그 전략: Choices Matter/Life Sim/Visual Novel/Romance/Multiple Endings/Story Rich 우선순위와 근거.

#### [x] ORDER-10 [P1] 데모 빌드 확정 + 넥스트페스트 준비
**완료 보고 (2026-07-13 Codex):** KO 893회·EN 897회의 실제 확인 입력으로 각각 24주와 53개 이벤트를 완주해 25주차 AP/이벤트 대신 위시리스트 CTA에 도달했다. 시작 프로필·취업·근속 플래그, 편의점/배달/일반 직장 첫 근무, 편의점 본업의 추가 시프트 명명과 2026 최저임금 기반 9만원 보수, 보너스 AP 표기·1280px 경계, 카페 전화 초상, 오프닝 연타를 교정했다. 월말 요약과 성향 모달이 겹쳐 멈추던 실입력 데드락을 직렬화하고 CTA 위 일시 오버레이를 제거했으며, 완료 기록은 2026년 6월 4주차·24주차로 고정했다. KO/EN `demo-blackbox`, `DemoBuildCheck`, 한영 커버리지, 아크 흐름, 시각 계약 62건, 밸런스 3정책, 오디오 64개, Godot 57스크립트 컴파일을 포함한 전체 audit가 ERROR 0/WARNING 0으로 통과했다. Valve 공식 2026년 10월 일정과 1회 참가 규칙은 `NEXTFEST_CHECKLIST.md`, 기술 통과와 외부 재미 검증의 경계는 `DEMO_QA_REPORT.md`에 기록했다.
1. 데모 범위(t=24 컷+데모 엔딩 CTA) 빌드 플래그 실증: 데모 모드에서 t=25 진입 불가·위시리스트 CTA 노출·풀버전 예고 카피 확인.
2. **데모 전용 블랙박스 1회**: 콜드오픈→프롤로그→t=24 풀 플레이(실입력), 막힘·모순·톤 이탈 기록·수리.
   - ORDER-08 macOS W1~W8 실입력에서 발견한 회귀 후보를 우선 재현한다: 편의점 야간직에도 사무실·지하철 문법인 `story_first_workday`가 발화하는 직종 정합성, 월초 AP가 `3/2`·`3 LEFT`로 보이는 상한/표기 불일치. 플레이테스트 배포 전에 수리·게이트화한다.
3. Steam Next Fest 참가 체크리스트 리서치(공식 문서 기준: 신청 시기·1회 참가 규칙·데모 페이지 요건) → `docs/NEXTFEST_CHECKLIST.md`. **참가 시기 결정은 유저 몫**(위시리스트가 어느 정도 모인 뒤가 정설 — 근거 포함해 정리).

#### [x] ORDER-11 [P1] 스토어 트레일러 (30초 + 60초 확장판)
**완료 보고 (2026-07-13 Codex):** 실제 Godot 표면만으로 KO/EN 각 22컷을 1920x1080으로 재현하는 `--qa=trailer`를 추가하고, 12/7/3초 대포통장 선택·동일 장면 White/Gray/Black·연애 4컷·파국 3컷·시간 기록·투자·경마·블랙잭·룰렛을 고정했다. 실제 선택 타이머는 12초부터 읽히고 3초에 적색 위기로 바뀐다. `timeline.json` 단일 정본에서 30초와 60초 컷, KO/EN 자막, moral 저역 통과, 파국 완전 무음, 프로젝트 소유 효과음을 조립하며 ffmpeg는 컷·자막·믹스·H.264/AAC 인코딩에만 쓴다. KO/EN 30초·60초 4종이 정확한 길이, 1080p60, H.264 High, AAC 48kHz stereo 검사를 통과했고 각 SRT·SHA-256 manifest·QA 프레임을 생성했다. 30초 EN 믹스 실측은 -15.3 LUFS/-1.1 dBTP이며 22-26초 무음이 확인됐다. 재생성·판정 계약은 `TRAILER_PRODUCTION.md`; 최종 편집/카피 판정은 Claude 몫이다.
> 깔때기에서 스크린샷보다 먼저 재생되는 최강 요소. 콘티는 Claude 확정본(아래) — Codex는 인게임 캡처·조립.
**30초 콘티 (컷 순서 고정)**:
1. (0-4s) 콜드오픈 — 2031년 새벽 강남, 플래시포워드 화면 + 자막 "이게 누구인지는, 당신이 정한다."
2. (4-8s) 통장 50만원 → 목표 30억 숫자 대비 컷(오프닝/AP 대시보드) — "5년밖에 없다."
3. (8-12s) 대포통장 12초 타이머 실화면 — 긴박.
4. (12-17s) **tint 붕괴 시퀀스**: 같은 초상/거리 화면이 밝음→회색→어둠으로 전이(MORAL_TINT 3단) — 자막 "영혼이 색으로 무너진다."
5. (17-22s) 로맨스 컷 몽타주: 벚꽃→바다→불꽃 옆얼굴→첫날밤 아침 CG 4연타 — "잃을 수 있는 결혼."
6. (22-26s) 파국 플래시: 이혼 도장·떠나는 뒷모습·네 자리 식탁 1인분 — 무음 처리.
7. (26-30s) 키아트 + 워드마크 + "35개의 엔딩. 당신은 몇 번째로 무너질까." + 위시리스트 CTA.
**규칙**: 인게임 캡처만(외부 모션그래픽 금지 — Godot 네이티브 원칙), BGM=메인 테마의 moral band 전이(밝→어둠)를 컷4와 동기, KR/EN 자막 2벌, 1080p60. 60초판은 동일 골격+데이트·미니게임·시간의 기록 카드 삽입. 조립은 ffmpeg 스크립트를 `tools/trailer/`에 재현 가능하게. 최종 컷 판정=Claude.

#### [x] ORDER-12 [P1] 다국어 인프라 (ja·zh-CN·zh-TW 준비 — 번역은 아직 금지) — 완료 2026-07-13: 영어 선행 폴백 로더·빈 UI/콘텐츠/카탈로그 스켈레톤·원화 로케일 규칙·일반 커버리지/한글 누수/런타임 게이트·CJK 1280x800 QA. Pretendard 중국어 글리프 부족을 확인해 Noto Sans CJK 번들 전까지 비출시 잠금.
> Codex 제안 승인(Claude 판정 2026-07-13): 방향 합격 — ja(미연시 본고장+존댓말/반말을 케이고로 재현 가능)·zh-CN(스팀 최대 언어권+미지원 리뷰 폭격 방어)·zh-TW(간체 파생). **단 번역 착수는 콘텐츠 동결 선언 후** — ORDER-02·03이 텍스트를 다시 쓰는 중이라 지금 번역=전량 재작업.
**지금 할 것 (인프라만, 텍스트 독립)**:
1. **코드 표면 계층**: `_tr(kr,en)`/`LocaleManager.ui(ko,en)` 1,835 호출을 **무수정 유지**하는 절충 설계 — ui() 내부에서 lang이 ja/zh면 **KR 원문을 키로 하는 사전 조회**(`locale/ui_ja.json` 등), 미스는 EN 폴백+미스 로그. 호출부 1,835곳을 안 건드리는 게 이 설계의 전부다.
2. **콘텐츠 계층**: 기존 EN 오버레이 구조(id 병합·text-only)를 언어 일반화 — `content/events_ja/` 등 디렉토리 규약+DataRegistry 로더 언어 매개변수화. 엔딩 dik "통째 덮어쓰기 → 패리티 키 필수" 규약도 언어별 동일 적용.
3. **감사 도구**: en_coverage_check를 언어 일반화(커버리지+dik 패리티), 표면 스캐너의 ja/zh판(표면에 한글 잔존 검출은 동일 로직 재사용 가능).
3b. **통화·단위 표기의 로케일 계층화**: format_money의 ₩/억·만 표기를 로케일 규칙 테이블로(ja=¥·万, zh=¥·万/억 관례, en=won 스펠아웃 유지) — ja/zh 필수 작업이자 향후 토탈 컨버전(타 도시·타 통화 개작)의 기반. 주거 사다리·직업명 등 표면 상수도 같은 계층으로.
4. **폰트/레이아웃**: 현 폰트의 CJK 글리프 커버리지 실사 → 부족 시 폰트 후보 보고(라이선스 포함). 긴 독일어식 줄바꿈 문제는 없지만 zh 줄바꿈 규칙(단어 경계 없음) ScreenshotQA 1컷 검증.
5. **산출물**: 인프라+빈 오버레이 스켈레톤+도구까지. **번역 파일 생성 금지** — 번역 웨이브는 콘텐츠 동결 후 별도 오더(우선순위 ja → zh-CN → zh-TW, 언어별 용어집·호칭 정본표 선행, 네이티브 스팟체크 게이트는 유저와 협의).

#### [x] ORDER-13 [P1] 마감 게이트 3종 — 30억 경로 다양화·엔딩 구분성·표면 잔재 — 완료 2026-07-13
> Claude 판정 2026-07-13: 방향은 확정, 남은 위험은 "마감". 이 오더가 끝나면 콘텐츠 동결 후보 상태.
1. **30억 정점 경로 다양화 (밸런스 패스)**: 현행 30억 도달이 베팅 수렴(14.8%). 창업 엑싯·부동산 사다리 경로로도 상위 자산 도달이 현실적으로 가능한지 시뮬(3,000런)로 실증 → 상한/수익 파라미터를 밴드 안에서 조정해 **3경로 각각 도달 가능**(각 3%+ 목표)하게. 모든 수치 변경은 `docs/BALANCE.md` 기록+밴드 재검(무직 95~100/직장 0~2/베팅 8~25/중앙값 5천만~1.5억 유지).
2. **엔딩 35종 구분성 감사**: 전 엔딩을 (제목/본문/CG/라우팅 조건) 4열 표로 뽑아 "플레이어가 받아봤을 때 구분되는가" 판정 — 본문·조건이 사실상 겹치는 쌍은 병합 제안서만 작성(**병합 실행은 Claude 승인 후** — 엔딩 id는 저장 호환·업적 배선에 걸려 있음). 산출물 docs/ENDING_AUDIT.md.
3. **표면 잔재 제거**: 영구 비활성 일반 상점 버튼·모달·구매 코드를 제거하고 관계 선물 진열대만 유지. 첫 투자 진입은 예측·추천 없이 현재가·위험 등급·수수료·레버리지/강제청산을 설명하는 1회 안내 카드로 교체.

**완료 보고 (2026-07-13 Codex):** 고정 시드 240주 시뮬에서 베팅 14.8%, 공동창업 M&A 4.8%, 재개발 사다리 3.9%로 세 경로 모두 30억 도달 3% 하한을 넘겼고 기존 무직/직장/중앙값 밴드도 유지했다. 35종 엔딩 4열 감사표와 자동 게이트를 추가해 한영 35/35, 본문 고유성, 공유 비주얼을 잠갔으며 라우팅 변경·병합은 승인 대기로 남겼다. 죽은 상점 표면과 거짓 첫 월급 해금 문구를 제거하고 한영 첫 투자 손잡이를 1280x800에서 검증했다. `--qa=invest-en --lang=ko/en`, 정적 ERROR/WARNING 0, 오디오·데모·업적·히든·57개 GDScript 강제 컴파일을 포함한 전체 `audit.sh`가 통과했다.

#### [x] ORDER-14 [P1] "AI 티" 전수 감사 — 이미지 품질 게이트 — 완료 2026-07-13
> 판정 기준: 유저는 AI 사용이 아니라 그 증상을 때린다. 출시 전 전 이미지에서 증상을 제거한다.
1. **전수 실사**: 활성 CG 50장+초상 전종+배경 전종을 체크리스트로 감사 — ①손가락/손 형태 ②눈·좌우 비대칭 ③**인물 일관성**(다은/지연/민준이 전 컷에서 같은 얼굴인가 — 최우선) ④질감(플라스틱 광택·과포화) ⑤배경 논리(문·창·가구 배치, 텍스트 뭉개짐 — 간판·책등 글자는 AI 티 1순위) ⑥그레이딩 통일 이탈. 컷별 판정표 docs/ART_AI_AUDIT.md, 불합격 컷은 재생성/수정.
2. **간판·인쇄물 글자 특별 점검**: 이미지 안의 한글/영문 텍스트는 AI가 가장 티 나는 지점 — 뭉개진 글자는 지우거나 실제 타이포로 오버레이.
3. **키 비주얼 상위 10컷**(캡슐·스토어 스크린샷 후보·트레일러 주요 컷)은 기준 2배 엄격 — 깔때기 앞일수록 많이 보인다.
4. **스토어 AI 공시 문구 초안**: 정직+당당 — "모든 이미지는 AI 생성 후 사람이 큐레이션·수정·통일 그레이딩" 톤. KR/EN.
5. ORDER-08 플레이테스트 설문에 아트 문항 2개 추가 연동("그림이 게임 분위기와 어울렸나 / 거슬렸던 장면 하나").

**완료 보고 (2026-07-13 Codex):** `ImageRegistry`에서 파생한 활성 이미지 179장(CG 50/초상 54/배경 75)을 콘택트시트 22장과 원본 해상도로 전수 판정해 `FAIL 0 / PENDING 0`을 확정했다. 키 비주얼 10컷은 손·시선·동일 인물·공간·크롭을 강화 판정했고, 비현실적인 6면 모니터 코인 폐인 엔딩은 정본 고시원·휴대폰 1대·노트북 1대로 교체했다. 배경이 구워진 50대 민준과 죽은 박재원 등록을 활성 표면에서 제거했다. KR/EN Steam AI 공시, 비유도 플레이테스트 문항, 활성 경로/초상 알파/중복/판정표 자동 게이트를 추가했으며 영문 엔딩 렌더와 전체 audit를 통과했다.

#### [~] ORDER-20 [P1·수리] 엔딩 감사 판정 집행 — 사실 정렬 6건 — 착수: 한영 본문 사실 교정+상위 4 결산 심벌+회귀 게이트 — 만지는 파일: `content/endings.json`, `content/endings_en.json`, `scenes/MainGame.gd`, `assets/ui/ending_symbols/**`, `tools/ending_distinctness_audit.py`, `tools/ScreenshotQA.gd`, `docs/ENDING_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`
`docs/ENDING_AUDIT.md`의 "Claude 판정(2026-07-13)" 그대로: ①jiyeon_man 첫 문장("한지연의 강남에" 결) ②second_love 10억 현실화 ③gangnam_dream에 startup_exit 경로 dik 1종(KR+EN, 라우팅 불변) ④retirement 2종 미래 전망 프레임 ⑤orthodox_pinnacle 숫자 정렬 ⑥무드 카드 12종 → 전용 결산 카드 심벌(빈도순: ordinary_life→burnout→mental_break→stable_success 우선). 전부 라우팅 불변 — ending_distinctness_audit 게이트 통과 확인.

#### [ ] ORDER-21 [P1] 일본어 번역 웨이브 (착수 조건: ORDER-12 인프라 완료 — 콘텐츠 동결로 해금됨)
1. **선행 산출물**: `docs/I18N_GLOSSARY_JA.md` — 용어집(고시원=コシウォン(gloss)/전세/9급/라면=ラーメン 등) + **호칭 정본표**: 다은→"ミンジュンさん"+です・ます체(진심의 격식) / 지연→"オッパ"(オッパ 표기 유지)+タメ口는 연애 확정 후(도도·직설 — 그 전엔 です체) / 민준→두 여성에게 です・ます 기조. 부끄러움 문법 주석 포함.
2. **번역**: KR 원본 기준(EN 아님 — 중역 금지), events_ja/ 오버레이 + endings_ja + ui 사전. 산문 밀도 유지(§8 톤 — 축역 금지), dik 패리티 필수.
3. **검증**: 언어 일반화된 coverage/패리티 게이트 + ScreenshotQA ja 표본 15컷(줄바꿈·글리프).
4. **네이티브 스팟체크 게이트**: 핵심 20씬(§8 레지스트리) 목록을 뽑아 유저에게 전달 — 네이티브 검수자 확보는 유저 몫. 검수 반영 전까지 "베타 번역" 딱지.
5. zh-CN 웨이브는 ja 파이프라인 검증 후 별도 오더.

#### [ ] ORDER-15 [P2] 모드 지원 2층 — 커뮤니티 언어팩 + 에셋 오버라이드 (유저 승인 2026-07-13)
> 판정: 스크립트 모딩·샌드박스는 기각(서사 게임 정합·QA 표면), 데이터 2층만 개방 — 공수 대비 커뮤니티 효과 최대 지점.
1. **커뮤니티 언어팩**: ORDER-12 로더 일반화에 확장 — `user://lang/<code>/` 아래 events_<code>/·endings_<code>.json·ui_<code>.json을 발견하면 언어 목록에 자동 추가(내장 언어와 동일 오버레이 규약). 팬번역이 JSON만으로 성립. 언어팩 제작 가이드 `docs/MODDING.md`(스키마·dik 패리티 규칙·검증 스크립트 사용법 포함 — 우리 en_coverage_check를 팬도 쓸 수 있게).
2. **에셋 오버라이드**: DataRegistry·ImageRegistry 로딩 초크포인트에 `user://mods/assets/` 우선 조회(동일 상대경로 덮어쓰기, 실패 시 내장 폴백). 오디오 포함. 공식 문구는 "에셋 교체를 기술적으로 지원"까지 — 특정 콘텐츠 비보증. **에셋 매니페스트 자동 생성**: 전 초상·CG·배경의 (상대경로·해상도·용도) 목록을 docs/MODDING.md에 표로 — 통짜 일러스트 교체 방식이라 이 목록이 모더의 전부다(VN 패치 표준 방식).
3. **안전 가드**: 모드 활성 시 타이틀에 소극적 표기(문제 리포트 구분용) + 세이브에 mod_active 플래그(버그 리포트 필터). 스크립트 로딩은 지원하지 않음을 명시.
4. 스토어 카피 한 줄 확보: "커뮤니티 번역·에셋 모드 지원" — 위시리스트 셀링포인트.

#### [ ] ORDER-16 [P1] 입력×해상도 매트릭스 (유저 지시 2026-07-13 — "키보드 온리·마우스 온리 지원해")
1. **해상도 QA 매트릭스**: 1920×1080(16:9)·2560×1440·3840×2160·울트라와이드(3440×1440) ScreenshotQA 스코프 추가 — expand 여백에서 레이아웃 깨짐·앵커 이탈·글자 잘림 전수. CG/초상 4K 업스케일 체감 확인(필요 시 필터 설정). 창모드/전체화면/해상도 옵션 UI 유무 점검(없으면 추가 — 표준 기대치).
2. **키보드 온리 완주**: 마우스 입력 0으로 타이틀→데모 엔딩(t=24) 실주행 — 포커스 도달 불가 위젯·포커스 함정(빠져나갈 수 없는 모달)·카지노 7종 조작 가능 여부 전수, 발견 즉시 수리. 키 안내(패드 힌트의 키보드판) 표시.
3. **마우스 온리 완주**: 동일 구간 — 텍스트 입력 지점(플레이어 이름 등)은 기본값 제공+화면 키보드 or 클릭 진행 가능하게.
4. **패드 매트릭스**: Xbox·듀얼센스·스위치 프로콘 글리프 3종 스크린샷 검증 + 진동 지점 목록화(과다 진동 금지 — 결정·타이머 순간만). Steam Input 기본 구성 파일 준비.
5. 산출물: docs/INPUT_MATRIX.md(지원 선언표 — 스토어 페이지 "전체 컨트롤러 지원" 표기 근거).

#### [ ] ORDER-17 [P3·출시 비차단] 데이터 모딩 3·4층 — 커스텀 이벤트 팩 + 밸런스 프리셋
> Claude 판정: 이 게임은 이벤트 1,477종이 전부 JSON = 반쯤 스토리 플랫폼. 3층을 열면 팬이 자기 사건을 쓴다. **출시 게이트 아님** — ORDER-12·15 로더 작업과 초크포인트가 같으니 그때 함께 하면 공수 최소.
1. **커스텀 이벤트 팩**: `user://mods/events/*.json`을 DataRegistry 로드 체인 끝에 추가(랜덤 풀 합류). **정본 격리 필수**: ①신규 모드 이벤트는 랜덤 풀에만 합류(`_next_arc_id` 스케줄 개입 불가) ②모드 이벤트의 신규 flags는 `mod_` 접두사만(로더 검증·위반 시 스킵+로그) ③id 충돌 기본=내장 우선, 단 **모드가 `"override": true`를 선언하면 아크 포함 동일 id 내용 교체 허용** — 스케줄 골격은 고정, 이야기(대사·선택지·효과·dik)는 통째 개작 가능 = "스토리 개작 모드" 성립(유저 승인 2026-07-13). 오버라이드 사용 세이브는 mod_active 강제.
2. **밸런스/시나리오 프리셋**: jobs.json·assets.json·items.json·news_templates.json도 user:// 오버라이드 허용(통째 교체 아닌 id 병합) — "하드코어 월세"·"금융위기 시나리오" 류 커뮤니티 프리셋 성립.
3. **인게임 모드 목록**: 시작 화면 설정에 감지된 모드 목록+개별 켜기/끄기+로드 순서(단순 리스트면 충분).
4. **모더 검증 도구**: 우리 audit의 축소판(JSON 스키마·mod_ 접두사·id 충돌 체크) 스크립트를 MODDING.md와 함께 배포.
4b. **테마 팔레트 데이터화 (색 모딩 + 접근성)**: `_moral_ui_palette()`의 밴드별 색 세트를 JSON 테마 파일로 추출 → user:// 오버라이드 허용. **구조 불변·값만 스킨**(밝음/회색/어둠 3단 밴드 구조는 도덕 표현이라 게임플레이 — 모더는 각 밴드의 색 값만 교체). 부수 산출: 공식 접근성 프리셋 2종(색약 팔레트·고대비) — "색으로 도덕을 말하는 게임"의 색약 지원은 리뷰 자산. 산재 hex 리터럴 전량 추출은 ORDER-18 B(v1.1 엔진 경화)로.
5. **Steam Workshop은 보류** — 출시 후 모드 씬 형성 확인 시 별도 오더(GodotSteam 연동 공수 큼).
> **포지셔닝 정본(유저 논의 2026-07-13)**: 토탈 컨버전("뉴욕 버전") 역량은 만들되 **스토어는 게임으로만 포지셔닝** — 플랫폼 지위는 커뮤니티가 사후에 명명하게(스카이림 패턴). 이 인프라의 1차 고객은 모더가 아니라 **우리 DLC**(다은의 5년·공식 스핀오프)다.
#### [ ] ORDER-18 [P1] 기술 부채 전수 인벤토리 + 3분류 수리 (유저 원칙 2026-07-13: "길게 봐서 하드코딩 정리" — 시점 분류로 집행)
> 판정 기준: **"로드맵을 막느냐"가 수리 기준** — 하드코딩≠스파게티(finish_run 캐스케이드·_next_arc_id 분기는 의도된 정본). 출시 직전 대수술 금지.
1. **전수 인벤토리**: 전 .gd에서 ①매직 넘버/문자열 상수 ②중복 패턴(복붙 함수) ③god-object 핫스팟(MainGame.gd 책임 지도) ④데이터여야 할 코드(표면 상수·수치 테이블) ⑤죽은 코드를 카탈로그 → docs/TECH_DEBT.md에 항목별 (위치·위험도·로드맵 연관) 표.
2. **3분류 집행**:
   - **A 출시 전 수리**: 로드맵을 실제로 막는 것(통화·표면 상수 로케일화=ORDER-12와 동일 건) + 기계적·저위험(상수 추출, 죽은 코드 제거, 명백한 중복 함수 통합). 각 수리는 개별 커밋+전체 audit+해당 ScreenshotQA.
   - **B 출시 후 v1.1 "엔진 경화"**: 구조 수술(MainGame 분할, 아크 스케줄러 데이터화, 이벤트 파이프라인 정리) — 실플레이 검증을 갑옷으로 삼은 뒤. TC/DLC 인프라와 동일 트랙.
   - **C 의도된 정본 — 문서화만**: finish_run 순서, _next_arc_id 명시 분기, dik 첫 매치 등 — "지저분해 보이지만 설계"인 것들은 TECH_DEBT.md에 사유와 함께 '건드리지 말 것'으로 등재(미래 리팩터 사고 예방).
3. A 분류 수리 완료 시점 = 콘텐츠 동결과 함께 **코드 동결**(이후 출시까지 수리 커밋만).

6. **[백로그·v1.x] 아크 스케줄러 데이터화**: `_next_arc_id()`의 하드코딩 분기를 데이터 테이블(턴 창·조건·체인)로 이관 — 완성 시 커스텀 아크·풀 토탈 컨버전 성립. 부수 효과로 우리 저작·arc_flow_sim도 개선. **출시 후 첫 대형 업데이트 후보** — 출시 전 착수 절대 금지(240주 스토리 흐름의 심장 수술).

---

## P0-IP. 기억되는 게임 얼굴 — 플래그십 캐스트 + 타이틀 키아트 + 시작 화면

**진행 상태 (2026-07-10 Codex): 완료.** 시작 화면은 민준·다은·지연의 신원 잠금 단일 1920x1080 유리/반사 키아트, 공용 KO/EN 건축형 워드마크, 단일 세로 명령 레일, 최신 기록 Continue, 별도 Load overlay로 교체했다. 같은 마스터에서 Steam 캡슐 3종을 결정론적으로 파생하고 `keyart_asset_check.py`로 런타임 소유권을 잠갔다.

## P0-0. 로맨스 아트 패키지 — 히로인 장면 전면 CG + 특별 초상화 (유저 지시 2026-07-07: "모든 히로인 관련 장면은 단독 CG와 특별 초상화 필수")

**진행 상태 (2026-07-13 Codex/Claude): T0 CG 10/10 + T0 의상 초상 10/10, T1 좁은 방 1건 + 남산 2건 + 놀이동산 2건 + 시골의 이틀 1건 + 첫날밤 아침 2건 + 다은 프로포즈 1건 + 다은 결혼식 2변주 + 지연 결혼 격차 1건, T2 이별 컷 2/2 완료.** 프로포즈는 수락 결과 문단에서만 열리고 결혼 준비 비용은 소형/풀 식장으로 지속된다. 다은의 도장과 지연의 떠나는 뒷모습도 결별 선택의 정확한 결과 문단에서만 열린다. P0 최종 삶 엔딩 CG 8종도 아래 P0-1에서 완료했다. Claude가 T2 히든 「그녀는 알고 있었다」의 실제 사건과 소유자를 구현했으며, 전용 컷은 `docs/ENDING_ART.md` P1 결산 CG 4종 뒤에 제작한다.

> 미연시 축은 비주얼 장르다 — 오타쿠 소구 CG가 엔딩 CG보다 커뮤니티 확산력이 높다(DECISIONS·ROMANCE_SYSTEM 7-D/7-G).
> 파이프라인: 외부 생성 → 사람 큐레이션 → **Gangnam Ink 그레이딩 통과**(스타일 통일). 초상화는 투명 배경 단독(DECISIONS 2026-07-03 인물 규칙). **기존 daeun/jiyeon 초상 기준 동일 인물성(얼굴) 유지가 게이트 1순위** — `docs/ASSET_CONTINUITY_CHECKLIST.md` 적용.
> 콘텐츠 스펙은 `docs/ROMANCE_SYSTEM.md` 7절이 정본 — 장면 구도는 각 항목의 명장면 컷 서술을 따른다.

**CG 샷 리스트 (티어순)**
- **T0 (트로프 성립 필수 — 이것 없으면 해당 콘텐츠 반쪽)**:
  1. 여름 바다 ×2 — 다은(동해 파도 앞 첫 웃음)/지연(해운대, "나 수영 못 해"의 순간)
  2. 불꽃축제 ×2 — 불꽃이 아니라 옆얼굴을 보는 구도(다은 원피스/지연 후드티)
  3. 벚꽃 데이트 ×1(공용 구도, 파트너 스왑 가능하면 ×2) — **tint 밝/어둠은 별도 작화가 아니라 그레이딩 셰이더 변주로**
  4. 첫 키스 ×2 — 다은(새벽 골목 캔커피 김)/지연(시동 끈 차 안)
  5. 첫눈 ×2 ✅ — 다은(편의점 밖 작은 캔커피 둘)/지연(왼쪽 운전석 세단, 멈춘 와이퍼)
- **T1**: 5. 남산 자물쇠 벽 앞 ×2 ✅ 6. 놀이동산 ×2 ✅ — 다은(아이 손을 잡은 셋)/지연(네 컷 사진 부스 프레임 그 자체) 7. 좁은 방(지연, 컵라면 김 서린 창) ✅ 8. 시골의 이틀(다은 — 밤 버스 차창) ✅ 9. 첫날밤 아침 ×2 ✅(다은 부엌 뒷모습/지연 민낯) 10. 프로포즈·결혼 선택 ×4 ✅(다은 수락 1 + 소형/풀 식 2 + 지연 격차 1). 엔딩 결과 컷은 `ENDING_ART.md` P0에서 별도 제작
- **T2**: 11. 이별 컷 ×2 ✅(결별 합의서의 도장/떠나는 뒷모습, 선택 결과 문단 지연 공개) 12. **히든 「그녀는 알고 있었다」 1컷(등기부를 서랍에 넣는 손) — 사건·소유자 구현 완료, P1 결산 CG 4종 뒤 제작 필수**

**특별 초상화 (스탠딩 변형)**
- 의상: 다은 — 원피스(축제)·여름(바다)·사복(유니폼 아닌 데이트 기본)·웨딩 / 지연 — 후드티(축제)·여름·웨딩
- 표정: 양쪽 — 부끄러움(**문법 준수: 다은=솔직한 수줍음, 지연=시선 회피+귀 끝 붉음**)·눈물·환한 웃음 / 지연 — 민낯(첫날밤 아침·히든용)
- 배선: 해당 이벤트 JSON의 `portrait` id로 — ImageRegistry 등록 + semantic audit mirror 동기(신규 인물 규칙과 동일 절차).

**수용 기준**: T0 10장이 완성·배선·검증되어야 한다(바다·불꽃·벚꽃·첫 키스·첫눈 각 2종). 각 CG는 회상 갤러리(P2-5.7) 해금 대상으로 설계.

## [x] P0-1. 최종 삶 엔딩 CG 8종 (2026-07-12 Codex 완료)

완료: `full_circle`, `gangnam_dream_white`, `with_daeun`, `second_love`, `jiyeon_man`, `guardian`, `jaehyuk_way`, `sangchul_reckoning`이 과정 CG 재사용 없이 각각 전용 1280×800 최종 삶 CG를 소유한다. 지연 거울은 현실 인물과 반사상을 따로 생성하지 않고 거울 안의 민준 왼쪽·지연 오른쪽만 한 번씩 보여, 좌우·자세 모순을 구조적으로 차단한다. Deep Black 엔딩도 얼굴·손·커튼이 읽히는 전용 미리보기 중간톤을 쓴다. KO/EN `--qa=ending-p0` 8컷, exact texture/430px crop, `CGRuntimeCheck`가 배선을 잠근다.

## [ ] P1-E. 정식 출시 결산 CG 확장 (2026-07-13: 7/9, 활성 오더 완료 후 재개)

**[x] P1-E-7 `instant_legend` 완료:** 시작 초상과 동일한 33세 민준이 첫해에 거의 빈 강남 거실에 도착해 등기 폴더를 내려다보는 전용 1280x800 CG를 연결했다. 한 상자·낡은 가방 외에는 비워 “삶보다 목표가 먼저 도착한” 히든 엔딩을 분리했고, 첫 후보에서 하단에 걸린 오른손을 폴더 쪽으로 올려 두 손·얼굴·등기·빈 공간이 950x430 안에 함께 남도록 보정했다. 코드 조건은 첫해인데 본문이 3개월이라던 한영 모순과 `KRW 3B` 표기 부채도 첫해/`3 billion won`으로 교정했다. 활성 CG 50장/배우 계약 86개, KO/EN `ending-p1` 각 15컷 통과. 유저 지시대로 다음은 신규 CG가 아니라 `ORDER-01`부터 순차 실행한다.

`late_call` 완료: 창원행 KTX의 민준·전화·겨울비·뺀 이어버드만 모든 기억 변주의 공통 사실로 고정했다. `ktx_window`를 실제 실내로 복구하고 지방역 `hometown_train_station`을 분리했다. `lonely_rich` 완료: 네 자리 식탁·1인분·세 빈 의자로 `empty_house`의 아버지 상실 소파와 분리하고, 강남 미달 이혼이 부자 CG/방 세 개 산문을 받던 라우팅 오류도 `ordinary_life` 전용 변주로 교정했다. `gambling_recovery` 완료: 랜덤 연속 노출이던 회복 아크를 1+3+1주 예약 체인으로 바꾸고, 과장된 100일 문구를 실제 서른 동그라미 이후의 반복으로 교정한 뒤 정본 고시원 달력 CG를 연결했다. `bankruptcy/debt_spiral` 완료: 임의의 원금·월급·500원 문구를 순자산 임계와 실제 공통 사실로 고치고, 같은 정본 고시원에서 계산을 멈춘 단계와 계산기를 뒤집은 단계를 별도 CG로 분리했다. `startup_exit` 완료: 작은 창업 사무실에서 서명 직후 펜을 놓는 민준으로 고정하고, 계약서·휴대폰 방향과 유리 반사를 실제 좌석 축에 맞췄다. `instant_legend` 완료: 첫해 33세 민준·등기 폴더·한 상자와 낡은 가방만 남은 빈 강남 거실로 일반 5년 성공 엔딩과 분리했다. KO/EN `ending-p1` 15컷이 배선·크롭·첫해 사실을 잠근다. 잔여 `orthodox_pinnacle`, `burnout`은 활성 오더 완료 뒤 재개한다.

## [x] P1-0. AP 주간 결정 보드 (2026-07-10 Codex 완료)

완료: 큰 주간 통계 대시보드를 결정/파장 밴드로 압축하고 세로 행동 레일을 2×2 보드로 재구성했다. 카드마다 선택 범위·예상 결과·위험·후속 파장을 선행 표시하며, 데이트/루틴은 전폭 특별행으로 분리했다. 상하좌우 포커스는 실제 2열 좌표로 계산하고 AP 소진 시 다음 주로 이동한다. 첫 면접 뒤 `Job Hunt`는 전 표면에서 `지원 계속/Keep Applying`으로 이어진다. KO/EN Act 1~5와 AP 전체 1280×800 회귀, `audit.sh` 통과.

## [x] P1-0.5. 데모 첫 30분 내부 블랙박스 (2026-07-10 Codex 완료, 외부 테스트 별도)

P0 완료: 실제 입력으로 콘텐츠 안내→타이틀→콜드오픈→첫 면접→첫 AP를 통과했다. 빈 콜드오픈 선택지, 첫 월급/투자 해금 오보, t8 시간축 모순, 튜토리얼 입력 누출을 수정했고 6개월 데모 CTA를 노스크롤 한 화면으로 압축했다. `TutorialInputCheck`가 뒤 UI 오작동과 포커스 복구를 자동 검증한다.

P1-A 완료: 프롤로그의 정상 독해 44회/연타 82회 입력을 계량하고 선택지 안전 AUTO를 추가했다. AUTO 사용 시 첫 AP 전 수동 확인은 6회이며 `StoryPlaybackCheck`·`first_session_pacing_audit.py`가 선택지 정지와 입력 밀도를 래칫한다.

다음 P1-B: 첫 3주 계획 이해, AP 확정 촉감/결과/후속 약속, 오디오 연속성, 텍스트 자발 독해를 검증한다.

P1-B 완료: 핵심 UI 4종의 음정형 SFX를 Gangnam Ink 종이/기계 질감으로 교체하고 전체 오디오 62개의 소유권/BGM 재시작 방지를 감사로 고정했다. 첫 4주의 잠긴 서울 지도를 수입→월세→경로 수평선으로 교체했으며, AP 확정 오버레이까지 KO/EN 캡처한다.

남은 외부 게이트: 무설명 신규 플레이어가 30분 뒤 다음 세 주 계획·기억나는 선택·다시 하고 싶은 이유를 말하는지 측정한다. 내부 코드/QA 완료와 재미 검증을 혼동하지 않는다.

## [x] P1-1. 몽타주 표면 (2026-07-10 Codex 완료)

완료: 전용 `action_routine.svg`, 카드형 2슬롯 루틴 모달, `TIME RECORD` 결과 카드, 진입 ink 전환, `--qa=ap-en` 루틴/기록 캡처 추가.

**코드 앵커 (실증)**
- `_maybe_add_montage_card()` — MainGame.gd:5765. `turn<8` 또는 AP 비만땅 return; `_essential_btn(_tr("루틴대로 시간을 보낸다","Let the weeks pass"), _tr("다음 사건까지 — 최대 4주","Until something happens — up to 4 weeks"), "rest", "#5a6478", "_open_routine_modal", ...)`.
- `_open_routine_modal()` — MainGame.gd:7234. `_routine_draft` 2슬롯을 `GameState.week_routine`에서 프리필 → `_open_modal(_tr("이번 루틴","This Routine"), true)` → `_render_routine_modal_body()`(7247)가 `_ROUTINE_KINDS` 토글 버튼 2행. 시작 버튼(7270)이 week_routine 기록→닫기→`_montage_advance()`.
- `_montage_advance()` — MainGame.gd:7353. 최대 4주 루프; 중단 사유 `"gameover"/"arc"/"health"/"mental"/"cash"/"cap"`; `week_of_month==4`면 `_run_month_end_transition()` 후 **조기 return**(몽타주 카드 없이 월말 결산이 대신 뜸 — 전환 연출은 두 출구 모두 처리).
- `_show_montage_card(weeks, assets_before, health_before, mental_before, money_wk, human_wk, reason)` — MainGame.gd:7428. `_open_modal(_tr("시간이 흘렀다","Time Passed"))`; Δ 계산 7432-34; 3열 Grid(`_month_summary_metric_card`, `#00c896`/`#ff6b6b`); 축 서사 `_montage_axis_line`(7409)·사유 `_montage_reason_line`(7418); 확인→`_begin_month_story_and_render()`.
- 참고 문법: AP 결과 카드 `_ap_result_feedback_card(disp, accent)` — 7986 (오버라인 "ACTION RESULT" 8008, 톤 라벨 `_ap_result_tone_label` 8038: TRADE-OFF/COST/GAIN/LOG, Δ 배지 `_ap_result_effect_badge` 8066). 커밋 토스트 `_show_ap_action_commit` — 1085 (`_ap_commit_layer` 오버레이, "행동 확정/ACTION LOCKED" 1154).

**구현 순서**
1. 레일 카드 전용 픽토그램(시계/달력, action_tiles 스타일 — 현재 "rest" 아이콘 차용 중).
2. 루틴 모달을 카드형 선택으로(4종 카드 × 2슬롯), 각 카드에 축 태그 칩(`_add_week_axis_compact` 5091 근처의 `_axis_count_chip` 문법 재사용).
3. 결과 카드를 게임 내 "기록물" 톤으로 — `_ap_result_feedback_card`의 오버라인/배지 문법 + 경과 주 수만큼 잉크 점 틱.
4. 몽타주 실행 시 짧은 잉크 전환(StoryMode `_play_story_ink_transition`(StoryMode.gd:565)과 같은 어휘).

**함정**: "몽타주" 단어 표면 노출 금지(현재 0). 축 요약 문장("돈에 N주, 사람에게 M주") 원문 유지.
**검증**: `ScreenshotQA --qa=ap-en --lang=en` + 루틴 모달/결과 카드 컷 추가(ScreenshotQA.gd의 기존 모달 캡처 패턴). 1280×800 노스크롤. `./tools/audit.sh` ✅.
**수용 기준**: 결과 카드가 웹 모달이 아니라 게임 내 기록물로 보일 것.

## [x] P1-2. 곁의 사람 셀 + 그라인드 힌트 폴리싱 (2026-07-10 Codex 완료)

완료: `PEOPLE` 압박 셀을 이름/상태/세부 문장으로 분리한 3상태 온도 카드로 승격, 돈-only 루프 힌트를 `ABSENCE` 스트립으로 정리, AP 카드 높이 소폭 압축, `--qa=ap-en`에 `ap_en_03h_people_pressure_grind.png`/`ap_en_03i_money_only_closed.png` 캡처 추가.

**코드 앵커 (실증)**
- `_people_pressure_state()` — MainGame.gd:5042 (grind_streak `>=4` "멀어진다/drifting" 5049 / `>=2` "뜸하다/quiet" 5051 / else "곁에 있다/near"). `_closest_person()` — 5022 (배우자>연인>최고호감(≥10, daeun/jiyeon/hyunsu/jaehyuk)>아버지>빈 dict).
- 셀: `_add_week_pressure_cell(parent,label,value,good)` — 5157 (34px, bad면 보더 `#6a4b4b`·값 `#f0c1c1`). 호출부 `_render_week_pressure_row` 5014-19 (CASHFLOW/TO GANGNAM/CONDITION/PEOPLE).
- 그라인드 힌트: `_render_situation_cards()` 내부 5504-13 ("돈을 쫓는 사이 — {p}에게 연락 못 한 지 {w}주", `#8a7f74`); "이번 주도 전부 돈에 썼다" 5520-22.
- 주간 보드 전체: `_render_week_focus_panel(ap, net, total, has_warning, ...)` — 4880 (WEEK PLAN 4918 → 압박 행 4950 → 우선순위 스트립 4958).

**구현 순서**: ①3상태 색온도(온기 미색→중성→한색 — moral_role 문법으로) ②4셀 EN 장문 오버플로 재확인 ③힌트 라인 타이포/여백.
**함정**: 관계 수치·tint 노출 금지(서술로만 — 현행 유지).
**검증**: `ScreenshotQA --qa=ap-en` + grind_streak 시드 컷(`GameState.grind_streak_weeks` 직접 세팅).

## [x] P1-3. 시장 생동감 표면화 ("정적/웹소설" 체감 해소 레버) (2026-07-10 Codex 완료)

완료: 뉴스 영향 자산군 티커 마커, 주간 티커 색 펄스, 보유 포트폴리오 상단 자산 라벨 펄스, 투자 Market 페이지 `Top movers` 카드(스파크라인/변동률/NEWS/보유 금액)를 추가했다. 예측 정보는 추가하지 않고 이미 발생한 뉴스·가격 변화만 표면화했다. `ScreenshotQA --qa=invest-en`, `--qa=ap-en`, `./tools/audit.sh` 통과.

**코드 앵커 (실증)**
- 상단 바에 자산 티커 **없음** — `_refresh_all()`(3767)은 날짜/돈/AP/바이탈만(3773-86). `top_labels` dict 선언 14행, 구성 1221-38.
- 자산 티커는 사이드바: `_render_sidebars()` — 4290. `investment_system.get_asset_rows().slice(0,12)`(4295) → 전주 대비 `change_pct`(4298, `prev_prices`) → 6포인트 스파크라인(4315-18) → `ticker_rtl` RichTextLabel(선언 20행)에 기록(4320-21). `_price_sparkline(history)` — 11895 (`▁▂▃▄▅▆▇█`, <2pt→"——", 평탄→"━━━━━━").
- 투자 모달: `_open_investments()` — 9449 (trade/holdings/market/bank 데스크). 데이터: `GameState.market_prices`(8990/9300/9393), `price_history`(8445/9327), `market_context`(8405-07: cycle/fear_greed/crash_risk, 8977-82).

**구현 순서**
1. 주 시작 시 `ticker_rtl` 등락 스윕 모션(± 항목 순차 하이라이트, Tween 1회 ≤0.6s).
2. 보유 자산 시 상단 자산 라벨 주간 ± 색 펄스 1회(키는 1221-38에서 확인).
3. 뉴스 직후 다음 주 티커의 해당 자산 행에 뉴스 마커(·) — NewsManager 영향 경로에서 자산 id를 얻어 GameState에 1주 기록(새 var면 serialize).
4. Market 페이지 스파크라인 색 강조(차트화 과투자 금지).

**함정**: 예측 정보 공짜 금지 — Market Analysis 게이트(investment_skill≥50) 유지. 장식이지 치트 아님.
**검증**: `ScreenshotQA --qa=invest-en`, `--qa=ap-en`.

## [x] P1-4. 유물 오브젝트 아트 — 유물 하나하나 이미지 필수 (유저 지시 2026-07-08) (2026-07-10 Codex 완료)

완료: `assets/items/artifacts/`에 유물 6종 오브젝트 스틸 SVG를 추가하고 `ImageRegistry.ITEM_ART` / `get_item_art(id)`로 등록했다. Info Deck `Items/Keepsakes` 탭은 유물 썸네일 슬롯을 표시하며, 유물은 `Auto-active` 대신 `Keepsake`로 표면화한다. Claude 웨이브 3b의 유물 제시 UI와 엔딩 리캡은 같은 `get_item_art(id)` API를 재사용하면 된다. `Godot --headless --import`, `CompileCheck`, `ScreenshotQA --qa=ap-en`, `git diff --check` 통과.

> 유물은 이 게임의 기억 물성이다 — 소지품 탭 텍스트 카드로는 반쪽. **6종 각각 단독 오브젝트 스틸 1장씩.**
> 파이프라인: 외부 생성 → Gangnam Ink 그레이딩(P0-0과 동일 게이트). 구도: 어두운 바닥/무광 배경 위 오브젝트 단독, 물성(종이 질감·액정 빛·명함 모서리 해짐) 강조. 인물 얼굴 금지(기억은 물건으로만).

**아트 리스트 (`content/items.json`의 6종과 1:1)**
1. `artifact_sangchul_card` — 임상철의 명함(뒷면 손글씨 번호가 살짝 보이는 각도)
2. `artifact_daeun_note` — 냉장고 포스트잇("잘 챙겨 먹어요" 세 글자, 자석 자국)
3. `artifact_father_call` — 통화기록 스크린샷(폰 액정, "아버지 · 23초")
4. `artifact_jiyeon_text` — 첫 문자(말풍선 하나, 새벽 시간 표시)
5. `artifact_jaehyuk_photo` — 포장마차 셀카(취한 두 남자, 플래시 번짐)
6. `artifact_hyunsu_card` — 현수의 명함(빳빳한 새 명함 — 상철 명함과 대비되는 물성)

**배선 표면 (Claude 웨이브 3b와 동기)**
- 소지품 탭 유물 카드(`MainGame._refresh_inventory` 계열, 4392행 근처)에 썸네일 슬롯.
- **유물 제시 UI**(웨이브 3b 신규 — 대면 장면에서 "(…무언가 꺼내 보인다)" → 보유 유물 목록): 목록 항목에 이미지 필수. 이 UI가 이 아트의 주 무대.
- 엔딩 리캡 "간직한 것들" 줄(웨이브 3b)과 회상 갤러리(P2-5.7) 재사용.
- 선물 8종 아이콘화는 T2(이모지 유지 가능 — 유물이 우선).

**수용 기준**: 6종 전부 동일 그레이딩·동일 구도 문법(시리즈로 보여야 함). ImageRegistry 등록 + semantic audit mirror 동기.

## [x] P2-4. 잔인한 통계 리캡 카드 (클립/공유용) (2026-07-10 Codex 완료)

완료: 텍스트 원장을 `GANGNAM DREAM / THE TIME LEDGER` 가로형 기록 카드로 승격했다. 돈·사람에 쓴 주를 큰 숫자와 비율 바로 대비하고, 가장 가까운 인물에게 먼저 연락한 횟수(0 포함)와 마지막 연락 시점을 같은 프레임에 남긴다. 정식 엔딩은 엔딩명/등급, 데모는 6개월 스탬프를 표시한다. moral/tint 수치나 평가 어휘는 노출하지 않는다. `ScreenshotQA`는 해당 카드로 자동 스크롤한 전용 KR/EN 컷을 남긴다.

**코드 앵커 (실증)**
- **텍스트 1차 이미 존재**: `_ending_time_ledger(parent)` — MainGame.gd:10874. 라인: "돈에 쓴 주 {m} · 사람에게 쓴 주 {h}"(10879, 합≥8 게이트) / "{p}에게 먼저 연락한 횟수: {n}회"(10887, `GameState.contact_counts`) / "마지막 연락은 {w}주 전이었다"(10891, 24주+ 게이트). 타이틀 "시간의 기록/The Time Ledger"(10898).
- 엔딩 모달: `_show_ending(ending_id)` — 10388 (CG 프리뷰 10430 / 무드카드 10432 → 한줄요약 `_ending_run_summary` 10434 → dik 설명 10437-43 → 인연 에필로그 10445 → **시간의 기록 10447** → 스탯 그리드).
- 데모 종료: `_show_demo_ending()` — 10174 (플래그 기반 story_lines 개인화).
- 데이터: `contact_counts`/`last_contact_turn`/`money_weeks_total`/`human_weeks_total`/`grind_streak_weeks`, cast affinity/stage, 결혼·이혼·사별 플래그.

**구현 순서**: ①시간의 기록 라인들을 **공유 특화 비주얼 카드 1장**으로 승격 — Gangnam Ink 톤, 로고+엔딩명+통계 3~4줄, 가로형(스크린샷 1장=광고) ②`_show_demo_ending`에 6개월판 동일 카드(위시리스트 CTA 옆) ③기존 텍스트 블록은 카드로 흡수 또는 하단 유지.
**함정**: 평가 어휘 금지(기록>지시). "0회"도 그대로(그게 잔인함의 본체).
**검증**: `ScreenshotQA --qa=endings-en --lang=ko/en`, 데모 종료 스코프.

## [x] P2-5. 오디오 moral-shift (레버⑤) (2026-07-10 Codex 완료)

완료: BGM 두 플레이어만 `GangnamDreamBGM` 전용 버스로 분리하고 `moral_tint_changed`의 **stage 전이 때만** 2.4초 low-pass/버스 레벨 전이를 적용했다. Gray/White/menu는 전대역, Black 1단계는 4.8kHz, Black 2단계는 1.45kHz로 닫힌다. 같은 밴드 안의 연속 norm 변화는 재발동하지 않으며 재생 위치·앰비언스·SFX는 유지된다. 선택적 `bgm_theme_neutral/dark/white.ogg` 3변주 팩은 세 파일이 모두 있을 때만 자동 사용하고, 부분 납품은 `AudioAssetCheck`가 차단한다. 제작 스펙은 `assets/audio/AUDIO_PROMPTS.md` v11.

**코드 앵커 (실증)**
- BGMPlayer(autoloads/BGMPlayer.gd): 듀얼 플레이어 크로스페이드 구조 있음 — `_player_a/_player_b`(51-52), `_FADE_TIME=2.5`(59), `TRACKS`(6)/`AMBIENCE_TRACKS`(16). 컨텍스트 선곡 `update_context()`(107), 엔딩 `on_ending(ending_id)`(114), 앰비언스 `set_ambience(key)`(137)/`clear_ambience()`(158)/`update_event_ambience(ev)`(131)/`update_idle_ambience()`(119).
- 시그널: `GameState.moral_tint_changed(norm: float, stage: int)` — shift_moral_tint 말미 emit. 구독 패턴 예시: StoryMode `_on_story_moral_tint_changed`(StoryMode.gd:96).

**구현 순서**: ①BGMPlayer가 moral_tint_changed 구독 — **stage(밴드) 전이 시에만** 반응(연속 norm 반응은 과민) ②외부 트랙 전 임시: 어둠 밴드에서 low-pass/볼륨 레이어(오디오 버스에 AudioEffectLowPassFilter) 또는 어두운 기존 트랙 크로스페이드 ③외부 메인 테마+3변주 도착 시 `TRACKS["theme_neutral"/"theme_dark"/"theme_white"]` 슬롯 교체만 하면 되는 구조.
**함정**: 밴드 전이 시 **재시작 금지** — 크로스페이드만(_FADE_TIME 재사용). `on_ending` 스팅어 경로와 충돌 주의.
**검증**: `BGMContinuityCheck`(전이 시 재시작 없음), `AudioAssetCheck`, 수동: tint −20 돌파 청감.

## [x] P2-5.5 씬 연출 디렉션 키 (2026-07-10 Codex 완료)

완료: StoryMode가 KR 이벤트 소스의 `direction`을 읽어 느린 타이핑/문단 beat, 앰비언스 cut·duck, 의미별 원샷 reveal·loss·cold, 배경 전용 slow zoom·drift, 최대 2초 선택지 hold를 렌더링한다. 일반 진행 입력은 slow/beat를 건너뛸 수 있고 hold만 대본 범위에서 잠깐 잠근다. 정점 16장면에 배선했으며 `SceneDirectionCheck`가 hold·camera·beat·sting·duck 복원과 BGM 연속성을 검증한다. 작업 중 발견한 `DataRegistry.EVENT_PATHS` 누락 27개도 전부 복구했고, 앞으로 디스크의 이벤트 JSON과 등록 목록이 어긋나면 audit가 실패한다.

**정본**: `docs/SCENE_DIRECTION.md` — 스키마(pace/beat·amb cut/duck·sting 3종·camera Ken Burns·hold≤2s) + 규율(전체 ~5% 이하, 풀스택 런당 3~4회, 스킵 항상 허용) + **정점 16장면 연출 대본**(상철 대면·아버지 임종·이혼 풀스택 3장면). 구현 순서는 그 문서 4절.

**코드 앵커 (실증)**
- 타이핑 엔진: `_start_typing(full_text)` — StoryMode.gd:788, 진행 `_process(delta)`(796), `_typing` 플래그(24). pace/hold 훅 지점.
- 배경: `_bg_img: TextureRect`(StoryMode.gd:33) — camera는 이 노드 scale/position Tween. 배경 로드 677-682. 그레이딩 셰이더 로드 305-310(`background_grade.gdshader`) — Tween과 머티리얼 공존 확인.
- 사운드: `BGMPlayer.set_ambience/clear_ambience`(위 앵커). sting=AudioManager 원샷(`AudioManager.play(key)`, 키 등록 `_load_sounds` AudioManager.gd:92).
- audit: `tools/audit.py` `EVENT_ROOT_KEYS` 410행에 `"direction"` + 필드/값 화이트리스트 검사 추가.

**함정**: direction 키는 KR 소스에만(EN 오버레이 text-only 원칙). 어떤 연출도 스킵 입력을 막지 않는다(hold ≤2s만 예외). **대본 16장면에 키를 넣는 것과 렌더러 구현은 같은 커밋에서**(키만 먼저 넣으면 audit 미지 키 ERROR).
**검증**: `ScreenshotQA --qa=story-en` + 대면/프로포즈 수동 확인, `BGMContinuityCheck`(sting이 BGM 재시작 안 함), audit ✅.

## [x] P3-6. 서울 지도 허브 M1 (2026-07-10 Codex 완료)

완료: 기존 ACTION RAIL의 높이·카드·패드 포커스를 그대로 유지하고, 중복 ACT 설명이 있던 헤더 중앙을 8노드 `SEOUL TRACE`/`서울 동선`으로 교체했다. 현재 주 방문 장소는 돈/사람 시간의 작은 온도 차로, 최근 동선은 잉크 선 잔흔으로, 미해금 지하·정선은 흐린 노드로 보인다. 강남 노드는 자산 30억 진행만큼만 선명해진다. AP 행동 장소 기록은 `GameState`에 구조화해 StoryMode 왕복과 저장/불러오기에서 유지하고 주 종료 때 현재 주 점등만 초기화한다. 투자 매수·매도는 정본대로 장소 점등 없는 폰 행동이다. `SeoulTraceCheck` 및 KR/EN `ScreenshotQA --qa=ap-en` 통과.

**M2 상태**: 장소를 직접 선택해 기존 레일 시트를 여는 내비게이션 전환은 M1 실제 체감 또는 데모 피드백 뒤 판정한다. 클릭 깊이와 초견 패드 조작을 바꾸므로 자동 착수하지 않는다.

**정본**: `docs/MAP_HUB_PROPOSAL.md` — 판정: 레일 **대체가 아니라 프레임**(장소→기존 레일 카드 시트). M1 컨텍스트 레이어(잉크 미니맵 스트립, 리스크 0) → M2 장소 내비게이션. 장소↔행동 매핑 정본 포함(투자는 폰 오버레이 — 장소화 금지). **유저 승인 대기: M1 즉시 / M2는 M1 체감 후.**
**앵커**: M1 스트립 삽입 지점 = `_render_week_focus_panel` MainGame.gd:4880. 조작 모델 = `docs/CONTROLLER_UX_STRATEGY.md`.

## [x] P3-7A. 엔딩 CG 런타임 그레이딩·계약 (2026-07-10 Codex 완료)

완료: 인라인 엔딩 CG TextureRect도 전체화면 배경과 동일한 `background_grade.gdshader`의 현재 moral 파라미터 복제본을 사용한다. 일반 강남 CG를 임시 공유하던 `gangnam_dream_white`는 연결을 제거해 전용 White 컷 입고 전까지 정합한 S+ 무드카드로 끝난다. `CGRuntimeCheck`는 모든 엔딩 CG가 1280×720 이상인지, 유효한 ImageRegistry 경로인지, 두 엔딩이 같은 컷을 공유하지 않는지, 인라인 프리뷰가 올바른 셰이더를 받는지 검사한다. EN 엔딩 QA에 White 엔딩을 추가했다.

**남은 아트 제작**: `docs/ENDING_ART.md` P0 신규 CG 8종은 외부 생성/큐레이션/정합성 게이트를 통과한 파일이 입고될 때 연결한다. 전용 컷 없는 상태에서 다른 엔딩 CG를 임시 재사용하지 않는다.

**코드 앵커 (실증)**
- CG 결정: `_get_ending_cg_path(ending)` — MainGame.gd:10866 (`ending["cg"]` id → `ImageRegistry.get_cg`).
- 인라인 프리뷰: `_add_ending_art_preview(parent, art_path, is_cg)` — 10565. **발견된 갭: 이 TextureRect에는 그레이딩 셰이더 미적용.** CG가 `event_bg`로 깔릴 때(10400-02, modulate 0.50)만 `_moral_bg_material`(생성 790행, `background_grade.gdshader`)을 받는다.
- 전역 그레이딩: `_apply_moral_surface_shader`(420 — bg 파라미터 433-45, 초상 465-77), 풀스크린 `_moral_surface_material`(871-885, `moral_surface.gdshader`).

**구현 순서**: ①`docs/ENDING_ART.md` P0 큐(결혼식·gangnam_dream·lonely_rich 우선) 외부 생성→큐레이션→그레이딩 통과 ②**인라인 프리뷰에도 `_moral_bg_material` 계열 적용**(위 갭 수리 — 스타일 통일 보장) ③`docs/PRODUCTION_ASSET_PIPELINE.md` Gate.

## [x] P3-8. 플래시포워드 셰이더 강제 (2026-07-10 Codex 완료)

완료: `story_flashforward`에 풀스택 direction(`slow/cut/cold/slow_zoom/hold=1.5/visual=black_future`)을 배선했다. `visual=black_future`는 StoryMode의 장면 로컬 norm만 −0.80으로 사용하며 `GameState.moral_tint`와 세이브는 건드리지 않는다. 2031 장면의 현재시점 HUD를 숨기고, 본문과 맞지 않던 강남 거리 배경을 펜트하우스 실내로 교정했다. 기존 `player_suit` 초상은 배경과 분리한 무명/무안면 실루엣으로만 합성한다. `story_arrival` 로드 시 override·HUD·초상 이름/색이 같은 프레임에 Gray로 복원된다. `FlashforwardVisualCheck`와 `ScreenshotQA --qa=story-en` 통과.

**코드 앵커**: `story_flashforward`(content/events/story_events.json 선두, 프롤로그 큐 선두 배선 — `_begin_month_story_and_render()` turn-1 분기, `follow_up_event: story_arrival` 체인). StoryMode moral 반영: `_story_palette()`(102)/`_apply_story_surface_palette`(148)/배경 그레이딩(305-10) — 전부 GameState.moral_tint 기반.
**할 것**: 이 씬 재생 동안만 **tint −80 상당의 시각 상태 강제** — StoryMode에 씬-로컬 오버라이드 파라미터(셰이더 파라미터만 변경) + `story_arrival` 컷백 시 원상 복귀. SCENE_DIRECTION 렌더러(5.5) 후엔 이 씬에 풀스택 direction 예약.
**함정 (중대)**: `GameState.moral_tint`를 임시로 바꾸는 구현 **금지** — 그 사이 autosave가 돌면 세이브가 오염된다. 시각 레이어에서만 해결.

---

## 공통 검증 (모든 항목)
```bash
GODOT=<경로> ./tools/audit.sh          # 마지막 줄 "✅ 감사 통과"
python3 tools/english_hangul_audit.py  # content_issues=0, runtime_candidate=0
xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=<해당 스코프> --lang=en
```
- 완료 시 CLAUDE.md 현재 상태 + docs/WORK_LOG.md 갱신, 이 파일 해당 항목에 `[x]`+날짜.

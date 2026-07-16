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

> **빈 손 금지 사다리 (2026-07-15 유저 지시 — "노는 토큰 없게")**: 현재 오더가 대기/차단되면 즉시 다음 순서로: **24(정점 체인) → 16(입력×해상도) → 18(부채 인벤토리) → P1-4 유물 오브젝트 아트 6종 → P1-E 잔여 결산 CG(orthodox_pinnacle→burnout→무드 심벌 잔여 8종→「그녀는 알고 있었다」 1컷) → 15(모드 2층) → 17(데이터 모딩)**. 유저 Round 판정 도착 시 모든 것에 우선해 데모 재수리.
> **🔁 데모 집중 체제 (2026-07-14)**: 모든 오더에 데모 우선 필터 — ORDER-22는 **데모 범위(t≤24)에 먼저 적용·빌드**하고 유저 라운드에 태운다(전 범위 확산은 그 다음). 유저 데모 GO 전까지 21(번역 본문)·11(트레일러 최종컷) 동결 유지. 라운드 원장 = `docs/DEMO_FIXLOG.md`.

#### [x] USER-P0 [P0·정합 인프라] 서사 규칙 원장 + 원격 대화 공간 연출
**착수 (2026-07-16 Codex) — 만지는 파일:** `content/meta/story_rules.json`, `locale/ui_ja.json`, `autoloads/DataRegistry.gd`, `scenes/StoryMode.gd`, `tools/story_consistency_audit.py`, `tools/StoryPresenceCheck.gd`, `tools/StoryPresenceCheck.gd.uid`, `tools/StoryPresenceCheck.tscn`, `tools/ScreenshotQA.gd`, `tools/audit.sh`, `docs/STORY_CONSISTENCY_SYSTEM.md`, `docs/ASSET_CONTINUITY_CHECKLIST.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 느슨한 불린 플래그를 즉시 런타임에서 교체하지 않고, 언어 독립 원장에 `requires/forbids/produces`·타입 상태·장소·대화 채널을 먼저 등록한다. 데모 아버지 연락은 `in_person/phone/video_call/message/memory/narration` 계약을 StoryMode가 소비하게 해, 고시원 배경에 아버지 전신이 현장 등장한 것처럼 보이는 오해를 없앤다. 정적 감사·런타임 검사·KO/EN 1280×800 비교 캡처로 대면 초상 회귀와 영어 누출까지 같이 잠근다. 전체 감사가 새 채널 표면의 일본어 사전 누락을 잡으면 같은 계약 범위에서 보완한다.

**완료 보고 (2026-07-16 Codex):** `story_rules.json`에 타입 상태 3축, 상호배타 결과 3그룹, 데모·핵심 아크 45/1,500건의 선행·배제·생산·장소·대화 채널 계약을 등록했다. 논리 계약 15건과 통화·영상통화·문자·회상 34건을 감사하며, 비주인공 초상이 붙은 통신 의심 장면의 미분류 허용치는 0으로 잠갔다. StoryMode는 원장을 읽어 아버지 같은 원격 화자를 작은 우측 프레임과 `통화 중/VOICE CALL` 명패로 분리하고, 문자 속 민준은 현장 큰 초상, 회상은 낮은 불투명도 인셋, 실제 대면은 명패 없는 큰 초상으로 복귀한다. 한국어·영어 1280×800 각 5컷을 육안 확인했고 일본어 준비 사전 7키도 보완했다. `STORY_PRESENCE_CHECK_OK phone=remote message=local memory=inset in_person=full en=clean`, `STORY_CONSISTENCY_AUDIT_OK events=1500 ledger=45 logic=15 remote=34 unclassified=0`; 전체 audit는 ERROR 0/WARNING 0, 영어 누출 0, 일본어 UI 2,044키, 밸런스 전 정책, 오디오·CG 계약, 57개 GDScript 컴파일까지 통과했다. 저장 호환 플래그의 즉시 치환은 하지 않았으며 다음 이관은 데모 선행조건부터 단계적으로 진행한다.

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
**발견 보존(유저 정본 2026-07-16)**: 색/소리/dik 등 메커니즘을 자막으로 설명 금지 — 컷은 흐르되 이름 붙이지 않는다(느끼게만). 컷4 자막은 정서 선언까지만.
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

#### [x] ORDER-20 [P1·수리] 엔딩 감사 판정 집행 — 사실 정렬 6건 — 완료 2026-07-13
`docs/ENDING_AUDIT.md`의 "Claude 판정(2026-07-13)" 그대로: ①jiyeon_man 첫 문장("한지연의 강남에" 결) ②second_love 10억 현실화 ③gangnam_dream에 startup_exit 경로 dik 1종(KR+EN, 라우팅 불변) ④retirement 2종 미래 전망 프레임 ⑤orthodox_pinnacle 숫자 정렬 ⑥무드 카드 12종 → 전용 결산 카드 심벌(빈도순: ordinary_life→burnout→mental_break→stable_success 우선). 전부 라우팅 불변 — ending_distinctness_audit 게이트 통과 확인.

**완료 보고 (2026-07-13 Codex):** 여섯 사실군을 실제 38세·10억원·30억원 라우팅에 맞춰 한영으로 교정했다. `jiyeon_man`은 지연의 강남, `second_love`는 강 건너 집, 은퇴 2종은 38세 현재와 미래 퇴직, `orthodox_pinnacle`은 10억원으로 정렬했고, 30억원 이상 창업 엑싯은 `gangnam_dream` DIK가 회수한다. 라우팅·ID·조건은 불변이다. 상위 4 결산에 서로 다른 전용 심벌을 연결했으며 한영 `ending-p0`·`endings-en` 실제 렌더, EN 커버리지·한글 누출 0, 엔딩 사실/심벌 감사와 전체 audit를 통과했다. 범용 카드 잔여 9종은 후속 P1-E로 남겼다.

#### [~] ORDER-21 [P1] 일본어 번역 웨이브 — ⛔ 부분 보류 (Claude 판정 2026-07-13, 유저 지시)
**보류 범위: 본문 번역(`content/events_ja/**`·`endings_ja`) 생성 중단.** 사유: 유저가 데모 체감 미완을 제기 — 데모 피드백 수리가 Y1 텍스트를 다시 쓸 수 있어 지금 번역=재작업. **계속 허용(인프라성)**: 용어집·호칭 정본표·폰트 번들·파이프라인/게이트 도구·ui_ja 표면 사전. **본문 번역 재개 조건: 유저의 데모 GO 판정** (실플레이 후). 이미 생성된 본문이 있으면 커밋은 유지하되 계속 생성하지 말 것.
**인프라 착수 — 만지는 파일:** `docs/I18N_GLOSSARY_JA.md`, `locale/ui_ja.json`, `assets/fonts/NotoSansJP-*`, `assets/fonts/OFL-NotoSansJP.txt`, `autoloads/FontKit.gd`, `autoloads/UIStyle.gd`, `tools/i18n_coverage_check.py`, `tools/multilingual_surface_audit.py`, `tools/ja_translation_pipeline.py`, `tools/ja_translation_audit.py`, `tools/I18nInfrastructureCheck.gd`, `tools/ScreenshotQA.gd`, `tools/audit.sh`, `docs/I18N_INFRASTRUCTURE.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
1. **선행 산출물**: `docs/I18N_GLOSSARY_JA.md` — 용어집(고시원=コシウォン(gloss)/전세/9급/라면=ラーメン 등) + **호칭 정본표**: 다은→"ミンジュンさん"+です・ます체(진심의 격식) / 지연→"オッパ"(オッパ 표기 유지)+タメ口는 연애 확정 후(도도·직설 — 그 전엔 です체) / 민준→두 여성에게 です・ます 기조. 부끄러움 문법 주석 포함.
2. **번역**: KR 원본 기준(EN 아님 — 중역 금지), events_ja/ 오버레이 + endings_ja + ui 사전. 산문 밀도 유지(§8 톤 — 축역 금지), dik 패리티 필수.
3. **검증**: 언어 일반화된 coverage/패리티 게이트 + ScreenshotQA ja 표본 15컷(줄바꿈·글리프).
4. **네이티브 스팟체크 게이트**: 핵심 20씬(§8 레지스트리) 목록을 뽑아 유저에게 전달 — 네이티브 검수자 확보는 유저 몫. 검수 반영 전까지 "베타 번역" 딱지.
5. zh-CN 웨이브는 ja 파이프라인 검증 후 별도 오더.

**인프라 진행 보고 (2026-07-14 Codex):** 공식 Noto Sans JP 가변 TTF와 OFL을 번들하고 프로젝트 폰트 폴백으로 연결해 히라가나·가타카나·한자·문장부호 실글리프와 1280x800 줄바꿈을 통과했다. KR 정본 직역 파이프라인은 기본 UI 전용이며 `events/endings/catalog`은 명시적 `--allow-body` 없이는 `BODY_TRANSLATION_HELD`로 실패한다. UI 표면 1,957개를 원문 대조 교정해 `ui_ja` 베타로 채우고 한글·엔화·자리표시자·줄바꿈·호칭·도박/트리플·잠금/해금 극성 감사를 전체 audit에 연결했다. 일본어는 여전히 선택 화면·Steam에서 비노출이며, 이벤트·엔딩·카탈로그 본문과 15컷·네이티브 검수는 유저 데모 GO 전까지 보류한다. 따라서 ORDER-21은 `[~]` 유지한다.

#### [~] ORDER-23 [P0·데모] 동기 각인 수술 — "읽게 하지 말고 하게 하라" (유저 진단 2026-07-14: "왜 30억을 모아야 하는지 모르겠다")
**착수 (2026-07-14 Codex) — 만지는 파일:** `content/events/story_events.json`, `content/events_en/story_events.json`, `content/events/arc_drama.json`, `content/events_en/arc_drama.json`, `content/events/amb_scenarios6.json`, `content/events_en/amb_scenarios6.json`, `scenes/StoryMode.gd`, `scenes/MainGame.gd`, `locale/ui_ja.json`, `tools/MotivationImprintCheck.gd`, `tools/MotivationImprintCheck.gd.uid`, `tools/MotivationImprintCheck.tscn`, `tools/ScreenshotQA.gd`, `tools/audit.py`, `tools/audit.sh`, `tools/en_coverage_check.py`, `tools/i18n_coverage_check.py`, `tools/first_session_pacing_audit.py`, `docs/STORY_BIBLE.md`, `docs/DEMO_FIXLOG.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 새 이미지를 생성하지 않고 정본 `dad_house`·`community_center`·`street_rainy_bus_stop_wallet` 배경을 재사용한다. 자동 게이트 완료 후에도 수첩 문장 회상 여부는 유저 라운드 질문으로 판정하며, GO 전에는 `[x]`로 닫지 않는다.
**자동 구현·검증 보고 (2026-07-14 Codex — 사용자 재플레이 대기):** 콜드오픈 뒤 「무릎」 3장면과 「마지막 상환」 3장면을 넣어 과거·오늘·내일의 민준을 정하는 3×3 선택을 실제 플래그로 남겼다. 선택별 기억은 아버지 고백·상철 대면·보증 부탁에서 다시 읽히며, 고른 수첩 문장은 AP 목표줄·수첩 모달·몽타주·월말 결산에 경과 개월과 함께 반복된다. 데모 아버지 접점은 11·15·21주에 고정했다. `MotivationImprintCheck`는 `chain=9 identity=9 readers=9 motives=3 father_contacts=3`, 첫 세션 감사는 108경로·정확한 12장면·최대 80문단/12확인/172빠른입력·첫 선택 5번째 장면을 통과했다. 한영 1280×800 `--qa=motivation-imprint` 7컷씩을 육안 확인했고, 24주 실입력 데모는 각각 1,214/1,211회 입력·59개 사건·CTA까지 완주했다. 새 기억 텍스트 키의 다국어 패리티도 등록했으며 전체 audit는 `ERROR 0/WARNING 0`, 영어 누출 0, 밸런스 전 정책, 오디오 68개, 활성 이미지 179장, 57스크립트 컴파일까지 통과했다. 사용자가 수첩 문장을 기억하는지는 자동화할 수 없으므로 `[~]`를 유지한다.
> 발견: 동기(아버지 보증 빚 6년·사기로 날아간 강남 집·아버지의 시간=5년)는 프롤로그 4씬에 전부 존재 — 문제는 ①내레이션으로 스쳐감(행위 없음) ②이후 게임이 재호출 안 함. 각인=행위, 기억=반복 호출. (+유저가 Continue로 진입해 프롤로그 자체를 못 봤을 가능성 확인 중 — 결과 무관하게 본 오더 유효)
**A. 프롤로그 각인 전환 — 점화 장면 「무릎」 확정 (유저 선택 2026-07-14: B안)**
1. **점화 플래시백 「무릎」** (story_arrival의 "아버지가 보증을 잘못 섰다…6년" 요약 단락을 장면으로 대체):
   - 스물일곱의 민준. 사기 직후, 아버지 집. 민준은 현관/문틈에서 본다 — **아버지가 바닥에 무릎을 꿇고 있다.** "미안합니다. 갚겠습니다." 같은 말을 반복하는 아버지. 채권자들은 화내지 않는다 — **지루해한다**(무심함이 잔인함, 설교 방지 5원칙: 악을 연기시키지 말 것). 탁자 위 보증 서류.
   - **첫 정체성 선택 (플레이어)**: ①뛰쳐나가 아버지를 일으킨다(흔적: 그날 아버지 눈을 정면으로 봤다) ②문 뒤에서 주먹만 쥔다 — 나설 돈이 없었다(흔적: 그날 자신이 제일 미웠다) ③등을 돌린다 — 차마 볼 수 없었다(흔적: 그날을 기억에서 지우려 했다). 각 선택=미세 route/tint 씨앗+흔적 플래그 `knee_day_*` — **독자 필수 2곳+**: 아버지 진실 국면(t26+) dik, 상철 대면 dik("그 무릎을 만든 손"), 가능하면 아버지 별세/화해에도.
   - 연출: 이 장면 앰비언스 완전 컷(무음) — ORDER-22 오디오 문법과 연동. 산문은 §8 루브릭(감각 구체: 장판의 냉기, 아버지 뒤통수의 흰머리, 문틈의 폭).
2. **점화 현재 장면 「마지막 상환」 (유저 승인 2026-07-14: A+B 콤보)**: 6년 요약 대신 마지막 상환 날의 실제 장면 — 추심 사무소/은행 창구. 마지막 이체를 확인한 남자가 서류를 넘기며 지나가듯: **"아버님께 전하세요. 보증은 아무나 서는 게 아니라고."** (화내지 않음 — 무심함 유지)
   - **두 번째 정체성 선택 (플레이어)**: ①고개 숙이고 나온다(생존 — 참는 법을 배운 6년) ②"말씀이 지나치시네요."(신념 — 아직 꺾이지 않음) ③웃어 보인다(증명 — 두고 보라는 웃음). 흔적 플래그 `last_payment_*`, 독자 1곳+ (빚/대출 계열 이벤트 dik 또는 재혁 보증 거울 장면 dik — "같은 자리"의 재독).
   - 나오는 길: 정류장 스크린에 강남 아파트 분양 광고 1컷(말 없이 — 기록>지시). 잔고 50만원 표시.
   - 「무릎」(6년 전)과 이 장면(오늘)이 수미상관 — 무릎을 본 자가 이제 자기 발로 서서 같은 종류의 시선을 받는다.
3. **수첩의 주어 교체** (기존 스펙 유지): 목표 문장을 플레이어가 고른다 — ①"아버지가 그 거실에 서는 걸 본다"(가족) ②"우리를 무너뜨린 세계에 내 이름으로 선다"(증명) ③"다시는 돈 앞에 무릎 꿇지 않는다"(생존 — **무릎 장면과 직결**). 문장 저장→B항 재호출 시스템으로.
3b. **장면 체감 길이 (유저 정본 2026-07-14)**: 「무릎」과 「마지막 상환」은 각각 **체인 2~3이벤트**로 — 단일 이벤트+선택 1개 금지. 무릎: 도착(낌새)→목격(정적 속 반복되는 사죄)→선택①+여파. 마지막 상환: 대기(번호표·마지막 서류)→그 한마디→선택②+정류장 광고. 대화 왕복과 침묵 비트 포함, 체감 각 2~3분. §8 "장면 체감 길이 표준" 준수.
4. 흐름 확정: 콜드오픈(2031) → 고시원 기상 → **「무릎」 플래시백+선택①** → **「마지막 상환」 모욕+선택②** → 아버지 전화(담담함이 이제 아프게 읽힘) → 수첩 문장 선택③ → 삼각김밥. 정체성 선택 3연타(무릎의 나→오늘의 나→내일의 나)가 프롤로그의 뼈대. 각 장면 반 페이지 이내 — 총 프롤로그 5~7분 유지. 데모 훅 자산(콜드오픈·t4 타이머) 불변.
**B. 동기 재호출 시스템 (표출 수리, 데모 우선)**
3. 골 바 툴팁/옆에 **내가 적은 수첩 문장** 상시 노출 — 목표가 스코어가 아니라 문장이 되게.
4. AP 화면에 수첩 오브젝트(클릭=내 문장+남은 주+아버지 상태 한 줄) — ORDER-22 시계·인박스와 통합 배치.
5. 월말 결산·몽타주 카드에 수첩 한 줄 리추얼("수첩을 폈다. {내 문장}. {n}개월째.").
6. 데모 구간(t≤24) 아버지 접점 3회 보장(기존 이벤트 게이팅 확인·재배치 우선, 신규 최소).
**검증**: 자동 게이트 + 유저 라운드 고정 질문: "민준한테 무슨 일이 생길지 궁금했는가 / 네 수첩 문장이 뭐였는지 기억나는가" — 후자 기억 못 하면 불합격.

#### [~] ORDER-22 [P0·체험 수리] 몰입 수리 — 주간 루프의 감정 설계 (유저 실플레이 판정 2026-07-14: "버튼만 누르게 되고 재미가 안 느껴진다")
**착수 (2026-07-14 Codex) — 만지는 파일:** `autoloads/GameState.gd`, `autoloads/EventManager.gd`, `autoloads/BGMPlayer.gd`, `autoloads/AudioManager.gd`, `scenes/MainGame.gd`, `scenes/StoryMode.gd`, `scenes/ArubaGame.gd`, `locale/ui_ja.json`, `tools/BGMContinuityCheck.gd`, `tools/ImmersionLoopCheck.gd`, `tools/ImmersionLoopCheck.gd.uid`, `tools/ImmersionLoopCheck.tscn`, `tools/ScreenshotQA.gd`, `tools/audit.sh`, `tools/arc_flow_sim.py`, `tools/audio_source_audit.py`, `tools/generate_audio_p1_assets.py`, `assets/audio/amb_*.wav`, `assets/audio/amb_*.wav.import`, `docs/DEMO_FIXLOG.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 자동 게이트 완료 후에도 유저 재플레이 GO 전에는 `[x]`로 닫지 않는다.
**범위 확장 (2026-07-14 Codex 블랙박스 재플레이):** 데모 W6의 편의점 야간 시프트에서 손님 슬롯이 마우스 전용 `Panel`이라 키보드·패드 진행이 막히고, 1280×800 표면 대부분이 빈 공간인 것을 실제 입력으로 재현했다. 같은 오더의 주간 루프 몰입 수리로 `scenes/ArubaGame.gd`를 추가 잠금한다.
**자동 수리 진행 보고 (2026-07-14 Codex — Round 2 재플레이 대기):** 최근 2주의 돈/사람/장소 행동을 저장해 같은 계열 사건에 최신 주 ×2.6, 직전 주 ×1.88의 에코를 주고, 조건 없는 저가치 필러는 ×0.42로 낮췄다. 강한 인과가 없는 주에는 결정론적 조용한 주를 허용하며, StoryMode 첫 문단에는 최근 행동 계열별 3변주 인과 프레임이 들어간다. AP 허브는 계절·시간·주거 구조가 맞는 주간 도입문, 1~3주 내 보장 아크의 짧은 기척, 월세 D-3주~이번 주 위협을 한 화면에 표시한다. 오디오는 상시 로파이를 폐기해 주거·계절 앰비언스를 기본 베드로 두고 일반 랜덤 사건은 음악 없이 유지하며, 아크는 3.2초 정적 뒤 BGM, 월말·엔딩은 구두점 BGM으로 분리했다. 고시원·원룸·아파트·여름·겨울 앰비언스를 재생성/추가하고 튀는 결과 SFX를 -2~-9dB 보정했으며 월간 전환음의 주간 오발도 막았다. 한영 1280x800 전용 3컷에서 도입·월세·인과 프레임의 잘림/중복을 확인했고, `ImmersionLoopCheck`·`BGMContinuityCheck`·영어 한글 0·양 경로 아크 완결·전체 audit(`ERROR 0/WARNING 0`, 57스크립트 컴파일)이 통과했다. **자동 검증은 끝났지만 재미 판정은 하지 않았으므로 `[~]` 유지 — 유저 Round 2 GO 또는 같은 오더 재수리만 남음.**
**Codex 사전 블랙박스 보강 (2026-07-14):** 콜드 부트부터 W6 편의점 추가 시프트까지 실제 입력으로 진행해, 마우스 전용 손님 `Panel` 때문에 패드 진행이 막히는 문제를 재현했다. 손님 3칸을 큰 포커스 카드로 바꾸고 선택→응대→다음 손님 포커스 복귀를 공통 UI 입력으로 연결했으며, 카드·편의점·배달 모드에 장소 배경/앰비언스와 한 화면 선택 보드를 적용했다. 한영 1280×800 실렌더와 실제 `ui_accept` 회귀, 전체 audit(`ERROR 0/WARNING 0`, 57스크립트 컴파일)이 통과했다. 이는 사용자 Round 2 판정이 아니므로 `[~]`를 유지한다.
**Codex AP 결과 수명 보강 (2026-07-14):** 실제 패드 입력으로 `휴식→확인→생계→절약`을 재생해, 자기계발·부업·절약·인맥·데이트가 결과 비네트를 만든 직후 AP 보드를 다시 그려 결과가 한 프레임 만에 사라지는 공통 결함을 확인했다. 다섯 경로의 조기 재렌더를 제거하고, 같은 주 안에서는 결과 확인 후 방금 선택한 상위 AP 카드로 포커스가 돌아가며 새 주에만 첫 카드로 초기화되게 했다. 한영 `--qa=ap-act-en`이 절약 결과 유지와 `생계` 포커스 복귀를 실제 `ui_accept`로 고정하고, 한영 24주 `--qa=demo-input --demo-build`은 각각 867/866회 입력·53개 사건·CTA 컷오프를 완주했다. 전체 audit도 `ERROR 0/WARNING 0`, 57스크립트 컴파일로 통과했다. 사용자 재미 GO 전이므로 ORDER-22는 `[~]`를 유지한다.
> 진단(Claude): 인과 단절 + 리듬 부재 + 오디오 톤 충돌. 콘텐츠·정합의 문제가 아니라 **루프의 감정** 문제. 수용 기준은 자동 게이트가 아니라 **유저 재플레이 체감** — 이 오더는 유저 GO가 나올 때까지 반복 수리한다. ORDER-11 트레일러 최종 조립은 이 오더 뒤로(오디오가 바뀌면 재작업).
**A. 인과 가시화 — 이벤트가 네 행동의 결과로 느껴지게**
1. **행동 에코 가중치**: EventManager 추첨에서 최근 2주의 행동 태그(투자/사람/구직/도박…)와 같은 계열 이벤트에 가중치 ×2~3. 몇 줄 수준 — 세계가 내 행동에 반응한다는 체감의 최저가 구현.
2. **인과 프레임 한 줄**: 조건 있는 이벤트 상위 ~60종의 도입부에 "왜 지금 이게 오는가" 1문장(예: 야근 주였다면 "사흘째 야근하던 주였다" — 최근 행동/상태 참조). 기존 dik 메커니즘 재사용 가능하면 재사용.
3. **순수 랜덤 필러 빈도 하향**: 조건 없는 저가치 필러의 주간 발생률을 낮추고 조용한 주는 조용하게(몽타주가 흡수) — 이벤트가 뜬다는 것 자체가 신호가 되게.
**B. 리듬·예감 — 다음 주를 기대할 이유**
4. **주 시작 상황 한 줄**: 매주 첫 화면에 계절·시간대·민준 상태 1문장(비네트 재사용) — 메뉴가 아니라 장면으로 열리게.
5. **예감 장치**: 보장 아크가 2~3주 안이면 AP 화면에 은은한 전조 1줄(내용 비공개 — "요즘 상철 씨 연락이 잦다" 결). 월세 납부일 D-표시는 위협으로 읽히게 강조.
**C. 오디오 톤 재정렬 — 소리로 장소를 짓는다 (유저 방향 확정 2026-07-14: 디제틱 앰비언스 전면화)**
> 원리: 음악=감정 지시(피로 누적), 앰비언스=장소감(몰입의 원료). 텍스트 게임은 후자가 본체다. 기존 앰비언스 25종+set_ambience 시스템을 전면 배치로 승격.
5.5 **장면=소리 장소**: 전 배경 id에 사운드스케이프 매핑 — 고시원(벽 너머 생활음·형광등 험)/편의점(냉장고 험·문 차임)/거리(차·행인 웅성임)/비 이벤트(빗소리 — **글에 비가 오면 귀에도 비가 온다** 규칙)/포장마차/사무실/카지노. 부족 자산은 앰비언스 우선 확보(라이선스 프리·생성 모두 가 — 앰비언스는 티 안 남).
5.6 **AP 허브도 장소다**: 주거 사다리가 소리로 — 고시원(옆방 기침·복도 발소리·얇은 벽) → 원룸(냉장고 험) → 아파트(정적). 계절(매미/겨울 바람)·시간대 레이어. 5년의 상승이 귀로 느껴지게.
5.65 **정점 체인의 소리 아크 (2026-07-15 추가 — 유저 사운드 지시와 결합)**: 체인이 2~4링크로 길어진 정점은 소리도 링크를 따라 진행한다 — 링크마다 같은 앰비언스 반복 금지. 예: 결혼식(로비 웅성임→행진곡→신랑석 링크에선 소리가 한 걸음 멀어짐), 무릎(생활 소음→문틈 너머 낮은 목소리→선택 순간 완전 무음), 대면(카페 소음→상철의 침묵과 함께 앰비언스 얇아짐). **정적은 가장 싼 클라이맥스 연출** — 체인 최종 링크의 결정 순간은 무음 우선 검토.
5.68 **moral 앰비언스 레이어 (유저 지시 2026-07-15 — "모랄에 따라 사운드 변화")**: 디제틱 앰비언스가 moral 밴드(시각 tint와 동일 경계 ±20/±60)에 반응 — 원칙: **어두워질수록 세상에서 사람 소리가 빠진다** (돈축/사람축의 청각 거울).
   - 밝음(stage 0+): 사람 계열 레이어(웅성임·대화·웃음·생활음) 선명, 무기질(냉장고 험·형광등·차) 배경.
   - 하강(stage -1): 사람 계열 -dB+로우패스(뭉개짐), 무기질 전면화, 자기 발소리 체감 증가.
   - 최심부(stage -2): 사람 소리 거의 소거 — 기계음+정적. 부자가 될수록 세상이 비어 들리게.
   - 구현: 신규 자산보다 **믹싱 규칙 우선**(앰비언스 버스 분리: human/inert 2계열 + moral 반응 볼륨/LPF — BGMPlayer moral 버스 패턴 확장). 전이는 주간 경계에서 점진(즉각 스위치 금지 — MORAL_TINT 주간 지각과 동일 문법). 회복 시 사람 소리가 돌아오는 것도 동일하게 점진.
   - **비노출 정본 준수**: 어떤 UI 표기도 없이 순수 질감으로만. 데모 범위(tint 스윙 존재) 우선 적용 → 유저 Round에서 "세상 소리가 변한 걸 눈치챘는가"를 히든 판정 문항으로.
5.69 **오디오 품질 계약 (2026-07-15 — "어중간한 소리는 없느니만 못하다")**:
   - **의심스러우면 무음**: 품질 확신 없는 소스·이음새 들리는 루프·톤 안 맞는 SFX는 넣지 말고 뺀다. 정적이 기본값인 우리 문법이 안전망 — 나쁜 소리 하나가 좋은 소리 열 개를 무효화한다.
   - **기술 기준**: 루프 심리스(크로스페이드 루프 필수), 장면 전환 크로스페이드 0.5~1.5s(연출적 컷 제외), 라우드니스 정규화(앰비언스 -28~-24 LUFS 대역·SFX 피크 상한 통일), 동시 앰비언스 레이어 2~3개 상한(과밀=진흙).
   - **귀 판정 게이트**: 자동 게이트는 배선·존재만 검증 — 최종 판정은 사람 귀. 유저 Round 사운드 4문(①이음새/반복 들렸나 ②튀는 소리 ③장소감 ④소리로 몰입 깨진 순간). 하나라도 걸리면 해당 소스 교체/제거.
5.7 **BGM 구두점 강등**: 상시 재생 중단 — 기본 베드=앰비언스+침묵, 음악은 아크·정점·월말 결산·엔딩에서만 진입(음악이 울리는 것 자체가 예감 신호가 되게). 로파이 상시 루프 폐지.
6. **로파이 정체성 재판정**: 절박·무너짐과 싸우는 트랙 식별 → 우선 처방은 교체가 아니라 **역학**: 잔고 위기·정신 저하 시 레이어 얇아짐/저음화(이미 있는 moral band 전이 확장), 아크 직전 3~5초 완전 침묵(정적이 최고의 예고), 시간대·연차별 트랙 로테이션으로 단일 루프 체감 제거.
7. **SFX 믹스 패스**: 전 UI 효과음 라우드니스 정규화(-6~-10dB 검토), 톤 이질 SFX 목록화·교체. "튀는" 순간 제로가 목표.
**C-2. 데모 정점 체인 확장 (유저 정본 2026-07-14)**: t≤24의 기존 정점을 §8 체인 표준으로 확장 — ①대포통장(t4): 접근→제안→12초 타이머→여파(현재 몇 비트인지 확인, 부족분 체인화) ②다은 첫 만남~초기 비트(t9~) ③chapter1_close(t8) ④SNS(t5). 전 범위 정점(결혼식·대면·첫 키스 등) 체인화는 **데모 GO 후** 동일 표준으로 확산.
**D. 검증**: 자동 게이트(기존) + **유저 데모 재플레이** — A~C 후 유저가 다시 완주하고 체감 보고. 불합격 항목은 이 오더 안에서 재수리(오더를 닫는 건 유저 GO뿐).

#### [~] ORDER-28 [P0·전범위/데모 우선] 전체 게임 재구성 — "240주의 시간을 50개의 결정으로" (유저 전권 위임 2026-07-16)
**측정·설계 착수 (2026-07-16 Codex) — 만지는 파일:** `tools/game_structure_audit.py`, `docs/GAME_RECOMPOSITION_PLAN.md`, `docs/AP_REDESIGN.md`, `docs/MASTER_RELEASE_AUDIT.md`, `docs/DECISIONS.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 이 선언 커밋 뒤에만 측정·설계 파일을 편집한다. 기존 사용자 변경 `project.godot`은 건드리지 않는다.
> 유저가 이 오더에 한해 콘텐츠 동결을 직접 해제하고, 난개발된 전체를 한 달 안에 작품성과 상품성 기준으로 재판정하도록 위임했다. 부분 기능 추가가 아니라 **주간 루프·챕터·모달·엔딩·오디오를 하나의 플레이 리듬으로 다시 편집**한다.
1. **측정 우선:** 1,505개 이벤트의 연차/주차/경로 밀도, 240주 중 직접 조작 주차, 메뉴·모달 깊이, 전략별 자산·엔딩·tint 발산, 5개 챕터의 setup→escalation→reversal→boss→aftermath를 기계 장부로 만든다. ORDER-26의 5아키타입 수렴 진단을 이 단계에 흡수한다.
2. **잠정 불변:** `turn=1주`, 5년=240턴, 기본 AP 2는 달력·희소성 규칙으로 유지한다. 단 플레이어에게 240회의 동일 조작을 요구하지 않는다. 저위험 주는 루틴/몽타주로 흐르고, 약 40~60개의 결정 주간만 직접 멈추는 구조를 데모 수직 슬라이스로 검증한다.
3. **새 표면 금지:** 신규 자원·탭·미니게임을 더하지 않는다. 필요한 새 계층은 기존 압박·이벤트·AP·후속을 편성하는 비노출 `Narrative Pressure Director` 하나뿐이며, 플레이어에게는 메뉴가 아니라 이번 주의 갈등과 포기 비용으로 보인다.
4. **챕터 보스:** 다섯 챕터마다 전투가 아닌 2~4링크 삶의 압박전을 둔다. 각 보스는 2~3개의 진짜 딜레마, 선택 전 예감, 선택 후 여파, 전용 음악 역할/정적 큐를 가지며 기존 정점 체인과 플래그를 우선 재사용한다.
5. **화면 감량:** 관계=현재 연락 가능한 사람 중심의 People/Phone, 뉴스=주간 헤드라인·시장 신호, 은행=Finance 내부, 선물=인물 행동 내부로 통합하는 안을 실제 클릭 수·패드 과업 기준으로 판정한다. 정보·도감·설정은 코어 루프 밖 Archive/Pause로 내린다.
6. **엔딩 순서:** 첫 공개는 CG/장면→여운→크레딧이고, 등급·통계·희귀도는 이후 기록 화면으로 분리한다. 35 ID 저장 호환은 유지하되 8~10개의 감정적 피날레 패밀리와 세부 변주로 읽히게 한다.
7. **실행 순서:** 측정/결정 문서 → 데모 24주 수직 슬라이스 → 실제 입력 블랙박스·패드·KO/EN → GO일 때만 5년 전체 확장. 데모가 재미없으면 전범위 코드 이식 금지.

**측정·설계 완료 보고 (2026-07-16 Codex):** `tools/game_structure_audit.py`가 1,505개 이벤트(작성형 328/랜덤 1,177), 대표 경로 117~120비트, 연차별 `46/29/14/16/12` 및 `46/27/16/19/12`, 몽타주 사용 시에도 최소 141~142 정지 주, 수동 진행 최대 480 AP 확정, 월말 모달 60회, AP 함수 42개 대비 루틴 대표 4개(9.5%), `_open_*` 표면 22개, 엔딩 35개/전용 CG 18개를 재현 가능하게 장부화했다. 평상 주 랜덤 사건은 수동 진행에서만 뽑히고 몽타주가 콘텐츠를 묵시적으로 생략하는 핵심 모순도 확인했다. 정본 처방은 `docs/GAME_RECOMPOSITION_PLAN.md`에 고정했다: 240주/AP2는 내부 시간으로 유지, Quiet/Echo/Decision/Boss 편성, 데모 8~10결정·2정점 우선, 전체 40~60결정·5보스, 분기/위기 결산, 장면 우선 엔딩. 전체 audit는 `ERROR 0/WARNING 0`, 57스크립트 컴파일, 영어 한글 0, 아크 잼 0을 통과했다.

**큐 실행 우선순위 (2026-07-16):** ①ORDER-28 구조 측정·결정 고정 ②ORDER-23/22는 자동 게이트 완료 상태를 보존하고 새 회귀만 수리 ③ORDER-26의 5아키타입 수렴 측정을 ORDER-28 데모 구현의 첫 게이트로 실행 ④ORDER-24의 남은 `arc_father_call_on_ktx` 확장 ⑤ORDER-27 스토어 톤 판정 ⑥UI 구조가 안정된 뒤 ORDER-16 ⑦전체 구조 잠금 뒤 ORDER-18 ⑧번역 확장 ⑨모딩은 데모 품질 이후. 현재 다음 착수는 ORDER-26 수렴 보고서이며, 수치 판정 전 주간 스케줄러를 넓게 수정하지 않는다.

#### [~] ORDER-24 [P1] 전 정점 체인 확장 — "모든 정점을 흥미진진하게 길게" (유저 지시 2026-07-14, Round 2 대기 중 백그라운드 실행)
**측정 착수 (2026-07-15 Codex) — 만지는 파일:** `tools/peak_scene_chain_audit.py`, `tools/audit.sh`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 먼저 §8 레지스트리의 실제 이벤트 ID·체인 링크·선택점·대화 왕복을 기계적으로 계수하고, 이미 2~4링크/2~3선택점을 갖춘 정점은 손대지 않는다. 콘텐츠 파일은 측정 결과로 첫 확장 대상을 확정한 뒤 별도 선언 커밋으로 추가한다.
**측정 완료 보고 (2026-07-15 Codex):** 정점 28개를 실제 StoryMode `follow_up_event` 경로로 전수 계수했다. 남산 다은·지연만 2링크/2선택점/대화 왕복 표준을 통과했고, 나머지 26개는 대부분 1이벤트/1선택점이라 확장 부채로 확정됐다. 긴 단일 이벤트를 완성된 체인으로 오인하지 않도록 패널과 대화도 함께 재며, KO/EN 선택지 수 패리티를 검증한다. 부채 상한 26과 남산 2경로를 전체 audit 래칫으로 연결했고 `ERROR 0/WARNING 0`, 밸런스·오디오·57스크립트 컴파일까지 통과했다. 판정표는 `docs/PEAK_SCENE_CHAIN_AUDIT.md`, 첫 확장 대상은 `arc_daeun_proposal`이다.
**다은 프로포즈 체인 [~] 착수 (2026-07-15 Codex) — 만지는 파일:** `content/events/arc_daeun_romance.json`, `content/events_en/arc_daeun_romance.json`, `assets/romance_visual_manifest.json`, `assets/event_visual_contracts.json`, `assets/COMMITMENT_VISUAL_BIBLE.md`, `tools/peak_scene_chain_audit.py`, `tools/SceneDirectionCheck.gd`, `tools/ScreenshotQA.gd`, `docs/ROMANCE_SYSTEM.md`, `docs/SCENE_DIRECTION.md`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 기존 수락·보류 선택의 효과·플래그·관계 단계와 수락 CG 공개 문단은 최종 링크에 원형 보존한다. 앞 링크에는 대화 축적과 관계를 대하는 태도 선택만 추가하며 결혼 라우팅은 바꾸지 않는다. CG 소유 이벤트와 반지의 느린 줌이 최종 링크로 이동하므로 비주얼 매니페스트·런타임 계약·연출 검사·정본 문서도 같은 커밋에서 동기화한다.
**다은 프로포즈 완료 보고 (2026-07-15 Codex):** `마지막 잔 → 내년 이맘때 → 프로포즈` 3링크·2선택점·25~26패널·대화 9~10회로 확장했다. 선행 선택은 다은의 내일을 먼저 묻거나 자신의 두려움을 털어놓는 태도 차이만 만들고 최종 플래그를 세우지 않는다. 기존 수락·보류 효과·플래그·관계 단계는 마지막 링크에 고정했고, 일반 초상에서 상자가 열린 정적을 거친 뒤 결과 문단 1에서만 손·눈물 동작 CG가 나온다. KO/EN 17컷씩에서 카페·의상·초상·줄바꿈·수락/보류를 확인했고, 라우팅 계약·장면 줌·아크 흐름·전체 audit(`ERROR 0/WARNING 0`, 57스크립트 컴파일)을 통과했다. 래칫은 PASS 3/부채 25로 전진했다.
**다은 결혼식 체인 [~] 착수 (2026-07-15 Codex) — 만지는 파일:** `content/events/arc_daeun_married.json`, `content/events_en/arc_daeun_married.json`, `assets/event_visual_contracts.json`, `assets/COMMITMENT_VISUAL_BIBLE.md`, `tools/peak_scene_chain_audit.py`, `tools/ScreenshotQA.gd`, `docs/ROMANCE_SYSTEM.md`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 결혼 준비에서 이미 정한 800만원 소형식/3,100만원 풀 패키지와 두 CG의 지속성은 그대로 둔다. 당일은 같은 식장 안에서 `입장 전 빈자리 → 두 사람의 서약 → 기존 신랑석 결산`으로 확장하며, 기존 최종 두 선택의 효과·플래그·관계 효과는 마지막 링크에 원형 보존한다. 앞 링크는 비용을 다시 고르게 하거나 결혼 완료 플래그를 세우지 않고, 하객의 수보다 민준이 무엇을 바라보는지를 대화와 감각으로 축적한다.
**다은 결혼식 범위 확장 선언 (2026-07-15 Codex) — 추가 파일:** `assets/cg/romance/wedding_daeun_small_v1.png`, `assets/cg/romance/wedding_daeun_full_v1.png`, `assets/cg_acting_manifest.json`, `assets/CHARACTER_VISUAL_BIBLE.md`. 사용자 정합 판정에 따라 기존 CG의 좌우 하객석과 입장 순서를 수리한다. 민준은 먼저 입장해 단상에서 기다리고 다은이 뒤에 입장하며, 화면 왼쪽 신랑석은 비고 오른쪽 신부석은 찬다. 다은 얼굴은 정본 초상의 33세 얼굴·짧은 머리·왼쪽 관자놀이 핀·민준을 향한 시선으로 잠근다. 이벤트 산문과 배우·카메라 계약도 새 구도에 맞춰 같은 작업에서 동기화한다.
**다은 결혼식 감사 장부 범위 확장 (2026-07-15 Codex) — 추가 파일:** `docs/ART_AI_AUDIT.md`. 교체한 소형/풀 CG의 원본·KO/EN 실제 렌더를 사람 눈으로 재검수한 뒤 새 해시와 구체 판정 근거를 기록한다. 검수 장부를 갱신하지 않은 이미지 교체가 전체 audit를 통과하지 못하는 래칫은 그대로 유지한다.
**다은 결혼식 완료 보고 (2026-07-15 Codex):** `먼저 선 사람 → 다은의 속도 → 신랑석` 3링크·2선택점·26패널·대화 3회로 확장했다. 민준은 먼저 입장해 단상에서 기다리고, 사회자의 신부 입장 선언 뒤 다은이 뒤쪽 문에서 나중에 걸어온다. 소형/풀 CG 모두 화면 왼쪽 신랑석은 비고 오른쪽 신부석은 차며, 다은의 33세 정본 얼굴·짧은 머리·왼쪽 관자놀이 핀·민준을 향한 시선을 공유한다. 준비 비용·소형/풀 플래그를 다시 고르지 않고, 결혼 완료 플래그와 기존 최종 효과는 마지막 링크에만 남겼다. KO/EN 27컷씩에서 입장 순서·좌석 방향·긴 선택지·결과 카드·레거시 폴백을 확인했고, 정점 래칫은 PASS 4/부채 24로 전진했다.
**다은 결혼식 좌석 방향·얼굴·현수 하객 REWORK [~] 착수 (2026-07-15 Codex) — 만지는 파일:** `assets/cg/romance/wedding_daeun_small_v1.png`, `assets/cg/romance/wedding_daeun_full_v1.png`, `assets/cg/romance/wedding_daeun_small_hyunsu_v1.png`, `assets/cg/romance/wedding_daeun_full_hyunsu_v1.png`, `content/events/arc_daeun_married.json`, `content/events_en/arc_daeun_married.json`, `autoloads/ImageRegistry.gd`, `scenes/StoryMode.gd`, `assets/event_visual_contracts.json`, `assets/cg_acting_manifest.json`, `assets/COMMITMENT_VISUAL_BIBLE.md`, `assets/CHARACTER_VISUAL_BIBLE.md`, `assets/ASSET_INDEX.md`, `assets/IMAGE_PROMPTS.md`, `docs/ROMANCE_SYSTEM.md`, `docs/ART_AI_AUDIT.md`, `tools/peak_scene_chain_audit.py`, `tools/ScreenshotQA.gd`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 직전 완료 보고의 좌우 판정은 카메라 화면과 신랑의 실제 좌우를 혼동한 오류다. 신랑 뒤에서 입구를 보는 현재 카메라에서는 **신랑의 오른쪽이 화면 오른쪽**이므로, 화면 오른쪽 신랑석을 비우고 화면 왼쪽 신부석을 채운다. 다은 얼굴은 정본 초상과 동일인으로 다시 고정한다. `hyunsu_reconnected` 경로에는 오른쪽 신랑석의 현수 단독 소형/풀 조건부 CG를 추가하고, 멀어진 경로에는 현수를 굽지 않는다. 현수 가족은 아래 하객 연표 REWORK에서 정본 부재로 폐기했다. 민준 선입장·단상 대기, 다은 후입장, 머리핀·의상·시선·소형/풀 라우팅과 기존 최종 효과는 그대로 보존한다.
**다은 결혼식 하객 연표 REWORK [~] 착수 (2026-07-15 Codex) — 추가로 만지는 파일:** `assets/cg/romance/wedding_daeun_small_father_passed_v1.png`, `assets/cg/romance/wedding_daeun_full_father_passed_v1.png`, `assets/cg/romance/wedding_daeun_small_father_passed_hyunsu_v1.png`, `assets/cg/romance/wedding_daeun_full_father_passed_hyunsu_v1.png`, 각 Godot `.import`, `assets/cast_detail_manifest.json`, `tools/cast_detail_contract_check.py`. 현수 아크에는 결혼·출산 사실이 없으므로 기존 조건부 CG의 배우자와 학령기 아이를 제거하고 현수는 단독 참석시킨다. 모든 와이드의 화면 왼쪽 신부석 앞줄에는 상견례를 마친 다은 어머니가 있어야 한다. 화면 오른쪽 신랑석은 아버지 생존 시 민준 아버지가 앞줄에 앉고, `father_passed`일 때는 그의 예약석이 비어 있는 별도 소형/풀 변주를 쓴다. `father_passed&hyunsu_reconnected`는 빈 아버지 자리와 현수 단독을 동시에 보존한다. 재혁·상철·지연·민준 어머니는 결혼식 참석 정본이 없거나 경로에 따라 모순되므로 이번 CG에 이름 있는 하객으로 굽지 않는다. 소형/풀 비용·민준 선입장·다은 후입장·좌석 방향·최종 효과는 불변이다.
**다은 결혼식 선택 원장·군중 위계 범위 확장 (2026-07-15 Codex) — 추가 파일:** `tools/audit.py`. 선택의 시각 결과와 산문이 같은 조합을 읽도록 `description_if_known`에도 `&` 복합 플래그를 지원하고, 감사기는 복합 키를 개별 실제 플래그로 분해해 고아·섀도잉을 검사한다. 모든 와이드의 양쪽 의자는 같은 단상 방향·대칭 원근으로 고정한다. 화면 왼쪽 신부측은 다은 어머니만 식별 가능한 얼굴·색으로 남기고, 나머지 익명 하객은 연령과 체형만 읽히는 저대비 무안면 실루엣으로 처리한다. 화면 오른쪽은 현재 플래그가 허용한 아버지와 현수만 선명하게 보이고 다른 이름 있는 인물은 추가하지 않는다.
**다은 결혼식 하이라이트 연출 범위 확장 (2026-07-15 Codex) — 추가 파일:** `assets/cg/romance/wedding_daeun_small_close_v1.png`, `assets/cg/romance/wedding_daeun_full_close_v1.png`. 먼 와이드 한 장을 세 링크에 반복하지 않는다. 첫 링크는 입장 순서·화면 왼쪽의 다은 어머니와 익명 실루엣·오른쪽의 드문 신랑 하객 및 조건부 현수 단독을 보여주는 와이드, 두 번째와 마지막 링크는 정본 다은 얼굴·민준을 향한 시선·떨림이 크게 읽히는 소형/풀 근접컷으로 전환한다. 결혼 준비 변주와 최종 선택 효과는 불변이다.
**다은 결혼식 인물 분리 컷 REWORK [~] 착수 (2026-07-15 Codex) — 추가로 만지는 파일:** `assets/cg/romance/wedding_daeun_mother_reaction_v1.png`, `assets/cg/romance/wedding_daeun_father_reaction_v1.png`, `assets/cg/romance/wedding_daeun_father_reaction_hyunsu_v1.png`, `assets/cg/romance/wedding_daeun_father_reaction_passed_v1.png`, `assets/cg/romance/wedding_daeun_father_reaction_passed_hyunsu_v1.png`, 각 Godot `.import`, 기존 소형/풀 커플 와이드·근접 4종, 기존 하객 합성 변주 6종(참조 제거 후 삭제), `assets/romance_visual_manifest.json`. 한 프레임에 민준·다은·양가 부모·현수·빈자리 상태를 모두 굽는 방식을 폐기한다. 당일 체인은 `다은 어머니 반응 → 민준 아버지/빈자리 반응 → 민준·다은 입장 → 두 사람 근접` 4링크로 재배치한다. 어머니 컷은 화면 왼쪽 신부석 맨 앞 통로측 의자에 자연스럽게 앉은 혼주 한복과 딸을 향한 시선만, 아버지 컷은 화면 오른쪽 신랑석의 혼주 정장·현수 단독·별세 시 빈 앞자리만 상태별로 보여준다. 커플 소형/풀 와이드와 근접은 이름 있는 하객을 제거해 두 사람의 눈맞춤만 남긴다. 기존 결혼 비용·소형/풀 플래그·최종 선택 효과·결혼 완료 플래그는 불변이다.
**다은 결혼식 사운드스케이프·중요 장면 오디오 계약 [~] 착수 (2026-07-15 Codex) — 만지는 파일:** `assets/audio/bgm_wedding_processional.ogg`, `assets/audio/bgm_intimate.ogg`, `assets/audio/bgm_reckoning.ogg`, `assets/audio/bgm_grief.ogg`, `assets/audio/bgm_wonder.ogg`, `assets/audio/amb_wedding_hall.wav`, `assets/audio/sfx_wedding_applause.wav`, `assets/audio/sfx_wedding_cheer.wav`, 각 Godot `.import`, `assets/scene_audio_manifest.json`, `content/events/arc_daeun_married.json`, `autoloads/BGMPlayer.gd`, `autoloads/AudioManager.gd`, `scenes/StoryMode.gd`, `tools/generate_audio_p1_assets.py`, `tools/audio_source_audit.py`, `tools/AudioAssetCheck.gd`, `tools/BGMContinuityCheck.gd`, `tools/scene_audio_contract_check.py`, `tools/audit.sh`, `tools/ScreenshotQA.gd`, `docs/AUDIO_QA.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 결혼식은 예식장 룸톤·하객 기척을 계속 유지하고, 민준의 선입장부터 다은의 입장·서약까지 하나의 저작권 안전한 오리지널 행진곡을 재시작 없이 이어 간다. 박수와 절제된 환호는 장면 진입 타이머가 아니라 신부 입장 문단에 동기화해 자연스럽게 겹친다. CG만이 아니라 정점 레지스트리 전체에 `친밀함·폭로/대면·상실·경이·결혼` 음악 역할과 문단 큐를 명시해 일반 로파이가 중요한 장면을 대신하지 못하게 한다.
**CG 환경음 계약 범위 확장 (2026-07-15 Codex) — 추가 파일:** `assets/audio/amb_hospital_room.wav`, `assets/audio/amb_seaside.wav`, `assets/audio/amb_amusement_park.wav`, `assets/audio/amb_car_interior.wav`, `assets/audio/amb_night_bus.wav`, `assets/audio/amb_train_interior.wav`, `assets/audio/sfx_distant_fireworks.wav`, 각 Godot `.import`, `scenes/MainGame.gd`. 해변을 강변음으로, 병실을 고시원 룸톤으로 대신하는 식의 장소 불일치를 허용하지 않는다. 활성 CG 54종 전부가 명시적 환경음 계약을 가져야 하며, 스토리 CG뿐 아니라 엔딩 CG도 그림의 실제 장소에 맞는 앰비언스로 전환한다. 불꽃놀이는 한강 룸톤 위 원거리 폭발음을 문단 시점에만 얹고, 차 안·버스·KTX는 외부 거리음과 분리한다.
**이벤트 중 오디오 설정 [~] 착수 (2026-07-15 Codex) — 만지는 파일:** `scenes/StoryMode.gd`, `tools/StoryAudioSettingsCheck.gd`, `tools/StoryAudioSettingsCheck.gd.uid`, `tools/StoryAudioSettingsCheck.tscn`, `tools/ScreenshotQA.gd`, `tools/audit.sh`, `docs/AUDIO_QA.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 플레이어가 장면에서 들은 BGM·환경음·효과음을 AP 허브로 돌아가지 않고 바로 조절할 수 있게 한다. StoryMode HUD에 작은 오디오 설정 버튼을 두고 BGM/SFX 슬라이더를 즉시 저장·적용하며, 마우스·키보드·패드 포커스와 모달 입력 차단을 함께 보장한다. 모달을 여닫아도 현재 장면 음악과 환경음은 재시작하지 않는다.
**게임 전반 물리음·미니게임 사운드 패스 [~] 착수 (2026-07-15 Codex) — 만지는 파일:** `assets/audio/sfx_card_shuffle.wav`, `assets/audio/sfx_card_deal.wav`, `assets/audio/sfx_card_flip.wav`, `assets/audio/sfx_chip_place.wav`, `assets/audio/sfx_chip_collect.wav`, `assets/audio/sfx_dice_cup_shake.wav`, `assets/audio/sfx_dice_roll.wav`, `assets/audio/sfx_roulette_wheel.wav`, `assets/audio/sfx_roulette_ball.wav`, `assets/audio/sfx_roulette_land.wav`, `assets/audio/sfx_slot_start.wav`, `assets/audio/sfx_slot_reel_stop.wav`, `assets/audio/sfx_big_wheel_tick.wav`, `assets/audio/sfx_race_gate.wav`, `assets/audio/sfx_horse_gallop.wav`, `assets/audio/sfx_race_crowd_rise.wav`, `assets/audio/sfx_race_finish.wav`, 각 Godot `.import`, `assets/game_audio_manifest.json`, `autoloads/AudioManager.gd`, `autoloads/BGMPlayer.gd`, `scenes/JeongseonCasino.gd`, `scenes/BlackjackTable.gd`, `scenes/BaccaratTable.gd`, `scenes/HoldemClub.gd`, `scenes/RouletteTable.gd`, `scenes/DaiSaiTable.gd`, `scenes/SlotMachineGame.gd`, `scenes/BigWheelGame.gd`, `scenes/RaceTrack.gd`, `scenes/TradingFloor.gd`, `scenes/ScalpingGame.gd`, `scenes/ArubaGame.gd`, `scenes/JobHuntMiniGame.gd`, `scenes/MainGame.gd`, `tools/generate_audio_p1_assets.py`, `tools/audio_source_audit.py`, `tools/AudioAssetCheck.gd`, `tools/GameAudioContractCheck.gd`, `tools/GameAudioContractCheck.gd.uid`, `tools/GameAudioContractCheck.tscn`, `tools/game_audio_contract_check.py`, `tools/audit.sh`, `docs/AUDIO_QA.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 공용 전자음 네 개를 모든 행위에 재사용하지 않는다. 카드 셔플·딜·플립, 칩 놓기·회수, 다이사이 컵·주사위, 룰렛 휠·볼·착지, 슬롯 시작·릴 정지, 빅휠 포인터 틱, 경마 게이트·말발굽·관중 상승·결승을 물리 단계별로 분리한다. 카지노·홀덤·경마 입장 중에는 각 장소 환경음을 유지하고 닫으면 AP 허브 환경음으로 복귀한다. 정적 매니페스트와 런타임 체크가 각 핵심 단계의 전용 키 배선을 강제한다.
**Moral 앰비언스·배우 디테일 위계 [~] 착수 (2026-07-15 Codex) — 만지는 파일:** `assets/audio/amb_human_*.wav`, 각 Godot `.import`, `assets/game_audio_manifest.json`, `assets/cast_detail_manifest.json`, `autoloads/BGMPlayer.gd`, `docs/GANGNAM_INK_ART_DIRECTION.md`, `assets/CHARACTER_VISUAL_BIBLE.md`, `tools/generate_audio_p1_assets.py`, `tools/audio_source_audit.py`, `tools/MoralAmbienceCheck.gd`, `tools/MoralAmbienceCheck.gd.uid`, `tools/MoralAmbienceCheck.tscn`, `tools/cast_detail_contract_check.py`, `tools/audit.sh`, `docs/AUDIO_QA.md`, `docs/ART_AI_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 화면과 소리를 같은 시대감·같은 서사 위계로 묶는다. 현대 서울의 디제틱 앰비언스는 사람층과 무기질층을 분리하고, 시각 tint와 동일한 moral 밴드 전이에 따라 어두워질수록 사람 소리만 점진적으로 멀어지게 한다. 전자음·칩튠·아케이드식 보상음은 금지한다. 인물은 A 주연(온전한 얼굴·색·연기), B 반복 조연(고유 실루엣·제한 팔레트), C 익명 군중(얼굴 정보 없는 저대비 실루엣) 3단계로 고정하며, 이름과 서사 기능이 있는 조연을 일괄 검은 형체로 지우지 않는다.
**다은 결혼식 분리 컷·현수 정본 REWORK 완료 보고 (2026-07-15 Codex):** 당일 체인을 `다은 어머니 반응 → 민준 아버지/빈자리 반응 → 민준·다은 입장 와이드 → 두 사람 근접` 4링크·2선택점·33패널로 확정했다. 아홉 CG가 어머니, 아버지 생존/별세×현수 재연결, 소형/풀 커플 와이드·근접을 분담하며 한 프레임에 모든 사람과 상태를 합성하던 방식을 폐기했다. 현수 두 컷은 정본 초상과 같은 넓고 부드러운 얼굴·둥근 볼/턱·완만한 눈매·중간 웨이브·원형 안경으로 다시 만들고, 카메라가 아니라 화면 왼쪽 통로의 다은을 보게 했다. 배우자·아이·대체 혼주를 발명하지 않고 별세 변주의 예약석은 완전히 비어 있다. KO/EN 33컷과 교체 후 KO 재렌더, 활성 아트 186장·배우/시선·복합 플래그·아크 흐름·전체 audit가 통과했다.
**장면·미니게임 오디오 및 Moral 사람층 완료 보고 (2026-07-15 Codex):** 오디오를 BGM 12·앰비언스 45·SFX 52, 총 109개 결정론적 프로젝트 소유 자산으로 정리했다. 활성 CG 57개와 정점 경로 이벤트 37개가 장소/음악 계약을 가지며, 다은 결혼식 부모 반응은 룸톤만 유지하고 커플 와이드부터 행진곡이 시작돼 근접까지 재시작 없이 이어진다. 박수·환호는 입장 문단에 동기화된다. 카드·칩·주사위·룰렛·슬롯·빅휠·경마는 17개 물리 단계 키로 분리했고, 장소 진입/복귀 앰비언스, 장면 중 패드 음량 창, Moral 밴드에 따라 사람층만 먼저 멀어지는 9개 프로필을 런타임 검사로 고정했다. 정적 감사 `ERROR 0/WARNING 0`, 영어 누출 0, 밸런스 전 정책, 장면/BGM 연속성, 57개 GDScript 컴파일과 전체 audit가 통과했다. `ORDER-24`는 다음 정점인 `arc_jiyeon_wedding_gap` 때문에 `[~]`를 유지한다.
**지연 결혼 격차 체인 [~] 착수 (2026-07-16 Codex) — 만지는 파일:** `content/events/arc_jiyeon_married.json`, `content/events_en/arc_jiyeon_married.json`, `assets/event_visual_contracts.json`, `assets/COMMITMENT_VISUAL_BIBLE.md`, `assets/scene_audio_manifest.json`, `tools/peak_scene_chain_audit.py`, `tools/ScreenshotQA.gd`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`, `docs/ROMANCE_SYSTEM.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. `arc_jiyeon_wedding_gap`은 프로포즈나 완성된 결혼식이 아니라 선택 전 계급 압력이다. 기존 호텔 볼룸 CG와 최종 두 선택의 비용·플래그·관계 효과는 마지막 링크에 원형 보존하고, 앞 링크는 처가의 기준·민준의 빈 신랑석·지연의 통제된 균열을 대화와 감각으로 축적한다. 웨딩드레스·결과 하객·새로운 결혼 완료 라우팅은 추가하지 않는다.
**지연 결혼 격차 [x] 완료 보고 (2026-07-16 Codex):** `볼룸 압력 → 비어 있는 신랑석 명단 → 그 정도` 3링크·3선택점·22~23패널·대화 6~8회로 확장했다. 첫 링크는 장인의 기준과 지연의 통제된 균열, 두 번째 링크는 신부 측 이름들과 신랑 측 빈칸, 마지막 링크는 기존 `빚내서 맞춤/형편대로` 최종 선택을 소유한다. 최종 돈·정신·Moral Tint·`arc_jiyeon_wedding_gap_seen`·지연 호감도 효과는 마지막 링크에만 남겼고, 기존 호텔 볼룸 CG는 선택 전 압력 컷으로 세 링크에 유지했다. 웨딩드레스·결과 하객·새 결혼 완료 라우팅은 추가하지 않았다. KO/EN 선택지 패리티와 EN 누출 검사를 통과했고, 정점 래칫은 PASS 5/부채 23으로 전진했다.
**지연 무자산 결혼·신혼집 정합 수리 [~] 착수 (2026-07-16 Codex) — 만지는 파일:** `content/events/arc_jiyeon_married.json`, `content/events_en/arc_jiyeon_married.json`, `content/events/arc_romance_specials.json`, `content/events_en/arc_romance_specials.json`, `scenes/MainGame.gd`, `tools/peak_scene_chain_audit.py`, `docs/STORY_BIBLE.md`, `docs/ROMANCE_SYSTEM.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 지연은 민준의 현재 잔고가 아니라 계속 올라갈 사람이라는 믿음으로 결혼하며, 신혼집은 부산에서 독립해 번 돈과 자기 자산으로 지연이 자기 명의로 마련한 서울 집이다. 민준의 무자산을 숨기지 않되 결혼 전 대화를 반드시 선행시키고, 결혼 후 심판은 단순 빈곤 비난이 아니라 움직임이 멎은 데 대한 갈등으로 쓴다. 기존 비용·결별·엔딩 효과와 자산 5억 게이트는 보존한다.
**지연 무자산 결혼·신혼집 정합 [x] 완료 보고 (2026-07-16 Codex):** 표준 지연 연애가 t193 이후 확정돼 기존 t175~188 결혼 대화를 영원히 놓치던 스케줄 결함을 수리했다. Y5 고백 뒤 `arc_y4_marriage_talk`을 먼저 회수하고, 결혼 격차 체인은 그 대화 뒤에만, 막판 심판은 실제 첫날밤 뒤에만 열린다. 지연은 민준의 빈 잔고를 처음부터 알고도 그의 방향을 믿어 결혼하며, 부산 중개 수입과 자기 자산으로 자기 명의 서울 신혼집을 얻은 것으로 한영 산문·정본을 고정했다. 형편대로 결혼한 결과의 무조건적 “오빠면 돼”를 “결혼은 오빠랑, 대신 멈추진 말자”로 바로잡고, 심판은 가난 비난이 아니라 멈춤과 자기 안의 계급 감각을 인정하는 갈등으로 정렬했다. 비용·호감도·결별·엔딩 효과와 5억 게이트는 불변이며, 한영 wedding-morning·breakup 실렌더와 아크 흐름·정점 strict를 통과했다.
**상철 t60 대면·심판 체인 [~] 착수 (2026-07-16 Codex) — 만지는 파일:** `content/events/arc_drama.json`, `content/events_en/arc_drama.json`, `assets/event_visual_contracts.json`, `assets/scene_audio_manifest.json`, `tools/peak_scene_chain_audit.py`, `tools/ScreenshotQA.gd`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`, `docs/STORY_BIBLE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. `arc_sangchul_confrontation`의 질문 뒤 “반응을 기다림/진실을 묻음/자리를 떠남” 세 갈래를 모두 최소 2링크·2선택점으로 확장한다. 묻음은 식은 커피 앞 침묵, 떠남은 카페 계단참의 마지막 호출을 후속 여파로 보여주고, 두 갈래 모두 마지막에 그대로 확정하거나 돌아서 심판을 듣게 한다. 기존 대면·심판의 돈/정신/평판/투자기술/Moral Tint·관계 단계·플래그·Y3 후속 라우팅은 각 갈래 최종 링크에서 합산 결과까지 원형 보존한다.
**상철 t60 대면·심판 체인 [x] 완료 보고 (2026-07-16 Codex):** 질문 뒤 `심판 직행 / 식은 커피의 침묵 / 문밖 세 걸음`으로 갈리고, 묻음·떠남도 마지막 확인 또는 심판 복귀를 고르는 2~3링크·2~3선택점·20~30패널·대화 4~15회 체인이 됐다. 기존 묻음·떠남 최종 효과는 각 분기 마지막에 그대로 두고, 심판 네 갈래는 기존 대면 효과를 합산해 실제 최종 정신·평판·투자기술·Moral Tint와 관계/엔딩 플래그를 보존했다. 상철이 아버지에게 박상진을 소개한 인과와 상환 시점의 생존 정합도 바로잡았다. 카페 안은 카페, 문밖은 서울 골목 배경·환경음으로 계약했으며 한영 36컷 실렌더, EN 누출 0, 아크 잼 0, 비주얼·오디오 계약과 정점 strict를 통과해 래칫은 PASS 6/부채 22가 됐다.
**아버지 병상·별세·23초 KTX 3정점 [~] 착수 (2026-07-16 Codex) — 만지는 파일:** `content/events/relationship_events.json`, `content/events_en/relationship_events.json`, `content/events/arc_drama.json`, `content/events_en/arc_drama.json`, `content/meta/story_rules.json`, `assets/event_visual_contracts.json`, `assets/scene_audio_manifest.json`, `tools/peak_scene_chain_audit.py`, `tools/ScreenshotQA.gd`, `tools/StoryPresenceCheck.gd`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`, `docs/STORY_CONSISTENCY_SYSTEM.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. `father_hospital_wait`, `arc_father_passing`, `arc_father_call_on_ktx`를 각각 2~4링크·2~3선택점으로 확장하되 기존 최종 선택의 효과·관계 단계·플래그와 별세 라우팅은 마지막 링크에 원형 보존한다. 병상 장면의 서울/창원 모순은 창원 병원과 서울 귀환으로 고정한다. KTX 장면은 민준이 열차 안, 아버지는 전화 너머라는 새 presence 계약을 사용하며, 별세 체인은 병원 전화→승강장/딜→병실 또는 다음 날 통보의 물리 장소와 소리 변화를 링크별로 분리한다. 세 체인은 판정 편의를 위해 구현 커밋을 장면별로 나눈다.
**아버지 병상 환자복 정합 REWORK [~] 착수 (2026-07-16 Codex) — 추가로 만지는 파일:** `assets/characters/npc_father_hospitalized.png`, 해당 Godot `.import`, `autoloads/ImageRegistry.gd`, `assets/ASSET_INDEX.md`, `docs/ART_AI_AUDIT.md`. 기존 `father_weak`은 부모님 서울 방문·전화 회상에도 공유되므로 덮어쓰지 않는다. 정본 아버지 얼굴·나이·체형을 유지한 투명 배경 환자복 전용 `father_hospitalized` 초상을 만들고, 입원 장면에만 연결한다. 병실/검사 이동 산문·환자복·배경의 물리 상태를 한 계약으로 고정한 뒤 KO/EN `father-peaks`를 다시 렌더한다.
**아버지 집 생활복 정합 REWORK [~] 착수 (2026-07-16 Codex) — 추가로 만지는 파일:** `assets/characters/npc_father_home.png`, 해당 Godot `.import`, `autoloads/ImageRegistry.gd`, `content/events/callback_events_44.json`, `content/events/callback_events_51.json`, `content/events/callback_events_54.json`, 대응 EN 오버레이, `content/meta/story_rules.json`, `assets/event_visual_contracts.json`, `assets/CHARACTER_VISUAL_BIBLE.md`, `assets/ASSET_INDEX.md`, `docs/ART_AI_AUDIT.md`, `tools/story_consistency_audit.py`, `tools/ScreenshotQA.gd`, `docs/STORY_CONSISTENCY_SYSTEM.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. `father_normal/weak`의 작업 재킷은 공장·외출·위기 문맥에만 남긴다. `dad_house`에서 실제 대면하는 아버지는 정본 얼굴·나이·체형을 유지한 색 바랜 버건디 폴로와 보풀이 밴 회갈색 지퍼 니트의 투명 `father_home` 초상을 사용한다. 고시원 배경의 전화·회상은 원격 채널 계약을 우선하며 이번 생활복 교체로 현장 방문처럼 재해석하지 않는다. 집·병원·외출 의상 ID를 장소 계약으로 감사하고 KO/EN 대표 장면을 렌더한다.
**아버지 장소별 의상 전수 REWORK [~] 착수 (2026-07-16 Codex) — 추가로 만지는 파일:** `content/events/arc_events.json`, `content/events/callback_events.json`, `content/events/callback_events_36.json`, 대응 EN 오버레이, `content/meta/story_rules.json`, `assets/event_visual_contracts.json`, `tools/story_consistency_audit.py`, `tools/ScreenshotQA.gd`, `docs/STORY_CONSISTENCY_SYSTEM.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. `hospital + father_normal/weak` 전수 네 건을 장면 동사로 다시 분류한다. 실제 301호 병상 방문과 쓰러진 뒤 병원 재진료는 `father_hospitalized`, 늦은 전화 회상은 병원 배경을 제거하고 현재 주거의 밤/창원 집 원격 `father_home`으로 고정한다. 병원·집·원격 채널과 초상 ID의 조합을 데이터 계약과 감사로 잠가 다시 작업복이 병상이나 집에 나타나지 못하게 한다.
**아버지 창원 집 원격 의상 전수 REWORK [~] 착수 (2026-07-16 Codex) — 추가로 만지는 파일:** `assets/characters/npc_father_home_weak.png`, 해당 Godot `.import`, `autoloads/ImageRegistry.gd`, `content/events/story_events.json`, `content/events/arc_midgame.json`, `content/events/arc_pre_ending.json`, `content/events/callback_events.json`, `content/events/callback_events_36.json`, `content/events/callback_events_39.json`, `content/events/callback_events_43.json`, `content/events/callback_events_46.json`, `content/meta/story_rules.json`, `assets/event_visual_contracts.json`, `assets/CHARACTER_VISUAL_BIBLE.md`, `assets/ASSET_INDEX.md`, `docs/ART_AI_AUDIT.md`, `tools/story_consistency_audit.py`, `tools/ScreenshotQA.gd`, `docs/STORY_CONSISTENCY_SYSTEM.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 원장의 `remote_location=changwon_home`, `remote_actor=father`, `portrait_role=remote`인 실제 아버지 초상 통화는 평상시 `father_home`, 마지막 건강 악화 통화는 같은 집 의상에 쇠약 표정만 분리한 `father_home_weak`를 쓴다. 민준 로컬 초상을 쓰는 통화는 유지한다. 원격 집 아버지가 `father_normal/weak` 작업 재킷으로 회귀하면 감사 실패하도록 장소별 의상 계약을 추가한다.
**아버지 병상·장소별 의상 정합 REWORK [x] 완료 보고 (2026-07-16 Codex):** 병상 체인을 입원 사흘째 `병동 검사실 대기 → 결과 → 301호 복귀/서울행 KTX`로 고정하고 기존 최종 효과를 보존했다. 동일 얼굴의 `father_home`, `father_home_weak`, `father_hospitalized`를 추가해 창원 집·평상 통화·건강 악화 통화·입원 병동을 생활복/환자복으로 분리했으며, 어머니가 말하는 방 회상은 어머니 초상으로 교정했다. `expected_portrait` 계약과 감사가 장소·채널·의상 조합을 잠그고 원장은 54/1,501건·논리 17·원격 36·미분류 0으로 전진했다. 집 초상의 잘못된 크로마 마스크가 피부와 옷을 반투명하게 만들던 결함도 얼굴 중심 알파 122→255로 복구했다. KO/EN `father-peaks` 각 11컷에서 정상 피부색·환자복·생활복·전화 인셋·영어 무누출을 확인했고 정점 래칫은 PASS 7/부채 21이다. `ORDER-24`는 남은 아버지 별세와 KTX 23초 통화 때문에 `[~]`를 유지한다.
**아버지 별세 공간 분리·배경 REWORK [~] 착수 (2026-07-16 Codex) — 추가로 만지는 파일:** `assets/backgrounds/seoul_station_ktx_platform_winter.png`, `assets/backgrounds/changwon_hospital_room_empty.png`, 각 Godot `.import`, `autoloads/ImageRegistry.gd`, `scenes/StoryMode.gd`, `content/events/arc_drama.json`, `content/events_en/arc_drama.json`, `content/meta/story_rules.json`, `assets/event_visual_contracts.json`, `assets/scene_audio_manifest.json`, `assets/ASSET_INDEX.md`, `docs/ART_AI_AUDIT.md`, `tools/peak_scene_chain_audit.py`, `tools/ScreenshotQA.gd`, `docs/PEAK_SCENE_CHAIN_AUDIT.md`, `docs/STORY_CONSISTENCY_SYSTEM.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 현재의 병원 복도 한 장 안에서 병원 전화·서울의 딜·KTX·창원 도착·빈 병실·다음 날 통보가 동시에 일어나는 모순을 없앤다. 첫 통화는 실제 `current_housing` 배경과 현장 민준/전화 너머 간호사, 중간은 겨울 서울역 KTX 승강장 또는 투자 딜룸, 최종은 창원 빈 병실 또는 다음 날 딜룸으로 분리한다. 기존 두 최종 결과의 정신·돈·Moral Tint·아버지 stage·세 플래그는 각 갈래 마지막 링크에 합산 그대로 보존하며, 결정 전 링크는 상태를 선점하지 않는다. 신규 배경은 인물·상표·텍스트를 굽지 않고 기존 Gangnam Ink 화풍과 1280×800 안전 구도를 따른다.
**아버지 별세 공간 분리·배경 REWORK [x] 완료 보고 (2026-07-16 Codex):** `arc_father_passing`을 현재 주거의 병원 전화에서 시작해 `서울역 KTX 승강장/투자 딜룸 → 창원 빈 병실/다음 날 딜룸`으로 이어지는 네 실제 3링크·2선택점 경로로 분리했다. `current_housing`은 저장된 실제 거주지와 방 앰비언스로 해석되며 간호사는 전화 인셋에만 나타난다. 신규 겨울 승강장·빈 병실 배경은 인물·상표·읽을 수 있는 문구 없이 1280×800 Gangnam Ink로 등록했다. 중간 선택은 상태를 선점하지 않고, 최종 `정신 -40/tint +10/내려감`과 `정신 -25/500만원/tint -8/돈 선택` 계약 및 아버지 stage·플래그는 원형 그대로다. KO/EN 각 20컷과 네 실제 경로 상태 검증, 전체 audit, 아크 잼 0을 통과했다. 원장은 58/1,505건·논리 21·원격 38·미분류 0, 정점 래칫은 PASS 8/부채 20이다. `ORDER-24`는 남은 `arc_father_call_on_ktx` 23초 통화 때문에 `[~]`를 유지한다.
> §8 "장면 체감 길이 표준"(정점=체인 2~4이벤트+선택 2~3+대화 왕복)을 전 게임 범위로. 데모 정점(ORDER-22 C-2)과 동일 문법 — 「무릎」 3연쇄가 구조 레퍼런스.
1. **측정 먼저**: §8 레지스트리 전 정점의 현재 비트 수(문단·선택점) 표 작성 — **이미 표준 충족(남산 체인 등)은 스킵**, 2~3클릭 씬만 확장 대상.
2. **확장 우선순위 (감정 하중순)**: ①결혼식 2종·프로포즈 ②상철 t60 대면·심판 ③아버지 별세·병상·23초 KTX ④첫 키스 2종·첫날밤 2종(전희 비트 — §5 페이드아웃 유지) ⑤재혁 ghost·거울 ⑥어머니의 밥상·좁은 방(이미 2연작 — 내부 비트만 점검) ⑦verdict·이혼 담판 ⑧계절 정점(바다·불꽃).
3. **라우팅 불변 절대 규칙**: 결정 씬(verdict·final_choice·wedding_gap 등 finish_run 관련)은 **결정 선택지·플래그·효과를 최종 링크에 원형 유지** — 앞 링크는 축적 비트(대화·긴장·회상)만, 신규 플래그는 독자 필수. 체인화 후 arc_flow_sim+ending 게이트 필수.
4. **dik 이관 주의**: 기존 이벤트의 dik는 체감상 같은 위치의 링크로 이동(첫 링크의 본문 변주는 첫 링크에). 섀도잉 재검.
5. KR+EN 동시, §8 6요소·호칭 정본·설교 방지. 각 정점 체인화는 개별 커밋(판정 용이).
6. **중단 조건**: 유저 Round 2 판정이 오면 이 작업을 일시 정지하고 데모 재수리 우선 — 판정에서 체인 표준 자체가 조정되면 이 오더 스펙도 갱신 후 재개.

#### [x] ORDER-25 [P1] 서사 정합 원장 + 원격 존재 렌더 (유저 직접 지시 2026-07-16 → Claude 판정: 합격·우수)
Codex가 오더 없이 `content/meta/story_rules.json`(언어 독립 서사 사실 원장) + 원격 통신 렌더 분리(phone/video/message/memory 채널·scene vs remote location·작은 원격 프레임)를 구현했다. **판정 합격**: ①몰입 버그(전화가 현장 존재처럼 보임) 실수리 = 현 P0 정렬 ②저장호환 flag 미변경·legacy bridge 방식 = ORDER-18 안전 철학 준수 ③자체 감사(story_consistency_audit.py 411줄)+런타임 체크 동반, 미분류 0. **기록 정정(2026-07-16)**: 유저가 직접 지시한 작업 — Codex 자체 발의 아님. 프로세스 위반 없음.

#### [~] ORDER-26 [P0·데모/전범위] AP 의미화 — "눌러도 차이가 없으면 고민을 안 한다" (유저 진단 2026-07-16: 즉각+전략 둘 다 밋밋)
> 원리: 흥미로운 선택 = 어느 쪽도 명백한 정답 아님 + 고른 것이 미래를 실제로 가른다(시드 마이어). **감으로 밸런스 금지 — 측정→표적 수리 순.** 밸런스 밴드 밖 수치 변경은 BALANCE.md 기록+밴드 재검 필수.
**A 수렴 진단 착수 (2026-07-16 Codex) — 만지는 파일:** `tools/convergence_sim.py`, `tools/balance_check.py`, `docs/CONVERGENCE_REPORT.md`, `docs/BALANCE.md`, `docs/GAME_RECOMPOSITION_PLAN.md`, `docs/MASTER_RELEASE_AUDIT.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 기존 경제 회귀 밴드는 그대로 유지하고, 별도 결정론적 240주 모델로 안전 직장형·공격 투자형·사람 중심형·도박형·스펙/창업형을 각 3,000런 측정한다. 자산만이 아니라 건강·정신·주요 인물 호감·돈/사람 주차·MORAL_TINT·정석/비정석 루트·엔딩 패밀리의 종착 분포를 보고한다. 모델이 생략한 런타임 요소와 신뢰 한계를 문서에 명시하며, 수렴 원인이 확인되기 전 게임 수치·주간 스케줄러·콘텐츠는 수정하지 않는다. 기존 사용자 변경 `project.godot`은 건드리지 않는다.
**A. 수렴 진단 (반드시 먼저 — 데이터 없이 수리 금지)**
1. `balance_check`를 **전략 발산 측정기**로 확장: 대표 아키타입 5종(안전 직장형 / 공격 투자형 / 사람 중심형 / 도박형 / 스펙·창업형)을 각 3,000런 시뮬 → **결과가 실제로 갈리는가**를 3층으로 리포트: ①자산 분포 ②도달 엔딩 분포 ③tint/route 종착 상태. `docs/CONVERGENCE_REPORT.md`.
2. 판정 기준: 아키타입 간 엔딩·자산·도덕 종착이 **유의미하게 다르면 건강**, 다 비슷한 곳에 수렴하면 그 지점이 병소. 어느 축이 "결국 다 돈으로 환금"되는지 지목.
**A 완료 보고 (2026-07-16 Codex):** 5정책×3,000런에서 자산 중앙값은 직장 2.44억/공격 투자 1.89억/사람 0.87억/도박 0.07억/창업 2.36억, 우세 엔딩은 4/5개, 평균 엔딩 JSD 0.893, 사람축 격차 220주, tint 격차 52로 측정됐다. 성실 직장의 30억 도달은 0%다. 실제 즉시 중독 엔딩을 모델에 반영해 순수 도박형은 `crypto_ghost` 99.2%로 정정했다. 소스 감사상 숨은 자산 추격 보정은 없고 `get_run_pace()`는 호출자 없는 표시 계산이다. 병소는 공격 투자형이 투자감각 100이어도 `career_climber`에 흡수되는 판정 순서와, 32억 인수대금의 `startup_exit`가 일반 30억 강남 분기에 먼저 잡히는 종결 정체성 두 곳이다. 수익률·월급은 변경하지 않았다. 자동 래칫과 모델 한계는 `docs/CONVERGENCE_REPORT.md`·`docs/BALANCE.md`에 고정했다.
**B 종결 정체성 수리 착수 (2026-07-16 Codex) — 만지는 파일:** `autoloads/GameState.gd`, `autoloads/DataRegistry.gd`, `content/endings.json`, `content/endings_en.json`, `content/meta/achievements.json`, `tools/convergence_sim.py`, `tools/balance_check.py`, `tools/ending_distinctness_audit.py`, `tools/EndingRouteIdentityCheck.gd`, `tools/EndingRouteIdentityCheck.gd.uid`, `tools/EndingRouteIdentityCheck.tscn`, `tools/audit.sh`, `docs/CONVERGENCE_REPORT.md`, `docs/BALANCE.md`, `docs/ENDING_AUDIT.md`, `docs/DECISIONS.md`, `docs/GAME_RECOMPOSITION_PLAN.md`, `docs/MASTER_RELEASE_AUDIT.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 32억 창업 인수는 NG+ 특수 결말 뒤·일반 30억 앞에서 전용 `startup_exit`로 판정한다. 38세 결산은 평판 뒤에 정석/비정석/은퇴/투자/10억/균형의 실제 삶 정체성을 일반 `career_climber`보다 먼저 판정한다. 투자형은 새 ID나 보상 없이 순자산 1억+, 투자감각 85+, `tendency_realized=invest`, 비정석 우세 15+를 모두 요구하며, 기존 5억 투자 달인 조건도 보존한다. 정확한 금액을 거짓으로 쓰던 한영 결산·업적 문구를 조건에 맞게 고치고 실제 `check_game_over()` 런타임 케이스와 5아키타입 3,000런으로 잠근다. 기존 사용자 변경 `project.godot`은 건드리지 않는다.
**B 완료 보고 (2026-07-16 Codex):** 32억 공동창업 인수는 NG+ 특수 결말 뒤·일반 30억 전에 `startup_exit`로 닫히고, 38세 결산은 정석/비정석/은퇴/투자/안정/균형을 일반 직장보다 먼저 판정한다. 기존 5억·투자감각55 문을 보존한 채 1억+·감각85+·투자 성향 자각·비정석 우세15+ 경로를 추가하고, 금액을 거짓 단정하지 않는 한영 `route_invest` 결산과 업적 문구를 맞췄다. 실제 `check_game_over()` 9경로가 통과했으며 5정책×3,000런은 우세 엔딩 **5/5**, JSD **0.989**, 공격 투자 `investment_master` **93.4%**, 희귀 인수 `startup_exit` **1.0%**, 성실 직장 30억 **0%**를 기록했다. 월급·수익률·기회 확률은 바꾸지 않았다. 다음은 C 데모 결과 가시화다.
**B. 수렴 원인 표적 수리 (진단이 가리키는 것만)**
3. **고무줄 제거**: 뒤처진 플레이어를 몰래 돕거나 앞선 플레이어를 견제하는 숨은 보정이 있으면 제거/완화(발산이 죽는 1순위 용의자).
4. **축의 종결 가치**: human/건강/정신 축이 "돈 버는 효율"로만 수렴하지 않게 — 각 축이 **다른 엔딩·다른 콘텐츠를 여는 목적 그 자체**가 되게(이미 부분 존재: 관계 엔딩·삶의 모양 칭호 — 발산에 실효가 있는지 시뮬로 확인, 부족분 강화). 신규 시스템 아님, 기존 가중치 조정.
5. **선택 지평 확장**: 이번 주 선택이 3주 뒤 잊히지 않게 — 모멘텀/누적 보상(연차 정체성·스노우볼과 통합, 이미 있는 것 강화).
**C. 결과 가시화 (즉각+전략 동시 — 데모 우선)**
**C 데모 압박·결과 가시화 착수 (2026-07-16 Codex) — 만지는 파일:** `scenes/MainGame.gd`, `locale/ui_ja.json`, `tools/ImmersionLoopCheck.gd`, `tools/DemoBuildCheck.gd`, `tools/ScreenshotQA.gd`, `docs/AP_REDESIGN.md`, `docs/GAME_RECOMPOSITION_PLAN.md`, `docs/MASTER_RELEASE_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/DEMO_FIXLOG.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 데모 24주에서 기존 주간 초점·AP 카드·최근 행동 메아리를 `이번 주의 압박 하나 → 맥락 대응 세 개 → 다른 행동 접기`로 재편한다. 세 대응은 실제 기존 함수만 호출하며 커밋 전에 즉시 기대·AP/현금/몸 비용·위험 밴드·1~3주 뒤 남는 파장을 표시한다. 정확한 확률·숨은 Moral/route 수치는 노출하지 않고, 프리뷰는 상태를 바꾸지 않는다. 전체 5년의 기존 Act 보드는 보존하며 데모 수직 슬라이스가 실제 입력·KO/EN·1280×800·패드 포커스 게이트를 통과한 뒤에만 확산한다. 기존 사용자 변경 `project.godot`은 건드리지 않는다.
**C 자동 구현·검증 완료 보고 (2026-07-16 Codex — 사용자 재미 판정 대기):** 데모 24주의 첫 AP 표면을 현재 상태에서 뽑은 압박 하나와 정확히 세 개의 맥락 대응으로 교체했다. 세 대응은 큰 장소 스틸·번호·위험·AP 비용·즉시 기대·1~3주 메아리를 한 가로 무대에 담고, 기존 실제 `_ap_*` 함수만 호출한다. 전체 행동은 보조 출구로 남겼고 주 25~240의 Act 보드는 아직 바꾸지 않았다. 프리뷰 무변이·5종 압박·정확히 3개 함수·영문 무누출/숨은 moral 비노출, 1280×800 한 줄 카드·결과 수명·패드 복귀를 자동 래칫으로 잠갔다. EN 1,212입력/57사건, KO 1,228입력/59사건으로 24주를 실제 `ui_accept` 완주했고 둘 다 돈/사람 24/24, 주 25 CTA, 잔상 0을 통과했다. 자동 게이트만 끝났으므로 ORDER-26은 `[~]`를 유지한다.
6. **위험/보상 프리뷰**: 확률·판단이 걸린 AP 행동(투자·도박·구직·인맥)은 커밋 **전에** 예상 범위·리스크를 표시(예측 정보 치트 아님 — 밴드만, 정확한 값 비노출). "안전한 알바 vs 위험한 투자"가 진짜 도박이 되게.
7. **"이번 주의 압박" 프레임**(ORDER-22 인박스·시계와 통합): 매주 초점 하나(월세 D-day·다은 무응답·면접 결과일) — AP 행동이 그 압박에 응답하는 수단이 되게. "붕 뜸"의 직접 처방.
**검증**: CONVERGENCE_REPORT가 아키타입별 실질 발산을 보이는가(자동) + 유저 Round: "1번과 2번을 누를 때 고민이 됐는가 / 다르게 플레이하면 다른 5년이 될 것 같은가"(체감). 둘 다 GO여야 닫힘.

#### [x] ORDER-29 [P0·비주얼/거실] Living Scene — 정지 CG를 살아 있는 서울 장면으로 (유저 직접 지시 2026-07-16)
**StoryMode 수직 슬라이스 착수 (2026-07-16 Codex) — 만지는 파일:** `scenes/ui/LivingSceneLayer.gd`, `scenes/ui/LivingSceneLayer.gd.uid`, `assets/shaders/living_scene_fx.gdshader`, `assets/shaders/background_grade.gdshader`, `scenes/StoryMode.gd`, `tools/LivingSceneCheck.gd`, `tools/LivingSceneCheck.gd.uid`, `tools/LivingSceneCheck.tscn`, `tools/ScreenshotQA.gd`, `tools/audit.sh`, `docs/GANGNAM_INK_ART_DIRECTION.md`, `docs/MASTER_RELEASE_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 기존 사용자 변경 `project.godot`은 건드리지 않는다.
> 목표는 레퍼런스의 외형 복제가 아니라 PS5 패드와 큰 TV에서 “정지 사진 위 웹 UI”로 보이지 않는 장면 호흡이다. 기존 Gangnam Ink, Moral Tint, 장소 오디오, 카메라 지시를 보존하면서 화면의 전경·중경·후경이 서로 다른 속도로 살아 있게 한다.
1. **공통 Living Scene 계층:** StoryMode 배경과 초상/UI 사이에 절차적 날씨·공기 레이어를 둔다. 비, 눈, 안개/기억, 도시 빛, 불꽃을 장소·이벤트 ID·통신 채널에서 결정론적으로 추론하고, 장면 전환 때만 프로필을 바꾼다. 일반 실내는 효과를 억지로 넣지 않는다.
2. **깊이와 초점:** 배경에 저비용 다중 샘플 blur를 추가해 선택·기억·정점에서만 0~2px 범위로 사용한다. CG와 얼굴은 선명하게 남고 UI에는 셰이더를 적용하지 않는다. 4K에서 과도한 흐림, Steam Deck에서 과부하가 없도록 상한과 비활성 경로를 둔다.
3. **자연스러운 운동:** 기존 명시적 `scene_direction.camera`가 최우선이다. 그 지시가 없을 때만 1~2%의 느린 push/drift를 적용하고, 대면 초상은 위치를 흔들지 않는 0.2~0.4% 호흡을 쓴다. 선택 시 과한 스윕·흔들림·백색 플래시는 금지한다.
4. **의미 있는 효과:** 비/눈은 실제 날씨 장면, 불꽃은 축제, 안개·초점 이탈은 기억/충격에만 쓴다. Moral Black은 반짝임이 늘어나는 것이 아니라 공기와 인간적 움직임이 줄고 잔상·기계적 표면이 남으며, White는 노출 상승이 아니라 공간 깊이와 생활 입자가 돌아온다.
5. **영상 사용 원칙:** 동영상 파일은 오프닝·챕터 보스·핵심 엔딩 6~10개 후보에만 검토한다. 일반 사건은 레이어형 실시간 연출을 사용해 용량·압축·언어·분기 정합을 지킨다. 소유권/라이선스가 불명확한 영상은 금지한다.
6. **접근성·성능:** Reduce Motion에서는 카메라/초상 호흡을 정지하고 날씨 속도·불꽃을 감쇠한다. 첫 파동은 기존 설정값을 읽는 비노출 안전 폴백만 구현하고, 표시 옵션은 ORDER-16 입력·해상도 매트릭스에서 정식 표면화한다.
7. **검증:** 비·눈·기억/안개·불꽃·중립 장면 프로필, 명시 카메라 우선, 숨은 Moral 비노출, KO/EN 동일 효과, 결과/선택 UI 비가림을 실행 게이트로 잠근다. 1920×1080 실렌더와 픽셀 샘플로 레이어가 실제 비어 있지 않고 텍스트·얼굴을 덮지 않는지 확인한다. 이 수직 슬라이스 뒤 AP 허브와 챕터 카드 확산을 별도 판정한다.
**완료 보고 (2026-07-16 Codex):** 배경-초상/UI 사이 공통 계층, 의미 기반 비·눈·기억·도시 빛·폭죽, 0~2px 배경 전용 blur, 명시 카메라 우선과 1~2% 기본 호흡, 대면 초상 0.3% 호흡, Black의 생기 감쇠/잔상과 White의 깊이 회복, Reduce Motion 폴백을 구현했다. 1920×1080 KO/EN 각 5장면에서 레이어 순서·안전 영역을 확인했고, 최종 조정 뒤 독립 비 프레임 960표본 중 EN 19/KO 15개 변화로 실제 운동을 통과했다. 일반 실내는 입자 0이며 영상은 짧고 스킵 가능한 오프닝·보스·핵심 엔딩 후보에만 제한한다.

#### [x] ORDER-30 [P0·데모/오디오·공간] 서사 음악 문법 + 프롤로그 연속성 수리 (유저 실플레이 판정 2026-07-16)
**착수 (2026-07-16 Codex) — 만지는 파일:** `content/events/story_events.json`, `content/events_en/story_events.json`, `content/meta/story_rules.json`, `assets/event_visual_contracts.json`, `autoloads/BGMPlayer.gd`, `tools/story_consistency_audit.py`, `tools/BGMContinuityCheck.gd`, `tools/StoryPresenceCheck.gd`, `tools/MotivationImprintCheck.gd`, `docs/STORY_CONSISTENCY_SYSTEM.md`, `docs/AUDIO_QA.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 기존 사용자 변경 `project.godot`과 병렬 ORDER-18 파일은 건드리지 않는다. `story_last_payment_exit`의 비 오는 버스정류장에서 받은 아버지 전화를 후속 장면 끝까지 같은 장소로 유지하고, 통화 종료 뒤 귀가를 산문으로 명시한 다음에만 고시원 수첩 장면으로 전환한다. `story_rules.json`의 전환 계약은 `same_location`과 `explicit_move`를 구분하고, 감사가 데모 핵심 체인의 무단 공간 점프를 0으로 강제한다. 로파이 계열은 타이틀/게임 메뉴 로비에만 허용하고 일반 사건은 장소·계절·사람 앰비언스만, 정점은 명시된 문단 스코어만 사용하도록 런타임 게이트로 잠근다. 같은 사건·장면 전환에서 재생 위치를 초기화하지 않는다.
**완료 보고 (2026-07-16 Codex):** 아버지 통화는 비 오는 정류장과 rain 앰비언스를 끝까지 유지하고, 버스 탑승 결과 뒤 한영 귀가 문장이 나온 다음에만 고시원 수첩으로 이동한다. 스키마 2 전환 원장이 데모 핵심 11개 follow-up의 실제 위치·이동 방식·한영 도착 문장을 검사해 무단 점프 0을 강제한다. `menu/early/hustle/late_tense`는 로비 전용이며 일반 사건과 미배정 아크는 환경음만, 정점은 명시 문단 스코어만 사용한다. BGM·원격 초상·한영 커버리지·전체 audit와 53스크립트 컴파일을 통과했다.

#### [~] ORDER-31 [P0·오디오] 정선 카지노 전용 음악 정체성
카지노 입장부터 게임 테이블까지 로파이를 재사용하지 않는다. 카지노 플로어는 절제된 유혹의 모티프, 실제 베팅 구간은 같은 모티프의 더 강한 리듬 변주를 사용하며, 허브↔테이블 왕복에서 불필요한 재시작 없이 크로스페이드한다. 환경음·칩·카드·휠 물리음은 음악 아래에서 분리해 유지한다.

**착수 (2026-07-16 Codex) — 만지는 파일:** `autoloads/BGMPlayer.gd`, `scenes/JeongseonCasino.gd`, `assets/game_audio_manifest.json`, `tools/generate_audio_p1_assets.py`, `tools/audio_source_audit.py`, `tools/game_audio_contract_check.py`, `tools/BGMContinuityCheck.gd`, `tools/GameAudioContractCheck.gd`, `assets/audio/bgm_casino_floor.ogg`, `assets/audio/bgm_casino_floor.ogg.import`, `assets/audio/bgm_casino_table.ogg`, `assets/audio/bgm_casino_table.ogg.import`, `docs/AUDIO_QA.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 기존 사용자 변경 `project.godot`은 건드리지 않는다. `JeongseonCasino`가 여섯 하위 게임의 진입·복귀를 중앙 소유하므로 개별 테이블 파일은 수정하지 않는다. 두 트랙은 같은 길이·조성·모티프를 공유하며 플로어↔테이블 전환 때 현재 재생 위상을 넘겨 크로스페이드한다. 같은 상태 재진입은 재시작하지 않고, 카지노를 완전히 나갈 때만 주거·계절 앰비언스로 복귀한다.

#### [ ] ORDER-32 [P0·서사 데이터] 챕터·자산·선택 기반 랜덤 이벤트 디렉터
기존 1,177개 랜덤 풀을 새 콘텐츠로 늘리지 않고 챕터 창, 자산 밴드, 직업·주거·관계·최근 선택 조건과 1회성/반복 가능 정책으로 데이터화한다. 일반 랜덤 사건은 기본 1회/런으로 하고 명시적 반복 사건만 감쇠·쿨다운을 허용한다. 보장 아크와 follow-up 체인은 디렉터 밖에서 정본 순서를 보존한다.

#### [ ] ORDER-33 [P1·UI/타이포그래피] 텍스트 깊이와 재질 패스
유료 폰트 구매 전 기존 번들 폰트로 본문 가독성을 보존하면서 표면 위계를 만든다. 본문에는 과한 그림자를 금지하고, 장면 제목·핵심 금액·선택지·상태 변화에만 얕은 잉크 음영, 국소 배경 대비, 선택/확정 시 1~2px 깊이와 짧은 재질 모션을 적용한다. 720p·Steam Deck·4K에서 번짐과 이중상이 없는지 확인한 뒤 브랜드 디스플레이 글꼴 구매 필요성을 재판정한다.

#### [ ] ORDER-27 [P2·자문] 판매 톤 의견 — "성공의 대가" vs "성공 판타지" (유저 요청: Codex 판단도 듣고 싶다)
> Claude·유저는 "성공의 대가"(긴장) 쪽으로 기울었으나 미확정. Codex는 게임을 코드/데이터로 만지는 입장에서 **근거 있는 의견**을 낸다 — 최종 결정은 유저.
1. **데이터 근거 수집**: ①실제 엔딩 도달 분포(3,000런 — 성공/파멸/관계상실 비율. 대다수 플레이어가 실제로 뭘 경험하나) ②데모(t≤24)의 실제 감정 곡선(콜드오픈→무릎→첫 성취→데모 엔딩 — 데모가 판타지를 파나 긴장을 파나) ③상품 정의(색 붕괴·잃는 결혼)와 각 톤의 정합도.
2. **의견 산출**: `docs/STORE_TONE_OPINION.md`에 — 어느 톤이 ①게임의 실제 내용과 정직한가 ②데모가 실제로 주는 경험과 일치하는가 ③위시리스트 전환에 유리한가. 두 톤의 트레일러 첫 3초·데모 엔딩 CTA 카피를 각각 1안씩 써서 대조(유저가 실제 문장으로 비교하게).
3. **월권 금지**: 의견·대조안까지만. 톤 확정·트레일러 최종컷(ORDER-11)은 유저 도장 전까지 진행 금지.

#### [ ] ORDER-15 [P2] 모드 지원 2층 — 커뮤니티 언어팩 + 에셋 오버라이드 (유저 승인 2026-07-13)
> 판정: 스크립트 모딩·샌드박스는 기각(서사 게임 정합·QA 표면), 데이터 2층만 개방 — 공수 대비 커뮤니티 효과 최대 지점.
1. **커뮤니티 언어팩**: ORDER-12 로더 일반화에 확장 — `user://lang/<code>/` 아래 events_<code>/·endings_<code>.json·ui_<code>.json을 발견하면 언어 목록에 자동 추가(내장 언어와 동일 오버레이 규약). 팬번역이 JSON만으로 성립. 언어팩 제작 가이드 `docs/MODDING.md`(스키마·dik 패리티 규칙·검증 스크립트 사용법 포함 — 우리 en_coverage_check를 팬도 쓸 수 있게).
2. **에셋 오버라이드**: DataRegistry·ImageRegistry 로딩 초크포인트에 `user://mods/assets/` 우선 조회(동일 상대경로 덮어쓰기, 실패 시 내장 폴백). 오디오 포함. 공식 문구는 "에셋 교체를 기술적으로 지원"까지 — 특정 콘텐츠 비보증. **에셋 매니페스트 자동 생성**: 전 초상·CG·배경의 (상대경로·해상도·용도) 목록을 docs/MODDING.md에 표로 — 통짜 일러스트 교체 방식이라 이 목록이 모더의 전부다(VN 패치 표준 방식).
3. **안전 가드**: 모드 활성 시 타이틀에 소극적 표기(문제 리포트 구분용) + 세이브에 mod_active 플래그(버그 리포트 필터). 스크립트 로딩은 지원하지 않음을 명시.
4. 스토어 카피 한 줄 확보: "커뮤니티 번역·에셋 모드 지원" — 위시리스트 셀링포인트.

#### [x] ORDER-16 [P1] 입력×해상도 매트릭스 (유저 지시 2026-07-13 — "키보드 온리·마우스 온리 지원해")
**착수 (2026-07-16 Codex) — 만지는 파일:** `autoloads/DisplayManager.gd`, `autoloads/ControllerHints.gd`, `autoloads/AudioManager.gd`, `scenes/StartMenu.gd`, `scenes/MainGame.gd`, `scenes/StoryMode.gd`, `scenes/BlackjackTable.gd`, `scenes/BaccaratTable.gd`, `scenes/SlotMachineGame.gd`, `scenes/RouletteTable.gd`, `scenes/BigWheelGame.gd`, `scenes/DaiSaiTable.gd`, `scenes/HoldemClub.gd`, `scenes/RaceTrack.gd`, `scenes/JeongseonCasino.gd`, `locale/ui_ja.json`, `tools/InputMatrixCheck.gd`, `tools/InputMatrixCheck.gd.uid`, `tools/InputMatrixCheck.tscn`, `tools/StoryAudioSettingsCheck.gd`, `tools/ScreenshotQA.gd`, `tools/audit.sh`, `steam_input/game_actions_gangnam_dream.vdf`, `docs/INPUT_MATRIX.md`, `docs/CONTROLLER_UX_STRATEGY.md`, `docs/QA_CHECKLIST.md`, `docs/MASTER_RELEASE_AUDIT.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 기존 사용자 변경 `project.godot`은 건드리지 않는다. 창 모드·해상도·동작 감소·진동 on/off/강도를 플레이어 표면에 올리고, 키보드/마우스/세 패드 계열과 1080p·QHD·4K·21:9의 데모 핵심 표면을 실행 가능한 계약으로 잠근다. Steam Input 파일은 실제 AppID 없이도 액션셋·행동 이름을 검토할 수 있는 배포 템플릿까지만 만들며 플랫폼 SDK를 코드에 강결합하지 않는다.
1. **해상도 QA 매트릭스**: 1920×1080(16:9)·2560×1440·3840×2160·울트라와이드(3440×1440) ScreenshotQA 스코프 추가 — expand 여백에서 레이아웃 깨짐·앵커 이탈·글자 잘림 전수. CG/초상 4K 업스케일 체감 확인(필요 시 필터 설정). 창모드/전체화면/해상도 옵션 UI 유무 점검(없으면 추가 — 표준 기대치).
2. **키보드 온리 완주**: 마우스 입력 0으로 타이틀→데모 엔딩(t=24) 실주행 — 포커스 도달 불가 위젯·포커스 함정(빠져나갈 수 없는 모달)·카지노 7종 조작 가능 여부 전수, 발견 즉시 수리. 키 안내(패드 힌트의 키보드판) 표시.
3. **마우스 온리 완주**: 동일 구간 — 텍스트 입력 지점(플레이어 이름 등)은 기본값 제공+화면 키보드 or 클릭 진행 가능하게.
4. **패드 매트릭스**: Xbox·듀얼센스·스위치 프로콘 글리프 3종 스크린샷 검증 + 진동 지점 목록화(과다 진동 금지 — 결정·타이머 순간만). Steam Input 기본 구성 파일 준비.
5. 산출물: docs/INPUT_MATRIX.md(지원 선언표 — 스토어 페이지 "전체 컨트롤러 지원" 표기 근거).

**완료 보고 (2026-07-16 Codex):** 창모드·테두리 없는 창·전체화면과 720p~4K 선택, 타이틀/인게임의 Reduce Motion·진동 on/off/강도, 마지막 입력 장치에 따른 키보드/Xbox/DualSense/Switch Pro 글리프를 하나의 의미 입력층으로 통합했다. 1080p·QHD·4K·3440×1440 실제 렌더에서 설정·데모 AP·Living Scene과 2.5% TV 안전영역을 통과했고, 키보드 온리와 마우스 온리로 각각 24주 데모를 0 반대장치 이벤트로 완주했다. 카지노 허브·블랙잭·바카라·슬롯·룰렛·빅휠·다이사이·홀덤·경마는 키보드/패드 보조동작 18경로와 키보드 베팅→실행 9과업을 런타임으로 잠갔다. 1080p 영문 블랙잭에서 키보드 힌트와 최장 금액을 확인하며 중앙 베팅 스폿 잘림도 수리했다. `INPUT_MATRIX_CHECK_OK modes=3 resolutions=6 brands=3 direct_scenes=9 direct_routes=18 keyboard_tasks=9 action_sets=4`, 전체 감사 ERROR 0/WARNING 0·58스크립트 컴파일을 통과했다. 실제 Steam Deck/DualSense/Switch Pro의 손맛·재연결·절전복귀·Steam 오버레이는 물리 기기 게이트로 남아 있으므로 그 전까지 Steam의 Full Controller Support 표기는 보류한다.

**추가 실렌더 증거:** 1280×720과 1280×800에서도 설정·AP·Living Scene을 다시 렌더해 같은 TV 안전영역과 무스크롤 결정을 확인했다. 위로 흐르던 비·눈 UV 방향은 실제 두 프레임에서 아래쪽 `+24px` 이동으로 교정하고 회귀 게이트에 넣었다.

#### [ ] ORDER-17 [P3·출시 비차단] 데이터 모딩 3·4층 — 커스텀 이벤트 팩 + 밸런스 프리셋
> Claude 판정: 이 게임은 이벤트 1,477종이 전부 JSON = 반쯤 스토리 플랫폼. 3층을 열면 팬이 자기 사건을 쓴다. **출시 게이트 아님** — ORDER-12·15 로더 작업과 초크포인트가 같으니 그때 함께 하면 공수 최소.
1. **커스텀 이벤트 팩**: `user://mods/events/*.json`을 DataRegistry 로드 체인 끝에 추가(랜덤 풀 합류). **정본 격리 필수**: ①신규 모드 이벤트는 랜덤 풀에만 합류(`_next_arc_id` 스케줄 개입 불가) ②모드 이벤트의 신규 flags는 `mod_` 접두사만(로더 검증·위반 시 스킵+로그) ③id 충돌 기본=내장 우선, 단 **모드가 `"override": true`를 선언하면 아크 포함 동일 id 내용 교체 허용** — 스케줄 골격은 고정, 이야기(대사·선택지·효과·dik)는 통째 개작 가능 = "스토리 개작 모드" 성립(유저 승인 2026-07-13). 오버라이드 사용 세이브는 mod_active 강제.
2. **밸런스/시나리오 프리셋**: jobs.json·assets.json·items.json·news_templates.json도 user:// 오버라이드 허용(통째 교체 아닌 id 병합) — "하드코어 월세"·"금융위기 시나리오" 류 커뮤니티 프리셋 성립.
3. **인게임 모드 목록**: 시작 화면 설정에 감지된 모드 목록+개별 켜기/끄기+로드 순서(단순 리스트면 충분).
4. **모더 검증 도구**: 우리 audit의 축소판(JSON 스키마·mod_ 접두사·id 충돌 체크) 스크립트를 MODDING.md와 함께 배포.
4b. **테마 팔레트 데이터화 (색 모딩 + 접근성)**: `_moral_ui_palette()`의 밴드별 색 세트를 JSON 테마 파일로 추출 → user:// 오버라이드 허용. **구조 불변·값만 스킨**(밝음/회색/어둠 3단 밴드 구조는 도덕 표현이라 게임플레이 — 모더는 각 밴드의 색 값만 교체). 부수 산출: 공식 접근성 프리셋 2종(색약 팔레트·고대비) — "색으로 도덕을 말하는 게임"의 색약 지원은 리뷰 자산. 산재 hex 리터럴 전량 추출은 ORDER-18 B(v1.1 엔진 경화)로.
5. **Steam Workshop은 보류** — 출시 후 모드 씬 형성 확인 시 별도 오더(GodotSteam 연동 공수 큼).
> **포지셔닝 정본(유저 논의 2026-07-13)**: 토탈 컨버전("뉴욕 버전") 역량은 만들되 **스토어는 게임으로만 포지셔닝** — 플랫폼 지위는 커뮤니티가 사후에 명명하게(스카이림 패턴). 이 인프라의 1차 고객은 모더가 아니라 **우리 DLC**(다은의 5년·공식 스핀오프)다.
#### [x] ORDER-18 [P1] 기술 부채 전수 인벤토리 + 3분류 수리 (유저 원칙 2026-07-13: "길게 봐서 하드코딩 정리" — 시점 분류로 집행)
**착수 (2026-07-16 Codex) — 만지는 파일:** `tools/tech_debt_inventory.py`, `docs/TECH_DEBT.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`. 먼저 전 `.gd`의 크기·책임·긴 함수·매직 리터럴·복제 함수·동적 호출·죽은 코드 후보를 읽기 전용으로 재현하는 인벤토리를 만들고 A/B/C를 판정한다. A급 수리 대상이 확정되면 해당 소스와 검증 파일을 이 선언에 추가한 별도 커밋을 먼저 푸시한 뒤에만 수정한다. 기존 사용자 변경 `project.godot`은 건드리지 않는다.
**A급 수리 범위 추가 (2026-07-16 Codex) — 만지는 파일:** `data/EventData.gd`, `data/EventData.gd.uid`, `data/InvestmentData.gd`, `data/InvestmentData.gd.uid`, `data/ItemData.gd`, `data/ItemData.gd.uid`, `data/JobData.gd`, `data/JobData.gd.uid`, `data/NewsData.gd`, `data/NewsData.gd.uid`, `scenes/StartMenu.gd`, `autoloads/GameState.gd`, `scenes/MainGame.gd`. A-01 참조 0 초기 GDScript 데이터 정본, A-02 호출 0 폐기 타이틀 UI, A-03 명시 legacy no-op·제거된 미니게임 필드만 삭제한다. ORDER-30의 오디오·스토리 파일 범위와 `project.godot`은 건드리지 않는다.
**A-02 번역 잔여키 범위 추가 (2026-07-16 Codex) — 추가로 만지는 파일:** `locale/ui_ja.json`. 폐기 타이틀 UI에서만 쓰던 일본어 베타 키 5개를 제거해 UI 원문 집합과 정확히 맞춘다. 현재 화면의 번역은 바꾸지 않는다.
**A급 AP 시각 회귀 게이트 수리 (2026-07-16 Codex) — 만지는 파일:** `tools/ScreenshotQA.gd`. 과거 4개 고정 행동 카탈로그를 요구하던 검사를 현재 데모의 3개 상황별 결정 카드 계약으로 교체한다. 보이는 카드 수·각 카드의 장면 스틸 소유·서로 다른 장면 구성을 검사하며, 제품 화면과 콘텐츠 데이터는 변경하지 않는다.
**A급 AP 연락 카드 스틸 수리 (2026-07-16 Codex) — 만지는 파일:** `scenes/MainGame.gd`. 데모의 `contact` 결정만 일반 SVG로 후퇴하던 매핑 누락을 공용 `people` 장면 스틸에 연결해 세 카드 모두 같은 시각 문법을 지키게 한다.
**완료 보고 (2026-07-16 Codex):** 전수 기준선 91파일/61,569줄을 A/B/C로 판정하고, 참조 0 데이터 스크립트 5개+UID·폐기 타이틀 함수 3개·일본어 고아 키 5개·명시 legacy no-op만 제거했다. 사후 기준선은 86파일/59,524줄/2,429함수로 -5파일/-2,045줄/-19함수다. AP 상황 카드 3개는 각기 다른 장면 스틸 소유를 실렌더로 잠갔다. MainGame 분할·아크 스케줄러·미니게임 공용화는 B(v1.1), 엔딩 순서·dik 첫 매치·직렬화·원화 단위는 C 정본으로 보호한다. 전체 audit와 53스크립트 컴파일 통과; Steam AppID는 외부 발급 대기다.
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

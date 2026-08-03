# CODEX_QUEUE.md — Codex 작업 대기열·실행 스펙 (2026-07-07 Claude 작성)

> **Codex 세션 시작 시 이 파일을 CLAUDE.md 직후에 읽는다.** 위에서부터 우선순위순.
> 전략 맥락: Steam "압도적으로 긍정적"이 목표 지표, 5레버는 `CLAUDE.md` 현재 상태 참조.
> 신규 정본 선독: `docs/DECISIONS.md` 2026-07-07 5건(Godot 네이티브 완성 / 외부 파이프라인 / 설교 방지 5원칙 / AP 축 / EN 표기).
> **앵커 주의**: 아래 파일:라인은 2026-07-07 HEAD 기준 — 라인은 ±30 오차 허용, 함수명으로 찾을 것.

---

## 과거 사고 사례와 공통 함정

2026-07-07 이전의 병합 프로토콜·표면 용어 원칙·코드 앵커는 [queue_archive/CODEX_QUEUE_2026-07.md](queue_archive/CODEX_QUEUE_2026-07.md)에 보존한다. 지금도 유효한 함정만 남긴다.

- 유저 표면 문자열은 `_tr(kr,en)` 필수 — `_tr` 밖 한글 리터럴은 `english_hangul_audit.py`가 실패시킨다.
- 새 GameState var는 `serialize()` 또는 `tools/audit.py` `SERIALIZE_EXEMPT` 등록.
- MainGame은 StoryMode 다녀오면 재생성된다 — 턴 상태는 GameState 경유.
- 이벤트 JSON 루트의 새 키는 `tools/audit.py` `EVENT_ROOT_KEYS` 화이트리스트 선등록.
- 내부 시스템 용어(런/몽타주/tint/moral/축)는 플레이어 화면 노출 금지.
- 모든 신규 카피는 설교 방지 원칙(DECISIONS) 검수를 통과한다.

---

## 🎖 운영 프로토콜 v2 (2026-07-13 유저 지시 — Claude=지휘·판정 / Codex=실행 전부)

> 유저 결정: Codex 토큰은 상시 가용, Claude 토큰은 희소. **Claude는 오더 발행·diff/카피 판정·병합 정합·정본 수호만** 하고,
> 구현·산문·QA·이미지·번역·리서치·반복 작업은 전부 Codex가 수행한다.

**루프**: ①Claude가 아래 "활성 오더"에 스펙 발행 → ②Codex가 위에서부터 실행, 완료 시 `[x]`+보고 단락+WORK_LOG 기록+main 커밋 → ③Claude가 다음 세션에서 diff 감사·카피 스팟체크로 판정(불합격=REWORK 오더) → ④상태 블록 갱신.
**착수 선언 (2026-07-13 추가)**: Codex는 오더/큐 항목에 **착수하는 순간** 해당 항목을 `[~] 착수 — 만지는 파일: <목록>`으로 바꾸는 선언 커밋을 먼저 푸시한다(작업 커밋과 분리). 완료 시 `[x]`+보고로 전환. 이 마킹이 실시간 작업판이다 — Claude는 `[~]` 항목의 파일을 건드리지 않고, Codex는 선언 없이 큰 작업을 시작하지 않는다.
**정본 승격 판정 (2026-07-30 유저 승인 — 완료 조건)**: 오더를 `[x]`로 닫기 전에 **그 오더가 만든 규범 문장을 훑어 각각을 둘 중 하나로 판정한다** — ⓐ 계속 유효한 규칙이면 정본 소유자 문서에 승격하고 완료 보고에 `승격: <파일>:<절>`을 적는다, ⓑ 이 오더에서만 유효한 작업 지시면 `일회성`으로 명시한다. 판정하지 않은 규범 문장을 남긴 채 닫지 않는다.

이유: 활성 오더는 완료 시 아카이브로 옮겨지고 부팅 문서는 아카이브를 읽지 않는다. 인덱스 항목은 표에서 제거되고 현재 상태는 매번 덮어쓴다. **오더 안에만 있는 규칙은 닫히는 순간 어떤 새 세션에도 도달하지 않는다.**

승격 시 주의: 정본 소유자 한 곳만 갱신하고 다른 문서에 복사하지 않는다. 본문에 오더 번호나 진행 상태를 쓰지 않는다 — 오더가 끝나도 유효한 문장이어야 한다. 기존 정본에 이미 같은 규칙이 있는지 먼저 확인하되, **오더는 한국어이고 `assets/*VISUAL_BIBLE.md` 등 자산 정본은 영어이므로 한쪽 언어로만 검색하면 있는 규칙을 없다고 오판한다.** 두 언어로 확인하거나 소유자 문서의 해당 절을 직접 읽는다.

**작업 단위 규격 (2026-07-30 유저 지시 — 완료 조건)**: 한 단위는 하나의 판정 가능한 것(원고 300~800자 또는 파일 1~3개), 한 배치는 서로 의존하지 않는 15~25단위다. 착수 전 `깊이 3문`, 완료 시 `증거 양식`, 판정은 L1 기계·L2 자가·L3 사람 표본. **배치 20단위마다 사용자가 무작위 3개를 보고 하나라도 불합격이면 전량 반려한다.** 대형 다단계 오더를 만들지 않고 새 발견은 새 오더로 분리한다. 전체 규격은 [WORK_UNIT.md](WORK_UNIT.md)가 소유한다.

**Codex 사전 승인 대기 항목**(오더 없이 착수 금지): 정본 규칙 변경 / finish_run·엔딩 라우팅 / 밸런스 밴드 밖 수치 / 오더에 없는 신규 시스템 / **반쪽 기능의 완성 또는 제거**. 반쪽을 자기 판단으로 완성하는 것은 수리처럼 보이는 오더 밖 신규 작업이며, 이 저장소가 반쪽을 쌓아 온 경로다. 만들 근거도 지울 근거도 정본 인용이어야 하고, 인용할 정본이 없으면 판단이 아니라 의견이므로 `POST_LAUNCH_NOTES.md`에 기록만 한다. 그 외(표면·아트·QA·기존 큐 항목)는 기존처럼 자율.
**Tier1 정점 산문**(§8 레지스트리)은 Codex가 초안 작성까지, 커밋 후 Claude 판정·리터치를 받는다(불합격 시 리라이트).

### 활성 오더 인덱스

> **읽기 규칙:** 이 인덱스에서 실행할 항목 하나를 고른 뒤 해당 `queue_active/<ID>.md`만 읽는다. 완료 이력 전체를 기본 컨텍스트에 넣지 않는다.
> **`[~]` 레거시 항목(9번 이하)은 자동 게이트가 전부 PASS이고 남은 것은 사람 판정뿐이다.**
> 그 행의 게이트 열에는 열려 있는 사람 판정만 적는다.
> **착수/완료 규칙:** 상태는 이 표가 정본이다. 상세 사양·범위 확장은 해당 활성 파일에 기록하고 선언 커밋을 먼저 푸시한다. 완료 시 보고를 월별 아카이브와 WORK_LOG에 옮기고 표에서 제거한다.

| 순서 | 상태 | 항목 | 전체 사양 | 현재 게이트 |
|---:|:---:|---|---|---|
| 1 | [~] | ORDER-68 · 데모 출시 실행 순서 정합화 | [ORDER-68](queue_active/ORDER-68.md) | **착수 — 만지는 파일:** 실행 큐·현재상태·인계·제안·사람 게이트·정합 검사. 게임 내용은 바꾸지 않는다 |
| 2 | [~] | ORDER-57 · Core Loop V2 데모 재구축 | [ORDER-57](queue_active/ORDER-57.md) | D 1~20주 AUTO PASS. **E 21~24주 후보 재통합 중** — 밀도·생계 authored·`direction` 백필과 조기 `mental_break` P1을 닫기 전 E PASS 금지. 전환·사람 GO OPEN |
| 3 | [~] | ORDER-60 · 프롤로그부터 전면 재검토 | [ORDER-60](queue_active/ORDER-60.md) | 배치 1·2 완료([PROLOGUE](PROLOGUE_TIER_AUDIT.md)·[DEMO](DEMO_TIER_AUDIT.md)), P0 0건. **3~7은 데모 출고 뒤** |
| 4 | [ ] | ORDER-62 · 기능 생존·킬링포인트 감사 | [ORDER-62](queue_active/ORDER-62.md) | **기계 축 완료(Claude)** — 고아 스크립트 래칫(`feature_liveness_audit`). 남은 것은 네 판정·킬링포인트 전수 판정, **제거는 사용자 승인 뒤** |
| 5 | [ ] | ORDER-61 · 정본 공백 (심의·접근성·저장·성능·오디오·리스크) | [ORDER-61](queue_active/ORDER-61.md) | 미착수. **배치 1(등급·심의)이 P0** — 도박 4종 5,496줄에 GRAC·Steam 언급이 정본 0개. 등급은 사용자 결정. 나머지 다섯은 독립 |
| 6 | [ ] | ORDER-59 · 정합 기반 (지식 원장·다은 phase·규칙 화계) | [ORDER-59](queue_active/ORDER-59.md) | 미착수. **대화량을 늘리기 전에 선행한다** — 화자도 지식도 표현할 자리가 없고 다은 phase가 typed fact가 아니다. 신규 장면에만 필수, 기존 1,581건은 래칫 |
| 7 | [ ] | ORDER-58 · 데모 평가 후속 | [ORDER-58](queue_active/ORDER-58.md) | 미착수. 축 대칭·유혹 밀도·선택지 중립. `ORDER-57` E 뒤, 영어 유혹 선택지 수리만 선행 가능. **구현보다 정본 배치를 먼저.** 장르·스토어 약속은 사용자 결정 대기 |
| 8 | [ ] | ORDER-67 · `.gd` 분해 (한 파일이 전부인 상태) | [ORDER-67](queue_active/ORDER-67.md) | 미착수. **`ORDER-57` E 뒤, `ORDER-63` 배치 3 앞.** `MainGame.gd` 19,984줄=전체 21%, 함수 688·`signal` 0. 테마 override 645건(27%)이 여기 있어 배치 3을 막는다. **첫 칼은 미접촉 316함수 7,267줄** |
| 9 | [ ] | ORDER-63 · 표면 단일 언어 (UI·폰트·테마) | [ORDER-63](queue_active/ORDER-63.md) | **배치 1·2 완료(Claude)** — 계측기(`surface_coherence_audit`)·물성 정본(`SURFACE_MATERIAL`). 배치 3(테마 단일 출처)이 화면을 바꾼다. **데모 화면만** |
| 10 | [ ] | ORDER-64 · 서명·연속성 강제 | [ORDER-64](queue_active/ORDER-64.md) | **배치 1·2 완료(Claude)** — 서명표를 `identity_signature.json`으로 승격·배선. 알려진 결함 5건은 래칫. 배치 3~7(모티프·음색·채택률·연속성) 미착수 |
| 11 | [ ] | ORDER-65 · 장이 닫는 것을 실제로 닫는다 | [ORDER-65](queue_active/ORDER-65.md) | **데모 출고 뒤.** `narrative_spine`이 장마다 닫는 동사를 선언하는데 구현이 0 — 3장이 `시간 팔기`를 닫는다면서 `JobSystem`에 장 게이팅이 없다. 소비자 없는 정본 |
| 12 | [ ] | ORDER-66 · 제품 패키징 (크레딧·버전·고지) | [ORDER-66](queue_active/ORDER-66.md) | 미착수. **빠진 것 셋** — 엔딩 크레딧·게임 버전 문자열·게임 내 제3자 고지. 폰트 OFL 사본과 빌드 포함은 선수리 완료. Steam SDK는 심의 뒤 별도 |
| 13 | [~] | ORDER-43 · 실제 녹음/샘플 오디오 REWORK | [ORDER-43](queue_archive/ORDER-43.md) | 장별 사람 연속 청취 |
| 14 | [~] | USER-P0N · 데모 장면 연출 문법 240주 전 구간 확산 | [USER-P0N](queue_archive/USER-P0N.md) | 정상 속도·실기기·A/V 사람 판정 |
| 15 | [~] | ORDER-21 · 일본어 번역 웨이브 | [ORDER-21](queue_archive/ORDER-21.md) | 데모 GO 뒤 본문 번역·15장 캡처·원어민 검수 |
| 16 | [~] | ORDER-23 · 동기 각인 수술 | [ORDER-23](queue_archive/ORDER-23.md) | 동기 문장 기억 여부 사람 판정 |
| 17 | [~] | ORDER-22 · 주간 루프 몰입 수리 | [ORDER-22](queue_archive/ORDER-22.md) | 정상 속도 몰입·재미 사람 판정 |
| 18 | [~] | ORDER-28 · 240주 전체 재구성 | [ORDER-28](queue_archive/ORDER-28.md) | 외부 정상 독해 10인 플레이 0/10 |
| 19 | [~] | ORDER-26 · AP 의미화 | [ORDER-26](queue_archive/ORDER-26.md) | 망설임·전략 재미 사람 판정 |

### 완료 이력

- **2026-07 전체 원문 스냅샷:** [CODEX_QUEUE_2026-07.md](queue_archive/CODEX_QUEUE_2026-07.md)
- 상세 작업 결과는 [WORK_LOG.md](WORK_LOG.md), 사용자 노트와 라운드 판정은 [DEMO_FIXLOG.md](DEMO_FIXLOG.md), 설계 결정은 [DECISIONS.md](DECISIONS.md)가 정본이다.
- `[x] ORDER-56` (2026-07-27): 실제 노출 사건 443개 전수 분류와 고위험 26장면 정합. [사양](queue_archive/ORDER-56.md)
- `[x] ORDER-55` (2026-07-26): 동적 주거·현재 직업 계약을 사건·시각·오디오까지 정렬. [사양](queue_archive/ORDER-55.md)
- `[x] ORDER-54` (2026-07-26): 씨앗 5건의 수확 12건을 예약해 휴면 체인 0. [사양](queue_archive/ORDER-54.md)
- `[x] ORDER-53` (2026-07-26): 지연 예약 정규화와 재혁·상철 대가 3건 부활. [사양](queue_archive/ORDER-53.md)
- `[x] ORDER-52` (2026-07-26): 고유 지연 회수 29건 예약. 전량 부활은 금지. [사양](queue_archive/ORDER-52.md)
- `[x] ORDER-51` (2026-07-26): 도달 가능 콜백의 결함 3건 수리와 휴면 기준선 회귀 게이트. [사양](queue_archive/ORDER-51.md)
- `ORDER-50` 이전 완료 이력은 월별 원문 스냅샷과 `WORK_LOG.md`에서 조회한다.

## 공통 검증 (모든 항목)
```bash
GODOT=<경로> ./tools/audit.sh          # 마지막 줄 "✅ 감사 통과"
python3 tools/english_hangul_audit.py  # content_issues=0, runtime_candidate=0
xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=<해당 스코프> --lang=en
```
- 완료 시 CLAUDE.md 현재 상태 + docs/WORK_LOG.md 갱신, 이 파일 해당 항목에 `[x]`+날짜.

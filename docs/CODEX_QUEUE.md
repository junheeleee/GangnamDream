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

### 활성 오더 인덱스

> **읽기 규칙:** 이 인덱스에서 실행할 항목 하나를 고른 뒤 해당 `queue_active/<ID>.md`만 읽는다. 완료 이력 전체를 기본 컨텍스트에 넣지 않는다.
> **착수/완료 규칙:** 상태는 이 표가 정본이다. 상세 사양·범위 확장은 해당 활성 파일에 기록하고 선언 커밋을 먼저 푸시한다. 완료 시 보고를 월별 아카이브와 WORK_LOG에 옮기고 표에서 제거한다.

| 순서 | 상태 | 항목 | 전체 사양 | 현재 게이트 |
|---:|:---:|---|---|---|
| 1 | [~] | ORDER-57 · Core Loop V2 데모 재구축 | [ORDER-57](queue_active/ORDER-57.md) | 6개월 설계·데이터 감사 PASS, 기존판 병존 1~8주 수직 단면 착수 전 |
| 2 | [~] | ORDER-43 · 실제 녹음/샘플 오디오 REWORK | [ORDER-43](queue_active/ORDER-43.md) | 전 사건·배경·대표 240주 자동 확산과 clean RC `d73afa6` PASS, 장별 사람 연속 청취 OPEN |
| 3 | [~] | USER-P0N · 데모 장면 연출 문법 240주 전 구간 확산 | [USER-P0N](queue_active/USER-P0N.md) | 1,565사건·960주 정적/KO·EN 240주 실주행·논리 4K와 clean RC PASS, 정상 속도·실기기·A/V 사람 판정 OPEN |
| 4 | [~] | ORDER-21 · 일본어 번역 웨이브 | [ORDER-21](queue_active/ORDER-21.md) | 번역 인프라·일본어 UI/프롤로그/직업명 자동 검사 PASS, 데모 GO 뒤 본문 번역·15장 캡처·원어민 검수 OPEN |
| 5 | [~] | ORDER-23 · 동기 각인 수술 | [ORDER-23](queue_active/ORDER-23.md) | 자동 구조·KO/EN 런타임 PASS, 플레이어의 동기 문장 기억 여부 사람 판정 OPEN |
| 6 | [~] | ORDER-22 · 주간 루프 몰입 수리 | [ORDER-22](queue_active/ORDER-22.md) | 자동 주간 루프·입력·오디오·KO/EN PASS, 정상 속도 몰입·재미 사람 판정 OPEN |
| 7 | [~] | ORDER-28 · 240주 전체 재구성 | [ORDER-28](queue_active/ORDER-28.md) | 구조·240주·엔딩·3플랫폼 clean RC 자동 게이트 PASS, 외부 정상 독해 10인 플레이 0/10 OPEN |
| 8 | [~] | ORDER-26 · AP 의미화 | [ORDER-26](queue_active/ORDER-26.md) | AP 인과·포기·후속·KO/EN·패드·240주 자동 게이트 PASS, 망설임·전략 재미 사람 판정 OPEN |

### 완료 이력

- **2026-07 전체 원문 스냅샷:** [CODEX_QUEUE_2026-07.md](queue_archive/CODEX_QUEUE_2026-07.md)
- 상세 작업 결과는 [WORK_LOG.md](WORK_LOG.md), 사용자 노트와 라운드 판정은 [DEMO_FIXLOG.md](DEMO_FIXLOG.md), 설계 결정은 [DECISIONS.md](DECISIONS.md)가 정본이다.
- `[x] ORDER-56` (2026-07-27): 런타임 진입점 306개와 후속 폐쇄로
  실제 노출 사건 442개를 고정하고 상태 민감 433개·검토 중립 9개로
  전수 분류했다. 직업·주거·관계·아버지 생사·장소 계약과 고위험
  26장면의 산문·시각·오디오 정합을 감사로 잠그고 발견 모순을 한영
  동시 수리했다.
  [완료 사양](queue_archive/ORDER-56.md)
- `[x] ORDER-55` (2026-07-26): 실제 노출 사건의 동적 주거·현재 직업
  계약을 사건·산문·시각·오디오·전환 원장까지 정렬했다. 이사 뒤
  고시원 회귀와 무직 상태의 회사 전용 사건을 차단하고, 동적 장소 58건과
  원장 135건을 자동 감사로 잠갔다.
  [완료 사양](queue_archive/ORDER-55.md)
- `[x] ORDER-54` (2026-07-26): 씨앗 5건의 생산자 선택 14행에서
  수확 12건을 8~12주 뒤 예약해 휴면 체인을 0으로 닫았다. 예약 조건을
  현재 직업·주거에 다시 대입하고 실제 취업·이직·월수입, 거절 기억,
  한영·일본어 UI와 장소 정합까지 잠갔다.
  [완료 사양](queue_archive/ORDER-54.md)
- `[x] ORDER-53` (2026-07-26): 지연 예약을 기존 문자열 또는 혼합
  배열로 정규화하고 엔진·모드·감사·시뮬레이터 전 소비자와 저장 회귀를
  잠갔다. 기존 1주 후속을 유지한 채 재혁·상철의 12~14주 대가 3건을
  부활시키고 한영 산문·장소·통화 표면을 정렬했다.
  [완료 사양](queue_archive/ORDER-53.md)
- `[x] ORDER-52` (2026-07-26): 생산자 선택 34행에서 고유 지연 회수
  29건을 8~16주 뒤 예약하고 산문·효과·조건·장소·한영 표면을 정렬했다.
  T2 엔진 배열 확장과 추가 3행은 사용자 승인 뒤 ORDER-53으로 이관했다.
  [완료 사양](queue_archive/ORDER-52.md)
- `[x] ORDER-51` (2026-07-26): 도달 가능한 콜백 24건 중 결함 3건의
  금액·산문·시점·장소를 한영 정렬했다. 콜백 620건과 체인 12건의
  실제 진입 경로를 계산하는 회귀 게이트를 추가해 휴면 기준선 596+12의
  증가를 차단했고, 선별 부활 결정은 ORDER-52로 분리했다.
  [완료 사양](queue_archive/ORDER-51.md)
- `ORDER-50` 이전 완료 이력은 월별 원문 스냅샷과 `WORK_LOG.md`에서 조회한다.

## 공통 검증 (모든 항목)
```bash
GODOT=<경로> ./tools/audit.sh          # 마지막 줄 "✅ 감사 통과"
python3 tools/english_hangul_audit.py  # content_issues=0, runtime_candidate=0
xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=<해당 스코프> --lang=en
```
- 완료 시 CLAUDE.md 현재 상태 + docs/WORK_LOG.md 갱신, 이 파일 해당 항목에 `[x]`+날짜.

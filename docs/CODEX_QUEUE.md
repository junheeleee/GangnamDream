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
| 1 | [~] | ORDER-48 · 정점 산문 밀도 역전 수리 | [ORDER-48](queue_active/ORDER-48.md) | 착수 2026-07-25 · 로맨스 경첩·엔딩 회수 산문 수리 |
| 2 | [ ] | ORDER-49 · 선택의 고민 장부화 | [ORDER-49](queue_active/ORDER-49.md) | ⚠P2, 밸런스·유저 승인 필요·산문분만 선제 |
| 3 | [ ] | ORDER-50 · 리뷰 부록(동기 문장 회수·루트 변주 설교) | [ORDER-50](queue_active/ORDER-50.md) | P1, ORDER-48 완료·커밋 후 착수(파일 겹침) |
| 4 | [~] | ORDER-43 · 실제 녹음/샘플 오디오 REWORK | [ORDER-43](queue_active/ORDER-43.md) | 데모 완료, 본편 240주 확산·장별 연속 청취 OPEN |
| 5 | [ ] | USER-P0N · 데모 장면 연출 문법 240주 전 구간 확산 | [USER-P0N](queue_active/USER-P0N.md) | 사양 기록, 구현 미착수 |
| 6 | [~] | ORDER-21 · 일본어 번역 웨이브 | [ORDER-21](queue_active/ORDER-21.md) | 부분 보류 |
| 7 | [~] | ORDER-23 · 동기 각인 수술 | [ORDER-23](queue_active/ORDER-23.md) | 외부 정상 독해 판정 대기 |
| 8 | [~] | ORDER-22 · 주간 루프 몰입 수리 | [ORDER-22](queue_active/ORDER-22.md) | 외부 정상 독해 판정 대기 |
| 9 | [~] | ORDER-28 · 240주 전체 재구성 | [ORDER-28](queue_active/ORDER-28.md) | 전체 범위 지속 개선 |
| 10 | [~] | ORDER-26 · AP 의미화 | [ORDER-26](queue_active/ORDER-26.md) | 외부 정상 독해 판정 대기 |

### 완료 이력

- **2026-07 전체 원문 스냅샷:** [CODEX_QUEUE_2026-07.md](queue_archive/CODEX_QUEUE_2026-07.md)
- 상세 작업 결과는 [WORK_LOG.md](WORK_LOG.md), 사용자 노트와 라운드 판정은 [DEMO_FIXLOG.md](DEMO_FIXLOG.md), 설계 결정은 [DECISIONS.md](DECISIONS.md)가 정본이다.
- `[x] USER-P0S` (2026-07-26): 긴 산문 안전 분할과 숨은 관계 수치 비노출,
  직업·인물 역할·장소·A/V의 사건 ID 결합 계약, 지연 버스정류장/한식당
  분기, 경마 실제 진입·결과 입력·경마장 복귀를 수리했다.
  [완료 사양](queue_archive/USER-P0S.md)
- `[x] USER-P0R` (2026-07-25): "고시원 공용 주방" 현수 장면을 개인실
  배경에서 분리해 같은 건물의 전용 주방 자산·사건 계약·회귀 감사를
  추가하고 실제 StoryMode 합성을 확인했다.
  [완료 사양](queue_archive/USER-P0R.md)
- `[x] USER-P0Q` (2026-07-25): 상철과 민준만 있는 사설 부동산
  사무실 4장면에서 공용 `public_interior` 사람층과 14.7초 기침을
  억제하되 사무실 룸톤·문단 폴리·무음악 연출은 유지했다.
  [완료 사양](queue_archive/USER-P0Q.md)
- `[x] USER-P0P` (2026-07-25): 민준 피로 초상의 붉고 반쯤 감긴 눈과
  붕괴된 상체를 같은 얼굴·검은 크루넥의 열린 하향 시선과 이완된 어깨로
  교체하고, 인물별 자세 실루엣 계약을 정본화했다.
  [완료 사양](queue_archive/USER-P0P.md)
- `[x] USER-P0O` (2026-07-25): 사용자 승인 JUNPAC GAMES PNG를 순백
  퍼블리셔 프리롤에 중앙 배치하고 과거 JPEG·코드 초승달을 제거했다.
  [완료 사양](queue_archive/USER-P0O.md)
- `[x] ORDER-47` (2026-07-25): 1장 환불선·결산, 중반 계산 장면,
  4장 간격, 4→5 정산 호흡과 실제 12월 보스 주를 정렬했다. 직접 결정
  52회·Echo 21회·대표 경로 잼 0을 잠갔다.
  [완료 사양](queue_archive/ORDER-47.md)
- `[x] ORDER-46` (2026-07-25): 랜덤 풀의 출처 없는 금전·산문 모순·
  스케일 이탈을 수리하고 초기 콜백 400개·후기 유보 분기 162개의 설교투
  결구를 낮췄다. [완료 사양](queue_archive/ORDER-46.md)
- `[x] ORDER-45` (2026-07-25): 지연·다은·민준·상철의 관계 단계별 호칭과
  말투를 사건·엔딩·영어 `oppa` 동일 필드까지 정렬하고 자동 회귀 감사를 추가했다.
  [완료 사양](queue_archive/ORDER-45.md)
- `[x] ORDER-44` (2026-07-25): 죽은 아버지 재등장, 인물 오기, 현수·상철
  궤적, 다은 사문, 엔딩 dik·나이·시제 등 정합 P0 18군을 수리하고 회귀
  계약을 확장했다. [완료 사양](queue_archive/ORDER-44.md)
- `[x] USER-P0M` (2026-07-24): 엔딩 35종을 고유 1280x800 전용 CG로 배선하고 도형·공용 카드·크롭 폴백을 제거했다. 한영 70장 런타임과 전체 감사를 통과했다. [완료 사양](queue_archive/USER-P0M.md)
- `[x] USER-P0L` (2026-07-24): 부팅 16.9KB·작업 프로필·문서 매니페스트·최근/보관 로그·프로젝트 스킬·자동 맥락 게이트를 구축하고 낡은 60턴 정본을 240주로 정렬했다.
- `[x] USER-P0K` (2026-07-24): 395KB 단일 큐를 활성 인덱스·ID별 사양·월별 원문 아카이브로 무손실 분리했다.

## 공통 검증 (모든 항목)
```bash
GODOT=<경로> ./tools/audit.sh          # 마지막 줄 "✅ 감사 통과"
python3 tools/english_hangul_audit.py  # content_issues=0, runtime_candidate=0
xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=<해당 스코프> --lang=en
```
- 완료 시 CLAUDE.md 현재 상태 + docs/WORK_LOG.md 갱신, 이 파일 해당 항목에 `[x]`+날짜.

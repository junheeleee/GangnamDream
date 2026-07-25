# CLAUDE.md — 강남드림 (Gangnam Dream)

> 이 파일은 모든 에이전트의 짧은 부팅 문서다. 긴 이력을 읽지 말고 3분 안에 현재 작업으로 복귀한다.
> 작업별 정본 라우팅은 [`docs/CONTEXT_INDEX.md`](docs/CONTEXT_INDEX.md), 기계 판독 계약은
> [`docs/context_manifest.json`](docs/context_manifest.json)이 소유한다.

## 현재 상태

| 항목 | 내용 |
|---|---|
| 목표 | Steam 유저 평가 "압도적으로 긍정적"(95%+). Metacritic 90은 방향이지 자동 판정 지표가 아니다. |
| 상품 정의 | **"나는 민준이다. 매주 무언가를 걸고, 건 것의 대가를 살아낸다."** 플레이어를 구경꾼으로 부르거나 숨은 도덕 점수를 설명하지 않는다. |
| 현재 범위 | 1턴=1주, 240주(5년), 데모=24주. 직접 Decision/Boss는 전체 52회이며 나머지 시간은 Quiet/Echo로 압축한다. |
| 품질 게이트 | [`docs/MASTER_RELEASE_AUDIT.md`](docs/MASTER_RELEASE_AUDIT.md). 콘텐츠 수량보다 블랙박스 플레이, 한영 패리티, 패드 과업, 사람 기억·전환 증거로 판정한다. |
| 최근 완료 | `ORDER-46` 랜덤 풀 위생 P1. 출처 없는 금전·산문 모순·스케일 이탈을 정렬하고, 초기 콜백 400개와 후기 유보 분기 162개의 격언·자기계발 결구를 낮췄다. 근거 원장 [`docs/SCRIPT_REVIEW_2026-07-24.md`]. |
| 바로 다음 | `ORDER-47` 편성/구조 P1. 이후 `ORDER-48` 정점 산문 P1, `ORDER-49`는 밸런스·유저 승인 게이트다. 오디오 `ORDER-43`/연출 `USER-P0N` 확산과 병행 가능. |
| 열려 있는 사람 게이트 | 데모 오디오 자동·RC는 완료됐지만, 본편 전 구간 A/V 연출 확산과 장별 대표 경로의 헤드폰·노트북·TV/Reduce Motion 체감 GO는 미완료다. |
| 마지막 갱신 | 2026-07-25 (Codex: ORDER-46 랜덤 풀 위생 P1 완료) |

사용자가 새 지시를 주면 그것이 위 순서보다 우선한다.

## 세션 시작

1. 이 파일의 `현재 상태`와 `불변 규칙`만 읽는다.
2. `git status --short --branch`로 현재 브랜치와 사용자 변경을 확인한다. 알 수 없는 변경은 되돌리지 않는다. 현재 사용자 소유 변경인 `project.godot`은 명시적 요청 없이는 수정·스테이징·복구하지 않는다.
3. [`docs/CODEX_QUEUE.md`](docs/CODEX_QUEUE.md)의 활성 인덱스에서 실행할 항목 하나를 고르고, 해당 `docs/queue_active/<ID>.md` 하나만 읽는다.
4. [`docs/CONTEXT_INDEX.md`](docs/CONTEXT_INDEX.md)에서 작업 종류에 맞는 프로필을 골라 필수 문서만 읽는다.
5. 최근 작업이 필요하면 `docs/WORK_LOG.md` 앞부분만 읽는다. 과거 근거가 필요할 때만 `docs/history/`, `docs/queue_archive/`, `docs/archive/`를 검색한다.
6. 설계 결정은 `docs/DECISIONS.md` 전체를 읽지 말고 먼저 `rg -n "<주제>" docs/DECISIONS.md`로 관련 절만 찾는다.

기본 컨텍스트에 `WORK_LOG` 보관본, `RELEASE_NOTES`, 큐 아카이브, 감사 보고서 전체를 넣지 않는다.

## 정본 판정

같은 주제의 문서가 충돌하면 다음 순서로 판정한다.

1. 현재 대화의 최신 사용자 지시
2. 같은 주제의 최신 `docs/DECISIONS.md` 항목
3. `docs/context_manifest.json`이 지정한 도메인 정본 문서
4. 런타임 코드·데이터가 보여 주는 현재 동작
5. 계획서·감사 보고서·작업 이력·아카이브

런타임이 정본과 다르면 런타임을 자동으로 정답 취급하지 않는다. 버그인지 정본이 낡았는지 확인하고, 한쪽만 조용히 바꾸지 말고 소유 문서와 구현을 같은 작업에서 정렬한다. 새로운 규칙은 기존 문서에 중복 작성하지 않고 정본 소유자 한 곳을 갱신한 뒤 필요하면 `DECISIONS.md`에 이유만 남긴다.

## 불변 규칙

### 작품과 시간

- 주제 스파인: **"같은 길을 오르면서, 같은 사람이 되지 않을 수 있을까."**
- 4대 가치 축: **돈, 사랑, 가족, 신념**. 결정적 장면은 둘 이상을 같은 프레임에 둔다.
- 33세 백수 김민준이 현금 50만원으로 시작해 38세 전 자산 30억원을 목표로 한다.
- 성실한 직장생활만으로 5년 안에 30억원을 보장하지 않는다. 성실함은 안정·관계·전문성·의미 있는 비강남 결말을 만들며, 큰 돈은 드물고 위험한 기회를 요구한다.
- 현재 콘텐츠 동결이 기본이다. 버그·정합·QA·번역·승인된 인프라와 `ORDER-28`의 기존 콘텐츠 재편만 허용하며, 새 아이디어는 `docs/POST_LAUNCH_NOTES.md`에 기록한다. 사용자의 직접 지시는 동결을 해제할 수 있다.

### 인물과 서사

- 호칭·연애·결혼·이별은 [`docs/ROMANCE_SYSTEM.md`](docs/ROMANCE_SYSTEM.md)가 소유한다.
- 인물 나이·역할·첫 만남·세계관은 [`docs/STORY_BIBLE.md`](docs/STORY_BIBLE.md)와 [`docs/CANON_MAP.md`](docs/CANON_MAP.md)가 소유한다.
- 아버지 생사, 지연 관계 단계, 상철 진실, 통화·기억·장소 이동은 `content/meta/story_rules.json`과 [`docs/STORY_CONSISTENCY_SYSTEM.md`](docs/STORY_CONSISTENCY_SYSTEM.md)를 먼저 확인한다.
- 조건이 성립하지 않은 인물·직업·관계·장소를 산문이나 이미지가 발명하면 안 된다. 전화·메시지·기억의 초상은 실제 동석처럼 보이면 안 된다.
- 명장면은 루틴 압축으로 확보한 시간을 소설 밀도에 쓴다. 감각 구체, 시간 늘리기, 절제된 연기, 여운을 갖추며 짧은 교훈 카드로 대체하지 않는다.

### 선택과 MORAL_TINT

- 직접 주의 핵심은 한 번의 장면 약속이다. 작성형 아크가 주간 갈등을 소유하면 일반 AP 3택을 다시 열지 않는다.
- 선택은 실제 비용, 놓친 길, 늦은 회수를 가져야 한다. 미래 결과를 선택 전에 확정적으로 해설하지 않는다.
- `moral_tint`, route, 선악 등급, 정확한 숨은 확률은 플레이어에게 절대 노출하지 않는다.
- MORAL_TINT는 UI 색놀이가 아니라 세계 인식의 변화다. 사람층, 공간, 산문, 초상 연기, 재질이 서서히 달라지되 버튼이 밝아졌다는 식으로 도덕을 설명하지 않는다.
- AP 분류·약속·몽타주 계약은 [`docs/AP_REDESIGN.md`](docs/AP_REDESIGN.md), MORAL 정본은 [`docs/MORAL_TINT.md`](docs/MORAL_TINT.md)가 소유한다.

### 데이터와 현지화

- KR 사건은 `content/events/`, EN은 `content/events_en/`의 text-only 오버레이다. gameplay key는 KR에만 둔다.
- 새 플래그는 생산자와 실제 독자를 함께 가져야 한다. write-only·inert 기준선은 0이다.
- 유저 표면 문자열은 `_tr(ko, en)`을 사용한다. 영어 표면에 한글이 새면 출시 차단이다.
- EN 통화는 `billion/million won`, 라면은 `ramyeon`, 문맥으로 못 푸는 한국어 명사만 첫 등장에 짧게 설명한다.
- 선택적 가상화 원칙: 서울·강남·전세·정선·카카오톡·코스피는 실명, 변동 자산·기업·단지는 투명 아날로그를 쓴다. 기존 asset/event id는 저장 호환 때문에 바꾸지 않는다.

### 아트·오디오·입력

- 반복 주연은 배경 없는 투명 초상, 장소는 주요 인물 없는 배경, 특정 사건은 전용 CG가 기본이다. 배경 구조·차량·의상·계절·연령·시선·손·반사가 산문과 맞아야 한다.
- 아트 방향은 [`docs/GANGNAM_INK_ART_DIRECTION.md`](docs/GANGNAM_INK_ART_DIRECTION.md), 연속성은 [`docs/ASSET_CONTINUITY_CHECKLIST.md`](docs/ASSET_CONTINUITY_CHECKLIST.md), 사건별 정본은 `assets/*VISUAL_BIBLE.md`와 매니페스트가 소유한다.
- 출시 오디오 원음은 실제 현장·사물 녹음 또는 녹음된 실악기 샘플만 쓴다. 코드 파형·오실레이터·생성 노이즈·런타임 합성 폴백은 금지한다.
- 마우스 호버와 키보드·패드 포커스는 같은 대상을 가리킨다. South=확인, East=취소 같은 의미 입력만 로직이 소유하고 실제 글리프는 `ControllerHints`가 결정한다.
- Steam/Steam Deck이 우선 출시 기준이다. 콘솔은 입력·10-foot 가독성·안전영역을 막지 않게 설계하되 승인·SDK·포팅 전에는 출시를 약속하지 않는다.

## 운영과 큐

- Codex는 구현·산문·QA·이미지·번역·반복 작업을 수행하고, Claude는 오더·판정·병합 정합·정본 수호에 집중한다.
- 큰 작업은 `docs/CODEX_QUEUE.md` 운영 프로토콜을 따른다. `[~] 착수 — 만지는 파일: ...` 선언 커밋을 먼저 푸시하고, 완료 시 `[x]`·검증 결과·`WORK_LOG` 기록을 남긴다.
- 정본 규칙 변경, `finish_run` 라우팅, 밸런스 밴드 밖 수치, 큐에 없는 신규 시스템은 사용자 또는 활성 오더의 근거 없이 착수하지 않는다.
- 설계 문서의 "구현 예정"은 담당과 상태를 명시한다. 같은 기능을 Claude와 Codex가 이중 구현하지 않는다.
- Codex는 `main`에서 작업하고, Claude 브랜치 병합 요청이 있을 때 계보와 사용자 변경을 확인한 뒤 합친다.

## 검증

기본 완료 게이트:

```bash
python3 tools/context_manifest_check.py
GODOT=/usr/local/bin/godot ./tools/audit.sh
python3 tools/en_coverage_check.py
git diff --check
```

- 아크 트리거 변경: `python3 tools/arc_flow_sim.py`
- 신규 바이너리 자산: 먼저 `godot --headless --import`
- 화면 작업: `ScreenshotQA.tscn`에서 해당 scope·KO/EN·목표 해상도만 우선 검증
- 오디오는 자동 검사와 별도로 실제 연속 청취가 필요하다.
- 전체 감사는 최종 통합 시 실행하고, 작은 수정 중에는 변경 영역의 표적 QA를 먼저 사용한다.

## 작업 종료

1. `CLAUDE.md`의 현재 상태를 한 줄로 갱신한다.
2. 구현 결과를 `docs/WORK_LOG.md`에 최신순으로 기록한다.
3. 새 설계 결정만 `docs/DECISIONS.md`, 수치 변경만 `docs/BALANCE.md`, 사용자 체험 노트만 `docs/DEMO_FIXLOG.md`에 쓴다.
4. 큐 상태와 활성 사양을 갱신한다.
5. 관련 검사, `git diff --check`, 사용자 변경 제외를 확인한 뒤 의도한 파일만 커밋·푸시한다.

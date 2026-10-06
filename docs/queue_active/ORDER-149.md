# Active Queue Spec: ORDER-149

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-149 [P2·프롤로그 리듬] 세 비트가 같은 속도로 지나가는 문제를 상수 하나를 데이터로 내려 푼다

**[ ] 미착수 · 입력은 `P-18` 1층만:**
`P-18`이 21일 결정 한도를 넘겨 제안 자신의 권고대로 **1층만** 오더로 올리고
2·3·4층은 보류한다. 이 오더는 **새 자산 0, 새 시스템 0, 새 문안 0**이며
상수 하나를 비트 데이터의 필드로 내리는 일이다.

**[~] 착수 — 2026-10-05.** 위는 최초 선언 이력이다. 현재 제품에서도 단일0.52와
hold3.10/3.10/3.00을 확인했다. 462 export 마감 뒤, Mac잠금 때문에457/302 실제
화면 검수가 불가한 동안 이 독립 source 수리를 진행한다. 다른 오더의 인간/HOLD를
닫지 않는다. 현재 작은 검사 뒤 source 수리만 main에 올리고 렌더/체감은 별도로 남긴다.

선택한 배분(초): 도시 fade0.44/hold2.80, 처지0.76/3.50, 목표0.36/2.90.
명목합계는 전후10.76로 동일하고, 처지 비트는3.62→4.26초가 되어50만원/고시원
조건을 오래 읽는다. 목표는3.52→3.26초로 더 빠르게 드러난다. 실측 시간은 별도다.

최초 `build/qa_order149/baseline1`은 제품 수정 전 실패로 보존한다. 첫 KO 비트의
tween 진행과 벽시계가 어긋났고 camera endpoint의 정규화 오차도 있었다. 같은
실행의 뒤 비트/EN은 정상이다. 검사 준비 시간을 t0 밖에 분리하고 실제 Vector2
endpoint를 읽어 다시 측정한다. 후속 PASS는 warmed fixture의 시간 계약이지
콜드 부팅·실제 렌더 품질의 증거가 아니다. 허용오차0.045초는 넓히지 않는다.

## 현재 source 표적 결과 (2026-10-05)

### 실제 렌더 의무 재개 선언 — 2026-10-06

472의 필수 관찰을 마감한 뒤 이 단위의 미관찰 화면을 잇는다. root는 private
.git/order149-render-20261006.elwY5j/render.py·render.gd·render.tscn 및 그 실행 결과/
PNG/관찰 기록만 작성·실행한다. 기존 OpeningRhythmCheck·ScreenshotQA의 장면 생성/
completed-frame readback과 StoryNameplateBootstrap·build_story_demo_successor_macos
보호 도우미를 재사용하며 새 범용 runner·tracked QA·제품 수정0이다. 정상 autoplay의
KO/EN×1280×800/1920×1080×3비트 실제12PNG와 요청/실제 창·이미지 크기·원문/
label경계·3비트→전환1을 결속한다. 창 크기만 바꾸며1280기준 content_scale 설정은
입장값 그대로 유지하고 이미지 사후 리사이즈는 금지한다. root가 PNG와 실제창을 본다.
기존 전후시간/fallback/ReduceMotion/skip 증거는 입력동일 검증 뒤 재사용한다.
비저자 order469_review는 새 docs/agent_reviews/ORDER-149-render.json만 소유한다.
기존149보고·HOLD 원장 행은 불변이다. root 운영 소유는 위 원래 선언과 같다.
이 선언을 먼저 별도 커밋·push한다. L3 첫 관객의 비유도 강조 기억은 미관찰로 보존하며
agent 관찰을 사람/원어민/물리패드·음질·콜드부팅·출시 GO로 바꾸지 않는다.

- 제품 `0afd81c8f702c1b792970f85cd864b6312774fa4`는 이 GD 하나만16추가/9삭제다.
  3개 fade/hold블록·getter·local값·6소비자의11개 치환 외 문안/자산/음향/입력은
  불변이다. `_beat_fade_seconds`는 값 없는 beat에0.52를 돌려준다.
- 동일 checker의 `build/qa_order149/baseline2` / `current1`에서 정상KO
  10.864439→10.840767초(0.997821배), ReduceMotion EN10.863720→10.832778초
  (0.997152배). 전후±15%·각curve±0.045초를 통과했다. 준비 대기는 t0 밖이다.
- 각 실행에서 두 번째 fade 중 release/echo는 전환0, 실제 synthetic key down과
  반복 down/up은 전환1·generation+1·다음beat0이다. physical 입력 증거가 아니다.
  실제저장34·공개저장9·seed3·462앱/manifest·원본project와9입력은 전후 동일하다.
- source 계측은 PASS지만 실제12PNG/가독성/검은프레임/강조체감은 NOT_RUN이다.
  camera `completed_at`은 endpoint 관측시각이며 최초완료시각으로 읽지 않는다.
  463의 정확한 현재 번역manifest 수용도 PASS다. 독립 보고는
  `docs/agent_reviews/ORDER-149.json`에 결속하며 이 오더 전체는 HOLD다.

## 판정 증거

`83d3f350`에서 재실측했고 `P-18`의 수치가 그대로 유효하다.

| 씬 | 줄 | `create_tween` | `AudioManager.*` |
|---|---:|---:|---:|
| MainGame | 22,550 | 44 | 55 |
| StoryMode | 5,761 | 18 | 20 |
| **OpeningCinematic** | **313** | **2** | **0** |

- `scenes/OpeningCinematic.gd:11`의 `const FADE_SECONDS := 0.52` **하나를 세 비트가
  모두 쓴다.**
- 비트별 `hold`는 `3.10`·`3.10`·`3.00`으로 사실상 균일하다.
- 결과적으로 민준의 50만원·고시원 처지와 30억원·5년 목표가 **같은 속도로 지나간다.**
- 프롤로그는 셰이더 등급·켄번즈·리듀스드 모션 대체를 이미 갖췄다. **없는 것은
  기술이 아니라 리듬이다.**

## 깊이 3문

1. **이걸 지우면 무엇이 깨지는가?** 데모를 켠 사람이 처음 14초 안팎에 만나는
   화면이 계속 같은 속도로 흐른다. 위시리스트를 누르는 사람과 끄는 사람이 갈리는
   자리이고, 코어가 아무리 좋아도 거기 닿기 전에 나가면 소용이 없다.
2. **고른 플레이어와 안 고른 플레이어가 뒤에 다른가?** 프롤로그에는 선택이 없다.
   이 오더가 바꾸는 것은 선택이 아니라 **강조**다. 어느 비트를 더 오래 보게 할지가
   작품의 첫 주장이 된다.
3. **같은 자리에서 무엇과 경쟁하는가?** 스플래시 단축(4층)과 125년 계산을 앞으로
   빼는 일(3층)과 경쟁한다. 둘 다 이 오더에 넣지 않는다. 1층의 실물을 본 뒤
   판단하는 것이 `P-18`의 권고다.

## 배치 A — 제품

1. `FADE_SECONDS` 상수를 `BEATS` 각 항목의 필드로 내린다. 기본값은 현재의
   `0.52`로 두어 값을 주지 않은 비트의 동작이 바뀌지 않게 한다.
2. 세 비트에 서로 다른 페이드를 준다. 무엇을 강조할지는 구현이 정하되 **선택한
   배분과 그 이유를 사양에 남긴다.** 처지를 세우는 비트와 목표를 세우는 비트가
   같은 속도면 이 오더는 실패다.
3. `hold`도 같은 원칙으로 손볼 수 있으나 총 재생 시간은 현재 대비 ±15% 안에
   유지한다. 프롤로그를 길게 만드는 오더가 아니다.
4. 리듀스드 모션 경로는 지금처럼 동작해야 하며, 비트별 값이 들어와도 접근성
   대체가 깨지지 않는다.
5. **새 오디오를 넣지 않는다.** `AudioManager` 호출 0회는 `P-18` 2층이며 출시
   원음 조달이 선행한다. 임시 합성음을 넣지 않는다.
6. KO/EN 두 해상도에서 문안 잘림·겹침이 없어야 한다. 문안 자체는 바꾸지 않는다.

## 배치 B — 증거

1. 비트별 페이드 값이 실제로 서로 다르고 데이터에서 읽히는지, 값 미지정 비트가
   `0.52`로 동작하는지 실행으로 확인한다.
2. 총 재생 시간을 수리 전후로 재고 ±15% 안임을 보인다.
3. 리듀스드 모션 켬/끔 두 경로를 실행한다.
4. KO/EN × 1280×800·1920×1080으로 세 비트를 렌더해 잘림·겹침·검은 프레임 0을
   확인한다.
5. `AudioManager` 호출이 여전히 0회임을 확인한다. 이 오더가 2층을 몰래 열지
   않았음을 증명한다.
6. 최신 CLAUDE·사용자의 효율적 검수 지시를 적용하여 전체감사 대신 새 표적
   자연 autoplay 정상/ReduceMotion의 전후4표본·fallback·실제 skip입력·원문
   보존을 검사한다. 재생 간 데이터/경로를 바꾸지 않으므로240주·옛대형suite를
   반복하지 않는다. 전체 source manifest의 정확한 전이 수용은 별도463 한 번으로
   결속하며 이전 full-body PASS를 새 source 수용으로 가져오지 않는다.

## 정확한 파일 소유권

**런타임/root:** `scenes/OpeningCinematic.gd` 하나. baseline 계측이 끝난 뒤만 수정한다.

**표적 검사/receipt_tests392 초안·root 후속 수리:** 새 `tools/OpeningRhythmCheck.gd`,
`tools/OpeningRhythmCheck.tscn`(필요시 생성 `.gd.uid`만).
기존 StoryNameplateBootstrap의 pre-autoload 격리를 재사용하며 새 범용 runner0.
root만 프로젝트/검사/엔진을 실행한다. 기존First30Seconds/Screenshot의
autoplay=false를 실제 시간 검증으로 바꾸어 주장하지 않는다.

**선언·마감/root:** `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양,
`docs/PROPOSALS.md`(P-18 결정 기록), `docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`,
CLAUDE 현재행·`tools/audit_scope.json`·필요한 위임판정원장.
**독립 판정/independent392:** 실제 증거 검수와 `docs/agent_reviews/ORDER-149.json`만.
Mac잠금 중 실제12PNG/가독성/검은전환/강조체감은 NOT_RUN이며 이 오더를 닫지 않는다.
기존 공개본/462 앱·manifest·핀·사용자 저장·번역 사전/키/receipt를 바꾸지 않는다.

`project.godot`, 프롤로그 문안, 셰이더 등급, 켄번즈 파라미터, `AudioManager`,
`SplashScreen`, `ORDER-87`이 만든 첫 5분 흐름은 수정하지 않는다.

## 완료 판정

- **L1 기계:** 비트별 값 반영, 기본값 회귀 0, 총 시간 ±15%, 리듀스드 모션 통과,
  `AudioManager` 0회 유지.
- **L2 자가:** 비트별 페이드·hold 전후 표와 KO/EN 렌더를 남긴다.
- **L3 사람:** 프롤로그를 처음 보는 사람이 세 비트 가운데 어디에 무게가 있었는지
  유도 없이 말할 수 있어야 한다. 이 판정 전에는 2·3·4층을 열지 않는다.

## 정본 승격 예정

- 계속 유효한 규칙: "연출 타이밍 상수는 비트 데이터가 소유한다"를
  `docs/DECISIONS.md`에 승격 판정한다.
- 일회성: 현재 `0.52`·`3.10/3.10/3.00` 수치와 P-18 층 분해.

## 다음 경계

`P-18`의 2층(소리 사건 3~4개), 3층(125년 계산을 앞으로), 4층(스플래시 단축)은
이 오더에 넣지 않는다. 2층은 출시 원음 조달이 선행하고, 3층은 `ORDER-87`의 사람
게이트를 다시 열며, 4층은 1층의 실물을 본 뒤 판단한다.

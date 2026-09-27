# Active Queue Spec: ORDER-350

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-350 [P1·본편] 3장 M25~M36 대본의 경로·회수·영어 정합을 고친다

**2026-09-27 Claude 발행.** 본편 대본 정합 검토 계획
([FULL_GAME_SCRIPT_REVIEW](../queue_backlog/FULL_GAME_SCRIPT_REVIEW.md))의 배치
R3다. story_map M25~M36 root 12장면(병실 뒤 통화, 서른다섯, 재혁 제안·정산·잠수,
지연 출국, 반환점, 상철 추리·대면, 알면서 사는 값, 먼저 거는 전화, 35세 결산)을
KO/EN으로 읽었다. 경로에 따라 사실이 갈리는 곳은 `MainGame.gd` 스케줄 조건과
선택 플래그로 확인했다. 번호는 Codex 동시 발번과 겹치지 않도록 350번대를 쓴다.

## 깊이 3문

1. **왜 지금인가?** 3장은 재혁 투자 여부와 상철 진실이 갈리는 장이다. 뒤 장면이
   앞 선택을 잘못 인용하면 플레이어가 "내 선택이 무시됐다"고 느낀다.
2. **무엇을 바꾸지 않는가?** gameplay key, 선택 수, 효과, 이벤트 ID, 스케줄 조건,
   경제 수치는 바꾸지 않는다. 11번만 실제 소비되는 기존 조건부 본문 구조를 쓴다.
3. **순서는?** 2장 오더(ORDER-313) 뒤. 본편 HOLD와 사람 게이트는 바꾸지 않는다.

## 수리 목록

### 2026-09-27 착수 — 만지는 파일과 검수 경계

- 313·356·357의 독립 작업 GO 뒤 시작한다. 기준 `20dbcfa`의 사용자 변경0.
- 원고 저자: `content/events/arc_midgame.json`, `content/events/arc_drama.json`,
  `content/events/arc_year3_drama.json` 및 `content/events_en/arc_events.json`,
  `content/events_en/arc_midgame.json`, `content/events_en/arc_drama.json`,
  `content/events_en/arc_year3_drama.json`의 1~10번 표적 text leaf만.
- root: `content/events/arc_year_close.json`, `content/events_en/arc_year_close.json`의
  11번 본문/선택/결과와 기존 조건부 본문 구조, `content/meta/full_game_localization.json`의
  해당 leaf 수용 기록만. 명시한 새 조건부 본문 외 gameplay/효과/ID/순서/스케줄 불변.
- 번역 저자: `content/events_ja/`, `content/events_zh-CN/`, `content/events_zh-TW/`의
  `arc_midgame.json`, `arc_drama.json`, `arc_year3_drama.json`, `arc_year_close.json`
  12파일 중 바뀐 한국어 대응 leaf만. 각 지역은 한국어에서 직접 번역하며
  이전 export와 새 source/target hash를 따로 보존하고 check/import로 수용한다.
- 비저자: 실제 분기 소비·원고 전체 차이·증거 읽기 전용 검수. 파일 저작과 분리한다.
- 마감 소유: 이 사양·CODEX_QUEUE·WORK_LOG·생성 STATUS·CLAUDE 현재 한 행,
  새 `docs/agent_reviews/ORDER-350.json`과 agent 판정 추가만. 실행/화면 증거와
  임시 harness는 `.git/full-game-localization/order350-*`에 둔다.
- #11 사양의 `description_variants`는 실제 엔진 소비 필드가 아니다.
  `StoryMode._resolved_story_description`의 `description_if_known`/기본 본문을 사용하며
  기존5변형 우선순위와 ghost/no-ghost·KO/EN 실제 소비를 검증한다. 새 엔진 기능은 만들지 않는다.
- 고정 해시 검사가 수리 원문을 거절하면 실패를 남기고 검증 연결만 별도 후속 범위로
  선언한다. 옛 source pin/역사 판정/공개 데모/인간 원장은 덮지 않는다.
- 위 지시는 일회성이다. 본편·새package HOLD, 원어민/인간/물리 관찰과 자동 검증은 별도다.

| # | 위치 | 결함 | 수리 방향 |
|---:|---|---|---|
| 1 | `content/events_en/arc_events.json` `arc_father_05_after_visit` 선택 2 결과 | KO는 민준이 “아버지도 잘 지내고 계세요. 걱정 마요.”라고 하고 아버지가 “…그래, 나도. 너도.”로 받는다. EN은 “I'm doing fine too. And so are you.” / “…Yeah. Me too.”로 화자와 뜻이 엉켰다. | “You take care too, Dad. Don't worry.” / “…Yeah. You too.” |
| 2 | `content/events/arc_midgame.json` `arc_35_birthday` 본문·선택, 같은 EN | 게임 나이는 새해에 오르고(`GameState.gd` 1447행, “34세의 마지막 밤”), 5장 결말은 연말을 “38세 생일까지 7일”로 쓴다(`arc_drama.json` 10곳 이상). 그런데 이 장면은 M26(2월 무렵)에 생일로 “서른다섯이 됐다”고 한다. 생일이 2월이면 결말의 “38세 생일까지 7일”이 거짓이 된다. | **설날 장면으로 바꾼다.** 설에 한 살 먹는 한국식 나이와 맞고 결말 문장을 건드리지 않는다. 아버지 문자를 설 인사로(예: “설인데 무리해서 내려오지 마라. 떡국은 먹었냐.”), 선택 2의 “생일로 보내기로”를 “명절로 보내기로”로 바꾼다. “서른다섯이 됐다”, “33세에 시작했다. 2년이 지났다”는 유지한다. 이벤트 ID·플래그·스케줄 주석의 “생일” 표기는 저장 호환 때문에 두고 제목·본문만 고친다. |
| 3 | 같은 장면 EN 선택 2 결과 | “chasing 3 billion”에 `won`이 빠졌다(통화 규칙). | “chasing 3 billion won”. |
| 4 | `content/events_en/arc_events.json` `arc_jaehyuk_03_pitch` | 선택 3 문구가 “Refuse.”인데 KO는 “생각 좀 해볼게”(보류)다. 선택 2·3 결과만 작은따옴표 대사다. 본문과 결과가 과거/현재형을 한 장면 안에서 오간다. | 선택 3을 “Say you'll think about it—and start looking into it.”로. 대사 인용부호를 큰따옴표로 통일. 장면 안 시제를 현재형(`DECISIONS` 2026-08-04 P-9 4번)으로 맞춘다. |
| 5 | `content/events_en/arc_midgame.json` `arc_jaehyuk_wait` | 본문이 “is next week” → “had always been” → “Why does he keep checking” → 주어 없는 “Opened KakaoTalk”으로 한 장면 안에서 시제와 문형이 흔들린다. | 현재형으로 통일하고 주어를 되살린다. |
| 6 | `content/events/arc_midgame.json` `arc_midpoint_reckoning` 본문 둘째 문단, 같은 EN | “며칠 전 강남의 불빛 앞에서 … 물었다”는 `arc_why_gangnam_real`(t115~140)을 가리키지만 반환점(t≥121)이 스케줄 우선순위상 먼저 뜰 수 있다. | 날짜를 특정하지 않는 회상으로 바꾼다(예: “언젠가 스스로에게 왜 여기까지 왔는지 물은 적이 있었다.”). |
| 7 | 같은 장면 선택 1 결과, 같은 EN | “지금까지 잃지 않은 게 다행인 거고”. 재혁에게 돈을 넣은 경로는 잠수(t≥116)로 이미 잃은 뒤다. | 모든 경로에서 참인 문장으로(예: “여기까지 버틴 게 다행인 거고”). |
| 8 | `content/events/arc_drama.json` `arc_sangchul_deduction` 본문 첫 두 문단, 같은 EN | (a) “마음 어딘가에 걸어둔 채 **몇 주**가 지났다”. 인맥 자리는 M14, 이 장면은 M32로 1년 반 뒤다. (b) 회상 속 상철이 한PD건설 질문에 “저쪽은 섞이지 마”라고 답한 것으로 나온다. M14 원문에서 상철은 그 질문에 **화제를 돌렸고**, “섞이지 마”는 ‘수익 보장’ 무리를 두고 한 말이다. | (a) “한 해가 훌쩍 넘게 지났다” / “More than a year passed.” (b) “상철은 표정 하나 바꾸지 않고 화제를 돌렸다.” / “Sangchul changed the subject without a flicker.” |
| 9 | `content/events/arc_year3_drama.json` `arc_minjun_first_call` 선택 2 결과, 같은 EN | 현수가 “어? {name}이? 오랜만이다”, “그냥, 공부”로 반말한다. 현수는 M19와 정본에서 “형”과 존댓말을 쓰고, M35에는 합격(공무원)이든 불합격(회계법인)이든 이미 일한다. | “어? 형? 오랜만이에요.” / “그냥, 퇴근했어요.”처럼 존댓말·재직 상태로 맞춘다. 대화 흐름과 약속 결과는 유지. |
| 10 | 같은 장면 본문, 같은 EN | “지난 3년 가까이, 먼저 연락해본 적이 거의 없었다.” M13 선택 3, M15 선택 1, M19, M25 등에서 먼저 연락한 경로가 있다. | “이유 없이 먼저 걸어 본 전화는 거의 없었다”처럼 모든 경로에서 참인 문장으로. |
| 11 | `content/events/arc_year_close.json` `arc_year3_close` | t=144에 **모든 런**에서 뜨는데 본문과 세 선택이 “재혁의 이름이 들어간 신청서(자기 서명)”와 “아버지의 오래된 보증서”를 올해 다시 연 서류로 전제한다. 신청서는 재혁에게 돈을 넣고 잠수 장면(`arc_jaehyuk_ghost_seen`)을 본 런에만 있다. `jaehyuk_refused` 런과 제안 전 런에서는 없는 서류를 꺼낸다. | 기존 `description_variants` 구조로 `arc_jaehyuk_ghost_seen`이 없는 런의 본문 변형을 추가한다(아버지 보증서만 다시 연 해). 선택지 문구가 변형을 지원하지 않으면 “두 서류”를 “올해 다시 연 서류”로 일반화한다. gameplay key와 플래그는 추가하지 않는다. |

## 2026-09-27 표적 수리 결과 — 통합 HOLD

- 제품 전용 `ef896982207de456042e4288cba651553feb38b1`(직접 부모 `d8fbf31`):
  KO/EN9파일41leaf + JA/CN/TW12파일45leaf, 총21JSON86leaf(기존81/새조건5).
  신규 조건은 각 언어 `arc_year3_close.description_if_known.arc_jaehyuk_ghost_seen`
  마지막 키 하나이며 옛 기본 본문을 그대로 보존했다. 기존5변형·순서·효과·ID·일정 불변.
- 1~10의 설 인사·통화 화자·영어 보류/시제·시간 회상·상철의 실제 대답·현수의
  호칭/일요일 휴무를 맞췄다. 11은 ghost 없는 기본 본문에서 없는 신청서/서명을
  빼고 공통 선택/결과를 개수 중립으로 수리했다. EN 기본 본문의 `{name}`4→3만
  부재한 자기 서명 삭제에 따른 의도적 예외이며 나머지 기존 token/newline 불변이다.
- 기존42receipt 갱신/새 ghost3 수용, 공식40299→40302·b139→140.
  이전139batch·meta9·보류72·native OPEN·전체 INCOMPLETE 보존.
  각15leaf fresh check/import PASS. CN 최초 export 뒤 저자의 후속 수정은 실제
  `target changed since export`로 거부됐고 CN v2 export/check/import로 재결속했다.
  옛3batch stale 거부도 유지한다. pre-export는 locale 저작 전이지만 KO1~10 수정 후다.
- 실제 StoryMode/KO·EN/ghost 양경로/선택3의12흐름, 기존5변형 우선순위를 포함한
 32본문 상태·84페이지 비어 있지 않음·선택별 기존 flag를 확인했다.
  `ORDER350_STORY_OK descriptions=32 flows=12 pages=84 languages=ko,en ghost=both prior_flags=5`.
  최종 증거 `.git/full-game-localization/order350-screen-gmnzz9u9/`의 exit0·3로그 오류0,
  실행 전후 소스15 SHA 동일. KO/EN × ghost 선택화면4 PNG를 root/비저자가 모두 읽었다.
- 준비 상태·직접 handler/빠른 진행의 자동 관찰이며 자연 입력·정상 통독이 아니다.
  PNG는 선택 화면만, 본문은 resolver/label 비공백 확인이다. 사용자34파일 불변은
  원시 전후 목록 없는 runner assertion이며 독립 재계산 불가, runner의 실행시 SHA도
  없다. [독립 보고](../agent_reviews/ORDER-350.json)에 한계를 보존했다.
- 초기 helper 오류3·실행파일 없음1·fade 전 캡처1을 보존한다. 제품 엔진 수정0.
  성공 실행의 임시 namespace만 정확히 제거했고 실제 저장을 정리하지 않았다.
- 수용 후6명령 **5 PASS/1 FAIL**: 일반감사 ERROR0/WARNING0·이야기 정합·i18n coverage·
  영어 한글0·localization264 PASS. full-body는 기존313 exact guard의 EN2파일/ledger
  **3실패**만 남고 receipt 오류는0이다. 앞선 수용 전47실패도 보존한다. EN coverage
  별도PASS·영향78선택은 전체78실행이 아니다. 전체 audit.sh/240주 재실행0.
- 주요 증거: `order350-self-check.json`(86leaf/45receipt/3신규/보호13),
  `order350-static-summary.json`(초기3정적), `order350-post-summary.json`(후속6정적,
  SHA `9edf3db751997c6e9be52c47d7f89b40e4e72066cba55c0a4408ef4470aef48b`).
  모두 `.git/full-game-localization/` 아래이며 실행 당시 HEAD는 선언 d8fbf31의 dirty
  제품 바이트다. 제품 commit에서 새로 실행했다고 세지 않는다.
- 직접 후속 4장 결산4변형의 “두 서류”는 [359](ORDER-359.md)에 별도 선언했다.
  원형 pin/모듈을 덮지 않고 [358](ORDER-358.md)에서350/359 현재·역사 검증을 연결한다.
  본 작업은 `[~]`/HOLD이며 다음 두 범위는 아직 미실행이다. 비저자 최종 source
  `ec9ddae56926bb37e98564a312af59947b551e34`/tree `c9049042b981df3914d171d6221355955ea514b1`의
  [독립 보고](../agent_reviews/ORDER-350.json)는 원고/표적 기능 적합·통합 HOLD다.
  SHA `842f2c5e27b6841aee04b9265d9038fa8340ced0fb9d118e4b46f3c9ed2b1743`를 정확복사하고
  옛113판정/91보고는 보존해114판정/92보고로 추가한다. 공개GO1·인간OPEN45·본편/새package HOLD 보존.
- 개발 스킬의 선언·파일 소유 분리·직접 한국어 번역·표적 검증을 적용했다.
  상시 정본 규칙 추가0, 일회성/기존 WORK_UNIT·I18N·P-9 적용이다. 자동 게이트는
  도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

```text
도달 경로      : ORDER350_STORY_OK descriptions=32 flows=12 pages=84 languages=ko,en ghost=both prior_flags=5
생산자 ↔ 독자   : content/events/arc_year_close.json:225 ↔ content/events/arc_year_close.json:279
바꾸는 상태     : 기존 year3_eyes_open/year3_weighted/year3_avoidant 각 false → true (12흐름)
포기 시 잃는 것 : 기존 선택3 중 택1 / 후속 arc_year4_close·father_passed의 year3 변형
서사 위치       : chapter3.M36 / m36_year_three_boss / arc_year3_close
장면 계층       : 기존 결산 사실 수리, 신규 tier·확장 저작 없음
닫는 것         : 없음 — 원고 표적 수리, 통합358 및 후속359 미완료
```

## 판단만 남기는 항목 (이 오더에서 고치지 않는다)

- **M27 `arc_jaehyuk_03_pitch`가 읽는 `memory.m11_first_open_door`는 도달하지 않는
  beat의 기억이다.** R1(ORDER-309) 판단 항목과 같은 뿌리다. M11 EXPAND 결정 때 함께
  정리한다.
- **M35 먼저 거는 전화는 beat 의도(직전 진실 선택을 실제 사람에게 들려준다)를 아직
  반영하지 않는다.** 현재 원문은 아버지·현수에게 이유 없는 안부다. `work: EXPAND`
  저작 때 다룬다.
- **M25·M26·M31은 초기 원고의 짧은 교훈형 결말이 남아 있다**(“자각은 보통
  그렇게 시작된다”, “버티는 사람이 남는 게임이기도 하다”). `DECISIONS` 2026-08-04
  P-9 1번 위반이지만 세 beat 모두 EXPAND이므로 확장 저작 때 다시 쓴다.

## 결함 아님으로 확인한 것

- 재혁 정산 대기·잠수 장면은 투자 플래그(`jaehyuk_trusted_fully`/`jaehyuk_partial`,
  `cast_has_flag(jaehyuk, invested)`)로만 열려 거절 경로에 “넣은 돈”이 나오지 않는다.
- 병실 뒤 통화(`arc_father_05_after_visit`)는 `visited_father`로만 열려 병실 문을
  열지 않은 경로에 “창원에서 돌아온 뒤로 통화가 달라졌다”가 나오지 않는다.
- 상철의 “자네”와 반말: `STORY_BIBLE.md` 임상철 “말투 정본”(2026-09-27)에 맞다.
- 재혁 성 “최”, 지연 “아버지 회사”: 정본과 맞다.

## 완료 조건

- 1~11번이 KO/EN(해당 시 JA/zh-CN/zh-TW 오버레이 포함)에 반영된다.
- `python3 tools/en_coverage_check.py`와 `python3 tools/audit_select.py -- <변경 파일>`
  PASS. 11번은 추가 변형이 실제 StoryMode에서 뜨는지 KO/EN 두 경로(`ghost_seen` 유무)로
  확인한다. 해시 고정 검사가 걸리면 기존 소유 오더의 갱신 규칙을 따른다.
- `WORK_LOG`와 이 사양 머리말·큐 행 상태를 함께 갱신한다.
- 원어민·외부 플레이테스트 게이트는 OPEN으로 남는다.

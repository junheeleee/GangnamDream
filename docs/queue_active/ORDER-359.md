# Active Queue Spec: ORDER-359

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-359 [P1·본편] 4장 결산이 없는 두 번째 서류를 회상하지 않게 한다

2026-09-27 Codex 발행. 350 비저자 검토 중 발견한 직접 후속 소비자다.
350에서 재혁 신청서가 없는 경로를 보증서만 있는 결산으로 수리했으므로,
다음 해 회상이 다시 “두 서류”를 전제하면 같은 플레이어 선택을 무시한다.

## 깊이 3문

1. 지우면 무엇이 깨지는가: 두 번째 서류를 얻지 않은 플레이어가 다음 해에 이를 회상한다.
2. 고른 상태는 어떻게 남는가: `year3_weighted`의 봉투와 `year3_eyes_open`의 열린 폴더는
   다음 해에도 구별한다. 개수만 중립화하며 플래그·선택·효과는 바꾸지 않는다.
3. 무엇과 경쟁하는가: 350의 직접 회수를 351 새 대본 수리와 검증 연결358 전에 닫는다.

## 선언 후 소유 가능한 범위

- KO/EN/JA/zh-CN/zh-TW `arc_year_close.json` 5파일.
- 정확한 root는 `arc_year4_close`, `arc_year4_close_father_passed` 둘뿐이다.
  각 `description_if_known.year3_weighted`·`.year3_eyes_open` 기존4leaf × 5언어만.
- “두 서류”/“two documents”와 대응 표현을 “작년 다시 열었던 서류”처럼 개수 중립으로
  고친다. 봉투/열린 폴더, 진료 안내, 마지막 연락, 아버지 생사, 개행·토큰을 보존한다.
  사전 key/order·gameplay·효과·일정·ID·다른 변형·30억 등 수치는 비소유다.
- root가 source-bound export 전후·check/import와 `content/meta/full_game_localization.json`
  기존 해당12receipt 재결속만 소유한다. 새 번역 수를 늘렸다고 세지 않는다.
- 마감: 이 사양, 두 큐, WORK_LOG, 생성 STATUS, CLAUDE 현재 행, 새 agent 판정과
  `docs/agent_reviews/ORDER-359.json`. private 증거 `order359-*`.
- 착수 시 파일 소유를 나누고 선언 커밋을 먼저 만든다. 350의 이미 수정한 leaf는
  다시 쓰지 않으며 350에서 남겨 둔 “100주”/일반적 진실 회상·문체 채무로 확장하지 않는다.

## 읽기 전용 사전 확인 (2026-09-27, 구현 아님)

- 20leaf 모두 `{name}`2개/개행4개이며350의86leaf와 교집합0이다. JA/ZH는 생사 root
  사이에 기존 문장 차이가 있으므로 서로 복사하지 않는다. EN은 `two documents`만
  지우지 말고 복수대명사/`kept together`도 확인한다. CN 생존형 `它们旁边`도 대상이다.
- 실제 resolver는 known key의 첫 true를 고른다. 16상태 준비 시 앞선
  `arc_y4_year_close_protected_relationship`, `arc_y4_year_close_protected_body`,
  `arc_y4_year_close_protected_family`, `arc_y4_midpoint_receipt_seen`을 비우고
  `year3_weighted`/`year3_eyes_open` 중 하나만 켠다. ghost는 이 두 root의
  known key가 아니므로 결과 본문이 변하지 않아야 한다.
- 생사는 `father_passed` 또는 `arc_father_passing_seen` 또는 cast father `stage=passed`다.
  생존 준비는 세 신호 모두 부재, 사망 준비는 terminal 뒤의 실제 상태를 맞춘다.
  MainGame의 turn192 진입과 EventManager의 생사 치환을 훼손하지 않는다. 코드 기준
  StoryMode:4354, DataRegistry:1107, EventManager:807/819, MainGame:7187을 시작점으로 삼는다.
- 위 확인은 비저자 읽기뿐이며 작성/엔진/검사 재실행0이다. 착수 선언과 검증을 대신하지 않는다.

## 완료 조건

- 4개 source leaf와 16개 대응 leaf의 exact 원시 차이, 개수 중립, 봉투/폴더 차이,
  기존 token/newline/gameplay·인간/공개 원장 불변을 확인한다.
- 실제 StoryMode에서 KO/EN × 두 root × 두 year3 플래그 × ghost 유무의 본문 선택을
  pre-autoload 격리로 확인한다. 준비 상태의 자동 관찰임을 밝힌다.
- 원문에서 직접 번역하고 새 source/target hash 수용을 검증한다. 원어민 OPEN 유지.
- 비저자 품질 판정과 358의 현재/역사 연결 완료 전에는 전체 완료로 올리지 않는다.
  본편·새package HOLD, 외부 출시·스토어·지출은 비권한이다.
- 일회성 지시이며 기존 WORK_UNIT·I18N·스토리 정본 적용, 새 상시 규칙0이다.

# Active Queue Spec: ORDER-359

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-359 [P1·본편] 4장 결산이 없는 두 번째 서류를 회상하지 않게 한다

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

### 2026-09-27 착수 — 만지는 파일

- 기준 main `9586560`, 사용자 변경0. 원격 P-20 제안과 이전114판정/92보고를 보존한다.
- root: `content/events/arc_year_close.json`·`content/events_en/arc_year_close.json`의
  위4조건부 본문씩8leaf, `content/meta/full_game_localization.json`의 해당 기존12receipt만.
- 번역 저자 `/root/screen_path_probe`: JA/zh-CN/zh-TW의 `arc_year_close.json`3파일,
  위4leaf씩12개만 한국어에서 직접 수리한다. 사전 export 뒤 root가 시작 신호를 준다.
- `/root/compat357`: private `order359-*` 정적/불변 검증. `/root/r3_route_probe`는
  제품 비저자 읽기 전용 검수와 private 최종 보고만. root는 격리 StoryMode16상태 검증을
  기존 bootstrap/helper 선례에 맞춰 준비하고 실행시 runner·사용자 전후 목록도 결속한다.
- 마감 root: 위 선언 범위의 사양/큐/WORK_LOG/생성STATUS/CLAUDE 한 행 및
  `docs/agent_reviews/ORDER-359.json`·새 agent 판정. tools/engine·기존350leaf·인간/공개
  원장·사용자 저장·P-20은 수정하지 않는다. 358 source 연결은 별도 미착수다.
- 일회성 작업 지시이며 원어민·인간·물리 관찰로 자동 결과를 승격하지 않는다.

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

## 2026-09-27 수리·표적 검증 (통합 HOLD)

- 제품 `acab8ea29d2ec392d1224513e005e8b8000a4535`, 직접 부모 선언
  `e3a6e09d5a6e3398a4db764177352dc7755d0892`. 5JSON 기존20leaf와 ledger뿐이다.
  원시 역재구성으로 대상 외 형식/키/순서/게임플레이·350의86leaf 불변을 확인했다.
- KO4·EN4·한국어 직접 JA/CN/TW 각4. 봉투와 열린 폴더, 생사별 기존 문장,
  진료 안내/마지막 연락, 각 `{name}`2·개행4 유지. EN의 together/them과 CN의
  생존형 它们旁边도 중립화했다. 다른 문체/시제·100주 채무로 넓히지 않았다.
- 사전3export는 원문/번역 수정 전에 확보했다. 사후3 source/response check/import
  `changed_files=0` PASS, 옛3batch `stale source manifest` 거절. 기존12receipt만 재결속,
  새0·40302 유지·b140→141·meta9/보류72/옛140batch와 나머지 ledger 원형 유지.
  첫 negative fixture의 manifest 혼용 오류와 CN/TW CLI locale 생략 실패는 private
  `order359-exchange-preflight-failure.txt`, `order359-cli-locale-failure.txt`에 보존했다.
  이번 교환 명령에는 각 batch의 `--locale`을 명시한다(일회성 실행 메모).
- 실제 격리 StoryMode1회: `order359-screen-l84hv0pu`, exact success marker·exit0·
  stdout/stderr/Godot log 오류0. KO/EN×생사×year3두선택×ghost =16상태에서
  base queue→실제 생사 치환·본문·48표시페이지 일치, ghost쌍8 불변. root/비저자
  모두 생존/ghost없음의 KO/EN×두선택 첫화면4PNG를 직접 읽었고 잘림/겹침0이다.
  result SHA `89b943c8adfdde81de4e7219528815dd26628995878d3aa3e34dcce119676d8e`.
- 실행 runner 자체 포함16경로 전후 SHA와 실제 사용자34파일 전후 map을 저장해
  불변을 대조했다. 정확한 성공 QA namespace만 정리했고 사용자 파일 삭제0이다.
  전체 소스 census·자연192주 도달·물리 입력·정상 속도·선택 결과·JA/ZH 화면을
  관찰했다고 세지 않는다. 48label은 실제 text 일치이며 독립 조판 알고리즘 검증은 아니다.
- 정적7명령 **6 PASS/1 FAIL**(full-body의 기존 EN2/ledger guard3), timeout0.
  localization264 포함. 영향선택71개는 실행한 수가 아니다. 제품6핀 매 명령 전후
  동일. summary SHA `5803bc6018a1337123e5215b4edaff340f38b940407b415c0aecbd7e263181af`,
  invariants SHA `fd8c6c62cf0bd4d145827fba1d8f372aed2c760ded310d448086b27bd78c4fa9`.
  dirty 선언HEAD의 바이트에서 수행했고 후속 clean commit 재실행을 주장하지 않는다.
- 독립 비저자 `/root/r3_route_probe`가20원고·12receipt·16상태48label·4PNG를
  전수 대조했다. 최종 source 판정은 별도 보고에 결속한다. 358 연결 전 `[~]`/HOLD,
  인간OPEN45·옛공개GO1·기존114판정/92보고·프로젝트·P-20 보존. 새판정만 추가한다.
- 규범은 일회성/기존 WORK_UNIT·I18N 적용, 새 상시 규칙0. 원어민/인간/물리
  관찰과 본편/새package GO·외부출시 권한은 발급하지 않는다. 다음은358이다.

## 완료 조건

- 4개 source leaf와 16개 대응 leaf의 exact 원시 차이, 개수 중립, 봉투/폴더 차이,
  기존 token/newline/gameplay·인간/공개 원장 불변을 확인한다.
- 실제 StoryMode에서 KO/EN × 두 root × 두 year3 플래그 × ghost 유무의 본문 선택을
  pre-autoload 격리로 확인한다. 준비 상태의 자동 관찰임을 밝힌다.
- 원문에서 직접 번역하고 새 source/target hash 수용을 검증한다. 원어민 OPEN 유지.
- 비저자 품질 판정과 358의 현재/역사 연결 완료 전에는 전체 완료로 올리지 않는다.
  본편·새package HOLD, 외부 출시·스토어·지출은 비권한이다.
- 일회성 지시이며 기존 WORK_UNIT·I18N·스토리 정본 적용, 새 상시 규칙0이다.

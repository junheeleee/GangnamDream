# Archived Queue Spec: ORDER-307

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-307 [QA] 데모 승인 수리와 M01~M06 그래프 역사 핀 대조

2026-09-27 착수. 원고305 제품 `031f5e5`. 현 `story_graph_contract_audit.py`는
M01~M06의 KO semantic event slice를 과거 hash와 직접 비교하므로 승인6leaf도 거부한다.
306의 별도 조사 후 발견한 reader이므로 새 사양으로 분리한다.

- 깊이: 보호를 지우면 임의 사실/효과 변경이 숨는다. 기존 graph 계약/옛hash는 그대로
  두고305의 exact 후계만 역투영한다. 새 플레이어 선택/상태/기회비용은0이다.
- 저자 `/root/release_status_crosscheck`: `tools/story_graph_contract_audit.py`만.
  306의 공통 `order305_demo_source_compat` API를 사용한다. 실제raw5파일 검사와
  in-memory semantic slice 검사를 구분하고, mutating fixture가 우회하지 않게 한다.
  graph·fixture·과거공개핀·payload 원형 변경0, 새 경계 selftest 추가.
- root: 큐2파일·이 사양·WORK_LOG·생성STATUS·CLAUDE현재행·새 scoped 판정원장,
  private `order307-*` 증거와 capture의307 label. 독립 검수자는 제품/검사저작0인
  `/root/blackjack_accounting_review`, private `order307-review*.json` 및
  `docs/agent_reviews/ORDER-307.json`만 소유한다.
- 검증: graph normal/self 및 exact현재 positive·원고/효과/타파일/fixture변조 negative,
  helper306과같은5파일신원. 전체/legacy/240주엔진실행0,305격리engine증거만공유.
- 기존 공개package·인간OPEN45/DONE1은 불변. work_unit 한정이며 출시/본편GO가 아니다.
  규범은 일회성/기존 WORK_UNIT 적용. 비저자 검수 후 종료한다.

## 선택기 실행 실수 기록

root가 영향 목록에 `--list`를 빠뜨려85개 중 초기 정적검사가 실행됐다. INT중단exit130,
Godot미발견으로 엔진실행0, 현재제품/검사 작성 중이라 공식PASS증거로 재사용하지 않는다.
full-body/graph/volume의 후계거부와 release inventory의 옛원형 대비 drift를 관찰했다.
후계3종은305/306/307 표적검사로 다시 판정한다. 옛공개inventory는 새package가 아니므로
덮어쓰지 않으며 그 실패를 출시준비PASS로 바꾸지 않는다. 실행 로그는 대화tool원문이다.
다음부터 영향만 조사할 때는 `audit_select.py --list -- ...`를 쓴다.

## 2026-09-27 완료 증거

- 최종 source `59d4f790ecfd84f023c5796039264e4bfe72cdcf`; [비저자 보고](../agent_reviews/ORDER-307.json) 작업 한정 GO.
- 생산자↔독자: exact5file raw/변경 KO3·EN1 event slice ↔ `story_graph_contract_audit.py` 역사semantic 비교. 원문·fixture·과거핀 보존; 선택/경제·포기비용·장면 계층 변화0/해당 없음.
- `story graph contract audit: PASS overlaps=8 forbidden_raw=6 required_closures=13 self_tests=66` 및 정상 preflight PASS, 이전47case와 신규19경계. 새raw guard가 기존 mutating fixture의 본래 검사를 가리지 않음을 확인했다.
- 공식 `307-graph-self-first`는 `354c270`, 최종 bridge에서 검사기/제품핀 동일을 확인. 추가 엔진0,305 엔진 증거는 기능한정이며 화면·인간 관찰이 아니다.
- 닫는 것: 승인23leaf의 exact graph 후계만.302/본편·새package HOLD. 규범은 일회성/기존 정본 적용; 목록 전용 선택기 사용 안내만 큐 공통검증에 반영했다.

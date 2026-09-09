# ORDER-216 — 위임된 최종 판단과 실제 인간 증거 분리

사용자 최신 개발·최종 검수 위임을 운영 규칙과 기계 원장에 반영했다.
선언23724b75b531363aa0b6b3b5b7ee3908a0e13ae4, 구현 검토 기준
6c8cc6cee0679095c8631cfa4e4418dcb493c4cf. 현재 제품 GO를 발급한 작업이 아니다.

## 구현·독립 검토

지속 판정 규칙의 단일 소유자는 [WORK_UNIT](../WORK_UNIT.md)다.
CLAUDE·큐·PROPOSALS·개발 skill·출시 감사는 이를 참조한다. 사용자에게 다시
판정을 넘기는 관성적 대기를 없애고 독립 검수와 근거를 에이전트가 책임진다.
외부 출시·스토어·지출·법률 인증은 위임 범위에 넣지 않았다.

새 agent_review_decisions.json은 인간 원장과 별개다. 권한·정확한 Git/package
신원·범위·작업 ID·최신 판정·실제 증거 경로와 해시를 검증한다. source와 package,
서로 다른 작업의 GO를 빌리지 못한다. 현재 decisions=[]이므로 HOLD가 정상이다.
CLI/Markdown/HTML은 같은 helper로 에이전트 판정·인간 증거·미관찰 한계를 나눈다.

Poincare의 구현 후 ROOT가 diff·호출부·유한 검사를 독립 검토했다. 최초 버전에서
판정 문서를 다음 커밋에 쓰면 자기 신원이 달라지는 결함과 다른 작업 GO를 차용할
수 있는 결함을 찾아 수정했다. caller가 실제 Git 제품 이력에서 신원을 관측하며,
그 뒤 차이가 고정된 운영·검수 문서뿐인지 확인한다. docs 전체를 허용하지 않는다.
work_unit은 요청한 unit_id와 정확히 같아야 한다. NUL·private 경로도 거부한다.

첫 수정 후134개 유한 self를 ROOT도 직접 실행했다. 실제 임시 Git의
제품→검수 wrapper 흐름과 제품 혼합 반례를 포함한다. 기존 queue25/fence4 통과,
기존 인간 처리6함수 AST와 queue self 원형 보존. 생성 표시와 명시 차선의
통합 마감은 별도이며, 이 유한 검사를 게임 품질 GO로 세지 않는다.

## 생성 STATUS 자기참조 후속 수리

ROOT가 판정 원장에 실제 작업 GO를 쓸 준비 중 생성 STATUS의 dirty→clean에 따라
표시 근거가 바뀌는 두 번째 자기참조를 발견했다. 실제 임시 Git에서 작업 GO3/
제품 GO1 두 흐름 모두 생성→check 실패를 먼저 봉인했다. 고정48개 assertion은
처음39통과9실패, 수리 뒤48통과다. 기존134에 포함해 최종 자체182이며 중복 합산하지 않는다.
정확한 생성물 docs/STATUS.md 단독 dirty만 예외로 두고 다른 미커밋 파일은
metadata라도 HOLD다. index·unstaged·untracked를 NUL 경로로 각각 읽으며,
혼합·rename·개행/탭 유사 경로의 거부를 보존한다. ROOT가 변경부와 반례를 재검토했다.
최종 human_gates.py SHA7c2847d452e9ea296f2c662bf1dc716586ba215cf958b4a98f779cdf00574614.
자체182 최종 보고는 같은 private WT 경로의
order216-status-self-reference-final.json 3595B /
234572790fe2f84b72a210808d595b2c7cdf4ce24e4860fe995580994b8912cb이다.

## 보존과 증거

human_gates.json 전체103390B /
6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6 불변.
46gate(open45/done1), 과거 delegated review22, candidate5, 공개 사용자 GO1과
원어민 OPEN3을 그대로 둔다. 과거 GO/REJECT를 최신 제품에 승계하지 않는다.
번역·입력의 병렬 작업은 각 별도 소유·검증이며 이 운영 판정에 합산하지 않는다.

구현 동결은 `.git/worktrees/checkout2/full-game-localization/`의
order216-agent-review-implementation-final.json 5053B /
e1a22f01f5941162070868e2c09c14da504173b757e1e7e4ed647eb80eb6f294.
원장·검증·self·dashboard·정본 6파일 해시와 실제 출력이 들어 있다.
개발 skill은 본문 참조만 바꾸고 frontmatter/정본 링크를 확인했다.
skill-creator 기본 검증기는 환경의 PyYAML 부재로 실행하지 못했으며 PASS로 세지 않는다.
WORK_LOG의 완료210절1371B와 별도214의209절1300B만 보관본 앞으로 옮겼다.
역제거 시 옛 history64946B 및 끝 LF2까지 byte-exact다.

승격: WORK_UNIT의 위임된 최종 판정·표본·연속 실행 절.
이 오더의 파일 소유·회귀 수량·실행 절차는 일회성이다.
현제품 HOLD·실제 인간/원어민/물리 조작감 미관찰은 그대로다.

# Active Queue Spec: ORDER-300

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-300 [표시·입력] 다이사이 신규 중국어 안내 19키의 실제 소비자를 검수한다

**[~] 2026-09-27 Codex 착수 — 아래 파일만 소유한다.** 부모 ORDER-157.
수용된 ORDER-299 source `96125930d9097a967c6c6bf3fa83d1f6c192b51a`,
현재 clean main `3d0ac8674b88d484e8e367bfd203a91f2dc972f4`의 동일 제품을 검수한다.
범위 설계 `.git/full-game-localization/order299-next-render-scope.json`
SHA `bce6e04626ba26c8fcf396bce602cc357783ad7acecceccf4c33b635870c70ab`를 따른다.
전체 실제 화면 번역/정상 게임 플레이나 금전 검수로 확대하지 않는다.

## 깊이 3문

1. 제거 손실: 새 19키의 치환 인수·문장 전체·실제 글꼴/줄바꿈/첫 화면 적합을 보증할 관측이 없다.
2. 장기 상태: 가역 선택만 바뀌고 cash/AP/전역/저장/RNG는 관측 구간 전체 불변이어야 한다.
3. 경쟁: 같은 첫 화면에서 모든 베팅 버튼·안내·하단 행동을 숨김/축소 없이 함께 읽어야 한다.

## 한 배치 19단위

단위는 아래 19개 원문 키 각각의 두 지역 실제 소비자다. 전체 19개를 독립 전수 판정한다.
`%s 베팅 모드`; `%s 선택. %s를 한 번 더 누르면 굴립니다.`;
`기본 베팅으로 되돌렸습니다.`; `숫자/페어`; `합계`; `간편`;
`홀수\n1:1`; `짝수\n1:1`; `%d 싱글\n1~3:1`; `%d%d 페어\n8:1`;
`합계 %d\n%d:1`; `베팅 단위`; `기본 베팅`;
`선택: %s   |   베팅액: %s   |   결과: %s`;
`[b]%s[/b] · %s  [%s/%s] 모드  [%s] 선택/굴림  [%s/%s] 칩 −/+  [%s] 칩 +  [%s] 규칙  [%s] 뒤로`;
`%d-%d-%d / 합계 %d`; `%d 싱글`; `%d 페어`; `합계 %d`.

## 실제 관측 계약

- CN/TW 각 같은 실제 DaiSaiTable 수명 하나, 1280×800 실제5PNG씩 총10PNG.
- 상태 FACE모드→single1선택→pair1선택→total10/100000선택→기본복원.
- 키 E,Enter,Down,Enter,PageDown,E,Enter,Esc 각 press/release, 지역당16행 총32raw.
  실제 Input.parse_input_event만 사용; 직접 handler/pressed 발화·강제 focus 금지.
- 준비 단계에만 money10000000·dice/pending[1,2,3]·IDLE·기본베팅50000 설정,
  _ready의 RNG 초기화는 별도다. 보호 baseline 뒤 필드 복원으로 변화를 감추지 않는다.
- 28번역 bet버튼(홀짝2+single6+pair6+total14), 모든 visible Label/RichTextLabel/Button,
  canvas 선택명과 전체 부모문장/10힌트 인수/피드백/선택info를 독립 고정 oracle와 비교.
  total4..17은7열2행 모두 보이며 scroll 없음. 무관한 영어 chrome도 잘림은 검사한다.
- 실제 TextLine/TextParagraph·유효 style margin·icon·글리프·폰트·전역 변환·ancestor clip,
  visible census와 원본10PNG를 root 및 비저자가 전수 검수한다.
- 각 raw/capture/teardown에 전체 typed GameState/MetaProgression/settings/namespace files,
  table 모든 gameplay/cursor 필드·RNG·cash/AP·라운드0·history[]·closed0를 비교한다.
  press의 명시적 가역 변화만 허용하고 모든 release는 no-op이다.
- 새로운 pre-autoload UUID 격리·양쪽 user-dir marker·exact 성공 marker·exit0 및
  stdout/stderr/engine log 오류0 필수. 실제 사용자 두 저장루트는 새 전후 전수 census한다.
- root만 그래픽 엔진 순차 실행. 시도별 exclusive 경로와 최초 실패 원본을 보존한다.
  기존297/298 측정 도구는 복사 기반 재사용만; 원본 수정/새 증거로 재사용 금지.

## 파일 소유권

- root: 이 사양→`docs/queue_archive/ORDER-300.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md` 순번만, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `CLAUDE.md` 현재 상태 한 행, `docs/agent_review_decisions.json` 새300행,
  독립보고 복사 `docs/agent_reviews/ORDER-300.json`.
- root: 새 private `.git/full-game-localization/order300-render.py` 및
  `order300-render-*` 실제 산출물/`order300-root-*`·`order300-check*` 기록.
- observer 저자 `/root/blackjack_accounting_tests`: 새 private `order300-selection-observer.gd/.tscn`만.
- 독립 기대값 저자 `/root/release_status_crosscheck`: 새 private `order300-oracle.json`,
  `order300-validate.py`, `order300-oracle-*` provenance/validator 자체 음성검사 기록만.
- 비저자 `/root/blackjack_accounting_review`: 새 private `order300-*review*.json`만.
  observer/oracle/runner 비저자로 preflight 및 최종 source-bound 품질 판정.
- 실제 제품 code/locale/receipt/assets/project/human/공개/서사/금전 모두 비소유.
  실제 제품 결함이면 정확한 별도 수리 오더를 먼저 선언한다.

## 검증·완료·한계

신규 helper 사전 독립 검수 뒤 위10PNG/32raw 실제 실행. 완전 문자열·typed continuity·
geometry strict validator 및 in-memory 변조 음성검사, root/비저자 PNG 전수 판정.
검수source 및 이후 CLAUDE 한 행만 달라지면 전체 runtime pins 불변으로 명시 결속하고
다시 실행했다고 쓰지 않는다. 관련 context/queue/ledger/dashboard/diff만 마감하며
이전 금융26PNG·188raw·297홀짝/Roulette·299번역 named12·전체감사는 반복하지 않는다.

정상 진입·실제 second-confirm roll·정산·금전로그 생성·history label 저장·정상exit·
모든 total 커서전이·마우스/패드·다른 해상도·오디오·패키지·원어민·인간·물리패드는
미관측. 공개GO1·인간OPEN45·본편HOLD 유지. 영어 chrome과 남은 번역 부재는 그대로다.
검사 통과를 재미/서사 깊이/인간판정으로 쓰지 않는다.

**규범 판정:** 19키·경로·증거 구성은 일회성. 기존 UI/I18N/WORK_UNIT 규칙 적용, 새 승격 없음.

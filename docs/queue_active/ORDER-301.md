# Active Queue Spec: ORDER-301

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-301 [P0·현지화] 다이사이 현금·결과·허브 안내를 간체·번체로 직접 번역한다

**[~] 2026-09-27 Codex 착수 — 아래 파일만 소유한다.** 부모 ORDER-157.
시작 clean `fa03c7278b7ad2625d67beeb7c68a5510a18ddca`; 300에서 관측한 남은 영어
안내를 줄인다. private `order300-root-next-scope.json`의11키/15literal 후보를
현재 원문/전체 reader에서 재확인하고, 한국어에서 지역별 독립 직접 저작한다.

## 깊이 3문

1. 제거 손실: 선택 이름은 번역되어도 지갑·승패·허브 및 실제 결과 안내가 영어로 남는다.
2. 장기 상태: 사전과 수용 기록만 바뀐다. 금전·확률·배당·AP·저장·입력·역사 로그 불변이다.
3. 경쟁: 승리 순이익과 원금포함 반환, 현재 지갑과 누적 손익, 결과와 다음 선택을 구별한다.

## 정확한 한 배치 — 11한국어키 × 2지역 = 22값

| 원문 | literal reader |
|---|---|
| `다음 베팅을 선택하세요.` | DaiSaiTable:249 |
| `주사위가 굴러갑니다...` | DaiSaiTable:393 |
| `당첨! %s  +%s` | DaiSaiTable:416 |
| `패배  %s` | DaiSaiTable:422 |
| `다이사이 %s %s (%s)` | DaiSaiTable:436 |
| `다이사이` | DaiSaiTable:528, JeongseonCasino:349·861, MainGame:11755 |
| `BIG, SMALL 또는 원하는 조합에 베팅하세요.` | DaiSaiTable:586 |
| `카지노 허브로` | DaiSaiTable:697, JeongseonCasino:883 |
| `[b]현금[/b] %s   \|   [b]라운드[/b] %d   승%d 패%d   \|   [color=%s][b]손익[/b] %s%s[/color]` | DaiSaiTable:782 |
| `현재 현금 %s` | DaiSaiTable:792 |
| `최근 결과 없음` | DaiSaiTable:929 |

모든 reader는 `scenes/`에 있다. 각22값을 전수 독립 판정한다. 11키에 묶인 공유
제목/허브와 완전 부모문장을 따로 추적한다. 제목은 카드·선택피드백·용어집·세션 정산
및 새 로그 부모에 도달하나 과거 저장 로그를 재번역하지 않는다. 허브 두 EN폴백은
같은 복귀 의미인지 대조한다. 기존 UI사전과 용어를 읽고 지역 일관성을 맞춘다.

승리 두 인수는 dice summary, 원금 제외 순이익이며 패배는 dice summary 하나다.
money로그는 bet label, 이미 부호가 붙은 net, dice summary다. HUD7인수는
cash/rounds/wins/losses/color/sign/abs(net)다. `%s/%d`, 개행·BBCode·공백구분·부호를
보존한다. BIG/SMALL은 현 버튼명이다. 다음 선택 안내를 자동 재베팅으로 만들지 않는다.
반올림 통화 표시를 정확 원화 회계로 주장하지 않는다. 새 재무 테스트 범위는 아니다.

## 파일 소유권·분업

- root 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 위11키씩만 추가,
  `content/meta/full_game_localization.json` 새22수용핀/1batch append-only.
- CN 저자 `/root/blackjack_accounting_tests`: 새 private `order301-zh-CN-draft.json`만.
- TW 저자 `/root/release_status_crosscheck`: 새 private `order301-zh-TW-draft.json`만.
- 비저자 `/root/blackjack_accounting_review`: 새 private `order301-*review*.json`만;
  원문/15reader/전체22값·적용 사전·영수증·보존·source에 결속한 최종 한정 판정.
- root 기록: 이 사양→`docs/queue_archive/ORDER-301.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md` 순번만, `CLAUDE.md` 현재 상태 한 행,
  `docs/WORK_LOG.md`, 생성 `docs/STATUS.md`, `docs/agent_review_decisions.json` 새301행,
  `docs/agent_reviews/ORDER-301.json` 독립보고 정확 복사.
- root 보조: 새 git-private `.git/full-game-localization/order301-*` 교환·검사·기록.
  기존 도구는 읽고 재사용하며 이전 초안/실패/증거를 수정하거나 새 증거로 쓰지 않는다.

## 검증과 수용

원문 고정 export→각지역 구조/문자/숫자/토큰 check→전수 의미판정→사전 추가→
변경된 target hash로 재export/check/import한다. 편집은 apply_patch로 수행한다.
공식40277/b135/meta9→40299/b136/meta9, 각사전1054→1065가 예상값이며 실제 계측한다.
JA3028대비각1963부재는 참고수일 뿐 전체 live UI 분모가 아니다.
기존40277핀/135batch/1054값의 역치환 바이트·source/targetSHA·공개보호키·JA·원문·
runtime·project·인간 원형을 검증한다. 기존 `news-panel-locale-only --list` 고정12
Python검사 차선을 새 변경에 사용한다(그 이름의 이전 파일소유/판정은 상속하지 않음).
관련 context/queue/queue-self/human/agent-ledger-self/dashboard/diff로 마감한다.

새 실제 렌더/입력/엔진 실행0. 300의10PNG/32raw 및 금융26PNG/188raw를 새 번역
증거로 쓰거나 이유 없이 반복하지 않는다. 실제 소비자 표시는 다음 별도 선언이다.
KO/EN/JA·원문·게임코드/규칙·공개판·SHIPPING_LANGUAGES·원본저장·인간판정 비소유.
직접영어 ROLL/ROLLING/SELECTED BET/PAYS/SHAKER/BIG/SMALL/ANY TRIPLE은 별도 추출 채무다.
보류72·공개GO1·인간OPEN45·본편HOLD 유지, native/rendered receipt OPEN 유지.
자동 PASS는 계약 증거이지 재미/문체/깊이·원어민/인간/물리패드·출시 GO가 아니다.

**규범 판정:** 위22값/파일/단계는 일회성; 기존 I18N/WORK_UNIT 적용, 새 승격 없음.

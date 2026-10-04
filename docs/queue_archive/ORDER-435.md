# ORDER-435 — 홀덤 준비와 첫 선택을 중국어로 읽는다

#### [x] ORDER-435 [P1·현지화] SETUP·첫 PREFLOP 22키의 간체·번체 44값

**[x] 완료 — 2026-10-04.** 434·436에서 원 단위 금액과 표시 폭 수리를 마쳤다.
사용자 계속 개발·효율적 검수·main 커밋/푸시 위임으로 남은 해당 화면 번역을 진행한다.
공개 데모·출시 언어 claim은 바꾸지 않는다.

## 범위·소유

- root: private435 한국어 key 목록·TW 초안, 공식 교환 수용과
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`, `content/meta/full_game_localization.json`의
  append 통합, private435 normal, CLAUDE·큐/L3·이 사양/보관본·WORK_LOG·생성STATUS·agent 보고/판정.
- claude_handoff_review: private435 CN 초안 한 파일만. 한국어에서 직접 저작하며 TW 자동 변환0.
- receipt_tests392: 새 private435 교환·격리 런타임 helper와 `tools/audit_scope.json`의
  명시 `holdem-zh` 차선만. 기존434/436 helper·성공/실패 원본은 수정하지 않는다.
- independent392: 비저자 원문/44값 전수 의미·실제8PNG·입력·최종 결과 검수.
  모든 실제 교환/검사/엔진 실행은 root만 한다.
- KO/EN/JA·Holdem/Main/LocaleManager/FontKit·게임 규칙·돈·덱·AI·저장·AP·인간원장·
  public demo/출시 manifest 불변. 기존 수용41612/b207·JA3044/CN/TW1711부터 시작한다.

## 번역 모집단

SETUP의 제목·부제·보유현금·3줄 안내·바이인 제목·규칙·퇴장·입력힌트 8키,
첫 PREFLOP의 상대 호칭2·단계·머리말·차례·EV3·행동6의14키다.
기존 table 입력힌트는 화면에서 검수하지만 신규키로 세지 않는다.

- 지하 홀덤 클럽
- No-Limit Texas Hold'em  ·  5,000 / 10,000 블라인드
- 보유 현금: %s
- `[color=#7a8a9a]• 상대방 2명과 1:1:1 대결\n• 상금은 모두 테이블 위로\n• 언제든 자리를 뜰 수 있습니다[/color]`
- 바이인 금액 선택
- 게임 규칙 보기
- 자리를 뜬다
- `[%s] 시작  [%s/%s] 바이인 −/+  [%s] 바이인 +  [%s] 규칙  [%s] 나가기`
- 조용한 남자 / 소란스러운 여자
- 프리플랍
- `[b][color=#f0b429]지하 홀덤 클럽[/color][/b]   [color=#3a4a5a]%s[/color]%s`
- 당신의 차례
- ` — [color=#5de89c]+EV 콜 (승률%d%% > 팟오즈%d%%)[/color]`
- ` — [color=#e85d5d]-EV 폴드 권장 (승률%d%% < 팟오즈%d%%)[/color]`
- ` — [color=#e8c45d]팟오즈 %d%% / 핸드강도 %d%%[/color]`
- 폴드 / `콜  %s` / `하프팟\n%s` / `팟\n%s` / `올인\n%s` / `자리를\n뜬다`

## 구현·표적 검수

- 한국어 원문에서 CN/TW를 각각 작성한다. 3줄 안내의 상금은 테이블 스택에 남는
  뜻이며 전액 베팅 명령으로 바꾸지 않는다. 수치·태그·LF·선행 대시·placeholder를
  보존한다. EV 두 분기는 승률→팟오즈, 중립은 팟오즈→강도 인자 순서를 유지한다.
- 공식 source-bound export/check/import 22값×2batch 후 기존4파일 raw 역상을 확인한다.
  수용 목표41656/b209·CN/TW1733·JA3044이며 실제 성공 전 완료로 기록하지 않는다.
- proven pre-autoload 격리 지역별1프로세스. 독립 준비/복원한 실제 첫손3개로
  SETUP1·+EV/−EV/중립 PREFLOP3, 총8PNG를 관측한다. 준비 cash5M/buy-in100k에서
  pot15k/call5k/odds25이고 실제 원분기는 win>35/<20/20..35다.
- 임시 RNG/원래 TexasHoldem 순수 함수로 각 분기의 seed만 bounded 탐색해 고정한다.
  제품에는 seed만 준비하고 실제 ui_accept로 패를 돌린다. hole/strength/win_pct/
  텍스트/포커스/사전/폰트 직접 주입0, 자연 ingress 주장은 아니다.
- 3회/지역 actual Tutorial 취소와 첫손 Enter, 첫 사례 setup4/table7 안전탐색을 관측한다.
  예정 총68raw/34synthetic taps·첫손6·정산0이며 실제 수행량을 기록한다.
  나머지 EV 사례는 초기 semantic cursor/보이는 활성 선택을 확인하고 table 확정은 하지 않는다.
- 22키를 실제 Label/RichText/Button 소비자에 결속하고 지역 normal/bold 서체·glyph·
  parsed text·줄바꿈·폭/높이·겹침을 확인한다. 기존 money/canvas 관측도 유지한다.
  52고유=6dealt+46remaining, typed GameState/Holdem/flash/Main·Meta·Tutorial·Hints·
  논리BGM 복원 및 실제player34 바이트 보존을 유지한다. playhead/전역visual RNG 복원 주장0.
- 새 helper의 malformed observation도 원본을 남기고 실패 기록을 마치게 한다.
  원래436의 성공·실패 기록 한계를 소급 수정하지 않는다.
- 같은 clean 후보에서 fresh receipt/fullbody·ZH/EN·context/queue/diff/등록8검증+
  명시차선 조회1만 실행한다. 변경 없는 JA 사전/게임소스를 byte 대조하며434의4종
  서사는 NOT_RUN 참조, 기존 focused·전체감사·240주·성능A/B 반복0이다.

## 경계·일회성

- 이 번역을 빼면 해당 화면이 영어로 fallback한다. 새 선택·경제 수치·경쟁·24주 결과
  차이를 추가하는 작업이 아니다. source 변경이 확인되면 현재 원문을 재검토한다.
- check/1/3pot/후속 street·승패·정산·규칙창 본문·direct POT/BOARD/STACK/BET/NEW HAND,
  모든 거액/해상도·자연진입·물리패드/원어민/인간 관측은 이 작업으로 닫지 않는다.
- 저작·검수 절차는 일회성, 상시 규범0. 자동PASS는 계약 증거다. 과거434 REWORK와
  새538e1318의434·436 GO를 보존하고 공개GO1·인간OPEN45·본편/새package HOLD를 유지한다.

## 완료 증거 — source 0feadbfb

- source `0feadbfbfac2e9b1922df41b3f8f25cdcff50e44`, tree `61bec873dbbceb436d84f844eecb0bbb9eb5b530`; main commit/push 완료.
- 공식22값×2batch 수용44, accepted41656/b209·CN/TW1733·JA3044. 기존4파일 raw 역상 PASS.
- 실제8PNG·88key bindings·68raw/34tap·첫손6·정산0,39.789초. 두 지역 actual SETUP와 +EV/−EV/중립 PREFLOP를 직접 읽었다.
- fresh8검증+조회1 PASS,371.91초. receipt/fullbody/ZH/EN/context/queue/diff/등록이며 이전4서사는434 증거 참조/NOT_RUN. 기존focused·JA감사·전체·240주 반복0.
- 결과: `.git/full-game-localization/order435-screen-first/result.json` SHA `88c2f00d277669c4bc48e205b446a20738634a3482a2d9543257ab1b17175bf2`, `order435-static-final/result.json` SHA `4b66d18ff4a7642bf4e224452944f9055da0ba3b41822adbafe59801b73f50c7`.
- 비저자 [최종 보고](../agent_reviews/ORDER-435.json)로 이 범위 GO. 자동PASS는 계약 증거이지 작품·출시GO가 아니다. 규범 판정: 저작·검수 지시는 **일회성**, 상시 정본 규칙 추가0.
- 신규44값의 가독성/입력만 닫는다. 직접 영어 라벨·10px 금액·크림 카드 위 어두운 문양의 낮은 대비, 후속 street/정산·자연진입·native/human/physical 미관측은 남긴다. 실제 인간 OPEN45·공개GO1·본편/새package HOLD 보존.

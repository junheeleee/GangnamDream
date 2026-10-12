# ORDER-579 — 일본어 정착 지원금의 양의 부호·임시 생존 의미

#### [~] ORDER-579 [정합·현지화] 착수 — 2026-10-13

clean main9d3ae5bb1dfb246793db2628b2fe26d153a47349에서 실제 JA 값의
`+30만원` 양의 부호 누락을 확인했다. ORDER-157/사용자 전체 번역 위임 안이다.
CI38303839800은 in_progress/결론null, OS잠금 True·M17/562 HOLD 하나다.
새 월·native·엔진·잠금 우회/해제 재요청0, source/저장/공개데모 변경0이다.

## 깊이 3문·실제 범위

1. KO `정착 지원금 +30만원이 이번 달 생존을 잠시 밀어줬다.`의 JA1399 값은
   `定着支援金 30万ウォンが、今月の生存を少しだけ先送りしてくれた。`다.
   +부호를 잃고 임시 생계 도움도 어색하다. 기존값을 방치하면 이 결함이 남는다.
2. MainGame.gd:22937 `_show_month_summary`의 subsidy 조건 :22935 뒤 label이다.
   실제 생산자는 :9015 claim → :9029 snap.subsidy → :9052 show_summary guard다.
   정상 FullStoryFlow:710은 false로 호출하므로 이 모달을 열지 않는다. legacy
   월말 모달의 표면 교정이며 정상 본편 노출·신규 번역 coverage로 세지 않는다.
3. 경제/주차/선택·24주 상태 차이0. 플레이어 결정이 아닌 기존 안내의 의미 수리다.
   한 키만 고치며 체크카드·나머지 invalid57개/카지노 도움말을 섞지 않는다.

## 소유·비소유

- root: locale/ui_ja.json 위 기존 값1만, content/meta/full_game_localization.json
  첫 accepted1/공식 receipt를 보존한 UI batch1/checksum만; 큐2/이 사양/마감
  WORK_LOG·CLAUDE 현재행. KO 직접 번역이며 인접 EN/옛JA를 읽은 사실을 공개한다.
- manual_save_ci: 새 .git/order579-20261013/의 비저자 원문/응답/receipt/delta 검수만.
- rework_batch_plan: 같은 private before/final·정확 역치환/비소유 보존 검수만.
- mod_layer_ci: 읽기전용 선행 조사. 저작/제품/검사0이다.

KO/EN/runtime·CN/TW·기존 원장/배치·project/presets·사용자/공개 저장설정·Human/
과거판정·공개demo/pin·retail언어·기존578raw/seed/app은 비소유다. 새helper/tool/
checker/self-test/등록·479/481 비용최적화0, 숫자 검증 완화0이다.

## 순서·검증

선언 commit/push → fresh official JA exact1 export(기존 target hash) → KO 직접
응답 → 비저자 전수 검수 → check/import --replace-existing --accept → 원official
header/digest/accepted1 별도 기록. 옛 값은 실제Git로 보존하고 source는 불변이다.
기존 UI3+원장4파일 raw inverse·실제Gitmanifest·옛batch/accepted·보호/비소유를
기존 pure-reader로 직접 확인한다. 기존값 수리를 append-only gate로 수용하지 않는다.

audit_select --list 영향만; JA UI·i18n·ZH all(CN/TW 비소유 보존)·demo scope all·
story demo·공식JA inventory·context/queue/diff를 표적으로 수행한다. EN 검사는
KO/EN/runtime exact와 직전578 actual0로 귀속한다. 변경 없는 self-test/엔진/
컴파일/전체audit/240주 반복0이다. 기존JAinvalid58 중 해당 부호1만 줄어야 하며
나머지 목록을 그대로 보존한다. source/receipt/보존 독립 GO 전에는 닫지 않는다.

## 판정 경계

위 파일 소유/단위/순서는 일회성·새규범 승격0이다. gangnamdream-dev/I18N의
KO 직접 저작·비소유 보존·기계/실관찰 분리를 따른다. 자동 계약은 재미·깊이·
문체·인간 관찰 GO가 아니다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·
출시 HOLD·M17 OS잠금 HOLD 하나를 유지한다. 실제 commit/새 CI는 마감 뒤
별도 private 신원으로 확인하며 현황판 단독 후속 commit0이다.

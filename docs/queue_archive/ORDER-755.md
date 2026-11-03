# ORDER-755 — 민기 원문 후속의 중국어 검증 결속

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-755 · 민기 원문 후속의 중국어 검증 결속

2026-11-03 root 착수·부모157/C5, 754 실제CN/TW거절에서발견한작은후속수리다.

## 정확한 소유권·깊이3문 (일회성)

- `tools/zh_translation_audit.py`: 기존MIDGAME_SOURCE_KIND/_midgame_latin에
  현재arc_year_two_pressure description/title exact source지문과local title역할만추가.
- `tools/full_game_localization_self_test.py`: 원문결속Mingi 반례·기존원문회귀 표적테스트만.
- 큐/활성755/부모157/WORK_LOG·독립보고/판정. 754원고/원장/역사이동비소유.
  기존Mingi준비형을재사용하며전역영어허용/새인명한자/KO/EN/원고수정0.

1. 제거하면: 이미허용한Mingi를현재한국어청첩장원문과제목에서영어잔재로오탐한다.
2. 선택대가: 원문없는민기/이름위치·개수/업종/관계/한자별칭을여전히거절한다.
3. 경쟁: 낡은exact원문은회귀로보존하고새exact2곳만결속한다. 전역허용이나
   번역에서이름삭제로검사를피하지않는다.

원거절/초안은754원자료에보존. 현재실제소비자전체check_batch와좁은positive/
negative·옛source를대조하고JSON/문자/돈·원화·한글/영어차단을완화하지않는다.
tools변경이므로해당실제표적test와검사등록/문맥/큐/diff를확인한다.
755코드와754번역은같은제품후보에합쳐독립적으로각범위를판정하며,
서로다른작업의GO를차용하지않는다. 번역수용·전체언어/native/화면/CI/출시는별도다.

도달 경로: 754원check zh-CN/TW description Mingi token거절.
생산자↔독자: 현재KR두leaf → midgame source kind → Latin name local guard.
바꾸는 상태: 현재원문누락2 → 지원2, 원어민/게임플레이변화0.
포기 시 잃는 것: 민기인명보존과현재청첩장본문의검증가능성.
서사 위치/계층: 기존원문/계층불변. 닫는 것: observed validator false positive만.
규범일회성/기존source-bound계약적용·새대형도구0.

## 검사 실물·후보

현재KR exact2 source결속·title역할만추가, 기존지문/전역차단불변.
독립코드/표적검수GO·추가3tests 최종PASS, 전체교환274tests exit0(79.274s).
최초focused의Leaf.validator fixture오류1은보존·category소유의명시값으로수리했고
제품오류/번역오류나최종통과로바꾸지않는다. CN/TW실제754 check/import도수용됐다.
검사등록registered186·context/queue/diff 확인. zh-self-test12783 exit0/stderr0·
ZH_TRANSLATION_AUDIT_OK mode=skeleton이며실제언어완성/화면아님.
원자료 `.git/localization-mingi-guard-20261103/` raw8=최종6/fixture오류2로SHA결속.
제품485494182d0dd88f3267dd082f2bd226a5f17e46/tree2e97aadf의
[독립코드검수](../agent_reviews/order755-mingi-source-guard.md)는이오탐수리만GO다.
독립focused3 exit0/0.277s, 실제4positive·추가hash2개제거시4reject·
추가12별칭/달러/한글반례거절도확인했다. 754번역GO를차용하지않는다.
2026-11-03 완료·규범일회성/기존source-bound계약적용·승격0.
전체언어/실화면/원어민·최신CI/M60/출시GO별도.

# ORDER-415 — 선물 뒤 인물 반응과 기록의 중국어 번역

#### [x] ORDER-415 [P1·현지화] 받은 사람의 말과 선물 기록을 중국어로 읽는다

**완료 — 2026-10-04.** source ae51a7d / tree60356f3 범위한정 독립 GO.
[독립 보고](../agent_reviews/ORDER-415.json)가 원문·실패·수리·검사·SHA를 소유한다.
415-r1 실제24전달/6PNG, 416 동일본문5언어/5PNG, 417 focused131 PASS.
공통검사 최초13중12PASS와 queue 수리PASS를 결합하며 실패원본/부분수리FAIL 보존.
게임·사전·플레이어 보호와 본편/새packageHOLD·인간/원어민/물리미관측 유지.
규범 판정: 아래 착수/검수 지시는 일회성. 기존 정본 적용, 상시규범 추가/승격 없음.

**[~] 착수 — 2026-10-04.** 사용자 계속 개발·독립검수·main 커밋/푸시 위임.
선물 준비 화면 다음에 실제 소비되는 16개 기존 KO UI 키를 CN/TW 각각 직접 번역한다.

## 판정 단위·깊이3문

- 누락 시 선물을 건넨 직후 인물 반응과 행동 기록이 영어 폴백으로 바뀐다.
- 표현만 추가한다. AP·호감·재고·쿨다운·시간·장기 관계 조건과 이후 회수는 기존 그대로다.
- 반응10·반복4·기록2의 한 배치. CN/TW 각16값, 총32값/receipt32/batch2.
  fallback 인물2키는 현재 선물 대상 밖의 방어 분기이며 자연 도달로 세지 않는다.

## 정확 모집단

MainGame::_gift_reaction / _gift_repeat_line / _ap_give_gift의 아래 기존 키만 소유한다.

1. 민준씨, 이거 고르는 데 얼마나 서 있었어요?
2. 고마워요, 민준씨. 잘 볼게요.
3. …이런 거 받으면, 나 뭘 돌려줘야 할지 모르겠어요.
4. 오빠, 이거 기억하고 있었어?
5. 고마워. …나 이런 거 많아.
6. 이런 거 처음 받아봐.
7. 고마워. 잘 쓸게.
8. …뭘 이런 걸 다.
9. 그래, 고맙다. 돈 아껴 써라.
10. 고맙다.
11. …민준씨, 또 이거네요.
12. …또 이거야?
13. …또 뭘 사왔냐.
14. …또 이거네.
15. `🎁 선물 — ` (끝 공백 포함)
16. `✓ 🎁 선물 · %s`

## 소유와 수용

- Root: 새 private415 CN/TW 직접초안·공식 export/check/import·기존raw 역상검증.
  locale/ui_zh-CN.json, locale/ui_zh-TW.json, content/meta/full_game_localization.json의
  위32값/receipt32·checksum·batch2만 변경한다. 사전/원장은 함께 commit한다.
- /root/receipt_tests392: 새 private order415-check.gd / tscn / run.py의 실제 소비자
  검수helper만. 기존 private/helper나 제품은 편집하지 않는다.
- /root/independent392: 번역32값 KO직접 전수대조, helper·수용·실제노드/PNG·검사원본
  독립읽기. 최종 private415-independent-review.json 한 번 작성 후 SHA봉인.
- Root운영: 큐·이사양·CLAUDE·WORK_LOG·생성STATUS·완료archive·
  docs/agent_reviews/ORDER-415.json·docs/agent_review_decisions.json.
- MainGame·GameState·KO/EN/JA·카탈로그·가격·게임조건·교정proof·기존시험·
  공개demo·인간원장·project.godot·출시manifest는 비소유다. 새범용검사0.

## 최소 표적 검수

- 다은의 조심스러운 존댓말·지연의 기존 친근한 말투·아버지의 짧은 반응을 유지한다.
  CN/TW는 각각 KO직접 저작하며 자동 문자변환/영어중역0, 이름 Roman잠금·%s·공백 유지.
- 공식교환 언어별1batch, accepted41252/b185 → 41284/b187.
  기존receipt·사전·나머지raw를 되돌림 비교로 보존한다.
- proven pre-autoload namespace에서 1280×800, locale당 실제 선물전달12회:
  다은3·지연4·아버지2 최초분기, 각인물 반복1. fallback2는 getter-only.
  준비 상태의 eligible/reachable/AP1/쿨다운0/재고int2/자산1천만원미만을 직접 확인한다.
  첫 gift_hits0, 반복은 기존gave=true/lastturn=turn-4로 준비하고 자연 진행 주장0.
- 실제 전달마다 AP1→0·재고2→1·정확 affinity·contact/axis/place/flags/log 변화만 허용,
  깊은 typed 상태복원으로 이전값·형식까지 확인한다. 직접전달24회와 item_used signal0은
  별도계수하며 confirm/raw/다음턴/구매/3hit열림은 실행하지 않는다.
- 실제 event_body RichTextLabel의 scene-first 19px·SC/TC·자연 타이핑완료·전체본문/높이/경계 계측,
  locale당 다은 부담반응·지연 도록반응·아버지 반복반응 3대표PNG(총6).
  나머지 실측노드는 screenshot직접열람과 구분한다. 두 기록 템플릿도 실제로그와 대조.
- source/helper/player 파일 불변 및 마지막 typed복원. 최종후보 normal receipt/fullbody/
  storygraph/Chapter5/Year5/Chapter1/ZH/EN/context/queue/diff/영향목록을 최대3병렬1회.
  변경없는414 focused·JA화면·과거self·전체감사·240주 반복0.
  실패원본을 보존하고 실패영향만 재검사한다.

## 알려진 별도 위험·경계

첫 실행 sourcecff41a6의 24회 상태효과/typed복원/전체본문은 PASS이나 지역서체는 FAIL이다.
static QA도 실제 _render_event에서 scene-first=true/19px로 전환되므로 최초18px/false
예상은 검사 오류다. commitment{}는 부가 ledger 없음과 정확본문으로 확인한다.
Open Sans 기본서체의 FontKit 미연결은 실제 제품결함이며 별도 [416](ORDER-416.md)이 소유한다.
최초 helper/실패원본은 보존하고 새 -r1 helper로 같은24회/6PNG를 검수한다.

ROMANCE_SYSTEM §1과 기존 _gift_eligible/_gift_reaction의 지연 연애전 호칭이 충돌한다.
이번 번역은 KO를 보존하고 지연 검수는 jiyeon_romance_started=true 및 다은연애false에서만
진행한다. 연애전 호칭을 승인/수리한 것으로 세지 않으며, 선물자체를 연애후로 잠그지 않고
pre/post 말투 분기와 §7F 정렬은 별도 후속 선언 대상이다. 기존 JA의 고르는 시간→줄서기
오독 의심도 별도 의미대조 대상이며 이번값을 바꾸지 않는다.

일회성 번역/표적사양·상시규범추가0. 자동PASS는 계약증거이지 재미·문체·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측을 보존한다.
기존B3/B4·그밖의UI/서사·외부출시/스토어/지출/법률은 범위 밖이다.

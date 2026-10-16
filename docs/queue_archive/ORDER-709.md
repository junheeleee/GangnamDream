# ORDER-709 — PR37 병합·R4/R5 승인 KO/EN 문안 적용

#### [x] ORDER-709 완료 — 2026-10-16 · 승인 KO/EN 58잎 source 수용

PR36은 merged/head8005b85이며 R2§1·2/R3§1~7은707에서 적용했다.
이를 반복하지 않고 PR37 head `4c2e051d621140cbf5cceaf7db598fa1ded902a9`의
R5 문서1개를 main에 병합한 뒤 main R4§1~8와 R5§1·2를 함께 적용한다.
R2§3는 기존 기록만 보존, R5§3는 기록만, R6·다른 문체 범위는 재개하지 않는다.
본문 수리는 SCENE_TIER의 현재 장면 감각·실제 생산 선택을 따른다.

## exact 소유와 보존

- 저자A `/root/av_audio_status`: `content/events/arc_drama.json`,
  `content/events_en/arc_drama.json`, `content/events/arc_year3_drama.json`,
  `content/events_en/arc_year3_drama.json`의 R4§2·3·5·6와 R5§1·2 text leaf만.
- 저자B `/root/m32_path_review`: `content/events/arc_pre_ending.json`,
  `content/events_en/arc_pre_ending.json`의 R4§1·4·7,
  `content/events/arc_new_characters.json`, `content/events_en/arc_new_characters.json`,
  `content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`의 §8만.
- root: PR 병합, 이 사양/archive·CODEX_QUEUE/L3·CLAUDE·WORK_LOG·
  POST_LAUNCH_NOTES의 R5§3 기록만. 파생 본문 지문이 변한 경우에만
  `content/meta/release_content_inventory.json`의 실제 실패축 후보본문 hash와
  `docs/CONTENT_RATING_INVENTORY.md` 생성뷰를 기존 도구로 정합한다.
  등급/강도/후보ID집합/설문답·제출·법률인증은 변경하지 않는다.
- private `.git/order709-text-reviews-20261016/`: root의 PR원문·before10raw/
  보호지문·표적 raw·수용 기록. A는 author-A.md/json, B는 author-B.md/json만.
  비저자 `/root/m32_isolation_review`는 independent-review.md/json만 소유한다.
  root만 Git/QA 실행, 저자·검수자는 Git/엔진/UI/실사용자path 접근0이다.
- flags/effects/조건/id/배열·dict키순서/선택index/typed reader 구조·토큰/
  일정/라우팅·tier/배경/초상/CG/audio/direction·밸런스/저장/project/preset/
  공개demo/사람·agent 역사·CI검사/예외/래칫은 비소유다. JA/zh384 event파일과
  번역원장·accepted hash는 byteexact, 바뀐 KO 영수증을 새 번역 수용으로 재결속0.

## 사전 대조로 확정한 최소 보정

R5 병실23초는 선택2의 artifact 생산 또는 실제 연결 사실이 없는 런에도
무조건 표시돼 문서의 공통 연락처 대안을 적용한다. artifact 최초 생산자는
`arc_father_01_call` choice2이며 KTX에서만 생산된다는 문서 약술은 기록에서 정정한다.

R5 7기억 키 안에서 실제 생산과 맞지 않는 두 기억을 그대로 남기지 않는다.
`father_knew_i_came`은 callback_medication_visited_echo choice0의 가족앨범/
승차권·약봉지 사진·아버지가 생선을 더 놓은 장면만 회수한다. 지어낸 ‘기억하고
있었어’ 발화는 복원0. `apologized_for_ignoring`은 callback_medication_ignored_echo
choice0의 어머니에게 보낸 사과와 어머니의 ‘알았다’ 회신만 회수한다. 아버지와의
사과 통화·‘괜찮다 바쁘잖냐’는 쓰지 않는다. 현재 7키/우선순위/조건은 그대로다.

새 위치 단정도 최소 중립화한다. R5 called_father의 ‘병동번호 바로 아래’는
통화목록 인접성을 생산하지 않으므로 휴대폰을 쥔 현재 손끝 감각으로 닫는다.
R4 사람판정의 ‘맨 뒤 장·마지막 칸’은 네 접수갈래가 같은 위치를 생산하지
않으므로 현재 서류의 마지막 상태가 적힌 자리로만 쓴다.

R4-SELF는 실제3사건/locale6등장 leaf이며 문서의5+2사건 수치를 반복하지 않는다.
본문 첫 등장3개만 풀고 minseo choice1 text/result의 후속 표기는 유지한다.
after_goal의 prepend[0][1]은 앞선 장면이 생산한 ‘그 수정본/that revision’으로
지시해 본문 첫 명칭 풀이와 중복하지 않는다. locale4leaf만 변경하고 새 슬롯/
조건/reader는 만들지 않는다. 모든 c5read 토큰과 typed source·순서는 보존한다.

## 깊이3문·검증·플레이 우선

도달: 기존 StoryMode/R4·R5 사건 그대로. 생산자↔독자는 기존 선택 flags와
known/typed reader이며 문구만 수리한다. 선택/24주 뒤 상태 변화0·현재 허위
회상 제거와 승인 현재 감각 반영만 닫는다. 사용자 앱/실제 월과 화면 경쟁0.
일반W224 둘은 기존T2, W239생사/W240다은과 아버지 죽음 체인은 기존T1이다.
신규 자산·장면 계층 상승·방향키 요구0, 기존 자산/audio/direction을 보존한다.

선언 push 뒤 저작·독립 검수를 파일 소유로 나눈다. 실제 교체13사건/예상58잎은
허용 text path와 before 전체raw를 전수 대조하고 모든 비text/타언어를 보호한다.
root 표적은 en_coverage/english_hangul/story_consistency/narrative_continuity/
narrative_spine/event_lifecycle/audit/mod_layer/release_content_inventory와
chapter5_human_reject normal/self(승인본문과 fact-guard 동시 대조), 문서표적5/
context·queue·advisory STATUS·diff다. 원실패 raw를 보존하고 실패 표적만 재실행한다.
전체로컬audit/240주엔진/앱·새월/새도구/번역새승인0.

f4c3201 CI38891115471은 2026-10-16T12:37:58Z completed/success를 확인했다.
이 결과는 새709원고의 전체CI가 아니다. M37입력0/W145·H3 checkpoint를 보존한다. 사용자16.2
실제 플레이를 방해하거나 저장/앱을 덮지 않으며 화면 없는 범위만 진행한다.
완료월 재개0·월최대2/월별한commit. source 수용≠새화면/재미/피로/사람/원어민/
물리패드/청취/CJK최종/C1완주/C2전체/Steam/출시GO. 새main CI는 push 뒤 별도다.

ScreenshotQA의 기존R3 잔여 literal은 이번 R4/R5가 만든 실패가 아니며 별도
source 대조 메모로만 보존한다. 현재CI 실패로 세거나709에서 도구를 확대수리0.
규범승격0/일회성. 개발·장면 스킬의 현재감각/생산조건/독립·표적 절차를 따른다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 표적 실행의 파생 지문 정합

최초 release_content_inventory 원실패는 예상 fear/crime과 달리 sexuality/fear의
expected_content_sha256 두 칸과 생성뷰 stale뿐이다. 같은 선언 exact두파일에서
실제 실패 두축 hash만 현재 승인본문에 정합한다. 다른축 crime 포함·ID집합·개수·
분류·강도·질문답은 그대로다. 원실패 raw를 남기고 이 표적만 재실행한다.
직접 T1 계약의 peak_scene_chain normal도 정적으로 대조하며 엔진/앱 실행0이다.

## 결과 · 승인 문안 한정 수용

- 선언f47e4f6 뒤 PR37의 exact head4c2e051d621140cbf5cceaf7db598fa1ded902a9를
  b107cbfcbab79fdca44ba517198a7e27c1f23d4c로병합/push했다. GitHub PR37
  closed/merged와동일merge SHA를확인했다. 병합delta는R5문서1개73줄뿐이다.
  이미병합된PR36/R2/R3는재적용0. R5§3는POST_LAUNCH_NOTES 기록만이다.
- R4§1~8/R5§1·2 실제13사건·KO29/EN29 총58text잎·10파일을두저자로분리했다.
  아버지사별은실제앨범/생선·어머니사과문자 기억과공통연락처이름으로맞췄다.
  새통화기록위치/서류맨뒤장 단정은현재손끝/기록된상태위치로중립화했다.
  SELF는실제3사건의본문3개와기존prepend1개/locale만변경·후속choice원형이다.
- root/비저자는58전후잎전독·승인범위/생산조건을대조했다. 482event-locale 중
  26객체만변경·10raw역치환exact·키/배열순서·모든비text/typed구조/c5read24토큰
  불변. 일반{name}은승인문안안5잎만변화(A1/B4), typed토큰보존과구분한다.
  1105비소유49555397B drift0·CJK384/번역원장/accepted hash exact·재결속0.
  처음CJK계수128은events_zh_경로오타로중국어를세지못한측정오류였으며,
  보호1105에는이미모두포함됐다. 원영수증보존뒤v2계수만384로정정·QA재실행0.
- source12 최초11pass/1fail·원raw보존/stderr0. 유일실패는sexuality/fear의
  본문hash와생성뷰stale였다. 선언exact두파일의hash2칸/뷰2셀만정합후
  기존재생성7.749487초/같은표적재검사7.644599초 exit0. 사건집합/개수/분류/
  강도/질문답/설문제출0. chapter5 normal/self109·peak31/debt0 통과,
  제품동작검사/예외/래칫/도구 변화0·전체로컬/240주엔진/새월/앱실행0.
- private `.git/order709-text-reviews-20261016/`: before243429B/
  4872a3c8eb775da466f8cb1d573cc228d0d266a8bdde009702287b5eeba1557b;
  root-source-verification-v2.json75529B/
  b33fe1921e2dca0156c7ec99d55521d6c38a16b19fc8793b73ea5c9e6c26fd12.
  author-A.md7124B/c4b11528…a7801·json54112B/c36aca05…48fff,
  author-B.md5085B/c34b0878…001f9·json11594B/58fc11b1…42ee1.
  독립보고/원raw/최종핀과root수용은같은private경로에결속한다.
  independent-review.md7635B/
  e6e6eeb9a31d48543c22ec3dc4ce2c6e4dcfadc7a7cd56c929eec3a0d4ae7e3b,
  json17533B/3a5309ce8522eaea78b971d8cee9bf7220e68b222b3a5eed8406af1ebac9e4f4.
  판정은GO_DECLARED_R4_R5_TEXT_DELTA_ONLY_PENDING_INTEGRATION·차단0이다.
  root가보고전문/최종24참조핀을확인·root-acceptance.json에통합index tree를결속한다.
- 개발·장면스킬의현재감각/생산조건/독립·표적계약적용·승격0/나머지일회성.
  사용자16.2·저장/설정·project/preset·공개demo·과거판정/복원HOLD/H3위험보존.
  f4c3201 전체CI success는별도기준이며수정main CI는push후별도확인한다.
  source수용≠새화면/사람·원어민·패드/청취/재미·피로/CJK최종/전체C2/C1완주/
  Steam/출시GO. 사용자실제플레이를중단시키거나앱을덮지않았다.
- 문서5 최초4pass/1contextfail: 큐13036B/max13000. 현재C3/C2 요약만줄여
  12865B로수리후실패표적만0.131998초 exit0·원raw보존·budget/규칙변경0.
  context boot30730/docs837/link304·queue active77/max_batches2·fixtures25,
  human OPEN45/DONE1/현재dirty전체후보HOLD·STATUS stale advisory비차단.
  git diff --check 통과·STATUS전용커밋0. 한정source수용을전체판정으로승격0.

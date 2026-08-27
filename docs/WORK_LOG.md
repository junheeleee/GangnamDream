# Gangnam Dream Work Log

> 최신 작업만 역순으로 기록한다. 2026-07-24 이전 원문은
> [`5/16~7/24`](history/WORK_LOG_2026-05-16_to_2026-07-24.md), 보관본은
> [`8/24`](history/WORK_LOG_2026-08-24.md), [`8/18`](history/WORK_LOG_2026-08-18.md),
> [`8/18 후속`](history/WORK_LOG_2026-08-18_late.md),
> [`8/15`](history/WORK_LOG_2026-08-15.md),
> [`8/14`](history/WORK_LOG_2026-08-14.md),
> [`8/12`](history/WORK_LOG_2026-08-12.md),
> [`8/11`](history/WORK_LOG_2026-08-11.md), [`8/10`](history/WORK_LOG_2026-08-10.md),
> [`8/5`](history/WORK_LOG_2026-08-05.md), [`8/4`](history/WORK_LOG_2026-08-04.md),
> [`8/3`](history/WORK_LOG_2026-08-03.md), [`7/31`](history/WORK_LOG_2026-07-31.md),
> [`7/30`](history/WORK_LOG_2026-07-30.md), [`7/29`](history/WORK_LOG_2026-07-29.md),
> [`7/27`](history/WORK_LOG_2026-07-27.md), [`7/26`](history/WORK_LOG_2026-07-26.md),
> [`7/25`](history/WORK_LOG_2026-07-25.md)에 손실 없이 보존한다.
> 과거 근거는 기본 컨텍스트에 넣지 말고 먼저 `rg -n "<키워드>" docs/history/`로 찾는다.

## 2026-08-27 (Codex — ORDER-136 M55 다은 회의 초상 수리·후보 재발급)

- Claude가 clean detached `611c635`에서 제품 source `771d0e7`과 후보 원장의
  일치, Python 감사 ERROR/WARNING 0, 이전 미도달 원고 127건 해소를 확인했다.
  다만 Godot·디스플레이가 없어 정상 독해 플레이, 검은 화면·잘림·초상 렌더,
  전환 체감은 판정하지 않았다. 따라서 보고는 원고·데이터 한정 CONDITIONAL로만
  보존하고 property/general 사람 플레이 게이트에는 합격·실패 evidence를 쓰지
  않았다.
- 막는 결함 `arc_y5_room_consent_receipt`의 `daeun_normal`을 제거했다. 사건은
  `meeting + portrait:""`, 시각 계약은 `portrait:null`, 표시 계약은 네 실제
  참가자와 `portrait_role:none`으로 일치한다. 다은의 동등한 참여는 손글씨 경계,
  지시, 투명 클립과 대사가 소유하며 회의용 재사용 초상이 생기기 전까지 기본
  편의점 근무복 초상을 띄우지 않는다.
- 기존 ScreenshotQA 목록에만 있고 실제 다섯 case에서는 빠졌던 W220 영수증을
  여섯 번째 화면으로 실행했다. causal visual self-test는 `daeun_normal` 복귀를
  거부하고, Year5 역사 감사는 ORDER-136 portrait 층을 제거한 뒤 ORDER-135 변경
  집합을 정확히 비교한다. portrait rollback은 이전 원장을 넓히지 않고 background
  같은 비소유 필드 변조는 숨기지 않는 48개 self-test가 통과했다.
- exact 제품 commit은 `b375af26f48668c68ec5bda05b25aedf064fe043`, tree
  `840016b61bceab6368ef79ea145b32a02730ba00`, source manifest SHA-256
  `9415428847c33b94536aa1a82be780cf4e88bcf2b8c9ebcf414a13625d066ad0`다.
  변경 범위 감사 74개와 전체 감사가 GREEN이고, KO/EN 1280×800 각 6장은
  `/private/tmp/gangnam-order136-final-ko.PFfJdE`,
  `/private/tmp/gangnam-order136-final-en.QSyUQQ`에서 `black=clear`, CG·focus
  verified다. W220에 다은 초상·프레임·CG 잔상·잘림이 없다.
- 일반 경로는 실제 source→finale 체인 7장면·17선택이며 네 선행 선택이 2~3회
  회수된다. raw 3장면·8선택과 property 9/24의 숫자 차이만으로 장면을 늘리지
  않는다. 정상 속도 플레이에서 W203→W224 공백, W237의 서류정리 감각,
  W240 서명→선발신 상승감이 실제로 실패할 때만 사람 압박 또는 비용을 작은
  후속으로 보강한다.
- 새 `chapter5_finale_rc`를 active로 등록했다. 두 정상 속도 L3와 사용자 최종
  GO는 OPEN이고 `main`은 HOLD다. 내부 `v0.1.0-dev · BUILD 2026.08.24.5`는
  그대로다. 승격 규칙은 `assets/CHAPTER5_MEETING_VISUAL_BIBLE.md`가 소유한다.

## 2026-08-27 (Codex — ORDER-135 일반 5장 종막 source candidate)

- `general_near_goal_father_passed`에서 M51 민서·M56 아버지·W229 마지막 지시·
  M59 25억 문턱의 exact 선택을 W237 기록 봉인, W240 서명, 같은 턴 선발신과
  엔딩 coda까지 연결했다. 작성량은 source+finale 4 roots·10 choices, 별도 finale
  원장 3 roots·8 choices이며 숫자에 맞춘 장면이 아니라 지시→기록 소유→해석→
  구체적 사람 행동의 서로 다른 인과 기능이다. 답장·용서·재회·매입·이체는
  발명하지 않았다.
- neutral과 투자형의 정확한 경로 tuple만 허용하고 career/startup·property·혼합·
  손상 상태는 fail-closed한다. 아버지 생사와 연락 source는 exact bool, 네 source는
  정확히 하나의 choice flag+event log가 있어야 하며 W237 잠금 뒤에는 경로·source를
  훼손해도 entry와 stage를 다시 쓰지 않는다. Python mutation 24건, Godot reducer·
  CoreChoice·ManualSave·EndingRouteIdentity, 기존 property 11/30·한 런 9/24,
  career/startup 32/86, 33세 30억 `instant_legend` 회귀를 통과했다.
- KO/EN×960·1280·1920 일반 78/78장과 기존 property KO/EN 1280 회귀 20/20장을
  자동·육안 확인했다. 검은 화면·잘림·겹침·초점·언어 누출·허위 동석은 0이고,
  W240 서명→같은 턴 선발신→엔딩 인계와 M55 다은 회의 사복도 유지된다.
- 제품 commit은 `21a3b473a590a47ba84b44daa9994f6f5f4e0e11`이다. 감사 수리까지
  합친 source candidate는 `771d0e735b9440b54d5449dfbd36369bf97d2b83`, tree
  `138ddf66f46ac3625eaf6dc355dcd4e2189545cc`, source manifest SHA-256
  `aff298c0c63d866637a8a1a7cd8283f90f0adfaafdb1744f25464968e7ef0fdc`다.
  source-only 로컬 Git 후보라 새 패키지와 버전 bump는 없고 내부 표시는
  `v0.1.0-dev · BUILD 2026.08.24.5` 그대로다.
- 첫 변경 범위 감사에서 드러난 기존 입력 시간 제한 2건과 인계·스토리 데모·
  패키지 감사 4건은 fixture/wrapper 최소 수리 뒤 표적 재검증으로 닫았다. 수리한
  exact source는 변경 범위 감사 111개와 전체 감사를 모두 통과해
  `chapter5_finale_rc` active Git source 후보로 등록했다. 두 정상 속도 L3와 사용자
  최종 GO가 남았으므로 완성·main 승격·재미 GO는 아직 아니다.

## 2026-08-27 (Codex — ORDER-135 일반 5장 종막 첫 profile 선언)

- 기준 `bc1006f`에서 일반 런의 직접 정지·선택·분량·peak가 투자 기준보다
  낮고, 민서 도착·아버지 기일·25억 문턱 선택이 generic W237/W240에 exact로
  읽히지 않는 결함을 확인했다.
- 첫 자식은 `general_near_goal_father_passed`만 소유한다. W229 마지막 지시,
  W237 기록 봉인, W240 서명, 같은 턴 선발신의 4 roots·10 choices를 source
  flag+event_log→typed entry→stage receipt→ending coda로 잇는다. 숫자 10에 맞춘
  장면 수가 아니라 서로 다른 네 인과 기능이다.
- 아버지 생존·중저자산·source 누락, property/career/startup은 기존 경로로
  fail-closed한다. `project.godot`, 기존 ending/balance, 즉시 실패 5종과 33세
  30억 `instant_legend`는 보호선이다. 기계·화면 검증 뒤에도 정상 속도 L3 전에는
  완성·main 병합·플레이 준비를 선언하지 않는다.

## 2026-08-27 (Codex — M55 네 사람 회의의 다은 복장 정합)

- M55 회의는 민준·상철·재혁·다은이 제안서·보증 PDF·미서명 사본을 한 방에
  놓고 다은의 이름과 시간을 계약에 쓸지 대치하는 장면이다. 기존 CG는 본문에
  근무 직후 도착했다는 근거가 없는데도 다은만 편의점 폴로·카디건을 입혀,
  동등한 동의 당사자보다 다른 장면에서 붙은 서비스 노동자처럼 읽혔다.
- 다은을 무광 차콜 재킷·청회색 블라우스의 평범한 회의 사복으로 교정했다.
  얼굴·단발·왼쪽 핀·민준을 향한 시선, 네 사람 배치, 별도 문서, 빨간 펜,
  계산기 하나, 종이컵 넷, 손·문·하단 크롭과 무서명 상태는 유지했다.
- 내장 ImageGen 편집 원본 `exec-714436d2-4463-4b19-b8d0-3373afca4190.png`을
  1280×800 `assets/cg/y5_three_in_room_v2.png`로 정규화했다. v1은 비활성
  출처본으로 보존하고 런타임·연기·모드·감사 원장은 v2로 옮겼다. 패키지
  raster 원장과 Chapter 1의 그 원장 exact source snapshot도 같은 실물에 맞췄다.

## 2026-08-26 (Codex — 5장 M49~M60 투자 기준 경로·안전 결말 완료)

- M49~M55 계약·보호·검사·보증·검토·공동 결정을 19 roots·47 choices의 exact
  receipt/reader로, M56~M60을 작성 11 roots·30 choices/한 런 9·24의
  흔적→보관→접수→판정→무이체→답→서명→선발신으로 연결했다.
- 구현 `974534f`, 감사 정합 `a543954` / tree `31c8749`에서 Chapter 1 478,
  저장·손상 차단·same-turn W240·consume-once와 clean 전체
  감사가 통과했다. 30억 비밀 엔딩과 즉시 실패 우선은 보존했다.
- KO/EN×3해상도 90장은 `BLACK_FAIL 0/90`; 서사 P0/P1/P2는 0이다.
  9단계는 10비트 할당이 아니라 서로 다른 기능의 결과다.
- 일반 안전 런은 `12 stops/14 choices/약 8k/peak 1`로 투자 기준
  `35/32/약 20k/peak 2`보다 낮다. 결말 후보는 `waiting_rebuild`,
  정상 속도 L3는 OPEN이다. 일반 W240과 정확한 reader 전에는 플레이 준비를
  알리지 않는다.

## 2026-08-26 (Codex — 갤러리 최초 관람 무결성)

- 갤러리 20루트는 최초 실제 진입에서만 유효 `seen + snapshot` 쌍을 한 번에
  만들고 이후 런이 덮어쓰지 않는다. seen-only·고아·손상·직접 실행은 현재
  상태로 과거를 꾸미지 않고 잠기며 다음 실제 조우에서만 복구된다.
- 이름·연차 초상·도덕 인지·주거/배경/앰비언스·selector·당시 보인 선택·계절
  음향을 동결하고 번역문은 최신 KO/EN을 읽는다. 전 구간 HUD/수치 결과 카드를
  숨겼고 재생 뒤 GameState·업적·history·CG·meta 변화는 0이다.
- 작성 폐쇄는 51편(일반 48+첫 청구서 3), 조건부 현수 echo 포함 runtime 최대
  52편이다. First Bill은 M3 장부 기억 3종과 legacy 누락을 구분한다. 전용 표지,
  476 인과 변이, exact 전체 감사가 통과했고 최종 고립 홈 정리 경고도 0이다.
- 실물 OpenGL KO/EN 각 5장을 확인해 잘림·검정막·현재 런 누출이 없었다. 독립
  코드 검토의 남은 P1/P2도 0이다. 구현 `2e2e5fe`, 감사 정렬 `7112744`, 정리
  `efd647d`다.
- 명시 T1은 12루트다. 나머지 8루트는 미선언 기본 T3이나 T2 기능을 해 formal
  tier가 미이관이고,
  `hometown_2`·`narrow_room_2` 두 실제 정점은 20개 폐쇄 밖이다. 자동 GREEN은
  모든 정점 회상·재미·언어·실물 입력 GO가 아니며 30억 `instant_legend`는 보존했다.
- 다음은 M49~M55의 인물·계약·선택 영수증을 먼저 연결하고 M56~M60의 마지막
  actor/signature를 잇는다. 사건 수나 10비트 할당량이 아니라 각 인과 기능으로 닫는다.

## 2026-08-26 (Codex — Chapter 4 선택·아버지 단일 시간선)

- M39~M48의 약속·진료·식탁·이름·청구·마지막 연락을 화면 밖 행동이 아니라
  StoryMode에서 직접 고르는 행동으로 옮기고, W157 표적 비용과 W193 첫 결산까지
  exact receipt로 연결했다. 같은 주 AP·효과·달력은 두 번 진행되지 않는다.
- W188의 생존/별세는 약물 확인·실제 임상 접근·M46 병동 조정 중 2개 이상만
  읽는다. 방문·통화·놓침은 관계 영수증이고 생사를 쓰지 않는다. 옛 passing receipt,
  canonical flag, passed cast 중 하나라도 있으면 사망은 단조이며 모순 저장은
  아버지를 부활시키거나 장면 효과를 두 번 적용하지 않는다.
- author-only 25편을 제품에 연결해 packaged/shipping/author-only가
  `1786/1656/130`이 됐다. KO/EN·시각·오디오·등급 원장을 맞추고 33세·1장의
  30억 `instant_legend`, 엔딩 35 ID·CG·15 route, 서명 coda 72/33은 보존했다.
- 구현 `3b275a913053412a3e2ff52fc9588d71d3a9bb37` / tree
  `9bc154b5b3cc534565fd66265183c7a0682e5b50`, 전체 감사 수리
  `2ec3a381722d7ba209d597c2a662a7546aa7cdb1` / tree
  `8ab3953c31335e306835fafdc8e694333629db16` 뒤 476 변이, Chapter 4·저장·
  24→48주 인계·CG·JA/ZH 검사를 통과했고 마감 전체 감사도 failure flag 0과
  `✅ 감사 통과`로 끝났다. 자동 GREEN은 사람 재미 GO가 아니다.
- 다음 제품 P1은 갤러리 20루트가 현재 런이 아니라 최초 관람 당시 이름·연도·
  도덕·주거·기억·선택을 재생하도록 고정하는 일이다. 그 뒤 M49~M60의 actor·문서·
  대화 영수증과 마지막 주 binding을 잇는다.

## 2026-08-26 (Codex — 종막 문단 할당량 철회·장면 기능 복구)

- 사용자의 “중요 장면은 10까지도 갈 수 있다”는 예시를 ORDER-129에서 exact
  `9/10/9` 문단 목표로 바꾼 판단이 잘못이었음을 확인했다. `docs/SCENE_TIER.md`의
  정본대로 문단과 dramatic beat를 분리하고, 현재 `6/8/6`은 관측값으로만 남겼다.
- summit은 정확히 25억인 경로와 이미 30억을 넘은 경로를 함께 사실대로 읽는다.
  정석·비정석 점수를 적금 만기·급등락 이력으로 꾸미지 않고 선택 기록의 기울기만
  말한다. countdown은 보장되지 않은 `같은 밤/조금 전 책상`을 버리고 독립적으로
  시작하며, 마지막 장 뒤 다음 장 자국과 결혼 유지 런의 `혼자가 됐다`도 없앴다.
- 기존 `final_week_self_approval`·`final_week_gratitude`가 결말에서 회수되는
  자기평가는 결과에 몰래 삽입하지 않고 선택문에 먼저 드러낸다. effects·flags·
  follow-up, ending coda 적용 72·제외 33, 엔딩 35 ID·CG·15 route와 33세·1장
  30억 즉시 비밀 엔딩은 보존했다.
- 패널 수 대신 기능·사실·variant·placeholder·선택 순서를 검사하고 literal filler,
  허위 30억 달성·매입·계약·등기·열쇠·이체·답장·화해를 거부하는 18개 mutation을
  추가했다. 구현 `fb9e473a6c2a9ead14c4becc12a1e28ddcbeabc0` / tree
  `24d7abdcae3e04c8a660e2feeed92eb1ec8318cf`에서 peak 32/32, Year5 self-test
  38, release `1758/1603/155`, 정적 ERROR 0, 한영 한글 누출 0을 통과했다.
- 남은 제품 P0는 보편 final week가 실제 대화 상대 receipt 없이 `그 사람`을 만드는
  점이다. Chapter 5의 M57·M59가 남은 인물·문서·마지막 대화를 저장한 뒤 actor를
  바인딩하고 signature 0개·2개 이상 손상 저장도 같은 오더에서 fail-closed한다.
  자동 GREEN은 이 후속이나 사람 재미 GO를 대신하지 않는다.

## 2026-08-25 (Codex — 종막 9·10·9비트와 마지막 서명 후일담)

- M59의 25억대 부동산 문턱, M60의 50만원/30억 마지막 장부, 마지막 주의
  선발신을 KO/EN 각각 `9/10/9` 의미 비트로 개작했다. 선택 결과는 모두
  4비트이며 매입·등기·열쇠·상대 답장·만남·용서·화해를 선택보다 먼저
  만들어 내지 않는다.
- 세 마지막 서명은 M60을 소유한 정규 엔딩 24개에서만 `사람들의 이후` 첫
  카드로 돌아온다. 실패 5개·`instant_legend`·M60 비소유 특수 5개는 제외하고,
  35 ending ID·전용 CG·15 route·기존 `description_if_known` 첫-true는 보존했다.
- 독립 한영 대조에서 만남의 존재, 이름의 위치·순서, 아버지 생존 조건이 언어마다
  달라진 P1 1건·P2 2건을 고쳤다. exact Year5 guard는 3 roots·18 surfaces와
  비산문 불변을 소유하고 self-test 38건이 변조를 거부한다.
- 10비트는 전역 할당량이 아니라 이 장면의 서로 다른 의미 전환이 요구한 길이다.
  이후 중요 장면은 필요한 기능을 먼저 정하고 자연스러운 길이에서 닫는다.
- 구현 `cd147f6f002e57ed11436466a37f2fd70336fc91` / tree
  `3eac06f9920a60a09941b62660e62b3324e1b913`에서 peak 32/32, coda 적용 72·
  제외 33, ControllerSemantic, ending distinctness 35, compile 66을 통과했다.
  자동 GREEN은 후반 전체의 사람 재미 판정이 아니며 다음은 Chapter 4 인과축이다.

## 2026-08-25 (Codex — 전체 감사 12 flag exact GREEN 복구)

- StoryMode 타입, 다은 guard, 첫 화면 고지와 Chapter 1·Year5 원장을 실제 의미에
  맞춰 재결합해 ORDER-127 뒤 12 failure flag를 0으로 닫았다.
- JA·zh-CN·zh-TW story-demo UI 실제 별도 소유는 34개였고, 중국어 `건당 백`,
  `Hanbit 流通`, 대만 표준자 `床`을 번역문 변경 없이 strict mutation gate에 연결했다.
- exact `0e4da0de95b7f3363067a09cea6b8dbace48c077` / tree
  `62f930fbd146a18daf2481eac7dce561c410d2d0`에서 full audit, 35 ending·15 route,
  240주 A/V, 66 script compile가 통과했다. 자동 GREEN은 후반 밀도·재미 GO가 아니다.

## 2026-08-25 (ORDER-127)
- 1장 30억은 즉시, 이후는 M60에 종결한다.

## 2026-08-25 (Codex — ORDER-126 5개 언어 story-first 공개 데모)

- 공개 표면은 StoryMode 선택·자동 정산으로 M01~M06을 잇고, 호환 AP
  엔진·저장은 보존했다.
- 5 locale의 11건·82 leaf·UI 117개와 cold exact resume를 잠갔다. 30개월·
  120주·정산 30회·AP 표면 0이고, 40개 캡처에 검정막·잘림이 없다.
- BUILD `2026.08.25.1` / `16675f6ce310adb477da9ab3431c2edfe15ab278`을
  `story_demo_rc`로 등록했다. 상세 해시·증거는
  [`ORDER-126`](queue_archive/ORDER-126.md)이 소유한다. 사용자 재미·시간감과
  JA·zh-CN·zh-TW 원어민 출시 claim만 OPEN이다.

## 2026-08-22 (Codex — ORDER-119 exact clean 기계·패키지 후보)

- exact clean `ebc58a839d64d8810b9da5548c20e58bc43c9e30` / tree
  `f978a22525b678ef83619dc50094a6dada75f190`에서 full audit failure flag `0`,
  KO gamepad·EN keyboard 각 24주 `CORE_LOOP_V2_INPUT_OK`, KO gamepad 240주
  `FULL_INPUT_RUN_OK weeks=240 events=240 ending=with_daeun`를 확인했다.
- BUILD `2026.08.22.1`의 Windows·macOS·Linux V2 playtest를 발급했고 manifest
  SHA-256은 `8a34920038962a4ba0885ad6189d92dc6d3c3ee2780020f3894938d380613177`다.
  macOS native no-arg smoke도 `PLAYTEST_RELEASE_ENTRY_READY`와 정상 종료 `0`을 확인했다.
  세 artifact SHA와 clean source identity는 manifest가 소유한다.
- 이 후보를 active `demo_rc`로 등록했다. 자동 증거는 사람 판정을 대신하지 않으므로
  ORDER-119는 `[~]`, 사용자 최종 GO는 `OPEN`이다. 고정 BUILD `.3` ORDER-99 저장
  게이트와 별도 ORDER-103 실행 후보·사용자 게이트도 바꾸지 않았다.

## 2026-08-22 (Codex — ORDER-123 원격 24주 입력 시간 예산 복구)

- closure `814f84b647aef8e351b7e5df727fe092309781ea`의 원격 run
  `32537893833`은 정적 job과 전체 `audit.sh`를 통과했다. KO PlayStation도
  Board 행렬, W9 exact terminal tuple, `v2_hyunsu_study_followup`을 통과하고
  W15까지 진행했으나 workflow의 420초 상한에 정확히 닿아 exit `124`로 끝났다.
- 종료 1.66초 전에도 W15 장면을 출력했고 engine/script/QA failure는 `0`이라
  제품 정지가 아니다. scope `65fbcf2` 뒤 구현
  `79f1e0db2878a1c1d8c380a478d2503c545c6af2`(tree
  `dea843ec197a456388d60801166f0baea26e1321`)에서 소유 범위를 20파일로
  늘리고 KO/EN 두 step의 유한 상한만 `420→1200`으로 고정했다.
- 제품·콘텐츠·입력 QA·runner는 `814f84b`와 byte-exact다. 같은 최종 closure
  바이트의 local full audit failure flag `0`을 재확인하며, 새 원격 CI가 KO·EN
  W24, SimRun, SmokeRace까지 green인 경우에만 `[x]`를 채택한다.

## 2026-08-22 (Codex — W9 다중 약속 선택·24주 입력 복구)

- 기준 `680e5f6bdcc9223b45143ca6224f7eb112809c6e`에서 구현
  `4177cd281d7be2c4084a294fd1aa3cbb89b15709`(tree
  `fc836ca142471c6520ba6f489e500ef1fc35d1dc`)으로 W9의 ordinary
  `daeun_world_meet`, Father terminal, Hyunsu terminal 세 후보를 모두
  보존했다. Board 상한은 현재 reachable max 4이며 5+,
  malformed record, 빈/중복 ID, KO/EN 결손, identity cross-wire는
  fail-closed한다.
- terminal candidate ID·authored bundle·route·variant를 분리했고,
  960×600에서 후보만 두 행 scroll로 보이며 설명·진전·deadline·
  Commit은 고정했다. W9의 Hyunsu terminal은 실제
  `hyunsu_study_followup` 번들과 `v2_hyunsu_study_followup` 장면으로
  연결됐다.
- KO/EN × keyboard/gamepad 24주 4개는 각각 24 allocations, W24 frozen
  snapshot, save/load, autosave, title return으로 완주했다. KO/EN ×
  1280×800/960×600 화면 4개, Board 0~4개 입력/해상도 행렬,
  Compile 65, Cycle 24/48/240 horizon, demo ORDER-123 음성 10,
  독립 L2 P0/P1 `0`을 확인했다.
- 첫 전체 감사는 제품·컴파일·밸런스·런타임을 통과하고 Year5 보호 해시
  1개와 Board 안내 lookup `+1`에서 파생된 JA/ZH 원장 4개만 실패했다.
  `284307e`가 범위를 19파일로 확장했고 `49942f7`은 잠금 4파일과
  Chapter source hash만 갱신했다. Year5 direct/self-test/R1 266,
  JA 68, ZH 251, demo localization 16, Chapter direct가 통과했다.
- `DemoCoreLoopV2`, GameState, KO/EN 사건, 실행 meta, 효과, 저장 schema,
  밸런스, Chapter ledger JSON은 기준과 byte-exact다. exact W9 IDs,
  유입 commit 계보, 20단위·19파일·산출물 경로는 일회성 증거이며,
  지속 규칙은 `docs/QA_CHECKLIST.md`의 Weeks 9–12 gate에 승격했다.
  ORDER-119 사용자 최종 GO는 계속 OPEN이다.

## 2026-08-22 (Codex — 전체 감사 잔여 7플래그 exact-scope 복구)

- 기준 `e53689ca58ef3fdc6e6fa9d2c67c7b4ca82975b4`에서 구현
  `5729b14af5f36af15a57cb21b8332e871224061f`(tree
  `4a77c593aa7a51cf4c08fd4a8071c7942365a20f`)로 surface, narrative continuity,
  full-run pacing, demo prose, exposed state, CoreLoop V2, scene-direction runtime의
  일곱 소유자를 수리했다. baseline·debt·project·manifest·gameplay metadata를
  완화하지 않았고 허용한 사건 산문은 exact 네 leaf뿐이다.
- surface는 StyleBox `260` / direct theme override `2112` / private color `681`,
  continuity는 A/B Chapter 2 isolated `0`과 branch `420/421` 경계, fixed-model
  2시간 crossing은 A W97 `modeled_random_foreground` / B W96
  `arc_year2_close`의 exact scene component다. demo prose written clock은 `0`,
  exposed-state는 domain `+2/-6`, CoreLoop V2 음성 검사는 `14`, direction runtime은
  shipping `1603`으로 통과했다.
- release는 packaged `1758` / shipping `1603` / author-only `155`, Chapter 1은
  authoritative `24/48` / debt code `8` / blocked evaluation `3`을 보존했다.
  Godot StoryMap/Direction/Compile이 통과했고 독립 L2 최종 판정은 P0/P1 `0`이다.
  `docs/QA_CHECKLIST.md`에는 branch 420/421, W96 exact-scene crossing, shipping
  direction fail-closed, reachable exact-minute permission을 정본 승격했다.
- 정확한 roots·edges·occurrences·domains·commit/tree·25단위·22파일은 일회성
  증거다. 이 마감 후보는 closure와 STATUS를 포함한 같은 최종 바이트에서 root가
  전체 `tools/audit.sh` failure flag `0`을 확인한 경우에만 완료 정본이며, 실패하면
  ORDER-122를 미완료로 되돌린다. ORDER-119는 그 green 뒤 마감을 재개하고 사용자
  최종 GO는 계속 OPEN이다.

## 2026-08-22 (Codex — author-only 생명주기와 shipping corpus 분리)

- 구현 `f7b9f6e53be1e06201b52360935593d372cb1ebb`(tree
  `3f7687f5acac752ba024d91f2ae9bb4ca68deeee`)에서 packaged 1,758 / shipping
  1,603 / author-only 155를 분리했다. tagged 127과 ledger-only 28의 exact 원장을
  만들고 weight/hidden/min_turn metadata와 제품 ingress 0을 함께 만족한 155편만
  dead/inert 감사에서 제외했다. `debt_baseline`은 올리지 않았고 `audit.py`는
  ERROR 0·inert 0이다.
- event director와 visual/audio/direction catalog는 shipping 1,603을 유지한다.
  release inventory/report는 packaged 1,758을 계속 심의 대상으로 세며, author-only를
  출시 package에서 지우거나 기존 manifest를 1,758로 부풀리지 않았다.
- Year5 kernel Dictionary 3곳, `arc_final_countdown` cue 4→3, Chapter 1 source/proof
  snapshot을 최소수리했다. lifecycle 27변이, release 14변이, year5 35변이·Godot
  266검사, Chapter 1 472변이와
  [정적 CI job](https://github.com/junheeleee/GangnamDream/actions/runs/32499196077)의
  story map·정적 감사·밸런스가 통과했다. 독립 L2 최종 판정은 P0/P1 0이다.
- 같은 구현의 전체 `audit.sh`는 rc 1이다. 확인된 잔여는 narrative continuity,
  full-run pacing, demo prose, exposed state, CoreLoopV2, surface coherence, stale STATUS,
  scene-direction runtime 여덟 플래그다. direction의 미분류 edge는
  `arc_y5_three_in_room→arc_y5_three_in_room_decision`과
  `arc_final_countdown_not_executed→arc_final_week`이다. STATUS는 이 closeout에서
  재생성해 해소했고, 현재 OPEN 7개는 별도 exact-scope 복구와 ORDER-119 마감 전까지
  넘긴다. leverage roundtrip 실패는 이번 전체 감사에서 재현되지 않았다.

## 2026-08-21 (Codex — ORDER-117 국소 수리·career 전수 판정 L1/L2 후보)

- 구현 후보 `e32c69b32acfbf6c5f1ced13cc88bf85ac5df563`(tree
  `a6f0a4050862e717d7eb4b365b557bcc5a409e3f`)에서 107/109 지목 2편과 career
  15편을 세 축으로 전수 판정했다. 지목 2편과 career 14편을 재작성해 KO/EN 각각
  exact changed roots는 16개이며, 비대상 object·metadata·choice count는 기준
  `921edf7e7eb04b5034bb3b788249875630619887`과 exact다.
- `arc_y5_after_goal_hyunsu_career`는 KO
  `0f813ff0292bb46f1e03cac8fbf66e79d807f88d7238a0c671a04782e32bc923`, EN
  `875b9e909f882712bf380b265c593327208599834bf339fc7d3acbe97fed2982`로 보존했고,
  `arc_y5_people_verdict_career_hyunsu`도 baseline exact다. description은 KO
  394~525자·EN 691~799자, 한영 leaf·placeholder parity exact, generalized
  code-token/backtick은 0이다.
- year5 direct/self-test 34, EN coverage, story consistency, speech register,
  random-pool hygiene와 diff 검사가 통과했고 독립 L2 후 최종 P0/P1은 0이다.
  ORDER-117은 `[~]`로 두며 Claude의 지목 2편 직접·career 15편 전수 재판정과
  사용자 최종 GO는 OPEN, R1b는 HOLD다.

## 2026-08-21 (Codex — ORDER-118 startup 마지막 해 재설계 L1/L2 후보)

- 구현 후보 `f425b812d72664c2baeeb746aa6ce0b5f6299c0f`(tree
  `4c0a659e972140660ae6d75968fcffef0c081cee`)에서 startup 16편을 고객 장애부터
  마지막 독립 저녁까지 사람·시간 중심 6결정+10다리로 다시 썼다. KO/EN은 각각
  16 roots·27 choices이며 공동창업자·팀·현재 고객 수진이 비용을 자기 행동으로 낸다.
- 마지막 해 인접 산문의 문서 코드·버전·해시 표기를 자연어로 내려 strict player
  token은 0이다. 한영 구조·placeholder·말투·서사 정합, 34개 음성 감사와 Godot
  historical kernel 266검사가 통과했고 product consumer·dispatch는 0이다.
- 독립 L2는 P0/P1 0이다. ORDER-118은 `[~]`로 두고 seed 9821의 새 16편 중 3편을
  `Claude(사용자 위임)`으로 다시 낭독한 뒤 사용자 최종 GO를 별도로 받는다. 새
  replacement contract가 없으므로 R1b·save·dispatcher·transaction·ending은 HOLD다.

## 2026-08-21 (Codex — ORDER-104~113 Claude 위임 L3 판정 기록)

- 803a372 원문에서 오더별 seed 9821 무작위 3편, 총 30편을 인물 목소리·지금
  잃는 것·다음을 기다리게 하는 여운으로 판정했다. 결과는 104/105/106/108/110/111
  합격, 107/109 조건부, 112 부분 반려, 113 전량 반려다. 기록 권위는
  `Claude(사용자 위임)`이며 사용자 최종 GO 10건은 모두 OPEN으로 남겼다.
- 합격한 6개만 `[x]`로 닫고, 조건부·부분·전량 반려 4개는 `[!]` 실패 이력으로
  보존했다. ORDER-118은 startup 16편·코드형 산문, ORDER-117은 107/109 지목 2편과
  career 15편 복구를 소유한다. 강한 현수 장면은 KO/EN exact 보존한다.
- dormant 9+9 계약은 `invalidated_by_delegated_l3`, `r1b_allowed=false`, replacement
  null로 잠갔다. pure kernel·제품 runtime·save·story map·endings는 건드리지 않았고,
  새 원고 L3와 별도 새 계약 전에는 R1b를 열지 않는다.

## 2026-08-21 (Codex — M01~M06 선택 화면 게임 장면형 재작업)

- 오래된 `BUILD 2026.08.10.1`의 빈 2×2 관리표를 제품 후보로 잘못 띄운 사실을
  확인하고 중단했다. 현행 정본 `StoryMapM1M6Playtest`도 같은 대시보드 문법이어서,
  제품·스토리·저장 경로는 건드리지 않고 선택 화면만 고시원 세계 위 어두운
  `Gangnam Ink` 장면 카드와 명시적 `주력`·`함께` 자리로 다시 만들었다.
- 19개 약속을 결과를 선취하지 않는 9개 신규 무인 이미지와 9개 안전한 기존 장소
  이미지에 연결했다. 마우스 호버와 패드 포커스는 같은 잉크선·2px 이하 들림·
  1.8% 장면 push-in·잉크막 걷힘을 쓰며, 확인은 55ms 동안 내용이 1px 눌린다.
  밝은 포스트잇·카테고리색·호버 효과음/진동은 쓰지 않는다.
- 카드 확인은 역할을 자동 배정하지 않고 해당 자리로 포커스만 옮긴다. 두 번째
  확인이 배치를 확정하고, 선택/취소에는 종이 소리와 쪽지 이동, 월 확정에는 도장
  소리가 한 번만 난다. 영문 960px 재시작 확인 문구는 좁은 버튼이 아니라 하단
  안내줄에 표시한다.
- 사용자 판정 “월 마감 지금 괜찮아”를 따라 결과·회고 레이아웃과 결과 계산은
  보존했다. KO/EN 960×600·1280×800 실렌더, 마우스·키보드/패드 의미 입력,
  여섯 달 전용 저장, 종료 자원 해제, 표적 5검사와 독립 L2는 P0/P1 0이다.
  사용자 L3 재플레이 전까지 ORDER-103은 `[~]`이고 기존 24주 이관은 시작하지 않는다.
  전체 UI 통일은 이 표면 승인 뒤 공용 토큰/장면 컴포넌트부터 단계 이관하며,
  승인된 월 마감·회고·엔딩은 마지막 별도 배치 전까지 동결한다.

## 2026-08-20 (Codex — 마지막 해 R1a 비활성 계약 커널)

- career·startup M49~M55의 18 roots·50 choices를 caller가 주입한 Dictionary만으로
  재생하는 pure `Year5ReferenceRouteKernel`을 만들었다. exact partner/M48/founding/
  route-lock ingress와 경제 경로, document role handle과 실제 scene actor, C0/C1·
  h0/h1 custody, M53 synthetic handoff, 월간 margin, continuation/terminal을 분리했다.
- 선택은 common+choice writes를 원자 적용하고 exact callback만 성공 no-op로 받는다.
  history는 매번 다시 계산하며 extra/missing receipt, 이직·퇴사, 잘못된 M52 actor,
  read-before-transfer, margin double-spend, terminal downstream, bool·float·string integer
  위조, 중복·부분·변조 row를 fail-closed한다. file I/O·autoload·GameState·SaveManager·
  EventManager·MainGame·StoryMode·돈·직업·flag·ending write는 0이다.
- manifest direct 2 routes/32 roots/86 choices와 음성 100건, Godot R1a 18/50·241건,
  story-map 차선 7/7, strict JSON·context·queue·scope·diff, 독립 L2가 모두 통과해
  P0/P1 0이다. 보호 37파일은 byte-exact, lifecycle은 `reference_only`, product consumer·
  dispatch 0, QA consumer 1이다. 메인 worktree의 기존 변경은 건드리지 않았고 전용
  `codex/story-map-240w` worktree에서 작업했다. R1b가 실제 ingress·GameState·save,
  R2가 M57~M60 transaction/finale를 별도 소유한다.

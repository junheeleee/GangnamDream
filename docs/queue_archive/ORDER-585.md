# ORDER-585 — M17 조건부 본문의 기간·수량 정합

#### [x] ORDER-585 [정합] KO/EN 5잎 source 수용 — 2026-10-13

기준 clean main64c7e35629166a60f1e0984a65ba336d7520af6e/tree
abc1c49d1550226fa114b5b6e5557cc243c193d4. 최신 사용자 지시:
Mac 잠금 동안 M17부터 월 순서로 실제 조건과 KO/EN 사실을 대조한다.
출시 언어 KO/EN/JA/zh-CN/zh-TW 유지, KO/EN 실제 플레이 확정 전 JA/zh
다듬기 중단·누락만 보충·일괄 정합은 뒤로 미룬다. 해제 시 562 실제 M17 우선이다.
CI 빨강 새 월0·열린 실제 월1·월 실제 검수 한 커밋 원칙을 보존한다.

## 사실·범위·깊이

1. `MainGame:8356–8357`은 arc_year_one_half를 W68–90에 허용한다.
   KO 제목/본문 1년 반·열여덟 달째와 EN 제목/본문 eighteen months는 허용창과
   다르다. 시간표·계약 검토의 행동은 유지하고 두 번째 해의 도시 습관으로 쓴다.
2. `MainGame:7853–7856`의 daeun_chose_her 조건부 arc_daeun_03b_date는
   KO 소주 한 잔이 EN one bottle로 늘어난다. EN만 one glass로 맞춘다.
3. 효과·플래그·선택·후속18주·라우팅·배우/장소/음악/저장은 바꾸지 않는다.
   플레이 상태·24주 결과는 그대로며, 달라지는 것은 사실의 표현뿐이다.

M17의 새 문턱 offguard W65+, date/bond W68+, year_one_half W68–90,
routine_trap W62–76의 KO/EN과 변형·결과를 읽는다. story_map의 human은 실제
W72–96이라 M17 장면으로 세지 않는다. fresh W68은 bond가 먼저 소비할 수 있고,
daeun_chose_her 현 생산자는 M22 fork다. 두 수리는 selector/구저장 조건부 원문
정합이며 fresh M17 실제 발생·모든 backlog/deferred/월 완료를 주장하지 않는다.
확정되지 않은 직업/투자 전제를 억지로 결함으로 만들지 않는다.

## 정확 소유

- root 제품: content/events/arc_midgame.json의 arc_year_one_half title/description,
  content/events_en/arc_midgame.json 같은2잎,
  content/events_en/arc_daeun.json date description의 bottle→glass. 총5잎이다.
- root 필요 지문: content/meta/release_content_inventory.json의 실제 변동
  candidate_scan 지문만, docs/CONTENT_RATING_INVENTORY.md 공식 재생성만.
- root metadata: 큐2·이 사양/마감 archive·WORK_LOG·CLAUDE 현재행만.
- manual_save_ci/mod_layer_ci: 읽기전용 조건·사실 독립 전수 검수.
- rework_batch_plan: 새 .git/order585-20261013/의 raw/보존 독립 판독만.

JA/CN/TW·번역 원장/accepted receipt는 불변이다. source 변경에 따라 생기는 stale는
공식 inventory로 드러내고 새 번역 수용·원어민 GO로 덮지 않는다. 게임 원문 확정
뒤의 일괄 정합 대상으로 남긴다. arc_events.json·M01~M06/pin·project.godot·
사용자 저장/설정·원559 seed/옛 앱/raw·human 원장은 비소유다.

## 검증·마감

선언 commit/push → KO/EN5잎만 patch → 공식3 locale inventory 전후 →
EN coverage/Hangul·서사 연속성/spine·story consistency·speech/audio·
demo scope/story demo·release inventory/report·context/queue/diff 표적 검사.
제품5잎 exact diff·다른 JSON/gameplay/CJK/원장/공개 보존을 독립 검수한다.
실패 원문과 실제 원인은 보존하고 새 실패0·독립 source GO 전 완료0이다.
새 tool/검사/등록/자체검사/엔진/native/전체audit/240주/검증비용 작업0이다.

장면 추가/격상·자산/연출 변화0, 기존 계층을 유지한 최소 사실 수리다.
gangnamdream-dev의 소유 보존·한영 정합·표적 검수와 WORK_UNIT 증거 경계를 따른다.
모든 작업 지시는 일회성/새 규범 승격0이다. 자동 계약은 재미·깊이·문체·
실제 원어민/인간/물리패드 관찰이 아니다. source GO와 본편/출시 GO를 분리한다.

## 실제 결과

KO/EN 5잎 수리·비저자 전수 source 품질 GO/blocker0이다. Mac locktrue/native0,
fresh M17 노출/월 완료/원어민/렌더/본편/출시 GO0이다. 기준 CI38338119304는
03:51:44Z in_progress/null(시작02:41:55Z), 완료 확정0·취소/재실행0이다.

- 실제 제품 변경: KO/EN year_one_half 제목을 도시 습관으로, 첫 문장을 두 번째
  해로 맞췄고 EN date one bottle→one glass. 원문3파일의 나머지 바이트·게임플레이는
  역복원 exact다. 지문 sexuality/alcohol의 content SHA2개와 생성 보고2행만 갱신했다.
- 표적13 actual0: EN2·서사 continuity/spine2·story consistency·speech/audio2·
  demo scope/story demo/JA demo/ZH demo/i18n5·release inventory/report1.
  공식 inventory 전후6 actual0는 전체 번역 완료 검사가 아니라 미완료 측정이다.
- source manifest98664e3985186e7173cfa8cde576aec6136f41f756cf185699d5020cd81177cb→
  5e73ab715659b69adbaef7a46930cfe3664e3b6b7baa91c188cdbba183a9ce47,
  정확 KO source2잎만 바뀌었다. source count17504/unsupported466은 exact다.
  JA/CN/TW event current receipt11450→11448씩, JA invalid56→57(title),
  CN/TW invalid0→1(description 2nd year vs18)이다. 기존 invalid 전부 보존,
  사전/번역 원장/accepted receipt 변경0·새 수용0이며 이는 후속 정합 빚이다.
  기본 표적검사 종료0을 다섯 언어 정합 실패0으로 쓰지 않는다.
- 독립 manual_save_ci: `.git/order585-20261013/independent-review.md`5940B/
  4d00814ad3dab5d13c901a8575c9906b1fc339206113f04e9ccc252fd37523bf.
  실제5잎/조건/생산자·CJK 잔여를 직접 읽은 dirty-source 한정 판정이다.
- 보존 rework_batch_plan: 제품5잎 span 역복원·SHA2/report2 역복원·before12·
  CJK3dir 각각128·비소유tracked3366·조건/효과/후속/ID 모두 exact, 19/19true다.
  사용자 저장은 이번 검사에서 접근/실행0이며 실제 디스크 저장 관찰로 확대하지 않는다.
  `.git/order585-20261013/preservation-review.md`10683B/
  fd81240f5a43b6a8afc188eb73940be3bab00ac717c100a7bb1b256b953b8795.
- `.git/order585-20261013/before.json`2374B/
  f648e4fd130d7bb6bafb1d14f707beaa4a567f4eb078290c017009d4342585b8;
  `validation-observation.json` SHA e3744c0a43bf0fc0f89deebbd90044dcbf5ffadc6851532b2b922322ad12ee13.
  처음 큰 before 출력 truncation/decode 거부(쓰기0), 큐 순번 FAIL/선언 전 수리,
  잘못된 help 파일명 exit2/실제 게이트 탐색, 비본문 축 candidate_scan 조회 KeyError는
  진단 그대로 보존한다. 제품 게이트 실패를 숨기거나 checker를 고친 일이 아니다.

```
도달 경로      : MainGame.gd:8356–8357 / 7853–7856; continuity actual0 t69 source-probe
생산자 ↔ 독자   : arc_daeun.json:272 ↔ MainGame.gd:7853; arc_midgame.json:2890 ↔ StoryMode.gd
바꾸는 상태     : gameplay delta0; KO/EN text5; CJK current receipt −2/locale
포기 시 잃는 것 : 신규 선택0; 기존 arc_34_two_years_in +18주 후속 exact
서사 위치       : M17 신규 문턱5 판독; 두 수리는 조건부/호환 consumer
장면 계층       : 기존 미선언 기본T3(SCENE_TIER.md §1); 격상0·전장면 계약 승인0
닫는 것         : KO/EN 기간·수량 사실2; 실제 M17/5언어 정합/출시 닫지 않음
```

일회성·승격0. Mac 잠금 중 다음 월 M18 KO/EN 읽기를 잇고, 해제 시 562 원W68
정상 실제 플레이로 복귀한다. 최신 사용자 정책은 자동화 같은 cadence에 반영했다.
공개 demo·프로젝트/저장·옛 판정·원어민/인간OPEN45·전체HOLD·종료 잔여는 보존한다.

# Active Queue Spec: ORDER-168

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-168 [P0·전체 현지화] 다은의 관계와 아버지의 통화를 세 언어로 옮긴다

**[~] 2026-09-07 Codex L1/L2 수용·L3 OPEN — 아래 정확25 ID의 JA·zh-CN·zh-TW text-only
overlay, 원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자 전체 게임 번역 지시를 구현 `1c6232e`에서 이어간다.
이전8,457 수용·비표시 메타9·공개 working baseline·배경 제품53493fe를 보존한다.

## 깊이 3문

1. **없으면 무엇이 깨지는가?** 다은과 사귀기/떠나기, 연락하기/보내지 않기,
   청혼하기/미루기와 아버지 통화가 영어로 돌아간다. 분기별 관계 단계와
   회신 여부를 원문 그대로 읽을 수 있게 한다.
2. **선택을 바꾸는가?** 효과·일정·생사·주거·관계·라우팅 변경0이다.
   원문에 있는 실제 회신은 보존하고 없는 응답을 만들지 않는다. 약혼 뒤 매물
   사진은 등기·소유 완료가 아니며 별세 대안은 사진과 빈 자리다.
3. **무엇과 경쟁하는가?** 다른 인물·생활 사건·UI·표시 소비자다. 정적 M07~M60
   closure의 마지막 비보호2종과 shipping 관계23종을 골랐다. shipping 분류는
   실제 플레이 도달성이나 해당 기간 전량 완료를 뜻하지 않는다.

## 한 배치 — 정확25 사건

- `arc_father_quiet_call`
- `arc_daeun_03b_date`
- `arc_daeun_04_morning`
- `arc_daeun_04b_future`
- `arc_daeun_05_breaking`
- `arc_daeun_05_together`
- `arc_daeun_05_uncertain`
- `arc_daeun_ghost`
- `arc_daeun_regret_draft`
- `arc_daeun_year3_together`
- `arc_daeun_year3_apart`
- `arc_daeun_year4_together`
- `arc_daeun_year4_quiet`
- `arc_daeun_year5_ending`
- `arc_daeun_year5_apart`
- `arc_daeun_first_night`
- `arc_daeun_first_night_silence`
- `arc_daeun_first_night_truth`
- `arc_daeun_first_night_decision`
- `arc_daeun_proposal`
- `arc_daeun_proposal_last_cup`
- `arc_daeun_proposal_answer`
- `arc_daeun_our_home`
- `arc_daeun_our_home_father_passed`
- `arc_daeun_families_meet`

164 leaf/15,758 KO자(공백·개행 포함), 표준164다. reader·scalar·foreshadow0,
사전형 조건12=memory3+known9이며 기존 조건 키/순서·배열·개행·토큰을 보존한다.
선택164 source aggregate
`45194fb72053be2099c57294bd6db2d3deaca3e8c004b785e29731c9321bc1fa`.
독립 collector와 ROOT 재계측이 일치하며 전부 shipping/protected=false,
builtin_overlay_static_only·세 locale target/accepted0이다.

정적 closure 소속은 `arc_father_quiet_call`과 `arc_daeun_year3_together`뿐이다.
나머지23은 shipping 원문 번역이며 별도 도달 증거를 발명하지 않는다.
첫날밤 intro/silence/truth/decision4, 청혼 intro/last_cup/answer3과
우리집 생존/별세2를 함께 옮기되 각 원문 hash·판정은 독립이다.
공개 재혁 재회8문구·author-only·결혼식 후속은 이 배치에서 제외한다.

## 정확한 소유권

각 `content/events_<ja|zh-CN|zh-TW>/`의 다음5파일에서 위25 ID만 추가한다.

- `arc_midgame.json` 1root/11 leaf
- `arc_daeun.json` 8roots/53 leaf
- `arc_daeun_extension.json` 6roots/44 leaf
- `arc_daeun_romance.json` 7roots/38 leaf
- `arc_daeun_married.json` 3roots/18 leaf

언어별 작성자1명·교차 검토 읽기 전용. 기존행 값/순서/raw prefix를 보존하고
신규행만 추가한다. KO 직접 저작, 영어 중역·간번 변환0이다.
ROOT는 `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`,
`tools/zh_translation_audit.py`, `tools/audit_scope.json`,
`content/meta/full_game_localization.json`, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·
생성STATUS·전체 현지화 backlog를 소유한다. 부팅 예산에 닿은 완료 WORK_LOG절과
legacy 큐 문단은 각각 기존 현지화 history·`queue_archive/CODEX_QUEUE_2026-09.md`에
원문 바이트로 이동 보존한다. 활성 작업·사람 gate를 완료로 바꾸지 않는다.

KO/EN·runtime·저장·routing·human_gates·catalog/endings·공개·폰트·배포는 비소유다.
새 수량·호칭 오탐은 실제 source와 정상/변조 짝으로 수리하고 독립 검토한다.
기존 baseline을 완화하거나 의미를 검사에 맞춰 훼손하지 않는다.

## 검증과 보존

- 원문 manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
  최초 source3개를 보존하고 최종 source/response/receipt3쌍을 발급한다.
- 세 언어492문구를 다른 작성자가 KO 전수 대조한다. 조건12/언어, 회신·발신·
  동의·관계·생사·매물/소유·연수·금액·수량을 점검한다.
- 원문 year3_apart의 '잘됐다'/두 글자, 청혼의4년/5년, 우리집의5년과
  year5_ending의4년 전 카페 약속은 별도 원문 확인점이다. 몰래 날짜·숫자를
  바꾸거나 사실이 없던 곳에 회신·만남을 추가하지 않는다.
- 이전8,457/meta9·공개·기존행 보존. L1 표적 차선·EN·diff·결속 검증과 독립 L2.
  L3·원어민·실제 화면 OPEN, 전체 INCOMPLETE·full/main/product HOLD·배포 데모 GO.

이 사양의 범위·증거·소유권은 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
세 용어집이 소유하며 새로운 서사·상품·출시 규칙을 만들지 않는다.

## 수용 결과 — L3·원어민·화면 OPEN

- 선언 `ce3b610` 뒤25종164×3=492문구를 KO 직접 저작·독립 전수 대조했다.
  조건12/언어, reader/scalar0. JA 원화6·한뼘1, CN 공간관계·라면2,
  TW 증가수·회수한 호칭2, 총11문구를 고쳐 재대조했다.
- 초기 source3개 보존, 최종 source/response/receipt3쌍 각164 check/import
  PASS·changed_files=0. 이전8,457/meta9를 보존해8,949문구다.
  accepted checksum `42c20d173dcee089a78c77f4717f0d39020edee691fabc14dee04b0902a82ec4`.
  최종164-record aggregate:
  - JA `b00f92d6a39ec4f452fa32c44e8e920297bd28fdd1349ac5d08d86ba13673400`
  - CN `002dda4ac7988fe97424b2cbb20e7540a699a103cf32f9f721e528b9d7a6d81d`
  - TW `d0c0106092661fd3c8c044813049f68940e1364d707386dbcfdb2af63681cfb8`
- 기존3파일39행/언어 값·순서/raw prefix와 신규2파일/언어의 text-only 구조를
  독립 확인했다. KO/EN·runtime·공개·폰트·human_gates 변경0이다. 사용자 원래
  작업트리는 이번 쓰기0이며 이전 snapshot이 없어 완전 동일 바이트를 주장하지 않는다.
- 근사 횟수·나이·반도·존칭·손뼘·1+1·실제 통화벨과 부정문/이합 동사/어순
  수량 검사 오탐을 고쳤다. 독립 검토에서 발견한8유형 신규 누출도 닫았다.
  self131 PASS, 독립117(정상24/변조93)·실본문11+변조30·문맥4를 재검증했다.
  기존 손뼘→손바닥 뒤 거리 단위의 분류기 한계1건은 별도다. 구V2 strict의25개
  기존 범위/인프라 실패와 중국어 JP-first 차단을 공개 데모 PASS로 덮지 않는다.
- 원문 연수·글자 수·첫 바깥 만남·아버지 빚 발화는 backlog의 별도 확인점이다.
  이전 JA 수용2곳의 `30億` 원화 명료화도 새 범위로 남기고 여기서 바꾸지 않았다.
- 완료166 WORK_LOG절1,518bytes SHA
  `36c7bc7d4d7496e477819b438e23df1d1fe4338fedb2587dd6be3deefbb5e198`를 이동.
  history13,326bytes SHA `525cad83ddf351f65c5bdd99cd37cbdf6e7bb4b7657c6a03667443d2dd05a1e7`.
  선언에서 옮긴 legacy 큐336bytes SHA
  `6eded99648e8541c001b0ce587c3b914c8e602e36e0c95be101dc62c95891a34`도 원문 보존이다.
- 전체 INCOMPLETE·full/main/product HOLD·출시 데모 GO 유지.
  최종12개 표적 차선·EN·diff PASS. 실제 stdout은 git-private
  `order168-final-checks.log`에 보존했다. self131·ZH935·공개14/100·UI121 PASS다.
  정적 closure의 비보호 원문191종1,743문구와 보호 재사용1종8문구를 구분하며,
  모든 무작위 사건·UI·표시 소비자·실제 플레이 완료로 해석하지 않는다.

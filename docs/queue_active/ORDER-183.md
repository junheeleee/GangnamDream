# Active Queue Spec: ORDER-183

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-183 [P0·전체 현지화] 초반 회상·생활 이정표와 사별 변형을 옮긴다

**[~] 2026-09-08 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
직전15,483번역(언어별5,161)·메타9·batch34를 착수 직전 재확인해 보존한다.
공개 working baseline·별도 배경 제품53493fe를 보존하며 전체 번역 지시를 이어간다.

## 깊이 3문

1. 아버지의 무릎·마지막 상환·첫 월급에서 관계와 돈의 무게가 같은 순서로 읽혀야 한다.
2. 과거/현재·실제 상환/통화/선물·미확인 주문과 사별 변형·도달 조건은 변경0이다.
3. 남은 본편 사건·UI와 경쟁하므로25단위 한 배치, 밖 장면/원문 수리는 추가하지 않는다.

## 배치 A — 회상·첫 생활25 roots /158 leaf /14,143 KO자

`content/events/story_events.json`의 다음25종, KO 상대순서다.
1년 반/2년/3년/4년/age35/age39 여섯 root는 다음 범위로 남긴다.

- `story_flashforward`
- `story_arrival`
- `story_knee_door`
- `story_knee_witness`
- `story_knee_choice`
- `story_last_payment_wait`
- `story_last_payment_word`
- `story_last_payment_exit`
- `story_prologue_dad`
- `story_prologue_goal`
- `story_prologue_meal`
- `story_pressure`
- `story_six_months`
- `story_one_year`
- `story_rainy_night`
- `story_compare_friend`
- `story_first_paycheck_feel`
- `story_late_night_grind`
- `story_weekend_choice`
- `story_gosiwon_neighbor`
- `story_payday_morning`
- `story_hometown_nostalgia`
- `story_first_savings_milestone`
- `story_first_paycheck_feel_father_passed`
- `story_hometown_nostalgia_father_passed`

source aggregate
`3f96f70fd4050e99b51c80e0c3d858410c2d2ad007b7f1906abbcd8f613f10c4`.
제목25+본문25+54선택/결과108=158. known/memory payload/reader/foreshadow/
밖name0, 전부 shipping·protected=false·builtin_overlay_static_only다.
father_passed root의 memory 태그는 별도 memory text leaf가 아니다.
JA는 story_prologue_goal1행8문구가 이미 있고 수용0, CN/TW target0·수용0이다.
기존 JA8은 원문 대조 후 값/raw row/relativeorder 그대로 재사용한다.
새 저작 JA150+CN158+TW158=466, 기존8 재검토와 합쳐 수용 대상474다.
선언 직전 source/target 상태와 직전 배치 교집합을 재확인한다.

M07~M60 정적 closure 교집합0이다. 선택별 직접 후속19회·중복 제거 root-pair11개는
flashforward→arrival→knee door/witness/choice→payment wait/word/exit→
dad→goal→meal→pressure의 내부 사슬이고 외부 유입/유출0이다.
runtime exact ID 참조11줄/3파일과 director demo commitment2개는 별개다.
MainGame은 turn1 프롤로그, 첫 월급·23주 이후 첫300만원·달력6/12개월을
따로 트리거한다. min_turn9999를 비도달로 읽지 않는다.
V2 fresh W1에서는 meal→pressure가 빈 후속으로 끝나고 별도 guided board로
넘어가며 legacy reserved queue만 호환 인계한다. 번역이 공개 새 도달/Send를 만들지 않는다.
27회/16종 flag write의 밖 조건 독자는 first_job_rejection·small_unexpected_win2종,
이들은 새 번역 대상이 아니다. 사별2쌍은 EventManager live variant·생사 계약을
그대로 소비하고 gosiwon 태그의 주거 필터도 그대로다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/story_events.json`의 위25행만 소유한다.
JA 기존1행8문구1,818bytes SHA
`fbd51506536f1088bfe0ba7dbff4118e15c33f4ca6d357e2cf087f8d5a14a675`
는 보존 재사용하고 새24행만 KO 상대순서로 추가한다. 기존 배열 전체 재정렬0.
CN/TW는 선언 직전 파일 존재 확인 뒤 없을 때만 새25행 파일을 만든다.
gameplay key 복사0. KO 직접 독립 저작·다른 작성자/ROOT 전수 L2.
영어 중역·간번 자동변환0, 문단·토큰·수량·인물/사실 경계 보존.

ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog를 소유한다. 관찰된 오탐만 문맥과 정상/변조 짝으로 수리한다.
필요하면 완료180 WORK_LOG절만 기존9/7 현지화 history 앞으로 원문 이동하고
해당 절·기존 history 내용·끝 개행을 byte-exact 보존한다.
KO/EN·runtime·save·routing·human_gates·다른 사건·catalog/endings·공개·폰트·
배포 비소유다. 기존JA8의 필수 의미 결함을 발견하면 덮지 말고 별도 범위 판단을 남긴다.
수용 후 같은 활성 이어보기로 옮겨도 [~]·L3 OPEN 유지.

## 원문 사실·부채 경계

- 2031년 얼굴 안 보이는 인물은 가능한 미래이지 현재 민준의 성공/소유 보증이 아니다.
  2026년1월·33세·1평반 신촌방·어제 마지막 상환과6년 전27세 겨울을 구분한다.
  평을 지역의 다다미나 다른 면적으로 치환하지 않는다.
- 구두3켤레·손바닥 폭 문틈·한 뼘 더 벌리기, 문을 열지 못했지만 넓힌 산문의
  압축은 재연출하지 않는다. 보증 서류/날인·무릎/실제 팔꿈치 잡기와 돈 부재,
  두 칸씩 계단 내려가기를 보존한다.
- 번호146→147·4번창구·잔고500,000원·두 번 대조·실제 이체/상환 확인서는
  요청/예정으로 약화하지 않는다. community_center 배경 계약은 원문 그대로다.
  call button 중복/아버지와 거짓말2개의 수는 원문 확인점이며 통화는 원격이다.
- 의사의 조언은 남은 시간을 말하지 않았다. 5년은 주인공이 정한 기한이지
  의학적 수명 보증이 아니다. 사기로 날린 사려던 집과 수첩30억/5년 동기는
  실제 새 집 계약/획득이 아니다.
- 잔고50만/월세65만/하루1만원 미만·삼각김밥1,200원 실제 구매 또는 굶기,
  보름 경과/수입0과 구인앱 열기·지원버튼 위 손을 그대로 옮긴다.
  지원 완료나 '축하해'의 새 전송/응답을 발명하지 않는다.
- 반년6장 달력/50만 시작/알람1시간 앞당김/반나절 쉼을 보존한다.
  1년12개월의 고시원/아파트는 조건문이다. 현재 집을 다른 주거로 강제하지 않는다.
- 친구 대기업 합격/웃는 답장/지원 완료 메일3통은 실제다. 이력서1장·밥1끼·
  산책30분 메모는 완료가 아니다. 야근22시→23:30 실제파일발신/막차2정거장,
  퇴근 분기 미완료파일, 새벽1시 파일 닫기를 모두 전송으로 합치지 않는다.
- 첫 월급의 부모님 상품권/실제답장과 사별 변형의 어머니/아버지 가정법은
  별개다. 저축 실제이체·운동화 실제구매/다음날은 유지하되 돌아가신 아버지를 살리지 않는다.
- 토요일9시/카페4시간 후 기운 해의 시간 압축과 실제 친구 만남은 원문대로다.
  옆방 몇 달/min_turn3은 별도 기간 확인점이며 gosiwon 주거태그 필터는 있다.
  인사/고개 끄덕임만으로 이름·친구 관계를 만들어 내지 않는다.
- 월급날25일 산문/날짜 조건 부재, 전액 저금과 고정비를 남긴 결과,
  명절 산문/월 조건 부재·귀향3인/사별 어머니만·전화/취소표 실제 이동을 구분한다.
  비주거태그 장면의 고시원 고정 산문은 새 거주 보증을 보충하지 않는다.
- 첫300만원은 300만원 이상을 pending flag로 잠가 정확히300만원이거나
  실제 표면 전 잔고가 줄 수도 있어 산문의
  현재 잔액과 차이는 별도 부채다. 계좌 이름 변경은 추가이체가 아니고,
  공격 분기의 주문금액 입력/확인 근처 손가락은 실제 주문 완료가 아니다.
  '첫 베팅' 비유로 허위 거래·수익을 보충하지 않는다.

## 검증

원문 manifest
`edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`,
KO story_events70,759bytes SHA
`25675b3ec0b92aad87f501cedfb84ee57eba380fc5e021e41ef1c5cc858b5f68`.
초기source3에서 JA8 기존값/150 null·CN/TW158 null을 저작 전 확인한다.
최종source/response/receipt3쌍·474문구 독립 KO 대조와 새466/기존8을 구분한다.
named full-game-localization-overlays --list 확인 후 실행, EN·diff·portable 전량
source/target hash 및 기존 수용/메타/공개를 검사한다. 실제 stdout은 실행 뒤 기록.
전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN,
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 범위·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·제품·출시 규칙을 만들지 않는다.

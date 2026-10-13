# ORDER-613 — 현수 재회의 M19 입구 정합

#### [x] ORDER-613 [정합] 월 배치 하한 수리·source 완료 — 2026-10-14

## 근거와 깊이 3문

612 실제 정상 플레이에서 현수 재회가 W70/M18에 소비됐다. W71 결과 뒤
기존 빈 주 자동 진행으로 W72~76을 지나 W77에 도착했다. 저장/정산은
정상이고 jump 버그가 아니다. story_map의 M19 beat root는 현수 재회다.
MainGame 하한70을 M19 첫 주73으로 정렬한다. 새 장면·월 행동판·달력
정지 장치를 만들지 않으며 기존 자동 루틴 압축을 보존한다.

1. 지키는 동작: M19의 재회가 M18에서 미리 소모되지 않는다.
2. 선택의 경쟁과 장기 차이: 기존 두 답장 경로/대면 약속/캐스트·후속을 유지한다.
3. 검증 경계: 유효 pivot은 W72까지 거부/W73부터 허용, pivot 없음은 계속 거부.
원W69 재플레이의 첫 다음월 foreground W73은 612 별도 재검수로 확인한다.

## 정확 소유

root: scenes/MainGame.gd의 hyunsu_reunion_later 하한70→73 및 해당 주석,
tools/arc_flow_sim.py의 기존 현수 temporal gate와 그 입구 반례만.
큐2/이 사양/archive·WORK_LOG·CLAUDE 현재행.
m17_native_admission: .git/order613-20261014/independent-review.md만.
다른 원문·EN·JA/zh·효과/flags/예약·저장/프로젝트·공개데모·과거인간판정 불변.
612 월별 미커밋 선언은 별도 보존하며 이 오더 선언에 섞어 커밋하지 않는다.

## 검증과 마감

선언 커밋 뒤 적용한다. arc_flow_sim·관련 story_map/서사/연속성·영어한글/
영어커버리지·context/queue/diff를 영향 범위로 검사한다. 기존 검사에 실제
월경계 동작 반례를 더하며 이력 hash 고정 검사·새 검수비용 사업을 만들지 않는다.
코드 parse/발급은 612 새 격리 후보 단계에서 정확 source로 확인하며, 실제
W73 경계 확인 전 612의 완료/출시 GO를 선언하지 않는다. 613 source 판정과
612 native 판정을 분리한다. 게임 원문/번역/저장 편집0·새 실제 월0.
일회성/승격0. 자동 계약은 재미·문체·인간 관찰을 대신하지 않는다.

## 완료 · source 범위만

제품 commit8c3078fc5e212d48590a0b22eaff8c293ce60470/
tree9aba2ab32014a72db31e0a4b72f2948ac83b2fcc.
MainGame t>=73·해당주석과 기존arc_flow의 temporal73/8입구반례만 변경했다.
기존70코드에서 새경계 반례 actual1, 수정뒤 actual0·대표2경로jam0.
story_map/consistency/graph/continuity/EN coverage/EN한글/release actual0.
continuity최종출력은 표시가 잘려 전체stdout보존 주장을 하지 않으며 exit0/OK는 관측했다.
비저자2파일/8반례 source 한정GO·root 최종보고 전문판독.
.git/order613-20261014/independent-review.md6143B/
SHA07944a0675e0681f58a4c601e88069faa46f591aff35702b75595b06f112e497.
제품8c3078의 두 Git blob에만 결속하며 미커밋612metadata가 있는 현재checkout의
전역resolverHOLD를 GO로 바꾸지 않는다.
MainGame SHAdd5d2a1bc52441a9c26209575974b437af5b4cffeeaf427364a754883d1173ad,
arc_flow SHAadc43d6ac22554e9526fb99643dbad8910808cdd6a911c333775097d5d042d16.
모든원문/번역/저장/효과/예약/project·공개·인간불변. compile/native는612재발급/
원W69→첫W73검수미완료이며 이소스마감을612경계GO로쓰지않는다.
일회성/승격0·자동계약은 재미/문체/인간관찰을 대신하지 않는다.

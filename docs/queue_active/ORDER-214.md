# Active Queue Spec: ORDER-214

> [~] 착수 — 만지는 파일: 아래 정확 소유 범위만.

#### [~] ORDER-214 [P0] 생활 선택과 부채·직장 연쇄

기준 main eb8f7aaa825491905294822c468b1f0820b9f345. 사용자 최신 전체판 번역·최종 검수 위임을 근거로 아래 사전 권고를 공식 실행 사양으로 채택한다. 사전 권고의 미선언 문구보다 이 선언이 우선한다.

## 깊이 3문

1. 원문 사실과 실제 검수 근거를 지켜 후속의 신뢰를 만든다.
2. 선택의 대가와 이전 판단의 한계를 시간이 흐른 뒤에도 보존한다.
3. 작업량이나 자동 통과를 작품 품질·관찰하지 않은 증거로 바꾸지 않는다.

## 정확 24 ID

- amb_jeonse_00
- amb_jeonse_check
- amb_jeonse_confront
- amb_hoesik_00
- amb_hoesik_drink
- amb_hoesik_dodge
- amb_coin_00
- amb_coin_warn
- amb_holiday_00
- amb_holiday_home
- amb_mlm_00
- amb_mlm_meet
- amb_health_00
- amb_mlm_aftermath
- amb_mlm_aftermath_father_passed
- amb_wallet_00
- amb_wallet_return
- amb_jobswitch_00
- amb_jobswitch_in
- amb_wallet_payoff
- amb_parent_hospital
- amb_guarantee_00
- amb_credit_steal_00
- amb_credit_confront

## 권고 판정

필수 범위 결함 0. 24종169문구를 **A 한 배치**로 선언한다.
원문6파일과24객체의 전체 지문 및169 source hash는 기존 preflight와 정확히 같다.
기존 preflight는212 수용 전 관측이므로 원장/기준제품만 현 main으로 갱신한다.
이전45입력 중 변경은 portable 한 파일뿐이며, 원문·연결/메타/런타임 입력은 그대로다.

- 일반 본문166 + `amb_guarantee_00.description_memory_if_known` 3 =169.
- 선택59, LF226, `{name}`81, 원문11,137자. 세 언어507문구.
- source aggregate: `ef6ef26d66b9173feeaf87ba9c813522ab71e3407403cbbab51324c3aaeb1e40`.
- current portable:32,484(각10,828)/b78/meta9.
  accepted SHA `d05b3933a7d9190ba9e37c2d00d74a3b0d031ef29a641b78bbef678814e35c1e`.
- 계획 완료:32,991(각10,997)/b79/meta9. 실행 전 수용으로 세지 않는다.
- 대상18파일 부재, 다른 동명/별도 locale 파일에서 선택ID 충돌0, selected accepted0.

## 정확한 저작 소유

각 언어 작성자는 `content/events_<자기 locale>/` 아래 다음6개 신규 파일만 소유한다.
locale은 `ja`, `zh-CN`, `zh-TW`이며 간체/번체 자동변환·EN 중역·타언어 복사0.

| basename | roots | leaves | choices |
|---|---:|---:|---:|
| amb_scenarios.json | 6 | 40 | 14 |
| amb_scenarios2.json | 4 | 28 | 10 |
| amb_scenarios3.json | 5 | 34 | 12 |
| amb_scenarios4.json | 4 | 28 | 10 |
| amb_scenarios5.json | 2 | 14 | 5 |
| amb_scenarios6.json | 3 | 25 | 8 |

행은 각 KO 파일 상대순서, 선택 배열은 KO 인덱스 그대로 쓴다.
허용 필드는 `id/title/description/choices[text,result_text]`와 원문에 존재하는
`description_memory_if_known` 세 키뿐이다. 기억 키/순서도 그대로 둔다:
`last_payment_endured`, `last_payment_spoke`, `last_payment_smiled`.
조건·효과·flag·태그·portrait·배경·opportunity·후속 연결은 복제하거나 수정하지 않는다.
기억 필드는 기존 collector/내장 overlay/StoryMode/검증 계약이 지원함을 소스에서 확인했다.

사별 MLM 대체는 hidden/weight0이지만 shipping 대상이다. 생존판과 합치거나
author_only로 제외하지 않는다. 내부 직접 연결10과 외부 deferred2는 번역 범위 판단 근거이며
그 자체로 새 플레이·M07~M60 도달 증거가 아니다. 외부 콜백/ending은 읽기만 한다.

## ROOT 통합 소유 권고

- portable: `content/meta/full_game_localization.json`.
- 운영: `CLAUDE.md`, `docs/WORK_LOG.md`, generated `docs/STATUS.md`,
  `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/queue_active/ORDER-214.md`,
  `docs/queue_archive/ORDER-214_L1_L2_RESULTS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`.
- 실제 오탐이 있을 때만 `tools/full_game_localization.py`,
  `tools/full_game_localization_self_test.py`, `tools/zh_translation_audit.py`를
  별도 담당에게 source-exact 표적 소유권으로 넘긴다. 필요할 때만
  `tools/audit_scope.json`의 정확한 표적 등록을 변경한다.
- KO/EN/기존 locale/공개 데모/엔딩/catalog/runtime/save/font/human/manifest는 비소유.
  213 strict historical transition 감사2도 이 번역 배치에서는 비소유다.

WORK_LOG 현재39,731B, 잔여269B다. 충분한 기록을 위해 이동이 필요하면 **선언에 먼저**
기존 완료209절 `계절·동네·취미의 한국 생활 번역` 1,300B
(SHA `832828a41c13d785a994fb6abc1f56b927c7859a34c21f93e2d6c5d5ff5cd018`)만
`docs/history/WORK_LOG_2026-09-07_localization.md` 앞에 raw exact 이동하도록 한정할 수 있다.
현 history64,946B/SHA `9a0dc936650799944ef3d9bc13f8cf4e29f9fdb6971d55b7d0d541ac28c76db6`와 끝 LF를
이동 직전에 재봉인한다. 이 선언으로 ROOT에 해당 raw 이동 소유권을 부여한다.

## 사실·후속 부채 보존선

ROOT가 직접 읽은14그룹과 기존 preflight를 공식 사양에 연결한다.
번역으로 기존 부채를 봉합하지 않는다.

- 전세: 일반 주거승급 flag를 전세계약 성립으로 확대하지 않는다.80%·보험마지노선은
  가상 원문의 주장이고 실제 현행 법률 승인서가 아니다. 이사 물색을 이사완료로 올리지 않는다.
- 코인: 대사 태호와 Hyunsu 관련 조건/효과의 차이, 전화와 표정 서술의 기존 차이를 보존.
  영상통화·현재 동석·친구에게 송금·확정수익을 발명하지 않는다.
- 회식: 현재3차, 화장실10분, 다음날 반차와 자리복귀를 구분.
  후속의 조기퇴장/회식불참으로 현재 선택을 바꾸지 않는다.
- 명절/부모: 생존 조건과 사별 대체를 나눠, 실제 수신·송금·발화·방문이 있는 곳은 유지한다.
  명절의 둘/한 그릇 원문 압축을 자의로 두 그릇으로 수정하지 않는다.
- 다단계: 월천/원문 글자수,300만원 카드빚/150만원 효과, 부모 비상금/6년 회고를 구분.
  어머니판에 현재 아버지 송금·통화를 만들지 않는다.
- 건강:119를 부르려는 단계와 실제 수액 치료를 구분. 외부 재검예약 flag 공유를 현재에 합치지 않는다.
- 지갑:30만원 주운 지갑과 별도 전무 지갑 연쇄를 섞지 않는다. 현재 명함/사례금/식사와
  후속 주말 가게일만 보존하고 회사입사·새 면접·일당60만원을 추가하지 않는다.
- 이직: 제안 연봉1.5배/조건부 옵션과 실제 사직·새 사무실을 구분.
  소스에 없는 job/salary 효과나 확정 현금화·후속 A라운드 보완을 만들지 않는다.
- 병원:부친 수술500만원은 후속의 부모빚 상환과 다르다. 거절 뒤 결과는 미정이며
  본문에서 실제 대출로 수술을 돕는 가지를 효과0이라는 이유로 지우지 않는다.
- 보증:20년 익명 고교친구, 보증 거절/실제 도장/도움 제안을 나눈다.
  c2 효과-30만원만으로 송금·합의를 추가하지 않고 기억3은 과거 창구의 회상으로 둔다.
- 직장 공로: 금융 신용으로 번역하지 않는다. 임원에게 원본 실제 송부·인지,
  부장의 동시이름 약속과 실제 향후 등재를 구분한다.
- 대부분 callback `min_turn`은 절대 하한이다. 이번 명시 deferred12주/8주 외 값을
  앞 사건 이후 지연기간으로 발명하지 않는다. 원문·후속 소비자는 전부 비수정.

## 검증 순서

1. 정확한 공식 선언 HEAD/clean과 KO6 지문, root24/leaf169, 미수용169·target18부재를 다시 봉인.
2. **원본 main의** `git --absolute-git-dir`는
   `/Users/junheelee/Documents/GitHub/GangnamDream/.git`다.
   initial은 `f.private_dir`가 가리키는 `.git/full-game-localization/<locale>/full-ko-direct-2026-09-07.1`
   에서 해석한다. 기존 WT의 `.git/worktrees/checkout2` 경로를 자동 복사하지 않는다.
3. export `--group events --ids <정확24ID 쉼표목록> --limit 169` 한 배치/locale,
   헤더 포함170행×3. previous는 JSON null이 아니라 `digest(None)` 문자열이다.
   507 null/source169/locale/manifest/batch·selection hash와 선언 HEAD를 저작 전에 검증.
   export rows의 leaf-ID 정렬과 locale파일의 KO행순서는 서로 다른 계약이다.
4. 세 작성자가 KO에서 독립 직접 저작. 전량 자체 의미대조·shape/LF/token/source/current L1,
   3파일이 아니라 자기 언어6파일 raw와169 ID-keyed records 지문을 동결.
5. 작성자가 아닌 담당의 전량169 L2. 제안된 정밀화만 ROOT 적용하고
   exact inverse raw18/나머지불변/기억3 보존 확인.
6. 자연문 오탐은 원문+타깃+typed error로 보존. 수정 전에 normal/자연변형/mutant/source-OFF 봉인.
   본문을 검출기에 맞춰 왜곡하거나 숫자값을 상수로 덮어쓰지 않는다.
7. current target hash 기준 final export3→response3→check/import --accept3.
   initial3+finalsource3+response3+receipt3=12교환파일의 결속·selfhash·target exact 확인.
   신규507만 append하고 old32,484/순서/b78/meta9/나머지 top-level 원형을 보존한다.
8. 수용전량 source/target hash·L1, named overlay lane `--list` 후 한 번,
   EN/context/queue/index/diff 및 생성 STATUS를 확인. 전체 audit/Godot/240주를 합산하지 않는다.
   자가·독립L2·자동검사·노출후회귀·사람 판정은 각자 분리한다.

원문/지침/기존 proof21 입력 전후 SHA:
`f0229395c7866021265c65ab535907cb2f60350aceb18fd62a04e776caab09be` 동일.
현재 범위는 번역 저작·텍스트 수용의 한 배치일 뿐이다. 전체 INCOMPLETE/HOLD,
원어민·화면·L3 OPEN을 자동 결과로 닫지 않으며 최신 사용자 위임의 정확한 판정 범위는
ROOT가 별도 근거로 기록한다. 이 시안의 작업 지시는 일회성이다.

# Active Queue Spec: ORDER-217

> [~] 착수 — 아래 파일 범위만. 2026-09-09 사용자 전체 번역·개발 검수 위임.

#### [~] ORDER-217 [P0] 선택의 후속과 미응답 약속 번역

기준 main a283a4e4cf3161a8d3d90c55be3dabefd5c934eb. 214/215/216은 완료했고,
그 source의 GO를 이 새 작업에 빌리지 않는다. 본편 전체 HOLD·원어민/화면 OPEN.

## 깊이 3문과 한 배치

1. 이 번역이 빠지면 이미 옮긴 선택과 뒤 회고 사이의 사건이 영어로 끊긴다.
2. 보증·보험·몸·거짓말의 이전 선택과, 이번의 실제 포기/회신을 다르게 보존한다.
3. 작업량보다 정확한 인과·문체를 택한다. 자동 PASS로 읽음·동의·만남을 만들지 않는다.

18사건을 A 한 배치로 직접 번역한다. callback12종70문구와 shadow6종44문구,
언어별114·선택39·LF304·{name}22·KO7891자, 세 언어342문구다.
한국어2파일 전체를 읽었고 표준 title/description/choices[text,result_text]만 수집한다.
known/foreshadow/Chapter5 reader0. hidden 후속3도 shipping이며 제외하지 않는다.

## 정확한 ID — 한국어 순서

```text
callback_guarantee_default
callback_guarantee_refused_news
callback_jeonse_auction_insured
callback_jeonse_auction_uninsured
callback_health_collapse
callback_lied_interview_surfaces
callback_happy_yes
callback_happy_no
callback_happy_unsure
callback_father_promise
callback_mlm_friend_escaped
callback_gambling_memory
shadow_loan_collector
shadow_loan_answer
shadow_snitch_rumor
shadow_snitch_found
shadow_old_promise
shadow_promise_again
```

source aggregate 933bbf350508e2fc1fe359b7c0cb3338ff2140d198b5e3eae1d845186ecfedd2.
KO callback_events.json 24095B/9ae2a6e344b29f34271e073cecc983a9c7f893ee0104fae748e8303762b3bf4f,
shadow_events.json 10794B/f8e298abf3034b52d2c2998440173bc1dd536908ee7e4671d80fe9250b00cea1.
기존 private/order217-preflight.json 80404B/7255ae14bd1b95f265763b1c2a6b36ec19e4c6dee46282effa609973615dbe70.
그 보고는 권고·옛 원장 snapshot이다. Rawls가 현 main에 재결속하여23입력 중
원장1의214 수용만 변경, 다른22 동일·현재23 전후 불변을 확인했다.

## 소유와 보호

- JA ROOT, zh-CN Plato, zh-TW Poincare는 자기 언어의 신규2파일만 저작한다:
  content/events_{ja,zh-CN,zh-TW}/callback_events.json 및 shadow_events.json.
  원문에서 독립 번역하고 EN 중역·간번 변환·다른 언어 복사0. 타깃6 부재·수용0 확인.
- ROOT: content/meta/full_game_localization.json, CLAUDE.md,
  docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md, docs/WORK_LOG.md,
  generated docs/STATUS.md, docs/queue_backlog/FULL_GAME_LOCALIZATION.md,
  docs/queue_active/ORDER-217.md, docs/queue_archive/ORDER-217_L1_L2_RESULTS.md,
  docs/agent_review_decisions.json의 이 작업 새 기록만, tools/audit_scope.json의 정확 등록.
- 실제 오탐이 있을 때만 tools/full_game_localization.py,
  tools/full_game_localization_self_test.py, tools/zh_translation_audit.py를
  담당별 source-exact 표적으로 나누고 정상/변조/source-OFF를 먼저 봉인한다.
- 기록 예산: 완료213절466B/fd6b9b5391e6e1085c34a4112c48fb10227937f89f1deaf4b9a40aa3df3e382c만
  docs/history/WORK_LOG_2026-09-07_localization.md 앞으로 raw 이동한다.
  기존 history67617B/db34205dbbf75fc3327debf66628674fb90514ddbb81a0f05a8f0f32985991f4와 끝 LF2 보존.
- KO/EN, 기존 locale, 공개 데모, 엔딩/catalog/UI/runtime/save/font/project.godot,
  human_gates와 역사 후보·출시 manifest는 비소유다. 부채 발견은 별도 범위로 넘긴다.

현재 portable32991/각10997/b79/meta9, accepted SHA
cef066d7685c1f2dbfe0bd57d236436c4379fb8de01a683ab3d6e54c5840e5cf.
수용 뒤 계획값33333/각11111/b80/meta9이며 미리 완료로 세지 않는다.
현재 비보호 shipping 잔여226종1649문구에서208종1535문구/언어가 남을 계산이다.
author_only105종741·공개보호2·UI/미확정 소비자는 별도다.

## 사실과 원문 부채

- 보증 청구3200만·수임료150만·감액700만·분할24개월을 합산하지 않는다.
  친구에게 준50만원은 대여가 아니다. 실제 합의/증여는 유지, 지운 문자는 미발신이다.
- 전세80%와 보험료30만·심사2달·실제 전액 반환, 무보험60%회수/40%=800만 손실,
  다른 분기의17명/1200만 손실을 나눈다. 역산한 보증금·현행 법률 보장 추가0.
  부모 식비 비교와 후속 몇만원/수억 압축 차이를 번역으로 고치지 않는다.
- 건강 부모20만과 후속의 반사실30만 불일치 보존. 정밀검사120만과 자의퇴원 구분.
- 면접6년 사업준비는 거짓, 실제는 부친 빚 상환. 고백 뒤 발표 유예 제안과
  다른 선택의 일주일/새벽3시 공부·실제 발표 통과는 다르다.
- 행복 부모min_turn200/후속144는 flag 연결이며144주 실제 노출 증거가 아니다.
- 아버지 생존 원격전화·실제 응답을 유지하고 동석·부활·입주/방문 완료를 만들지 않는다.
- MLM 빚1,400은 문맥상1400만원, 식사14,000원은 동창이 계산했다.
  두 국밥/소주1병·실제 만남 가지와 날짜 미정 답장을 구분한다.
- 경마 부모 복승/쌍승·효과9만/산문90만 부채를 보존. 후속18배·5만→90만/2분
  회상과 현재5경주/15만 손실·4호선을 섞지 않는다.
- 수금전화의 주장은 채무/본인 서명의 확정이 아니다. 실제 만남20만·후속30만
  지급은 유지하되 후속 회고의 대출권유 표현에 원문을 맞추지 않는다.
- 소문 추적 전 출처를 확정하지 않고2주뒤 면접/합격 연락 부재를 유지한다.
- 창업은 자기 발신·준비비50만/30만 별도 보관·한장 초안까지만이다.
  7주뒤 자기 달력 마감은 상대의 기다림/읽음/답장/동의/송금/공동창업이 아니다.
- 내부 deferred는4/5/7주. min_turn 일반 절대하한을 사건 이후 지연기간으로 바꾸지 않는다.
  외부 부모9·후속독자13은 읽기 전용 문맥이며 이 번역만으로 새 도달/실플레이를 주장0.

## 검수·수용·완료

1. 선언 clean HEAD에서 KO2/source114/타깃6부재·미수용을 봉인하고 initial export3.
   원본 main의 .git/full-game-localization/<locale>/full-ko-direct-2026-09-07.1을 쓴다.
2. 각 저자는114 전량 자체 대조·L1/shape/LF/token 후 자기2파일·records를 동결한다.
3. 저자와 다른 담당이 한국어와114문구 전량 대조. ROOT는 제안된 변경만 적용하고
   원형 역치환과 미변경 문구를 확인한다. 오탐 때문에 산문/원문을 왜곡하지 않는다.
4. 실제 새 제품 commit의 current target 기준 final export→response→check/import --accept.
   initial/finalsource/response/receipt12개와 신규342를 결속하고 old32991/순서/b79/meta9
   raw를 보존한다. 신규만 역제거하면 옛 portable가 byte-exact여야 한다.
5. 전량 source/target hash·L1, named overlay lane --list 후 한 번, EN/context/queue/index/
   diff/generated STATUS와 실제 독립 증거를 확인한다. 이유 없이 전체감사/Godot/240주 반복0.
6. 독립 최종 검수 뒤 source exact 작업 GO만 agent 원장에 기록하고 원문 사양을 보존해
   archive로 닫는다. 실제 원어민·렌더·인간/물리 관찰과 본편 전체 판정은 별개다.

지속 규칙은 I18N_INFRASTRUCTURE·세 용어집 및 WORK_UNIT에 이미 있다.
이번 수량·파일 소유·절차는 일회성이다. 자동 게이트는 도달성과 계약 증거이지 재미·문체의 증거가 아니다.

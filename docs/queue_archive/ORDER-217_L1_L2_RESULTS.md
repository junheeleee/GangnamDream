# ORDER-217 — 선택의 후속·미응답 약속 번역 검토

> [x] 완료 — 독립 전수 검토·수용·최종 차선 뒤 작업 범위 GO. 본편 전체 HOLD.
> 본편 전체 HOLD·원어민/화면 미관찰. 사람 판정 기록은 변경하지 않는다.

## 원문과 저작

KO callback12종70문구 + shadow6종44문구를 세 언어로 직접 옮겼다.
18종114문구·39선택·LF304·{name}22/언어이며 신규 후보342문구다.
KO2 전체와 부모9·후속 독자13을 직접 읽었다. EN 중역·간번 변환0,
gameplay/effects/flag/조건·한국어·영어 원문 변경0이다.

최초 export는 clean d45672552965c223a483656fc8ce2b9242bad92e에서 실행했다.
세 파일 각각115행/114문구, target6 부재와 previous=digest(null), ID18·LF·token을
저작 전에 확인했다. source aggregate는933bbf350508e2fc1fe359b7c0cb3338ff2140d198b5e3eae1d845186ecfedd2,
현재 collector manifest는8cf471d2c6b3b900371e47f9c0bc5f1dcaf8a116f7bcfe740ff7e682c3243a91이다.
선언 뒤 추가된218은 별도 CI 검사 수리이며 KO source114에는 변화가 없다.

| 최초 source JSONL | bytes | SHA256 |
|---|---:|---|
| ja | 94455 | 538f4689fe68c5d2eef4264d63c877af5bfa4643cd770221ba59f2890b7f36ee |
| zh-CN | 95142 | 1a2acdd3c074733adb28b1629d733add3ceaecfd328c0eab0849061af171db1a |
| zh-TW | 95142 | 11e944859134ae130e00d9729d62a19999eb28734ed23029fc810b30962c88c0 |

## 독립 전수 대조와 정밀화

JA ROOT 저작→Plato114 전수, CN Plato 저작→ROOT114 전수,
TW Poincare 저작→ROOT114 전수. 각 검수자는 원문과 산출물을 직접 읽었다.
필수 지적0, 선택 정밀화9를 ROOT가 반영했다. 저자의 자가 정밀화와 중복하지 않는다.

- JA3: 수임료를 착수금으로 좁히지 않음, 동창의 한 잔 사겠다는 약속 명시,
  모르는 발신자를 잘못 걸려 온 전화라고 확정하지 않음.
- CN3: 자연스런 시간 경과, 강남과 무관한 돌봄 약속, 통화의4주 뒤 재연락 명시.
- TW3: 자연스런 시간 경과, 일주일 동안 매일 새벽3시까지 공부, 돌봄 약속 명시.

변경9를 역치환하면 저자 동결6파일의 바이트가 정확히 복원된다.
나머지333문구·source114·선택39·LF304·이름22/언어는 그대로다.

보증 청구/수임료/감액/분할, 보험 회수율/손실/보험료를 합산하지 않았다.
MLM 빚1,400만원과 동창이 계산한14,000원 식사, 경마의 과거90만원과 현재15만원
손실을 구별했다. 원문의 실제 통화·만남·지급이 있는 선택은 그대로 유지했다.
서명의 필체 유사성이 채무나 서명의 진위를 확정하지 않는다. 아버지는 살아 있는
원격 통화 상대이고, 돌봄 약속이 실제 이사나 동석이 되지 않는다.
창업은 본인이 보낸 제안·준비비 별도 보관·자기 달력의7주 마감뿐이며,
상대의 읽음·답장·동의·약속·공동창업 성립은 추가하지 않았다.

원문의 별도 부채(건강 부모20만/후속 반사실30만, 경마 부모복승/쌍승·효과9만/
산문90만, 행복 부모200/후속144 flag 하한, 수금 뒤 독자의 대출권유 압축)는
번역으로 몰래 수리하지 않았다. 이번 번역이 새 도달이나 실제240주 플레이 증거는 아니다.

## 최초 검사 결과와 오탐 수리

자가 동결 L1은 JA105/114 clean·9문구10진단, CN105/114·9문구13진단,
TW104/114·10문구14진단이다. CN의 은행 계좌 용어1 수리 전104/114·14진단도
자가 기록에 남아 있다. 정상 산문을 검사 통과용으로 왜곡하지 않았다.

JA는 complete KO10문맥의 줄별 금액·사람수·개월·경주·시간·기한 역할을 검사한다.
자가110(실제10/자연10/변조70/source-OFF20)을 코드 전에 봉인했다.
ROOT 독립4쌍 첫 실행은7/8로, 정상 구어체 残ってる가 오탐이었다.
이 실패를 보존하고 노출 후 정상2/변조6/OFF2를 추가 봉인해 술어만 수리했다.
같은4쌍 재검증은8/8이다. 재검증을 새 블라인드 독립 표본으로 세지 않는다.
source-OFF는 helper 비적용 증거이며 전체 L1의 거부와 같은 뜻이 아니다.

ZH는 complete KO11문맥의 실제22/자연22/변조96/source-OFF44를 코드 전에
봉인했다. 최초 정상3/22·자연5/22 clean, 변조85/96 오류는 수리 전 관측일 뿐
변별 통과가 아니다. ROOT 별도6쌍은 코드 전 봉인했고 첫 실행10/12였다.
시간 경과와 한 명씩 묻는 정상 표현2건의 오탐을 보존한 뒤, 노출된 정상2/
변조8/OFF4를 추가 봉인했다. source-exact 두 표현만 수리해 같은6쌍12/12,
자가184·추가14 각각 통과했다. 공개 재검을 새 블라인드 표본으로 세지 않는다.
JA114와 ZH228 최종 문구의 표적 L1 진단은0이다. 전체 차선 검사는 별도다.

## 증거와 완료 경계

원본 저장소의 git-private full-game-localization 디렉터리에 다음을 보존했다.
이는 기계 교환/에이전트 검수 증거이며 실제 원어민·화면·인간 플레이 증거가 아니다.

- order217-{ja,cn,tw}-author-freeze.json: 저자 동결114씩, 최초 진단·파일 지문.
- order217-ja-independent-l2.json: Plato 전수114·필수0/선택3·입력11 전후 불변.
- order217-root-{ja,zh}-l2-integration.json: 정밀화9·raw6 역치환·나머지333 불변.
- order217-root-ja-independent-{probes,first,recheck}.json: 독립4쌍과7/8→8/8.
- order217-zh-own-{fixtures,baseline}.json: ZH 코드 전184 입력과 최초 관측.
- order217-root-zh-independent-probes.json: ROOT 별도6쌍, 완성 검사 실행 전 봉인.
- order217-work-log-raw-move.json: 완료213절466B만 이동, 옛 history와 끝LF2 raw 복원.

## 최종 수용

clean C1 27baec9718ca62d498df2c1bd8481f4ed1bbca71,
tree02099810e362046a853a9cd35e6854677ef77357에서 final export→response→
check/import --accept를 각 언어에 실행했다. 114씩 통과했고 changed_files=0이다.
initial3/final3/response3/receipt3의 교환12 지문과 순서를 private
order217-root-portable-acceptance.json에 보존했다. 현재 collector8cf471…은
처음과 같고 역사 원장의 source_revision/manifest는 덮지 않았다.

ROOT가 동일 C1의 기존32,991+신규342 전량을 실제 hash/L1 대조했다.
오류0, 입력503개 전후 동일, 57.69초다. order217-root-full-accepted-l1.json에
실제 입력 지문·신규342 영수증·범위를 보존했다.
수용은33,333(각11,111)/b80/meta9, 사건1,486종10,043문구/locale다.
비보호 shipping 잔여는 실제208종1,535문구/locale다. UI 등 별도 잔여를 지우지 않았다.

portable:8,639,778B/34740a735bed834100fe4781b759ed468d0cfdf527fec8253b4ff870eff92193.
accepted SHA468d1ecdf539b7b075d911c0a24f223d170ff705f03975cd3f0e8c5e1c175237.
신규342+b80만 역제거하고 accepted SHA를 복원하면 옛8,552,044B/
32283da99eaa76b409da6dba65fc158eeea4bcafdd4f6cc3c229512163c9aaa5와 byte-exact다.
기존 순서·메타9·역사 header·공개 데모·human 원장을 보존했다.
최종 차선과 독립 종료 검수의 완료 근거·판정은 아래에 분리한다.
선언·소유·배치·회귀 절차는 일회성이며 지속 규칙은 기존 I18N 정본을 따른다.

## 최종 차선과 독립 종료 검수

최종 명시 차선은 clean19b1933f8a7c8a8d09879e203a0d36a55960537c에서
--list 후1회 실행했다.12항목/11고유 모두 exit0: full-body52, 전체번역233,
JA69, ZH11787, demo4와 실제5언어 구조, EN coverage, audit ERROR0/WARNING0,
scope140, context/queue가 통과했다. audit.py 중복과218의 공통 검사를
서로 다른 독립 품질 표본으로 합산하지 않는다. ZH self의 font-route blocked
출력은 차단 반례의 기대 결과이며 현재 제품 렌더 관찰로 쓰지 않는다.
private order217-final-named-lane.json:5081B/
5ba661aa8820d088c179b378328be5fa08c335e84c2e8f3b9671e6dd71f0b90a.

Plato가 교환12·신규342·영수증·원장을 별도로 결속했다.5개 raw 영역만
역제거해 C1의 옛 원장과 byte-exact이고 기존 순서·메타9·역사 header는 같다.
C1→수용 C2→STATUS wrapper의 KO2/target6/guard3와 collector 입력은 불변이다.
입력24 전후 동일, 필수 지적0. 원문/전체 L1을 다시 실행하지 않았다.
private order217-independent-final-receipts.json:18884B/
ec4c02eefaa03ec4984ca94b3141ac6052553216fca03b7c13da5e075c8741c3.
의도된 portable 반영과 완료 문서2개의 변경을 뒤늦게 관측한 검사 가정 수정은
private phase_observations에 남겨 제품 결함과 구별했다.

최종 작업 판정 source6bc268859d9854e78c55bd4ffb5360ba657f567e,
tree9c729fba6a0ef7df6567a51a656fc61b3242706e. 실제 검사는 위19b1933이고
C2와 차이는 STATUS뿐이다. 번역 수용·표적 도구·독립 검수 범위 **GO**.
본편 전체 HOLD, 실제 원어민·화면·인간/물리 관찰·외부 출고는 미판정이다.
앞선 작업의 GO나 자동 검사를 인간 관찰로 합산하지 않았다.

## 선언 사양 원문 — 아래 상태는 착수 시점의 역사

활성 사양 원형을 보관했다. 위 완료 판정이 현재 상태이며, 아래 소유·절차는
이 작업의 일회성 지시이지 다른 작업의 권한이 아니다.

````markdown
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
````

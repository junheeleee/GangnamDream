# Active Queue Spec: ORDER-129

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-129 [P0·종막 밀도] M59~M60을 9·10·9비트로 개작하고 마지막 서명을 엔딩 첫 후일담에서 회수한다

**사용자 승인·착수 선언 (2026-08-25):** 사용자는 처음부터 끝까지 이야기와
게임성이 빽빽하고, 엔딩으로 갈수록 더 치밀하고 격동적이어야 하며 중요한
장면은 1~2비트가 아니라 최대 10비트까지 가야 한다고 지시했다. 33세·1장의
30억 즉시 엔딩은 이스터에그로 보존한다. ORDER-128 exact full audit가 GREEN인
기준선 위에서 종막 원고와 마지막 선택 회수만 별도 변경한다.

**[~] 착수 — 만지는 파일:** `content/events/arc_pre_ending.json`,
`content/events_en/arc_pre_ending.json`, `content/events/arc_drama.json`,
`content/events_en/arc_drama.json`, `systems/EndingSystem.gd`,
`scenes/MainGame.gd`, `tools/EndingRouteIdentityCheck.gd`,
`tools/ControllerSemanticCheck.gd`, `tools/ending_distinctness_audit.py`,
`tools/peak_scene_chain_audit.py`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`,
`content/meta/year5_reference_routes.json`, `tools/year5_reference_route_audit.py`,
`tools/audit_scope.json`, `docs/ENDING_CONTRACT.md`, `docs/CODEX_QUEUE.md`,
이 사양, `docs/queue_archive/CODEX_QUEUE_2026-08.md`, `CLAUDE.md`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`.

## 깊이 3문

1. 왜 장면을 길게만 쓰지 않는가? 문단 수가 아니라 장소·물건·숫자·사람·행동이
   차례로 의미를 바꾸는 9·10·9비트여야 종막이 실제로 상승한다.
2. 왜 마지막 서명을 엔딩 설명 조건에 넣지 않는가? 기존 첫-true
   `description_if_known`를 덮으면 고유 엔딩 본문이 사라진다. 독립 첫 후일담
   카드로 두 층을 모두 보존한다.
3. 왜 모든 35개 엔딩에 붙이지 않는가? 실패 귀결과 33세 비밀 엔딩은 M60 서명을
   거치지 않으며, 인수·재혼·보호자·창작·정치 특수 엔딩도 현재 M60 소유가 아니다.
   경험하지 않은 선택을 회고시키면 거짓이다.

## 배치 A — M59~M60 한영 9·10·9 의미 전환 18단위

1. `arc_pre_ending_summit.description`을 부동산 사무실→25억대 매물→현재 자산
   25억+→30억 목표→부대비용→계약·열쇠 부재→문턱→아버지/걷기→결정의 9비트로 쓴다.
2. 정석 변형도 같은 9비트를 지키고 4·7비트만 정석 경로의 실제 비용으로 바꾼다.
3. 비정석 변형도 같은 9비트를 지키고 4·7비트만 변동·운·위험 비용으로 바꾼다.
4. 아버지 선택 결과는 연락처를 연 사실까지만 확정하고 통화·답장·화해를 만들지 않는다.
5. 걷기 선택 결과는 한 블록의 몸과 문턱을 보여 주되 매입·등기·열쇠를 만들지 않는다.
6. 위 다섯 표면의 영어판은 같은 비트·사실·placeholder를 가진다.
7. `arc_final_countdown.description`을 같은 방→50만원/30억 수첩→현재 결과→실제
   기록→돈/사람 시간→비공식 빈 줄→세 서명 의미→한 선택의 포기→펜→결정의 10비트로 쓴다.
8. Black 변형도 같은 10비트를 지키고 이름을 비용화한 대가만 더 어둡게 읽는다.
9. White 변형도 같은 10비트를 지키고 도움을 지우지 않는 책임만 더 밝게 읽는다.
10. 자기 이름 결과는 책임을 맡지만 빚·관계가 자동 해결되지 않는 4비트다.
11. 담보 결과는 실제 이름만 비용·가치 열에 옮기고 목소리가 밀려나는 4비트다.
12. 사람들 결과는 실제 기록의 이름만 옮기며 동행·복귀를 증명하지 않는 4비트다.
13. 위 여섯 표면의 영어판은 같은 비트·사실·placeholder를 가진다.
14. `arc_final_week.description`을 몇 분 뒤 같은 밤→수첩 닫기→실제 대화→관계
   불확정→답장 부재→세 발신 행동→강제 불가→커서/충전선→먼저 보내기의 9비트로 쓴다.
15. 세 `final_signature_*` 변형은 같은 9비트에서 2비트만 직전 서명에 맞게 바꾼다.
16. 식사 제안·사과·거리와 다음 연락 결과는 발신만 확정하는 각 4비트다.
17. 위 일곱 표면의 영어판은 같은 비트·사실·placeholder를 가진다.
18. 제목·선택문·effects·flags·follow-up·CG·조건·다른 기억 변형은 그대로 보존한다.

## 배치 B — 마지막 서명 독립 후일담·회귀 15단위

1. `EndingSystem`에 ending ID와 flags만 받는 순수 서명 후일담 resolver를 둔다.
2. `final_signature_owned/collateral/people` 중 정확히 하나만 참일 때만 반환한다.
3. 0개·2개 이상·알 수 없는 서명·비 Dictionary 입력은 빈 결과를 반환한다.
4. 적용 대상은 M60을 소유한 정규 엔딩 24개로 exact whitelist한다.
5. 실패 5개, `instant_legend`, M60 비소유 특수 5개에는 빈 결과를 반환한다.
6. 세 후일담은 KO/EN 대응 문장과 안정적인 `kind`를 가진다.
7. 사람들 페이지 제목 직후, 기존 인물 grid보다 앞에 후일담 카드 하나를 넣는다.
8. 카드에는 `ending_signature_coda=<kind>` 메타만 두고 내부 flag 이름은 노출하지 않는다.
9. 기존 `description_if_known` 첫-true 해석과 엔딩 본문은 그대로 둔다.
10. 35×3 전수에서 적용 72·제외 33, 누락·중복·입력 변형 0을 실행 검사한다.
11. 결과 화면에서 후일담 카드가 정확히 첫 카드이고 기존 인물 grid가 뒤에 남는지 실행 검사한다.
12. 엔딩 JSON에 `final_signature_*` 조건을 추가하지 않았음을 정적 검사한다.
13. 종막 9·10·9와 결과 4비트, 허위 계약·답장·화해 문구 부재를 한영 mutation gate로 고정한다.
14. 승인된 제품 변경 뒤 Chapter 1 source snapshot과 dormant Year5 보호 baseline만 exact 재결합한다.
15. 표적 검사·영향 selector·전체 감사·66 script compile·diff가 모두 통과한다.

## 완료 증거

- KO/EN 세 장면의 기본 비트가 정확히 `9/10/9`, 모든 선언 변형이 같은 수를
  가지며 선택 결과는 각 4비트다.
- 25억대 매물과 25억+ 자산을 30억 도달·매입·등기·열쇠로 오인시키는 문장이 0이다.
- 마지막 메시지는 발신만 남기고 상대 답장·만남·용서·화해를 확정하지 않는다.
- 엔딩 35 ID·CG와 15 route, `description_if_known` 첫-true, effects·flags·저장·
  밸런스는 불변이다.
- 서명 coda는 적용 24개×3=72개만 반환하고 제외 11개×3=33개와 잘못된 입력은
  모두 빈 결과다. 실제 사람들 페이지 첫 카드 순서가 실행 검사로 증명된다.
- exact clean 전체 감사가 failure flag 0과 `✅ 감사 통과`로 끝난다.

## 다음 경계

이 오더는 종막의 인터페이스와 마지막 선택 회수만 소유한다. Chapter 4의
M39·M41·M42·M45·M46 인과축, 아버지 시간선 모순, M49~M58 계약 상승곡선과
민서·미등장 인물의 전면 후일담은 다음 작은 오더가 차례로 소유한다.
자동 GREEN은 종막 사람 플레이 GO가 아니다.

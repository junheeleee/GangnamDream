# 칭호 보너스 안내·언어 전환 버튼 현지화

#### [~] ORDER-256 다음 시작 보너스·상단 칭호 버튼

[~] 착수 — 2026-09-13, Codex. ROOT가 선언 커밋을 만든 뒤 사적 병렬 저작과
독립 검토를 시작한다. 제품 적용·Git·검사·공식 수용은 ROOT가 직렬 수행한다.
255의 독립 단위 GO·원문 보관 뒤 이어지는 별도 선언이다. 새 실제 검사는 아직0이다.

## 하나의 표시 계약

칭호 도감의 실제 보너스 7키와 상단 버튼 1키, 정확히 8키를 JA·zh-CN·zh-TW로
검토하고 공식 수용한다. 동시에 같은 상단 버튼이 언어 변경 후 예전 언어를
유지하는 결함을 수리한다. 현재 수용 기준선은 38,944/b104/meta9,
JA12,980·CN/TW각12,982다. 이 8키의 정확한 24 leaf는 아직 공식 수용0이다.

| KO 원문 | EN 호환 표면 |
|---|---|
| 투자감각 | Invest Skill |
| 지력 | Intelligence |
| 사교력 | Social |
| 운 | Luck |
| 정신력 | Mental |
| 자금 +%s | Money +%s |
| 다음 시작 보너스: (뒤 ASCII 공백2) | Next Start Bonus: (뒤 ASCII 공백2) |
| 칭호 | Title |

JA8은 기존값의 KO 직접 재검토이며, CN/TW 각8은 새 저작이다. 공유 caller의 뜻도
검토하고 UI 값의 존재와 공식 수용을 구분한다. money 분기에서 실제로 쓰지 않는
standalone ‘자금’은 제외하되 기존 계산/값을 삭제하지 않는다. 별도 GameState
현재 인물 칭호 ‘엘리트 코스’의 JA 오타는 다른 소비자이며 이번에 섞지 않는다.

깊이 3문: 제거하면 CN/TW 보너스의 EN fallback과 같은 버튼의 언어 잔류가 남는다.
24주·5년의 상태·획득·보너스 양은 바뀌지 않는다. 나머지 UI와 경쟁하지만 완성된
50칭호 name/desc 다음의 하나의 안내/접근 계약만 닫는다. 전체 UI·본편 GO는 아니다.

## 소유권 — 제품·검사·수용 최대11경로

1. scenes/MainGame.gd — 기존 칭호 lookup을 pure label 함수로 추출, 생성·refresh 공유.
2. tools/main_game_locale_history.py — 새 Main exact raw 전단과 기존 API 위임만.
3. tools/ci_localization_reconciliation_self_test.py — 새 고정 source 대조와 옛28 보존 wrapper.
4. tools/meta_title_locale_successor_self_test.py — 변경된 helper/CI self의 원형 보존 outer wrapper.
5. tools/MetaTitleLocaleCheck.tscn — 새 bonus/top 실제 소비자, 기존520 원형 계약 보존.
6. tools/run_meta_title_locale_qa.sh — 새 스트림만, 기존 격리·로그·프로세스·디스크 계약 보존.
7. locale/ui_ja.json — 선택8의 검토 필수 수리만; 전부 유지 판정이면 실제 diff0.
8. locale/ui_zh-CN.json — 승인8만.
9. locale/ui_zh-TW.json — 승인8만.
10. tools/audit_scope.json — 위 소유·영향 검사 차선.
11. content/meta/full_game_localization.json — 공식24와 batch만; 이전 전량 raw 역복원.

운영 문서는 CLAUDE, CODEX_QUEUE·L3_PENDING, 본 active/archive, WORK_LOG,
STATUS, 부모 backlog, agent_review_decisions와 agent_reviews/ORDER-256.json에 한정한다.
소스·언어·runtime 저자는 서로 다른 사적 파일을 쓰고 ROOT만 제품에 직렬 적용한다.

MP·GS·LM·JA pipeline·meta successor·Chapter/Year5 checker·audit.sh·기존244self,
사건/엔딩·assets·project·인간 원장·공개 데모·조건·보너스 계산·저장 ID는 원형 보존한다.
JA8 외 기존 UI와 기존38,944수용값을 건드리지 않는다. 새 owner가 필요하면 먼저 재선언한다.

## 구현과 역사 검사 경계

MainGame의 _title_collection_button_text() 한 lookup을 생성과 언어 refresh가 공유한다.
새 lookup을 캐시하거나 버튼을 다시 만들지 않는다. 기존 pressed 연결·object identity·
크기·색·폰트·DEMO_CORE_LOOP_V2 가시성 정책을 유지한다. bonus 계산은 변경0이다.
literal occurrence와 JA 통계 유지가 코드 독해 예측이며, ROOT 최초 collector로 실제
owner 이동·count·unsupported를 확인한다. 예측과 다르면 기대를 고치기 전에 범위를 판단한다.

새 Main 전단은 exact 실제 raw·경로·unique inverse를 먼저 검사하고 9029 원형으로만
역복원한 뒤 기존 240→239→220 API에 위임한다. 옛 raw를 대체 현재로 허용하지 않는다.
기존 함수·registry·hash는 변경하지 않고 append와 명시적 entry hook만 쓴다.
wrong claim은 raw source 유효성과 별개이며 원 claim을 유지한다. OFF/잘못된 raw는
identity·원 진단을 유지하고 위조 projector/hash만으로 양쪽 live gate를 우회하지 못한다.

CI self의 옛28과 meta self의 현26·역사18/23/19/24/18은 원래 ID/기대/입력 핀을
보존한다. 새 raw와 old 논리 view를 별도로 출력하고 새 normal 성공 뒤에만 역사 entry를
호출한다. 세 사적 logical raw는 검증한 exact inverse만 제공한다. 모든 임시 API/read/
출력 변경은 성공·예외 모두 복구한다. 물리 핀과 역사 핀을 같은 관측으로 세지 않는다.

## 고정·실행·검토 순서

비저자가 실제 소스 원인별 기대를 먼저 봉인한다. 정상 Main/양쪽 live entry, rollback,
생성/refresh 누락, KO/EN/owner·literal 중복, LF/CRLF·비표시 변조, resealed wrong/
missing/duplicate inverse, wrong claim·forged hash·OFF를 다루되 목표 개수를 채우지 않는다.
첫 baseline은 이전 제품에서 같은 입력을 관찰한다. 새 정상 base가 둘 다 성공해야
부정 대조를 유효하게 센다. 첫 실패·raw streams·예외·전후핀은 삭제하거나 덮지 않는다.

runtime 모집단은 독립 source oracle를 먼저 고정한다. 실제 도감의 빈/unknown-only
보너스 없음, mixed/capped 보너스, 다섯 언어의 같은 Button 언어 변경·복귀를 관찰한다.
PERK_RULES와 fixed ordered title IDs로 stat5/money 값을 사전 계산하며, 실제 getter를 expected로
복사하지 않는다. 순서는 unlocked_titles의 ID 순서→category 최초 삽입→stat 최초 삽입이며
같은 stat의 추가 기여는 그 위치를 바꾸지 않는다. PERK_RULES 선언순으로 sort하지 않는다.
mental8/money400,000원은 범주 cap 합의 이론상 상한이며, 현재 서로 다른 실제 title IDs로
구성하는 관측 최댓값과 구분한다. 투자/직업은 실제 서로 다른 ID4개로 cap4에 닿고
관계는 ID3개로 social3이다. 중복 ID를 정상 over-cap 증거로 만들지 않는다.
현재 정상 규칙은 양수이므로 빈/unknown-only의 {}와 명시적 0항목 생략은 다른 경계다.
후자의 실행 증거를 만들려고 규칙/getter를 mock하지 않고 기존 코드 보존으로 기록한다.
housing/story mental 및 meta/minigame money 합산·범주별 cap·순서·
0생략·%s/%+d·구분자·뒤 공백2·기존 통화 format을 유지한다. 버튼 테스트는 실제
language_changed→_refresh_all 소비자이며 재생성으로 잔류 결함을 숨기지 않는다.

기존520은 그대로 유지하고 신규 의미 모집단을 분리한다. 새 visible bonus가 옛 aggregate
라벨 출력에 영향을 주면 현재 값을 먼저 독립 검증한 뒤 필요한 copy-only 호환 뷰만 추가한다.
기존 기대를 덮거나 모집단을 줄이지 않는다. full state·hash형·타입 증거·중복 출력·조건
nested는 분리하고, 메모리 복구를 사용자 저장이나 launch disk 원상 복구로 말하지 않는다.

ROOT의 첫 current collector/source post 및 격리 runtime → 공식8×3 export/check/import
→ old38,944 raw 역복원·신규24 → clean source 전체 수용 L1·고유 영향 검사 → 비저자
최종 WORK_UNIT 판정 순서다. 성공한 runtime은 실제 입력 핀이 그대로일 때만 최종 source에
재사용한다. 로컬 full audit·240주·사용자 저장·원격 재실행은 하지 않는다.

원어민·렌더·물리패드·정상 속도 실플레이는 미관찰이다. 공개 GO1·인간 OPEN45·본편 HOLD와
기존 역사 판정을 보존한다. 이 작업은 기존 현지화·저장·사실 계약의 일회성 적용이며 새 규범0이다.

## 적용 진행 — 첫 current 실행 전

독립24 필수0 뒤 CN/TW각8을 적용하고 JA8 원형을 유지했다. clean e330의 첫baseline20은
새API 부재/effective0 관측이다. source4 B1 정적 지적2를 B2에서 고쳐 비저자 f0f4 필수0 뒤
실제로 적용했다. CI old10/meta56 함수·whole4 역복원과 고정20을 보존한다. meta의 frozen
current_exact 재사용 선행1/all8은 신규20 중복이 아니다. CI codeview52ae와 실제fullraw ddd679를
구분한다. 첫post20/old28·실제545·공식24·최종독립은 아직 전이며 본편HOLD를 유지한다.

## 첫 current 코드·언어 검사

clean2b94c68에서 첫post20/유효음성17·old28 PASS(5c111590), 독립25d2d47b 필수0이다.
24 L1(1b2191fd)와 보충 actual owner1호출(dfe325d0), preflight3×8(5a3b7ea0)이 통과했다.
meta 정상선행/역사chain·실제545·공식24는 아직 전이다. 런타임 cold-cache 의심은
custom-name의 전 언어 순회로 반증됐으며 B1 실제실패가 아니다. 초기 검토와 정정1f02f4bc를
보존하고 따뜻한 cache 전제를 관측하는 최소 보강만 한다. 공식38944/b104·본편HOLD 유지.

## 첫 실제 소비자·공식 수용

clean f10a92a/tree5764fe34의 actual545 PASS(기존520+새25), 200.083535583초다.
capture bf5e57c1/runner3c82ce27, 외부1194·내부19 불변이며 새primary65/settings35와
초기/각전환전 cache warm을 확인했다. B2는49164e80 독립검토 뒤 readiness만true로 적용했다.
같은clean에서 공식8×3 export/check/import 첫PASS·changed_files0 뒤24를 portable에 더했다.
현재38968/b105/meta9, 이전38944 whole raw inverse exact다. 전체L1·고유13·최종독립은
아직 전이다. 원어민·렌더·정상속도플레이·물리패드·개인디스크복구·본편GO는 주장하지 않는다.

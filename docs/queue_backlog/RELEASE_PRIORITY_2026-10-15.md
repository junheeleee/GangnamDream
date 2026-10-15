# 2026-10-15 출시 기준별 큐 분류

## 권한·분모

사용자의 PR #34 병합·우선순위 정렬 지시를 적용했다.
출시 조건과 목표일의 정본은 [DECISIONS 승인 항목](../DECISIONS.md#2026-10-15-본편-출시-완료-조건과-목표일--사용자-승인)이다.
이 문서는 그 조건을 복제하는 새 승인표가 아니라 **기존 오더의 잔여 범위 분류 근거**다.
판정 기준 제품: main 병합 commit `7c08e0b1a6427d348e6e8b82e862f1fa1885ef08`,
tree `6a5d30c1d848b0a489594f106558c77a8ebd0834`.
분모는 기존 열린 78개(추적 77개 + 같은 월 한 커밋으로 보존 중인 612 overlay)다.
이 문서 정렬 오더 672는 분모에서 제외한다. **유지1 + 조건부1 + 출시 후 보류76 = 78**.
단일 실행 순서는 [CODEX_QUEUE](../CODEX_QUEUE.md)만 소유한다.

- 유지: 실제 대표 월/치명 결함 재검수 612. 이 사양은 동일 M18만 소유하며
  M19 이후는 해당 월별 작은 선언으로 이어간다. 612를 M60 포괄 권한으로 확대하지 않는다.
- 조건부: 157을 C2/C4/C5의 출시 현지화 닫기로 축소. 무기한 전체 원어민 작업을 재개하지 않는다.
- 보류: core 22개와 현지화 54개. 상태 [~]/[ ]는 과거 미완료를 보존하고 실행 gate만 제외한다.
  기존 사양을 삭제·[x] 처리하거나 인간/원어민/물리 패드 GO로 바꾸지 않는다.
- 이미 수리한 원문 부채와 정적 누락 수치만으로 새 치명 결함을 만들지 않는다.
  보류 항목에서 현재 C2급 반례가 확인되면 그 exact 결함만 새 소유 범위로 선언한다.

## 조건별 현재 남은 일

| 조건 | 실행·증거 경계 | 현재 미충족/다음 닫기 |
|---|---|---|
| C1 대표 완주 | 실제 앱 1경로를 이어가며 완료 월과 보조 경로 전수 반복은 금지 | 동일 M18 수정 앱 HUD/저장 재검수, 이후 M60 엔딩 도달. Mac 잠금 동안 실제 관찰 발급 0 |
| C2 치명 결함 | 진행/저장·EN 한글/빈 번역·선택과 정반대 사실의 확인된 결함만 | 같은 M18 실제 저장 수리 재확인. 새 C2 반례는 작은 자식 수리; 산문·밀도 개선을 동급 차단으로 올리지 않음 |
| C3 main CI | KNOWN_FAILURES 밖 실패와 만료 예외 0, 현재 HEAD 결과를 확인 | 정렬 선언 main4643bcc의 CI38690801672는 조회 당시 in_progress/null. 과거 표적 GO는 녹색 대체 아님; 빨강 동안 새 월 0 |
| C4 사람·AI 고지 | 사람 2~3시간 직접 확인과 최종 판단은 사용자/지인 1명; 원어민 전수는 제외 | JA/zh AI 보조 번역 고지를 게임 언어 선택과 상점 초안에 구현해야 함. 현재 사람 확인·고지 완료 발급 0 |
| C5 출시 준비물 | 5언어를 유지하고 최종 retail 패키지·설명/샷/트레일러·등급 설문 준비 | retail 언어 선택은 현재 KO/EN. 5언어 enablement·KO/EN 확정 뒤 CJK 1회 정합·Steam 준비물 확인은 별도 bounded 범위. 외부 업로드/상점 수정/설문은 별도 권한 |

C4/C5의 gap은 이번 문서 정렬로 구현된 것이 아니다. 제품/상점 문안을 바꾸려면 정확한
파일 소유권으로 자식 선언 후 구현한다. 외부 출시·지출·법률 인증은 이 지시로 승인되지 않았다.
5조건 밖 보류 작업을 재개하려면 사용자 새 승인 또는 실제 C1~C5 기여 근거가 필요하다.

### 실제 현지화 gap의 소스

- `autoloads/LocaleManager.gd:7-8,77-85`: 지원5언어와 retail 선택 KO/EN을 구분한다.
- `scenes/SplashScreen.gd:140-200`, `scenes/StartMenu.gd:2798-2831`,
  `scenes/StoryMode.gd:1140-1145`: 현재 언어 선택에 결정의 JA/zh AI 보조 번역 고지가 없다.
- `docs/STEAM_PAGE.md:296-317`: 기존 일반 AI 제작/영문 현지화 공시를 해당 고지 완료로 세지 않는다.
- `autoloads/LocaleManager.gd:212-241`, `autoloads/DataRegistry.gd:423-468`:
  준비 언어의 EN 폴백 때문에 정적 missing845각을 빈 문자열845건으로 세지 않는다.
- I18N/Steam의 옛 원어민 gate 요구는 최신 DECISIONS가 출시 차단 기준으로 대체한다.
  역사 원문과 제품 번역/원장 수용은 보존한다. 실제 구현 시 해당 정본도 새 결정에 맞춰 정렬한다.

## 기존 78개 전수 처분

아래 원 gate는 정렬 전 기준의 보존값이다. 현재 실행 여부는 큐의 `출시 후 보류`가 결정한다.
같은 번호의 사양이 근거이며, 보류는 구현/수용 증거를 폐기한다는 뜻이 아니다.
사양 좌표는 현재 보존 사양의 줄 번호다(157은 최신 범위 증보 20줄을 반영).
재정렬 전 큐 줄 번호는 근거 칸에서 제외했고, 원 gate·분류 조사 원문은 별도로 보존한다.

| 오더·사양 | 처분 | 잔여 범위의 근거 | 원 gate 보존 | 사양 좌표 |
|---|---|---|---|---|
| ORDER-612 (미커밋 월별 overlay) · 최신 수리 후보 M18 실제 앱 검수 | 유지 · C1/C2 | 동일 M18 HUD/내구 저장 불일치 수리 후보의 실제 재검수; 이후는 월별 선언 | 월초 저장 source GO · 동일M18 수정 앱 재검수/화면접근 HOLD | `docs/queue_active/ORDER-612.md:93-109`; `docs/queue_active/ORDER-612.md:122-128`; `docs/queue_active/ORDER-612.md:143-147` |
| [ORDER-149](../queue_active/ORDER-149.md) · 프롤로그 세 비트의 강조·리듬 | 출시 후 보류 | 강조·리듬·옛 캡처 및 전 프레임/사람 L3; 현재 치명 결함 수리의 확인된 범위가 아님 | 실제창 autoplay4·OS skip2 PASS/표본관찰 · 옛캡처 FAIL·전프레임 HOLD · L3 OPEN | `docs/queue_active/ORDER-149.md:95-113`; `docs/queue_active/ORDER-149.md:202-217` |
| [ORDER-302](../queue_active/ORDER-302.md) · 체험판 대본 사실·영어 정합 수리 | 출시 후 보류 | 공개 데모 사실 수리 source GO·실제 저장/재개/월 복귀 GO 후 남은 별도 후보/분기 관찰 | 수리7항목 source GO · 실제 저장·재개·월 복귀 GO/나머지 HOLD | `docs/queue_active/ORDER-302.md:139-166`; `docs/queue_active/ORDER-302.md:168-187` |
| [ORDER-352](../queue_active/ORDER-352.md) · 본편 5장 대본 이름·시간·회수 정합 | 출시 후 보류 | 미착수 이름·시간·호칭/문법 목록; 현재 대표 경로의 미수리 C2 반례로 확정되지 않음 | 5장 HOLD 수리 닫힌 뒤 착수 · 미실행 | `docs/queue_active/ORDER-352.md:16-19`; `docs/queue_active/ORDER-352.md:34-40`; `docs/queue_active/ORDER-352.md:64-70` |
| [ORDER-212](../queue_active/ORDER-212.md) · 선택의 나비효과·친절의 연쇄 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 432번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-212.md:130-149` |
| [ORDER-211](../queue_active/ORDER-211.md) · 카페·만남·SNS 생활 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 660번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-211.md:170-199` |
| [ORDER-210](../queue_active/ORDER-210.md) · 도시 휴식·도박·우정 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 714번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-210.md:123-142` |
| [ORDER-209](../queue_active/ORDER-209.md) · 계절·동네·취미 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 726번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-209.md:142-163` |
| [ORDER-208](../queue_active/ORDER-208.md) · 투자 연쇄·한국 생활 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 828번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-208.md:217-237` |
| [ORDER-207](../queue_active/ORDER-207.md) · 투자·직장·불안·자기 기준 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 822번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-207.md:247-254` |
| [ORDER-206](../queue_active/ORDER-206.md) · 도움·경계·가족·인맥 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 288번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-206.md:127-134` |
| [ORDER-205](../queue_active/ORDER-205.md) · 비교·돌봄·관계·재기 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 720번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-205.md:177-184` |
| [ORDER-204](../queue_active/ORDER-204.md) · 소비·습관·도박·인연 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 756번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-204.md:237-245` |
| [ORDER-203](../queue_active/ORDER-203.md) · 직장·투자·이별 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 720번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-203.md:238-241` |
| [ORDER-202](../queue_active/ORDER-202.md) · 현수·가족·건강·목표 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 738번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-202.md:225-232` |
| [ORDER-201](../queue_active/ORDER-201.md) · 아버지·관계·목표 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 270번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-201.md:206-210` |
| [ORDER-200](../queue_active/ORDER-200.md) · 친구·직장·살림 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 276번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-200.md:181-219` |
| [ORDER-199](../queue_active/ORDER-199.md) · 어머니·일·살림 중간 회수 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 348번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-199.md:177-222` |
| [ORDER-198](../queue_active/ORDER-198.md) · 생활 인연·마지막 전략 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 342번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-198.md:153-187` |
| [ORDER-197](../queue_active/ORDER-197.md) · 일·신뢰·되돌림 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 774번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-197.md:206-211` |
| [ORDER-196](../queue_active/ORDER-196.md) · 거절·재기·연락 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 804번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-196.md:197-229` |
| [ORDER-195](../queue_active/ORDER-195.md) · 절제·신뢰·생활 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 762번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-195.md:186-217` |
| [ORDER-194](../queue_active/ORDER-194.md) · 가족·회복·관계 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 714번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-194.md:189-217` |
| [ORDER-193](../queue_active/ORDER-193.md) · 투자·사람 후속 결과 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 576번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-193.md:175-206` |
| [ORDER-192](../queue_active/ORDER-192.md) · 관계의 다음 말·책임 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 360번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-192.md:163-197` |
| [ORDER-191](../queue_active/ORDER-191.md) · 판단의 비용·작은 회신 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 444번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-191.md:163-194` |
| [ORDER-190](../queue_active/ORDER-190.md) · 투자·인연 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 582번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-190.md:191-218` |
| [ORDER-189](../queue_active/ORDER-189.md) · 마지막 질주·선택의 대가 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 642번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-189.md:205-230` |
| [ORDER-188](../queue_active/ORDER-188.md) · 관계·투자 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 600번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-188.md:189-224` |
| [ORDER-187](../queue_active/ORDER-187.md) · 소비·독립 생활 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 312번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-187.md:143-177` |
| [ORDER-186](../queue_active/ORDER-186.md) · 가족·일상 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 312번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-186.md:122-156` |
| [ORDER-185](../queue_active/ORDER-185.md) · 창업·크리에이터·회복 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 438번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-185.md:151-182` |
| [ORDER-184](../queue_active/ORDER-184.md) · 후반 이정표와 돈·직장 갈림길 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 567번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-184.md:164-207` |
| [ORDER-183](../queue_active/ORDER-183.md) · 회상·첫 생활과 사별 변형 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 474번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-183.md:143-190` |
| [ORDER-182](../queue_active/ORDER-182.md) · 생활·숨은 사건 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 594번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-182.md:139-199` |
| [ORDER-181](../queue_active/ORDER-181.md) · 창업·정치·정선과 생활 전환 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 534번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-181.md:120-158` |
| [ORDER-180](../queue_active/ORDER-180.md) · 아버지·인연·연애 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 516번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-180.md:118-150` |
| [ORDER-179](../queue_active/ORDER-179.md) · 생활비·소비·주거 불안 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 558번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-179.md:114-165` |
| [ORDER-178](../queue_active/ORDER-178.md) · 직장·구직·자기계발 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 582번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-178.md:109-146` |
| [ORDER-177](../queue_active/ORDER-177.md) · 고시원·출퇴근·건강 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 528번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-177.md:108-143` |
| [ORDER-176](../queue_active/ORDER-176.md) · 월세·첫 월급·가족 기억 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 555번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-176.md:122-149` |
| [ORDER-174](../queue_active/ORDER-174.md) · 다은 일본어 존대 복구 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 기존2문구 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-174.md:63-84` |
| [ORDER-173](../queue_active/ORDER-173.md) · 남은 관계·부모 대화 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | 282번역 L1/L2 · L3 OPEN | `docs/queue_active/ORDER-173.md:102-133` |
| [ORDER-172](../queue_active/ORDER-172.md) · 가족·직장·친구 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-172.md:146-175` |
| [ORDER-171](../queue_active/ORDER-171.md) · 데이트·계절 장면 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-171.md:125-158` |
| [ORDER-170](../queue_active/ORDER-170.md) · 결혼·가족 장면 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-170.md:103-150` |
| [ORDER-169](../queue_active/ORDER-169.md) · 일본어 원화 단위 정밀화 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-169.md:49-63` |
| [ORDER-168](../queue_active/ORDER-168.md) · 다은 관계·통화 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-168.md:103-130` |
| [ORDER-167](../queue_active/ORDER-167.md) · 종막 서명·선발신 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-167.md:91-112` |
| [ORDER-166](../queue_active/ORDER-166.md) · 마지막 해 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-166.md:117-148` |
| [ORDER-165](../queue_active/ORDER-165.md) · 데모 간체 수량 정밀화 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-165.md:38-45` |
| [ORDER-164](../queue_active/ORDER-164.md) · 4년차와 아버지 경과 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-164.md:135-163` |
| [ORDER-163](../queue_active/ORDER-163.md) · 3년차와 장기 후속 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-163.md:150-188` |
| [ORDER-162](../queue_active/ORDER-162.md) · M07~M24 연결 사건 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-162.md:114-140` |
| [ORDER-161](../queue_active/ORDER-161.md) · catalog 전체 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-161.md:70-95` |
| [ORDER-160](../queue_active/ORDER-160.md) · 남은 결말18종 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-160.md:62-98` |
| [ORDER-159](../queue_active/ORDER-159.md) · 일상·회복 결말 14종 번역 | 출시 후 보류 | 번역 L1/L2 수용 후 원어민/화면 L3; C4 고지로 출시 차단 의무 대체 | L1/L2 PASS · L3 OPEN | `docs/queue_active/ORDER-159.md:91-105` |
| [ORDER-158](../queue_active/ORDER-158.md) · 본편 8장면 번역 | 출시 후 보류 | 8장면 L1/L2 수용 후 원어민/화면 L3만 미완료 | L1/L2 PASS · 원어민 OPEN | `docs/queue_active/ORDER-158.md:74-86` |
| [ORDER-157](../queue_active/ORDER-157.md) · 본편 일본어·중국어 전체 번역 | 조건부 축소 · C2/C4/C5 | 실제 빈 표면/EN 한글, AI 보조 번역 고지, KO/EN 확정 후 CJK 1회 정합·retail5언어 준비만 | 전체 INCOMPLETE · 원어민 OPEN | `docs/queue_active/ORDER-157.md:99-117` |
| [ORDER-156](../queue_active/ORDER-156.md) · Ch5 생활 routine 실제 배경 | 출시 후 보류 | Ch5 생활 배경의 추가 입력/사람 관찰; 별도 두 경로 전수 요구 | 입력 QA 잔여 · 사람 OPEN·HOLD | `docs/queue_active/ORDER-156.md:67-82` |
| [ORDER-151](../queue_active/ORDER-151.md) · Ch5 장소·기간·카지노 맥락 | 출시 후 보류 | Ch5 장소/기간/카지노 맥락 후속 관찰; 156과 과거 두 경로 gate | 후속 156 · 사람 OPEN·HOLD | `docs/queue_active/ORDER-151.md:65-76`; `docs/queue_active/ORDER-151.md:78-113` |
| [ORDER-150](../queue_active/ORDER-150.md) · Ch5 human REJECT 수리 | 출시 후 보류 | 과거 REJECT 수리 뒤 exact 두 경로·두 사람 gate | 후속 151 exact 재플레이 대기 · 두 사람 gate OPEN · HOLD | `docs/queue_active/ORDER-150.md:19-28`; `docs/queue_active/ORDER-150.md:195-214` |
| [ORDER-148](../queue_active/ORDER-148.md) · 5장 종막의 부정 종결 습관을 푼다(사실은 유지) | 출시 후 보류 | 부정 종결 습관의 문체 개선·재계측; 사실 삭제나 치명 수리 아님 | ORDER-150 exact 제품 뒤 재계측 · 금지 사실은 한 건도 삭제 금지 · 선행 대기 | `docs/queue_active/ORDER-148.md:107-109`; `docs/queue_active/ORDER-148.md:111-144` |
| [ORDER-147](../queue_active/ORDER-147.md) · runtime identity | 출시 후 보류 | 과거 runtime identity 후보의 인간 REJECT; 현재 CI/대표 경로와 별도인 후보 승인 | human REJECT | `docs/queue_active/ORDER-147.md:167-183` |
| [ORDER-146](../queue_active/ORDER-146.md) · ledger | 출시 후 보류 | 후보 ledger의 두 경로 replay OPEN; 자동 검사/저장 계약은 그대로 유지 | 후속 151 새 exact 후보 · 두 replay OPEN | `docs/queue_active/ORDER-146.md:65-85` |
| [ORDER-145](../queue_active/ORDER-145.md) · 후보 | 출시 후 보류 | 과거 후보 HOLD 해소를 위한 추가 replay/사람 판정 | HOLD | `docs/queue_active/ORDER-145.md:77-83`; `docs/queue_active/ORDER-147.md:167-183` |
| [ORDER-143](../queue_active/ORDER-143.md) · graph | 출시 후 보류 | graph/공개 M01~M06 보호 후 남은 후보 HOLD; 제품 보호 검사는 유지 | M01~M06 보호 · HOLD | `docs/queue_active/ORDER-143.md:130-137`; `docs/queue_active/ORDER-142.md:75-77` |
| [ORDER-144](../queue_active/ORDER-144.md) · trace | 출시 후 보류 | trace PENDING·역사 인간 OPEN; 현 대표 1회 완주와 중복 승인하지 않음 | PENDING · human OPEN | `docs/queue_active/ORDER-144.md:72-91`; `docs/queue_active/ORDER-146.md:70-85` |
| [ORDER-142](../queue_active/ORDER-142.md) · volume | 출시 후 보류 | 전체 원고량·밀도·회수의 품질 목표 HOLD | M01~M60 · HOLD | `docs/queue_active/ORDER-142.md:49-77`; `docs/queue_active/ORDER-142.md:132-141` |
| [ORDER-138](../queue_active/ORDER-138.md) · finale | 출시 후 보류 | 종막 품질·과거 인간 REJECT와 추가 경로 | human REJECT · HOLD | `docs/queue_active/ORDER-138.md:15-29`; `docs/queue_active/ORDER-138.md:199-209` |
| [ORDER-137](../queue_active/ORDER-137.md) · Ch5 수리 | 출시 후 보류 | Ch5 이전 후보의 인간 REJECT·후속 수리/관찰 | human REJECT · HOLD | `docs/queue_active/ORDER-137.md:7-19`; `docs/queue_active/ORDER-137.md:194-197` |
| [ORDER-135](../queue_active/ORDER-135.md) · 일반 경로 | 출시 후 보류 | 137/138 후속 두 Ch5 replay 잔여; 대표 1회 완주와 중복 요구하지 않음 | human REJECT · HOLD | `docs/queue_active/ORDER-135.md:7-19`; `docs/queue_active/ORDER-135.md:197-209` |
| [ORDER-119](../queue_active/ORDER-119.md) · 표면 언어 | 출시 후 보류 | 표면 언어의 과거 최종 사용자 GO 대기; 현 EN 누출/빈 문자열은 C2로 별도 수리 | 사용자 GO OPEN | `docs/queue_active/ORDER-119.md:94-122`; `docs/queue_active/ORDER-119.md:184-200` |
| [ORDER-118](../queue_active/ORDER-118.md) · startup | 출시 후 보류 | startup 사용자 GO·R1b 추가 경로 HOLD | 사용자 GO OPEN · R1b HOLD | `docs/queue_active/ORDER-118.md:19-35`; `docs/queue_active/ORDER-118.md:165-180` |
| [ORDER-117](../queue_active/ORDER-117.md) · career | 출시 후 보류 | career 사용자 GO·R1b 추가 경로 HOLD | 사용자 GO OPEN · R1b HOLD | `docs/queue_active/ORDER-117.md:79-97` |
| [ORDER-99](../queue_active/ORDER-99.md) · SAVE-P0 | 출시 후 보류 | SAVE-P0 과거 사용자 확인 대기; 현 저장 손실/CI 실패는 C2/C3으로 우선 수리 | 사용자 확인 대기 | `docs/queue_active/ORDER-99.md:70-86`; `docs/queue_active/ORDER-99.md:95-98` |
| [ORDER-97](../queue_active/ORDER-97.md) · LOC-0.5 | 출시 후 보류 | LOC-0.5 과거 L3 사용자/언어 관찰 대기 | L3 대기 | `docs/queue_active/ORDER-97.md:170-181`; `docs/queue_active/ORDER-97.md:193-218` |
| [ORDER-98](../queue_active/ORDER-98.md) · PAD-1 | 출시 후 보류 | PAD-1 물리 패드 L3; 전 기종 실물 전수는 새 출시 차단 조건 아님 | 물리 패드 L3 OPEN | `docs/queue_active/ORDER-98.md:181-203`; `docs/queue_active/ORDER-98.md:225-238` |

## 정렬 전 실행 문맥 — 역사 보존, 현재 추가 차단 조건 아님

다음 원문은 정렬 전 큐에서 이동한 지시다. 새 5조건 밖 원어민/밀도/두 경로 HOLD는
출시 후 보류이며, 저장 호환·제품 검사·공개 데모 보호 사실은 계속 보존한다.

이후 자식 작업은 공개 데모 증량이 아니라 **본편 M07~M60**의 장면·선택·회수·
정점 밀도를 M01~M60 전체에서 관리한다. 앞 작업의 실측값을 입력으로 쓰고, 차례가
오면 서로 의존하지 않는 15~25단위의 1~2배치 오더로 위 표에 올린다.

1. M01~M06 제품 바이트와 사용자 GO를 동결하고 세 원어민 게이트만 별도로 닫는다.
2. legacy W1~W24 V2의 저장·영수증·회귀 계약은 호환 경로에서만 보존한다.
3. M07~M60은 story map·typed graph·fresh-title trace로 공백과 잘못된 ingress를 먼저 찾는다.
4. 장면 수를 맞추지 않고 실측 결손만 15~25단위 표적 원고·연출 배치로 수리한다.
5. Chapter 5 두 경로는 새 exact 후보의 M49~M60 정상 속도 재플레이 전까지 HOLD다.
6. 2026-09-07 사용자 지시로 M01~M60 JA·zh-CN·zh-TW 번역을 지금 시작한다. 원문 hash로 이후 변경을 검출하며 출시·원어민 GO는 별도다.
7. 현재 전체 본편은 HOLD다. 앞으로의 내부 제품 판단은 WORK_UNIT과 agent_review_decisions를 따르며, 역사 인간 gate OPEN을 가짜 done으로 바꾸거나 공개 출고 권한으로 확대하지 않는다.

### 공개 데모/legacy 원문

공개 출시 데모는 active `story_demo_rc` BUILD `2026.08.31.1`의 **M01~M06**에서
끝나며 사용자 GO다. 한 달 네 주라 내부 계측이 `weeks=24`인 것은 범위를
M07~M24로 늘린다는 뜻이 아니다. M01~M06 공개 데모를 더 확장하거나 새
`demo_rc`로 교체하는 자식 대기선은 없다. JA·zh-CN·zh-TW 원어민 판정은 각각
OPEN으로 남는다.

옛 내부 V2의 호환·재발급 금지는 [보존선](../queue_archive/CODEX_QUEUE_2026-09.md#legacy-v2-호환-보존선)을 따른다.

### 보류 legacy 검증 지시 원문

이 지시는 해당 과거 범위의 보존 기록이며 새 출시 필수 작업을 열지 않는다.

- ORDER-124는 전용 M01~M06 스토리 선택 차선만 쓰며 기존 24주·240주 검사를 실행하지 않는다.
- ORDER-118은 startup 16편·코드 토큰 표면·invalidated 계약만 검사한다. R1b·save·
  dispatcher·transaction·ending·JA/ZH는 건드리지 않고 전체 감사·240주를 생략한다.
- ORDER-117은 지목 2편과 career 15편·보존 1편만 검사하며 story map·계약·runtime·
  save·ending을 byte-exact로 둔다.

## 검토·관측 경계

core23와 현지화55를 별도 읽기 검토로 분리했다. 제품·검사 도구·원어민/인간 원장
변경 0, 새 앱 플레이/월 작업 0, 외부 실행 0. 자동 검사/에이전트 분류는 대표 완주나
사람 2~3시간 관찰·출시 판정이 아니다. 원어민/물리 패드의 역사 OPEN은 그대로다.

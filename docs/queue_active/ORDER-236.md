# Active Queue Spec: ORDER-236

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-236 [전체 현지화] 엔딩 마지막 기록23단위·UI42키 번역

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. 종료235 이후 clean main `396d71d7fd4a4d1b7ef8604dfc0c30ceeb1d79ca` /
tree `5202c142bc2a5200b21baa05d971b0dd2427b03a`를 기준으로 한다. 저작은 선언 커밋과 독립 초기 봉인 후 시작한다.
현재 기준 수용38311/b95/meta9, 새126 수용0이다. 이전235의156검수·회귀를 이번 검수로 합산하지 않는다.

## 깊이 3문·배치

1. 없으면 무엇이 빠지는가? 마지막 자산·일·거처·나이·시간, 공유 기록과 다음 삶 힌트의
   중국어 표면이 영어로 남고, 기존 일본어42의 의미·자연성이 아직 독립 수용되지 않는다.
2. 바뀌는 미래 상태는? 텍스트만 바뀐다. 자산·기록·해금·관계·클립보드·재시작 효과와 조건은 그대로다.
3. 무엇과 경쟁하는가? 결말의 실제 기록과 미경험 이야기, 달성률과 보존률, 실행과 가능성의 의미를 구분한다.

한 배치23의미단위·42키/언어, 총126검수·수용 후보이다. 42키를42배치단위로 세지 않는다.
기존 JA42 직접 검수와 CN/TW 신규84 저작을 구분한다. 좋은 JA는 유지하며 의미 없는 diff를 만들지 않는다.

사전 근거는 `.git/full-game-localization/order235-next-ending-preflight.json`
(60054B / SHA `d700a5d45e92d4e899fe24c45587f5530dec513b41fe2bf5dc3a0698581b7803`),
정확 ID 원형은 `order235-next-ending-ids.json`
(3253B / raw SHA `fd880bb77dcfb245330feb467dd2aa1f549cdadc310a27a4ebb9904664bee20f`)이다.
ID source-order 배열의 canonical digest는 `3304b5e7a9b730f548404cad5bb736b68e0b573ee0be0d2880580d67d78789e5`로 raw SHA와 다르다.
source map은 flat `{leafID:source_sha256}`의 digest
`b402c744ec2fb63891f1b11802787824520e1e933c15390575fa4b21c3410eb4`이다.
preflight rows는 원문 호출순서이며 official collector 정렬순서로 가정하지 않는다.
adapter는 원형을 보존하고 ID집합·정렬된 동등성 및 flat source map을 비교한다.
`runtime:static_ui`는 source_path sentinel이며 파일 경로로 열지 않는다. 값 조회는 owner를 사용한다.

42키의 보호/author_only/기수용0, JA기존42·CN/TW각42부재를 새 초기 봉인에서 재확인한다.
LF/name/brace0, printf 인수17(`%s`6/`%d`11), percent literal `%%`2다.
두 `owner`의 `/`는 leaf pointer에서 `~1`이며, 최고자산 문구의 선행 ASCII 공백2를 유지한다.
실제 literal caller44(키42)와 후치 printf 슬롯은 별도 계측이며 format_template=false가 포맷 미사용을 뜻하지 않는다.

## 정확한23단위·42키

1. 출발점과 마지막 장: 서울에 들고 온 50만원과 지난 5년의 선택이 이 마지막 장에 함께 남았다.
2. 최종 자산: 최종 자산 / 최종 자산: %s  (목표 달성률 %d%%)
3. 마지막 일: 마지막 일 / 다음 일을 찾는 중 / 마지막 일: %s
4. 마지막 거처: 살던 곳 / 마지막 거처: %s
5. 나이와 플레이어 기록: 나이 / %d세 / 플레이어: %s  |  33세 → %d세  |  %d개월
6. 살아낸 시간: 살아낸 시간 / %d주
7. 발자취 표제: 5년의 발자취
8. 주거 이력: 원룸 이사 성공 / 아파트 입성 / 강남 아파트 입성
9. 창업 이력: 스타트업 엑싯 성공 / 창업 도전
10. 크리에이터 이력: 크리에이터 수익화 성공 / 크리에이터 활동 시작
11. 투자 관찰: 숫자를 보고도 거래를 서두르지 않았다 / 가격표 너머의 위험을 살피기 시작했다
12. 정계 이력: 정계 진출
13. 도감 기록: 다시 볼 기록 / 엔딩 도감  %d / %d 발견
14. 정점 대비 보존: `  최고 자산 %s 중 결말에 %d%% 지킴` (선행 공백2 포함)
15. 공유 기록 식별: [강남드림 마지막 기록] / #강남드림 #GangnamDream
16. 만난 사건 수: 만난 사건: %d / %d개
17. 공유 엔딩 제목: 엔딩: "%s"
18. 복사 동작과 완료 상태: 결과 복사하기 / 복사됨
19. 다음 삶 표제와 미경험 수: 다시 시작한다면 / 아직 만나지 못한 이야기가 %d개 더 있습니다.
20. 지연 힌트의 대안: 이번 삶에서 한지연을 만나지 못했습니다. / 한지연의 진실을 끝까지 보지 못했습니다.
21. 아버지 힌트: 아버지 아크를 아직 시작하지 않았습니다.
22. 창업·크리에이터 힌트의 대안: 창업과 크리에이터 이야기, 둘 다 아직 만나지 못했습니다. / 창업 이야기 — 아이디어 하나로 엑싯까지, 아직 만나지 못했습니다. / 크리에이터 이야기 — 구독자 100만까지, 아직 만나지 못했습니다.
23. 투자 반사실 질문: 투자 기술을 먼저 키웠다면 결과가 달랐을까요?

## 소유권

- Rawls: `locale/ui_ja.json`의 기존 선택42만 KO 직접 검수·필요 정밀화.
- Plato: `locale/ui_zh-CN.json` 신규42 KO 직접 저작.
- Poincare: `locale/ui_zh-TW.json` 신규42 KO 직접 저작. CN 자동변환·EN 중역0.
- 비저자 전량: Plato→JA / Poincare→CN / Rawls→TW 각42. ROOT 통합·한정 판정.
- ROOT: `content/meta/full_game_localization.json` 신규126/batch1만 추가.
  기존38311/b95/meta9와 모든 top 필드·순서·선택 밖 수용 원형을 역복원한다.
- 조건부 코드3: `tools/full_game_localization.py`, `tools/zh_translation_audit.py`,
  `tools/full_game_localization_self_test.py`. 실제 첫42 L1의 정당한 오탐이 관측되기 전 변경0.
  오탐 발생 시 exact source/key/typed slot의 actual·자연형·정상 base가 붙은 유효변조·key/source-OFF와
  독립 입력을 코드 전에 봉인하고 비저자가 결과·코드를 검토한다. 첫 실패·역사 기대·기존 함수 보존,
  전역 면제·whole-leaf 허용·검사 맞춤 산문0. `tools/ja_translation_pipeline.py`는 읽기 전용이다.
- 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  `docs/queue_active/ORDER-236.md`, `docs/queue_archive/ORDER-236_L1_L2_RESULTS.md`,
  `tools/audit_scope.json`, `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-236.json`.
- ROOT 추가 보관 소유: `docs/history/WORK_LOG_2026-09-07_localization.md`의 아래 exact1187B raw prepend만.
- 사적 helper·봉인·진단·검수·QA: `.git/full-game-localization/order236-*`만.
  공식 receipt는 도구가 정한 같은 private locale/prompt_version 아래 이번 batch_id 경로만 새로 만든다.

쓰기 허용은 위 tracked19경로이며 그중 코드3은 조건부다. JA pipeline은20번째 쓰기경로가 아니다.
감사 등록은 기존 full-game-localization-overlays 명시 차선의 이번 사양·보고 경로만 추가한다.
선택 밖 JA2859키·탭5행 포함 raw/순서/값과 CN/TW각247키 raw를 보존한다(추가 후 각각289키).
JA 전체 JSON 재직렬화0; CN/TW 신규42만 추가하고 제거하면 전체 old raw exact여야 한다.
MainGame/GameState/MetaProgression/LocaleManager/EndingSystem, 모든 KO/EN·조건/효과·소비자·
폰트/FontKit·SHIPPING_LANGUAGES·project·설정/사용자 저장·공개/인간 원장은 비소유다.
ZH_FONT_ROUTE의 기존 정적 readiness blocked/recognizer 오탐 수리는 이번236에 포함하지 않는다.

## 의미·소비자·원문 채무

- 직접 읽을 소비자: MainGame의 기록/수집 페이지21111–21146, 선택 전문22212–22420,
  동적 metric2969–3006; GameState4471–4490, MetaProgression803–821의 run 기록 순서.
  지연 부모원문은 `content/events/arc_events.json:548–585`, 실제 정본은
  `content/meta/story_rules.json:2231–2246`이다. preflight의2640–2700 참조는 이번용 참조가 아니다.
- 고정50만원·지난5년/5년발자취와 조기 엔딩의 기존 불일치를 번역으로 중화하지 않는다.
  share개월 `(age-33)*12+month`, 나이, stat의 `GameState.turn` 주는 다른 카운터다.
  모든 엔딩이60개월/240주이거나 이전 경과주와 같다고 주장하지 않는다.
- 목표달성률은 total/30억원의0–999 clamp, 최고자산 보존률은 final/peak의0–100 clamp/round다.
  보존률을 손실률로 뒤집거나 표제만으로 수익·승리·인생 순위를 발명하지 않는다.
- 사건수 분모는 DataRegistry.events.size(), 미경험수는 events_seen을 뺀 값이며 local clamp가 없다.
  현재 도달 가능한 고유 출시 사건 수라는 보증은 아니다. 엔딩도감의 발견/전체 슬롯과 혼동하지 않는다.
- 힌트는 앞3개만 표시한다. 지연 미만남/진실은 if/elif, 아버지 시작은 별도,
  창업/크리에이터3문구는 상호대안이다. crash flag가 모든 경로의 미만남을 증명하지 않는 원문 채무를 보존한다.
  아버지 아크 미시작을 사망·부활로 만들지 않으며, 반사실 투자 질문을 결과 보장으로 만들지 않는다.
- startup exit/launch·creator viral/start 우선순위, 현재 housing 표면을 유지한다.
  투자 skill threshold의 관찰에 새 체결·실현수익을 보태지 않고 정계 진출을 당선으로 올리지 않는다.
- 복사 버튼은 clipboard_set 뒤 완료 표시·1.8초 후 원문 복원이다. 게시·외부 전송 완료가 아니다.
- 제외6: 난이도: %s(235기수용), 비교 operand 현실, stat_grid가 읽지 않는 note ‘5년 끝의 흔적’,
  상철/아버지/다은 NG+ 힌트3. runs_completed reader와 total_runs producer/갱신시점 문제를 몰래 고치지 않는다.
- 동적 몸/밤·threshold8·미기록값, 일/거처/엔딩/난이도/돈·플레이어 삽입값과 literal NEW는 비소유다.
  템플릿42 수용은 이 동적 값·전체 grid 중국어 완성 또는 실제 화면/도달 검증이 아니다.

## 초기 봉인·검증·마감

1. ROOT만 종료235 clean full40 commit/tree와 최종 code4·UI3·인간·기존 agent22·원장·WORK/history를 재봉인한다.
   과거 preflight C1 관측을 새 초기 신원으로 대체하지 않는다. 선언/동기화 뒤 동일 clean initial에서
   공식 --leaf-ids/--limit42 initial3을 export한다. 각43 JSONL행/42본문, JA42 previous-present·CN/TW84 null,
   세 언어 source 동일·선택 기수용0·보호0을 독립 확인한 뒤 저작한다.
2. 각 저자가 정본/KO/consumer를 직접 읽고 자신의42 최초 translation_errors L1을1회 실행해 모든 진단과
   source/target/initial/code 전후 pin을 보존한다. 각42 records와 raw/digest, 전체126 비저자 L2를 같은 최종본문에 결속한다.
   필수결함은 원래 모집단42로 재결속하며 축소하지 않는다. checker 증거와 문체 판정을 합산하지 않는다.
3. clean C1에서 final3 export/response/check/import--accept를 언어별 공식 실행하고 changed_files0·정확42를 확인한다.
   initial/final source동일, target·3L2/keymap, canonical receipt checksum/state/nativeOPEN 및 C1 신원을 독립 결속한다.
   UI 바이트·순서와126/b96 역제거→old38311/b95/meta9 전체 raw exact를 확인한다.
4. ROOT가 최종 조합 전체수용 hash/L1 및 명시12 차선을 각1회 실행한다. 실제 전후 입력 수·code pins·stdout·exit를 남긴다.
   실패/후속 같은입력 재검을 모두 보존하고 새 blind 또는 최초 PASS로 바꾸지 않는다. 추가 fullaudit/240/Godot/화면 실행0.
5. 결과 문서 포함 exact C2에서 비저자가 ORDER236 work_unit만 판정하고 자기 저작 승인은 다른 비저자 L2에 의존한다.
   이후 active 원형 보관·기존75행 두 큐 raw 복원·기존22 agent decisions exact+이번1만 metadata로 결속한다.
   source subject는 실제 resolver로 확인하며 기존 원장으로 역추정하지 않는다. 인간 원장은 수정0이다.
      기존 WORK 39007B/SHA 2accf6376c849f92a926bede1bb7961c96edea9e729b8b643e6ddc94fce7654e에서 완료223/222 두 절1187B를 기존 history에 raw prepend한다.
   선언 후 WORK 37820B, 완료절 최대 2000B 예약; 합계 39820B ≤40000.
   새 절이 예약을 넘으면 먼저 명시 보관 범위를 재판정한다. 본문 압축/삭제0, WORK EOF2·history 원래 EOF1·이동 원형 역복원을 검증한다.
6. STATUS는 ROOT가 생성·검사하고 main/기존 번역 mirror를 비파괴 동기화한다. 보고서의 관측 시점과 원격 CI를 구분한다.

성공한 공식 수용 이후에만38437(JA12811/CN·TW12813)/b96/meta9다. 현재는 새126 수용0이다.
본편 HOLD·원어민/화면/실입력/실플레이·human OPEN, 외부 출시/현재원격CI 미관찰 경계를 보존한다.
지속 규범은 I18N/WORK_UNIT 정본이 소유하고, 이번23단위·42키와 파일·마감은 일회성이다.

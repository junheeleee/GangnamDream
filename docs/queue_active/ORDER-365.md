# Active Queue Spec: ORDER-365

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-365 [P0·현지화] 취업 미니게임 결과 산문 22키를 간체·번체로 직접 번역한다

**[~] 2026-09-28 Codex 착수 — 아래 파일만 소유한다.** 부모157의 직접 번역 위임,
clean main `6a568d9702cb03d829e17ec13cbf0c11bff0fadb`에서 시작한다.
351/361의 범위 한정 통합 GO 뒤 이어가는 UI 번역이다. 전체 본편·원어민·렌더 GO가 아니다.

## 깊이 3문

1. 제거 손실: 두 중국어에서 자기소개서/면접의 결과가 영어로 남는다.
2. 장기 상태: 텍스트와 수용 증거만 바뀐다. 등급·스트레스·채용·비용·시간·효과는 그대로다.
3. 경쟁 대상: 수정 흔적/추가 질문/예정된 질문/먼저 닫힌 수첩이라는 다른 결과를 구별한다.
   번역에 합격 보장·숫자 등급·숨은 수치를 새로 쓰지 않는다.

## 한 배치 22단위 — 한국어에서 지역별 독립 작성

| 단위 | 한국어 원문 |
|---:|---|
| 1 | 자기소개서 완성 |
| 2 | 모의 면접 종료 |
| 3 | 첫 장으로 돌아간 원고 |
| 4 | 마지막 답 뒤 이어진 질문 |
| 5 | 멈춰 다시 읽은 줄 |
| 6 | 메모가 남은 면접 |
| 7 | 끝까지 쓴 한 장 |
| 8 | 예정된 마지막 질문 |
| 9 | 다시 고칠 표시가 많은 초안 |
| 10 | 일찍 닫힌 수첩 |
| 11 | 첫 장으로 돌아가 경력 문장을 한 번 더 고쳤다. |
| 12 | 면접관이 정해 둔 시간을 넘겨 다음 질문을 꺼냈다. |
| 13 | 경력 문장 옆에 고쳐 쓸 표시 하나가 남았다. |
| 14 | 면접관은 답변 하나를 적고 마지막 질문까지 이어 갔다. |
| 15 | 마지막 줄까지 썼지만 접힌 모서리나 메모는 남지 않았다. |
| 16 | 면접관은 고개를 한 번 끄덕인 뒤 예정된 질문만 마쳤다. |
| 17 | 끝까지 썼지만 네 답 옆에는 근거를 다시 채울 표시가 남았다. |
| 18 | 면접관은 수첩을 먼저 닫았고, 방 안의 침묵이 길어졌다. |
| 19 | 화면을 닫고도 어깨의 힘이 오래 빠지지 않았다. |
| 20 | 마지막 문장을 저장하자 막혔던 숨이 조금 풀렸다. |
| 21 | 문을 닫고 나와도 어깨의 힘이 오래 빠지지 않았다. |
| 22 | 밖으로 나오자 막혔던 숨이 조금 풀렸다. |

직접 소비자 `scenes/JobHuntMiniGame.gd:608`의 `_show_result()`/LocaleManager.ui.
`scenes/MainGame.gd:17982`의 자기소개서→open(0), 모의면접→open(1)이 호출한다.
완료·확인·지원서 검토로, 문제/응답 본문, 화면 배치/입력과 정상 진입은 이번 소유가 아니다.
기존 JA 및 KO/EN은 문맥 확인만 하고 바꾸지 않는다. 두 지역 값은 문자 변환하지 않는다.

## 정확한 소유권

- root 제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 위22키씩 추가,
  `content/meta/full_game_localization.json`에 정확44 accepted receipt와 이 작업 batch1행 추가.
  source/target hash·accepted_sha256 외 기존40302행·142batch·meta9·보류72는 원형 보존한다.
- root 간체 저작/보조: git-private `order365-*` source/response/receipt/check/보존/마감 파일.
- `/root/screen_path_probe`: git-private `order365-zh-TW-draft.json`만 직접 번체 저작.
- `/root/r3_route_probe`: 저작 비참여, git-private `order365-*review*.json`만,44값 전수 독립검수.
- `/root/compat357`: 현재 읽기 전용. 원장 raw 입구의 후속 수리는 별도366 선언 뒤만 구현한다.
- root 기록: 이 사양→`docs/queue_archive/ORDER-365.md`, 큐2·WORK_LOG·생성STATUS,
  CLAUDE 현재행, `docs/agent_review_decisions.json` 새 work_unit판정1건,
  `docs/agent_reviews/ORDER-365.json`의 독립보고 정확 복사.

## 수용·검증과 연결 경계

지역별 정확22leaf 사전 export→check→독립 원문 비교→사전 적용→fresh export/check/import.
공식 receipt는 private import 증거에서만 만든다. 기대40346/b143, 사전각1065→1087;
JA 사전합집합3028 대비 부재각1963→1941은 전체 live 노출 UI 분모가 아니다.
전체 기존 raw 값·공식40302행·142batch·JA·KO/EN·runtime·project·공개·인간 기록을 보존한다.
22 literal 문맥/추가 공유 consumer, 중복키·문자·수사·토큰·개행·직접번역을 전수 확인한다.
기존 `news-panel-locale-only` named12 Python검사 목록을 재사용하되 이 작업의 파일 범위는
별도로 검증한다. 기존 범위 GO는 상속하지 않는다. context·queue·판정원장·dashboard·diff 마감.

**확인된 통합 의존:** `tools/order351_source_compat.py:387`의 원장 전체 raw 잠금은
정상적인44수용 추가도 거절한다. 핀 교체·예외 면제·검사 생략으로 숨기지 않는다.
별도366에서 정확 후속 전이를 선언/검증하고, 그 전에는365의 통합 완료를 주장하지 않는다.
번역 초안과 독립 문맥 검수는 병렬 진행하며 이 의존 때문에 저작을 다시 미루지 않는다.

## 비소유·판정 한계

도구·KO/EN/JA·runtime·규칙·보상·상태·project.godot·공개 M01~M06·기존 판정·인간 원장은 비소유.
새 엔진/화면/입력 검수는 별도 선언하며 이전 캡처로 새 번역을 인증하지 않는다.
원어민·인간 플레이·물리 패드·연속 정상 경로·렌더 미관측, 본편/새package HOLD 유지.
자동 통과는 계약 증거이지 재미·깊이·문체 또는 인간 관찰이 아니다。
22키·파일·배치·검증은 **일회성**, 상시 승격0. I18N/WORK_UNIT 기존 정본을 적용한다.

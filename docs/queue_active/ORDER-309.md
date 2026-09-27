# Active Queue Spec: ORDER-309

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-309 [P1·본편] 1장 후반 M07~M12 대본의 장소·영어 정합을 고친다

**2026-09-27 Claude 발행.** 본편 대본 정합 검토 계획
([FULL_GAME_SCRIPT_REVIEW](../queue_backlog/FULL_GAME_SCRIPT_REVIEW.md))의 배치
R1이다. Claude가 story_map M07~M12 root 장면(현수 결과, 고시원 작별, 다은 단골,
첫 원룸, 재혁 재회, 1년 결산)과 M05 재혁 선행 장면을 KO/EN으로 읽고, 재혁
재회 스케줄을 `MainGame.gd`에서 확인했다. 산문을 새로 쓰는 작업이 아니라
사실·영어 정합 수리다.

## 깊이 3문

1. **왜 지금인가?** 체험판(ORDER-302) 다음으로 플레이어가 읽는 구간이다. 1장
   사실이 2장 이후 판독의 기준이 되므로 R2 전에 닫는다.
2. **무엇을 바꾸지 않는가?** gameplay key, 선택 수, 효과, 이벤트 ID, 장면 순서,
   스케줄 조건, 경제 수치는 바꾸지 않는다.
3. **순서는?** ORDER-302·303(체험판)이 우선이다. 본편은 HOLD이므로 이 수리는
   공개 GO나 사람 게이트를 바꾸지 않는다.

## 수리 목록

| # | 위치 | 결함 | 수리 방향 |
|---:|---|---|---|
| 1 | `content/events/arc_hyunsu.json` `hyunsu_result_fail`·`hyunsu_result_pass` 본문, 같은 EN 오버레이 | 결과 장면은 `t>=25`(M07)에 나오며 이때 민준과 현수는 같은 고시원 옆방이다(`hyunsu_study_together` 공용 주방, `arc_goshiwon_goodbye` C2 "불 켜진 옆방 … 이웃은 현수"). 그런데 fail은 "현수의 고시원으로 갔다 / went to Hyunsu's goshiwon", pass는 "현수가 사는 고시원 복도를 지나 / walked down the corridor of Hyunsu's goshiwon"이라 다른 건물처럼 읽힌다. | 같은 층 복도 끝 현수의 방 앞으로 가는 문장으로 KO/EN/JA/zh를 맞춘다(예: "복도 끝 현수의 방 앞으로 갔다" / "went down the hall to Hyunsu's door"). 이사 이후인 `hyunsu_pass_news`·`hyunsu_pivot`의 "현수가 사는 고시원으로 찾아갔다"는 맞으므로 두지 않는다. |
| 2 | `content/events_en/arc_midgame.json` `arc_goshiwon_goodbye` 선택 3 결과 | KO "그런데 기억은 그 조건대로만 남지 않았다"가 EN "Memory did not preserve that time by its conditions alone."으로 직역돼 뜻이 흐리다. | 의미를 살린 자연스러운 문장으로 바꾼다(예: "Yet memory had not kept that time on those terms alone."). |
| 3 | `content/events_en/core_loop_v2_events.json` `v2_jaehyuk_plain_reunion_echo` 본문·선택 결과 | KO는 과거형인데 EN만 현재형이다("they agree to meet", "Jaehyuk dresses", "asks"). 앞뒤 1장 EN 장면은 모두 과거형이다. | EN 본문과 두 선택 결과를 과거형으로 통일한다. C1 결과의 원문에 없는 "For the first time"은 원문대로 뺀다. |

## 판단만 남기는 항목 (이 오더에서 고치지 않는다)

- **재혁 재회의 월 배치가 story_map과 런타임에서 다르다.** story_map은 M05
  `m05_jaehyuk_plain_echo`(root `v2_jaehyuk_plain_reunion_echo`, "포장마차에서
  다시", 이미 카톡을 주고받은 뒤의 두 번째 만남)와 M11
  `m11_jaehyuk_reunion`(root `arc_jaehyuk_01_reunion`, `work: EXPAND`,
  `rule_status: needs_rule`)을 따로 둔다. 그러나 M11 root의 원문은 "나
  재혁이… 기억나지?", "10년 만에 연락한 사람"인 **첫 연락** 장면이다. 런타임은
  두 이벤트 모두 `arc_jaehyuk_reunion_seen`을 쓰고, `MainGame.gd`는
  `t>=19`(M05)에 이 플래그가 없을 때만 `arc_jaehyuk_01_reunion`을 띄운다. 그래서
  실제 플레이어는 어느 경로든 M05에 재혁을 한 번만 만나며 M11 beat는 도달하지
  않는다. 이중 소개는 지금 화면에 없지만, M11 EXPAND를 구현할 때 현재 원문을
  그대로 쓰면 재혁이 두 번 처음 연락하게 된다. 해결은 (a) M11 root를 "두 번째
  이후의 재혁"으로 새로 쓰거나, (b) story_map M11 beat를 M05에 합치는 것 중
  하나다. 서사·구조 결정이므로 M11 EXPAND 착수 전에 판정한다.
- `arc_year_close` EN의 인용 `"3 billion won. Five years"`는 첫 주 장면의
  `'3 billion won. Five years.'`와 마침표가 다르지만 문장 중간 인용이라 영어
  규범상 허용된다. 수리 대상에서 뺀다.

## 완료 조건

- 1~3번이 KO/EN(해당 시 JA/zh-CN/zh-TW 오버레이 포함)에 반영된다.
- `python3 tools/en_coverage_check.py`와 `python3 tools/audit_select.py -- <변경 파일>`
  PASS. 해시 고정 검사가 걸리면 기존 소유 오더의 갱신 규칙을 따른다.
- `WORK_LOG`와 이 사양 머리말·큐 행 상태를 함께 갱신한다.
- 원어민·외부 플레이테스트 게이트는 OPEN으로 남는다.

## 번호 충돌 정리 (2026-09-27)

원격 `0fe2119`/merge `4f7bdff`에서는305로 발행됐다. 같은 기준선에서 먼저 선언·
구현·검수한 데모305~308의 exact 기록과 구분하려고 미착수인 이 사양을309로
옮겼다. 위 수리3·판단1·검증 원문은 헤더 번호 외 동일하며 새 구현 권한이나
진행 상태를 추가하지 않는다.302·303 다음 순서/미착수/HOLD는 그대로다.

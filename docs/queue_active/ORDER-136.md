# Active Queue Spec: ORDER-136

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-136 [P0·5장 화면 정합] M55 계약 회의 뒤 다은의 편의점 근무복 초상을 제거하고 후보를 재발급한다

**[~] 착수 · `chapter5_finale_rc` waiting_rebuild · L3 재개 전 차단:**
Claude의 `611c635` 원고·데이터 한정 검토는 제품 source `771d0e7`과 후보 원장이
일치하고 자동 감사가 GREEN임을 확인했지만, `arc_y5_room_consent_receipt`가
`meeting + daeun_normal`을 사용해 5년차 편의점 근무복 초상을 계약 회의실에
띄우는 결함 한 건을 찾았다. 이 검토는 Godot·디스플레이·정상 속도 플레이를
수행하지 않았으므로 사람 플레이 게이트의 합격·실패 증거가 아니다. 기존 후보는
재발급 전까지 새 세션에 쓰지 않는다.

## 깊이 3문

1. **이걸 지우면 무엇이 깨지는가?** 회의용 사복 CG 직후 기본 다은 초상이 다시
   나타나 편의점에서 곧장 온 것처럼 보이고, 다은이 동등한 계약 당사자라는 M55
   연기가 의상 하나로 무너진다.
2. **고친 플레이어와 안 고친 플레이어가 다른가?** 해당 경로의 모든 플레이어는
   CG 뒤 영수증 장면에서 문서·클립·대사에 집중하고, 장소와 맞지 않는 떠 있는
   근무복 초상을 보지 않는다. 선택·사실·원고·저장 상태는 바뀌지 않는다.
3. **같은 자리에서 무엇과 경쟁하는가?** 새 회의용 초상 제작과 경쟁한다. 이 장면은
   인접 M55·M57·M58처럼 문서와 사람의 행동이 중심이고 재사용 가능한 회의 사복
   초상이 없으므로, 초상을 숨기는 최소 수리가 현재 정본과 비용 모두에 맞다.

## 정확한 제품 범위

- `content/events/arc_pre_ending.json`: 대상 root의 `portrait`만 빈 값으로 내린다.
- `assets/event_visual_contracts.json`: 대상 계약을 `meeting + no portrait`로 잠근다.
- `content/meta/story_rules.json`: 회의실에 네 사람이 실제로 남아 있지만 재사용
  초상은 쓰지 않는 `in_person + portrait_role:none` 표시 계약을 명시한다.
- `assets/CHAPTER5_MEETING_VISUAL_BIBLE.md`: CG 이후 재사용 초상을 띄우지 않는 이유와
  다은이 여전히 현장 참여자라는 경계를 정본에 맞춘다.
- `tools/chapter5_causal_route_audit.py`: 런타임을 과거 `daeun_normal`로 되돌리면
  실패하는 M55 visual lock·mutation self-test를 추가한다.
- `tools/ScreenshotQA.gd`: 기존 목록에만 있고 실제 다섯 case에서는 빠졌던 W220
  receipt를 여섯 번째로 렌더해 meeting 배경, `portrait_role:none`, 빈 texture와
  숨은 frame을 직접 단언한다.
- `tools/year5_reference_route_audit.py`: ORDER-118/129/134/135 역사 투영을 넓히지
  않고 이 root의 `portrait` 한 필드와 `story_rules` old→new hash만 ORDER-136
  후속층으로 등록한다.
- `tools/chapter1_core_loop_v2_causal_ledger_check.py`: 공통 감사 source snapshot의
  `story_rules.json` 해시만 새 정확 바이트로 갱신한다.
- 영어 사건은 text-only overlay라 gameplay visual key를 중복하지 않는다. 신규 원화,
  원고, 선택, 밸런스, 저장, 엔딩 라우팅, `project.godot`은 바꾸지 않는다.

## 완료 판정

- **L1 기계:** 대상 runtime=`background: meeting, portrait: ""`, manifest=`portrait:
  null`, story presentation=`in_person/meeting/four participants/none`; causal visual
  lock self-test가 `daeun_normal` 복귀를 거부하고 event visual·story consistency·
  lifecycle·cast-time·changed-scope와 전체 감사가 GREEN이다.
- **L2 화면:** KO/EN `arc_y5_room_consent_receipt` 실제 1280×800 화면에서 검은 화면,
  다은 근무복 초상, CG 잔상, 잘림이 0이다. `CGRuntimeCheck`와
  `CastVisualTimeCheck`도 같은 exact source에서 GREEN이다.
- **L3 사람:** 새 exact source 후보를 active로 등록한 뒤에만 property·general
  M49~M60 정상 속도 플레이를 다시 연다. Claude의 이번 원고·데이터 검토는 이
  게이트를 닫지 않는다.

## 선언·마감

착수 파일은 위 제품 8개와 `docs/CODEX_QUEUE.md`, 이 사양,
`docs/human_gates.json`, `CLAUDE.md`, `docs/WORK_LOG.md`, 생성본
`docs/STATUS.md`다. 제품 commit/tree/source manifest와 검증 증거를 남긴 뒤 후보를
재등록한다. 내부 버전은 `v0.1.0-dev · BUILD 2026.08.24.5` 그대로이며 `main`은
사용자 최종 GO 전까지 HOLD다.

# Archived Queue Spec: ORDER-136

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-136 [P0·5장 화면 정합] M55 계약 회의 뒤 다은의 편의점 근무복 초상을 제거하고 후보를 재발급한다

**[x] 완료 · `chapter5_finale_rc` active · 두 L3 OPEN · main HOLD:**
제품 commit `b375af26f48668c68ec5bda05b25aedf064fe043` / tree
`840016b61bceab6368ef79ea145b32a02730ba00` / source manifest SHA-256
`9415428847c33b94536aa1a82be780cf4e88bcf2b8c9ebcf414a13625d066ad0`으로
후보를 재발급했다. `arc_y5_room_consent_receipt`는 `meeting + no portrait`이고,
네 사람의 실제 현장 참여는 문서·대사·표시 계약이 소유한다. 변경 범위 74개와
전체 감사가 GREEN이며, 같은 exact source의 KO/EN 1280×800 각 6장에 검은 화면,
잘림, CG 잔상, 다은 근무복 초상과 초상 프레임이 없다. Claude의 앞선 원고·데이터
CONDITIONAL은 Godot·디스플레이·정상 속도 플레이 미실시 판정이므로 두 사람
게이트를 닫지 않는다.

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

## 완료 증거

- L1: 대상 사건·시각 계약·표시 계약이 각각 `portrait:""`, `portrait:null`,
  `portrait_role:none`으로 일치한다. causal self-test 16건, Year5 역사 투영
  self-test 48건, 변경 범위 감사 74개와 exact 전체 감사가 통과했다.
- L2: `/private/tmp/gangnam-order136-final-ko.PFfJdE`와
  `/private/tmp/gangnam-order136-final-en.QSyUQQ`의 실제 1280×800 각 6장,
  특히 `*_06_w220_room_consent_receipt_no_portrait.png`를 전수 확인했다.
  `SCREENSHOT_QA_DONE ... black=clear ... cg=verified focus=verified`다.
- 보호: `project.godot` git hash
  `de7af180446a6976bdbb622d9d814175d0869115`, SHA-256
  `78e98d7bdc1349570df6f2cc7ca6cbb11d4fc5451f5bbfdd338561653c7380c5`로
  불변이다. 선택·원고·수치·저장·엔딩 라우팅과 33세 30억
  `instant_legend`도 바꾸지 않았다.

## 정본 승격 판정

- **승격:** `assets/CHAPTER5_MEETING_VISUAL_BIBLE.md`의 `Owner and Use`와
  `Continuity Lock`. 회의용 재사용 초상이 등록되지 않은 상태에서 M55 영수증은
  기본 편의점 근무복 초상을 띄우지 않고, 다은의 참여는 손글씨 경계·지시·투명
  클립으로 보여 준다는 규칙을 정본에 남겼다.
- **일회성:** 폐기 후보 차단, exact commit/tree/manifest 등록, 임시 화면 경로,
  변경 범위·전체 감사 실행 순서와 마감 문서 갱신은 이 수리에서만 유효하다.

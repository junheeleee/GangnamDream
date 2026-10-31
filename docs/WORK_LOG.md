# WORK_LOG.md — 강남드림 작업 기록

## 2026-11-01 — 연속 대표 플레이와 C2 중단

- 사용자 최신 지시: 월별 격리 빌드/독립 입구/해시 고정/마감 없이 같은 대표 저장으로 M60까지 연속 플레이, 확인된 C2만 중단, 비긴급 문제는 엔딩 뒤 일괄 검토. 진행 기록은 하루 한 번. 과거 월별 자료는 보존하되 새 실행의 장벽으로 재사용하지 않는다.
- 이미 완료한 M39를 재생하지 않았다. 기존731a에서 정상157c0·전체결과·자동158/159→160첫문단을 관측한 뒤, 같은29.1 앱/저장의 정상Continue로 W160→M40~M43을 한 세션에서 진행했다. 선택은160c1/161c0/164c0/167c0/169c0/170c0/174통화c0/174후속경청c0. 월별 재빌드/문서/커밋0, 새seed/저장편집/경제·RNG재실행0.
- 실제 출구: M44/W176, last175, H0/M81/돈−14537619, `is_game_over=true`, `full_story_ending_id=burnout`. 자동 루틴176 회복 뒤 정상 월말 건강−2/정신−9/월세650000으로 종료됐다. 중복 처리·저장 손실·루틴 순서 결함은 확인되지 않았고 체력/경제/엔딩 규칙을 고쳐 생존시키지 않는다. **M60 미도달**.
- 확인 C2: StoryMode 복귀 때 전역 전환막이 덮인 상태로 자동 진행 중 엔딩에 도달하면 `_show_ending`이 막을 걷지 않아 엔딩 본문·버튼을 가린다. 수분 뒤에도 같은 흰 화면. 원화면 `.git/continuous-play-20261101-63ghwxm8/early-ending.jpg`, 원stdout154B/stderr0. CmdQ 정상 종료·이후 앱 재선택0, 프로세스 부재 확인. 도구 세션 회수로 supervisor 종료코드는 미확인이며 0으로 만들지 않는다.
- C2 수리: `MainGame._show_ending`의 유효 첫 페이지 뒤 `SceneTransition.fade_in()` 1행. 기존 `SceneDirectionCheck`에 준비된 W4 자동 월말 burnout 회귀 하나와 격리 없을 때 명시 NOT_RUN을 추가했다. 마지막 positive2 exit0/stderr0/오류·누수0, 전환막0·input ignore·terminal serialize불변과 기존1702/103/7/35 검사 통과. 같은 최종 fixture에서 수리1행만 없는 별도 소스 negative2는 가림/입력 차단 한 건만 예상 실패(exit1), 누수0. 첫 시도 누수는 성공으로 세지 않고 원로그 보존, fixture의 SFX/배경tween 수명 정리만 고쳤다. capsule_review 독립 대조·root 원로그 확인 완료. 원로그는 실제 플레이 폴더에 함께 보존했다.
- 실제29.1 autosave/bak/settings·project.godot 원문 전후 동일, 수치/끝난 런 연장/엔딩 선택 변경0. **source·표적 회귀만 완료, 수정앱 실제 화면·새 remote CI는 미관측**. 자동 이어가기도 월별 절차 없이 최신 위치를 따르도록 갱신했다. 새 정상 대표 런 허용 여부를 질문했으며 응답 없이 새게임/과거 저장 복원은 하지 않는다. 이 terminal 저장 자체로 M60에 갈 수 없다. context/queue/감사등록·diff 검사 통과, 원HOLD/인간판정은 그대로다.
- 비긴급 보류 1건:167택시 뒤169회고의 transit-card record 표현 구체성. 반대 이동을 명시한 문장으로 확정하지 않았으며 이후 일괄 검토. 전체 C2/사람2~3h/청취/원어민/패드/출시GO0. 737 캡슐 실물은 재생성하지 않았다.

## 2026-10-31 — 잠금 중 실제 오프라인 캡슐 제작 착수

- C5/737: 사용자 잠금 중 작업 지시. 기존 master/폰트/wordmark/4규격을 이용하는 CPU/Pillow 실물4PNG와 소형2장만 준비한다. native exporter/잠금가드/게임/저장/원그림 변경0. 별도 source-derived rendition이며 native pixel/layout parity·출시GO0.
- exact 소유는 활성737, 제작자/비저자 분리. 완료 로그39765B를 아래 history에 byteexact 보관했으며 기존 월별 마감/HOLD/인간판정은 삭제하지 않았다. 신규규범0/일회성.

## 2026-10-31 — 실제 캡슐 4종 제작·독립 검수 완료

- [737 마감](queue_archive/ORDER-737.md): 고정 원화/폰트/wordmark 규칙의 CPU/Pillow 실제4PNG와 소형120x45·184x69 전독GO_OFFLINE_ASSETS_ONLY. 새 외부폴더 `GangnamDream-Release-Assets/steam-capsules-20261031-y33uh_11`, manifest SHA fd6ba8c01682c9bf7306c3787bed1ded9c3a87bf642ce533ee96a9d50348e50d. 원3인/민준crop·얼굴비겹침·제목가독성 유지. 합성15/독립15PASS, 실제exit0/3.823초/stderr0.
- source3558/입력6/helper2 exact·보호1147그룹1815항목 전후/현재 exact·live378278B/8df231 불변. 독립보고 private737 review.md SHA de413fccd80290c257c62915d2b30dec691abd34e597ab6ec6a85f706e901690, JSON b7b5bb850dd631b910de630ee154b47ee034fe852cc75caa81134535f8c189f0.
- offline4/native0·native pixel/layout parity0·게임/엔진/UI/저장편집/업로드0. STEAM_PAGE §8에 별도 실물 한계 기록, 원native guard/735/736/HOLD/인간판정 보존. 규범은 일회성·승격0. M40/M60/전체C2/C5·사람/청취/retail5언어·출시 미완이며 로컬기록을 remote CI로 세지 않는다.

## 이전 완료 기록

[2026-10-31 체크포인트](history/WORK_LOG_2026-10-31_order737_checkpoint.md)에 이전 기커밋 원문을 보존한다.
원문39765B/SHA256 bb196b32a5e51c387e20fcdf3e211ec5ce2015a7d9e93d9076bf8053d0c53f35.

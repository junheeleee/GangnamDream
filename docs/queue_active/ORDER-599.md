# ORDER-599 — M24 실제 직업과 직장 회상

#### [~] ORDER-599 [정합] KO/EN18잎·기존 장소 배선 — 2026-10-13

사용자 위임 잠금 중 월순서 사실 수리. 598 뒤 같은 M24에서 확인한
사무직 전제와 회수의 현재재직/투자성과 발명을 함께 고친다.
실제월은562/M17 하나 HOLD, 해제 즉시 원559 W68 우선이며 CI빨강 새월0.

## 근거와 작업 단위

- MainGame:7307–7312/story_rules:3233은 job존재/tenure6/mirror만 요구한다.
  정상본편 arc_rescue_job→GameState:2038은 job01편의점을 부여한다.
  job02배달도 합법 legacy JobSystem/저장 경로이며 신규본편선택판이라고 주장하지 않는다.
  현재 prose/배경은 사무실·팀장·책상·형광등·사원증·업무모니터를 단정한다.
- 기존 ImageRegistry:589와 BGMPlayer:662의 current_workplace를 재사용한다.
  직종 제한을 붙여 월급 한계 장면을 지우지 않는다. 기존 job데이터/엔진은 불변이다.
- W93mirror 뒤 W94~95 입구는 '다음날/어젯밤'을 항상 보장하지 않는다.
  주마지막밤→다음주첫날 해석을 불가능하다고 단정하지 않고 상대회상으로 고친다.
- callback45 두독자는 옛 의향flag만 읽으며 고용 게이트의 commute태그도 없다.
  퇴사 뒤에도 유효한 기억이므로 현재주거에서 돌아보고, 안정/야심의 기존 차이를 남긴다.

깊이3문: 방치하면 실제 편의점/배달·퇴사경로에 없는 직장/투자성을 발명한다.
새24주차이/게임상태0, 기존 직장기반/이직의향 생산자·두 reader의 차이를 보존한다.
동일 장면의 자기계산·생활기반과 다음도전이 경쟁하며 새 장면/격상0이다.

## 정확한 소유 범위

- root content/events/arc_midgame.json, EN counterpart: arc_career_ceiling
  description/DIK2, choice1.text, choices0/1/2.result_text 각7잎=14.
  실제일터의 폰/명세서와 다음근무로 사무직/통근/아침 단정을 제거하고 상대회상으로 정렬.
  KO background만 office→current_workplace. 효과/flags/조건/선택순서/새자산0.
- root content/events/callback_events_45.json: kept_job_as_base_echo 및
  career_pivot_intent_echo background→current_housing 두 값.
  kept_job_as_base_echo.choice0.text/result_text KO/EN 각2잎=4.
  현재수입/지출·그때의의향 점검으로 고치며 pivot문안/kept선택1은 보존한다.
- root content/meta/story_rules.json의 career presentation 장소/background만,
  assets/event_visual_contracts.json career background만,
  assets/scene_audio_manifest.json career ambience만 current_workplace로 정렬.
  기존 reckoning음악/start0/방향·로직 불변. 두callback은 기존 background추론을 사용한다.
- root content/meta/story_map.json m24 career intent의 '전날'만 상대회상 정렬.
- 필요 release inventory 실제내용SHA/공식report, 큐2/이사양/archive/WORK_LOG/CLAUDE.
- m24_money_fact_review .git/order599-20261013/independent-review.md만,
  rework_batch_plan 같은 곳 preservation-review.md만. 다른파일은 root만 쓴다.

ScreenshotQA는 id없는 Office Worker fixture이며 두 resolver fallback이 office다.
기존 office기대는 그대로 유효하므로 수정0. 이를 job03나 편의점/배달 실제화면
검증이라고 주장하지 않는다. runtime/저장/경제/공개M01~06/project.godot 불변.
JA/zh원문/원장수용0·5언어유지·이번KO9 중 career본문3은597과 중복,
고유정합대기33→39 예상(공식inventory에서 확인). 실제 확정뒤 일괄정합한다.

## 검증·완료 경계

선언commit/push 먼저. 직전598 after3 재사용, 새공식inventory3으로 source잎/미수용
상태를 측정한다. 기존13표적(EN/Hangul/story consistency/continuity/spine/speech/audio/
i18n/demo scope/story/JA/ZH/release)에 event_visual_contract를 추가해14표적.
context/queue/diff, 비저자18잎 의미·직업입구/reader·wholeinverse·데모/비소유를 검수한다.
새검사/도구/등록/전체audit/240주/엔진/앱/저장접근0. 기존 동적resolver의 코드/배선
증거와 실제화면 미관찰을 분리한다. 본편/실제월/5언어/출시HOLD 유지.
gangnamdream-dev/WORK_UNIT 및 STORY_CONSISTENCY_SYSTEM의 ID별 원문·시청각
동시정렬 원칙 적용. 한오더지시 일회성/정본승격0.

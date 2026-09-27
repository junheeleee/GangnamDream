# Archived Queue Spec: ORDER-315

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-315 데모·StoryMode 상단 안전 여백 수리

2026-09-27 등록. ORDER-314의 실제 KO/EN 1280×800 화면에서 발견한 결함이다.
착수 선언을 먼저 커밋한 뒤 아래 소유 범위에서 구현한다.

2026-09-27 착수, 기준 clean main `15fc0fd`. 아래 소유로 선언 후 구현한다.
제품 두 파일은 `/root/header_layout`, 새 검사/등록은 `/root/screen_path_probe`,
검사 실행기 `tools/run_story_header_safe_area_check.py`와 private315 bootstrap/launcher·실행·문서·판정 원장은 root,
독립 비저자 검수/보고는 `/root/screen_independent_review`가 소유한다.
root 문서 범위에 `CLAUDE.md` 현재행과 WORK_LOG 예산 롤링용
`docs/history/WORK_LOG_2026-09-27_pre_header.md` 원문 보존본을 포함한다.
검사 준비에서 확인된 복구 lock 부작용의 재발 방지 한 줄은 root가 개발 스킬의
Verify 절에 승격한다. 제품 규범 변경이 아니라 실제 검사 격리 교훈이다.
검사 helper·등록과 제품 저자를 분리하고 old314 증거·기존97판정은 무수정이다.

## 깊이 3문과 한 배치

- 없으면: 상단 설정·대화기록·제목이 화면 가장자리 손실에 노출된다.
- 상태 차이: 선택·경제·이력은 불변이고 표시 위치·크기와 재배치만 바뀐다.
- 경쟁: 확인된 공통 상단 결함을 먼저 고친다. 화면 전체 재설계나 미관 변경은 하지 않는다.
- 기존 정본 `INPUT_MATRIX.md`의 2.5% TV-safe 사각형을 적용한다. 새 규칙이 아니다.
  1280×800 관측에서 StoryMode 버튼 y4/설정 right1266·HUD left24,
  데모 home/recap 제목 left20·언어 버튼 right1260은 목표 x32..1248/y20..780 밖이다.
  데스크톱에서 실제 잘렸다는 뜻은 아니며 안전 여백 위반이다.
- StoryMode 상단 HUD·대화기록·설정과 공개 데모 shell의 제목·언어·홈 버튼을 수리한다.
  공통 shell의 home/recap/언어선택 소비자를 확인하고, 같은 compact 상태 안에서
  창 너비가 바뀌어도 여백을 다시 계산한다. 현재 `_on_resized`의 조기 반환을 점검한다.
- 폰트 축소·버튼 숨김·기능 삭제로 통과시키지 않는다. 배경·구분선은 화면 끝까지
  그릴 수 있으나 읽는 내용·포커스·조작 영역은 안전 영역과 겹침 방지를 만족해야 한다.

## 파일 소유와 검증

- 제품 저자: `scenes/StoryMode.gd`, `playtests/order124/StoryChoiceM1M6Playtest.gd`
  중 상단 생성/배치/resize 경로만. 게임 규칙·선택·원고·언어 사전은 무수정.
- 검사 저자: 새 `tools/story_header_safe_area_check.gd` 및 Godot 생성 `.uid`,
  `tools/audit_scope.json`의 해당 검사 등록 항목,
  root 소유 `tools/run_story_header_safe_area_check.py`의 명시 실행·자체 검사,
  private `.git/full-game-localization/order315-*`의 bootstrap/launcher/실행 증거만.
  저자와 독립 검수자의 파일 소유를 분리하고 최종 검수자는 제품·검사 비저자로 둔다.
- root: 이 사양·큐2개·부모302/314 진행 꼬리·WORK_LOG·생성STATUS·별도 판정 원장.
  비저자 보고는 `docs/agent_reviews/ORDER-315.json`.
- 먼저 기존 exact controller/StoryMode 핀 검사 영향을 `audit_select.py --list`로
  확인한다. 옛 핀을 덮거나 검사기를 느슨하게 하지 않는다. 호환 수리가 필요하면
  제품 수리와 다른 새 범위를 선언한다. 공개 데모 package 바이트는 변경하지 않는다.
  확인된 exact 핀 호환 영향은 별도 ORDER-316에서 수리한다.
- KO/EN 1280×800·1280×720·960×600의 home/recap/StoryMode 본문·5선택지를 표적 검수.
  논리 canvas 좌표와 실제 PNG 크기를 구별해 2.5% 경계·겹침·본문/선택 잘림을 판정한다.
  같은 compact 상태의 가로 resize도 확인한다. 설정/기록 열기·닫기·원래 선택 포커스
  복귀와 합성 press/release를 검증하고 실제 화면을 독립 검수한다.
- fresh pre-autoload 저장 격리, 사용자43파일 census/hash, 실행 source/helper 핀,
  exact marker·exit0·3로그 오류/누수0를 대조한다. 첫 실패와 ORDER-314 원형을 보존한다.
  전체 24/240주·720 self-test·전해상도/전언어를 근거 없이 반복하지 않는다.
- 수리 후 새 exact source에만 판정한다. 314의 REWORK를 삭제하거나 새 GO로 덮지 않는다.
  314의 나머지 계약과 영향 범위를 재검토해 닫을 수 있을 때만 별도 후속 판정을 남긴다.
  부모302·본편·새패키지 HOLD, 옛 공개GO1·인간OPEN45·원어민/물리 입력 미관측은 유지한다.

이 사양은 일회성 수리 지시이며 영구 안전영역·입력 규범은 기존 정본이 소유한다.
승격: `.codex/skills/gangnamdream-dev/SKILL.md`:Verify의 Godot 검사 격리 교훈 한 줄.

## 2026-09-27 완료 — 작업 한정 GO

- 제품 `1e141ea`, 최종 실행/독립 판정 source `d99f2037ecbcb959004b97d380efb3b33314a512`,
  tree `2373139d718d4a6db54a91cc9ce08d9e08aa1bb9`. StoryMode/controller 두 파일의
  상단 함수만 수리했다. 폰트·문자열·선택·경제·저장 규칙은 무수정이다.
- KO/EN ×1280×800·1280×720·960×600의6실행 모두 PASS. 각10PNG/102합성 edge,
  총60PNG 전수 독립 관찰·204상단 사각형·6가로resize·12모달 exact포커스 복귀를 확인했다.
  기본 글자 크기이며 모든 논리 화면은 noncompact다. Large/실제 compact 전환 관측은 아니다.
- 각 실행 exit0·exact marker1·ENTRY2·3로그 오류/누수0·종료 프로세스0,
  선택 source/helper1225핀과 사용자43파일 전후 동일. 28.09~28.65초이며 이전월은 fixture다.
  각9선택/영수증9·6정산·24주·turn25·cash632만원·health70·mental76이다.
  이전314의 answer1/mental68과 달리 이번 fixture는 answer0이므로 동일 경로라 부르지 않는다.
- 초기 그래픽 실패3회(구문2/합성키 매핑1)와7실패PNG를 모두 보존했다. 별도 비격리
  `--check-only`는 autoload 오류와 빈 복구 lock 삭제43→42를 일으켰다. 원래0byte를
  복원해 전체43경로·크기·SHA 일치를 독립 확인했다. inode/시각 보존이나 작업 내내
  무변경을 주장하지 않는다. 세부 원형과 복구 증거는 독립 보고에 결속했다.
- [독립 보고](../agent_reviews/ORDER-315.json) SHA
  `05d1feba9dbf3e776dd066589e5b872941cf710ed2de50f9a29bd0d24b481b88`.
  검사 정합16·데모 언어 정합·EN누출0·기존97판정/168증거/39629byte WORK_LOG 보존 PASS.
- 이 GO는 위 상단 수리에 한정한다. 314의 과거 REWORK는 보존하며 같은 원래 범위의
  새source 후속 판정은 별도다. 본편/302/새패키지 HOLD·공개옛GO1·인간OPEN45 유지.

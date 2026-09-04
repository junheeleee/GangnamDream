# Active Queue Spec: ORDER-156

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-156 [P0·장면 정합] Chapter 5 생활 routine의 실제 결과 배경을 행동 장소와 맞춘다

**[~] 2026-09-05 Codex 착수 — 아래 exact 범위만 소유한다.** 기준은
ORDER-155 종료 `dd5d29812b74cb9fd5cf00cfbcbd8e0e66b4e2be`다. 근거는 exact
`042f5ea2bac73d27479922bc5f5051c2ad637355`의 두 경로 Codex 화면 관찰이며
독립 인간 인증이 아니다. 관찰된 routine settled frame은 6회지만,
중복된 `SAVE[4]`를 하나로 세면 고유 원고는 5개다.

## 깊이 3문

1. **현재 키워드 추론에 예외를 더할 것인가?** 아니다. `편의점 도시락
   대신 집밥`은 거절한 대안인 편의점을 현재 장소로 오독한다. 무작위
   생활 원고가 자신의 장소 ID를 소유하고 표시 직전에만 현재 주거를
   해석한다.
2. **집밥을 항상 고시원 공용 주방으로 보여줄 것인가?** 아니다. 일반 경로의
   고시원은 공용 주방, 원룸·아파트·다은과의 완결 결혼은 각자의 현재
   집을 쓴다. 경제 주거값과 결혼·이혼 규칙은 바꾸지 않는다.
3. **W220 에코를 routine 6에 셀 것인가?** 아니다. `31초 녹음`은
   SAVE/REST 무작위 원고가 아니라 저작 선택의 주간 요약·에코다. 다만 같은
   MainGame 장소 결정 경로에서 기본 지하철로 추락한 별도 관찰 결함이므로,
   routine 6과 혼합하지 않는 일곱 번째 fixture로 같은 배치에서 닫는다.

## 배치 — 20개 표적 단위

1. 기준 source의 `_SAVE_SCENES`, `REST_VIGNETTES`, 한영 원고·효과 hash를 기록한다.
2. 관찰 6회의 달력·경로·원고·실제 배경을 fail-first fixture로 고정한다.
3. 실제 MainGame에서 행동 선택→무작위 결과→settled texture·생활음을 재생한다.
4. Property `REST[8]` 길에서 만원을 주운 결과는 `street_day`로 닫는다.
5. General `REST[5]` 공원 벤치 결과는 새 `park_bench_day`로 닫는다.
6. General `SAVE[4]` 냉장고·계란·김치 결과는 현재 집의 취사 공간으로 닫는다.
7. 같은 `SAVE[4]`가 다시 뽑혀도 편의점 배경이 남지 않는다.
8. General `SAVE[0]` 집밥 결과는 문장 속 거절된 편의점이 아닌 현재 집이다.
9. General `SAVE[1]` 구독 정리 결과는 선택 카드의 편의점 스틸을 남기지 않는다.
10. 인접 `SAVE[2]` 걷기는 `street_day`, `SAVE[3]` 편의점 커피는
    `convenience_night`이라는 양성 대조를 고정한다.
11. 집 취사 resolver는 고시원만 공용 주방, 나머지는 현재 주거를 가리킨다.
12. 완결 결혼은 다은 신혼집, 이혼은 경제 주거로 돌아간다.
13. 새 공원 배경은 낮의 서울 도심 공원·빈 벤치이며 전경 인물·글자·로고가 없다.
14. 새 배경의 1280×800·960×600 UI-safe crop과 불투명·중복·import를 검사한다.
15. 공원·거리·주거·편의점의 생활음이 settled texture와 일치하는지 검사한다.
16. KO/EN 전환 전후 같은 원고가 같은 장소로 닫는다.
17. W220 저작 선택 영수증은 선택 결과의 실제 장소 ID를 기록하고 나중 주거가
    바뀌어도 에코에서 원래 장소를 다시 보여 준다.
18. 행동 원고·효과·확률·AP·축·저장 의미와 공개 M01~M06, `project.godot`을 보존한다.
19. 변경 영향 선택·저장 왕복·MainGame/StoryMode 컴파일·전체 감사를 통과한다.
20. 독립 읽기 전용 리뷰를 받고 새 exact 제품·review 후보를 봉인한다.

## 정확한 파일 소유권

- 제품 런타임: `scenes/{MainGame,StoryMode}.gd`,
  `autoloads/{GameState,ImageRegistry}.gd`의 routine background 필드·현재 집 취사
  resolver·직접 결과 표시·저작 선택 실제 장소 영수증만.
- 새 자산: `assets/backgrounds/park_bench_day.png`과 Godot import.
- 자산 계약: 새 `assets/ROUTINE_VIGNETTE_VISUAL_BIBLE.md`,
  `assets/ASSET_INDEX.md`, `assets/{scene_audio_manifest,scene_direction_manifest}.json`,
  `docs/{ASSET_GAP_SPEC,ART_AI_AUDIT,ASSET_QA}.md`의 exact 새 key/행만.
- 회귀: 새 전용 MainGame settled-frame 검사·격리 실행기, 필요한 최소
  static audit, `tools/{audit.sh,audit_scope.json}` 의 해당 의존성만.
- 파생 관측: 변경 영향 검사가 요구하는 current source hash/snapshot만.
- 기록: 이 사양, `docs/{CODEX_QUEUE,WORK_LOG,DEMO_FIXLOG,STATUS}.md`, `CLAUDE.md`.
  `docs/human_gates.json`은 변경하지 않는다.

## 비소유·보존선

원고·선택·효과·무작위 확률·AP·행동 축·사람 관계·주거 경제값, W220
주간 요약/에코의 원고·시점·선택 내용, Chapter 5 원고·사실 안전선·엔딩, 공개 M01~M06,
JA/zh-CN/zh-TW 번역, `project.godot`, 원본 slot 01·02는 비소유다.
ORDER-155의 저작 사건 전용 `CHAPTER5_LOCATION_VISUAL_BIBLE.md`과 event-id
전용 `event_visual_contracts.json`도 비소유다.

## 검증·완료 경계

제품 수정 전 전용 검사는 실제 MainGame의 선택 장면에서 행동을 실행하고,
원고가 나온 뒤 크로스페이드가 끝난 texture·생활음을 확인해 현재 오배치를
실패로 남긴다. 수정 뒤에도 같은 경로를 재실행한다. 자동·시각 계약은
정상 독해 속도 사람 플레이와 재미 GO를 대신하지 않는다. 새 exact 제품/
review 후보가 나올 때까지 두 Chapter 5 사람 gate는 OPEN, full·main·product는
HOLD다. 그때만 두 경로 M49→M60→후일담→6/6 재플레이를 요청한다.

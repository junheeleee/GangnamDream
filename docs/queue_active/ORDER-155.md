# Active Queue Spec: ORDER-155

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-155 [P0·장소 연출] Chapter 5 저작 장면의 장소·시간대 배경을 산문과 맞춘다

**[~] 2026-09-05 Codex 착수 — 아래 exact 범위만 소유한다.** 기준은
ORDER-154 종료 `f601f822838d72d376d79c21eaa9aa5cbfe21fcd`다. 근거는 exact
`042f5ea2bac73d27479922bc5f5051c2ad637355`의 두 경로 Codex 화면 관찰과
현재 제품의 정적 역추적이다. 이 관찰은 독립 인간 인증이 아니며 두 Chapter 5
사람 gate는 OPEN, full·main·product는 HOLD다.

## 깊이 3문

1. **기존 배경을 이름만 바꿔 재사용하면 되는가?** 아니다. 현재 진료실은 창밖이
   밤이고, 식당은 야간 고깃집이며, 지하철은 열차 객실뿐이다. 오전 진료·토요일
   12:30 한정식·역 계단/역무실에 쓰면 장소 사실이 다시 틀린다. 기존 화풍과
   1280×800 구도를 고정한 여섯 장소 자산을 만들고 사람·간판·브랜드·글자를
   전경에 굽지 않는다.
2. **결과 문단의 이동을 도입 배경 하나로 덮을 것인가?** 아니다. 선택 전에는
   현재 장소만 보이고, 실제 이동을 선택한 결과에만 `result_background`를 둔다.
   거절·사양 분기는 원래 장소를 유지하며, 오픈하우스의 두 결과는 마지막 물리
   위치인 현재 집/지하철로 각각 닫는다.
3. **생활 routine의 공원·길·집밥까지 함께 고칠 것인가?** 아니다. 무작위 vignette는
   event JSON과 다른 MainGame 경로이고 SAVE[1]/[4]는 현재 정적 해석과 과거 화면
   관찰이 어긋난다. 이 배치는 저작 event 7개만 고치고, routine 6개는 별도
   settled-frame fail-first 뒤 다음 배치로 닫는다.

## 배치 A — 20개 표적 단위

1. 기준 제품의 7개 event 객체, 대응 EN overlay, 기존 배경/초상/선택/효과 hash를 기록한다.
2. 새 장소 여섯 곳의 화풍·공간·시간·금지 인물·UI crop 계약과 ImageGen provenance를 쓴다.
3. 금요일 오전 9:20의 사람 없는 동네 가정의학과 진료실 배경을 만든다.
4. `arc_y5_burnout_check_reference` 도입·세 결과가 그 낮 진료실과 병원 ambience를 유지한다.
5. 퇴근 뒤 도시 지하철역 계단/개찰구 배경을 만든다.
6. 같은 역의 사람 없는 역무실·분실물 접수대 배경을 만든다.
7. `rare_wallet_executive` 도입과 현금 선택은 계단, 역무원 인계 결과만 역무실로 이동한다.
8. 토요일 12:30의 조용한 강남 한정식집 낮 배경을 만든다.
9. `chain_exec_meal_arrival` 도입·두 결과가 낮 한정식집을 유지한다.
10. `arc_jiyeon_year5_news` 점심 도입과 축하 결과는 같은 낮 식당, 침묵 결과만 거리로 나간다.
11. 실존 가수·브랜드·읽을 수 있는 무대 문구가 없는 야간 콘서트 홀 배경을 만든다.
12. `yolo_spend_moment` 예매/저가석 결과만 콘서트장으로 가고 참기 결과는 편의점에 남는다.
13. 토요일 새벽 화곡동 낡은 빌라 실내 보수 현장 배경을 만든다.
14. `chain_envelope_owner_return` 현장 일을 택한 결과만 빌라 현장으로 가고 사양 결과는 편의점에 남는다.
15. `hidden_gangnam_open_house` 도입은 기존 빈 강남 아파트 실내를 명시해 ‘한강 조망’을 산책로로 오독하지 않는다.
16. 오픈하우스 조건 질문 결과는 마지막 책상 서랍의 `current_housing`, 구경 뒤 귀가 결과는 마지막 지하철 객실로 이동한다.
17. 새 여섯 background key의 registry·scene direction·audio profile과 exact visual contract를 닫는다.
18. KO/EN × 모든 선택의 실제 StoryMode 도입/결과 settled frame·texture·ambience를 전수 재생한다.
19. 960×600·1280×800 crop, 자산 인덱스·AI 감사·import·투명도/중복/인물 bake-in 검사를 통과한다.
20. 공개 M01~M06, 두 Chapter 5 경로 사실선, 저장·로케일 왕복과 변경 영향 선택을 통과한다.

## 정확한 파일 소유권

- 제품 데이터: `content/events/{arc_new_characters,rare_encounter_events,chain_events,
  arc_year3_drama,social_independence,hidden_events}.json`의 위 exact 7개 객체에서
  `background`·`paragraph_backgrounds`·`result_background`만. EN overlay는 텍스트
  불변을 검사하며 gameplay key를 추가하지 않는다.
- 표시 정본: `content/meta/story_rules.json`의 기존 burnout expected background,
  `assets/event_visual_contracts.json`의 exact 7개 visual row만 필요한 만큼 갱신한다.
- 새 자산: `assets/backgrounds/{hospital_clinic_day,subway_station_stairs,
  subway_station_lost_found,hanjeongsik_restaurant_day,concert_hall_night,
  villa_renovation_day}.png`와 Godot import. 기존 raster는 덮어쓰지 않는다.
- 자산 계약: 새 `assets/CHAPTER5_LOCATION_VISUAL_BIBLE.md`, `assets/ASSET_INDEX.md`,
  `docs/{ART_AI_AUDIT,ASSET_QA}.md`, `autoloads/ImageRegistry.gd`,
  `assets/{scene_audio_manifest,scene_direction_manifest}.json`의 exact 새 key/행.
- 회귀: 새 전용 실제 StoryMode background-context 검사와 격리 실행기,
  `tools/chapter5_human_reject_audit.py`, `tools/scene_direction_catalog.py`,
  `tools/audit.sh`, `tools/audit_scope.json`. 기존 검사기는 기준을 완화하지 않고
  실제 의존성·새 hash만 추가한다. 새 background key를 실내·교통으로 올바르게
  분류하려면 scene-direction 생성기의 등록 집합도 함께 갱신해야 한다.
- 파생 관측: 영향 검사에서 요구하는 current source hash/snapshot만 exact successor로
  갱신한다. ORDER-151~154 역사 상수, 볼륨 debt·threshold·사람 판정은 바꾸지 않는다.
- 기록: 이 사양, `docs/{CODEX_QUEUE,WORK_LOG,DEMO_FIXLOG,STATUS}.md`, `CLAUDE.md`.
  `docs/human_gates.json`은 변경하지 않는다.

## 비소유·보존선

위 7개 객체의 원고·선택 문구·choice index·effects·flags·follow-up·조건·weight,
KO/EN topology, 인물 초상·화자·관계·아버지 생사·민서 원격·지갑 상호 동의,
M55 복장·무초상, W237 30분·W240 무응답/무이체, 30억 즉시엔딩,
`scenes/StoryMode.gd`의 공통 전환 구현, `scenes/MainGame.gd`의 routine/SAVE/REST,
`project.godot`, 원본 slot 01·02, 공개 M01~M06 제품은 비소유다. JA/zh 원고를
이 배경 수리로 번역하지 않는다.

## 검증·완료 경계

- 제품 수정 전 전용 검사는 현재 실제 StoryMode에서 잘못된 도입/결과 texture와
  ambience를 exact 선택별로 실패시키고 로그 SHA-256을 남긴다. 정적 키 비교나
  이미지만 단독으로 보는 검사는 이를 대체하지 않는다.
- ImageGen 출력은 정본 화풍·continuity와 UI-safe crop을 사람이 직접 보고,
  불합격 이미지는 제품에 연결하지 않는다. 원본 생성 경로·최종 prompt·채택/반려를
  자산 원장에 기록한다.
- L1/L2는 정상 독해 속도 사람 플레이와 재미 판정을 대신하지 않는다. 다음 routine
  배경 묶음까지 닫은 새 exact 제품/review 후보에서만 두 경로 M49→M60→후일담→6/6
  재플레이를 요청한다.

## Fail-first 증거 (제품 수정 전)

- 정적 검사: `CHAPTER5_HUMAN_REJECT_AUDIT_FAIL errors=50`, stdout SHA-256
  `abec2c1e4bb20223f3e7693d31b1cde0b9947c77efb0801fd0bb172a8978db2c`.
- 실제 StoryMode 검사: KO/EN에서 잘못된 기존 texture/ambience와 누락된 결과 이동을
  재현했다. stdout/Godot log SHA-256
  `78282ecf9f77857378cf64138a9eefcbf1c792f37ddaf6c35d5df1513c25ea6b`,
  runner receipt SHA-256
  `8a8d5b037f3739592c12da8097ef987b20eddb53b59edfaab235f972b11ed900`.
  evidence는
  `/var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-story-background-context-cr_avopu`에
  보존했다. 이 RED는 32개 KO/EN×choice fixture 중 기존 동일 장소 4건만 통과하고,
  오전 진료실·역 계단/역무실·낮 한정식·콘서트·빌라·오픈하우스의 실제 오배치를
  각각 실패시킨다.

## 수정 뒤 기계·시각 회귀 증거

- 실제 StoryMode KO/EN×모든 선택은 1280×800과 960×600 각각 32경우,
  도입 122문단·결과 100문단에서 settled texture와 ambience까지 통과했다.
  1280 evidence `gangnam-story-background-context-rcwze_6q`의 stdout SHA-256은
  `3fe05097094b7827ee20143cdbe5548d8fce825c74ae0320525283ae0622b7f5`,
  runner receipt는
  `58cce932050dc24593277e5b0389d45483c740f827b6fdd7e112457e78a169f7`다.
  960 evidence `gangnam-story-background-context-jd4esjtq`의 stdout은
  `9437eb19018cfc1eb10da7417f974187f3c387b1f0cf9112cfeb4c6b6d25a0ad`,
  receipt는 `37ddea15b1f7be6fa94ce9d89ef6830987a36eeb9ff02fbb6a2d449e23479124`다.
- `VisualCropQA`는 새 여섯 배경×두 해상도의 0px cover crop, 정확한 산출 크기,
  HUD·대화·선택 dock 경계를 포함해 전체 39프레임을 통과했다. contact sheet
  `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png`의 SHA-256은
  `a940f667ba79e9521c8442c74fb646f9e101de53bbc6020264269e41e86ec65f`다.
- 여섯 자산은 원본·실제 조합을 직접 보아 장소·시간·동선·무문자·비주연 대역을
  확인했다. 다만 생성 원본이 2560×1600 미만이므로 B+/`PASS-B` runtime 후보이며
  A급 출시 master로 승격하지 않는다.
- Godot 4.6.2 전체 감사는 종료 코드 0과 `✅ 감사 통과`로 닫혔다. 이 실행에서
  Chapter 1 역사 보존 변조 519건, StoryPlayback 156경우·1,044화면,
  Chapter 5 human-reject 런타임, 35개 엔딩, 68개 스크립트 강제 컴파일을 함께
  통과했다. Godot 종료 시 기존 허용 자원 정리 알림은 있었으며 경고 0으로
  과장하지 않는다.
- 위 증거는 정상 속도 사람 플레이나 재미 판정이 아니다. 사람 gate는 계속 OPEN,
  full·main·product는 HOLD다.

**규범 소유권:** 장소는 prose keyword가 아니라 event id의 명시 계약이 소유하고,
실제 이동을 택한 결과만 새 배경으로 전환한다는 기존
`docs/STORY_CONSISTENCY_SYSTEM.md`·`assets/scene_direction_manifest.json`을 적용한다.
새 여섯 장소의 지속 시각 규칙은 `assets/CHAPTER5_LOCATION_VISUAL_BIBLE.md`에
승격한다. exact 일곱 id·증거·파일 소유권은 일회성이다.

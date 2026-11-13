# ORDER-830 — 장면 감각 정합

#### [~] ORDER-830 · C2/C3/C5 · 2026-11-13 본편 전구간 사용자 지시

같은 플레이로 M60 엔딩과 크레디트 도달. 사용자는 출시 전 글·그림·소리·효과가
모든 상황과 맞도록, 맞는 에셋이 없으면 신규 제작까지 요청했다. 장면과 실제 도달
분기의 글(장소·시간·행동), 표정/구도, 장소음·음악·효과·전환을 함께 본다. 실화면,
사용자 실청취, 정적 후보, 격리 재현을 구분한다. 의도된 인물/장소 모티프는 남긴다.
첫 두 묶음 이후 M01부터 누락 분기와 엔딩까지 이어가되 새 묶음의 제품 파일을
먼저 명시한다. 초기 정적 모수는 출시 사건 1,702 ID(저작 전용111 제외)이며,
전수 실플레이를 의미하지 않는다. 신규 번역 오더/공개 데모/저장/Steam 업로드0.

## 배치 1 — W200–201 결혼식·신혼집

- W200 소형식 입장 원본 얼굴/질감 결함: 확정 앵커와 클로즈업으로 새 후보 제작.
  채택 시 `cg_romance_wedding_daeun_small` ID 유지, 별도 버전 PNG와 import,
  `autoloads/ImageRegistry.gd`, `assets/{COMMITMENT_VISUAL_BIBLE.md,ASSET_INDEX.md,
  IMAGE_PROMPTS.md,cg_acting_manifest.json,mod_asset_manifest.json}`, `tools/art_resolution_baseline.json`,
  `docs/{ART_AI_AUDIT.md,MODDING.md}`의 해당 항목만. 828의 기존 머리말은 별도 보존.
  원본 보존. 신부 시선·짧은 머리·왼쪽 클립·작은 홀/빈자리·대사 안전 영역을 검사.
- W201 `arc_daeun_wedding_night{,_tea,_honest,_choice}`: `assets/scene_audio_manifest.json`
  네 행과 필요 시 `tools/BGMContinuityCheck.gd` 표적 검증. 이전 식장음 종료 수리 유지.
  실내에 비 추가0. 마지막 분기의 원문 속 순간 냉장고 소리와 상시 윙윙거림을 구별.
  현장음과 음악은 독립 판정하고 새 빌드 실청취 전에는 청취 승인0.
- M54 같은 생활음 수리: `assets/scene_audio_manifest.json`에서 실제 어머니 집
  `arc_daeun_hometown_2{,_father_passed}`·`arc_daeun_hometown_table_{hands,daughter,decision}`
  다섯 행만. 집 실내 음원·음악 시작·이웃 장면을 검증한다.

## 배치 2 — M60 마지막 책상

실화면 ‘마지막 서명’·‘마지막 주’: 책상·실내 문장과 젖은 실외 대로가 동시 노출.
`arc_final_countdown`과 `arc_final_week`만 `content/events/{arc_pre_ending,arc_drama}.json`,
`assets/{event_visual_contracts,scene_audio_manifest,scene_direction_manifest}.json`에서
주거별 실내 그림과 냉장고 루프를 별도 합성하지 않은 방 환경음으로 결속.
`tools/{SceneDirectionCheck,ScreenshotQA}.gd` 해당 회귀만 확장 가능.
원문·선택·효과·기억·음악/타이밍·실제 실외 변형 보존. 렌더에서 밝기/책상/창을 다시
보고 틀린 주거 그림이면 해당 주거만 새 에셋으로 확장한다. 단순 대체만으로 합격0.

상점 준비물: 기존 725/727 파이프라인을 로컬 실행. 실제 소스에서 8번 회고 실패,
영상 회고 두 장 중복과 정리 오류를 발견했다. `tools/ScreenshotQA.gd`의 해당 두
촬영 범위만 소유(실제 회고 페이지·중복·격리 정리). 가짜/대체 PNG·검사 완화0.
후보에서 결함과 엔딩 스포일러 제외; 사람·물리패드·원어민·출시 GO는 별도다.

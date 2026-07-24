# 엔딩 아트 운영 계약

Updated: 2026-07-24

엔딩 화면은 240주의 대가를 한 프레임으로 증명한다. 등급과 관계없이 35개 엔딩
모두 전용 16:10 CG를 소유하며, 텍스트를 읽기 전에도 서로 다른 마지막 삶으로
구분되어야 한다.

## 정본

- 35개 장면의 시간·장소·행동:
  [`assets/ENDING_COMPLETE_VISUAL_BIBLE.md`](../assets/ENDING_COMPLETE_VISUAL_BIBLE.md)
- 카메라·시선·손·소품:
  [`assets/cg_acting_manifest.json`](../assets/cg_acting_manifest.json)
- 엔딩 ID·본문·CG 키: `content/endings.json`
- 런타임 경로: `autoloads/ImageRegistry.gd`
- 실제 분기 우선순위: `autoloads/GameState.gd`, `systems/EndingSystem.gd`
- 스타일: [`GANGNAM_INK_ART_DIRECTION.md`](GANGNAM_INK_ART_DIRECTION.md)

## 런타임 계약

1. `content/endings.json`의 35개 항목은 모두 고유한 `cg`를 가진다.
2. 각 키는 `ImageRegistry.CG`의 서로 다른 `1280x800` PNG로 해석된다.
3. 엔딩 이미지는 `KEEP_ASPECT_CENTERED`로 전체 프레임을 표시한다. 화면을 채우기
   위한 aspect-cover 크롭은 금지한다.
4. 캡션은 왼쪽 아래에만 2차원 페이드 스크림을 만들고, 오른쪽의 손·소품·행동은
   가리지 않는다.
5. 이미지 누락 시 검은 바탕으로 실패를 드러낸다. 도형 심벌, 공용 배경, 무관한
   사건 CG로 조용히 대체하지 않는다.
6. KO와 EN은 같은 엔딩 ID와 CG를 공유한다. 영문 길이가 이미지의 얼굴·핵심
   행동을 덮으면 레이아웃 실패다.

## 제작·교체 순서

1. 엔딩 본문과 실제 조건을 읽고 유효한 연애·아버지·주거·MORAL 변주를 찾는다.
2. 여러 변주가 공유할 수 있는 마지막 물리 행동 하나를 정한다.
3. 카메라 역할, 시선 목표, 양손 행동, 핵심 소품을 acting manifest에 먼저 쓴다.
4. Gangnam Ink 스타일로 전용 16:10 이미지를 제작한다.
5. 원본 해상도에서 얼굴, 연령, 손, 반사, 문자, 공간 동선을 확인한다.
6. 실제 엔딩 UI의 KO/EN 1280x800 화면에서 전체 프레임과 텍스트 가림을 확인한다.
7. AI 감사, 해상도 기준선, 모드 에셋 매니페스트를 같은 변경에서 갱신한다.

## 금지

- 배경 단순 크롭, 코드 도형, 공용 무드 카드, 다른 엔딩 CG 재사용
- 이유 없는 렌즈 응시, 중복 신체, 불가능한 유리·거울 반사
- 본문에 없는 배우자·아버지 생사·강남 주거·직업·재산 발명
- 38세 일반 결산에 33세 초반 얼굴 사용
- 읽히는 가짜 계약서·통장·앱·회사 로고
- 하단 캡션을 피하려고 얼굴만 위에 두고 손과 결말 행동을 잘라내는 구도

## 자동 게이트

```bash
python3 tools/ending_distinctness_audit.py
python3 tools/art_ai_audit.py
python3 tools/art_resolution_audit.py
godot --headless --path . --scene res://tools/CGRuntimeCheck.tscn
godot --path . --scene res://tools/ScreenshotQA.tscn -- --qa=ending-all --lang=ko
godot --path . --scene res://tools/ScreenshotQA.tscn -- --qa=ending-all --lang=en
```

자동 통과는 미학적 승인 자체가 아니다. 최종 원본과 KO/EN 전수 캡처를 사람이
연속해서 보고, 텍스트 없이도 35개의 차이를 설명할 수 있어야 완료다.

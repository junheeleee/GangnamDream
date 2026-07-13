# Steam Store Screenshot Shotlist

> 정본 세트: `assets/store/screenshots/`의 영문 1280x720 PNG 8장.
> 모든 이미지는 실제 Godot 인게임 렌더다. 외부 카피, 합성 HUD, 콘셉트 목업을 섞지 않는다.

## 배열 원칙

1. 처음 네 장은 `미스터리 -> 위험한 선택 -> 반복 압축 -> 장기 결과` 순서로 게임 루프를 설명한다.
2. 다섯째와 여섯째는 반드시 연속 배치해 같은 장면이 플레이에 따라 달리 보인다는 핵심을 증명한다.
3. 일곱째는 로맨스와 CG 품질, 여덟째는 5년이 개인 기록으로 돌아오는 결산을 보여준다.
4. 한 장에 하나의 시스템만 판다. 기능이 많은 화면보다 기억되는 차이를 우선한다.
5. 8장 전체의 기본 언어는 영어다. 한국어 스토어에서도 영어 완성도를 국제 타깃에게 먼저 증명한다.

## 최종 8장

| # | 파일 | 실제 소스 | 한 장이 말하는 것 | Steam 캡션 KO | Steam Caption EN |
|---:|---|---|---|---|---|
| 1 | `01_cold_open.png` | `story_flashforward` 첫 문단 | 2031년 강남의 정체불명 남자로 시작하는 플래시포워드 | 2031년 새벽. 누가 이곳에 도착했는지는 아직 모른다. | Dawn, 2031. You do not yet know who survived the climb. |
| 2 | `02_money_mule_timer.png` | `arc_temptation_01` 실제 12초 선택지 | 돈의 절박함과 되돌리기 어려운 첫 선 | 12초. 200만원. 한 번 넘으면 돌아오기 어려운 선. | Twelve seconds. Two million won. One line that is hard to uncross. |
| 3 | `03_montage_card.png` | Y4 3주 몽타주 결과 | 240주 반복을 그대로 클릭시키지 않는 시간 압축 | 조용한 주는 접혀 지나가지만, 그 대가는 남는다. | Quiet weeks fold forward. Their cost remains. |
| 4 | `04_time_ledger.png` | `stable_success` 최종 시간 원장 | 돈과 사람에게 쓴 시간, 마지막 연락을 함께 결산 | 돈, 건강, 인연, 간직한 것. 게임은 5년을 기록한다. | Money, health, relationships, keepsakes. The game records all five years. |
| 5 | `05_moral_bright.png` | `arc_y2_worn_face`, tint +80 | 다은의 걱정을 먼저 알아보는 같은 카페 장면 | 같은 장면, 아직 사람을 먼저 보는 시선. | The same scene, while he can still see the person first. |
| 6 | `06_moral_dark.png` | `arc_y2_worn_face`, tint -80 | 영수증과 잔액을 먼저 세는 같은 카페 장면 | 같은 장면, 이제 숫자를 먼저 세는 시선. | The same scene, after the numbers have learned to come first. |
| 7 | `07_season_date_cg.png` | `arc_season_cherry_daeun` CG + 3선택지 | 계절 데이트, 히로인 매력, 선택 가능한 로맨스 | 사랑은 계절을 따라 자라고, 선택에 따라 사라질 수도 있다. | Love grows across seasons, and your choices can still cost it. |
| 8 | `08_ending_recap.png` | `stable_success` + 연차별 선택 장면 5개 | 엔딩이 자산 등급만이 아니라 플레이어의 기억을 돌려줌 | 5년, 다섯 장면. 무엇을 기억할지도 플레이어가 고른다. | Five years, five scenes. You choose what the ending remembers. |

7번은 `CG 1장`과 `데이트` 요구를 같은 실제 장면으로 충족한다. 별도 데이트 UI를 억지로 추가하지 않아 총 8장을 유지한다.

## 육안 판정

| 검사 | 통과 조건 |
|---|---|
| 1번 | 인물 정체를 스포일러하지 않으며 강남 야경과 고독한 실루엣이 읽힌다 |
| 2번 | 두 선택지와 `TIME LEFT 12`가 16:9 크롭 안에 모두 남는다 |
| 3번 | `3 weeks passed`, 돈/건강/정신 변화가 한 화면에 보인다 |
| 4번 | `TIME ALLOCATION`과 `CONTACT LEDGER`가 동시에 보인다 |
| 5-6번 | 배경, 인물, 선택지 수와 카메라는 같고 색·질감·문장만 달라진다 |
| 7번 | 다은의 얼굴, 벚꽃길, 한강, 세 선택지가 서로 가리지 않는다 |
| 8번 | `FIVE YEARS, FIVE SCENES`와 Year 1-5가 첫 화면에 가로로 들어온다 |

## 재생성 절차

```bash
/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  --path . \
  --rendering-driver opengl3 \
  --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=store --lang=en

/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot \
  --path . \
  --headless \
  res://tools/StoreScreenshotExport.tscn

mkdir -p assets/store/screenshots
cp /tmp/gangnamdream_store_screenshots/*.png assets/store/screenshots/
python3 tools/store_shot_check.py
```

`ScreenshotQA`는 `/tmp/gangnamdream_qa`를, `StoreScreenshotExport`는 `/tmp/gangnamdream_store_screenshots`를 매 실행 때 정리한다. 내보내기는 1280x800 원본의 중앙 1280x720을 잘라 Steam용 16:9로 고정한다.

## 이번 8장에서 제외한 것

| 후보 | 제외 이유 | 사용할 곳 |
|---|---|---|
| AP 행동 보드 | 현재 게임 루프 설명에는 유용하지만 키 비주얼 밀도가 낮고 웹 UI 인상을 다시 앞세움 | 데모 튜토리얼 GIF, 상세 업데이트 |
| 투자 차트 | 흔한 금융 UI만으로는 강남드림의 차이를 말하지 못함 | 60초 트레일러 |
| 카지노 미니게임 | 기능 폭은 보여주지만 첫 8장에 넣으면 사회 리얼리즘과 관계 드라마의 초점이 흐려짐 | 60초 트레일러, 별도 미니게임 클립 |
| 파산 엔딩 | 위험은 2번 타이머로 이미 전달되며, 일반 카드형 파산 화면은 현재 로맨스 CG보다 약함 | 엔딩 기능 소개 |
| 회상 갤러리 | 강한 유지 기능이지만 미해금 실루엣 위주의 화면은 첫 구매 전환력이 낮음 | 커뮤니티 공지, 업데이트 GIF |

스크린샷을 교체할 때는 동일한 시스템 역할을 유지한다. 더 예쁜 장면이 생겼다는 이유만으로 여덟 장의 정보 구조를 깨지 않는다.

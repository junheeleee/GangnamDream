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
| 4 | `04_time_ledger.png` | `stable_success` 최종 시간 원장 | 돈과 사람을 택한 주의 겹치는 흔적, 마지막 연락을 함께 결산 | 돈, 건강, 인연, 간직한 것. 게임은 5년을 기록한다. | Money, health, relationships, keepsakes. The game records all five years. |
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
| 4번 | `CHOICE PATTERN`과 `CONTACT LEDGER`가 동시에 보이고 두 막대가 총 기록 주를 독립 기준으로 삼는다 |
| 5-6번 | 배경, 인물, 선택지 수와 카메라는 같고 색·질감·문장만 달라진다 |
| 7번 | 다은의 얼굴, 벚꽃길, 한강, 세 선택지가 서로 가리지 않는다 |
| 8번 | `FIVE YEARS, FIVE SCENES`와 Year 1-5가 첫 화면에 가로로 들어온다 |

## 재생성 절차

**현재 새 촬영은 보류다.** 옛 일반 프로젝트 부팅과 공용 임시
출력 복사 명령은 실행하지 않는다. 기존 8장과 그 역사적 렌더 근거는 보존하지만,
현재 본편 후보의 화면·문장·선택을 새로 검수한 것으로 세지 않는다.

기존 파일의 읽기 전용 구조 검사는 다음 명령뿐이다. 이 검사는 촬영·게임 부팅·
내보내기·그림 교체를 하지 않으며, 최신 후보 여부나 화면 내용의 정확성은 판정하지 않는다.

```bash
python3 tools/store_shot_check.py
```

현재 `StoreScreenshotExport.gd`는 입력 `/tmp/gangnamdream_qa`와 출력
`/tmp/gangnamdream_store_screenshots`를 고정하고, 출력의 PNG·Markdown·JSON을
먼저 삭제한다. `GANGNAM_QA_OUT`는 `ScreenshotQA`에만 적용되므로 그것 하나를
지정해도 exporter가 같은 새 입력을 읽는다는 보장이 없다. 트레일러의 격리 runner도
트레일러 전용이며 스토어 촬영에 대신 쓰지 않는다.

다음 새 촬영은 별도 파일 범위를 선언하고 아래 입구를 마련한 뒤에만 실행한다.

- 사용자 저장·설정과 분리된 저장 경로를 autoload 이전에 확정한다.
- 새 전용 입력·출력 디렉터리를 양쪽 도구에 결속한다. 이전 캡처 삭제·공용 임시
  파일 폴백·`assets/store/screenshots/` 덮어쓰기를 촬영 단계에 섞지 않는다.
- 동일 후보의 영어 원본 8장과 1280x720 크롭 8장을 이름·SHA로 연결하고,
  실제 종료코드·원 stdout/stderr/Godot 로그·격리/완료 표식·오류를 함께 보존한다.
- 위 육안 판정으로 새 8장을 검수한 뒤에만 교체를 별도 확정한다. 1280x800 원본의
  중앙 1280x720 크롭과 기존 컷·캡션 계약은 유지한다.

이는 새 촬영에 필요한 안전 입구이지 새 촬영 승인·C5 완료가 아니다. Mac 잠금 중에는
실제 촬영을 시작하지 않으며, 잠금 해제 시 보류 중인 본편 대표 경로 플레이가 우선이다.

### 게임을 부팅하지 않는 내보내기

`tools/store_shot_export.py`는 이미 확보한 원본만 처리하는 별도 오프라인 도구다.
Python과 Pillow가 필요하다. 게임·Godot·autoload를 실행하지 않고, 기존 GDScript의
8컷 이름·KO/EN 캡션 상수를 텍스트로 읽는다. PNG 1280x800의 중앙 y=40..759를
1280x720으로 자르며 리사이즈·합성·새 카피 추가는 하지 않는다.

입력은 전용 디렉터리의 `receipt.json`과 원본8장, 별도의 촬영 기록 파일이다.
receipt는 아래 구조로 실제 촬영 기록에서 작성한다(예시 placeholder는 실행값이 아니다).
frames에는 위 표 순서대로 8개의 `store_en_01_cold_open.png`부터
`store_en_08_ending_recap.png`까지 **실제 원본 SHA256**을 넣는다.

```json
{
  "schema_version": 1,
  "language": "en",
  "candidate": {
    "source_commit": "<40 lowercase hex>",
    "source_tree": "<40 lowercase hex>",
    "build_id": "<actual build ID>"
  },
  "capture_record": {"file": "capture.json", "sha256": "<64 lowercase hex>"},
  "frames": [{"file": "store_en_01_cold_open.png", "sha256": "<64 lowercase hex>"}]
}
```

유효한 receipt와 검수할 원본을 준비한 뒤 사용한다. 경로는 작업자가 지정한다.

```bash
python3 tools/store_shot_export.py --manifest /absolute/capture-run/receipt.json --output-parent /absolute/export-parent
```

출력 부모는 이미 존재하고 저장소·입력 폴더 밖이어야 한다. 매번 그 아래 새
`gangnam-store-export-*` 폴더만 만들며 기존 폴더를 재사용하거나 삭제하지 않는다.
추가/누락 PNG·잘못된 순서/크기·손상 PNG·중복 원본/크롭·hash 불일치·파일 symlink는
실패한다. 8장 전체를 decode·검증한 뒤에만 출력을 만들고, 각 파일의 저장/재독을 확인한다.
중간 저장 실패 시 부분 산출물은 그 경로에 남기고 성공표식을 내지 않는다.

완료 시 `STORE_SHOT_EXPORT_OK ... scope=offline_crop_only`와 `manifest.json`이 생긴다.
`manifest.pending.json`은 원자적 완료 발급에 쓴 동일 바이트 원본으로 함께 남는다.
원 receipt 복사본 `source-manifest.json`, 촬영 기록 복사본 `capture-record.bin`,
원본→크롭 SHA·치수·좌표·캡션·도구/계약 SHA를 보존한다. 후보 값은 `candidate_claim`이며,
**입력 파일의 일치만 검사한다.** 촬영 기록의 진실성, 실제 후보 일치, 촬영 격리,
그림 품질, 출시 승인은 검사하지 않는다. 합성 시험용 이미지도 형식이 맞으면 통과하므로
성공표식을 실제 게임 화면 증거나 C5 완료로 쓰지 않는다.

새 실제 촬영에는 여전히 위 pre-autoload 격리와 원로그 입구가 필요하다. 원본과 크롭의
시각 검수 뒤에만 기존 상점 8장 교체를 별도로 확정한다. 도구 자체의 합성 시험은
`python3 tools/store_shot_export_self_test.py`이며 엔진·실제 캡처·기존 자산을 건드리지 않는다.

## 이번 8장에서 제외한 것

| 후보 | 제외 이유 | 사용할 곳 |
|---|---|---|
| AP 행동 보드 | 현재 게임 루프 설명에는 유용하지만 키 비주얼 밀도가 낮고 웹 UI 인상을 다시 앞세움 | 데모 튜토리얼 GIF, 상세 업데이트 |
| 투자 차트 | 흔한 금융 UI만으로는 강남드림의 차이를 말하지 못함 | 60초 트레일러 |
| 카지노 미니게임 | 기능 폭은 보여주지만 첫 8장에 넣으면 사회 리얼리즘과 관계 드라마의 초점이 흐려짐 | 60초 트레일러, 별도 미니게임 클립 |
| 파산 엔딩 | 위험은 2번 타이머로 이미 전달되며, 일반 카드형 파산 화면은 현재 로맨스 CG보다 약함 | 엔딩 기능 소개 |
| 회상 갤러리 | 강한 유지 기능이지만 미해금 실루엣 위주의 화면은 첫 구매 전환력이 낮음 | 커뮤니티 공지, 업데이트 GIF |

스크린샷을 교체할 때는 동일한 시스템 역할을 유지한다. 더 예쁜 장면이 생겼다는 이유만으로 여덟 장의 정보 구조를 깨지 않는다.

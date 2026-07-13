# 6개월 데모 QA 보고서

기준일: 2026-07-13
범위: OpeningCinematic부터 24주차 종료와 Steam 위시리스트 CTA까지

## 판정

**기술적 데모 후보 통과. 외부 재미 검증 전이므로 공개 출시 후보는 아직 아니다.**

정식판/데모 빌드 분리, 24주 경계, 한국어/영어 입력 진행, 주요 장면 직종 정합성, AP 표기, 마지막 CTA를 자동 검증했다. 내부 자동화는 진행 가능성과 표면 모순을 증명하지만, 신규 플레이어의 자발적 독해와 계속 플레이 의향은 `docs/PLAYTEST_KIT.md`의 외부 테스트로만 판정한다.

## 실행 증적

| 검사 | 결과 |
|---|---|
| `DemoBuildCheck.tscn -- --demo-build` | `DEMO_BUILD_CHECK_OK feature=gangnam_demo cutoff=24 chain=8 presets=6` |
| 영어 실입력 완주 | 24주, 897 입력, 53 이벤트, `job_01`, CTA 도달 |
| 한국어 실입력 완주 | 24주, 893 입력, 53 이벤트, `job_01`, CTA 도달 |
| 영어 `demo-blackbox` | 시작 표면, t1~8, 직종 회귀 4종, AP/보너스 AP, 월말, CTA 통과 |
| 한국어 `demo-blackbox` | 같은 범위 통과 |
| 데모 종료 표면 | `2026-06 W4 / 2026년 6월 4주차`, `WEEK 24 / 24주차`, 25주차 문구 없음 |
| 전체 `tools/audit.sh` | ERROR 0, WARNING 0, 밸런스 3정책, 오디오 64개, 시각 계약 62건, GDScript 57개 컴파일 통과 |

실입력 검사는 `ui_accept`를 실제로 보내 StoryMode 본문, 선택지, AP 행동, 결과, 월말 모달을 통과한다. 25주차는 내부 경계 판정을 위해 달력이 한 번 증가하지만 AP 화면이나 이벤트는 시작하지 않고 24주 기록 CTA로 전환한다.

## 이번 패스에서 수리한 문제

| 문제 | 수리 |
|---|---|
| 취업하지 않은 프로필과 입사 연차 문구 충돌 | 시작 프로필과 `has_job`, `job_started_turn`, 누적 근속을 일치시킴 |
| 편의점/배달 본업에도 사무실 첫 출근 장면 노출 | 첫 근무 주를 편의점, 배달, 일반 직장으로 분기 |
| 폐기된 `story_first_workday`가 중복 발화 | KO/EN 이벤트와 마일스톤 제거 |
| 편의점 본업 중 별도 편의점 시프트가 주 40만원대 지급 | 추가 야간 시프트로 명명하고 기본 보수를 9만원으로 조정 |
| 보너스 AP가 `3/2 AP`, `3 LEFT`로 보임 | `3 AP (+1)`, 세 번째 보너스 슬롯으로 통일 |
| 보너스 AP가 1280 화면을 오른쪽으로 밀어냄 | HUD와 슬롯 예약 폭을 고정하고 카드 경계 자동 검사 추가 |
| 전화 콜백인데 카페 남성이 고시원에 서 있음 | 전화 장면은 민준 피로 초상만 사용 |
| 오프닝 마지막 카드 연타 시 재생 반복 | 생성 가드 추가 |
| 월말 성향 모달이 요약 모달 상태를 덮어 진행 정지 | 요약 종료 뒤 성향 모달, 그 뒤 다음 주 순서로 직렬화 |
| 데모 CTA 위에 AP 확정 오버레이/토스트 잔류 | CTA 진입 시 일시 표면 정리 |
| 완료 카드가 `WEEK 25`로 표시 | 마지막 플레이 가능 시점인 24주차로 고정하고 회귀 검사 추가 |

## 잔여 위험

1. **재미와 몰입**: 자동 QA는 반복 루프가 재미있는지 판단하지 못한다. ORDER-08 외부 무설명 테스트가 공개 판단의 필수 게이트다.
2. **오디오 결속감**: 연속 재생과 소유권 감사는 통과하지만, 플레이어가 곡과 효과음이 따로 논다고 느끼는 문제는 실제 청취 세션과 외부 평가가 필요하다.
3. **종료 리소스 경고**: OpenGL ScreenshotQA 종료 때 CanvasItem/Texture/Text RID 정리 경고가 남는다. 실행은 exit 0이며 플레이 진행 오류는 아니지만 `ORDER-18` 기술 부채 감사에 등록한다.
4. **하드코딩**: 이번 결함들은 국소 수리가 가능했으나 MainGame 책임 집중과 표면/수치 상수가 넓게 분포한다. 출시 직전 대수술은 금지하고 `ORDER-18`에서 A/B/C로 분류한다.
5. **실제 Steam 배포**: 로컬 preset과 런타임 계약은 검증했지만 App ID, Depot, Steam 클라이언트 설치, 플랫폼별 깨끗한 PC 스모크는 아직 외부 상태 작업이다.

## 재현 명령

```bash
GODOT=/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot

env HOME=/tmp/gangnamdream-demo-check \
  "$GODOT" --headless --path . res://tools/DemoBuildCheck.tscn -- --demo-build

env HOME=/tmp/gangnamdream-demo-input \
  "$GODOT" --rendering-driver opengl3 --path . --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=demo-input --lang=en --demo-build

env HOME=/tmp/gangnamdream-demo-blackbox \
  "$GODOT" --rendering-driver opengl3 --path . --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=demo-blackbox --lang=ko --demo-build
```

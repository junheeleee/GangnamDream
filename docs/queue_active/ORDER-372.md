# Active Queue Spec: ORDER-372

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-372 [P0·수리] 취업 준비 화면의 언어별 글꼴 연결을 고친다

**[~] 2026-09-28 Codex 착수.** 371 첫 간체 실제 실행에서 결과 Label/Button의
font base가 프로젝트 SC 폰트가 아니었다. 글리프 조회가 실패했으나 문자열·배치·
저장 격리는 정상이었다. 첫 실패의 로그/관측/원본 helper는 보존한다. PNG가 없어
화면의 깨진 자형을 시각적으로 보았다고 쓰지 않는다. MainGame의 주입 누락을
독립 점검했고, 전역 fallback만으로 이 consumer의 기본 테마 폰트가 바뀌지 않았다.

## 깊이 3문

1. 없으면: 중국어 결과 번역이 제공된 지역 글꼴 대신 시스템 의존 폴백을 사용한다.
2. 장기 상태: 글꼴 연결만 바꾸며 점수·스트레스·AP·언어 문자열·저장은 불변이다.
3. 경쟁: 이 화면 내부 theme 연결과 전역 theme 교체 중 전자를 택해 파급을 제한한다.

## 소유·비소유

- `/root/compat357`: `scenes/JobHuntMiniGame.gd`의 로컬 font/theme 연결만 수정한다.
- `/root/screen_path_probe`: private `.git/full-game-localization/order372-check.gd`,
  `order372-check.tscn`만 작성한다. 기존 371 작성 helper는 수정하지 않는다.
- root: 큐2파일·이 사양→archive·CLAUDE 현재행·WORK_LOG·생성STATUS,
  신규 `docs/agent_reviews/ORDER-372.json` 및 판정 원장 신규1행,
  private `order372-run.py`, `order372-font-*` 증거·closure helper.
- `/root/r3_route_probe`: 비저자 검수, private `order372-independent-review.json`만 작성.
- FontKit/UIStyle/MainGame·project.godot·locale·인간 원장·과거 증거는 비소유다.

## 한 배치·검증

- 동적으로 생기는 Label/Button이 FontKit의 공유 언어별 font를 상속하도록 연결한다.
  전역 ThemeDB/default theme, 폰트 크기·여백·게임 계산·문구는 변경하지 않는다.
- 371의 같은 모집단 CN/TW 준비48·합성입력4·PNG20을 새로운 출력 경로에서 재검사한다.
- 보충 격리 QA: 같은 JobHunt 인스턴스의 ko→en→ja→zh-CN→zh-TW 변경,
  언어별 resume/interview의 첫 질문 및 준비된 중간등급 결과 = 20화면.
  모든 실제 표시 Label/Button의 프로젝트 font base·문자 지원·가시 경계를 검사한다.
  KO/EN/JA 결과6 PNG를 직접 관찰한다. 직접 준비/종료 호출은 정상 입력 주장과 분리한다.
- 원본 저장·tracked source·helper SHA·실행 전후 신원을 보존하고 bootstrap 이전 격리,
  exact 성공 marker·종료0·stdout/stderr/Godot log error0를 모두 요구한다.
- 독립 검수는 제품 diff·보충 helper 전체·20화면 자료/6PNG와 371 재실행을 읽는다.
  audit_select의 영향 검사를 사용하며 전체/240주/이미 완료한 번역 감사를 반복하지 않는다.

## 경계·규범

물리 입력·인간/원어민·MainGame 진입/AP·실제 타임아웃·다른 해상도·전체 상품은
미관측이다. 공개GO1·인간OPEN45·본편/새package HOLD 유지. 자동 계약 통과는
재미·깊이·문체 판정이 아니다. 이 20화면/6PNG와 파일 소유·순서는 **일회성**이다.

# ORDER-509 — 중국어 추천 우선순위 숫자 오탐 수리

#### [~] ORDER-509 [현지화 수용 수리] 기존 숫자검사1파일 — 2026-10-09

착수 — 소유 tools/zh_translation_audit.py의 기존 숫자 의미 검사와 embedded self-test.
운영 큐/L3·본 사양/완료archive·WORK_LOG·생성STATUS만. 게임원문·번역·원장·
runtime/경제/저장·project.godot는 비소유. 508은 의미검수 GO/공식수용 HOLD다.

## 깊이3문 / 재현 / 최소 수리

- 지우면: 수입0원 탈출이1순위라는 정상 중국어 第一要务를 숫자누락으로 거부한다.
- 독자: full_game_localization check/import와 ZH audit의 실제 번역 수용 게이트.
- 경쟁: 새검사/재사용도구/형식보고를 만들지 않고 기존 의미 숫자분류만 고친다.

508 cn.advice.response의 求职 → 摆脱0韩元收入是第一要务。先做兼职也好는
non-money number sequence changed: ['1'] != []로 실패했다. 비저자가 재현했고
TW 第1要務는 PASS다. 의미를 숫자 표기 형식에 맞추려고 번역하지 않는다.

한국어 명시적 우선순위와 중국어 우선사항의 서수를 같은 값으로 비교하되
삭제·다른순위·중복·음수/양수 부호·돈/횟수/다른 서수로의 변조는 계속 거부한다.
관측 경계 밖 숫자를 전역 삭제하거나 문자열/배치 예외로 승인하지 않는다.
CN저자는 tool1만, TW는 비저자 읽기전용 별도 정상/음성 표본과 현재 source census를 검수.
root가 최종 diff/현 source 영향과 508 공식4배치를 확인한다.

기존 ZH self-test/current·full localization self-test·i18n·공개/legacy demo·
audit 등록/context/queue/diff만 표적 실행. 전체audit/240주·새검사파일/계측/재사용0.
선언commit/push 뒤 구현. 독립수리·검증·main수용 후508을 재개한다.
새규범0/이 범위·절차 일회성. 원어민/실제화면/물리패드 OPEN·출시HOLD다.

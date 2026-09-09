# ORDER-215 — 자각 모달 입력 수리

기준 eb8f7aaa825491905294822c468b1f0820b9f345, 선언
6c8cc6cee0679095c8631cfa4e4418dcb493c4cf. 원격 CI34316116861의 W18 빈
modal_kind 실패는 실제 제목 로그가 없어 소스상 원인 후보로 남긴다. 이번 재현은
그 CI의 전체 입력열 재생이 아니라 career8을 준비한 controlled W17 fixture다.

## 구현과 독립 확인

MainGame은 기존 자각 창과 Continue에 종류·소유 metadata만 추가했다.
점수·산문·효과·주차·라우팅은 바꾸지 않았다. QA는 아래 결과/보드보다 현재 모달을
먼저 판별하고 그 창의 유일한 확인 버튼에 raw South/Enter를 보낸다. 모르는 창,
종류 누락, 잘못된 소유자, 확인 버튼 누락·중복을 통과시키지 않는다.

Rawls 구현·자체 검사 뒤 ROOT가 제품 3파일 diff와 실제 호출부를 읽고 동일한
최종 파일로 KO gamepad 및 EN keyboard component를 각각 실행했다.
Godot4.6.2.stable.official.71f334935, Apple M1 Max/OpenGL 환경이다.
8→12에서 자각 확인 동안 상태 불변, 이후 결과 한 번·신청 영수증 한 개·W17→18,
4→8에서는 모달 없음, malformed6 반례를 두 장치에서 확인했다.
stdout와 각 격리 Godot log 모두 아래 성공 marker 및 오류0이다.

`CORE_LOOP_V2_MODAL_PRIORITY_OK ... fixture=controlled-w17`

| 입력 | 로그 bytes | stdout/Godot log SHA256 |
|---|---:|---|
| KO gamepad | 5565 | a3f6703630096cc978749a9660c5a267b00dea3c1caede9c9473b6a5415874a0 |
| EN keyboard | 5567 | d1b1700112c993d6053ccca5a4ba77bb2296a2115876f3763e55578084a4f107 |

ROOT 로그는 원본 저장소 `.git/full-game-localization/order215-root-{ko,en}.log`다.
구현 동결은 `.git/worktrees/checkout2/full-game-localization/`의
order215-implementation-final.json 12389B /
b8490b92147e41f3d3b9651d7af904658e95acc1159f402be9877cbca6252136이다.

검토한 제품 SHA256:

- MainGame.gd: 77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd
- ScreenshotQA.gd: 155870fb95722cbd1ca8ac01c5a4df414567a5190f48395f7dbe078c5e9b4b19
- wrapper: ede5607f0413a32d1983e5a54f2731e7e73e6a5c58999136b75fbed4fd0a56bc

## 경계와 남은 마감

초기 자체 fixture의 잘못된 tendency_score 속성과 JSON 주차 비교 실패는
수리 전 실패로 보존했다. 성공 marker만으로 앞선 실패를 지우지 않았다.
shell syntax·context·queue·diff 통과. 병렬 변경을 좁은 차선의 소유 범위로
확장하지 않으며, 통합 뒤 명시 차선 결과는 아래 후속 마감에 기록한다.
fresh24주/240주·원격 CI 전체·인간 독해·물리 패드 조작감·재미 GO는 미판정이다.
공개 M01~M06 GO는 보존, 본편 HOLD. 이 오더의 절차·범위는 일회성이고
지속 입력 규칙은 기존 INPUT_UX의 의미 입력 소유를 따른다.

# ORDER-494 — 중국어 V2 결산 UI25키

#### [~] ORDER-494 [전체 현지화] CN/TW 결산·옛 저장 설명50값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json의 신규25키씩,
content/meta/full_game_localization.json의 해당50영수증·배치1. 운영 파일은
큐/L3 이어보기·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
도구·원문·런타임·기존 번역·새 formal 검수/판정원장은 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 기존 V2 결산의 끝낸/대신 남긴/기한지난 일과 옛 저장 누락의 구분,
  닫힌 시점 현금·고정비·다음 목표·월별 기록25키가 중국어에서 영어로 폴백한다.
- 독자: MainGame._core_loop_v2_completion_view_model25호출과 옛 completion5·
  month_summary1 공유호출, LocaleManager.ui→지역 사전. 실제closing_state와
  legacy_boundary_incomplete 분기가 누락을 추정하지 않는다는 의미를 지킨다.
- 경쟁: 현재29/29context·JA전체기존값·공개M01~M06를 보존한다. 이 화면은 기존
  V2호환 결산이지 StoryMode 신규 기능이나 M60엔딩이 아니다. 수용25키만 닫는다.

## 정확 선택25

- %d개월 끝의 흔적
- %d개월차
- %d개월차 · %d–%d주
- %d주차 결산
- %d주차에 결국 한 가지를 끝냈다. 그 선택 때문에 남은 일과, 지난 %d개월 동안 여기까지 온 기록을 함께 확인한다.
- 24주차에 남아 있던 일은 옛 저장에서 복원할 수 없다.
- 24주차의 마지막 선택은 기록에 남아 있지 않다.
- 결과를 짐작해 채우지 않았다. 남아 있는 월별 기록만 확인할 수 있다.
- 고정비
- 기한이 끝난 일
- 끝낸 일
- 내가 먼저 건넨 연락
- 누가 먼저 연락했는지는 당시 기록에서 복원할 수 없다.
- 다음 재정 목표
- 달성까지 %s
- 대신 남긴 일
- 서울에서 보낸 스물네 주
- 여섯 달은 민준의 삶을 해결하지 않았다. 다만 끝낸 일과 남겨 둔 일의 값을 한 페이지에 올려놓았다.
- 옛 저장
- 월말 정산 후
- 이 달의 누락 기록은 옛 저장에서 완전히 복원할 수 없다.
- 종결 시점 기록 없음
- 종결 현금
- 첫 달 제안의 결론은 당시 기록에서 복원할 수 없다.
- 첫 달에 내린 결정

## 실행 / 검증 / 경계

지역별 저자 둘은 KO 직접 private response만 소유한다. root는 선언commit/push 뒤
기존 공식 export/check/import, 원영수증 header/SHA·source/target 원장 결속을 한다.
비저자는 KO/31실제소비자·50값·원영수증·기존4파일 raw 역상·실제Git source를
메시지로 검수한다. 새 도구/보고0·새규범0·절차 일회성이다.

기존 ui_translation_append·현재 원장·EN/Hangul·JA UI·ZH·i18n·보호 데모 영향만.
게임원문·결산/저장/엔딩동작 변경0이므로 전체 local audit/엔진240주/새 계측0.
Mac잠금으로 실제폭/입력은 미관찰/OPEN, 원어민·물리패드·전체출시HOLD다.
project.godot·사용자 저장·shipping language·공개 데모·역사 인간판정은 불변이다.

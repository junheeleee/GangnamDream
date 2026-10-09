# ORDER-492 — 연락 휴대전화 중국어 UI25키

#### [~] ORDER-492 [전체 현지화] CN/TW 연락 화면의 영어 폴백50값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json의 신규25키씩,
content/meta/full_game_localization.json의 해당50영수증·배치1. 운영 파일은
큐/L3 이어보기·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
도구·원문·런타임·기존 번역·새 formal 검수/판정원장은 비소유다.

## 판정 단위 / 깊이3문

- 지우면: CommunicationPhone의 통화/문자·받은 연락·실제 연락처·일정 이동과
  연락수단 설명25키가 두 중국어 지역에서 영어로 나온다. 현재 collector의
  builtin_overlay_static_only/protected=false이며 두 target에 모두 없다.
- 독자: MainGame의 기존 V2 휴대전화 open/offer_requested → CommunicationPhone의
  ui/ui_context/ui_format → LocaleManager의 built-in dictionary. 말뜻을 바꾸지 않고
  실제 번호/대화방을 얻은 사람만 표시하는 상태와 기록/일정 가능 여부를 구별한다.
- 경쟁: 일본어에는 해당25값이 이미 있으므로 바꾸거나 재수용하지 않는다.
  이름·동적 대화본문/계획판 전체·새 UI는 이 묶음에 넣지 않는다. 효과/저장 변화0.

## 정확 선택25 / 실행

연락; %s/%s 탭 · %s 뒤로 · P/%s 닫기; 대화; 연락처; ui.phone.title;
이번 달 받은 연락 · %d; 새로 받은 연락이 없다;
문자나 통화가 아닌 제안은 넓은 계획판에서 확인한다.; 통화; 문자;
이번 달 통화 기록; 이번 달 받은 문자; 일정에서 보기; 지금은 일정에 넣을 수 없음;
이 대화는 기록으로만 남아 있다.; 실제로 연락할 수 있는 사람 · %d;
저장된 연락처가 없다; 직접 번호나 대화방을 얻은 사람만 여기에 남는다.;
이번 달 연락 일정 없음; 저장된 전화번호; 카카오톡 대화방; 받은 명함의 번호;
연락수단 없음; 일정 보기; 알 수 없는 발신자.

한국어 직접 CN/TW 독립 저작자 두 명은 각각 private response만 소유한다.
root는 선언 commit/push 뒤 기존 공식 export/check/import를 실행하고 원영수증
header/SHA·source/target 해시를 원장에 결속한다. 비저자는 실제 원문/소비자·50번역·
원장·기존 바이트 보존을 메시지로 검수한다. 새 도구/보고0. 새규범0·절차 일회성.

## 표적 검증 / 경계

기존 ui_translation_append의 명시 전후50추가/원영수증·Git source manifest·raw 역상,
현재 full_game_localization 원장, EN/Hangul·JA UI·ZH·i18n·보호 데모 영향 검사만.
컴파일/저장/엔딩/스케줄러 변경0이므로 전체 local audit/240주 반복0.
Mac 잠금 때문에 실제 화면은 미관찰/OPEN이며 원어민·물리패드·출시 claim도 OPEN/HOLD다.
UI25키 수용만 닫고 넓은 ORDER-157 전체완료나 연락 화면 전체번역으로 확대하지 않는다.
project.godot·사용자 저장·공개 M01~M06·shipping language·인간 판정은 불변이다.

# ORDER-492 — 연락 휴대전화 중국어 UI25키

#### [x] ORDER-492 [전체 현지화] CN/TW 연락 화면의 영어 폴백50값 — 2026-10-09

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

## 수용 결과 — 2026-10-09 / 텍스트 범위만 GO

선언79f69c0 → 제품061d7b7f6a5b8d334779fb70976982391a7f9174를 main commit/push했다.
CN/TW 저자 둘이 독립 KO 직접25씩 작성했다. 비저자가 KakaoTalk도 읽는 문자를
SMS로 한정한 TW3값을 지적해 訊息으로 수리한 뒤 공식 check/import25씩 PASS다.
UI1827→1852씩/JA3055 불변; 정적ZH legacy1620→1644/2952·context11→12/29,
accepted41887→41937·batch287→288이며 전체 INCOMPLETE다.

기존 append raw 역상·현재50 source/target/overlay/receipt·공식header2/SHA2 PASS.
비저자의 actual Git current_proof는 base7df56fd→제품061d7b7 transition1/50추가만,
실제 선언Git의 source manifest와 현재 b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea
일치·옛 UI/원장 원바이트 유지다. 최종 메시지 scope GO/blocking0·새 formal 보고0.
EN/Hangul·JA UI·ZH·i18n·multilingual·공개storydemo·legacy demo 범위 영향검사 PASS.
새 도구/전체 local audit/엔진/저장 실행0이다. 이 전화는 기존 V2 소비자이며
StoryMode의 새 기능·동적 메시지 전량 번역을 주장하지 않는다. 렌더/원어민·전체 출시
HOLD는 그대로다. 새규범0·절차 일회성, 넓은 번역 규칙은 기존 I18N 정본에 이미 있다.

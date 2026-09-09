# ORDER-209 L1/L2 수용 기록

전체판 INCOMPLETE/HOLD, 공개 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.
이 문서의 수용은 번역 원고·기계 회귀의 수용이다. 원어민·화면·정상 속도 인간 플레이는 수행하지 않았으며 native/render/L3 OPEN이다.

## 범위와 저작

기준 완료 소스 `2b308511eed0e568a2feba5ae4b191a6f2477499`, 선언 `01216fbceea5d1f34a4b265eadb33654728c9898`.
기존29,952(각9,984)/b71/meta9를 보존하고 A19종122문구·B20종120문구를 직접 한국어에서 세 언어로 저작했다.
새39종242문구/locale·726번역·27새파일, 82선택·KO12,174자·LF401/name0.
전체 source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`와 KO9는 불변이다.
source aggregate A `8239f4eb25416708cfeccab40c110acbc07b060671e1cf2830be88cea4d44a70`,
B `c0a80954741d68704a3719cf24814e53cf9dddd2c2e98ba6f1ba02034172bc4a`,
전체 `11ccf0332dc3b322c7bc5a5bb22e0296ffcf1aa19212318c923141f8549960d3`.

JA 자기정밀7·CN5·TW12는 저자 동결 전이며 독립 L2에 합산하지 않는다.
독립 L2는 JA Plato242·CN ROOT242·TW Poincare242 전수다.
독립 대조와 추가 원문 확인으로 JA4·CN6·TW4, 총14문구를 정밀화했다.
- 본전 생각·참고만 한다는 태도·음식보다 따뜻해진 마음의 비교를 원문대로 분명히 했다.
- 미세먼지를 PM2.5로 좁히지 않았고, 동해는 한반도 동쪽 해역으로 설명했다.
- 사주의 생년월일 질문 주체·친척 호칭·한국 시장의 구조적 디스카운트를 정밀화했다.
- 5초 만의 매진을 5초 이내로 확대하지 않았고, 수능 날짜의 셋째 **주** 목요일을 JA/CN에 명시했다.

정확14곳을 역치환하면 저자 동결27파일의 raw가 일치한다. 나머지712문구와 기존29,952는 그대로다.
최종 target 동결 v2 197,647B SHA `cf075c2e9758ec415056b326c55dc7674d9622eeb743cba1e1b2af413e4d8702`.
신규242/locale record SHA:
- JA `326baf12aba4f5cabfc99d6e27f52d4f57e5e489842f2a7be67f0543759a59a4`
- CN `2ab5da1a5c15812fa8dd9bf21f7c5f4066a28a1d8938275e3febab14e791aed6`
- TW `1e44004165da5ee29a7268a4b3a45bd8ba25fa6027a80deef2dd6fe06ad93e14`

실제 답장·등록·수업·만남과 제안·개인 목표·전해 들은 주장을 구분했다.
현재 뉴스·제도·가격·확률로 재작성하지 않았고, 조건·시점·금액/효과의 KO 간극도 수리하지 않았다.
자세한 사실 경계는 [활성 사양](../queue_active/ORDER-209.md)이 소유한다.

## 가드 최초 독립 검사와 한계

원문 전체에 결속한 좁은 숫자/금액/시간/단위/호칭 문법만 보강했다.
타깃 완성 문장 목록이나 event ID 전체 면제는 쓰지 않았다.
새 원화 합성액·비화폐 수량·시각·차수·비연애 남성 호칭을 구분하며 기존 전역 검사를 보존했다.

B1 실제 신규726의 L1·source/target hash 오류0.
B1 사전 봉인 ROOT12쌍은 정상9/12·변조9/12거부, Plato10쌍은 정상5/10·변조10/10거부였다.
정상문도 거부된 쌍은 의미 분리 성공으로 세지 않았다.
ROOT에서는 일본어 19:30 표현·중국어 배달 금액 역할·밈 수량/서비스 표현의 오탐과
게임 판수·추가 노래 수·암표 배수 변조의 누락이 드러났다.
Plato에서는 일본어 모임/삼분의 일/노래방 가격 문법과 중국어 배달/회원·댓글 표현의 오탐이 드러났다.
Plato의 변조10거부 중 typed 식별6과 동일 오탐/원문 fallback4를 구분했다.

ROOT 원본15,933B SHA `1eabc34a1ab6cde1d4e57a8638528b2e6b4d72bb99cdefdd3fa1d290ac8adfb7`,
Plato24,468B SHA `162b778379148fbb4a9f1d2ec5317fc9e0cf0218a74895435e385d5133fb91a6`는 변경하지 않았다.
B1 결과는 보존하고 공개 후 수리는 B2 회귀로 따로 기록한다. 재검을 새 블라인드 시험으로 부르지 않는다.

JA B1 전체 self221=기존216+5 PASS. 자체152는 정상34·target84·source-OFF34다.
target84는 typed71·호칭6·newline-only6·잘못 만든 fixture1로 분리했다.
마지막1은 코시원 표기를 바꾼 입력이어서 금액 단위 검출의 성공/실패로 세지 않았다.
별도 올바른 통화변조1과 자연문법16은 독립 검사와 합산하지 않는다.
ZH B1 self10,529=기존9,977+552 PASS. 자체552는 실물72·자연52·target344·source-OFF72·변경원문 E2E12다.
Source licence OFF와 의미 오류 E2E 거부는 서로 다른 증거이며 기존 한계가 남는 경우를 숨기지 않았다.

기존 JA 함수는 translation_errors의 연결부 외 AST가 그대로이고 기존216 검사 본문을 보존했다.
ZH 기존 focused39·상수137 AST가 그대로이며 새 helper/data와 연결부를 역치환하면 baseline AST가 일치했다.
교차 코드 검토에서 전역/전체문장 우회는 없었다. 수능 주 단위 생략 허용은 B2 대상에 별도 기록했다.
기존 가드가 source 밖에서 임의의 모든 자연어 오류를 검출한다는 주장은 하지 않는다.

## 최종 검증과 수용

공개 후 B2에서 동일 ROOT12쌍은 정상12/12·변조12/12거부, Plato10쌍은 정상10/10·변조10/10거부다.
Plato target변조8은 해당 값/단위/역할로 거부됐고 source-OFF2는 기존 fallback 진단이므로 그 한계를 그대로 구분했다.
JA 공개8쌍(정상8/변조8)은 신규 typed6/기존 generic2로 분리했다.
ZH 기존 focused552의 원본은 보존했으며, 잘못된 CN ‘세 번째 목요일’ 정상1을 현재 ‘셋째 주 목요일’로 정밀화한 테스트와 추가8을 포함해 focused560이 됐다.
공개28 및 주차/노래 수/암표 배수/경계28, 합56을 더해 전체 self10,593=기존9,977+560+56이다.
JA 전체 self222=기존216+B1 5+B2 공개회귀1이며 원본 자체169의 결과/한계는 B1과 같다.
본 검사는 일반 자연어 검증 완성이나 새로운 독립 블라인드·원어민 평가가 아니다.

최종 도구 지문:
- full141,446B SHA `d46d3f9cf521b07dd319df82072f52f5061a188f2cd8c8d7e5a573880774550b`
- self395,134B SHA `37945ccb96ea66e2e9ea3f5cc8ced07bf7adcf6112b3290e6e44ef9c36554adf`
- ZH899,159B SHA `025c9528ca5ddcd40d4d4c40bd81f579f9620898597438a328ddf63cbdfca1d3`

초기6은 A123행/B121행으로 각source122/120와 previous-null을 저작 전에 봉인했다.
최종 v2 source6/response6/check6/import6가 모두 PASS이며 changed_files=0이다.
앞선 최종 v1 export6은 마지막 날짜2문구 정밀화 이전본으로 남기고 수입하지 않았다.
독립 교환 전 검토60입력 seal `b8bd4c3294084d6dc5397195baaa56cc331e23ef0d4a864842bee1fe500ba680`에서 source/response/current726와14정밀화/712불변/역치환27을 확인했다.
수용 후 receipt6·portable·현재 번역의67입력 seal `f5313d5ab9beba6fa3b66bd6ae36f8a0a0bf5699f6c74f2155298e91e775876b`도 전후 일치했다.
기존29,952의 값·키순서·상대순서와71배치, 메타9 및 다른16개 최상위 필드는 그대로다.

최종30,678(각10,226)/b73, 사건1,344종9,158문구·엔딩35종234문구·catalog834/locale.
전체30,678 source/target hash 및 L1 오류0, 입력42개 전후 불변이다.
portable7,970,460B SHA `1a69e382559f13bc05804a452b5e12315d0236e59a051ea3ebe43bcef5668446`;
accepted SHA `5ea879a1076fd5972c43cf2611a02e108e27d6a0f7fb203da4e72437250b7bd5`.

## 회귀·보존·다음 작업

명시 full-game-localization-overlays 차선12개를 --list로 확인한 뒤 모두 PASS했다.
source-scope52·full self222·JA pipeline69·ZH self10,593·공개 story-demo 본검사/변이4 PASS,
audit.py ERROR0/WARNING0, EN strict1,813/1,813사건·35/35엔딩 및 별도 EN 누출검사 PASS다.
scope139·context321문서·queue72행/진행70과 diff --check도 PASS다.
skeleton1,358종은 수용1,344종과 기존 공개14종이며 전체 제품 번역 완료 수가 아니다.
ZH legacy/full 글꼴의 shared_han_jp_first=1/blocked 진단은 그대로 남겼다.
이번 skeleton/self 통과를 중국어 전체 런타임 글꼴·렌더 준비 완료로 바꾸지 않는다.
정확41소유경로·비소유변경0을 ROOT가 확인했다.
WORK_LOG에 이번209절만 추가하고 완료206절1,206B
SHA `6ac630abd3b2f2bc0e0e51b57012556c40748fe74dc4cc413d36709dcf6c4756`만
9/7 history 앞으로 그대로 옮겼다. 기존61,095B 전체와 끝 LF2는 보존됐다.
history62,301B SHA `f67c78c1be192042b45436d76c4ffd39edddbc0748793b756054d033371a16fc`.
큐의 이전71개 행은 내용·상대순서를 보존하고 이번 행만 L3 OPEN으로 추가했다.

긴 유니코드 private 검사 스크립트의 직접 실행이 디코딩 오류를 내면 입력 바이트를 먼저 확인하고,
동일 UTF-8 코드를 읽어 compile해 실행한다. 이때 번역·fixture·판정 기준은 바꾸지 않는다.

KO/EN·조건·효과·라우팅·runtime·public·font·save·human_gates 변경0.
전체 audit·Godot·240주 자동 주행·원어민 평가·신규 인간 GO는 실행하거나 발급하지 않았다.
main 통합은 완료된 개발 소스의 정리이며 출시 후보나 인간 판정 승격이 아니다.
다른 브랜치·worktree는 삭제·리베이스·혼합 병합하지 않는다.
다음 도시 휴식·도박의 비용·달라지는 우정39종은 독립 사전검토까지 마쳤으며 별도 선언/초기봉인 뒤에만 저작한다.
남은 shipping 사건364종2,522문구와 UI·표시 소비자는 별도이며, 이 수를 전체 게임 번역 완료라고 부르지 않는다.

## 규범 판정

범위·지문·소유권·수용 수는 이번 묶음의 일회성 계약이다.
직접 원문 번역·text-only overlay·수용과 사람 판정의 분리는 기존
[I18N_INFRASTRUCTURE](../I18N_INFRASTRUCTURE.md)가 소유하며 새 지속 규칙을 만들지 않는다.

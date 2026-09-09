# ORDER-220 — 선택 미리보기 언어 소비자 검토

> 진행 중. 저자 component 완료이며 ROOT 독립 실행·guard 최종 차선 전이다.

## 실제 제품 변경

MainGame _choice_effects_preview에4줄124B만 추가했다. health와 mental에만
기존 _tr를 호출한다. KO/EN·돈·stress 반전/합산·부호·0 필터·순서·다른 stat 숨김,
입력·원고·상태·레이아웃은 그대로다. JA 사전의 健康/精神을 이제 소비하며,
해당 키가 없는 CN/TW는 기존 Health/Mental fallback을 유지한다.

전1139343B/77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd,
후1139467B/5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88.
삽입한 정확 hunk 하나만 역제거하면 전체 raw가 복원된다. ROOT가 실제 diff를 별도로 읽었다.

## 자가 component와 실패 보존

Rawls는50개 기대값을 코드 전에 봉인하고, 선언의 재선택·community/부분키
추가14를 component 전에 별도로 봉인했다. 첫50 proof의 PRE_DECLARATION 문구와
실제 선언 HEAD8360의 동시성은 정정한다. 정확한 주장은 제품 수정 **전** 봉인이다.
원형50 proof는 덮지 않았고 추가14를 원래50이었다고 쓰지 않는다.

새 검사는 실제 MainGame을 격리 초기화하고 _render_event→_finish_typing→
_reveal_choices가 만든 Label.text를 읽는다. 수작업 Label이나 helper만의 검사가 아니다.
실제 Label44개·의도된 무표시20개, dictionary와 명시 game state64개를 비교했다.
1280×800 headless component이며 렌더·전체 플레이·물리 입력 주장은0이다.

1. 첫 실행: 검사 코드 예약어 namespace로 parse error. timeout 안전 종료·로그 보존.
2. 변수명을 qa_namespace로 수리한 같은64: 문구64 PASS지만 SC/TC fontdata 캐시
   부재6 ERROR로 wrapper FAIL. exit0와 성공 marker만으로 통과시키지 않았다.
3. 허용된 격리 import1회로 로컬 캐시를 준비했다. font 원본2·.import2·project.godot·
   bootstrap·제품5·git status는 전후 exact, 새/삭제 UID0이다. editor 종료의 RID/ObjectDB
   오류는 cache 준비 관측으로 보존했고 품질 PASS에 합산하지 않았다.
4. 같은64 최종 자가 실행: Godot/wrapper exit0, 두 로그 오류0·64 PASS.
   기대값과 MainGame은 첫 동결 그대로다. 원래50/추가14·실패·재검을 독립 표본처럼 더하지 않는다.

private order220-author-component-final.json134608B/
d8632afa883b625f7539e423d3b048689260db0736b3dab3b258bad4c5bd990e에 모든 원형이 있다.
새 script15525B/59b537a380f0e7dea22fd2fdc3e66bc4e4be38acd072c742902917fb7e36db23,
wrapper5999B/addf9068790b76ac261efe0ed7086e34038fb781da10753e8e4fbd5b0fda5c05.
ROOT는 component/script/wrapper 전량을 직접 읽었고 별도 실제 실행은 최종 차선에 둔다.

## 역사 지문 연결과 한계

새 MainGame N을77c690으로 정확 역투영한 뒤 기존215 3e15와 앞선 역사 체인에 잇는다.
현재 raw를 먼저 검사하고, 과거 바이트로의 rollback은 현재 승인으로 받지 않는다.
옛 manifest·pin·validator·assert는 바꾸지 않고 명시 관측 hook만 역치환으로 검증한다.
자가 유한26/guard와 ROOT 별도12/guard의 실행 결과는 최종 동결 뒤 기록한다.
기존487/564 전체 self는 저자 단계에서 반복하지 않으며 최종 차선 한 번에 둔다.

Poincare 자가 신규26/guard와 기존 modal27/guard는 통과했다. 앞선 불일치 각2를
원형 보존했으며 전체 self를 아직 실행하지 않았다. ROOT는 실제 두 diff 전체를
읽고 코드 전 봉인한 별도12/guard를 실행해24/24 통과했다. 비소유 key·부호·0필터·
간격·갯수·CRLF·경로와 과거 rollback은 투영하지 않고 거부했다.
명시 새 block/관측 hook만 역제거해 두 이전 파일의 whole raw/AST exact,
옛 assignment·modal validator3개 AST exact와 보호12입력 불변을 확인했다.
이는 새 가드의 독립 정적 검수이며 아직 최종 전체 self나 실제 게임 실행을 대신하지 않는다.

기존 causal coverage gap/blocked·인간/원어민 OPEN은 그대로다. 새 작업 GO는
독립 검수와 정확 source가 결속된 뒤만 기록한다. 본편 전체·공개 출고는 HOLD다.
지속 언어 규칙은 기존 I18N 정본, 이번 정확 소유·절차는 일회성이다.
자동 게이트는 도달성과 계약 증거이지 재미·깊이·문체의 증거가 아니다.

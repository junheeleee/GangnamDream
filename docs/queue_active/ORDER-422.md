# ORDER-422 — 구직 선택 수량과 절약 범위 검사 오탐 수리

#### [~] ORDER-422 [P1·검수] 한 길·두 길과 3만~10만원을 정확히 비교한다

**[~] 착수 — 2026-10-04.** 421 최초 공식 check21.036초 FAIL을 보존한다.
A17 두 지역에서 source ‘두 길’을 읽지 못했고, B21 번체에서 source 공유 원화
단위의 하한3만원을 숫자3으로 분리했다. 간체 B21 PASS도 하한금액 검증의 증거가 아니다.

## 모집단·파일 소유

- exact UI source/key2:
  `하나를 택하면 다른 두 길은 이번 주에 닫힌다.`
  `지출 3만~10만원을 막는다`
- 421 두 지역76초안/source/response 원본 불변. 번역을 수사 삭제나 단위 생략으로
  바꿔 통과시키지 않는다. 실제 선택 경쟁1/2와 절약30000~100000원 의미를 보존한다.
- /root/receipt_bridge392: tools/zh_translation_audit.py exact adapter/연결,
  tools/employment_choice_number_self_test.py 새 focused,
  tools/audit_scope.json 새 owned lane/등록만. generic 수사·금액·역사 tests0.
- Root: 큐·본사양·CLAUDE·WORK_LOG·생성STATUS·보고/판정원장·archive,
  private421-r1 공식교환/후보결속 helper. 기존 실패·export·response·과거봉인본0수정.
- /root/independent392: 독립 원문/수리/반례/공식교환·normal·최종421/422 보고.
  /root/receipt_tests392는 기존421 화면·입력만 소유하고 checker를 수정하지 않는다.
- 사전조건/게임플레이/KO/EN/JA/폰트/Main/인간원장/공개demo/project.godot 수정0.

## 수리·검수 계약

- locale CN/TW·정확 source와 escaped UI key가 모두 맞을 때만 활성화한다.
  숫자의 역할과 지역 단위를 국소 결속하며 원문/화면에는 normalized 비교문을 쓰지 않는다.
- footer의 선택1/닫히는 나머지2를 서로 바꾸거나 누락·중복·다른 위치 숫자로
  빌려 쓰지 않는다. 기존 제목 두 길 사이와 generic 동작을 바꾸지 않는다.
- 절약 range 양 끝30000/100000과 범위 의미·원화·부호를 검사한다.
  한 번만 적힌 공유 단위와 양쪽 명시 단위가 같은 값이면 허용하되
  뒤집힌 범위·상하한 변조·합계/개별 두 금액 치환·통화변조·중복은 거부한다.
- source/key/group/locale 경계, 직접 validate_text와 공식 Leaf validator 연결,
  숫자 외 placeholder/script/newline/currency 검사 유지의 focused 반례를 봉인한다.
- 421 firstcheck원본을 false로 보존. 영향A17×2/B21×2를 동일76응답으로 새 checker에서
  확인한다. CN B도 수정된 range 해석의 영향이 있어 재검수하며 새 export0.
- 새 focused와 정상13은 최종421후보에서 공유1회/최대3병렬. 기존 focused/full/240주0.
  실제화면8/키보드32taps는421가 소유하며 checker를 실제 제품입력 판정으로 대신하지 않는다.
- 일회성 오탐수리·기존 정본 적용, 새 상시규범0. 자동PASS는 문체·재미·출시GO가 아니다.
  공개GO1·인간OPEN45·본편/새packageHOLD·원어민/인간/물리미관측을 보존한다.

# Full-game localization — remaining scope

2026-09-07 사용자 직접 지시로 M01~M60의 일본어·중국어 간체·번체 번역을 시작한다.
현재 실행 배치와 우선순위는 `../CODEX_QUEUE.md`, 지속 규칙은
`../I18N_INFRASTRUCTURE.md`가 소유한다. 이 문서는 큰 활성 오더가 아니라
누락 없이 후속 15~25단위 배치를 고르는 전체 범위 지도다.

- 사건: 기존 text collector는 packaged 1,813개/12,415 leaf, shipping
  1,708/11,674와 author-only 105/741이다. 여기에는 Chapter5 reader 133개가
  포함되지만 실제 결과에 표시되는 `choices[].foreshadow` 6개가 누락됐다.
  본편 사건 번역 분모는 이를 포함한 최소 12,421 leaf로 보강한다.
- 엔딩: 35개/268 leaf, 조건별 변형을 포함한다. 첫 배치의 세 root 이후 나머지를
  누락 없이 원문 대조한다.
- catalog: assets/jobs/items/achievements/clues/thoughts/news 7섹션/834 leaf.
- UI: 정적·문맥 key와 동적 pair를 합집합으로 계측한다. 기존 demo 동적 701키만
  본편 전체 동적 분모인 것처럼 사용하지 않는다. 현재 정적/문맥 2,864와 demo
  동적의 합집합은 3,556키, 전역 미확정 후보 329를 더한 포착 분모는 3,885키다.
  JSON 계약·관계 표시 이름·독립 이름표·분기 조립문까지 확인 전에는 이 수를
  최종 전체 UI 분모라고 부르지 않는다.
- runtime: 대상 언어 overlay가 모든 수집 필드를 실제로 읽는지, 조건별 reader,
  돈/이름/주거/뉴스/연말/후일담의 영어 직행 경로가 남는지 별도 배치에서 수리한다.
  확인 대상 직접 영어 분기 13곳과 `relationship_effects[].name` 표시 21곳
  (고유 이름 14개)을 추적한다. 넓은 `is_english()` 탐지 22곳에는 함수 정의도
  들어 있으므로 전부 실제 누출 분기로 세지 않는다.
  기본 내장 overlay는 Chapter5 reader를 지원하지만 커뮤니티 sanitizer는 별도다.
  기존 i18n skeleton 검사에서 JA/ZH reader 누락을 허용하는 경로는 full strict
  완료 근거로 쓰지 않는다. 중국어 CJK AUTO 속도 분기는 이미 정상이다.
- 현재 수집된 전체 leaf는 17,408이다. 그중 기존 정적 계약 지원 17,073,
  foreshadow 정적 validator 미지원 6, 소비자 미확정 329를 분리한다. 관계 표시명
  21위치는 이 leaf 분모 밖 미지원이다. JSON pair 미해석 138건은 진단이지
  번역문 138개가 아니다. 이 수들을 더해 허위 전체 커버리지를 만들지 않는다.
- 엔딩 `with_daeun`, `late_call`, `instant_legend`의 언어별 25 leaf는
  한국어 직접 대조·기계 검사 후 source/target 해시로 수용했다. 초반 이후 8개
  root도 언어별 94 leaf를 수용했다. 총 신규 357문구이며 전체판 완료가 아니다.
  다음은 미번역 엔딩과 조건별 후일담이다. 두 배치 모두 원어민·화면 검수 OPEN.
- QA: source/target 완전성, 지역 문자·금액·토큰·문단, 한글/영어 누출, save/resume,
  지역 primary 폰트, 1280×800/960×600 실제 화면을 대상 언어별로 검증한다.
- 출시: 번역 텍스트 수용은 원어민 자연스러움이나 본편 재미 GO가 아니다. 기존
  M01~M06 공개 데모를 덮지 않고 별도 전체판 후보에서 검토한다.

배치마다 완료·미완료·source 변경으로 낡은 번역을 분리한다. 한국어에 새 텍스트가
생기면 그 source hash만 재번역 대상으로 되돌린다. 영어 중역이나 간번 문자 변환을
새 독립 번역으로 세지 않는다.

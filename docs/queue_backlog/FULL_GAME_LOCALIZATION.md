# Full-game localization — remaining scope

2026-09-07 사용자 직접 지시로 M01~M60의 일본어·중국어 간체·번체 번역을 시작한다.
현재 실행 배치와 우선순위는 `../CODEX_QUEUE.md`, 지속 규칙은
`../I18N_INFRASTRUCTURE.md`가 소유한다. 이 문서는 큰 활성 오더가 아니라
누락 없이 후속 15~25단위 배치를 고르는 전체 범위 지도다.

- 사건: 기존 text collector는 packaged 1,813개/12,415 leaf, shipping
  1,708/11,674와 author-only 105/741이다. 여기에는 Chapter5 reader 133개가
  포함되지만 실제 결과에 표시되는 `choices[].foreshadow` 6개가 누락됐다.
  본편 사건 번역 분모는 이를 포함한 최소 12,421 leaf로 보강한다.
- 엔딩: 35개/234 번역 leaf, 조건별 산문 변형을 포함한다. 최초268에는 실제
  화면에 안 나오는 작성 메모 condition34가 섞여 있었다. 이 메타를 제외하고
  원문 도달·화면·자연스러움은 별도 검사한다. 실제 결말 판정 로직은 변경0이다.
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
- 현재 수집된 번역 leaf는 17,374다(최초17,408에서 비표시 엔딩 메타34 분리).
  그중 기존 정적 계약 지원 17,039,
  foreshadow 정적 validator 미지원 6, 소비자 미확정 329를 분리한다. 관계 표시명
  21위치는 이 leaf 분모 밖 미지원이다. JSON pair 미해석 138건은 진단이지
  번역문 138개가 아니다. 이 수들을 더해 허위 전체 커버리지를 만들지 않는다.
- 엔딩 `with_daeun`, `late_call`, `instant_legend`의 언어별22 번역 leaf와
  초반 이후 8개 root의 언어별94 leaf를 수용했다. 최초357 중 비표시 메타9를
  별도 해시 보존해348번역으로 정정했다. 일상·안정·회복14종83 leaf/locale도
  독립 대조·수용했다. 남은 엔딩18종129 leaf/locale도 전수 대조·수용해 현재
  catalog834 leaf/locale도 전수 대조·수용해 총3,486번역이다(언어별 엔딩234+
  사건94+catalog834). catalog 신규 작성2,485·기존 JA 누락 수리1·기존 유지16을
  구분한다. 엔딩35종과 catalog7섹션은 채웠지만 사건·UI·표시 소비자는 아직
  남는다. 원어민·화면·전체판 완료는 OPEN.
- 다음 runtime 수리의 실제 소비자: `GameState.apply_relationship_effect`는 원문
  이름을 저장하고 `MainGame:9852/18298`, `RelationshipSystem:30/50`이 그대로
  표시한다. 저장 값을 바꾸지 않는 locale 표시 resolver가 필요하다. 또한
  `MetaProgression._localized_title`, `GameState.tendency_name/tendency_desc`,
  `_localized_route_label/_localized_profile_label/_roll_run_theme`,
  `MainGame._choice_effects_preview`, `HoldemClub._fmt`의 non-KO=EN 분기를
  개별 표시 계약으로 검사한다. 번역 파일만 채워도 이 소비자는 저절로 바뀌지 않는다.
- QA: source/target 완전성, 지역 문자·금액·토큰·문단, 한글/영어 누출, save/resume,
  지역 primary 폰트, 1280×800/960×600 실제 화면을 대상 언어별로 검증한다.
- 출시: 번역 텍스트 수용은 원어민 자연스러움이나 본편 재미 GO가 아니다. 기존
  M01~M06 공개 데모를 덮지 않고 별도 전체판 후보에서 검토한다.

## 원문 대조에서 발견한 별도 서사 확인점

- catalog 원문 전수 대조에서 다음5건을 세 작성자가 독립 확인했다. 현재 번역은
  원문에 묶어 두며 KO를 몰래 수정하거나 화면에서 관찰한 결함이라고 주장하지 않는다.
  `content/items.json:artifact_daeun_note.description`은 '밥 먹고 다녀.' 뒤
  '세 글자'라 실제5음절과 맞지 않는다. `content/meta/achievements.json:
  startup_exit.description`의 '스물에 억대 계약'은 33세 시작 정본과 다르다.
  같은 파일 `political_fix.description`의 정치 테마주 한탕은 현재 동명 엔딩의
  정치인 당선 산문과 다르므로 실제 업적 ingress와 엔딩을 별도 확인해야 한다.
  `content/news_templates.json:news_009.topics[4]`는 '밈코인코인' 중복이며,
  `news_057.headline`은 '낙찰가율78%하락'의 하락폭/도달수준이 모호하다.
  별도 KO 정합 수리에서 저작 의도와 실제 독자를 확인한 뒤 해당 leaf의 번역만
  갱신할 것을 권고한다. 미수리 비용은 나이·유물 문구·업적 의미·뉴스 수치의
  원문 결함이 세 언어에도 남는 것이다. 번역 배치나 자동 검사는 이 문제를 닫지 않는다.
- `content/endings.json`의 `gangnam_dream.description_if_known.
  cleared_father_debt_from_sangchul`: 기본 산문에서 초인종·아버지 도착·입장·
  함께 야경 보기를 마친 뒤 이 부록이 다시 초인종·아버지 도착·야경을 반복한다.
  세 언어 작성자와 원문 대조에서 같은 중복을 확인했다. 현재 번역은 원문을
  보존한다. 별도 한국어 서사 수리 범위에서 기본문과 부록의 실제 조합을
  확인하고 반복 입장을 정리한 뒤 해당 source hash의 번역만 갱신할 것을 권고한다.
  미수리 비용은 같은 입장을 두 번 읽는 장면 중복이 세 언어에도 남는 것이다.
  이 기록은 코드·원고 관찰이며 새 인간 플레이 판정이나 REJECT 증거가 아니다.

배치마다 완료·미완료·source 변경으로 낡은 번역을 분리한다. 한국어에 새 텍스트가
생기면 그 source hash만 재번역 대상으로 되돌린다. 영어 중역이나 간번 문자 변환을
새 독립 번역으로 세지 않는다.

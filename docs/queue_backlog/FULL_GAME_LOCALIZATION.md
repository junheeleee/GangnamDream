# Full-game localization — remaining scope

2026-09-07 사용자 직접 지시로 M01~M60의 일본어·중국어 간체·번체 번역을 시작한다.
현재 실행 배치와 우선순위는 `../CODEX_QUEUE.md`, 지속 규칙은
`../I18N_INFRASTRUCTURE.md`가 소유한다. 이 문서는 큰 활성 오더가 아니라
누락 없이 후속 15~25단위 배치를 고르는 전체 범위 지도다.

- 사건: packaged 1,813개/12,421 leaf, shipping 1,708/11,680과 author-only
  105/741이다. Chapter5 reader133과 결과 foreshadow6을 포함한다. 기존 보조
  수집기의12,415/11,674 누락은 foreshadow6을 추가해 정렬했고, 나머지 원문
  leaf는 변경0이다. M07~M60 정적 closure는192사건/1,751 leaf다.
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
  그중 정적 계약 지원17,045, 소비자 미확정329를 분리한다. foreshadow6의
  builtin-overlay validator를 보강했으며 표시 완료나 외부팩 지원은 아니다. 관계 표시명
  21위치는 이 leaf 분모 밖 미지원이다. JSON pair 미해석 138건은 진단이지
  번역문 138개가 아니다. 이 수들을 더해 허위 전체 커버리지를 만들지 않는다.
- 엔딩 `with_daeun`, `late_call`, `instant_legend`의 언어별22 번역 leaf와
  초반 이후 8개 root의 언어별94 leaf를 수용했다. 최초357 중 비표시 메타9를
  별도 해시 보존해348번역으로 정정했다. 일상·안정·회복14종83 leaf/locale도
  독립 대조·수용했다. 남은 엔딩18종129 leaf/locale와 catalog834 leaf/locale도
  전수 대조·수용했다. M07~M24 정적 연결의 미번역35사건279 leaf/locale를 더해
  4,323번역에3년차48사건363 leaf/locale를 더해 총5,412번역이다(언어별
  엔딩234+사건736+catalog834). catalog 신규 작성2,485·
  기존 JA 누락 수리1·기존 유지16을 구분한다. 엔딩35종과 catalog7섹션은 채웠지만
  사건·UI·표시 소비자는 아직 남는다. M07~M24 정적 연결은 해당 기간 모든 무작위
  사건·UI나 실플레이 전량의 번역 완료를 뜻하지 않는다. 원어민·화면·전체판은 OPEN.
  3년차도 정적45종+별세1+NG2의 한정 묶음이며 M37·M53 장기 후속을 포함한다.
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

- `arc_jaehyuk_aftermath.choices[0..2].text`에는 `[take_high_road 경로]`,
  `[crossed_line 경로]`, `[jaehyuk_scammed 경로]`가 실제 선택문에 붙어 있다.
  숨은 경로 표시 금지 정본과 충돌하는 기존 원문 결함이다. 번역 작업본은
  식별자를 그대로 두고 '경로'만 중립 번역하며, 삭제나 도덕 힌트로 변형하지
  않는다. 원문 대조 수용은 이 노출의 승인이나 출시 GO가 아니다. 공개 전
  KO/EN·대상 언어·실제 선택문 소비자를 함께 수리해야 할 승격 차단 항목이다.
- `arc_y3_jiyeon_departure.choices[2].result_text`는 '고마워요'(4음절)를
  '세 글자'라고 부른다. 대상 언어의 짧은 감사 표현과 원문의3을 보존하며
  원문 지시 대상을 별도 확인한다.
- `arc_minjun_first_call.choices[1].result_text`는 현수와 통화 중 '이번 주?'라고
  한 뒤 같은 결과 끝에서 '한 달 후의 약속'이라고 한다. 별도 일정 정합 수리가
  필요하며 번역은 둘 중 하나를 임의 채택하지 않았다.
- `arc_sangchul_confrontation.choices[2].result_text`에서 유리문을 밀고 찬 공기를
  맞은 뒤, 직접 후속 `arc_sangchul_stairwell.description`은 다시 의자 곁·문까지
  세 걸음·같은 테이블로 돌아간다. 이 순서는 원문/후속 키 직접 대조 결과이며
  새 실플레이 증거는 아니다. 퇴장 단계를 KO와 표시 계약에서 함께 수리해야 한다.
- `callback_sangchul_truth_buried_echo.choices[1].result_text`의 '어떻게 알았어?'
  회상은 confrontation 선택0의 말인데, buried를 만드는 선택1은 '네가 꺼낸
  이름이야'다. 묻은 경로의 회상 독자를 실제 ingress와 대조할 대상이다.
- `arc_sangchul_year3`와 `arc_sangchul_year3_father_passed.description`은
  '{name}이 신고한 것과 관계없이'라고 한다. reckoning의 신고 외 선택들도
  같은 후속을 지정하므로 신고 전제를 별도 확인한다. 세 번역은 원문 전제를
  조건부로 몰래 바꾸지 않았다. `arc_sangchul_reckoning.choices[1].result_text`의
  '아버지가 돌아오는 건 아니었다' 역시 생존 경로에서 회복의 비유인지 확인한다.
- `arc_jaehyuk_04a_ghost.description_if_known.asked_partial_return`의 시선·웃음
  회상은 앞선 문자 답변과 대면 연출이 이어지는지 확인할 대상이다.
  `callback_jaehyuk_exploited_retaliate`의 세 배 미지급 주장 및 선택1 재입금은
  앞선 역제안 정산과 중복되는지 실제 분기 영수증으로 확인해야 한다.
- `arc_year3_close.description`의 남은100주는 240주·연48주 기준의3년말
  잔여96주와 다르다. 실제 발화 주차와 저작 의도를 확인할 수치 부채다.
  위 확인점은 원문 대조 관찰이며 독립 사람 판정이나 새 GO/REJECT가 아니다.
- 공개 보호 root `arc_temptation_01`의 choice0/1 foreshadow는 JA·간체·번체에서
  미작성이다. 기존6 leaf와 공개 GO를 건드리지 않고 별도 보강 대상으로 남긴다.
  EN foreshadow6도 미작성이다. 정적 검사 지원 추가가 기존 파일을 채우지는 않는다.
  지도 밖 `arc_daeun_money_gap`와 selector의 `arc_after_scam`,
  `arc_jaehyuk_04c_stand_up` 역시 이번48종 밖 사건 잔여다.

- `content/events/arc_midgame.json:arc_hyunsu_drift.choices[2].result_text`는
  답장 '형도요'(3음절)를 '그 두 글자'라고 부른다. 현수 후속 번역에서는 원문의
  수량을 유지하고, 글자 수를 세 언어에 맞춰 재작성하는 것으로 KO 결함을 숨기지
  않는다. 별도 원문 수리에서 지시 대상과 저작 의도를 확인해야 한다.
- `arc_father_03_hospital`의 도입은 부모 방문 '나흘째'인데 첫차 선택 결과는
  마지막 얼굴을 본 때를 계산하다 '너무 오래됐다'고 닫는다. 정서적 거리의
  의도일 수 있어 확정 오류가 아닌 대조 항목이다. 같은 도입의 '방 안과 식당'은
  `arc_34_parents_visit`에서 방을 보여 주지 않은 선택과 조건별 대조가 필요하다.
  세 언어 저작자는 원문을 보존했다. 이 정적 관찰은 새 실플레이 판정이 아니다.
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

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
  4,323번역에3년차48사건363 leaf/locale와4년차47사건460 leaf/locale를 더해
  마지막 해40사건358·종막15사건197과 관계25사건164에 결혼·가족34사건206
  leaf/locale와 데이트·계절36사건209, 가족·직장·친구50사건380 및 남은 관계15종94
  leaf/locale, 생활·월세·첫 월급25종185 leaf/locale와
  주거·건강25종176 leaf/locale와 직장·구직25종194 leaf/locale까지 총13,281번역이다
  (언어별 엔딩234+사건3,359+catalog834). catalog 신규 작성2,485·
  기존 JA 누락 수리1·기존 유지16을 구분한다. 엔딩35종과 catalog7섹션은 채웠지만
  사건·UI·표시 소비자는 아직 남는다. M07~M24 정적 연결은 해당 기간 모든 무작위
  사건·UI나 실플레이 전량의 번역 완료를 뜻하지 않는다. 원어민·화면·전체판은 OPEN.
  3년차도 정적45종+별세1+NG2의 한정 묶음이며 M37·M53 장기 후속을 포함한다.
  4년차47종은 조건128/언어와27조합을 포함하며 M49 이후 후속3종도 있어 기간별
  실플레이 전량 커버리지가 아니다. 별도 선언한 공개CN의 두 기록1문장 수리는
  기존 baseline100문구 안의 정밀화로 수용 수에 중복 합산하지 않는다.
  마지막 해40종은 조건14와 reader78/언어, 종막15종은 사전형 조건38+scalar2와
  reader55/언어를 포함한다. 관계25종은 조건12/언어다. M07~M60 정적 closure는
  신규 수용191종1,743문구와 보호 재사용 재혁 재회1종8문구가 구분된다.
  비보호 정적 연결의 번역문은 채웠지만 해당 기간의 모든 무작위 사건·UI·
  실제 도달/플레이 전량 번역 완료는 아니다. 결혼·가족34종은 조건22/언어이며
  이전8,949/meta9와 기존행을 보존했다. 관계의 나머지23종도 shipping
  원문 번역이며 정적 closure 수에 중복 합산하지 않는다.
- 다음 runtime 수리의 실제 소비자: `GameState.apply_relationship_effect`는 원문
  이름을 저장하고 `MainGame:9852/18298`, `RelationshipSystem:30/50`이 그대로
  표시한다. 저장 값을 바꾸지 않는 locale 표시 resolver가 필요하다. 또한
  `MetaProgression._localized_title`, `GameState.tendency_name/tendency_desc`,
  `_localized_route_label/_localized_profile_label/_roll_run_theme`,
  `MainGame._choice_effects_preview`, `HoldemClub._fmt`의 non-KO=EN 분기를
  개별 표시 계약으로 검사한다. 번역 파일만 채워도 이 소비자는 저절로 바뀌지 않는다.
- 기존 JA 정밀화: `arc_father_legacy.description`과
  `arc_y5_final_offer.description`의 `30億`을 용어집의 `30億ウォン`으로
  명시했다. 별도169 선언 뒤 두 target/수용 hash만 갱신했으며 기존8,947와
  메타9는 보존했다. 수용 수는8,949 그대로다. 원어민·화면은 OPEN이다.
- QA: source/target 완전성, 지역 문자·금액·토큰·문단, 한글/영어 누출, save/resume,
  지역 primary 폰트, 1280×800/960×600 실제 화면을 대상 언어별로 검증한다.
- 출시: 번역 텍스트 수용은 원어민 자연스러움이나 본편 재미 GO가 아니다. 기존
  M01~M06 공개 데모를 덮지 않고 별도 전체판 후보에서 검토한다.

## 원문 대조에서 발견한 별도 서사 확인점

- 관계50종 사전계측의 현재 foreground 허용은 `father_hospital_wait`와
  `father_old_photo`이며, wait의 두 선택이 hidden `father_hospital_results`로
  이어진다. results 도입의 빈 종이컵은 선택0의 컵 없음/선택1의 물 채운 컵과
  연속성을 대조해야 한다. wait은 father_visited·생존을 검사하나 본문은 입원
  사흘째로 고정되어 있어 실제 입원 시점과 별도 검토한다. 이 정적 확인은
  화면 관찰·새 인간 REJECT가 아니다.
- 같은 묶음의 나머지47종은 shipping 데이터이나 현 foreground/bridge 허용이나
  직접 ID 호출을 찾지 못한 legacy 원문이다. `rel_ex_reunion.choices[1]`의
  선택 읽음↔결과 읽지 않음, `rel_family_visit_seoul` 두 생사 대안의 도착
  뒤 방문 미루기·다음 주/이번 주, `rel_romantic_progress.choices[0]`의
  발신→카페 대면, mentor_coffee·coworker_conflict의 연락→동석 생략을
  개별 source대로 옮긴다. 번역에서 승인·회신·이동을 만들어 이어 붙이지 않는다.
- 비전경 `family_007.choices[0].result_text`는 '고마워'를 두 글자라고 하며
  30만원 송금 산문에 money=+430000이 붙는다. `family_016.description`의
  오빠(언니)는 고정 남성 MC와의 템플릿 차이다. 외동 명시는 확인하지 못했으므로
  동생의 존재 자체를 위반으로 확정하지 않는다. `rel_blind_date_setup`의
  친구 민준 역시 동명이인 여부 미확정이며 임의 개명을 하지 않는다.
- 비전경 daeun_regular~choice의 민준 계산원/다은 고객·디자인 프리랜서·
  청주 부모 설정은 STORY_BIBLE의 다은 직원/민준 손님·경기 외곽과 다르다.
  daeun_feeling의 거절도 date_done을 만들고 daeun_choice가 이를 배제하지
  않는 점, jiyeon_gangnam_moment가 자산20억원 조건만으로 전입신고 완료와
  아파트 열쇠를 서술하는 점도 원문/라우팅 부채다. 현재 비전경이라는 구분을
  유지하며 KO/EN·flag·소유 조건을 이 번역 배치에서 고치지 않는다.
  `jiyeon_mother`의 도입은 차 한 모금, 선택1 결과는 커피를 다 마셨다고 하므로
  음료 지칭의 원문 확인점도 분리한다. 번역에서 같은 음료로 몰래 통일하지 않는다.

- 데이트 번역의 국소 해석: `arc_jiyeon_first_kiss.choices[1].result_text`의
  '차갑게 들으려 했지만'은 문맥의 냉정한 말투로 옮겼으며 새 청취 행동을 만들지
  않았다. `arc_season_fireworks_daeun.description`의 목적어 없는 '내리지'
  는 앞 시선과 뒤 dress의 숨지 않는3초를 따라 시선을 내리지 않는 것으로 해석했다.
  `arc_season_sea_daeun.description`의 '동해행'은 특정 시·역 이름을 확정하지
  않고 동쪽 바다 방향으로 옮겼다. KO를 고친 것이 아니라 번역 해석의 근거이며,
  원문 명료화 때 해당 source key를 다시 대조한다.

- 데이트 사전계측: 남산의 `arc_date_namsan_daeun.description`과
  `arc_date_namsan_jiyeon.description/choices[0].result_text`는 목표를 좇은
  5년을 회수하나 `_date_milestone_id`는 dc>=3·적합 월·미관찰을 검사하고 연도/
  turn 조건은 없다. legacy AP 호출과 현 제품 실제 도달성은 분리하며, 원문과
  진입 조건의 시간축 확인점이지 새 플레이 REJECT가 아니다.
- `arc_date_park_jiyeon.choices[0].result_text`의 마지막 사진은 민준 얼굴이
  망가지지만 `callback_amusement_photo_found.description`은 그녀 얼굴로
  회수한다. 사진의 주체를 번역에서 하나로 몰래 정정하지 않는다.
- `arc_season_fireworks_daeun.description`은 평소 수수한 사복도 봤다고 한 뒤
  "유니폼 아닌 거, 처음 보죠"라고 발화한다. 처음 보는 원피스와 첫 사복을 구분할
  원문 확인점이다. dress 결과의 첫 발사 폭음 뒤 decision 도입의 폭음 전으로
  넘어가는 순서, Jiyeon pace 결과→decision 도입의 손잡기 반복도 연속 동작
  확인점이며 번역문에서 새 이동·재실행을 만들거나 삭제하지 않는다.
- `_season_date_id`는 지연 부산 장거리 기간에도 여름 바다를 허용하지만
  `arc_season_sea_jiyeon.description`과 presentation은 부산행 KTX 동승으로
  시작한다. 부산에 머무르던 지연이 함께 탄 경위의 정적 장소 연결 확인점이다.
  배선 검토만으로 실제 동석 오류를 인증하지 않는다. 다은의 바다5년은 개인의
  미뤄온 시간으로, 남산의 민준 목표5년과 같은 연도 분모라고 단정하지 않는다.

- `arc_jiyeon_wedding_guest_list.description_if_known.hyunsu_reconnected`는
  '아버지, 현수. 두 이름'을 적은 뒤 '그 두 글자들'이라고 회수한다. 이름 개수와
  실제 문자 수가 섞인 원문 확인점이다. 각 언어는 두 이름/두 글자를 보존하며
  번역에서 하나의 분모로 몰래 바꾸지 않는다.
- `arc_daeun_wedding_prep.description`의 견적480만+1800만+500만+400만은
  3,180만원이나 선택1 결과와 money effect는3,100만원이다. 두 준비 결과는
  식 종료·사진 수령까지 가는데 MainGame의 뒤 `arc_daeun_wedding_day`는
  입장 전으로 돌아간다. 금액·원고/일정 순서 확인점이며 번역에서 몰래 고치지 않는다.
- `arc_jiyeon_narrow_room_1` 기본/부산 변형에 이미 민낯이 등장하지만,
  `arc_jiyeon_wedding_night_choice` 양 결과는 아침의 민낯을 '처음 보는 얼굴'로
  표현한다. 문학적 새 아침인지 첫 노출 충돌인지 원문 판단이 별도다.
  위 원문 대조를 새 실제 플레이 REJECT나 기존 사람 GO 변경으로 합산하지 않는다.

- `arc_daeun_families_meet.choices[0].text`에서 민준은 아버지가 빚을
  다 갚았다고 말한다. 첫 통화 `arc_father_01_call.description`의 서술은
  아버지가 보증한 뒤 남은 빚을 민준이6년에 걸쳐 갚았다고 한다. 상견례에서
  아버지의 체면을 세우려는 의도적 발화인지 확인할 주체 차이다. 번역에서는
  대사를 원문대로 보존하며 실제 상환 주체가 바뀐 서술로 승격하지 않는다.

- `arc_daeun_03b_date.description`는 편의점 밖의 다은을 처음 본다고 한다.
  앞선 `arc_daeun_02_regular`의 결과0은 분식집 식사, 결과1은40분 산책이므로
  해당 선택을 거친 경로의 '처음'과 맞는지 원문 확인이 필요하다. 원문·결과 대조이며
  실제 경로 재플레이/새 인간 판정은 아니다. 번역에서 '첫 데이트'로 몰래 바꾸지 않았다.

- 관계 묶음 `arc_daeun_year3_apart.choices[0].result_text`는 '잘됐다'를
  '두 글자'라고 부른다(실제3음절). `arc_daeun_proposal_answer`의 기본/첫날밤
  변형은 함께 버틴4년, 수락 결과는5년이며 `proposal_last_cup`도 네 해다.
  `arc_daeun_our_home` 생존/별세 두 대안은 약혼 직후의 매물 사진을 보며
  5년을 말한다. `arc_daeun_year5_ending.description_if_known.daeun_year4_close`
  는4년차 카페 약속을4년 전이라고 회수한다. 각 실제 주차/관계 시작일과 대조할
  기존 원문 시간·문자 수 부채이며 번역에서 연수·글자 수를 몰래 정정하지 않는다.
  원고 대조만으로 새 인간 REJECT를 발급하지 않는다.

- `arc_final_countdown_property_not_executed`의 finale reader `texts[3][2]`는
  '전날 아버지 기록 곁에 둔 오늘 날짜가'라고 한다. 앞선 기록의 작성일을
  인용하는지, 현재 서명일을 뜻하는지 날짜 지시 대상을 확인할 원문 부채다.
  번역에서 전날/오늘 중 하나를 임의로 삭제하거나 날짜를 당기지 않았다.

- 종막 `arc_pre_ending_summit.description_orthodox/unorthodox`는 원문에서
  '선택 기록은 정석/비정석 쪽으로 더 기울어 있었다'고 직접 말한다.
  StoryMode의 해당 selector는 실제 route 두 수치의15 차이로 이 본문을 선택한다.
  숨은 route·도덕 라벨을 표면에 노출하지 않는 CLAUDE/MORAL_TINT와 대조할
  기존 원문 표시 부채다. 번역에서는 몰래 문장을 삭제하거나 선악 평가를 더하지 않는다.
  코드·원고 대조일 뿐 새 실플레이 관찰은 아니며 KO/EN과 consumer 수리가 별도다.

- 마지막 해 계약 입구 `arc_y5_contract_cover_investment`는 월요일08:42,
  `arc_y5_contract_reviewer_delivery_sangchul`은 수요일21:16인데 후자의
  causal reader0은 전자의 수첩을 '전날'이라고 회수한다. 원문·reader의 실제
  source ID를 대조했으며 번역에서 날짜를 몰래 바꾸지 않았다.
- `arc_y5_general_name_boundary_exact`의 memory `chapter5_general_minseo_arrival_0`
  은 민서가 '도착하면 다음 질문이 온다'고 했다고 회수한다. 해당 flag 생산자인
  `arc_minseo_03_arrival.choices[0]` 결과는 발신만 있고 새 답장이 없다.
  앞선 `arc_minseo_02_real`의 목표 소멸 대비 발화를 풀어쓴 것인지, 낡은 답변
  회수인지 확인할 대상이다. 원문은 '답했다'가 아닌 '했다'이므로 곧바로 새 답장
  결함으로 확정하지 않으며, 번역에도 응답·발화 순서를 추가하지 않는다.
- `arc_daeun_final_choice_decision.choices[2].result_text`는 '잘 챙겨 먹어요.'를
  '세 글자씩'과 '이 세 글자'로 부르지만 실제 한국어는6음절(1+2+3)이다.
  인용문을 세 글자에 억지로 맞추지 않고 원문 의미와 수량 진술을 함께 보존했다.
  김다은 이름의 원문3음절은 이 결함과 다르며 로마자/가나 표기의 길이로 바꾸지 않는다.
- `arc_father_legacy.choices[0]`는 선택에서 마음속 발화, 결과에서 입 밖으로 나온
  말을 명시한다. 의도된 불수의 발화일 수 있어 확정 오류가 아닌 확인점이다.
  아버지 부재·무응답은 양쪽에 그대로이며 번역도 이를 보존했다. 위 관찰은
  한국어 원고 확인점이지 새 인간 판정이 아니다. 원문 수정 뒤 해당 hash만 갱신한다.

- 4년차 가족·별세 묶음의 원문을 직접 읽고 다음 시간/화자 지시 대상을 분리했다.
  `arc_y4_family_partner_collision_jiyeon.choices[0].result_text`는 부산발
  열차로 서울 식당에 막 도착한 지연이 '오늘 왕복했습니다'라고 완료형으로 말한다.
  선택2는 같은 부산→서울 이동을 철회한 결과인데 '부산행도 … 열리지 않았다'다.
  현재 세 번역은 방향·완료형을 몰래 정정하지 않는다. 실제 이동 단계와 발화를
  KO/EN에서 수리한 뒤 해당 hash 번역을 함께 갱신할 확인점이다.
- `arc_father_passing.description`은 이미 사망을 확인한 뒤 곧 시작할 거래를
  선택하게 하지만 `arc_father_passing_deal_morning.description`은 사망 시각이
  거래로500만원을 벌던 시간과 겹쳤다고 회상한다. `arc_father_passing_hospital_room`
  도입의 '한 시간 전' 역시 장거리 이동 뒤 상대시각과 대조해야 한다. 미수리 비용은
  생사 확정·이동·돈을 번 인과의 시간 역전이 번역에도 남는 것이다.
- `arc_y4_father_call_answered_on_ktx.choices[0].result_text`는 아버지의
  '오늘은 숨이 조금 찬다'는 답변을 들은 뒤 '질문 하나를 끝까지 들은 대가'라고 한다.
  질문/답변의 지시 대상을 원문 수리에서 확인한다. 위 관찰은 원고 대조이며
  독립 인간 플레이 판정이나 새 REJECT가 아니다. 번역 검증으로 닫지 않는다.
  JA는 앞 실제 응답을 문맥상 `問いの答え`로 풀어썼다. 새 회신/정보를 만들지 않은
  현지화 해석과 원문 질문/답변 혼용을 구분하며 다른 언어를 이 표현에 중역하지 않는다.
- `callback_medication_ignored_echo.choices[0]`의 `apologized_for_ignoring`은
  어머니에게 사과한 뒤 '알았다'는 메시지를 받지만, `arc_father_passing`의 같은
  조건문은 아버지 통화와 '괜찮다, 바쁘잖냐'를 회상한다. `father_knew_i_came`도
  `callback_medication_visited_echo.choices[0]`의 말 없는 생선/앨범 기록에서
  생산되는데 사망 조건문은 '...기억하고 있었어'라는 발화를 회수한다. 생산자와
  원고를 직접 읽고 확인한 회상 정합 부채이며, 미수리 비용은 발화/응답의 허위
  회수가 세 번역에도 남는 것이다. KO 회수 계약 수리 뒤 해당 번역만 갱신한다.
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

## 관계 파일 잔여15종의 원문 확인점 (2026-09-07)

- `relationship_events2:rel_mother_confession.choices[0].result_text`의
  '어머니가 딸/아들이 아닌 한 사람'은 주체/관계 비교 원문이 어긋난다.
  같은 파일23선택의 도덕·관계·보상 괄호도 원문 표면 규칙과 대조해야 한다.
  번역에서 몰래 '엄마가 아닌'으로 고치거나 괄호를 삭제하지 않는다.
- `rel_friend_breakup`의 '고마워' 두 글자, `rel_mentor_wisdom`의 노트 선택→
  메모앱 결과, `daeun_birthday_missed`의 오늘 생일→늦었지만은 원문 확인점이다.
  `rel_hyunsu_loan`은 계좌를 보내고 뒤에 반환을 서술하므로 번역에서 앞의 계좌
  전달을 송금으로 바꾸지 않는다. 형동생 친밀 서술은 첫 만남 조건만 요구한다.
- `rel_daeun_first_text`의 최초 선연락 주장은 과거 선연락 이력 조건이 없으며,
  명시 message/received 계약은 동석이 아니다. 다은 커피/옛 친구 식사 제안에
  수락·날짜 확정·대면을 추가하지 않는다. father_silent/primary는 별세3상태
  hard gate를 보존한다. foreground0·bridge2 정적 탐색을 새 실플레이 판정이나
  나머지13의 모든 비도달 증명으로 부르지 않는다.

## 일본어 다은 고정 말투의 정밀화 기록 (2026-09-07)

- 직전172 L2에서 KO의 가까워진 말투를 따라 `daeun_share` 결과0의
  'それも勇気だね', `daeun_feeling` 결과0의 'いいね。こういうの'를 권고·수용했으나,
  173 용어집 재독에서 `I18N_GLOSSARY_JA.md`의 다은→민준은 연애 뒤에도
  です・ます체라는 기존 잠금과 충돌함을 발견했다. 해당 말투 권고2를 철회한다.
  원래 'それも勇気ですね'/'いいですね。こういうの'로 복구하고 기존 수용의
  target hash 두 개만 새로 발급할 것을 권고한다. 현재173은 기존380 보존을
  소유하므로 다른 오더의 정확2 leaf 선언으로 분리한다. 관계 단계·KO·용어집
  변경이 아니라 기존 일본어 말투 준수 수리이며, 미수리 비용은 다은의 말투가
  이 두 장면에서만 갑자기 달라지는 것이다. L3/원어민 GO는 발급하지 않는다.
- 이후 정확2 leaf를 별도 선언해 'それも勇気ですね'/'いいですね。こういうの'로
  복구하고 KO·용어집 독립 대조와 새 target hash 수용을 마쳤다. 현재 총11,616은
  그대로이며 다른11,614/meta9도 보존했다. 위 대기 비용은 이 수정에서 닫혔지만
  원어민·화면·사람 게이트는 OPEN이다.

## 생활·월세·첫 월급25종의 원문 확인점 (2026-09-08)

- 생활25종 대조에서 landlord_rent_up의15만원 인상→협상10/5→최종7 불일치와
  월별 산문/일회 effects의 차이, apartment_view의 실제 계약·입주 산문에 주거
  상태 효과가 없는 점을 분리했다. 동창회의 다음 달 셋째 주 토요일 초대→참석,
  친구 출산의 실제 하트 회신·한 달 뒤 선물은 원문 압축 그대로다.
  첫 월급 alive→passed 대체는 EventManager 생사 검사이며, 정적 번역 수용은
  고정 배경·주거·시점의 실플레이 합격을 뜻하지 않는다. 새 괄호를 만들지 않고
  원문의 선택52개 기능 설명을 노출 부채로 유지했다.

- 생활·건강25종의 옆방 이웃 relationship_effects 표시명1곳은176 leaf 밖
  기존 resolver 부채다. 첫 서울 지인·33살·면접8→9시·고시원 귀환 산문과
  현재 조건의 관계는 별도 source 확인점이다. 찜질방12,000원/이사 저축3만원의
  결과·효과 차이를 번역에서 수리하지 않는다. 실제 입금·벽 답장·감사 메모·
  10분 통화와 검색/예약에서 진료·정상 검사로 이어지는 압축은 명시된 사실대로다.
  우산3선택 기능 괄호도 원문 노출 부채이며 새 플레이 REJECT 판정은 아니다.

- 직장·구직25종의 jobs_003 준비비22만원 지출↔+220000효과, jobs_014의
  '네, 알겠습니다' 세 글자→두 글자, jobs_036의 약속 유무와 지하철에서
  '막 나왔다'를 거짓말로 부르는 원문은 별도 확인점이다. salary_not_enough의
  고시원비·영어 학원 선배의 조건 부재도 번역으로 수리하지 않았다.
  첫 탈락의 '첫 번째가 아닐 수도'와 월급의 '한 달을 번다'는 원문 모호함을
  유지한다. 회식의 '다음엔 더 있어요'는 화자 이름을 만들지 않은 요청 독해다.
  13개 밖 callback과 resume_polished 소비자를 신규 도달성으로 합산하지 않는다.

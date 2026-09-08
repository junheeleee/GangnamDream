# Active Queue Spec: ORDER-198

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-198 [P0·전체 현지화] 생활 인연과 마지막 전략의 후속을 옮긴다

**[~] 2026-09-08 Codex 착수 — 19종 한 배치, 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
선언 직전 ORDER197 수용23,844(각7,948)·meta9·batch54를 재확인한다.
공개 working baseline·별도 배경 제품53493fe는 변경하지 않는다.

## 깊이 3문

1. 반찬가게·현장·이웃·정치·가족·정보·이력서 후속을 KO에서 읽는다.
2. 현재 장면의 실제 행동과 기회·생각을 구분하고 부모 장면과의 차이를 기록한다.
3. callback25 전체15종과 callback26 전체4종, 19종/114leaf 한 배치만 옮긴다.
   파일27 이후를 작은 잔여 배치로 억지 편입하지 않는다. KO·게임플레이 수리는 비소유다.

## 범위 — A19/114, 총3,219 KO자

- `callback_chain_banchan_job_lead_echo`
- `callback_chain_banchan_regular_echo`
- `callback_chain_interior_gig_echo`
- `callback_chain_interior_manager_echo`
- `callback_chain_neighbor_friend_echo`
- `callback_chain_warned_victim_echo`
- `callback_political_candidate_echo`
- `callback_political_winner_echo`
- `callback_final_sprint_aggressive_echo`
- `callback_final_sprint_defensive_echo`
- `callback_final_sprint_reflective_echo`
- `callback_parent_took_loan_echo`
- `callback_parent_paid_full_echo`
- `callback_guarantee_compromise_echo`
- `callback_mystery_info_paid_off_echo`
- `callback_mystery_info_scammed_echo`
- `callback_mystery_info_resolved_echo`
- `callback_resume_lie_doubled_down_echo`
- `callback_resume_lied_toeic_echo`

합38선택·LF87·{name}0, source aggregate
`88cda9070db021a23253c08e5797477cf60902d0654ce1e0c32d743deb1da47a`.
known/reader/memory-field/foreshadow/밖표시명 신규0.
전부 shipping·event_standard·protected=false·builtin_overlay_static_only.

파일25는15/90·2,331자/LF61, 파일26은4/24·888자/LF26다.
각 locale 두 파일 모두 신규이며 KO 전체 순서로 쓴다.
누락·추가·gameplay 복사0. 선언 직전 새 파일 부재와 신규114 미수용을 재검사한다.

## 도달·조건·독자

- DataRegistry 87~88행에 두 파일이 등록돼 있다. 실플레이 도달 증거는 아니다.
  공개·정적 M07~M60 closure 교집합0, 정확ID runtime literal0, inbound/outbound0.
- director 정확참조0·신규flag0·신규외부조건/메모리reader0.
- 기본 min_turn8, 정치2종10, 마지막전략3종208이다.
  parent_paid_full_echo는 no_flag father_passed를 갖는다.
  다른 장면에 없는 직장·주거·관계·생존조건을 번역으로 보충하지 않는다.
- 개별 후속의 두달 회고를 실제 주차 대기·장면 순서가 검증됐다는 뜻으로 쓰지 않는다.

## 파일 소유권

각 locale callback_events_25.json·26.json 여섯 파일만 저작한다.
KO 직접 독립 저작, EN 중역·간번 자동변환0, 전수 교차 L2.
ROOT는 tools/full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, portable 수용원장, 이 사양,
CODEX_QUEUE·L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·전체 현지화 backlog를 소유한다.
오탐은 실물 정상/변조 짝과 원문 경계로만 수리한다.
필요하면 완료195 WORK_LOG절만 기존9/7 history 앞으로 원문 이동한다.
기존 history bytes/끝 개행을 보존한다.
KO/EN·runtime·save·fonts·routing·공개·human_gates·다른 사건·catalog/endings 비소유.
완료는 같은 큐 이어보기 [~]·L3 OPEN, 전체 번역이나 제품 GO가 아니다.

## 생활 인연의 사실 경계와 부모 부채

- banchan_job_lead는 취업기회 뒤 결과를 모르는 상태에서 사장님연락,
  감사말→잘됐냐는질문/실제근황공유→도움필요시말하라는답변이다.
  취업완료·새채용·금전지원을 만들지 않는다.
  producer chain_banchan_son은 단골방문→사장아들의명함→이력서제출→면접연락이며
  echo의 '반찬가게 알바'와 다르다. 번역에서 새알바 과거나 채용완료를 보태지 않는다.
- regular는 익숙한단골의 실제방문이며 대화/바쁘게구입두결과를 보존한다.
- interior_gig는 새단기일 제안 뒤 c0실제다시일함/적응, c1실제조건협상이다.
  효과의40/60만원을 산문에 새로 추가하거나 협상결과를 새계약문서로 만들지 않는다.
  manager는 첫단독판단상황이다. c0판단후맞고틀림은미래, c1위에실제확인받음이다.
- neighbor_friend는 힘들어보이는이웃에게 말걸고실제감사듣기/관찰하고다음에말걸생각이다.
  관찰에 대화·약속·문제해결을 만들지 않는다.
  producer chain_neighbor_moving은 이삿짐도움→연락처교환→차출발/옆방빈자리다.
  echo의 이어지는 작은인사·오늘관찰과 주거/재방문 경위를 번역으로 메우지 않는다.
- warned_victim은 상대연락 후 경고를듣고피했다는실제말/서로다행이라말함이다.
  producer chain_scammer_again은 현장경고뒤대학생이떠나며 연락처교환은없다.
  echo의 새연락을 삭제하지도, 없는번호교환·송금·구조장면을 추가하지도 않는다.

## 정치·마지막 전략의 사실 경계와 부모 부채

- political_candidate는 출마결심 두달후 첫지지조사이며 수치·당선확정은 없다.
  결과보기/전략다시짜기는 실제 행동이다.
  producer political_recruitment는 보좌관자리수락/발령이며 echo의출마결심과다르다.
- political_winner는 KO상 당선 두달후 생긴권한의 첫사용이다.
  약속한것부터실제함/현실파악의 대비를 보존하고 새법안·정책·직함을 특정하지 않는다.
  producer political_election_victory는 공천장수령·선거사무소계약·접힌현수막까지만이며
  실제선거/당선은 서술하지 않는다. flag이름을 당선증거로 보지 않는다.
  이번echo의당선서술과 부모차이는 KO/제품부채이며 번역으로 선거장면을 만들지 않는다.
- aggressive는 이미큰베팅 후 결과확인이다. c0성공시큰수익/실패시큰손실의
  일반조건문이지 어느쪽인지·금액확정이 아니다. c1일부실제방어전환을 보존한다.
- defensive는 현재자산점검/추가기회여지살핌이다.
  일반적손실/증가억제 서술을 새손익금액·수익보장·실제매수로 부풀리지 않는다.
- reflective는 두달전돌아보기선택과 오늘5년회고, 의미있었다/아직안끝났다는
  판단이다. 5년을4년으로 수정하거나 실제플레이종료를 만들지 않는다.
  parent final_stretch_check의 min_turn200/max216·1년미만남음/5년전상경·5년회고와
  echo min_turn208의 기간관계는 번역으로 고치지 않는다.

## 가족·정보·이력서의 사실 경계와 부모 부채

- parent_took_loan은 집안빚대신갚기로함의 부담뒤 어머니연락이다.
  두 선택의 실제감사/사과는 원문사실이며 새완납·빚면제는 없다.
  parent_paid_full은 원문상부모빚완납뒤 살아있는아버지의 실제전화이며
  건강질문/그냥전화했다는답변이다. 원격통화를 실제동석으로 바꾸지 않는다.
  두producer는 amb_parent_hospital의 수술비500만원을 자기돈/대출로마련한장면이다.
  echo가부모빚상환으로쓴차이를 새상환·두번째수술·과거이체로 메우지 않는다.
- guarantee_compromise는 완전하지않은타협의진행을 평가한다.
  producer는 보증대신작게돕겠다는제안과 불완전한관계이며 보증서명·법적채무종결0.
  제목의해결을 완전면책·완납·화해로 확장하지 않는다.
- mystery_info_paid_off는 과거정보실제성공뒤 새정보에 c0실제베팅/
  c1출처확인이다. 한번성공이이번성공보장아님을 보존하며 새수익·효과50만원추가0.
- scammed는 과거실제사기손실뒤 새정보차단/이번엔다를수있다는생각이다.
  c1가능성을 새송금·새피해확정으로 바꾸지 않는다.
- resolved는 어떤방향으로든결론을낸뒤 결과수용/다음선택기준정립이다.
  producer는 정보맞음후투자/타이밍놓침, 사기후수업료수용/신고 등 서로다른결과다.
  행정사건종결·체포·환급·무죄나 새수익으로 단일확정하지 않는다.
- resume_lie_doubled_down은 검증요청뒤 이번은넘김/실제 솔직히 말한 뒤 예상보다 크지 않은 반응이다.
  거짓말잔존/커지는복잡함을 보존하고 새위조방법·해고·완전용서·징계없음확정0.
  producer butterfly_resume_lie_caught는 성적표위조제출·통과를 서술한다.
  echo의덮어두기로함을 새위조기법이나 새과거로 확장하지 않는다.
- resume_lied_toeic은 아직확인없던과장점수뒤 실제영어상황이다.
  c0이번상황넘김/능력은못대체함, c1부족함인정/채우기로결심이다.
  실제시험·점수상승·영어습득·새취업을 만들지 않는다.
  producer butterfly_resume_lie는 실제745→기재900·서류통과/면접예정이다.
  echo에는 점수수치가없으므로 옮겨넣지 않는다. 현재업무의채용경위도 새로만들지 않는다.

## 검증

source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
callback_events_25.json 13309B SHA `b3860d74c9446954bf1ba502df4b71cdfb4fc87065f979a21fecab328c8a1944`.
callback_events_26.json 4157B SHA `1537f56c3aa5486be1d3b1c706fc1836edc9de98199be54fddeaf63e9db5267e`.
저작전 initial3 A115행, 신규114previousnull×3.
check/import는 source JSONL을 `--batch`, 언어를 `--locale`로 명시한다(`--source` 없음).
최종source/response/receipt3쌍·342문구 대조, 기존23,844/meta9/b54 보존.
named full-game-localization-overlays --list 뒤 선택12·EN·diff·전량수용 hash/L1.
실행 stdout만 증거화, 전체audit/Godot/240주0.
전체 INCOMPLETE·full/main/product HOLD·L3/원어민/화면 OPEN.
출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.
이 문서는 일회성 범위이며 지속 규칙의 소유자는 I18N_INFRASTRUCTURE/용어집이다.

## 수용 결과 — 342번역·L1/L2, L3 OPEN

- 선언 `5b05db3d25b42acc88d7eee691c666b2f9c82d4f` commit/push 뒤
  initial3(A115행·신규114 previous null×3)을 저작 전에 봉인했다.
  KO 직접 독립 저작 뒤 다른 작성자/ROOT가342문구 전부를 대조했다.
- callback25/26 신규15/90·4/24를 각 언어 KO 순서대로 썼다.
  기존23,844/meta9/b54 보존, 누적24,186(각8,062)·b55이다.
  각 언어 events996종6,994·endings234·catalog834다.
- 독립 L2 필수0, 정밀3: CN 실제상황/폭로공포의 비교1,
  TW 현재행동을 '아직늦지않음' 보장으로 옮긴 표현2를 정밀화했다.
  지정3 교차검토와 전체6파일·records 역치환으로
  JA114/CN113/TW112 나머지 불변을 확인했다.
- 일본어 실제12leaf/24진단의 bareて/で 경과형은 기존37
  exact KOopening/JA행동·주체 결속에12만 더해 수리했다.
  추가로 남은 reflective1leaf의 두달결심/오늘5년회고를
  full source와 셋째줄의 수량·단위·회고완료에 따로 결속했다.
  정상 번역을 검사기에 맞춰 바꾸지 않았다.
- full self204 PASS, 독립고정150은 정상26·target96·source28로 구분한다.
  첫136 입력을 유지하고 회고14만 추가했다. 새오허용0/잔여0이며
  전체문장의 무수량 의미나 원어민 품질 인증은 아니다.
  독립 입력 SHA
  `c89ee55c5023fc176368412c70c72c2470377c1ef9f1a5da516337871f93e253`.
- 최종 source/response/receipt3쌍·실물342 L1 오류0,
  check/import --accept3 changed_files0. 최종114 records:
  JA `e7ce61d65daf26ca0ada87c5dee74f4f0a6db0b62d25189b43dfc107c11fe3c8`,
  CN `b6bbb48f8fc4ed0f9e0f2121e35bd54c6a61e49d2f67b84e86863cfa74bdc949`,
  TW `e99d29e14fd6ac8bbdffcbda9a91ffd85a60af457178389107bac4858966dd80`.
- 완료195 WORK_LOG절1,107B만 history 앞으로 원문 이동했다.
  48,218→49,325B SHA
  `0b8ea0d03ab85f75b7b50784c53f0692c08b9d61e5040b0b0bda210465e877f5`.
  기존 bytes·끝 LF2 유지, 같은 활성 이어보기 [~]·L3 OPEN이다.
- 취업기회/채용·판단/확인·재베팅/성과·상환결심/완납을 구분했다.
  부모의 알바/소개·이사/인사·공천/당선·수술비/빚 등 원문 부채는 남겼다.
  KO/EN·runtime·공개·fonts·save·human_gates 변경0, 원본 checkout 쓰기0.
  전체 INCOMPLETE·full/main/product HOLD, 원어민/화면 OPEN·출시 데모 GO 유지.
- portable checksum `1119d2d3fa8a88d38500d2f3a31c83d2e01474d5fc13d05ee6bed54d8abca772`.

- 최종 named12·EN strict·전량24,186 source/target hash와 L1·diff PASS.
  full self204/ZH self6436, protected 공개14사건·100leaf/121UI 패리티 유지.
  private12/portable342 독립 인수에서 기존23,844·meta9·batch54와
  신규342 결속, 22입력 전후 불변을 확인했다.
  snapshot `441bca0fd2e673bad79647fef3ca1dfce79ccf8d7b2b61d3815ce33dfae50e4b`.
  실제 stdout `order198-final-checks.log` 4,685bytes SHA
  `80029963b711061b8d50865c03be0440b974454faa79fd13bec2f304f347cc83`.

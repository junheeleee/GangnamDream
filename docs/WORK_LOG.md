# Gangnam Dream Work Log

> 최신 작업만 역순으로 기록한다. 2026-07-24 이전 원문은
> [`9/01`](history/WORK_LOG_2026-09-01.md),
> [`5/16~7/24`](history/WORK_LOG_2026-05-16_to_2026-07-24.md), 보관본은
> [`8/27`](history/WORK_LOG_2026-08-27.md),
> [`8/27 후속`](history/WORK_LOG_2026-08-27_late.md),
> [`8/26`](history/WORK_LOG_2026-08-26.md),
> [`8/24`](history/WORK_LOG_2026-08-24.md),
> [`8/22`](history/WORK_LOG_2026-08-22.md),
> [`8/21`](history/WORK_LOG_2026-08-21.md), [`8/20`](history/WORK_LOG_2026-08-20.md),
> [`8/18`](history/WORK_LOG_2026-08-18.md),
> [`8/18 후속`](history/WORK_LOG_2026-08-18_late.md),
> [`8/15`](history/WORK_LOG_2026-08-15.md),
> [`8/14`](history/WORK_LOG_2026-08-14.md),
> [`8/12`](history/WORK_LOG_2026-08-12.md),
> [`8/11`](history/WORK_LOG_2026-08-11.md), [`8/10`](history/WORK_LOG_2026-08-10.md),
> [`8/5`](history/WORK_LOG_2026-08-05.md), [`8/4`](history/WORK_LOG_2026-08-04.md),
> [`8/3`](history/WORK_LOG_2026-08-03.md), [`7/31`](history/WORK_LOG_2026-07-31.md),
> [`7/30`](history/WORK_LOG_2026-07-30.md), [`7/29`](history/WORK_LOG_2026-07-29.md),
> [`7/27`](history/WORK_LOG_2026-07-27.md), [`7/26`](history/WORK_LOG_2026-07-26.md),
> [`7/25`](history/WORK_LOG_2026-07-25.md)에 손실 없이 보존한다.
> 과거 근거는 기본 컨텍스트에 넣지 말고 먼저 `rg -n "<키워드>" docs/history/`로 찾는다.

## 2026-09-05 (Claude — ORDER-148 ID 충돌 개번·큐 ID 재사용 가드)

- **내가 만든 ID 충돌을 고쳤다.** 9월 1일에 새 오더 번호를 고를 때
  `docs/queue_active/`만 보고 `docs/queue_archive/`를 보지 않아, 이미 닫혀 있던
  `ORDER-148`(P0·public demo truth, 이번 후보의 제품 부모 `83d3f350`이 아카이브한
  바로 그 오더)의 번호를 재사용했다. 활성 사양을 `ORDER-157`로 개번하고 큐 인덱스,
  `CLAUDE.md` 그다음 항목, `DEMO_FIXLOG`, `ORDER-150` 본문의 참조를 함께 옮겼다.
  아카이브의 `ORDER-148`과 그것을 가리키는 `WORK_LOG` 기록은 이력이므로 건드리지
  않았다.
- **그 충돌이 감사를 통과한 이유도 닫았다.** `queue_consistency_check.py`는 중복을
  큐 인덱스 표의 행 안에서만 봤고 `queue_active`·`queue_archive`·`queue_backlog`
  사이의 ID 재사용은 검사 범위 밖이었다. 세 디렉터리를 가로지르는 검사를 추가했다.
  `ORDER-100_L1_L2_2026-08-12.md` 같은 증거 첨부는 같은 번호를 의도적으로 공유하므로
  `ORDER-<숫자>.md` 정확 매칭만 센다. 충돌을 되살려 실패하는 것과 첨부를 오탐하지
  않는 것을 둘 다 실행해 확인했다.
- `docs/WORK_LOG.md`가 이 브랜치에서 **내 편집 이전부터** 40,516바이트로 부팅 예산
  40,000을 넘겨 `context_manifest_check`를 실패시키고 있었다. 내 편집분은 9바이트다.
  9월 1일 이전 항목을 `docs/history/WORK_LOG_2026-09-01.md`로 분리해 32,881바이트로
  낮췄다.
- 확인만 한 것: `story_demo_m1_m6_user_play`가 `done`으로 닫혔다. 이 원장에서 처음
  닫힌 사람 게이트이며 열림 45 / 닫힘 1이 됐다. 내 8월 31일 위임 판정은 CONDITIONAL
  이었고 최종 서명은 사용자 몫이므로 이 기록은 확인일 뿐 판정이 아니다.

## 2026-09-05 (Codex — ORDER-156 Chapter 5 생활 routine 배경 수리 선언)

- `042f5ea` 두 경로 화면 관찰의 실제 routine 오배치 6회를 보존 저장과
  대조했다. 고유 원고는 Property `REST[8]` 길의 만원, General
  `REST[5]` 공원 벤치, `SAVE[4]` 냉장고(두 번), `SAVE[0]` 집밥,
  `SAVE[1]` 구독 정리의 다섯 개다.
- 키워드 예외 대신 routine 데이터가 장소를 소유한다. 고시원 집밥은 기존
  공용 주방, 나머지 집밥과 구독 정리는 결혼·이혼을 포함한 실제 현재
  집, 길은 낮 거리, 공원은 새 낮 배경을 쓴다.
- W220 `31초 녹음`의 지하철 배경은 routine 6에 포함되지 않는 저작 선택
  에코 결함이지만, 같은 MainGame 장소 결정 경로이므로 별도 일곱 번째
  fixture로 함께 닫는다. 수정 전·후 실제 settled frame을 같은 검사로
  비교하며 새 exact 후보 전에는 플레이를 요청하지 않는다.

## 2026-09-05 (Codex — Chapter 5 저작 장면 장소·시간대 배경 완료)

- 산문과 맞지 않던 저작 사건 일곱 개를 실제 이동 결과 단위로 바로잡았다. 오전
  진료실, 같은 역의 계단/역무실, 낮 한정식집, 야간 콘서트 홀, 새벽 빌라 보수
  현장 여섯 배경을 추가했고 오픈하우스는 기존 빈 강남 아파트에서 시작해 현재
  집 또는 지하철로 끝난다. 원고·선택·효과·KO/EN·사실 안전선은 불변이다.
- 수정 전 정적 50건과 실제 StoryMode 오배치를 실패로 기록했다. 수정 뒤 한영
  32경우·도입 122문단·결과 100문단, StoryPlayback 156경우·1,044문단, crop
  39프레임, Chapter 1 변조 519건, 전체 68-script compile과 전체 감사를 통과했다.
- 제품 장면 commit `bf1ca506170af8e6212241f6e2ecf03c776da1ae` 뒤, 독립 리뷰가
  macOS 외부 제한 신호에서 검사 자식이 남을 수 있는 1건을 찾아 최종 소스
  `0655d4d9b6ee4f14d6bd74b0bd0a41f9e38cca88`에서 닫았다. 서사·검사·자산
  독립 리뷰 최종 blocker는 0이다. 여섯 raster는 B+/`PASS-B`이며 A급 master가 아니다.
- 자동·시각 계약은 정상 속도 사람 플레이와 재미 판정을 대신하지 않는다. 생활
  routine 6개를 실제 settled frame으로 닫은 새 exact 후보 전에는 플레이를
  요청하지 않는다. 두 Chapter 5 사람 gate OPEN, full·main·product HOLD다.
  세부 해시와 경계는 [완료 영수증](queue_archive/ORDER-155.md)에 보존했다.

## 2026-09-05 (Codex — ORDER-155 Chapter 5 저작 장면 배경 수리 선언)

- ORDER-154 종료 `f601f82`를 기준으로 화면 관찰에서 확인한 저작 event 7개의
  장소·시간대 불일치를 분리했다. 오전 진료실의 야경, 역 계단/역무실의 열차 객실,
  12:30 점심의 야간 고깃집, 점심 식탁의 거리, 콘서트 결과의 편의점, 빌라 현장의
  편의점, 오픈하우스 실내의 한강 산책로가 표적이다.
- 기존 자산 전수조사로 오픈하우스는 `gangnam_apartment`를 재사용할 수 있지만
  낮 진료실·역 2면·낮 한정식집·콘서트 홀·빌라 보수 현장은 새 raster가 필요하다고
  판정했다. 사람·브랜드·읽을 수 있는 간판을 굽지 않고 Gangnam Ink 화풍과
  960×600/1280×800 텍스트·초상 여백을 계약한다.
- 원고·선택·효과·사실은 보존하고 실제 이동을 고른 결과에만 배경을 전환한다.
  무작위 REST/SAVE와 W220 echo는 별도 runtime 경로이므로 다음 settled-frame
  배치로 남긴다. 두 배치와 새 exact 후보 전에는 플레이를 요청하지 않으며
  사람 gate OPEN, full·main·product HOLD를 유지한다.

## 2026-09-05 (Codex — ORDER-154 결혼 첫날·비교본 보관 이름표 수리 완료)

- ORDER-153 종료 `0e8c363`을 기준으로 결혼 첫날 네 root와 M56 비교본 보관
  `arc_y5_father_trace_custody`의 거짓 초상 이름표 다섯 건을 분리했다. 한 event의
  서술·민준·다은 발화가 섞여 있어 event-level 초상 이름을 실제 화자로 표시할 수 없다.
- exact 다섯 presentation에만 기존 hidden 계약을 적용했다. 다은 첫날밤 초상,
  민준 피곤한 초상, 배경·아침 CG reveal, 원고·선택·효과·follow-up과 공통
  StoryMode는 보존했다. 제품 `18006c9c529a9359452e39c7cd8c9ad98bb907eb`,
  tree `338e309f9313bb37455fded903a1cb52fbf381bd`, source manifest SHA-256
  `c4f26a3f7b78f3045cf2180324f89510b93de41a8607b1d118097028f6e1714c`다.
- 수정 전 정적 29건과 실제 StoryMode 이름표 274건을 실패로 남겼다. 수정 뒤
  KO/EN 결혼 체인·custody를 합친 24경우·262문단, 정적 self-test 71건,
  Year 5 267건, Chapter 1 장기 self-test 502건과 최종 7파일 영향 선택 43개를
  통과했다. 독립 읽기 전용 코드리뷰도 blocker 0이다.
- 이는 사람 플레이나 재미 GO가 아니다. 낮 진료실·점심·역·공원·오픈하우스·
  생활 vignette 배경을 별도 묶음으로 닫은 새 exact 후보 전에는 플레이를 요청하지
  않는다. 두 Chapter 5 사람 gate OPEN, full·main·product HOLD를 유지한다.
  exact 로그·해시·L2 경로는 [완료 영수증](queue_archive/ORDER-154.md)에 보존했다.

## 2026-09-05 (Codex — ORDER-153 W237 익명 보증 충돌 수리 완료)

- exact `042f5ea` Property 코덱스 화면 관찰에서 M53 재혁 보증 후 W237
  `amb_guarantee_00`이 다시 익명 친구의 보증·연락 단절을 만들고 W238
  재혁 채널로 복귀하는 중복을 확인했다. 독립 인간 인증은 아니며 전체 HOLD다.
- 익명 루트와 두 direct callback은 삭제하지 않고 W192까지 보존했다. 세 객체에
  `max_turn: 192`만 추가해 W193부터 재진입을 닫았고, 저작 M53 재혁선과 W238
  열린 채널 회수, 예전 세이브의 플래그·횟수·마지막 주차를 그대로 유지했다.
- 제품은 `f4c7fd9092b229d50ce4a742e64ffe42cb648b4c`, tree
  `323cd807590705e1b09b22452e1d2af037a6ac87`, source manifest SHA-256
  `de966d552a82c8f6b79b3886ff35c7a52ad8e37d3d6b2c8fa3656114ff8dfbfb`다.
  수정 전 정적 6건·Godot 38건 실패를 남긴 뒤 수정 후 정적 self-test 62건,
  KO/EN EventManager·구세이브 왕복·W238, Year 5 248건, Chapter 1 495건,
  최종 변경 8파일 영향 선택 73개를 통과했다. 기존 허용 종료 자원 경고를
  오류·경고 0으로 과장하지 않는다.
- 원고·재혁선·W238·공개 M01~M06은 불변이다. 다음은 결혼 첫날 네 장면과
  M56 비교본 보관 장면의 혼합 대화 이름표 다섯 건이며, 이어 배경 묶음까지 닫은
  새 exact 후보 전에는 플레이를 요청하지 않는다. 두 Chapter 5 사람 gate OPEN,
  full·main·product HOLD를 유지한다. 정확한 로그 해시는
  [완료 영수증](queue_archive/ORDER-153.md)에 보존했다.

## 2026-09-04 (Codex — ORDER-152 이름표 수리 완료)

- `d934741`의 M51 `남는 하루 말고`를 보존 turn-204 저장의 별도 격리 화면에서
  다시 읽었다. 다은 초상을 유지한 채 도입·민준 질문·다은 발화·선택·결과·월말
  복귀까지 거짓 `김다은` 이름표가 0건이었다. 독립 인간 인증이나 전체 후보 GO는 아니다.
- 전용 검사의 실제 StoryMode/autoload/Chapter 5 route 의존성을 선택 감사에
  등록했고, 실행 뒤 검증된 QA 저장 경로만 삭제한다. KO/EN 12경우·92문단을
  재통과했고 누적 테스트 폴더 25개도 제거했다.
- 기존 `042f5ea` Property 관찰은 M60 후일담·6/6까지 완료했으나 W237의 익명
  보증 사건이 M53 재혁 보증 뒤 중복 진입해 REJECT/HOLD다. 결혼·비교본 이름표와
  생활 배경은 별도 후속이며 두 사람 gate OPEN·full/main/product HOLD를 유지한다.
- exact 증거·규범 판정은 [ORDER-152 완료 영수증](queue_archive/ORDER-152.md)에 보존했다.

## 2026-09-03 (Codex — M51 이름표 부분 수리)

- 별도 브랜치에서 다은 장면의 이름표 계약 한 건만 수정했다. 원고·초상·선택·
  효과·공통 런타임·M6는 불변이다. KO/EN 12경우·92문단 L2와 최종 표적 43개 통과.
- 진료실은 미재현이다. 기존 후보의 Codex 관찰은 General 6/6, Property M51까지이며
  Mac 잠금으로 중단했다. 독립 인간 인증·새 전체 후보가 아니고 HOLD/OPEN 그대로다.
- exact 신원·실패/통과 로그·잔여 배경 진단·한계·일회성 규범 판정은
  [ORDER-152 완료 영수증](queue_archive/ORDER-152.md)에 보존했다.

## 2026-09-03 (Codex — ORDER-151 장소·기간·카지노 맥락 수리)

- af511ee/236d8eb의 두 경로 REJECT는 **Codex 화면 관찰**로 기록했다. 독립 인간
  인증이나 이전 후보의 GO로 합산하지 않는다. 사양 후 무약속·무동석·무식당은
  관찰됐으나 지갑 수락 결과는 미관찰이다. 선언 `7a83ce9` 뒤 표적만 수정했다.
- M54 기본 도입·다섯 변형·선택·결과를 이번 달 포함 일곱 달로 맞추고 실제 집을
  지정했다. 투자 계획은 미체결 계획이다. W224는 편의점 배경·생활음으로 정렬하고
  본문·두 영수증은 보존했다. 카지노는 집에서 안내에 사양/날짜 문의만 보내며,
  두 callback도 태도만 회수한다. 조건·index·효과·flag·예약 간격은 불변이다.
- 정적 self-test 50·최초 표적 감사 6·실제 StoryMode KO/EN×미혼/결혼/이혼
  156개·1,044페이지가 GREEN이다. 별도 1280×800 렌더 32장은
  `/private/tmp/gangnamdream-order151-rendered-final.n1qFlf`에 있다. 초기 캡처의 프레임
  제한 중단은 통과가 아니며 전환 분류 교정 후 새 렌더에서 정상 종료·오류 0을 확인했다.
- M55·지갑 세 root·W237/W240·30억 비밀 엔딩·공개 M6와 원본 slot 01·02는
  보존했다. 과거 exact 원장을 대체하지 않고 새 델타로 연결했다. 전체 볼륨의
  30개 알려진 과제와 수량은 그대로이며 source hash만 갱신했다. 심의 후보 검색은
  EN `on the bed`를 포함한 카지노 안내가 1건 추가 탐지됐을 뿐 사실 강도·등급
  결정은 바꾸지 않았다. 8/26의 오래된 두 로그는 기존 보관본으로 손실 없이 옮겼다.
- 최초 전체 감사의 전환 매니페스트 갱신 누락을 고쳤다. 카지노 한 root만
  explicit_move→remote이며 catalog 2·year5 222건이 통과했다. 실패 로그는 보존했다.
- 최종 전체 재감사는 종료 0·68-script compile GREEN이다. Chapter 5 50·year5 222·
  인과 원장 481건도 통과했다. 로그는 `gangnamdream-order151-audit-final.4EA6Sn`에
  보존했다. 새 제품을 docs-only 직계 검토 후보로 등록했다. 자동·자가 화면 증거는 사람 판정이
  아니다. 새 exact 후보의 두 경로 M49→M60→후일담→6/6 재플레이와
  지갑 수락 관찰 전까지 두 gate OPEN, full·main·product HOLD다.
- 제품 `2f91f4265613e57c8e3aaf34ab4f7f0971699f92`, tree
  `0c36eac8a45430c726c5e8d4812c1217918db3b1`, source manifest SHA-256
  `fabfcbe47a861ba37b3221c122fe8beab09499a8712b2ef8621944b3e7a2b89e`다.

## 2026-09-02 (Codex — ORDER-150 지갑 동의 재플레이 후보 발급)

- 새 제품은 `236d8eb2c532172c60da3fafce0fc1b768e38049`, tree
  `f6270643439f1c0ddecc8421c1c39d4d211b6ca0`, source manifest SHA-256
  `a227fd03518e5f8a1a6e33a3289ce93f77bebf600e87d49959c0becfc5003138`다.
- 지갑 반환 당일에는 분실물 접수 영수증만 남긴다. 8주 뒤 `chain_exec_meal`은
  초대에 답하는 화면상 선택이며, 수락할 때 민준이 가능한 토요일을 보내고 상대가
  토요일 12:30·강남 식당을 회신한 뒤 민준이 확인해야만 별도
  `chain_exec_meal_arrival`로 들어간다. 거절은 날짜·장소·달력·동석·도착을 만들지 않는다.
- KO/EN, lifecycle·exposed state·연출/오디오·release/번역/볼륨 파생 원장을 함께
  맞췄다. 전체 `tools/audit.sh`, 실제 StoryMode 초대→수락→도착 및 거절→무도착,
  Chapter 5 정적 self-test 29·Godot, Year 5 178, Chapter 1 478, 68-script compile이
  GREEN이다. 현황 도구도 review commit/tree가 active 후보와 일치할 때만 현재
  판정으로 표시하고, 직전 판정은 `현재 후보에 미적용`으로 분리한다.
- 공개 M01~M06 제품·번역·`project.godot`, 30억 즉시엔딩, 원본 slot 01·02와 두
  경로의 앞선 통과점은 변경하지 않았다. 직전 Property GO는 역사 증거일 뿐 새
  제품에 승계하지 않는다.
- `chapter5_finale_rc`는 active 식별자일 뿐 GO가 아니다. 전역 rare chain 변경이므로
  property와 `general_near_goal_father_passed`를 같은 새 후보에서 KO 정상 속도로
  M49→M60→후일담→크레딧 6/6까지 모두 다시 플레이한다. 두 사람 gate와 사용자 최종
  GO는 OPEN이며 full·main·product는 HOLD다.

## 2026-09-02 (Codex — ORDER-150 지갑 약속 동의 수리 선언)

- exact wrapper `390d786f7df711d34f7ad61d4abf4d6fc1bfe77f` / 제품
  `2e768643e53c5dbe84a864fcf3c0ba27e3c5501d`의 실제 디스플레이 최종 판정은
  Property GO / `general_near_goal_father_passed` REJECT / 전체 REJECT다.
- Property의 화면·시간·공동 주거·민서 입장·W240 책임과 general의 W240 무응답·
  미소유·아버지 불부활은 통과했다. 유일한 차단점은 지갑 주인의 식사 제안 뒤
  민준의 답장·수락·일시 조율 없이 `chain_exec_meal`이 약속을 성립시킨 것이다.
- 이 chain은 조건 없이 전역 도달하므로 과거 Property GO는 정확한 역사 증거로
  보존하되 새 제품에는 승계하지 않는다. KO/EN에 실제 수락 선택·상호 일정 영수증·
  거절 종결을 넣고 새 exact 후보에서 두 경로 M49→M60 전체 재플레이를 다시 받는다.
- 제품 수정 전 scope expansion 6를 선언했다. `chapter5_finale_rc`는
  `waiting_rebuild`, 두 gate는 OPEN, full·main·product는 HOLD다.

## 2026-09-02 (Codex — ORDER-150 exact 재플레이 후보 발급)

- 실제 디스플레이에서 둘 다 REJECT였던 제품 `83d3f350`을 기준으로, 결혼 뒤 주거
  회귀·달력 역전·화자 오표기·resume tutorial·고정 자산 문구와 general의 민서
  물리 동석·허위 외부 반응·후기 legacy 재진입·SNS 중복·credits 표기를 표적 수리했다.
- 새 제품은 `2e768643e53c5dbe84a864fcf3c0ba27e3c5501d`, tree
  `d246184955ad60af3eb4de41907b58afde9756da`, source manifest
  `6ac6f969f235787871c9d41dbbf98e8ca390c8a1ef2968b26ff23b26bf4d39f2`다.
- 전체 감사가 통과했다. Chapter 5 정적 25·Godot, Year 5 174, Chapter 1 478,
  영어 누수 후보 0, JA 69, ZH 273, 68-script compile이 GREEN이다. 주거 KO/EN
  이름은 ID별 인접 쌍으로 바꿔 영어 감사를 예외 없이 통과시켰다.
- W207/W230/W237/W240, M55 복장, 무이체·무소유·무응답, 30억 즉시엔딩과 공개
  M01~M06 바이트는 보존했다. BGM 경고는 기준본과 동일한 QA 종료 노이즈다.
- Claude의 ORDER-157(구 148)·149를 보존하고 이 수리를 ORDER-150으로 등록했다. 157은 이
  exact 제품의 사람 재플레이 뒤 재계측하고 149는 그다음이다.
- 후보는 active 식별자일 뿐 GO가 아니다. property와
  `general_near_goal_father_passed`의 KO 정상 속도 M49→M60→후일담→크레딧 6/6
  재플레이, 두 사람 gate와 사용자 최종 GO는 OPEN이며 full·main·product는 HOLD다.
## 2026-09-02 (Claude — 탐색 2라운드·P-18 결정·ORDER-149)

- **탐색 2라운드는 결함 0이다.** 선언 엔딩 35개 전부가 런타임·사건·메타 중 최소
  한 곳에서 생산되어 미도달 0건이다. 서로 다른 사건에 반복되는 60자 이상 문단은
  71건이지만 변종 계열을 접으면 5건이고, 그 5건도 전부 상호 배타 분기이거나 설계된
  공유였다. 특히 `arc_father_passing_platform`↔`_deal_room`은 승강장·회의실 양쪽에서
  한 번 더 되돌릴 기회를 주는 설계이며 공유 문장은 실제로 열차를 탄 쪽에서만 나온다.
  **변종을 접기 전 수치를 결함으로 보고하지 않는다**를 절차로 남겼다.
- `docs/PROPOSALS.md`의 `P-18`이 21일 결정 한도를 22일로 넘겨 부팅 게이트를
  실패시키고 있었다. 제안 자신의 권고대로 **1층만 승인하고 2·3·4층은 보류**해
  닫았다. 이는 게이트 한도 때문에 Claude가 내린 범위 결정이며 사용자가 뒤집을 수 있다.
- `ORDER-149`를 발행했다. `83d3f350` 재실측에서 `OpeningCinematic`은 313줄에
  `create_tween` 2회·`AudioManager` 0회이고 `FADE_SECONDS := 0.52` 하나를 세 비트가
  공유하며 `hold`가 3.10/3.10/3.00으로 균일하다. 상수를 비트 데이터 필드로 내리는
  일이며 새 자산·새 시스템·새 문안이 0이다. 2층(소리)은 출시 원음 조달이 선행하고
  3층(125년 계산)은 `ORDER-87` 사람 게이트를 다시 열며 4층(스플래시)은 1층 실물을
  본 뒤 판단하므로 `POST_LAUNCH_NOTES.md`가 보관한다.
- 어제 story demo 브랜치 감사 실패 4건을 재검증했다. 그 워크트리는 임포트돼 있었고
  FontKit 파스에러가 0이므로 **실제 결함이 맞다**. `ce57751`이 `scenes/StoryMode.gd`를
  고치면서 그것을 보호하던 ORDER-138 해시 매니페스트를 갱신하지 않았다. 오늘 o147
  워크트리에서 난 유사 실패는 임포트를 빠뜨린 내 환경 문제였고 재실행으로 해소했다.

## 2026-09-01 (Claude — 5장 원고·수치 검토·ORDER-157 발행)

- 인간 실플레이는 별도 세션이 소유하므로 이 작업은 **데이터와 문장만** 판정했고
  인간 게이트를 닫지 않았다. 검토 HEAD `84b6498`이 제품 `83d3f350`의 문서 전용
  래퍼임을 확인했고(런타임 diff 0) 제품 tree `97f81c70`·source manifest
  `6bc13de7…`가 선언값과 일치한다.
- `ORDER-138`이 요구한 구조 수리가 이행됐다. general 진입이 W237→W224로 당겨지고
  소유 주차가 3→8, 원장이 3 roots/7 choices→8 roots/17 choices, **최장 연속 공백이
  9주→4주**가 됐다. property는 소유 주차 11개와 뿌리 수가 불변이다.
- 원고 수리 네 건을 확인했다. W224 회수가 각주에서 갈래별 전용 장면 2종으로
  이동했고(결과 65자→177~204자), property W240이 read 4개를 잃지 않고 한 문장에
  융합했으며, M56·M59가 source 플래그에서 실제 소유 장면으로 승격됐고, 신규 W211이
  중개사의 공동명의 요구를 아버지의 마지막 상환확인서와 같은 프레임에 놓는다.
- 보존을 확인했다. W207 선택 2 결과 연출 계약과 W230 민서 입장 reads가 두 custody
  갈래 모두 바이트 동일하다. W230은 `description`이 아니라 `chapter5_finale_reads`가
  입장을 소유하므로 description만 보면 회귀로 오독된다. 실제로 한 번 오독했다가
  두 판본 전문을 대조해 정정했다.
- 정합은 통과다. 허위 사실 0이고 "읽음" 언급 4곳은 전부 부정문이며 25억 문턱·30억
  목표 금액이 일관된다.
- **`ORDER-157`을 발행했다.** 부정 종결 습관은 고쳐지지 않았고 오히려 밀도가 올랐다
  (general 종막 43→67, 0.93%→1.13%). 5장 종막 계열 결과문 248개 중 부정절 3개 이상
  32개, 마지막 문장이 부정인 것 53개, 합집합 69개가 수리 대상이며 property/공통
  27·startup 16·general 15·career 11로 코퍼스 전반의 습관이다. 이 오더는 허위 사실
  금지를 한 줄도 약화하지 않고 **부정되는 항목 집합이 전후로 동일함을 증명하는
  검사**를 핵심 안전장치로 요구한다.

## 2026-09-01 (Codex — exact Chapter 5 재플레이 후보 발급)

- 본편 제품 `83d3f350de0900ce050277d6da1331940d1872a3`에서 세 fresh-title profile을
  state injection 없이 W1→W240까지 완주했고, 오디오 strict teardown 12/12와
  import 후 전체 감사를 통과했다. 공개 M01~M06 `story_demo_rc` 바이트와 사용자
  GO는 바꾸지 않았다.
- 실제 W1→W193 제품 입력으로 property/general M49 수동 저장을 각각 만들고 KO
  냉간 불러오기에서 챕터 5·결산 진입과 입력·선택·상태 무변조를 확인했다. 자동
  증거는 사람 플레이를 대신하지 않으므로 본편은 HOLD다.
- 다음 사람 과업은 같은 exact review wrapper에서 property와
  `general_near_goal_father_passed` M49~M60을 정상 속도로 각각 완주하는 것이다.
  그 뒤 다음 20단위 제품 배치가 공개 M06의 3×5 실제 영수증을 M07~M12로 잇는다.

## 2026-09-01 (Codex — 공개 M01~M06와 본편 M01~M60 범위 정렬)

- 공개 출시 데모는 exact `story_demo_rc` BUILD `2026.08.31.1`의 M01~M06으로
  고정했다. 한 달 네 주인 내부 `W1~W24`·정산 6회 계측은 그대로지만 M07~M24를
  공개 범위로 늘리지 않는다. 공개 제품 바이트와 package/product/manifest hash는
  바꾸지 않았다.
- 옛 `demo_rc` W1~W24 V2는 `runtime_default=false` 저장 호환·회귀·역사
  증거로만 남겼다. 연결된 사람 게이트 27건을 삭제하거나 거짓 완료하지 않고 모두
  legacy scope로 옮겼다. 공개 `story_demo_rc`에는 사용자 GO 1건과
  JA·zh-CN·zh-TW 원어민 OPEN 3건만 연결된다.
- 열 개 checked-in `export_presets.cfg` profile 행과 별도로 `story_demo_rc`의
  외부 clean-source staging 계약을 release content inventory에 등록했다. 빌더는
  기존 macOS preset을 파생하고 `all_resources`를 유지하므로 M01~M06에서 실행되지
  않는 본편 리소스도 package 심의 범위에 포함한다. 공개 월 범위·내부 주차·
  StoryMode entry·다섯 locale과 사용자 GO 1건·native OPEN 3건을 함께 기계 검증한다.
- 공개 후보의 exact 원장은 package source `362578d`에서 KO/EN 사건
  `1,806/1,806`, shipping `1,696`, author-only `110`으로 다시 산출했고, 현재 개발
  소스 `1,812/1,707/105`와 별도 namespace로 분리했다. 실제 app ZIP
  `956ac935` 안 PCK `0e606643`의 1,481 entry·raw JSON 309개·raster import
  298개·audio import 139개를 exact source와 직접 대조했다. 공개 후보의 20개
  정성 사실·검색 축·자산 review도 frozen source ledger에서 렌더하므로 이후
  M07~M60 본편 원장이 늘어나도 M01~M06 패키지 사실과 섞이지 않는다.
- exact app ZIP은 실행 앱 7파일과 AppleDouble provenance 11파일의 경로·모드·
  payload를 고정했다. PCK 1,481개 payload의 directory MD5를 전수 대조하고,
  raster/audio 437개 `.import`가 frozen source와 같은 importer·type·유일 target을
  가리키는지 검사한다. PCK-only ZIP, 다른 CG target 치환, type 치환, payload
  손상과 중간 성공 marker를 self-test 45건이 거부한다. `human_gates.json`의
  active 후보와 네 공개 데모 행도 whole-row digest로 묶어 M01~M60 GO나 원어민
  완료 문구가 acceptance·sample·note에 삽입되는 변조를 거부한다.
- 현 작업 tree의 전체 볼륨 감사는 60개월·169 scheduled refs·139 shipping-eligible
  refs·478 static paths·471 choices를 관측했다. 알려진 debt는 30건으로,
  M52~M60의 `NEW/planned` 11건과 제품 ingress 없는 `author_only` 19건이다.
  이는 실제 한 경로의 분량이나 재미 점수가 아니며 본편 `HOLD`, runtime 사람 밀도
  `OPEN`을 유지한다.
- 정본 정렬 구현 `b18aa03f5e469c19cdfe40e71e644b5549482200` / tree
  `aeddecc28d5a7fbe6036a08b6f0816bb38111e95`에서 전체 Godot 감사,
  causal self-test 478건, release self-test 45건, 실제 ZIP/PCK와 독립 적대 검토가
  모두 통과했다. 제품/runtime diff 0을 확인하고 ORDER-148을 완료 보관했다.
- 다음은 ORDER-147의 audio teardown을 clean exact에서 12회 stress·전체 감사로
  봉인하고 세 fresh-title profile을 W1→W240까지 재실행하는 일이다. 그 뒤에만 새
  exact Chapter 5 사람 재플레이 후보를 발급한다. 다음 15~25단위 제품 배치는
  M06 실제 영수증→M07~M12를 잇고 runtime occurrence와 story-map 월 소유권을
  대조한다. 진단 trace에서 세 경로 모두 비었던 M11 W41~W44와 M08·M10의
  상태별 장면, M11 receipt를 읽는 M12 보스를 먼저 수리한다.

## 2026-08-31 (Codex — 전체 볼륨 자식 배치 선언)

- ORDER-142 배치 A를 제품 변경 없이 `06277c30e61ed54c99069e16fd591ec0ef26c388`로
  푸시했다. 표적 감사 21개와 Chapter 1 반례 478건이 통과했다. Godot 부재로
  본편은 `HOLD`, runtime trace는 `PENDING`이다.
- ORDER-143은 월경계 A5/B2/C1과 `money→network`, Ch2 보스 raw chain의 guard
  우회를 typed graph contract로 고친다. M01~M06와 5장 사실 안전선을 보호한다.
- ORDER-144는 event-ID dedup 자동 완주를 제외하고 실제 새 게임의 occurrence·선택·
  receipt·주차·ending을 JSONL로 남긴다. 주입 없는 세 profile의 실패도 기록한다.

## 2026-08-31 (Codex — M01~M60 전체 볼륨 정적 기준선)

- 공개 데모는 M01~M06 `story_demo_rc` GO로 고정하고, 본편 작가용 편성 176 refs와
  생명주기상 제품 연결 가능 135 refs를 처음부터 끝까지 분리 집계했다. 제품 연결
  가능 표면의 root-ref 합계는 519 terminal path·476 choice·한국어 155,961자다.
  같은 immediate closure를 한 번만 세는 전역 합집합은 411 choice·133,752자다.
  둘 다 실제 한 경로의 플레이 분량이나 재미 판정으로 사용하지 않는다.
- 구조 debt는 exact 49개다. 파일이 없는 `NEW/planned` 16, 원고는 있으나 ingress가
  없는 `EXPAND/needs_rule` 25, cross-month 즉시 후속 8(강제 4·시간 역전 1·조건부
  1·분기 2)이다. Year 5 경력·창업 32 roots·86 choices는 `reference_only`로 별도
  보존하고 본편 분량에서 제외했다.
- `full_game_volume_audit.py`는 새 debt와 해결된 allowlist debt, 관측 집계 drift를
  모두 baseline
  재발급 없이 거부하고, memory/decision/carryover write-only, KO/EN topology,
  cycle·zero terminal, 초록 audit/제품 GO 혼동 반례 14개를 거부한다. 출력은
  정적 `HOLD`, 실제 런타임 trace `PENDING`, 사람 밀도 판정 `OPEN`을 고정한다.
- spine phase root를 story-map의 직접·지연 closure와 별도 대조해, opening·chapter
  card 8개를 제외한 gap 21개를 찾았다. 특히 Ch2 보스의 raw follow-up은 무직·미입원·
  아버지 별세 상태의 가드를 우회할 수 있어 다음 graph-contract의 최우선이다.
- 영향 감사에서 공개 데모 저장 복구 커밋 뒤 갱신되지 않은 Chapter 1 인과 원장의
  `StoryMode.gd` 전체 파일 SHA-256을 발견했다. 제품 코드는 바꾸지 않고 현재 exact
  바이트로 스냅샷만 갱신했으며 direct/self-test를 다시 실행한다.
- 다음은 8개 edge를 같은 장면 chain·독립 월·조건부/deferred 중 하나로 귀속한 뒤,
  실제 `MainGame`·`StoryMode` fresh-title W1~W240 occurrence trace를 만든다. 그
  결과가 나오기 전 정상 경로 공백을 원고 수로 덮지 않는다.
- 8개 edge의 원고와 런타임 우회를 직접 대조해 같은 장면 chain 5, 독립 월 2,
  조건부 미래 월 1로 판정했다. 인접 조사에서 `money→network`가 상철 선행·자산
  guard를, Ch2 `상철 거울→직업 천장→아버지 병실`이 직업·입원·생존 guard를
  우회하는 것도 확인했다. 다음 graph contract는 이 P0를 함께 막되 M01~M06 제품
  그래프와 이미 통과한 5장 사실 경계를 바꾸지 않는다.

## 2026-08-31 (Codex — 공개 스토리 데모 consequence 후보 발급)

- M2의 dirty 선택을 M6 restitution·escalation root에서 서로 다르게 청구하고,
  M3~M5 exact 선택 문장을 M6 도입이 읽으며 M6 뒤 대가 ledger가 고른 한 줄과
  포기한 네 줄을 남기게 했다. 14 variant·29 visible option·28 receipt selector,
  clean 360 + restitution 720 + escalation 720 = 1,800 합법 서명을 고정했다.
- BUILD `2026.08.31.1` 제품은 `4e80a63e89821094b8bab21b8d5c73ecfc9b6278`
  / tree `0fdddf11e2ef030cd172d23e691e3d7da4ea29ff`, package source는
  `362578d8f4c0781fe35f643a74cc3037e7a80b21` / tree
  `e7f50b065b3369afa1894df8292756a95f94fd11`이며 보호 runtime diff는 0이다.
- manifest SHA-256은 `50eed10b18c2c2b056f875a8df55230dc07b5535c55e59ddb89fff1d64e91870`,
  ZIP은 `956ac93524df6030ef984521550cec7dddafea381387a3df52194e43f5e61289`,
  app tree는 `56a4f2997256e68baa21c02807fcf1f0e995ce114f57f96f26d309b300b7ec14`다.
- 실제 StoryMode clean/ko 9, restitution/en 10, escalation/zh-CN 10 영수증
  경로가 각각 24주·정산 6·수동 저장·별도 프로세스 cold restart·exact resume를
  통과했다. 기존 BUILD `.25.1` M2 저장은 새 Chapter-5 원장 두 키가 없다는 이유로
  migration 앞에서 막히던 validator를 두 명시 키만 허용하도록 수리했고, 실제
  저장 복사본이 byte-exact로 이어졌다.
- JA·zh-CN·zh-TW는 각각 14/14사건·100/100 leaf·121/121 UI·catalog 1/1이다.
  자동 증거는 정상 속도 밀도·재미·화면과 원어민 문체를 승인하지 않으므로 네
  사람 게이트는 OPEN, main과 본편 이관은 HOLD다.

## 2026-08-31 (Codex — 실종 ORDER-124 BUILD `.2` 아카이브 보호)

- BUILD `.2` ZIP은 실종됐고 재빌드 hash도 달라 복구로 표시하지 않았다. exact
  manifest/checksum과 `archive_restored=false`, `candidate_eligible=false`를 고정했다.
- `cb06744`는 exact 실물 또는 selected-source의 `missing_with_loss_receipt`만
  허용한다. 204개 변조와 독립 검토를 통과했고 사람 게이트는 그대로다.

## 2026-08-31 (Codex — 공개 스토리 데모 선택 밀도 exact 실측)

- active `story_demo_rc` exact `16675f6` / tree `aed6904f` / BUILD
  `2026.08.25.1`을 제품 변경 없이 읽어 M01~M06의 11 runtime variant·24 choice와
  실제 controller·StoryMode 소비자를 연결했다. clean 360 + fallout 720 = 1,080개
  고유 완주 signature가 9개 영수증과 6회 정산을 가지며, 전부 생존한다.
- 기존 selector 검사는 17/24만 고른다. M6는 M3~M5 exact 선택을 읽지 않고,
  M2 환수 callback은 M6 전에 due가 되어도 데모 안에서 소비되지 않으며, M6 다섯
  선택은 recap 뒤 이야기 독자가 없다. clean 재유혹 0, fallout 심화 후 세계 반응 0,
  비-bridge 21개 중 명시적 포기 없음 6개, 보이는 수치 변화 18/24 대 exact 이야기
  독자 6개를 다음 최소 수리의 입력으로 확정했다.
- 측정기 구현 `a4d3271`은 exact commit/tree/BUILD와 8개 Git blob, 24개 ordered
  축 분류, 실행 가능한 receipt/follow-up true branch와 selector caller를 고정한다.
  Python self-test 44·JSON assertion·정적 감사·Godot 4.6.2 전체 감사와
  68 스크립트 컴파일이 실패 플래그 0으로 GREEN이고, 독립 반례 검토
  P0/P1/P2도 0이다. 자동화는 사람의 정상 속도 밀도·재미를 판정하지 않아
  두 값은 `not_measured`, 사람 게이트는 OPEN이다.

# ORDER-514 — 수리된 마지막 주를 실제 저장에서 엔딩까지 확인한다

#### [~] ORDER-514 [P1·실제 종막] W238 실제 Load→W240 원장240→후일담6/6→Quit

**착수 — 2026-10-10.** [513](../queue_archive/ORDER-513.md)의 기록 수리를
main에 올렸다. [457](../queue_archive/ORDER-457.md)이 실제 메뉴로 저장한
W238을 새 격리로 그대로 이어 실제 마지막 선택·원장/기록 일치·끝까지 입력을 본다.
준비 fixture/다른 source의 앞 구간/인간 관찰과 구분하는 한 단위다.

## 근거·깊이

- 지우면: 자동 상태 비교만 남고 실제 마지막 화면의239/240 결함 수리가 확인되지 않는다.
- 장기 상태: 진짜 outbound와 정산/자동저장·기록이240주 한 번으로 이어지는지 본다.
- 경쟁: 주차/flags/자산을 주입하거나 앞선 실제 선택을 바꿔 도달성을 만들지 않는다.
  같은 원저장을 새 격리에 byte-copy하며 실제 Load 메뉴와 개별 키 입력만 사용한다.

## 소유·파일 범위

- root 기존 비공개 `.git/chapter5-replay/order457-continue.py`: W215 helper 원문을
  보존한 뒤 checkpoint path/SHA/bytes/turn·unit/mode literal만 W238/514로 바꾼다.
  안전·격리·시간제한·종료·snapshot logic 불변. 새 runner/checker/계측0.
- 원저장: `GangnamDream_StoryNameplateQA_50b35a3247b70dfcd274a7034b67c702/`
  `gangnam_dream_slot_1.json`,156239B,
  SHA`e05a456c5f9c429a9a4bd4ccde83d08699c508612360fcade29190e04438f157`.
  W238/2030-12 W2·건강86/정신100·resume{}·분류237·pending ending.
  사용자 저장33/원seed2/과거 W195·W200·510bak·W215·W238·최종 W240은 불변.
- root 새 격리 실제 EN1280×800: 언어 선택→실제 Load slot1→W238/W239→같은
  W240 주소/알림 삭제와 민서 선발신01→Investment Master/후일담6/6→Main Menu/Quit.
  선택 전 본문을 정상 속도로 읽는다. AUTO/일괄 입력/주차 주입/텍스트 스킵0.
  실제로 나온 장면만 기록하고 조용한 주차·미포착 문장을 추론하지 않는다.
- root 운영: 이 사양/완료 archive·큐·WORK_LOG·CLAUDE 마지막갱신·생성STATUS와
  agent_review_decisions의 관찰/보존 한정 결속. 새 오더별 형식 보고 파일0.
  비저자는 실제 원관찰/로그/저장·source와 전후 보호 dictionary를 독립 대조한다.

## 실행·완료 경계

선언 commit/push 후 기존 helper를 literal-only 갱신하고 clean source를 prepare한다.
prepare→엔진 정상 Quit→fresh snapshot까지 제품/문서/기존 증거 쓰기를 동결한다.
새 evidence/storage에만 로그/메뉴가 만드는 저장을 허용한다. user editor는 건드리지 않는다.

정확 격리 marker·정상 Quit/exit0·엔진 오류/경고0·원본 전후 동일을 원로그로 본다.
W240 원장 네 칸 합240/기간240과 기록240, last action 소비/버퍼clear·consumed·
중복 run record 없음은 실제 화면/최종저장을 각각 대조한다. 새 엔딩/돈·관계 사실은
만들지 않는다. 실패/미관찰은 있는 그대로 남기고 별도 수리한다.

513 준비 EN11의 동일PNG 도구 표시차도 실제 원장 관찰로 보완한다. 자연 재생은
에이전트 관찰이지 인간/원어민/물리패드/청취가 아니다. Property·다른 엔딩·전체
W1~240 한 후보·JA/zh 실제 재생·전체제품/외부출시는 이 단위 GO가 아니다.
새 source 수정/원문/번역/project.godot/사용자 저장/공개 데모/과거 인간 판정0.
기존 제품 계약 검수만 수행하며 새 정본 규칙0·일회성이다.

## 2026-10-10 첫 시도 — Mac 잠금·실제 재플레이 HOLD

선언 source `af420e6dd26e4a0268f8721764974d72ac3e02c8` / tree
`d6f0f4f1da858a322266f138fc5e20b5eff57535`. 기존 helper literal-only 갱신과
W215 원문 보존(SHA`da05b3d62de76315078508a7a62728798821e6f51bb69df11eaaf6708fa04569`),
현재 helper SHA`a85dad784cdf4c91916037acf3304134daf489b7201353917b4696339e1d6af0`.
prepare 입구의 잘못된 expected-head 한 번은 검증에서 거절됐고 evidence 생성 전이었다.
관측한 exact HEAD로 prepare한 아래 시도만 실제 실행 증거다.

- `.git/chapter5-replay/order457-w238-order514-live-20261010`의 fresh 격리
  `GangnamDream_StoryNameplateQA_99d2cb82ff3c6db55809d48da74fafb1`에 원 W238
  slot1 바이트만 복사됐다. 첫 CUA `listApps`가 Mac locked/자동 해제 실패를 반환해
  실제 Load/화면/게임 입력0이다. 잠금 우회나 사용자 편집기 조작은 하지 않았다.
- own launcher26216만 SIGINT로 기존 safety cleanup을 호출했다. own Godot26285
  exit−9/`interrupted`/`KeyboardInterrupt`1/39.054초, 자동입력0/NOT_ASSIGNED다.
  정상 메뉴 Quit/실제 재플레이 PASS로 쓰지 않는다. result SHA
  `93a0b4f3537e910fcadcd8c447b7103ecb169484dd9532db5c481e9fa9b48bd1`.
- stdout/godot 각300B·SHA`3e779217806cc1ba5914caa2866db859e96a41d77eed8a18b25d37f39c0d742f`,
  정확 격리 marker1·엔진오류/경고/누수0, stderr0B. 새 격리는 slot1 한 파일만
  보존하며 원 W238의156239B/SHAe05a456…와 같다.
- root와 `/root/phone_independent_review`가 종료 직후 새 helper.snapshot 전수로
  prepared.before=entry.before=result.before=result.after=current를 각각 대조했다.
  clean tracked3249/helper5/seed2/player33와 원 W195/W200/510bak/W215/W238/옛W240
  불변, own26216·26285 부재/user editor61385 생존. 보존만 GO, actual HOLD다.
  독립 엔진/CUA/입력/수정0. 동결을 해제하고 잠금 없이 가능한 확인된 EN 수리를
  별도515에서 진행한다. 다음 실제 시도는 잠금 해제 뒤 새 evidence/storage를 쓴다.

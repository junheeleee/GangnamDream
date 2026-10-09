# ORDER-510 — 저장 복원에서 이미 읽은 주차에 랜덤 사건을 추가하지 않는다

#### [~] ORDER-510 [P1·저장 복원] 소비된 foreground의 추가 추첨 차단

**[~] 착수 — 2026-10-09.** 457의 실제 EN 메뉴 재플레이에서 확인했다.
source6977의 W200 Main 저장은 resume={}·foreground_story_turn=200·month_event_turn=199다.
정상 현수 통화 복귀는 보드로 가지만 실제 Load Game→slot1은
_ready→_begin_month→_maybe_play_month_situation에서 yolo_spend_moment를 추가 추첨했다.
월초 경제·시장국면·지연거리·회식직업 문제는 이 수리와 섞지 않는다.

## 범위·소유

- root: scenes/MainGame.gd의 _maybe_play_month_situation 진입 guard/같은 줄 수 주석만.
  이미 저장된 foreground_story_turn과 기존 판독 helper를 사용한다. 새 저장 키·스키마·
  사건/효과·문장·번역·경제·엔딩·데모 후보를 추가/변경하지 않는다.
- phone_cn_author: 기존 tools/ManualSaveCheck.gd에 소비된 주차의 디스크 왕복·
  Main 진입·추첨 latch/cooldown/queue 불변과 미소비/다음 주 허용 반례를 추가한다.
  별도 검사/runner·audit등록·이력고정·계측·재사용 프레임워크는 만들지 않는다.
- phone_independent_review: 실제 원관찰/source/변경/기존 엔진 증거를 직접 대조,
  저장 보존과 제품 행동 한정 판단. 새 오더별 형식 보고/인간 판정은 쓰지 않는다.
- root 운영: CLAUDE·CODEX_QUEUE/L3 순번·이 사양/완료보관·WORK_LOG(예산 시 원문 보존
  롤링)·생성 STATUS. project.godot·사용자 저장·과거 인간/공개 판정은 변경0이다.
- root 실제 화면: 기존 private .git/chapter5-replay/order457-continue.py의 원문을
  보존한 뒤 checkpoint 경로/SHA/151708B/turn200 및 unit/mode literal만 이번 재현에
  맞춘다. 원 W195·seed2/player33·전체tracked/helper 전후 검사, pre-autoload 신규
  격리와 개별 OS 입력은 유지한다. 새 실행기/검사 도구/자동 입력/상태 편집은 없다.

## 입력·깊이

- 재현 원본: GangnamDream_StoryNameplateQA_34722084693ccc205576ab7587902b19의
  gangnam_dream_slot_1.json.bak. 실제 yolo 추가 추첨 직전 W200 저장 그대로,
  151708B/SHA911fd3955ba87ad217c854aaf8633c02118b6c4e334334aaef728f37359ee6e3.
- 지우면: 이미 읽은 주를 불러오는 것만으로 새 선택/효과가 생겨 저장 경로가 달라진다.
- 24주 후: 복원하지 않은 플레이어에 없던 추가 사건·선택 효과가 누적될 수 있다.
- 경쟁: 기존 한 주 한 foreground 소유와 다음 주 신규 장면의 정상 진입을 함께 지킨다.
  새로운 선택이나 분기 예산을 만들지 않는 기존 저장 복원 수리1단위/1배치다.

## 검증·완료

기존 저장 fixture의 consumed-current·stale·missing/next-week 가드 반례,
격리 정상엔진 ManualSaveCheck exact marker+stdout/stderr/engine 오류0,
실제 메뉴에 원본을 byte-copy한 W200 slot1 불러오기→동일 보드/추가 장면0→정상 종료.
자동 fixture를 실제 읽기/OS 입력으로 포장하지 않는다. UI 원문/collector/번역 원장과
공개 데모 영향은 기존 audit_select의 표적 검사로 확인한다. 스케줄러 진입 가드 변경의
최종 전체 감사는 main CI에서 확인하고, 반복 local whole audit/240주를 추가하지 않는다.
독립 actual Git·원본 저장 보존·표적 증거 대조 후 해당 수리만 닫는다.

정본 규칙 신설0, 위 소유·재현·배치는 일회성이다. 이미 존재하는 한 주 한 foreground
가드와 저장 복원의 일치를 수리하며 M60/후일담6/6·전체번역·인간/원어민/패드·출시는 별개다.

## 실행 증거 — 실제 메뉴·최종 CI 전

- MainGame guard/주석2줄만 수정, 기존 ManualSaveCheck에 합성 W200 디스크 왕복·
  Main 진입·전체 serialize/flags/queue/cooldown 무부작용·missing/stale/next-week의
  실제 후보 handoff와 기존 latch/첫 주 반례를 추가했다. 원문/번역/저장 스키마0이다.
- 격리 정상엔진 6f459b3eebb27d586488f8a85444dcd9: exit0/정확 success marker1·
  pre-autoload marker1. stdout/stderr/godot의 parse/script/engine ERROR·leak0이다.
  기존 실패주입·구버전·복구 fixture의 경고13개는 보존한다. root wrapper가 WARNING까지
  묶어 exit1인 원 result를 덮지 않았다. 비저자가 원 backtrace/13경고의 기존 실패주입
  분기·새 함수 경고0을 직접 대조해 비예상 오류0으로 한정 수용했다.
  private .git/chapter5-replay/order510-manual-save-20261009의 원로그/결과,
  tracked3242/helper5/player33/seed2/checkpoint 및 별도 원W195 전후 hash 불변이다.
- EN/한글·EN coverage·JA UI·i18n·demo scope·서사 연속성·장면 음악 표적7 PASS.
  이전 c0e8188/fc1a730 main CI 실패는 connector 실제 로그에서 STATUS_DOC_EXIT1개,
  COMPILE_CHECK_OK68을 확인했다. 510 guard 이전 실패이며 새 제품 CI 통과로 쓰지 않는다.

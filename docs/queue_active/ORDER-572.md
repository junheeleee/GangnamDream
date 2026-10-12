# ORDER-572 — 월말·마지막 기록 간체·번체 직접 번역

#### [~] ORDER-572 [P0·전체 현지화] 착수 — 2026-10-12

사용자 전체 번역 위임/ORDER-157의 후속이다. 기준7a6cbc72/tree b43a3012의
아래 표시용8키×CN/TW=16 target만 채운다. 선행571 CI는 미확정이며
M17/562 OS잠금 HOLD 하나·새 월0을 유지한다.

## 깊이 3문·exact 모집단

1. 없으면 준비 중국어의 월말 변화·최종 기록/legacy 종료 안내가 EN fallback이다.
   기존 `_tr`→LocaleManager.ui→label/카드/버튼 소비자로 번역할 수 있다.
2. 선택·24주/5년 상태는 바꾸지 않는다. UI8의 부호/의미·6개월·시점·강도와
   미명명/부분 회복을 보존한다. 완료·건강 회복·후속 플레이 가능성을 발명하지 않는다.
3. 같은 기록 표면의 누락을 채우며 새 카드·행동·비교 키를 만들지 않는다.
   원문의 기존 legacy 6개월 안내를 공개 story_demo_rc 교체로 주장하지 않는다.

| KO source key | MainGame.gd 소비자 |
|---|---|
| 최종 기록 | _add_ending_mood_card / _build_time_ledger_card |
| 마지막 거처 | _add_ending_mood_card |
| 도시는 이 결말에 아직 이름을 붙이지 못했다. | _ending_card_signal_line → mood card |
| 6개월 기록 | _build_time_ledger_card의 is_demo 분기 |
| 아침에 일어날 때 몸이 지난달보다 덜 굳어 있었다. | _show_month_summary의 health 증가 분기 |
| 방 안의 작은 소리들이 다시 하나씩 들리기 시작했다. | _show_month_summary의 mental 증가 분기 |
| 데모는 여기까지입니다. 지난 6개월의 기록을 확인하고 풀버전에서 이어질 선택을 살펴보세요. | _show_month_summary의 legacy demo-limit 안내 |
| 6개월 기록 보기  › | 같은 분기의 _show_demo_ending 버튼 |

실제 source/표시 경로를 읽은 것이며 렌더/native 실행 증거는 아니다.
탐색에서 찾은 `현실`은 _ending_add_unlocks의 번역값 비교용이라 제외한다.
그 기존 코드의 언어 의존성은 별도 수리 후보, 이 오더의 runtime 변경0이다.

## 정확한 소유·병렬

- root: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각 신규8키 및
  `content/meta/full_game_localization.json` accepted16/checksum/UI batch1만.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, CN KO 직접 초안·
  공식 export/check/import와 원receipt 편입, private 원출력 보관.
- mod_layer_ci: TW KO 직접 초안만 `.git/order572-20261012/tw.draft.json`.
- manual_save_ci: 같은 private 경로의 fresh 보존 before 자료만, tracked 편집0.
- rework_batch_plan: 비저자 KO8↔target16/공식receipt·역치환·비소유 보존 최종 검수만.

원문/KO/EN/JA·runtime/선택/조건/효과/플래그·collector/검사·source manifest·
project/presets·SHIPPING_LANGUAGES·공개 demo121/원문/pin·사용자/공개 저장/설정·
Human/과거 판정·옛 raw/seed/app은 비소유다. 새 도구/검사/등록·최적화·엔진/
전체 audit/240주/새 월0이다. 기존 helper/validator/named lane만 재사용한다.

## 수용·완료

- 선언 commit/push 뒤 exact8 source-bound export/locale, protected=false/
  이전값null을 확인하고 두 언어를 KO에서 독립 작성한다. 중역/간번 변환0.
- 비저자16 전수 대조 후 공식 check/import --accept. 원공식receipt header/digest를
  portable batch에 보존하며 기존 accepted/batch prefix/사전값·순서 불변이다.
- 기존 4파일 append inverse와 실제 선언 Git source manifest, named
  full-game-localization-overlays preview/실행, context/queue/diff를 확인한다.
  verifier를 바꾸지 않아 그 self-test나 옛 전체 suite를 반복하지 않는다.
- 새 실패0·독립 source/영수증 GO·비소유 byte 보존 뒤 마감한다. 실제 렌더/
  원어민/인간/물리패드 OPEN·전체 번역 INCOMPLETE·본편/출시 HOLD는 그대로다.
- 기존 I18N 정본/강남드림 개발 스킬을 적용한다. 이 모집단·소유·순서와 검증은
  일회성, 새 규범/승격0이며 자동 검사는 재미·문체·인간 또는 출시 GO가 아니다.

# Active Queue Spec: ORDER-238

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-238 [P0·현지화] 승인된 중국어 폰트 전체 지문을 원장에 보강한다

**[~] 2026-09-10 Codex 착수 — 아래 13파일만 소유한다.** 기준은 clean
`69936d63a935b6ca7ebace60d3c8af66e40bfa65`, tree
`ad7686b01b49437df7632ec75f8d5de63ca5c302`다. 기존 중국어 경로 수리 뒤
실제 CN/TW 고정6글리프는 있으나 원장 full SHA 누락으로 준비 상태가 막혔다.
이미 승인된 파일 지문을 빠짐없이 기록하는 데이터 수리이며 새 서체/법률/출시 판정이 아니다.

## 깊이 3문

1. 없애면 무엇이 깨지는가: `_font_ledger_bundle`이 승인된 SC/TC도 full SHA 부재로 거부한다.
2. 장기 상태 차이는 무엇인가: 번역·원문·선택·240주 상태 변화0. 실제 원장 검증 상태만 바뀐다.
3. 무엇과 경쟁하는가: 검사 완화/새 폰트보다 기존 승인 지문 보강을 선택한다. 기존 채택표의
   short16 계약은 다른 소비자가 읽으므로 교체하지 않고 별도 구획에 full64를 둔다.

## 정확한 파일 소유권

제품2:
- `assets/fonts/FONT_LICENSE_LEDGER.md`: 기존 채택8행·7열·short16와 OFL5행·문구 보존,
  기존 헤더와 겹치지 않는 분리 구획에 SC/TC full64 두 행만 추가.
- `content/meta/third_party_notices.json`: 기존 순수 생성기로 생성한
  `generated_from`의 위 원장 SHA scalar1만 갱신. 역치환하면 기존 raw와 같아야 한다.

운영11:
- `tools/audit_scope.json`의 명시 차선 `chinese-font-ledger-pins`만 등록.
- `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`.
- 이 사양, `docs/queue_archive/ORDER-238.md`.
- `docs/WORK_LOG.md`, `docs/history/WORK_LOG_2026-09-07_localization.md`.
- `docs/STATUS.md`, `docs/agent_review_decisions.json`.
- `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`.

## 입력·보존 경계

승인값은 `docs/I18N_INFRASTRUCTURE.md:410`의 기존 SC/TC full64와 실제 TTF raw다.
`order238-author-baseline.json`(git-private) 32핀 SHA
`e16d092c0817e993566200d16011c04f776f49bbde7738d26691998da6873772`를 보존한다.
원장5584B SHA `b355a17c965564e2bf45fb07dc2aa44f7a30bfe050372210271e50c5a573edc8`,
고지30408B SHA `e62eec2a7844dfb6e00820be8378a03f9d354f84a78ef621322facf7f58df830`.
기존 고지의 지문은 현재 원장과 일치하며, 처음부터 stale이었던 것으로 쓰지 않는다.

코드·폰트8·OFL5·오디오·FontKit/UIStyle/LocaleManager·KO/EN/번역·수용38,437/b96/meta9·
project/export·인간103390B·출시 원장·과거237보고는 비소유/raw 고정이다.
`third_party_notice_audit --write`는 오디오 고지도 쓰므로 실행하지 않는다.
`load_snapshot/build_notice/rendered_json`으로 메모리 생성 후 owned JSON만 apply_patch한다.
`rendered_audio_notice`는 현재 raw와 같은지만 검증하고 쓰지 않는다. 추가 생성 차이가 있으면 중단한다.

공개판 source `362578d8f4c0781fe35f643a74cc3037e7a80b21`, tree
`e7f50b065b3369afa1894df8292756a95f94fd11`, manifest SHA
`50eed10b18c2c2b056f875a8df55230dc07b5535c55e59ddb89fff1d64e91870`를 재고정하지 않는다.
기존 패키지·인간 GO1/OPEN45는 별도 역사 증거다. 현재 checkout에 conventional 앱/ZIP/manifest가
없어 실물 보존을 새로 관찰한 것은 아니다. 새 원장으로 옛 pack을 검사/재빌드/재배포하지 않는다.

## 고정 검증·최종 판정

- Rawls의 사전봉인 `order238-independent-ledger-controls.json` 40688B SHA
  `c0fe93c7c3e79a4587a53c8e73754210ed7b84279324de7826d54b07e137da9e`:
  oldblocked2/정상2/그 정상에 연결한 변조12. 기존 helper와 메모리 원장만 사용한다.
  helper의 ledger전체 fullhash 검색을 행명-해시 귀속의 더 강한 검사라고 부르지 않는다.
- 제품 수정 전 위16을 한 번 실행하고, 수정 뒤 실제 CN/TW `font_route` 각 고정6 표본을 한 번 확인.
  코드 무변경이므로 같은16/237전체self/수용전량을 반복하지 않는다.
- `python3 tools/audit_select.py --lane chinese-font-ledger-pins`: 고지 self(15 변조,
  임시 ZIP fixture는 실제 게임 패키지 아님), 등록 검증, queue index self, agent decisions self,
  always context/queue 포함6개. 최초 결과와 입력 지문을 보존하고 실패 시 같은 범위를 재검한다.
- 원장 구획 역제거·고지 SHA 역치환으로 제품2 raw 복원, 나머지 보호핀/코드/인간/공개역사 불변.
- 저자 Plato와 다른 Poincare가 제품2·증거 전수/소스 신원·실패·한계를 읽고 work_unit238만 판정.
  보고 경로는 resolver 허용 `docs/queue_archive/ORDER-238.md`; 사람/원어민/렌더/물리패드/
  원격CI/전체판/공개출시 GO를 발급하지 않는다. Godot·collector·전체감사·240주 실행0.

## 원문 이동·마감

완료227/226 연속 원문860B SHA `9501216db19c2c728a0842a24bec269310230791d82f71e45e504f822cce77fd`
를 WORK에서 기존 history 맨 앞에 raw 이동한다. WORK38363B/EOF2, history85927B/EOF1,
각 역복원으로 기준39223/85067B 확인. 완료 절은1500B 이하(최대39863B), 기존 내용 압축0.
완료 시 큐2는 기준raw복원·active 원문은 archive에 보관하며 내부 원장24→25만 추가한다.
규범은 기존 I18N/WORK_UNIT 그대로이며 이번 범위·봉인·마감 절차는 일회성이다.
자동 게이트는 계약 증거이지 재미·깊이·문체·실제 화면 품질의 증거가 아니다. 본편 HOLD 유지.

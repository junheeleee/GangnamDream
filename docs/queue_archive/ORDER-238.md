# 중국어 폰트 전체 지문 보강 — 결과

ORDER-238. 제품2 데이터 수리 완료, 표적6 PASS와 실제 정적 CN/TW 준비 상태 확인.
Poincare 독립 최종 판정은 이번 work_unit 한정 GO/필수0·선택0이다. 본편 HOLD·공개판 사용자 GO 원형 유지.

## 범위와 실제 변경

기준 `69936d63a935b6ca7ebace60d3c8af66e40bfa65`에서 기존 서체8·OFL5를 그대로 쓰고,
승인된 SC/TC의 full64만 추가했다. 원장5584→5999B(+415)이며 기존 채택8행/7열/short16,
출처·저작권·법문·OFL5행은 추가 구획을 역제거하면 byte-exact다.

| 실제 제품 파일 | 최종 SHA-256 |
|---|---|
| `assets/fonts/FONT_LICENSE_LEDGER.md` | `a42a11abb11cee3e146ddf2057e426b299a04b739ed22d07211081b4565f3b9d` |
| `content/meta/third_party_notices.json` | `df349fb33c8f856c36a0fc10e236afeff179d4468cb8d58b8bd0cbbff66f355a` |

고지는 기존 순수 생성기를 메모리에서1회 실행한30408B와 같다. 변경은
`/generated_from/1/sha256` 하나이고 역치환하면 기존30408B/e62eec2a…f830 원형이다.
표면 문자열·순서·항목·분류·배포 목록·나머지 출처 지문은 그대로다.
`--write`는 오디오 고지도 쓰므로 사용0. 생성된 오디오 문자열과 기존3739B raw는 같고 쓰기0이다.
생성 실제 입력158·확장보존176 전후exact/errors0, 적용 후176중175불변·고지1승인차이다.
코드·폰트·OFL·오디오·저장·KO/EN·세 언어 번역·수용38,437/b96/meta9 변경0.

## 독립 고정 대조와 표적 QA

- Rawls가 저작 전에 봉인한16: 실제 기존 차단2, 예정 정상2, 그 정상에 연결한 변조12.
  첫 실행16/16 기대 충족, 정상2가 실제 통과한 상태에서12 모두 거부했다.
  full행 누락·마지막 hex 변경·16자리만 유지·OFL링크 누락/탈출·명명된 OFL SHA행 누락을 각각 검사.
  `ledger_text`만 메모리 변조하고 실제 TTF/OFL은 읽기만 했다. 입력21 전후exact,
  helper16회/0.154초/재실행0. 기존 차단 결과도 보존했다.
- 기존 helper는 full SHA가 원장 전체에 있는지 찾는다. 따라서 이 PASS를 행명-해시 귀속의
  일반적 공격 검증이라고 부르지 않는다. 이번 두 행은 승인 원문과 실제 두 파일을 직접 대조한다.
- 명시 `chinese-font-ledger-pins` 첫 실행6 PASS/23.760403초, 입력289 전후exact.
  고지 감사 `components=1 font_families=5 font_files=8 audio_sources=21 audio_assets=139
  attribution_required_audio=1 presets=10`, self `mutations=15`.
  등록141, 큐self25/fence4, agent self222/HOLD/human unchanged, context/queue PASS.
  고지 self의 임시 ZIP은 fixture이지 공개 게임 패키지가 아니다.
- 전체 번역 수집·전량L1·237전체self·Godot·전체감사·240주·실제 화면 검사 실행0.
  코드가 안 바뀌었으므로 첫16을 결과만 얻으려고 다시 실행하지 않았다.
- Rawls 실제 원장 post는 CN/TW 각각 고정6glyph의 `font_route`를1회씩만 호출했다.
  두 경로6/6·ready=true·shared_han_jp_first=false·진단0, 내부 source_contract2는
  shared-role/recognized=true/errors0다. 투명 메모리 wrapper는 내부 반환만 기록했고 추가평가0.
  입력28 전후exact/0.080715초. 이 표본 준비 상태는 전체글리프·렌더·법률·패키지 GO가 아니다.

## 원형 증거

아래 경로는 `.git/full-game-localization/` 안의 비공개 작업 증거다. 원래 실패/기준 파일을 덮지 않았다.

| 파일 | bytes | SHA-256 |
|---|---:|---|
| `order238-author-baseline.json` | 13115 | `e16d092c0817e993566200d16011c04f776f49bbde7738d26691998da6873772` |
| `order238-independent-ledger-controls.json` | 40688 | `c0fe93c7c3e79a4587a53c8e73754210ed7b84279324de7826d54b07e137da9e` |
| `order238-independent-ledger-pre-result.json` | 23126 | `f9416bd9c5a95d3f2c46fbe4949c44686b460cc3caea43fef7e576a404e18dee` |
| `order238-author-memory-generation.json` | 89363 | `1f7e8da3a7f38b50c2bdd0a15072453d19332d99289b55a8f16a74feb04fe3ee` |
| `order238-author-final.json` | 9953 | `8b2f493bd49669fea79bd74c2a89b834c7b2bd9772ef25326b54861712f132f1` |
| `order238-named-qa-first.json` | 91824 | `a129a24a03ace102017c1d2b57e54831334d8f4bd3807c71fff5f4b8e0b92935` |
| `order238-independent-font-route-post-result.json` | 12156 | `4f284f858dcc7a727df56d00f2546d89062c37523aa567ffb27ce487546130b5` |

## 운영·실패·보존선

선언 bc9b86a 뒤 대시보드 첫 생성은 `execution sequence must be continuous in source order`로
실패했다. 새1행을 pending include 뒤에 둔 운영 실수이며, 제품 검사나 제품 실패가 아니다.
8290ceb에서 include 앞의 별도 표로 옮긴 뒤61b533f에서 생성·fresh 확인·push했다.
제품 저작과16/실제폰트/명시6은 그 선언 교정 이후에만 실행한다.

WORK의 완료227/226 원문860B는 기존 history 맨 앞에 raw 이동했다.
WORK38363B/EOF2·history85927B/EOF1로 역복원 확인했으며, 완료 절만 추가한다.
큐2·기존 내부판정24는 원형 보존하고238 판정만 별도로 더한다.

공개판 source362578d8f4c0781fe35f643a74cc3037e7a80b21/treee7f50b065b3369afa1894df8292756a95f94fd11/
manifest50eed10b18c2c2b056f875a8df55230dc07b5535c55e59ddb89fff1d64e91870은 재핀하지 않았다.
인간103390B 원형, GO1/OPEN45와 본편HOLD 유지. conventional 앱/ZIP/manifest가 현재 checkout에
없으므로 실물 보존이나 재출하 PASS를 새로 주장하지 않는다. 옛 패키지를 현재 원장과 비교해
반려/재인증하거나 재빌드·업로드하지 않았다.

규범 승격은 없음: 기존 I18N/WORK_UNIT 그대로, 이번 입력·차선·파일·마감 지시는 일회성이다.
자동 게이트는 계약 증거이지 재미·깊이·문체·실제 화면 품질의 증거가 아니다.

## 정확 source·독립 최종 마감

제품 source `9a94f294bea05f9b2e21285315fd50274137adc1`, tree
`52fa1814dd03726ed2cc6b579e0a38252b6987ed`. 저자 Plato와 다른 Poincare가 제품2·승인값·
생성 원형/역복원·고정16·실제font2·명시6·운영 원형을 직접 읽고 work_unit238만 GO/필수0·선택0 판정했다.
`order238-poincare-final.json` 11291B SHA
`971e3992905498a4523cc8552442570f5d4762543655e5041fe85fb8bc3af6e8`.
QA289와 C1은286 raw exact, CLAUDE/backlog/report3은 결과 설명 갱신이며
C1을 새 source로 발급했다. source-neutral이라고 해석하지 않는다. ROOT 결속4997B:
`order238-source-binding.json` SHA `4501c5c1a1929bc11cd9ad92bf96591c857ffe03c2f3c5e1a9c4087fd69479b0`.
이후 마감은 resolver가 허용한 metadata wrapper만이며 source·제품2는 그대로다.
검수자의 읽기 준비 중 resolver 키 추정 KeyError와 없는 optional glob은 고친 RO 준비 오류다.
새 검사·생성 재실행이나 결과 맞춤 수정은 없었다. 원어민·인간 플레이·실제 렌더·물리패드·
원격CI·법률·공개출시·본편 품질은 이 판정 범위 밖이다.

다음 관계 이름21위치/14종과 안전한 폰트 실행기 RO 조사는 별도 미착수 범위다.
각 private `order238-next-relationship-display-preflight.json` / `order238-next-font-runtime-preflight.json`에
남겼으며 신규 번역·runtime 수리·Godot 실행·그 범위의 GO로 합산하지 않았다.

## 선언 원형 — 착수 사양 보관

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

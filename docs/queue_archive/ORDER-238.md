# 중국어 폰트 전체 지문 보강 — 결과

ORDER-238. 제품2 데이터 수리 완료, 표적6 PASS와 실제 정적 CN/TW 준비 상태 확인.
정확 source의 독립 최종 판정은 아래 후속 결속 전까지 미완료다. 본편 HOLD·공개판 사용자 GO 원형 유지.

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

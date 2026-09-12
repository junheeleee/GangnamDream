# 주거·직업 칭호의 실제 세 언어 표시 — 결과

[x] ORDER-242 — 2026-09-12. 독립 Poincare의 work_unit GO 한정이다.
source `e2147ec392a0031765dad024da204238f6cbc1b3`, tree
`0954b7c47188b5daf9e048e68ec1d9223fdbfd4f`, exact 검토 HEAD
`48c28bc9315bcdfbc7556532f3acd06aeea1eeaa`다. 공개 GO1·인간 OPEN45·본편 HOLD.
자동 검사는 재미·깊이·문체나 인간 판정이 아니다.

## 제품·번역

- 주거5·직업4의 name/desc18만 raw KO locale 조회로 연결했다. 기존 ALL_TITLES50/
  TITLE_EN50·KO/EN·해금/저장ID·조건·보너스·cat/rare·unknown/custom·비선택41은 보존했다.
  MP 삽입30행/2823B 역제거로 전체 원형 exact다. 저장·게임플레이·새 사건 변경0.
- 직접 KO54 독립 검수에서 필수0·선택 정밀화5를 채택했다. 첫 L1은52통과,
  급여 CN/TW 통장 명시성 탐지2였다. 到账/入帳는 자연스러운 계좌 입금으로 의미
  오류가 아니며, 독립 승인 후 银行账户/銀行帳戶를 명시한2문구로 정밀화했다.
  처음 표/진단을 보존했고 나머지52와 source/ID/hash는 그대로, 같은54 재검 오류0.
- 신규 사전49(JA15/CN17/TW17)·기존5 보존이며 apartment3 기수용은 raw 유지했다.
  실제 신규 KO는15/공유3이다. 고시원 이름2의 기존 GameState 조건과 Goshiwon EN,
  apartment milestone의 Entered an apartment와 칭호 Apartment Life는 그대로다.
- clean `65261f514345bd25c5da8aa04f3d1e922e1fa853` final/export/check/import에서
  신규17×3·changed_files0. 초기/최종 export는 previous_target_hash 외 원형exact.
  portable 제품 `dd078a90c92b18a7d550f964f63dec3c02f4309a`의51/b1 역제거로
  이전38,587/b98/meta9 raw exact. 누적38,638/b99, JA12,878·CN/TW각12,880이다.
  언어별 사건11,578·엔딩234·catalog834, UI232/234/234이며 전체 UI 완료가 아니다.

## 회귀·원형 실패

- 최초 source 고정20은 공유 GameState2 누락 예측과 함수 마지막LF 가정 때문에
  normal3도 실패해 mutant17을 유효 통과로 세지 않았다. 명시적 정정 후 같은20의
  정상3/유효 변조17거부와 별도 retained4를 통과했다. 최초 예측/실패는 보존했다.
  기존 JA69함수·5클래스 raw 보존, collect/main hook 외 기존원형 변경0이다.
  실제 collector는 현재 calls3374/keys2864/entries2893/context34·29,
  collision103(format28/shared48/context27)을 그대로 노출한다. 역사 투영만 따로다.
  마지막 auxiliary legacy_api_calls 현재3284/역사3266 수리는 최종 JA146에 결속했다.
- 최초 headless actual100(원95+사전 공유5) 전부 PASS: 선택9·비선택41·도감50
  잠금/해금·조건20·중복·알림/로그·엔딩카드·언어저장·공유GameState2.
  full state30과 무변경 digest70, disk100·입력19 exact, restore1/exit0/stderr0,
  fatal/leak/잔류 process0. 사전 namespace의 meta/settings와 원형 로그는 보존했다.
  실제 full-month/autosave/엔딩 진행·렌더 관측이 아니라 기존 소비자 경계 검사다.
- 전체 수용38,638 hash/L1 첫1회 오류0,69.970191584초/입력1,187 전후exact.
  명시 `meta-title-localization` 첫9 PASS,88.890041167초/입력1,196 exact.
  fullself259·JA146·ZH12446·EN0·registry143·queue25/fence4·agent222,
  context357/active76. 전체 감사·240주·원어민·실제 화면은 실행0이다.
- 포착17,403/지원17,074/미확정329, UI합집합3,585다. 정적 수집 수를 전체
  플레이 화면의 최종 분모로 쓰지 않는다. 비보호 shipping 텍스트 결손0은 유지한다.
- 이전 c2cc7fd main CI run34686915442는 failure이며 이 source의 로컬9와 별개다.
  원격 전체 CI 성공·공개 출시·전체판 GO를 주장하지 않는다.

```text
도달 경로      : META_TITLE_CHECK_OK cases=100 locales=5 selected=9 unselected=41 conditions=20 shared_readers=2 isolation=preautoload rendered=0
생산자 ↔ 독자   : MetaProgression._localized_title ↔ MainGame 도감/해금 알림/엔딩 카드
바꾸는 상태     : 번역 수용38587→38638; 기존 해금/조건/저장/게임플레이 변경0
포기 시 잃는 것 : 없음 — 선택/효과 신규 저작이 아닌 표시 수리
서사 위치       : 전체판 기존 주거·직업 칭호; 새 사건0
장면 계층       : 해당 없음 — UI 현지화
닫는 것         : 선택18표면의 내부 단위; 공개/인간/원어민/전체판 닫기0
```

이미 생성된 엔딩 title cache는 언어 전환으로 재번역되지 않는다. 새 getter/도감
재열기·새 wrapper의 언어 변경과 구분한다. 남은41칭호·wrapper·cat/rare·다른 UI,
실제 가독성·원어민·정상 속도 플레이·물리 감각은 별도다. 이번 scope/fixture는
일회성이고 새 규범 없음. [독립 판정](../agent_reviews/ORDER-242.json)이 결과를 소유한다.

## 원형 증거

다음은 `.git/full-game-localization/`의 원형 SHA다.
- `order242-translation-revised.json`: `2d3fd135e0ebb911d6498a381e1aae89cdf8aa6538bdb5db2da29701662e8116`.
- `order242-language-review.json`: `7828fd02e5c3d9f7ca24d8a9814f50088462d38aa35d97b1b65f05672e0c2f9b`.
- `order242-source-static-review.json`: `91fa9e2241732fc46a708a6178b57ff7d01f63efeca0ab338951b8ebd401736e`.
- `order242-test-static-review.json`: `e4a4131637de0b7da83185fb8888f32ce38b7690543121860f41a1a2c16004e7`.
- `order242-meta-title-author-run-proof.json`: `8e58c820ca7870ca90e166beb7ad10fc0e6d5a270e1d4fd06784e1a2deaee457`.
- `order242-runtime-review.json`: `4ca50242e129b7a35ceaeba57050db30eb5068854c9cd38b11d33cfde3f49049`.
- `order242-revised-l1.json`: `390df2bec089156a8a2f9b64397fcf7e173e7614d2cf8e64817bb71d2961a121`.
- `order242-official-final.json`: `fd6d6564086834b21429a7999300eeb14bc5454b502e0b894b6c4119bea690ea`.
- `order242-official-check.json`: `d0ebf2e5d332cff138e959039f41b25555650629df220c6500fada405c239457`.
- `order242-official-import.json`: `74a1b9451b7c5efc3194a6dd824b6676ab549bed8a56b29f8a2347d7133f90c1`.
- `order242-portable-proof.json`: `eb2c22e865e2ee3ed339a697a18397e3e64f7dc54b08610db244d099e03424d8`.
- `order242-all-accepted-l1.json`: `af045bb8880d7dab045129da7619971d59d1c051059f057f57f3fd5e2e1718a6`.
- `order242-named-first.json`: `d721aee55ee8a85e2d60204368809f4f94ebae8beea7dbed7f24f36f2c038a8d`.

## 선언·진행 원문 보존

# 주거·직업 칭호의 실제 세 언어 표시

#### [~] ORDER-242 주거·직업 칭호 세 언어

[~] 착수 — 2026-09-12, Codex. 사용자 전체판 현지화·내부 검수 위임의 후속이다.
기준선 `c2cc7fd5fe8658f59301b3a1bce7f5966dc1e3c6` main, source `ad7ff36b`.
공개 M01~M06 GO1·인간 OPEN45·본편 HOLD는 그대로다. 이 사양은 일회성이다.

## 실물·범위

`MetaProgression._localized_title`는 KO 외 모든 언어에 TITLE_EN을 덮어써
칭호 도감·해금 알림·엔딩 보상이 JA/CN/TW 사전을 거치지 않는다.
실제 MainGame Title 버튼→도감의 unlocked 카드, 월 정산→새 칭호,
엔딩의 `_ending_add_unlocks`가 소비자다. 휴면 helper를 번역 실적으로 세지 않는다.

선택은 기존 9칭호의 name/desc 18표면, 1배치다. 크기는 독립 판정 가능한 기존
표면18 기준이며 새 선택·장면이 아니다. 원문과 해금 조건은 그대로 둔다.

- 주거5: gosiwon_survivor, first_move, apartment_life, gangnam_resident, long_gosiwon.
- 직업4: first_paycheck, one_year_worker, three_year_worker, long_unemployed.
- raw KO18을 재사용한다. 아파트 입성은 기존 수용1을 유지하고 나머지17×3의
  신규 수용51만 목표다. 실제 수집·공식 수용으로 확정하기 전에는 완료 숫자가 아니다.
- 기존 영어 `Apartment Life`와 MainGame milestone의 `Entered an apartment`는
  둘 다 보존한다. 새 shared-translation 충돌1은 현재 delta로 분리 검증하며
  옛 collision/hash/문맥 registry를 덮어쓰거나 영어를 맞춰 바꾸지 않는다.
- cat/rare, 잠긴 카드의 미발견 칭호/빈 설명, 나머지41칭호, unknown/empty/custom 입력의
  기존 동작, ALL_TITLES/TITLE_EN·해금 조건·저장ID·보너스·게임 상태는 보호한다.
  연속 거주·연속 무직·주택 소유·새 만남 등 원문에 없는 사실을 번역에 넣지 않는다.

## 만지는 파일 — 선언된 소유권

- source2 (Plato): `autoloads/MetaProgression.gd`, `tools/ja_translation_pipeline.py`.
  선택18 literal lookup과 exact owner/KO/EN/field 계약, 실제 collector는 현재
  호출을 그대로 수집한다. 역사 투영은 옛 계약 비교에만 적용한다. 기존 self를
  지우거나 현재 통계로 기대값을 자동 생성하지 않는다.
- 번역3 (ROOT): `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`.
  KO 직접 지역별 저작·전량54 독립 검토. 기존 수용 apartment3은 byte 보존한다.
- test2 (Rawls): `tools/MetaTitleLocaleCheck.tscn`, `tools/run_meta_title_locale_qa.sh`.
  프로젝트 autoload 전에 격리한 storage로 실제 함수/Control 검사를 수행한다.
- 수용·검증 (ROOT): `content/meta/full_game_localization.json`, `tools/audit_scope.json`.
- 운영 (ROOT): `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  이 사양과 `docs/queue_archive/ORDER-242.md`, `docs/agent_reviews/ORDER-242.json`,
  `docs/agent_review_decisions.json`.
- 다른 제품·검사 파일 변경은 이 사양에 끼워 넣지 않는다. `project.godot`,
  실제 사용자 save/meta, human 원장, 공개 demo 제품·manifest, KO/EN 원문은 변경0.

## 착수 질문과 검증

- 없애면 무엇이 깨지는가: 실제 unlocked 칭호 소비자는 번역 사전을 우회해 영어를 낸다.
- 24주 뒤 상태·같은 자리 경쟁: 새 선택이 아니며 상태/경쟁/비용을 만들지 않는다.
  기존 조건을 만족한 플레이어만 기존 칭호를 얻는다. 화면의 언어만 수리한다.
- source 검증 기대/정상·변조 모집단을 구현 전에 고정한다. owner/함수/KO/EN,
  중복/누락/예상 밖 pair, shared apartment 양쪽 영어 및 역사 역복원을 검사한다.
- runtime 모집단은 실행 전에 고정한다. KO/EN/JA/CN/TW의 선택9 전량,
  미선택41 보존, 실제 도감 unlocked/locked, 새 해금 반환/알림·엔딩 카드,
  조건 경계·중복 해금·언어 변경·unknown과 원본 Dictionary/저장ID 불변을 포함한다.
  성공 marker와 exit뿐 아니라 stdout·Godot log 오류, 입력/격리 storage를 확인한다.
  실패는 원형 보존하고 같은 모집단을 수리 재검한다. headless는 실제 렌더가 아니다.
- 공식 export/check/import는 clean checkpoint에서 locale을 명시하고 신규17×3만
  수용한다. 기존38,587/b98/meta9와 공유 apartment3은 raw 역복원·hash로 보존한다.
- 새54의 L1·독립 언어 전량, 최종 수용 전체 hash/L1, 실제 component 및 source
  고정 회귀를 실행한다. 공동 최종 named 차선은 fullself/JAself/ZHself/EN leak/
  registry/queue/agent/context/queue 정합만 포함한다. 변경 없는 녹색 검사는 반복하지 않는다.
- 전체 audit·240주·공개 패키지·원어민·인간·물리 입력 검사는 이번에 실행하지 않는다.
  새 공개 출고, 전체 칭호/UI 완료, 전체판 GO를 주장하지 않는다.

## 닫기

소스·운영 입력을 먼저 freeze하고 비저자 Poincare가 직접 원문/번역/코드/증거를
검토한다. 실제 Git에서 관측한 source commit/tree와 검토 HEAD를 결속한 scoped
GO만 기록하며 사용자 재판정을 기다리지 않는다. 자동 검사는 재미·깊이·문체
판정이 아니다. 실제 렌더·원어민·인간 플레이·물리 감각은 미관찰로 남긴다.
필수 잔여가 있으면 원형 모집단을 축소하지 않고 수리한다. 새 발견은 다음 오더다.

## 진행 — 최초 수집에서 확인된 예측 정정

- 첫 collector에서 선택18 중 고시원 이름2는 GameState의 기존 UI에도 있었다.
  실제 신규 KO는15·재사용3이다. 두 고시원 키의 과거 accepted는0이라 신규 수용
  17×3=51 목표는 그대로다. 기존영어 Goshiwon/Gosiwon 표기와 각 owner를 보존한다.
- 실제 calls3374/legacy3340/keys2864/context34·29, collision103이다. 보존된
  세 의미공유 pair를 모두 등록한 뒤 shared48로 검증한다.
  사전 keys2866/collision101은 실행 전 예측 오류였다. 현재 결과로 역사 계약을
  덮지 않고 기존 GameState2의 exact owner/pair 보존을 새 delta에 추가한다.
- 최초 고정20은 normal3도 실패해 mutant17을 유효 통과로 세지 않는다. 함수 경계
  마지막 LF 가정도 원형 코드 기준으로 수리한다. 원형 기대·첫 실패를 보존하고
  사실 정정 addendum 뒤 같은20을 재검한다. 추가 retained2의 누락/EN 변조4는
  별도 사전 고정 보강이며 원래 모집단을 대체하지 않는다.

## 진행 — 언어 정밀화와 실행 전 동결

- 직접 KO 대조54의 독립 언어 필수0, 선택 정밀화5를 반영했다. 첫 L1은52통과와
  급여 CN/TW의 통장 용어 탐지2였다. 到账/入帳는 의미 오류가 아니라 명시성 탐지
  오탐으로 판정했고, 원문 통장을 자연스럽게 풀어쓴 银行账户/銀行帳戶를 별도
  언어 승인 후 채택했다. 최초 표·54진단을 보존하며 같은54 재검은 오류0이다.
- source 고정20 재검과 별도 retained4는 통과했다. 보조 legacy_api_calls의
  현재3284/역사3266 계측 수리는 최종 JA self에서 따로 결속하며 이전 실행과
  혼동하지 않는다. source2 raw 역복원과 보호 파일은 그대로다.
- 실제 기존 GameState 이름2도 영향을 받으므로 최초95그룹에 별도 공유 호출자
  5언어를 실행 전에 고정해 총100그룹이다. 기대 조건/영어 표기를 서로 옮기지
  않는다. 기존 collection 그룹에서 category 기반 다음 회차 보너스까지 비교한다.
  실행 전 ROOT·비저자 전체 구조 검토의 필수0이며 최초 엔진 실행은 아직 전이다.

## 진행 — 실제 실행·수용

- clean `65261f514345bd25c5da8aa04f3d1e922e1fa853`에서 첫 actual100 전부 PASS,
  restore1/exit0/stderr0, preautoload 별도 저장 공간·원형 로그를 보존했다.
  source19 전후 exact이며 실제 렌더/정상 속도 플레이 증거는 아니다.
- 같은 clean checkpoint의 final/export/check/import는 신규17×3·changed_files0.
  portable `dd078a90c92b18a7d550f964f63dec3c02f4309a`에51/b1만 추가해
  38,638/b99/meta9다. 이전38,587/b98 raw 역복원 exact와 apartment3을 보존했다.
- 전체 수용38,638 hash/L1은 첫1회 오류0/69.970191584초/입력1,187 전후exact.
  현재 수집17,403 중 지원17,074/미확정329, UI합집합3,585이며 최종 UI 분모가 아니다.
  최종 명시9·비저자 exact-source 판정은 이 뒤 별도이며 본편 HOLD를 유지한다.

## 최종 회귀

- source `e2147ec392a0031765dad024da204238f6cbc1b3`, tree
  `0954b7c47188b5daf9e048e68ec1d9223fdbfd4f`에서 명시 차선9 첫 PASS,
  88.890041167초/입력1,196 전후exact/stderr0이다. fullself259·JA146·ZH12446,
  EN누출0·registry143·queue25/fence4·agent222·context357·active76을 확인했다.
  마지막 보조 통계 수리는 이 JA146 실행으로 결속했으며 원래20/추가4와 구분한다.
- 앞서 원격 배포한 `c2cc7fd5fe8658f59301b3a1bce7f5966dc1e3c6` main CI
  run34686915442는 failure다. 이번 source의 로컬9와 합산하지 않으며 별도 원인
  확인 중이다. 이번 작업의 원격 전체 CI·실제 렌더·원어민·본편 GO는 주장하지 않는다.

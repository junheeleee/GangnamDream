# ORDER-576 — 경마 화면의 중국어 빈값 안내

#### [x] ORDER-576 [현지화·UI] 번역 수용 — 2026-10-13

ORDER-157의 전체 번역 위임 안에서 RaceTrack의 KO2키/CN·TW4개만 수용한다.
기준 clean main424a1b171696498b60fbc89910d40c7435e817b2/
treeaca23222d6403275684f84b0df4cd2715e79cb93다. CI38286178784 attempt1은
17:51 UTC 조회에서 in_progress다. 새 월/엔진/실제 입력0, M17/562 하나는
OS잠금 HOLD로 유지한다. 사용자에게 해제를 재요청하지 않는다.

## 깊이 3문·정확 모집단

1. 빼면 기존 RaceTrack 방어적 빈값 안내 두 곳이 CN/TW에서 EN으로 폴백한다.
   MainGame:18041~18051의 full-story activity 입구→RaceTrack.open→기존 _tr→
   LocaleManager.ui 독자는 있지만, 아래 fallback 조건의 실제 정상 플레이 도달을
   주장하지 않는다. native/새 월 확인이나 본편 노출률로 세지 않는다.
2. 기존 상태를 설명할 뿐 선택/24주 결과/가격/정산/저장을 바꾸지 않는다.
   `0전 0승`은 출전0·승리0이지 패배0이 아니다. `선택 없음`은 선택 부재다.
3. 기존 경마 주 안내는 이미 번역돼 있어 반복 수용하지 않는다. 실제 누락2개를
   15~25로 채우기 위해 중복·소비자 미확정·휴면 문구를 섞지 않는다.
   WORK_UNIT의 첫 배치 크기 추정과 판정 가능한 단위 원칙에 따른 작은 수리다.

| exact KO key | 소비자·조건 |
|---|---|
| 0전 0승 | scenes/RaceTrack.gd:456 _render_betting, horse.record 부재 fallback |
| 선택 없음 | scenes/RaceTrack.gd:1225 _pick_summary_text, race.horses 부재 fallback |

두 키의 JA 행은 존재하며 비소유다. 기존 JA `0勝0敗`의 출전/패배 의미 차이는
이번에 발견한 별도 기존 결함이며 이 CN/TW 추가로 고쳤다고 하지 않는다.

## 파일 소유·경계

- root: locale/ui_zh-CN.json·ui_zh-TW.json 위 신규2키와
  content/meta/full_game_localization.json accepted/checksum/UI batch1만.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, CN KO 직접 저작.
- mod_layer_ci: 새 private tw.response.jsonl/draft-review.md, TW KO 직접 저작만.
- manual_save_ci: KO2/번역4/원receipt/실제 caller 독립 전수 검수만.
- rework_batch_plan: 새 private before/final·비소유 보존·4파일 exact inverse만.

KO/EN/JA·runtime·조건/효과/플래그/가격·source manifest·project/presets·검사/
collector·공개데모/pin·출시언어·사용자/공개 저장/설정·Human/과거 판정·옛 raw/
seed/app 비소유다. 영구 tool/helper/checker/self-test/등록·479/481 검증비용/
최적화·전체 audit/240주·엔진/컴파일/native/새 월0이다.

## 수용·마감

선언 commit/push 뒤 official export/check/import --accept로 신규 잎만 처리한다.
CN/TW previous null·protected=false, 기존 JA와 원문 불변을 확인한다.
KO에서 지역별 독립 저작하며 root의 인접 EN 노출은 공개한다. 중역·간번 변환0.
원receipt header/digest와 batch를 portable 원장에 추가하고 기존318batch/accepted/
사전 prefix·JA 포함4파일 exact inverse·실제 Git source manifest를 확인한다.
ZH/JA UI·i18n·데모·원장 inventory 및 context/queue/diff를 표적 검증한다.
EN coverage/한글은 직전575 actual0와 KO/EN/runtime byteexact 귀속으로 재실행하지
않는다. 변경 없는 자체검사 반복0, 새 실패0·독립 의미/receipt/보존 GO 뒤 닫는다.

before는 .git/order576-20261013/preservation-before.json 38533B/
dd0be51a9a488c73728730afff3d7fa321ccb2920c5e51604d75ead953d1b1d0에
선언 전 clean·제품4/비소유3359/보호54그룹951개로 봉인했다. 이후 선언 metadata와
구분한다. 예비 읽기 진단의 Entry.calls AttributeError1·없는 조사 파일 rg 오류1은
제품/게이트 실패가 아니며 검사·제품 수정으로 숨기지 않는다.

gangnamdream-dev/I18N의 직접 저작·비소유 보존·source/실관찰 경계를 적용한다.
모집단·소유·검증은 일회성, 새 규범/승격0이다. 자동 계약은 재미·깊이·문체/
인간 관찰 GO가 아니다. 렌더/원어민/인간/물리패드 OPEN·전체 INCOMPLETE·출시 HOLD다.

## 마감 — 방어적 대체 안내 번역 한정

선언138ec7cfd82b7413a57a97aafe168c46966c143f/tree
e900e8db3c186a0eedd5d22dd918331223d876e6를 먼저 commit/push했다.
KO2키의 CN/TW4개를 지역별 직접 저작하고 비저자 전4 의미 검수 뒤 공식
export/check/import --accept 각2×2를 actual0으로 마쳤다. root의 인접 EN 노출과
필수 사양의 기존 JA 오역 인용 노출은 공개하며 중역/간번 변환0이다.

| KO | CN | TW |
|---|---|---|
| 0전 0승 | 0场0胜 | 出賽0場，0勝 |
| 선택 없음 | 未选择 | 未選擇 |

RaceTrack:456은 horse.record 부재, :1225는 race.horses 부재일 때의 안내다.
정상 HorseWorld:82~119는 horses/record를 생성하므로 정상 플레이에서 실제
누락이 보였다고 주장하지 않는다. 본편 입구/lookup의 source 경로만 확인했다.
선택·효과·가격·정산·저장·KO/EN/JA·runtime·데모/핀 변경0이다.

원receipt semantic digest는 CN
3e090089533bfdc6cfe59c7ad5e8f1798123fb11cf70e67921fabc9e4ffc263d /
TW 0b438ac963bfcffed023972682244a2927dba48286d2bf2fa14ffc53219d9af9다.
official accepted raw SHA는 CN
145f2ce833a978ef2059f3413969accd2bbd2f916e44d86c1d9dd24cfefebbe0 /
TW 57604cfe8768814ba34a9f0e71bb7b69322dc3172dfd728d9520b29ad00852be다.
원header/source_revision을 portable UI batch에 보존, accepted14761→14763씩·
JA13169 불변·batch318→319, checksum
466851ae761c54bfef57984383cb5e503764e8205678e96ee277844e75bf421e다.
실제 Git source manifest
c13d47f56851ab9f26567d53a53db1f13e39d5931881f8f1bd2c7ab91a71e19b와
source17504/unsupported466은 불변이다.

표적 ZH all·JA UI·i18n coverage·demo scope all·story demo·CN/TW inventory
7명령 actual0, inventory invalid[]·UIstatic2020/2980·missing960씩이다.
전역 번역 INCOMPLETE/OPEN은 남는다. EN coverage/한글은 직전575 actual0와
KO/EN/runtime byteexact로 귀속, 변경 없는 자체검사/전체 audit/엔진 재실행0이다.
새 제품 게이트 실패0이며 초기 읽기 진단2건은 위 원기록 그대로 보존한다.

독립 source/receipt 검수는 전4/원receipt2/318batch prefix GO·blocker0,
`.git/order576-20261013/independent-review.md` 9850B/SHA
61560cb953564dc844334387c8cf99aad77b208727d2d8b0f70543fa445a5427다.
독립 보존18/18·기존 verifier의 JA 포함4파일 exact inverse PASS, 보호54그룹951개·
비소유3359·old575raw36 exact다. final JSON15510B/SHA
daa3c842f7969647681efe9d8b19773f60c53690ecef67b386a339d78a59f256,
review3227B/SHA ad68a200bc3325ce9ddbb13a40764f31beb26ccccf8c7c7fff51f5bcbaf3537b다.
root가 두 review와 final 전체를 읽었다. 이 보존은 제품3 변경 직후의 판정이며
마감 최초 context 검사는 CLAUDE18083B/max18000 초과로 actual1이었다. 새 현재행을
줄인 뒤 context actual0(690docs/209links/15invariants)으로 재확인했다.
실패를 숨기거나 예산/검사/규칙을 완화하지 않았다. queue actual0(78/76/max2)·
diff actual0, commit 뒤 실제 Git proof는 별도 확인한다.
최종 CN195569B/SHA af8ddabd9c7666da97f93bbf6b13ce8e0f233be411b74a060df32762957e9501,
TW196145B/SHA 5cfefb4ad4754b5112ef42d20f204e81716bff715362f18bbd3e7cf180036ca4,
원장11732939B/SHA 450c788f6e3a63ba22fce94f499483876cb2889c6430023cd93e35c74663e652다.

기존 JA `0勝0敗`의 출전/패배 혼동은 별도 수리 대상으로 남긴다. 여기서 JA
수정/해결 주장0이다. M17/562 OS잠금 HOLD 하나·새 월/실제 화면0·잠금 해제
재요청0·렌더/원어민/인간/물리패드 OPEN·출시 HOLD다. 기준424a1b1 CI는 마지막
조회에서도 in_progress였으며 새 push CI와 구분한다. 현황판 단독 후속0이다.
이 모집단·소유·검증은 일회성, 새 규범/승격0이다.

# ORDER-466 — 일반 투자 매수·매도 결과의 중국어 안내

#### [x] ORDER-466 [P1·현지화] 성공·기본실패·행동기록8키를 읽는다

**완료 — 2026-10-05.** CN8/TW8 의미·공식수용 및 불변기준선/두제품전이 한정GO.
사전1809/1809·accepted41821/b237. 독립 검수 [466](../agent_reviews/ORDER-466.json).
actual clean ae28a8b/tree3679f0: tracked3146/protected57 전후동일, delta17.943166459초·
ZH34.348521초 exit0/stderr0. result SHA
`1f50a10cefca0a7eb187dc7799988a419bd7e1cbf6442553ac7f443f844a93d9`, delta SHA
`84d54fbaf7dd486174ed61c233206907123b0f18613660b8db3e1561aa39d167`.
그뒤7b3bee3/tree8dd0bd4는CLAUDE3행만변경했으며 후속HEAD재실행으로세지않는다.
current365/wholehistory/렌더/원어민/물리입력 NOT_RUN. 본편·출시HOLD.
승격: 새규범0·이8키의 선언/검증은일회성, 기존I18N/WORK_UNIT을그대로적용했다.

## 당시 선언

**[~] 착수 — 2026-10-05.** 부모157, 직전465와교집합0. 한국어8키는JA에있고
CN/TW사전·accepted에는없다. 주변은행/보유/거래카드/패드안내는기수용이므로
다른주제를억지로붙이지않고 한판정가능기능8키×2지역16값으로진행한다.

## 정확한 원문과 실제 소비자

모두 `scenes/MainGame.gd`의기존 `_tr`이다.

| KO key | 줄/분기 |
|---|---|
| 매수할 수 없습니다 | 19824·19837 / result.message·transaction.error가없을때 기본toast |
| ✓ 투자 → %s 매수 %s | 19846 / 자산명→실제투입금cash_committed 순서 |
| 투자 매수 | 19852 / nonpending 행동완료표시 |
| 매수 완료 %s | 19854 / 성공toast·투입금이며수량아님 |
| 매도할 수 없습니다 | 19870·19883 / 기존상세오류우선,없으면기본문구 |
| ✓ 투자 → %s 매도 | 19891 / 자산명1개, 매도액·수량추가금지 |
| 투자 매도 | 19896 / nonpending 행동완료표시 |
| 매도 완료 | 19898 / 성공toast |

거래카드버튼19719/19739와패드callback19526/19532가두핸들러로도달한다.
로그는turn_action_log→10438 _ap_recent_action_line의cleanup/34자절단을거친다.
새문구는✓·→·%s순서를보존하지만실제화면에서기호/전문이그대로보인다는뜻은아니다.
자산명동적값/구체오류/화면전체중국어·거래정산은이번판정범위아니다.

깊이3문: 누락이면거래결과의일부영어폴백이남는다. 선택/24주상태는불변이며언어만
바뀐다. 짧은피드백과자산명·금액식별성이경쟁하므로수량이나매도가격을덧붙이지않는다.
`행동력이 없습니다. 이번 달 거래 불가`19829/19875는주간맥락과의시간축위험이있어
이번번역에서제외한다. 코드/원문확인후별도수리범위로판단하며모른채완료로덮지않는다.

## 소유권

- root제품: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json` 각정확8키와
  `content/meta/full_game_localization.json` 신규16accepted/공식receipt2batch만.
- claude_handoff_review는private order466-cn-draft.json, receipt_tests392는
  order466-tw-draft.json만한국어직접저작한다. 상대언어를중역하지않는다.
- independent392는비저자전수16값·원문·실제증거검토와
  `docs/agent_reviews/ORDER-466.json`만. root만공식교환/검사를실행한다.
- root기록: 큐·이사양→archive·CLAUDE현재행·WORK_LOG·생성STATUS·신규판정행.
  private `.git/full-game-localization/order466-*` 교환/helper/결과만추가한다.
- 예상CN/TW1801→1809, accepted41805→41821, batch235→237,JA3053불변.
  원문/KO·EN·JA/가격·AP·거래/정산·입력·저장·공개·검사도구/history adapter변경0.

## 검증

선언commit/push후공식export→독립저작→check→전수KO대조→import한다.
기존465교환helper의atomic writer만apply_patch출력으로연결하고validation은불변이다.
공식header/selection/nullprior/receipt digest를그대로원장에복사한다.

465의실제증거 `.git/full-game-localization/order465-normal1/result.json` SHA
`de1fccb26eb47da078362f930a227dcaccd529a08f0855fb2dfab9b4936bdf04`와
그기준선464 clean dd1c391의365 PASS를재사용한다. current365/wholehistory는NOT_RUN,
과거실행/현재증명/현재ZH를따로기록한다. 새tracked검증도구나우회차선은만들지않는다.

1. 실제464 결과·로그SHA/3141경로와현재전체path set/부모계보를결속한다. 이후허용변경은
   464/465마감·466선언/현재상태의정확metadata와위3제품파일뿐이다. 기존보고·인간원장·
   판정prefix·보호파일은개별바이트로확인한다. WORK_LOG보존본도변경하지않는다.
2. 464이후제품전이는465와466의정확2개로고정한다. 중간UI/원장변경·되돌림을최종역상만으로
   숨기지않고, 각commit의실제parent4raw→제품4raw를변경없는 `validate_append`로검증한다.
   전이는각32/16값·2/2batch이며마지막제품4raw=현재disk/Git다.
3. 원문·collector/provider/code의전체기존SHA가불변이어야한다. freshcollect 전체hash/
   digest와각공식export revision의actualancestor/Git `_source_manifest`를결속한다.
   새8키부재/새16핀·구원장전체역상·이전baseline PASS 불변이하나라도어긋나면중지한다.
4. clean현재후보의전후tracked/보호맵·ZH기본1회, 신규16전수검수·context/queue/human/
   생성STATUS/diff로마감한다. 반복전체selftest/JA·EN/240주/엔진/패키지실행0이다.

Mac잠금중GUI0. 실제toast·log/잘림·패드과업·원어민은NOT_RUN이며완료범위는16값의
의미와공식수용뿐이다. 149/457/302runtime·본편/출시HOLD. 자동PASS는계약증거이지
재미·깊이·문체/사람승인이아니다. 기존I18N/WORK_UNIT적용,새규범승격0·이번8키는일회성.

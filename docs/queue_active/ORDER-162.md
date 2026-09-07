# Active Queue Spec: ORDER-162

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-162 [P0·전체 현지화] M07~M24의 남은 연결 사건을 세 언어로 옮긴다

**[~] 2026-09-07 Codex 착수 선언 — 만지는 파일: 아래 정확한35사건의
JA·zh-CN·zh-TW text-only overlay, 수용 원장, 표적 검사와 증거 문서.**
사용자 전체판 번역 지시를 catalog 구현 `ea17c33`에서 이어간다.
KO 제품 `53493fe`·기존3,486 수용 번역·비표시 메타9·공개 데모는 보존한다.

## 깊이 3문

1. **없으면 무엇이 깨지는가?** 이미 번역한 현수 낙방·이사·다은 재방문 뒤
   후속과2년차 사람선이 영어로 돌아간다. 도입뿐 아니라 모든 선택 결과와
   조건별 산문을 같이 옮겨 연결을 보존한다.
2. **선택을 바꾸는가?** 선택·효과·시간·사실·회수는 변경0이다. 답장/수락/동석을
   발명하지 않고 원문에 실제 있는 행위와 관계 거리만 대상 언어로 옮긴다.
3. **무엇과 경쟁하는가?** 뒤 챕터와UI 번역 예산이다. M07~M12만 남은6사건/
   47문구/3,782자라 M07~M24 정적 closure의 미번역35사건/279문구/29,849자로
   명시 분할한다. 이는 출시 데모 확장이 아니라 본편 번역 범위다.

## 두 배치 — 정확한 원문 단위

A M07~M18:15사건/120 leaf/11,388 KO자. 이벤트별 독립 text deliverable을
단위로 삼고 연결 서사 묶음으로 다시 읽는다. 기존 M21 seed와 겹치는
`arc_34_two_years_in`은A에서 한 번만 작성한다.

- `arc_hyunsu_exam_fail`
- `arc_hyunsu_drift`
- `arc_hyunsu_new_path`
- `arc_housing_new_life`
- `arc_daeun_02b_dream`
- `callback_daeun_supportive_warmth`
- `arc_34_money_attracts_money`
- `callback_shadow_investors_proposal`
- `arc_father_medication`
- `callback_medication_ignored_echo`
- `callback_medication_visited_echo`
- `arc_34_routine_trap`
- `arc_sangchul_human`
- `arc_year_one_half`
- `arc_34_two_years_in`

B M19~M24:20사건/159 leaf/18,461 KO자.

- `hyunsu_reunion_later`
- `hyunsu_reunion_photo`
- `hyunsu_reunion_memory`
- `hyunsu_reunion_meet`
- `arc_34_doors_open`
- `arc_daeun_03_fork`
- `arc_daeun_03_fork_hold_receipt`
- `arc_daeun_03_fork_release_receipt`
- `arc_jiyeon_03_offer`
- `callback_jiyeon_honest_referral`
- `arc_y2_relationship_fork_unattached`
- `arc_34_parents_visit`
- `arc_father_03_hospital`
- `callback_rushed_to_father_echo`
- `callback_sent_money_instead_echo`
- `arc_sangchul_mirror`
- `arc_sangchul_mirror_receipt`
- `arc_career_ceiling`
- `arc_father_04_visit`
- `arc_year2_close`

자수는 공백·개행 포함 실측이다. 인물선19묶음과 개별35사건의 단위를 구분하며,
길이가 다른 원문을300~800자로 억지 절단·요약하지 않는다. 번역 파일은
독립 수리 가능하되 현수 후속/재회, 다은 진로 receipt, 아버지 병원과
콜백, 상철 거울 receipt는 연결 상태로 L2 대조한다.
단위 수를 맞추려고 새 장면·선택을 더하지 않는다.

## 정확한 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/` 아래 다음12파일 중 위35 ID만 소유한다.
기존 행과 공개 `story_demo_events.json`은 변경0이다.

- `arc_midgame.json`, `arc_daeun.json`, `arc_chapter_themes.json`
- `arc_hyunsu.json`, `arc_events.json`, `arc_drama.json`, `arc_year_close.json`
- `callback_events_2.json`, `callback_events_5.json`, `callback_events_6.json`,
  `callback_events_13.json`, `callback_events_36.json`

root는 수용 원장 `content/meta/full_game_localization.json`과 이 사양,
CODEX_QUEUE·CLAUDE·WORK_LOG·생성 STATUS·전체 현지화 backlog·
`tools/audit_scope.json`의 등록을 소유한다. 실제 수량/토큰 오탐이 발견되면
`tools/zh_translation_audit.py`, `tools/full_game_localization.py`,
`tools/full_game_localization_self_test.py`를 원문 문맥에만 묶어 수리하고
정상/변조 쌍을 독립 검토한다. 광역 완화나 금액 단위 생략은 금지한다.
언어 파일은 작성자1명씩, 교차 검토는 읽기 전용이다.

KO/EN·runtime·gameplay·저장·라우팅·폰트·catalog·공개 언어·human_gates는
비소유다. 원문의 `arc_hyunsu_drift.choices[2].result_text`가 '형도요'를
'그 두 글자'로 부르는 결함은 번역에서 몰래 고치지 않고 별도 원문 부채로 기록한다.

## 검증과 보존선

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
  최초 source export를 보존한다. A limit128/B256으로 전체120/159를 담고
  ID·leaf 개수를 단언한다. KO에서 세 언어를 각각 직접 작성한다.
- A 조건별8/B20, 총28 leaf를 포함한다. 일반/도덕/기억 변형의 위치와
  배열 순서·선택 개수·토큰·문단 경계·돈·나이·시각·주체를 대조한다.
- 전부 lifecycle shipping, static overlay 지원이며 공개 보호 leaf0이다.
  ORDER-158 기번역8 roots, M09 author-only fallback3 roots는 제외했다.
  shipping 정적 연결은 실제 플레이 도달성의 증거가 아니다.
- L1: `full-game-localization-overlays` 차선, EN·diff, 정확 source/target
  receipt와 이전3,486 보존. 원어민·화면·전체판 완료는 OPEN이다.
- L2: 다른 작성자가 전체 KO 대조, 인물·시간·돈·기억·선발신·결과 산문 확인.
  L3: 사용자 무작위 표본·원어민·실제 화면은 별도이며 자동으로 닫지 않는다.

위 분할·파일·해시는 일회성이다. 지속 규범은 기존 I18N_INFRASTRUCTURE와
세 용어집에 있고 새로운 서사/상품/언어 출시 규칙을 이 오더에서 만들지 않는다.

## 2026-09-07 실행 증거 — L1/L2 수용, L3 OPEN

- 선언 `9ca9e12` 이후36개 overlay에 정확35 ID/279 leaf씩, 총837개를 추가했다.
  기존8행/언어와 공개 story_demo를 포함한 다른 기존 파일은 보존했다.
  기존3,486 수용 receipt와 비표시 메타9를 유지해 현재4,323개다.
- 독립 KO 전수 대조는 언어별35 roots/279 leaves, 조건별28과 모든 결과를
  포함한다. CN 연락 요구/누운 자세/송금 주체/직업 한정과 TW 전공/질문
  뉘앙스/부정 범위의 수정 뒤 잔여 의미 지적0이다. 다른 언어를 원문으로
  삼거나 간번 변환을 독립 번역으로 세지 않았다.
- 최종 source+target receipt aggregate 산식은
  `digest({leaf.id: {source_sha256, target_sha256}})`이며 언어별:
  - JA `f5f54a0e6aada26291d5c93d61dd1f7b3e1c546966d5676b52cb48ade468938c`
  - zh-CN `d1c9e1552c6b7acff21004d1eee4f2991953fecc6703e4371a7a5f43271d1bb4`
  - zh-TW `cf09eb83e7a82adf6bb52358734907950b7f8fc4fa9e6463259afdab9b7be4f0`
- git-private `full-game-localization/<locale>/full-ko-direct-2026-09-07.1/`의
  `order162-initial-{A,B}.source.jsonl` 원문을 보존했다. 최종 `order162-final-`
  source/response6쌍은 check/import 각각 PASS·changed_files0이며 실제
  `<batch_id>.accepted.json` checksum/원문 identity를 확인해 portable 원장에 합쳤다.
- 검사기 변경은 `zh_translation_audit.py`와 현지화 self-test뿐이다.
  실제837 오류0, self-test83, ZH935, 독립 guard128(정상46/변조82)을 통과했다.
  독립 최종 guard 파일 SHA는
  `d6ecbb7de68e1215abd7b2b22bb74a63d38c4a68055a4cc7cb71798e764a4339`다.
  기존3,486개도 새 검사기에서 오류0/원문·대상 hash 현재값 일치다.
- 자동 수량 검사에 남은 AM/PM·암시 단위 한계는 KO 대조로 별도 확인했다.
  JSON 최상위 속성 배치와 배열/조건 순서는 구분하며 후자는 변경0이다.
  원문 글자 수·병원 선행 문맥 부채는 backlog에 남겼다. 새 장면을 더하지 않았다.
- 원어민·무작위 사람 표본·실제 렌더링은 OPEN이다. M07~M24 모든 무작위 사건과
  UI를 끝냈다는 주장이 아니며, 기존 제품/공개 데모/사람 게이트는 변경0이다.
- 수용 후 `full-game-localization-overlays`12개·EN·diff를 통과했다.
  실제 stdout은 git-private `full-game-localization/order162-final-checks.log`에
  남긴다. portable accepted SHA는
  `1c415c551d721997b9a4c86033a79d3d86f40f5c731fdf1238cee47204285ea6`다.
  중국어 skeleton의 JP-first full font blocked와 직접 영어 분기13은 기존
  미완료 항목이며 초록 차선이 이를 해제하지 않는다. Godot은 이 배치에서 실행하지 않았다.

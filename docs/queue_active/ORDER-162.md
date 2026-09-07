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


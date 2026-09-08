# Active Queue Spec: ORDER-203

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-203 [P1·출시 claim] 원어민 게이트를 출시 차단에서 미검수 표시로 내리고, 그 사실을 유저가 보는 자리에 적는다

**[ ] 미착수 · 근거는 사용자 지시:** `DECISIONS.md` 2026-09-08. 원어민 검수자를
세울 경로가 없으므로 JA·zh-CN·zh-TW는 코덱스 저작으로 마무리하고 지원 언어로
표시한다. 대신 **검수하지 않았다는 사실을 원장과 유저 표면 양쪽에 남긴다.**

## 지금 상태와 무엇이 틀렸는가

- `docs/human_gates.json`의 원어민 게이트 **일곱 건**이 `blocks`에 `claim:ja`,
  `claim:ja-story-demo`, `claim:zh-CN-story-demo`, `claim:zh-TW-story-demo`,
  `legacy-v2-ja`, `legacy-v2-zh-CN`, `legacy-v2-zh-TW`를 걸고 있다.
- 이 문자열은 “일본어 지원 자체가 막혀 있다”로 읽힌다. 결정 뒤의 사실은
  **“원어민이 검수했다는 주장만 막혀 있다”**이므로 원장이 사실과 다르다.
- 유저가 보는 표면에는 아무 고지도 없다. 원장만 고치고 표면을 두면 이 오더는
  실패다. 유저는 원장을 읽지 않는다.

## 깊이 3문

1. **이걸 지우면 무엇이 깨지는가?** 세 언어권 유저가 검수된 번역을 기대하고
   사서 아니라는 걸 플레이 중에 알게 된다. Steam 평가는 품질이 아니라 기대와의
   차이에서 갈린다. 목표가 95%+이므로 이 차이를 먼저 없애는 것이 싸다.
2. **고른 플레이어와 안 고른 플레이어가 뒤에 다른가?** 고지를 보고 그 언어를
   고른 사람은 번역투를 결함이 아니라 알려진 조건으로 읽는다. 같은 문장이 다른
   리뷰가 된다.
3. **같은 자리에서 무엇과 경쟁하는가?** 번역 배치(ORDER-176~202)와 경쟁하지
   않는다. 저 오더들은 문구를 만들고 이 오더는 그 문구를 무엇이라 부를지 정한다.

## 배치 A — 원장 (`human_gates.json` 단독 소유)

이 오더가 `docs/human_gates.json`을 소유한다. **다른 오더는 이 파일을 건드리지
않는다.** `PUBLIC_STORY_DEMO_GATE_ROW_SHA256`가 게이트 객체 전체를
`canonical_json_sha256`로 잠그므로 두 오더가 동시에 손대면 락이 깨진다.

1. 일곱 원어민 게이트의 `scope.blocks`를 **검수 주장에 한정하는 문자열로 바꾼다.**
   `claim:ja` → `claim:ja-native-verified` 식으로 무엇이 막히는지가 이름에서
   읽혀야 한다. "지원 언어"가 아니라 "원어민 검수 주장"을 가리켜야 한다.
2. 같은 게이트의 `why`에 **출시 차단이 아니라는 사실과 근거 결정 날짜**를 적는다.
3. **열린 45건 전부에 위임 등급 D1/D2/D3를 부여한다.** 정본은
   `WORK_UNIT.md` §3④다. 원어민 검수 일곱 건은 D2이고, 5장 정상 속도 두 건과
   장별 연속 청취 한 건은 **D3이며 위임하지 않는다.**
4. **Legacy V2 내부 후보 전용 게이트 28건을 그렇게 표시하고 출시 판정 목록에서
   뺀다.** 공개 데모는 `story_demo_rc` M01~M06이고 legacy V2 W1~W24는 출시하지
   않는다. 출시하지 않는 후보의 게이트가 출시를 막고 있었다. **지우지 않는다** —
   그 후보를 다시 꺼내면 그대로 유효하다.
5. **금지:** `state`를 `done`으로 바꾸지 않는다. 사용자 서명(`authority=user_final`,
   `decided_by=user`)을 대신 쓰지 않는다. 게이트를 삭제하지 않는다. D3를 D2로
   내리지 않는다 — 그것은 품질 기준을 내리는 결정이라 사용자 지시가 필요하다.
6. `tools/release_content_inventory.py`의 `PUBLIC_STORY_DEMO_GATE_CONTRACT`와
   `PUBLIC_STORY_DEMO_GATE_ROW_SHA256` 세 건을 **같은 커밋에서 다시 잠근다.**
   `why` 한 글자만 바꿔도 락이 깨진다. 해시를 지우거나 검사를 우회하지 말고
   재계산해 넣는다.
7. `docs/I18N_GLOSSARY_ZH.md`의 옛 스코프 참조를 새 이름으로 맞춘다.

## 배치 B — 유저 표면과 증거

1. 인게임 언어 선택에서 JA·zh-CN·zh-TW를 고를 때 **한 줄 고지**를 보인다.
   KO: `일본어·중국어(간체/번체)는 원어민 검수를 거치지 않은 번역입니다.`
   EN: `Japanese and Chinese (Simplified/Traditional) have not been reviewed by native speakers.`
   해당 언어 문안도 함께 넣되, 그 문안 자체도 미검수라는 사실은 바뀌지 않는다.
2. 고지는 **선택을 막지 않는다.** 확인 모달이나 경고 아이콘이 아니라 목록의
   보조 문구다. 사과하거나 변명하지 않는다.
3. KO/EN/JA/zh-CN/zh-TW 다섯 언어 × 목표 해상도에서 잘림·겹침이 없어야 한다.
   패드 포커스와 마우스 호버가 같은 항목을 가리켜야 한다. **새 자산 0.**
4. `python3 tools/human_gates.py`(인자 없이 원장 검사)가 통과하고 일곱 건이
   여전히 OPEN임을 보인다. `done`이 0건 늘어난 것을 확인한다.
5. `python3 tools/release_content_inventory.py`가 새 해시로 통과함을 보인다.
6. **출시를 막는 게이트 수를 정리 전후로 적는다.** 45 → 17이 되고, 그중 D3가
   몇 건인지 명시한다. 이 숫자가 사용자가 직접 해야 할 일의 전부다.
7. `ScreenshotQA`로 언어 선택 화면을 다섯 언어에서 캡처해 고지 문구를 보인다.
8. 기본 완료 게이트(`context_manifest_check.py`, `audit_select.py`,
   `en_coverage_check.py`, `git diff --check`)를 통과한다. **워크트리를 먼저
   `--headless --import --quit` 하고 감사를 돌린다.** 임포트를 빼면 FontKit
   파스에러 수천 건이 후보 결함으로 오독된다.

## 관측 (이 오더에서 고치지 않음)

- 전체판 원어민 게이트는 `ja_native_review` 하나뿐이고 zh-CN·zh-TW에는 대응이
  없다. 비대칭이지만 **여기서 새 게이트를 만들지 않는다.**
- 물리 패드 게이트 세 건은 legacy V2 후보에만 걸려 있다. 공개 출시 후보용
  D3 패드 게이트가 없다. 게이트 신설은 사용자 승인 항목이므로
  `POST_LAUNCH_NOTES.md`에 기록만 한다.

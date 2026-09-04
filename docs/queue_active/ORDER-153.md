# Active Queue Spec: ORDER-153

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-153 [P0·서사 충돌] W237 익명 보증 사건을 M53 재혁 보증선과 분리한다

**[~] 2026-09-05 Codex 착수 — 아래 exact 범위만 소유한다.** 기준은
`4f4689e0ff6265da9f29f690933425d2558e4d24` 이며, 결함은 review
`042f5ea2bac73d27479922bc5f5051c2ad637355` / 제품
`2f91f4265613e57c8e3aaf34ab4f7f0971699f92`의 Property 코덱스 화면 관찰에서
확인됐다. 이 관찰은 독립 인간 인증이 아니며, 두 Chapter 5 사람 gate·
full·main·product는 계속 OPEN/HOLD다.

## 깊이 3문

1. **W237의 익명 고교 친구를 재혁으로 바꾸면 되는가?** 아니다. 저자가
   편성한 M53 W209~W212는 재혁의 재회→보증 부탁→결과→후유증이고,
   W238이 그 exact 결과를 회수한다. `amb_guarantee_00`은 별개의 익명
   초기 생활 사건이다. 플래그 합치기·인물 개명·W238 재작성은 새 과거를
   만들므로 금지한다.
2. **사건을 삭제해야 하는가?** 아니다. 원문·선택·효과·초기 메모리 독자는
   유효하다. 4년차 끝 W192까지는 그대로 열고 W193부터 익명 루트와
   두 direct callback만 닫아, 5장의 저작 보증선을 중복·상충하지 않게 한다.
3. **느직한 풀이나 세이브 마이그레이션이 필요한가?** 아니다. 런타임의
   `max_turn` 조건을 그대로 사용한다. 예전 세이브의 `guarantee_refused`,
   `guarantee_signed`, 이벤트 횟수와 기록은 일반 `flags`/상태 직렬화로 보존하되,
   로드 시점이 W193 이후면 새로 진입하지 않음을 런타임으로 증명한다.

## 15개 표적 단위

1. 기준 제품에서 `amb_guarantee_00` W237 적격을 실패 증거로 남긴다.
2. `amb_guarantee_00` W192 적격을 보존한다.
3. 같은 이벤트의 W193 비적격을 고정한다.
4. `callback_guarantee_default` W192 적격을 보존한다.
5. 같은 callback의 W193 비적격을 고정한다.
6. `callback_guarantee_refused_news` W192 적격을 보존한다.
7. 같은 callback의 W193 비적격을 고정한다.
8. W237 foreground/bridge/deferred 적격 집합에서 세 root 모두를 제외한다.
9. W238 저작 재혁 거절·열린 연락 회수의 진입·산문·영수증을 보존한다.
10. `guarantee_refused=true`인 예전 W237 세이브를 로드→재직렬화해 플래그·
    횟수·마지막 주차를 보존하고 느직한 재진입은 닫는다.
11. `guarantee_signed=true`인 예전 W237 세이브에 같은 경계를 증명한다.
12. 세 KO 객체의 조건 외 cooldown·weight·선택 순서·효과·flag·문장을 바이트 보존한다.
13. EN text-only overlay의 gameplay key 0개와 KO 조건 투영을 유지한다.
14. 공개 M01~M06 제품·번역·패키지·GO 표면을 바이트/게이트로 보존한다.
15. Chapter 5 Property/General, event director, 이어질 기억, 전체 영향 선택 회귀를 통과한다.

## 정확한 파일 소유권

- 제품: `content/events/amb_scenarios6.json`의 `amb_guarantee_00.conditions`,
  `content/events/callback_events.json`의 `callback_guarantee_default.conditions` /
  `callback_guarantee_refused_news.conditions`에 `max_turn` 경계만 추가한다.
- 회귀: `tools/chapter5_human_reject_audit.py`, `tools/Chapter5HumanRejectCheck.gd`에
  W192/W193/W237 경계, 세이브 roundtrip, 원문 projection 보존 검사만 추가한다.
  필요한 경우 `tools/audit_scope.json`의 기존 검사 의존성만 보완한다.
- 파생 관측: 실제 영향 검사가 요구하는 현행 source hash/snapshot만 해당
  검사·원장에 갱신한다. 과거 상수·수량·밀도 기준·판정 문구는 느슨하게
  바꾸지 않는다.
- 기록: 이 사양, `docs/{CODEX_QUEUE,WORK_LOG,DEMO_FIXLOG,STATUS}.md`,
  `CLAUDE.md`. `docs/human_gates.json`은 사람 gate·HOLD를 변경하지 않는다.

## 비소유·보존선

M53 W209~W212 재혁 보증 원고·플래그·효과·예약, W238 산문·원장,
M55 블레이저·무초상, W240 무이체·무응답, 아버지 생사·민서 원격, 지갑
동의 세 root, 30억 즉시엔딩, `scenes/`·`autoloads/`·`systems/`의 제품 코드,
`project.godot`, 원본 slot 01·02, 공개 M01~M06 데모는 비소유다. EN/JA/zh
원고를 이 조건 수리를 근거로 재번역하지 않는다.

## 검증·완료 경계

- 수정 전 새 표적 검사가 W193/W237의 세 진입을 실패로 잡는 로그와
  SHA-256을 남긴 뒤 제품을 수정한다.
- 수정 후 같은 검사와 context/queue, JSON, `audit.py`, 영향 선택, Chapter 5
  두 종막 경로, EventManager 적격·세이브 런타임을 통과한다.
- L2는 적격 집합·로드된 KO/EN 객체·예전 세이브·W238 회수를 실제
  autoload API로 검사한다. 이는 정상 독해 속도 인간 플레이를 대체하지 않는다.
- 남은 배경·결혼/비교본 이름표를 함께 닫고 새 exact 제품/review 후보를
  발급한 뒤에만 Property와 `general_near_goal_father_passed` M49→M60→후일담→
  크레딧 6/6 두 경로의 정상 속도 사람 재플레이를 요청한다.

**규범 소유권:** 사건 이력이 후반 저작 아크와 새 사건으로 중복되지 않아야
한다는 기존 `STORY_BIBLE.md`·`CHOICE_CONSEQUENCE_SYSTEM.md`·`story_rules.json`을
적용한다. W192 cutoff, 파일 소유권, exact 증거는 이 수리의 일회성이며
새 정본 규칙을 추가하지 않는다.

# ORDER-802 — 본편 엔딩 캡션 원화·인과

#### [x] ORDER-802 · 본편 엔딩 캡션 원화·인과

부모157/C5. 착수 — `locale/ui_ja.json`의 강남 white·파산·외로운 부자·
빈집·다은 캡션 5값, `locale/ui_zh-CN.json`의 orthodox_hollow 캡션 1값,
`content/meta/full_game_localization.json`의 해당 결속만 소유한다.
JA에서 같은 30억/마이너스 1억에 원화 단위를 명시한다. CN에서
이미 이룬 성공의 원인을 묻는 질문을 성공하려는 동기의 질문과 분리한다.
`MainGame._ending_add_finale_stage`가 실제 `_ending_run_summary`를 읽는
본편 화면의 문구다. 신규 키/선택/상태/라우팅·KO/EN/TW·데모·저장 비소유.
공식 source/이전 target 결속 export/check/import replace, 사전/원장 역복원,
데모/EN·독립6전독으로 확인한다. 실화면/사람/출시와 별개. 일회성.

## 2026-11-06 결과

제품 `7917559d805b80b1f156b097c67338336ed7b485`, tree
`ec0bb437d845e2ffd0d86bc3ee9e9141160778b4` 정상 push.
[독립6전독 GO](../agent_reviews/order802-cjk-ending-caption-units.md).
JA5는 원화 단위만, CN1은 이미 이룬 성공의 이유만 수리. 신규0.
최초 응답의 manifest 누락 거절을 보존하고 정확한 헤더만 보충,
최종 check/import JA5/CN1 실제 exit0·stderr0.
2UI/원장 byte 역복원, 원392배치/JA기존값 첫 결속5·CN 동일source 원수용1/
기존360판정/raw30·비소유10 보존. JA UI·데모5언어·EN 통과,
lane34는 선택뿐. 제품 CI42151517230 진행 중, 실화면·사람·출시 미관측.

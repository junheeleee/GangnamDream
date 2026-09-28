# Active Queue Spec: ORDER-367

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-367 [P0·검증 수리] 자기소개서 네 답의 수량을 중국어 수용 검사에 보존한다

**[~] 2026-09-28 Codex 착수.** 365 사전 check의 두 지역 실물 실패에서 파생했다.
`끝까지 썼지만 네 답 옆에는 근거를 다시 채울 표시가 남았다.`의 ‘네 답’은
JobHuntMiniGame의 세션4문항과 MainGame의 네 문항 제출을 가리킨다. 정확한
`四个回答`/`四個回答`를 일반 검사가 invented quantity4로 거절했다.
원문/번역에서4를 지워 우회하지 않고, 이 정확 UI leaf의 수량 해석만 수리한다.

## 깊이 3문·소유

1. 제거 손실: 문맥에 맞는4답을 보존한 중국어가 수용되지 못한다.
2. 장기 상태: 검사 해석만 수정한다. 실제 문항·결과·게임 수치/규칙은 바꾸지 않는다.
3. 경쟁 대상: 수사 네/2인칭 네를 구별하며 임의 문장 전체에4를 주입하지 않는다.

- `/root/screen_path_probe` 구현: `tools/full_game_localization.py`,
  `tools/full_game_localization_self_test.py` 정확2파일.
- root 표적 실행/기록: git-private `order367-*`, 이 사양→archive, 큐2·WORK_LOG·
  생성STATUS, agent_review_decisions 새1행, agent_reviews/ORDER-367.json.
- `/root/r3_route_probe` 독립 검수: 비저작, git-private `order367-*review*.json`만.

1배치: group/owner/path/전체KO source/중국어 locale를 모두 구속한 작은 수량 해석.
기존 일반 checker의 오류를 필터링하거나 숫자 전체를 마스킹하지 않는다. 맞는4답
슬롯만 동등 표현으로 바꾸고 나머지 수량·화폐·문자·토큰·개행 검사를 그대로 적용한다.
인접 leaf/원문/키/locale에는 기존 거절·진단을 보존한다. 기존 테스트를 완화하지 않는다.

## 검증·완료

최소 양지역 실제2 정상, 적절한 대체 수사 표기,3/5/답 소거/다른 소유자·단위/중복4/
추가수량·화폐·토큰·개행·문자오류 거절, source/key/group/locale 이탈 비활성 및
기존진단 보존을 표적으로 기록한다. 실제 실패2를 보존하고 동일365 CLI check를 재실행한다.
365 named12의 기존 full_game_localization_self_test 전체에 새 테스트가 포함돼 실행된다.
이 수리는 새 언어·렌더·인간 GO가 아니며365/366 통합·본편/새package HOLD는 별개다.
전체 범용 숫자 규칙 확장·zh_translation_audit·제품3파일·KO/EN/JA·runtime·기존핀은 비소유.
이 정확 leaf/2파일/검증은 **일회성**, 상시 규칙 승격0. 기존 WORK_UNIT/I18N을 따른다.

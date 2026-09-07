# CODEX_QUEUE 2026-09 이동 보존

> 2026-09-07 부팅 예산에 닿은 공통 함정 절을 보존했다(상대 링크 경로만 조정).
> 현재 실행 순서와 상태는 ../CODEX_QUEUE.md가 소유한다. 완료 판정 기록이 아니다.

## 과거 사고 사례와 공통 함정

2026-07-07 이전의 병합 프로토콜·표면 용어 원칙·코드 앵커는 [queue_archive/CODEX_QUEUE_2026-07.md](CODEX_QUEUE_2026-07.md)에 보존한다. 지금도 유효한 함정만 남긴다.

- 유저 표면 문자열은 `_tr(kr,en)` 필수 — `_tr` 밖 한글 리터럴은 `english_hangul_audit.py`가 실패시킨다.
- 새 GameState var는 `serialize()` 또는 `tools/audit.py` `SERIALIZE_EXEMPT` 등록.
- MainGame은 StoryMode 다녀오면 재생성된다 — 턴 상태는 GameState 경유.
- 이벤트 JSON 루트의 새 키는 `tools/audit.py` `EVENT_ROOT_KEYS` 화이트리스트 선등록.
- 내부 시스템 용어(런/몽타주/tint/moral/축)는 플레이어 화면 노출 금지.
- 모든 신규 카피는 설교 방지 원칙(DECISIONS) 검수를 통과한다.

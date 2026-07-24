# Gangnam Dream Work Log

> 최신 작업만 이 파일에 역순으로 기록한다. 2026-05-16부터 2026-07-24 USER-P0K까지의 원문은
> [`history/WORK_LOG_2026-05-16_to_2026-07-24.md`](history/WORK_LOG_2026-05-16_to_2026-07-24.md)에 손실 없이 보존했다.
> 과거 근거는 기본 컨텍스트에 넣지 말고 먼저 `rg -n "<키워드>" docs/history/`로 찾는다.

## 2026-07-24 (Codex — USER-P0L 장기 맥락 아키텍처)

### 새 세션이 기록의 무게가 아니라 현재 작업에서 시작한다

- 기존 `CLAUDE.md`와 큐를 합쳐 기본 부팅에 약 419KB가 필요하던 구조를 16.9KB로 줄였다. `CLAUDE.md`는 현재 상태·불변 규칙·운영·검증만 남기고, `CONTEXT_INDEX.md`가 서사·루프·아트·오디오·UI·현지화·출시 작업별 필수 정본을 단계적으로 안내한다.
- `context_manifest.json`에 정본 소유자, 작업 프로필, 문서 생명주기, 기본 로드 금지 이력, 크기 예산을 기계 판독 가능하게 고정했다. `context_manifest_check.py`는 92개 문서 분류, 부팅 예산, 관리 문서 링크, 핵심 시간축을 검사하며 전체 `audit.sh`의 첫 게이트가 됐다.
- 738,138바이트 `WORK_LOG.md` 원문은 `docs/history/WORK_LOG_2026-05-16_to_2026-07-24.md`로 손실 없이 보관하고 최근 로그를 새로 시작했다. 큐·결정·릴리스·과거 감사는 기본 컨텍스트가 아니라 키워드 검색 대상이 됐다.
- 저장소 안에 얇은 `.codex/skills/gangnamdream-dev` 스킬을 만들고 `~/.codex/skills/gangnamdream-dev`에 연결했다. 스킬은 세계관을 복제하지 않고 부팅·큐 선언·정본 라우팅·표적 QA·사용자 변경 보호만 가르친다.
- 낡은 `CANON_MAP.md`의 `5 years, 60 turns`를 실제 정본인 `5 years, 240 weeks`로 정렬하고, 코드와 문서가 충돌할 때 코드를 자동 정답으로 취급하지 않는 판정 순서를 명시했다.
- 스킬 공식 validator, 문서 게이트, 실제 Godot 경로의 전체 감사를 통과했다. 사건 1,565개, 엔딩 35개, 영어 한글 누출 0, 55개 GDScript 전체 컴파일이 유지됐고 사용자 변경 `project.godot`은 건드리지 않았다.

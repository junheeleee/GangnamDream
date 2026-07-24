# USER-P0L — 장기 맥락 아키텍처·프로젝트 스킬

## 상태

`[~] 착수 — 만지는 파일: CLAUDE.md, docs/CODEX_QUEUE.md, docs/CONTEXT_INDEX.md, docs/context_manifest.json, docs/WORK_LOG.md, docs/history/WORK_LOG_*.md, docs/queue_active/USER-P0L.md, tools/context_manifest_check.py, tools/audit.sh, .codex/skills/gangnamdream-dev/**`

## 사용자 의도

- 긴 개발 대화가 이어져도 새 세션이 최소 문서만 읽고 정확히 복귀해야 한다.
- 정본, 현재 작업, QA, 이력을 섞어 읽어 토큰을 낭비하거나 오래된 결정을 현재 규칙으로 오인하지 않아야 한다.
- Codex와 Claude가 같은 정본을 사용하되 에이전트별 절차를 문서 본문에 중복하지 않아야 한다.

## 완료 조건

1. `CLAUDE.md`가 현재 상태, 불변 규칙, 시작·종료 절차만 담는 짧은 부팅 문서가 된다.
2. `docs/CONTEXT_INDEX.md`가 작업 종류별로 필요한 정본과 금지된 기본 로드를 안내한다.
3. `docs/context_manifest.json`이 부팅 문서, 정본 소유자, 작업별 로드 프로필, 이력·아카이브를 기계 판독 가능하게 분류한다.
4. 거대한 `WORK_LOG.md`는 최근 이력만 남기고 과거 원문을 손실 없이 보관한다.
5. 프로젝트 전용 `gangnamdream-dev` 스킬은 정본을 복제하지 않고 컨텍스트 라우팅과 운영 프로토콜만 제공한다.
6. 자동 검사가 필수 문서 누락, 부팅 예산 초과, 잘못된 이력 기본 로드, 깨진 내부 링크를 차단한다.
7. 사용자 변경 `project.godot`은 건드리지 않는다.

## 검증

```bash
python3 tools/context_manifest_check.py
GODOT=/usr/local/bin/godot ./tools/audit.sh
git diff --check
```


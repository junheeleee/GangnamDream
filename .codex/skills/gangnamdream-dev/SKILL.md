---
name: gangnamdream-dev
description: Develop, review, debug, test, localize, or produce visual/audio/UI assets for the Gangnam Dream Godot repository while preserving its story canon, queue protocol, player-owned work, bilingual surface, and targeted QA workflow. Use whenever Codex works inside the GangnamDream repo or the user refers to 강남드림 development.
---

# Gangnam Dream Development

Use the repository as the source. Do not copy project canon into this skill.

## Boot

1. Locate the repository root containing `CLAUDE.md`, `project.godot`, and `docs/context_manifest.json`.
2. Read `CLAUDE.md`.
3. Run `git status --short --branch`. Preserve unknown and user-owned changes.
4. Read `docs/CODEX_QUEUE.md`.
5. Read only the selected `docs/queue_active/<ID>.md`.
6. Open `docs/CONTEXT_INDEX.md` and load one matching task profile.

Do not load full logs, release notes, archives, or unrelated active orders by default.

## Work

- For substantial work, mark the queue item `[~] 착수 — 만지는 파일: ...`, commit, and push before implementation.
- Search `docs/DECISIONS.md` by topic instead of reading it whole.
- Treat runtime as evidence. If it conflicts with a domain owner, determine whether the code or document is stale and align both deliberately.
- Keep edits scoped. Do not revert unrelated work and do not touch a dirty `project.godot` unless the user explicitly assigns it.
- For image work, read the target visual bible and continuity contract before generation. Recurring cast portraits, place backgrounds, and event CGs have different ownership.
- For audio work, use recorded or real-instrument sample sources only and preserve source manifests.
- Keep Korean source and English player surface aligned. Never move gameplay keys into translation overlays.

## Verify

Run the narrow check for the changed behavior first. Before completion, run:

```bash
python3 tools/context_manifest_check.py
GODOT=/usr/local/bin/godot ./tools/audit.sh
python3 tools/en_coverage_check.py
git diff --check
```

Use only relevant ScreenshotQA scopes while iterating. Treat automated visual/audio checks as contract evidence, not human taste approval.

## Close

1. Update the live state in `CLAUDE.md`.
2. Add the newest entry to `docs/WORK_LOG.md`.
3. Update only the owner ledger required by the change.
4. Mark the queue item complete or state its real remaining gate.
5. Stage only intended files, commit, and push the current branch.

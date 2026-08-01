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

## Propose, and improve yourself

`docs/PROPOSALS.md` owns the rules. Read it before your first proposal, not this skill — a copy here would go stale.

Three ways to handle what you find while working. **Most findings are the first kind.**

1. **Just do it** — typo, broken link, dead comment, a check that reports something false, a failure message that does not say how to fix it, an unregistered check, a stale generated document. Same commit, no proposal.
2. **Do it and record why** — inside scope but a reasonable person could disagree. Proceed, and put the reasoning in the commit message and `WORK_LOG.md` so the user can reverse it later.
3. **Stop and propose** — canon rules, story/cast/relationships, numbers outside the balance bands, a new system not in the queue, deleting anything, scope growth, finishing or removing a half-built feature, ratings/legal. File it and **do not start that one item.** Finish the rest of the work unit; a proposal must not halt the session.

**Eligibility is friction, not imagination.** If you did not hit it while working, it belongs in `docs/POST_LAUNCH_NOTES.md`. Five open proposals maximum, twenty-one days to a decision — `context_manifest_check.py` fails on both, and open ones surface in `docs/STATUS.md` where the user already looks.

Every proposal carries a recommendation. Listing options without choosing hands the work back. And if you cannot write **what the project keeps paying if nobody acts**, it is a preference, not a proposal — do not file it.

**The cheapest self-improvement is one line.** When this session cost you time — a tool you could not find, an assumption that was wrong, an order whose boundary was unclear — add one line to the skill or the owning document in the same commit. That is category 1 and needs no permission. **Add a line only where it would have saved you; a skill that grows every session stops being read.**

## Verify

**Let the repository choose the checks. Do not run the full audit while iterating** — it takes about ten minutes, and `audit_select` resolves a docs-only change in under a second.

```bash
python3 tools/audit_select.py --base main   # 변경이 요구하는 검사만 고른다
```

An unmatched path deliberately demands the full audit; that is the safe default, not a bug. Register a new check in `tools/audit_scope.json` — `--verify` fails on an unregistered one.

Before completion:

```bash
python3 tools/context_manifest_check.py
GODOT=/usr/local/bin/godot ./tools/audit.sh
python3 tools/en_coverage_check.py
git diff --check
```

`docs/STATUS.md` is generated, never hand-edited. Any content change makes it stale and `audit.sh` fails on it. Regenerate in the same commit:

```bash
python3 tools/project_dashboard.py --md docs/STATUS.md
```

Several checks are ratchets with a recorded baseline: `surface_coherence_audit`, `identity_signature_audit`, `feature_liveness_audit`, `peak_scene_chain_audit`. **A known defect passes and a new one fails.** When one improves, update its baseline in the same commit so the debt cannot creep back. Never widen a baseline to make a failure go away — fix the change or say why the ratchet is wrong.

Use only relevant ScreenshotQA scopes while iterating. Treat automated visual/audio checks as contract evidence, not human taste approval.

**A green audit means the contracts held, not that the work is good.** `docs/human_gates.json` lists what no check can decide — every audit that has a gate in its domain prints it as pending and never passes it. Do not report a task finished when its gate is still open; say which gate remains and who owns it. Move a gate to `done` only when a human judged it, and record the evidence — `tools/human_gates.py` fails on a `done` without it, and on a gate whose owning order no longer exists.

## Close

1. Update the live state in `CLAUDE.md`.
2. Add the newest entry to `docs/WORK_LOG.md`.
3. Update only the owner ledger required by the change.
4. Mark the queue item complete or state its real remaining gate.
5. Stage only intended files, commit, and push the current branch.

---
name: gangnamdream-scene
description: Author or deepen a Gangnam Dream scene against its tier contract before writing prose, so density, assets, direction, and speaker knowledge are settled up front instead of being caught by an audit afterwards. Use when writing a new scene, raising a one-beat scene, or filling a demo slot in the GangnamDream repo.
---

# Gangnam Dream Scene Authoring

Use the repository as the source. **Do not copy the contract into this skill** — it
changes, and a copy goes stale.

The audit already catches contract violations. It catches them *after* the prose
exists, which is the expensive moment. This skill moves the same questions before
the first line.

## Settle before writing

1. **Read [`docs/SCENE_TIER.md`](../../../docs/SCENE_TIER.md).** §0 defines the unit:
   **one chain is one scene**, individual events are beats, and the contract binds
   the whole chain — not each beat.
2. **Name the tier and say why.** T1 is the chapter's peak, a turning point, a
   chapter close, a temptation fork. Everything else is not. **Do not raise a scene
   to T1 to make it feel important** — if everything is a peak there is no peak.
3. **List what the tier requires and where each item will come from**, before prose:
   beats, choice points, the chain, background, portrait or CG acting, scene audio,
   the `direction` key.

## Blocking conditions

**Assets absent means the scene does not ship.** If the contract calls for a
dedicated background, portrait acting, CG, or an ambience that does not exist as a
real file, stop and record the gap. Do not crop a lookalike, and do not write prose
that assumes an asset someone will make later.

**No `direction` key means the scene is not finished.** The renderer exists;
`docs/SCENE_DIRECTION.md` owns the schema. Do not invent keys. Fill it in the same
unit as the prose — a separate pass over direction never happens.

## Choices carry cost

`MORAL_TINT.md` §2 owns this. Before writing a choice set, answer: **what does each
option push away?**

- An option that is better on every axis with the same follow-up and the same flags
  is a right answer, not a choice. `DEMO_TIER_AUDIT.md` measured 413 of those.
- The moral axis follows what was given up, not how kind the line sounds.
- Never explain the axis to the player, and never state a future consequence as
  certain before the choice.

## Who is speaking, and what do they know

`content/meta/story_rules.json` and `docs/STORY_CONSISTENCY_SYSTEM.md` decide what a
character can reference at this point in the run. A portrait in a call, message, or
memory must not read as physical presence.

**Flags are consumed as dik prose keys, not only in `conditions`.** Searching
`conditions` alone will report a live flag as dormant.

## Close the unit

Follow `docs/WORK_UNIT.md`: the evidence form, then the targeted audit
(`python3 tools/audit_select.py --base main`). A blank in the evidence form means
the unit is not done.

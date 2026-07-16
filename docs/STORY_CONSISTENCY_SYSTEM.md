# Story Consistency System

Updated: 2026-07-16

## Purpose

`content/meta/story_rules.json` is the language-independent source for story facts that must not drift between Korean text, English overlays, routing code, portraits, and backgrounds.

The ledger does not replace the save-compatible flag system in one risky rewrite. It first makes hidden assumptions measurable, then moves runtime routing to typed facts in controlled slices.

## Contract Layers

### Typed facts

An enum fact gives one concept one legal state at a time. Current first-pass facts are:

- `father.life`: alive -> concern -> hospitalized -> passed
- `relationship.jiyeon.phase`: unmet -> acquainted -> dating -> married, then a verdict state
- `sangchul.truth_resolution`: hidden -> known -> one final resolution

`requires`, `forbids`, `produces`, and per-choice `choice_produces` may only use declared values. A rule cannot require and forbid the same fact.

### Legacy bridge

`logic.legacy` records the current boolean implementation while migration is in progress:

- `requires_flags`: facts the scheduler must already know
- `forbids_flags`: states that make the event impossible
- `produces_all`: flags every choice must set
- `produces_any`: flags at least one choice must set

The audit compares producer contracts with the actual event choices. This catches a newly added choice that forgets to close an arc.

### Exclusive outcomes

`exclusive_flag_groups` describes flags that cannot be produced together by one choice. The first groups cover romance route ownership, Jiyeon's verdict, and Sangchul's truth resolution.

### Scene presence

Every high-risk remote scene declares:

- `channel`: `in_person`, `phone`, `video_call`, `message`, `memory`, or `narration`
- `scene_location`: where Minjun and the camera physically are
- `remote_location`: where the off-screen participant is
- `remote_actor`: who is on the other end
- `portrait_role`: `present`, `remote`, `local`, or `none`
- `expected_portrait`: the exact wardrobe/expression asset required by the location contract

For remote media, identical local and remote locations are invalid. A remote portrait must resolve to the declared remote actor.

## Runtime Visual Grammar

- `in_person`: full standing portrait over the physical location, no media badge.
- `phone`: compact right-side inset, `VOICE CALL / 통화 중`, and a remote suffix in the name tag.
- `video_call`: the same spatial separation with a video-call label.
- `message`: media badge; a remote sender may use the inset, while a local reaction portrait stays full size.
- `memory`: compact inset at quieter opacity. It is not a person physically entering the room.
- `narration`: no portrait.

CGs remain authoritative. A split-screen phone CG may hide the standing portrait, but the channel badge still states the scene grammar.

## Current Baseline

The first pass intentionally covers high-risk material instead of pretending all 1,500 events are migrated:

- Ledger events: 54 / 1,501 (3.6%)
- Typed logic contracts: 17
- Remote/media presentation contracts: 36
- Unclassified non-player portraits with phone/message titles: 0
- Demo father-contact logic targets: 4 / 4

The first migrated in-person Father peak is now explicit as well: Minjun waits opposite an inpatient examination room on Father's third day in a Changwon hospital, Father appears in a hospital gown only after the door opens, and the return trip is to Seoul. Changwon-home meetings and calls use the worn home cardigan, while the late illness call changes acting without changing clothes. The waiting response cannot commit medical-result state before the final decision.

These are ratchets. `minimum_ledger_events` cannot fall, and the unclassified communication count cannot rise above zero.

## Authoring Workflow

1. Write or identify the event in Korean source JSON.
2. Add its rule to `story_rules.json` before wiring visuals.
3. Declare typed prerequisites and outcomes for a critical arc.
4. Declare scene presence whenever dialogue is not physically co-located.
5. Run `python3 tools/story_consistency_audit.py`.
6. For presentation changes, run `StoryPresenceCheck.tscn` and `ScreenshotQA --qa=story-presence` in Korean and English.

Do not infer channels from localized prose at runtime. Text scanning is only an audit signal; authored data owns the result.

## Migration Order

1. Audit-only ledger and remote-presentation runtime: complete.
2. Demo weeks 1-24 prerequisite evaluation from the ledger.
3. Father, romance, Sangchul, and ending-critical routing.
4. Remaining authored arcs, then ambient/random events.

Hard contradictions fail the build even if an aggregate quality score is high. Coverage percentage is progress, not permission to ship an impossible scene.

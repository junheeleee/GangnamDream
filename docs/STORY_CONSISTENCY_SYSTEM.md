# Story Consistency System

Updated: 2026-07-26

## Purpose

`content/meta/story_rules.json` is the language-independent source for story facts that must not drift between Korean text, English overlays, routing code, portraits, and backgrounds.

The ledger does not replace the save-compatible flag system in one risky rewrite. It first makes hidden assumptions measurable, then moves runtime routing to typed facts in controlled slices.

## Event ID Is the Join Key

Every authored event keeps one stable ID across all layers:

- Korean source and localized text overlays
- executable prerequisites and outcomes
- participants and their role in the physical scene
- background, portrait, CG, ambience, and transition contracts
- route simulation and regression tests

Do not infer these facts from prose or filenames. A rewrite may keep the event ID
for save compatibility while changing its title, venue, or wording; the contracts
attached to that ID must change in the same commit.

### Executable prerequisites

`logic.prerequisites` is the first generic runtime-owned gate. It accepts `all`
and `any` groups whose clauses use a dotted state path:

```json
{
  "logic": {
    "prerequisites": {
      "all": [
        {"path": "turn", "op": "gte", "value": 20},
        {"path": "player.job.id", "op": "in", "value": ["job_03", "job_08"]},
        {"path": "flags.scene_seen", "op": "neq", "value": true}
      ]
    }
  }
}
```

Supported operators are `eq`, `neq`, `in`, `not_in`, `gte`, `lte`, `truthy`,
and `falsy`. Runtime context currently exposes `turn`, `player`, and `flags`.
New domains must be added to one context builder rather than read ad hoc inside
each scheduler branch.

### Participant roles and audiovisual expectations

An in-person scene may add `participant_roles` and exact expectations:

```json
{
  "presentation": {
    "channel": "in_person",
    "scene_location": "convenience_store",
    "participants": ["player", "daeun"],
    "participant_roles": {"player": "customer", "daeun": "clerk"},
    "expected_background": "convenience_night",
    "expected_portrait": "daeun_smile",
    "expected_ambience": "convenience"
  }
}
```

`story_consistency_audit.py` joins this declaration to the event JSON, visual
contract, and scene-audio manifest. A customer scanning the register, a company
manager visiting an unemployed save, or a Korean restaurant showing a cafe must
fail before playtest.

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

- `channel`: `in_person`, `internal`, `phone`, `video_call`, `message`, `memory`, or `narration`
- `scene_location`: where Minjun and the camera physically are
- `remote_location`: where the off-screen participant is
- `remote_actor`: who is on the other end
- `portrait_role`: `present`, `remote`, `local`, or `none`
- `expected_portrait`: the exact wardrobe/expression asset required by the location contract

For remote media, identical local and remote locations are invalid. A remote portrait must resolve to the declared remote actor. `internal` is reserved for one physically present participant thinking or investigating alone; it requires one local portrait and cannot declare a remote actor or location.

### Dynamic scene locations

`current_housing` and `current_workplace` are state-owned scene locations, not
generic fallbacks. When an event uses one of these keys, the event background,
story-rule presentation, visual contract, audio profile, and transition contract
must all retain the same dynamic key. Runtime resolves it from the current save
only when the scene opens.

Do not replace `current_housing` with `goshiwon_room` merely because Minjun starts
the game there. Likewise, an office scene that requires `current_workplace` must
also carry an executable employment prerequisite. A remembered specialization or
past company flag cannot make an office scene valid after Minjun quits.

### Scene transitions

Demo-critical follow-up edges declare one of four modes:

- `same_location`: camera and physical location must remain identical.
- `explicit_move`: the destination description must name the move or arrival.
- `time_cut`: the destination must carry an authored Korean and English time cue.
- `memory_cut`: the destination must identify the recalled time and place in both languages.

Every contract owns `from_location` and `to_location`. Non-local cuts also own exact `arrival_cue_ko` and `arrival_cue_en` strings that must occur in the destination event. The audit follows the real `follow_up_event` edge, resolves presentation locations before background fallbacks, and rejects undeclared demo jumps.

## Runtime Visual Grammar

- `in_person`: full standing portrait over the physical location, no media badge.
- `internal`: one local reaction portrait over the physical location, with no invented second participant or media badge.
- `phone`: compact right-side inset, `VOICE CALL / 통화 중`, and a remote suffix in the name tag.
- `video_call`: the same spatial separation with a video-call label.
- `message`: media badge; a remote sender may use the inset, while a local reaction portrait stays full size.
- `memory`: compact inset at quieter opacity. It is not a person physically entering the room.
- `narration`: no portrait.

CGs remain authoritative. A split-screen phone CG may hide the standing portrait, but the channel badge still states the scene grammar.

## Current Baseline

The first pass intentionally covers high-risk material instead of pretending all 1,500 events are migrated:

- Ledger events: 135 / 1,565 (8.6%)
- Typed logic contracts: 49
- Remote/media presentation contracts: 49
- Dynamic location contracts: 58
- Authored transition contracts: 64 / 64
- Unauthorized demo location jumps: 0
- Unclassified non-player portraits with phone/message titles: 0
- Demo father-contact logic targets: 4 / 4

The migrated Father peaks are now explicit as well. The prologue call remains at the rainy bus stop reached by the previous scene; the result boards a bus, and only `Back at the goshiwon / 고시원에 돌아온 뒤` authorizes the notebook background change. Minjun later waits opposite an inpatient examination room on Father's third day in a Changwon hospital; Father appears in a hospital gown only after the door opens, and the return trip is to Seoul. Changwon-home meetings and calls use the worn home cardigan, while the late illness call changes acting without changing clothes. The 23-second artifact scene now establishes a Seoul-bound KTX eleven minutes after it passed Changwon Jungang Station; the old call uses a compact `MEMORY / 기억` inset with Father at his Changwon home, never a body standing inside the train. Its buildup cannot alter state, and only the terminal call/no-call choice applies the legacy effects. The final passing call begins in Minjun's actual current housing, then separates the winter Seoul KTX platform or Seoul deal room from the empty Changwon hospital room or next-morning hospital call. Neither buildup link can commit Father's death, money, mental, or moral state before the terminal scene.

Seasonal romance now uses the same movement grammar. Both sea routes remain physically inside their KTX through the root and either dialogue branch, then use an explicit arrival cue before the final East Sea or Haeundae decision owns the beach CG and state. Both fireworks routes remain at the same Hangang riverside before launch; their buildup has no particles, explosion cue, or state change, and the final decision alone owns the first visible and audible shell.

Daeun's first-night peak is a same-location contract across four events. `current_housing` resolves once from the live save and remains the physical room through both buildup routes and the final decision, whether Minjun currently rents a goshiwon, one-room, villa, or apartment. Daeun remains in the same navy convenience-store polo and beige cardigan; only her acting progresses from normal to sad to a restrained smile. The scene uses city light and indoor rain-on-glass audio, never rain particles inside the room. Buildup choices cannot alter state, and only the terminal choice owns the legacy relationship, affinity, mental, Moral Tint, and completion outcomes.

Sangchul's first meeting is likewise a same-location contract across its two opening routes and final answer. All four events remain in the early-spring Sinchon real-estate office with Sangchul physically present in the same clothes; only his expression moves from measured warmth to seriousness. The measure/coffee buildup cannot change stats, flags, cast stage, or artifact ownership. Only the three final answers may advance Sangchul, preserve the Changwon pause seed, and grant exactly one business card.

Sangchul's deduction is an `internal` same-location chain in Minjun's live housing. The paid-in-full certificate and archived-business routes contain no state changes and converge only after the case number, Mapo address, dates, and registered owner agree. The final 15-second choice alone may establish or defer the truth and grant `clue_father_broker`. `hidden_whole_picture` uses the same live-housing rule instead of inventing a return to the goshiwon.

Sangchul's casino invitation starts as a `message` in Minjun's live housing, moves through two `internal` calculation routes, and reaches the original local reply without changing location or room tone. Only the accepted reply issues a ticket and follows an `explicit_move` contract to the Jeongseon exterior, where Sangchul resets to `in_person`. The declined route cannot show the casino or imply that Sangchul entered Minjun's room.

Hyunsu's employment news is a `message` in Minjun's live housing with Hyunsu shown only as the remote accounting-route sender. The photo and failed-exam memory links remain in that same room and cannot mutate state. `hyunsu_comforted` selects the knocked-door memory; its absence selects the respectful-waiting memory. Both routes require an explicit Saturday move to the old-neighborhood restaurant before Hyunsu becomes `in_person`, the cafe/intimate audio bed begins, or the physical business card can enter inventory.

Exposed callbacks and career scenes now obey the same state contract. Calls,
messages, private memories, and domestic reflections follow Minjun's live housing
after every move; Sangchul's in-person tea confession stays in a cafe. Father's
medication message occurs on a public-transit trip home, so it remains valid for
unemployed, part-time, and salaried saves. Routine reflections use work, income,
and schedule language instead of inventing an office. Hold'em-to-negotiation and
career-specialization results require a current job at the moment they are
scheduled, including after a later resignation.

These are ratchets. `minimum_ledger_events` cannot fall, and the unclassified communication count cannot rise above zero.

## Authoring Workflow

1. Write or identify the event in Korean source JSON.
2. Add its rule to `story_rules.json` before wiring visuals.
3. Declare typed prerequisites and outcomes for a critical arc.
4. Declare scene presence whenever dialogue is not physically co-located.
5. Add a transition contract when a demo-critical follow-up moves camera, place, time, or memory frame.
6. Run `python3 tools/story_consistency_audit.py`.
7. For presentation changes, run `StoryPresenceCheck.tscn` and `ScreenshotQA --qa=story-presence` in Korean and English.

Do not infer channels from localized prose at runtime. Text scanning is only an audit signal; authored data owns the result.

## Migration Order

1. Audit-only ledger and remote-presentation runtime: complete.
2. Demo weeks 1-24 prerequisite evaluation from the ledger: in progress.
3. Migrate job-dependent and romance-critical events with participant and A/V
   contracts.
4. Move repeated choice effects into one validated effect evaluator.
5. Resolve MORAL_TINT through authored presentation profiles rather than
   scattered color literals.
6. Remaining authored arcs, then ambient/random events.

Hard contradictions fail the build even if an aggregate quality score is high. Coverage percentage is progress, not permission to ship an impossible scene.

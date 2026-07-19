# DEMO SCENE FLOW AUDIT - First 24 Weeks

Updated: 2026-07-19

## Decision

The first-24-week scene-flow regression gate passes in Korean and English. This is a structural continuity pass, not a player-fun pass. Demo Round 2 remains **NO-GO** until a normal-reading human replay reports that the sequence feels like one developing story rather than a queue of short events.

## Scope

- Fresh title boot through the week-25 demo CTA.
- Real gamepad South-button input through StoryMode, AP decisions, results, and summaries.
- Every StoryMode entry recorded with week, event ID, inferred character/conflict thread, resolved location, previous event, follow-up ownership, and transition mode.
- Identical gameplay seed and actions in Korean and English.

The profiler distinguishes three release-blocking discontinuities:

| Counter | Failure definition |
|---|---|
| `followup_recuts` | A direct follow-up remains in the same location but has no continuity contract, so it is presented as a fresh scene cut. |
| `uncontracted_moves` | A direct follow-up changes location without `time_cut` or `explicit_move`, so the player is teleported between scenes. |
| `same_week_conflict_switches` | A different non-chapter story root interrupts the same week with another person or conflict. |

## Measured Baseline

The initial English Xbox route completed 24 weeks in 690 confirms across 47 events.

| Metric | Baseline |
|---|---:|
| Same-location follow-up recuts | 3 |
| Follow-up moves without a transition contract | 6 |
| Same-week unrelated conflict switches | 5 |

The five scheduling collisions were concrete, not inferred from event volume:

| Week | Colliding beats | Diagnosis |
|---:|---|---|
| 2 | Father-call chain + first work shift | A new employment conflict was appended to the interview/origin chain. |
| 12 | Daeun's first beat + Hyunsu study | Two different character threads claimed the same week. |
| 14 | Father beat + first investment loss | Family and investment roots were stacked without causal ownership. |
| 17 | Jiyeon beat + first savings milestone | A relationship scene was immediately replaced by a financial reckoning. |
| 20 | Job-versus-investment + Hyunsu's night question | The second scene was thematically relevant but was scheduled as an unrelated root. |

## Repairs

### Calendar ownership

- The first work-shift scene now waits until week 3.
- Hyunsu's study scene opens in week 11, leaving week 12 to Daeun.
- The first investment-loss beat opens in week 15, after the week-14 Father beat.
- Crossing 3 million won latches the savings milestone, but it cannot surface before week 18. Later AP spending cannot erase the earned milestone.
- All three results of `arc_job_vs_invest` now lead directly to `arc_hyunsu_night_talk` in week 20, making the night conversation an authored mirror of the preceding conflict.

No event effects, choice effects, economic values, or reward probabilities changed.

### Spatial and temporal contracts

The demo chains now declare `same_location`, `time_cut`, or `explicit_move` in `story_rules.json`. This covers the opening interview-to-goshiwon cut, temptation aftermaths, the Hyunsu hallway handoff, cafe conversations and callback arrival, Gangnam-to-Han-River movement, and the office-to-goshiwon Hyunsu mirror.

The first-paycheck event no longer assumes an office worker. `current_workplace` resolves survival convenience work, delivery work, and office jobs to their live locations, and the Korean/English prose is shift-neutral. The first-savings scene similarly resolves `current_housing` instead of inventing a return to the starting room.

### Language-independent gameplay randomness

UI sound pitch and presentation motion previously consumed the same global random stream as jobs, events, and weekly income. Korean and English require different numbers of text inputs, so that coupling could change later cash and pressure selection even with the same seed and choices. Audio pitch variation and presentation-only motion now use private `RandomNumberGenerator` instances.

## Final Evidence

| Route | Weeks | Events | Confirms | Roots / follow-ups | Continuous follow-ups | Recuts | Uncontracted moves | Conflict switches |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| KO Xbox | 24 | 47 | 689 | 24 / 23 | 10 | 0 | 0 | 0 |
| EN Xbox | 24 | 47 | 693 | 24 / 23 | 10 | 0 | 0 | 0 |

Both routes expose the same ten pressure decisions in the same order:

`employment -> home_margin -> body_capacity -> career_ceiling -> relationship -> human_debt -> home_margin -> career_ceiling -> capital -> career_ceiling`

They also produce identical week-by-week cash, event order, action choices, and final gameplay state. The four-confirm difference is localized prose length only. The final 24-week cadence is ten direct weeks (eight Decision plus two Boss), three Echoes, and eleven Quiet weeks.

`DemoBuildCheck` locks the schedule, savings latch, contextual locations, and transition contracts. `ScreenshotQA --qa=demo-gamepad` fails if any of the three scene-flow counters is nonzero or the fixed demo beats drift from their repaired weeks and locations.

The final repository gate also passes with static `ERROR 0 / WARNING 0`, 68 transition contracts, 1,565/1,565 English event coverage, zero arc jams, current mod manifests, and all 55 GDScript files compiled. The representative Chapter 1 paths now contain 26/28 foreground roots and eight causal chains; Hyunsu's night mirror remains inside the week-20 job/investment chain instead of inflating the root count.

## Remaining Human Gate

This audit proves that the game no longer cuts away from a scene because of accidental scheduling, missing spatial grammar, or localization-dependent randomness. It does not prove that the prose is moving, that the choices are difficult, or that the 24 weeks create curiosity. Those remain the next user replay questions, and the Round 2 **NO-GO** remains authoritative.

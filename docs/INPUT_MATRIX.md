# Input and Display Matrix

Updated: 2026-09-01

## Release Position

Gangnam Dream is designed around one semantic command model rather than literal focus traversal. Keyboard, mouse, and gamepad may present different labels, but they must reach the same decisions and never change simulation results.

The current public release demo is `story_demo_rc` M01-M06 (24 internal weeks),
whose structure and scope have user GO. The recorded 24-week keyboard, mouse,
planner, AP, and CTA runs below belong to the legacy/internal `demo_rc` W1-W24 V2
compatibility and regression lane; they are not the identity or public-candidate
proof of `story_demo_rc`.

This automated evidence may continue to protect shared input and display behavior.
It is not sufficient to claim Steam "Full Controller Support": the current
`story_demo_rc` still needs the named physical Steam Deck/DualSense/Switch Pro
blind passes, suspend/resume, and Steam overlay verification at release-candidate
time.

## Input Contract

| Surface | Keyboard | Mouse | Xbox / Steam Deck | DualSense | Switch Pro | Evidence |
|---|---|---|---|---|---|---|
| Legacy `demo_rc` title to W24 CTA | PASS | PASS | Contract only | Contract only | Contract only | Real W1-W24 V2 keyboard and mouse regression routes; not current public-candidate identity |
| Title load/archive pages | PageUp/PageDown, Q/E | Direct click | LT/RT pages, LB/RB archive tabs | L2/R2 pages, L1/R1 archive tabs | ZL/ZR pages, L/R archive tabs | Raw trigger edge and modal-capture gate |
| VN choices | Arrows + Enter/Esc | Direct click | D-pad + South/East | D-pad + Cross/Circle | D-pad + B/A | StoryMode route and brand screenshots |
| Legacy/internal AP decision | Arrows + Enter | Direct click | D-pad + A/B | D-pad + Cross/Circle | D-pad + B/A | Preserved one-screen regression board, no scroll; not a public `story_demo_rc` layer |
| Fresh Seoul Cycle | Arrows, Enter/Esc | Direct click | D-pad, A/B | D-pad, Cross/Circle | D-pad, B/A | Four local nodes; no fake trigger action |
| Legacy V2 planner | Arrows, Enter, X, Q/E | Direct click | D-pad, A/X, LB/RB | D-pad, Cross/Square, L1/R1 | D-pad, B/Y, L/R | Four-week planner, review, immutable reopen |
| Portrait contact phone | P, arrows, Enter/Esc, Q/E | Direct click | Y, D-pad, A/B, LB/RB | Triangle, D-pad, Cross/Circle, L1/R1 | X, D-pad, B/A, L/R | Messages/Contacts only, modal focus restore |
| Story settings/save pages | F10/Esc, PageUp/PageDown | Settings button | Menu/B, LT/RT save pages | Options/Circle, L2/R2 save pages | Plus/A, ZL/ZR save pages | Text/language/audio/motion/vibration gate, no scroll |
| Completion/month ledger | Y, PageUp/PageDown, Esc | Direct click | Y, LT/RT, B | Triangle, L2/R2, Circle | X, ZL/ZR, A | Triggers page only; never finish or exit |
| Casino hub and direct games | Q/E, PageUp/PageDown, X, Y, Enter, Esc | Direct click | LB/RB group, LT/RT stake, X/Y, A/B | L1/R1 group, L2/R2 stake, Square/Triangle, Cross/Circle | L/R group, ZL/ZR stake, Y/X, B/A | Nine scenes, 18 secondary routes, eight reversible major routes |
| Vibration | N/A | N/A | On/off + strength | On/off + strength | On/off + strength | Title/Main/Story persistence, immediate stop, named cue profiles; physical feel pending |

Physical-position names are canonical: South confirms, East cancels, West performs the contextual secondary action, and North opens details/rules. L1/R1 move between sibling tabs, groups, or action families; L2/R2 move a page or reversibly decrease/increase a coarse value. Triggers never confirm, save, load, buy, commit, advance time, exit, or delete. `ControllerHints` owns all visible labels. No game scene may hardcode Xbox letters.

The keyboard equivalent is equally semantic: `Enter` confirms, `Esc` backs out, `X` performs the contextual secondary action, `Y` opens rules/details, `Q/E` change groups, `PageUp/PageDown` move pages or coarse values, `F10` opens settings, and `N` advances a finished week. Analog triggers press at `0.55`, re-arm only below `0.35`, and produce exactly one change per press. Keyboard input immediately replaces pad letters in visible hints.

Legacy/internal `demo_rc` W1-W24 V2 keyboard-only regression evidence:

```text
DEMO_INPUT_RUN_OK device=keyboard weeks=24 inputs=1101 events=59
start_job=unemployed end_job=job_01 axes=15/24
key_events=2206 mouse_events=0 cutoff=cta
```

Legacy/internal `demo_rc` W1-W24 V2 mouse-only regression evidence:

```text
DEMO_INPUT_RUN_OK device=mouse weeks=24 inputs=1035 events=59
start_job=unemployed end_job=job_01 axes=15/24
key_events=0 mouse_events=3111 cutoff=cta
```

The legacy mouse run exposed a clipped month-summary progression button. The
summary is now a single no-scroll surface and the legacy W24 CTA remains fully
visible at 1280x800. This preserved regression does not redefine the public demo.

## Display Contract

| Output | Aspect | Automated render | Result | Notes |
|---|---:|---:|---|---|
| 960x600 | 16:10 | Settings, AP, Living Scene | PASS | Minimum free-window contract; functional layout, not a handheld readability target |
| 1280x720 | 16:9 | Settings, AP, Living Scene | PASS | Low-height reference; hardware spot pass still required |
| 1280x800 | 16:10 | Repeated legacy V2 and Steam Deck regression QA | PASS | Primary Deck reference; public `story_demo_rc` candidate pass remains separate |
| 1600x900 | 16:9 | Settings, AP, Living Scene | PASS | Common desktop window size |
| 1920x1080 | 16:9 | Settings, AP, Living Scene, three glyph families | PASS | TV safe margin enforced |
| 2560x1440 | 16:9 | Settings, AP, Living Scene | PASS | Same command hierarchy |
| 3440x1440 | 21:9 | Settings, AP, Living Scene | PASS | Background view expands; decisions remain in safe composition |
| 3840x2160 | 16:9 | Settings, AP, Living Scene | PASS | UI/text geometry is sharp; raster-master enlargement is tracked separately |

The project uses an 800-pixel logical-height canvas and expands horizontally. UI scales with output resolution, while background art uses cover framing. Story text, portraits, and controls must remain inside a 2.5% TV-safe rectangle. Ultrawide may reveal additional environment but must never reveal hidden UI, offstage actors, or branch-dependent art.

Window settings expose:

- Windowed, borderless window, and fullscreen modes.
- 960x600, 1280x720, 1280x800, 1600x900, 1920x1080, 2560x1440, 3440x1440, and 3840x2160 window sizes.
- Reduce Motion.
- Vibration on/off and strength.
- Music and SFX levels plus language selection.

## Accessibility and Motion

Reduce Motion stops camera drift and portrait breathing, reduces weather speed and fireworks, and preserves all information. It does not remove rain/snow identity or alter timing and choices.

Story text has Small, Default, and Large levels. The event-scene settings hub applies them immediately and can switch the active language without leaving the scene. While open it freezes prose, AUTO, direction timing, and timed choices; closing restores the exact choice focus and countdown remainder. KO/EN 1280x720 and 1280x800 renders must keep every control and the Large body text inside the viewport without a scroll surface.

Rain and snow use canvas-UV-correct downward movement. `LivingSceneCheck` locks the shader sign and `ScreenshotQA` compares real rain frames; the current probe found a best displacement of `+24 px` downward with `0.9507` correlation.

Vibration is limited to named meaningful commits, danger/results, and sparse physical beats. Ambient navigation, focus, tabs, page movement, prose advance, hover, value preview, looping weather, and failed or disabled actions remain silent. Turning vibration off or setting strength to zero immediately stops an in-flight cue; all information remains visible and audible without haptics.

## Automated Gates

`InputMatrixCheck.tscn` currently requires:

```text
INPUT_MATRIX_CHECK_OK modes=3 resolutions=8 brands=3
direct_scenes=9 direct_routes=18 major_routes=8 modal_routes=8 boundary_routes=16 invalid_routes=8
keyboard_tasks=10 action_sets=4

CONTROLLER_SEMANTIC_CHECK_OK surfaces=4 major_actions=2 raw_routes=8
trigger_gate=1 reconnect_gate=2 modal_leaks=0 vibration=1
```

The ten keyboard tasks do more than toggle a control: Blackjack deals, Baccarat places a Player bet and deals, Slots starts the reels, Roulette stages a bet and spins, Big Wheel selects and spins, Dai Sai selects and rolls, Holdem buys in and deals, RaceTrack selects a horse and starts the race, the casino hub launches the highlighted table, and the resume assessment returns control to the AP surface. The same gate sends raw L2/R2 press, held jitter, and release events through all eight direct games. Each first-entry/rules tutorial consumes those edges without changing the hidden stake or buy-in. A valid setup changes one value step; all sixteen endpoint routes clamp instead of wrapping; an in-flight/result phase preserves value, money, round/session count, focus, phase, and visibility. A held trigger carried through disconnect/reconnect cannot fire until a neutral release has been observed, while a neutral reconnect preserves the first intentional press.

`ScreenshotQA --qa=display-matrix` passes in both Korean and English at 960x600, 1280x720, 1280x800, 1600x900, 1920x1080, 2560x1440, 3440x1440, and 3840x2160. Each of the sixteen runs captures title settings, a legacy `demo_rc` AP decision, and a StoryMode choice, and verifies exact PNG dimensions, TV-safe controls, active keyboard/controller focus, and distortion-free background cover. The 1080p passes also capture Xbox, PlayStation, and Nintendo title hints in both languages. These shared-surface renders remain regression evidence rather than a new public demo candidate.

This is a layout and routing result. The active AP stills, the sampled romance CG, and many world backgrounds are 1280x800 raster masters, so QHD and 4K currently use filtered enlargement rather than native high-resolution art. Native-master review remains a separate image-production gate and must not be inferred from a successful 4K screenshot.

## Remaining Hardware Gates

- Steam Deck LCD/OLED: cold boot, 30-minute controller-only current `story_demo_rc` M01-M06 pass, suspend/resume, overlay, on-screen keyboard, and battery/performance sample.
- DualSense over USB and Bluetooth: glyph detection, confirm/cancel, vibration intensity, reconnect, and no duplicate input.
- Switch Pro through Steam Input: Nintendo face labels, confirm/cancel orientation, reconnect, and rules/secondary actions.
- Mouse drag-resize at arbitrary in-between window sizes, including repeated resize while a modal is open.
- 4K television overscan/readability from normal sofa distance.

Until these passes are signed, store copy may say "controller-friendly design in progress" internally, but the Steam full-controller badge remains held.

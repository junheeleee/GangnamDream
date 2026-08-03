# Input and Display Matrix

Updated: 2026-07-19

## Release Position

Gangnam Dream is designed around one semantic command model rather than literal focus traversal. Keyboard, mouse, and gamepad may present different labels, but they must reach the same decisions and never change simulation results.

The automated evidence below is sufficient for continued demo production. It is not yet sufficient to claim Steam "Full Controller Support": a physical Steam Deck/DualSense/Switch Pro blind pass, suspend/resume, and Steam overlay verification remain release-candidate gates.

## Input Contract

| Surface | Keyboard | Mouse | Xbox / Steam Deck | DualSense | Switch Pro | Evidence |
|---|---|---|---|---|---|---|
| Title to demo ending | PASS | PASS | Contract only | Contract only | Contract only | Real 24-week keyboard and mouse routes |
| VN choices | Arrows + Enter/Esc | Direct click | D-pad + South/East | D-pad + Cross/Circle | D-pad + B/A | StoryMode route and brand screenshots |
| AP decision | Arrows + Enter | Direct click | D-pad + A/B | D-pad + Cross/Circle | D-pad + B/A | One-screen decision board, no scroll |
| V2 monthly planner | Arrows, Enter, X, Q/E | Direct click | D-pad, A/X, LB/RB | D-pad, Cross/Square, L1/R1 | D-pad, B/Y, L/R | Four-week planner, review, immutable reopen |
| Portrait contact phone | P, arrows, Enter/Esc, Q/E | Direct click | Y, D-pad, A/B, LB/RB | Triangle, D-pad, Cross/Circle, L1/R1 | X, D-pad, B/A, L/R | Messages/Contacts only, modal focus restore |
| Story settings | F10/Esc | Settings button | Menu/B | Options/Circle | Plus/A | Text/language/audio/motion runtime gate, no scroll |
| Casino hub and direct games | Q/E, X, Y, Enter, Esc | Direct click | LB/RB, X/Y, A/B | L1/R1, Square/Triangle, Cross/Circle | L/R, Y/X, B/A | Nine scenes, 18 keyboard/gamepad secondary routes, nine keyboard core tasks |
| Vibration | N/A | N/A | API contract | API contract | API contract | Enable, strength, and bounded cue profiles; physical feel pending |

Physical-position names are canonical: South confirms, East cancels, West performs the contextual secondary action, and North opens details/rules. `ControllerHints` owns all visible labels. No game scene may hardcode Xbox letters.

The keyboard equivalent is equally semantic: `Enter` confirms, `Esc` backs out, `X` performs the contextual secondary action, `Y` opens rules/details, `Q/E` change groups, `F10` opens settings, and `N` advances a finished week. Keyboard input immediately replaces pad letters in visible hints.

Keyboard-only demo evidence:

```text
DEMO_INPUT_RUN_OK device=keyboard weeks=24 inputs=1101 events=59
start_job=unemployed end_job=job_01 axes=15/24
key_events=2206 mouse_events=0 cutoff=cta
```

Mouse-only demo evidence:

```text
DEMO_INPUT_RUN_OK device=mouse weeks=24 inputs=1035 events=59
start_job=unemployed end_job=job_01 axes=15/24
key_events=0 mouse_events=3111 cutoff=cta
```

The mouse run exposed a clipped month-summary progression button. The summary is now a single no-scroll surface and the demo CTA remains fully visible at 1280x800.

## Display Contract

| Output | Aspect | Automated render | Result | Notes |
|---|---:|---:|---|---|
| 960x600 | 16:10 | Settings, AP, Living Scene | PASS | Minimum free-window contract; functional layout, not a handheld readability target |
| 1280x720 | 16:9 | Settings, AP, Living Scene | PASS | Low-height reference; hardware spot pass still required |
| 1280x800 | 16:10 | Repeated demo and Steam Deck QA | PASS | Primary Deck reference |
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

Vibration is limited to meaningful commits and pressure beats. Ambient navigation, prose advance, hover, looping weather, and ordinary focus movement must remain silent and still.

## Automated Gates

`InputMatrixCheck.tscn` currently requires:

```text
INPUT_MATRIX_CHECK_OK modes=3 resolutions=8 brands=3
direct_scenes=9 direct_routes=18 keyboard_tasks=9 action_sets=4
```

The nine keyboard tasks do more than toggle a control: Blackjack deals, Baccarat places a Player bet and deals, Slots starts the reels, Roulette stages a bet and spins, Big Wheel selects and spins, Dai Sai selects and rolls, Holdem buys in and deals, RaceTrack selects a horse and starts the race, and the casino hub launches the highlighted table. The English 1080p Blackjack capture also verifies that keyboard hints replace gamepad letters and that the longest stake text fits the central betting spot.

`ScreenshotQA --qa=display-matrix` passes in both Korean and English at 960x600, 1280x720, 1280x800, 1600x900, 1920x1080, 2560x1440, 3440x1440, and 3840x2160. Each of the sixteen runs captures title settings, the demo AP decision, and a StoryMode choice, and verifies exact PNG dimensions, TV-safe controls, active keyboard/controller focus, and distortion-free background cover. The 1080p passes also capture Xbox, PlayStation, and Nintendo title hints in both languages.

This is a layout and routing result. The active AP stills, the sampled romance CG, and many world backgrounds are 1280x800 raster masters, so QHD and 4K currently use filtered enlargement rather than native high-resolution art. Native-master review remains a separate image-production gate and must not be inferred from a successful 4K screenshot.

## Remaining Hardware Gates

- Steam Deck LCD/OLED: cold boot, 30-minute controller-only demo, suspend/resume, overlay, on-screen keyboard, and battery/performance sample.
- DualSense over USB and Bluetooth: glyph detection, confirm/cancel, vibration intensity, reconnect, and no duplicate input.
- Switch Pro through Steam Input: Nintendo face labels, confirm/cancel orientation, reconnect, and rules/secondary actions.
- Mouse drag-resize at arbitrary in-between window sizes, including repeated resize while a modal is open.
- 4K television overscan/readability from normal sofa distance.

Until these passes are signed, store copy may say "controller-friendly design in progress" internally, but the Steam full-controller badge remains held.

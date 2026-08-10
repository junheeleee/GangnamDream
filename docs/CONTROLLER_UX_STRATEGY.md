# Controller UX Strategy

Updated: 2026-07-27

## Why This Exists

Gangnam Dream must treat controller support as a release gate, not a nice-to-have. A game can have strong content, visuals, and technical ambition, yet still lose player trust if the first hour feels like fighting the controls.

The warning case is Crimson Desert: public criticism repeatedly centered on over-complex inputs, unintuitive button combinations, basic actions sharing confusing bindings, and players having to think about the controller instead of the game. Gangnam Dream is not an action game, but the same failure mode applies to dense UI: if a Steam Deck player spends attention finding the right button instead of making a decision, the game feels unfinished.

## Core Principle

Do not make every visible button a controller destination.

Mouse UI can expose many clickable elements. Controller UI needs a smaller semantic input model:

- One highlighted decision at a time.
- One confirm button.
- One back/cancel button.
- Shoulder buttons for switching groups or tabs.
- Face buttons for clear secondary verbs only.
- No required multi-button chords for basic actions.

Focus routing is a fallback safety net. It is not the design.

## Global Controller Contract

| Input | Meaning |
|---|---|
| D-pad / Left stick | Move selection inside the current group |
| South / A | Confirm the highlighted choice |
| East / B | Back, close, or cancel pending bet |
| West / X | Adjust stake / quick secondary action where relevant |
| North / Y | Rules / details / inspect |
| LB / RB | Switch tab, group, or betting category |
| Menu / Start | System menu |
| R3 | Advance week only when AP is empty |

Keyboard uses the same semantic layer instead of pretending to be an Xbox pad: `Enter` confirms, `Esc` cancels, `X` is the contextual secondary action, `Y` opens details/rules, `Q/E` switch groups, `F10` opens settings, and `N` advances an empty week. Visible hints must switch with the last active device.

The same button should not mean different things on neighboring screens unless the screen title makes the mode unmistakable.

Button labels shown to the player must come from `ControllerHints`, not hardcoded `A/B/X/Y` strings. The design contract uses physical positions (`South`, `East`, `West`, `North`), but the UI must surface the connected brand: Xbox/Steam Deck `A/B/X/Y`, PlayStation `✕/○/□/△`, Nintendo `B/A/Y/X`.

## Acceptance Gates

Before demo/release candidate builds:

- A new player must be able to complete the first 15 minutes on controller without touching mouse or keyboard.
- No core screen may require navigating more than 12 focusable controller targets in a single uninterrupted rail.
- Core decision screens should not require vertical scrolling. Use compact rails, pages, tabs, or semantic cursors instead.
- Dense grids are allowed only in a dedicated cursor/grid mode, not as dozens of independent UI buttons mixed with other controls.
- Every screen must have a visible default focus within 0.5 seconds of appearing.
- Pressing `B` must never accidentally commit a destructive or irreversible action.
- `A` must always commit the highlighted thing, not trigger a hidden default elsewhere.
- Help/rules must be reachable without leaving the current screen.
- The player should never need to remember a hidden button chord to perform a basic action.

## Screen Models

### Core Loop V2 Monthly Planner / Contact Phone

Implementation status: the 24-week planner and communication phone use separate
focus contexts. The existing AP surface remains the post-V2 fallback until the
human GO.

- The full-width planner shows exactly four vertical week slots beside the
  current offers at 1280×800. At 960×600, reference surfaces may scroll
  vertically but the active decision and footer remain reachable.
- The planner has one visible workflow navigation layer: **Weeks n/4 → Weekly
  Activities n/2 → Final Review**. Those three names never change with state;
  only their count or status suffix changes. A fixed assignment counts toward
  n/4, but merely arming an offer does not. Confirmed records remain content
  inside Final Review rather than becoming a renamed navigation item. They keep
  their confirmed progress even when later state changes make an old offer
  unavailable; a historical record is not revalidated as a new plan.
- D-pad moves within offers or week slots; South assigns or confirms. West
  removes the selected non-fixed assignment. It never removes a locked week or
  commits the month. LB/RB and Q/E cycle only the three workflow steps.
- **Overview** and **People** are fixed information actions outside the workflow
  rail. D-pad Up reaches that header row and left/right moves only among visible
  neighbours. People shows lived relationship history without revealing an
  unmet character's name, affinity, route stage, or future requirement.
- Down enters every focusable reading card, routine choice, and valid footer in
  one continuous path; focus-follow scrolling exposes content below 960×600.
  Mouse hover grabs the same GUI focus used by keyboard and controller.
- The planner names its prefilled routines as recommended defaults and exposes
  Change without making the player discover a hidden setup step.
- Reading paths loop back to the visible action or workflow step that owns them
  unless a valid footer action exists. Hidden and disabled controls are omitted
  from every directional neighbour and focus-restoration path. Non-Week footer
  copy never advertises Week-only place/remove actions. When employed, primary
  Income is visibly fixed and duplicate secondary Income is disabled and also
  omitted from focus.
- Final confirmation stays disabled until the complete plan validates,
  including all four weeks and two valid, distinct weekly activities. The
  Final Review step remains readable, and its rail label states
  the exact actionable reason: remaining weeks or activities, invalid routine,
  required primary livelihood, missed deadline, overlapping meetings, active
  character cap, unavailable offer, changed fixed event, or duplicate booking.
  A disabled confirmation can never receive focus through D-pad, hover, Tab, or
  Shift-Tab.
- The first confirm opens the chosen/unchosen review; held/repeated input and an
  OS double-click edge are discarded, so only a fresh second confirm commits.
- The top Plan button reopens only the immutable confirmed month. East closes it
  and restores the prior gameplay focus.
- P or North opens a separate portrait communication drawer. Its LB/RB tabs are
  Messages / Contacts; South opens a thread or authored contact action; East
  moves thread → list → closed.
- The contact phone overlays rather than reflows the planner or game. While it is
  open, the underlying surface cannot receive input. Closing restores the exact
  control that opened it.
- Messages may route to an authored offer on the wide planner, but no phone
  action directly changes money, stats, relationship stage, or weekly progress.
### AP / Life Sim Screens

Use a vertical action rail.

Implementation status: retained as the week 9-240 fallback while Core Loop V2
is evaluated. Main AP rail first pass, slot numbering/keycaps, 1280x800
no-scroll, and cancelable AP/menu back behavior are complete in
`scenes/MainGame.gd`.

- D-pad up/down: move between action cards.
- A: choose action.
- R3: next week when AP is empty.
- LB/RB: info tabs only when an info panel is open.
- Menu: system.
- B: close cancelable menu modals such as category, investment, bank, job, shop, title collection, and glossary.
- The ordinary weekly AP screen must fit the week summary, pressure board, and four default action slots in one 1280x800 view without a visible scrollbar.

Top HUD buttons may remain clickable by mouse, but they should not pull controller focus away from the main rail during ordinary play.
Flow-protected modals such as demo records, final records, month summaries, warnings, and tendency popups should remain button-confirmed so B does not accidentally commit progression.

## Scroll Policy

Scroll is acceptable only for archive or reference surfaces: glossary, records, long rules, logs, collections, and dense read-only documentation. If the player is currently making a run-critical decision, the screen should prefer one of these patterns instead:

- Compact vertical action rail.
- Page stepper with clear page count.
- Shoulder-tabbed categories.
- Semantic cursor over a board/table.
- Short summary plus details on demand.

AP, casino tables, RaceTrack betting, and investment actions should not feel like scrolling a web page. If content exceeds the viewport, reduce the surface or split it into modes before allowing scroll.

### Visual Novel Choice Screens

Use a numbered vertical or short stacked choice rail.

- D-pad up/down: choice.
- A: confirm.
- B: skip/close only when safe; never auto-choose.
- The portrait shift on choice reveal is good and should remain because it clarifies the active decision layer.
- Holding South/A advances prose paragraphs only inside the current event. It must stop on the event's final paragraph and may never open or commit a choice, cross a chapter/result boundary, or enter the next event.
- While a gamepad is active, the continue hint advertises localized `Hold to read` only when another prose paragraph remains. It uses the physical South label for the active brand (`A`, `✕`, or `B`) and returns to plain `Advance` on the final paragraph so the UI never promises a protected-boundary crossing.
- A fresh South/A press is required after every protected boundary. Short press, AUTO, mouse, and the focused-choice button keep their existing meanings.
- A non-timed, non-chapter event with exactly one authored choice, when that choice is visible, is an action rather than a decision. Its actual localized action text replaces generic `Advance` on the final paragraph; one fresh South/Enter/click commits it without opening a one-item rail or shifting the portrait. AUTO and an accept held from earlier prose must stop before that commit.
- A real multi-choice event still opens the numbered rail and portrait shift. Do not collapse choices merely because one branch is recommended or safe.
- A direct follow-up marked `same_location` in `story_rules.json` retains the current visual breath: update title, portrait, direction, and audio ownership, but do not replay the full scene ink wipe or text-panel fade as if the player had entered a new room.

### Investment Modal

Implementation status: paged no-scroll pass complete in `scenes/MainGame.gd`.

Investment is a core loop, so the controller model should not make players visit every visible buy/sell button one by one.

- LB/RB: switch pages (`Trade`, `Holdings`, `Market`, `Bank`).
- D-pad up/down on Trade page: choose asset.
- D-pad left/right on Trade page: choose the current asset action.
- A: confirm the highlighted buy/sell action.
- B: close the modal.
- The Trade page should show a small asset window plus an asset cursor, not a long scroll stack of every visible asset.
- Holdings, Market, and Bank pages should fit in one 1280x800 modal view without requiring vertical scrolling.

Mouse players can still click individual buy/sell buttons. Controller users should experience the screen as asset selection plus an action rail.

### Casino Hub

Use a venue list, not free-floating small buttons.

Implementation status: first pass complete in `scenes/JeongseonCasino.gd`.

- D-pad up/down: venue.
- A: enter.
- B: leave casino.
- Y: rules/explanation.
- X: glossary.

### Blackjack / Holdem

Use an action rail.

- Primary actions: Hit/Stand/Call/Raise/Fold.
- Stake/raise amount should be adjusted by X/Y or LB/RB, not selected from many small chip buttons unless in a dedicated stake mode.
- A commits current highlighted action.
- B cancels a pending raise/bet, then exits only if nothing is pending.

### Blackjack

Implementation status: first pass complete in `scenes/BlackjackTable.gd`.

Blackjack should read as one table decision, not a web form with five buttons.

- Betting phase: A deals, X/LB/RB cycles stake, Y opens rules, B exits.
- Player turn: D-pad or LB/RB/X moves the action rail across Hit / Stand / Double / Split.
- A confirms the highlighted action.
- Result phase: A starts the next hand, Y opens rules, B exits.

Double and Split stay visible for mouse readability, but the controller rail only lands on them when they are legal.

### Holdem

Implementation status: first pass complete in `scenes/HoldemClub.gd`.

Holdem has higher accident risk than other casino screens because the wrong confirm can fold or shove.

- Buy-in phase: A starts, X/LB/RB cycles buy-in, Y opens rules, B leaves.
- Player turn: D-pad or LB/RB/X moves the action rail across legal actions only.
- A confirms the highlighted action.
- B leaves the seat/session rather than landing on a small Leave button in the same rail.
- New action turns default to Check/Call rather than Fold.

Mouse buttons can still show the full action set, but controller focus must prioritize safe repeat play over literal button order.

### Baccarat

Use betting zones, not five independent card-like buttons plus chip buttons as the main controller path.

Implementation status: first pass complete in `scenes/BaccaratTable.gd`.

- D-pad left/right: Player / Banker / Tie.
- D-pad up/down or LB/RB: side bets.
- X: cycle stake.
- A: place chip on highlighted zone; on the Deal target, start the round.
- Y: rules.
- B: clear current bets, then exit if no bet is pending.

### Dai Sai

Dai Sai must not expose all 40+ bets as a flat controller rail.

Implementation status: first pass complete in `scenes/DaiSaiTable.gd`.

Use three betting modes:

1. Simple: Big, Small, Odd, Even, Any Triple.
2. Face: choose die face 1-6, then Single/Pair/Triple with LB/RB or X.
3. Total: choose total 4-17 in a compact grid/cursor mode.

Controller flow:

- LB/RB: switch Simple / Face / Total.
- D-pad: move within the current mode.
- X: cycle stake.
- A: select/place the highlighted bet; press A again on the active bet to roll.
- Y: rules.
- B: clear pending bet or exit.

The current many-button layout can remain for mouse, but controller mode should collapse it into this semantic model.

### Roulette

Roulette needs a cursor/mode design, not raw focus over every number plus every outside bet.

Implementation status: first pass complete in `scenes/RouletteTable.gd`.

Recommended model:

- Mode 1: Outside bets (Red/Black/Odd/Even/Low/High/Dozens).
- Mode 2: Number board cursor.
- Mode 3: Action target (BET/SPIN).
- LB/RB: switch modes.
- D-pad: move cursor in current mode.
- X: cycle stake.
- A: place chip or spin on the active action target.
- B: clear last chip / back.
- Y: rules/payouts.

The number board can be dense only because it is a recognizable grid mode with cursor movement, not mixed with unrelated buttons.

### Slots

Implementation status: first pass complete in `scenes/SlotMachineGame.gd`.

Slots should be the simplest controller experience in the game.

- A: Spin.
- X or LB/RB: cycle stake.
- Y: rules.
- B: exit.

If slots need more than this, the slot UI is overdesigned.

### Big Wheel

Implementation status: first pass complete in `scenes/BigWheelGame.gd`.

Big Wheel should feel like choosing a wedge and pulling the lever.

- LB/RB or D-pad left/right: move segment cursor.
- D-pad down: move to `SPIN`.
- D-pad up: return to segment cursor.
- A: select the segment; when `SPIN` is active, spin.
- X: cycle stake.
- Y: rules.
- B: clear the selected segment, then exit if nothing is selected.

After selecting a segment with A, the target moves to `SPIN` so the main rhythm is `A -> A`: choose, then spin.

### RaceTrack

Implementation status: first pass complete in `scenes/RaceTrack.gd`.

RaceTrack should read as a betting slip, not a long web list with chip buttons.

- D-pad up/down: choose horse.
- D-pad left/right or LB/RB: change bet type.
- X: cycle stake.
- A: pick the highlighted horse; once enough horses are picked, place the bet.
- Y: rules.
- B: remove the last pick, then exit if no pick is pending.
- Result phase: A starts the next race, B exits.

The horse list may remain scrollable/clickable for mouse, but controller mode must keep one visible horse cursor plus one visible bet/stake target.

## Implementation Order

1. Core Loop V2 month planner and portrait contact phone: separate focus
   contexts, four-week semantic schedule, cancellation, and human ownership GO.
   ✅ 24-week automated contract complete; physical Deck pass pending
2. AP and VN fallback: lock main rail behavior and default focus.
3. Slots and Blackjack: simple action rail first. ✅ first pass complete
4. Dai Sai: replace flat controller traversal with Simple/Face/Total mode model. ✅ first pass complete
5. Baccarat: betting-zone selector. ✅ first pass complete
6. Roulette: outside/number/action cursor. ✅ first pass complete
7. Big Wheel: segment cursor plus spin target. ✅ first pass complete
8. Holdem: action rail plus safe default action. ✅ first pass complete
9. Casino hub: unified venue list and rules access. ✅ first pass complete
10. RaceTrack: horse cursor plus betting slip flow. ✅ first pass complete
11. Investment modal: asset cursor plus trade-action rail. ✅ first pass complete

## QA Method

Run targeted screenshot QA for visuals, but controller UX also needs manual blind passes:

1. Start with hands on controller only.
2. Enter the target screen.
3. Without reading code or using mouse, complete the core action once.
4. Count mis-presses, wrong focus jumps, and moments of uncertainty.
5. Any confusion in the first attempt is a design bug unless the game intentionally teaches it on-screen.

For casino, each minigame must pass:

- Change stake.
- Place a valid bet.
- Read the current bet.
- Start the round.
- Read win/loss result.
- Repeat or exit.

All on controller only.

## Current Automated Evidence

`InputMatrixCheck.tscn` executes the shared West/North secondary routes for the casino hub, Blackjack, Baccarat, Slots, Roulette, Big Wheel, Dai Sai, Holdem, and RaceTrack in both keyboard and gamepad modes. It also drives nine keyboard core tasks through real input dispatch, from stake selection to starting the actual hand, spin, roll, race, or selected casino table. This prevents a keyboard-only command from being documented but unreachable, and prevents gamepad labels from drifting away from their physical action.

The title-to-demo route has completed all 24 weeks with actual keyboard events and zero mouse events, then with actual mouse events and zero keyboard events. Sixteen Korean/English display-matrix renders cover eight release resolutions, and each language has Xbox, PlayStation, and Nintendo title-glyph evidence at 1080p. The exact contract and remaining physical-device gates are recorded in `docs/INPUT_MATRIX.md`.

`CoreLoopV2Check.tscn` verifies explicit activation, the fixed three-step
workflow rail and information actions, four-slot scheduling, the fixed fourth
week, first-legal-empty-week focus, raw D-pad-only placement, East cancellation,
West removal only on the week card that owns focus, disabled-focus exclusion,
and a release-gated final review that starts on the safe Edit action. It also
covers save/load, delayed consequences across a month boundary, one consequence
per week, player-initiated relationship state, and zero hidden-score or Korean
leakage on the English planner.
`CommunicationPhoneCheck.tscn` separately verifies portrait bounds, message and
contact filtering, thread navigation, offer routing, and focus isolation.
`ScreenshotQA --qa=core-loop-v2 --lang=ko/en` boots the real `MainGame`, opens
the planner and contact phone through their runtime handoff, and captures both
at 1280×800 and 960×600.

These automated passes prove routing and presentation, not hand feel. Full Controller Support remains blocked on physical Steam Deck, DualSense, and Switch Pro blind passes, including reconnect, suspend/resume, Steam overlay, and accidental-input review.

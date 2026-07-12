# Wardrobe And Season Audit

Updated: 2026-07-12

## Current Verdict

The game does not yet provide four-season wardrobe coverage for every character. Runtime portrait selection is partly scene-specific and partly state-based. Fifty-four high-risk event surfaces are now locked by `assets/event_visual_contracts.json`, and the current strict background/staging debt gate is zero. This closes the audited high-risk queue without pretending every generic cast outfit has four seasonal variants.

## Contract

- Clothing follows scene reality, not the calendar alone: indoor/outdoor, work/off-duty, weather, travel continuity, and prose all matter.
- A uniform inside a convenience store or office may remain stable across seasons.
- Fixed outerwear in an outdoor or doorway scene must have an allowed-month trigger or a same-identity seasonal variant.
- A CG and its event portrait share one outfit unless the prose explicitly shows a change.
- A story that misses its suitable month defers to the next suitable month instead of disappearing.

## Coverage Matrix

| Character / surface | Current selection | Seasonal status | Required follow-up |
|---|---|---|---|
| Kim Minjun general portrait | Job, housing/wealth, emotion, explicit climate events, and off-duty neutral override | Climate P0 and audited weather reuse complete; generic exterior inventory remains | Heatwave/monsoon/cold-snap and all four year closes now have month-locked clothing |
| Kim Minjun romance CG | Off-duty black crewneck/jacket | Scene-locked | Continue pairing every new CG with explicit weather and outfit text |
| Kim Daeun default | Convenience-store polo + cardigan | Valid for work interior; not universal outdoors | Do not reuse for unrelated summer/winter exterior scenes |
| Kim Daeun spring/sea/fireworks | Dedicated portrait + CG | Complete for April, July-August, September-October | Maintain existing month gates |
| Kim Daeun Namsan/amusement | Dedicated mild-weather outfit | Complete for March-May, September-November | Runtime deferral is tested |
| Kim Daeun hometown | One summer outfit across train/home/bus | Complete for June-August entry | Runtime deferral and delayed bus CG are tested |
| Kim Daeun first night/morning | Mauve indoor lounge outfit across portrait/CG | Complete, indoor all-season | Dedicated small newlywed home and paragraph-1 morning reveal are tested |
| Kim Daeun first snow | Cranberry quilted coat + oatmeal scarf outside the store | Complete for December | Person-free exterior prelude, two-can CG, delayed reveal, and December routing are tested |
| Han Jiyeon default | Cream tailored jacket + black inner | Valid for office/vehicle interiors; not universal outdoors | Avoid using as generic all-season exterior wear |
| Han Jiyeon spring/sea/fireworks | Dedicated portrait + CG | Complete for April, July-August, September-October | Maintain existing month gates |
| Han Jiyeon Namsan/amusement | Dedicated mild-weather outfit | Complete for March-May, September-November | Runtime deferral is tested |
| Han Jiyeon Narrow Room | Long coat at door, oxblood top indoors | Complete for January-April, October-December entry | Runtime deferral is tested |
| Han Jiyeon first night/morning | Midnight-blue indoor lounge outfit across portrait/CG | Complete, indoor all-season | Dedicated high-rise home, bare-face continuity, and paragraph-1 morning reveal are tested |
| Han Jiyeon first snow | Charcoal tailored coat + garnet knit inside her sedan | Complete for December | Left-hand-drive seating, resting wipers, mutual gaze, delayed reveal, and December routing are tested |
| Hyunsu, Sangchul, cafe investor, Manager Kim, Father, Jaehyuk, Seongjun, Minseo, minor recurring cast | Primary outfit plus Hyunsu accounting/civil-service stages | Mostly season-neutral indoor use; Hyunsu's time passage and both cafe identities are state/scene-locked | Current high-risk bus-stop/cultural staging and recurring cafe identity gates are complete |

## Locked Event Surfaces

- Weather reuse: heatwave, monsoon, cold snap, rainy commute, rainy delivery memory, and winter street food now use explicit backgrounds/portraits and allowed months where the clothing is seasonal.
- Indoor/outdoor routing: rainy-night introspection and father-medication calls stay in Minjun's goshiwon; Sangchul's network scene uses its Gangnam private dining room; Daeun's test and broker meetings use the cafe; phone research uses the investment-phone still.
- Year close: Year 1 uses the canonical off-duty goshiwon frame. Years 2-4 use the same cold-weather Minjun continuity with dedicated December night street, bare winter Han River, and laundry-free winter rooftop backgrounds.
- Hyunsu passage: the late-night call retains his exam-prep hoodie, the goodbye result moves to a physically coherent intercity terminal, and Year 4/5 callbacks select accounting-firm or civil-service clothing from the known route flag.
- Cafe identity: the unnamed folder owner and Manager Kim use separate silhouettes, names, props, and callback ownership. The old office-team-lead stand-in is removed, and the folder owner appears only after his paragraph reveal.
- Cultural staging: the wallet event owns a road-facing Seoul bus shelter with a visible wallet; the bungeoppang event owns a winter cart with readable food hardware; Seollal owns a four-person bow CG in the canonical Changwon home with no reunited mother.
- Identity safety: a missing portrait is visible production debt; a wrong recurring identity is a continuity error.
- `python3 tools/event_visual_contract_check.py` is part of `tools/audit.sh`. `--strict` now passes and will fail again if a future acknowledged debt row is added.

## Known Production Debt

None in the current high-risk event visual contract. New events can create new debt and must not bypass the manifest.

## Next Production Order

1. Move to proposal, wedding, and ending scene contracts; do not turn those climax outfits into generic calendar swaps.
2. Re-run the machine contract plus `--qa=event-visuals --lang=ko/en` whenever a locked surface changes.
3. Add a debt row immediately when a new event knowingly ships with mismatched background, staging, or wardrobe; strict mode must remain the completion claim.

## Completion Gate

Four-season wardrobe coverage may be called complete only when every explicit outdoor/weather event has one of:

- a matching dedicated portrait/CG and an allowed-month trigger;
- a clearly season-neutral layered outfit justified by the prose; or
- intentional background-only staging with no contradictory visible clothing.

The current audited high-risk inventory satisfies this gate: `python3 tools/event_visual_contract_check.py --strict` exits zero. This statement does not claim that every possible generic cast/calendar combination has bespoke art.

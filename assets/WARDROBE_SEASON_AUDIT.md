# Wardrobe And Season Audit

Updated: 2026-07-12

## Current Verdict

The game does not yet provide four-season wardrobe coverage for every character. Runtime portrait selection is partly scene-specific and partly state-based. Thirty-seven high-risk event surfaces are now locked by `assets/event_visual_contracts.json`; eleven acknowledged background, portrait, or staging debts remain. This document prevents partial coverage from being reported as complete.

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
| Hyunsu, Sangchul, Father, Jaehyuk, Seongjun, Minseo, minor recurring cast | One primary outfit each | Mostly season-neutral indoor use; explicit debt now inventoried | Employed Hyunsu, cafe broker, and transit scenes remain in the strict debt gate |

## Locked Event Surfaces

- Weather reuse: heatwave, monsoon, cold snap, rainy commute, rainy delivery memory, and winter street food now use explicit backgrounds/portraits and allowed months where the clothing is seasonal.
- Indoor/outdoor routing: rainy-night introspection and father-medication calls stay in Minjun's goshiwon; Sangchul's network scene uses a restaurant; Daeun's test and broker meetings use the cafe; phone research uses the investment-phone still.
- Year close: Year 1 uses the canonical off-duty goshiwon frame. Years 2-4 use the same cold-weather Minjun continuity with dedicated December night street, bare winter Han River, and laundry-free winter rooftop backgrounds.
- Identity safety: cafe broker events hide the old office-team-lead stand-in until a dedicated portrait exists. A missing portrait is visible production debt; a wrong recurring identity is a continuity error.
- `python3 tools/event_visual_contract_check.py` is part of `tools/audit.sh`. `--strict` intentionally fails while any acknowledged row remains.

## Known Production Debt

1. Upscale private Gangnam networking room for `arc_sangchul_03_network`.
2. Physically correct Seoul bus-stop background for `amb_wallet_00`.
3. Bus-terminal departure/result visual for `arc_y2_hyunsu_night_bus`.
4. Employed Hyunsu suit/business-card and civil-service badge variants for two later callbacks.
5. Dedicated cafe broker portrait for four callback events.
6. Visible winter bungeoppang cart for `kx_street_food`.
7. Seollal family gathering/bowing visual for `kx_seollal_sebae`.

## Next Production Order

1. Clear the eleven remaining strict debt rows in emotional order: Sangchul's private room, Hyunsu terminal/employment, cafe broker, bus stop, then cultural ambient scenes.
2. Re-run the machine contract plus `--qa=event-visuals --lang=ko/en` whenever a debt row is replaced.
3. First-morning and first-snow outfits are complete scene contracts; proposal, wedding, and ending outfits remain scene contracts rather than generic season variants.

## Completion Gate

Four-season wardrobe coverage may be called complete only when every explicit outdoor/weather event has one of:

- a matching dedicated portrait/CG and an allowed-month trigger;
- a clearly season-neutral layered outfit justified by the prose; or
- intentional background-only staging with no contradictory visible clothing.

Completion also requires `python3 tools/event_visual_contract_check.py --strict` to exit zero. The normal release audit may acknowledge scheduled art debt, but it cannot be used to claim the inventory complete.

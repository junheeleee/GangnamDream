# Gangnam Dream Commitment Visual Bible

This document owns the visual continuity for proposal and wedding-choice scenes. It does not add a new romance beat or alter the authored relationship outcome.

## Shared Rules

- Use Gangnam Ink: Korean adult faces, restrained manhwa/VN rendering, matte paper grain, readable limited color, and deliberate Japanese visual-novel staging. No DSLR realism, mobile-game gloss, text, logos, or fake signage.
- Minjun remains the same 33-37-year-old Korean man as `main_character_unemployed.png`: lean face, short tousled black hair, and worn black off-duty crewneck unless the scene explicitly requires formalwear.
- Daeun remains the same 33-year-old Korean woman as `npc_daeun_smile.png`: short layered dark-brown hair, small clip at her left temple, warm brown eyes, modest adult styling. Never lengthen her hair or turn her into Jiyeon's glamorous silhouette.
- Jiyeon remains the same 31-year-old Korean woman as `npc_mentor.png`: long black waves, sharp almond eyes, controlled old-money styling, and restrained geometric jewelry.
- Named characters look at each other or the scene object. They do not address the lens unless the prose explicitly makes Minjun's POV the person being watched.
- Keep faces, hands, the ring box, aisle imbalance, and seating chart above the lower 34% StoryMode dialogue/choice safe area.
- Moral Tint is applied at runtime. Do not bake a brown/sepia moral grade into the source art.

## Daeun Proposal

### Prelude Portrait

- Asset: `assets/characters/npc_daeun_proposal.png`.
- Outfit: deep muted berry-red fine-knit date dress with a modest square neckline and a soft charcoal cropped cardigan. This is a deliberate late-game date outfit, not her navy convenience-store uniform, first-night mauve lounge set, or bridal dress.
- Acting: quiet unguarded smile toward screen-left, unaware of the ring; shoulders relaxed, hands outside the crop. Same short hair and left-temple clip.

### Accepted Proposal CG

- Asset: `assets/cg/romance/proposal_daeun_v1.png`.
- Timing: choice 0 result only, revealed after result paragraph 0. Never show it before the player takes out the box, and never show it for the delayed-proposal choice.
- Location: the same rainy Seoul cafe language as `cafe_seoul.png`: wooden table, street-facing rain window, warm pendant, espresso counter at frame-left.
- Camera: Minjun's restrained over-shoulder position. His black crewneck shoulder/forearm may frame the lower-left, but Daeun is the clear subject.
- Action: one open ring box sits on the table; Daeun covers her mouth with one anatomically clear hand as her eyes redden. Her other hand rests naturally on the table. She looks at Minjun, not the ring and not the lens.
- Avoid: ring already on her finger, kneeling pose unsupported by the prose, duplicated hands, exaggerated idol tears, wedding dress, or generic luxury restaurant.

## Daeun Wedding Day

The wedding-prep choice must survive into the wedding-day image. Both variants share Daeun and Minjun identity, aisle direction, and the social cost in the seating.

### Invariant Staging

- Korean ceremony order is explicit: Minjun has already entered first and waits at the altar; Daeun enters afterward and walks from the rear doors toward him. The rear entrance, never an altar or podium, is visible behind Daeun.
- Camera is behind/three-quarter behind Minjun at the altar and looks outward toward the entrance. Daeun approaches the camera and Minjun without lens contact.
- Screen-left groom side is sparse; screen-right bride side is visibly fuller. The imbalance must read in one second without labels.
- Guests remain anonymous and distant. Do not identify Father, Hyunsu, Daeun's mother, or any deceased/conditional person; those variants stay in prose and may contradict a baked guest face.
- Daeun looks toward Minjun with contained emotion and a natural adult expression. Minjun's posture is tense but waiting, not defeated or staring at the lens.
- Do not place critical guests in the lower dialogue-safe zone.

### Small Wedding

- Asset: `assets/cg/romance/wedding_daeun_small_v1.png`.
- Venue: modest, physically plausible small Seoul wedding hall with simple chairs, restrained white/green flowers, low ceiling, and practical aisle.
- Daeun: simple ivory A-line dress, minimal short veil, small lisianthus/greenery bouquet, natural makeup, same short hair and clip identity.
- Minjun: clean charcoal suit with a plain dark tie. No luxury tuxedo styling.

### Full-Package Wedding

- Asset: `assets/cg/romance/wedding_daeun_full_v1.png`.
- Venue: polished full-package Seoul wedding hall with refined wall lighting and more elaborate but coherent aisle flowers. It stays spatially comparable to the modest hall so the social imbalance, not sheer room size, remains the focal difference.
- Daeun: refined ivory satin A-line gown with restrained beaded bodice and longer veil; professional makeup must not change her face or age.
- Minjun: fitted charcoal formal suit. The image may look expensive, but groom-side emptiness remains visible.

## Jiyeon Wedding Gap

- Asset: `assets/cg/romance/wedding_gap_jiyeon_v1.png`.
- This is the pre-decision class negotiation, not a proposal and not the completed ceremony. Do not put Jiyeon in a bridal gown or show the choice outcome.
- Location: an empty/prepared five-star Seoul hotel grand ballroom with a long central aisle, restrained chandeliers, formal round tables, and a seating-plan table. No hotel brand or readable guest names.
- Jiyeon: tailored ivory planning suit over a black silk inner layer, long black hair, geometric earrings. She stands beside Minjun but watches her father with controlled tension.
- Minjun: inexpensive charcoal suit, visibly less polished but properly fitted; he looks toward the father or the blank groom-side list.
- Father-in-law: older Korean man in a dark navy luxury suit, seen only from back/three-quarter side so he cannot become a reusable named portrait. His stance applies pressure without theatrical villain posing.
- Composition: an elegant, potentially full bride-side plan contrasts with a sparse groom-side list/empty chairs. The choice is whether Minjun borrows to match the world or refuses it; the image must not decide for him.

## Runtime Contract

- `arc_daeun_proposal` → `arc_daeun_proposal_last_cup` → `arc_daeun_proposal_answer`: all buildup frames retain the cafe background and proposal portrait. Only the final event's accepted choice owns `cg_romance_proposal_daeun`, revealed at result paragraph 1; the defer branch never reveals it.
- `arc_daeun_wedding_prep`: choice 0 records `daeun_wedding_small`; choice 1 records `daeun_wedding_full`.
- `arc_daeun_wedding_day` → `arc_daeun_wedding_walk` → `arc_daeun_wedding_aisle`: all three aisle frames retain the same ceremony variant. The default is the small CG for legacy saves; every link's `cg_if_known` selects the explicit small/full variant. Only the final aisle event may set `arc_daeun_wedding_day_seen`.
- `arc_jiyeon_wedding_gap`: dedicated pre-decision full-scene CG.
- All four CG files require active actor/camera/gaze/body contracts and Korean/English 1280x800 intro/choice/result captures where applicable.

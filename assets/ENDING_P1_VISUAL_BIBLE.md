# Gangnam Dream P1 Ending Visual Bible

This document owns the release-tier P1 ending CGs added after the eight-image P0 final-life package. Each image depicts the ending's shared physical truth across every `description_if_known` variant. It never bakes a conditional person, confession, or route fact into the frame.

## Shared Contract

- Runtime source: 1280x800 PNG, restrained-color Gangnam Ink VN climax layer.
- Every ending owns a distinct CG key and file. No event, romance, or other ending may borrow it.
- The centered 950x430 ending preview must retain the face, gaze, decisive hand, and story prop.
- Conditional characters remain voice-only or outside the frame unless every prose variant guarantees their physical presence.
- No readable UI, route sign, ticket, legal text, brand, logo, watermark, or invented ending fact.
- Runtime Moral Tint may damage color and print surface but cannot erase the decisive action.

## `cg_ending_late_call`

- File: `assets/cg/ending_late_call_v1.png`.
- Owner: `late_call` only.
- Shared moment: on a KTX bound for Changwon, Minjun has heard Father's voice and presses the phone closer after removing an earbud. Father is voice-only.
- Camera: medium-wide aisle-side three-quarter. Minjun occupies the screen-center window seat; the rain-streaked window and moving Korean winter landscape fill screen-right. The forward-facing two-seat row, armrests, aisle, overhead rack, and window alignment must remain physically coherent.
- Identity: 38-year-old Minjun retains the canonical lean face, short messy black hair, tired eyes, and hollow cheeks. He wears a plain charcoal travel coat over the worn black crewneck, never a corporate suit or success costume.
- Acting: right hand holds one unbranded phone to the right ear. Raised left hand holds exactly one removed earbud; one case rests on the lap. His eyes stay on the rain, mouth barely released, shoulders easing without a broad smile or collapse.
- Variant lock: Sangchul and Jaehyuk are memories only. No Father, scammer, partner, romance heroine, gukbap bowl, Gangnam apartment, or station platform appears.
- Avoid: subway bench, luxury first class, Japanese rail styling, readable route display, repeated phone/earbud/case, malformed hands, lens gaze, funeral mood, or triumphant arrival.

## `cg_ending_lonely_rich`

- File: `assets/cg/ending_lonely_rich_v1.png`.
- Owner: `lonely_rich` only. It must never replace `empty_house`, whose physical story is Father's death, two unused cups, deed/envelope, and a collapsed sofa posture.
- Shared moment: after reaching the three-billion-won Gangnam target, Minjun receives one single-person delivery and sits alone at a table for four. The meal, three empty chairs, and city view carry every base, divorce, one-billion-warning, and calculated-singlehood variant.
- Camera: quiet kitchen-side room-wide three-quarter. The rectangular dining table runs across the middle; Minjun occupies one end inside the central crop, exactly three empty chairs remain readable, and the Gangnam night window establishes the apartment without turning into a skyline poster.
- Identity: canonical 38-year-old Minjun, lean Korean face, short messy black hair, tired narrow eyes, hollow cheeks. Home clothes are a plain charcoal knit over a muted gray crewneck and dark trousers, never a suit, casino costume, coat, or wedding outfit.
- Acting: Minjun's torso stays upright but drained. One hand rests beside a single plain paper delivery bag; the other has just turned one unbranded phone face-down. His eyes settle on the nearest empty chair, not the phone, food, skyline, or lens.
- Prop count: one delivery bag, at most one plain single-person container, one phone, four chairs total with Minjun using one. No second meal, paired cups, extra place setting, envelope, deed, keys, flowers, moving box, or readable app/order slip.
- Variant lock: Daeun, Father, both mothers, Sangchul, Jaehyuk, and any date remain outside the frame. The divorce seal and unsigned registration are memories in prose, not documents repeated in this final-life image.
- Avoid: reusing the `empty_house` sofa composition, funeral staging, hunched grief collapse, triumphant wealth pose, luxury-ad glamour, lens gaze, visible brand, fake Korean text, delivery worker, malformed hand, or duplicate phone.

## Acceptance Gate

- `ImageRegistry`, Korean ending data, `cg_acting_manifest.json`, and `CGRuntimeCheck` agree on the owner and path.
- The English ending remains a text-only overlay and inherits the Korean CG key.
- `ScreenshotQA --qa=ending-p1 --lang=ko/en` proves each exact texture and 430px crop, including `late_call`'s `jaehyuk_trusted_fully` variant and `lonely_rich`'s divorce variant.
- Event visual contracts prove that `ktx_window` resolves to an actual train interior, while the holiday decision retains the separate provincial station platform.

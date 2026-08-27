# Chapter 5 Meeting Visual Bible

Updated: 2026-08-27

## Owner and Use

`cg_y5_three_in_room` is the one-off M55 visual for
`arc_y5_three_in_room → arc_y5_three_in_room_decision`. It is not a reusable
office background, an ending image, or proof that any contract was signed.
`arc_y5_room_consent_receipt` returns to the meeting background without a
reusable portrait after the four-person confrontation. Daeun remains physically
present through her handwritten boundary, spoken instruction, and handling of
the clear clip; the default convenience-store portrait must not float over this
meeting, and no separate meeting-attire portrait is registered for reuse.

## Canon Frame

- Time and place: late night in a modest glass-walled Seoul meeting room.
- Exactly four named adults appear: 37–38-year-old Minjun, 37–38-year-old Daeun,
  38–39-year-old Jaehyuk, and 56–57-year-old Sangchul.
- Minjun is the near rear-three-quarter anchor. Daeun looks at him from the
  right; Jaehyuk holds the far center; Sangchul holds the far left. Nobody looks
  at the lens.
- The documents remain physically separate: Sangchul's proposal and laid-down
  red pen, Jaehyuk's guarantee PDF, Daeun's unsigned copy and detached cup
  sleeve, and one calculator only in front of Minjun.
- No signature, handshake, money pile, readable amount, approval mark, or
  celebratory posture may pre-empt the player's decision.

## Identity and Acting Locks

- Minjun: lean face and slim navy corporate suit; guarded shoulders, not luxury
  polish.
- Daeun: short black bob, left-temple clip, a soft charcoal unbranded jacket
  over a muted blue-gray blouse; inexpensive matte cloth rather than executive
  tailoring. She is dressed as an equal consent party for this late-night
  meeting, not in her convenience-store uniform, romance wardrobe, or luxury
  businesswear; upright and direct, never pleading or glamorous.
- Jaehyuk: swept black hair, narrow polished face, black suit, controlled
  exhaustion; not Sangchul's age and not a theatrical villain.
- Sangchul: salt-and-pepper hair, weathered broker face, practical dark suit;
  grounded rather than frail or triumphant.
- Every visible hand must be anatomically coherent. Documents, pen, sleeve,
  cups, calculator, chairs, table, glass door, and clock must remain physically
  usable at the 1280×800 crop.

## Surface and Crop

Gangnam Ink owns the finish: desaturated Korean VN/manhwa realism, concrete gray
and charcoal, matte paper grain, restrained fluorescent night light, no glossy
mobile-game color and no photoreal stock-photo surface. The lower dialogue dock
may cover Minjun's lower back and the near table, but it must not cover any face,
gaze line, the separate document ownership, or the laid-down red pen.

## Production Record

- Mode: OpenAI built-in ImageGen, reference-guided generation followed by one
  identity-preserving wardrobe correction.
- Identity references: `main_character_corporate_y5.png`,
  `npc_daeun_normal_y5.png`, `npc_jaehyuk_shadow_y5.png`,
  `npc_sangchul_serious_y5.png`.
- Style reference: `assets/cg/jaehyuk_reveal.png`.
- Original generated source:
  `$CODEX_HOME/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-b795aa6d-a371-4e74-a13d-5ccd41f84815.png`.
- Wardrobe-corrected source:
  `$CODEX_HOME/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-714436d2-4463-4b19-b8d0-3373afca4190.png`.
- Release image: near-exact 16:10 source resized to 1280×800 at
  `assets/cg/y5_three_in_room_v2.png`.
- Release SHA-256: `d18a9c38300eb33f18a87c79f7fe05f8f9e1015cda55907a9b4390625e862d9c`.
- `assets/cg/y5_three_in_room_v1.png` remains an inactive provenance copy. It is
  not registered because its default convenience-store uniform implies an
  unsupported straight-from-shift arrival and visually weakens Daeun's equal
  standing in the room.

The final prompt specified the four reference identities in fixed order, the
observational ensemble blocking, separate proposal/PDF/unsigned copy, laid-down
red pen, detached cup sleeve, one calculator, four plain cups, dialogue-safe
crop, natural hands, no readable text or signatures, and the Gangnam Ink
social-reality surface. The corrective prompt changed only Daeun's clothing to
ordinary serious meeting attire and explicitly locked all identities, poses,
gazes, documents, props, lighting, and framing.

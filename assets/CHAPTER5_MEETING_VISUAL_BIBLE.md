# Chapter 5 Meeting Visual Bible

Updated: 2026-08-26

## Owner and Use

`cg_y5_three_in_room` is the one-off M55 visual for
`arc_y5_three_in_room → arc_y5_three_in_room_decision`. It is not a reusable
office background, an ending image, or proof that any contract was signed.
`arc_y5_room_consent_receipt` returns to the meeting background and Daeun's
portrait because the four-person confrontation has ended.

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
- Daeun: short black bob, left-temple clip, practical navy-and-beige clothes;
  upright and direct, never pleading or glamorous.
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

- Mode: OpenAI built-in ImageGen, reference-guided generation.
- Identity references: `main_character_corporate_y5.png`,
  `npc_daeun_normal_y5.png`, `npc_jaehyuk_shadow_y5.png`,
  `npc_sangchul_serious_y5.png`.
- Style reference: `assets/cg/jaehyuk_reveal.png`.
- Generated source:
  `$CODEX_HOME/generated_images/019fabe6-f383-7b53-a060-7220e3ce36f4/exec-b795aa6d-a371-4e74-a13d-5ccd41f84815.png`.
- Release crop: centered to 16:10 and resized to 1280×800 at
  `assets/cg/y5_three_in_room_v1.png`.
- Release SHA-256: `e75878140ac0fe3233149b630f9085370f89f37fc42dd0b71e0f5cb276c525a0`.

The final prompt specified the four reference identities in fixed order, the
observational ensemble blocking, separate proposal/PDF/unsigned copy, laid-down
red pen, detached cup sleeve, one calculator, four plain cups, dialogue-safe
crop, natural hands, no readable text or signatures, and the Gangnam Ink
social-reality surface.

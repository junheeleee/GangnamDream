# ORDER-785 — Localized mastery names in the ending

**GO** for the source connection in candidate `f962b17e69b8cb384a9833aab6da8b69d50bf09c`, tree `34e484b2b03e8c04aa48f5d3df43959067869e4c`. Baseline `e68d36244f685d144f929a0ad58712b61c8f3ad3`. No new translation values were accepted.

I traced the ending collection page into `_ending_add_unlocks` and checked the four minigame play producers, mastery thresholds and grade labels. The extracted helper preserves exactly the progress card's existing names. Only the JA/zh-CN/zh-TW ending name slot uses those names; other languages retain their original internal IDs. Grade eligibility, labels, order and list formatting do not change, nor do acquisition, settlement or saving. The independent inverse restores the previous MainGame source byte for byte. All 12 existing dictionary values, the acceptance ledger, public demo and producer files are unchanged.

The static contract, final context/delta marker, JA, demo and EN logs are clean. The initial CLAUDE budget failure (18,009 against 18,000) is retained as history. The machine report binds all eight raw files individually and as a set, seven final and one historical. Lane output lists 86 selected checks, not their execution.

Native display, native-speaker review, human playtest, physical controller feel, M60 completion, full localization, remote CI success and release remain unobserved. No app, engine or saves used.

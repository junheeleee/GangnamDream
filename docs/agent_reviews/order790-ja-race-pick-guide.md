# ORDER-790 — Japanese racetrack pick instructions

**GO** for three existing JA values in candidate `43ce8e58d143d9bcf1a55fe8a79d5a76c4d0996e`, tree `db6641b7837c74365cc311e2f0358e45bc6af171`. Baseline `fb725b84df3c2d3a1e6179ff982f7befdfcac1cd`. No new keys.

I compared the three Korean instructions and Japanese targets against the actual incomplete-pick branch of `_bet_info_text` and the payout predicates. `選んだ` now denotes the selected horse, not a horse already matched. Place still requires first or second and describes relative ease and lower payout; Win still requires first and pays by odds; Quinella still requires two top-two horses in either order and describes medium payout. The bet names, Trifecta explanation, selection counts, settlement and saving are unchanged.

The canonical receipt matches all three accepted values and binds the previous target hashes. No earlier JA accepted rows existed. Reversal restores the Japanese dictionary and complete prior ledger byte for byte (381 prior batches). Other languages and public demo are unchanged. Official check/import are VALID with empty stderr; JA/UI, demo, EN and document logs are clean. The machine report binds all 16 raw files individually and as a set. Lane output lists 31 checks, not their execution.

Native display, native-speaker review, human playtest, physical controller feel, M60 completion, full localization, remote CI success and release remain unobserved. No app, engine or saves used.

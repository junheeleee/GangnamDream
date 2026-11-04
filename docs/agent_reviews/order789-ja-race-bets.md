# ORDER-789 — Japanese race wager names

**GO** for three existing JA labels in candidate `c43ef61227c305e7870c24bf68cfd6d1bbdbe5b4`, tree `0d540f832c6c7573b352e25d521e1e264b300339`. Baseline `ab397ef001fc4c03643a383d79e56f4dc6242a25`. No new keys.

RaceTrack picks one horse for `複勝` (first or second in this 5–7 horse field), two for `馬連` (first and second, either order), and three for `三連単` (exact first–second–third order). I matched the actual HorseWorld/HorseRace field and payout predicates to [JRA's bet types](https://www.jra.go.jp/kouza/beginner/baken/) and [JRA's field-size rule](https://www.jra.go.jp/kouza/baken/index.html). The mapping does not claim broader equivalence to real-world payouts. Win, descriptions, selection counts, RNG, odds, settlement, saves and other languages are unchanged.

The canonical receipt matches all three actual values and binds the three previous target hashes. No earlier JA accepted rows existed. Reversal restores the Japanese dictionary and complete prior ledger byte for byte (380 prior batches). Public demo is unchanged. Official check/import are VALID with empty stderr; the rules, JA/UI, demo, EN and document evidence was checked. The machine report binds all 16 raw files individually and as a set. Lane output lists 31 checks, not their execution.

Native display, native-speaker review, human playtest, physical controller feel, M60 completion, full localization, remote CI success and release remain unobserved. No app, engine or saves used.

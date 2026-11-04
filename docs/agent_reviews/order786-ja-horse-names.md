# ORDER-786 — Japanese racehorse names

**GO** for six existing JA values in candidate `63c4957657ae2e147bdabe8b32d5208776070067`, tree `91a18f5e52e7caa183f882dc6348752c8e744f10`. Baseline `5afecdda71e5e2e1d54c97329acbeb4f9d404e26`. No new keys.

I checked the six Korean names directly against their Japanese targets: `夜明けの星`, `鋼鉄`, `大当たり`, `鋳鉄`, `赤兎馬`, and `黒い星`. These remove wrong identity, material, time of day or grammatical readings. HorseWorld resolves a valid `name_id` through its current dictionary; RaceTrack uses that path in the entry list, tip and results. HorseRace's separate legacy name pool shares five keys; Red Hare belongs to HorseWorld. Existing stored names are not migrated, while future JA roster creation may store the corrected display strings. IDs, RNG, odds, settlement and save schema are unchanged.

The six previous target hashes and canonical receipt match the actual values. No earlier accepted rows existed for these JA keys. Exact reversal restores the Japanese dictionary and full prior ledger byte for byte (377 prior batches). Other locales, runtime and public demo are unchanged. Check/import are VALID with empty stderr; JA/UI, demo, EN and final document checks are clean. The machine report binds all 15 raw files individually and as a set. Lane output lists 31 checks, not their execution.

Native display, native-speaker review, human playtest, physical controller feel, M60 completion, full localization, remote CI success and release remain unobserved. No app, engine or saves used.

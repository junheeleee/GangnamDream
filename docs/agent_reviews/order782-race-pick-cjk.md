# ORDER-782 — Localized selected-horse suffix

**GO** for the one source change in candidate `2795c566d9c38a73e6fa3f078a1080b4de38ecf9`, tree `0a22136d0250988d4dd6ef1b814ff32db9f358cc`. Baseline `d1e6198aebd9a4050dd193c2f690d0cc80fd79fb`.

I traced MainGame's weekly racetrack entry into the Finish Board, `_make_result_row`, and LocaleManager's existing lookup. Picked rows use `自分の選択`, `我的选择` or `我的選擇` in JA, zh-CN and zh-TW. Other languages retain `MY PICK`; unpicked rows receive no suffix. The selected index test, rank, one-decimal odds, styling, settlement and save flow are unchanged. The one-block inverse restores the previous RaceTrack source byte for byte. The existing dictionaries and localization ledger did not change, so this is consumer coverage, not new translations.

Static source and collector/dictionary checks agree with the original contract marker; public-demo and strict EN logs are clean. The machine report binds the five original files individually and as a set. The lane output lists 22 selected checks; it is not proof they ran. No engine, game, or saves were used.

Native display, native-speaker review, human playtest, physical controller feel, M60 completion, full localization, remote CI success and release remain unobserved.

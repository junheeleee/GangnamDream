# ORDER-784 — First ending discovery badge

**GO** for the source connection and three new JA/zh-CN/zh-TW UI values in candidate `6261f6c1e08722e87987cf64283f1ca78fb3ee8c`, tree `35cb4cdd39dbf3282f007f4be1c151b249aa404a`. Declaration `e71903ac5c0b29a08dbdde9802cfd2ff3d1a7c36`; official receipt source `f7a39cfbddbecc514295bf643c2e0a4a993f3baf`.

I traced the full-game ending record page through `_ending_playstyle` to the existing `new_ending` produced only when `record_run` discovers a previously absent ending. The collection must still exist and that flag must still be nonempty. JA shows `初めて発見`, CN `新发现`, and TW `首次發現`; other languages retain `NEW`. Counts, spacing, emphasis, discovery and saving conditions are unchanged. Reversing the single source block and the append restores prior MainGame, dictionaries and the entire ledger byte for byte (376 prior batches). The public demo is unchanged.

Pure validation and the three canonical receipts match the accepted values, bound to the committed source-only intermediate. Final bound-check/import logs are VALID with empty stderr; the exact candidate append marker and JA/UI, demo and EN checks are clean. Initial response-manifest rejections and earlier-revision check-only VALID logs are historical, not acceptance. The machine report binds all 58 raw files individually and as a set, 31 final and 27 historical. Lane output only selects checks.

Native display, native-speaker review, human playtest, physical controller feel, M60 completion, full localization, remote CI success and release remain unobserved. No app, engine or saves used.

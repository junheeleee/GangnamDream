# ORDER-780 — Non-default approach labels in Chinese

**GO** for eight newly covered zh-CN/zh-TW static UI values in candidate `8f16dd9f268029201b9c07b1f39e7ae3b5c54b09`, tree `84af79dcaeb0bb7ff4f5b886c5aaf1601c919da3`. Baseline `f4b8aee61bfcd9ab3034af12d5bd9edac044ddee`.

I compared all four Korean labels and eight accepted targets with the actual Starting Conditions and ending-details consumers and LocaleManager's Korean-key lookup. The investment, relationship, principles and steady-life labels describe the chosen approach; they do not claim performance or impose a new rule. Each existing wrapper still has one `%s`, and I composed all eight strings against it in the data check. Both consumers exclude the default free-choice label. JA's existing values, KO/EN, runtime and public-demo files are unchanged.

Pure batch and exact append checks, two canonical receipts and the eight accepted values agree. The append can be reversed to byte-exact prior dictionaries and ledger (373 prior batches). Final check/import logs are VALID with empty stderr, and the candidate's exact `UI_APPEND_HISTORY_OK` marker was observed. The machine report binds all 20 raw files: 19 final and one historical lane CLI rejection. The corrected named-lane output is only a selection list.

Native display, native-speaker review, human playtest, physical controller feel, M60 completion, full localization, remote CI success and release remain unobserved. No app, engine or saves used.

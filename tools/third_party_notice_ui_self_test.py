#!/usr/bin/env python3
"""Notice source boundaries and real validator consumers; no engine/legal QA."""
from __future__ import annotations

import contextlib
import copy
import hashlib
import io
import json
import unittest
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

import full_game_localization as full
import ja_translation_audit as ja
import ja_translation_pipeline as pipeline
import story_demo_localization_audit as story
import third_party_notice_ui as notice
import zh_translation_audit as zh

ROOT = Path(__file__).resolve().parents[1]


@contextlib.contextmanager
def source_view(relative, raw):
    original = Path.read_bytes
    def read(path):
        if path == ROOT / relative:
            if isinstance(raw, Exception):
                raise raw
            return raw
        return original(path)
    try:
        with patch.object(Path, "read_bytes", read):
            yield
    finally:
        if Path.read_bytes is not original:
            raise AssertionError("notice source view did not restore Path.read_bytes")


class NoticeUiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw = (ROOT / notice.NOTICE_PATH).read_bytes()
        cls.document = json.loads(cls.raw)
        cls.rows = notice.collect_third_party_notice_ui_entries(ROOT)
        cls.static = {r.source for r in cls.rows if r.static_fallback}
        if len(cls.rows) != 14 or len(cls.static) != 2:
            raise AssertionError("normal notice source must succeed before mutants")

    def test_source_roles_and_legal_exclusion(self):
        self.assertEqual(len(notice.notice_ui_additions(self.rows, self.static)), 12)
        changed = copy.deepcopy(self.document)
        changed["unrelated_pair"] = {"ko": "검사용 비소유 본문", "en": "Unowned test body"}
        changed["sections"][0]["entries"][0]["copyright"] = "DO NOT TRANSLATE LEGAL BODY"
        changed["sections"][0]["entries"][0]["license_text_path"] = "res://unowned/license.txt"
        with source_view(notice.NOTICE_PATH, json.dumps(changed).encode()):
            self.assertEqual(notice.collect_third_party_notice_ui_entries(ROOT), self.rows)

    def test_malformed_json_roles(self):
        def reject(label, change):
            value = copy.deepcopy(self.document)
            change(value)
            with self.subTest(case=label), source_view(notice.NOTICE_PATH, json.dumps(value).encode()):
                with self.assertRaises(notice.NoticeSourceError):
                    notice.collect_third_party_notice_ui_entries(ROOT)
        reject("schema", lambda d: d.update(schema_version=2))
        reject("missing", lambda d: d["surface"].pop("intro"))
        reject("extra_surface", lambda d: d["surface"].update(body={"ko": "본문", "en": "Body"}))
        reject("extra_label", lambda d: d["surface"]["labels"].update(body={"ko": "본문", "en": "Body"}))
        reject("non_string", lambda d: d["surface"]["intro"].update(ko=7))
        reject("empty", lambda d: d["surface"]["intro"].update(en=" "))
        reject("extra_locale", lambda d: d["surface"]["intro"].update(ja="本文"))
        reject("duplicate_source", lambda d: d["surface"].update(intro=d["surface"]["package_note"]))
        reject("section_id", lambda d: d["sections"][0].update(id="unowned"))
        reject("duplicate_section", lambda d: d["sections"].append(copy.deepcopy(d["sections"][0])))
        reject("unknown_status", lambda d: d["sections"][0]["entries"][0].update(notice_status="unowned"))
        reject("fallback_pair", lambda d: d["surface"]["title"].update(en="Unowned title"))
        duplicate = self.raw.replace(b'"schema_version": 1,', b'"schema_version": 1, "schema_version": 1,', 1)
        self.assertNotEqual(duplicate, self.raw)
        for label, raw in (("raw_duplicate", duplicate), ("invalid_json", b"["),
                           ("missing_file", FileNotFoundError("notice fixture missing"))):
            with self.subTest(case=label), source_view(notice.NOTICE_PATH, raw):
                with self.assertRaises(notice.NoticeSourceError):
                    notice.collect_third_party_notice_ui_entries(ROOT)

    def test_reader_path_and_lookup_fail_closed(self):
        original = (ROOT / notice.READER_PATH).read_bytes()
        localized = notice._function(original.decode("utf-8"), "_notice_localized").encode("utf-8")
        self.assertEqual(original.count(localized), 1)
        self.assertEqual(localized.count(b'return LocaleManager.ui(\n'), 1)
        for before, after in (
            (b'res://content/meta/third_party_notices.json', b'res://content/meta/other.json'),
            (localized, localized.replace(b'return LocaleManager.ui(\n', b'return str(\n', 1)),
            (b'_notice_localized(surface.get("intro", {}))', b'str(surface.get("intro", {}))'),
        ):
            raw = original.replace(before, after, 1)
            self.assertNotEqual(raw, original)
            with self.subTest(before=before), source_view(notice.READER_PATH, raw):
                with self.assertRaises(notice.NoticeSourceError):
                    notice.collect_third_party_notice_ui_entries(ROOT)
        for keys in (set(), self.static | {self.rows[1].source}):
            with self.assertRaises(notice.NoticeSourceError):
                notice.notice_ui_additions(self.rows, keys)
        for keys in (set(), {next(iter(self.static))}):
            self.assertEqual(notice.notice_ui_additions(
                self.rows, keys, allow_partial_static=True), {})
        for keys in ({self.rows[1].source}, self.static | {self.rows[1].source}):
            with self.assertRaises(notice.NoticeSourceError):
                notice.notice_ui_additions(self.rows, keys, allow_partial_static=True)
        self.assertEqual(len(notice.notice_ui_additions(
            self.rows, self.static, allow_partial_static=True)), 12)

    def test_actual_collection_keeps_old_static_identities(self):
        inventory = full.collect()
        by_id = {leaf.id: leaf for leaf in inventory["leaves"]}
        new_rows = [leaf for leaf in by_id.values() if leaf.category == "ui_notice_chrome"]
        self.assertEqual(len(new_rows), 12)
        self.assertEqual({leaf.owner for leaf in new_rows}, {r.source for r in self.rows} - self.static)
        for row in self.rows:
            leaf = by_id[row.key]
            self.assertEqual(leaf.path, (row.source,))
            self.assertEqual(leaf.runtime_support, "builtin_overlay_static_only")
            self.assertFalse(leaf.protected)
            if row.static_fallback:
                self.assertEqual(leaf.category, "ui_static_context")
                self.assertEqual(leaf.source_path, "runtime:static_ui")
                self.assertEqual(leaf.source_sha256, full.digest({
                    "path": "runtime:static_ui", "field": (row.source,), "ko": row.source}))
            else:
                self.assertEqual(leaf.source_path, notice.NOTICE_PATH)
            self.assertNotIn("ui_unverified:" + row.key[3:], by_id)
        self.assertTrue(set(notice.SOURCE_PATHS) <= set(inventory["source_hashes"]))

    def test_isolated_real_consumers_and_exchange(self):
        # Source-provider isolation, not replacement validators: two existing
        # static fallbacks + one actual notice label. These three synthetic UI
        # targets test gates, not the authored 36-value translation cohort.
        pair = next(r for r in self.rows if r.pointer == "/surface/labels/provider")
        selected = [r for r in self.rows if r.static_fallback] + [pair]
        entries = tuple(pipeline.Entry(r.key, r.source, r.owner) for r in selected[:-1])
        blueprint = {e.source: {"$entry": e.key} for e in entries}
        inv = pipeline.UiInventory((), entries, blueprint, (), {}, (), {}, (),
                                   {"migrated_context_ids": 0, "planned_context_ids": 0})
        with contextlib.ExitStack() as stack:
            stack.enter_context(patch.object(notice, "collect_third_party_notice_ui_entries", return_value=selected))
            stack.enter_context(patch.object(ja, "collect_ui_inventory", return_value=inv))
            stack.enter_context(patch.object(ja, "_demo_runtime", return_value=({}, {"merged_pairs": {}})))
            stack.enter_context(patch.object(ja, "premature_context_dictionary_keys", return_value=[]))
            stack.enter_context(patch.object(ja, "retired_relationship_ui_entries", return_value=({}, [])))
            stack.enter_context(patch.object(story, "ui_pairs", return_value=({}, [], {})))
            stack.enter_context(patch.object(zh, "_static_ui_inventory", return_value=inv))
            stack.enter_context(patch.object(zh, "_story_demo_exclusive_ui_pairs", return_value=({}, [])))
            leaf, = full.notice_ui_leaves(self.static, set())
            for locale, target in (("ja", "提供元"), ("zh-CN", "提供方"), ("zh-TW", "提供者")):
                actual_ui = json.loads((ROOT / "locale" / f"ui_{locale}.json").read_text())
                actual = {key: actual_ui[key] for key in self.static}
                actual[pair.source] = target
                def audit(value, strict=False):
                    if locale == "ja":
                        errors = []
                        with contextlib.redirect_stdout(io.StringIO()):
                            ja.check_ui_scope(value, errors)
                        return errors
                    return zh.static_ui_coverage(locale, {"merged_pairs": {}}, strict, value)[-1]
                with self.subTest(locale=locale):
                    self.assertEqual(audit(actual), [])
                    self.assertEqual(full.translation_errors(leaf, locale, target), [])
                    for bad in ("", 7, pair.source, target + " %s", target + "\n"):
                        with self.subTest(locale=locale, bad=repr(bad)):
                            self.assertTrue(audit({**actual, pair.source: bad}))
                            self.assertTrue(full.translation_errors(leaf, locale, bad))
                    self.assertTrue(audit({**actual, "검사용 법률 본문": target}))
                    missing = {k: v for k, v in actual.items() if k != pair.source}
                    self.assertTrue(audit(missing, strict=True))
                    if locale != "ja":
                        self.assertEqual(audit(missing), [])  # Existing skeleton contract.
                        # A source-scoped partial view owns only its old static
                        # entry; the new notice key must not become an exemption.
                        partial = replace(inv, legacy_entries=entries[:1],
                            legacy_blueprint={entries[0].source: blueprint[entries[0].source]})
                        with patch.object(zh, "_static_ui_inventory", return_value=partial):
                            scoped = {entries[0].source: actual[entries[0].source]}
                            self.assertEqual(audit(scoped, strict=True), [])
                            self.assertTrue(audit({**scoped, pair.source: target}, strict=True))
                    inventory = {"leaves": [leaf], "source_manifest_sha256": "notice-fixture"}
                    documents = {f"locale/ui_{locale}.json": {"unowned": "retained"}}
                    before = copy.deepcopy(documents)
                    batch = full.make_batch(inventory, locale, [leaf], "0" * 40, documents, {})
                    response = [batch[0], {"id": leaf.id, "locale": locale,
                        "source_sha256": leaf.source_sha256, "prompt_version": full.PROMPT_VERSION, "text": target}]
                    translations = full.check_batch(inventory, batch, response)
                    result = full.merge_selected(inventory, batch, translations, documents, {})
                    self.assertEqual(result[f"locale/ui_{locale}.json"], {"unowned": "retained", pair.source: target})
                    self.assertEqual(documents, before)


if __name__ == "__main__":
    paths = (*notice.SOURCE_PATHS, "tools/third_party_notice_ui.py",
             "tools/full_game_localization.py", "tools/ja_translation_audit.py",
             "tools/zh_translation_audit.py", "tools/third_party_notice_ui_self_test.py",
             "locale/ui_ja.json", "locale/ui_zh-CN.json", "locale/ui_zh-TW.json")
    before = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(NoticeUiTests))
    after = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    unchanged = before == after
    print(json.dumps({"input_pins_before": before, "input_pins_after": after, "unchanged": unchanged}, sort_keys=True))
    if result.wasSuccessful() and unchanged:
        print(f"THIRD_PARTY_NOTICE_UI_SELF_TEST_OK tests={result.testsRun} source_roles=14 additions=12 unchanged=True")
    raise SystemExit(0 if result.wasSuccessful() and unchanged else 1)

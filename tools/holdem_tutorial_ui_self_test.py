#!/usr/bin/env python3
"""Four reached tutorial leaves and their actual validators; no engine/history suite."""
from __future__ import annotations

import contextlib
import copy
import hashlib
import io
import json
import sys
import unittest
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

import demo_localization_scope as demo
import full_game_localization as full
import holdem_tutorial_ui as tutorial
import ja_translation_audit as ja
import ja_translation_pipeline as pipeline
import story_demo_localization_audit as story
import third_party_notice_ui as notice
import zh_translation_audit as zh

ROOT = Path(__file__).resolve().parents[1]


@contextlib.contextmanager
def source_view(relative, raw):
    """One read-only fault seam; neither writes files nor changes the other readers."""
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
            raise AssertionError("tutorial source seam not restored")


class HoldemTutorialTests(unittest.TestCase):
    cases = 0

    @classmethod
    def setUpClass(cls):
        cls.raw = (ROOT / tutorial.SOURCE_PATH).read_bytes()
        cls.source = cls.raw.decode("utf-8")
        cls.rows = tutorial.collect_holdem_tutorial_ui_entries(ROOT)
        cls.anchors = set(tutorial.STATIC_ANCHORS)
        cls.actual = {locale: json.loads((ROOT / f"locale/ui_{locale}.json").read_bytes())
                      for locale in ("ja", "zh-CN", "zh-TW")}

    @contextlib.contextmanager
    def case(self, label):
        type(self).cases += 1
        with self.subTest(case=label):
            yield

    def changed_call(self, index, transform):
        start = self.source.index('\t\t"holdem":\n')
        for _ in range(index + 1):
            opening = self.source.index("_localized_slide(", start) + len("_localized_slide")
            body, end = demo._gd_call_body(self.source, opening)
            start = end
        args = demo._gd_call_args(body)
        transform(args)
        return self.source[:opening + 1] + ",\n\t\t\t\t\t".join(args) + self.source[end - 1:]

    def test_exact_roles_literals_and_roundtrip(self):
        with self.case("four source roles/IDs and raw bodies"):
            self.assertEqual([(r.slide, r.field) for r in self.rows],
                             [(0, "title"), (0, "body"), (1, "title"), (1, "body")])
            self.assertEqual([r.source.count("\n") for r in self.rows], [0, 8, 0, 11])
            self.assertEqual(len({r.key for r in self.rows}), 4)
            self.assertEqual(sum(r.source.count("💡") for r in self.rows), 2)
            self.assertEqual(sum(r.source.count("+EV") for r in self.rows), 1)
            for row in self.rows:
                self.assertEqual(row.key, full.Leaf("ui", row.source, tutorial.SOURCE_PATH,
                    (row.source,), row.source, tutorial.CATEGORY).id)
            self.assertEqual(tutorial.parse_holdem_tutorial_ui_entries(self.source), self.rows)
        with self.case("decoded escaped literals, LF and parentheses"):
            changed = self.changed_call(0, lambda a: a.__setitem__(4, json.dumps(self.rows[1].english)))
            self.assertEqual(tutorial.parse_holdem_tutorial_ui_entries(changed), self.rows)
        with self.case("fresh source reads and caller list isolation"):
            rows = tutorial.collect_holdem_tutorial_ui_entries(ROOT)
            rows.pop()
            self.assertEqual(tutorial.collect_holdem_tutorial_ui_entries(ROOT), self.rows)

    def test_parser_rejects_nonliteral_duplicate_extra_and_unreached(self):
        mutants = {
            "variable": self.changed_call(0, lambda a: a.__setitem__(3, "other_body")),
            "empty": self.changed_call(0, lambda a: a.__setitem__(4, '" "')),
            "adjacent literals": self.changed_call(0, lambda a: a.__setitem__(3, '"가" "나"')),
            "trailing operator": self.changed_call(0, lambda a: a.__setitem__(3, '"가" +')),
            "unbalanced grouping": self.changed_call(0, lambda a: a.__setitem__(3, '("가"')),
            "six arguments": self.changed_call(0, lambda a: a.append('"extra"')),
            "four arguments": self.changed_call(0, lambda a: a.pop()),
            "icon role": self.changed_call(0, lambda a: a.__setitem__(0, '"🏆"')),
            "title role": self.changed_call(0, lambda a: a.__setitem__(1, '"다른 규칙"')),
            "duplicate body": self.changed_call(1, lambda a: a.__setitem__(3, json.dumps(self.rows[1].source))),
            "wrong branch": self.source.replace('\t\t"holdem":\n', '\t\t"other":\n', 1),
            "early wildcard": self.source.replace('\t\t"baccarat":\n', '\t\t_:\n', 1),
            "dispatch": self.source.replace('\tmatch game_id:\n', '\tmatch "holdem":\n', 1),
        }
        start = self.source.index('\t\t"holdem":\n')
        end = self.source.index('\t\t"slot":\n', start)
        block = self.source[start:end]
        mutants["duplicate branch"] = self.source[:end] + block + self.source[end:]
        mutants["dedented return"] = self.source[:start] + block.replace(
            "\t\t\treturn [", "\t\treturn [", 1) + self.source[end:]
        mutants["extra slide"] = self.source[:start] + block.replace(
            '\n\t\t\t]\n', ', _localized_slide("x","x","x","x","x")\n\t\t\t]\n') + self.source[end:]
        for name, value in mutants.items():
            with self.case(name):
                self.assertNotEqual(value, self.source)
                with self.assertRaises(tutorial.HoldemTutorialSourceError):
                    tutorial.parse_holdem_tutorial_ui_entries(value)

    def test_actual_lookup_display_and_ingress_fail_closed(self):
        ready = tutorial._function(self.source, "_ready")
        hidden = ready.rstrip() + "\n# column-zero comment cannot hide a reader statement\n\t_slides.clear()\n"
        with self.case("column-zero comment followed by same-function execution"):
            changed = self.source.replace(ready.rstrip(), hidden.rstrip(), 1)
            self.assertNotEqual(changed, self.source)
            with self.assertRaises(tutorial.HoldemTutorialSourceError):
                tutorial.parse_holdem_tutorial_ui_entries(changed)
        for path, functions in tutorial.READER_FUNCTIONS.items():
            raw = (ROOT / path).read_bytes()
            for name in functions:
                body = tutorial._function(raw.decode(), name)
                changed = raw.replace(body.encode(), body.replace("\n", "\n\t# changed reader\n", 1).encode(), 1)
                with self.case(path + "::" + name), source_view(path, changed):
                    self.assertNotEqual(changed, raw)
                    with self.assertRaises(tutorial.HoldemTutorialSourceError):
                        tutorial.collect_holdem_tutorial_ui_entries(ROOT)
            for fault in (FileNotFoundError("isolated missing source"), b"\xff"):
                with self.case((path, repr(fault))), source_view(path, fault):
                    with self.assertRaises(tutorial.HoldemTutorialSourceError):
                        tutorial.collect_holdem_tutorial_ui_entries(ROOT)
        with self.case("fresh recovery after all failed admissions"):
            self.assertEqual(tutorial.collect_holdem_tutorial_ui_entries(ROOT), self.rows)

    def test_overlap_and_partial_scope_are_not_exemptions(self):
        with self.case("four additions and inputs unchanged"):
            before = copy.deepcopy((self.rows, self.anchors))
            self.assertEqual(set(tutorial.holdem_tutorial_ui_additions(self.rows, self.anchors, set(), set())),
                             {r.source for r in self.rows})
            self.assertEqual((self.rows, self.anchors), before)
        for owner in range(3):
            for row in self.rows:
                sets = [set(self.anchors), set(), set()]
                sets[owner].add(row.source)
                with self.case(("overlap", owner, row.field, row.slide)):
                    with self.assertRaises(tutorial.HoldemTutorialSourceError):
                        tutorial.holdem_tutorial_ui_additions(self.rows, *sets, allow_partial_static=True)
        for partial in (set(), {"힌트: "}, {"다음 ›"}):
            with self.case(("missing anchors", sorted(partial))):
                with self.assertRaises(tutorial.HoldemTutorialSourceError):
                    tutorial.holdem_tutorial_ui_additions(self.rows, partial, set(), set())
                self.assertEqual(tutorial.holdem_tutorial_ui_additions(
                    self.rows, partial, set(), set(), allow_partial_static=True), {})
        for rows in (self.rows[:-1], self.rows[::-1], self.rows + self.rows[:1],
                     [*self.rows[:3], replace(self.rows[3], source=self.rows[1].source)]):
            with self.case(("invalid roles", repr(rows))):
                with self.assertRaises(tutorial.HoldemTutorialSourceError):
                    tutorial.holdem_tutorial_ui_additions(rows, self.anchors, set(), set())

    def test_actual_full_collection_only_adds_four_keeps_demo_and_static(self):
        # Both are real collectors. The controlled comparison view suppresses
        # only the new four-leaf addition, not any old source/parser/validator.
        demo_views, static_views = [], []
        old_demo, old_static = demo.build_scope, pipeline.collect_ui_inventory
        def observed_demo(*args, **kwargs):
            value = old_demo(*args, **kwargs); demo_views.append(value); return value
        def observed_static(*args, **kwargs):
            value = old_static(*args, **kwargs); static_views.append(value); return value
        with patch.object(demo, "build_scope", observed_demo), patch.object(pipeline, "collect_ui_inventory", observed_static):
            actual = full.collect()
            with patch.object(tutorial, "holdem_tutorial_ui_additions", return_value={}):
                prior_view = full.collect()
        with self.case("actual four leaves and whole prior population"):
            new = [leaf for leaf in actual["leaves"] if leaf.category == tutorial.CATEGORY]
            self.assertEqual(len(new), 4)
            self.assertEqual({leaf.id for leaf in new}, {row.key for row in self.rows})
            self.assertEqual([leaf for leaf in actual["leaves"] if leaf.category != tutorial.CATEGORY], prior_view["leaves"])
            for key in ("source_hashes", "source_manifest_sha256", "unsupported", "relationship_display_names", "internal_ending_notes"):
                self.assertEqual(actual[key], prior_view[key])
            for leaf in new:
                self.assertEqual(leaf.path, (leaf.source,))
                self.assertEqual(leaf.source_path, tutorial.SOURCE_PATH)
                self.assertEqual(leaf.runtime_support, "builtin_overlay_static_only")
                self.assertFalse(leaf.protected)
        with self.case("same 701 demo and UiCall inventories"):
            self.assertEqual(len(demo_views), 2)
            self.assertEqual(demo_views[0], demo_views[1])
            self.assertEqual(len(demo_views[0][1]["merged_pairs"]), 701)
            self.assertEqual(len(static_views), 2)
            self.assertEqual(static_views[0], static_views[1])

    def test_actual_three_locale_validator_consumers(self):
        entries = tuple(pipeline.Entry("ui::fixture::" + str(i), key, tutorial.SOURCE_PATH)
                        for i, key in enumerate(sorted(self.anchors)))
        blueprint = {e.source: {"$entry": e.key} for e in entries}
        inv = pipeline.UiInventory((), entries, blueprint, (), {}, (), {}, (),
                                  {"migrated_context_ids": 0, "planned_context_ids": 0})
        with contextlib.ExitStack() as stack:
            # Source population isolation only. The new shared provider and
            # actual JA/ZH text validation bodies are never mocked.
            for owner, name, value in ((ja, "collect_ui_inventory", inv),
                    (ja, "_demo_runtime", ({}, {"merged_pairs": {}})),
                    (ja, "premature_context_dictionary_keys", []),
                    (ja, "retired_relationship_ui_entries", ({}, [])),
                    (story, "ui_pairs", ({}, [], {})),
                    (zh, "_static_ui_inventory", inv),
                    (zh, "_story_demo_exclusive_ui_pairs", ({}, [])),
                    (notice, "notice_ui_additions", {})):
                stack.enter_context(patch.object(owner, name, return_value=value))
            for locale, live in self.actual.items():
                actual = {key: live[key] for key in self.anchors | {r.source for r in self.rows}}
                before = copy.deepcopy(actual)
                def audit(value, strict=True):
                    if locale == "ja":
                        errors = []
                        with contextlib.redirect_stdout(io.StringIO()):
                            # Current retail checker owns the integration.
                            ja._TUTORIAL_OLD_CHECK_UI_SCOPE(value, errors)
                        return errors
                    return zh.static_ui_coverage(locale, {"merged_pairs": {}}, strict, value)[-1]
                with self.case((locale, "actual accepted four values")):
                    self.assertEqual(audit(actual), [])
                    self.assertEqual(actual, before)
                if locale == "ja":
                    with self.case("JA actual UI-only forbidden output remains enforced"):
                        title = self.rows[0].source
                        self.assertTrue(audit({**actual, title: actual[title] + " コスピ"}))
                for row in self.rows:
                    target = actual[row.source]
                    leaf = full.Leaf("ui", row.source, tutorial.SOURCE_PATH, (row.source,), row.source, tutorial.CATEGORY)
                    with self.case((locale, row.slide, row.field, "official validator")):
                        self.assertEqual(full.translation_errors(leaf, locale, target), [])
                    invalid = ["", 7, row.source, target + " %s", target + "\n", target + " 999"]
                    if row.field == "body":
                        invalid.append(target.replace("[b]", "", 1))
                    if row.slide == 0 and row.field == "body":
                        numeric = target.replace("[b]2", "[b]3", 1)
                        self.assertNotEqual(numeric, target)
                        invalid.append(numeric)
                        if locale in ("zh-CN", "zh-TW"):
                            card_mutants = (("[b]5张公共牌[/b]", "[b]4张公共牌[/b]"), ("[b]5张牌[/b]", "[b]5张底牌[/b]")) \
                                if locale == "zh-CN" else (("[b]5張公共牌[/b]", "[b]4張公共牌[/b]"), ("[b]5張牌[/b]", "[b]5張底牌[/b]"))
                            for old, new in card_mutants:
                                changed = target.replace(old, new, 1)
                                self.assertNotEqual(changed, target)
                                invalid.append(changed)
                    if row.slide == 1 and row.field == "body":
                        ordinal = target.replace("[b]2位", "[b]3位", 1) if locale == "ja" else target.replace("[b]第2位", "[b]第3位", 1)
                        self.assertNotEqual(ordinal, target)
                        invalid.append(ordinal)
                        if locale in ("zh-CN", "zh-TW"):
                            rank_mutants = (("四条", "五条"), ("三条 + 一对", "三条 + 两对"), ("4张", "3张")) \
                                if locale == "zh-CN" else (("四條", "五條"), ("三條 + 一對", "三條 + 兩對"), ("4張", "3張"))
                            for old, new in rank_mutants:
                                changed = target.replace(old, new, 1)
                                self.assertNotEqual(changed, target)
                                invalid.append(changed)
                    for bad in invalid:
                        with self.case((locale, row.slide, row.field, repr(bad))):
                            self.assertTrue(audit({**actual, row.source: bad}))
                            self.assertTrue(full.translation_errors(leaf, locale, bad))
                    with self.case((locale, row.slide, row.field, "missing")):
                        missing = {k: v for k, v in actual.items() if k != row.source}
                        self.assertTrue(audit(missing))
                        if locale != "ja": self.assertEqual(audit(missing, strict=False), [])
                with self.case((locale, "unknown source is not exempt")):
                    self.assertTrue(audit({**actual, "검사용 비소유 규칙": next(iter(actual.values()))}))
                self.assertEqual(actual, before)


if __name__ == "__main__":
    paths = (*tutorial.SOURCE_PATHS, "tools/holdem_tutorial_ui.py", "tools/holdem_tutorial_ui_self_test.py",
             "tools/demo_localization_scope.py", "tools/full_game_localization.py", "tools/ja_translation_pipeline.py",
             "tools/ja_translation_audit.py", "tools/zh_translation_audit.py", "locale/ui_ja.json",
             "locale/ui_zh-CN.json", "locale/ui_zh-TW.json", "content/meta/full_game_localization.json")
    before = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    result = unittest.TextTestRunner(stream=sys.stdout, verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(HoldemTutorialTests))
    after = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    unchanged = before == after
    print(json.dumps({"before": before, "after": after, "unchanged": unchanged,
                      "actual_collectors": "current plus scoped four-addition-free comparison; no historical suite"}, sort_keys=True))
    if result.wasSuccessful() and unchanged:
        print(f"HOLDEM_TUTORIAL_UI_SELF_TEST_OK cases={HoldemTutorialTests.cases} historical_cases=0")
    raise SystemExit(0 if result.wasSuccessful() and unchanged else 1)

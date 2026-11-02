#!/usr/bin/env python3
"""Offline store draft extraction and preservation regressions; no game/network."""
import json
from pathlib import Path
import tempfile
import unittest

import store_copy_export as copy


class CopyTests(unittest.TestCase):
    def setUp(self):
        self.raw = copy.SOURCE.read_bytes()

    def test_exact_fields_and_no_discarded_drafts(self):
        files = copy.extract(self.raw)
        self.assertEqual(len(files), 15)
        text = self.raw.decode()
        for locale in copy.LOCALES:
            for field in ("short_description.txt", "about_this_game.bbcode.txt", "ai_translation_notice.txt"):
                self.assertIn(files[f"{locale}/{field}"].rstrip("\n"), text)
        en = files["en/short_description.txt"]
        self.assertTrue(en.startswith("A choice-driven interactive novel."))
        self.assertNotIn("Can you climb Seoul", en)
        self.assertNotIn("world changes color", en)
        self.assertIn("AI-assisted translation", files["en/ai_translation_notice.txt"])

    def test_two_exports_preserve_previous_and_source(self):
        with tempfile.TemporaryDirectory() as temp:
            parent = Path(temp).resolve()
            sentinel = parent / "existing.txt"
            sentinel.write_bytes(b"keep")
            first = copy.export(parent)
            original = {str(p.relative_to(first)): p.read_bytes() for p in first.rglob("*") if p.is_file()}
            second = copy.export(parent)
            self.assertNotEqual(first, second)
            self.assertEqual(original, {str(p.relative_to(first)): p.read_bytes() for p in first.rglob("*") if p.is_file()})
            self.assertEqual(sentinel.read_bytes(), b"keep")
            manifest = json.loads((first / "manifest.json").read_text())
            self.assertEqual(manifest["scope"], "existing_store_drafts_only")
            self.assertEqual(manifest["source_sha256"], copy.sha(self.raw))
            self.assertEqual((first / "source.md").read_bytes(), self.raw)
            for row in manifest["files"]:
                self.assertEqual(row["sha256"], copy.sha((first / row["file"]).read_bytes()))
            self.assertEqual(copy.SOURCE.read_bytes(), self.raw)

    def test_malformed_source_rejected_before_output(self):
        mutations = [
            self.raw.replace(b"### A. ", b"### Z. ", 1),
            self.raw.replace(b"### B. ", b"### A. duplicate\n\n### B. ", 1),
            self.raw.replace(b"English:\n", b"Other:\n", 1),
            self.raw.replace(b"```text\n", b"```oops\n", 1),
            self.raw.replace(b"[h2]", b"[bad]", 1),
            self.raw.replace(b"[/h2]", b"[/i]", 1),
            self.raw.replace(b"A choice-driven interactive novel.", "한글".encode(), 1),
            self.raw.replace(b"Japanese and Chinese (Simplified/Traditional) use AI-assisted translation.", b"", 1),
        ]
        for raw in mutations:
            with self.subTest(raw=copy.sha(raw)):
                with self.assertRaises(ValueError):
                    copy.extract(raw)
        with tempfile.TemporaryDirectory() as temp:
            parent = Path(temp).resolve()
            source = parent / "bad.md"
            source.write_bytes(mutations[0])
            with self.assertRaises(ValueError):
                copy.export(parent, source)
            self.assertEqual(list(parent.iterdir()), [source])

    def test_duplicate_section_and_empty_field(self):
        for raw in (self.raw + b"\n## 4. About This Game - duplicate\n",
                    self.raw.replace(b"A choice-driven interactive novel. Thirty-three, unemployed, in a 4.5-pyeong Seoul goshiwon with 500,000 won. Five years to reach a three-billion-won Gangnam apartment. Each month you decide who gets your time and what you let go. Minjun knows why his father once knelt.", b"")):
            with self.assertRaises(ValueError):
                copy.extract(raw)

    def test_output_path_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            parent = Path(temp).resolve()
            link = parent / "link"
            link.symlink_to(parent, target_is_directory=True)
            for path in (link, copy.ROOT, Path("relative"), parent / "missing"):
                with self.subTest(path=path), self.assertRaises(ValueError):
                    copy.export(path)
            self.assertEqual(list(parent.iterdir()), [link])


if __name__ == "__main__":
    unittest.main()

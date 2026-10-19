#!/usr/bin/env python3
"""Synthetic PNG tests only. No game capture or release-image judgment."""
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

from PIL import Image, ImageDraw

import store_shot_export as exporter


class ExportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="gangnam-store-export-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "captures"
        self.source.mkdir()
        self.outputs = self.root / "outputs"
        self.outputs.mkdir()
        self.sentinel = self.outputs / "previous-run.png"
        self.sentinel.write_bytes(b"previous user output")
        self.entries, _ = exporter.load_contract()
        frames = []
        for n, entry in enumerate(self.entries):
            image = Image.new("RGB", (1280, 800), (n * 21, 42, 63))
            draw = ImageDraw.Draw(image)
            draw.rectangle((0, 0, 1279, 39), fill=(255, 0, 0))
            draw.rectangle((0, 760, 1279, 799), fill=(0, 0, 255))
            draw.point((0, 40), fill=(0, 255, 0))
            draw.point((1279, 759), fill=(255, 255, 0))
            path = self.source / entry["src"]
            image.save(path)
            frames.append({"file": path.name, "sha256": exporter.sha(path.read_bytes())})
        record = self.source / "capture.json"
        record.write_text('{"synthetic_fixture":true}\n')
        self.receipt = {"schema_version": 1, "language": "en",
                        "candidate": {"source_commit": "a" * 40, "source_tree": "b" * 40, "build_id": "TEST_ONLY"},
                        "capture_record": {"file": record.name, "sha256": exporter.sha(record.read_bytes())},
                        "frames": frames}
        self.manifest = self.source / "receipt.json"
        self.save_receipt()

    def save_receipt(self):
        self.manifest.write_text(json.dumps(self.receipt))

    def run_export(self):
        return exporter.export(self.manifest, self.outputs)

    def rejected(self):
        with self.assertRaises((ValueError, OSError)):
            self.run_export()
        self.assertEqual(list(self.outputs.iterdir()), [self.sentinel])
        self.assertEqual(self.sentinel.read_bytes(), b"previous user output")

    def test_success_pixels_captions_receipts_and_preservation(self):
        before = {p.name: p.read_bytes() for p in self.source.iterdir()}
        out = self.run_export()
        self.assertEqual({p.name: p.read_bytes() for p in self.source.iterdir()}, before)
        self.assertEqual(self.sentinel.read_bytes(), b"previous user output")
        manifest = json.loads((out / "manifest.json").read_text())
        self.assertEqual(manifest["scope"], "offline_crop_only")
        self.assertIn("candidate_match", manifest["unverified"])
        self.assertEqual(manifest["source_manifest_sha256"], exporter.sha(self.manifest.read_bytes()))
        self.assertEqual((out / "capture-record.bin").read_bytes(), before["capture.json"])
        for n, row in enumerate(manifest["frames"]):
            self.assertEqual(row["file"], self.entries[n]["dst"])
            self.assertEqual(row["caption_en"], self.entries[n]["en"])
            self.assertEqual(row["caption_ko"], self.entries[n]["ko"])
            self.assertEqual(row["source_sha256"], exporter.sha(before[row["source"]]))
            self.assertEqual(row["sha256"], exporter.sha((out / row["file"]).read_bytes()))
            with Image.open(out / row["file"]) as image:
                self.assertEqual(image.size, (1280, 720))
                self.assertEqual(image.getpixel((0, 0)), (0, 255, 0))
                self.assertEqual(image.getpixel((1279, 719)), (255, 255, 0))
                self.assertEqual(image.getpixel((640, 360)), (n * 21, 42, 63))
        second = self.run_export()
        self.assertNotEqual(second, out)
        self.assertTrue((out / "manifest.json").is_file())

    def test_source_hash_mismatch(self):
        self.receipt["frames"][0]["sha256"] = "0" * 64
        self.save_receipt()
        self.rejected()

    def test_capture_hash_mismatch(self):
        (self.source / "capture.json").write_text("changed")
        self.rejected()

    def test_bad_identity_and_language_and_types(self):
        for field, value in (("language", "ko"), ("schema_version", True), ("frames", {})):
            original = self.receipt[field]
            self.receipt[field] = value
            self.save_receipt()
            self.rejected()
            self.receipt[field] = original
        self.receipt["candidate"]["source_commit"] = "HEAD"
        self.save_receipt()
        self.rejected()

    def test_wrong_order_and_missing_frame(self):
        self.receipt["frames"].reverse()
        self.save_receipt()
        self.rejected()
        self.receipt["frames"].pop()
        self.save_receipt()
        self.rejected()

    def test_extra_png(self):
        (self.source / "stale.PNG").write_bytes(b"old")
        self.rejected()

    def test_missing_png(self):
        (self.source / self.entries[0]["src"]).unlink()
        self.rejected()

    def test_invalid_png_with_matching_hash(self):
        path = self.source / self.entries[0]["src"]
        path.write_bytes(b"\x89PNG\r\n\x1a\ninvalid payload")
        self.receipt["frames"][0]["sha256"] = exporter.sha(path.read_bytes())
        self.save_receipt()
        self.rejected()

    def test_wrong_size_with_matching_hash(self):
        path = self.source / self.entries[0]["src"]
        Image.new("RGB", (1280, 720)).save(path)
        self.receipt["frames"][0]["sha256"] = exporter.sha(path.read_bytes())
        self.save_receipt()
        self.rejected()

    def test_duplicate_source(self):
        p0, p1 = [self.source / e["src"] for e in self.entries[:2]]
        p1.write_bytes(p0.read_bytes())
        self.receipt["frames"][1]["sha256"] = exporter.sha(p1.read_bytes())
        self.save_receipt()
        self.rejected()

    def test_duplicate_crop_even_if_source_bytes_differ(self):
        p0, p1 = [self.source / e["src"] for e in self.entries[:2]]
        with Image.open(p0) as image:
            image.putpixel((2, 2), (13, 14, 15))
            image.save(p1)
        self.receipt["frames"][1]["sha256"] = exporter.sha(p1.read_bytes())
        self.save_receipt()
        self.rejected()

    def test_symlink_frame_and_manifest(self):
        path = self.source / self.entries[0]["src"]
        real = self.root / "outside.png"
        path.rename(real)
        path.symlink_to(real)
        self.rejected()
        receipt_link = self.root / "link.json"
        receipt_link.symlink_to(self.manifest)
        self.manifest = receipt_link
        self.rejected()

    def test_source_output_overlap(self):
        with self.assertRaises(ValueError):
            exporter.export(self.manifest, self.source)
        nested = self.source / "nested"
        nested.mkdir()
        with self.assertRaises(ValueError):
            exporter.export(self.manifest, nested)
        self.assertEqual(list(nested.iterdir()), [])

    def test_repo_output_rejected(self):
        with self.assertRaises(ValueError):
            exporter.export(self.manifest, exporter.ROOT / "assets/store/screenshots")

    def test_capture_traversal(self):
        self.receipt["capture_record"]["file"] = "../outside.json"
        self.save_receipt()
        self.rejected()

    def test_failure_preserves_partial_no_completion(self):
        actual = exporter.write_new
        for failure in ("03_montage_card.png", "manifest.pending.json"):
            def fail_at(path, data):
                if path.name == failure:
                    raise OSError("synthetic disk error")
                actual(path, data)
            with patch.object(exporter, "write_new", side_effect=fail_at):
                with self.assertRaisesRegex(ValueError, "preserve partial output"):
                    self.run_export()
        partials = list(self.outputs.glob("gangnam-store-export-*"))
        self.assertEqual(len(partials), 2)
        for out in partials:
            self.assertFalse((out / "manifest.json").exists())
            self.assertTrue((out / "01_cold_open.png").exists())
        self.assertEqual(self.sentinel.read_bytes(), b"previous user output")

    def test_cli_fails_without_success_marker(self):
        self.receipt["language"] = "ja"
        self.save_receipt()
        result = subprocess.run([sys.executable, str(exporter.ROOT / "tools/store_shot_export.py"),
                                 "--manifest", str(self.manifest), "--output-parent", str(self.outputs)],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("STORE_SHOT_EXPORT_ERROR", result.stderr)
        self.assertNotIn("STORE_SHOT_EXPORT_OK", result.stdout)


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ExportTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if result.wasSuccessful():
        print(f"STORE_SHOT_EXPORT_SELF_TEST_OK tests={result.testsRun} synthetic_only=1 engine_runs=0")
    raise SystemExit(0 if result.wasSuccessful() else 1)

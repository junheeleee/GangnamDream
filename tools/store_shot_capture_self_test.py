#!/usr/bin/env python3
"""Adversarial synthetic fixtures only; never launches Godot or certifies art."""
from __future__ import annotations

from contextlib import ExitStack
import copy
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from PIL import Image

import store_shot_capture as capture_tool
import store_shot_export as exporter


class CaptureTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="gangnam-store-capture-test-")
        self.addCleanup(self.temp.cleanup)
        # macOS exposes its temporary root through /var -> /private/var.
        # Resolve that platform alias before testing deliberate symlinks.
        self.base = Path(self.temp.name).resolve()
        self.root = self.base / "source"
        self.root.mkdir()
        self.outputs = self.base / "outputs"
        self.outputs.mkdir()
        self.sentinel = self.outputs / "previous-user-output.png"
        self.sentinel.write_bytes(b"preserve previous output")
        self.user_parent = self.base / "user-data"
        self.user_parent.mkdir()
        self.engine = self.base / "fake-engine-never-executed"
        self.engine.write_bytes(b"synthetic executable fixture only\n")
        self.engine.chmod(0o700)
        self.source = {"candidate": {"source_commit": "a" * 40,
                      "source_tree": "b" * 40, "build_id": "SYNTHETIC_ONLY"},
                       "files": [{"file": "source.gd", "bytes": 1,
                                  "sha256": "c" * 64}]}
        self.entries, _ = exporter.load_contract()
        self.pngs = {}
        for index, row in enumerate(self.entries):
            buffer = io.BytesIO()
            Image.new("RGB", (1920, 1200), (index * 23, 50, 80)).save(buffer, format="PNG")
            self.pngs[row["src"]] = buffer.getvalue()
        self.mutate = lambda output, stdout, stderr, godot: (stdout, stderr, godot)
        self.returncode = 0
        self.timeout = False
        self.launch_error = None
        self.commands = []
        self.namespace_dirs = []
        self.stack = ExitStack()
        self.addCleanup(self.stack.close)
        environment = {key: value for key, value in os.environ.items()
                       if key not in capture_tool.OVERRIDES}
        self.original_environment = environment
        self.stack.enter_context(patch.dict(os.environ, environment, clear=True))
        self.snapshot = self.stack.enter_context(patch.object(
            capture_tool, "source_snapshot", side_effect=lambda root: copy.deepcopy(self.source)))
        self.stack.enter_context(patch.object(capture_tool.safety, "user_data_parent",
                                              return_value=self.user_parent))
        self.stack.enter_context(patch.object(capture_tool.safety, "install_handlers", return_value={}))
        self.stack.enter_context(patch.object(capture_tool.safety, "set_handlers"))
        self.kill = self.stack.enter_context(patch.object(capture_tool.safety,
                                                         "kill_remaining_group", return_value=None))
        self.terminate = self.stack.enter_context(patch.object(capture_tool.safety,
                                                              "terminate_tree", return_value=("", "", None)))
        self.popen = self.stack.enter_context(patch.object(capture_tool.subprocess, "Popen",
                                                          side_effect=self.fake_popen))

    def fake_popen(self, command, **kwargs):
        if self.launch_error is not None:
            raise self.launch_error
        self.commands.append((command, kwargs))
        output = Path(kwargs["env"]["GANGNAM_QA_OUT"])
        user_dir = self.user_parent / kwargs["env"]["STORY_NAMEPLATE_QA_NAMESPACE"]
        user_dir.mkdir()
        (user_dir / "fixture.txt").write_bytes(b"preserve synthetic QA state")
        self.namespace_dirs.append(user_dir)
        for name, raw in self.pngs.items():
            (output / name).write_bytes(raw)
        pre = f"STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR={user_dir}\n"
        done = f"SCREENSHOT_QA_DONE scope=store lang=en dir={output}\n"
        stdout, stderr, godot = self.mutate(output, (pre + done).encode(), b"", b"Godot fixture\n")
        kwargs["stdout"].write(stdout)
        kwargs["stderr"].write(stderr)
        if godot is not None:
            (output / "godot.log").write_bytes(godot)
        owner = self

        class FakeProcess:
            pid = 987654321
            returncode = owner.returncode

            def communicate(self, timeout):
                if owner.timeout:
                    self.returncode = -9
                    raise subprocess.TimeoutExpired(command, timeout)
                return None, None

        return FakeProcess()

    def run_capture(self, **kwargs):
        return capture_tool.capture(kwargs.get("parent", self.outputs),
                                    str(kwargs.get("engine", self.engine)),
                                    kwargs.get("timeout", 10), self.root)

    def assert_old_output_preserved(self):
        self.assertEqual(self.sentinel.read_bytes(), b"preserve previous output")
        for namespace in self.namespace_dirs:
            self.assertEqual((namespace / "fixture.txt").read_bytes(), b"preserve synthetic QA state")

    def rejected(self):
        old = set(self.outputs.iterdir())
        with self.assertRaises((ValueError, OSError)):
            self.run_capture()
        created = set(self.outputs.iterdir()) - old
        self.assertEqual(len(created), 1)
        output = created.pop()
        self.assertFalse((output / "receipt.json").exists())
        self.assertTrue((output / "capture-start.json").is_file())
        record = json.loads((output / "capture-result.json").read_bytes())
        self.assertEqual(record["status"], "failed")
        self.assertTrue(record["errors"])
        self.assertTrue((output / "stdout.log").is_file())
        self.assertTrue((output / "stderr.log").is_file())
        self.assert_old_output_preserved()
        return output, record

    def test_success_isolation_raw_receipt_and_exporter_linkage(self):
        output = self.run_capture()
        command, kwargs = self.commands[0]
        self.assertIn("--qa=store", command)
        self.assertIn("--lang=en", command)
        self.assertEqual(command[command.index("--script") + 1], "res://tools/StoryNameplateBootstrap.gd")
        self.assertEqual(command[command.index("--resolution") + 1], "1920x1200")
        self.assertEqual(kwargs["cwd"], self.root)
        self.assertEqual(kwargs["env"]["GANGNAM_QA_OUT"], str(output))
        for key in ("HOME", "XDG_DATA_HOME", "XDG_CONFIG_HOME", "APPDATA"):
            self.assertEqual(kwargs["env"].get(key), self.original_environment.get(key))
        if os.name != "nt":
            self.assertIs(kwargs["start_new_session"], True)
        self.assertEqual(self.snapshot.call_count, 2)
        self.kill.assert_called_once()
        self.terminate.assert_not_called()
        receipt = json.loads((output / "receipt.json").read_bytes())
        self.assertEqual(set(receipt), {"schema_version", "language", "candidate", "capture_record", "frames"})
        self.assertEqual(receipt["candidate"], self.source["candidate"])
        raw = (output / "capture-result.json").read_bytes()
        self.assertEqual(receipt["capture_record"], {"file": "capture-result.json", "sha256": exporter.sha(raw)})
        record = json.loads(raw)
        self.assertEqual(record["status"], "passed")
        self.assertEqual(record["export_profile"], "steam")
        self.assertEqual(record["source_size"], [1920, 1200])
        self.assertEqual(record["error_lines"], [])
        self.assertEqual(record["source_manifest_sha256"], exporter.sha((output / "source-manifest.json").read_bytes()))
        for key in ("native_play", "human_observation", "visual_review", "package_identity_verified",
                    "previous_outputs_deleted"):
            self.assertIs(record[key], False)
        self.assertEqual([frame["file"] for frame in receipt["frames"]], [entry["src"] for entry in self.entries])
        before = {path.name: path.read_bytes() for path in output.iterdir()}
        export_parent = self.base / "exported"
        export_parent.mkdir()
        exported = exporter.export(output / "receipt.json", export_parent, profile="steam")
        self.assertEqual({path.name: path.read_bytes() for path in output.iterdir()}, before)
        self.assertEqual(len(list(exported.glob("*.png"))), 8)
        for image_path in exported.glob("*.png"):
            with Image.open(image_path) as image:
                self.assertEqual(image.size, (1920, 1080))
        self.assertIn("candidate_match", json.loads((exported / "manifest.json").read_bytes())["unverified"])
        self.assert_old_output_preserved()

    def test_repeated_capture_uses_new_output_and_namespace(self):
        first = self.run_capture()
        first_raw = (first / "receipt.json").read_bytes()
        second = self.run_capture()
        self.assertNotEqual(first, second)
        self.assertNotEqual(self.namespace_dirs[0], self.namespace_dirs[1])
        self.assertEqual((first / "receipt.json").read_bytes(), first_raw)
        self.assert_old_output_preserved()

    def test_marker_missing_duplicate_mismatch_and_order(self):
        mutations = (
            lambda data: b"\n".join(data.splitlines()[1:]) + b"\n",
            lambda data: data + data.splitlines()[0] + b"\n",
            lambda data: data + data.splitlines()[1] + b"\n",
            lambda data: data.replace(b"lang=en", b"lang=ko"),
            lambda data: data.replace(b"scope=store", b"scope=trailer"),
            lambda data: b"\n".join(reversed(data.splitlines())) + b"\n",
            lambda data: data.replace(b"USER_DIR=", b"USER_DIR=/wrong/"),
            lambda data: data.replace(b" dir=", b" dir=/wrong/"),
        )
        for mutate in mutations:
            with self.subTest(mutation=mutate):
                self.mutate = lambda output, stdout, stderr, godot: (mutate(stdout), stderr, godot)
                self.rejected()

    def test_marker_on_stderr_not_valid_stdout_evidence(self):
        self.mutate = lambda output, stdout, stderr, godot: (b"", stdout, godot)
        self.rejected()

    def test_all_three_streams_scan_script_errors_and_leaks(self):
        errors = (b"SCRIPT ERROR: synthetic\n", b"Parse Error: synthetic\n",
                  b"Compile Error: synthetic\n", b"ERROR: synthetic\n",
                  b"ObjectDB instances leaked at exit\n", b"resources still in use\n",
                  b"Failed to load script fixture\n", b"SCREENSHOT_QA_FAIL synthetic\n",
                  b"STORY_NAMEPLATE_CHECK_FAIL synthetic\n")
        for stream in range(3):
            for error in errors:
                with self.subTest(stream=stream, error=error):
                    def mutate(output, stdout, stderr, godot):
                        values = [stdout, stderr, godot]
                        values[stream] += error
                        return tuple(values)
                    self.mutate = mutate
                    output, record = self.rejected()
                    self.assertTrue(record["error_lines"])
                    self.assertIn(error, (output / ("stdout.log", "stderr.log", "godot.log")[stream]).read_bytes())

    def test_nonzero_exit_even_with_valid_markers(self):
        self.returncode = 1
        _, record = self.rejected()
        self.assertEqual(record["engine_exit"], 1)

    def test_timeout_terminates_tree_preserves_raw_and_no_receipt(self):
        self.timeout = True
        self.rejected()
        self.terminate.assert_called_once()
        self.kill.assert_not_called()

    def test_remaining_process_group_error(self):
        self.kill.return_value = "synthetic remaining-process failure"
        self.rejected()

    def test_launch_failure(self):
        self.launch_error = OSError("synthetic launch failure")
        _, record = self.rejected()
        self.assertIsNone(record["engine_exit"])

    def test_missing_and_invalid_utf8_godot_log(self):
        for godot_log in (None, b"\xff\xfe"):
            with self.subTest(godot_log=godot_log):
                self.mutate = lambda output, stdout, stderr, godot: (stdout, stderr, godot_log)
                self.rejected()

    def test_invalid_utf8_stdout_and_stderr(self):
        for stream in (0, 1):
            def mutate(output, stdout, stderr, godot):
                values = [stdout, stderr, godot]
                values[stream] += b"\xff"
                return tuple(values)
            self.mutate = mutate
            self.rejected()

    def test_missing_extra_duplicate_corrupt_dimensions_and_symlink_frames(self):
        first, second = [entry["src"] for entry in self.entries[:2]]
        def wrong_size(output):
            Image.new("RGB", (1280, 720)).save(output / first)
        def symlink(output):
            (output / first).unlink()
            (output / first).symlink_to(output / second)
        cases = (
            lambda output: (output / first).unlink(),
            lambda output: (output / "stale.PNG").write_bytes(b"stale"),
            lambda output: (output / second).write_bytes((output / first).read_bytes()),
            lambda output: (output / first).write_bytes(b"\x89PNG\r\n\x1a\ninvalid"),
            wrong_size, symlink,
        )
        for mutation in cases:
            with self.subTest(mutation=mutation):
                def mutate(output, stdout, stderr, godot):
                    mutation(output)
                    return stdout, stderr, godot
                self.mutate = mutate
                self.rejected()

    def test_non_rgb_and_animated_pngs_rejected(self):
        first = self.entries[0]["src"]
        def grayscale(output):
            Image.new("L", (1920, 1200), 40).save(output / first)
        def animated(output):
            Image.new("RGB", (1920, 1200), (0, 0, 0)).save(
                output / first, save_all=True,
                append_images=[Image.new("RGB", (1920, 1200), (255, 255, 255))],
                duration=100, loop=0)
        for mutation in (grayscale, animated):
            with self.subTest(mutation=mutation):
                def mutate(output, stdout, stderr, godot):
                    mutation(output)
                    return stdout, stderr, godot
                self.mutate = mutate
                self.rejected()

    def test_legacy_and_mixed_source_sizes_never_get_capture_receipt(self):
        for count in (1, 8):
            with self.subTest(legacy_frames=count):
                def mutate(output, stdout, stderr, godot):
                    for index, entry in enumerate(self.entries[:count]):
                        Image.new("RGB", (1280, 800), (index * 23, 50, 80)).save(output / entry["src"])
                    return stdout, stderr, godot
                self.mutate = mutate
                output, record = self.rejected()
                self.assertTrue(any("1920x1200" in error for error in record["errors"]))

    def test_symlink_godot_log_rejected_without_following(self):
        outside = self.base / "outside-log.txt"
        outside.write_bytes(b"untouched outside log")
        def mutate(output, stdout, stderr, godot):
            (output / "godot.log").symlink_to(outside)
            return stdout, stderr, None
        self.mutate = mutate
        self.rejected()
        self.assertEqual(outside.read_bytes(), b"untouched outside log")

    def test_source_and_engine_drift(self):
        changed = copy.deepcopy(self.source)
        changed["files"][0]["sha256"] = "d" * 64
        self.snapshot.side_effect = [copy.deepcopy(self.source), changed]
        self.rejected()
        self.snapshot.side_effect = lambda root: copy.deepcopy(self.source)
        def mutate(output, stdout, stderr, godot):
            self.engine.write_bytes(b"synthetic engine changed during capture\n")
            return stdout, stderr, godot
        self.mutate = mutate
        self.rejected()

    def test_source_check_fails_after_capture(self):
        self.snapshot.side_effect = [copy.deepcopy(self.source), ValueError("source dirtied during capture")]
        self.rejected()

    def test_inherited_qa_override_rejected_before_launch(self):
        for key in capture_tool.OVERRIDES:
            with self.subTest(key=key), patch.dict(os.environ, {key: ""}):
                with self.assertRaisesRegex(ValueError, "inherited QA override"):
                    self.run_capture()
        self.popen.assert_not_called()
        self.assertEqual(list(self.outputs.iterdir()), [self.sentinel])

    def test_output_source_userdata_and_symlink_paths_rejected(self):
        source_child = self.root / "nested-output"
        source_child.mkdir()
        user_child = self.user_parent / "nested-output"
        user_child.mkdir()
        link = self.base / "outputs-link"
        link.symlink_to(self.outputs, target_is_directory=True)
        for parent in (self.root, source_child, self.user_parent, user_child, link):
            with self.subTest(parent=parent):
                with self.assertRaises((ValueError, OSError)):
                    self.run_capture(parent=parent)
        self.popen.assert_not_called()
        self.assertEqual(list(self.outputs.iterdir()), [self.sentinel])

    def test_bad_timeout_and_non_executable_rejected_before_launch(self):
        for timeout in (0, 1801, True, "10"):
            with self.subTest(timeout=timeout):
                with self.assertRaises(ValueError):
                    self.run_capture(timeout=timeout)
        self.engine.chmod(0o600)
        with self.assertRaises(ValueError):
            self.run_capture()
        self.popen.assert_not_called()
        self.assertEqual(list(self.outputs.iterdir()), [self.sentinel])

    def test_existing_namespace_refused_without_launch_or_overwrite(self):
        namespace = self.user_parent / (capture_tool.safety.PREFIX + "a" * 32)
        namespace.mkdir()
        sentinel = namespace / "previous-save.json"
        sentinel.write_bytes(b"preserve existing namespace")
        with patch.object(capture_tool.secrets, "token_hex", return_value="a" * 32):
            with self.assertRaisesRegex(ValueError, "pre-existing QA namespace"):
                self.run_capture()
        self.assertEqual(sentinel.read_bytes(), b"preserve existing namespace")
        self.popen.assert_not_called()

    def test_receipt_publication_failure_has_no_completed_receipt(self):
        original_write = capture_tool.write_new
        def fail_publication(path, data):
            if path.name == "receipt.pending.json":
                raise OSError("synthetic receipt storage failure")
            original_write(path, data)
        with patch.object(capture_tool, "write_new", side_effect=fail_publication):
            with self.assertRaisesRegex(OSError, "synthetic receipt storage failure"):
                self.run_capture()
        outputs = list(self.outputs.glob("gangnam-store-capture-*"))
        self.assertEqual(len(outputs), 1)
        output = outputs[0]
        self.assertFalse((output / "receipt.json").exists())
        self.assertTrue((output / "capture-result.json").is_file())
        self.assertTrue((output / self.entries[0]["src"]).is_file())
        self.assert_old_output_preserved()


class SourceSnapshotTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="gangnam-store-source-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        (self.root / "systems").mkdir()
        self.build = self.root / "systems/BuildInfo.gd"
        self.build.write_text('extends RefCounted\nconst BUILD_ID := "SYNTHETIC_ONLY"\n')
        self.payload = self.root / "content.txt"
        self.payload.write_bytes(b"synthetic tracked source\n")
        self.git("init", "--quiet")
        self.git("config", "user.name", "Synthetic Fixture")
        self.git("config", "user.email", "fixture@example.invalid")
        self.commit()

    def git(self, *args):
        return subprocess.run(["git", "-C", str(self.root), *args], check=True,
                              capture_output=True).stdout

    def commit(self):
        self.git("add", "--all")
        self.git("commit", "--quiet", "-m", "synthetic source fixture")

    def test_clean_git_identity_build_and_every_tracked_file_pinned(self):
        snapshot = capture_tool.source_snapshot(self.root)
        self.assertEqual(snapshot["candidate"], {"source_commit": self.git("rev-parse", "HEAD").decode().strip(),
                                                "source_tree": self.git("rev-parse", "HEAD^{tree}").decode().strip(),
                                                "build_id": "SYNTHETIC_ONLY"})
        self.assertEqual({row["file"] for row in snapshot["files"]}, {"content.txt", "systems/BuildInfo.gd"})
        for row in snapshot["files"]:
            raw = (self.root / row["file"]).read_bytes()
            self.assertEqual(row["bytes"], len(raw))
            self.assertEqual(row["sha256"], exporter.sha(raw))
            self.assertEqual(row["git_blob"], self.git("rev-parse", "HEAD:" + row["file"]).decode().strip())

    def test_dirty_tracked_staged_and_untracked_source_rejected(self):
        self.payload.write_bytes(b"changed\n")
        with self.assertRaisesRegex(ValueError, "clean dedicated"):
            capture_tool.source_snapshot(self.root)
        self.git("add", "content.txt")
        with self.assertRaisesRegex(ValueError, "clean dedicated"):
            capture_tool.source_snapshot(self.root)
        self.commit()
        (self.root / "untracked.txt").write_bytes(b"untracked\n")
        with self.assertRaisesRegex(ValueError, "clean dedicated"):
            capture_tool.source_snapshot(self.root)

    def test_committed_symlink_and_missing_ambiguous_build_rejected(self):
        link = self.root / "tracked-link"
        link.symlink_to(self.payload)
        self.commit()
        with self.assertRaisesRegex(ValueError, "source symlink|non-regular entries"):
            capture_tool.source_snapshot(self.root)
        link.unlink()
        self.build.write_text('extends RefCounted\n')
        self.commit()
        with self.assertRaisesRegex(ValueError, "BUILD_ID"):
            capture_tool.source_snapshot(self.root)
        self.build.write_text('const BUILD_ID := "ONE"\nconst BUILD_ID := "TWO"\n')
        self.commit()
        with self.assertRaisesRegex(ValueError, "BUILD_ID"):
            capture_tool.source_snapshot(self.root)

    def test_assume_unchanged_cannot_hide_modified_source_bytes(self):
        self.git("update-index", "--assume-unchanged", "content.txt")
        self.payload.write_bytes(b"modified despite status clean\n")
        self.assertEqual(self.git("status", "--porcelain=v1", "--untracked-files=all"), b"")
        with self.assertRaisesRegex(ValueError, "source bytes differ from committed blob"):
            capture_tool.source_snapshot(self.root)

    def test_skip_worktree_cannot_hide_modified_source_bytes(self):
        self.git("update-index", "--skip-worktree", "content.txt")
        self.payload.write_bytes(b"modified despite status clean\n")
        self.assertEqual(self.git("status", "--porcelain=v1", "--untracked-files=all"), b"")
        with self.assertRaisesRegex(ValueError, "source bytes differ from committed blob"):
            capture_tool.source_snapshot(self.root)

    def test_edit_during_manifest_read_rejected(self):
        original_pin = capture_tool.file_pin
        changed = False
        def change_after_pin(path):
            nonlocal changed
            value = original_pin(path)
            if not changed:
                self.payload.write_bytes(b"changed during source read\n")
                changed = True
            return value
        with patch.object(capture_tool, "file_pin", side_effect=change_after_pin):
            with self.assertRaisesRegex(ValueError, "source changed during manifest"):
                capture_tool.source_snapshot(self.root)


if __name__ == "__main__":
    suite = unittest.TestSuite(unittest.defaultTestLoader.loadTestsFromTestCase(case)
                               for case in (CaptureTests, SourceSnapshotTests))
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if result.wasSuccessful():
        print(f"STORE_SHOT_CAPTURE_SELF_TEST_OK tests={result.testsRun} synthetic_only=1 engine_runs=0")
    raise SystemExit(0 if result.wasSuccessful() else 1)

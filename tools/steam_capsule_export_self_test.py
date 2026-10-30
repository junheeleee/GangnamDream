#!/usr/bin/env python3
"""Synthetic/mocked capsule export tests; never starts Godot or judges art."""
from __future__ import annotations

from contextlib import ExitStack, redirect_stdout, redirect_stderr
import copy
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

from PIL import Image

import steam_capsule_export as exporter


class CapsuleTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="gangnam-capsule-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.root = self.base / "source"
        self.root.mkdir()
        self.input_paths = (exporter.CONTRACT_FILE, exporter.RENDERER, exporter.SCENE,
                            exporter.MASTER_FILE, "scenes/ui/GangnamWordmark.gd",
                            "tools/StoryNameplateBootstrap.gd")
        for name in self.input_paths:
            target = self.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes((exporter.ROOT / name).read_bytes())
        self.outputs = self.base / "outputs"
        self.outputs.mkdir()
        self.sentinel = self.outputs / "old-approved-capsule.png"
        self.sentinel.write_bytes(b"preserve approved output")
        self.user_parent = self.base / "user-data"
        self.user_parent.mkdir()
        self.engine = self.base / "never-executed-engine-fixture"
        self.engine.write_bytes(b"synthetic engine fixture only\n")
        self.engine.chmod(0o700)
        self.source = {"candidate": {"source_commit": "a" * 40, "source_tree": "b" * 40,
                                     "build_id": "SYNTHETIC_ONLY"},
                       "files": [{"file": "synthetic.gd", "bytes": 1, "sha256": "c" * 64}]}
        self.pngs = {}
        for index, (_target_id, filename, size) in enumerate(exporter.TARGETS):
            stream = io.BytesIO()
            Image.new("RGB", size, (index * 30, 40, 70)).save(stream, format="PNG")
            self.pngs[filename] = stream.getvalue()
        self.mutate = lambda output, stdout, stderr, godot: (stdout, stderr, godot)
        self.returncode, self.timeout, self.launch_error = 0, False, None
        self.commands, self.namespace_dirs = [], []
        self.stack = ExitStack()
        self.addCleanup(self.stack.close)
        self.environment = {key: value for key, value in os.environ.items() if key not in exporter.OVERRIDES}
        self.stack.enter_context(patch.dict(os.environ, self.environment, clear=True))
        self.console = self.stack.enter_context(patch.object(exporter, "require_console_unlocked",
                                                            return_value={"console_unlocked": True,
                                                                          "method": "synthetic_only"}))
        self.snapshot = self.stack.enter_context(patch.object(exporter, "source_snapshot",
                                                             side_effect=lambda root: copy.deepcopy(self.source)))
        self.stack.enter_context(patch.object(exporter.safety, "user_data_parent", return_value=self.user_parent))
        self.stack.enter_context(patch.object(exporter.safety, "install_handlers", return_value={}))
        self.stack.enter_context(patch.object(exporter.safety, "set_handlers"))
        self.kill = self.stack.enter_context(patch.object(exporter.safety, "kill_remaining_group", return_value=None))
        self.terminate = self.stack.enter_context(patch.object(exporter.safety, "terminate_tree", return_value=("", "", None)))
        self.popen = self.stack.enter_context(patch.object(exporter.subprocess, "Popen", side_effect=self.fake_popen))

    def fake_popen(self, command, **kwargs):
        if self.launch_error:
            raise self.launch_error
        self.commands.append((command, kwargs))
        output = Path(kwargs["env"]["GANGNAM_QA_OUT"])
        user_dir = self.user_parent / kwargs["env"]["STORY_NAMEPLATE_QA_NAMESPACE"]
        user_dir.mkdir()
        (user_dir / "fixture.txt").write_bytes(b"preserve QA fixture")
        self.namespace_dirs.append(user_dir)
        for filename, raw in self.pngs.items():
            (output / filename).write_bytes(raw)
        pre = f"STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR={user_dir}\n"
        done = f"STEAM_CAPSULE_EXPORT_DONE count=4 dir={output}\n"
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

    def run_render(self, **kwargs):
        return exporter.render(kwargs.get("parent", self.outputs), str(kwargs.get("engine", self.engine)),
                               kwargs.get("timeout", 10), self.root)

    def preserved(self):
        self.assertEqual(self.sentinel.read_bytes(), b"preserve approved output")
        for directory in self.namespace_dirs:
            self.assertEqual((directory / "fixture.txt").read_bytes(), b"preserve QA fixture")

    def rejected_render(self):
        before = set(self.outputs.iterdir())
        with self.assertRaises((ValueError, OSError)):
            self.run_render()
        created = set(self.outputs.iterdir()) - before
        self.assertEqual(len(created), 1)
        output = created.pop()
        self.assertFalse((output / "manifest.json").exists())
        self.assertTrue((output / "render-start.json").is_file())
        self.assertTrue((output / "stdout.log").is_file())
        self.assertTrue((output / "stderr.log").is_file())
        report = json.loads((output / "render-result.json").read_bytes())
        self.assertEqual(report["status"], "failed")
        self.assertTrue(report["errors"])
        self.preserved()
        return output, report

    def contract_mutation(self, mutate):
        path = self.root / exporter.CONTRACT_FILE
        contract = json.loads(path.read_bytes())
        mutate(contract)
        path.write_text(json.dumps(contract))

    def test_source_only_contract_check_has_no_native_claim(self):
        before = {name: (self.root / name).read_bytes() for name in self.input_paths}
        report = exporter.check_contract(self.root)
        self.assertEqual(report["scope"], "source_contract_only")
        self.assertEqual([row["size"] for row in report["capsules"]], [[1232, 706], [920, 430], [462, 174], [748, 896]])
        for key in ("gdscript_compiled", "native_render", "human_observation", "visual_review",
                    "package_identity_verified", "release_approved"):
            self.assertIs(report[key], False)
        self.assertEqual(before, {name: (self.root / name).read_bytes() for name in self.input_paths})
        self.popen.assert_not_called()
        self.console.assert_not_called()

    def test_renderer_avoids_namespace_reserved_identifier(self):
        script = (self.root / exporter.RENDERER).read_text()
        self.assertNotRegex(script, r"\bvar\s+namespace\b")
        self.assertIn('var qa_namespace := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")', script)
        self.assertIn('pattern.search(qa_namespace)', script)
        self.assertIn('OS.get_user_data_dir().get_file() != qa_namespace', script)

    def test_contract_rejects_wrong_schema_master_extra_text_and_dimensions(self):
        path = self.root / exporter.CONTRACT_FILE
        original = path.read_bytes()
        for mutate in (
                lambda value: value.update(schema_version=True),
                lambda value: value["master"].update(sha256="0" * 64),
                lambda value: value["master"].update(file="../elsewhere.png"),
                lambda value: value["capsules"][0].update(subtitle="NOT ALLOWED"),
                lambda value: value["capsules"][0].update(size=[616, 353]),
                lambda value: value["capsules"][0].update(file="../outside.png"),
                lambda value: value["capsules"].reverse(),
                lambda value: value["capsules"].pop(),
                lambda value: value["capsules"][2].update(subjects=["daeun"]),
                lambda value: value["capsules"][0].update(font_size=True),
                lambda value: value["capsules"][0].update(font_size=121)):
            with self.subTest(mutate=mutate):
                path.write_bytes(original)
                self.contract_mutation(mutate)
                with self.assertRaises(ValueError):
                    exporter.load_contract(self.root)
        path.write_bytes(original)

    def test_contract_rejects_bad_rectangles(self):
        path = self.root / exporter.CONTRACT_FILE
        original = path.read_bytes()
        for field, value in (("source_crop", [-1, 0, 1, 1]), ("source_crop", [0, 0, 1921, 1080]),
                             ("art_rect", [0, 0, 1233, 706]), ("title_rect", [0, 0, 0, 1]),
                             ("title_rect", [0, 0, 1.0, 1]), ("source_crop", [0, 0, 10])):
            with self.subTest(field=field, value=value):
                path.write_bytes(original)
                self.contract_mutation(lambda contract: contract["capsules"][0].update({field: value}))
                with self.assertRaises(ValueError):
                    exporter.load_contract(self.root)

    def test_duplicate_json_keys_rejected(self):
        path = self.root / exporter.CONTRACT_FILE
        raw = path.read_text()
        path.write_text(raw.replace('"schema_version": 1', '"schema_version": 1, "schema_version": 1', 1))
        with self.assertRaisesRegex(ValueError, "duplicate JSON"):
            exporter.load_contract(self.root)

    def test_master_drift_and_source_symlinks_rejected(self):
        master = self.root / exporter.MASTER_FILE
        original = master.read_bytes()
        master.write_bytes(original + b"drift")
        with self.assertRaisesRegex(ValueError, "master bytes"):
            exporter.load_contract(self.root)
        master.write_bytes(original)
        target = self.root / exporter.RENDERER
        outside = self.base / "elsewhere.gd"
        target.rename(outside)
        target.symlink_to(outside)
        with self.assertRaisesRegex(ValueError, "symlink"):
            exporter.load_contract(self.root)

    def test_missing_native_bindings_and_wrong_scene_rejected(self):
        gd = self.root / exporter.RENDERER
        gd.write_text(gd.read_text().replace("STEAM_CAPSULE_EXPORT_DONE count=4 dir=%s", "unbound"))
        with self.assertRaisesRegex(ValueError, "binding"):
            exporter.load_contract(self.root)
        gd.write_bytes((exporter.ROOT / exporter.RENDERER).read_bytes())
        scene = self.root / exporter.SCENE
        scene.write_text(scene.read_text().replace("SteamCapsuleExport.gd", "Other.gd"))
        with self.assertRaisesRegex(ValueError, "binding"):
            exporter.load_contract(self.root)

    def test_success_fresh_storage_all_sizes_raw_receipts_and_no_old_writes(self):
        before_inputs = {name: (self.root / name).read_bytes() for name in self.input_paths}
        output = self.run_render()
        command, kwargs = self.commands[0]
        self.assertEqual(command[command.index("--script") + 1], "res://tools/StoryNameplateBootstrap.gd")
        self.assertEqual(command[command.index("--scene") + 1], "res://tools/SteamCapsuleExport.tscn")
        self.assertNotIn("KeyArtExport.tscn", " ".join(command))
        self.assertEqual(kwargs["cwd"], self.root)
        self.assertEqual(kwargs["env"]["GANGNAM_QA_OUT"], str(output))
        for key in ("HOME", "XDG_DATA_HOME", "XDG_CONFIG_HOME", "APPDATA"):
            self.assertEqual(kwargs["env"].get(key), self.environment.get(key))
        self.kill.assert_called_once()
        self.terminate.assert_not_called()
        self.assertEqual(self.snapshot.call_count, 2)
        result_bytes = (output / "render-result.json").read_bytes()
        report = json.loads(result_bytes)
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["candidate"], self.source["candidate"])
        self.assertEqual(report["source_manifest_sha256"], exporter.sha((output / "source-manifest.json").read_bytes()))
        self.assertEqual(len(report["streams"]), 3)
        for key in ("native_play", "human_observation", "visual_review", "package_identity_verified",
                    "release_approved", "previous_outputs_deleted"):
            self.assertIs(report[key], False)
        manifest = json.loads((output / "manifest.json").read_bytes())
        self.assertEqual(manifest["render_record"], {"file": "render-result.json", "sha256": exporter.sha(result_bytes)})
        self.assertIn("title_readability", manifest["unverified"])
        self.assertEqual([row["size"] for row in manifest["images"]], [[1232, 706], [920, 430], [462, 174], [748, 896]])
        for row in manifest["images"]:
            self.assertEqual(row["sha256"], exporter.sha((output / row["file"]).read_bytes()))
            with Image.open(output / row["file"]) as image:
                self.assertEqual(list(image.size), row["size"])
        self.assertEqual(before_inputs, {name: (self.root / name).read_bytes() for name in self.input_paths})
        self.preserved()

    def test_repeated_runs_create_distinct_directories_and_namespaces(self):
        first = self.run_render()
        second = self.run_render()
        self.assertNotEqual(first, second)
        self.assertNotEqual(*self.namespace_dirs)
        self.assertTrue((first / "manifest.json").is_file())
        self.preserved()

    def test_locked_unknown_console_refused_before_output_or_launch(self):
        self.console.side_effect = ValueError("locked/unknown console")
        with self.assertRaisesRegex(ValueError, "console"):
            self.run_render()
        self.assertEqual(list(self.outputs.iterdir()), [self.sentinel])
        self.popen.assert_not_called()

    def test_wrong_paths_symlink_repository_userdata_missing_parent(self):
        link = self.base / "output-link"
        link.symlink_to(self.outputs, target_is_directory=True)
        nested_source = self.root / "nested"
        nested_source.mkdir()
        nested_user = self.user_parent / "nested"
        nested_user.mkdir()
        for parent in (link, self.root, nested_source, self.user_parent, nested_user, self.base / "missing"):
            with self.subTest(parent=parent), self.assertRaises((ValueError, OSError)):
                self.run_render(parent=parent)
        self.popen.assert_not_called()

    def test_timeout_values_and_engine_admission(self):
        for value in (True, 0, -1, 1801, 1.5):
            with self.subTest(timeout=value), self.assertRaises(ValueError):
                self.run_render(timeout=value)
        self.engine.chmod(0o600)
        with self.assertRaisesRegex(ValueError, "executable"):
            self.run_render()
        self.popen.assert_not_called()

    def test_unknown_userdata_parent_refused(self):
        with patch.object(exporter.safety, "user_data_parent", return_value=None):
            with self.assertRaisesRegex(ValueError, "user-data"):
                self.run_render()
        self.popen.assert_not_called()

    def test_existing_namespace_and_inherited_overrides_refused(self):
        for key in exporter.OVERRIDES:
            with patch.dict(os.environ, {key: ""}), self.assertRaisesRegex(ValueError, "override"):
                self.run_render()
        namespace = exporter.safety.PREFIX + "0" * 32
        (self.user_parent / namespace).mkdir()
        with patch.object(exporter.secrets, "token_hex", return_value="0" * 32):
            with self.assertRaisesRegex(ValueError, "pre-existing"):
                self.run_render()
        self.popen.assert_not_called()
        self.assertEqual(list(self.outputs.iterdir()), [self.sentinel])

    def test_dirty_source_refused_before_launch(self):
        self.snapshot.side_effect = ValueError("dirty source fixture")
        with self.assertRaisesRegex(ValueError, "dirty source"):
            self.run_render()
        self.popen.assert_not_called()
        self.assertEqual(list(self.outputs.iterdir()), [self.sentinel])

    def test_source_and_engine_drift_rejected(self):
        changed = copy.deepcopy(self.source)
        changed["files"][0]["sha256"] = "0" * 64
        self.snapshot.side_effect = [self.source, changed]
        self.rejected_render()
        self.snapshot.side_effect = lambda root: copy.deepcopy(self.source)
        def mutate(output, stdout, stderr, godot):
            self.engine.write_bytes(b"changed executable fixture")
            return stdout, stderr, godot
        self.mutate = mutate
        self.rejected_render()

    def test_contract_drift_during_process_rejected(self):
        def mutate(output, stdout, stderr, godot):
            self.contract_mutation(lambda contract: contract["capsules"][0].update(font_size=53))
            return stdout, stderr, godot
        self.mutate = mutate
        _, report = self.rejected_render()
        self.assertTrue(any("changed during render" in error for error in report["errors"]))

    def test_nonzero_and_launch_failure_and_timeout(self):
        self.returncode = 2
        self.rejected_render()
        self.returncode = 0
        self.launch_error = OSError("synthetic launch failure")
        self.rejected_render()
        self.launch_error = None
        self.timeout = True
        self.rejected_render()
        self.terminate.assert_called_once()

    def test_remaining_process_group_error_rejected(self):
        self.kill.return_value = "synthetic process-group remained"
        self.rejected_render()

    def test_markers_missing_duplicate_wrong_namespace_count_and_order(self):
        def mutations(raw):
            lines = raw.splitlines(keepends=True)
            return (b"".join(lines[1:]), raw + lines[0], raw + lines[1],
                    raw.replace(b"count=4", b"count=3"), raw.replace(b"PRE_AUTOLOAD", b"WRONG"),
                    b"".join(reversed(lines)), raw.replace(b"dir=", b"wrong_dir="),
                    raw.replace(b"_StoryNameplateQA_", b"_Other_"))
        for index in range(8):
            with self.subTest(index=index):
                self.mutate = lambda output, stdout, stderr, godot: (mutations(stdout)[index], stderr, godot)
                self.rejected_render()

    def test_stderr_markers_do_not_supply_stdout_evidence(self):
        self.mutate = lambda output, stdout, stderr, godot: (b"", stdout, godot)
        self.rejected_render()

    def test_each_raw_stream_scans_errors_and_leaks(self):
        for stream in range(3):
            for error in (b"SCRIPT ERROR: fixture", b"Parse Error: fixture", b"Compile Error: fixture",
                          b"ERROR: fixture", b"ObjectDB instances leaked", b"resources still in use",
                          b"STEAM_CAPSULE_EXPORT_FAIL fixture"):
                with self.subTest(stream=stream, error=error):
                    def mutate(output, stdout, stderr, godot):
                        streams = [stdout, stderr, godot]
                        streams[stream] += error + b"\n"
                        return tuple(streams)
                    self.mutate = mutate
                    self.rejected_render()

    def test_missing_or_non_utf8_logs_rejected(self):
        for stream in range(3):
            with self.subTest(stream=stream):
                def mutate(output, stdout, stderr, godot):
                    streams = [stdout, stderr, godot]
                    streams[stream] += b"\xff"
                    return tuple(streams)
                self.mutate = mutate
                self.rejected_render()
        self.mutate = lambda output, stdout, stderr, godot: (stdout, stderr, None)
        self.rejected_render()

    def test_symlink_log_refused_without_touching_external_bytes(self):
        outside = self.base / "external-godot.log"
        outside.write_bytes(b"preserve external log")
        def mutate(output, stdout, stderr, godot):
            (output / "godot.log").symlink_to(outside)
            return stdout, stderr, None
        self.mutate = mutate
        self.rejected_render()
        self.assertEqual(outside.read_bytes(), b"preserve external log")

    def test_nonfatal_warning_is_kept_in_raw_log_and_report(self):
        self.mutate = lambda output, stdout, stderr, godot: (stdout, stderr, godot + b"WARNING: synthetic retained warning\n")
        output = self.run_render()
        report = json.loads((output / "render-result.json").read_bytes())
        self.assertEqual(report["warning_lines"], ["WARNING: synthetic retained warning"])
        self.assertIn(b"WARNING: synthetic retained warning", (output / "godot.log").read_bytes())

    def test_missing_extra_corrupt_wrong_size_and_symlink_images(self):
        filename = exporter.TARGETS[0][1]
        mutations = (
            lambda output: (output / filename).unlink(),
            lambda output: (output / "stale.PNG").write_bytes(b"stale fixture"),
            lambda output: (output / filename).write_bytes(b"corrupt fixture"),
            lambda output: Image.new("RGB", (616, 353)).save(output / filename),
        )
        for mutation in mutations:
            with self.subTest(mutation=mutation):
                def mutate(output, stdout, stderr, godot):
                    mutation(output)
                    return stdout, stderr, godot
                self.mutate = mutate
                self.rejected_render()
        outside = self.base / "outside-image.png"
        outside.write_bytes(self.pngs[filename])
        def symlink(output, stdout, stderr, godot):
            (output / filename).unlink()
            (output / filename).symlink_to(outside)
            return stdout, stderr, godot
        self.mutate = symlink
        self.rejected_render()
        self.assertEqual(outside.read_bytes(), self.pngs[filename])

    def test_duplicate_wrong_mode_and_animated_images_rejected(self):
        filename, other = exporter.TARGETS[0][1], exporter.TARGETS[1][1]
        def duplicate(output):
            (output / other).write_bytes((output / filename).read_bytes())
        def grayscale(output):
            Image.new("L", (1232, 706), 40).save(output / filename)
        def animated(output):
            Image.new("RGB", (1232, 706)).save(output / filename, save_all=True,
                append_images=[Image.new("RGB", (1232, 706), (255, 255, 255))], duration=100, loop=0)
        for mutation in (duplicate, grayscale, animated):
            with self.subTest(mutation=mutation):
                def mutate(output, stdout, stderr, godot):
                    mutation(output)
                    return stdout, stderr, godot
                self.mutate = mutate
                self.rejected_render()

    def test_manifest_publication_failure_keeps_partial_without_success(self):
        actual = exporter.write_new
        def fail(path, raw):
            if path.name == "manifest.pending.json":
                raise OSError("synthetic publication failure")
            actual(path, raw)
        with patch.object(exporter, "write_new", side_effect=fail):
            with self.assertRaisesRegex(OSError, "publication failure"):
                self.run_render()
        outputs = list(self.outputs.glob("gangnam-steam-capsules-*"))
        self.assertEqual(len(outputs), 1)
        self.assertTrue((outputs[0] / "render-result.json").is_file())
        self.assertFalse((outputs[0] / "manifest.json").exists())
        self.preserved()


class ConsoleTests(unittest.TestCase):
    def test_verified_mac_unlocked_only(self):
        with patch.object(exporter.sys, "platform", "darwin"):
            for text in (b'"IOConsoleLocked" = Yes', b"", b'"IOConsoleLocked" = No\n"IOConsoleLocked" = No'):
                with self.subTest(text=text), patch.object(exporter.subprocess, "run",
                        return_value=subprocess.CompletedProcess([], 0, stdout=text)):
                    with self.assertRaises(ValueError):
                        exporter.require_console_unlocked()
            with patch.object(exporter.subprocess, "run", return_value=subprocess.CompletedProcess(
                    [], 0, stdout=b'"IOConsoleLocked" = No')):
                self.assertTrue(exporter.require_console_unlocked()["console_unlocked"])

    def test_other_os_and_probe_failure_refused(self):
        with patch.object(exporter.sys, "platform", "linux"), self.assertRaisesRegex(ValueError, "macOS"):
            exporter.require_console_unlocked()
        with patch.object(exporter.sys, "platform", "darwin"), patch.object(exporter.subprocess, "run",
                side_effect=subprocess.TimeoutExpired("ioreg", 10)), self.assertRaises(subprocess.TimeoutExpired):
            exporter.require_console_unlocked()


class CLITests(unittest.TestCase):
    def test_default_check_never_starts_engine(self):
        with patch.object(exporter.sys, "argv", ["steam_capsule_export.py"]), \
                patch.object(exporter.subprocess, "Popen") as popen, redirect_stdout(io.StringIO()) as output:
            self.assertEqual(exporter.main(), 0)
        self.assertIn("STEAM_CAPSULE_CHECK_OK count=4 scope=source_contract_only engine_runs=0", output.getvalue())
        popen.assert_not_called()

    def test_render_requires_explicit_mode_and_all_arguments(self):
        for args in (["--godot", "/fixture"], ["--output-parent", "/fixture"], ["--render"],
                     ["--render", "--godot", "/fixture"], ["--render", "--output-parent", "/fixture"]):
            with self.subTest(args=args), patch.object(exporter.sys, "argv", ["steam_capsule_export.py", *args]), \
                    patch.object(exporter.subprocess, "Popen") as popen, redirect_stdout(io.StringIO()) as output, \
                    redirect_stderr(io.StringIO()):
                self.assertEqual(exporter.main(), 1)
                self.assertNotIn("STEAM_CAPSULE_RENDER_OK", output.getvalue())
                popen.assert_not_called()


if __name__ == "__main__":
    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__]))
    if result.wasSuccessful():
        print(f"STEAM_CAPSULE_EXPORT_SELF_TEST_OK tests={result.testsRun} synthetic_only=1 engine_runs=0")
    raise SystemExit(0 if result.wasSuccessful() else 1)

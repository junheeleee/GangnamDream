#!/usr/bin/env python3
"""Capture eight English store sources in fresh pre-autoload-isolated storage.

Graphical execution is an explicit separate task. Self-tests mock the process;
neither they nor a receipt certify visual quality or a release package.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import secrets
import stat
import subprocess
import sys
import tempfile
import time

import run_routine_background_context_check as safety
from store_shot_export import (json_bytes, load_contract, read_regular, sha,
                               write_new, SOURCE_SIZE)

ROOT = Path(__file__).resolve().parents[1]
OVERRIDES = ("STORY_NAMEPLATE_QA_NAMESPACE", "GANGNAM_QA_OUT",
             "STORY_DEMO_QA_BOOTSTRAP_NAME", "STORY_DEMO_ALLOW_ISOLATED_QA",
             "GANGNAM_QA_USER_DIR")
FAILURE = re.compile(r"SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|"
                     r"\bERROR:|STORY_NAMEPLATE_CHECK_FAIL|SCREENSHOT_QA_FAIL|"
                     r"ObjectDB instances leaked|resources still in use", re.I)


def git(root: Path, *args: str) -> bytes:
    return subprocess.run(["git", "-C", str(root), *args], check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          timeout=30).stdout


def file_pin(path: Path) -> dict:
    """Hash regular source files without loading large audio assets into RAM."""
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, "rb") as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode):
            raise ValueError(f"not a regular source file: {path}")
        digest = hashlib.sha256()
        blob = hashlib.sha1(b"blob " + str(info.st_size).encode("ascii") + b"\0")
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
            blob.update(chunk)
    return {"bytes": info.st_size, "sha256": digest.hexdigest(), "git_blob": blob.hexdigest()}


def source_snapshot(root: Path) -> dict:
    """Do not infer clean source from HEAD while changed/untracked files exist."""
    if git(root, "status", "--porcelain=v1", "-z", "--untracked-files=all"):
        raise ValueError("capture requires a clean dedicated source checkout; preserve existing work")
    commit = git(root, "rev-parse", "HEAD").decode().strip()
    tree = git(root, "rev-parse", "HEAD^{tree}").decode().strip()
    for value in (commit, tree):
        if not re.fullmatch(r"[0-9a-f]{40}", value):
            raise ValueError("unsupported source Git identity")
    paths = [os.fsdecode(p) for p in git(root, "ls-files", "-z").split(b"\0") if p]
    expected = {}
    for entry in git(root, "ls-tree", "-r", "-z", "HEAD").split(b"\0"):
        if not entry:
            continue
        metadata, name = entry.split(b"\t", 1)
        mode, kind, oid = metadata.split()
        if kind != b"blob" or mode not in (b"100644", b"100755"):
            raise ValueError("source tree contains non-regular entries")
        expected[os.fsdecode(name)] = oid.decode("ascii")
    if set(paths) != set(expected):
        raise ValueError("index file roster differs from source commit")
    files = []
    for name in paths:
        path = root / name
        if any(p.is_symlink() for p in (path, *path.parents)):
            raise ValueError(f"source symlink refused: {name}")
        pin = file_pin(path)
        if pin["git_blob"] != expected[name]:
            raise ValueError(f"source bytes differ from committed blob: {name}")
        files.append({"file": name, **pin})
    build = read_regular(root / "systems/BuildInfo.gd").decode("utf-8")
    matches = re.findall(r'^const BUILD_ID := "([A-Za-z0-9._-]{1,80})"$', build, re.M)
    if len(matches) != 1:
        raise ValueError("source BUILD_ID is missing or ambiguous")
    # Detect edits during the manifest read, not only before it.
    if git(root, "status", "--porcelain=v1", "-z", "--untracked-files=all"):
        raise ValueError("source changed during manifest read")
    return {"candidate": {"source_commit": commit, "source_tree": tree,
                          "build_id": matches[0]}, "files": files}


def plain_directory(path: Path) -> Path:
    path = path.absolute()
    if any(p.is_symlink() for p in (path, *path.parents)):
        raise ValueError(f"symlink directory refused: {path}")
    resolved = path.resolve(strict=True)
    if not resolved.is_dir():
        raise ValueError(f"not a directory: {path}")
    return resolved


def validate_frames(output: Path) -> list[dict]:
    try:
        from PIL import Image
    except ImportError as exc:
        raise ValueError("capture validation requires Pillow") from exc
    contract, _ = load_contract()
    expected = [entry["src"] for entry in contract]
    actual = sorted(p.name for p in output.iterdir() if p.suffix.lower() == ".png")
    if actual != sorted(expected):
        raise ValueError("fresh PNG roster differs from the canonical eight frames")
    frames, seen = [], set()
    for name in expected:
        data = read_regular(output / name)
        digest = sha(data)
        if digest in seen:
            raise ValueError("duplicate capture frames")
        with Image.open(io.BytesIO(data)) as image:
            if (image.format != "PNG" or image.size != SOURCE_SIZE or
                    image.mode not in ("RGB", "RGBA") or getattr(image, "n_frames", 1) != 1):
                raise ValueError(f"expected single RGB/RGBA PNG 1280x800: {name}")
            image.verify()
        with Image.open(io.BytesIO(data)) as image:
            image.load()
        frames.append({"file": name, "sha256": digest})
        seen.add(digest)
    return frames


def marker_errors(stdout: str, output: Path, user_dir: Path) -> list[str]:
    pre = "STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=" + str(user_dir)
    done = "SCREENSHOT_QA_DONE scope=store lang=en dir=" + str(output)
    errors = []
    if re.findall(r"(?m)^STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=[^\r\n]*$", stdout) != [pre]:
        errors.append("exact pre-autoload namespace marker absent/duplicate")
    if re.findall(r"(?m)^SCREENSHOT_QA_DONE[^\r\n]*$", stdout) != [done]:
        errors.append("exact store completion marker absent/duplicate")
    if pre in stdout and done in stdout and stdout.index(pre) > stdout.index(done):
        errors.append("isolation marker follows completion")
    return errors


def capture(output_parent: Path, godot: str, timeout: int, root: Path = ROOT) -> Path:
    if type(timeout) is not int or not 1 <= timeout <= 1800:
        raise ValueError("timeout must be 1..1800 seconds")
    for key in OVERRIDES:
        if key in os.environ:
            raise ValueError("refusing inherited QA override: " + key)
    parent = plain_directory(output_parent)
    root = plain_directory(root)
    if parent == root or root in parent.parents:
        raise ValueError("capture output parent must be outside the source repository")
    user_parent = safety.user_data_parent()
    if user_parent is None:
        raise ValueError("unknown Godot user-data parent")
    user_parent = plain_directory(user_parent)
    # Never make ScreenshotQA clear a user-data subtree, even a new child.
    if parent == user_parent or user_parent in parent.parents:
        raise ValueError("capture output must be outside Godot user-data storage")
    engine = Path(godot).absolute().resolve(strict=True)
    if not engine.is_file() or not os.access(engine, os.X_OK):
        raise ValueError("Godot must be an executable file")
    engine_pin = file_pin(engine)
    before = source_snapshot(root)
    from PIL import Image  # Validate dependency before launching anything.
    del Image
    namespace = safety.PREFIX + secrets.token_hex(16)
    user_dir = user_parent / namespace
    if os.path.lexists(user_dir):
        raise ValueError("refusing pre-existing QA namespace")
    output = Path(tempfile.mkdtemp(prefix="gangnam-store-capture-", dir=parent))
    write_new(output / "source-manifest.json", json_bytes(before))
    env = os.environ.copy()
    env.update(STORY_NAMEPLATE_QA_NAMESPACE=namespace, GANGNAM_QA_OUT=str(output))
    command = [str(engine), "--path", str(root), "--rendering-driver", "opengl3",
               "--audio-driver", "Dummy", "--resolution", "1280x800", "--max-fps", "60",
               "--log-file", str(output / "godot.log"),
               "--script", "res://tools/StoryNameplateBootstrap.gd",
               "--scene", "res://tools/ScreenshotQA.tscn", "--", "--qa=store", "--lang=en"]
    record = {"schema_version": 1, "scope": "isolated_store_capture", "language": "en",
              "candidate": before["candidate"], "command": command, "engine": engine_pin,
              "expected_user_dir": str(user_dir), "source_manifest_sha256":
              sha(json_bytes(before)), "native_play": False, "human_observation": False,
              "visual_review": False, "package_identity_verified": False,
              "previous_outputs_deleted": False}
    write_new(output / "capture-start.json", json_bytes(record))
    started, process, errors = time.monotonic(), None, []
    with (output / "stdout.log").open("xb") as out, (output / "stderr.log").open("xb") as err:
        flags = {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == "nt" else {"start_new_session": True}
        handlers = safety.install_handlers()
        try:
            process = subprocess.Popen(command, cwd=root, env=env, stdout=out, stderr=err, **flags)
            record["pid"] = process.pid
            process.communicate(timeout=timeout)
            safety.set_handlers(handlers, True)
            group_error = safety.kill_remaining_group(process)
            if group_error:
                errors.append(group_error)
        except BaseException as exc:
            safety.set_handlers(handlers, True)
            errors.append("process failed: " + repr(exc))
            if process is not None:
                _, _, group_error = safety.terminate_tree(process)
                if group_error:
                    errors.append(group_error)
        finally:
            safety.set_handlers(handlers, False)
    record.update(engine_exit=process.returncode if process else None,
                  seconds=round(time.monotonic() - started, 6))
    streams, pins = [], []
    for name in ("stdout.log", "stderr.log", "godot.log"):
        try:
            raw = read_regular(output / name)
            pins.append({"file": name, "bytes": len(raw), "sha256": sha(raw)})
            streams.append(raw.decode("utf-8"))
        except (OSError, ValueError, UnicodeError) as exc:
            streams.append("")
            errors.append(f"invalid/missing {name}: {exc}")
    record["streams"] = pins
    errors += marker_errors(streams[0], output, user_dir)
    record["error_lines"] = [line for stream in streams for line in stream.splitlines() if FAILURE.search(line)]
    record["warning_lines"] = [line for stream in streams for line in stream.splitlines() if "WARNING:" in line]
    if record["error_lines"] or record["engine_exit"] != 0:
        errors.append("engine exit/error/leak check failed")
    try:
        frames = validate_frames(output)
        after = source_snapshot(root)
        record["source_after_sha256"] = sha(json_bytes(after))
        if after != before or file_pin(engine) != engine_pin:
            errors.append("capture source/engine changed during process")
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        frames = []
        errors.append("frames/source validation failed: " + repr(exc))
    record.update(status="failed" if errors else "passed", errors=errors,
                  frames=frames, storage_retained=str(user_dir))
    capture_bytes = json_bytes(record)
    write_new(output / "capture-result.json", capture_bytes)
    if errors:
        raise ValueError(f"capture incomplete; preserve raw evidence at {output}: {'; '.join(errors)}")
    receipt = {"schema_version": 1, "language": "en", "candidate": before["candidate"],
               "capture_record": {"file": "capture-result.json", "sha256": sha(capture_bytes)},
               "frames": frames}
    write_new(output / "receipt.pending.json", json_bytes(receipt))
    # Exclusive publication only after every original and raw log validates.
    os.link(output / "receipt.pending.json", output / "receipt.json")
    return output


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-parent", type=Path, required=True)
    parser.add_argument("--godot", required=True, help="trusted official Godot executable")
    parser.add_argument("--timeout", type=int, default=600)
    args = parser.parse_args()
    try:
        output = capture(args.output_parent, args.godot, args.timeout)
    except (OSError, ValueError, ImportError, subprocess.SubprocessError) as exc:
        print(f"STORE_SHOT_CAPTURE_ERROR {exc}", file=sys.stderr)
        return 1
    print(f"STORE_SHOT_CAPTURE_OK count=8 language=en scope=isolated_source_capture dir={output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

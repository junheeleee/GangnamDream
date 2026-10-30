#!/usr/bin/env python3
"""Check the current capsule contract, or explicitly render into fresh storage.

Default checking never starts Godot. Actual rendering requires a clean source
checkout, a trusted executable, and an unlocked macOS console. Neither source
checks nor mocked tests certify rendered art, package identity, or publication.
"""
from __future__ import annotations

import argparse
import io
import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import sys
import tempfile
import time

from store_shot_capture import (file_pin, plain_directory, source_snapshot,
                                OVERRIDES, safety)
from store_shot_export import json_bytes, read_regular, sha, write_new

ROOT = Path(__file__).resolve().parents[1]
MASTER_FILE = "assets/keyart/gangnam_dream_keyart_cast_v1.png"
MASTER_SHA = "3883727682c02ab78e3ce0980800a4aa04912a939b363d31ceed5496072c388b"
TARGETS = (
    ("main", "steam_capsule_main.png", (1232, 706)),
    ("header", "steam_header.png", (920, 430)),
    ("small", "steam_capsule_small.png", (462, 174)),
    ("vertical", "steam_capsule_vertical.png", (748, 896)),
)
CONTRACT_FILE = "tools/steam_capsules.json"
RENDERER = "tools/SteamCapsuleExport.gd"
SCENE = "tools/SteamCapsuleExport.tscn"
FAILURE = re.compile(r"SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|"
                     r"\bERROR:|STORY_NAMEPLATE_CHECK_FAIL|STEAM_CAPSULE_EXPORT_FAIL|"
                     r"ObjectDB instances leaked|resources still in use", re.I)


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def exact_keys(value, keys, label):
    if not isinstance(value, dict) or set(value) != set(keys):
        raise ValueError(f"invalid {label} fields")


def rectangle(value, bounds, label):
    if (not isinstance(value, list) or len(value) != 4 or
            any(type(number) is not int for number in value)):
        raise ValueError(f"invalid {label} rectangle")
    x, y, width, height = value
    if min(x, y) < 0 or min(width, height) < 1 or x + width > bounds[0] or y + height > bounds[1]:
        raise ValueError(f"{label} exceeds its source/target bounds")


def load_contract(root: Path = ROOT) -> tuple[dict, list[dict]]:
    """Read-only schema/source binding, not a GDScript compile or art judgment."""
    root = plain_directory(root)
    paths = (CONTRACT_FILE, RENDERER, SCENE, MASTER_FILE,
             "scenes/ui/GangnamWordmark.gd", "tools/StoryNameplateBootstrap.gd")
    for name in paths:
        path = root / name
        if any(parent.is_symlink() for parent in (path, *path.parents)):
            raise ValueError(f"source symlink refused: {name}")
    raw = read_regular(root / CONTRACT_FILE)
    contract = json.loads(raw, object_pairs_hook=unique_object)
    exact_keys(contract, ("schema_version", "master", "capsules"), "contract")
    if type(contract["schema_version"]) is not int or contract["schema_version"] != 1:
        raise ValueError("capsule contract schema_version must be 1")
    master = contract["master"]
    exact_keys(master, ("file", "sha256", "size"), "master")
    if master != {"file": MASTER_FILE, "sha256": MASTER_SHA, "size": [1920, 1080]}:
        raise ValueError("approved master identity differs")
    from PIL import Image
    master_bytes = read_regular(root / MASTER_FILE)
    if sha(master_bytes) != MASTER_SHA:
        raise ValueError("approved master bytes differ")
    with Image.open(io.BytesIO(master_bytes)) as image:
        if image.format != "PNG" or image.size != (1920, 1080):
            raise ValueError("approved master dimensions differ")
        image.verify()
    capsules = contract["capsules"]
    if not isinstance(capsules, list) or len(capsules) != 4:
        raise ValueError("capsule contract needs four ordered targets")
    for row, (target_id, filename, size) in zip(capsules, TARGETS):
        exact_keys(row, ("id", "file", "size", "font_size", "source_crop",
                         "art_rect", "title_rect", "subjects"), "capsule")
        if row["id"] != target_id or row["file"] != filename or row["size"] != list(size):
            raise ValueError("capsule target order/name/current dimensions differ")
        if type(row["font_size"]) is not int or not 10 <= row["font_size"] <= 120:
            raise ValueError("invalid title font size")
        rectangle(row["source_crop"], (1920, 1080), "source_crop")
        rectangle(row["art_rect"], size, "art_rect")
        rectangle(row["title_rect"], size, "title_rect")
        subjects = ["minjun"] if target_id == "small" else ["minjun", "daeun", "jiyeon"]
        if row["subjects"] != subjects:
            raise ValueError("capsule subject scope differs")
    script = read_regular(root / RENDERER).decode("utf-8")
    scene = read_regular(root / SCENE).decode("utf-8")
    for token in ("res://tools/steam_capsules.json", "res://scenes/ui/GangnamWordmark.gd",
                  "STEAM_CAPSULE_EXPORT_DONE count=4 dir=%s", "GANGNAM_QA_OUT",
                  "STORY_NAMEPLATE_QA_NAMESPACE", "get_combined_minimum_size()",
                  'WordmarkScript.new(int(spec["font_size"]), "")'):
        if token not in script:
            raise ValueError(f"renderer source binding absent: {token}")
    if scene.count('path="res://tools/SteamCapsuleExport.gd"') != 1:
        raise ValueError("capsule scene renderer binding differs")
    pins = [{"file": name, **file_pin(root / name)} for name in paths]
    return contract, pins


def check_contract(root: Path = ROOT) -> dict:
    contract, pins = load_contract(root)
    return {"schema_version": 1, "scope": "source_contract_only", "capsules":
            [{"id": row["id"], "file": row["file"], "size": row["size"]}
             for row in contract["capsules"]], "input_pins": pins,
            "gdscript_compiled": False, "native_render": False, "human_observation": False,
            "visual_review": False, "package_identity_verified": False, "release_approved": False}


def require_console_unlocked() -> dict:
    if sys.platform != "darwin":
        raise ValueError("actual capsule render currently supports verified macOS consoles only")
    result = subprocess.run(["ioreg", "-l", "-n", "Root", "-d", "1"], check=True,
                            capture_output=True, timeout=10)
    output = result.stdout.decode("utf-8")
    if re.findall(r'"IOConsoleLocked"\s*=\s*(Yes|No)', output) != ["No"]:
        raise ValueError("locked/unknown console; no render was started")
    return {"console_unlocked": True, "method": "ioreg.IOConsoleLocked",
            "observation_sha256": sha(result.stdout)}


def marker_errors(stdout: str, output: Path, user_dir: Path) -> list[str]:
    pre = "STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=" + str(user_dir)
    done = "STEAM_CAPSULE_EXPORT_DONE count=4 dir=" + str(output)
    errors = []
    if re.findall(r"(?m)^STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=[^\r\n]*$", stdout) != [pre]:
        errors.append("exact pre-autoload namespace marker absent/duplicate")
    if re.findall(r"(?m)^STEAM_CAPSULE_EXPORT_DONE[^\r\n]*$", stdout) != [done]:
        errors.append("exact capsule completion marker absent/duplicate")
    if pre in stdout and done in stdout and stdout.index(pre) > stdout.index(done):
        errors.append("isolation marker follows completion")
    return errors


def validate_images(output: Path) -> list[dict]:
    from PIL import Image
    actual = sorted(path.name for path in output.iterdir() if path.suffix.lower() == ".png")
    if actual != sorted(row[1] for row in TARGETS):
        raise ValueError("fresh PNG roster differs from four current capsules")
    images, seen = [], set()
    for target_id, filename, size in TARGETS:
        raw = read_regular(output / filename)
        digest = sha(raw)
        if digest in seen:
            raise ValueError("duplicate capsule images")
        with Image.open(io.BytesIO(raw)) as image:
            if (image.format != "PNG" or image.size != size or image.mode not in ("RGB", "RGBA")
                    or getattr(image, "n_frames", 1) != 1):
                raise ValueError(f"invalid current {target_id} PNG; expected {size[0]}x{size[1]}")
            image.verify()
        with Image.open(io.BytesIO(raw)) as image:
            image.load()
        images.append({"id": target_id, "file": filename, "size": list(size),
                       "bytes": len(raw), "sha256": digest})
        seen.add(digest)
    return images


def render(output_parent: Path, godot: str, timeout: int, root: Path = ROOT) -> Path:
    if type(timeout) is not int or not 1 <= timeout <= 1800:
        raise ValueError("timeout must be 1..1800 seconds")
    for key in OVERRIDES:
        if key in os.environ:
            raise ValueError("refusing inherited QA override: " + key)
    console = require_console_unlocked()
    root, parent = plain_directory(root), plain_directory(output_parent)
    if parent == root or root in parent.parents:
        raise ValueError("capsule output parent must be outside the source repository")
    user_parent = safety.user_data_parent()
    if user_parent is None:
        raise ValueError("unknown Godot user-data parent")
    user_parent = plain_directory(user_parent)
    if parent == user_parent or user_parent in parent.parents:
        raise ValueError("capsule output must be outside Godot user-data storage")
    engine = Path(godot).absolute().resolve(strict=True)
    if not engine.is_file() or not os.access(engine, os.X_OK):
        raise ValueError("Godot must be a trusted executable file")
    engine_pin = file_pin(engine)
    contract, contract_pins = load_contract(root)
    before = source_snapshot(root)
    namespace = safety.PREFIX + secrets.token_hex(16)
    user_dir = user_parent / namespace
    if os.path.lexists(user_dir):
        raise ValueError("refusing pre-existing QA namespace")
    output = Path(tempfile.mkdtemp(prefix="gangnam-steam-capsules-", dir=parent))
    source_bytes = json_bytes(before)
    write_new(output / "source-manifest.json", source_bytes)
    env = os.environ.copy()
    env.update(STORY_NAMEPLATE_QA_NAMESPACE=namespace, GANGNAM_QA_OUT=str(output))
    command = [str(engine), "--path", str(root), "--rendering-driver", "opengl3",
               "--audio-driver", "Dummy", "--resolution", "1280x800", "--max-fps", "60",
               "--log-file", str(output / "godot.log"), "--script",
               "res://tools/StoryNameplateBootstrap.gd", "--scene", "res://" + SCENE]
    record = {"schema_version": 1, "scope": "isolated_capsule_source_render",
              "candidate": before["candidate"], "command": command, "engine": engine_pin,
              "console": console, "expected_user_dir": str(user_dir), "input_pins": contract_pins,
              "source_manifest_sha256": sha(source_bytes), "native_play": False,
              "human_observation": False, "visual_review": False,
              "package_identity_verified": False, "release_approved": False,
              "previous_outputs_deleted": False}
    write_new(output / "render-start.json", json_bytes(record))
    started, process, errors = time.monotonic(), None, []
    with (output / "stdout.log").open("xb") as stdout, (output / "stderr.log").open("xb") as stderr:
        flags = {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == "nt" else {"start_new_session": True}
        handlers = safety.install_handlers()
        try:
            process = subprocess.Popen(command, cwd=root, env=env, stdout=stdout, stderr=stderr, **flags)
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
    streams, stream_pins = [], []
    for name in ("stdout.log", "stderr.log", "godot.log"):
        try:
            raw = read_regular(output / name)
            stream_pins.append({"file": name, "bytes": len(raw), "sha256": sha(raw)})
            streams.append(raw.decode("utf-8"))
        except (OSError, ValueError, UnicodeError) as exc:
            streams.append("")
            errors.append(f"invalid/missing {name}: {exc}")
    record["streams"] = stream_pins
    errors += marker_errors(streams[0], output, user_dir)
    record["error_lines"] = [line for stream in streams for line in stream.splitlines() if FAILURE.search(line)]
    record["warning_lines"] = [line for stream in streams for line in stream.splitlines() if "WARNING:" in line]
    if record["error_lines"] or record["engine_exit"] != 0:
        errors.append("engine exit/error/leak check failed")
    images = []
    try:
        images = validate_images(output)
        after = source_snapshot(root)
        after_contract, after_pins = load_contract(root)
        record["source_after_sha256"] = sha(json_bytes(after))
        if after != before or after_contract != contract or after_pins != contract_pins or file_pin(engine) != engine_pin:
            errors.append("source/contract/engine changed during render")
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        errors.append("image/source validation failed: " + repr(exc))
    record.update(status="failed" if errors else "passed", errors=errors, images=images,
                  storage_retained=str(user_dir))
    result_bytes = json_bytes(record)
    write_new(output / "render-result.json", result_bytes)
    if errors:
        raise ValueError(f"render incomplete; preserve raw evidence at {output}: {'; '.join(errors)}")
    manifest = {"schema_version": 1, "scope": "capsule_render_contract_only",
                "candidate": before["candidate"], "images": images,
                "render_record": {"file": "render-result.json", "sha256": sha(result_bytes)},
                "input_pins": contract_pins, "unverified": ["visual_quality", "title_readability",
                    "character_crop", "native_reader", "human_observation", "package_identity", "release_approval"]}
    write_new(output / "manifest.pending.json", json_bytes(manifest))
    os.link(output / "manifest.pending.json", output / "manifest.json")
    return output


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--check", action="store_true", help="source-only check (default); no engine")
    modes.add_argument("--render", action="store_true", help="explicit graphical render; unlocked macOS only")
    parser.add_argument("--godot", help="trusted official Godot executable")
    parser.add_argument("--output-parent", type=Path)
    parser.add_argument("--timeout", type=int, default=600)
    args = parser.parse_args()
    try:
        if not args.render:
            if args.godot or args.output_parent:
                raise ValueError("--godot/--output-parent require explicit --render")
            report = check_contract()
            print("STEAM_CAPSULE_CHECK_OK count=4 scope=source_contract_only engine_runs=0")
            print(json.dumps(report, ensure_ascii=False, indent=2))
        else:
            if not args.godot or args.output_parent is None:
                raise ValueError("--render requires --godot and --output-parent")
            output = render(args.output_parent, args.godot, args.timeout)
            print(f"STEAM_CAPSULE_RENDER_OK count=4 scope=capsule_render_contract_only dir={output}")
    except (OSError, ValueError, ImportError, SyntaxError, subprocess.SubprocessError) as exc:
        print(f"STEAM_CAPSULE_EXPORT_ERROR {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

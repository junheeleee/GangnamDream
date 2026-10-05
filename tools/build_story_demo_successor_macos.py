#!/usr/bin/env python3
"""Export an isolated local story-demo successor; never assert runtime/release GO.

Only main() performs work. The five byte transforms are pure, exact and usable by
the separate auditor's synthetic tests. Existing public outputs are read-only.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import plistlib
import re
import signal
import subprocess
import sys
import tarfile
import tempfile
import time
import uuid

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
BUILD = "2026.10.05.1"
GODOT_VERSION = "4.6.2.stable.official.71f334935"
FINDERINFO_HEX = "0000000000000000200000000000000000000000000000000000000000000000"
ENTRY = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
CHANGED = ("project.godot", "export_presets.cfg",
           "playtests/order124/StoryChoiceM1M6Playtest.gd", "tools/StoryDemoFourLanguageCheck.gd")
GENERATED_UIDS = ("tools/RoutineBackgroundInputCheck.gd.uid",
                  "tools/order103_export/AudioManagerStub.gd.uid",
                  "tools/order103_export/Entry.gd.uid")
SUPPORT = Path("/Users/junheelee/Library/Application Support")
PLAYER = SUPPORT / "Godot/app_userdata/강남드림"
PENDING = ["no_argument_boot", "new_save", "cold_resume", "story_return_input",
           "five_locale_screens", "old_public_save_copy_compatibility"]
ERRORS = re.compile(r"(?im)^.*(?:SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|"
                    r"Failed loading resource|ERROR:|FATAL:|Traceback \(most recent call last\)|"
                    r"_FAIL(?:\s|:|$)).*$")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def identity_for(build_id, attempt):
    require(type(build_id) is str and build_id == BUILD, "unsupported BUILD")
    require(type(attempt) is str and re.fullmatch(r"[a-z][a-z0-9-]{0,31}", attempt), "invalid attempt")
    return {"build_id": build_id, "attempt": attempt,
            "app_stem": "GangnamDream-StoryDemo-Successor-" + build_id + "-" + attempt,
            "bundle_id": "dev.junheelee.gangnamdream.storydemo.successor." + attempt,
            "app_version": "2026.10.5", "preset_name": "macOS StoryDemo Successor",
            "artifact_namespace": "GangnamDream_StoryDemo_Successor_2026_10_05_1_" + attempt,
            "output_rel": "build/story_demo_successor/" + build_id + "/" + attempt,
            "entry_scene": ENTRY, "profile": "story_demo_rc"}


def _identity(identity):
    require(type(identity) is dict and identity == identity_for(identity.get("build_id"), identity.get("attempt")),
            "identity fields differ")


def _section_replace(raw, section, replacements):
    """Replace each exact old line once; None means the key must be absent."""
    require(type(raw) is bytes and b"\r" not in raw, "source must be LF UTF-8 bytes")
    raw.decode("utf-8", errors="strict")
    heading = ("[" + section + "]\n").encode()
    require(raw.count(heading) == 1, "section absent/duplicate: " + section)
    start = raw.index(heading) + len(heading)
    end = raw.find(b"\n[", start)
    if end == -1:
        end = len(raw)
    body = raw[start:end]
    for key, old, new in replacements:
        prefix = key.encode() + b"="
        lines = [line for line in body.splitlines(keepends=True) if line.startswith(prefix)]
        replacement = prefix + new.encode() + b"\n"
        if old is None:
            require(not lines, "unexpected existing key: " + key)
            require(body.endswith(b"\n"), "section missing terminal LF")
            body += replacement
        else:
            expected = prefix + old.encode() + b"\n"
            require(lines == [expected], "source key/occurrence differs: " + key)
            body = body.replace(expected, replacement, 1)
    return raw[:start] + body + raw[end:]


def project_bytes(original, identity, namespace):
    _identity(identity)
    require(type(namespace) is str and (namespace == identity["artifact_namespace"] or
            re.fullmatch(r"GangnamDream_StoryDemo_RuntimeQA_[A-Za-z0-9_-]+", namespace)), "invalid namespace")
    return _section_replace(original, "application", (
        ("config/name", '"강남드림"', json.dumps(identity["app_stem"])),
        ("run/main_scene", '"res://scenes/SplashScreen.tscn"', json.dumps(ENTRY)),
        ("boot_splash/image", '"res://assets/logos/gangnam_dream_logo_concept.png"', '""'),
        ("config/use_custom_user_dir", None, "true"),
        ("config/custom_user_dir_name", None, json.dumps(namespace)),
        ("boot_splash/show_image", None, "false")))


def presets_bytes(original, identity):
    _identity(identity)
    # Select the original macOS preset, never a new reduced export filter.
    text = original.decode("utf-8", errors="strict")
    matches = []
    for match in re.finditer(r"(?m)^\[preset\.(\d+)\]\n", text):
        body = text[match.end():].split("\n[", 1)[0]
        if 'name="macOS"\n' in body and 'platform="macOS"\n' in body:
            matches.append(match.group(1))
    require(len(matches) == 1, "original macOS preset absent/duplicate")
    section = "preset." + matches[0]
    block = text.split("[" + section + "]\n", 1)[1].split("\n[", 1)[0]
    for line in ('export_filter="all_resources"',
                 'include_filter="assets/fonts/*.txt, assets/fonts/*.md, assets/audio/*.md, assets/third_party/*.txt, assets/third_party/*.json"',
                 'exclude_filter="tools/*, docs/*, build/*"'):
        require(block.splitlines().count(line) == 1, "export filter differs")
    result = _section_replace(original, section, (
        ("name", '"macOS"', json.dumps(identity["preset_name"])),
        ("export_path", '"build/macos/GangnamDream.zip"', json.dumps(identity["app_stem"] + ".zip"))))
    return _section_replace(result, section + ".options", (
        ("application/bundle_identifier", '"dev.junheelee.gangnamdream"', json.dumps(identity["bundle_id"])),
        ("application/short_version", '""', json.dumps(identity["app_version"])),
        ("application/version", '""', json.dumps(identity["app_version"]))))


def _replace_once(raw, old, new):
    require(type(raw) is bytes and raw.count(old) == 1, "exact source line absent/duplicate")
    return raw.replace(old, new, 1)


def controller_bytes(original, identity):
    _identity(identity)
    require(original.count(b'const PUBLIC_PROFILE := "story_demo_rc"\n') == 1
            and original.count(b'const PUBLIC_SAVE_PATH := "user://story_demo_save.json"\n') == 1,
            "controller profile/save format differs")
    result = _replace_once(original, b'const PUBLIC_BUILD_ID := "2026.08.31.1"\n',
                           ('const PUBLIC_BUILD_ID := "' + identity["build_id"] + '"\n').encode())
    return _replace_once(result, b'const PUBLIC_CUSTOM_USER_DIR := "GangnamDream_StoryDemo_v1"\n',
                         ('const PUBLIC_CUSTOM_USER_DIR := "' + identity["artifact_namespace"] + '"\n').encode())


def check_bytes(original, identity):
    _identity(identity)
    return _replace_once(original, b'const PUBLIC_BUILD_ID := "2026.08.31.1"\n',
                         ('const PUBLIC_BUILD_ID := "' + identity["build_id"] + '"\n').encode())


def no_symlink(path):
    path = Path(path).absolute()
    require(all(not item.is_symlink() for item in (path, *path.parents)), "symlink path: " + str(path))
    return path


def require_fresh_path(path):
    """Read-only admission shared by the real builder and synthetic tests."""
    path = no_symlink(path)
    require(not os.path.lexists(path), "path already exists: " + str(path))
    return path


def parse_finderinfo_hex(text):
    """Only the exact observed candidate-root FinderInfo is removable."""
    require(type(text) is str, "FinderInfo output is not text")
    value = "".join(text.split()).lower()
    require(value == FINDERINFO_HEX, "unreviewed FinderInfo value")
    return value


def file_record(path):
    path = no_symlink(path)
    require(path.is_file(), "file missing: " + str(path))
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return {"path": str(path), "sha256": digest.hexdigest(), "size": path.stat().st_size}


def snapshot(label, path):
    path = no_symlink(path)
    entries = []
    candidates = ([path] if path.is_file() else sorted(path.rglob("*"))) if path.exists() else []
    for item in candidates:
        relative = "." if item == path else item.relative_to(path).as_posix()
        if item.is_symlink():
            entries.append({"path": relative, "kind": "symlink", "target": os.readlink(item)})
        elif item.is_file():
            record = file_record(item)
            entries.append({"path": relative, "kind": "file", "sha256": record["sha256"], "size": record["size"]})
        else:
            require(item.is_dir(), "protected special file: " + str(item))
    return {"label": label, "path": str(path), "exists": path.exists(), "entries": entries}


def protected(extra):
    paths = [("product_project_godot", ROOT / "project.godot"),
             ("product_export_presets", ROOT / "export_presets.cfg"),
             ("human_gates", ROOT / "docs/human_gates.json"),
             ("public_story_demo_build", ROOT / "build/story_demo"),
             ("public_story_demo_user_data", SUPPORT / "GangnamDream_StoryDemo_v1"),
             ("retail_player_files", PLAYER)]
    paths.extend(("extra_" + str(index), Path(path)) for index, path in enumerate(extra))
    return [snapshot(label, path) for label, path in paths]


def git(*args):
    return subprocess.check_output(["git", "--no-replace-objects", "-C", str(ROOT), *args], stderr=subprocess.PIPE)


def source_state():
    return {"head": git("rev-parse", "HEAD").decode().strip(),
            "tree": git("rev-parse", "HEAD^{tree}").decode().strip(),
            "status": git("status", "--porcelain=v1", "--untracked-files=all").decode()}


def write_json(path, value):
    with no_symlink(path).open("x", encoding="utf-8") as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def clean_environment():
    return {key: value for key, value in os.environ.items()
            if not key.startswith(("STORY_DEMO_", "ORDER124_", "GODOT_", "GIT_"))
            and key not in ("PYTHONPATH", "PYTHONHOME")}


def run_command(rows, logs, name, argv, cwd, env, namespace=None, marker=None, godot_log=None, timeout=600):
    stdout, stderr = logs / (name + ".stdout.log"), logs / (name + ".stderr.log")
    require(not stdout.exists() and not stderr.exists(), "command logs already exist")
    started = time.monotonic()
    row = {"name": name, "argv": [str(arg) for arg in argv], "cwd": str(cwd), "namespace": namespace,
           "expected_marker": marker, "exit_code": None, "elapsed_seconds": 0.0,
           "stdout": None, "stderr": None, "godot_log": None}
    rows.append(row)
    error = None
    process = None
    try:
        with stdout.open("xb") as out, stderr.open("xb") as err:
            process = subprocess.Popen(row["argv"], cwd=cwd, env=env, stdout=out, stderr=err, start_new_session=True)
            try:
                row["exit_code"] = process.wait(timeout=timeout)
            except BaseException:
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGTERM)
                    try:
                        process.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid, signal.SIGKILL)
                        process.wait(timeout=10)
                row["exit_code"] = process.returncode
                raise
    except BaseException as exc:
        error = exc
    finally:
        row["elapsed_seconds"] = round(time.monotonic() - started, 6)
        row["stdout"], row["stderr"] = file_record(stdout), file_record(stderr)
        if godot_log is not None and Path(godot_log).is_file():
            row["godot_log"] = file_record(godot_log)
    if error is not None:
        raise error
    require(row["exit_code"] == 0, "command failed: " + name)
    if godot_log is not None:
        require(row["godot_log"] is not None, "Godot log absent: " + name)
    for field in ("stdout", "stderr", "godot_log"):
        if row[field] is not None:
            text = Path(row[field]["path"]).read_text(encoding="utf-8")
            require(not ERRORS.search(text), "error in " + name + " " + field)
    if marker is not None:
        require(stdout.read_text(encoding="utf-8").splitlines().count(marker) == 1,
                "exact success marker absent/duplicate: " + name)


def extract_archive(archive_path, stage):
    with tarfile.open(archive_path, "r:") as archive:
        names = set()
        for item in archive.getmembers():
            value = item.name.rstrip("/")
            path = PurePosixPath(value)
            require(value and not path.is_absolute() and "\\" not in value
                    and not any(part in ("", ".", "..") for part in value.split("/"))
                    and value not in names and (item.isfile() or item.isdir()), "unsafe Git archive member")
            names.add(value)
        # Python 3.9 has no extraction filter. Every member above is a unique,
        # relative regular file/directory, and stage is a fresh private tree.
        archive.extractall(stage)


def stage_inventory(stage):
    result = {}
    for path in sorted(stage.rglob("*")):
        relative = path.relative_to(stage).as_posix()
        if relative == ".godot" or relative.startswith(".godot/"):
            continue
        require(not path.is_symlink(), "staging contains symlink: " + relative)
        require(path.is_file() or path.is_dir(), "staging special file: " + relative)
        if path.is_file():
            record = file_record(path)
            result[relative] = {"sha256": record["sha256"], "size": record["size"]}
    return result


def validate_stage(stage, baseline, expected):
    current = stage_inventory(stage)
    require(set(baseline) <= set(current), "tracked staging file removed")
    for name, record in baseline.items():
        wanted = {"sha256": sha(expected[name]), "size": len(expected[name])} if name in expected else record
        require(current[name] == wanted, "unowned staging bytes changed: " + name)
    extras = set(current) - set(baseline)
    require(extras <= set(GENERATED_UIDS), "unexpected generated staging files: " + repr(sorted(extras)))
    generated = []
    for name in GENERATED_UIDS:
        row = {"path": name, "exists": name in extras}
        if name in extras:
            require(re.fullmatch(rb"uid://[a-z0-9]+\n?", (stage / name).read_bytes()), "invalid generated UID")
            row.update(current[name])
        generated.append(row)
    return generated


def stage_shape_guard(stage, baseline, expected):
    """Cheap post-import guard; final validate_stage still hashes every file."""
    files = set()
    for path in stage.rglob("*"):
        relative = path.relative_to(stage).as_posix()
        if relative == ".godot" or relative.startswith(".godot/"):
            continue
        require(not path.is_symlink() and (path.is_file() or path.is_dir()), "unsafe staging entry")
        if path.is_file():
            files.add(relative)
    require(set(baseline) <= files and files - set(baseline) <= set(GENERATED_UIDS), "staging file population drift")
    for name, raw in expected.items():
        require((stage / name).read_bytes() == raw, "staging owned-source drift: " + name)
    for name in files - set(baseline):
        require(re.fullmatch(rb"uid://[a-z0-9]+\n?", (stage / name).read_bytes()), "invalid generated UID")


def build(args):
    require(sys.platform == "darwin", "macOS export/signing requires macOS")
    identity = identity_for(args.build_id, args.attempt)
    require(re.fullmatch(r"[0-9a-f]{40}", args.source), "source must be a full commit SHA")
    before = source_state()
    require(before["head"] == args.source and before["status"] == "", "source must be clean current HEAD")
    date = git("show", "-s", "--format=%cs", args.source).decode().strip()
    require(date == "2026-10-05", "source commit date differs from BUILD date")
    # Reject unsupported archive kinds before touching any output.
    for entry in git("ls-tree", "-r", "-z", args.source).split(b"\0"):
        if entry:
            require(entry.split(b" ", 1)[0] in (b"100644", b"100755"), "source contains symlink/submodule")
    godot = no_symlink(args.godot)
    require(Path(args.godot).is_absolute() and godot.is_file() and os.access(godot, os.X_OK), "invalid Godot executable")
    for tool in ("/usr/bin/ditto", "/usr/bin/codesign", "/usr/bin/xattr"):
        require(Path(tool).is_file(), "required macOS utility absent: " + tool)
    for path in args.protect:
        require(Path(path).is_absolute() and no_symlink(path).is_file(), "extra protection must be an existing absolute file")
    require(len(args.protect) == 3 and len(set(args.protect)) == 3, "provide the two seed files and W195 via three --protect paths")
    protections = protected(args.protect)
    player = next(row for row in protections if row["label"] == "retail_player_files")
    require(player["exists"] and len(player["entries"]) == 34, "actual player file census is not 34")
    output = require_fresh_path(ROOT / identity["output_rel"])
    require(output.is_relative_to(ROOT / "build/story_demo_successor"), "output escaped")
    namespace_path = require_fresh_path(SUPPORT / identity["artifact_namespace"])
    builder = Path(__file__).resolve()
    require(builder.read_bytes() == git("show", args.source + ":tools/build_story_demo_successor_macos.py"),
            "running builder differs from source commit")
    output.mkdir(parents=True, exist_ok=False)
    logs = output / "logs"
    logs.mkdir()
    work = Path(tempfile.mkdtemp(prefix="gangnamdream-story-demo-successor-", dir="/private/tmp")).resolve()
    stage = work / "source"
    stage.mkdir()
    qa = "GangnamDream_StoryDemo_RuntimeQA_successor_" + args.attempt.replace("-", "_") + "_" + uuid.uuid4().hex
    require(not no_symlink(SUPPORT / qa).exists(), "QA namespace already exists")
    env = clean_environment()
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    qa_env = dict(env, STORY_DEMO_ALLOW_ISOLATED_QA="1", STORY_DEMO_QA_BOOTSTRAP_NAME=qa)
    rows = []
    entry = {"unit": "ORDER-462", "status": "RUNNING", "identity": identity,
             "source": before, "staging": str(stage), "protected": protections}
    write_json(output / "entry.json", entry)
    manifest = None
    failure = None
    try:
        from story_demo_successor_package_audit import audit_manifest, package_inventory, safe_zip_members
        run_command(rows, logs, "godot_version", [godot, "--version"], work, env, marker=GODOT_VERSION, timeout=30)
        archive = work / "source.tar"
        run_command(rows, logs, "archive", ["git", "--no-replace-objects", "-C", ROOT,
                    "archive", "--format=tar", "--output=" + str(archive), args.source], work, env)
        extract_archive(archive, stage)
        baseline = stage_inventory(stage)
        original = {name: (stage / name).read_bytes() for name in CHANGED}
        qa_raw = {CHANGED[0]: project_bytes(original[CHANGED[0]], identity, qa),
                  CHANGED[1]: presets_bytes(original[CHANGED[1]], identity),
                  CHANGED[2]: controller_bytes(original[CHANGED[2]], identity),
                  CHANGED[3]: check_bytes(original[CHANGED[3]], identity)}
        artifact_raw = dict(qa_raw)
        artifact_raw[CHANGED[0]] = project_bytes(original[CHANGED[0]], identity, identity["artifact_namespace"])
        # Normal source validators run on the pristine archive; no old self-tests.
        localization = "STORY_DEMO_LOCALIZATION_OK locales=5 source_events=14 leaves=100 controller_ui=38 story_ui=82 target_ui=121"
        notice = json.loads((stage / "content/meta/third_party_notices.json").read_bytes())["summary"]
        third = ("THIRD_PARTY_NOTICE_OK components={component_entries} font_families={font_families} "
                 "font_files={font_files} audio_sources={audio_sources} audio_assets={audio_assets} "
                 "attribution_required_audio={attribution_required_audio_sources} presets=10").format(**notice)
        run_command(rows, logs, "localization", [sys.executable, "-B", stage / "tools/story_demo_localization_audit.py"], stage, env, marker=localization)
        run_command(rows, logs, "third_party", [sys.executable, "-B", stage / "tools/third_party_notice_audit.py"], stage, env, marker=third)
        for name, raw in qa_raw.items():
            (stage / name).write_bytes(raw)
        validate_stage(stage, baseline, qa_raw)

        def engine(name, tail, marker=None, exporting=False):
            log = logs / (name + ".godot.log")
            run_command(rows, logs, name, [godot, "--headless", "--path", stage, "--log-file", log, *tail],
                        stage, env if exporting else qa_env,
                        identity["artifact_namespace"] if exporting else qa, marker, log, 900)

        engine("import", ["--import"])
        stage_shape_guard(stage, baseline, qa_raw)
        engine("font", ["res://tools/FontRoutingCheck.tscn"],
               "FONT_ROUTING_CHECK_OK ko_en=Pretendard ja=NotoSansJP zh_cn=NotoSansSC zh_tw=NotoSansTC weights=400,600,700 emoji=last")
        engine("i18n", ["res://tools/I18nInfrastructureCheck.tscn"],
               "I18N_INFRASTRUCTURE_CHECK_OK targets=3 ui_fallback=en content_fallback=en")
        engine("five_locale", ["res://tools/StoryDemoFourLanguageCheck.tscn"],
               "STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=30 weeks=120 settlements=30 ap_surface=0 save=5 story=10 build=" + BUILD)
        (stage / CHANGED[0]).write_bytes(artifact_raw[CHANGED[0]])
        raw_zip = work / "raw.zip"
        engine("export", ["--export-release", identity["preset_name"], str(raw_zip)], exporting=True)
        safe_zip_members(raw_zip)
        unpacked = work / "unpacked"
        unpacked.mkdir()
        run_command(rows, logs, "extract_raw", ["/usr/bin/ditto", "-x", "-k", raw_zip, unpacked], work, env)
        apps = list(unpacked.glob("*.app"))
        require(len(apps) == 1, "export must contain one app")
        app = apps[0]
        plist_path = app / "Contents/Info.plist"
        plist = plistlib.loads(plist_path.read_bytes())
        executable = plist.get("CFBundleExecutable")
        require(type(executable) is str and executable and Path(executable).name == executable,
                "unsafe/missing exported executable")
        require(plist.get("CFBundleIdentifier") == identity["bundle_id"]
                and plist.get("CFBundleVersion") == identity["app_version"]
                and plist.get("CFBundleShortVersionString") == identity["app_version"], "exported bundle identity differs")
        for directory, suffix in (("Contents/MacOS", ""), ("Contents/Resources", ".pck")):
            old = no_symlink(app / directory / (executable + suffix))
            new = app / directory / (identity["app_stem"] + suffix)
            require(old.is_file(), "export payload absent")
            if old != new:
                require(not new.exists(), "renamed payload already exists")
                old.rename(new)
        plist.update(CFBundleExecutable=identity["app_stem"], CFBundleName=identity["app_stem"],
                     CFBundleDisplayName=identity["app_stem"])
        plist_path.write_bytes(plistlib.dumps(plist, sort_keys=False))
        named_app = unpacked / (identity["app_stem"] + ".app")
        if app != named_app:
            require(not named_app.exists(), "named app already exists")
            app.rename(named_app)
        run_command(rows, logs, "sign", ["/usr/bin/codesign", "--force", "--deep", "--sign", "-", "--options", "runtime", named_app], work, env)
        run_command(rows, logs, "verify_signed", ["/usr/bin/codesign", "--verify", "--deep", "--strict", named_app], work, env)
        macos = output / "macos"
        macos.mkdir()
        final_zip = macos / (identity["app_stem"] + ".zip")
        run_command(rows, logs, "zip", ["/usr/bin/ditto", "-c", "-k", "--sequesterRsrc", "--keepParent", named_app, final_zip], work, env)
        safe_zip_members(final_zip)
        # The delivered app is the re-extracted finalized ZIP, not its input.
        final_app = require_fresh_path(macos / (identity["app_stem"] + ".app"))
        run_command(rows, logs, "extract_final", ["/usr/bin/ditto", "-x", "-k", final_zip, macos], work, env)
        require(no_symlink(final_app).resolve() == output / "macos" / (identity["app_stem"] + ".app")
                and final_app.is_dir(), "metadata target is not the newly extracted app root")
        run_command(rows, logs, "attributes_before", ["/usr/bin/xattr", final_app], work, env)
        before_attrs = (logs / "attributes_before.stdout.log").read_text(encoding="utf-8").splitlines()
        require(len(before_attrs) == len(set(before_attrs)) and all(before_attrs), "invalid attribute listing")
        metadata = {"path": str(final_app), "attribute": "com.apple.FinderInfo",
                    "observed_hex": None, "removed": False}
        if "com.apple.FinderInfo" in before_attrs:
            run_command(rows, logs, "finderinfo_read", ["/usr/bin/xattr", "-px", "com.apple.FinderInfo", final_app], work, env)
            metadata["observed_hex"] = parse_finderinfo_hex((logs / "finderinfo_read.stdout.log").read_text(encoding="utf-8"))
            run_command(rows, logs, "finderinfo_remove", ["/usr/bin/xattr", "-d", "com.apple.FinderInfo", final_app], work, env)
            metadata["removed"] = True
        run_command(rows, logs, "attributes_after", ["/usr/bin/xattr", final_app], work, env)
        after_attrs = (logs / "attributes_after.stdout.log").read_text(encoding="utf-8").splitlines()
        require(len(after_attrs) == len(set(after_attrs)) and all(after_attrs)
                and set(after_attrs) == set(before_attrs) - {"com.apple.FinderInfo"},
                "FinderInfo remains or another attribute name changed")
        run_command(rows, logs, "verify_final", ["/usr/bin/codesign", "--verify", "--deep", "--strict", final_app], work, env)
        artifacts = package_inventory(final_app, final_zip, stage)
        generated = validate_stage(stage, baseline, artifact_raw)
        save_files = sorted(str(path.relative_to(namespace_path)) for path in namespace_path.rglob("*") if path.is_file())
        require(not save_files, "artifact namespace contains prior/runtime data")
        after, protections_after = source_state(), protected(args.protect)
        require(after == before and after["status"] == "", "source HEAD/tree/status drift")
        require(protections_after == protections, "protected inputs changed")
        manifest = {"schema_version": 1, "unit": "ORDER-462", "status": "EXPORTED_NOT_RUNTIME_VERIFIED",
                    "identity": identity, "source": {"commit": args.source, "tree": before["tree"],
                    "commit_date": date, "before": before, "after": after},
                    "builder": {"path": str(builder), "sha256": sha(builder.read_bytes()), "source_commit": args.source},
                    "staging": {"root": str(stage), "source": args.source, "git_archive_sha256": file_record(archive)["sha256"],
                    "changes": [{"path": name, "before_sha256": sha(original[name]), "qa_sha256": sha(qa_raw[name]),
                                 "artifact_sha256": sha(artifact_raw[name])} for name in CHANGED],
                    "generated_uid_files": generated}, "commands": rows, "artifacts": artifacts,
                    "artifact_paths": {"app": str(final_app), "zip": str(final_zip)},
                    "metadata_normalization": metadata,
                    "protected": {"before": protections, "after": protections_after},
                    "namespaces": {"artifact_before_exists": False, "artifact_after_save_files": [], "qa": [qa]},
                    "runtime": {"status": "NOT_RUN", "pending": PENDING}, "user_go": "NOT_INHERITED", "codesign": "ad-hoc"}
        pending = output / "MANIFEST.pending.json"
        write_json(pending, manifest)
        errors = audit_manifest(pending, source_root=ROOT)
        require(not errors, "independent manifest audit: " + "; ".join(errors))
    except BaseException as exc:
        failure = exc
    finally:
        final_errors = []
        try:
            final_source, final_protected = source_state(), protected(args.protect)
            if final_source != before:
                final_errors.append("source HEAD/tree/status drift")
            if final_protected != protections:
                final_errors.append("protected inputs changed")
        except Exception as exc:
            final_source, final_protected = None, None
            final_errors.append("final preservation read failed: " + repr(exc))
        result = {"unit": "ORDER-462", "all_pass": failure is None and not final_errors,
                  "status": "EXPORTED_NOT_RUNTIME_VERIFIED" if failure is None and not final_errors else "FAILED",
                  "runtime": "NOT_RUN", "source_after": final_source, "protected_after": final_protected,
                  "commands": rows, "staging": str(stage), "error": repr(failure) if failure else None,
                  "preservation_errors": final_errors}
        write_json(output / "result.json", result)
    if failure is not None:
        raise failure
    require(not final_errors, "; ".join(final_errors))
    # Final source/player protection completed before publishing this filename.
    require(not (output / "MANIFEST.json").exists(), "final manifest already exists")
    pending.rename(output / "MANIFEST.json")
    print("STORY_DEMO_SUCCESSOR_EXPORT_OK build=" + BUILD + " attempt=" + args.attempt + " runtime=NOT_RUN")
    print(str(output / "MANIFEST.json"))
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True)
    parser.add_argument("--build-id", required=True)
    parser.add_argument("--attempt", required=True)
    parser.add_argument("--godot", required=True)
    parser.add_argument("--protect", action="append", default=[])
    return build(parser.parse_args())


if __name__ == "__main__":
    raise SystemExit(main())

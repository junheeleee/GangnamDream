#!/usr/bin/env python3
"""Verify a separate local successor export, never grant runtime/release GO.

The self-test uses tiny synthetic ZIP/PCK fixtures and the builder's pure byte
transforms. It does not export, launch Godot, or run historical package audits.
"""
from __future__ import annotations

import argparse
from copy import deepcopy
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import plistlib
import re
import stat
import struct
import subprocess
import sys
import tempfile
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
BUILD = "2026.10.05.1"
ENTRY = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
CHANGED = ("project.godot", "export_presets.cfg",
           "playtests/order124/StoryChoiceM1M6Playtest.gd", "tools/StoryDemoFourLanguageCheck.gd")
PENDING = ["no_argument_boot", "new_save", "cold_resume", "story_return_input",
           "five_locale_screens", "old_public_save_copy_compatibility"]
ERRORS = re.compile(r"(?im)^.*(?:SCRIPT ERROR:|Parse Error:|Compile Error|Failed to load script|Failed loading resource|ERROR:|FATAL:|Traceback \(most recent call last\)|_FAIL(?:\s|:|$)).*$")
GENERATED_UIDS = ("tools/RoutineBackgroundInputCheck.gd.uid", "tools/order103_export/AudioManagerStub.gd.uid",
                  "tools/order103_export/Entry.gd.uid")
FINDERINFO_ATTRIBUTE = "com.apple.FinderInfo"
FINDERINFO_HEX = "0000000000000000200000000000000000000000000000000000000000000000"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def canonical(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def digest_stream(handle):
    digest = hashlib.sha256()
    while True:
        chunk = handle.read(1024 * 1024)
        if not chunk:
            return digest.hexdigest()
        digest.update(chunk)


def file_record(path):
    with Path(path).open("rb") as handle:
        digest = digest_stream(handle)
    return {"sha256": digest, "bytes": Path(path).stat().st_size}


def safe_relative(value):
    require(type(value) is str and value and "\\" not in value and "\x00" not in value,
            "invalid relative path")
    path = PurePosixPath(value)
    require(not path.is_absolute() and not any(part in (".", "..", "") for part in value.split("/"))
            and ":" not in path.parts[0], "relative path escapes its root")
    return path


def no_symlink(path):
    path = Path(path).absolute()
    require(all(not parent.is_symlink() for parent in (path, *path.parents)),
            "symlink path is not allowed: " + str(path))
    return path


def safe_zip_members(zip_path):
    """All entries get safety checks; only __MACOSX regular metadata is omitted."""
    no_symlink(zip_path)
    logical, names = [], set()
    with zipfile.ZipFile(zip_path) as archive:
        for item in archive.infolist():
            value = item.filename[:-1] if item.is_dir() else item.filename
            safe_relative(value)
            require(value not in names, "duplicate ZIP member: " + value)
            names.add(value)
            mode = item.external_attr >> 16
            kind = stat.S_IFMT(mode)
            require(kind in (0, stat.S_IFREG, stat.S_IFDIR), "ZIP symlink/special member: " + value)
            require(not item.flag_bits & 1, "encrypted ZIP member")
            require(item.is_dir() == (kind == stat.S_IFDIR) or kind == 0
                    or (not item.is_dir() and kind == stat.S_IFREG), "ZIP member type mismatch")
            if not item.is_dir() and not value.startswith("__MACOSX/"):
                logical.append(value)
    require(logical, "ZIP has no app files")
    return sorted(logical)


def app_inventory(app):
    app = no_symlink(app)
    require(app.is_dir() and app.suffix == ".app", "app directory missing")
    values = {}
    for item in sorted(app.rglob("*")):
        require(not item.is_symlink(), "app contains symlink")
        require(item.is_file() or item.is_dir(), "app contains special file")
        if item.is_file():
            relative = item.relative_to(app).as_posix()
            safe_relative(relative)
            values[relative] = file_record(item)
    require(values, "empty app")
    return values


def pck_inventory(pck, stage):
    # Reuse only these pure readers, never the old ledger or package audit.
    from release_content_inventory import (parse_pck_directory, pck_entry_bytes,
                                           validate_pck_payload_digests)
    header, entries, errors = parse_pck_directory(pck)
    require(not errors, "PCK directory: " + "; ".join(errors))
    require(header.get("format_version") == 3 and header.get("engine_version") == [4, 6, 2]
            and header.get("flags") == 2 and header.get("base_offset", 0) >= 112
            and header.get("entry_count") == len(entries) and entries,
            "PCK version/flags/population differs")
    normalized = {}
    for member, entry in entries.items():
        relative = member[6:] if member.startswith("res://") else member
        safe_relative(relative)
        require(relative not in normalized and entry["flags"] == 0, "PCK duplicate/encrypted entry")
        normalized[relative] = entry
    require("project.binary" in normalized and normalized["project.binary"]["size"] > 0,
            "PCK project.binary is absent/empty (its Variant identity is not runtime-verified)")
    content = {}
    with Path(pck).open("rb") as handle:
        errors = validate_pck_payload_digests(handle, header["base_offset"], entries)
        require(not errors, "PCK payload: " + "; ".join(errors))
        wanted = {item.relative_to(stage).as_posix(): item for item in (Path(stage) / "content").rglob("*.json")}
        actual = {name for name in normalized if name.startswith("content/") and name.endswith(".json")}
        require(wanted and actual == set(wanted), "PCK current content JSON population differs")
        for name, item in sorted(wanted.items()):
            no_symlink(item)
            raw = item.read_bytes()
            require(pck_entry_bytes(handle, header["base_offset"], normalized[name]) == raw,
                    "PCK current raw JSON differs: " + name)
            content[name] = {"sha256": sha(raw), "bytes": len(raw)}
    return {"path": str(Path(pck)), **file_record(pck), "entries": len(entries),
            "entry_paths_sha256": sha(("\n".join(sorted(entries)) + "\n").encode()),
            "content_json": content}


def package_inventory(app, zip_path, stage):
    app, zip_path, stage = no_symlink(app), no_symlink(zip_path), no_symlink(stage)
    values = app_inventory(app)
    members = safe_zip_members(zip_path)
    require(members == sorted(app.name + "/" + name for name in values), "ZIP/app logical file population differs")
    with zipfile.ZipFile(zip_path) as archive:
        for relative, record in values.items():
            name = app.name + "/" + relative
            with archive.open(name) as handle:
                require(digest_stream(handle) == record["sha256"]
                        and archive.getinfo(name).file_size == record["bytes"],
                        "ZIP/app logical bytes differ: " + relative)
    stem = app.stem
    launcher = app / "Contents/MacOS" / stem
    plist = app / "Contents/Info.plist"
    pck = app / "Contents/Resources" / (stem + ".pck")
    require(launcher.is_file() and launcher.stat().st_mode & 0o111, "app launcher missing/not executable")
    return {"app_files": values, "app_tree_sha256": sha(canonical(values)),
            "zip": file_record(zip_path),
            "launcher": {"path": str(launcher), **file_record(launcher)},
            "plist": {"path": str(plist), **file_record(plist)},
            "pck": pck_inventory(pck, stage)}


def load_json(raw):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            require(key not in result, "duplicate JSON key: " + key)
            result[key] = value
        return result
    return json.loads(raw, object_pairs_hook=unique,
                      parse_constant=lambda value: (_ for _ in ()).throw(ValueError("nonfinite JSON")))


def git(root, *args):
    return subprocess.check_output(["git", "--no-replace-objects", "-C", str(root), *args], stderr=subprocess.PIPE)


def expected_identity(build_id, attempt):
    require(build_id == BUILD and type(attempt) is str and re.fullmatch(r"[a-z][a-z0-9-]{0,31}", attempt),
            "invalid successor build/attempt")
    return {"build_id": BUILD, "attempt": attempt,
            "app_stem": "GangnamDream-StoryDemo-Successor-" + BUILD + "-" + attempt,
            "bundle_id": "dev.junheelee.gangnamdream.storydemo.successor." + attempt,
            "app_version": "2026.10.5", "preset_name": "macOS StoryDemo Successor",
            "artifact_namespace": "GangnamDream_StoryDemo_Successor_2026_10_05_1_" + attempt,
            "output_rel": "build/story_demo_successor/" + BUILD + "/" + attempt,
            "entry_scene": ENTRY, "profile": "story_demo_rc"}


def manifest_shape(data):
    require(type(data) is dict and type(data.get("schema_version")) is int and data["schema_version"] == 1
            and data.get("unit") == "ORDER-462" and data.get("status") == "EXPORTED_NOT_RUNTIME_VERIFIED",
            "manifest schema/export status differs")
    identity = data.get("identity")
    require(type(identity) is dict and identity == expected_identity(identity.get("build_id"), identity.get("attempt")),
            "manifest identity differs")
    require(data.get("runtime") == {"status": "NOT_RUN", "pending": PENDING}
            and data.get("user_go") == "NOT_INHERITED" and data.get("codesign") == "ad-hoc",
            "runtime/release/signature claim differs")
    source = data.get("source")
    require(type(source) is dict and re.fullmatch(r"[0-9a-f]{40}", str(source.get("commit", "")))
            and re.fullmatch(r"[0-9a-f]{40}", str(source.get("tree", "")))
            and source.get("commit_date") == "2026-10-05", "explicit source identity/date differs")
    require(source.get("before") == source.get("after")
            and source.get("before") == {"head": source["commit"], "tree": source["tree"], "status": ""},
            "source before/after is not the same clean candidate")


def section_delta(before, after, allowed):
    """Inspect permitted INI/Godot keys while retaining every other raw line."""
    def view(raw):
        section, rest, values = "", [], {}
        for line in raw.decode("utf-8").splitlines(keepends=True):
            match = re.fullmatch(r"\[([^\]]+)\]\r?\n?", line)
            if match:
                section = match.group(1)
            key = line.split("=", 1)[0] if "=" in line else None
            token = (section, key)
            if token in allowed:
                require(token not in values, "duplicate staged key")
                values[token] = line.rstrip("\r\n").split("=", 1)[1]
            else:
                rest.append(line)
        return values, rest
    _old, old_rest = view(before)
    values, new_rest = view(after)
    require(values == allowed and old_rest == new_rest, "staging changed an unowned key/raw line")


def stage_contract(before, after, identity, namespace):
    quoted = lambda value: json.dumps(value, ensure_ascii=False)
    section_delta(before[CHANGED[0]], after[CHANGED[0]], {
        ("application", "config/name"): quoted(identity["app_stem"]),
        ("application", "run/main_scene"): quoted(ENTRY),
        ("application", "config/use_custom_user_dir"): "true",
        ("application", "config/custom_user_dir_name"): quoted(namespace),
        ("application", "boot_splash/show_image"): "false",
        ("application", "boot_splash/image"): '""',
    })
    section_delta(before[CHANGED[1]], after[CHANGED[1]], {
        ("preset.1", "name"): quoted(identity["preset_name"]),
        ("preset.1", "export_path"): quoted(identity["app_stem"] + ".zip"),
        ("preset.1.options", "application/bundle_identifier"): quoted(identity["bundle_id"]),
        ("preset.1.options", "application/short_version"): quoted(identity["app_version"]),
        ("preset.1.options", "application/version"): quoted(identity["app_version"]),
    })
    for path, changes in ((CHANGED[2], ((b'const PUBLIC_BUILD_ID := "2026.08.31.1"',
                                        ('const PUBLIC_BUILD_ID := "' + BUILD + '"').encode()),
                                       (b'const PUBLIC_CUSTOM_USER_DIR := "GangnamDream_StoryDemo_v1"',
                                        ('const PUBLIC_CUSTOM_USER_DIR := "' + identity["artifact_namespace"] + '"').encode()))),
                          (CHANGED[3], ((b'const PUBLIC_BUILD_ID := "2026.08.31.1"',
                                        ('const PUBLIC_BUILD_ID := "' + BUILD + '"').encode()),))):
        value = before[path]
        for old, new in changes:
            require(value.count(old) == 1, "staging source constant missing/duplicate")
            value = value.replace(old, new, 1)
        require(after[path] == value, "staging changed unowned script bytes: " + path)


def tracked_stage(source_root, commit, stage, changes, identity, qa):
    rows = git(source_root, "ls-tree", "-r", "-z", commit).split(b"\0")
    owned, before, after = set(), {}, {}
    for row in rows:
        if not row:
            continue
        descriptor, path_raw = row.split(b"\t", 1)
        mode, kind, oid = descriptor.split()
        path = path_raw.decode("utf-8")
        safe_relative(path)
        require(kind == b"blob" and mode in (b"100644", b"100755"), "unsupported source archive entry")
        owned.add(path)
        item = no_symlink(stage / path)
        require(item.is_file(), "staging omitted tracked source: " + path)
        raw = item.read_bytes()
        if path in CHANGED:
            before[path] = git(source_root, "show", commit + ":" + path)
            after[path] = raw
        else:
            require(hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest().encode() == oid,
                    "staging unowned source drift: " + path)
    stage_contract(before, after, identity, identity["artifact_namespace"])
    require(type(changes) is list and len(changes) == 4 and {row.get("path") for row in changes} == set(CHANGED),
            "staging changed-path population differs")
    for row in changes:
        path = row["path"]
        qa_raw = after[path]
        if path == "project.godot":
            old = identity["artifact_namespace"].encode()
            require(qa_raw.count(old) == 1, "artifact namespace is not unique in project")
            qa_raw = qa_raw.replace(old, qa.encode(), 1)
        require(row == {"path": path, "before_sha256": sha(before[path]),
                        "qa_sha256": sha(qa_raw), "artifact_sha256": sha(after[path])},
                "staging transformation hashes differ")
    generated = {}
    for item in stage.rglob("*"):
        relative = item.relative_to(stage).as_posix()
        if relative == ".godot" or relative.startswith(".godot/"):
            continue
        require(not item.is_symlink(), "staging symlink")
        if item.is_file() and relative not in owned:
            require(relative in GENERATED_UIDS and re.fullmatch(rb"uid://[a-z0-9]+\n?", item.read_bytes()),
                    "unexpected generated staging file: " + relative)
            generated[relative] = file_record(item)
    return [{"path": name, "exists": name in generated,
             **({"sha256": generated[name]["sha256"], "size": generated[name]["bytes"]} if name in generated else {})}
            for name in GENERATED_UIDS]


def validate_log(row, output):
    require(type(row) is dict and type(row.get("name")) is str
            and type(row.get("argv")) is list and row["argv"]
            and all(type(arg) is str for arg in row["argv"])
            and type(row.get("exit_code")) is int and row["exit_code"] == 0,
            "command identity/exit differs")
    require(type(row.get("elapsed_seconds")) in (float, int) and row["elapsed_seconds"] >= 0,
            "command elapsed missing")
    texts = []
    for field in ("stdout", "stderr", "godot_log"):
        record = row.get(field)
        if record is None and field == "godot_log":
            continue
        require(type(record) is dict and set(record) == {"path", "sha256", "size"}, "command log shape differs")
        path = no_symlink(record["path"])
        require(path.is_relative_to(output), "command log escaped output")
        raw = path.read_bytes()
        require(type(record["size"]) is int and record["size"] == len(raw)
                and sha(raw) == record["sha256"], "command log bytes differ")
        text = raw.decode("utf-8", errors="strict")
        require(not ERRORS.search(text), "command contains failure/error: " + row["name"])
        texts.append(text)
    marker = row.get("expected_marker")
    require(marker is None or type(marker) is str and marker, "command marker type differs")
    if marker:
        require(sum(text.splitlines().count(marker) for text in texts[:1]) == 1,
                "command success marker missing/duplicate: " + row["name"])


def protected_snapshot(row):
    path = no_symlink(row["path"])
    entries = []
    candidates = ([path] if path.is_file() else sorted(path.rglob("*"))) if path.exists() else []
    for item in candidates:
        name = "." if item == path else item.relative_to(path).as_posix()
        if item.is_symlink():
            entries.append({"path": name, "kind": "symlink", "target": os.readlink(item)})
        elif item.is_file():
            record = file_record(item)
            entries.append({"path": name, "kind": "file", "sha256": record["sha256"], "size": record["bytes"]})
        else:
            require(item.is_dir(), "protected special file")
    return {"label": row["label"], "path": str(path), "exists": path.exists(), "entries": entries}


def metadata_contract(record, app, before_text, read_text, after_text):
    """Bind only the declared app-root FinderInfo removal to observed xattr logs."""
    require(type(record) is dict and set(record) == {"path", "attribute", "observed_hex", "removed"}
            and record["path"] == str(app) and record["attribute"] == FINDERINFO_ATTRIBUTE
            and type(record["removed"]) is bool, "metadata normalization identity differs")
    require(type(before_text) is str and type(after_text) is str, "attribute lists are not text")
    before, after = before_text.splitlines(), after_text.splitlines()
    require(len(before) == len(set(before)) and all(before)
            and len(after) == len(set(after)) and all(after), "invalid attribute listing")
    require(set(after) == set(before) - {FINDERINFO_ATTRIBUTE}, "attribute names changed outside FinderInfo removal")
    if record["removed"]:
        require(FINDERINFO_ATTRIBUTE in before and type(read_text) is str
                and "".join(read_text.split()).lower() == FINDERINFO_HEX
                and record["observed_hex"] == FINDERINFO_HEX,
                "FinderInfo removal lacks the exact observed value")
    else:
        require(FINDERINFO_ATTRIBUTE not in before and record["observed_hex"] is None and read_text is None,
                "absent FinderInfo has a removal/read claim")


def command_contract(rows, stage, output, source_root, source, identity, qa, metadata):
    require(type(metadata) is dict and type(metadata.get("removed")) is bool, "metadata removal type differs")
    names = ["godot_version", "archive", "localization", "third_party", "import", "font", "i18n",
             "five_locale", "export", "extract_raw", "sign", "verify_signed", "zip", "extract_final",
             "attributes_before"]
    if metadata["removed"]:
        names += ["finderinfo_read", "finderinfo_remove"]
    names += ["attributes_after", "verify_final"]
    require(type(rows) is list and [row.get("name") for row in rows] == names, "command population/order differs")
    notice = load_json(git(source_root, "show", source + ":content/meta/third_party_notices.json"))["summary"]
    markers = {
        "godot_version": "4.6.2.stable.official.71f334935",
        "localization": "STORY_DEMO_LOCALIZATION_OK locales=5 source_events=14 leaves=100 controller_ui=38 story_ui=82 target_ui=121",
        "third_party": ("THIRD_PARTY_NOTICE_OK components={component_entries} font_families={font_families} "
                        "font_files={font_files} audio_sources={audio_sources} audio_assets={audio_assets} "
                        "attribution_required_audio={attribution_required_audio_sources} presets=10").format(**notice),
        "font": "FONT_ROUTING_CHECK_OK ko_en=Pretendard ja=NotoSansJP zh_cn=NotoSansSC zh_tw=NotoSansTC weights=400,600,700 emoji=last",
        "i18n": "I18N_INFRASTRUCTURE_CHECK_OK targets=3 ui_fallback=en content_fallback=en",
        "five_locale": "STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=5 months=30 weeks=120 settlements=30 ap_surface=0 save=5 story=10 build=" + BUILD,
    }
    engine = rows[0]["argv"][0]
    require(Path(engine).is_absolute(), "engine path is not absolute")
    raw_zip, unpacked = stage.parent / "raw.zip", stage.parent / "unpacked"
    named_app = unpacked / (identity["app_stem"] + ".app")
    final_zip = output / "macos" / (identity["app_stem"] + ".zip")
    final_app = final_zip.with_suffix(".app")
    fixed = {
        "godot_version": [engine, "--version"],
        "archive": ["git", "--no-replace-objects", "-C", str(source_root), "archive", "--format=tar",
                    "--output=" + str(stage.parent / "source.tar"), source],
        "extract_raw": ["/usr/bin/ditto", "-x", "-k", str(raw_zip), str(unpacked)],
        "sign": ["/usr/bin/codesign", "--force", "--deep", "--sign", "-", "--options", "runtime", str(named_app)],
        "verify_signed": ["/usr/bin/codesign", "--verify", "--deep", "--strict", str(named_app)],
        "zip": ["/usr/bin/ditto", "-c", "-k", "--sequesterRsrc", "--keepParent", str(named_app), str(final_zip)],
        "extract_final": ["/usr/bin/ditto", "-x", "-k", str(final_zip), str(output / "macos")],
        "attributes_before": ["/usr/bin/xattr", str(final_app)],
        "finderinfo_read": ["/usr/bin/xattr", "-px", FINDERINFO_ATTRIBUTE, str(final_app)],
        "finderinfo_remove": ["/usr/bin/xattr", "-d", FINDERINFO_ATTRIBUTE, str(final_app)],
        "attributes_after": ["/usr/bin/xattr", str(final_app)],
        "verify_final": ["/usr/bin/codesign", "--verify", "--deep", "--strict", str(final_app)],
    }
    scenes = {"import": ["--import"], "font": ["res://tools/FontRoutingCheck.tscn"],
              "i18n": ["res://tools/I18nInfrastructureCheck.tscn"],
              "five_locale": ["res://tools/StoryDemoFourLanguageCheck.tscn"],
              "export": ["--export-release", identity["preset_name"], str(raw_zip)]}
    for row in rows:
        name = row["name"]
        validate_log(row, output)
        require(row.get("expected_marker") == markers.get(name), "declared marker changed: " + name)
        expected_ns = identity["artifact_namespace"] if name == "export" else qa if name in scenes else None
        require(row.get("namespace") == expected_ns, "command namespace differs: " + name)
        require(row.get("cwd") == str(stage if name in (*scenes, "localization", "third_party") else stage.parent),
                "command working directory differs: " + name)
        if name in scenes:
            log = output / "logs" / (name + ".godot.log")
            require(row["godot_log"] is not None and row["godot_log"]["path"] == str(log), "engine log not bound")
            wanted = [engine, "--headless", "--path", str(stage), "--log-file", str(log), *scenes[name]]
        elif name in ("localization", "third_party"):
            script = "story_demo_localization_audit.py" if name == "localization" else "third_party_notice_audit.py"
            wanted = [row["argv"][0], "-B", str(stage / "tools" / script)]
        else:
            wanted = fixed[name]
        require(row["argv"] == wanted, "command argv differs: " + name)
        if name in ("attributes_before", "finderinfo_read", "finderinfo_remove", "attributes_after"):
            require(row["godot_log"] is None, "attribute command has an unrelated Godot log")
    logs = {row["name"]: Path(row["stdout"]["path"]).read_text(encoding="utf-8")
            for row in rows if row["name"] in ("attributes_before", "finderinfo_read", "attributes_after")}
    metadata_contract(metadata, final_app, logs["attributes_before"], logs.get("finderinfo_read"), logs["attributes_after"])


def audit_manifest(path, source_root=ROOT):
    """Read-only verifier; metadata-only later commits do not invalidate source Git objects."""
    try:
        source_root, path = no_symlink(source_root), no_symlink(path)
        data = load_json(path.read_bytes())
        manifest_shape(data)
        identity, source = data["identity"], data["source"]
        output = source_root / identity["output_rel"]
        require(path.parent == output and path.name in ("MANIFEST.json", "MANIFEST.pending.json"), "manifest output path differs")
        require(git(source_root, "rev-parse", source["commit"] + "^{commit}").decode().strip() == source["commit"]
                and git(source_root, "rev-parse", source["commit"] + "^{tree}").decode().strip() == source["tree"]
                and git(source_root, "show", "-s", "--format=%cs", source["commit"]).decode().strip() == source["commit_date"],
                "actual Git source identity differs")
        builder = data["builder"]
        require(builder == {"path": str(source_root / "tools/build_story_demo_successor_macos.py"),
                            "source_commit": source["commit"],
                            "sha256": sha(git(source_root, "show", source["commit"] + ":tools/build_story_demo_successor_macos.py"))},
                "builder source identity differs")
        staging = data["staging"]
        stage = no_symlink(staging["root"])
        require(stage.is_absolute() and stage.is_dir() and not stage.is_relative_to(source_root)
                and not source_root.is_relative_to(stage) and staging["source"] == source["commit"],
                "staging is not an external source archive")
        require(file_record(stage.parent / "source.tar")["sha256"] == staging["git_archive_sha256"], "Git archive hash differs")
        spaces = data["namespaces"]
        require(type(spaces) is dict and spaces.get("artifact_before_exists") is False
                and spaces.get("artifact_after_save_files") == [] and type(spaces.get("qa")) is list
                and len(spaces["qa"]) == 1 and type(spaces["qa"][0]) is str
                and re.fullmatch(r"GangnamDream_StoryDemo_RuntimeQA_successor_[A-Za-z0-9_]+", spaces["qa"][0]),
                "namespace freshness evidence differs")
        qa = spaces["qa"][0]
        require(qa != identity["artifact_namespace"], "QA and artifact namespaces overlap")
        artifact_user = no_symlink(Path("/Users/junheelee/Library/Application Support") / identity["artifact_namespace"])
        require(not any(item.is_file() or item.is_symlink() for item in artifact_user.rglob("*")), "artifact namespace contains runtime files")
        generated = tracked_stage(source_root, source["commit"], stage, staging["changes"], identity, qa)
        require(generated == staging["generated_uid_files"], "generated UID inventory differs")
        command_contract(data["commands"], stage, output, source_root, source["commit"], identity, qa,
                         data["metadata_normalization"])
        app = output / "macos" / (identity["app_stem"] + ".app")
        zip_path = app.with_suffix(".zip")
        require(data["artifact_paths"] == {"app": str(app), "zip": str(zip_path)}, "artifact paths differ")
        artifacts = package_inventory(app, zip_path, stage)
        require(canonical(data["artifacts"]) == canonical(artifacts), "manifest artifacts differ from actual typed bytes")
        plist = plistlib.loads((app / "Contents/Info.plist").read_bytes())
        require(all(plist.get(key) == value for key, value in {
            "CFBundleIdentifier": identity["bundle_id"], "CFBundleVersion": identity["app_version"],
            "CFBundleShortVersionString": identity["app_version"], "CFBundleExecutable": identity["app_stem"],
            "CFBundleName": identity["app_stem"], "CFBundleDisplayName": identity["app_stem"]}.items()),
            "actual app plist identity differs")
        protection = data["protected"]
        require(protection["before"] == protection["after"] and type(protection["before"]) is list,
                "protected before/after differs")
        rows = protection["before"]
        labels = ["product_project_godot", "product_export_presets", "human_gates", "public_story_demo_build",
                  "public_story_demo_user_data", "retail_player_files", "extra_0", "extra_1", "extra_2"]
        require([row.get("label") for row in rows] == labels, "protected population differs")
        expected_paths = [source_root / "project.godot", source_root / "export_presets.cfg", source_root / "docs/human_gates.json",
                          source_root / "build/story_demo", Path("/Users/junheelee/Library/Application Support/GangnamDream_StoryDemo_v1"),
                          Path("/Users/junheelee/Library/Application Support/Godot/app_userdata/강남드림")]
        require([row["path"] for row in rows[:6]] == [str(item) for item in expected_paths], "protected primary path differs")
        require(len({row["path"] for row in rows}) == 9 and all(row["exists"] is True for row in rows[6:])
                and len(rows[5]["entries"]) == 34, "player34/extra3 protections differ")
        for row in rows:
            require(canonical(row) == canonical(protected_snapshot(row)), "actual protected bytes differ: " + row["label"])
        if path.name == "MANIFEST.json":
            result = load_json(no_symlink(output / "result.json").read_bytes())
            require(result.get("unit") == "ORDER-462" and result.get("all_pass") is True
                    and result.get("status") == "EXPORTED_NOT_RUNTIME_VERIFIED" and result.get("runtime") == "NOT_RUN"
                    and result.get("error") is None and result.get("preservation_errors") == []
                    and result.get("source_after") == source["after"]
                    and result.get("protected_after") == protection["after"]
                    and result.get("commands") == data["commands"] and result.get("staging") == str(stage),
                    "final manifest lacks matching successful final preservation result")
        return []
    except (ValueError, OSError, KeyError, TypeError, AttributeError, IndexError, UnicodeError,
            subprocess.SubprocessError, zipfile.BadZipFile, struct.error) as error:
        return [type(error).__name__ + ": " + str(error)]


def self_test():
    # Local import avoids builder/auditor initialization cycles. Pure calls only.
    import build_story_demo_successor_macos as builder
    checks = []

    def good(name, value):
        require(value, "self-test: " + name)
        checks.append(name)

    def bad(name, operation):
        try:
            operation()
        except (ValueError, OSError, TypeError, KeyError, zipfile.BadZipFile, struct.error):
            checks.append(name)
            return
        raise ValueError("self-test falsely admitted: " + name)

    identity = expected_identity(BUILD, "synthetic")
    good("independent identity", builder.identity_for(BUILD, "synthetic") == identity)
    observed_hex = " ".join(FINDERINFO_HEX[index:index + 2] for index in range(0, 64, 2)) + "\n"
    good("actual builder exact FinderInfo parser", builder.parse_finderinfo_hex(observed_hex) == FINDERINFO_HEX)
    for value in ("", FINDERINFO_HEX[:-1], "f" + FINDERINFO_HEX[1:], FINDERINFO_HEX.encode()):
        bad("actual builder rejects unreviewed FinderInfo " + repr(value),
            lambda value=value: builder.parse_finderinfo_hex(value))
    app_path = Path("/synthetic/fresh.app")
    metadata = {"path": str(app_path), "attribute": FINDERINFO_ATTRIBUTE,
                "observed_hex": FINDERINFO_HEX, "removed": True}
    before_attrs = FINDERINFO_ATTRIBUTE + "\ncom.apple.quarantine\n"
    after_attrs = "com.apple.quarantine\n"
    metadata_contract(metadata, app_path, before_attrs, observed_hex, after_attrs)
    good("exact root removal preserves other attribute names", True)
    absent = dict(metadata, observed_hex=None, removed=False)
    metadata_contract(absent, app_path, after_attrs, None, after_attrs)
    good("absent FinderInfo records no removal", True)
    for field, value in (("path", str(app_path / "Contents")), ("attribute", "com.apple.quarantine"),
                         ("observed_hex", "0" * 64), ("removed", 1)):
        bad("metadata forged " + field, lambda field=field, value=value: metadata_contract(
            dict(metadata, **{field: value}), app_path, before_attrs, observed_hex, after_attrs))
    bad("FinderInfo remains after removal", lambda: metadata_contract(metadata, app_path, before_attrs, observed_hex, before_attrs))
    bad("other attribute removed", lambda: metadata_contract(metadata, app_path, before_attrs, observed_hex, ""))
    bad("removal without exact raw read", lambda: metadata_contract(metadata, app_path, before_attrs, "0" * 64, after_attrs))
    bad("absent attribute falsely removed", lambda: metadata_contract(metadata, app_path, after_attrs, observed_hex, after_attrs))
    bad("absent branch has read evidence", lambda: metadata_contract(absent, app_path, after_attrs, observed_hex, after_attrs))
    for attempt in ("", "../old", "/absolute", "UPPER", "a" * 33, 1):
        bad("attempt rejected " + repr(attempt), lambda attempt=attempt: builder.identity_for(BUILD, attempt))
    bad("old BUILD rejected", lambda: builder.identity_for("2026.08.31.1", "first"))
    original = {name: (ROOT / name).read_bytes() for name in CHANGED}
    frozen = deepcopy(original)
    changed = {CHANGED[0]: builder.project_bytes(original[CHANGED[0]], identity, identity["artifact_namespace"]),
               CHANGED[1]: builder.presets_bytes(original[CHANGED[1]], identity),
               CHANGED[2]: builder.controller_bytes(original[CHANGED[2]], identity),
               CHANGED[3]: builder.check_bytes(original[CHANGED[3]], identity)}
    stage_contract(original, changed, identity, identity["artifact_namespace"])
    good("pure transformations preserve inputs", original == frozen)
    bad("duplicate owned project key", lambda: builder.project_bytes(
        original[CHANGED[0]].replace(b'config/name="', b'config/name="extra"\nconfig/name="', 1), identity, identity["artifact_namespace"]))
    bad("changed export filter", lambda: builder.presets_bytes(original[CHANGED[1]].replace(
        b'export_filter="all_resources"', b'export_filter="selected_resources"'), identity))
    bad("missing source constant", lambda: builder.controller_bytes(original[CHANGED[2]].replace(
        b'const PUBLIC_BUILD_ID := "2026.08.31.1"', b'const PUBLIC_BUILD_ID := "drift"'), identity))
    bad("public namespace disallowed", lambda: builder.project_bytes(original[CHANGED[0]], identity, "GangnamDream_StoryDemo_v1"))
    mutated = dict(changed)
    mutated[CHANGED[0]] = changed[CHANGED[0]].replace(b"viewport_width=1280", b"viewport_width=1200")
    bad("unowned staging byte", lambda: stage_contract(original, mutated, identity, identity["artifact_namespace"]))
    source = {"commit": "1" * 40, "tree": "2" * 40, "commit_date": "2026-10-05",
              "before": {"head": "1" * 40, "tree": "2" * 40, "status": ""},
              "after": {"head": "1" * 40, "tree": "2" * 40, "status": ""}}
    sample = {"schema_version": 1, "unit": "ORDER-462", "status": "EXPORTED_NOT_RUNTIME_VERIFIED",
              "identity": identity, "source": source, "runtime": {"status": "NOT_RUN", "pending": PENDING},
              "user_go": "NOT_INHERITED", "codesign": "ad-hoc"}
    manifest_shape(sample)
    for field, value in (("schema_version", True), ("status", "RUNTIME_VERIFIED"), ("codesign", "notarized"),
                         ("user_go", "INHERITED"), ("runtime", {"status": "NOT_RUN", "pending": []})):
        mutant = deepcopy(sample)
        mutant[field] = value
        bad("manifest tamper " + field, lambda mutant=mutant: manifest_shape(mutant))
    mutant = deepcopy(sample)
    mutant["identity"]["artifact_namespace"] = "GangnamDream_StoryDemo_v1"
    bad("manifest identity tamper", lambda: manifest_shape(mutant))
    mutant = deepcopy(sample)
    mutant["source"]["after"]["head"] = "3" * 40
    bad("source drift", lambda: manifest_shape(mutant))
    bad("duplicate manifest key", lambda: load_json(b'{"status":1,"status":2}'))
    with tempfile.TemporaryDirectory(prefix="gangnam-successor-audit-") as temporary:
        root = Path(temporary).resolve()
        stage, app = root / "source", root / "Tiny.app"
        (stage / "content").mkdir(parents=True)
        fresh = root / "fresh-output"
        builder.require_fresh_path(fresh)
        good("real fresh-path guard has no creation side effect", not fresh.exists())
        bad("real existing-output guard", lambda: builder.require_fresh_path(stage))
        namespace = root / identity["artifact_namespace"]
        namespace.mkdir()
        bad("real existing-namespace guard", lambda: builder.require_fresh_path(namespace))
        payload = b'{"current":true}\n'
        (stage / "content/test.json").write_bytes(payload)
        for directory in ("Contents/MacOS", "Contents/Resources"):
            (app / directory).mkdir(parents=True)
        (app / "Contents/MacOS/Tiny").write_bytes(b"synthetic launcher, not a real export")
        (app / "Contents/MacOS/Tiny").chmod(0o755)
        (app / "Contents/Info.plist").write_bytes(plistlib.dumps({"CFBundleExecutable": "Tiny"}))
        pck = app / "Contents/Resources/Tiny.pck"
        binary = b"synthetic project.binary; not a Variant decoder test"
        payloads = payload + binary
        header = bytearray(112)
        header[:4] = b"GDPC"
        struct.pack_into("<5I", header, 4, 3, 4, 6, 2, 2)
        struct.pack_into("<2Q", header, 24, 112, 112 + len(payloads))
        pck_raw = bytes(header) + payloads + struct.pack("<I", 2)
        for member, value, offset in ((b"res://content/test.json\0", payload, 0),
                                      (b"res://project.binary\0", binary, len(payload))):
            pck_raw += struct.pack("<I", len(member)) + member
            pck_raw += struct.pack("<QQ", offset, len(value)) + hashlib.md5(value).digest() + struct.pack("<I", 0)
        pck.write_bytes(pck_raw)
        package = root / "Tiny.zip"

        def pack(path, extras=()):
            with zipfile.ZipFile(path, "w") as archive:
                for item in sorted(app.rglob("*")):
                    if item.is_file():
                        archive.write(item, app.name + "/" + item.relative_to(app).as_posix())
                for item, value in extras:
                    archive.writestr(item, value)

        pack(package)
        measured = package_inventory(app, package, stage)
        good("synthetic package three files and current JSON", len(measured["app_files"]) == 3
             and measured["pck"]["entries"] == 2 and measured["pck"]["content_json"]["content/test.json"]["sha256"] == sha(payload))
        for name in ("../escape", "/absolute", "Tiny.app/../escape", "Tiny.app\\escape"):
            pack(root / "bad.zip", ((name, b"x"),))
            bad("unsafe ZIP " + name, lambda: safe_zip_members(root / "bad.zip"))
        link = zipfile.ZipInfo("Tiny.app/link")
        link.create_system, link.external_attr = 3, (stat.S_IFLNK | 0o777) << 16
        pack(root / "bad.zip", ((link, b"../../escape"),))
        bad("ZIP symlink", lambda: safe_zip_members(root / "bad.zip"))
        (root / "link").symlink_to(stage, target_is_directory=True)
        bad("filesystem symlink", lambda: no_symlink(root / "link/content/test.json"))
        bad("real fresh-path symlink guard", lambda: builder.require_fresh_path(root / "link/new"))
        (stage / "content/test.json").write_bytes(b'{ "current":true}\n')
        bad("semantic equal but raw JSON mismatch", lambda: pck_inventory(pck, stage))
        (stage / "content/test.json").write_bytes(payload)
        pck.write_bytes(pck_raw[:-2])
        bad("PCK truncated directory", lambda: pck_inventory(pck, stage))
        pck.write_bytes(pck_raw[:112] + b"!" + pck_raw[113:])
        bad("PCK payload digest mismatch", lambda: pck_inventory(pck, stage))
        pck.write_bytes(pck_raw)
        (app / "Contents/MacOS/Tiny").write_bytes(b"tampered")
        bad("app versus finalized ZIP bytes", lambda: package_inventory(app, package, stage))
        stdout, stderr = root / "stdout", root / "stderr"
        stdout.write_bytes(b"SYNTHETIC_OK\n")
        stderr.write_bytes(b"")

        def log_record(path):
            row = file_record(path)
            return {"path": str(path), "sha256": row["sha256"], "size": row["bytes"]}

        row = {"name": "synthetic", "argv": ["synthetic"], "exit_code": 0, "elapsed_seconds": 0,
               "stdout": log_record(stdout), "stderr": log_record(stderr), "godot_log": None,
               "expected_marker": "SYNTHETIC_OK"}
        validate_log(row, root)
        for token in ("SCRIPT ERROR:", "Compile Error", "Failed to load script", "Failed loading resource"):
            stderr.write_text(token + " synthetic\n")
            row["stderr"] = log_record(stderr)
            bad("marker plus engine error " + token, lambda: validate_log(row, root))
        stderr.write_bytes(b"")
        row["stderr"] = log_record(stderr)
        stdout.write_bytes(b"SYNTHETIC_OK\nSYNTHETIC_OK\n")
        row["stdout"] = log_record(stdout)
        bad("duplicate success marker", lambda: validate_log(row, root))
    print("STORY_DEMO_SUCCESSOR_PACKAGE_SELF_TEST_OK cases=%d actual_exports=0" % len(checks))
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--self-test", action="store_true")
    mode.add_argument("--manifest", type=Path)
    parser.add_argument("--source-root", type=Path, default=ROOT)
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    require(args.manifest.name == "MANIFEST.json", "CLI verification requires the final manifest, not a pending draft")
    errors = audit_manifest(args.manifest, args.source_root)
    for error in errors:
        print("STORY_DEMO_SUCCESSOR_PACKAGE_FAIL " + error)
    if errors:
        return 1
    print("STORY_DEMO_SUCCESSOR_PACKAGE_OK status=EXPORTED_NOT_RUNTIME_VERIFIED runtime=NOT_RUN")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, OSError, KeyError, TypeError) as error:
        print("STORY_DEMO_SUCCESSOR_PACKAGE_FAIL " + str(error))
        raise SystemExit(1)

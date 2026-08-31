#!/usr/bin/env python3
"""Audit the factual release-content ledger and optional exported pack ZIPs.

This tool deliberately separates three questions that are easy to conflate:
what an all-resources package contains, what runtime eagerly/lazily loads, and
what an official fresh-start route can reach.  It never chooses an age rating,
deletes content, or changes an export filter.

    python3 tools/release_content_inventory.py
    python3 tools/release_content_inventory.py --self-test
    python3 tools/release_content_inventory.py --write-report
    python3 tools/release_content_inventory.py --print-baselines
    python3 tools/release_content_inventory.py \
      --pack-zip story_demo_rc=build/story_demo/macos/GangnamDream-StoryDemo.zip \
      --pack-zip retail_full=build/qa/release_content_inventory/full.zip \
      --pack-zip v2_playtest=build/qa/release_content_inventory/v2.zip
"""

from __future__ import annotations

import argparse
import ast
import copy
import hashlib
import json
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any

from event_lifecycle import (
    audit_author_only,
    collect_lifecycle_inputs,
    evaluate_author_only,
)


ROOT = Path(__file__).resolve().parents[1]
LEDGER_PATH = ROOT / "content/meta/release_content_inventory.json"
REPORT_PATH = ROOT / "docs/CONTENT_RATING_INVENTORY.md"
EVENT_ROOT = ROOT / "content/events"
EVENT_EN_ROOT = ROOT / "content/events_en"
DEMO_V2_PATH = ROOT / "content/meta/demo_core_loop_v2.json"
NARRATIVE_SPINE_PATH = ROOT / "content/meta/narrative_spine.json"
PROFILE_IDS = ("retail_full", "legacy_demo", "v2_playtest")
PUBLIC_STORY_DEMO_PROFILE = "story_demo_rc"
PACK_PROFILE_IDS = PROFILE_IDS + (PUBLIC_STORY_DEMO_PROFILE,)
PUBLIC_STORY_DEMO_CONTRACT = {
    "profile": "story_demo_rc",
    "build_pipeline": "tools/build_story_demo_macos.sh",
    "package_audit": "tools/story_demo_package_audit.py",
    "package_mode": "external_clean_source_staging",
    "preset_origin": "derived_from_checked_in_macOS",
    "checked_in_profile_entry": False,
    "derived_preset_name": "Story Demo macOS",
    "export_filter": "all_resources",
    "package_source_commit": "362578d8f4c0781fe35f643a74cc3037e7a80b21",
    "package_source_tree": "e7f50b065b3369afa1894df8292756a95f94fd11",
    "product_commit": "4e80a63e89821094b8bab21b8d5c73ecfc9b6278",
    "product_tree": "0fdddf11e2ef030cd172d23e691e3d7da4ea29ff",
    "manifest_sha256": "50eed10b18c2c2b056f875a8df55230dc07b5535c55e59ddb89fff1d64e91870",
    "entry_scene": "res://playtests/order124/StoryChoiceM1M6Playtest.tscn",
    "public_months": [1, 6],
    "internal_weeks": [1, 24],
    "settlements": 6,
    "locales": ["ko", "en", "ja", "zh-CN", "zh-TW"],
    "range_and_structure_verdict": "user_go",
    "native_claims": {"ja": "open", "zh-CN": "open", "zh-TW": "open"},
    "identity_owner": "docs/human_gates.json",
}
PUBLIC_STORY_DEMO_ARTIFACT_CONTRACT = {
    "zip": {
        "path": "build/story_demo/macos/GangnamDream-StoryDemo.zip",
        "sha256": "956ac93524df6030ef984521550cec7dddafea381387a3df52194e43f5e61289",
        "size_bytes": 413881598,
        "logical_file_count": 7,
        "logical_members": [
            "GangnamDream-StoryDemo.app/Contents/Info.plist",
            "GangnamDream-StoryDemo.app/Contents/MacOS/GangnamDream-StoryDemo",
            "GangnamDream-StoryDemo.app/Contents/PkgInfo",
            "GangnamDream-StoryDemo.app/Contents/Resources/GangnamDream-StoryDemo.pck",
            "GangnamDream-StoryDemo.app/Contents/Resources/PrivacyInfo.xcprivacy",
            "GangnamDream-StoryDemo.app/Contents/Resources/icon.icns",
            "GangnamDream-StoryDemo.app/Contents/_CodeSignature/CodeResources",
        ],
        "logical_paths_sha256": "fbe415a3c0b831d0a60611aa8e9920173fd2a9cc650ada0a42b56319d704e9f0",
        "logical_entries_sha256": "3a8a346b2cfdb757b77e64b2bd04d20d937613ecc47b7eee7ca56f9f2a62a470",
        "logical_uncompressed_size_bytes": 549375435,
        "metadata_file_count": 11,
        "metadata_paths_sha256": "45bbbf1663b759235fd889f91125a1ebf31e75a8a1a9b8e56dadb179646f5e51",
        "app_tree_sha256": "56a4f2997256e68baa21c02807fcf1f0e995ce114f57f96f26d309b300b7ec14",
        "launcher_sha256": "f1e2ce4faf3849e84843947db33405496393452ae68f1df1ca1279e4923aef5f",
        "launcher_size_bytes": 184222320,
    },
    "pck": {
        "member": (
            "GangnamDream-StoryDemo.app/Contents/Resources/"
            "GangnamDream-StoryDemo.pck"
        ),
        "sha256": "0e6066434bd6679292ae5f41ae506da90bf06d1bef3af05acf419f7bea8f4c89",
        "size_bytes": 362597916,
        "format_version": 3,
        "engine_version": [4, 6, 2],
        "flags": 2,
        "base_offset": 112,
        "directory_offset": 362458848,
        "entry_count": 1481,
        "entry_paths_sha256": "e85f8526143f3d634f1b049bc5bc8086e1d8e6f6d0d9c3550d252151e4fa3f40",
        "entry_metadata_sha256": "a60ea87a0892b0524274918bc763ebae3cc3becaa9d564de990e1e89e15cc388",
        "raw_json_files": 309,
        "packaged_raster_imports": 298,
        "packaged_audio_imports": 139,
        "import_binding_count": 437,
        "import_bindings_sha256": "2181c5c7259f9bbe34d1ee04dc685a021eb43062f700e765d38d2168a5a6363c",
    },
}
PUBLIC_STORY_DEMO_GATE_CONTRACT = {
    "story_demo_m1_m6_user_play": {
        "state": "done",
        "gate": "M01~M06 story-first 공개 데모 사용자 판정",
        "blocks": ["order124-close", "story-only-product-migration"],
        "content": (
            "월간 행동판 없이 실제 StoryMode 선택과 자동 네 주·월세·생활 압박만으로 "
            "clean·restitution·escalation을 각각 M01~M06 완주하는 독립 체험판"
        ),
        "record": (
            "2026-08-31 사용자 대화에서 ‘출시 데모자체는 m6이 맞아 이대로 go’라고 exact "
            "story_demo_rc M01~M06의 출시 범위와 StoryMode 중심 구조에 최종 GO함. "
            "일본어·간체·번체 원어민 claim은 별도 OPEN 게이트로 유지함."
        ),
    },
    "story_demo_ja_native_review": {
        "state": "open",
        "gate": "M01~M06 story demo 일본어 원어민 출시 claim 검수",
        "blocks": ["claim:ja-story-demo"],
        "content": (
            "story_demo_rc의 M01~M06 실제 14사건·모든 선택·결과·도달 UI 121개 "
            "일본어 표면"
        ),
    },
    "story_demo_zh_cn_native_review": {
        "state": "open",
        "gate": "M01~M06 story demo 간체 중국어 원어민 출시 claim 검수",
        "blocks": ["claim:zh-CN-story-demo"],
        "content": (
            "story_demo_rc의 M01~M06 실제 14사건·모든 선택·결과·도달 UI 121개 "
            "zh-CN 표면"
        ),
    },
    "story_demo_zh_tw_native_review": {
        "state": "open",
        "gate": "M01~M06 story demo 번체 중국어 원어민 출시 claim 검수",
        "blocks": ["claim:zh-TW-story-demo"],
        "content": (
            "story_demo_rc의 M01~M06 실제 14사건·모든 선택·결과·도달 UI 121개 "
            "zh-TW 표면"
        ),
    },
}
PUBLIC_STORY_DEMO_CANDIDATE_SHA256 = (
    "ccb3e382dc8519b038085930c99018d4b8b1ec2d770861fdaab54cca72eeb080"
)
PUBLIC_STORY_DEMO_GATE_ROW_SHA256 = {
    "story_demo_ja_native_review":
        "b9724e143efebcce3d0aabc12d7db1a92f4feab662a6d6073b7be3f5a9d7e121",
    "story_demo_zh_cn_native_review":
        "d2112023b33448b05a42e8df96ac47d4609baf1e2cf508d51b34a9f6e6af850e",
    "story_demo_zh_tw_native_review":
        "933377f73bbf168163f92221d54dbc2cb6b482eaa73e23c8ff325323533c7505",
    "story_demo_m1_m6_user_play":
        "78090b88b35c75908fd6f30e19a05f26a1b8aa3759e145290ad0aabf20c130f0",
}
AXIS_IDS = {
    "gambling", "sexuality", "violence", "fear", "language", "crime",
    "alcohol_tobacco_drugs", "generative_ai", "online_features",
}
RUNTIME_LOAD = {"boot_eager", "main_entry_eager", "lazy", "none"}
FRESH_START = {"contracted", "static_possible", "blocked", "unknown", "not_applicable"}
INTENSITIES = {
    "none", "mild", "moderate", "strong", "disclosure_required",
    "external_link_only",
}
AI_RUNTIME_TOKENS = (
    "api.openai.com", "api.anthropic.com", "GenerativeAI", "OpenAIClient",
    "AnthropicClient", "LLMClient",
)
EXPECTED_RUNTIME_ROOTS = ("autoloads", "scenes", "systems", "ui_components")
REQUIRED_NETWORK_TOKENS = (
    "HTTPRequest", "HTTPClient", "WebSocketPeer", "WebSocketMultiplayerPeer",
    "ENetMultiplayerPeer", "MultiplayerAPI", "PacketPeerUDP", "TCPServer",
    "StreamPeerTCP",
)
NETWORK_FALSE_FIELDS = (
    "multiplayer", "chat", "remote_ugc", "telemetry",
    "real_money_transactions", "live_ai",
)
PUBLIC_CORPUS_SCALAR_FIELDS = (
    "ko_event_files", "en_event_files", "ko_events", "en_events",
    "event_ids_sha256", "event_content_sha256", "shipping_ko_events",
    "shipping_en_events", "shipping_event_ids_sha256", "author_only_events",
    "author_only_event_ids_sha256", "ko_endings", "en_endings",
    "ending_ids_sha256", "ending_content_sha256", "qualitative_fact_count",
    "active_art_assets", "source_raster_assets", "packaged_raster_assets",
    "registry_external_source_raster_assets",
    "registry_external_packaged_raster_assets",
    "source_only_gdignored_raster_assets",
    "registry_external_raster_paths_sha256",
    "registry_external_packaged_paths_sha256",
    "source_only_gdignored_paths_sha256", "audio_source_assets",
    "audio_manifest_sha256", "network_api_hits", "live_ai_api_hits",
)
RASTER_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp"}
AUDIO_SUFFIXES = {".ogg", ".wav", ".mp3"}


class GitSnapshot:
    """Read one immutable Git tree without checking it out."""

    def __init__(self, revision: str):
        self.revision = revision
        self._cache: dict[str, bytes] = {}
        self.commit = self._git_text("rev-parse", f"{revision}^{{commit}}")
        self.tree = self._git_text("rev-parse", f"{revision}^{{tree}}")
        result = self._git(
            "ls-tree", "-r", "--name-only", "-z", self.commit,
            text_output=False,
        )
        self.paths = tuple(
            item.decode("utf-8")
            for item in result.split(b"\0") if item
        )
        self.path_set = frozenset(self.paths)

    @staticmethod
    def _git(*args: str, text_output: bool = False) -> bytes | str:
        result = subprocess.run(
            ["git", *args],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if result.returncode != 0:
            detail = result.stderr.decode("utf-8", errors="replace").strip()
            raise ValueError(f"git {' '.join(args)} failed: {detail}")
        if text_output:
            return result.stdout.decode("utf-8").strip()
        return result.stdout

    @classmethod
    def _git_text(cls, *args: str) -> str:
        return str(cls._git(*args, text_output=True))

    def read(self, path: str) -> bytes:
        if path not in self.path_set:
            raise ValueError(f"{self.commit}: tracked path missing: {path}")
        if path not in self._cache:
            self._cache[path] = bytes(self._git("show", f"{self.commit}:{path}"))
        return self._cache[path]

    def text(self, path: str) -> str:
        return self.read(path).decode("utf-8", errors="replace")

    def files_below(self, prefix: str) -> list[str]:
        prefix = prefix.rstrip("/") + "/"
        return [path for path in self.paths if path.startswith(prefix)]

    def has_directory(self, prefix: str) -> bool:
        prefix = prefix.rstrip("/") + "/"
        return any(path.startswith(prefix) for path in self.paths)


_GIT_SNAPSHOTS: dict[str, GitSnapshot] = {}
_SNAPSHOT_LIFECYCLE_REPORTS: dict[str, Any] = {}


def git_snapshot(revision: str) -> GitSnapshot:
    snapshot = _GIT_SNAPSHOTS.get(revision)
    if snapshot is None:
        snapshot = GitSnapshot(revision)
        _GIT_SNAPSHOTS[revision] = snapshot
    return snapshot


def snapshot_lifecycle_report(snapshot: GitSnapshot) -> Any:
    cached = _SNAPSHOT_LIFECYCLE_REPORTS.get(snapshot.commit)
    if cached is not None:
        return cached
    required = [
        path for path in snapshot.paths
        if (
            Path(path).parent.as_posix() == "content/events"
            and path.endswith(".json")
        )
        or path in {
            "content/meta/event_lifecycle.json",
            "content/meta/thoughts.json",
            "content/meta/demo_core_loop_v2.json",
            "content/meta/event_director.json",
            "content/meta/release_content_inventory.json",
        }
        or (
            path.endswith(".gd")
            and path.split("/", 1)[0] in EXPECTED_RUNTIME_ROOTS
        )
    ]
    with tempfile.TemporaryDirectory(
        prefix="gangnamdream-exact-lifecycle-"
    ) as temp:
        temp_root = Path(temp)
        for relative in required:
            destination = temp_root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(snapshot.read(relative))
        cached = evaluate_author_only(collect_lifecycle_inputs(temp_root))
    _SNAPSHOT_LIFECYCLE_REPORTS[snapshot.commit] = cached
    return cached


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def sha_lines(values: list[str]) -> str:
    return hashlib.sha256("\n".join(values).encode("utf-8")).hexdigest()


def canonical_json_sha256(value: Any) -> str:
    payload = json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def is_below_gdignore(path: Path) -> bool:
    parent = path.parent
    while parent != ROOT and ROOT in parent.parents:
        if (parent / ".gdignore").is_file():
            return True
        parent = parent.parent
    return False


def event_array(data: Any, path: Path) -> list[dict[str, Any]]:
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and isinstance(data.get("events"), list):
        return data["events"]
    raise ValueError(f"{path.relative_to(ROOT)}: event array shape not recognized")


def load_event_corpus(root: Path) -> tuple[dict[str, dict[str, Any]], dict[str, str], list[Path]]:
    events: dict[str, dict[str, Any]] = {}
    owners: dict[str, str] = {}
    files = sorted(root.glob("*.json"))
    for path in files:
        for event in event_array(load_json(path), path):
            event_id = event.get("id")
            if not isinstance(event_id, str) or not event_id:
                raise ValueError(f"{path.relative_to(ROOT)}: event without id")
            if event_id in events:
                raise ValueError(f"duplicate event id: {event_id}")
            events[event_id] = event
            owners[event_id] = path.relative_to(ROOT).as_posix()
    return events, owners, files


def strings_in(value: Any) -> list[str]:
    out: list[str] = []
    if isinstance(value, str):
        out.append(value)
    elif isinstance(value, dict):
        for item in value.values():
            out.extend(strings_in(item))
    elif isinstance(value, list):
        for item in value:
            out.extend(strings_in(item))
    return out


def parse_string_value(raw: str) -> str:
    raw = raw.strip()
    try:
        parsed = ast.literal_eval(raw)
    except (ValueError, SyntaxError):
        return raw
    return parsed if isinstance(parsed, str) else raw


def parse_export_presets_text(text: str) -> list[dict[str, str]]:
    starts = list(re.finditer(r"(?m)^\[preset\.(\d+)\]\s*$", text))
    presets: list[dict[str, str]] = []
    for index, match in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(text)
        block = text[match.end():end]
        options = re.search(r"(?m)^\[preset\.\d+\.options\]\s*$", block)
        if options:
            block = block[:options.start()]
        values: dict[str, str] = {"index": match.group(1)}
        for line in block.splitlines():
            if "=" not in line or line.lstrip().startswith("#"):
                continue
            key, raw = line.split("=", 1)
            values[key.strip()] = parse_string_value(raw)
        presets.append(values)
    return presets


def parse_export_presets() -> list[dict[str, str]]:
    return parse_export_presets_text(
        (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    )


def gd_function_block(path: Path, function_name: str) -> str:
    """Return one top-level GDScript function for runtime-marker audits."""
    text = path.read_text(encoding="utf-8")
    marker = re.search(
        rf"(?m)^(?:static\s+)?func\s+{re.escape(function_name)}\s*\(", text
    )
    if marker is None:
        raise ValueError(f"{path.relative_to(ROOT)}: function missing: {function_name}")
    next_marker = re.search(r"(?m)^(?:static\s+)?func\s+", text[marker.end():])
    end = marker.end() + next_marker.start() if next_marker else len(text)
    return text[marker.start():end]


def candidate_fingerprint(
    axis: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    en_events: dict[str, dict[str, Any]],
    owners: dict[str, str],
) -> dict[str, Any] | None:
    scan = axis.get("candidate_scan")
    if not scan:
        return None
    categories = set(scan.get("categories", []))
    tags = set(scan.get("tags", []))
    ko_tokens = [token.casefold() for token in scan.get("tokens_ko", [])]
    en_tokens = [token.casefold() for token in scan.get("tokens_en", [])]
    found: list[str] = []
    for event_id, event in ko_events.items():
        overlay = en_events.get(event_id, {})
        category = str(event.get("category", ""))
        event_tags = {str(tag) for tag in event.get("tags", [])}
        ko_text = "\n".join(strings_in(event)).casefold()
        en_text = "\n".join(strings_in(overlay)).casefold()
        if (
            category in categories
            or bool(event_tags & tags)
            or any(token in ko_text for token in ko_tokens)
            or any(token in en_text for token in en_tokens)
        ):
            found.append(event_id)
    found.sort()
    files = sorted({owners[event_id] for event_id in found})
    content_rows = [
        json.dumps(
            {"id": event_id, "ko": ko_events[event_id], "en": en_events[event_id]},
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        for event_id in found
    ]
    return {
        "event_count": len(found),
        "file_count": len(files),
        "ids_sha256": sha_lines(found),
        "content_sha256": sha_lines(content_rows),
        "event_ids": found,
        "files": files,
    }


def snapshot_event_corpus(
    snapshot: GitSnapshot,
    root: str,
) -> tuple[dict[str, dict[str, Any]], dict[str, str], list[str]]:
    files = sorted(
        path for path in snapshot.files_below(root)
        if path.endswith(".json") and Path(path).parent.as_posix() == root
    )
    events: dict[str, dict[str, Any]] = {}
    owners: dict[str, str] = {}
    for path in files:
        raw = json.loads(snapshot.text(path))
        rows = raw if isinstance(raw, list) else raw.get("events") \
            if isinstance(raw, dict) else None
        if not isinstance(rows, list):
            raise ValueError(f"{snapshot.commit}:{path}: event array shape not recognized")
        for row in rows:
            if not isinstance(row, dict):
                raise ValueError(f"{snapshot.commit}:{path}: event row must be an object")
            event_id = row.get("id")
            if not isinstance(event_id, str) or not event_id:
                raise ValueError(f"{snapshot.commit}:{path}: event without id")
            if event_id in events:
                raise ValueError(f"{snapshot.commit}: duplicate event id: {event_id}")
            events[event_id] = row
            owners[event_id] = path
    return events, owners, files


def snapshot_is_below_gdignore(snapshot: GitSnapshot, path: str) -> bool:
    parent = Path(path).parent
    while parent.as_posix() not in {"", "."}:
        if (parent / ".gdignore").as_posix() in snapshot.path_set:
            return True
        parent = parent.parent
    return False


def snapshot_owner_text(snapshot: GitSnapshot, path_text: str) -> str:
    if path_text in snapshot.path_set:
        suffix = Path(path_text).suffix.lower()
        if suffix in RASTER_SUFFIXES | AUDIO_SUFFIXES:
            return Path(path_text).name
        return snapshot.text(path_text)
    if not snapshot.has_directory(path_text):
        return ""
    pieces: list[str] = []
    for child in snapshot.files_below(path_text):
        if Path(child).suffix.lower() in {".gd", ".json", ".md", ".txt"}:
            pieces.append(snapshot.text(child))
    return "\n".join(pieces) if pieces else path_text


def validate_snapshot_facts(
    ledger: dict[str, Any],
    snapshot: GitSnapshot,
    ko_events: dict[str, dict[str, Any]],
    en_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    runtime_paths = [
        path for path in snapshot.paths
        if path.endswith(".gd")
        and path.split("/", 1)[0] in EXPECTED_RUNTIME_ROOTS
    ]
    runtime_blob = "\n".join(snapshot.text(path) for path in runtime_paths)
    for axis in ledger["content_axes"]:
        for fact in axis["facts"]:
            where = f"public story demo {axis['id']}.{fact['id']}"
            evidence_parts: list[str] = []
            for owner in fact["owner_paths"]:
                owner_evidence = snapshot_owner_text(snapshot, owner)
                if not owner_evidence:
                    errors.append(f"{where}: exact-source owner missing: {owner}")
                else:
                    evidence_parts.append(owner_evidence)
            for event_id in fact["event_ids"]:
                if event_id not in ko_events or event_id not in en_events:
                    errors.append(f"{where}: exact-source bilingual event missing: {event_id}")
                    continue
                evidence_parts.append(json.dumps(ko_events[event_id], ensure_ascii=False))
                evidence_parts.append(json.dumps(en_events[event_id], ensure_ascii=False))
            evidence = "\n".join(evidence_parts)
            for token in fact["evidence_tokens"]:
                if token not in evidence:
                    errors.append(
                        f"{where}: exact-source evidence token not found: {token!r}"
                    )
            for relative in fact.get("runtime_unreferenced_paths", []):
                relative = str(relative)
                if relative not in snapshot.path_set:
                    errors.append(
                        f"{where}: exact-source runtime-unreferenced file missing: {relative}"
                    )
                    continue
                if f"res://{relative}" in runtime_blob or Path(relative).name in runtime_blob:
                    errors.append(
                        f"{where}: exact-source unreferenced asset appears in runtime: {relative}"
                    )


def newline_id_digest(values: set[str]) -> str:
    payload = "\n".join(sorted(values)) + "\n"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def validate_public_story_demo_source(
    ledger: dict[str, Any],
    errors: list[str],
) -> dict[str, dict[str, Any]]:
    public = ledger.get("public_story_demo_package_contract")
    staged = ledger.get("export_contract", {}).get("staged_public_demo", {})
    if not isinstance(public, dict):
        errors.append("public_story_demo_package_contract must be an object")
        return {}
    for key in (
        "profile", "inventory_basis", "package_source_commit", "package_source_tree",
        "product_commit", "product_tree", "axis_fingerprints", "zip", "pck",
        *PUBLIC_CORPUS_SCALAR_FIELDS,
    ):
        if key not in public:
            errors.append(f"public story demo package contract field missing: {key}")
    identity_pairs = {
        "profile": "profile",
        "package_source_commit": "package_source_commit",
        "package_source_tree": "package_source_tree",
        "product_commit": "product_commit",
        "product_tree": "product_tree",
    }
    for public_key, staged_key in identity_pairs.items():
        if public.get(public_key) != staged.get(staged_key):
            errors.append(
                f"public story demo {public_key} differs from staged public identity"
            )
    if public.get("inventory_basis") != (
        "exact package-source Git snapshot plus exact app ZIP/PCK directory"
    ):
        errors.append("public story demo inventory_basis drifted")

    snapshot = git_snapshot(str(staged["package_source_commit"]))
    product = git_snapshot(str(staged["product_commit"]))
    if snapshot.commit != staged["package_source_commit"]:
        errors.append("public story demo package source commit does not resolve exactly")
    if snapshot.tree != staged["package_source_tree"]:
        errors.append(
            f"public story demo package source tree {snapshot.tree} "
            f"!= {staged['package_source_tree']}"
        )
    if product.commit != staged["product_commit"]:
        errors.append("public story demo product commit does not resolve exactly")
    if product.tree != staged["product_tree"]:
        errors.append(
            f"public story demo product tree {product.tree} != {staged['product_tree']}"
        )
    runtime_scope = (
        "project.godot", "export_presets.cfg", "icon.png", "icon.png.import",
        "icon.svg", "icon.svg.import", "assets", "autoloads", "content", "locale",
        "playtests", "scenes", "steam_input", "systems", "ui_components",
    )
    runtime_diff = GitSnapshot._git(
        "diff", "--name-only", product.commit, snapshot.commit, "--", *runtime_scope,
        text_output=True,
    )
    if runtime_diff:
        errors.append(
            "public story demo product/package-source runtime diff is not empty: "
            f"{str(runtime_diff).splitlines()[:8]}"
        )

    exact_release_ledger = json.loads(
        snapshot.text("content/meta/release_content_inventory.json")
    )
    exact_export_contract = exact_release_ledger["export_contract"]
    exact_presets = parse_export_presets_text(snapshot.text("export_presets.cfg"))
    exact_mac = next(
        (preset for preset in exact_presets if preset.get("name") == "macOS"), None
    )
    if exact_mac is None:
        errors.append("public story demo exact source lacks the macOS base preset")
    else:
        for key in ("export_filter", "include_filter", "exclude_filter"):
            expected = exact_export_contract[key]
            if exact_mac.get(key) != expected:
                errors.append(
                    f"public story demo exact macOS {key}={exact_mac.get(key)!r} "
                    f"!= {expected!r}"
                )
        if exact_mac.get("export_filter") != staged["export_filter"]:
            errors.append("public story demo exact macOS filter differs from staged filter")
    exact_builder = snapshot.text(staged["build_pipeline"])
    for marker in (
        f'readonly PROFILE="{staged["profile"]}"',
        f'readonly ENTRY_SCENE="{staged["entry_scene"]}"',
        'git -C "$PROJECT_DIR" archive --format=tar "$SOURCE_COMMIT"',
        're.search(r\'(?m)^name="macOS"$\'',
    ):
        if marker not in exact_builder:
            errors.append(f"public story demo exact builder marker missing: {marker}")

    ko_events, owners, ko_files = snapshot_event_corpus(snapshot, "content/events")
    en_events, _en_owners, en_files = snapshot_event_corpus(
        snapshot, "content/events_en"
    )
    if set(ko_events) != set(en_events):
        errors.append(
            "public story demo exact KO/EN event ID mismatch "
            f"count={len(set(ko_events) ^ set(en_events))}"
        )
    exact_axes = {
        str(axis.get("id", "")): axis
        for axis in exact_release_ledger.get("content_axes", [])
        if isinstance(axis, dict) and axis.get("id")
    }
    event_content_rows = [
        json.dumps(
            {"id": event_id, "ko": ko_events[event_id], "en": en_events[event_id]},
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        for event_id in sorted(ko_events)
    ]
    lifecycle = json.loads(snapshot.text("content/meta/event_lifecycle.json"))
    raw_author_ids = lifecycle.get("author_only_event_ids", [])
    author_ids = {
        event_id for event_id in raw_author_ids
        if isinstance(event_id, str) and event_id
    }
    if raw_author_ids != sorted(author_ids) or len(raw_author_ids) != len(author_ids):
        errors.append("public story demo exact lifecycle IDs must be sorted and unique")
    if not author_ids <= set(ko_events):
        errors.append("public story demo exact lifecycle contains missing events")
    shipping_ids = set(ko_events) - author_ids
    for event_id in sorted(author_ids):
        event = ko_events[event_id]
        if (
            event.get("weight") != 0
            or isinstance(event.get("weight"), bool)
            or event.get("hidden") is not True
            or event.get("conditions") != {"min_turn": 9999}
        ):
            errors.append(
                f"public story demo exact author-only metadata drifted: {event_id}"
            )
    tagged_ids = {
        event_id for event_id, event in ko_events.items()
        if isinstance(event.get("tags"), list) and "author_only" in event["tags"]
    }
    lifecycle_sets = {
        "packaged_event_ids": set(ko_events),
        "shipping_event_ids": shipping_ids,
        "author_only_event_ids": author_ids,
        "tagged_author_only_event_ids": tagged_ids,
        "ledger_only_author_only_event_ids": author_ids - tagged_ids,
    }
    lifecycle_counts = {
        "packaged_events": len(ko_events),
        "shipping_events": len(shipping_ids),
        "author_only_events": len(author_ids),
        "tagged_author_only_events": len(tagged_ids),
        "ledger_only_author_only_events": len(author_ids - tagged_ids),
    }
    for key, value in lifecycle_counts.items():
        if lifecycle.get("counts", {}).get(key) != value:
            errors.append(
                f"public story demo exact lifecycle count {key} drifted"
            )
    for key, values in lifecycle_sets.items():
        if lifecycle.get("sha256", {}).get(key) != newline_id_digest(values):
            errors.append(
                f"public story demo exact lifecycle digest {key} drifted"
            )
    lifecycle_report = snapshot_lifecycle_report(snapshot)
    errors.extend(
        f"public story demo exact lifecycle: {message}"
        for message in lifecycle_report.errors
    )
    if set(lifecycle_report.packaged_event_ids) != set(ko_events):
        errors.append("public story demo exact lifecycle packaged roster drifted")
    if set(lifecycle_report.exempt_ids) != author_ids:
        errors.append(
            "public story demo exact lifecycle author-only exemptions drifted"
        )
    if set(lifecycle_report.product_event_ids) != shipping_ids:
        errors.append("public story demo exact lifecycle shipping roster drifted")

    endings_by_locale: dict[str, dict[str, dict[str, Any]]] = {}
    for locale, path in (
        ("ko", "content/endings.json"), ("en", "content/endings_en.json")
    ):
        raw = json.loads(snapshot.text(path))
        rows = raw if isinstance(raw, list) else raw.get("endings", [])
        endings_by_locale[locale] = {
            str(row["id"]): row for row in rows
            if isinstance(row, dict) and row.get("id")
        }
    ending_ids = sorted(endings_by_locale["ko"])
    if set(ending_ids) != set(endings_by_locale["en"]):
        errors.append("public story demo exact KO/EN ending ID mismatch")
    ending_content_rows = [
        json.dumps(
            {
                "id": ending_id,
                "ko": endings_by_locale["ko"][ending_id],
                "en": endings_by_locale["en"][ending_id],
            },
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        for ending_id in ending_ids
    ]

    exact_fingerprints: dict[str, dict[str, Any]] = {}
    for axis in exact_axes.values():
        result = candidate_fingerprint(axis, ko_events, en_events, owners)
        if result is not None:
            exact_fingerprints[axis["id"]] = result
    recorded_fingerprints = public.get("axis_fingerprints", {})
    if set(recorded_fingerprints) != set(exact_fingerprints):
        errors.append("public story demo exact axis fingerprint set drifted")
    for axis_id, result in exact_fingerprints.items():
        observed = {
            key: result[key]
            for key in ("event_count", "file_count", "ids_sha256", "content_sha256")
        }
        if recorded_fingerprints.get(axis_id) != observed:
            errors.append(
                f"public story demo exact axis fingerprint drifted: {axis_id}"
            )

    asset_paths = snapshot.files_below("assets")
    source_rasters = sorted(
        path for path in asset_paths if Path(path).suffix.lower() in RASTER_SUFFIXES
    )
    packaged_rasters = sorted(
        path for path in source_rasters
        if not snapshot_is_below_gdignore(snapshot, path)
    )
    image_registry = snapshot.text("autoloads/ImageRegistry.gd")
    active_rasters = set(re.findall(
        r'"res://(assets/(?:backgrounds|characters|cg)/[^"\n]+'
        r'\.(?:png|jpg|jpeg|webp))"',
        image_registry,
        re.IGNORECASE,
    ))
    external_rasters = sorted(set(source_rasters) - active_rasters)
    external_packaged = sorted(set(packaged_rasters) - active_rasters)
    source_only = sorted(set(source_rasters) - set(packaged_rasters))
    review_groups = exact_release_ledger["registry_external_raster_review"]["groups"]
    reviewed_all = {
        str(path) for group in review_groups for path in group["paths"]
    }
    reviewed_packaged = {
        str(path) for group in review_groups if group["packaged"]
        for path in group["paths"]
    }
    reviewed_source_only = {
        str(path) for group in review_groups if not group["packaged"]
        for path in group["paths"]
    }
    if reviewed_all != set(external_rasters):
        errors.append("public story demo exact raster review coverage drifted")
    if reviewed_packaged != set(external_packaged):
        errors.append("public story demo exact packaged raster review drifted")
    if reviewed_source_only != set(source_only):
        errors.append("public story demo exact source-only raster review drifted")

    audio_manifest_bytes = snapshot.read("assets/audio/AUDIO_SOURCE_MANIFEST.json")
    audio_manifest = json.loads(audio_manifest_bytes)
    audio_sources = sorted(
        path for path in asset_paths
        if Path(path).suffix.lower() in AUDIO_SUFFIXES
        and not snapshot_is_below_gdignore(snapshot, path)
    )
    if set(audio_manifest.get("assets", {})) != {
        Path(path).name for path in audio_sources
    }:
        errors.append("public story demo exact audio manifest/source roster drifted")

    runtime_paths = [
        path for path in snapshot.paths
        if path.endswith(".gd")
        and path.split("/", 1)[0] in EXPECTED_RUNTIME_ROOTS
    ]
    network_hits = [
        f"{path}:{token}" for path in runtime_paths
        for token in REQUIRED_NETWORK_TOKENS if token in snapshot.text(path)
    ]
    live_ai_hits = [
        f"{path}:{token}" for path in runtime_paths
        for token in AI_RUNTIME_TOKENS if token in snapshot.text(path)
    ]
    exact_main = snapshot.text("scenes/MainGame.gd")
    for relative in exact_export_contract["main_entry_eager_paths"]:
        marker = f'load("res://{relative}").new()'
        if marker not in exact_main:
            errors.append(
                f"public story demo exact MainGame eager marker missing: {marker}"
            )
    exact_registry = snapshot.text(exact_export_contract["boot_registered_owner"])
    registered_event_paths = set(re.findall(
        r'"res://(content/events/[^"\n]+\.json)"', exact_registry
    ))
    if registered_event_paths != set(ko_files):
        errors.append("public story demo exact DataRegistry event roster drifted")

    observed_scalars: dict[str, Any] = {
        "ko_event_files": len(ko_files),
        "en_event_files": len(en_files),
        "ko_events": len(ko_events),
        "en_events": len(en_events),
        "event_ids_sha256": sha_lines(sorted(ko_events)),
        "event_content_sha256": sha_lines(event_content_rows),
        "shipping_ko_events": len(shipping_ids),
        "shipping_en_events": len(shipping_ids),
        "shipping_event_ids_sha256": sha_lines(sorted(shipping_ids)),
        "author_only_events": len(author_ids),
        "author_only_event_ids_sha256": sha_lines(sorted(author_ids)),
        "ko_endings": len(endings_by_locale["ko"]),
        "en_endings": len(endings_by_locale["en"]),
        "ending_ids_sha256": sha_lines(ending_ids),
        "ending_content_sha256": sha_lines(ending_content_rows),
        "qualitative_fact_count": sum(
            len(axis.get("facts", [])) for axis in exact_axes.values()
        ),
        "active_art_assets": len(active_rasters),
        "source_raster_assets": len(source_rasters),
        "packaged_raster_assets": len(packaged_rasters),
        "registry_external_source_raster_assets": len(external_rasters),
        "registry_external_packaged_raster_assets": len(external_packaged),
        "source_only_gdignored_raster_assets": len(source_only),
        "registry_external_raster_paths_sha256": sha_lines(external_rasters),
        "registry_external_packaged_paths_sha256": sha_lines(external_packaged),
        "source_only_gdignored_paths_sha256": sha_lines(source_only),
        "audio_source_assets": len(audio_sources),
        "audio_manifest_sha256": hashlib.sha256(audio_manifest_bytes).hexdigest(),
        "network_api_hits": len(network_hits),
        "live_ai_api_hits": len(live_ai_hits),
    }
    for key in PUBLIC_CORPUS_SCALAR_FIELDS:
        if public.get(key) != observed_scalars.get(key):
            errors.append(
                f"public story demo {key}: observed {observed_scalars.get(key)!r} "
                f"!= ledger {public.get(key)!r}"
            )
    validate_snapshot_facts(
        exact_release_ledger, snapshot, ko_events, en_events, errors
    )
    return exact_fingerprints


def reachable_registered_event_ids(
    roots: set[str],
    events: dict[str, dict[str, Any]],
    errors: list[str],
    owner: str,
    suppressed: set[str] | None = None,
    follow_up_replacements: dict[tuple[str, str], str] | None = None,
) -> set[str]:
    """Traverse immediate authored choice links and fail closed on registry gaps."""
    excluded = suppressed or set()
    reachable: set[str] = set()
    pending = list(roots)
    while pending:
        event_id = str(pending.pop()).strip()
        if not event_id or event_id in excluded or event_id in reachable:
            continue
        event = events.get(event_id)
        if not isinstance(event, dict):
            errors.append(f"{owner}: missing registered event {event_id}")
            continue
        reachable.add(event_id)
        for raw_choice in event.get("choices", []):
            if not isinstance(raw_choice, dict):
                continue
            follow_up = str(raw_choice.get("follow_up_event", "")).strip()
            if follow_up_replacements:
                follow_up = follow_up_replacements.get(
                    (event_id, follow_up), follow_up
                )
            if follow_up and follow_up not in excluded:
                pending.append(follow_up)
    return reachable


def v2_reachable_event_surfaces(
    ledger: dict[str, Any],
    events: dict[str, dict[str, Any]],
    errors: list[str],
) -> tuple[set[str], set[str], set[str]]:
    """Build every authored surface shown before and during the 24-week demo."""
    contract = load_json(DEMO_V2_PATH)
    bundles = contract.get("scene_bundles", {})
    if not isinstance(bundles, dict):
        errors.append("demo_core_loop_v2.scene_bundles must be an object")
        return set(), set(), set()

    suppressions_by_root: dict[str, set[str]] = {}
    reachable: set[str] = set()
    for bundle_id, raw_bundle in bundles.items():
        if not isinstance(raw_bundle, dict):
            errors.append(f"demo bundle {bundle_id} must be an object")
            continue
        raw_roots = raw_bundle.get("existing_roots", [])
        raw_suppressed = raw_bundle.get("suppress_follow_up_events", [])
        if not isinstance(raw_roots, list) or not isinstance(raw_suppressed, list):
            errors.append(f"demo bundle {bundle_id}: roots/suppressions must be arrays")
            continue
        roots = {str(value).strip() for value in raw_roots if str(value).strip()}
        suppressed = {
            str(value).strip() for value in raw_suppressed if str(value).strip()
        }
        for root in roots:
            suppressions_by_root.setdefault(root, set()).update(suppressed)
        reachable.update(reachable_registered_event_ids(
            roots, events, errors, f"V2 bundle {bundle_id}", suppressed
        ))

    spine = load_json(NARRATIVE_SPINE_PATH)
    scope = contract.get("scope", {})
    min_week = int(scope.get("min_week", 1)) if isinstance(scope, dict) else 1
    max_week = int(scope.get("max_week", 24)) if isinstance(scope, dict) else 24
    demo = spine.get("demo", {}) if isinstance(spine, dict) else {}
    sequences = demo.get("sequences", []) if isinstance(demo, dict) else []
    if not isinstance(sequences, list) or not sequences:
        errors.append("narrative_spine.demo.sequences must be a non-empty array")
        sequences = []
    spine_roots: set[str] = set()
    for index, raw_sequence in enumerate(sequences):
        if not isinstance(raw_sequence, dict):
            errors.append(f"narrative spine demo sequence {index} must be an object")
            continue
        weeks = raw_sequence.get("weeks", [])
        if not isinstance(weeks, list) or len(weeks) != 2 or any(
            not isinstance(value, int) for value in weeks
        ):
            errors.append(f"narrative spine demo sequence {index}: invalid weeks")
            continue
        if max(weeks[0], min_week) > min(weeks[1], max_week):
            continue
        raw_roots = raw_sequence.get("foreground_roots", [])
        if not isinstance(raw_roots, list):
            errors.append(f"narrative spine demo sequence {index}: roots must be an array")
            continue
        spine_roots.update(str(value).strip() for value in raw_roots if str(value).strip())
    runtime_text = gd_function_block(
        ROOT / "systems/DemoCoreLoopV2.gd", "prepare_demo_collision"
    )
    dynamic_matches = re.findall(
        r'(?:dirty_root\s*=\s*"([^"]+)"|roots\.append\(\s*"([^"]+)"\s*\))',
        runtime_text,
    )
    dynamic_roots = {
        value for pair in dynamic_matches for value in pair if value
    }
    expected_dynamic_roots = set(
        ledger["v2_reachability_contract"][
            "runtime_dynamic_roots"
        ]
    )
    if dynamic_roots != expected_dynamic_roots:
        errors.append(
            "V2 runtime dynamic roots differ from ledger: "
            f"runtime={sorted(dynamic_roots)} ledger={sorted(expected_dynamic_roots)}"
        )
    if not dynamic_roots <= spine_roots:
        errors.append(
            "V2 runtime dynamic roots missing from narrative spine: "
            f"{sorted(dynamic_roots - spine_roots)}"
        )
    for root in sorted(dynamic_roots):
        reachable.update(reachable_registered_event_ids(
            {root}, events, errors, "V2 runtime dynamic root",
            suppressions_by_root.get(root, set()),
        ))

    missing_spine_surface = spine_roots - reachable
    if missing_spine_surface:
        errors.append(
            "V2 narrative spine claims roots absent from executable bundle/dynamic surface: "
            f"{sorted(missing_spine_surface)}"
        )

    prologue_block = gd_function_block(
        ROOT / "scenes/MainGame.gd", "_begin_month_story_and_render"
    )
    resume_prologue_markers = re.findall(
        r'var\s+prologue_root\s*:=\s*"([^"]+)"',
        prologue_block,
    )
    retail_cold_open_markers = re.findall(
        r'if\s+not\s+GameState\.flags\.get\('
        r'"story_flashforward_seen",\s*false\s*\)\s*:\s*'
        r'prologue_root\s*=\s*"([^"]+)"',
        prologue_block,
    )
    expected_prologue = str(
        ledger["v2_reachability_contract"][
            "fresh_start_prologue_root"
        ]
    ).strip()
    fresh_prologue_contract = all((
        re.search(r'DEMO_CORE_LOOP_V2\.is_active\(\)', prologue_block),
        re.search(r'DEMO_CORE_LOOP_V2\.begin_fresh_w1_onboarding\(\)', prologue_block),
        re.search(r'_go_story_mode\(\s*\[\s*prologue_root\s*\]\s*\)', prologue_block),
    ))
    if not fresh_prologue_contract \
            or retail_cold_open_markers != [expected_prologue] \
            or resume_prologue_markers != ["story_arrival"]:
        errors.append(
            "V2 fresh-start prologue runtime marker differs from ledger: "
            f"cold_open={retail_cold_open_markers} "
            f"resume={resume_prologue_markers} ledger={expected_prologue!r}"
        )

    opening = bundles.get("opening_interview_math", {})
    if not isinstance(opening, dict):
        errors.append("opening_interview_math bundle must be an object")
        opening = {}
    trigger = opening.get("preplan_trigger", {})
    if not isinstance(trigger, dict):
        errors.append("opening_interview_math.preplan_trigger must be an object")
        trigger = {}
    trigger_event_id = str(trigger.get("event_id", "")).strip()
    if not trigger_event_id:
        errors.append("opening_interview_math pre-plan trigger event is empty")

    replacement_block = gd_function_block(
        ROOT / "systems/DemoCoreLoopV2.gd", "opening_follow_up_event"
    )
    legacy_queue_block = gd_function_block(
        ROOT / "systems/DemoCoreLoopV2.gd",
        "_legacy_preplan_opening_queue_matches",
    )
    source_match = re.search(r'event_id\s*!=\s*"([^"]+)"', replacement_block)
    target_match = re.search(r'follow_up_id\s*!=\s*"([^"]+)"', replacement_block)
    replacement_source = source_match.group(1) if source_match else ""
    replacement_target = target_match.group(1) if target_match else ""
    if (replacement_source, replacement_target) != (
        "story_prologue_meal", "story_pressure"
    ):
        errors.append(
            "V2 fresh-start replacement must target only "
            "story_prologue_meal->story_pressure"
        )
    fresh_w1_replacement = re.search(
        r'if\s+str\(onboarding\.get\(\s*"origin",\s*""\s*\)\)\s*'
        r'==\s*W1_ONBOARDING_ORIGIN.*?'
        r'and\s+str\(onboarding\.get\(\s*"phase",\s*""\s*\)\)\s*'
        r'==\s*"prologue".*?'
        r'and\s+int\(GameState\.turn\)\s*==\s*1\s*:\s*'
        r'(?:#[^\n]*\n\s*)*return\s+""',
        replacement_block,
        re.S,
    )
    if not fresh_w1_replacement:
        errors.append(
            "V2 fresh-start replacement must end the ORDER-101 W1 prologue "
            "without a follow-up event"
        )
    for marker in (
        "_preplan_opening_base_available(state)",
        "_legacy_preplan_opening_queue_matches(reserved_queue)",
        "_preplan_opening_trigger()",
        '"story_job_unlocked"',
        '"opening_interview_application_sent"',
    ):
        if marker not in replacement_block:
            errors.append(
                f"V2 legacy opening replacement lost runtime guard {marker!r}"
            )
    for marker in (
        "resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID)",
        "reserved_queue.size()",
        "reserved_queue[root_index]",
    ):
        if marker not in legacy_queue_block:
            errors.append(
                f"V2 legacy opening queue check lost runtime guard {marker!r}"
            )
    if not re.search(
        r"return\s+OPENING_APPLICATION_EVENT_ID\s*\\?\s*"
        r"if\s+trigger_event_id\s*==\s*OPENING_APPLICATION_EVENT_ID\s+"
        r"else\s+follow_up_id",
        replacement_block,
        re.S,
    ):
        errors.append("V2 legacy opening replacement lost its trigger return")
    replacements = {
        (replacement_source, replacement_target): "",
    } if replacement_source and replacement_target else {}
    prologue = reachable_registered_event_ids(
        {expected_prologue},
        events,
        errors,
        "V2 fresh-start prologue",
        follow_up_replacements=replacements,
    )
    if (
        "story_prologue_meal" not in prologue
        or "story_pressure" in prologue
        or trigger_event_id in prologue
    ):
        errors.append(
            "V2 fresh-start prologue must end after story_prologue_meal "
            "without story_pressure or the legacy application preview"
        )
    legacy_replacements = {
        (replacement_source, replacement_target): trigger_event_id,
    } if replacement_source and replacement_target and trigger_event_id else {}
    legacy_prologue = reachable_registered_event_ids(
        {expected_prologue},
        events,
        errors,
        "V2 legacy pre-ORDER-101 prologue",
        follow_up_replacements=legacy_replacements,
    )
    if "story_pressure" in legacy_prologue or trigger_event_id not in legacy_prologue:
        errors.append(
            "V2 legacy pre-ORDER-101 prologue must still replace story_pressure "
            f"with {trigger_event_id or '<missing trigger>'}"
        )

    chapter_block = gd_function_block(
        ROOT / "scenes/MainGame.gd", "_opening_chapter_event_id"
    )
    chapter_markers = re.findall(r'return\s+"([^"]+)"', chapter_block)
    expected_chapter = str(
        ledger["v2_reachability_contract"]["fresh_start_chapter_root"]
    ).strip()
    if chapter_markers != [expected_chapter]:
        errors.append(
            "V2 fresh-start chapter runtime marker differs from ledger: "
            f"runtime={chapter_markers} ledger={expected_chapter!r}"
        )
    chapter = reachable_registered_event_ids(
        {expected_chapter}, events, errors, "V2 fresh-start chapter card"
    )
    return reachable, prologue, chapter


def validate_structure(ledger: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if ledger.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    decisions = ledger.get("decision_boundary", {})
    for key in ("final_age_rating", "content_removal", "export_filter_change"):
        if decisions.get(key) != "user_required":
            errors.append(f"decision_boundary.{key} must remain user_required")

    sources = ledger.get("official_sources", [])
    if not isinstance(sources, list) or not sources:
        errors.append("official_sources must be a non-empty list")
    else:
        source_ids: set[str] = set()
        for index, source in enumerate(sources):
            where = f"official_sources[{index}]"
            if not isinstance(source, dict):
                errors.append(f"{where}: must be an object")
                continue
            source_id = str(source.get("id", "")).strip()
            if not source_id or source_id in source_ids:
                errors.append(f"{where}: id missing/duplicate")
            source_ids.add(source_id)
            if not str(source.get("url", "")).startswith("https://"):
                errors.append(f"{where}: https URL required")
            if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(source.get("accessed", ""))):
                errors.append(f"{where}: accessed must be YYYY-MM-DD")
            if not str(source.get("boundary", "")).strip():
                errors.append(f"{where}: boundary missing")

    raster_review = ledger.get("registry_external_raster_review", {})
    if raster_review.get("final_human_verdict") != "user_required":
        errors.append("registry external raster final_human_verdict must remain user_required")
    groups = raster_review.get("groups", [])
    if not isinstance(groups, list) or not groups:
        errors.append("registry_external_raster_review.groups must be non-empty")
    else:
        review_paths: list[str] = []
        group_ids: set[str] = set()
        for group in groups:
            group_id = str(group.get("id", "")).strip() if isinstance(group, dict) else ""
            if not group_id or group_id in group_ids:
                errors.append("registry external raster review group id missing/duplicate")
                continue
            group_ids.add(group_id)
            paths = group.get("paths", [])
            if not isinstance(paths, list) or not paths:
                errors.append(f"registry raster group {group_id}: paths missing")
                continue
            if not str(group.get("review", "")).strip():
                errors.append(f"registry raster group {group_id}: review missing")
            if not isinstance(group.get("packaged"), bool):
                errors.append(f"registry raster group {group_id}: packaged must be boolean")
            review_paths.extend(str(path) for path in paths)
        if len(review_paths) != len(set(review_paths)):
            errors.append("registry external raster review paths must be unique")

    profiles = ledger.get("export_contract", {}).get("profiles", {})
    if set(profiles) != set(PROFILE_IDS):
        errors.append(f"export profiles must be exactly {list(PROFILE_IDS)}")
    export_contract = ledger.get("export_contract", {})
    staged_demo = export_contract.get("staged_public_demo")
    if not isinstance(staged_demo, dict):
        errors.append("export_contract.staged_public_demo must be an object")
    else:
        if set(staged_demo) != set(PUBLIC_STORY_DEMO_CONTRACT):
            errors.append(
                "staged public demo fields must be exactly "
                f"{sorted(PUBLIC_STORY_DEMO_CONTRACT)}"
            )
        for key, expected in PUBLIC_STORY_DEMO_CONTRACT.items():
            if staged_demo.get(key) != expected:
                errors.append(
                    f"staged public demo {key}: {staged_demo.get(key)!r} != {expected!r}"
                )
        if staged_demo.get("profile") in profiles:
            errors.append("staged public demo must remain outside export preset profiles")
    public_package = ledger.get("public_story_demo_package_contract", {})
    if not isinstance(public_package, dict):
        errors.append("public_story_demo_package_contract must be an object")
    else:
        for artifact_key, expected in PUBLIC_STORY_DEMO_ARTIFACT_CONTRACT.items():
            if public_package.get(artifact_key) != expected:
                errors.append(
                    f"public story demo {artifact_key} exact artifact contract drifted"
                )
    for key in ("main_entry_eager_paths", "main_entry_hub_paths", "pack_smoke_paths"):
        values = export_contract.get(key, [])
        if not isinstance(values, list) or not values or len(values) != len(set(values)):
            errors.append(f"export_contract.{key} must be a non-empty unique list")
    eager_paths = set(export_contract.get("main_entry_eager_paths", []))
    hub_paths = set(export_contract.get("main_entry_hub_paths", []))
    if not hub_paths <= eager_paths:
        errors.append("export_contract.main_entry_hub_paths must be a subset of eager paths")

    v2_contract = ledger.get("v2_reachability_contract", {})
    dynamic_roots = v2_contract.get("runtime_dynamic_roots", [])
    if (
        not isinstance(dynamic_roots, list)
        or not dynamic_roots
        or dynamic_roots != sorted(set(dynamic_roots))
    ):
        errors.append("v2 runtime_dynamic_roots must be a non-empty sorted unique list")
    if not str(v2_contract.get("fresh_start_prologue_root", "")).strip():
        errors.append("v2 fresh_start_prologue_root must be non-empty")
    if not str(v2_contract.get("fresh_start_chapter_root", "")).strip():
        errors.append("v2 fresh_start_chapter_root must be non-empty")

    legacy_contract = ledger.get("legacy_reachability_contract", {})
    if legacy_contract.get("owner") != "content/meta/event_director.json":
        errors.append("legacy reachability owner must be content/meta/event_director.json")
    for key in ("required_foreground_ids", "registered_but_not_foreground_ids"):
        values = legacy_contract.get(key, [])
        if (
            not isinstance(values, list)
            or not values
            or values != sorted(set(values))
        ):
            errors.append(f"legacy_reachability_contract.{key} must be sorted/unique")
    required_foreground = set(legacy_contract.get("required_foreground_ids", []))
    condition_anchors = legacy_contract.get("required_event_conditions", {})
    if not isinstance(condition_anchors, dict) or set(condition_anchors) != required_foreground:
        errors.append(
            "legacy condition anchors must exactly match required foreground IDs"
        )
    axes = ledger.get("content_axes", [])
    axis_ids = [axis.get("id") for axis in axes]
    if len(axis_ids) != len(set(axis_ids)):
        errors.append("content axis ids must be unique")
    if set(axis_ids) != AXIS_IDS:
        errors.append(f"content axes mismatch: {sorted(set(axis_ids) ^ AXIS_IDS)}")

    network = ledger.get("network_contract", {})
    if tuple(network.get("runtime_roots", [])) != EXPECTED_RUNTIME_ROOTS:
        errors.append(f"network runtime_roots must be exactly {list(EXPECTED_RUNTIME_ROOTS)}")
    if tuple(network.get("forbidden_api_tokens", [])) != REQUIRED_NETWORK_TOKENS:
        errors.append("network forbidden_api_tokens must match the required fail-closed set")
    for field in NETWORK_FALSE_FIELDS:
        if network.get(field) is not False:
            errors.append(f"network_contract.{field} must remain false")
    if network.get("local_data_mods") is not True:
        errors.append("network_contract.local_data_mods must remain true")

    for axis in axes:
        axis_id = axis.get("id", "<missing>")
        facts = axis.get("facts")
        if not isinstance(facts, list) or not facts:
            errors.append(f"{axis_id}: facts must be non-empty")
            continue
        fact_ids: set[str] = set()
        for fact in facts:
            fact_id = fact.get("id", "<missing>")
            where = f"{axis_id}.{fact_id}"
            if fact_id in fact_ids:
                errors.append(f"{where}: duplicate fact id")
            fact_ids.add(fact_id)
            if not fact.get("summary_ko"):
                errors.append(f"{where}: summary_ko missing")
            if not isinstance(fact.get("event_backed"), bool):
                errors.append(f"{where}: event_backed must be boolean")
            if fact.get("intensity") not in INTENSITIES:
                errors.append(f"{where}: intensity missing/invalid")
            if not fact.get("media"):
                errors.append(f"{where}: media missing")
            owners = fact.get("owner_paths")
            if not isinstance(owners, list) or not owners:
                errors.append(f"{where}: owner_paths missing")
            if not isinstance(fact.get("event_ids"), list):
                errors.append(f"{where}: event_ids must be a list")
            elif fact.get("event_backed") is True and not fact["event_ids"]:
                errors.append(f"{where}: event-backed fact requires event_ids")
            elif fact.get("event_backed") is False and fact["event_ids"]:
                errors.append(f"{where}: non-event fact must not claim event_ids")
            if not fact.get("evidence_tokens"):
                errors.append(f"{where}: evidence_tokens missing")
            per_profile = fact.get("per_profile", {})
            if set(per_profile) != set(PROFILE_IDS):
                errors.append(f"{where}: per_profile must cover all three profiles")
                continue
            for profile_id, state in per_profile.items():
                pwhere = f"{where}.{profile_id}"
                if not isinstance(state.get("packaged"), bool):
                    errors.append(f"{pwhere}: packaged must be boolean")
                elif ledger.get("export_contract", {}).get("export_filter") == "all_resources" and not state["packaged"]:
                    errors.append(f"{pwhere}: all_resources fact cannot claim package absence")
                if state.get("runtime_load") not in RUNTIME_LOAD:
                    errors.append(f"{pwhere}: runtime_load missing/invalid")
                if state.get("fresh_start_reachability") not in FRESH_START:
                    errors.append(f"{pwhere}: fresh_start_reachability missing/invalid")
                if not state.get("basis"):
                    errors.append(f"{pwhere}: reachability basis missing")
    return errors


def validate_presets(ledger: dict[str, Any], errors: list[str]) -> list[dict[str, str]]:
    contract = ledger["export_contract"]
    presets = parse_export_presets()
    if len(presets) != contract["preset_count"]:
        errors.append(f"export preset count {len(presets)} != {contract['preset_count']}")
    by_name = {preset.get("name", ""): preset for preset in presets}
    expected_names: set[str] = set()
    for profile_id, profile in contract["profiles"].items():
        expected_names.update(profile["preset_names"])
        expected_features = set(profile["features"])
        for name in profile["preset_names"]:
            preset = by_name.get(name)
            if not preset:
                errors.append(f"{profile_id}: missing preset {name}")
                continue
            actual_features = {item for item in preset.get("custom_features", "").split(",") if item}
            if actual_features != expected_features:
                errors.append(f"{name}: features {sorted(actual_features)} != {sorted(expected_features)}")
    if set(by_name) != expected_names:
        errors.append(f"unexpected/missing preset names: {sorted(set(by_name) ^ expected_names)}")
    for preset in presets:
        name = preset.get("name", f"preset.{preset.get('index')}")
        for key in ("export_filter", "include_filter", "exclude_filter"):
            if preset.get(key) != contract[key]:
                errors.append(f"{name}: {key}={preset.get(key)!r} != {contract[key]!r}")
    return presets


def validate_staged_public_demo(ledger: dict[str, Any], errors: list[str]) -> None:
    contract = ledger["export_contract"]["staged_public_demo"]
    build_path = ROOT / contract["build_pipeline"]
    package_audit_path = ROOT / contract["package_audit"]
    entry_path = ROOT / contract["entry_scene"].removeprefix("res://")
    identity_path = ROOT / contract["identity_owner"]
    for label, path in (
        ("build pipeline", build_path),
        ("package audit", package_audit_path),
        ("entry scene", entry_path),
        ("identity owner", identity_path),
    ):
        if not path.is_file():
            errors.append(f"staged public demo {label} missing: {path.relative_to(ROOT)}")
    if not build_path.is_file():
        return
    build_text = build_path.read_text(encoding="utf-8")
    required_markers = (
        f'readonly PROFILE="{contract["profile"]}"',
        f'readonly ENTRY_SCENE="{contract["entry_scene"]}"',
        'git -C "$PROJECT_DIR" archive --format=tar "$SOURCE_COMMIT"',
        're.search(r\'(?m)^name="macOS"$\'',
        '("name", \'"Story Demo macOS"\')',
        '"months=6" "weeks=24" "settlements=6"',
    )
    for marker in required_markers:
        if marker not in build_text:
            errors.append(f"staged public demo build marker missing: {marker}")
    if 'set_section_value(presets, f"preset.{mac_number}", "export_filter"' in build_text:
        errors.append("staged public demo must not rewrite the inherited all_resources filter")

    human_gates = load_json(identity_path)
    validate_public_story_demo_human_gates(human_gates, contract, errors)


def validate_public_story_demo_human_gates(
    human_gates: dict[str, Any],
    contract: dict[str, Any],
    errors: list[str],
) -> None:
    profile = contract["profile"]
    candidate = human_gates.get("release_candidates", {}).get(profile, {})
    if not isinstance(candidate, dict) or candidate.get("status") != "active":
        errors.append("staged public demo human-gate candidate must be active")
    if canonical_json_sha256(candidate) != PUBLIC_STORY_DEMO_CANDIDATE_SHA256:
        errors.append("staged public demo active candidate row digest drifted")

    raw_profile_gates = [
        gate
        for gate in human_gates.get("gates", [])
        if isinstance(gate, dict) and gate.get("revision") == profile
    ]
    raw_gate_ids = [str(gate.get("id", "")) for gate in raw_profile_gates]
    if len(raw_profile_gates) != len(PUBLIC_STORY_DEMO_GATE_CONTRACT):
        errors.append(
            "staged public demo must have exactly four raw human-gate rows"
        )
    if len(raw_gate_ids) != len(set(raw_gate_ids)):
        errors.append("staged public demo human-gate IDs must be unique")
    profile_gates = {
        str(gate.get("id", "")): gate for gate in raw_profile_gates
    }
    if set(profile_gates) != set(PUBLIC_STORY_DEMO_GATE_CONTRACT):
        errors.append(
            "staged public demo human gates must be exactly one user GO and three native OPEN: "
            f"{sorted(profile_gates)}"
        )
    for gate_id, expected in PUBLIC_STORY_DEMO_GATE_CONTRACT.items():
        gate = profile_gates.get(gate_id, {})
        if canonical_json_sha256(gate) != PUBLIC_STORY_DEMO_GATE_ROW_SHA256[gate_id]:
            errors.append(
                f"staged public demo gate {gate_id} row digest drifted"
            )
        if gate.get("state") != expected["state"]:
            errors.append(
                f"staged public demo gate {gate_id} state must be {expected['state']}"
            )
        if gate.get("gate") != expected["gate"]:
            errors.append(f"staged public demo gate {gate_id} label drifted")
        scope = gate.get("scope", {}) if isinstance(gate, dict) else {}
        if not isinstance(scope, dict):
            scope = {}
        if scope.get("blocks") != expected["blocks"]:
            errors.append(f"staged public demo gate {gate_id} blocks drifted")
        if scope.get("content") != expected["content"]:
            errors.append(f"staged public demo gate {gate_id} content scope drifted")

    candidate_identity = {
        "commit": contract["package_source_commit"],
        "tree": contract["package_source_tree"],
        "manifest_sha256": contract["manifest_sha256"],
    }
    for key, expected in candidate_identity.items():
        if candidate.get(key) != expected:
            errors.append(f"staged public demo active candidate {key} drifted")
    candidate_note = str(candidate.get("note", ""))
    for token in (
        "BUILD 2026.08.31.1", "공개 M01~M06", "사용자 최종 GO는 M01~M06",
        "JA·zh-CN·zh-TW 원어민 출시 claim 세 건만 별도 OPEN",
        "main과 본편 이관은 HOLD", "AP 데이터·엔진 삭제 GO가 아니다",
    ):
        if token not in candidate_note:
            errors.append(
                f"staged public demo active candidate note lacks {token!r}"
            )
    note_folded = candidate_note.casefold()
    for forbidden in (
        "m01~m60", "m01–m60", "전체 게임 최종 go", "원어민도 완료",
        "main과 본편 이관은 go",
    ):
        if forbidden in note_folded:
            errors.append(
                "staged public demo active candidate note expanded beyond its gate: "
                f"{forbidden}"
            )

    user_gate = profile_gates.get("story_demo_m1_m6_user_play", {})
    evidence = user_gate.get("evidence", {}) if isinstance(user_gate, dict) else {}
    if not isinstance(evidence, dict):
        evidence = {}
    for key, expected in candidate_identity.items():
        if evidence.get(key) != expected:
            errors.append(f"staged public demo user GO {key} drifted from exact contract")
    if (
        evidence.get("authority") != "user_final"
        or evidence.get("decided_by") != "user"
        or evidence.get("verdict") != "GO"
    ):
        errors.append("staged public demo done gate requires exact user-final GO evidence")
    if evidence.get("record") != PUBLIC_STORY_DEMO_GATE_CONTRACT[
        "story_demo_m1_m6_user_play"
    ]["record"]:
        errors.append("staged public demo user GO evidence record drifted")
    user_why = str(user_gate.get("why", ""))
    for token in ("BUILD 2026.08.31.1", "AP 표면 0", "사람이 직접 판정"):
        if token not in user_why:
            errors.append(f"staged public demo user GO why lacks {token!r}")
    semantic_blob = "\n".join(
        str(value)
        for value in (
            user_gate.get("gate", ""), user_gate.get("why", ""),
            evidence.get("record", ""),
        )
    ).casefold()
    for forbidden in ("m01~m60", "m01–m60", "전체 게임 최종 go", "본편 전체 go"):
        if forbidden in semantic_blob:
            errors.append(
                f"staged public demo user GO meaning expanded beyond M01~M06: {forbidden}"
            )


def validate_corpus(
    ledger: dict[str, Any],
    errors: list[str],
) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]], dict[str, str], dict[str, dict[str, Any]]]:
    ko_events, owners, ko_files = load_event_corpus(EVENT_ROOT)
    en_events, _en_owners, en_files = load_event_corpus(EVENT_EN_ROOT)
    corpus = ledger["corpus_contract"]
    observed = {
        "ko_event_files": len(ko_files),
        "en_event_files": len(en_files),
        "ko_events": len(ko_events),
        "en_events": len(en_events),
        "event_ids_sha256": sha_lines(sorted(ko_events)),
    }
    for key, value in observed.items():
        if corpus.get(key) != value:
            errors.append(f"corpus {key}: observed {value!r} != ledger {corpus.get(key)!r}")
    if set(ko_events) != set(en_events):
        errors.append(f"KO/EN event id mismatch count={len(set(ko_events) ^ set(en_events))}")

    lifecycle = audit_author_only(ROOT)
    errors.extend(f"event lifecycle: {message}" for message in lifecycle.errors)
    if lifecycle.packaged_event_ids != frozenset(ko_events):
        errors.append(
            "event lifecycle packaged corpus differs from release corpus: "
            f"delta={len(lifecycle.packaged_event_ids ^ frozenset(ko_events))}"
        )
    lifecycle_observed = {
        "shipping_ko_events": len(lifecycle.product_event_ids),
        "shipping_en_events": len(lifecycle.product_event_ids),
        "shipping_event_ids_sha256": sha_lines(sorted(lifecycle.product_event_ids)),
        "author_only_events": len(lifecycle.exempt_ids),
        "author_only_event_ids_sha256": sha_lines(sorted(lifecycle.exempt_ids)),
    }
    for key, value in lifecycle_observed.items():
        if corpus.get(key) != value:
            errors.append(
                f"corpus {key}: observed {value!r} != ledger {corpus.get(key)!r}"
            )
    ending_ids_by_locale: dict[str, list[str]] = {}
    endings_by_locale: dict[str, dict[str, dict[str, Any]]] = {}
    for locale, path_key, expected_key in (
        ("ko", "content/endings.json", "ko_endings"),
        ("en", "content/endings_en.json", "en_endings"),
    ):
        value = load_json(ROOT / path_key)
        endings = value if isinstance(value, list) else value.get("endings", [])
        if not isinstance(endings, list):
            errors.append(f"{path_key}: endings must be an array")
            endings = []
        if len(endings) != corpus[expected_key]:
            errors.append(f"{path_key}: {len(endings)} != {corpus[expected_key]}")
        ending_ids = [
            str(ending.get("id", "")).strip()
            for ending in endings if isinstance(ending, dict)
        ]
        if len(ending_ids) != len(endings) or any(not value for value in ending_ids):
            errors.append(f"{path_key}: every ending must have a non-empty id")
        if len(set(ending_ids)) != len(ending_ids):
            errors.append(f"{path_key}: duplicate ending ids")
        ending_ids_by_locale[locale] = ending_ids
        endings_by_locale[locale] = {
            str(ending.get("id")): ending
            for ending in endings
            if isinstance(ending, dict) and ending.get("id")
        }
    if set(ending_ids_by_locale.get("ko", [])) != set(ending_ids_by_locale.get("en", [])):
        errors.append("KO/EN ending id mismatch")
    ending_ids_sha = sha_lines(sorted(ending_ids_by_locale.get("ko", [])))
    if corpus.get("ending_ids_sha256") != ending_ids_sha:
        errors.append(
            f"corpus ending_ids_sha256: observed {ending_ids_sha!r} "
            f"!= ledger {corpus.get('ending_ids_sha256')!r}"
        )
    ending_content_rows = [
        json.dumps(
            {
                "id": ending_id,
                "ko": endings_by_locale.get("ko", {}).get(ending_id, {}),
                "en": endings_by_locale.get("en", {}).get(ending_id, {}),
            },
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        for ending_id in sorted(endings_by_locale.get("ko", {}))
    ]
    ending_content_sha = sha_lines(ending_content_rows)
    if corpus.get("ending_content_sha256") != ending_content_sha:
        errors.append(
            f"corpus ending_content_sha256: observed {ending_content_sha!r} "
            f"!= ledger {corpus.get('ending_content_sha256')!r}"
        )

    registry = (ROOT / ledger["export_contract"]["boot_registered_owner"]).read_text(encoding="utf-8")
    event_paths = set(re.findall(r'"res://(content/events/[^"\n]+\.json)"', registry))
    source_paths = {path.relative_to(ROOT).as_posix() for path in ko_files}
    if event_paths != source_paths:
        errors.append(f"DataRegistry event paths mismatch source files={len(event_paths ^ source_paths)}")

    art_text = (ROOT / "docs/ART_AI_AUDIT.md").read_text(encoding="utf-8")
    art_match = re.search(r"Inventory:\s*\d+ CG / \d+ portraits / \d+ backgrounds / (\d+) total", art_text)
    if not art_match or int(art_match.group(1)) != corpus["active_art_assets"]:
        errors.append("active art inventory total does not match docs/ART_AI_AUDIT.md")
    raster_suffixes = {".png", ".jpg", ".jpeg", ".webp"}
    source_rasters = sorted(
        path.relative_to(ROOT).as_posix()
        for path in (ROOT / "assets").rglob("*")
        if path.is_file() and path.suffix.lower() in raster_suffixes
    )
    packaged_rasters = sorted(
        relative
        for relative in source_rasters
        if not is_below_gdignore(ROOT / relative)
    )
    image_registry = (ROOT / "autoloads/ImageRegistry.gd").read_text(encoding="utf-8")
    active_rasters = set(re.findall(
        r'"res://(assets/(?:backgrounds|characters|cg)/[^"\n]+'
        r'\.(?:png|jpg|jpeg|webp))"',
        image_registry,
        re.IGNORECASE,
    ))
    if len(active_rasters) != corpus["active_art_assets"]:
        errors.append(
            f"active ImageRegistry raster count {len(active_rasters)} "
            f"!= ledger {corpus['active_art_assets']}"
        )
    external_rasters = sorted(set(source_rasters) - active_rasters)
    external_packaged_rasters = sorted(set(packaged_rasters) - active_rasters)
    source_only_rasters = sorted(set(source_rasters) - set(packaged_rasters))
    external_content_rows = [
        f"{relative}:{file_sha256(ROOT / relative)}"
        for relative in external_rasters
    ]
    external_packaged_content_rows = [
        f"{relative}:{file_sha256(ROOT / relative)}"
        for relative in external_packaged_rasters
    ]
    raster_observed = {
        "source_raster_assets": len(source_rasters),
        "packaged_raster_assets": len(packaged_rasters),
        "registry_external_source_raster_assets": len(external_rasters),
        "registry_external_packaged_raster_assets": len(external_packaged_rasters),
        "source_only_gdignored_raster_assets": len(source_only_rasters),
        "registry_external_raster_paths_sha256": sha_lines(external_rasters),
        "registry_external_raster_content_sha256": sha_lines(external_content_rows),
        "registry_external_packaged_paths_sha256": sha_lines(external_packaged_rasters),
        "registry_external_packaged_content_sha256": sha_lines(
            external_packaged_content_rows
        ),
        "source_only_gdignored_paths_sha256": sha_lines(source_only_rasters),
    }
    for key, value in raster_observed.items():
        if corpus.get(key) != value:
            errors.append(
                f"corpus {key}: observed {value!r} != ledger {corpus.get(key)!r}"
            )
    review_groups = ledger["registry_external_raster_review"]["groups"]
    reviewed_rasters = {
        str(path)
        for group in review_groups if isinstance(group, dict)
        for path in group.get("paths", [])
    }
    if reviewed_rasters != set(external_rasters):
        errors.append(
            "registry external raster review coverage mismatch: "
            f"delta={sorted(reviewed_rasters ^ set(external_rasters))[:8]}"
        )
    reviewed_packaged = {
        str(path)
        for group in review_groups
        if isinstance(group, dict) and group.get("packaged") is True
        for path in group.get("paths", [])
    }
    reviewed_source_only = {
        str(path)
        for group in review_groups
        if isinstance(group, dict) and group.get("packaged") is False
        for path in group.get("paths", [])
    }
    if reviewed_packaged != set(external_packaged_rasters):
        errors.append(
            "registry external packaged raster classification mismatch: "
            f"delta={sorted(reviewed_packaged ^ set(external_packaged_rasters))[:8]}"
        )
    if reviewed_source_only != set(source_only_rasters):
        errors.append(
            "source-only .gdignore raster classification mismatch: "
            f"delta={sorted(reviewed_source_only ^ set(source_only_rasters))[:8]}"
        )
    audio = load_json(ROOT / "assets/audio/AUDIO_SOURCE_MANIFEST.json")
    if len(audio.get("assets", [])) != corpus["audio_source_assets"]:
        errors.append("audio source manifest count does not match ledger")

    fingerprints: dict[str, dict[str, Any]] = {}
    for axis in ledger["content_axes"]:
        result = candidate_fingerprint(axis, ko_events, en_events, owners)
        if result is None:
            continue
        fingerprints[axis["id"]] = result
        scan = axis["candidate_scan"]
        comparisons = {
            "expected_event_count": result["event_count"],
            "expected_file_count": result["file_count"],
            "expected_ids_sha256": result["ids_sha256"],
            "expected_content_sha256": result["content_sha256"],
        }
        for key, value in comparisons.items():
            if scan.get(key) != value:
                errors.append(f"{axis['id']}.{key}: observed {value!r} != ledger {scan.get(key)!r}")
        reviewed_noise = scan.get("reviewed_search_noise_ids", [])
        if not isinstance(reviewed_noise, list):
            errors.append(f"{axis['id']}.reviewed_search_noise_ids must be a list")
            continue
        if len(reviewed_noise) != len(set(reviewed_noise)):
            errors.append(f"{axis['id']}: reviewed search-noise IDs must be unique")
        unknown_noise = set(reviewed_noise) - set(result["event_ids"])
        if unknown_noise:
            errors.append(
                f"{axis['id']}: reviewed search-noise IDs are not candidates: "
                f"{sorted(unknown_noise)}"
            )
        fact_event_ids = {
            event_id
            for fact in axis["facts"]
            for event_id in fact["event_ids"]
        }
        overlap = set(reviewed_noise) & fact_event_ids
        if overlap:
            errors.append(
                f"{axis['id']}: search-noise IDs overlap fact evidence: {sorted(overlap)}"
            )
    return ko_events, en_events, owners, fingerprints


def owner_text(path_text: str) -> str:
    path = ROOT / path_text
    if not path.exists():
        return ""
    if path.is_file():
        if path.suffix.lower() in {".png", ".jpg", ".jpeg", ".ogg", ".wav", ".mp3"}:
            return path.name
        return path.read_text(encoding="utf-8", errors="ignore")
    pieces: list[str] = []
    for child in sorted(path.rglob("*")):
        if child.is_file() and child.suffix.lower() in {".gd", ".json", ".md", ".txt"}:
            pieces.append(child.read_text(encoding="utf-8", errors="ignore"))
    return "\n".join(pieces)


def validate_facts(
    ledger: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    en_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    runtime_blob = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in runtime_files(ledger)
    )
    for axis in ledger["content_axes"]:
        for fact in axis["facts"]:
            where = f"{axis['id']}.{fact['id']}"
            evidence_parts: list[str] = []
            for owner in fact["owner_paths"]:
                path = ROOT / owner
                if not path.exists():
                    errors.append(f"{where}: owner missing: {owner}")
                else:
                    evidence_parts.append(owner_text(owner))
            for event_id in fact["event_ids"]:
                if event_id not in ko_events or event_id not in en_events:
                    errors.append(f"{where}: bilingual event missing: {event_id}")
                    continue
                evidence_parts.append(json.dumps(ko_events[event_id], ensure_ascii=False))
                evidence_parts.append(json.dumps(en_events[event_id], ensure_ascii=False))
            evidence = "\n".join(evidence_parts)
            for token in fact["evidence_tokens"]:
                if token not in evidence:
                    errors.append(f"{where}: evidence token not found: {token!r}")
            unreferenced_paths = fact.get("runtime_unreferenced_paths", [])
            if not isinstance(unreferenced_paths, list):
                errors.append(f"{where}: runtime_unreferenced_paths must be a list")
                continue
            for relative in unreferenced_paths:
                relative = str(relative)
                path = ROOT / relative
                if not path.is_file():
                    errors.append(f"{where}: runtime-unreferenced file missing: {relative}")
                    continue
                if relative not in fact["owner_paths"]:
                    errors.append(f"{where}: runtime-unreferenced path lacks fact ownership: {relative}")
                if f"res://{relative}" in runtime_blob or Path(relative).name in runtime_blob:
                    errors.append(f"{where}: claimed unreferenced asset appears in runtime source: {relative}")
            if unreferenced_paths:
                for profile_id, state in fact["per_profile"].items():
                    if state["runtime_load"] != "none" or state["fresh_start_reachability"] != "blocked":
                        errors.append(
                            f"{where}.{profile_id}: runtime-unreferenced assets require none/blocked"
                        )


def validate_legacy_reachability(
    ledger: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    contract = ledger["legacy_reachability_contract"]
    director = load_json(ROOT / contract["owner"])
    content_diet = director.get("content_diet", {})
    foreground = set(content_diet.get("foreground_event_ids", []))
    required = set(contract["required_foreground_ids"])
    absent = set(contract["registered_but_not_foreground_ids"])
    if not required <= foreground:
        errors.append(
            f"legacy required foreground IDs missing: {sorted(required - foreground)}"
        )
    unexpected = absent & foreground
    if unexpected:
        errors.append(
            f"legacy registered/package-only IDs unexpectedly foreground: {sorted(unexpected)}"
        )
    for event_id in sorted(required | absent):
        if event_id not in ko_events:
            errors.append(f"legacy reachability contract event missing: {event_id}")
    for event_id, expected_conditions in contract["required_event_conditions"].items():
        event = ko_events.get(event_id, {})
        if event.get("conditions", {}) != expected_conditions:
            errors.append(
                f"legacy anchor {event_id} conditions {event.get('conditions', {})!r} "
                f"!= {expected_conditions!r}"
            )
        weight = event.get("weight", 0)
        if not isinstance(weight, (int, float)) or weight <= 0:
            errors.append(f"legacy anchor {event_id} must keep positive weight")


def validate_v2_reachability(
    ledger: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> set[str]:
    week_reachable, prologue_reachable, chapter_reachable = v2_reachable_event_surfaces(
        ledger, ko_events, errors
    )
    reachable = week_reachable | prologue_reachable | chapter_reachable
    contract = ledger.get("v2_reachability_contract", {})
    observed = {
        "week_1_24_event_count": len(week_reachable),
        "week_1_24_event_ids_sha256": sha_lines(sorted(week_reachable)),
        "prologue_event_count": len(prologue_reachable),
        "prologue_event_ids_sha256": sha_lines(sorted(prologue_reachable)),
        "chapter_event_count": len(chapter_reachable),
        "chapter_event_ids_sha256": sha_lines(sorted(chapter_reachable)),
        "fresh_start_event_count": len(reachable),
        "fresh_start_event_ids_sha256": sha_lines(sorted(reachable)),
    }
    for key, value in observed.items():
        if contract.get(key) != value:
            errors.append(
                f"v2 reachability {key}: observed {value!r} != ledger {contract.get(key)!r}"
            )

    for axis in ledger["content_axes"]:
        for fact in axis["facts"]:
            if not fact["event_backed"]:
                continue
            event_ids = set(fact["event_ids"])
            intersection = sorted(event_ids & reachable)
            state = fact["per_profile"]["v2_playtest"]["fresh_start_reachability"]
            where = f"{axis['id']}.{fact['id']}.v2_playtest"
            if intersection and state != "contracted":
                errors.append(
                    f"{where}: V2 closure contains {intersection}, so state must be contracted"
                )
            elif not intersection and state != "blocked":
                errors.append(
                    f"{where}: no fact event is in V2 closure, so state must be blocked"
                )
    return reachable


def runtime_files(ledger: dict[str, Any]) -> list[Path]:
    files: list[Path] = []
    for root_text in EXPECTED_RUNTIME_ROOTS:
        files.extend(sorted((ROOT / root_text).rglob("*.gd")))
    return sorted(set(files))


def validate_runtime_and_ai(ledger: dict[str, Any], errors: list[str]) -> None:
    network = ledger["network_contract"]
    sources = {path: path.read_text(encoding="utf-8", errors="ignore") for path in runtime_files(ledger)}
    forbidden: list[str] = []
    for path, text in sources.items():
        for token in REQUIRED_NETWORK_TOKENS:
            if token in text:
                forbidden.append(f"{path.relative_to(ROOT)}:{token}")
        for token in AI_RUNTIME_TOKENS:
            if token in text:
                forbidden.append(f"{path.relative_to(ROOT)}:{token}")
    if forbidden:
        errors.append(f"runtime network/live-AI APIs found: {forbidden[:8]}")
    if network.get("runtime_network_api_count") != 0:
        errors.append("network_contract.runtime_network_api_count must remain 0")
    for action in network["allowed_external_actions"]:
        path = ROOT / action["path"]
        if not path.is_file():
            errors.append(f"external action owner missing: {action['path']}")
            continue
        count = path.read_text(encoding="utf-8").count(action["token"])
        if count != action["expected_count"]:
            errors.append(f"{action['path']}:{action['token']} count {count} != {action['expected_count']}")

    disclosure = ledger["ai_disclosure_contract"]
    steam_text = (ROOT / disclosure["owner"]).read_text(encoding="utf-8")
    for phrase in disclosure["required_ko_phrases"] + disclosure["required_en_phrases"]:
        if phrase not in steam_text:
            errors.append(f"Steam AI disclosure phrase missing: {phrase!r}")
    decision_text = (ROOT / disclosure["decision_owner"]).read_text(encoding="utf-8")
    for phrase in disclosure["required_decision_phrases"]:
        if phrase not in decision_text:
            errors.append(f"canonical AI decision phrase missing: {phrase!r}")
    for evidence in disclosure["evidence"]:
        if not (ROOT / evidence).exists():
            errors.append(f"AI disclosure evidence missing: {evidence}")
    if disclosure.get("audio_production_assistance") is not True:
        errors.append("audio_production_assistance must remain disclosed")
    if disclosure.get("audio_source_waveform_generation") != "recording_or_sample_only":
        errors.append("audio source waveform provenance must remain recording_or_sample_only")
    if disclosure.get("runtime_generation") is not False:
        errors.append("runtime_generation must remain false unless runtime evidence changes")
    if disclosure.get("external_ai_service_during_play") is not False:
        errors.append("external_ai_service_during_play must remain false unless runtime evidence changes")

    main_text = (ROOT / "scenes/MainGame.gd").read_text(encoding="utf-8")
    for relative in ledger["export_contract"]["main_entry_eager_paths"]:
        marker = f'load("res://{relative}").new()'
        if marker not in main_text:
            errors.append(f"MainGame eager-load marker missing: {marker}")


def render_report(
    ledger: dict[str, Any],
    fingerprints: dict[str, dict[str, Any]],
) -> str:
    contract = ledger["export_contract"]
    corpus = ledger["corpus_contract"]
    public = ledger["public_story_demo_package_contract"]
    public_snapshot = git_snapshot(public["package_source_commit"])
    public_source_ledger = json.loads(
        public_snapshot.text("content/meta/release_content_inventory.json")
    )
    public_axes = public_source_ledger["content_axes"]
    public_fact_map = {
        (axis["id"], fact["id"]): fact
        for axis in public_axes for fact in axis["facts"]
    }
    access_dates = sorted({source["accessed"] for source in ledger["official_sources"]})
    access_label = ", ".join(access_dates)
    lines: list[str] = [
        "# 출시 콘텐츠·심의 사실 인벤토리",
        "",
        "> 이 문서는 `content/meta/release_content_inventory.json`, frozen 공개 Git source, 현재 개발 소스에서 자동 생성한다.",
        "> 최종 연령 등급·법률 의견·콘텐츠 삭제 결정이 아니며 수동 편집하지 않는다.",
        "",
        f"갱신 기준: {ledger['updated']}",
        "",
        "## 가장 중요한 범위 판정",
        "",
        f"`export_presets.cfg`의 {contract['preset_count']}개 retail/legacy preset은 모두 `all_resources`다. 따라서 legacy V2의 공식 24주 경로가",
        f"열지 않는 5년 사건·카지노·경마·홀덤·단타도 패키지에는 포함되며, 사건 {corpus['ko_event_files']}파일은",
        f"DataRegistry가 부팅 때 등록하고 도박·위험거래 노드 {len(contract['main_entry_eager_paths'])}개(직접 미니게임 {len(contract['main_entry_eager_paths']) - len(contract['main_entry_hub_paths'])}개 + 허브 {len(contract['main_entry_hub_paths'])}개)는 MainGame 진입 때 생성한다.",
        "`패키지 포함`, `런타임 로드`, `공식 fresh-start 도달`을 같은 값으로 읽지 않는다.",
        "",
        "공개 출시 데모는 checked-in profile 행이 아니다. clean source를 외부 staging한 뒤",
        "기존 macOS preset을 파생하지만 `all_resources` 필터는 그대로인 다음 별도 제품이다.",
        "M01~M06은 공개 월 범위이고 24주는 한 달 네 주를 센 내부 계측이다.",
        "",
        "| 공개 프로필 | 빌드 | 공개 범위 | 내부 계측 | 파생 preset / 필터 |",
        "|---|---|---:|---:|---|",
        (
            f"| `{contract['staged_public_demo']['profile']}` | "
            f"`{contract['staged_public_demo']['build_pipeline']}` | "
            f"M{contract['staged_public_demo']['public_months'][0]:02d}–"
            f"M{contract['staged_public_demo']['public_months'][1]:02d} | "
            f"W{contract['staged_public_demo']['internal_weeks'][0]}–"
            f"W{contract['staged_public_demo']['internal_weeks'][1]} · "
            f"정산 {contract['staged_public_demo']['settlements']}회 | "
            f"`{contract['staged_public_demo']['derived_preset_name']}` / "
            f"`{contract['staged_public_demo']['export_filter']}` |"
        ),
        "",
        "따라서 M01~M06에서 실행되지 않는 5년 사건·도박 미니게임·후반 연애/엔딩",
        "리소스도 공개 데모 PCK에 포함된다. 런타임 도달 범위로 심의·업로드",
        "콘텐츠를 줄여 답하지 않으며, exact package hash와 전용 package audit를 함께 쓴다.",
        "",
        "범위와 StoryMode 구조는 사용자 GO다. 일본어·간체·번체의 원어민 출시 claim은",
        "각각 OPEN이며 자동 검사나 다른 언어의 판정으로 닫지 않는다.",
        "",
        "## 공개 `story_demo_rc` exact 패키지 원장",
        "",
        f"- exact package source: `{public['package_source_commit']}` / tree `{public['package_source_tree']}`",
        f"- KO/EN 사건: 각각 {public['ko_event_files']}파일 · {public['ko_events']}건, ID와 원문 바이트 대조",
        f"- 실제 진입 사건: {public['shipping_ko_events']}건 · author-only 보관 원고: {public['author_only_events']}건",
        f"- KO/EN 엔딩: 각각 {public['ko_endings']}건 · raster {public['packaged_raster_assets']}장 · 오디오 {public['audio_source_assets']}개",
        f"- exact app PCK: {public['pck']['entry_count']} entries · raw JSON {public['pck']['raw_json_files']}개 · raster/audio import 1:1 연결 {public['pck']['import_binding_count']}개 · `{public['pck']['sha256']}`",
        f"- exact app ZIP: 실행 앱 {public['zip']['logical_file_count']}파일 · AppleDouble provenance {public['zip']['metadata_file_count']}파일 · {public['zip']['size_bytes']} bytes · `{public['zip']['sha256']}`",
        "",
        "위 수치는 현재 개발 HEAD에서 역산하지 않는다. exact Git source와 manifest에 묶인",
        "PCK의 디렉터리·전 payload MD5·JSON·raster/audio import target과 ZIP의 실행 앱 roster를 직접 대조한다. 패키지의 전체",
        "리소스 포함과 M01~M06 공개 플레이 도달은 서로 다른 사실이다.",
        "",
        "| 공개 후보 축 | 후보 사건/파일 | ID SHA-256 | KO/EN 본문 SHA-256 |",
        "|---|---:|---|---|",
    ]
    axis_labels = {axis["id"]: axis["label_ko"] for axis in public_axes}
    for axis_id, fingerprint in public["axis_fingerprints"].items():
        lines.append(
            f"| {axis_labels[axis_id]} | {fingerprint['event_count']} / "
            f"{fingerprint['file_count']} | `{fingerprint['ids_sha256']}` | "
            f"`{fingerprint['content_sha256']}` |"
        )
    lines.extend([
        "",
        f"### 공개 후보의 정성 사실 {public['qualitative_fact_count']}개",
        "",
        "아래 소유 경로는 exact Git source에서 근거·사건을 대조하는 위치다. `docs/*`·",
        "`tools/*`·`build/*` 자체는 preset exclude이며, 해당 출처·공시 사실이 게임에",
        "실린 표현과 리소스에 적용된다는 뜻이지 문서 파일이 PCK에 들어간다는 뜻은 아니다.",
        "",
    ])
    for axis in public_axes:
        lines.append(f"- **{axis['label_ko']}**")
        for fact in axis["facts"]:
            lines.append(
                f"  - `{fact['id']}` · {fact['intensity']} — {fact['summary_ko']}"
            )
            lines.append(
                "    - exact 근거: "
                + ", ".join(f"`{owner}`" for owner in fact["owner_paths"])
            )
    lines.extend([
        "",
        "아래 표는 별도 공개 데모가 아니라 기존 export preset 세 범위다.",
        "",
        "| export preset 프로필 | feature | 공식 범위 | 콘텐츠 필터 |",
        "|---|---|---:|---|",
    ])
    for profile_id in PROFILE_IDS:
        profile = contract["profiles"][profile_id]
        features = ", ".join(profile["features"]) or "없음"
        weeks = f"{profile['official_weeks'][0]}–{profile['official_weeks'][1]}주"
        lines.append(f"| `{profile_id}` | {features} | {weeks} | `{contract['export_filter']}` |")

    lines.extend([
        "",
        "## 현재 개발 소스 코퍼스 (공개 후보 아님)",
        "",
        f"- KO/EN 사건: 각각 {corpus['ko_event_files']}파일 · {corpus['ko_events']}건, ID 일치",
        f"- 패키지 사건: {corpus['ko_events']}건 · 현재 shipping 사건: {corpus['shipping_ko_events']}건 · author-only reference 원고: {corpus['author_only_events']}건",
        f"- KO/EN 엔딩: 각각 {corpus['ko_endings']}건",
        f"- 활성 스토리 이미지: {corpus['active_art_assets']}장 · source raster: {corpus['source_raster_assets']}장",
        f"- 게임 pack 대상 raster: {corpus['packaged_raster_assets']}장 · ImageRegistry 외부 pack 대상: {corpus['registry_external_packaged_raster_assets']}장",
        f"- `.gdignore` source-only 상점 스크린샷: {corpus['source_only_gdignored_raster_assets']}장 · 출처 원장 오디오: {corpus['audio_source_assets']}개",
        f"- 사건 ID SHA-256: `{corpus['event_ids_sha256']}`",
        f"- KO/EN 엔딩 본문 SHA-256: `{corpus['ending_content_sha256']}`",
        "",
        "아래 current-source fingerprint는 표현의 최종 등급이 아니라 개발 코퍼스가 조용히 바뀌는 것을",
        "막는 자동검색 래칫이다. fact의 사건 ID는 결정적 증거 앵커이지 후보 전부의 1:1",
        "처분표가 아니다. 후보가 바뀌면 사람이 원문·이미지·음향·플레이를 다시 확인한다.",
        "",
        "| 축 | 후보 사건/파일 | ID SHA-256 | KO/EN 본문 SHA-256 | 최고 사실 강도 |",
        "|---|---:|---|---|---|",
    ])
    for axis in ledger["content_axes"]:
        fp = fingerprints.get(axis["id"])
        candidate = "기술 축" if not fp else f"{fp['event_count']} / {fp['file_count']}"
        digest = "—" if not fp else f"`{fp['ids_sha256']}`"
        content_digest = "—" if not fp else f"`{fp['content_sha256']}`"
        intensities = ", ".join(dict.fromkeys(fact["intensity"] for fact in axis["facts"]))
        lines.append(
            f"| {axis['label_ko']} | {candidate} | {digest} | {content_digest} | {intensities} |"
        )

    reviewed_noise_axes = [
        axis for axis in ledger["content_axes"]
        if axis.get("candidate_scan", {}).get("reviewed_search_noise_ids")
    ]
    if reviewed_noise_axes:
        lines.extend([
            "",
            "명시 검토한 검색 오탐(후보 해시에는 남겨 검색 규칙 변화도 드러낸다):",
        ])
        for axis in reviewed_noise_axes:
            noise_ids = axis["candidate_scan"]["reviewed_search_noise_ids"]
            lines.append(
                f"- {axis['label_ko']}: {', '.join(f'`{event_id}`' for event_id in noise_ids)}"
            )

    lines.extend([
        "",
        f"## ImageRegistry 외부 source raster {corpus['registry_external_source_raster_assets']}장",
        "",
        "`all_resources`라 ImageRegistry 외부 구버전·마케팅·UI raster 중",
        f"{corpus['registry_external_packaged_raster_assets']}장도 게임 pack 대상이다. 나머지 {corpus['source_only_gdignored_raster_assets']}장 상점 스크린샷은 `.gdignore` 아래 source-only라 게임 pack에는 없다.",
        f"전체 {corpus['registry_external_source_raster_assets']}장은 원본·접촉표로 에이전트 시각 검토했지만 최종 사람 판정은",
        "여전히 `user_required`다. 실제 pack 검사는 대상 raster의 각 `.import`가 가리키는 `.ctex`까지 확인한다.",
        "",
        f"- 경로 SHA-256: `{corpus['registry_external_raster_paths_sha256']}`",
        f"- 경로+파일 SHA-256: `{corpus['registry_external_raster_content_sha256']}`",
        f"- 실제 pack 대상 외부 raster 경로 SHA-256: `{corpus['registry_external_packaged_paths_sha256']}`",
        f"- 실제 pack 대상 외부 raster 경로+파일 SHA-256: `{corpus['registry_external_packaged_content_sha256']}`",
        f"- `.gdignore` source-only 경로 SHA-256: `{corpus['source_only_gdignored_paths_sha256']}`",
    ])
    for group in ledger["registry_external_raster_review"]["groups"]:
        package_label = "게임 pack 포함" if group["packaged"] else "source-only / 게임 pack 제외"
        lines.append(
            f"- `{group['id']}` {len(group['paths'])}장 · {package_label} — {group['review']}"
        )

    lines.extend([
        "",
        "## 축별 실제 표현과 세 export-preset 범위",
        "",
        "아래 fresh-start 판정은 `retail_full`·legacy `demo_rc`·내부 V2용이다.",
        "`story_demo_rc`는 위의 frozen 정성 사실을 exact Git source에서 검증하고, PCK에서는",
        "raw JSON과 raster/audio import roster를 대조했다. provenance용 docs/tools/build는",
        "preset exclude다. 실제",
        "M01~M06 fresh-start 도달은 아래 세 프로필의 도달 판정으로 대신하지 않는다.",
        "",
    ])
    reach_labels = {
        "contracted": "명시 계약", "static_possible": "정적 가능", "blocked": "차단",
        "unknown": "미확인", "not_applicable": "해당 없음",
    }
    load_labels = {
        "boot_eager": "부팅 등록", "main_entry_eager": "메인 진입 생성",
        "lazy": "지연", "none": "로드 없음",
    }
    for axis in ledger["content_axes"]:
        lines.append(f"### {axis['label_ko']}")
        lines.append("")
        for fact in axis["facts"]:
            lines.append(f"- **{fact['id']} · {fact['intensity']}** — {fact['summary_ko']}")
            lines.append(f"  - 소유: {', '.join(f'`{path}`' for path in fact['owner_paths'])}")
            if fact["event_ids"]:
                lines.append(f"  - 사건: {', '.join(f'`{event_id}`' for event_id in fact['event_ids'])}")
            for profile_id in PROFILE_IDS:
                state = fact["per_profile"][profile_id]
                packaged = "포함" if state["packaged"] else "제외"
                lines.append(
                    f"  - `{profile_id}`: 패키지 {packaged} / {load_labels[state['runtime_load']]} / "
                    f"fresh-start {reach_labels[state['fresh_start_reachability']]} — {state['basis']}"
                )
            public_fact = public_fact_map.get((axis["id"], fact["id"]))
            if public_fact == fact:
                lines.append(
                    "  - `story_demo_rc`: frozen 후보에도 동일 사실이 적용됨 / M01~M06 도달은 전용 route audit 소유 — "
                    "exact source 근거와 1,806사건·PCK JSON/import roster를 분리 대조했다."
                )
            elif public_fact is not None:
                lines.append(
                    "  - `story_demo_rc`: 동일 ID의 frozen 후보 정의만 적용 — 현재 개발 정의를 공개 후보에 소급하지 않는다."
                )
            else:
                lines.append(
                    "  - `story_demo_rc`: frozen 후보 fact roster에 없음 — 현재 개발 사실을 공개 후보에 포함됐다고 주장하지 않는다."
                )
        lines.append("")

    lines.extend([
        "## 생성형 AI·온라인 공시 경계",
        "",
        "- 사전 생성 보조: 일부 2D 아트, 서사, 영문 현지화, 프로그래밍/코드,",
        "  오디오 소스 선별·편집·배열·믹싱.",
        "- 오디오 원음은 현장·사물 녹음 또는 녹음된 실악기 샘플이며 텍스트-투-오디오·",
        "  코드 합성 파형은 없다. 이 출처 사실이 오디오 제작 과정의 AI 보조 공시를 없애지는 않는다.",
        "- 런타임 생성, 플레이 중 외부 AI 서비스: 없음.",
        "- 오프라인 싱글플레이. 서버·멀티플레이·채팅·원격 UGC·텔레메트리·실결제 없음.",
        "- 예외는 데모 CTA의 `OS.shell_open` Steam 위시리스트/스토어 링크 1곳이며,",
        "  `user://mods/`는 로컬 데이터 모드다.",
        "",
        "## 제출 직전 수동 절차",
        "",
        "1. 공개 `story_demo_rc`는 전용 builder·manifest audit와 아래 app ZIP/PCK 내용 검사를 모두 실행한다.",
        "   파생 preset도 `all_resources`라는 사실과 exact 1,806사건 원장을 심의·업로드 대조에 포함한다.",
        "2. 제출 후보의 full/V2 실제 resource-pack ZIP도 아래 명령으로 검사하고 출력 해시를 보관한다.",
        "3. Steam 파트너 설문과 국내 접수 화면을 다시 캡처해 문항·버전·빌드 해시를 묶는다.",
        "4. 최종 등급·삭제·export 필터 변경은 사용자와 심의 주체가 결정한다.",
        "5. 필수 심의 공시는 상점 마케팅에서 숨은 반전·Moral Tint를 공개할 허가가 아니다.",
        "",
        "```bash",
        "python3 tools/release_content_inventory.py --self-test",
        "python3 tools/release_content_inventory.py \\",
        "  --pack-zip story_demo_rc=build/story_demo/macos/GangnamDream-StoryDemo.zip \\",
        "  --pack-zip retail_full=build/qa/release_content_inventory/full.zip \\",
        "  --pack-zip v2_playtest=build/qa/release_content_inventory/v2.zip",
        "```",
        "",
        f"## 공식 공개 근거 (확인일 {access_label})",
        "",
    ])
    for source in ledger["official_sources"]:
        lines.append(f"- [{source['id']}]({source['url']}) — {source['boundary']}")
    lines.extend([
        "",
        "Steam 공개 문서는 설문을 General Content, Mature Content, Generative AI의",
        "세 구획으로 나누며, 업로드된 성인 콘텐츠는 접근 불가여도 공개하라고 안내한다.",
        "공개 페이지에는 파트너 전용 전체 문항이 없고 Steam 답변이 한국 등급분류를",
        "자동 대체하지 않는다. 이 문서는 법률 자문이 아니다.",
        "",
    ])
    return "\n".join(lines)


def normalize_member(name: str) -> str:
    name = name.replace("\\", "/")
    if name.startswith("res://"):
        name = name[6:]
    while name.startswith("./"):
        name = name[2:]
    return name


def resource_present(
    archive: zipfile.ZipFile,
    member_by_normalized: dict[str, str],
    expected: str,
) -> bool:
    members = set(member_by_normalized)
    if expected in members:
        return True
    if expected.endswith(".gd"):
        stem = expected[:-3]
        variants = {
            stem + ".gdc", expected + ".remap", stem + ".gdc.remap",
            stem + ".gd.remap",
        }
        return bool(members & variants)
    if Path(expected).suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}:
        import_sidecar = expected + ".import"
        raw_sidecar = member_by_normalized.get(import_sidecar)
        if raw_sidecar is None:
            return False
        sidecar_text = archive.read(raw_sidecar).decode("utf-8", errors="ignore")
        targets = {
            normalize_member(value)
            for value in re.findall(r'"res://([^"]+\.(?:ctex|stex))"', sidecar_text)
        }
        return bool(targets) and any(target in members for target in targets)
    return False


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        while chunk := handle.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def parse_pck_directory(
    path: Path,
) -> tuple[dict[str, Any], dict[str, dict[str, Any]], list[str]]:
    errors: list[str] = []
    entries: dict[str, dict[str, Any]] = {}
    with path.open("rb") as handle:
        header = handle.read(112)
        if len(header) != 112 or header[:4] != b"GDPC":
            return {}, {}, ["story_demo_rc: PCK header/magic is invalid"]
        format_version, major, minor, patch, flags = struct.unpack_from(
            "<5I", header, 4
        )
        base_offset, directory_offset = struct.unpack_from("<2Q", header, 24)
        file_size = path.stat().st_size
        if directory_offset < 112 or directory_offset + 4 > file_size:
            return {}, {}, ["story_demo_rc: PCK directory offset is out of bounds"]
        handle.seek(directory_offset)
        entry_count = struct.unpack("<I", handle.read(4))[0]
        for index in range(entry_count):
            raw_length = handle.read(4)
            if len(raw_length) != 4:
                errors.append(f"story_demo_rc: PCK entry {index} is truncated")
                break
            path_length = struct.unpack("<I", raw_length)[0]
            if path_length <= 0 or path_length > 1024 * 1024:
                errors.append(
                    f"story_demo_rc: PCK entry {index} path length is invalid"
                )
                break
            raw_path = handle.read(path_length)
            fixed = handle.read(36)
            if len(raw_path) != path_length or len(fixed) != 36:
                errors.append(f"story_demo_rc: PCK entry {index} record is truncated")
                break
            try:
                member = raw_path.rstrip(b"\0").decode("utf-8")
            except UnicodeDecodeError:
                errors.append(f"story_demo_rc: PCK entry {index} path is not UTF-8")
                continue
            offset, size = struct.unpack_from("<2Q", fixed, 0)
            digest = fixed[16:32].hex()
            entry_flags = struct.unpack_from("<I", fixed, 32)[0]
            if member in entries:
                errors.append(f"story_demo_rc: duplicate PCK member: {member}")
            absolute_offset = base_offset + offset
            if absolute_offset < base_offset or absolute_offset + size > directory_offset:
                errors.append(
                    f"story_demo_rc: PCK member bounds invalid: {member}"
                )
            entries[member] = {
                "offset": offset,
                "size": size,
                "md5": digest,
                "flags": entry_flags,
            }
    header_values = {
        "format_version": format_version,
        "engine_version": [major, minor, patch],
        "flags": flags,
        "base_offset": base_offset,
        "directory_offset": directory_offset,
        "entry_count": entry_count,
    }
    return header_values, entries, errors


def pck_entry_bytes(
    handle: Any,
    base_offset: int,
    entry: dict[str, Any],
) -> bytes:
    handle.seek(base_offset + int(entry["offset"]))
    value = handle.read(int(entry["size"]))
    if len(value) != int(entry["size"]):
        raise ValueError("PCK member read was truncated")
    return value


def validate_app_zip_member_roster(
    logical_members: list[str],
    metadata_members: list[str],
    expected_zip: dict[str, Any],
) -> list[str]:
    errors: list[str] = []
    expected_logical = expected_zip["logical_members"]
    if len(logical_members) != len(set(logical_members)):
        errors.append("story_demo_rc: app ZIP has duplicate logical members")
    if sorted(logical_members) != expected_logical:
        errors.append("story_demo_rc: app ZIP logical member roster drifted")
    if len(logical_members) != expected_zip["logical_file_count"]:
        errors.append("story_demo_rc: app ZIP logical file count drifted")
    if sha_lines(sorted(logical_members)) != expected_zip["logical_paths_sha256"]:
        errors.append("story_demo_rc: app ZIP logical path digest drifted")
    if len(metadata_members) != len(set(metadata_members)):
        errors.append("story_demo_rc: app ZIP has duplicate __MACOSX members")
    if len(metadata_members) != expected_zip["metadata_file_count"]:
        errors.append("story_demo_rc: app ZIP __MACOSX file count drifted")
    if sha_lines(sorted(metadata_members)) != expected_zip["metadata_paths_sha256"]:
        errors.append("story_demo_rc: app ZIP __MACOSX path digest drifted")
    return errors


def import_remap_binding(
    sidecar: str,
    text: str,
    label: str,
    errors: list[str],
) -> tuple[str, str, str] | None:
    remap = text.rstrip("\0").split("[deps]", 1)[0]
    importers = re.findall(r'(?m)^importer="([^"]+)"$', remap)
    types = re.findall(r'(?m)^type="([^"]+)"$', remap)
    targets = re.findall(
        r'(?m)^path(?:\.[^=]+)?="res://([^"]+)"$',
        remap,
    )
    if len(importers) != 1 or len(types) != 1 or len(targets) != 1:
        errors.append(
            f"story_demo_rc: {label} {sidecar} must have exactly one "
            "importer, type, and remap target"
        )
        return None
    importer, resource_type, target = importers[0], types[0], targets[0]
    source_suffix = Path(sidecar.removesuffix(".import")).suffix.lower()
    expected_by_suffix = {
        ".png": ("texture", "CompressedTexture2D", {".ctex"}),
        ".jpg": ("texture", "CompressedTexture2D", {".ctex"}),
        ".jpeg": ("texture", "CompressedTexture2D", {".ctex"}),
        ".webp": ("texture", "CompressedTexture2D", {".ctex"}),
        ".wav": ("wav", "AudioStreamWAV", {".sample"}),
        ".ogg": ("oggvorbisstr", "AudioStreamOggVorbis", {".oggvorbisstr"}),
        ".mp3": ("mp3", "AudioStreamMP3", {".mp3str"}),
    }
    expected = expected_by_suffix.get(source_suffix)
    if expected is None:
        errors.append(f"story_demo_rc: unsupported import source suffix: {sidecar}")
        return None
    expected_importer, expected_type, target_suffixes = expected
    if importer != expected_importer or resource_type != expected_type:
        errors.append(
            f"story_demo_rc: {label} {sidecar} importer/type drifted"
        )
    if Path(target).suffix.lower() not in target_suffixes:
        errors.append(
            f"story_demo_rc: {label} {sidecar} target suffix drifted"
        )
    if not target.startswith(".godot/imported/"):
        errors.append(
            f"story_demo_rc: {label} {sidecar} target leaves .godot/imported"
        )
    return importer, resource_type, target


def validate_import_binding_pair(
    sidecar: str,
    exact_binding: tuple[str, str, str] | None,
    packed_binding: tuple[str, str, str] | None,
    available_targets: set[str],
    target_owners: dict[str, str],
) -> list[str]:
    errors: list[str] = []
    if exact_binding is None or packed_binding is None:
        return errors
    if packed_binding[:2] != exact_binding[:2]:
        errors.append(
            f"story_demo_rc: PCK {sidecar} importer/type differs from exact source"
        )
    if packed_binding[2] != exact_binding[2]:
        errors.append(
            f"story_demo_rc: PCK {sidecar} remap target differs from exact source"
        )
    target = packed_binding[2]
    if target not in available_targets:
        errors.append(
            f"story_demo_rc: PCK {sidecar} remap target is not packed: {target}"
        )
    previous = target_owners.get(target)
    if previous is not None and previous != sidecar:
        errors.append(
            f"story_demo_rc: PCK import target is shared by {previous} and {sidecar}: "
            f"{target}"
        )
    else:
        target_owners[target] = sidecar
    return errors


def validate_pck_payload_digests(
    handle: Any,
    base_offset: int,
    entries: dict[str, dict[str, Any]],
) -> list[str]:
    errors: list[str] = []
    for member, entry in entries.items():
        handle.seek(base_offset + int(entry["offset"]))
        remaining = int(entry["size"])
        digest = hashlib.md5()
        while remaining:
            chunk = handle.read(min(1024 * 1024, remaining))
            if not chunk:
                errors.append(
                    f"story_demo_rc: PCK payload truncated while hashing: {member}"
                )
                break
            digest.update(chunk)
            remaining -= len(chunk)
        if remaining == 0 and digest.hexdigest() != entry["md5"]:
            errors.append(
                f"story_demo_rc: PCK payload MD5 differs from directory: {member}"
            )
    return errors


def validate_story_demo_app_zip(
    ledger: dict[str, Any],
    path: Path,
    success_markers: list[str],
) -> list[str]:
    errors: list[str] = []
    public = ledger["public_story_demo_package_contract"]
    staged = ledger["export_contract"]["staged_public_demo"]
    expected_zip = public["zip"]
    expected_pck = public["pck"]
    if not path.is_file():
        return [f"pack ZIP missing: {path}"]
    if not zipfile.is_zipfile(path):
        return [f"not a ZIP pack: {path}"]
    if path.stat().st_size != expected_zip["size_bytes"]:
        errors.append("story_demo_rc: app ZIP size differs from exact contract")
    if file_sha256(path) != expected_zip["sha256"]:
        errors.append("story_demo_rc: app ZIP SHA-256 differs from exact contract")

    manifest_path = path.parent.parent / "MANIFEST.json"
    if not manifest_path.is_file():
        errors.append(
            "story_demo_rc: sibling build/story_demo/MANIFEST.json is required"
        )
    else:
        if file_sha256(manifest_path) != staged["manifest_sha256"]:
            errors.append("story_demo_rc: manifest SHA-256 differs from exact contract")
        manifest = load_json(manifest_path)
        source = manifest.get("source", {})
        package = manifest.get("package", {})
        for key, expected in (
            ("revision", staged["package_source_commit"]),
            ("tree", staged["package_source_tree"]),
            ("product_revision", staged["product_commit"]),
            ("product_tree", staged["product_tree"]),
        ):
            if source.get(key) != expected:
                errors.append(f"story_demo_rc: manifest source.{key} drifted")
        manifest_zip_contract = {
            key: expected_zip[key] for key in ("path", "sha256", "size_bytes")
        }
        if package.get("zip") != manifest_zip_contract:
            errors.append("story_demo_rc: manifest ZIP contract drifted")
        if package.get("app") != {
            "path": "build/story_demo/macos/GangnamDream-StoryDemo.app",
            "name": "GangnamDream-StoryDemo.app",
            "tree_sha256": expected_zip["app_tree_sha256"],
            "file_count": expected_zip["logical_file_count"],
        }:
            errors.append("story_demo_rc: manifest app contract drifted")
        if package.get("launcher") != {
            "path": "GangnamDream-StoryDemo.app/Contents/MacOS/GangnamDream-StoryDemo",
            "sha256": expected_zip["launcher_sha256"],
            "size_bytes": expected_zip["launcher_size_bytes"],
        }:
            errors.append("story_demo_rc: manifest launcher contract drifted")
        if package.get("resource_pack") != {
            "path": expected_pck["member"],
            "sha256": expected_pck["sha256"],
            "size_bytes": expected_pck["size_bytes"],
        }:
            errors.append("story_demo_rc: manifest resource-pack contract drifted")

    pck_member = expected_pck["member"]
    with zipfile.ZipFile(path) as archive:
        file_infos = [info for info in archive.infolist() if not info.is_dir()]
        real_members = [
            info.filename for info in file_infos
            if not info.filename.startswith("__MACOSX/")
        ]
        metadata_members = [
            info.filename for info in file_infos
            if info.filename.startswith("__MACOSX/")
        ]
        errors.extend(validate_app_zip_member_roster(
            real_members,
            metadata_members,
            expected_zip,
        ))
        if real_members.count(pck_member) != 1:
            errors.append(
                f"story_demo_rc: exact app PCK member count is {real_members.count(pck_member)}"
            )
            return errors
        with tempfile.TemporaryDirectory(prefix="gangnamdream-story-demo-pack-") as temp:
            pck_path = Path(temp) / "GangnamDream-StoryDemo.pck"
            with archive.open(pck_member) as source, pck_path.open("wb") as destination:
                shutil.copyfileobj(source, destination, length=1024 * 1024)
            if pck_path.stat().st_size != expected_pck["size_bytes"]:
                errors.append("story_demo_rc: embedded PCK size differs from exact contract")
            actual_pck_sha = file_sha256(pck_path)
            if actual_pck_sha != expected_pck["sha256"]:
                errors.append("story_demo_rc: embedded PCK SHA-256 differs from exact contract")

            info_by_member = {info.filename: info for info in file_infos}
            logical_hashes = {pck_member: actual_pck_sha}
            for member in real_members:
                if member == pck_member:
                    continue
                digest = hashlib.sha256()
                with archive.open(member) as member_handle:
                    while chunk := member_handle.read(1024 * 1024):
                        digest.update(chunk)
                logical_hashes[member] = digest.hexdigest()
            logical_entry_rows = []
            for member in sorted(real_members):
                info = info_by_member[member]
                mode = (info.external_attr >> 16) & 0xFFFF
                logical_entry_rows.append(
                    f"{member}\t{info.file_size}\t{mode:o}\t{logical_hashes[member]}"
                )
            if sha_lines(logical_entry_rows) != expected_zip["logical_entries_sha256"]:
                errors.append("story_demo_rc: app ZIP logical entry digest drifted")
            if sum(info_by_member[member].file_size for member in real_members) != (
                expected_zip["logical_uncompressed_size_bytes"]
            ):
                errors.append("story_demo_rc: app ZIP uncompressed size drifted")

            app_prefix = "GangnamDream-StoryDemo.app/"
            app_tree_rows = []
            for member in sorted(real_members):
                if not member.startswith(app_prefix):
                    errors.append(
                        f"story_demo_rc: logical ZIP member leaves app root: {member}"
                    )
                    continue
                relative = member.removeprefix(app_prefix)
                app_tree_rows.append(
                    f"file\0{relative}\0{logical_hashes[member]}\n".encode("utf-8")
                )
            actual_app_tree = hashlib.sha256(b"".join(app_tree_rows)).hexdigest()
            if actual_app_tree != expected_zip["app_tree_sha256"]:
                errors.append("story_demo_rc: app tree SHA-256 drifted")
            launcher_member = (
                "GangnamDream-StoryDemo.app/Contents/MacOS/GangnamDream-StoryDemo"
            )
            launcher_info = info_by_member.get(launcher_member)
            if (
                launcher_info is None
                or launcher_info.file_size != expected_zip["launcher_size_bytes"]
                or logical_hashes.get(launcher_member) != expected_zip["launcher_sha256"]
            ):
                errors.append("story_demo_rc: launcher payload contract drifted")

            header, entries, pck_errors = parse_pck_directory(pck_path)
            errors.extend(pck_errors)
            for key in (
                "format_version", "engine_version", "flags", "base_offset",
                "directory_offset", "entry_count",
            ):
                if header.get(key) != expected_pck[key]:
                    errors.append(
                        f"story_demo_rc: PCK {key}={header.get(key)!r} "
                        f"!= {expected_pck[key]!r}"
                    )
            entry_paths_sha = sha_lines(sorted(entries))
            if entry_paths_sha != expected_pck["entry_paths_sha256"]:
                errors.append("story_demo_rc: PCK entry-path digest drifted")
            entry_metadata_sha = sha_lines([
                f"{member}\t{entries[member]['size']}\t{entries[member]['md5']}\t"
                f"{entries[member]['flags']}"
                for member in sorted(entries)
            ])
            if entry_metadata_sha != expected_pck["entry_metadata_sha256"]:
                errors.append("story_demo_rc: PCK entry metadata digest drifted")
            if any(entry["flags"] != 0 for entry in entries.values()):
                errors.append("story_demo_rc: PCK contains unexpected per-entry flags")

            snapshot = git_snapshot(staged["package_source_commit"])
            exact_json = sorted(
                source_path for source_path in snapshot.paths
                if source_path.endswith(".json")
                and not source_path.startswith(("tools/", "docs/", "build/"))
                and not snapshot_is_below_gdignore(snapshot, source_path)
            )
            pck_json = sorted(
                member for member in entries if member.endswith(".json")
            )
            if set(exact_json) != set(pck_json):
                errors.append(
                    "story_demo_rc: PCK raw JSON roster differs from exact source "
                    f"delta={len(set(exact_json) ^ set(pck_json))}"
                )
            if len(pck_json) != expected_pck["raw_json_files"]:
                errors.append("story_demo_rc: PCK raw JSON count drifted")
            with pck_path.open("rb") as handle:
                base_offset = int(header.get("base_offset", 0))
                errors.extend(validate_pck_payload_digests(
                    handle,
                    base_offset,
                    entries,
                ))
                mismatched_json: list[str] = []
                for relative in sorted(set(exact_json) & set(pck_json)):
                    packed = pck_entry_bytes(handle, base_offset, entries[relative])
                    if packed != snapshot.read(relative):
                        mismatched_json.append(relative)
                if mismatched_json:
                    errors.append(
                        "story_demo_rc: PCK JSON differs from exact source: "
                        f"{mismatched_json[:8]}"
                    )

                asset_paths = snapshot.files_below("assets")
                packaged_rasters = sorted(
                    relative for relative in asset_paths
                    if Path(relative).suffix.lower() in RASTER_SUFFIXES
                    and not snapshot_is_below_gdignore(snapshot, relative)
                )
                source_only_rasters = sorted(
                    relative for relative in asset_paths
                    if Path(relative).suffix.lower() in RASTER_SUFFIXES
                    and snapshot_is_below_gdignore(snapshot, relative)
                )
                packaged_audio = sorted(
                    relative for relative in asset_paths
                    if Path(relative).suffix.lower() in AUDIO_SUFFIXES
                    and not snapshot_is_below_gdignore(snapshot, relative)
                )
                binding_rows: list[str] = []
                target_owners: dict[str, str] = {}
                for label, sources, expected_count in (
                    ("raster", packaged_rasters, expected_pck["packaged_raster_imports"]),
                    ("audio", packaged_audio, expected_pck["packaged_audio_imports"]),
                ):
                    sidecars = {f"{relative}.import" for relative in sources}
                    present_sidecars = {
                        member for member in entries if member in sidecars
                    }
                    if present_sidecars != sidecars:
                        errors.append(
                            f"story_demo_rc: PCK {label} import roster differs "
                            f"delta={len(present_sidecars ^ sidecars)}"
                        )
                    if len(sidecars) != expected_count:
                        errors.append(
                            f"story_demo_rc: exact-source {label} count drifted"
                        )
                    for sidecar in sorted(present_sidecars):
                        packed_text = pck_entry_bytes(
                            handle, base_offset, entries[sidecar]
                        ).decode("utf-8", errors="ignore")
                        exact_binding = import_remap_binding(
                            sidecar,
                            snapshot.text(sidecar),
                            "exact-source",
                            errors,
                        )
                        packed_binding = import_remap_binding(
                            sidecar,
                            packed_text,
                            "PCK",
                            errors,
                        )
                        errors.extend(validate_import_binding_pair(
                            sidecar,
                            exact_binding,
                            packed_binding,
                            set(entries),
                            target_owners,
                        ))
                        if exact_binding is not None:
                            binding_rows.append(
                                f"{sidecar}\t{exact_binding[0]}\t"
                                f"{exact_binding[1]}\t{exact_binding[2]}"
                            )
                if len(binding_rows) != expected_pck["import_binding_count"]:
                    errors.append("story_demo_rc: exact import binding count drifted")
                if sha_lines(sorted(binding_rows)) != expected_pck[
                    "import_bindings_sha256"
                ]:
                    errors.append("story_demo_rc: exact import binding digest drifted")
                if len(target_owners) != expected_pck["import_binding_count"]:
                    errors.append(
                        "story_demo_rc: PCK import target ownership is not one-to-one"
                    )
                leaked_source_only = [
                    relative for relative in source_only_rasters
                    if relative in entries or f"{relative}.import" in entries
                ]
                if leaked_source_only:
                    errors.append(
                        "story_demo_rc: .gdignore raster leaked into PCK: "
                        f"{leaked_source_only}"
                    )
    if not errors:
        success_markers.append(
            "STORY_DEMO_PACK_ZIP_OK "
            f"profile={PUBLIC_STORY_DEMO_PROFILE} events="
            f"{public['ko_events']} shipping={public['shipping_ko_events']} "
            f"author_only={public['author_only_events']} entries="
            f"{expected_pck['entry_count']} zip_sha256={expected_zip['sha256']} "
            f"pck_sha256={expected_pck['sha256']} path={path}"
        )
    return errors


def validate_pack_zip(
    ledger: dict[str, Any],
    spec: str,
    success_markers: list[str],
) -> list[str]:
    errors: list[str] = []
    if "=" not in spec:
        return [f"--pack-zip requires profile=path, got {spec!r}"]
    profile_id, path_text = spec.split("=", 1)
    if profile_id not in PACK_PROFILE_IDS:
        return [f"unknown pack profile: {profile_id}"]
    path = Path(path_text)
    if not path.is_absolute():
        path = ROOT / path
    if profile_id == PUBLIC_STORY_DEMO_PROFILE:
        return validate_story_demo_app_zip(ledger, path, success_markers)
    if not path.is_file():
        return [f"pack ZIP missing: {path}"]
    if not zipfile.is_zipfile(path):
        return [f"not a ZIP pack: {path}"]
    with zipfile.ZipFile(path) as archive:
        raw_members = [info.filename for info in archive.infolist() if not info.is_dir()]
    members_list = [normalize_member(name) for name in raw_members]
    members = set(members_list)
    if len(members) != len(members_list):
        errors.append(f"{profile_id}: duplicate ZIP member paths")
    unsafe = [name for name in members if name.startswith("/") or ".." in PurePosixPath(name).parts]
    if unsafe:
        errors.append(f"{profile_id}: unsafe ZIP paths: {unsafe[:5]}")
    forbidden = [name for name in members if name.startswith(("tools/", "docs/", "build/"))]
    if forbidden:
        errors.append(f"{profile_id}: excluded roots packaged: {forbidden[:5]}")
    with zipfile.ZipFile(path) as archive:
        member_by_normalized = {
            normalize_member(info.filename): info.filename
            for info in archive.infolist() if not info.is_dir()
        }
        expected_paths = list(ledger["export_contract"]["pack_smoke_paths"])
        expected_paths.extend(
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_ROOT.glob("*.json"))
        )
        expected_paths.extend(
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_EN_ROOT.glob("*.json"))
        )
        expected_paths.extend(
            str(relative)
            for group in ledger["registry_external_raster_review"]["groups"]
            if group["packaged"]
            for relative in group["paths"]
        )
        expected_paths.extend(
            asset.relative_to(ROOT).as_posix()
            for asset in sorted((ROOT / "assets").rglob("*"))
            if asset.is_file()
            and asset.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}
            and not is_below_gdignore(asset)
        )
        expected_paths.extend([
            "content/endings.json", "content/endings_en.json", "project.binary"
        ])
        missing = [
            expected for expected in sorted(set(expected_paths))
            if not resource_present(archive, member_by_normalized, expected)
        ]
        if missing:
            errors.append(f"{profile_id}: representative resources missing: {missing}")
        source_only_present = [
            str(relative)
            for group in ledger["registry_external_raster_review"]["groups"]
            if not group["packaged"]
            for relative in group["paths"]
            if resource_present(archive, member_by_normalized, str(relative))
        ]
        if source_only_present:
            errors.append(
                f"{profile_id}: .gdignore source-only rasters unexpectedly packaged: "
                f"{source_only_present}"
            )
        project_member = member_by_normalized.get("project.binary")
        project_binary = archive.read(project_member) if project_member else b""
        known_features = {
            feature
            for profile in ledger["export_contract"]["profiles"].values()
            for feature in profile["features"]
        }
        expected_features = set(
            ledger["export_contract"]["profiles"][profile_id]["features"]
        )
        for feature in sorted(known_features):
            present = feature.encode("utf-8") in project_binary
            if present != (feature in expected_features):
                errors.append(
                    f"{profile_id}: project.binary feature {feature!r} "
                    f"present={present} expected={feature in expected_features}"
                )

        current_json_paths = [
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_ROOT.glob("*.json"))
        ] + [
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_EN_ROOT.glob("*.json"))
        ] + [
            "content/endings.json",
            "content/endings_en.json",
            "content/meta/release_content_inventory.json",
        ]
        stale_json: list[str] = []
        for relative in current_json_paths:
            raw_name = member_by_normalized.get(relative)
            if raw_name is None:
                continue
            if archive.read(raw_name) != (ROOT / relative).read_bytes():
                stale_json.append(relative)
        if stale_json:
            errors.append(
                f"{profile_id}: packaged JSON differs from current source: {stale_json[:8]}"
            )
    if not errors:
        entries_digest = sha_lines(sorted(members))
        success_markers.append(
            f"PACK_ZIP_OK profile={profile_id} entries={len(members)} "
            f"sha256={file_sha256(path)} entries_sha256={entries_digest} path={path}"
        )
    return errors


def validate_source(ledger: dict[str, Any]) -> tuple[list[str], dict[str, dict[str, Any]]]:
    errors = validate_structure(ledger)
    validate_presets(ledger, errors)
    validate_staged_public_demo(ledger, errors)
    validate_public_story_demo_source(ledger, errors)
    ko_events, en_events, _owners, fingerprints = validate_corpus(ledger, errors)
    validate_legacy_reachability(ledger, ko_events, errors)
    validate_facts(ledger, ko_events, en_events, errors)
    validate_v2_reachability(ledger, ko_events, errors)
    validate_runtime_and_ai(ledger, errors)
    return errors, fingerprints


def self_test(ledger: dict[str, Any]) -> list[str]:
    failures: list[str] = []
    cases: list[tuple[str, dict[str, Any], str]] = []

    changed = copy.deepcopy(ledger)
    changed["decision_boundary"]["final_age_rating"] = "12_plus"
    cases.append(("rating_autodecision", changed, "final_age_rating"))

    changed = copy.deepcopy(ledger)
    del changed["content_axes"][0]["facts"][0]["intensity"]
    cases.append(("missing_intensity", changed, "intensity"))

    changed = copy.deepcopy(ledger)
    del changed["content_axes"][0]["facts"][0]["per_profile"]["v2_playtest"]
    cases.append(("missing_reachability", changed, "per_profile"))

    changed = copy.deepcopy(ledger)
    changed["content_axes"][0]["facts"][0]["per_profile"]["v2_playtest"]["packaged"] = False
    cases.append(("false_package_absence", changed, "package absence"))

    changed = copy.deepcopy(ledger)
    changed["content_axes"][0]["facts"][0]["owner_paths"] = []
    cases.append(("missing_owner", changed, "owner_paths"))

    changed = copy.deepcopy(ledger)
    changed["network_contract"]["runtime_roots"] = []
    cases.append(("empty_network_scan_scope", changed, "runtime_roots"))

    changed = copy.deepcopy(ledger)
    changed["network_contract"]["telemetry"] = True
    cases.append(("false_offline_claim", changed, "telemetry"))

    changed = copy.deepcopy(ledger)
    changed["content_axes"][0]["facts"][0]["event_ids"] = []
    cases.append(("event_backed_without_event_ids", changed, "requires event_ids"))

    changed = copy.deepcopy(ledger)
    del changed["legacy_reachability_contract"]["required_event_conditions"][
        "racetrack_mentor_meet"
    ]
    cases.append(("missing_legacy_condition_anchor", changed, "condition anchors"))

    changed = copy.deepcopy(ledger)
    del changed["export_contract"]["staged_public_demo"]
    cases.append(("missing_staged_public_demo", changed, "staged_public_demo"))

    changed = copy.deepcopy(ledger)
    changed["export_contract"]["staged_public_demo"]["checked_in_profile_entry"] = True
    cases.append(("story_demo_misclassified_as_checked_in_profile", changed, "checked_in_profile_entry"))

    changed = copy.deepcopy(ledger)
    changed["export_contract"]["staged_public_demo"]["export_filter"] = "resources"
    cases.append(("story_demo_package_filter_drift", changed, "export_filter"))

    changed = copy.deepcopy(ledger)
    changed["export_contract"]["staged_public_demo"]["public_months"] = [1, 24]
    cases.append(("story_demo_public_range_drift", changed, "public_months"))

    changed = copy.deepcopy(ledger)
    changed["export_contract"]["staged_public_demo"]["internal_weeks"] = [1, 6]
    cases.append(("story_demo_internal_weeks_drift", changed, "internal_weeks"))

    changed = copy.deepcopy(ledger)
    changed["export_contract"]["staged_public_demo"]["entry_scene"] = "res://scenes/Main.tscn"
    cases.append(("story_demo_entry_drift", changed, "entry_scene"))

    changed = copy.deepcopy(ledger)
    changed["public_story_demo_package_contract"]["pck"]["entry_count"] += 1
    cases.append(("story_demo_pck_contract_drift", changed, "pck exact artifact"))

    for name, candidate, marker in cases:
        messages = validate_structure(candidate)
        if not any(marker in message for message in messages):
            failures.append(f"self-test {name}: mutation was not rejected with {marker!r}: {messages}")

    ko_events, _owners, _files = load_event_corpus(EVENT_ROOT)
    for bad_state in ("blocked", "static_possible"):
        changed = copy.deepcopy(ledger)
        for axis in changed["content_axes"]:
            if axis["id"] != "language":
                continue
            axis["facts"][0]["per_profile"]["v2_playtest"][
                "fresh_start_reachability"
            ] = bad_state
        reachability_errors: list[str] = []
        validate_v2_reachability(changed, ko_events, reachability_errors)
        if not any("state must be contracted" in message for message in reachability_errors):
            failures.append(
                f"self-test v2_reachability_{bad_state}: mutation was not rejected: "
                f"{reachability_errors}"
            )

    changed = copy.deepcopy(ledger)
    changed["v2_reachability_contract"]["runtime_dynamic_roots"] = []
    reachability_errors = []
    validate_v2_reachability(changed, ko_events, reachability_errors)
    if not any("dynamic roots differ from ledger" in message for message in reachability_errors):
        failures.append(
            "self-test v2_runtime_root_contract: mutation was not rejected: "
            f"{reachability_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["v2_reachability_contract"]["fresh_start_prologue_root"] = "story_arrival"
    reachability_errors = []
    validate_v2_reachability(changed, ko_events, reachability_errors)
    if not any("prologue runtime marker differs" in message for message in reachability_errors):
        failures.append(
            "self-test v2_prologue_contract: mutation was not rejected: "
            f"{reachability_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["v2_reachability_contract"]["fresh_start_chapter_root"] = "chapter_card_34"
    reachability_errors = []
    validate_v2_reachability(changed, ko_events, reachability_errors)
    if not any("chapter runtime marker differs" in message for message in reachability_errors):
        failures.append(
            "self-test v2_chapter_contract: mutation was not rejected: "
            f"{reachability_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["corpus_contract"]["shipping_ko_events"] += 1
    corpus_errors: list[str] = []
    validate_corpus(changed, corpus_errors)
    if not any("corpus shipping_ko_events" in message for message in corpus_errors):
        failures.append(
            "self-test lifecycle_shipping_count: mutation was not rejected: "
            f"{corpus_errors}"
        )

    human_gates = load_json(ROOT / ledger["export_contract"]["staged_public_demo"]["identity_owner"])
    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    )["state"] = "open"
    gate_errors: list[str] = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("story_demo_m1_m6_user_play state" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_user_go_state: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    extra_gate = copy.deepcopy(changed_gates["gates"][0])
    extra_gate["id"] = "story_demo_invented_gate"
    extra_gate["revision"] = "story_demo_rc"
    changed_gates["gates"].append(extra_gate)
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("human gates must be exactly" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_extra_gate: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    changed_gates["release_candidates"]["story_demo_rc"]["status"] = "historical"
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("candidate must be active" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_inactive_candidate: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    changed_gates["release_candidates"]["story_demo_rc"]["commit"] = "0" * 40
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    )["evidence"]["commit"] = "0" * 40
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("active candidate commit drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_coordinated_identity_drift: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    )["scope"]["blocks"] = ["full"]
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("story_demo_m1_m6_user_play blocks drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_user_scope_drift: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_zh_cn_native_review"
    )["scope"]["content"] = "story_demo_rc M01~M60"
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("story_demo_zh_cn_native_review content scope drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_native_scope_drift: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    )["gate"] = "M01~M60 전체 게임 최종 GO"
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("story_demo_m1_m6_user_play label drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_user_meaning_expansion: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    duplicate_gate = copy.deepcopy(next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    ))
    changed_gates["gates"].append(duplicate_gate)
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("human-gate IDs must be unique" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_duplicate_gate: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    changed_gates["release_candidates"]["story_demo_rc"]["note"] = (
        "M01~M60 전체 게임 최종 GO. 원어민도 완료."
    )
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("active candidate note" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_candidate_note_expansion: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    )["evidence"]["record"] = "M01~M60 전체 게임과 원어민 출시까지 최종 GO"
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("evidence record drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_evidence_expansion: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    )["acceptance"] = ["M01~M60 전체 게임 최종 GO"]
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("story_demo_m1_m6_user_play row digest drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_user_acceptance_expansion: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_m1_m6_user_play"
    )["sample"]["requirements"] = ["M01~M60 전체 게임 최종 GO"]
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("story_demo_m1_m6_user_play row digest drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_user_sample_expansion: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    changed_gates["release_candidates"]["story_demo_rc"]["note"] += " 본편도 GO다."
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("active candidate row digest drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_candidate_note_append: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed_gates = copy.deepcopy(human_gates)
    next(
        gate for gate in changed_gates["gates"]
        if gate["id"] == "story_demo_ja_native_review"
    )["acceptance"] = ["이미 원어민 최종 GO 완료"]
    gate_errors = []
    validate_public_story_demo_human_gates(
        changed_gates, ledger["export_contract"]["staged_public_demo"], gate_errors
    )
    if not any("story_demo_ja_native_review row digest drifted" in message for message in gate_errors):
        failures.append(
            "self-test story_demo_native_acceptance_false_go: mutation was not rejected: "
            f"{gate_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["public_story_demo_package_contract"]["ko_events"] += 1
    exact_errors: list[str] = []
    validate_public_story_demo_source(changed, exact_errors)
    if not any("public story demo ko_events" in message for message in exact_errors):
        failures.append(
            "self-test story_demo_exact_corpus_count: mutation was not rejected: "
            f"{exact_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["public_story_demo_package_contract"]["axis_fingerprints"][
        "gambling"
    ]["content_sha256"] = "0" * 64
    exact_errors = []
    validate_public_story_demo_source(changed, exact_errors)
    if not any("axis fingerprint drifted: gambling" in message for message in exact_errors):
        failures.append(
            "self-test story_demo_exact_axis_content: mutation was not rejected: "
            f"{exact_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["export_contract"]["staged_public_demo"]["export_filter"] = "resources"
    exact_errors = []
    validate_public_story_demo_source(changed, exact_errors)
    if not any("exact macOS filter differs from staged filter" in message for message in exact_errors):
        failures.append(
            "self-test story_demo_exact_source_filter: mutation was not rejected: "
            f"{exact_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["content_axes"][0]["facts"].pop(0)
    exact_errors = []
    validate_public_story_demo_source(changed, exact_errors)
    changed_report = render_report(changed, {})
    if exact_errors or "`simulated_wagering`" not in changed_report:
        failures.append(
            "self-test story_demo_fact_namespace: frozen fact disappeared or coupled "
            f"to current facts: errors={exact_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["public_story_demo_package_contract"]["qualitative_fact_count"] -= 1
    exact_errors = []
    validate_public_story_demo_source(changed, exact_errors)
    if not any("public story demo qualitative_fact_count" in message for message in exact_errors):
        failures.append(
            "self-test story_demo_fact_count_underreport: mutation was not rejected: "
            f"{exact_errors}"
        )

    changed = copy.deepcopy(ledger)
    gambling_scan = changed["content_axes"][0]["candidate_scan"]
    for key in ("categories", "tags", "tokens_ko", "tokens_en"):
        gambling_scan[key] = []
    exact_errors = []
    exact_fingerprints = validate_public_story_demo_source(changed, exact_errors)
    if (
        exact_errors
        or exact_fingerprints.get("gambling", {}).get("event_count") != 137
    ):
        failures.append(
            "self-test story_demo_scan_namespace: current scan altered frozen public scan: "
            f"errors={exact_errors} fingerprint={exact_fingerprints.get('gambling')}"
        )

    exact_sidecar = "assets/backgrounds/a.png.import"
    exact_import_text = (
        '[remap]\n\nimporter="texture"\n'
        'type="CompressedTexture2D"\n'
        'path="res://.godot/imported/a.ctex"\n'
    )
    moved_import_text = exact_import_text.replace("a.ctex", "b.ctex")
    import_errors: list[str] = []
    exact_binding = import_remap_binding(
        exact_sidecar, exact_import_text, "exact-source", import_errors
    )
    moved_binding = import_remap_binding(
        exact_sidecar, moved_import_text, "PCK", import_errors
    )
    import_errors.extend(validate_import_binding_pair(
        exact_sidecar,
        exact_binding,
        moved_binding,
        {".godot/imported/a.ctex", ".godot/imported/b.ctex"},
        {".godot/imported/b.ctex": "assets/backgrounds/b.png.import"},
    ))
    if not any("remap target differs from exact source" in message for message in import_errors):
        failures.append(
            "self-test story_demo_import_target_substitution: mutation was not rejected: "
            f"{import_errors}"
        )

    wrong_type_text = exact_import_text.replace(
        'type="CompressedTexture2D"',
        'type="AudioStreamWAV"',
    )
    type_errors: list[str] = []
    wrong_type_binding = import_remap_binding(
        exact_sidecar, wrong_type_text, "PCK", type_errors
    )
    type_errors.extend(validate_import_binding_pair(
        exact_sidecar,
        exact_binding,
        wrong_type_binding,
        {".godot/imported/a.ctex"},
        {},
    ))
    if not any("importer/type differs from exact source" in message for message in type_errors):
        failures.append(
            "self-test story_demo_import_type_substitution: mutation was not rejected: "
            f"{type_errors}"
        )

    roster_errors = validate_app_zip_member_roster(
        [ledger["public_story_demo_package_contract"]["pck"]["member"]],
        [],
        ledger["public_story_demo_package_contract"]["zip"],
    )
    if not any("logical member roster drifted" in message for message in roster_errors):
        failures.append(
            "self-test story_demo_pck_only_app_zip: mutation was not rejected: "
            f"{roster_errors}"
        )

    with tempfile.TemporaryFile() as payload_fixture:
        payload_fixture.write(b"good")
        payload_fixture.flush()
        digest_errors = validate_pck_payload_digests(
            payload_fixture,
            0,
            {
                "fixture.bin": {
                    "offset": 0,
                    "size": 4,
                    "md5": hashlib.md5(b"bad!").hexdigest(),
                    "flags": 0,
                }
            },
        )
    if not any("payload MD5 differs" in message for message in digest_errors):
        failures.append(
            "self-test story_demo_pck_payload_corruption: mutation was not rejected: "
            f"{digest_errors}"
        )
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write-report", action="store_true", help="regenerate the deterministic Markdown reviewer view")
    parser.add_argument("--self-test", action="store_true", help="prove missing ownership/scope/intensity and auto-decisions are rejected")
    parser.add_argument("--print-baselines", action="store_true", help="print current candidate fingerprints without accepting them")
    parser.add_argument("--pack-zip", action="append", default=[], metavar="PROFILE=PATH", help="inspect a resource-pack ZIP or the exact story_demo_rc app ZIP")
    args = parser.parse_args()

    try:
        ledger = load_json(LEDGER_PATH)
        if args.self_test:
            failures = self_test(ledger)
            if failures:
                print("RELEASE_CONTENT_INVENTORY_SELF_TEST_FAIL")
                for failure in failures:
                    print(f"  ERROR: {failure}")
                return 1
            print("RELEASE_CONTENT_INVENTORY_SELF_TEST_OK cases=45")
            return 0

        errors, fingerprints = validate_source(ledger)
        if args.print_baselines:
            print(json.dumps({key: {k: v for k, v in value.items() if k not in {"event_ids", "files"}} for key, value in fingerprints.items()}, ensure_ascii=False, indent=2))
            return 1 if any("expected_" not in error for error in errors) else 0

        report = render_report(ledger, fingerprints)
        if args.write_report:
            REPORT_PATH.write_text(report, encoding="utf-8")
        elif not REPORT_PATH.is_file():
            errors.append(f"generated report missing: {REPORT_PATH.relative_to(ROOT)}; run --write-report")
        elif REPORT_PATH.read_text(encoding="utf-8") != report:
            errors.append(f"generated report stale: {REPORT_PATH.relative_to(ROOT)}; run --write-report")

        pack_sets: list[tuple[str, set[str]]] = []
        pack_success_markers: list[str] = []
        seen_pack_profiles: set[str] = set()
        seen_pack_paths: set[Path] = set()
        seen_pack_hashes: dict[str, str] = {}
        for spec in args.pack_zip:
            errors.extend(validate_pack_zip(ledger, spec, pack_success_markers))
            if "=" not in spec:
                continue
            profile_id, path_text = spec.split("=", 1)
            if profile_id in seen_pack_profiles:
                errors.append(f"duplicate --pack-zip profile: {profile_id}")
            seen_pack_profiles.add(profile_id)
            path = Path(path_text)
            if not path.is_absolute():
                path = ROOT / path
            if profile_id in PACK_PROFILE_IDS and path.is_file() and zipfile.is_zipfile(path):
                resolved = path.resolve()
                if resolved in seen_pack_paths:
                    errors.append(f"duplicate --pack-zip resolved path: {resolved}")
                seen_pack_paths.add(resolved)
                digest = file_sha256(path)
                previous_profile = seen_pack_hashes.get(digest)
                if previous_profile is not None and previous_profile != profile_id:
                    errors.append(
                        f"pack ZIP bytes reused across profiles: {previous_profile} and {profile_id}"
                    )
                seen_pack_hashes[digest] = profile_id
                if profile_id in PROFILE_IDS:
                    with zipfile.ZipFile(path) as archive:
                        pack_sets.append((profile_id, {
                            normalize_member(info.filename)
                            for info in archive.infolist() if not info.is_dir()
                        }))
        if len(pack_sets) > 1 and ledger["export_contract"]["export_filter"] == "all_resources":
            baseline_profile, baseline = pack_sets[0]
            for profile_id, members in pack_sets[1:]:
                if members != baseline:
                    errors.append(
                        f"all_resources entry-set mismatch: {baseline_profile} vs {profile_id} "
                        f"delta={len(baseline ^ members)}")

        if errors:
            print("RELEASE_CONTENT_INVENTORY_FAIL")
            for error in errors:
                print(f"  ERROR: {error}")
            return 1
        for marker in pack_success_markers:
            print(marker)
        print(
            "RELEASE_CONTENT_INVENTORY_OK "
            f"presets={ledger['export_contract']['preset_count']} "
            f"current_events={ledger['corpus_contract']['ko_events']} "
            f"story_demo_events={ledger['public_story_demo_package_contract']['ko_events']} "
            f"story_demo_shipping={ledger['public_story_demo_package_contract']['shipping_ko_events']} "
            f"story_demo_author_only={ledger['public_story_demo_package_contract']['author_only_events']} "
            f"axes={len(ledger['content_axes'])} network_apis=0 decisions=user_required"
        )
        return 0
    except (OSError, ValueError, KeyError, json.JSONDecodeError, zipfile.BadZipFile) as exc:
        print(f"RELEASE_CONTENT_INVENTORY_FAIL\n  ERROR: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())

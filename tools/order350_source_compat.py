#!/usr/bin/env python3
"""Exact 350/359 current admission; separate KO/EN-only historical views.

No product, receipt, translation inventory or old source gate is rewritten.
Both immutable product transitions and every live successor byte are bound.
"""
from __future__ import annotations

import argparse
import contextlib
import contextvars
import copy
import functools
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

import order313_source_compat as previous

ROOT = Path(__file__).resolve().parents[1]
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALES = ("ja", "zh-CN", "zh-TW")
TOKEN_RE = previous.TOKEN_RE
TRANSITIONS = {
    "350": {
        "before": "d8fbf31cf3171bef1824bec87bdb88d026d77abc", "after": "ef896982207de456042e4288cba651553feb38b1",
        "hashes": {
            "content/events/arc_drama.json": ("8d3a514d2ab5da4190ec4d82a3eaaf1fbc2c224ad32c9da0c500ebe535cca3b2", "88ddf36bdc1f7a51228873393f0680be3d3dd5fc238817451258932c23651537"),
            "content/events/arc_midgame.json": ("c95b30b2172ebc64f3812527a8656b6055fa2068e2b728c0838bcad965eafffd", "9f5e3c2d6401e4a0c52202f69bd5324af6b010af759b99e941e353f32725bfdf"),
            "content/events/arc_year3_drama.json": ("479c31ad52e3707fc9f3ff44a1c539aece40dccaef35a6198330b838d66a7619", "815ab79cd6870a4e6976122232614427dd1817a534466dbd65d4092760536e2f"),
            "content/events/arc_year_close.json": ("5b1e642c159fcdad4ea76f808f41be30036cab77ad350565b06b8db5a00a790b", "6c6f5b2d210e9f6522e28d2dff2654214e0b42e805ff8beec07a50555c0d6314"),
            "content/events_en/arc_drama.json": ("979b96ad1b8f6ecd74382113ffb35af1a5d453fd731997c8710d1144299f001a", "62a4dbe004fdfdb05901b44f82f027766a84e94270ce7b366680ed7c9185bd69"),
            "content/events_en/arc_events.json": ("0baf517023e2b922e003a028cd38c9468622879e30cdceb6a1700679ce81fcc4", "a598057e745ddef838e3cbd4c468f6c1bb25f5cb092514bb0b42c418471775fc"),
            "content/events_en/arc_midgame.json": ("5740e9bcb3013e7378c8f7b42e2b70f66efc1cb30f7eeecc933d16ad86ab8c35", "5ad6715943c969c33df7496838c63fa62041801335aba1cdb8a3b31e5edbcc47"),
            "content/events_en/arc_year3_drama.json": ("a93c68301853a9ee978ac4e36ed00ce284752b06f3c1a0db183f8f0fe69351e8", "3a40e704205559b0f2185b6b0102d14645cc5f398141d3935e62829e703f5188"),
            "content/events_en/arc_year_close.json": ("ea58d290a200397f8e469d1b88bd866a6207f0d6820248b372e658d07b8033e7", "9a467655ad46d22d8595fbd7b75e07dc1b1ec3cbcddd9e95250aefb7720300e4"),
            "content/events_ja/arc_drama.json": ("b1ca526c6f012ee264c864ca778a87fd2377ccda3739d727ecc5a8d233d79986", "9a835aa45cc3e16d9612ee696b715c3189efddb67d3cc6692603978a9c697750"),
            "content/events_ja/arc_midgame.json": ("db38addfe498500a9d5e25d369ba7a327df3ce3f90c9ba704370c31548122d00", "3490522bbcbc58795d6cd2adc7fa48142c647ddb5db638d5af3df78c2e73cd4c"),
            "content/events_ja/arc_year3_drama.json": ("04b96a45a7f6cd0ecba3921ca1ca1b06e4d14a9dabdd1fbfd0093094d9f0a02d", "c1ef551cbf7b06c3793ac1daa81adc0047860fad62d2a7cefd26ac389aac4e98"),
            "content/events_ja/arc_year_close.json": ("14e62e838f01c7dd02654ebe549809457214baae9f0c9a945a8222811d552001", "d33131271249750a2849216a9f5d3e6f7f92c2ba94e96ee48f9e328e56f14aac"),
            "content/events_zh-CN/arc_drama.json": ("9b7fb369c33e14f5d35d3b22f8e9c343c37f82b3a1f53e502ccb62de31ac0476", "0d5abd71dfc8f9f4d7c06491d5c76740def789a699e8f3142be9906d878fc9bd"),
            "content/events_zh-CN/arc_midgame.json": ("466ebd5a2e6cb4f59a171b34d986dcff43a081d4dc4bab4727f4fa092e5c9044", "913350847ea2ec08de5c2a8e656629a8d24d825272857c8c661dddbe665f90b4"),
            "content/events_zh-CN/arc_year3_drama.json": ("03c594ab96d6e7cc82bfbae9ba41d144bd0e98e0dd184ac6bf78638fef3974aa", "3045c2eb3567bdec74636ab3e3eed60aad763c81a902da7934d6a8d0f10dee2b"),
            "content/events_zh-CN/arc_year_close.json": ("21864793fbf946c2cc2e2a470e95d62b3a01dc7d6989f7eb904a1f53d4ad0e20", "486615ec8cb111d4bcadcbaf9fa882413074c50951dbc48e7315e7fe09f5e03e"),
            "content/events_zh-TW/arc_drama.json": ("888a40ffada4fa5e38909c07c59aef93beaf21cb900685cafeffe9958bf7c9ea", "96be10f8d5cd065dd4f828bd8ad36ff13443b7667e0c74667e281fd2d732f7ff"),
            "content/events_zh-TW/arc_midgame.json": ("3b5bf5b956af9636dc0c15b5ab254b4ca97cc16d4d8c2bfe0af04023efa6441c", "59f35f3c3c42524947ca309918c9df01f32fa75a4b8cf2ecd40dd4cfb3a4e162"),
            "content/events_zh-TW/arc_year3_drama.json": ("16dd8d47158bcea020d997de0d62d98e8b47597866eefefc7e55867c00c74b95", "3e052c050f5955e08ef099460a388742caecd936f10d5df31ce390045eeb18cd"),
            "content/events_zh-TW/arc_year_close.json": ("63aa183fe9a6c20ceec3bedb2d6f56774d3e0c9307b2029a2d59503910aeea78", "131fdae0a73c402cbbfd2a871320cc85df2006fc8feb51cbe051817f30e5323f"),
            "content/meta/full_game_localization.json": ("30ca5537b6457d1286522bbdda602f01c23ad6bce1c78d9f14e2dba45bce1ece", "8eda03f5bdd9bb05863e93e5d04090eb6246e43b826edc5f30dff3befb402b8f"),
        },
        "leaves": {
            "content/events/arc_drama.json": (
                ("edit", "arc_sangchul_deduction", ("description",)),
            ),
            "content/events/arc_midgame.json": (
                ("edit", "arc_35_birthday", ("choices", 1, "text")),
                ("edit", "arc_35_birthday", ("description",)),
                ("edit", "arc_35_birthday", ("title",)),
                ("edit", "arc_midpoint_reckoning", ("choices", 0, "result_text")),
                ("edit", "arc_midpoint_reckoning", ("description",)),
            ),
            "content/events/arc_year3_drama.json": (
                ("edit", "arc_minjun_first_call", ("choices", 1, "result_text")),
                ("edit", "arc_minjun_first_call", ("description",)),
            ),
            "content/events/arc_year_close.json": (
                ("add", "arc_year3_close", ("description_if_known", "arc_jaehyuk_ghost_seen")),
                ("edit", "arc_year3_close", ("choices", 0, "result_text")),
                ("edit", "arc_year3_close", ("choices", 0, "text")),
                ("edit", "arc_year3_close", ("choices", 1, "result_text")),
                ("edit", "arc_year3_close", ("choices", 1, "text")),
                ("edit", "arc_year3_close", ("choices", 2, "result_text")),
                ("edit", "arc_year3_close", ("description",)),
            ),
            "content/events_en/arc_drama.json": (
                ("edit", "arc_sangchul_deduction", ("description",)),
            ),
            "content/events_en/arc_events.json": (
                ("edit", "arc_father_05_after_visit", ("choices", 1, "result_text")),
                ("edit", "arc_jaehyuk_03_pitch", ("choices", 0, "result_text")),
                ("edit", "arc_jaehyuk_03_pitch", ("choices", 1, "result_text")),
                ("edit", "arc_jaehyuk_03_pitch", ("choices", 2, "result_text")),
                ("edit", "arc_jaehyuk_03_pitch", ("choices", 2, "text")),
                ("edit", "arc_jaehyuk_03_pitch", ("description_orthodox",)),
                ("edit", "arc_jaehyuk_03_pitch", ("description_unorthodox",)),
                ("edit", "arc_jaehyuk_03_pitch", ("description",)),
            ),
            "content/events_en/arc_midgame.json": (
                ("edit", "arc_35_birthday", ("choices", 1, "result_text")),
                ("edit", "arc_35_birthday", ("choices", 1, "text")),
                ("edit", "arc_35_birthday", ("description",)),
                ("edit", "arc_35_birthday", ("title",)),
                ("edit", "arc_jaehyuk_wait", ("description",)),
                ("edit", "arc_midpoint_reckoning", ("choices", 0, "result_text")),
                ("edit", "arc_midpoint_reckoning", ("description",)),
            ),
            "content/events_en/arc_year3_drama.json": (
                ("edit", "arc_minjun_first_call", ("choices", 1, "result_text")),
                ("edit", "arc_minjun_first_call", ("description",)),
            ),
            "content/events_en/arc_year_close.json": (
                ("add", "arc_year3_close", ("description_if_known", "arc_jaehyuk_ghost_seen")),
                ("edit", "arc_year3_close", ("choices", 0, "result_text")),
                ("edit", "arc_year3_close", ("choices", 0, "text")),
                ("edit", "arc_year3_close", ("choices", 1, "result_text")),
                ("edit", "arc_year3_close", ("choices", 1, "text")),
                ("edit", "arc_year3_close", ("choices", 2, "result_text")),
                ("edit", "arc_year3_close", ("choices", 2, "text")),
                ("edit", "arc_year3_close", ("description",)),
            ),
            "content/events_ja/arc_drama.json": (
                ("edit", "arc_sangchul_deduction", ("description",)),
            ),
            "content/events_ja/arc_midgame.json": (
                ("edit", "arc_35_birthday", ("choices", 1, "text")),
                ("edit", "arc_35_birthday", ("description",)),
                ("edit", "arc_35_birthday", ("title",)),
                ("edit", "arc_midpoint_reckoning", ("choices", 0, "result_text")),
                ("edit", "arc_midpoint_reckoning", ("description",)),
            ),
            "content/events_ja/arc_year3_drama.json": (
                ("edit", "arc_minjun_first_call", ("choices", 1, "result_text")),
                ("edit", "arc_minjun_first_call", ("description",)),
            ),
            "content/events_ja/arc_year_close.json": (
                ("add", "arc_year3_close", ("description_if_known", "arc_jaehyuk_ghost_seen")),
                ("edit", "arc_year3_close", ("choices", 0, "result_text")),
                ("edit", "arc_year3_close", ("choices", 0, "text")),
                ("edit", "arc_year3_close", ("choices", 1, "result_text")),
                ("edit", "arc_year3_close", ("choices", 1, "text")),
                ("edit", "arc_year3_close", ("choices", 2, "result_text")),
                ("edit", "arc_year3_close", ("description",)),
            ),
            "content/events_zh-CN/arc_drama.json": (
                ("edit", "arc_sangchul_deduction", ("description",)),
            ),
            "content/events_zh-CN/arc_midgame.json": (
                ("edit", "arc_35_birthday", ("choices", 1, "text")),
                ("edit", "arc_35_birthday", ("description",)),
                ("edit", "arc_35_birthday", ("title",)),
                ("edit", "arc_midpoint_reckoning", ("choices", 0, "result_text")),
                ("edit", "arc_midpoint_reckoning", ("description",)),
            ),
            "content/events_zh-CN/arc_year3_drama.json": (
                ("edit", "arc_minjun_first_call", ("choices", 1, "result_text")),
                ("edit", "arc_minjun_first_call", ("description",)),
            ),
            "content/events_zh-CN/arc_year_close.json": (
                ("add", "arc_year3_close", ("description_if_known", "arc_jaehyuk_ghost_seen")),
                ("edit", "arc_year3_close", ("choices", 0, "result_text")),
                ("edit", "arc_year3_close", ("choices", 0, "text")),
                ("edit", "arc_year3_close", ("choices", 1, "result_text")),
                ("edit", "arc_year3_close", ("choices", 1, "text")),
                ("edit", "arc_year3_close", ("choices", 2, "result_text")),
                ("edit", "arc_year3_close", ("description",)),
            ),
            "content/events_zh-TW/arc_drama.json": (
                ("edit", "arc_sangchul_deduction", ("description",)),
            ),
            "content/events_zh-TW/arc_midgame.json": (
                ("edit", "arc_35_birthday", ("choices", 1, "text")),
                ("edit", "arc_35_birthday", ("description",)),
                ("edit", "arc_35_birthday", ("title",)),
                ("edit", "arc_midpoint_reckoning", ("choices", 0, "result_text")),
                ("edit", "arc_midpoint_reckoning", ("description",)),
            ),
            "content/events_zh-TW/arc_year3_drama.json": (
                ("edit", "arc_minjun_first_call", ("choices", 1, "result_text")),
                ("edit", "arc_minjun_first_call", ("description",)),
            ),
            "content/events_zh-TW/arc_year_close.json": (
                ("add", "arc_year3_close", ("description_if_known", "arc_jaehyuk_ghost_seen")),
                ("edit", "arc_year3_close", ("choices", 0, "result_text")),
                ("edit", "arc_year3_close", ("choices", 0, "text")),
                ("edit", "arc_year3_close", ("choices", 1, "result_text")),
                ("edit", "arc_year3_close", ("choices", 1, "text")),
                ("edit", "arc_year3_close", ("choices", 2, "result_text")),
                ("edit", "arc_year3_close", ("description",)),
            ),
        },
        "counts": (40299, 40302), "batch_counts": (139, 140),
        "batch_hash": "f34dd480568dcf343a87f83212f801a01f2b9acc9674c7de4363595f1b5ca0f0",
    },
    "359": {
        "before": "e3a6e09d5a6e3398a4db764177352dc7755d0892", "after": "acab8ea29d2ec392d1224513e005e8b8000a4535",
        "hashes": {
            "content/events/arc_year_close.json": ("6c6f5b2d210e9f6522e28d2dff2654214e0b42e805ff8beec07a50555c0d6314", "f81c88e06d0b96f3b22d42bc74adbab6e1366c030b6a29bb182df56dfb924855"),
            "content/events_en/arc_year_close.json": ("9a467655ad46d22d8595fbd7b75e07dc1b1ec3cbcddd9e95250aefb7720300e4", "7e8809cb61be9d99c5df4bdf4b12da762a57502cbf5113fda943f179c92b5921"),
            "content/events_ja/arc_year_close.json": ("d33131271249750a2849216a9f5d3e6f7f92c2ba94e96ee48f9e328e56f14aac", "2acdf5e3987af3ecf0aa568c0e75597240d2436d5939047f815dfa7c05c441b0"),
            "content/events_zh-CN/arc_year_close.json": ("486615ec8cb111d4bcadcbaf9fa882413074c50951dbc48e7315e7fe09f5e03e", "53592dafae59623ed0a74c21657bf181f427a04e5fd0325c9745d929004e61aa"),
            "content/events_zh-TW/arc_year_close.json": ("131fdae0a73c402cbbfd2a871320cc85df2006fc8feb51cbe051817f30e5323f", "3c4df76b5c4afd8f9c5a0eef775a0a05b956d59a80dffa19400bc6263422c70c"),
            "content/meta/full_game_localization.json": ("8eda03f5bdd9bb05863e93e5d04090eb6246e43b826edc5f30dff3befb402b8f", "786003ef4a6da383f52c3945fb58b1782cf7e95775d1a2bd9ff4a23e7f5c5c91"),
        },
        "leaves": {
            "content/events/arc_year_close.json": (
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_weighted")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_weighted")),
            ),
            "content/events_en/arc_year_close.json": (
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_weighted")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_weighted")),
            ),
            "content/events_ja/arc_year_close.json": (
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_weighted")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_weighted")),
            ),
            "content/events_zh-CN/arc_year_close.json": (
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_weighted")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_weighted")),
            ),
            "content/events_zh-TW/arc_year_close.json": (
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close_father_passed", ("description_if_known", "year3_weighted")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_eyes_open")),
                ("edit", "arc_year4_close", ("description_if_known", "year3_weighted")),
            ),
        },
        "counts": (40302, 40302), "batch_counts": (140, 141),
        "batch_hash": "d6e06e39de3c927a14cc7d5ad97e6edce4c04616bc6bce3f6fab03654cc3d3b4",
    },
}

BEFORE_COMMIT = TRANSITIONS["350"]["before"]
AFTER_COMMIT = TRANSITIONS["359"]["after"]
CURRENT_PATHS = tuple(TRANSITIONS["350"]["hashes"])
CURRENT_JSON_LEAVES = {
    p: tuple((event, path) for order in TRANSITIONS
             for _op, event, path in TRANSITIONS[order]["leaves"].get(p, ()))
    for p in CURRENT_PATHS if p != LEDGER_PATH
}
JSON_LEAVES = {p: leaves for p, leaves in CURRENT_JSON_LEAVES.items()
               if p.startswith(("content/events/", "content/events_en/"))}
PATHS = tuple(JSON_LEAVES)
FILE_HASHES = {
    p: (TRANSITIONS["350"]["hashes"][p][0],
        TRANSITIONS["359"]["hashes"].get(p, TRANSITIONS["350"]["hashes"][p])[1])
    for p in CURRENT_PATHS
}
LIVE_PATHS = tuple(dict.fromkeys((*previous.LIVE_PATHS, *CURRENT_PATHS)))
HISTORICAL_PATHS = tuple(dict.fromkeys((*previous.HISTORICAL_PATHS, *PATHS)))
HISTORICAL_JSON_LEAVES = {
    p: tuple(dict.fromkeys((*previous.HISTORICAL_JSON_LEAVES.get(p, ()), *JSON_LEAVES.get(p, ()))))
    for p in HISTORICAL_PATHS
}
LIVE_EVENT_IDS = {
    p: frozenset(previous.LIVE_EVENT_IDS.get(p, ()))
    | frozenset(event for event, _path in CURRENT_JSON_LEAVES.get(p, ()))
    for p in LIVE_PATHS if p.endswith(".json") and p != LEDGER_PATH
}
MODULE_HASHES = {**previous.MODULE_HASHES,
    "tools/order313_source_compat.py": "100851c461fbb044e27e985265bc90bafcd26dd5816499886cbbe789ecbb92ba"}
_ACTIVE_PROOF = contextvars.ContextVar("order350_git_proof", default=None)
_sha = previous._sha
_canonical = previous._canonical
_digest = previous._digest
_loads = previous._loads
_rows = previous._rows
_leaf = previous._leaf
_set_leaf = previous._set_leaf


def _git(*args: str) -> bytes:
    result = subprocess.run(("git", *args), cwd=ROOT, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-350: immutable Git proof unavailable: " + " ".join(args))
    return result.stdout


def _git_blob(revision: str, relative: str) -> bytes:
    proof = _ACTIVE_PROOF.get()
    if proof is not None and (revision, relative) in proof:
        return proof[revision, relative]
    return _git("show", f"{revision}:{relative}")


def _verify_git_registration() -> None:
    for order, transition in TRANSITIONS.items():
        before, after = transition["before"], transition["after"]
        if _git("rev-parse", after + "^").decode().strip() != before:
            raise ValueError("ORDER-350: exact parent drifted " + order)
        actual = _git("diff", "--name-status", "-z", before, after).split(b"\0")
        expected = [part for path in sorted(transition["hashes"])
                    for part in (b"M", path.encode())] + [b""]
        if actual != expected:
            raise ValueError("ORDER-350: exact transition population drifted " + order)
    for path, pair in TRANSITIONS["359"]["hashes"].items():
        if pair[0] != TRANSITIONS["350"]["hashes"][path][1]:
            raise ValueError("ORDER-350: non-contiguous transition bytes " + path)


def _read_git_pairs() -> dict[tuple[str, str], bytes]:
    requests = [(revision, path) for transition in TRANSITIONS.values()
                for path in transition["hashes"]
                for revision in (transition["before"], transition["after"])]
    query = "".join(f"{rev}:{path}\n" for rev, path in requests).encode()
    result = subprocess.run(("git", "cat-file", "--batch"), cwd=ROOT,
                            input=query, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-350: bulk immutable proof unavailable")
    cursor, blobs = 0, {}
    for request in requests:
        end = result.stdout.find(b"\n", cursor)
        header = result.stdout[cursor:end].split()
        if (end < cursor or len(header) != 3 or not re.fullmatch(rb"[0-9a-f]{40}", header[0])
                or header[1] != b"blob" or not header[2].isdigit()):
            raise ValueError("ORDER-350: malformed immutable blob " + str(request))
        size, cursor = int(header[2]), end + 1
        if result.stdout[cursor + size:cursor + size + 1] != b"\n":
            raise ValueError("ORDER-350: truncated immutable blob " + str(request))
        blobs[request] = result.stdout[cursor:cursor + size]
        cursor += size + 1
    if cursor != len(result.stdout):
        raise ValueError("ORDER-350: trailing bulk proof bytes")
    return blobs


@contextlib.contextmanager
def fresh_validation_proof():
    """Share only immutable Git reads within one invocation, never across calls."""
    if _ACTIVE_PROOF.get() is not None:
        yield
        return
    _verify_git_registration()
    token = _ACTIVE_PROOF.set(_read_git_pairs())
    try:
        with previous.fresh_validation_proof():
            _verify_original_modules()
            yield
    finally:
        _ACTIVE_PROOF.reset(token)


class _Document:
    """Strict JSON and literal/key spans for exact inverse reconstruction."""
    def __init__(self, raw: bytes):
        self.value = _loads(raw)
        self.text = raw.decode("utf-8")
        self.spans: dict[tuple, tuple[int, int]] = {}
        self.keys: dict[tuple, int] = {}
        end = self._walk(0, ())
        if self.text[end:].strip():
            raise ValueError("ORDER-350: trailing JSON data")

    def _ws(self, index):
        while index < len(self.text) and self.text[index].isspace():
            index += 1
        return index

    def _walk(self, index, path):
        start = index = self._ws(index)
        char = self.text[index]
        if char == "{":
            index = self._ws(index + 1)
            while self.text[index] != "}":
                key_start = index
                key, index = json.JSONDecoder().raw_decode(self.text, index)
                index = self._ws(index)
                if self.text[index] != ":":
                    raise ValueError("ORDER-350: missing colon")
                self.keys[(*path, key)] = key_start
                index = self._ws(self._walk(index + 1, (*path, key)))
                if self.text[index] != ",":
                    break
                index = self._ws(index + 1)
            index += 1
        elif char == "[":
            index, ordinal = self._ws(index + 1), 0
            while self.text[index] != "]":
                index = self._ws(self._walk(index, (*path, ordinal)))
                ordinal += 1
                if self.text[index] != ",":
                    break
                index = self._ws(index + 1)
            index += 1
        else:
            _, index = json.JSONDecoder().raw_decode(self.text, index)
        self.spans[path] = (start, index)
        return index


def _delete_leaf(row: Any, path: tuple) -> None:
    for key in path[:-1]:
        row = row[key]
    del row[path[-1]]


def _ordered(value: Any) -> bytes:
    """Bind condition priority and every other observed object-key order."""
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"),
                      allow_nan=False).encode("utf-8")


def _verify_json_delta(order: str, before: bytes, after: bytes, relative: str) -> None:
    leaves = TRANSITIONS[order]["leaves"][relative]
    old_doc, new_doc = _Document(before), _Document(after)
    old, new = old_doc.value, new_doc.value
    old_rows, new_rows = _rows(old), _rows(new)
    if list(old_rows) != list(new_rows):
        raise ValueError("ORDER-350: event roster/order drifted " + relative)
    restored = copy.deepcopy(new)
    restored_rows = _rows(restored)
    indexes = {row["id"]: i for i, row in enumerate(new)}
    replacements = []
    for op, event, path in leaves:
        new_text = _leaf(new_rows[event], path)
        if not isinstance(new_text, str):
            raise ValueError("ORDER-350: non-text declared leaf " + event)
        location = (indexes[event], *path)
        start, end = new_doc.spans[location]
        if op == "add":
            if (order != "350" or event != "arc_year3_close"
                    or path != ("description_if_known", "arc_jaehyuk_ghost_seen")
                    or path[-1] in old_rows[event][path[0]]
                    or new_text != old_rows[event]["description"]
                    or list(new_rows[event][path[0]])[-1] != path[-1]):
                raise ValueError("ORDER-350: exact appended ghost variant drifted")
            start = new_doc.keys[location] - 1
            while new_doc.text[start].isspace():
                start -= 1
            if new_doc.text[start] != ",":
                raise ValueError("ORDER-350: added variant delimiter drifted")
            replacements.append((start, end, ""))
            _delete_leaf(restored_rows[event], path)
        elif op == "edit":
            old_text = _leaf(old_rows[event], path)
            # Approved 350 exception: the absent signature removes one name
            # from EN default; the newly appended ghost keeps the old four.
            token_exception = (order == "350" and relative == "content/events_en/arc_year_close.json"
                               and event == "arc_year3_close" and path == ("description",)
                               and TOKEN_RE.findall(old_text) == ["{name}"] * 4
                               and TOKEN_RE.findall(new_text) == ["{name}"] * 3)
            if (not isinstance(old_text, str) or old_text == new_text
                    or old_text.count("\n") != new_text.count("\n")
                    or (TOKEN_RE.findall(old_text) != TOKEN_RE.findall(new_text) and not token_exception)):
                raise ValueError("ORDER-350: exact text/token/newline delta drifted " + event)
            a, b = old_doc.spans[location]
            replacements.append((start, end, old_doc.text[a:b]))
            _set_leaf(restored_rows[event], path, old_text)
        else:
            raise ValueError("ORDER-350: unregistered leaf operation")
    raw = new_doc.text
    for start, end, value in sorted(replacements, reverse=True):
        raw = raw[:start] + value + raw[end:]
    if raw.encode() != before or _canonical(restored) != _canonical(old):
        raise ValueError("ORDER-350: non-owned raw/JSON source drifted " + relative)


def _receipt(row: Any, ko_path: str, target: Any, path: tuple) -> dict[str, str]:
    return {"source_sha256": _digest({"path": ko_path, "field": path, "ko": _leaf(row, path)}),
            "target_sha256": _digest(_leaf(target, path))}


def _verify_receipt_delta(order: str, before: bytes, after: bytes,
                          texts: dict[str, tuple[bytes, bytes]]) -> None:
    old, new = _loads(before), _loads(after)
    transition = TRANSITIONS[order]
    owned = {"accepted", "accepted_sha256", "batches"}
    if (list(old) != list(new) or {k: v for k, v in old.items() if k not in owned}
            != {k: v for k, v in new.items() if k not in owned}):
        raise ValueError("ORDER-350: receipt metadata drifted " + order)
    if ([len(x["batches"]) for x in (old, new)] != list(transition["batch_counts"])
            or new["batches"][:-1] != old["batches"]
            or _digest(new["batches"][-1]) != transition["batch_hash"]):
        raise ValueError("ORDER-350: immutable receipt batch history drifted " + order)
    if list(old["accepted"]) != list(new["accepted"]) or set(new["accepted"]) != set(LOCALES):
        raise ValueError("ORDER-350: receipt locale population drifted")
    for locale in LOCALES:
        edits, additions = set(), set()
        prior, current = old["accepted"][locale], new["accepted"][locale]
        for relative, leaves in transition["leaves"].items():
            if not relative.startswith(f"content/events_{locale}/"):
                continue
            ko_path = relative.replace(f"events_{locale}/", "events/", 1)
            ko = [_rows(_loads(raw)) for raw in texts[ko_path]]
            target = [_rows(_loads(raw)) for raw in texts[relative]]
            for op, event, path in leaves:
                receipt_id = f"events:{event}:/" + "/".join(map(str, path))
                (additions if op == "add" else edits).add(receipt_id)
                if current.get(receipt_id) != _receipt(ko[1][event], ko_path, target[1][event], path):
                    raise ValueError("ORDER-350: current receipt text binding drifted " + receipt_id)
                if op == "edit" and prior.get(receipt_id) != _receipt(ko[0][event], ko_path, target[0][event], path):
                    raise ValueError("ORDER-350: prior receipt text binding drifted " + receipt_id)
        if (set(current) - set(prior) != additions or set(prior) - set(current)
                or {key for key in prior if prior[key] != current.get(key)} != edits
                or [key for key in current if key not in additions] != list(prior)):
            raise ValueError("ORDER-350: non-owned receipt/key/order drifted " + locale)
    for ledger, count in zip((old, new), transition["counts"]):
        if (sum(map(len, ledger["accepted"].values())) != count
                or ledger["accepted_sha256"] != _digest(ledger["accepted"])):
            raise ValueError("ORDER-350: receipt total/checksum drifted")


@functools.lru_cache(maxsize=28)
def _verify_transition(order: str, before: bytes, after: bytes, relative: str,
                       receipt_texts: tuple = ()) -> None:
    # Cache pure byte proofs only; Git registration and blob reads stay fresh.
    if (_sha(before), _sha(after)) != TRANSITIONS[order]["hashes"][relative]:
        raise ValueError("ORDER-350: immutable raw hashes drifted " + order + ":" + relative)
    if relative == LEDGER_PATH:
        _verify_receipt_delta(order, before, after, {p: (a, b) for p, a, b in receipt_texts})
    else:
        _verify_json_delta(order, before, after, relative)


def _stage_blobs(order: str, relative: str) -> tuple[bytes, bytes]:
    stage = TRANSITIONS[order]
    before, after = (_git_blob(stage[side], relative) for side in ("before", "after"))
    texts = ()
    if relative == LEDGER_PATH:
        texts = tuple((p, *_stage_blobs(order, p)) for p in stage["leaves"]
                      if not p.startswith("content/events_en/"))
    _verify_transition(order, before, after, relative, texts)
    return before, after


def verified_blobs(relative: str) -> tuple[bytes, bytes]:
    """Return pre350/latest359 bytes; old-only history paths retain prior API."""
    if relative not in CURRENT_PATHS:
        return previous.verified_blobs(relative)
    if _ACTIVE_PROOF.get() is None:
        with fresh_validation_proof():
            return verified_blobs(relative)
    before, after = _stage_blobs("350", relative)
    if relative in previous.LIVE_PATHS and previous.source_errors(before, relative):
        raise ValueError("ORDER-350: predecessor does not bind to original 313 chain " + relative)
    if relative in TRANSITIONS["359"]["hashes"]:
        middle, latest = _stage_blobs("359", relative)
        if middle != after:
            raise ValueError("ORDER-350: sequential transition gap " + relative)
        after = latest
    return before, after


def inverse_350_bytes(raw: bytes, relative: str) -> bytes:
    if relative not in PATHS or _sha(raw) != FILE_HASHES[relative][1]:
        return raw
    try:
        before, after = verified_blobs(relative)
        return before if raw == after else raw
    except (OSError, ValueError):
        return raw


def inverse_350_payload(payload: Any, relative: str) -> Any:
    """Comparison only: inverse complete exact rows; remove new ghost keys."""
    projected = copy.deepcopy(payload)
    if relative not in PATHS or not isinstance(payload, list):
        return projected
    try:
        rows = _rows(projected)
        # This comparison-only copy has nothing for this layer to restore.
        # Admission and the enclosing chain's fresh proof remain unchanged.
        if not any(event in rows for event, _path in JSON_LEAVES[relative]):
            return projected
        old, new = (_rows(_loads(raw)) for raw in verified_blobs(relative))
        for event in dict.fromkeys(event for event, _ in JSON_LEAVES[relative]):
            if event not in rows or _ordered(rows[event]) != _ordered(new[event]):
                continue
            for order in reversed(TRANSITIONS):
                for op, owner, path in TRANSITIONS[order]["leaves"].get(relative, ()):
                    if owner == event:
                        if op == "add":
                            _delete_leaf(rows[event], path)
                        else:
                            _set_leaf(rows[event], path, _leaf(old[event], path))
    except (OSError, ValueError, KeyError, TypeError, IndexError):
        return copy.deepcopy(payload)
    return projected


def inverse_350_hash(digest: str, relative: str) -> str:
    if relative in PATHS and digest == FILE_HASHES[relative][1]:
        try:
            before, after = verified_blobs(relative)
            return _sha(before) if digest == _sha(after) else digest
        except (OSError, ValueError):
            pass
    return digest


def _compose(value: Any, relative: str, inverse, next_step):
    # Do not fall through to an older inverse when any current proof fails.
    if relative in PATHS:
        try:
            verified_blobs(relative)
        except (OSError, ValueError):
            return copy.deepcopy(value)
        value = inverse(value, relative)
    elif relative in CURRENT_PATHS:
        return copy.deepcopy(value)
    return next_step(value, relative)


def inverse_current_bytes(raw: bytes, relative: str) -> bytes:
    """Post305 comparison: undo 359/350 -> 313 -> 309 only."""
    return _compose(raw, relative, inverse_350_bytes, previous.inverse_current_bytes)


def inverse_current_payload(payload: Any, relative: str) -> Any:
    return _compose(payload, relative, inverse_350_payload, previous.inverse_current_payload)


def inverse_current_hash(digest: str, relative: str) -> str:
    return _compose(digest, relative, inverse_350_hash, previous.inverse_current_hash)


def project_bytes(raw: bytes, relative: str) -> bytes:
    return _compose(raw, relative, inverse_350_bytes, previous.project_bytes)


def project_payload(payload: Any, relative: str) -> Any:
    return _compose(payload, relative, inverse_350_payload, previous.project_payload)


def project_byte_hash(digest: str, relative: str) -> str:
    return _compose(digest, relative, inverse_350_hash, previous.project_byte_hash)


def historical_blobs(relative: str) -> tuple[bytes, bytes]:
    if relative not in HISTORICAL_PATHS:
        raise ValueError("ORDER-350: unregistered historical path " + relative)
    with fresh_validation_proof():
        _before, current = verified_blobs(relative)
        return inverse_current_bytes(current, relative), current


def source_errors(raw: bytes, relative: str) -> list[str]:
    if relative not in CURRENT_PATHS:
        return previous.source_errors(raw, relative)
    if _sha(raw) != FILE_HASHES[relative][1]:
        return ["ORDER-350: current source exceeds exact approved successor " + relative]
    try:
        _before, after = verified_blobs(relative)
        return [] if raw == after else ["ORDER-350: immutable raw proof mismatch " + relative]
    except (OSError, ValueError) as exc:
        return [str(exc)]


def current_source_errors(root: Path = ROOT) -> list[str]:
    errors = []
    try:
        with fresh_validation_proof():
            for relative in LIVE_PATHS:
                try:
                    errors.extend(source_errors((root / relative).read_bytes(), relative))
                except OSError as exc:
                    errors.append("ORDER-350: current source unavailable " + relative + ": " + str(exc))
    except (OSError, ValueError) as exc:
        errors.append(str(exc))
    return errors


def source_observation_errors(raw: bytes, payload: Any, relative: str) -> list[str]:
    errors = source_errors(raw, relative)
    try:
        if _ordered(_loads(raw)) != _ordered(payload):
            errors.append("ORDER-350: observed payload not bound to raw bytes " + relative)
    except (ValueError, TypeError, UnicodeError):
        errors.append("ORDER-350: malformed raw/payload observation " + relative)
    return errors


def observed_byte_hash(relative: str, observed: str, raw: bytes) -> tuple[str, list[str]]:
    errors = source_errors(raw, relative)
    if _sha(raw) != observed:
        errors.append("ORDER-350: observed hash not bound to raw bytes " + relative)
    if errors:
        return observed, errors
    if relative in HISTORICAL_PATHS:
        return inverse_current_hash(observed, relative), []
    if relative in CURRENT_PATHS:
        return observed, []
    return previous.observed_byte_hash(relative, observed, raw)


def _verify_original_modules() -> dict[str, bytes]:
    modules = (previous.previous.original305, previous.previous.original310,
               previous.previous.previous, previous.previous, previous)
    blobs = {}
    for (relative, digest), module in zip(MODULE_HASHES.items(), modules):
        raw = _git_blob(BEFORE_COMMIT, relative)
        if (_sha(raw) != digest or Path(module.__file__).resolve() != ROOT / relative
                or module.ROOT != ROOT or (ROOT / relative).read_bytes() != raw):
            raise ValueError("ORDER-350: original module/import identity drifted " + relative)
        blobs[relative] = raw
    return blobs


def _run_isolated_313() -> dict[str, Any]:
    """Run the unchanged 370-case CLI against verified pre350 live bytes."""
    blobs = _verify_original_modules()
    live_hashes = {}
    with previous.fresh_validation_proof():
        for relative in previous.LIVE_PATHS:
            raw = _git_blob(BEFORE_COMMIT, relative)
            errors = previous.source_errors(raw, relative)
            if errors:
                raise ValueError("ORDER-350: pre350 fixture admission: " + "; ".join(errors))
            blobs[relative] = raw
            live_hashes[relative] = _sha(raw)
    if len(live_hashes) != 19:
        raise ValueError("ORDER-350: isolated pre350 live population drifted")
    git_dir = Path(_git("rev-parse", "--absolute-git-dir").decode().strip())
    scratch = git_dir / "full-game-localization"
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="order358-original313-", dir=scratch) as directory:
        root = Path(directory).resolve()
        for relative, raw in blobs.items():
            target = root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(0o444)
        runner = """
import hashlib, importlib, json, pathlib, sys
root = pathlib.Path(sys.argv[1]).resolve()
hashes = json.loads(sys.argv[2])
sys.path.insert(0, str(root / 'tools'))
identity = {}
for relative, expected in hashes.items():
    module = importlib.import_module(pathlib.Path(relative).stem)
    path = pathlib.Path(module.__file__).resolve()
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if path != root / relative or module.ROOT != root or digest != expected:
        raise RuntimeError('isolated module/import identity mismatch: ' + relative)
    identity[relative] = {'file': str(path), 'root': str(module.ROOT), 'sha256': digest}
print('ORDER350_ISOLATED_IDENTITY ' + json.dumps(identity, sort_keys=True), flush=True)
sys.argv = [str(root / 'tools/order313_source_compat.py'), '--self-test']
raise SystemExit(importlib.import_module('order313_source_compat').main())
"""
        env = dict(os.environ, GIT_DIR=str(git_dir), GIT_WORK_TREE=str(root),
                   GIT_OPTIONAL_LOCKS="0", PYTHONDONTWRITEBYTECODE="1")
        process = subprocess.run((sys.executable, "-I", "-B", "-c", runner,
                                  str(root), json.dumps(MODULE_HASHES)),
                                 cwd=root, env=env, capture_output=True, text=True, timeout=600)
        marker = ("ORDER313_SOURCE_OK current_files=7 leaves=20 receipts=9 "
                  "historical_files=4 historical_leaves=11 live_files=19 "
                  "historical_union=7 units=313,356 cases=370")
        errors = []
        if process.returncode or marker not in process.stdout.splitlines() or process.stderr.strip():
            errors.append("unmodified isolated ORDER-313 CLI failed")
        identity_lines = [line.removeprefix("ORDER350_ISOLATED_IDENTITY ")
                          for line in process.stdout.splitlines()
                          if line.startswith("ORDER350_ISOLATED_IDENTITY ")]
        identities = json.loads(identity_lines[0]) if len(identity_lines) == 1 else {}
        if set(identities) != set(MODULE_HASHES):
            errors.append("isolated module identity output missing")
        for relative, raw in blobs.items():
            if (root / relative).read_bytes() != raw:
                errors.append("isolated original fixture changed " + relative)
        return {"corpus": "ORDER-313", "cases": 370 if not errors else 0,
                "source_revision": BEFORE_COMMIT, "live_files": live_hashes,
                "modules": identities, "errors": errors, "returncode": process.returncode,
                "stdout": process.stdout, "stderr": process.stderr,
                "meaning": "historical CLI on immutable pre350 fixture, not current admission"}


def historical_self_test() -> tuple[list[str], int, list[dict[str, Any]]]:
    """Original 301 current-caller functions + isolated CLI 286 + CLI 370."""
    errors, cases, results = current_source_errors(), 0, []
    if errors:
        return errors, cases, results
    try:
        _verify_original_modules()
        failures, count, original = previous.previous.historical_self_test()
        errors.extend(failures)
        cases += count
        for item in original:
            item["meaning"] = "unchanged original function corpus using actual current consumers"
        results.extend(original)
        for runner in (previous._run_isolated_309, _run_isolated_313):
            result = runner()
            errors.extend(result["errors"])
            cases += result["cases"]
            results.append(result)
    except (OSError, ValueError, subprocess.TimeoutExpired) as exc:
        errors.append("ORDER-350: historical corpus unavailable: " + str(exc))
    if cases != 957:
        errors.append(f"ORDER-350: expected historical cases957 observed{cases}")
    return errors, cases, results


def self_test() -> tuple[list[str], int]:
    """Current positives and exact-scope negatives; no old corpus assertions altered."""
    from unittest import mock
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def rejected(call, label):
        try:
            call()
        except (ValueError, OSError, TypeError, KeyError, IndexError):
            check(True, label)
        else:
            check(False, label)

    check(len(CURRENT_PATHS) == 22 and len(CURRENT_JSON_LEAVES) == 21
          and sum(map(len, CURRENT_JSON_LEAVES.values())) == 106
          and len(LIVE_PATHS) == 38, "exact live population 22/106 union38")
    check(len(PATHS) == 9 and sum(map(len, JSON_LEAVES.values())) == 49
          and len(HISTORICAL_PATHS) == 14
          and sum(map(len, HISTORICAL_JSON_LEAVES.values())) == 68,
          "exact historical population 9/49 union14/68")
    check(not current_source_errors(), "actual current whole-union admission")
    check(len(_verify_original_modules()) == 5, "five original module identities")
    with fresh_validation_proof():
        blobs = {p: verified_blobs(p) for p in CURRENT_PATHS}
        for relative, (before, after) in blobs.items():
            old, new = _loads(before), _loads(after)
            check((ROOT / relative).read_bytes() == after and not source_errors(after, relative),
                  relative + " current exact raw positive")
            check(not source_observation_errors(after, new, relative), relative + " raw/payload positive")
            check(not observed_byte_hash(relative, _sha(after), after)[1], relative + " raw/hash positive")
            check(bool(source_observation_errors(after, old, relative)), relative + " stale payload rejected")
            check(bool(observed_byte_hash(relative, _sha(before), after)[1]), relative + " stale hash rejected")
            for label, raw in (("rollback", before), ("raw format", after + b"\n"),
                               ("empty", b""), ("malformed", b"[")):
                check(bool(source_errors(raw, relative)) and inverse_350_bytes(raw, relative) == raw
                      and inverse_350_hash(_sha(raw), relative) == _sha(raw), relative + " rejects " + label)
            check(bool(source_errors(after, relative + ".wrong")), relative + " wrong path rejected")
            if relative not in PATHS:
                check(inverse_current_bytes(after, relative) == after
                      and inverse_current_payload(new, relative) == new
                      and inverse_current_hash(_sha(after), relative) == _sha(after)
                      and project_bytes(after, relative) == after
                      and project_payload(new, relative) == new
                      and project_byte_hash(_sha(after), relative) == _sha(after),
                      relative + " current prepared targets/ledger never projected")
            else:
                check(inverse_350_bytes(after, relative) == before
                      and inverse_350_payload(new, relative) == old
                      and inverse_350_hash(_sha(after), relative) == _sha(before),
                      relative + " exact two-transition inverse")
                check(project_bytes(after, relative) == previous.project_bytes(before, relative)
                      and project_payload(new, relative) == previous.project_payload(old, relative)
                      and project_byte_hash(_sha(after), relative) == previous.project_byte_hash(_sha(before), relative),
                      relative + " complete historical chain")
                check(inverse_current_bytes(after, relative) == previous.inverse_current_bytes(before, relative)
                      and inverse_current_payload(new, relative) == previous.inverse_current_payload(old, relative),
                      relative + " post305 comparison preserves305")
                saved = copy.deepcopy(new)
                check(inverse_350_payload(list(reversed(new)), relative) == list(reversed(old)) and new == saved,
                      relative + " copied projection preserves row order/input")
            if relative not in CURRENT_JSON_LEAVES:
                continue
            old_rows, new_rows = _rows(old), _rows(new)
            for event, path in CURRENT_JSON_LEAVES[relative]:
                for label, value in (("mutation", "unapproved"), ("type", 350)):
                    mutated = copy.deepcopy(new_rows[event])
                    _set_leaf(mutated, path, value)
                    check(bool(source_observation_errors(after, [mutated], relative))
                          and inverse_350_payload([mutated], relative) == [mutated],
                          f"{relative}:{event}:{path} {label}")
                rollback = copy.deepcopy(new_rows[event])
                try:
                    _set_leaf(rollback, path, _leaf(old_rows[event], path))
                except KeyError:
                    _delete_leaf(rollback, path)
                check(inverse_350_payload([rollback], relative) == [rollback]
                      and bool(source_observation_errors(after, [rollback], relative)),
                      f"{relative}:{event}:{path} partial rollback/deleted ghost")
            event = CURRENT_JSON_LEAVES[relative][0][0]
            for field, value in (("title", "neighbor"), ("conditions", {"money": 1}),
                                 ("id", "wrong-id"), ("extra_key", "unapproved")):
                mutated = copy.deepcopy(new_rows[event])
                mutated[field] = value
                check(inverse_350_payload([mutated], relative) == [mutated], relative + " altered " + field)
            duplicate = [new_rows[event], copy.deepcopy(new_rows[event])]
            check(inverse_350_payload(duplicate, relative) == duplicate
                  and bool(source_observation_errors(after, duplicate, relative)), relative + " duplicate row")
            check(inverse_350_payload([], relative) == []
                  and bool(source_observation_errors(after, [], relative)), relative + " missing row")
            reordered = copy.deepcopy(new_rows[event])
            reordered = dict(reversed(list(reordered.items())))
            check(inverse_350_payload([reordered], relative) == [reordered]
                  and bool(source_observation_errors(after, [reordered], relative)),
                  relative + " in-memory event key order")
            if relative.endswith("arc_year_close.json"):
                reordered = copy.deepcopy(new_rows["arc_year3_close"])
                reordered["description_if_known"] = dict(reversed(list(reordered["description_if_known"].items())))
                check(inverse_350_payload([reordered], relative) == [reordered]
                      and bool(source_observation_errors(after, [reordered], relative)),
                      relative + " conditional priority order")
        for relative in HISTORICAL_PATHS:
            historical, current = historical_blobs(relative)
            check(current == (ROOT / relative).read_bytes()
                  and historical == inverse_current_bytes(current, relative)
                  and not source_errors(current, relative), relative + " union historical binding")
        for order, stage in TRANSITIONS.items():
            for relative in stage["leaves"]:
                before, after = _stage_blobs(order, relative)
                rejected(lambda: _verify_json_delta(order, before, after + b"\n", relative),
                         order + ":" + relative + " raw neighbor formatting")
            before, after = _stage_blobs(order, LEDGER_PATH)
            old, new = _loads(before), _loads(after)
            texts = {p: _stage_blobs(order, p) for p in stage["leaves"]
                     if not p.startswith("content/events_en/")}
            for locale in LOCALES:
                changed = [key for key in new["accepted"][locale]
                           if new["accepted"][locale][key] != old["accepted"][locale].get(key)]
                check(len(changed) == (15 if order == "350" else 4), order + ":" + locale + " receipt census")
                for key in changed:
                    for field in ("source_sha256", "target_sha256"):
                        mutant = copy.deepcopy(new)
                        mutant["accepted"][locale][key][field] = "0" * 64
                        mutant["accepted_sha256"] = _digest(mutant["accepted"])
                        rejected(lambda: _verify_receipt_delta(order, before, _canonical(mutant), texts),
                                 order + ":" + locale + ":" + key + ":" + field)
            for label, mutate in (
                ("prior batch", lambda x: x["batches"][0].update({"order": "forged"})),
                ("current batch", lambda x: x["batches"][-1].update({"native_review": "GO"})),
                ("metadata", lambda x: x.update({"full_game_status": "GO"})),
                ("neighbor receipt", lambda x: x["accepted"]["ja"].pop(next(iter(x["accepted"]["ja"])))),
            ):
                mutant = copy.deepcopy(new)
                mutate(mutant)
                mutant["accepted_sha256"] = _digest(mutant["accepted"])
                rejected(lambda: _verify_receipt_delta(order, before, _canonical(mutant), texts), order + " " + label)
    # No cross-invocation proof cache may turn these warm negatives positive.
    for relative in CURRENT_PATHS:
        after = blobs[relative][1]
        new = _loads(after)
        for label, proof in (("missing", mock.Mock(side_effect=OSError("missing immutable proof"))),
                             ("altered", lambda rev, path: _git("show", f"{rev}:{path}") + b"\n")):
            # Enter with valid original-module identities, then corrupt the
            # stage proof itself: do not let an earlier identity failure mask it.
            with fresh_validation_proof(), mock.patch(__name__ + "._git_blob", proof):
                check(bool(source_errors(after, relative))
                      and inverse_current_bytes(after, relative) == after
                      and inverse_current_payload(new, relative) == new
                      and inverse_current_hash(_sha(after), relative) == _sha(after)
                      and project_bytes(after, relative) == after
                      and project_payload(new, relative) == new
                      and project_byte_hash(_sha(after), relative) == _sha(after), relative + " warm " + label + " proof")
    for raw in (b'{"a":1,"a":2}', b'[NaN]', b'[Infinity]', b'[-Infinity]', b'[1e999]'):
        rejected(lambda: _loads(raw), "strict JSON " + raw.decode())
    for value in (float("nan"), float("inf"), float("-inf")):
        path = PATHS[0]
        check(bool(source_observation_errors(blobs[path][1], [value], path)), "nonfinite observed payload")
    scratch = Path(_git("rev-parse", "--absolute-git-dir").decode().strip()) / "full-game-localization"
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="order358-mixed-", dir=scratch) as directory:
        root = Path(directory)
        for relative in LIVE_PATHS:
            target = root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes((ROOT / relative).read_bytes())
        check(not current_source_errors(root), "copied exact live38 root")
        for relative, (before, after) in blobs.items():
            (root / relative).write_bytes(before)
            check(bool(current_source_errors(root)), "mixed prior/latest " + relative)
            (root / relative).write_bytes(after)
        for relative, (before, _) in blobs.items():
            (root / relative).write_bytes(before)
        check(bool(current_source_errors(root)), "whole pre350 rollback")
        for relative in CURRENT_PATHS:
            (root / relative).write_bytes(_git_blob(TRANSITIONS["350"]["after"], relative))
        check(bool(current_source_errors(root)), "intermediate350 rollback")
    real_git = _git
    for label, command, reply in (("parent", "rev-parse", b"0" * 40 + b"\n"),
                                   ("population", "diff", b"")):
        def changed_git(*args):
            return reply if args[0] == command else real_git(*args)
        with mock.patch(__name__ + "._git", changed_git):
            check(bool(current_source_errors()), "wrong immutable " + label)
    check(_ACTIVE_PROOF.get() is None, "no leaked proof before scope test")
    with fresh_validation_proof():
        first = _ACTIVE_PROOF.get()
        check(len(first) == 56, "all 28 immutable file pairs present")
        with fresh_validation_proof():
            check(_ACTIVE_PROOF.get() is first, "nested same invocation snapshot")
    check(_ACTIVE_PROOF.get() is None, "normal scope exit cleanup")
    with fresh_validation_proof():
        check(_ACTIVE_PROOF.get() is not first, "fresh next invocation")
    try:
        with fresh_validation_proof():
            raise RuntimeError("intentional cleanup test")
    except RuntimeError:
        pass
    check(_ACTIVE_PROOF.get() is None, "exception cleanup")
    with mock.patch(__name__ + "._git", side_effect=OSError("Git unavailable")):
        check(bool(current_source_errors()), "proof unavailable before context entry")
    check(_ACTIVE_PROOF.get() is None, "failed entry cleanup")
    return failures, cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--self-test", action="store_true")
    mode.add_argument("--historical-self-test", action="store_true")
    args = parser.parse_args()
    errors, cases = current_source_errors(), 0
    if args.self_test and not errors:
        failures, cases = self_test()
        errors.extend(failures)
    if args.historical_self_test and not errors:
        failures, cases, results = historical_self_test()
        errors.extend(failures)
        for result in results:
            print("ORDER350_ORIGINAL_CORPUS " + json.dumps(result, ensure_ascii=False, sort_keys=True))
    for error in errors:
        print("ORDER350_SOURCE_ERROR " + error)
    marker = "ORDER350_HISTORICAL" if args.historical_self_test else "ORDER350_SOURCE"
    print(f"{marker}_{'FAIL' if errors else 'OK'} current_files=21 leaves=106 receipts=57 "
          f"new_receipts=3 historical_files=9 historical_leaves=49 live_files={len(LIVE_PATHS)} "
          f"historical_union={len(HISTORICAL_PATHS)} units=350,359 cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())

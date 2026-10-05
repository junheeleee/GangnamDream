#!/usr/bin/env python3
"""Exact, fresh source admission for the ORDER-149 opening rhythm repair."""

from __future__ import annotations

import hashlib
from pathlib import Path
import re
import subprocess


OPENING_PATH = "scenes/OpeningCinematic.gd"
BEFORE_COMMIT = "5bf7a8ebf53cf00c44b96a9741b42edaa79c079b"
AFTER_COMMIT = "0afd81c8f702c1b792970f85cd864b6312774fa4"
TREES = ("2e56b1ddfdf1e1ca4c8c841f37fabae5a69a213f", "7e47f76baf5f1361b8fa5f8dfa594982b7859026")
BLOBS = ("3b066d6263870dc083247cd56729f91cb70c7387", "5d4ce7606aed23aed0819c622f67732c154ef325")
HASHES = ("bc78ee5de4af3cbb661db3b116edd653fc57817d1235fec3042ac4d3df8be0ef",
          "cee056e40352561670079ca6a9469b751f745de332e3b6c31aa0a85e024ddf77")
REPLACEMENTS = (
    ('\t\t"ambience": "street",\n\t\t"hold": 3.10,\n',
     '\t\t"ambience": "street",\n\t\t"fade": 0.44,\n\t\t"hold": 2.80,\n'),
    ('\t\t"ambience": "room",\n\t\t"hold": 3.10,\n',
     '\t\t"ambience": "room",\n\t\t"fade": 0.76,\n\t\t"hold": 3.50,\n'),
    ('\t\t"ambience": "street",\n\t\t"hold": 3.00,\n',
     '\t\t"ambience": "street",\n\t\t"fade": 0.36,\n\t\t"hold": 2.90,\n'),
    ('\tvar beat: Dictionary = BEATS[index]\n',
     '\tvar beat: Dictionary = BEATS[index]\n\tvar fade_seconds := _beat_fade_seconds(beat)\n'),
    ('\ttween.tween_property(next_image, "modulate:a", 1.0, FADE_SECONDS)\n',
     '\ttween.tween_property(next_image, "modulate:a", 1.0, fade_seconds)\n'),
    ('\ttween.tween_property(_title_label, "modulate:a", 1.0, FADE_SECONDS * 0.85)\n',
     '\ttween.tween_property(_title_label, "modulate:a", 1.0, fade_seconds * 0.85)\n'),
    ('\ttween.tween_property(_body_label, "modulate:a", 1.0, FADE_SECONDS)\n',
     '\ttween.tween_property(_body_label, "modulate:a", 1.0, fade_seconds)\n'),
    ('\ttween.tween_property(_beat_rule, "modulate:a", 1.0, FADE_SECONDS * 0.75)\n',
     '\ttween.tween_property(_beat_rule, "modulate:a", 1.0, fade_seconds * 0.75)\n'),
    ('\t\t\tnext_image, "scale", Vector2.ONE, float(beat["hold"]) + FADE_SECONDS)\n',
     '\t\t\tnext_image, "scale", Vector2.ONE, float(beat["hold"]) + fade_seconds)\n'),
    ('\t\ttween.tween_property(old_image, "modulate:a", 0.0, FADE_SECONDS)\n',
     '\t\ttween.tween_property(old_image, "modulate:a", 0.0, fade_seconds)\n'),
    ('func _localized(beat: Dictionary, field: String) -> String:\n',
     'func _beat_fade_seconds(beat: Dictionary) -> float:\n'
     '\treturn float(beat.get("fade", FADE_SECONDS))\n\n'
     'func _localized(beat: Dictionary, field: String) -> String:\n'),
)


def _git(root, *args, input=None):
    """Read-only seam; callers validate every returned object or predicate."""
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    if result.returncode:
        raise ValueError("ORDER-463: immutable Git proof unavailable")
    return result.stdout


def _current_binding(root: Path) -> tuple[str, str, str]:
    """Observe actual HEAD, its tree and the actual Opening blob, without projection."""
    values = tuple(_git(root, "rev-parse", "--verify", expression).decode().strip()
                   for expression in ("HEAD^{commit}", "HEAD^{tree}", "HEAD:" + OPENING_PATH))
    if any(re.fullmatch(r"[0-9a-f]{40}", value) is None for value in values):
        raise ValueError("ORDER-463: current Git identities malformed")
    return values


def opening_rhythm_inverse(current: bytes, before: bytes) -> bytes:
    """Reverse only the reviewed timing edits, then compare the entire old file."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(REPLACEMENTS, tuple) or len(REPLACEMENTS) != 11
            or any(not isinstance(pair, tuple) or len(pair) != 2
                   or any(not isinstance(part, str) for part in pair) for pair in REPLACEMENTS)):
        raise ValueError("ORDER-463: inverse population/type differs")
    recovered = current
    for old_text, new_text in REPLACEMENTS:
        old, new = old_text.encode("utf-8"), new_text.encode("utf-8")
        if (not old or not new or old == new or before.count(old) != 1
                or before.count(new) != 0 or recovered.count(new) != 1):
            raise ValueError("ORDER-463: timing inverse is not exact one-per-edit")
        recovered = recovered.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-463: change outside exact opening rhythm repair")
    return recovered


def opening_rhythm_predecessor(current: bytes, root: Path | None = None) -> bytes:
    """Fresh six-request typed proof; returned old bytes are comparison-only."""
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    identities = (BEFORE_COMMIT, AFTER_COMMIT, *TREES, *BLOBS)
    if (any(not isinstance(value, str) or re.fullmatch(r"[0-9a-f]{40}", value) is None
            for value in identities)
            or any(not isinstance(value, str) or re.fullmatch(r"[0-9a-f]{64}", value) is None
                   for value in HASHES)):
        raise ValueError("ORDER-463: actual product pins pending or malformed")
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != HASHES[1]:
        raise ValueError("ORDER-463: unapproved current Opening raw")
    binding = _current_binding(root)
    if binding[2] != BLOBS[1] or (root / OPENING_PATH).read_bytes() != current:
        raise ValueError("ORDER-463: current raw/HEAD blob binding differs")
    requests = [(commit, commit, "commit") for commit in (BEFORE_COMMIT, AFTER_COMMIT)]
    requests += [(tree, tree, "tree") for tree in TREES]
    requests += [(commit + ":" + OPENING_PATH, blob, "blob")
                 for commit, blob in zip((BEFORE_COMMIT, AFTER_COMMIT), BLOBS)]
    packet = _git(root, "cat-file", "--batch",
                  input=("\n".join(row[0] for row in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = packet.index(b"\n", cursor)
        oid, actual_kind, size_text = packet[cursor:end].decode().split()
        if not size_text.isdecimal():
            raise ValueError("ORDER-463: invalid immutable object size")
        size = int(size_text)
        raw = packet[end + 1:end + 1 + size]
        if (oid != wanted or actual_kind != kind or len(raw) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + raw).hexdigest() != oid
                or packet[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-463: forged immutable object")
        values.append(raw)
        cursor = end + 2 + size
    if cursor != len(packet):
        raise ValueError("ORDER-463: trailing immutable proof bytes")
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        if [row for row in headers if row.startswith(b"tree ")] != [b"tree " + TREES[index].encode()]:
            raise ValueError("ORDER-463: immutable tree differs")
        if index and [row for row in headers if row.startswith(b"parent ")] != [b"parent " + BEFORE_COMMIT.encode()]:
            raise ValueError("ORDER-463: direct parent differs")
    if tuple(hashlib.sha256(raw).hexdigest() for raw in values[4:6]) != HASHES or values[5] != current:
        raise ValueError("ORDER-463: immutable whole raw differs")
    if _git(root, "diff", "--name-status", "-z", BEFORE_COMMIT, AFTER_COMMIT) != b"M\0" + OPENING_PATH.encode() + b"\0":
        raise ValueError("ORDER-463: product path population differs")
    _git(root, "merge-base", "--is-ancestor", AFTER_COMMIT, binding[0])
    previous = opening_rhythm_inverse(current, values[4])
    if (root / OPENING_PATH).read_bytes() != current or _current_binding(root) != binding:
        raise ValueError("ORDER-463: current source/HEAD/tree/blob changed during proof")
    return previous

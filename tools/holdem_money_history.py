#!/usr/bin/env python3
"""Fresh, independent proof of the one-function Holdem money display repair."""

from __future__ import annotations

import hashlib
from pathlib import Path
import subprocess


HOLDEM_PATH = "scenes/HoldemClub.gd"
BEFORE_COMMIT = "373aef46b10d3a39485b0f545618ae9da998b94b"
AFTER_COMMIT = "265119c8ff87f3c3fe8d2d3d2a1692bea5bed4b1"
TREES = ("a29429ba0ef2b6ca39a5ae086649d0169f15b01a", "d115ba581c6213c89d2a71ca644403f74cd3bf8b")
BLOBS = ("a8d8ba57ac3a0566234eaa90d2ff6c09ee4e2f49", "e0721b114ff0546d6b45ecdea429e5134016a074")
HASHES = ("62981d4f2a45b20e068da7462e3452c432e6c009a9c02a16719de4cb84312d90",
          "247701a481721d1ec02672a83086ea8bc48da2b4d12ca34890c795c25ba87c1f")
RETIRED_PAIRS = (("%.1f억", "₩%.1fB"), ("%d만", "₩%dK"), ("%d원", "₩%d"))
FMT_REPLACEMENT = (
    'func _fmt(amount) -> String:\n'
    '\tvar a := int(amount)\n'
    '\tif LocaleManager.is_english():\n'
    '\t\tif abs(a) >= 1_000_000_000:\n'
    '\t\t\treturn "₩%.1fB" % (float(a) / 1_000_000_000.0)\n'
    '\t\tif abs(a) >= 1_000_000:\n'
    '\t\t\treturn "₩%.1fM" % (float(a) / 1_000_000.0)\n'
    '\t\tif abs(a) >= 1_000:\n'
    '\t\t\treturn "₩%dK" % int(a / 1_000)\n'
    '\t\treturn "₩%d" % a\n'
    '\tif abs(a) >= 100_000_000: return _tr("%.1f억", "₩%.1fB") % (float(a) / 100_000_000.0)\n'
    '\tif abs(a) >= 10_000:      return _tr("%d만", "₩%dK") % (a / 10_000)\n'
    '\treturn _tr("%d원", "₩%d") % a\n',
    'func _fmt(amount) -> String:\n\treturn LocaleManager.format_whole_won(int(amount))\n',
)


def _git(root, *args, input=None):
    """Read-only Git seam; every caller checks the returned object or predicate."""
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    if result.returncode:
        raise ValueError("ORDER-434: immutable Git proof unavailable")
    return result.stdout


def holdem_money_inverse(current: bytes, before: bytes) -> bytes:
    """Prove the complete local inverse independently of raw hash admission."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(FMT_REPLACEMENT, tuple) or len(FMT_REPLACEMENT) != 2
            or any(not isinstance(part, str) for part in FMT_REPLACEMENT)):
        raise ValueError("ORDER-434: inverse population/type differs")
    old, new = (part.encode("utf-8") for part in FMT_REPLACEMENT)
    if (not old or old == new or before.count(old) != 1 or before.count(new) != 0
            or current.count(new) != 1):
        raise ValueError("ORDER-434: whole formatter inverse is not exact1")
    recovered = current.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-434: change outside exact whole formatter repair")
    return recovered


def holdem_money_predecessor(current: bytes, root: Path | None = None) -> bytes:
    """Fresh six-object proof; old bytes are comparison-only, never current data."""
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != HASHES[1]:
        raise ValueError("ORDER-434: unapproved current Holdem raw")
    head = _git(root, "rev-parse", "HEAD")
    if (root / HOLDEM_PATH).read_bytes() != current:
        raise ValueError("ORDER-434: current raw/read binding differs")
    requests = [(c, c, "commit") for c in (BEFORE_COMMIT, AFTER_COMMIT)]
    requests += [(t, t, "tree") for t in TREES]
    requests += [(c + ":" + HOLDEM_PATH, blob, "blob")
                 for c, blob in zip((BEFORE_COMMIT, AFTER_COMMIT), BLOBS)]
    proof = _git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = proof.index(b"\n", cursor)
        oid, actual_kind, size = proof[cursor:end].decode().split()
        size = int(size)
        value = proof[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or proof[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-434: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-434: trailing immutable proof bytes")
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + TREES[index].encode()]:
            raise ValueError("ORDER-434: immutable tree differs")
        if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + BEFORE_COMMIT.encode()]:
            raise ValueError("ORDER-434: direct parent differs")
    if tuple(hashlib.sha256(v).hexdigest() for v in values[4:6]) != HASHES:
        raise ValueError("ORDER-434: immutable whole raw differs")
    if _git(root, "diff", "--name-status", "-z", BEFORE_COMMIT, AFTER_COMMIT) != b"M\0" + HOLDEM_PATH.encode() + b"\0":
        raise ValueError("ORDER-434: product path population differs")
    _git(root, "merge-base", "--is-ancestor", AFTER_COMMIT, "HEAD")
    if _git(root, "rev-parse", "HEAD:" + HOLDEM_PATH).decode().strip() != BLOBS[1] or values[5] != current:
        raise ValueError("ORDER-434: current Git/blob binding differs")
    previous = holdem_money_inverse(current, values[4])
    if (root / HOLDEM_PATH).read_bytes() != current or _git(root, "rev-parse", "HEAD") != head:
        raise ValueError("ORDER-434: current source/HEAD changed during proof")
    return previous

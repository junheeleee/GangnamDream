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


# BEGIN_HOLDEM_CANVAS_WIDTH_HISTORY_436
# Keep the complete434 proof and its pins above. New raw admission proves both
# real transitions; neither disk reads nor HEAD responses are projected backward.
CANVAS_BEFORE_COMMIT = "dc9bc1e0506e88f942eecf53ea2269980175170b"
CANVAS_AFTER_COMMIT = "bd573a489b125f119dd1b82b318b2619b6eedb78"
CANVAS_TREES = ("303422eab50417f8b63f5ebae406bf0502247349", "eb22e3974ebdd5c22b7b73b12c056a42dbddc638")
CANVAS_BLOBS = ("e0721b114ff0546d6b45ecdea429e5134016a074", "51e882f350356e6f6ea0c2c8ba1dd439b3adc273")
CANVAS_HASHES = ("247701a481721d1ec02672a83086ea8bc48da2b4d12ca34890c795c25ba87c1f",
                 "892e70e06b2c8ba584d1b37c661308c9aec0463c4674288f21279e8fc75c6bba")
CANVAS_REPLACEMENT = (
    '\tctrl.draw_string(f, pos + Vector2(-24.0, 24.0), _fmt(amount),\n'
    '\t\tHORIZONTAL_ALIGNMENT_CENTER, 48.0, 10, Color(0.86, 0.90, 0.80, 0.78))\n',
    '\tvar text_width := maxf(48.0, f.get_string_size(_fmt(amount), HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x)\n'
    '\tctrl.draw_string(f, pos + Vector2(-text_width * 0.5, 24.0), _fmt(amount), HORIZONTAL_ALIGNMENT_CENTER, text_width, 10, Color(0.86, 0.90, 0.80, 0.78))\n',
)
_HOLDEM_CANVAS_OLD_MONEY_PREDECESSOR = holdem_money_predecessor


def holdem_canvas_inverse(current: bytes, before: bytes) -> bytes:
    """Undo only the two-for-two-line centered-width repair, without hash gates."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(CANVAS_REPLACEMENT, tuple) or len(CANVAS_REPLACEMENT) != 2
            or any(not isinstance(part, str) for part in CANVAS_REPLACEMENT)):
        raise ValueError("ORDER-436: inverse population/type differs")
    old, new = (part.encode("utf-8") for part in CANVAS_REPLACEMENT)
    if (old == new or old.count(b"\n") != 2 or new.count(b"\n") != 2
            or before.count(old) != 1 or before.count(new) != 0 or current.count(new) != 1):
        raise ValueError("ORDER-436: canvas inverse is not exact two-for-two lines")
    recovered = current.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-436: change outside exact canvas width repair")
    return recovered


def _holdem_canvas_proof(current: bytes, root: Path | None = None) -> tuple[bytes, bytes]:
    """Fresh twelve-object proof, returning434 and pre434 comparison bytes."""
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != CANVAS_HASHES[1]:
        raise ValueError("ORDER-436: unapproved current Holdem raw")
    head = _git(root, "rev-parse", "HEAD")
    if (root / HOLDEM_PATH).read_bytes() != current:
        raise ValueError("ORDER-436: current raw/read binding differs")
    stages = ((BEFORE_COMMIT, AFTER_COMMIT, TREES, BLOBS, HASHES),
              (CANVAS_BEFORE_COMMIT, CANVAS_AFTER_COMMIT, CANVAS_TREES, CANVAS_BLOBS, CANVAS_HASHES))
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + HOLDEM_PATH, blob, "blob") for c, blob in zip((before, after), blobs))
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
            raise ValueError("ORDER-436: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-436: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-436: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-436: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-436: immutable whole raw differs")
        if _git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + HOLDEM_PATH.encode() + b"\0":
            raise ValueError("ORDER-436: product path population differs")
        if stage:
            _git(root, "merge-base", "--is-ancestor", AFTER_COMMIT, CANVAS_BEFORE_COMMIT)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-436: nonconsecutive Holdem raw history")
    _git(root, "merge-base", "--is-ancestor", CANVAS_AFTER_COMMIT, "HEAD")
    if _git(root, "rev-parse", "HEAD:" + HOLDEM_PATH).decode().strip() != CANVAS_BLOBS[1] or values[11] != current:
        raise ValueError("ORDER-436: current Git/blob binding differs")
    canonical = holdem_canvas_inverse(current, values[10])
    previous = holdem_money_inverse(canonical, values[4])
    if (root / HOLDEM_PATH).read_bytes() != current or _git(root, "rev-parse", "HEAD") != head:
        raise ValueError("ORDER-436: current source/HEAD changed during proof")
    return canonical, previous


def holdem_canvas_predecessor(current: bytes, root: Path | None = None) -> bytes:
    return _holdem_canvas_proof(current, root)[0]


def holdem_money_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == HASHES[1]:
        # Historical434 is not a grant on a436 checkout: its original actual
        # disk and HEAD guards still reject stale caller-supplied bytes.
        return _HOLDEM_CANVAS_OLD_MONEY_PREDECESSOR(current, root)
    return _holdem_canvas_proof(current, root)[1]
# END_HOLDEM_CANVAS_WIDTH_HISTORY_436


# BEGIN_HOLDEM_BETTING_TURN_HISTORY_437
# Preserve both earlier proofs verbatim. This third transition changes only
# gameplay; every existing UI call retains its complete source coordinates.
BETTING_BEFORE_COMMIT = "8b47d6d6dfcffec9ade6fc5619a4358b9cc69462"
BETTING_AFTER_COMMIT = "f42861efaaa2f8a219bb7883925766e4ee0e9ce0"
BETTING_TREES = ("2466bdc7af2f14447597250de8aa21c80e259130", "3848689148de0e84d967904e8bafb78c69cf2b55")
BETTING_BLOBS = ("51e882f350356e6f6ea0c2c8ba1dd439b3adc273", "ae11e6b873bd621649803637f43d79bc7e89b1d4")
BETTING_HASHES = ("892e70e06b2c8ba584d1b37c661308c9aec0463c4674288f21279e8fc75c6bba",
                  "4a8ae2c046e59ab4c2425bbb2270a552c73fbc76398c75079d45179f8748114f")
BETTING_REPLACEMENTS = (
    ('var _pad_action_signature: String = ""\n\n# 핸드 히스토리',
     'var _pad_action_signature: String = ""\nvar _round_pending: Array[int] = []  # 블라인드는 행동이 아니며 매 라운드 응답을 기다린다.\n# 핸드 히스토리'),
    ('\t_pad_action_signature = ""\n\n\t# 포스트 블라인드 (플레이어=SB, opp0=BB)\n\t_post_blind(0, SMALL_BLIND, true)   # 플레이어 SB\n\t_post_blind(1, BIG_BLIND, false)    # opp0 BB\n',
     '\t_pad_action_signature = ""\n\t_reset_round_actions()\n\t# 포스트 블라인드 (플레이어=SB, opp1=BB)\n\t_post_blind(0, SMALL_BLIND, true)   # 플레이어 SB\n\t_post_blind(1, BIG_BLIND, false)    # opp1 BB\n'),
    ('\tif _player_folded:\n\t\treturn false\n\tif _turn_order.is_empty():',
     '\tif _player_folded or _player_stack <= 0:\n\t\treturn false\n\tif _turn_order.is_empty():'),
    ('\t# 차례 찾기 (folded 건너뜀)\n\twhile true:\n\t\t_action_idx = _action_idx % 3\n\t\tvar who: int = _turn_order[_action_idx]\n\t\tif (who == 0 and _player_folded) or (who != 0 and _opp[who - 1]["folded"]):\n',
     '\t# 차례 찾기 (folded·all-in 건너뜀)\n\twhile true:\n\t\t_action_idx = _action_idx % 3\n\t\tvar who: int = _turn_order[_action_idx]\n\t\tif not _seat_can_bet(who):\n'),
    ('\t# 액티브 플레이어 모두 max_bet에 맞췄거나 all-in인지 확인\n',
     '\tif not _round_actions_complete(): return false\n'),
    ('\t\tch.queue_free()\n\n\tvar to_call: int = _max_bet - _player_bet\n',
     '\t\tch.queue_free()\n\tvar previous_max := _max_bet\n\tvar to_call: int = _max_bet - _player_bet\n'),
    ('\t\t\t_shake_node(_content_root, 4.0, 0.16)\n\n\t_action_idx += 1\n',
     '\t\t\t_shake_node(_content_root, 4.0, 0.16)\n\t_record_round_action(0, _max_bet > previous_max)\n\t_action_idx += 1\n'),
    ('\t\t\tfloat(o["aggression"]), _rng)\n\n\t_set_msg',
     '\t\t\tfloat(o["aggression"]), _rng)\n\tvar previous_max := _max_bet\n\t_set_msg'),
    ('\t\t\t_screen_flash(Color("#f0b429"), 0.08, 0.16)\n\n\t_action_idx += 1\n',
     '\t\t\t_screen_flash(Color("#f0b429"), 0.08, 0.16)\n\t_record_round_action(opp_idx + 1, _max_bet > previous_max)\n\t_action_idx += 1\n'),
    ('\tvar banner := ""\n\n\tmatch _phase:\n',
     '\tvar banner := ""\n\t_reset_round_actions()\n\tmatch _phase:\n'),
)
BETTING_APPENDIX = (
    '\nfunc _seat_can_bet(who: int) -> bool:\n'
    '\tif who == 0:\n'
    '\t\treturn not _player_folded and _player_stack > 0\n'
    '\treturn not _opp[who - 1]["folded"] and int(_opp[who - 1]["stack"]) > 0\n'
    '\nfunc _reset_round_actions() -> void:\n'
    '\t_round_pending.assign([0, 1, 2])\n'
    '\nfunc _record_round_action(who: int, raised_max: bool) -> void:\n'
    '\tif raised_max:\n'
    '\t\t_reset_round_actions()\n'
    '\t_round_pending.erase(who)\n'
    '\nfunc _round_actions_complete() -> bool:\n'
    '\tvar actionable: Array[int] = []\n'
    '\tfor who in range(3):\n'
    '\t\tif _seat_can_bet(who):\n'
    '\t\t\tactionable.append(who)\n'
    '\t# 응답할 상대 잔액이 없으면 추가 베팅하지 않는다. 미납 콜은 기존 금액 검사에서 기다린다.\n'
    '\tif actionable.size() <= 1:\n'
    '\t\treturn true\n'
    '\tfor who in actionable:\n'
    '\t\tif _round_pending.has(who):\n'
    '\t\t\treturn false\n'
    '\treturn true\n'
)
_HOLDEM_BETTING_OLD_CANVAS_PREDECESSOR = holdem_canvas_predecessor
_HOLDEM_BETTING_OLD_MONEY_PREDECESSOR = holdem_money_predecessor


def holdem_betting_inverse(current: bytes, before: bytes) -> bytes:
    """Undo ten exact spans/13 line replacements and the26-line EOF helper."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(BETTING_REPLACEMENTS, tuple) or len(BETTING_REPLACEMENTS) != 10
            or any(not isinstance(pair, tuple) or len(pair) != 2
                   or any(not isinstance(value, str) for value in pair) for pair in BETTING_REPLACEMENTS)
            or not isinstance(BETTING_APPENDIX, str)):
        raise ValueError("ORDER-437: inverse population/type differs")
    suffix = BETTING_APPENDIX.encode("utf-8")
    if (suffix.count(b"\n") != 26 or not current.endswith(suffix)
            or current.count(suffix) != 1 or before.count(suffix)):
        raise ValueError("ORDER-437: exact EOF helper differs")
    recovered = current[:-len(suffix)]
    changed_lines = 0
    for old_text, new_text in reversed(BETTING_REPLACEMENTS):
        old, new = old_text.encode("utf-8"), new_text.encode("utf-8")
        if (not old or old == new or old.count(b"\n") != new.count(b"\n")
                or before.count(old) != 1 or before.count(new) != 0 or recovered.count(new) != 1):
            raise ValueError("ORDER-437: local inverse is not exact1 with preserved lines")
        changed_lines += sum(a != b for a, b in zip(old.splitlines(), new.splitlines()))
        recovered = recovered.replace(new, old, 1)
    if changed_lines != 13 or recovered != before:
        raise ValueError("ORDER-437: change outside exact betting repair")
    return recovered


def _holdem_betting_proof(current: bytes, root: Path | None = None) -> tuple[bytes, bytes, bytes]:
    """Fresh18-object/three-transition proof; return436,434,373 whole bytes."""
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != BETTING_HASHES[1]:
        raise ValueError("ORDER-437: unapproved current Holdem raw")
    head = _git(root, "rev-parse", "HEAD")
    if (root / HOLDEM_PATH).read_bytes() != current:
        raise ValueError("ORDER-437: current raw/read binding differs")
    stages = ((BEFORE_COMMIT, AFTER_COMMIT, TREES, BLOBS, HASHES),
              (CANVAS_BEFORE_COMMIT, CANVAS_AFTER_COMMIT, CANVAS_TREES, CANVAS_BLOBS, CANVAS_HASHES),
              (BETTING_BEFORE_COMMIT, BETTING_AFTER_COMMIT, BETTING_TREES, BETTING_BLOBS, BETTING_HASHES))
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + HOLDEM_PATH, blob, "blob") for c, blob in zip((before, after), blobs))
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
            raise ValueError("ORDER-437: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-437: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-437: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-437: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-437: immutable whole raw differs")
        if _git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + HOLDEM_PATH.encode() + b"\0":
            raise ValueError("ORDER-437: product path population differs")
        if stage:
            _git(root, "merge-base", "--is-ancestor", stages[stage - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-437: nonconsecutive Holdem raw history")
    _git(root, "merge-base", "--is-ancestor", BETTING_AFTER_COMMIT, "HEAD")
    if _git(root, "rev-parse", "HEAD:" + HOLDEM_PATH).decode().strip() != BETTING_BLOBS[1] or values[17] != current:
        raise ValueError("ORDER-437: current Git/blob binding differs")
    canvas = holdem_betting_inverse(current, values[16])
    money = holdem_canvas_inverse(canvas, values[10])
    previous = holdem_money_inverse(money, values[4])
    if (root / HOLDEM_PATH).read_bytes() != current or _git(root, "rev-parse", "HEAD") != head:
        raise ValueError("ORDER-437: current source/HEAD changed during proof")
    return canvas, money, previous


def holdem_betting_predecessor(current: bytes, root: Path | None = None) -> bytes:
    return _holdem_betting_proof(current, root)[0]


def holdem_canvas_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == BETTING_HASHES[1]:
        return _holdem_betting_proof(current, root)[1]
    return _HOLDEM_BETTING_OLD_CANVAS_PREDECESSOR(current, root)


def holdem_money_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == BETTING_HASHES[1]:
        return _holdem_betting_proof(current, root)[2]
    return _HOLDEM_BETTING_OLD_MONEY_PREDECESSOR(current, root)
# END_HOLDEM_BETTING_TURN_HISTORY_437


# BEGIN_HOLDEM_ASYNC_ACTION_HISTORY_438
# Earlier proof bodies/pins remain immutable. The private stage loop below
# checks the fixed current chain without projecting disk reads or Git replies.
ASYNC_BEFORE_COMMIT = "031c3c2f8639e5c03f569e6f1509aee8ad38dcda"
ASYNC_AFTER_COMMIT = "aa21f0b08a21f839194fc2147869534c8c6b4ec2"
ASYNC_TREES = ("081c1926783f2c58d22f568d7b403f89f30a7d7c", "87007677e516ac1a79a39b53dccc0cd030b42a37")
ASYNC_BLOBS = ("ae11e6b873bd621649803637f43d79bc7e89b1d4", "bf36544000f94319b32ea6b299694a9644c8ebf4")
ASYNC_HASHES = ("4a8ae2c046e59ab4c2425bbb2270a552c73fbc76398c75079d45179f8748114f",
                "35c2a7124160bfbab0e9b039aad496d2059131d83222f87eeb12ef344e5a0e5c")
ASYNC_REPLACEMENTS = (
    ('func open() -> void:\n', 'func _open_session() -> void:\n'),
    ('func _start_hand() -> void:\n', 'func _deal_next_hand() -> void:\n'),
    ('\tif _phase not in [Phase.PREFLOP, Phase.FLOP, Phase.TURN, Phase.RIVER]:\n',
     '\tif not visible or _action_busy or _phase not in [Phase.PREFLOP, Phase.FLOP, Phase.TURN, Phase.RIVER]:\n'),
    ('\t# 남은 플레이어가 1명이면 즉시 쇼다운\n', '\tif not _can_process_betting(): return\n'),
    ('func _player_action(action: String, amount: int) -> void:\n\tAudioManager.play("click")\n',
     'func _player_action(action: String, amount: int) -> void:\n\tif not _begin_player_action(): return\n'),
    ('\tawait get_tree().create_timer(0.3).timeout\n', '\tif not (await _finish_action_after(0.3)): return\n'),
    ('func _do_ai_action(opp_idx: int) -> void:\n', 'func _commit_ai_action(opp_idx: int) -> void:\n'),
    ('\tawait get_tree().create_timer(0.6).timeout\n', '\tif not (await _finish_action_after(0.6)): return\n'),
    ('\t_phase = Phase.SHOWDOWN\n', '\tif not _enter_showdown_phase(): return\n'),
    ('\t_phase = Phase.RESULT\n', '\tif not _enter_result_phase(): return\n'),
    ('func _leave() -> void:\n', 'func _close_session() -> void:\n'),
)
ASYNC_APPENDIX = (
    '\n# 각 비동기 행동은 자기 세대만 이어간다. 저장 상태가 아닌 overlay 수명 상태다.\n'
    'var _action_generation: int = 0\n'
    'var _action_busy: bool = false\n'
    '\nfunc _invalidate_action_flow() -> void:\n'
    '\t_action_generation += 1\n'
    '\t_action_busy = false\n'
    '\nfunc _can_process_betting() -> bool:\n'
    '\treturn visible and not _action_busy and _phase in [Phase.PREFLOP, Phase.FLOP, Phase.TURN, Phase.RIVER]\n'
    '\nfunc open() -> void:\n'
    '\tif visible: return\n'
    '\t_invalidate_action_flow()\n'
    '\t_open_session()\n'
    '\nfunc _start_hand() -> void:\n'
    '\tif not visible or _action_busy or _phase not in [Phase.SETUP, Phase.SHOWDOWN]: return\n'
    '\t_invalidate_action_flow()\n'
    '\t_deal_next_hand()\n'
    '\nfunc _begin_player_action() -> bool:\n'
    '\tif not _is_player_action_waiting(): return false\n'
    '\t_action_busy = true\n'
    '\tAudioManager.play("click")\n'
    '\treturn true\n'
    '\nfunc _do_ai_action(opp_idx: int) -> void:\n'
    '\tif not _can_process_betting() or opp_idx < 0 or opp_idx >= _opp.size(): return\n'
    '\tif _turn_order.is_empty() or _turn_order[_action_idx % _turn_order.size()] != opp_idx + 1: return\n'
    '\tif not _seat_can_bet(opp_idx + 1): return\n'
    '\t_action_busy = true\n'
    '\t_commit_ai_action(opp_idx)\n'
    '\nfunc _finish_action_after(seconds: float) -> bool:\n'
    '\tvar generation := _action_generation\n'
    '\tawait get_tree().create_timer(seconds).timeout\n'
    '\tif generation != _action_generation or not visible or _phase not in [Phase.PREFLOP, Phase.FLOP, Phase.TURN, Phase.RIVER]: return false\n'
    '\t_action_busy = false\n'
    '\treturn true\n'
    '\nfunc _enter_showdown_phase() -> bool:\n'
    '\tif not _can_process_betting(): return false\n'
    '\t_invalidate_action_flow()\n'
    '\t_phase = Phase.SHOWDOWN\n'
    '\treturn true\n'
    '\nfunc _enter_result_phase() -> bool:\n'
    '\tif not visible or _phase == Phase.RESULT: return false\n'
    '\t_invalidate_action_flow()\n'
    '\t_phase = Phase.RESULT\n'
    '\treturn true\n'
    '\nfunc _leave() -> void:\n'
    '\tif not visible or _phase not in [Phase.SETUP, Phase.RESULT]: return\n'
    '\t_invalidate_action_flow()\n'
    '\t_close_session()\n'
)
_HOLDEM_ASYNC_OLD_BETTING_PREDECESSOR = holdem_betting_predecessor
_HOLDEM_ASYNC_OLD_CANVAS_PREDECESSOR = holdem_canvas_predecessor
_HOLDEM_ASYNC_OLD_MONEY_PREDECESSOR = holdem_money_predecessor


def holdem_async_inverse(current: bytes, before: bytes) -> bytes:
    """Undo only the eleven exact line edits and the58-line ownership helper."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(ASYNC_REPLACEMENTS, tuple) or len(ASYNC_REPLACEMENTS) != 11
            or any(not isinstance(pair, tuple) or len(pair) != 2
                   or any(not isinstance(value, str) for value in pair) for pair in ASYNC_REPLACEMENTS)
            or not isinstance(ASYNC_APPENDIX, str)):
        raise ValueError("ORDER-438: inverse population/type differs")
    suffix = ASYNC_APPENDIX.encode("utf-8")
    if (suffix.count(b"\n") != 58 or not current.endswith(suffix)
            or current.count(suffix) != 1 or before.count(suffix)):
        raise ValueError("ORDER-438: exact EOF helper differs")
    recovered = current[:-len(suffix)]
    changed_lines = 0
    for old_text, new_text in reversed(ASYNC_REPLACEMENTS):
        old, new = old_text.encode("utf-8"), new_text.encode("utf-8")
        if (not old or old == new or old.count(b"\n") != new.count(b"\n")
                or before.count(old) != 1 or before.count(new) != 0 or recovered.count(new) != 1):
            raise ValueError("ORDER-438: local inverse is not exact1 with preserved lines")
        changed_lines += sum(a != b for a, b in zip(old.splitlines(), new.splitlines()))
        recovered = recovered.replace(new, old, 1)
    if changed_lines != 11 or recovered != before:
        raise ValueError("ORDER-438: change outside exact async repair")
    return recovered


def _holdem_exact_stage_chain(current, root, stages):
    """Private same-path loop; pinned callers supply descriptors, never input data."""
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if (not isinstance(stages, tuple) or not stages
            or any(not isinstance(stage, tuple) or len(stage) != 6 for stage in stages)):
        raise ValueError("ORDER-438: immutable stage population differs")
    for before, after, trees, blobs, hashes, inverse in stages:
        if (not all(isinstance(v, str) and len(v) == 40 for v in (before, after))
                or any(not isinstance(pair, tuple) or len(pair) != 2 for pair in (trees, blobs, hashes))
                or not all(isinstance(v, str) and len(v) == width
                           for pair, width in ((trees, 40), (blobs, 40), (hashes, 64)) for v in pair)
                or not callable(inverse)):
            raise ValueError("ORDER-438: immutable descriptor differs")
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != stages[-1][4][1]:
        raise ValueError("ORDER-438: unapproved current Holdem raw")
    head = _git(root, "rev-parse", "HEAD")
    if (root / HOLDEM_PATH).read_bytes() != current:
        raise ValueError("ORDER-438: current raw/read binding differs")
    requests = []
    for before, after, trees, blobs, _hashes, _inverse in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + HOLDEM_PATH, blob, "blob") for c, blob in zip((before, after), blobs))
    if len(requests) != 6 * len(stages):
        raise ValueError("ORDER-438: immutable object population differs")
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
            raise ValueError("ORDER-438: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-438: trailing immutable proof bytes")
    for index, (before, after, trees, _blobs, hashes, _inverse) in enumerate(stages):
        offset = index * 6
        for side in range(2):
            headers = values[offset + side].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[side].encode()]:
                raise ValueError("ORDER-438: immutable tree differs")
            if side and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-438: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-438: immutable whole raw differs")
        if _git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + HOLDEM_PATH.encode() + b"\0":
            raise ValueError("ORDER-438: product path population differs")
        if index:
            _git(root, "merge-base", "--is-ancestor", stages[index - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-438: nonconsecutive Holdem raw history")
    _git(root, "merge-base", "--is-ancestor", stages[-1][1], "HEAD")
    if _git(root, "rev-parse", "HEAD:" + HOLDEM_PATH).decode().strip() != stages[-1][3][1] or values[-1] != current:
        raise ValueError("ORDER-438: current Git/blob binding differs")
    predecessors, recovered = [], current
    for index in range(len(stages) - 1, -1, -1):
        before = values[index * 6 + 4]
        recovered = stages[index][5](recovered, before)
        if not isinstance(recovered, bytes) or recovered != before:
            raise ValueError("ORDER-438: stage inverse differs from actual Git before")
        predecessors.append(recovered)
    if (root / HOLDEM_PATH).read_bytes() != current or _git(root, "rev-parse", "HEAD") != head:
        raise ValueError("ORDER-438: current source/HEAD changed during proof")
    return tuple(predecessors)


def _holdem_async_proof(current: bytes, root: Path | None = None) -> tuple[bytes, bytes, bytes, bytes]:
    """Fixed four transitions/24 objects per call; return437,436,434,373."""
    stages = (
        (BEFORE_COMMIT, AFTER_COMMIT, TREES, BLOBS, HASHES, holdem_money_inverse),
        (CANVAS_BEFORE_COMMIT, CANVAS_AFTER_COMMIT, CANVAS_TREES, CANVAS_BLOBS, CANVAS_HASHES, holdem_canvas_inverse),
        (BETTING_BEFORE_COMMIT, BETTING_AFTER_COMMIT, BETTING_TREES, BETTING_BLOBS, BETTING_HASHES, holdem_betting_inverse),
        (ASYNC_BEFORE_COMMIT, ASYNC_AFTER_COMMIT, ASYNC_TREES, ASYNC_BLOBS, ASYNC_HASHES, holdem_async_inverse),
    )
    if len(stages) != 4:
        raise ValueError("ORDER-438: fixed four-transition population differs")
    return _holdem_exact_stage_chain(current, root, stages)


def holdem_async_predecessor(current: bytes, root: Path | None = None) -> bytes:
    return _holdem_async_proof(current, root)[0]


def holdem_betting_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == ASYNC_HASHES[1]:
        return _holdem_async_proof(current, root)[1]
    return _HOLDEM_ASYNC_OLD_BETTING_PREDECESSOR(current, root)


def holdem_canvas_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == ASYNC_HASHES[1]:
        return _holdem_async_proof(current, root)[2]
    return _HOLDEM_ASYNC_OLD_CANVAS_PREDECESSOR(current, root)


def holdem_money_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == ASYNC_HASHES[1]:
        return _holdem_async_proof(current, root)[3]
    return _HOLDEM_ASYNC_OLD_MONEY_PREDECESSOR(current, root)
# END_HOLDEM_ASYNC_ACTION_HISTORY_438


# BEGIN_HOLDEM_CARD_COLOR_HISTORY_441
# Preserve every prior proof and pin. Only the one card-face ink line is new.
CARD_COLOR_BEFORE_COMMIT = "fe418e336e7296962686949536711a2e6230bd71"
CARD_COLOR_AFTER_COMMIT = "99aee1b0dc7db01edd2efe33349bc5570847c011"
CARD_COLOR_TREES = ("e030d0d5ef3c836dcfc426519cdb97fde77954eb", "2c8b3b8691e9cd53e92aaf340e86f6be234413b8")
CARD_COLOR_BLOBS = ("bf36544000f94319b32ea6b299694a9644c8ebf4", "1485a4e883457e45ae7dd9f2b9d0905265dc5dd0")
CARD_COLOR_HASHES = ("35c2a7124160bfbab0e9b039aad496d2059131d83222f87eeb12ef344e5a0e5c",
                     "5529f970bd5f9a494d048ebc10a3440dffdc388e93f25777d6e4d5c5b70c9bdb")
CARD_COLOR_REPLACEMENT = (
    '\tlbl.add_theme_color_override("font_color", Color(TH.card_color(card)))\n',
    '\tlbl.add_theme_color_override("font_color", Color("#b4232c") if int(card["suit"]) in [1, 2] else Color("#141827"))\n',
)
_HOLDEM_CARD_COLOR_OLD_ASYNC_PREDECESSOR = holdem_async_predecessor
_HOLDEM_CARD_COLOR_OLD_BETTING_PREDECESSOR = holdem_betting_predecessor
_HOLDEM_CARD_COLOR_OLD_CANVAS_PREDECESSOR = holdem_canvas_predecessor
_HOLDEM_CARD_COLOR_OLD_MONEY_PREDECESSOR = holdem_money_predecessor


def holdem_card_color_inverse(current: bytes, before: bytes) -> bytes:
    """Recover the entire predecessor by undoing exactly one complete line."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(CARD_COLOR_REPLACEMENT, tuple) or len(CARD_COLOR_REPLACEMENT) != 2
            or any(not isinstance(part, str) for part in CARD_COLOR_REPLACEMENT)):
        raise ValueError("ORDER-441: inverse population/type differs")
    old, new = (part.encode("utf-8") for part in CARD_COLOR_REPLACEMENT)
    if (not old or old == new or old.count(b"\n") != 1 or new.count(b"\n") != 1
            or not old.endswith(b"\n") or not new.endswith(b"\n")
            or before.count(old) != 1 or before.count(new) != 0
            or current.count(new) != 1 or current.count(old) != 0):
        raise ValueError("ORDER-441: card-face line inverse is not exact1")
    recovered = current.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-441: change outside exact card-face ink repair")
    return recovered


def _holdem_card_color_proof(
    current: bytes, root: Path | None = None,
) -> tuple[bytes, bytes, bytes, bytes, bytes]:
    """Fixed five transitions/30 objects; return438,437,436,434,373."""
    stages = (
        (BEFORE_COMMIT, AFTER_COMMIT, TREES, BLOBS, HASHES, holdem_money_inverse),
        (CANVAS_BEFORE_COMMIT, CANVAS_AFTER_COMMIT, CANVAS_TREES, CANVAS_BLOBS, CANVAS_HASHES, holdem_canvas_inverse),
        (BETTING_BEFORE_COMMIT, BETTING_AFTER_COMMIT, BETTING_TREES, BETTING_BLOBS, BETTING_HASHES, holdem_betting_inverse),
        (ASYNC_BEFORE_COMMIT, ASYNC_AFTER_COMMIT, ASYNC_TREES, ASYNC_BLOBS, ASYNC_HASHES, holdem_async_inverse),
        (CARD_COLOR_BEFORE_COMMIT, CARD_COLOR_AFTER_COMMIT, CARD_COLOR_TREES, CARD_COLOR_BLOBS, CARD_COLOR_HASHES, holdem_card_color_inverse),
    )
    if len(stages) != 5:
        raise ValueError("ORDER-441: fixed five-transition population differs")
    return _holdem_exact_stage_chain(current, root, stages)


def holdem_card_color_predecessor(current: bytes, root: Path | None = None) -> bytes:
    return _holdem_card_color_proof(current, root)[0]


def holdem_async_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == CARD_COLOR_HASHES[1]:
        return _holdem_card_color_proof(current, root)[1]
    return _HOLDEM_CARD_COLOR_OLD_ASYNC_PREDECESSOR(current, root)


def holdem_betting_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == CARD_COLOR_HASHES[1]:
        return _holdem_card_color_proof(current, root)[2]
    return _HOLDEM_CARD_COLOR_OLD_BETTING_PREDECESSOR(current, root)


def holdem_canvas_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == CARD_COLOR_HASHES[1]:
        return _holdem_card_color_proof(current, root)[3]
    return _HOLDEM_CARD_COLOR_OLD_CANVAS_PREDECESSOR(current, root)


def holdem_money_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == CARD_COLOR_HASHES[1]:
        return _holdem_card_color_proof(current, root)[4]
    return _HOLDEM_CARD_COLOR_OLD_MONEY_PREDECESSOR(current, root)
# END_HOLDEM_CARD_COLOR_HISTORY_441


# BEGIN_HOLDEM_MESSAGE_PULSE_HISTORY_443
# Keep all earlier proofs/pins intact. Only the two full-width label pulses
# are replaced; every literal, line coordinate and other visual cue survives.
MESSAGE_PULSE_BEFORE_COMMIT = "251f5d98af29b7e2864864ca28a28eacaf17a9e2"
MESSAGE_PULSE_AFTER_COMMIT = "9dc812d11e54cd34ed45376513753d0cda8b12fa"
MESSAGE_PULSE_TREES = ("cbdf176f8c41b13db861205beb330400652f616f", "2a7669b34c72b8ef614d1aa3e878a7b133247885")
MESSAGE_PULSE_BLOBS = ("1485a4e883457e45ae7dd9f2b9d0905265dc5dd0", "6b1e43f4547be5aa8f2aae54b3f730c40f7d437c")
MESSAGE_PULSE_HASHES = ("5529f970bd5f9a494d048ebc10a3440dffdc388e93f25777d6e4d5c5b70c9bdb",
                        "cfc4987793e22738d8d7474f8cb821c072276e6d8c9390cf05ff5f1ef2a68ee4")
MESSAGE_PULSE_REPLACEMENTS = (
    ('\t\t\t_pulse_node(_msg_lbl, 1.04, 0.18)\n',
     '\t\t\t# Keep full-width action text inside the clipping viewport.\n'),
    ('\t_pulse_node(_msg_lbl, 1.08, 0.30)\n',
     '\t# Keep full-width showdown text inside the clipping viewport.\n'),
)
_HOLDEM_MESSAGE_PULSE_OLD_CARD_COLOR_PREDECESSOR = holdem_card_color_predecessor
_HOLDEM_MESSAGE_PULSE_OLD_ASYNC_PREDECESSOR = holdem_async_predecessor
_HOLDEM_MESSAGE_PULSE_OLD_BETTING_PREDECESSOR = holdem_betting_predecessor
_HOLDEM_MESSAGE_PULSE_OLD_CANVAS_PREDECESSOR = holdem_canvas_predecessor
_HOLDEM_MESSAGE_PULSE_OLD_MONEY_PREDECESSOR = holdem_money_predecessor


def holdem_message_pulse_inverse(current: bytes, before: bytes) -> bytes:
    """Recover the whole predecessor by undoing exactly two complete lines."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(MESSAGE_PULSE_REPLACEMENTS, tuple) or len(MESSAGE_PULSE_REPLACEMENTS) != 2
            or any(not isinstance(pair, tuple) or len(pair) != 2
                   or any(not isinstance(part, str) for part in pair) for pair in MESSAGE_PULSE_REPLACEMENTS)):
        raise ValueError("ORDER-443: inverse population/type differs")
    recovered = current
    for pair in reversed(MESSAGE_PULSE_REPLACEMENTS):
        old, new = (part.encode("utf-8") for part in pair)
        if (not old or old == new or old.count(b"\n") != 1 or new.count(b"\n") != 1
                or not old.endswith(b"\n") or not new.endswith(b"\n")
                or before.count(old) != 1 or before.count(new) != 0
                or recovered.count(new) != 1 or recovered.count(old) != 0):
            raise ValueError("ORDER-443: message-pulse line inverse is not exact1")
        recovered = recovered.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-443: change outside exact message-pulse repair")
    return recovered


def _holdem_message_pulse_proof(
    current: bytes, root: Path | None = None,
) -> tuple[bytes, bytes, bytes, bytes, bytes, bytes]:
    """Fixed six transitions/36 objects; return441,438,437,436,434,373."""
    stages = (
        (BEFORE_COMMIT, AFTER_COMMIT, TREES, BLOBS, HASHES, holdem_money_inverse),
        (CANVAS_BEFORE_COMMIT, CANVAS_AFTER_COMMIT, CANVAS_TREES, CANVAS_BLOBS, CANVAS_HASHES, holdem_canvas_inverse),
        (BETTING_BEFORE_COMMIT, BETTING_AFTER_COMMIT, BETTING_TREES, BETTING_BLOBS, BETTING_HASHES, holdem_betting_inverse),
        (ASYNC_BEFORE_COMMIT, ASYNC_AFTER_COMMIT, ASYNC_TREES, ASYNC_BLOBS, ASYNC_HASHES, holdem_async_inverse),
        (CARD_COLOR_BEFORE_COMMIT, CARD_COLOR_AFTER_COMMIT, CARD_COLOR_TREES, CARD_COLOR_BLOBS, CARD_COLOR_HASHES, holdem_card_color_inverse),
        (MESSAGE_PULSE_BEFORE_COMMIT, MESSAGE_PULSE_AFTER_COMMIT, MESSAGE_PULSE_TREES, MESSAGE_PULSE_BLOBS, MESSAGE_PULSE_HASHES, holdem_message_pulse_inverse),
    )
    if len(stages) != 6:
        raise ValueError("ORDER-443: fixed six-transition population differs")
    return _holdem_exact_stage_chain(current, root, stages)


def holdem_message_pulse_predecessor(current: bytes, root: Path | None = None) -> bytes:
    return _holdem_message_pulse_proof(current, root)[0]


def holdem_card_color_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == MESSAGE_PULSE_HASHES[1]:
        return _holdem_message_pulse_proof(current, root)[1]
    return _HOLDEM_MESSAGE_PULSE_OLD_CARD_COLOR_PREDECESSOR(current, root)


def holdem_async_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == MESSAGE_PULSE_HASHES[1]:
        return _holdem_message_pulse_proof(current, root)[2]
    return _HOLDEM_MESSAGE_PULSE_OLD_ASYNC_PREDECESSOR(current, root)


def holdem_betting_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == MESSAGE_PULSE_HASHES[1]:
        return _holdem_message_pulse_proof(current, root)[3]
    return _HOLDEM_MESSAGE_PULSE_OLD_BETTING_PREDECESSOR(current, root)


def holdem_canvas_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == MESSAGE_PULSE_HASHES[1]:
        return _holdem_message_pulse_proof(current, root)[4]
    return _HOLDEM_MESSAGE_PULSE_OLD_CANVAS_PREDECESSOR(current, root)


def holdem_money_predecessor(current: bytes, root: Path | None = None) -> bytes:
    if isinstance(current, bytes) and hashlib.sha256(current).hexdigest() == MESSAGE_PULSE_HASHES[1]:
        return _holdem_message_pulse_proof(current, root)[5]
    return _HOLDEM_MESSAGE_PULSE_OLD_MONEY_PREDECESSOR(current, root)
# END_HOLDEM_MESSAGE_PULSE_HISTORY_443

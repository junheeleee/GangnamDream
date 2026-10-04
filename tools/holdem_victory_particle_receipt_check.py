#!/usr/bin/env python3
"""One exact victory-particle source proof and one current UI inventory.

Source-bound Python formatting and captured Git faults are not engine evidence.
No previous focused suite, private artifact, official exchange or engine runs.
"""
from __future__ import annotations

import copy
import hashlib
import itertools
import re
import sys
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
import holdem_money_history as history
import ja_translation_pipeline as pipeline
import main_game_locale_history as main_history
import ui_translation_append as bridge

ROOT = Path(__file__).resolve().parents[1]
HOLD = history.HOLDEM_PATH
MAIN, SCALP, ARUBA = main_history.MAIN_GAME_PATH, bridge.SCALPING_PHASE_PATH, bridge.ARUBA_FONT_PATH
TABLE_KEYS = ("팟", "공개 카드", "보유 칩", "베팅")
KO_TEMPLATE, EN_TEMPLATE = "%s으로 승리! +%s", "Won with %s! +%s"
RANKS = (("하이카드", "High Card"), ("원페어", "One Pair"), ("투페어", "Two Pair"),
         ("트리플", "Three of a Kind"), ("스트레이트", "Straight"), ("플러시", "Flush"),
         ("풀하우스", "Full House"), ("포카드", "Four of a Kind"), ("스트레이트 플러시", "Straight Flush"))
DATA_HASHES = {
    "locale/ui_ja.json": "c056e24b20ad6e9711bce82eaaface23edc49d62d4598d397baf08ed5a7b2816",
    "locale/ui_zh-CN.json": "56aa8c8320624223159f6d0034121aef0b8699ec51788c095b96627be2b3e863",
    "locale/ui_zh-TW.json": "b589d1887d3660c9f3122e371ef5b28d06c258c23ddad18bfa6d8f5bef312ce0",
    bridge.LEDGER_PATH: "095d5e46dca4c4ddabcfde1f255565ff18f6cc913997238ca22ea812c102f53d",
}
PROTECTED_HASHES = {
    "tools/holdem_hand_net_receipt_check.py": "1734b73ac4968d9a33d7d100b686a66ae89862740849a0556c221446743249e0",
    "tools/ui_fixed_ledger_projection_check.py": "4f5e17a98eba65a1fdc30dc670cf72de712f290a9e7cc9607ba4d8e1fd887b9c",
    "tools/ui_receipt_cost_profile.py": "c27ae55ea79fa4784b5535fa021caee3c4257fc76ba6f2d842f0f1ae305ee3d1",
    "tools/ja_translation_pipeline.py": "f45887eb301871177cbd47d3c5013e4a5a68a3e578cdb1e1a3a6a42c81b621ca",
    "systems/TexasHoldem.gd": "c1ddc88718a0b9f5738ec3ba089ae29ad69158015ab1ab621c6013ad71ba92b4",
    "autoloads/LocaleManager.gd": "9417e6b9e241e1d2b9ec7a7668cf4d19fe337ce6719d87e032020fe421ceec9a",
}
CASES: list[str] = []


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def check(name, condition):
    if not condition:
        raise AssertionError(name)
    CASES.append(name)


def rejects(name, operation):
    try:
        operation()
    except (ValueError, OSError):
        pass
    else:
        raise AssertionError(name + ": unexpectedly admitted")
    CASES.append(name)


def bound(raw, expected, result, root=None):
    if root not in (None, ROOT) or raw != expected:
        raise ValueError("captured source binding differs")
    return result


def census(hashes):
    return {"source_hashes": hashes, "source_manifest_sha256": bridge.exchange.digest(hashes)}


def pure_particle_checks(raw, observed):
    """Finite source-bound formatting contract, never GDScript execution."""
    text = raw.decode()
    rank_rows = re.findall(r'^\t\t([0-8]): return LocaleManager\.ui\("([^"]+)", "([^"]+)"\)$',
                          observed["systems/TexasHoldem.gd"].decode(), re.MULTILINE)
    check("exact nine rank IDs and existing locale lookup pairs",
          rank_rows == [(str(index), ko, en) for index, (ko, en) in enumerate(RANKS)])
    check("KO predicate and exclusive helper are source-bound",
          'func is_korean() -> bool:\n\treturn language == "ko"\n' in observed["autoloads/LocaleManager.gd"].decode()
          and text.endswith(history.VICTORY_PARTICLE_APPENDIX)
          and text.count("_victory_template(") == 2
          and text.count(history.VICTORY_PARTICLE_REPLACEMENT[1]) == 1)
    check("placeholder order and hand net stay unchanged",
          KO_TEMPLATE.count("%s") == EN_TEMPLATE.count("%s") == 2
          and history.VICTORY_PARTICLE_REPLACEMENT[1].endswith(' % [TH.rank_name(best_hand[0]), _fmt(hand_net)])\n'))
    def model(template, language):
        return template.replace("%s으로", "%s로") if language == "ko" else template
    for index, (ko, _en) in enumerate(RANKS):
        final = (ord(ko[-1]) - 0xAC00) % 28
        check("pure KO rank " + str(index), final in (0, 8)
              and model(KO_TEMPLATE, "ko") % (ko, "20,000원") == ko + "로 승리! +20,000원")
    templates = {"en": EN_TEMPLATE, "community": "%s으로 custom +%s", "unknown": EN_TEMPLATE}
    for locale in ("ja", "zh-CN", "zh-TW"):
        table = bridge._loads(observed[f"locale/ui_{locale}.json"])
        templates[locale] = table[KO_TEMPLATE]
    for locale, template in templates.items():
        check("pure non-KO template identity " + locale,
              model(template, locale) is template and template.count("%s") == 2)
    check("payout hand accounting AI message and reader are preserved",
          '\t\t_player_stack += _pot\n' in text
          and text.count('\t\thand_net = _player_stack - _hand_start_stack\n') == 2
          and '\t\tmsg_parts.append(_tr("%s가 이겼습니다 (%s)", "%s wins (%s)") % [_opp_name(winner_idx), TH.rank_name(best_hand[0])])\n' in text
          and '\t_set_msg(" ".join(msg_parts))\n' in text)


def main():
    protected = tuple(dict.fromkeys((*DATA_HASHES, *PROTECTED_HASHES, HOLD, MAIN, SCALP, ARUBA,
        "scenes/TutorialOverlay.gd", "autoloads/GameState.gd", "autoloads/MetaProgression.gd",
        "tools/holdem_money_history.py", "tools/ui_translation_append.py",
        "tools/ja_translation_audit.py", "tools/zh_translation_audit.py", "tools/full_game_localization.py",
        "tools/holdem_victory_particle_receipt_check.py")))
    observed = {path: (ROOT / path).read_bytes() for path in protected}
    for path, marker, digest in (
        ("tools/holdem_money_history.py", b"\n\n# BEGIN_HOLDEM_VICTORY_PARTICLE_HISTORY_455\n",
         "99fbb936c9abcb83d7638e8d292b83ed001c6fea667027a3fa426b78b0990de3"),
        ("tools/ui_translation_append.py", b"\n\n# BEGIN_HOLDEM_VICTORY_PARTICLE_APPEND_455\n",
         "1bbdf4c1edc38ff8618ac9b783e39729bd8780bd5e526d42428e28a34124abc2"),
    ):
        check("whole frozen prefix " + path, observed[path].count(marker) == 1
              and sha(observed[path].split(marker)[0]) == digest)
    check("previous focused profiler collector rank and locale sources are sealed",
          all(sha(observed[path]) == digest for path, digest in PROTECTED_HASHES.items()))
    check("all dictionary and ledger bytes preserved",
          set(DATA_HASHES) == set(bridge.CURRENT_PATHS)
          and all(sha(observed[path]) == digest for path, digest in DATA_HASHES.items()))
    ledger = bridge._loads(observed[bridge.LEDGER_PATH])
    check("accepted41755 batches228 and canonical forward fix preserved",
          sum(map(len, ledger["accepted"].values())) == 41755 and len(ledger["batches"]) == 228
          and ledger["accepted_sha256"] == bridge.exchange.digest(ledger["accepted"])
          and ledger["batches"][-1]["receipt_sha256_by_locale"]["ja"] == "6012dda18bc67c32603dc6fcf4a4ce631fe4a2bee62d35c90ca9b06b8b977109")
    raw = observed[HOLD]
    check("actual new product pins", history.VICTORY_PARTICLE_BEFORE_COMMIT == "b768cf325099463b17a7717b084ae846c367389a"
          and history.VICTORY_PARTICLE_AFTER_COMMIT == "a8fc6a3ac1d5e444c01ec6f1ed1b33c67b4cf418"
          and history.VICTORY_PARTICLE_TREES == ("d02bdd7efb32ef031ba3f92aad723a781364084f", "abec89f88b2de6b25279af08401249f5a4a60c6b")
          and history.VICTORY_PARTICLE_BLOBS == ("5ef770fb2f05653ef4203038ed01826173e98858", "577184e702939b292343a9ebbdd4734087787ddf")
          and history.VICTORY_PARTICLE_HASHES == (history.HAND_NET_HASHES[1], "3a00cdfad92a5e86e951d7fbffac7cc34919d0dfb4b61561b926e0ee626938a8"))
    real_git, trace, responses = history._git, [], {}
    def record(root, *args, **kwargs):
        result = real_git(root, *args, **kwargs)
        key = (args, kwargs.get("input"))
        trace.append(key); responses[key] = result
        return result
    with patch.object(history, "_git", side_effect=record):
        predecessors = history._holdem_victory_particle_proof(raw, ROOT)
    previous = predecessors[0]
    prefixes = ("", "CANVAS_", "BETTING_", "ASYNC_", "CARD_COLOR_", "MESSAGE_PULSE_", "BANNER_",
                "BANNER_LOCALE_", "TABLE_LABELS_", "SEAT_HEIGHT_", "FOLDED_LOCALE_", "HAND_NET_", "VICTORY_PARTICLE_")
    stages = tuple(tuple(getattr(history, prefix + key) for key in ("BEFORE_COMMIT", "AFTER_COMMIT", "TREES", "HASHES"))
                   for prefix in prefixes)
    requests = tuple(item for before, after, trees, _hashes in stages
                     for item in (before, after, *trees, before + ":" + HOLD, after + ":" + HOLD))
    batch = ("\n".join(requests) + "\n").encode()
    chronology = (*reversed(predecessors), raw)
    check("one actual thirteen-stage 78-request proof", len(predecessors) == 13 and len(requests) == 78
          and [data for args, data in trace if args == ("cat-file", "--batch")] == [batch]
          and all((sha(chronology[i]), sha(chronology[i + 1])) == stage[3] for i, stage in enumerate(stages)))
    packet, cursor, ids = responses[(("cat-file", "--batch"), batch)], 0, []
    for _request in requests:
        end = packet.index(b"\n", cursor)
        oid, _kind, size = packet[cursor:end].split(); ids.append(oid)
        cursor = end + 2 + int(size)
    check("66 distinct OIDs including five added identities", cursor == len(packet)
          and len(set(ids)) == 66 and len(set(ids[-6:]) - set(ids[:-6])) == 5)
    check("one existing line and four EOF lines only",
          history.holdem_victory_particle_inverse(raw, previous) == previous
          and raw.count(b"\n") == previous.count(b"\n") + 4
          and [i for i, (a, b) in enumerate(zip(previous.splitlines(), raw.splitlines()), 1) if a != b] == [1210])
    parsed = [pipeline.parse_ui_calls(HOLD, value.decode()) for value in (previous, raw)]
    # UiCall preserves path/function/line/api/KR/EN/context_id, not the moved column.
    check("all 71 UiCall fields and line numbers unchanged", not any(errors for _calls, errors in parsed)
          and len(parsed[0][0]) == 71 and parsed[0][0] == parsed[1][0])
    for name, changed in (
        ("outside byte", raw + b"\n"),
        ("non-KO global replacement", raw.replace(b' if LocaleManager.is_korean() else template', b'', 1)),
        ("wrong suffix", raw.replace('"%s로") if'.encode(), '"%s으로") if'.encode(), 1)),
        ("lookup key migration", raw.replace('_tr("%s으로 승리!'.encode(), '_tr("%s로 승리!'.encode(), 1)),
        ("gross message amount", raw.replace(b'_fmt(hand_net)])', b'_fmt(_pot)])', 1)),
        ("payout change", raw.replace(b'_player_stack += _pot\n', b'_player_stack += _pot + 1\n', 1)),
    ):
        if changed == raw: raise AssertionError("ineffective source mutation " + name)
        rejects("inverse rejects " + name, lambda changed=changed: history.holdem_victory_particle_inverse(changed, previous))
    pure_particle_checks(raw, observed)
    source_bound = lambda value, root=None: bound(value, raw, predecessors, root)
    with patch.object(history, "_holdem_victory_particle_proof", side_effect=source_bound):
        check("all thirteen public predecessor meanings preserved", tuple(fn(raw, ROOT) for fn in (
            history.holdem_victory_particle_predecessor, history.holdem_hand_net_predecessor,
            history.holdem_folded_locale_predecessor, history.holdem_seat_height_predecessor,
            history.holdem_table_labels_predecessor, history.holdem_banner_locale_predecessor,
            history.holdem_banner_predecessor, history.holdem_message_pulse_predecessor,
            history.holdem_card_color_predecessor, history.holdem_async_predecessor,
            history.holdem_betting_predecessor, history.holdem_canvas_predecessor,
            history.holdem_money_predecessor)) == predecessors
              and history._holdem_hand_net_proof(raw, ROOT) == predecessors[1:]
              and history._holdem_table_labels_proof(raw, ROOT) == predecessors[4:])
    def replay(root, *args, **kwargs):
        if root != ROOT or set(kwargs) - {"input"}: raise AssertionError("unexpected captured Git request")
        return responses[(args, kwargs.get("input"))]
    for name, prefix, change in (
        ("trailing packet", ("cat-file",), lambda value: value + b"x"),
        ("typed object corruption", ("cat-file",), lambda value: value.replace(b" commit ", b" blob ", 1)),
        ("forged new commit parent bytes", ("cat-file",), lambda value: value.replace(b"parent " + history.VICTORY_PARTICLE_BEFORE_COMMIT.encode(), b"parent " + b"0" * 40, 1)),
        ("forged new tree bytes", ("cat-file",), lambda value: value.replace(b"tree " + history.VICTORY_PARTICLE_TREES[1].encode(), b"tree " + b"0" * 40, 1)),
        ("extra product path", ("diff", "--name-status", "-z", history.VICTORY_PARTICLE_BEFORE_COMMIT), lambda value: value + b"M\0outside.gd\0"),
        ("stale HEAD blob", ("rev-parse", "HEAD:" + HOLD), lambda value: history.VICTORY_PARTICLE_BLOBS[0].encode() + b"\n"),
    ):
        def fault(root, *args, prefix=prefix, change=change, **kwargs):
            value = replay(root, *args, **kwargs)
            return change(value) if args[:len(prefix)] == prefix else value
        with patch.object(history, "_git", side_effect=fault):
            rejects("captured Git " + name, lambda: history.holdem_victory_particle_predecessor(raw, ROOT))
    def ancestry_fault(root, *args, **kwargs):
        if args == ("merge-base", "--is-ancestor", history.VICTORY_PARTICLE_AFTER_COMMIT, "HEAD"):
            raise ValueError("captured missing ancestry")
        return replay(root, *args, **kwargs)
    with patch.object(history, "_git", side_effect=ancestry_fault):
        rejects("captured ancestry failure", lambda: history.holdem_victory_particle_predecessor(raw, ROOT))
    head_reads = 0
    def moving_head(root, *args, **kwargs):
        nonlocal head_reads
        value = replay(root, *args, **kwargs)
        if args == ("rev-parse", "HEAD"):
            head_reads += 1
            if head_reads > 1: return b"0" * 40 + b"\n"
        return value
    with patch.object(history, "_git", side_effect=moving_head):
        rejects("captured moving final HEAD", lambda: history.holdem_victory_particle_predecessor(raw, ROOT))
    for name, values in (("initial raw", (raw + b"\n",)), ("final raw", (raw, raw + b"\n"))):
        with patch.object(history, "_git", side_effect=replay), patch.object(Path, "read_bytes", side_effect=values):
            rejects("captured " + name + " mismatch", lambda: history.holdem_victory_particle_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=OSError("captured fresh Git failure")):
        rejects("success never caches a later failure", lambda: history.holdem_victory_particle_predecessor(raw, ROOT))
    with patch.object(history, "_git", side_effect=replay):
        rejects("unsupported current source", lambda: history.holdem_victory_particle_predecessor(raw + b"\n", ROOT))
        check("captured recovery", history.holdem_victory_particle_predecessor(raw, ROOT) == previous)

    old_views, main_views = [], []
    real_rebind, real_main = pipeline._HOLDEM_TABLE_LABELS_OLD_REBIND, main_history._log_body_font_proof
    def capture_rebind(inventory, value, contract=None):
        result = real_rebind(inventory, value, contract); old_views.append(result)
        return result
    def capture_main(value, root=None):
        result = real_main(value, root); main_views.append(result)
        return result
    with patch.object(history, "_holdem_victory_particle_proof", side_effect=source_bound), \
         patch.object(pipeline, "_HOLDEM_TABLE_LABELS_OLD_REBIND", side_effect=capture_rebind), \
         patch.object(main_history, "_log_body_font_proof", side_effect=capture_main):
        current = pipeline.collect_ui_inventory()
    check("one current collector using unchanged rebind", not current.errors and len(old_views) == 1 and bool(main_views))
    retained = old_views[0]
    identity = lambda entry: (entry.key, entry.source, entry.source_hash, entry.context_id, entry.format_template)
    check("71 current calls and every retained Entry identity",
          tuple(c for c in current.calls if c.path == HOLD) == tuple(parsed[0][0])
          and len(current.calls) == len(retained.calls) + 5
          and tuple(identity(e) for e in current.entries if e.source not in TABLE_KEYS) == tuple(identity(e) for e in retained.entries)
          and {e.source for e in current.entries} - {e.source for e in retained.entries} == set(TABLE_KEYS)
          and current.stats["holdem_table_labels_added_calls"] == 5
          and current.stats["holdem_table_labels_added_keys"] == 4)
    main_raw, scalp_raw, aruba_raw = (observed[path] for path in (MAIN, SCALP, ARUBA))
    main_previous = main_views[0]
    check("captured Main predecessor population", len(main_previous) == 12 and all(row == main_previous for row in main_views))
    scalp_old, aruba_old = bridge.scalping_phase_predecessor(ROOT, scalp_raw), bridge.aruba_font_predecessor(ROOT, aruba_raw)
    hashes = {HOLD: sha(raw), MAIN: sha(main_raw), SCALP: sha(scalp_raw), ARUBA: sha(aruba_raw), "unowned.gd": "fixed"}
    views = [{**hashes, HOLD: sha(value)} for value in (raw, *predecessors)]
    oldest = views[-1]
    views.append({**oldest, MAIN: sha(main_previous[0])})
    views.extend({**oldest, MAIN: sha(value), SCALP: sha(scalp_old)} for value in main_previous)
    views.append({**views[-1], ARUBA: sha(aruba_old)})
    allowed, supplied = {bridge.exchange.digest(value) for value in views}, census(hashes)
    saved = copy.deepcopy(supplied)
    check("28 distinct actual lineage tuples supplied synthetically", len(views) == len(allowed) == 28)
    with patch.object(history, "_holdem_victory_particle_proof", side_effect=source_bound), \
         patch.object(main_history, "_log_body_font_proof", side_effect=lambda value, root=None: bound(value, main_raw, main_previous, root)), \
         patch.object(bridge, "scalping_phase_predecessor", side_effect=lambda root, value: bound(value, scalp_raw, scalp_old, root)), \
         patch.object(bridge, "aruba_font_predecessor", side_effect=lambda root, value: bound(value, aruba_raw, aruba_old, root)):
        check("synthetic census admits only actual lineage", all(bridge._source_manifest_matches(ROOT, supplied, digest) for digest in allowed))
        phantoms = {bridge.exchange.digest({**hashes, MAIN: main, SCALP: scalp, ARUBA: aruba})
                    for main, scalp, aruba in itertools.product(tuple(map(sha, (main_raw, *main_previous))),
                        (sha(scalp_raw), sha(scalp_old)), (sha(aruba_raw), sha(aruba_old)))} - allowed
        check("new Holdem rejects51 phantom peer mixtures", len(phantoms) == 51
              and all(not bridge._source_manifest_matches(ROOT, supplied, digest) for digest in phantoms))
        rejects("stale supplied census", lambda: bridge._source_manifest_matches(ROOT, census(views[1]), bridge.exchange.digest(views[1])))
        rejects("tampered census digest", lambda: bridge._source_manifest_matches(ROOT, {**supplied, "source_manifest_sha256": "0" * 64}, "0" * 64))
        check("unknown manifest rejected", not bridge._source_manifest_matches(ROOT, supplied, "0" * 64))
    check("supplied census not mutated", supplied == saved)
    check("all observed bytes and HEAD preserved", all((ROOT / path).read_bytes() == value for path, value in observed.items())
          and bridge._git(ROOT, "rev-parse", "HEAD") == responses[(("rev-parse", "HEAD"), None)])
    check("unique focused names", len(CASES) == len(set(CASES)))
    print(f"HOLDEM_VICTORY_PARTICLE_RECEIPT_CHECK_OK cases={len(CASES)} historical_cases=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

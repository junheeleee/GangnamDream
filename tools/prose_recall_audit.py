#!/usr/bin/env python3
"""Bounded prose-only delta audit; runtime and language quality are separate evidence."""
from __future__ import annotations

import argparse
import copy
import json
import re
import subprocess
from pathlib import Path

from order470_source_compat import _Document

ROOT = Path(__file__).resolve().parents[1]
BASE = "629452e7650bdfb9f20fc547c7d4696481cf239b"
LOCALES = {"ko": "events", "en": "events_en", "ja": "events_ja",
           "zh-CN": "events_zh-CN", "zh-TW": "events_zh-TW"}
MEMORY_KEY = "arc_y4_missed_cost_seen&arc_y4_missed_cost_repaired_person"
SELECTORS = {
    "arc_midgame.json": {
        "arc_year_one_mark": (
            ("description",),
            *(("description_memory_if_known", "m4_housing_priority_" + key)
              for key in ("runway", "privacy", "time")),
            *(("choices", i, key) for i in (0, 1) for key in ("text", "result_text")),
        ),
    },
    "arc_year_close.json": {
        "arc_year2_close": (
            ("description",),
            *(("description_if_known", key) for key in (
                "y2_lease_renewed_one_year", "y2_lease_renewed_six_months",
                "y2_lease_move_out_scheduled", "year1_resolve", "year1_numb",
                "jaehyuk_stood_up", "chose_money_over_father", "crossed_line")),
            *(("choices", i, key) for i in range(3) for key in ("text", "result_text")),
        ),
    },
    "arc_hyunsu.json": {
        eid: (("title",), ("description",),
              ("description_if_known", "crossed_line"),
              ("description_if_known", "called_hyunsu_first"),
              ("choices", 1, "result_text"))
        for eid in ("hyunsu_year5_call", "hyunsu_year5_call_father_passed")
    },
    "arc_daeun_extension.json": {
        "arc_daeun_year5_apart": (("description",),),
        "arc_daeun_year5_ending": (("description",),
            *(("description_if_known", key) for key in
              ("daeun_married", "daeun_year4_close", "daeun_romance_started"))),
    },
    "arc_chapter_themes.json": {
        eid: (("description_memory_if_known", MEMORY_KEY),)
        for eid in ("arc_y4_body_witness", "arc_y4_body_witness_hyunsu")
    },
}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def at(value, keys):
    for key in keys:
        value = value[key]
    return value


def validate_delta(before: bytes, after: bytes, filename: str) -> int:
    """Restore only owned literal spans, then require the whole baseline byte string."""
    old, new = _Document(before), _Document(after)
    old_ids = [row["id"] for row in old.value]
    require(len(set(old_ids)) == len(old_ids), "duplicate baseline event id")
    require(old_ids == [row["id"] for row in new.value], "event order/population changed")
    replacements = []
    for eid, selectors in SELECTORS[filename].items():
        i = old_ids.index(eid)
        for keys in selectors:
            previous, current = at(old.value[i], keys), at(new.value[i], keys)
            require(type(previous) is str and type(current) is str and previous != current,
                    f"expected changed string: {eid}:{keys}")
            require(len(previous.split("\n\n")) == len(current.split("\n\n")),
                    f"paragraph count: {eid}:{keys}")
            require(sorted(re.findall(r"\{[^}]+\}", previous)) ==
                    sorted(re.findall(r"\{[^}]+\}", current)), f"tokens: {eid}:{keys}")
            a, z = old.spans[(i, *keys)]
            b, end = new.spans[(i, *keys)]
            replacements.append((b, end, old.text[a:z]))
    restored = new.text
    for a, z, literal in sorted(replacements, reverse=True):
        restored = restored[:a] + literal + restored[z:]
    require(restored.encode("utf-8") == before,
            f"unowned bytes, gameplay or key order changed: {filename}")
    return len(replacements)


def baseline(path):
    spec = BASE + ":" + path
    kind = subprocess.check_output(["git", "--no-replace-objects", "cat-file", "-t", spec], cwd=ROOT).strip()
    require(kind == b"blob", "baseline is not a Git blob: " + path)
    return subprocess.check_output(["git", "--no-replace-objects", "cat-file", "blob", spec], cwd=ROOT)


def snapshots(locales):
    return {(locale, filename): (baseline(path), (ROOT / path).read_bytes())
            for locale in locales for filename in SELECTORS
            for path in [f"content/{LOCALES[locale]}/{filename}"]}


def self_test():
    """Small synthetic corpus: every negative starts from a valid owned-string edit."""
    count = 0
    for filename, events in SELECTORS.items():
        rows = []
        for eid, selectors in events.items():
            row = {"id": eid, "description": "old {name}",
                   "conditions": {"min_turn": 1}, "choices": [
                       {"text": "keep", "result_text": "keep", "flags": ["a"],
                        "effects": {"mental": 1}},
                       {"text": "keep2", "result_text": "keep2", "flags": ["b"]},
                       {"text": "keep3", "result_text": "keep3"}], "title": "keep"}
            for keys in selectors:
                node = row
                for key in keys[:-1]:
                    if type(key) is str and key not in node:
                        node[key] = {}
                    node = node[key]
                node[keys[-1]] = "old {name}"
            rows.append(row)
        rows.append({"id": "arc_y4_body_witness_jiyeon", "description": "author only"})
        dump = lambda value: json.dumps(value, ensure_ascii=False, indent=2).encode()
        before = dump(rows)
        edited = copy.deepcopy(rows)
        for i, selectors in enumerate(events.values()):
            for keys in selectors:
                node = edited[i]
                for key in keys[:-1]:
                    node = node[key]
                node[keys[-1]] = "new {name}"
        after = dump(edited)
        expected = sum(map(len, events.values()))
        require(validate_delta(before, after, filename) == expected, "valid synthetic delta")
        count += 1
        mutations = []
        for key, val in (("effects", {"mental": 9}), ("flags", ["wrong"])):
            bad = copy.deepcopy(edited); bad[0]["choices"][0][key] = val
            mutations.append(dump(bad))
        bad = copy.deepcopy(edited); bad[0]["conditions"]["min_turn"] = 2
        mutations.append(dump(bad))
        bad = copy.deepcopy(edited); bad[0]["choices"].reverse()
        mutations.append(dump(bad))
        bad = copy.deepcopy(edited); bad[-1]["description"] = "changed author only"
        mutations.append(dump(bad))
        bad = copy.deepcopy(edited); bad[0] = dict(reversed(list(bad[0].items())))
        mutations.append(dump(bad))
        for key in ("description_if_known", "description_memory_if_known"):
            if len(edited[0].get(key, {})) > 1:
                bad = copy.deepcopy(edited)
                bad[0][key] = dict(reversed(list(bad[0][key].items())))
                mutations.append(dump(bad))
        first = next(iter(events.values()))[0]
        for replacement in ("old {name}", "new {assets}", "new {name}\n\nextra"):
            bad = copy.deepcopy(edited); node = bad[0]
            for key in first[:-1]: node = node[key]
            node[first[-1]] = replacement
            mutations.append(dump(bad))
        mutations += [after + b"\n", after.replace(b"  ", b" ", 1)]
        for bad in mutations:
            try:
                validate_delta(before, bad, filename)
            except (ValueError, KeyError, IndexError):
                count += 1
            else:
                raise ValueError("mutation accepted: " + filename)
    print(f"PROSE_RECALL_SELF_TEST_OK cases={count}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-only", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    locales = ("ko", "en") if args.source_only else tuple(LOCALES)
    files = snapshots(locales)
    counts = {locale: 0 for locale in locales}
    for (locale, filename), (before, after) in files.items():
        counts[locale] += validate_delta(before, after, filename)
    require(all(value == 40 for value in counts.values()), "exact owned leaf population")
    print("PROSE_RECALL_OK " + json.dumps({"files": len(files), "changed_leaves": counts,
          "baseline": BASE, "unowned_bytes_preserved": True,
          "runtime_or_quality_claim": False}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, KeyError, IndexError, OSError, subprocess.CalledProcessError) as exc:
        print("PROSE_RECALL_FAIL " + str(exc))
        raise SystemExit(1)

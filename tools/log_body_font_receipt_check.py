#!/usr/bin/env python3
"""Current UI/font semantics; read-only checks, not rendered observations.

Closed MainGame commit chains and whole-file predecessor seals are not product
gates. Current string ownership, layout and source-bound packets remain checked.
"""
import copy
import hashlib
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
import full_game_localization as exchange
import ja_translation_pipeline as ja

ROOT = Path(__file__).resolve().parents[1]
MAIN = "scenes/MainGame.gd"


def source_errors(source: str) -> list[str]:
    """Bind log body font/size/fit to the current information panel."""
    body = ja._gd_function_source(source, "_build_info_panel")
    lines = [re.sub(r"\s+", "", line) for line in body.splitlines()
             if line.strip() and not line.lstrip().startswith("#")]
    rules = (
        ("log_box=", "log_box=RichTextLabel.new()", "log body widget"),
        ("log_box.bbcode_enabled=", "log_box.bbcode_enabled=true", "BBCode log body"),
        ("log_box.fit_content=", "log_box.fit_content=true", "fit log content"),
        ('log_box.add_theme_font_override("normal_font",', 'log_box.add_theme_font_override("normal_font",_font_regular)', "regular log body font"),
        ('log_box.add_theme_font_size_override("normal_font_size",', 'log_box.add_theme_font_size_override("normal_font_size",13)', "log body size"),
        ("stat_box.add_child(log_box)", "stat_box.add_child(log_box)", "log body attached to information panel"),
    )
    errors = [label for prefix, expected, label in rules
              if [line for line in lines if line.startswith(prefix)] != [expected]]
    if not errors and not all(lines.index(expected) < lines.index(rules[-1][1])
                              for _, expected, _ in rules[:-1]):
        errors.append("configure log before attaching to information panel")
    return errors


def current_ui_contract_checks(source, check):
    calls, errors = ja.parse_ui_calls(MAIN, source)
    calls = tuple(sorted(calls, key=lambda call: (call.path, call.line, call.api)))
    ui = ja.collect_ui_inventory()
    check(not errors and not ui.errors, "current UI parser and collector diagnostics")
    check(tuple(call for call in ui.calls if call.path == MAIN) == calls,
          "collector owns current MainGame strings and coordinates")
    check(set(ui.legacy_blueprint) == {entry.source for entry in ui.legacy_entries},
          "current UI blueprint and legacy source keys agree")
    _, malformed = ja.parse_ui_calls(MAIN, 'func test():\n\tLocaleManager.ui_context("audit.log", "기록")\n')
    check(bool(malformed), "missing English context UI argument is rejected")

    # This bounded packet binds a current UI leaf and actual MainGame hash.
    # It is not a full-game census and admits no historical source-hash aliases.
    entry = next(entry for entry in ui.legacy_entries if entry.source == "기록")
    leaf = exchange.Leaf("ui", entry.source, "runtime:static_ui", (entry.source,),
                         entry.source, "ui_static_context", format_template=entry.format_template)
    hashes = {MAIN: hashlib.sha256(source.encode()).hexdigest()}
    inventory = {"leaves": [leaf], "source_hashes": hashes,
                 "source_manifest_sha256": exchange.digest(hashes)}
    documents = {"locale/ui_ja.json": exchange.read_json(ROOT / "locale/ui_ja.json")}
    batch = exchange.make_batch(inventory, "ja", [leaf], "a" * 40, documents, {})
    response = [copy.deepcopy(batch[0]), {"id": leaf.id, "locale": "ja",
        "source_sha256": leaf.source_sha256, "prompt_version": exchange.PROMPT_VERSION,
        "text": documents["locale/ui_ja.json"][leaf.source]}]
    preserved = copy.deepcopy(inventory)
    check(exchange.check_batch(inventory, batch, response) == {leaf.id: response[1]["text"]},
          "current UI manifest and leaf binding admitted")
    for label, field, message in (
        ("unknown source manifest", "source_manifest_sha256", "stale source manifest"),
        ("stale source leaf", "source_sha256", "unknown/stale source leaf"),
    ):
        altered = copy.deepcopy(batch)
        if field == "source_sha256":
            altered[1][field] = "0" * 64
            altered[0]["selection_sha256"] = exchange.digest(altered[1:])
        else:
            altered[0][field] = "0" * 64
        altered[0]["batch_id"] = exchange.digest({key: value for key, value in altered[0].items()
                                                if key != "batch_id"})
        try:
            exchange.check_batch(inventory, altered, [altered[0], response[1]])
        except exchange.ContractError as error:
            check(message in str(error), label + ": " + str(error))
        else:
            check(False, label + ": unexpectedly admitted")
    altered_response = copy.deepcopy(response)
    altered_response[1]["locale"] = "zh-CN"
    try:
        exchange.check_batch(inventory, batch, altered_response)
    except exchange.ContractError as error:
        check("binding drift" in str(error), "wrong response locale: " + str(error))
    else:
        check(False, "wrong response locale unexpectedly admitted")
    check(inventory == preserved, "manifest checks do not rewrite current source census")
    ledger = exchange.read_json(ROOT / "content/meta/full_game_localization.json")
    check(ledger.get("accepted_sha256") == exchange.digest(ledger["accepted"]),
          "current receipt checksum; no fixed historical leaf count")

def log_body_font_receipt_self_test() -> tuple[list[str], int]:
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("log body font: " + label)

    source = (ROOT / MAIN).read_text(encoding="utf-8")
    check(not source_errors(source), "current log body semantics")
    body = ja._gd_function_source(source, "_build_info_panel")
    for label, before, after in (
        ("wrong font role", '"normal_font", _font_regular', '"normal_font", _font_bold'),
        ("wrong target", "log_box.add_theme_font_override", "log_hdr.add_theme_font_override"),
        ("font removed", 'log_box.add_theme_font_override("normal_font", _font_regular)', "# removed font role"),
        ("size changed", 'log_box.add_theme_font_size_override("normal_font_size", 13)',
         'log_box.add_theme_font_size_override("normal_font_size", 14)'),
        ("fit removed", "log_box.fit_content = true", "log_box.fit_content = false"),
    ):
        check(body.count(before) == 1 and source.count(body) == 1, "mutation owner " + label)
        mutant = source.replace(body, body.replace(before, after, 1), 1)
        check(bool(source_errors(mutant)), "reject " + label)
    check(not source_errors(source + "\n# Unrelated formatting is not a log-font failure.\n"),
          "unrelated edits are not predecessor seals")
    check(bool(source_errors(source.replace("func _build_info_panel(", "func _missing_info_panel(", 1))),
          "missing log-panel owner rejected")
    current_ui_contract_checks(source, check)
    return failures, cases


def main():
    errors, cases = log_body_font_receipt_self_test()
    for error in errors:
        print("LOG_BODY_FONT_RECEIPT_CHECK_ERROR " + error)
    print(f"LOG_BODY_FONT_RECEIPT_CHECK_{'FAIL' if errors else 'OK'} cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())

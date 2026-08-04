#!/usr/bin/env python3
"""Lock the authored opportunity/fallback topology for the one-won cash ledger."""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "content" / "events"
EN_DIR = ROOT / "content" / "events_en"
OPPORTUNITY_FILES = (
    "amb_scenarios2.json",
    "arc_events.json",
    "callback_events_3.json",
    "callback_events_4.json",
    "callback_events_5.json",
    "investment_events.json",
    "scenario_cafe_callback.json",
)
FALLBACK_EVENT_IDS = {"cafe_cb_stole_allin", "cafe_cb_stole_smart"}
FALLBACK_KEYS = {
    "text",
    "result_text",
    "opportunity_unavailable_fallback",
}
ALLOWED_GAME_STATE_CASH_WRITES = {
    "var money = 1_000_000.0",
    'money = settle_cash(float(diff_data.get("start_money", 500_000.0)))',
    "money = previous_money + amount",
    "money += legacy_phone_refund",
    "money = settle_cash(float(money))",
}


def load_rows(path: Path, errors: list[str]) -> list[dict[str, Any]]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path.relative_to(ROOT)}: invalid JSON ({exc})")
        return []
    if not isinstance(value, list):
        errors.append(f"{path.relative_to(ROOT)}: root must be an array")
        return []
    rows: list[dict[str, Any]] = []
    for index, row in enumerate(value):
        if not isinstance(row, dict):
            errors.append(f"{path.relative_to(ROOT)}[{index}]: event must be an object")
            continue
        rows.append(row)
    return rows


def event_index(rows: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {str(row.get("id", "")): row for row in rows if row.get("id")}


def main() -> int:
    errors: list[str] = []
    opportunity_rows: list[tuple[str, str, int, dict[str, Any]]] = []
    opportunity_event_ids: set[str] = set()
    fallback_ids: set[str] = set()
    ordinary_alternative_events: set[str] = set()

    all_disk_opportunity_files: set[str] = set()
    for path in sorted(EVENT_DIR.glob("*.json")):
        rows = load_rows(path, errors)
        if any(
            isinstance(choice, dict) and bool(choice.get("opportunity"))
            for event in rows
            for choice in event.get("choices", [])
            if isinstance(event.get("choices", []), list)
        ):
            all_disk_opportunity_files.add(path.name)
    if all_disk_opportunity_files != set(OPPORTUNITY_FILES):
        errors.append(
            "opportunity file set drifted: "
            f"expected={sorted(OPPORTUNITY_FILES)} "
            f"actual={sorted(all_disk_opportunity_files)}"
        )

    for filename in OPPORTUNITY_FILES:
        ko_rows = load_rows(EVENT_DIR / filename, errors)
        en_rows = load_rows(EN_DIR / filename, errors)
        en_by_id = event_index(en_rows)
        for event in ko_rows:
            event_id = str(event.get("id", ""))
            choices = event.get("choices", [])
            if not isinstance(choices, list):
                continue
            opportunity_indices: list[int] = []
            fallback_indices: list[int] = []
            ordinary_indices: list[int] = []
            for choice_index, choice in enumerate(choices):
                if not isinstance(choice, dict):
                    continue
                opportunity = choice.get("opportunity")
                if isinstance(opportunity, dict) and opportunity:
                    opportunity_indices.append(choice_index)
                    opportunity_rows.append(
                        (filename, event_id, choice_index, opportunity)
                    )
                    ratio = opportunity.get("stake_ratio")
                    cost = opportunity.get("cost")
                    if ratio is None and cost is None:
                        errors.append(
                            f"{filename}:{event_id}[{choice_index}]: "
                            "opportunity needs stake_ratio or cost"
                        )
                    if ratio is not None and (
                        not isinstance(ratio, (int, float))
                        or isinstance(ratio, bool)
                        or not 0.0 < float(ratio) <= 1.0
                    ):
                        errors.append(
                            f"{filename}:{event_id}[{choice_index}]: "
                            f"invalid stake_ratio {ratio!r}"
                        )
                    if cost is not None and (
                        not isinstance(cost, (int, float))
                        or isinstance(cost, bool)
                        or float(cost) < 0.5
                    ):
                        errors.append(
                            f"{filename}:{event_id}[{choice_index}]: "
                            f"fixed cost cannot settle to a positive won: {cost!r}"
                        )
                    continue
                if choice.get("opportunity_unavailable_fallback") is True:
                    fallback_indices.append(choice_index)
                    fallback_ids.add(event_id)
                    if set(choice) != FALLBACK_KEYS:
                        errors.append(
                            f"{filename}:{event_id}[{choice_index}]: fallback must "
                            f"contain exactly {sorted(FALLBACK_KEYS)}, got {sorted(choice)}"
                        )
                    if not str(choice.get("text", "")).strip() or not str(
                        choice.get("result_text", "")
                    ).strip():
                        errors.append(
                            f"{filename}:{event_id}[{choice_index}]: fallback text is empty"
                        )
                else:
                    ordinary_indices.append(choice_index)

            if not opportunity_indices:
                continue
            opportunity_event_ids.add(event_id)
            if event_id in FALLBACK_EVENT_IDS:
                if len(opportunity_indices) != 1 or len(fallback_indices) != 1:
                    errors.append(
                        f"{filename}:{event_id}: expected one opportunity and one fallback"
                    )
                if ordinary_indices:
                    errors.append(
                        f"{filename}:{event_id}: fallback scene gained an ordinary alternative"
                    )
            else:
                if not ordinary_indices:
                    errors.append(
                        f"{filename}:{event_id}: opportunity event has no ordinary alternative"
                    )
                if fallback_indices:
                    errors.append(
                        f"{filename}:{event_id}: only legacy one-choice scenes may use fallback"
                    )
                ordinary_alternative_events.add(event_id)

            en_event = en_by_id.get(event_id)
            if en_event is None:
                errors.append(f"events_en/{filename}:{event_id}: missing overlay")
                continue
            en_choices = en_event.get("choices", [])
            if not isinstance(en_choices, list) or len(en_choices) != len(choices):
                errors.append(
                    f"events_en/{filename}:{event_id}: choice count "
                    f"{len(en_choices) if isinstance(en_choices, list) else 'invalid'} "
                    f"!= KO {len(choices)}"
                )
                continue
            for fallback_index in fallback_indices:
                en_choice = en_choices[fallback_index]
                if not isinstance(en_choice, dict) or set(en_choice) != {
                    "text",
                    "result_text",
                }:
                    errors.append(
                        f"events_en/{filename}:{event_id}[{fallback_index}]: "
                        "fallback overlay must remain text-only"
                    )

    if len(opportunity_rows) != 19:
        errors.append(f"opportunity choice count drifted: {len(opportunity_rows)} != 19")
    if len(opportunity_event_ids) != 15:
        errors.append(
            f"opportunity event count drifted: {len(opportunity_event_ids)} != 15"
        )
    if len(ordinary_alternative_events) != 13:
        errors.append(
            "ordinary-alternative opportunity event count drifted: "
            f"{len(ordinary_alternative_events)} != 13"
        )
    if fallback_ids != FALLBACK_EVENT_IDS:
        errors.append(
            f"fallback event set drifted: expected={sorted(FALLBACK_EVENT_IDS)} "
            f"actual={sorted(fallback_ids)}"
        )

    fomo = next(
        (
            event
            for event in load_rows(EVENT_DIR / "callback_events_5.json", errors)
            if event.get("id") == "callback_fomo_invested_result"
        ),
        {},
    )
    fomo_choices = fomo.get("choices", []) if isinstance(fomo, dict) else []
    if (
        not isinstance(fomo_choices, list)
        or len(fomo_choices) <= 1
        or not isinstance(fomo_choices[1], dict)
        or float(fomo_choices[1].get("effects", {}).get("money", 0.0))
        != -1_000_000.0
    ):
        errors.append(
            "callback_fomo_invested_result[1] lost its pre-stake KRW 1,000,000 debit"
        )

    game_state_path = ROOT / "autoloads" / "GameState.gd"
    game_state_source = game_state_path.read_text(encoding="utf-8")
    cash_write_pattern = re.compile(r"^(?:var\s+)?money\s*(?:[+\-*/]?=)")
    for line_number, raw_line in enumerate(game_state_source.splitlines(), 1):
        statement = raw_line.strip()
        if cash_write_pattern.match(statement) and statement not in ALLOWED_GAME_STATE_CASH_WRITES:
            errors.append(
                f"autoloads/GameState.gd:{line_number}: direct cash write bypasses "
                f"the one-won boundary ({statement})"
            )
    direct_global_write = re.compile(r"GameState\.money\s*[+\-*/]?=")
    for directory in ("autoloads", "systems", "scenes", "ui_components"):
        for path in sorted((ROOT / directory).rglob("*.gd")):
            for line_number, raw_line in enumerate(
                path.read_text(encoding="utf-8").splitlines(), 1
            ):
                if direct_global_write.search(raw_line):
                    errors.append(
                        f"{path.relative_to(ROOT)}:{line_number}: direct GameState.money "
                        "write bypasses the one-won boundary"
                    )
    if '"money": settle_cash(float(money))' not in game_state_source:
        errors.append("GameState.serialize no longer emits settled whole-won cash")
    if "sibling_required_item" not in game_state_source:
        errors.append("fallback availability ignores item-gated opportunity siblings")

    registry_source = (ROOT / "autoloads" / "DataRegistry.gd").read_text(
        encoding="utf-8"
    )
    if registry_source.count("_mod_opportunity_topology_valid(") < 3:
        errors.append(
            "DataRegistry does not apply opportunity-exit topology to both new and "
            "override mod events"
        )

    if errors:
        for message in errors:
            print(f"ERROR: {message}")
        print(f"OPPORTUNITY_MONEY_AUDIT_FAIL errors={len(errors)}")
        return 1
    print(
        "OPPORTUNITY_MONEY_AUDIT_OK "
        "files=7 events=15 choices=19 ordinary_alternatives=13 "
        "fallbacks=2 ko_en_positional=exact fomo_predebit=1000000 "
        "mod_exit=new_override_item_gate"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

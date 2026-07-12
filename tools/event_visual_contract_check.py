#!/usr/bin/env python3
"""Check explicit event background, portrait, and calendar contracts.

The normal release audit verifies locked contracts and tagged-event coverage while
reporting acknowledged production debt. Run with --strict before claiming the
season/location/wardrobe inventory complete; strict mode fails on any debt row.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "content" / "events"
MANIFEST = ROOT / "assets" / "event_visual_contracts.json"


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as source:
        return json.load(source)


def load_events() -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(EVENT_DIR.glob("*.json")):
        payload = load_json(path)
        if not isinstance(payload, list):
            raise ValueError(f"event file is not an array: {path.relative_to(ROOT)}")
        for event in payload:
            event_id = str(event.get("id", ""))
            if not event_id:
                raise ValueError(f"event without id: {path.relative_to(ROOT)}")
            if event_id in events:
                raise ValueError(f"duplicate event id: {event_id}")
            events[event_id] = event
    return events


def normalized_months(value: Any) -> list[int]:
    if value is None:
        return []
    if isinstance(value, int):
        return [value]
    if isinstance(value, list):
        return sorted(int(month) for month in value)
    raise ValueError(f"invalid month condition: {value!r}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()

    errors: list[str] = []
    try:
        events = load_events()
        manifest = load_json(MANIFEST)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"EVENT_VISUAL_CONTRACT_FAIL {exc}")
        return 1

    contracts = manifest.get("contracts", [])
    debt = manifest.get("known_debt", [])
    contract_ids: set[str] = set()
    debt_ids: set[str] = set()

    for contract in contracts:
        event_id = str(contract.get("id", ""))
        if not event_id or event_id in contract_ids:
            errors.append(f"duplicate or empty contract id: {event_id!r}")
            continue
        contract_ids.add(event_id)
        event = events.get(event_id)
        if event is None:
            errors.append(f"contract references missing event: {event_id}")
            continue
        for field in ("background", "portrait"):
            if field not in contract:
                continue
            expected = contract[field]
            actual = event.get(field)
            if expected is None:
                if actual not in (None, ""):
                    errors.append(f"{event_id} expected no {field}, got {actual!r}")
            elif actual != expected:
                errors.append(f"{event_id} expected {field}={expected!r}, got {actual!r}")
        if "months" in contract:
            expected_months = normalized_months(contract["months"])
            actual_months = normalized_months((event.get("conditions") or {}).get("month"))
            if actual_months != expected_months:
                errors.append(
                    f"{event_id} expected months={expected_months}, got {actual_months}"
                )

    for item in debt:
        event_id = str(item.get("id", ""))
        issue = str(item.get("issue", "")).strip()
        if not event_id or event_id in debt_ids:
            errors.append(f"duplicate or empty debt id: {event_id!r}")
            continue
        debt_ids.add(event_id)
        if event_id not in events:
            errors.append(f"known debt references missing event: {event_id}")
        if not issue:
            errors.append(f"known debt has no issue text: {event_id}")

    covered = contract_ids | debt_ids
    coverage_tags = {str(tag) for tag in manifest.get("tag_coverage", [])}
    for event_id, event in events.items():
        tags = {str(tag) for tag in event.get("tags", []) or []}
        if tags & coverage_tags and event_id not in covered:
            errors.append(
                f"tagged event lacks visual contract/debt row: {event_id} tags={sorted(tags & coverage_tags)}"
            )

    if args.strict and debt:
        errors.append(f"strict mode: {len(debt)} acknowledged visual debt rows remain")

    if errors:
        for error in errors:
            print(f"EVENT_VISUAL_CONTRACT_FAIL {error}")
        return 1

    debt_list = ",".join(sorted(debt_ids)) if debt_ids else "none"
    print(
        "EVENT_VISUAL_CONTRACT_OK "
        f"locked={len(contracts)} tagged_coverage={len(coverage_tags)} "
        f"known_debt={len(debt)} debt_ids={debt_list}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Shared parsing for immediate and delayed event schedule fields."""

from __future__ import annotations

from typing import Any


class DeferredFollowUpError(ValueError):
    """Raised when deferred_follow_up does not match the content contract."""


def deferred_follow_ups(owner: dict[str, Any]) -> list[tuple[str, int]]:
    """Return normalized ``(event_id, delay)`` entries for one event or choice."""
    raw = owner.get("deferred_follow_up", "")
    if raw in ("", None):
        return []

    default_delay = owner.get("deferred_delay", 6)
    if isinstance(default_delay, bool) or not isinstance(default_delay, int):
        raise DeferredFollowUpError("deferred_delay must be an integer")

    if isinstance(raw, str):
        event_id = raw.strip()
        return [(event_id, default_delay)] if event_id else []
    if not isinstance(raw, list):
        raise DeferredFollowUpError(
            "deferred_follow_up must be a string or an array"
        )

    result: list[tuple[str, int]] = []
    for index, value in enumerate(raw):
        if isinstance(value, str):
            event_id = value.strip()
            delay = default_delay
        elif isinstance(value, dict):
            unknown = set(value) - {"id", "delay"}
            if unknown:
                raise DeferredFollowUpError(
                    f"deferred_follow_up[{index}] has unsupported keys "
                    f"{sorted(unknown)}"
                )
            raw_id = value.get("id", "")
            if not isinstance(raw_id, str):
                raise DeferredFollowUpError(
                    f"deferred_follow_up[{index}].id must be a string"
                )
            event_id = raw_id.strip()
            delay = value.get("delay", default_delay)
            if isinstance(delay, bool) or not isinstance(delay, int):
                raise DeferredFollowUpError(
                    f"deferred_follow_up[{index}].delay must be an integer"
                )
        else:
            raise DeferredFollowUpError(
                f"deferred_follow_up[{index}] must be a string or an object"
            )
        if event_id:
            result.append((event_id, delay))
    return result


def deferred_target_ids(owner: dict[str, Any]) -> set[str]:
    return {event_id for event_id, _delay in deferred_follow_ups(owner)}

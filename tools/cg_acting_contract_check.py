#!/usr/bin/env python3
"""Fail when an active CG lacks a concrete camera, gaze, and acting contract."""

from __future__ import annotations

import json
import re
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "autoloads/ImageRegistry.gd"
MANIFEST = ROOT / "assets/cg_acting_manifest.json"
ALLOWED_SIZES = {(1280, 800), (1280, 720)}


def active_cg_paths() -> dict[str, str]:
    source = REGISTRY.read_text(encoding="utf-8")
    try:
        block = source.split("const CG = {", 1)[1].split("\n}", 1)[0]
    except IndexError as exc:
        raise ValueError("ImageRegistry CG table could not be parsed") from exc
    return {
        asset_id: path.removeprefix("res://")
        for asset_id, path in re.findall(
            r'"([^"]+)"\s*:\s*"(res://[^"]+\.png)"', block
        )
    }


def png_size(path: Path) -> tuple[int, int]:
    header = path.read_bytes()[:24]
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    return struct.unpack(">II", header[16:24])


def main() -> int:
    failures: list[str] = []
    active = active_cg_paths()
    payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    contracts = payload.get("cg", {})

    missing = sorted(set(active) - set(contracts))
    stale = sorted(set(contracts) - set(active))
    if missing:
        failures.append(f"active CGs missing contracts: {', '.join(missing)}")
    if stale:
        failures.append(f"stale contracts not active in ImageRegistry: {', '.join(stale)}")

    for asset_id, runtime_path in active.items():
        contract = contracts.get(asset_id)
        if not isinstance(contract, dict):
            continue

        manifest_path = str(contract.get("path", ""))
        if manifest_path != runtime_path:
            failures.append(
                f"{asset_id}: runtime path {runtime_path} != manifest path {manifest_path}"
            )

        path = ROOT / runtime_path
        if not path.exists():
            failures.append(f"{asset_id}: missing image {runtime_path}")
        else:
            try:
                size = png_size(path)
            except ValueError as exc:
                failures.append(f"{asset_id}: {exc}")
            else:
                if size not in ALLOWED_SIZES:
                    failures.append(
                        f"{asset_id}: unsupported CG size {size}; expected 1280x800 or 1280x720"
                    )

        camera_role = str(contract.get("camera_role", "")).strip()
        story_action = str(contract.get("story_action", "")).strip()
        actors = contract.get("actors")
        if len(camera_role) < 4:
            failures.append(f"{asset_id}: camera_role is missing or vague")
        if len(story_action) < 16:
            failures.append(f"{asset_id}: story_action is missing or vague")
        if not isinstance(actors, list):
            failures.append(f"{asset_id}: actors must be a list")
            continue
        if not actors and camera_role != "environment":
            failures.append(f"{asset_id}: actor-free CG must use camera_role=environment")

        seen_actors: set[str] = set()
        for actor in actors:
            if not isinstance(actor, dict):
                failures.append(f"{asset_id}: actor contract must be an object")
                continue
            actor_id = str(actor.get("id", "")).strip()
            gaze_target = str(actor.get("gaze_target", "")).strip()
            pose_support = str(actor.get("pose_support", "")).strip()
            if not actor_id:
                failures.append(f"{asset_id}: actor id is missing")
            elif actor_id in seen_actors:
                failures.append(f"{asset_id}: duplicate actor id {actor_id}")
            seen_actors.add(actor_id)
            if len(gaze_target) < 6:
                failures.append(f"{asset_id}/{actor_id}: gaze_target is missing or vague")
            if len(pose_support) < 12:
                failures.append(f"{asset_id}/{actor_id}: pose_support is missing or vague")
            gaze_lower = gaze_target.lower()
            lens_facing = re.search(r"\b(?:lens|camera|viewer)\b", gaze_lower) is not None
            if lens_facing and camera_role not in {"player_pov", "four_cut_booth_camera"}:
                failures.append(
                    f"{asset_id}/{actor_id}: lens-facing gaze requires a diegetic camera role"
                )

    if failures:
        for failure in failures:
            print(f"CG_ACTING_CHECK_FAIL {failure}")
        return 1

    actor_count = sum(len(contract["actors"]) for contract in contracts.values())
    print(
        f"CG_ACTING_CHECK_OK active={len(active)} actor_contracts={actor_count} "
        "missing=0 stale=0"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

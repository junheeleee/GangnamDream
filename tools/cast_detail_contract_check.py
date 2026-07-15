#!/usr/bin/env python3
"""Lock the A/B/C cast hierarchy so extras cannot replace authored actors."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "cast_detail_manifest.json"
ACTING = ROOT / "assets" / "cg_acting_manifest.json"
CAST_STAGES = ROOT / "content" / "meta" / "cast_stages.json"
ART_DIRECTION = ROOT / "docs" / "GANGNAM_INK_ART_DIRECTION.md"
VISUAL_BIBLE = ROOT / "assets" / "CHARACTER_VISUAL_BIBLE.md"


def load_json(path: Path):
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def main() -> int:
    failures: list[str] = []
    manifest = load_json(MANIFEST)
    tiers = manifest.get("tiers", {})
    tier_a = set(tiers.get("A_story_anchor", {}).get("characters", []))
    tier_b = set(tiers.get("B_scene_actor", {}).get("characters", []))
    tier_c = set(tiers.get("C_atmospheric_extra", {}).get("roles", []))

    if manifest.get("contract_id") != "CAST_DETAIL_CONTRACT_V1":
        failures.append("cast detail contract id drifted")
    if not tier_a or not tier_b or not tier_c:
        failures.append("all three cast detail tiers must be populated")
    overlap = sorted((tier_a & tier_b) | (tier_a & tier_c) | (tier_b & tier_c))
    if overlap:
        failures.append("cast detail tiers overlap: " + ", ".join(overlap))

    required_anchors = {"minjun", "daeun", "jiyeon", "father", "jaehyuk", "sangchul", "hyunsu"}
    missing_anchors = sorted(required_anchors - tier_a)
    if missing_anchors:
        failures.append("story anchors lost A-tier detail: " + ", ".join(missing_anchors))

    acting = load_json(ACTING).get("cg", {})
    active_actor_ids: set[str] = set()
    for cg_id, contract in acting.items():
        for actor in contract.get("actors", []):
            actor_id = str(actor.get("id", "")).strip()
            if not actor_id:
                continue
            active_actor_ids.add(actor_id)
            if actor_id in tier_c:
                failures.append(f"{cg_id}: atmospheric extra {actor_id} was promoted to acting focus")
            elif actor_id not in tier_a and actor_id not in tier_b:
                failures.append(f"{cg_id}: actor {actor_id} has no A/B detail contract")

    cast_stages = {
        key for key in load_json(CAST_STAGES)
        if not str(key).startswith("_")
    }
    missing_stage_cast = sorted(cast_stages - tier_a - tier_b)
    if missing_stage_cast:
        failures.append("relationship cast lacks detail tier: " + ", ".join(missing_stage_cast))

    cg_policy = manifest.get("cg_policy", {})
    if cg_policy.get("listed_actor_tiers") != ["A_story_anchor", "B_scene_actor"]:
        failures.append("CG actor policy must exclude atmospheric extras")
    reusable = manifest.get("reusable_background_policy", {})
    if reusable.get("allowed_embedded_tier") != "C_atmospheric_extra":
        failures.append("reusable backgrounds may embed only C-tier extras")

    wedding_actor_contracts = {
        "cg_romance_wedding_daeun_mother_reaction": {"daeun_mother"},
        "cg_romance_wedding_daeun_father_reaction": {"father"},
        "cg_romance_wedding_daeun_father_reaction_hyunsu": {"father", "hyunsu"},
        "cg_romance_wedding_daeun_father_reaction_passed": set(),
        "cg_romance_wedding_daeun_father_reaction_passed_hyunsu": {"hyunsu"},
        "cg_romance_wedding_daeun_small": {"minjun", "daeun"},
        "cg_romance_wedding_daeun_full": {"minjun", "daeun"},
        "cg_romance_wedding_daeun_small_close": {"minjun", "daeun"},
        "cg_romance_wedding_daeun_full_close": {"minjun", "daeun"},
    }
    for cg_id, expected_actors in wedding_actor_contracts.items():
        actors = {actor.get("id") for actor in acting.get(cg_id, {}).get("actors", [])}
        if actors != expected_actors:
            failures.append(
                f"{cg_id}: wedding focus drifted: expected {sorted(expected_actors)}, got {sorted(actors)}"
            )

    for path in (ART_DIRECTION, VISUAL_BIBLE):
        if "CAST_DETAIL_CONTRACT_V1" not in path.read_text(encoding="utf-8"):
            failures.append(f"{path.relative_to(ROOT)} does not cite the cast detail contract")

    if failures:
        for failure in failures:
            print("CAST_DETAIL_CONTRACT_FAIL", failure)
        return 1
    print(
        "CAST_DETAIL_CONTRACT_OK "
        f"anchors={len(tier_a)} scene_actors={len(tier_b)} extras={len(tier_c)} "
        f"cg_actor_ids={len(active_actor_ids)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Gate active raster dimensions and report 1080p/4K enlargement debt.

ImageRegistry is the active-art source of truth. This audit deliberately keeps
geometric readiness separate from human review: dimensions can prove that an
asset will be enlarged, but cannot prove that hands, faces, lettering, or
composition survive that enlargement.
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

from art_ai_audit import ROOT, _raster_info, active_inventory


SCHEMA_VERSION = 1
DEFAULT_BASELINE = ROOT / "tools" / "art_resolution_baseline.json"
SCREENSHOT_QA = ROOT / "tools" / "ScreenshotQA.gd"
EVENT_ROOT = ROOT / "content" / "events"
ENDINGS = ROOT / "content" / "endings.json"
HIGH_ENDING_GRADES = {"A", "A+", "S", "S+"}
TARGETS: dict[str, dict[str, tuple[int, int]]] = {
    "1080p": {
        "CG": (1920, 1080),
        "Background": (1920, 1080),
        "Portrait": (512, 768),
    },
    "4k": {
        "CG": (3840, 2160),
        "Background": (3840, 2160),
        "Portrait": (1024, 1536),
    },
}
BAND_LIMITS: tuple[tuple[str, float], ...] = (
    ("native", 1.0001),
    ("light", 1.5),
    ("medium", 2.0),
    ("heavy", 3.0),
    ("severe", float("inf")),
)
BAND_ORDER = {name: index for index, (name, _limit) in enumerate(BAND_LIMITS)}


def _target_json() -> dict[str, dict[str, list[int]]]:
    return {
        output: {kind: list(size) for kind, size in kinds.items()}
        for output, kinds in TARGETS.items()
    }


def _band_json() -> dict[str, float | None]:
    return {
        name: (None if limit == float("inf") else limit)
        for name, limit in BAND_LIMITS
    }


def _required_scale(kind: str, width: int, height: int, output: str) -> float:
    target_width, target_height = TARGETS[output][kind]
    # Full-screen art uses KEEP_ASPECT_COVERED. Portrait targets represent the
    # largest authored character frame, so the same uniform-scale rule applies.
    return max(target_width / width, target_height / height)


def _scale_band(scale: float) -> str:
    for name, limit in BAND_LIMITS:
        if scale <= limit + 1e-9:
            return name
    return "severe"


def _snapshot() -> dict[str, Any]:
    assets: dict[str, Any] = {}
    counts: dict[str, dict[str, Counter[str]]] = {
        output: {kind: Counter() for kind in ("CG", "Portrait", "Background")}
        for output in TARGETS
    }
    for row in active_inventory():
        path = ROOT / row["path"]
        width, height, alpha = _raster_info(path)
        scales = {
            output: round(_required_scale(row["kind"], width, height, output), 4)
            for output in TARGETS
        }
        bands = {output: _scale_band(scale) for output, scale in scales.items()}
        for output, band in bands.items():
            counts[output][row["kind"]][band] += 1
        assets[row["path"]] = {
            "kind": row["kind"],
            "ids": row["ids"],
            "width": width,
            "height": height,
            "alpha": alpha,
            "scale": scales,
            "band": bands,
        }
    return {
        "schema_version": SCHEMA_VERSION,
        "targets": _target_json(),
        "band_limits": _band_json(),
        "inventory_count": len(assets),
        "counts": {
            output: {
                kind: {band: counter.get(band, 0) for band in BAND_ORDER}
                for kind, counter in kinds.items()
            }
            for output, kinds in counts.items()
        },
        "assets": dict(sorted(assets.items())),
    }


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _compare_baseline(current: dict[str, Any], baseline: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if int(baseline.get("schema_version", 0)) != SCHEMA_VERSION:
        errors.append("baseline schema version changed")
    if baseline.get("targets") != current.get("targets"):
        errors.append("render targets changed; review and regenerate the baseline")
    if baseline.get("band_limits") != current.get("band_limits"):
        errors.append("scale bands changed; review and regenerate the baseline")
    old_assets = baseline.get("assets", {})
    new_assets = current.get("assets", {})
    if not isinstance(old_assets, dict) or not isinstance(new_assets, dict):
        return errors + ["baseline assets are malformed"]
    old_paths = set(old_assets)
    new_paths = set(new_assets)
    if old_paths != new_paths:
        added = sorted(new_paths - old_paths)
        removed = sorted(old_paths - new_paths)
        if added:
            errors.append("resolution baseline missing active paths: " + ", ".join(added[:8]))
        if removed:
            errors.append("resolution baseline has stale paths: " + ", ".join(removed[:8]))
    for path in sorted(old_paths & new_paths):
        old = old_assets[path]
        new = new_assets[path]
        if old.get("kind") != new.get("kind"):
            errors.append(f"asset kind changed: {path}")
            continue
        old_width = int(old.get("width", 0))
        old_height = int(old.get("height", 0))
        new_width = int(new.get("width", 0))
        new_height = int(new.get("height", 0))
        if new_width < old_width or new_height < old_height:
            errors.append(
                f"asset resolution regressed: {path} "
                f"{old_width}x{old_height} -> {new_width}x{new_height}"
            )
    return errors


def _experience_exposure(paths: list[Path], snapshot: dict[str, Any]) -> Counter[str]:
    id_to_path: dict[str, str] = {}
    for path, row in snapshot["assets"].items():
        for asset_id in row.get("ids", []):
            id_to_path[str(asset_id)] = path
    exposure: Counter[str] = Counter()
    for report_path in paths:
        report = json.loads(report_path.read_text(encoding="utf-8"))
        for event in report.get("events", []):
            if not isinstance(event, dict):
                continue
            for key in ("backgrounds", "cgs"):
                for asset_id in event.get(key, []):
                    path = id_to_path.get(str(asset_id), "")
                    if path:
                        exposure[path] += 1
            for raw_path in event.get("portraits", []):
                path = str(raw_path).removeprefix("res://")
                if path in snapshot["assets"]:
                    exposure[path] += 1
    return exposure


def _records_by_id(root: Path) -> dict[str, dict[str, Any]]:
    records: dict[str, dict[str, Any]] = {}
    for path in sorted(root.rglob("*.json")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(payload, list):
            continue
        for row in payload:
            if isinstance(row, dict) and isinstance(row.get("id"), str):
                records[str(row["id"])] = row
    return records


def _visual_ids(record: dict[str, Any]) -> set[str]:
    ids: set[str] = set()

    def collect(value: Any) -> None:
        if isinstance(value, str):
            ids.add(value.removeprefix("res://"))
        elif isinstance(value, list):
            for item in value:
                collect(item)
        elif isinstance(value, dict):
            for item in value.values():
                collect(item)

    for key, value in record.items():
        lowered = str(key).lower()
        if any(
            lowered == stem
            or lowered.startswith(stem + "_")
            or lowered.endswith("_" + stem)
            or ("_" + stem + "_") in lowered
            for stem in ("background", "portrait", "cg")
        ):
            collect(value)
    return ids


def _store_contract_ids() -> tuple[set[str], set[str]]:
    source = SCREENSHOT_QA.read_text(encoding="utf-8")
    match = re.search(
        r"func _shot_store_surfaces\b(?P<body>.*?)(?=\nfunc \w)",
        source,
        re.DOTALL,
    )
    if not match:
        raise RuntimeError("ScreenshotQA store surface contract is missing")
    body = match.group("body")
    event_ids = set(
        re.findall(r'_shot_story_event\s*\(\s*"([^"]+)"', body, re.DOTALL)
    )
    ending_ids = set(
        re.findall(r'_seed_ending_state\s*\(\s*"([^"]+)"', body, re.DOTALL)
    )
    return event_ids, ending_ids


def _priority_reasons(
    snapshot: dict[str, Any],
) -> tuple[dict[str, set[str]], dict[str, set[str]]]:
    reasons: dict[str, set[str]] = defaultdict(set)
    p0_reasons: dict[str, set[str]] = defaultdict(set)
    id_to_path: dict[str, str] = {}
    for path, row in snapshot["assets"].items():
        id_to_path[path] = path
        for asset_id in row.get("ids", []):
            id_to_path[str(asset_id)] = path

    endings = json.loads(ENDINGS.read_text(encoding="utf-8"))
    endings_by_id = {
        str(row["id"]): row
        for row in endings
        if isinstance(row, dict) and isinstance(row.get("id"), str)
    }
    for ending in endings_by_id.values():
        grade = str(ending.get("grade", "?"))
        for asset_id in _visual_ids(ending):
            path = id_to_path.get(asset_id, "")
            if not path:
                continue
            reasons[path].add("ending")
            if grade in HIGH_ENDING_GRADES:
                p0_reasons[path].add(f"grade {grade} ending")

    events = _records_by_id(EVENT_ROOT)
    store_event_ids, store_ending_ids = _store_contract_ids()
    for event_id in store_event_ids:
        event = events.get(event_id)
        if not event:
            raise RuntimeError(f"Store ScreenshotQA event is missing: {event_id}")
        for asset_id in _visual_ids(event):
            path = id_to_path.get(asset_id, "")
            if path:
                p0_reasons[path].add("Steam store surface")
    for ending_id in store_ending_ids:
        ending = endings_by_id.get(ending_id)
        if not ending:
            raise RuntimeError(f"Store ScreenshotQA ending is missing: {ending_id}")
        for asset_id in _visual_ids(ending):
            path = id_to_path.get(asset_id, "")
            if path:
                p0_reasons[path].add("Steam store surface")

    main_source = (ROOT / "scenes" / "MainGame.gd").read_text(encoding="utf-8")
    for path, row in snapshot["assets"].items():
        if path in main_source:
            reasons[path].add("AP/runtime")
    return reasons, p0_reasons


def _summary_rows(snapshot: dict[str, Any]) -> list[dict[str, Any]]:
    rows = []
    for kind in ("CG", "Portrait", "Background"):
        assets = [row for row in snapshot["assets"].values() if row["kind"] == kind]
        rows.append(
            {
                "kind": kind,
                "count": len(assets),
                "median_source": "%dx%d"
                % (
                    round(statistics.median(row["width"] for row in assets)),
                    round(statistics.median(row["height"] for row in assets)),
                ),
                "native_1080": sum(row["band"]["1080p"] == "native" for row in assets),
                "native_4k": sum(row["band"]["4k"] == "native" for row in assets),
                "median_4k": statistics.median(row["scale"]["4k"] for row in assets),
                "max_4k": max(row["scale"]["4k"] for row in assets),
            }
        )
    return rows


def _write_report(
    path: Path, snapshot: dict[str, Any], experience_paths: list[Path]
) -> None:
    exposure = _experience_exposure(experience_paths, snapshot)
    reasons, p0_reasons = _priority_reasons(snapshot)
    ranked = []
    for asset_path, row in snapshot["assets"].items():
        priority = (
            "P0"
            if exposure[asset_path] or p0_reasons[asset_path]
            else ("P1" if reasons[asset_path] else "P2")
        )
        ranked.append(
            (
                priority,
                -float(row["scale"]["4k"]),
                -exposure[asset_path],
                asset_path,
                row,
            )
        )
    ranked.sort()
    priority_counts = Counter(item[0] for item in ranked)
    lines = [
        "# Active Art Resolution Readiness",
        "",
        "> Generated from `autoloads/ImageRegistry.gd`. Dimension readiness is not a human art verdict.",
        "",
        "## Summary",
        "",
        "| Kind | Active | Median source | Native at 1080p | Native at 4K | Median 4K scale | Worst 4K scale |",
        "|---|---:|---:|---:|---:|---:|---:|",
    ]
    for row in _summary_rows(snapshot):
        lines.append(
            "| {kind} | {count} | {median_source} | {native_1080}/{count} | "
            "{native_4k}/{count} | {median_4k:.2f}x | {max_4k:.2f}x |".format(**row)
        )
    lines.extend(
        [
            "",
            "Scale bands: native <=1.00x, light <=1.50x, medium <=2.00x, "
            "heavy <=3.00x, severe >3.00x.",
            "",
            "The 1080p/4K CG and background targets model full-screen `KEEP_ASPECT_COVERED`. "
            "Portrait targets model the largest authored transparent character frame.",
            "",
            "## Priority",
            "",
            f"- P0 demo, Steam store, or grade A-or-higher ending: {priority_counts['P0']}",
            f"- P1 ending or AP/runtime surface: {priority_counts['P1']}",
            f"- P2 remaining active library: {priority_counts['P2']}",
            "",
            "| Priority | Kind | Asset | Demo hits | 1080p | 4K | Reason |",
            "|---|---|---|---:|---:|---:|---|",
        ]
    )
    visible_rows = [item for item in ranked if item[0] in ("P0", "P1")]
    for priority, _negative_scale, _negative_hits, asset_path, row in visible_rows:
        reason = ", ".join(sorted(reasons[asset_path]))
        priority_reason = ", ".join(sorted(p0_reasons[asset_path]))
        reason = ", ".join(filter(None, [priority_reason, reason]))
        if exposure[asset_path]:
            reason = ", ".join(filter(None, [f"demo x{exposure[asset_path]}", reason]))
        lines.append(
            f"| {priority} | {row['kind']} | `{asset_path}` | {exposure[asset_path]} | "
            f"{row['scale']['1080p']:.2f}x {row['band']['1080p']} | "
            f"{row['scale']['4k']:.2f}x {row['band']['4k']} | {reason} |"
        )
    lines.extend(
        [
            "",
            "## Production Decision",
            "",
            "1. P0 people/hand/lettering CGs: return to identity references and repaint or regenerate at the final master size. Blind super-resolution is not an approval pass.",
            "2. P0/P1 clean environments without readable signs or foreground anatomy: run a deterministic offline super-resolution comparison, then inspect 100% crops before replacement.",
            "3. Transparent portraits: use an alpha-aware 2x process and inspect hair edges, eye identity, hands, and outfit silhouette against the current portrait contract.",
            "4. Do not ship simple Lanczos/bicubic enlargement as a new master. It changes file dimensions without adding recoverable detail and this audit intentionally cannot certify it.",
            "5. Every replacement still requires `ART_AI_AUDIT`, scene ownership checks, KO/EN ScreenshotQA, and a source/license record.",
            "",
            "## Open Human Gates",
            "",
            "- 100% pixel inspection on a 4K panel and normal sofa distance on a 4K TV.",
            "- Face, gaze, hand, prop, lettering, architecture, and crop continuity review.",
            "- A/B comparison of the actual game frame, not the isolated source file.",
            "- Physical Steam Deck review remains separate; 1280x800 is its native layout target.",
            "",
        ]
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path, default=DEFAULT_BASELINE)
    parser.add_argument("--write-baseline", action="store_true")
    parser.add_argument("--report", type=Path)
    parser.add_argument("--experience-report", type=Path, action="append", default=[])
    parser.add_argument("--inventory-json", type=Path)
    args = parser.parse_args()

    snapshot = _snapshot()
    if args.write_baseline:
        _write_json(args.baseline, snapshot)
        print(f"ART_RESOLUTION_BASELINE_WRITTEN path={args.baseline} assets={snapshot['inventory_count']}")
    if args.inventory_json:
        _write_json(args.inventory_json, snapshot)
    missing_reports = [path for path in args.experience_report if not path.exists()]
    if missing_reports:
        for path in missing_reports:
            print(f"ART_RESOLUTION_ERROR missing experience report: {path}")
        return 1
    if args.report:
        _write_report(args.report, snapshot, args.experience_report)
        print(f"ART_RESOLUTION_REPORT path={args.report}")

    if not args.baseline.exists():
        print(f"ART_RESOLUTION_ERROR missing baseline: {args.baseline}")
        return 1
    baseline = json.loads(args.baseline.read_text(encoding="utf-8"))
    errors = _compare_baseline(snapshot, baseline)
    counts = snapshot["counts"]
    native_1080 = sum(
        kinds["native"] for kinds in counts["1080p"].values()
    )
    native_4k = sum(kinds["native"] for kinds in counts["4k"].values())
    heavy_4k = sum(
        kinds["heavy"] + kinds["severe"] for kinds in counts["4k"].values()
    )
    print(
        "ART_RESOLUTION_AUDIT inventory=%d native_1080=%d native_4k=%d heavy_4k=%d baseline=locked"
        % (snapshot["inventory_count"], native_1080, native_4k, heavy_4k)
    )
    for error in errors:
        print("ART_RESOLUTION_ERROR " + error)
    if errors:
        return 1
    print("ART_RESOLUTION_AUDIT_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())

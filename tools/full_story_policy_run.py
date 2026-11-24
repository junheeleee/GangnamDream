#!/usr/bin/env python3
"""ORDER-838 D1 — new-story policy runs (measurement, not a product gate).

Subcommands:
  profiles            write tools/full_story_policy_profiles.json (6 policies × seeds)
  run                 run FullStoryPolicyRun.tscn headless for selected profiles,
                      each in its own user-data directory, N in parallel
  summary             summarize traces into ending distribution, M24/M48/M60
                      total assets, story gaps and decision-free months

The runner drives the real product flow (see tools/FullStoryPolicyRun.gd). It needs
`godot` on PATH (or GODOT=/path) and a clean, imported checkout.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import statistics
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROFILES = ROOT / "tools" / "full_story_policy_profiles.json"
SCENE = "res://tools/FullStoryPolicyRun.tscn"
BASE_SEED = 2026112400

ACTION_FUNCS = {
    "contact": "_ap_contact_person",
    "rest": "_ap_free_time",
    "side_shift": "_ap_side_job",
    "apply": "_ap_job_hunt",
    "resume": "_ap_write_resume",
    "study": "_ap_study",
    "save": "_ap_save_money",
    "invest": "_ap_invest",
}

# Weights are a measurement assumption, not balance canon. [첫 실행 재조정]
POLICIES: dict[str, dict] = {
    "diligent": {
        "description": "성실: 직장·저축, 위험과 중독 회피",
        "actions": ["apply", "resume", "side_shift", "save", "study", "rest", "contact", "invest"],
        "effect_weights": {"money": 0.3, "health": 0.5, "mental": 0.3, "reputation": 0.5,
                           "intelligence": 0.3, "work_performance": 1.0, "social_skill": 0.2,
                           "tint": 0.2, "addiction_tendency": -3.0, "gambling_tendency": -3.0},
        "keyword_weights": {"출근": 1.0, "저축": 2.0, "베팅": -3.0, "대출": -2.0, "코인": -1.0},
    },
    "invest": {
        "description": "투자: 834 A 결정 일관",
        "actions": ["invest", "study", "save", "apply", "resume", "side_shift", "rest", "contact"],
        "effect_weights": {"investment_skill": 1.0, "money": 0.6, "intelligence": 0.3,
                           "mental": 0.1, "addiction_tendency": -1.0},
        "keyword_weights": {"투자": 3.0, "매수": 3.0, "주식": 3.0, "ETF": 3.0, "부동산": 2.0,
                            "포트폴리오": 2.0, "코인": 1.5, "공부": 1.0, "invest": 2.0},
    },
    "gamble": {
        "description": "도박: 834 B 결정 일관",
        "actions": ["side_shift", "invest", "contact", "rest", "apply", "resume", "study", "save"],
        "effect_weights": {"addiction_tendency": 1.0, "gambling_tendency": 2.0, "luck": 0.5, "money": 0.3},
        "keyword_weights": {"베팅": 3.0, "경마": 3.0, "카지노": 3.0, "홀덤": 3.0, "칩": 2.0,
                            "한 판": 2.0, "한 번만": 2.0, "race": 2.0, "casino": 2.0, "gambl": 2.0},
    },
    "people": {
        "description": "관계 우선: 사람 갈래 결정 우선",
        "actions": ["contact", "rest", "apply", "resume", "side_shift", "study", "save", "invest"],
        "effect_weights": {"social_skill": 0.8, "mental": 0.5, "reputation": 0.3, "tint": 0.3, "money": 0.1},
        "keyword_weights": {"아버지": 2.0, "다은": 2.0, "지연": 2.0, "현수": 2.0, "재혁": 1.0,
                            "만나": 2.0, "연락": 2.0, "전화": 2.0, "같이": 1.0, "함께": 1.0},
    },
    "overreach": {
        "description": "무리한 상승: 레버리지·밤샘·대출 수락",
        "actions": ["side_shift", "invest", "apply", "resume", "study", "save", "contact", "rest"],
        "effect_weights": {"money": 1.0, "investment_skill": 0.3, "work_performance": 0.5},
        "keyword_weights": {"대출": 3.0, "레버리지": 3.0, "올인": 3.0, "밤샘": 2.0, "야근": 2.0,
                            "수락": 2.0, "받는다": 1.0},
    },
    "recovery": {
        "description": "회복: 836 회복 결정 우선",
        "actions": ["rest", "contact", "study", "apply", "resume", "save", "side_shift", "invest"],
        "effect_weights": {"health": 1.0, "mental": 1.0, "addiction_tendency": -3.0,
                           "gambling_tendency": -3.0, "money": 0.1},
        "keyword_weights": {"쉬": 2.0, "병원": 3.0, "상담": 3.0, "끊": 3.0, "잠": 2.0,
                            "산책": 2.0, "거절": 1.0},
    },
}


def build_profiles(seeds: int, explore: float) -> dict:
    rows = []
    for name, spec in POLICIES.items():
        for i in range(seeds):
            actions = spec["actions"]
            rows.append({
                "id": f"{name}_s{i + 1:02d}",
                "description": spec["description"],
                "seed": BASE_SEED + 1000 * list(POLICIES).index(name) + i,
                "locale": "ko",
                "input_mode": "keyboard",
                "default_choice": {"index": 0, "selection_mode": "policy"},
                "choice_policy": {
                    "explore_rate": explore,
                    "effect_weights": spec["effect_weights"],
                    "keyword_weights": spec["keyword_weights"],
                },
                "modal_policy": {"study_type": 0},
                "main_action_priority": actions,
                "main_function_priority": [ACTION_FUNCS[a] for a in actions],
                "survival_policy": None if name == "overreach" else {
                    "enter_health_at_or_below": 30,
                    "enter_mental_at_or_below": 30,
                    "resume_health_at_or_above": 45,
                    "resume_mental_at_or_above": 45,
                    "action_priority": ["rest", "contact"],
                    "function_priority": ["_ap_free_time", "_ap_contact_person"],
                },
                "asset_band_policy": None,
                "required_event_sequence": [],
                "required_edges": [],
                "required_event_occurrences": {},
                "target": {
                    "minimum_week": 1,
                    "ending_page_count": 6,
                    "minimum_total_assets": None,
                    "maximum_total_assets": None,
                    "required_flags_true": [],
                    "required_flags_false": [],
                    "required_ending_ids": [],
                    "forbidden_ending_ids": [],
                },
            })
    return {"schema_version": 1, "trace_schema_version": 1,
            "scope": {"purpose": "ORDER-838 D1 policy runs; measurement only",
                      "product_go": "HOLD", "human_density_gate": "OPEN"},
            "profiles": rows}


def profile_hash(profile_id: str) -> str:
    data = PROFILES.read_bytes()
    return hashlib.sha256(data + b"\0" + profile_id.encode()).hexdigest()


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True,
                          check=True).stdout.strip()


def run_one(profile_id: str, out_dir: Path, timeout: int) -> tuple[str, int, str]:
    godot = os.environ.get("GODOT", "godot")
    home = out_dir / "home" / profile_id
    home.mkdir(parents=True, exist_ok=True)
    trace = out_dir / f"{profile_id}.jsonl"
    if trace.exists():
        trace.unlink()
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(home / "data"),
               XDG_CONFIG_HOME=str(home / "config"), XDG_CACHE_HOME=str(home / "cache"))
    cmd = [godot, "--headless", "--path", str(ROOT), SCENE, "--",
           f"--profile={profile_id}", f"--profiles={PROFILES}",
           f"--trace-output={trace}", f"--candidate-commit={git('rev-parse', 'HEAD')}",
           f"--candidate-tree={git('rev-parse', 'HEAD^{tree}')}", "--candidate-dirty=false",
           f"--profile-hash={profile_hash(profile_id)}"]
    try:
        proc = subprocess.run(cmd, cwd=ROOT, env=env, capture_output=True, text=True, timeout=timeout)
        tail = "\n".join((proc.stdout + proc.stderr).strip().splitlines()[-2:])
    except subprocess.TimeoutExpired:
        tail, proc = "timeout", None
    if trace.exists():
        # Traces grow with the event log; keep a compact summary and a gzip copy.
        result = {"id": profile_id, **read_trace(trace)}
        (out_dir / f"{profile_id}.summary.json").write_text(
            json.dumps(result, ensure_ascii=False), encoding="utf-8")
        subprocess.run(["gzip", "-f", str(trace)], check=False)
    return profile_id, (proc.returncode if proc else -9), tail


def read_trace(path: Path) -> dict:
    weeks_story: set[int] = set()
    weeks_choice: set[int] = set()
    assets_by_week: dict[int, float] = {}
    money_by_week: dict[int, float] = {}
    ending = ""
    last_week = 0
    errors: list[str] = []
    events = Counter()
    final: dict = {}
    with path.open(encoding="utf-8") as fh:
        for line in fh:
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue
            week = int(row.get("week", 0) or 0)
            last_week = max(last_week, week)
            kind = row.get("record_type")
            payload = row.get("payload", {}) or {}
            if kind == "story_enter":
                weeks_story.add(week)
                events[str(payload.get("event_id", ""))] += 1
            elif kind == "choice_offer":
                if len(payload.get("choices") or []) >= 2:
                    weeks_choice.add(week)
            elif kind in ("week_open", "week_close"):
                state = payload.get("state") or payload.get("state_after") or payload.get("state_before") or {}
                if isinstance(state, dict) and "total_assets" in state:
                    assets_by_week[week] = float(state["total_assets"])
                    money_by_week[week] = float(state.get("money", 0))
            elif kind == "ending_open":
                ending = str(payload.get("ending_id", "")) or ending
            elif kind == "run_end":
                fs = payload.get("final_state") or {}
                if isinstance(fs, dict):
                    final = {k: fs.get(k) for k in ("total_assets", "money", "health", "mental",
                                                    "player_route", "tendency_realized")}
            elif kind == "trace_error":
                errors.append(str(payload.get("message", payload))[:160])
    def at(week: int) -> float | None:
        keys = [w for w in assets_by_week if w <= week]
        return assets_by_week[max(keys)] if keys and last_week >= week else None
    gaps, run = [], 0
    for w in range(1, last_week + 1):
        if w in weeks_story:
            if run >= 4:
                gaps.append(run)
            run = 0
        else:
            run += 1
    if run >= 4:
        gaps.append(run)
    months_no_decision = sum(
        1 for m in range(1, last_week // 4 + 1)
        if not any(w in weeks_choice for w in range(4 * m - 3, 4 * m + 1)))
    return {"ending": ending or ("(none)" if last_week >= 240 else f"(stopped W{last_week})"),
            "last_week": last_week, "m24": at(96), "m48": at(192), "m60": at(240),
            "gaps_ge4": gaps, "longest_gap": max(gaps) if gaps else 0,
            "months_no_decision": months_no_decision, "story_events": sum(events.values()),
            "final": final, "errors": errors[:2]}


def fmt_won(v: float | None) -> str:
    if v is None:
        return "—"
    if abs(v) >= 1e8:
        return f"{v / 1e8:.1f}억"
    return f"{v / 1e4:,.0f}만"


def summary(out_dir: Path) -> str:
    by_policy: dict[str, list[dict]] = defaultdict(list)
    for path in sorted(out_dir.glob("*.summary.json")):
        row = json.loads(path.read_text(encoding="utf-8"))
        by_policy[row["id"].rsplit("_s", 1)[0]].append(row)
    for path in sorted(out_dir.glob("*.jsonl")):
        if (out_dir / f"{path.stem}.summary.json").exists():
            continue
        name = path.stem.rsplit("_s", 1)[0]
        by_policy[name].append({"id": path.stem, **read_trace(path)})
    lines = ["| 정책 | 런 | 엔딩 분포 | M24 중앙 | M48 중앙 | M60 중앙 | 4주+ 공백(평균 개수/최장) | 결정 없는 달(평균) |",
             "|---|---:|---|---:|---:|---:|---:|---:|"]
    detail = ["", "| 런 | 마지막 주 | 엔딩 | M24 | M48 | M60 | 최장 공백 | 결정 없는 달 | 오류 |",
              "|---|---:|---|---:|---:|---:|---:|---:|---|"]
    for name, rows in sorted(by_policy.items()):
        endings = Counter(r["ending"] for r in rows)
        def med(key: str) -> str:
            vals = [r[key] for r in rows if r[key] is not None]
            return fmt_won(statistics.median(vals)) if vals else "—"
        gap_n = statistics.mean(len(r["gaps_ge4"]) for r in rows)
        gap_max = max(r["longest_gap"] for r in rows)
        nodec = statistics.mean(r["months_no_decision"] for r in rows)
        dist = ", ".join(f"{k} {v}" for k, v in endings.most_common())
        lines.append(f"| {name} | {len(rows)} | {dist} | {med('m24')} | {med('m48')} | {med('m60')} | "
                     f"{gap_n:.1f}/{gap_max} | {nodec:.1f} |")
        for r in rows:
            detail.append(f"| {r['id']} | {r['last_week']} | {r['ending']} | {fmt_won(r['m24'])} | "
                          f"{fmt_won(r['m48'])} | {fmt_won(r['m60'])} | {r['longest_gap']} | "
                          f"{r['months_no_decision']} | {'; '.join(r['errors'])} |")
    total = Counter(r["ending"] for rows in by_policy.values() for r in rows)
    n = sum(total.values()) or 1
    top = total.most_common(1)[0] if total else ("—", 0)
    lines.append("")
    lines.append(f"전체 {n}런, 서로 다른 엔딩 {len(total)}종, 최다 엔딩 {top[0]} {top[1] / n:.0%}.")
    return "\n".join(lines + detail)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("profiles")
    p.add_argument("--seeds", type=int, default=3)
    p.add_argument("--explore", type=float, default=0.15)
    r = sub.add_parser("run")
    r.add_argument("--out", type=Path, required=True)
    r.add_argument("--only", default="", help="comma-separated profile ids or policy names")
    r.add_argument("--jobs", type=int, default=3)
    r.add_argument("--timeout", type=int, default=5400)
    s = sub.add_parser("summary")
    s.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    if args.cmd == "profiles":
        PROFILES.write_text(json.dumps(build_profiles(args.seeds, args.explore), ensure_ascii=False,
                                       indent=2) + "\n", encoding="utf-8")
        print(f"wrote {PROFILES.relative_to(ROOT)}")
        return 0
    if args.cmd == "run":
        if git("status", "--porcelain"):
            print("refusing to run on a dirty tree (trace identity must be clean)", file=sys.stderr)
            return 2
        ids = [row["id"] for row in json.loads(PROFILES.read_text(encoding="utf-8"))["profiles"]]
        if args.only:
            wanted = [w.strip() for w in args.only.split(",") if w.strip()]
            ids = [i for i in ids if i in wanted or i.rsplit("_s", 1)[0] in wanted]
        args.out.mkdir(parents=True, exist_ok=True)
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
            for pid, code, tail in pool.map(lambda i: run_one(i, args.out, args.timeout), ids):
                print(f"{pid} exit={code} {tail}", flush=True)
        return 0
    print(summary(args.out))
    return 0


if __name__ == "__main__":
    sys.exit(main())

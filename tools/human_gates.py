#!/usr/bin/env python3
"""자동으로 잴 수 없는 판정을 출력하고, 원장이 실제와 어긋나면 실패한다.

`identity_signature_audit`만 하던 일을 모든 도메인으로 넓힌 것이다. 못 재는 것을
조용히 넘어가면 초록불이 "다 됐다"로 읽힌다. **이 도구는 아무것도 통과시키지
않는다** — 남은 사람 판정을 매번 화면에 올려 초록불의 뜻을 좁히는 것이 전부다.

    python3 tools/human_gates.py            # 열린 게이트 전부 + 원장 검사
    python3 tools/human_gates.py --domain audio
    python3 tools/human_gates.py --scope demo

검사 도구에서 자기 도메인 몫만 찍으려면:

    from human_gates import print_pending
    print_pending("audio")
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/human_gates.json"
QUEUE = ROOT / "docs/CODEX_QUEUE.md"
SCHEMA_VERSION = 2
CANDIDATE_STATES = {"waiting_rebuild", "active"}
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
ORDER_RE = re.compile(r"^(?:ORDER|USER)-[\w]+$")


class LedgerValidationError(ValueError):
    """Machine-readable human-gate ledger is absent, malformed, or unbound."""

    def __init__(self, errors: list[str]):
        self.errors = errors
        super().__init__("; ".join(errors))


def load_ledger() -> dict[str, Any] | None:
    if not LEDGER.is_file():
        return None
    try:
        data = json.loads(LEDGER.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    return data if isinstance(data, dict) else None


def load() -> list[dict]:
    """Backward-compatible gate list used by domain-specific audit imports."""
    ledger = load_ledger() or {}
    gates = ledger.get("gates", [])
    return [g for g in gates if isinstance(g, dict)] if isinstance(gates, list) else []


def scope_blocks(gate: dict, release_scope: str) -> bool:
    scope = gate.get("scope", {})
    blocks = scope.get("blocks", []) if isinstance(scope, dict) else []
    return release_scope in blocks


def open_gates(domain: str | None = None, release_scope: str | None = None) -> list[dict]:
    return [
        gate for gate in load()
        if gate.get("state") == "open"
        and (domain is None or gate.get("domain") == domain)
        and (release_scope is None or scope_blocks(gate, release_scope))
    ]


def known_orders() -> set[str]:
    """실행 큐와 보존 사양에 실재하는 오더 ID.

    사람 판정만 남은 사양은 실행 큐에서 빠져도 된다. 큐 표만 검사하면 완료 증거를
    보존하기 위해 유령 실행 행을 남겨야 하므로 active/backlog/archive 파일도 본다.
    """
    orders: set[str] = set()
    if QUEUE.is_file():
        orders |= set(re.findall(
            r"\|\s*((?:ORDER|USER)-[\w]+)\s*·",
            QUEUE.read_text(encoding="utf-8"),
        ))
    for folder_name in ("queue_active", "queue_backlog", "queue_archive"):
        folder = ROOT / "docs" / folder_name
        if not folder.is_dir():
            continue
        for path in folder.glob("*.md"):
            if ORDER_RE.fullmatch(path.stem):
                orders.add(path.stem)
    return orders


def _nonempty_strings(value: Any) -> bool:
    return (
        isinstance(value, list)
        and bool(value)
        and all(isinstance(item, str) and bool(item.strip()) for item in value)
    )


def validate_ledger(ledger: Any) -> list[str]:
    """Validate schema and evidence binding without treating open work as failure.

    `waiting_rebuild` is a valid development state. It becomes a hard error only when a
    consumer, such as the external playtest reporter, asks for an active candidate.
    """
    if not isinstance(ledger, dict):
        return ["ledger root must be an object"]

    errors: list[str] = []
    if ledger.get("schema_version") != SCHEMA_VERSION:
        errors.append(f"schema_version must be {SCHEMA_VERSION}")

    candidates = ledger.get("release_candidates")
    if not isinstance(candidates, dict) or not candidates:
        errors.append("release_candidates must be a non-empty object")
        candidates = {}
    for candidate_id, candidate in candidates.items():
        prefix = f"release_candidates.{candidate_id}"
        if not isinstance(candidate_id, str) or not candidate_id.strip():
            errors.append("release_candidates contains an empty id")
            continue
        if not isinstance(candidate, dict):
            errors.append(f"{prefix} must be an object")
            continue
        required = {"status", "commit", "tree", "manifest_sha256"}
        missing = sorted(required - candidate.keys())
        unknown = sorted(candidate.keys() - required - {"note"})
        if missing:
            errors.append(f"{prefix} missing fields: {', '.join(missing)}")
        if unknown:
            errors.append(f"{prefix} unknown fields: {', '.join(unknown)}")
        status = candidate.get("status")
        if status not in CANDIDATE_STATES:
            errors.append(
                f"{prefix}.status must be one of {sorted(CANDIDATE_STATES)}"
            )
        hashes = {
            "commit": candidate.get("commit"),
            "tree": candidate.get("tree"),
            "manifest_sha256": candidate.get("manifest_sha256"),
        }
        if status == "waiting_rebuild":
            for field, value in hashes.items():
                if value is not None:
                    errors.append(f"{prefix}.{field} must be null while waiting_rebuild")
        elif status == "active":
            for field in ("commit", "tree"):
                if not isinstance(hashes[field], str) or not COMMIT_RE.fullmatch(hashes[field]):
                    errors.append(f"{prefix}.{field} must be a full lowercase Git hash")
            manifest = hashes["manifest_sha256"]
            if not isinstance(manifest, str) or not SHA256_RE.fullmatch(manifest):
                errors.append(f"{prefix}.manifest_sha256 must be a lowercase SHA-256")
        note = candidate.get("note")
        if note is not None and (not isinstance(note, str) or not note.strip()):
            errors.append(f"{prefix}.note must be non-empty text when present")

    gates = ledger.get("gates")
    if not isinstance(gates, list) or not gates:
        errors.append("gates must be a non-empty array")
        return errors

    seen: set[str] = set()
    orders = known_orders()
    required_gate_fields = {
        "id", "domain", "gate", "why", "owner", "state",
        "scope", "revision", "sample", "acceptance",
    }
    allowed_gate_fields = required_gate_fields | {"evidence"}
    for index, gate in enumerate(gates):
        if not isinstance(gate, dict):
            errors.append(f"gates[{index}] must be an object")
            continue
        gid = gate.get("id") if isinstance(gate.get("id"), str) else ""
        prefix = gid or f"gates[{index}]"
        missing = sorted(required_gate_fields - gate.keys())
        unknown = sorted(gate.keys() - allowed_gate_fields)
        if missing:
            errors.append(f"{prefix} missing fields: {', '.join(missing)}")
        if unknown:
            errors.append(f"{prefix} unknown fields: {', '.join(unknown)}")
        for field in ("id", "domain", "gate", "why", "owner", "revision"):
            if not isinstance(gate.get(field), str) or not gate.get(field, "").strip():
                errors.append(f"{prefix}: {field} must be non-empty text")
        if gid in seen:
            errors.append(f"{prefix}: duplicate id")
        seen.add(gid)

        state = gate.get("state")
        if state not in {"open", "done"}:
            errors.append(f"{prefix}: state must be open or done")
        owner = gate.get("owner")
        if isinstance(owner, str) and owner and owner not in orders:
            errors.append(f"{prefix}: owner {owner} has no queue/archive/backlog spec")

        scope = gate.get("scope")
        if not isinstance(scope, dict):
            errors.append(f"{prefix}.scope must be an object")
        else:
            if set(scope) != {"blocks", "content"}:
                errors.append(f"{prefix}.scope fields must be blocks and content")
            blocks = scope.get("blocks")
            if not _nonempty_strings(blocks):
                errors.append(f"{prefix}.scope.blocks must be non-empty text array")
            elif len(blocks) != len(set(blocks)):
                errors.append(f"{prefix}.scope.blocks contains duplicates")
            content = scope.get("content")
            if not isinstance(content, str) or not content.strip():
                errors.append(f"{prefix}.scope.content must be non-empty text")

        revision_id = gate.get("revision")
        candidate = candidates.get(revision_id) if isinstance(revision_id, str) else None
        if revision_id and candidate is None:
            errors.append(f"{prefix}.revision references unknown candidate {revision_id}")

        sample = gate.get("sample")
        if not isinstance(sample, dict):
            errors.append(f"{prefix}.sample must be an object")
        else:
            if set(sample) != {"cohort", "requirements"}:
                errors.append(f"{prefix}.sample fields must be cohort and requirements")
            cohort = sample.get("cohort")
            if not isinstance(cohort, str) or not cohort.strip():
                errors.append(f"{prefix}.sample.cohort must be non-empty text")
            if not _nonempty_strings(sample.get("requirements")):
                errors.append(f"{prefix}.sample.requirements must be non-empty text array")
        if not _nonempty_strings(gate.get("acceptance")):
            errors.append(f"{prefix}.acceptance must be a non-empty text array")

        evidence = gate.get("evidence")
        if state == "open" and evidence is not None:
            errors.append(f"{prefix}: open gate must not carry completion evidence")
        if state != "done":
            continue
        if not isinstance(evidence, dict):
            errors.append(f"{prefix}: done gate requires structured evidence")
            continue
        evidence_fields = {
            "decided_at", "decided_by", "verdict", "commit", "tree",
            "manifest_sha256", "record",
        }
        missing_evidence = sorted(evidence_fields - evidence.keys())
        unknown_evidence = sorted(evidence.keys() - evidence_fields)
        if missing_evidence:
            errors.append(f"{prefix}.evidence missing fields: {', '.join(missing_evidence)}")
        if unknown_evidence:
            errors.append(f"{prefix}.evidence unknown fields: {', '.join(unknown_evidence)}")
        if not isinstance(evidence.get("decided_at"), str) or not DATE_RE.fullmatch(
            evidence.get("decided_at", "")
        ):
            errors.append(f"{prefix}.evidence.decided_at must be YYYY-MM-DD")
        for field in ("decided_by", "record"):
            if not isinstance(evidence.get(field), str) or not evidence.get(field, "").strip():
                errors.append(f"{prefix}.evidence.{field} must be non-empty text")
        if evidence.get("verdict") != "GO":
            errors.append(f"{prefix}.evidence.verdict must be GO")
        if not isinstance(candidate, dict) or candidate.get("status") != "active":
            errors.append(f"{prefix}: done gate requires an active revision")
            continue
        for field in ("commit", "tree", "manifest_sha256"):
            if evidence.get(field) != candidate.get(field):
                errors.append(f"{prefix}.evidence.{field} does not match active revision")

    return errors


def canonical_active_candidate(
    gate_id: str, ledger: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Return the exact active candidate bound to a gate or raise a useful error."""
    data = ledger if ledger is not None else load_ledger()
    if data is None:
        raise LedgerValidationError(["docs/human_gates.json cannot be read"])
    errors = validate_ledger(data)
    if errors:
        raise LedgerValidationError(errors)
    gate = next((g for g in data["gates"] if g.get("id") == gate_id), None)
    if gate is None:
        raise LedgerValidationError([f"unknown human gate {gate_id}"])
    revision_id = gate["revision"]
    candidate = data["release_candidates"][revision_id]
    if candidate["status"] != "active":
        raise LedgerValidationError([
            f"{gate_id}: canonical candidate {revision_id} is {candidate['status']}; "
            "new human sessions are blocked until a clean RC is active"
        ])
    return {"id": revision_id, **candidate}


def _candidate_label(ledger: dict[str, Any], gate: dict) -> str:
    revision_id = str(gate.get("revision", "?"))
    candidates = ledger.get("release_candidates", {})
    candidate = candidates.get(revision_id, {}) if isinstance(candidates, dict) else {}
    if candidate.get("status") == "active":
        return (
            f"{revision_id} {str(candidate.get('commit', ''))[:8]} / "
            f"manifest {str(candidate.get('manifest_sha256', ''))[:8]}"
        )
    if candidate.get("status") == "waiting_rebuild":
        return f"{revision_id} · 재빌드 대기"
    return f"{revision_id} · 상태 오류"


def _scope_label(gate: dict) -> str:
    scope = gate.get("scope", {})
    if not isinstance(scope, dict):
        return "범위 오류"
    return f"{', '.join(scope.get('blocks', []))} · {scope.get('content', '')}"


def print_pending(domain: str, indent: str = "  ") -> None:
    """검사 도구가 자기 도메인 몫을 찍는다. 아무것도 판정하지 않는다."""
    ledger = load_ledger() or {}
    gates = [g for g in open_gates(domain)]
    if not gates:
        return
    print(f"\n{indent}사람 판정 대기 — 자동으로 잴 수 없다. 통과 처리하지 않는다.")
    for gate in gates:
        print(
            f"{indent}  · {gate.get('gate', '<이름 없음>')}  "
            f"[{gate.get('owner', '?')} · {_candidate_label(ledger, gate)}]"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--domain")
    parser.add_argument("--scope", dest="release_scope")
    args = parser.parse_args()

    ledger = load_ledger()
    if ledger is None:
        print("HUMAN_GATES_FAIL — docs/human_gates.json 을 읽을 수 없다")
        return 1
    errors = validate_ledger(ledger)
    if errors:
        print("HUMAN_GATES_FAIL")
        for error in errors:
            print(f"  ERROR: {error}")
        return 1

    gates = ledger["gates"]
    rows = [
        gate for gate in gates
        if gate["state"] == "open"
        and (args.domain is None or gate["domain"] == args.domain)
        and (args.release_scope is None or scope_blocks(gate, args.release_scope))
    ]
    filters = []
    if args.domain:
        filters.append(f"domain={args.domain}")
    if args.release_scope:
        filters.append(f"scope={args.release_scope}")
    suffix = f" ({', '.join(filters)})" if filters else ""
    print(f"● 사람 판정 대기{suffix} — 자동 검사가 대신할 수 없다. 통과 처리하지 않는다.")
    if not rows:
        print("    (열린 게이트 없음)")
    for domain in sorted({gate["domain"] for gate in rows}):
        print(f"\n  [{domain}]")
        for gate in [row for row in rows if row["domain"] == domain]:
            print(f"    · {gate['gate']}  [{gate['owner']}]")
            print(f"      범위 — {_scope_label(gate)}")
            print(f"      후보 — {_candidate_label(ledger, gate)}")
            sample = gate["sample"]
            print(f"      표본 — {sample['cohort']}: {' / '.join(sample['requirements'])}")
            for acceptance in gate["acceptance"]:
                print(f"      합격 — {acceptance}")
            print(f"      왜 사람이어야 하나 — {gate['why']}")

    done = sum(1 for gate in gates if gate.get("state") == "done")
    open_count = sum(1 for gate in gates if gate.get("state") == "open")
    waiting = sum(
        1 for candidate in ledger["release_candidates"].values()
        if candidate.get("status") == "waiting_rebuild"
    )
    print(f"\nHUMAN_GATES_OK open={open_count} done={done} total={len(gates)}")
    print(f"  canonical_candidates_waiting_rebuild={waiting}")
    print("  이 도구는 아무것도 통과시키지 않는다. 초록불은 계약을 지켰다는 뜻이지")
    print("  좋다는 뜻이 아니다.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

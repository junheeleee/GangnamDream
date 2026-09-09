#!/usr/bin/env python3
"""자동으로 잴 수 없는 판정을 출력하고, 원장이 실제와 어긋나면 실패한다.

인간 증거 원장과 별도 에이전트 최종 판정을 구분한다. 구조 검사 성공은 품질 GO가
아니다. 위임된 개발 판단은 계속하되 미관찰 인간 증거를 발급하지 않는다.

    python3 tools/human_gates.py            # 열린 게이트 전부 + 원장 검사
    python3 tools/human_gates.py --domain audio
    python3 tools/human_gates.py --scope demo

검사 도구에서 자기 도메인 몫만 찍으려면:

    from human_gates import print_pending
    print_pending("audio")
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/human_gates.json"
QUEUE = ROOT / "docs/CODEX_QUEUE.md"
SCHEMA_VERSION = 3
CANDIDATE_STATES = {"waiting_rebuild", "active"}
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
ORDER_RE = re.compile(r"^(?:ORDER|USER)-[\w]+$")
DELEGATED_VERDICTS = {"GO", "CONDITIONAL", "PARTIAL_REJECT", "REJECT"}
DELEGATED_DISPOSITIONS = {
    "GO": ("none", False),
    "CONDITIONAL": ("only", True),
    "PARTIAL_REJECT": ("all_except", True),
    "REJECT": ("all", False),
}

AGENT_LEDGER = "docs/agent_review_decisions.json"
AGENT_SCOPES = {"work_unit", "internal_product"}
AGENT_DELEGATED_SCOPES = {"game_development", "quality_review", "internal_product_decision"}
AGENT_EXCLUSIONS = {"external_publication", "storefront_change", "expenditure", "legal_certification"}
AGENT_EVIDENCE_KINDS = {
    "source_review", "automated_contract", "agent_render_observation", "agent_runtime_observation",
}
AGENT_UNOBSERVED = {"native_reader", "human_playtest", "physical_controller_feel"}
AGENT_METADATA_PATHS = {
    AGENT_LEDGER, "docs/CODEX_QUEUE.md", "docs/CODEX_QUEUE_L3_PENDING.md",
    "docs/WORK_LOG.md", "docs/STATUS.md", "docs/history/WORK_LOG_2026-09-07_localization.md",
}
AGENT_METADATA_REPORT_RE = re.compile(
    r"^(?:docs/agent_reviews/[A-Za-z0-9_-]+\.(?:json|md)|"
    r"docs/(?:queue_active|queue_archive)/ORDER-[0-9]+(?:_L1_L2_RESULTS)?\.md)$"
)


def load_agent_review_ledger(root: Path | None = None) -> dict[str, Any] | None:
    """Read the separate agent ledger, rejecting duplicate JSON keys."""
    def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        result: dict[str, Any] = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f"duplicate key: {key}")
            result[key] = value
        return result

    try:
        data = json.loads(((root or ROOT) / AGENT_LEDGER).read_text(encoding="utf-8"),
                          object_pairs_hook=unique_object)
    except (OSError, ValueError):
        return None
    return data if isinstance(data, dict) else None


def _agent_git_tree(root: Path, commit: str) -> str | None:
    if not isinstance(commit, str) or not COMMIT_RE.fullmatch(commit):
        return None
    try:
        result = subprocess.run(
            ["git", "show", "-s", "--format=%T", commit], cwd=root,
            text=True, capture_output=True, timeout=5, check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    return result.stdout.strip() if result.returncode == 0 else None


def _agent_subject_errors(subject: Any, root: Path) -> list[str]:
    if not isinstance(subject, dict) or set(subject) != {"kind", "commit", "tree", "manifest_sha256"}:
        return ["subject must have exactly kind/commit/tree/manifest_sha256"]
    errors = []
    if subject["kind"] not in ("source", "package"):
        errors.append("subject.kind must be source or package")
    for key in ("commit", "tree"):
        if not isinstance(subject[key], str) or not COMMIT_RE.fullmatch(subject[key]):
            errors.append(f"subject.{key} must be a full Git hash")
    actual_tree = _agent_git_tree(root, subject["commit"])
    if actual_tree is None or actual_tree != subject["tree"]:
        errors.append("subject commit/tree does not match Git")
    manifest = subject["manifest_sha256"]
    if subject["kind"] == "source" and manifest is not None:
        errors.append("source subject must not borrow a package manifest")
    if subject["kind"] == "package" and (
        not isinstance(manifest, str) or not SHA256_RE.fullmatch(manifest)
    ):
        errors.append("package subject requires a manifest SHA-256")
    return errors


def _agent_file_is_git_storage(resolved: Path, root: Path) -> bool:
    """Reject actual Git storage, including a worktree pointer and storage aliases."""
    marker = root / ".git"
    storage = [marker.resolve()]
    for option in ("--absolute-git-dir", "--git-common-dir"):
        result = subprocess.run(["git", "rev-parse", option], cwd=root,
                                capture_output=True, timeout=5, check=False)
        if result.returncode:
            if marker.exists():
                raise ValueError("Git storage identity unavailable")
            # Non-Git fixture roots have no private storage to borrow. A real
            # decision still needs the separately validated commit/tree identity.
            continue
        location = result.stdout.decode("utf-8", errors="strict").removesuffix("\n")
        if not location:
            raise ValueError("Git storage identity empty")
        directory = Path(location)
        storage.append((directory if directory.is_absolute() else root / directory).resolve())
    for directory in storage:
        if resolved.is_relative_to(directory):
            return True
        # resolve() can retain a case alias on a case-insensitive filesystem.
        # Compare inode identity as well, not just lexically folded whole paths.
        if directory.exists() and any(parent.samefile(directory) for parent in (resolved, *resolved.parents)):
            return True
    return False


def _agent_file_errors(item: Any, root: Path, evidence: bool = False) -> list[str]:
    expected = {"path", "sha256", "kind"} if evidence else {"path", "sha256"}
    if not isinstance(item, dict) or set(item) != expected:
        return ["evidence/record has missing or unknown fields"]
    errors = []
    if evidence and item["kind"] not in tuple(AGENT_EVIDENCE_KINDS):
        errors.append("agent evidence cannot certify human/native/physical observations")
    path, digest = item["path"], item["sha256"]
    if not isinstance(digest, str) or not SHA256_RE.fullmatch(digest):
        errors.append("evidence/record requires a SHA-256")
    if not isinstance(path, str) or not path or "\\" in path or "\0" in path or Path(path).is_absolute() or any(p == ".." or p.casefold() == ".git" for p in Path(path).parts):
        return errors + ["evidence/record path must stay inside the repository"]
    try:
        resolved = (root / path).resolve()
    except (OSError, RuntimeError, ValueError):
        return errors + ["evidence/record path cannot be resolved safely"]
    if not resolved.is_relative_to(root.resolve()) or not resolved.is_file():
        return errors + ["evidence/record file missing or outside repository"]
    try:
        if _agent_file_is_git_storage(resolved, root):
            return errors + ["evidence/record must not use private Git storage"]
    except (OSError, RuntimeError, ValueError, UnicodeError, subprocess.TimeoutExpired):
        return errors + ["evidence/record Git storage boundary unavailable"]
    try:
        if hashlib.sha256(resolved.read_bytes()).hexdigest() != digest:
            errors.append("evidence/record SHA-256 drift")
    except OSError:
        errors.append("evidence/record file unreadable")
    return errors


def validate_agent_review_ledger(ledger: Any, root: Path | None = None) -> list[str]:
    """Validate authority and evidence identity, not the truth of review prose."""
    root = root or ROOT
    if not isinstance(ledger, dict) or set(ledger) != {"schema_version", "delegation", "decisions"}:
        return ["agent ledger must have exactly schema_version/delegation/decisions"]
    errors: list[str] = []
    if type(ledger["schema_version"]) is not int or ledger["schema_version"] != 1:
        errors.append("agent schema_version must be 1")
    delegation = ledger["delegation"]
    delegation_keys = {"id", "granted_at", "granted_by", "delegated_to", "source", "scopes", "exclusions", "user_resign_required"}
    if not isinstance(delegation, dict) or set(delegation) != delegation_keys:
        return errors + ["delegation has missing or unknown fields"]
    for key in ("id", "source"):
        if not isinstance(delegation[key], str) or not delegation[key].strip():
            errors.append(f"delegation.{key} must be nonempty")
    try:
        if not isinstance(delegation["granted_at"], str) or not DATE_RE.fullmatch(delegation["granted_at"]):
            raise ValueError()
        date.fromisoformat(delegation["granted_at"])
    except ValueError:
        errors.append("delegation.granted_at must be a real YYYY-MM-DD")
    if delegation["granted_by"] != "user" or delegation["delegated_to"] != "Codex":
        errors.append("delegation must be user to Codex")
    if delegation["user_resign_required"] is not False:
        errors.append("delegated work must not require user re-signing")
    for key, expected in (("scopes", AGENT_DELEGATED_SCOPES), ("exclusions", AGENT_EXCLUSIONS)):
        value = delegation[key]
        if not isinstance(value, list) or not all(isinstance(v, str) for v in value) or len(value) != len(expected) or set(value) != expected:
            errors.append(f"delegation.{key} differs from the bounded user grant")
    decisions = ledger["decisions"]
    if not isinstance(decisions, list):
        return errors + ["decisions must be a list"]
    ids: set[str] = set()
    decision_keys = {"id", "delegation_id", "decided_at", "decided_by", "authority", "scope", "subject", "verdict", "evidence", "unobserved", "record"}
    for index, decision in enumerate(decisions):
        prefix = f"decisions[{index}]"
        local: list[str] = []
        expected_keys = decision_keys | ({"unit_id"} if isinstance(decision, dict) and decision.get("scope") == "work_unit" else set())
        if not isinstance(decision, dict) or set(decision) != expected_keys:
            errors.append(f"{prefix}: missing or unknown fields")
            continue
        identifier = decision["id"]
        if not isinstance(identifier, str) or not identifier.strip() or identifier in ids:
            local.append("decision id empty or duplicate")
        else:
            ids.add(identifier)
        if decision["delegation_id"] != delegation["id"]:
            local.append("unknown delegation_id")
        try:
            if not isinstance(decision["decided_at"], str) or not DATE_RE.fullmatch(decision["decided_at"]):
                raise ValueError()
            if date.fromisoformat(decision["decided_at"]) < date.fromisoformat(delegation["granted_at"]):
                raise ValueError()
        except (ValueError, TypeError):
            local.append("decision date invalid or before delegation")
        reviewer = decision["decided_by"]
        if not isinstance(reviewer, str) or not reviewer.strip() or reviewer.strip().casefold() == "user":
            local.append("decided_by must identify an agent, not user")
        if decision["authority"] != "user_delegated_agent_final":
            local.append("wrong agent authority")
        if decision["scope"] not in tuple(AGENT_SCOPES):
            local.append("scope is not a delegated internal decision")
        if decision["scope"] == "work_unit" and (
            not isinstance(decision["unit_id"], str) or not decision["unit_id"].strip()
            or decision["unit_id"] != decision["unit_id"].strip()
        ):
            local.append("work_unit requires an exact nonempty unit_id")
        if decision["verdict"] not in ("GO", "HOLD", "REWORK"):
            local.append("unknown agent verdict")
        local.extend(_agent_subject_errors(decision["subject"], root))
        evidence = decision["evidence"]
        if not isinstance(evidence, list) or (decision["verdict"] == "GO" and not evidence):
            local.append("GO requires nonempty evidence list")
        else:
            for item in evidence:
                local.extend(_agent_file_errors(item, root, evidence=True))
            subject = decision["subject"]
            if isinstance(subject, dict) and subject.get("kind") == "package" and not any(
                isinstance(item, dict) and item.get("sha256") == subject.get("manifest_sha256") for item in evidence
            ):
                local.append("package manifest must be bound to an evidence file")
        unobserved = decision["unobserved"]
        if not isinstance(unobserved, list) or not all(isinstance(v, str) and v.strip() for v in unobserved) or not AGENT_UNOBSERVED.issubset(unobserved):
            local.append("unobserved must retain native_reader/human_playtest/physical_controller_feel")
        local.extend(_agent_file_errors(decision["record"], root))
        errors.extend(f"{prefix}: {error}" for error in local)
    return errors


def effective_agent_decision(
    subject: dict[str, Any] | None, scope: str,
    ledger: Any = None, root: Path | None = None, *, unit_id: str | None = None,
) -> dict[str, Any]:
    """Resolve only the caller-observed subject; never infer it from a decision."""
    root = root or ROOT
    data = load_agent_review_ledger(root) if ledger is None else ledger
    errors = validate_agent_review_ledger(data, root)
    result: dict[str, Any] = {
        "verdict": "HOLD", "decided_by": None, "decision_id": None,
        "unobserved": sorted(AGENT_UNOBSERVED), "errors": errors,
        "reason": "현재 후보의 독립 최종 검수 기록 없음",
        "user_resign_required": False if not errors else None,
    }
    if errors:
        result["reason"] = "에이전트 판정 원장 계약 오류"
        return result
    if scope not in tuple(AGENT_SCOPES):
        result["reason"] = "위임 범위 밖 — 외부 행위 권한으로 사용 불가"
        return result
    if (scope == "work_unit" and (not isinstance(unit_id, str) or not unit_id.strip() or unit_id != unit_id.strip())) or (scope == "internal_product" and unit_id is not None):
        result["reason"] = "작업 단위 신원 미확정 또는 제품 범위와 혼합"
        return result
    if not data["decisions"]:
        return result
    if subject is None or _agent_subject_errors(subject, root):
        result["reason"] = "현재 후보 신원 미확정 또는 작업 트리 변경 중"
        return result
    for decision in reversed(data["decisions"]):
        if decision["subject"] == subject and decision["scope"] == scope and decision.get("unit_id") == unit_id:
            result.update(verdict=decision["verdict"], decided_by=decision["decided_by"],
                          decision_id=decision["id"], unobserved=decision["unobserved"],
                          reason="현재 후보·범위와 일치하는 마지막 에이전트 판정")
            break
    return result


def _agent_metadata_path(path: str) -> bool:
    return path in AGENT_METADATA_PATHS or AGENT_METADATA_REPORT_RE.fullmatch(path) is not None


def current_agent_source_subject(root: Path | None = None) -> dict[str, Any] | None:
    """Observe the last product commit and verify any fixed-metadata-only wrapper.

    Neither the decision ledger nor its claimed evidence paths select this identity.
    Canon, balance, human evidence, manifests, runtime and code are never excluded.
    """
    root = root or ROOT

    def read(*args: str) -> bytes:
        result = subprocess.run(["git", *args], cwd=root, capture_output=True,
                                timeout=5, check=False)
        if result.returncode:
            raise ValueError("Git identity unavailable")
        return result.stdout

    def paths(raw: bytes) -> list[str]:
        return [p.decode("utf-8", errors="strict") for p in raw.split(b"\0") if p]

    try:
        # STATUS is an output of this resolver. Its sole dirty path must not
        # change the identity/reason between dashboard generation and --check.
        # Keep index, worktree and untracked paths distinct until NUL decoding;
        # rename source paths and every other metadata/code path still block.
        dirty: set[str] = set()
        for args in (
            ("diff", "--name-only", "--no-renames", "--ignore-submodules=none", "-z"),
            ("diff", "--cached", "--name-only", "--no-renames", "--ignore-submodules=none", "-z"),
            ("ls-files", "--others", "--exclude-standard", "-z"),
        ):
            dirty.update(paths(read(*args)))
        if dirty - {"docs/STATUS.md"}:
            return None
        head = read("rev-parse", "HEAD").decode().strip()
        history = read("rev-list", "--first-parent", "--max-count=128", head).decode().splitlines()
        for commit in history:
            parent_row = read("rev-list", "--parents", "-n", "1", commit).decode().split()
            changed = paths(read("diff", "--name-only", "--no-renames", "-z", parent_row[1], commit)) if len(parent_row) > 1 else paths(read("ls-tree", "-r", "--name-only", "-z", commit))
            if all(_agent_metadata_path(p) for p in changed):
                continue
            # Verify the actual wrapper, not just log-path filtering. A mixed code,
            # source, manifest or canon change produces its own new candidate.
            wrapper = paths(read("diff", "--name-only", "--no-renames", "-z", commit, head))
            if any(not _agent_metadata_path(p) for p in wrapper):
                return None
            tree = read("rev-parse", f"{commit}^{{tree}}").decode().strip()
            return {"kind": "source", "commit": commit, "tree": tree, "manifest_sha256": None}
    except (OSError, ValueError, UnicodeError, subprocess.TimeoutExpired):
        return None
    return None


def agent_review_status_lines(root: Path | None = None) -> list[str]:
    """Shared plain-text view model for CLI, Markdown and HTML."""
    root = root or ROOT
    result = effective_agent_decision(current_agent_source_subject(root), "internal_product", root=root)
    reviewer = result["decided_by"] or "미기록"
    try:
        human = json.loads((root / "docs/human_gates.json").read_text(encoding="utf-8"))
        gates = human.get("gates", [])
        counts = f"open={sum(g.get('state') == 'open' for g in gates)} done={sum(g.get('state') == 'done' for g in gates)}"
    except (OSError, ValueError, AttributeError, TypeError):
        counts = "원장 미확인"
    lines = [f"에이전트 최종 판정: {result['verdict']} · 검수자 {reviewer}",
             f"판정 근거: {result['reason']}",
             f"인간 증거 상태: {counts} · 별도 human_gates.json의 실제 기록만 유효",
             "미관찰 한계: " + ", ".join(result["unobserved"])]
    if result["user_resign_required"] is False:
        lines.append("개발·품질·내부 판정은 사용자 재서명 대기 없이 계속한다. 외부 출시 권한은 별도다.")
    else:
        lines.append("원장 계약 오류를 수리해야 한다. 오류를 제품 GO로 처리하지 않는다.")
    return lines


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
    allowed_gate_fields = required_gate_fields | {"delegated_reviews", "evidence"}
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

        delegated_reviews = gate.get("delegated_reviews", [])
        if not isinstance(delegated_reviews, list):
            errors.append(f"{prefix}.delegated_reviews must be an array when present")
            delegated_reviews = []
        for review_index, review in enumerate(delegated_reviews):
            review_prefix = f"{prefix}.delegated_reviews[{review_index}]"
            if not isinstance(review, dict):
                errors.append(f"{review_prefix} must be an object")
                continue
            review_fields = {
                "decided_at", "decided_by", "authority", "verdict", "commit", "tree",
                "sample", "disposition", "record",
            }
            missing_review = sorted(review_fields - review.keys())
            unknown_review = sorted(review.keys() - review_fields)
            if missing_review:
                errors.append(f"{review_prefix} missing fields: {', '.join(missing_review)}")
            if unknown_review:
                errors.append(f"{review_prefix} unknown fields: {', '.join(unknown_review)}")
            if not isinstance(review.get("decided_at"), str) or not DATE_RE.fullmatch(
                review.get("decided_at", "")
            ):
                errors.append(f"{review_prefix}.decided_at must be YYYY-MM-DD")
            for field in ("decided_by", "record"):
                if not isinstance(review.get(field), str) or not review.get(field, "").strip():
                    errors.append(f"{review_prefix}.{field} must be non-empty text")
            if review.get("authority") != "user_delegated":
                errors.append(f"{review_prefix}.authority must be user_delegated")
            verdict = review.get("verdict")
            if verdict not in DELEGATED_VERDICTS:
                errors.append(
                    f"{review_prefix}.verdict must be one of {sorted(DELEGATED_VERDICTS)}"
                )
            for field in ("commit", "tree"):
                value = review.get(field)
                if not isinstance(value, str) or not COMMIT_RE.fullmatch(value):
                    errors.append(f"{review_prefix}.{field} must be a full lowercase Git hash")
            review_sample = review.get("sample")
            if not isinstance(review_sample, dict) or set(review_sample) != {
                "seed", "population", "size",
            }:
                errors.append(f"{review_prefix}.sample requires seed, population and size")
            else:
                for field in ("seed", "population", "size"):
                    value = review_sample.get(field)
                    if type(value) is not int or value < 0:
                        errors.append(f"{review_prefix}.sample.{field} must be a non-negative integer")
                population = review_sample.get("population")
                size = review_sample.get("size")
                if type(population) is int and type(size) is int and (
                    population < 1 or size < 1 or size > population
                ):
                    errors.append(f"{review_prefix}.sample size must fit its population")
            disposition = review.get("disposition")
            if not isinstance(disposition, dict) or set(disposition) != {"mode", "roots"}:
                errors.append(f"{review_prefix}.disposition requires mode and roots")
            elif verdict in DELEGATED_DISPOSITIONS:
                expected_mode, needs_roots = DELEGATED_DISPOSITIONS[verdict]
                roots = disposition.get("roots")
                if disposition.get("mode") != expected_mode:
                    errors.append(
                        f"{review_prefix}.disposition.mode must be {expected_mode} for {verdict}"
                    )
                if not isinstance(roots, list) or any(
                    not isinstance(root, str) or not root.strip() for root in roots
                ):
                    errors.append(f"{review_prefix}.disposition.roots must be a text array")
                elif len(roots) != len(set(roots)):
                    errors.append(f"{review_prefix}.disposition.roots contains duplicates")
                elif needs_roots != bool(roots):
                    need = "non-empty" if needs_roots else "empty"
                    errors.append(
                        f"{review_prefix}.disposition.roots must be {need} for {verdict}"
                    )

        evidence = gate.get("evidence")
        if state == "open" and evidence is not None:
            errors.append(f"{prefix}: open gate must not carry completion evidence")
        if state != "done":
            continue
        if not isinstance(evidence, dict):
            errors.append(f"{prefix}: done gate requires structured evidence")
            continue
        evidence_fields = {
            "decided_at", "decided_by", "authority", "verdict", "commit", "tree",
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
        if evidence.get("decided_by") != "user":
            errors.append(f"{prefix}.evidence.decided_by must be user")
        if evidence.get("authority") != "user_final":
            errors.append(f"{prefix}.evidence.authority must be user_final")
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


def _review_matches_active_candidate(
        ledger: dict, gate: dict, review: dict) -> bool:
    """A delegated verdict applies only to the exact active candidate it reviewed."""
    revision_id = gate.get("revision")
    candidates = ledger.get("release_candidates", {})
    candidate = candidates.get(revision_id, {}) if isinstance(candidates, dict) else {}
    return (
        isinstance(candidate, dict)
        and candidate.get("status") == "active"
        and review.get("commit") == candidate.get("commit")
        and review.get("tree") == candidate.get("tree")
    )


def _delegated_review_lines(ledger: dict, gate: dict) -> list[str]:
    reviews = gate.get("delegated_reviews", [])
    if not isinstance(reviews, list) or not reviews:
        return []
    review = reviews[-1]
    if not isinstance(review, dict):
        return []
    verdict = str(review.get("verdict", ""))
    disposition = review.get("disposition", {})
    roots = disposition.get("roots", []) if isinstance(disposition, dict) else []
    root_text = ", ".join(roots) if isinstance(roots, list) else ""
    if verdict == "GO":
        label = "합격"
    elif verdict == "CONDITIONAL":
        label = f"조건부 · 재작성: {root_text}"
    elif verdict == "PARTIAL_REJECT":
        label = f"부분 반려 · 보존: {root_text} · 나머지 재판정"
    elif verdict == "REJECT":
        label = "전량 반려"
    else:
        label = "판정 오류"
    if _review_matches_active_candidate(ledger, gate, review):
        return [
            f"역사 판정: {review.get('decided_by', '미기록')}(사용자 위임) — {label}",
            "인간 증거와 현재 에이전트 최종 판정은 별도 원장에서 확인",
        ]

    revision_id = gate.get("revision")
    candidates = ledger.get("release_candidates", {})
    candidate = candidates.get(revision_id, {}) if isinstance(candidates, dict) else {}
    reviewed_ref = str(review.get("commit", ""))[:8] or "신원 없음"
    active_ref = (
        str(candidate.get("commit", ""))[:8]
        if isinstance(candidate, dict) and candidate.get("status") == "active"
        else "재빌드 대기"
    )
    return [
        f"이전 후보 {reviewed_ref} 판정 · {review.get('decided_by', '미기록')} · 현재 후보에 미적용 — {label}",
        f"현재 후보 {active_ref}: 인간 증거 미확인",
        "현재 에이전트 최종 판정은 별도 원장에서 확인",
    ]


def print_pending(domain: str, indent: str = "  ") -> None:
    """검사 도구가 자기 도메인 몫을 찍는다. 아무것도 판정하지 않는다."""
    ledger = load_ledger() or {}
    gates = [g for g in open_gates(domain)]
    if not gates:
        return
    print(f"\n{indent}인간 증거 상태 — 미관찰을 통과 처리하지 않는다.")
    for line in agent_review_status_lines():
        print(f"{indent}{line}")
    for gate in gates:
        print(
            f"{indent}  · {gate.get('gate', '<이름 없음>')}  "
            f"[{gate.get('owner', '?')} · {_candidate_label(ledger, gate)}]"
        )
        for line in _delegated_review_lines(ledger, gate):
            print(f"{indent}    {line}")


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

    agent_errors = validate_agent_review_ledger(load_agent_review_ledger())
    if agent_errors:
        print("AGENT_REVIEW_LEDGER_FAIL")
        for error in agent_errors:
            print(f"  ERROR: {error}")
        return 1
    for line in agent_review_status_lines():
        print(line)

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
    print(f"● 인간 증거 상태{suffix} — 관찰하지 않은 증거를 발급하지 않는다.")
    if not rows:
        print("    (열린 게이트 없음)")
    for domain in sorted({gate["domain"] for gate in rows}):
        print(f"\n  [{domain}]")
        for gate in [row for row in rows if row["domain"] == domain]:
            print(f"    · {gate['gate']}  [{gate['owner']}]")
            print(f"      범위 — {_scope_label(gate)}")
            print(f"      후보 — {_candidate_label(ledger, gate)}")
            for line in _delegated_review_lines(ledger, gate):
                print(f"      {line}")
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
    delegated = [
        gate["delegated_reviews"][-1]
        for gate in gates
        if isinstance(gate.get("delegated_reviews"), list) and gate["delegated_reviews"]
    ]
    delegated_counts = {
        verdict: sum(1 for review in delegated if review.get("verdict") == verdict)
        for verdict in sorted(DELEGATED_VERDICTS)
    }
    print(
        f"\nHUMAN_GATES_OK open={open_count} done={done} total={len(gates)} "
        f"delegated_reviewed={len(delegated)}"
    )
    print(
        "  delegated_verdicts="
        + ",".join(f"{key}:{value}" for key, value in delegated_counts.items())
    )
    print(f"  canonical_candidates_waiting_rebuild={waiting}")
    print("  이 도구는 아무것도 통과시키지 않는다. 초록불은 계약을 지켰다는 뜻이지")
    print("  좋다는 뜻이 아니다.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Validate the progressive context contract for Gangnam Dream."""

from __future__ import annotations

import glob
import json
import re
import sys
from collections import defaultdict
from datetime import date
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "docs/context_manifest.json"
WILDCARD_CHARS = set("*?[")
MARKDOWN_LINK_RE = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def has_wildcard(value: str) -> bool:
    return any(char in value for char in WILDCARD_CHARS)


def expand_path(value: str, errors: list[str]) -> list[Path]:
    if has_wildcard(value):
        matches = [Path(item) for item in sorted(glob.glob(str(ROOT / value)))]
        if not matches:
            errors.append(f"pattern matched no files: {value}")
        return matches

    path = ROOT / value
    if not path.exists():
        errors.append(f"missing referenced path: {value}")
        return []
    return [path]


def iter_path_values(value: Any) -> Iterable[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for item in value:
            yield from iter_path_values(item)
    elif isinstance(value, dict):
        for key, item in value.items():
            if key in {"path", "required", "conditional"}:
                yield from iter_path_values(item)


def validate_path_references(manifest: dict[str, Any], errors: list[str]) -> None:
    sections = (
        manifest.get("domain_owners", {}),
        manifest.get("task_profiles", {}),
        manifest.get("document_groups", {}),
        manifest.get("managed_links", []),
    )
    checked: set[str] = set()
    for section in sections:
        for value in iter_path_values(section):
            if value in checked:
                continue
            checked.add(value)
            expand_path(value, errors)


def validate_budgets(manifest: dict[str, Any], errors: list[str]) -> None:
    boot = manifest.get("boot", {})
    budget_entries = list(boot.get("required", []))
    for key in ("router", "recent_log", "handoff"):
        entry = boot.get(key)
        if isinstance(entry, dict):
            budget_entries.append(entry)

    # 활성 오더는 부팅 문서가 아니지만 Codex가 매 세션 통째로 읽는다. 인덱스만
    # 예산이 있고 인덱스가 가리키는 문서에 없으면 무게가 그쪽으로 흘러간다.
    spec = boot.get("active_order")
    if isinstance(spec, dict):
        max_bytes = int(spec.get("max_bytes", 0))
        exceptions = dict(spec.get("exceptions", {}))
        for path in sorted(ROOT.glob(str(spec.get("glob", "")))):
            rel = path.relative_to(ROOT).as_posix()
            size = path.stat().st_size
            if size <= max_bytes:
                continue
            if rel in exceptions:
                print(f"  NOTE {rel} is {size} bytes — 예외: {exceptions[rel]}")
                continue
            errors.append(
                f"active order too large: {rel} is {size} bytes (max {max_bytes}). "
                "완료된 단계를 docs/queue_archive/ 로 내리거나 오더를 나눈다"
            )

    for entry in budget_entries:
        path_value = str(entry.get("path", ""))
        max_bytes = int(entry.get("max_bytes", 0))
        paths = expand_path(path_value, errors)
        if not paths or max_bytes <= 0:
            if max_bytes <= 0:
                errors.append(f"invalid byte budget for {path_value}")
            continue
        size = paths[0].stat().st_size
        if size > max_bytes:
            errors.append(f"context budget exceeded: {path_value} is {size} bytes (max {max_bytes})")


def validate_document_classification(manifest: dict[str, Any], errors: list[str]) -> tuple[int, int]:
    memberships: dict[Path, list[str]] = defaultdict(list)
    for group, patterns in manifest.get("document_groups", {}).items():
        for pattern in patterns:
            for path in expand_path(pattern, errors):
                memberships[path.resolve()].append(group)

    actual = {path.resolve() for path in (ROOT / "docs").rglob("*.md")}
    classified = set(memberships)
    for path in sorted(actual - classified):
        errors.append(f"unclassified docs markdown: {relative(path)}")

    duplicates = {
        path: groups
        for path, groups in memberships.items()
        if len(groups) > 1
    }
    for path, groups in sorted(duplicates.items()):
        errors.append(f"document has multiple lifecycle groups: {relative(path)} -> {', '.join(groups)}")

    return len(actual), len(classified)


def resolve_markdown_link(source: Path, target: str) -> Path | None:
    target = target.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    if target.startswith(("http://", "https://", "mailto:", "#")):
        return None
    target = target.split("#", 1)[0]
    if not target:
        return None
    return (source.parent / target).resolve()


def validate_managed_links(manifest: dict[str, Any], errors: list[str]) -> int:
    checked = 0
    for pattern in manifest.get("managed_links", []):
        for source in expand_path(pattern, errors):
            if source.suffix.lower() != ".md":
                continue
            text = source.read_text(encoding="utf-8")
            for raw_target in MARKDOWN_LINK_RE.findall(text):
                target = resolve_markdown_link(source, raw_target)
                if target is None:
                    continue
                checked += 1
                if not target.exists():
                    errors.append(
                        f"broken managed markdown link: {relative(source)} -> {raw_target}"
                    )
    return checked


def validate_invariants(manifest: dict[str, Any], errors: list[str]) -> int:
    checks = 0
    for contract in manifest.get("invariants", []):
        path_value = str(contract.get("path", ""))
        paths = expand_path(path_value, errors)
        if not paths:
            continue
        text = paths[0].read_text(encoding="utf-8")
        for phrase in contract.get("must_contain", []):
            checks += 1
            if phrase not in text:
                errors.append(f"missing context invariant in {path_value}: {phrase!r}")
        for phrase in contract.get("must_not_contain", []):
            checks += 1
            if phrase in text:
                errors.append(f"stale context invariant in {path_value}: {phrase!r}")
    return checks


def validate_archive(errors: list[str]) -> int:
    archive = ROOT / "docs/history/WORK_LOG_2026-05-16_to_2026-07-24.md"
    if not archive.exists():
        errors.append("missing lossless work-log archive")
        return 0
    size = archive.stat().st_size
    if size < 700_000:
        errors.append(f"work-log archive unexpectedly small: {size} bytes")
    return size


PROPOSAL_CAP = 5
PROPOSAL_EXPIRY_DAYS = 21
PROPOSAL_HEAD = re.compile(
    r"^###\s+(P-\d+)\s+·\s+(.+?)\s+\[열림\s+(\d{4}-\d{2}-\d{2})\]\s*$")


def validate_proposals(errors: list[str]) -> int:
    """열린 제안의 개수와 나이를 강제한다.

    상한이 없으면 목록이 길어지고, 길어지면 안 읽히고, 안 읽히면 제안하는 행위
    자체가 무의미해진다. 이 저장소가 이미 여러 번 겪은 실패라 명예 규칙으로
    두지 않는다. 규칙 자체는 docs/PROPOSALS.md가 소유한다.
    """
    path = ROOT / "docs/PROPOSALS.md"
    if not path.exists():
        errors.append("missing docs/PROPOSALS.md")
        return 0

    section = None
    open_rows: list[tuple[str, str, str]] = []
    pending = None
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            section = line[3:].strip()
            pending = None
            continue
        if section != "열린 제안":
            continue
        head = PROPOSAL_HEAD.match(line)
        if head:
            pending = head.groups()
            open_rows.append(pending)
            continue
        if pending and line.strip().startswith("- **결정**"):
            decided = line.split("—", 1)[-1].strip()
            if decided and decided != "(대기)":
                open_rows.remove(pending)
            pending = None

    if len(open_rows) > PROPOSAL_CAP:
        errors.append(
            f"open proposals {len(open_rows)} exceed cap {PROPOSAL_CAP} — "
            "close one before adding another (docs/PROPOSALS.md)")

    today = date.today()
    for pid, title, opened in open_rows:
        try:
            age = (today - date.fromisoformat(opened)).days
        except ValueError:
            errors.append(f"proposal {pid} has an unreadable open date: {opened}")
            continue
        if age > PROPOSAL_EXPIRY_DAYS:
            errors.append(
                f"proposal {pid} is {age} days old (limit {PROPOSAL_EXPIRY_DAYS}) — "
                f"decide it or move it to docs/POST_LAUNCH_NOTES.md: {title}")
    return len(open_rows)


def main() -> int:
    errors: list[str] = []
    if not MANIFEST_PATH.exists():
        print("CONTEXT_MANIFEST_CHECK_FAIL missing docs/context_manifest.json")
        return 1

    try:
        manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"CONTEXT_MANIFEST_CHECK_FAIL invalid manifest: {exc}")
        return 1

    if manifest.get("schema_version") != 1:
        errors.append("unsupported context manifest schema_version")

    validate_path_references(manifest, errors)
    validate_budgets(manifest, errors)
    docs_count, classified_count = validate_document_classification(manifest, errors)
    link_count = validate_managed_links(manifest, errors)
    invariant_count = validate_invariants(manifest, errors)
    archive_size = validate_archive(errors)
    open_proposals = validate_proposals(errors)

    if errors:
        print("CONTEXT_MANIFEST_CHECK_FAIL")
        for error in errors:
            print(f"  ERROR: {error}")
        return 1

    boot_bytes = sum(
        (ROOT / entry["path"]).stat().st_size
        for entry in manifest["boot"]["required"]
    )
    print(
        "CONTEXT_MANIFEST_CHECK_OK "
        f"boot_bytes={boot_bytes} docs={docs_count} classified={classified_count} "
        f"links={link_count} invariants={invariant_count} archive_bytes={archive_size} "
        f"open_proposals={open_proposals}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())

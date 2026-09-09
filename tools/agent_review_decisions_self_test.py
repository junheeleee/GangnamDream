#!/usr/bin/env python3
"""Finite ORDER216 authority/identity fixtures; not a product or human verdict."""

from __future__ import annotations

import ast
import contextlib
import copy
import hashlib
import io
import json
import subprocess
import tempfile
from pathlib import Path
from unittest.mock import patch

import human_gates as gates
import project_dashboard as dashboard

ROOT = Path(__file__).resolve().parents[1]
HUMAN_SHA = "6ab5c927c9f327aa2892c231d49fe144c1c154cb6069fc539f4f3f8e9c30c9f6"
PRESERVED_ASTS = {
    "load_ledger": "d7965dc8ee17c5d75063bab52405d740a099687324b687c4331d26ab5b02a7db",
    "load": "3066be76c8c46d7959a66f69b1a2f951061e65d27c503bb1b4db8c43544a1f5c",
    "scope_blocks": "ac9350fc457fba0b589f381977a14dd96be4f689c6cda5cee8f78c1ccf88b4b4",
    "open_gates": "608656e6b7d4c056af2d0b0eca30bebcb94ba68546c9015355cdb1472c7a6972",
    "validate_ledger": "d27e7ff67b11aa1e208add863b5d1f0ea52b040acaaa6905bc5c0d2c7e0f4908",
    "canonical_active_candidate": "abe7f7889d7373a77c96e020c9c230088b3e166c31f67ab544ebd4dc4e744488",
}


def generated_status_cases(base: dict, human_raw: bytes) -> list[dict]:
    """Real isolated Git and real dashboard main; no project writes or fake verdicts."""
    results: list[dict] = []

    def observe(name: str, expected: object, observed: object) -> None:
        results.append({"name": name, "expected": expected, "observed": observed,
                        "pass": expected == observed})

    def setup(repo: Path, mode: str = "internal_product") -> tuple:
        def git(*args: str) -> str:
            return subprocess.check_output(["git", *args], cwd=repo, text=True,
                                           stderr=subprocess.DEVNULL).strip()

        def commit(message: str) -> str:
            git("add", ".")
            git("-c", "user.name=Agent Fixture", "-c", "user.email=fixture@example.invalid",
                "commit", "-qm", message)
            return git("rev-parse", "HEAD")

        git("init", "-q")
        (repo / "game").mkdir()
        (repo / "docs/agent_reviews").mkdir(parents=True)
        (repo / "game/source.txt").write_text("product-v1\n", encoding="utf-8")
        (repo / "docs/human_gates.json").write_bytes(human_raw)
        (repo / "docs/STATUS.md").write_text("initial generated placeholder\n", encoding="utf-8")
        (repo / "docs/CODEX_QUEUE.md").write_text(
            "### 실행 오더 인덱스\n\n| 1 | [~] | ORDER-216 · fixture | [216](queue_active/ORDER-216.md) | fixture |\n",
            encoding="utf-8")
        (repo / gates.AGENT_LEDGER).write_text(json.dumps(base), encoding="utf-8")
        commit("fixture product before review")
        subject = gates.current_agent_source_subject(repo)
        report = repo / "docs/agent_reviews/status-review.md"
        report.write_text("Independent fixture review; no human evidence.\n", encoding="utf-8")
        ref = {"path": "docs/agent_reviews/status-review.md",
               "sha256": hashlib.sha256(report.read_bytes()).hexdigest()}
        data = copy.deepcopy(base)
        data["decisions"] = []
        for n in range(3 if mode == "work_unit" else 1):
            decision = {
                "id": f"status-fixture-{n}", "delegation_id": data["delegation"]["id"],
                "decided_at": data["delegation"]["granted_at"], "decided_by": "Independent fixture",
                "authority": "user_delegated_agent_final", "scope": mode, "subject": subject,
                "verdict": "GO", "evidence": [{"kind": "source_review", **ref}],
                "record": ref, "unobserved": sorted(gates.AGENT_UNOBSERVED),
            }
            if mode == "work_unit":
                decision["unit_id"] = f"ORDER-fixture-{n}"
            data["decisions"].append(decision)
        (repo / gates.AGENT_LEDGER).write_text(json.dumps(data), encoding="utf-8")
        commit("ledger-only wrapper after review")
        return git, commit, subject

    for mode in ("work_unit", "internal_product"):
        with tempfile.TemporaryDirectory(prefix="agent-status-flow-") as directory:
            repo = Path(directory)
            git, commit, subject = setup(repo, mode)
            expected_verdict = "HOLD" if mode == "work_unit" else "GO"
            clean_lines = gates.agent_review_status_lines(repo)
            observe(mode + "-clean-subject", subject, gates.current_agent_source_subject(repo))
            observe(mode + "-clean-verdict", expected_verdict,
                    gates.effective_agent_decision(subject, "internal_product", root=repo)["verdict"])

            def dashboard_cli(check_only: bool = False) -> tuple[int, str]:
                argv = ["project_dashboard.py", "--md", "docs/STATUS.md"]
                if check_only:
                    argv.append("--check")
                out = io.StringIO()
                with patch.object(dashboard, "ROOT", repo), patch("sys.argv", argv), contextlib.redirect_stdout(out):
                    code = dashboard.main()
                return code, out.getvalue()

            written, _ = dashboard_cli()
            checked, output = dashboard_cli(True)
            observe(mode + "-generate", 0, written)
            observe(mode + "-generated-only-lines-stable", clean_lines, gates.agent_review_status_lines(repo))
            observe(mode + "-generated-only-check", 0, checked)
            results[-1]["stdout"] = output
            commit("generated STATUS only")
            checked_clean, output_clean = dashboard_cli(True)
            observe(mode + "-committed-generated-check", 0, checked_clean)
            results[-1]["stdout"] = output_clean

    cases = (
        ("clean", True), ("status-unstaged", True), ("status-staged", True),
        ("status-staged-and-unstaged", True), ("status-untracked", True),
        ("status-deleted", True), ("status-plus-code-unstaged", False),
        ("status-plus-code-staged", False), ("status-plus-untracked", False),
        ("status-plus-metadata-unstaged", False), ("status-plus-metadata-staged", False),
        ("newline-lookalike-untracked", False), ("tab-lookalike-staged", False),
        ("source-renamed-to-status", False),
    )
    for name, allowed in cases:
        with tempfile.TemporaryDirectory(prefix="agent-status-dirty-") as directory:
            repo = Path(directory)
            git, commit, subject = setup(repo)
            observe(name + "-base-subject", subject, gates.current_agent_source_subject(repo))
            status = repo / "docs/STATUS.md"
            if name == "status-untracked":
                git("rm", "docs/STATUS.md")
                commit("metadata wrapper removes generated file")
            if name != "clean":
                status.write_text("regenerated status\n", encoding="utf-8")
            if name in ("status-staged", "status-staged-and-unstaged"):
                git("add", "docs/STATUS.md")
            if name == "status-staged-and-unstaged":
                status.write_text("newer regenerated status\n", encoding="utf-8")
            if name == "status-deleted":
                status.unlink()
            if name in ("status-plus-code-unstaged", "status-plus-code-staged"):
                (repo / "game/source.txt").write_text("unreviewed product\n", encoding="utf-8")
                if name.endswith("-staged"):
                    git("add", "game/source.txt")
            if name == "status-plus-untracked":
                (repo / "untracked.txt").write_text("unreviewed\n", encoding="utf-8")
            if name in ("status-plus-metadata-unstaged", "status-plus-metadata-staged"):
                (repo / "docs/CODEX_QUEUE.md").write_text("unreviewed queue\n", encoding="utf-8")
                if name.endswith("-staged"):
                    git("add", "docs/CODEX_QUEUE.md")
            if name == "newline-lookalike-untracked":
                (repo / "docs/STATUS.md\nother.txt").write_text("not STATUS\n", encoding="utf-8")
            if name == "tab-lookalike-staged":
                odd = "docs/STATUS.md\tother.txt"
                (repo / odd).write_text("not STATUS\n", encoding="utf-8")
                git("add", odd)
            if name == "source-renamed-to-status":
                git("mv", "-f", "game/source.txt", "docs/STATUS.md")
            observed = gates.current_agent_source_subject(repo)
            observe(name, subject if allowed else None, observed)
            if not allowed:
                observe(name + "-HOLD", "HOLD",
                        gates.effective_agent_decision(observed, "internal_product", root=repo)["verdict"])
    return results


def git_evidence_boundary_cases() -> list[dict]:
    """Exercise only real temporary Git storage and in-repository evidence paths."""
    results: list[dict] = []
    with tempfile.TemporaryDirectory(prefix="agent-git-evidence-") as directory:
        container = Path(directory)
        outside = container / "outside.md"
        outside.write_text("outside evidence\n", encoding="utf-8")

        def git(repo: Path, *args: str) -> str:
            return subprocess.check_output(["git", *args], cwd=repo, text=True,
                                           stderr=subprocess.DEVNULL).strip()

        def check_file(name: str, repo: Path, path: str, allowed: bool) -> None:
            candidate = repo / path
            digest = hashlib.sha256(candidate.read_bytes()).hexdigest()
            for evidence in (False, True):
                item = {"path": path, "sha256": digest}
                if evidence:
                    item["kind"] = "source_review"
                errors = gates._agent_file_errors(item, repo, evidence=evidence)
                results.append({"name": name + ("-evidence" if evidence else "-record"),
                                "expected_allowed": allowed, "observed_allowed": not errors,
                                "errors": errors, "pass": allowed == (not errors)})

        def public_report(repo: Path) -> None:
            (repo / "docs").mkdir(exist_ok=True)
            (repo / "docs/review.md").write_text("Source review only; no human evidence.\n",
                                                 encoding="utf-8")

        normal = container / "normal"
        normal.mkdir()
        git(normal, "init", "-q")
        public_report(normal)
        git(normal, "add", "docs/review.md")
        git(normal, "-c", "user.name=Agent Fixture", "-c", "user.email=fixture@example.invalid",
            "commit", "-qm", "fixture")
        check_file("normal-public-report", normal, "docs/review.md", True)
        (normal / "docs/public-link").symlink_to(normal / "docs/review.md")
        check_file("normal-public-symlink", normal, "docs/public-link", True)
        for spelling in (".git", ".GIT", ".GiT"):
            alias = normal / spelling
            if not alias.exists():
                alias.symlink_to(normal / ".git", target_is_directory=True)
            check_file("normal-" + spelling, normal, spelling + "/config", False)
        (normal / "docs/git-file-link").symlink_to(normal / ".git/config")
        check_file("normal-private-file-symlink", normal, "docs/git-file-link", False)
        (normal / "docs/git-dir-link").symlink_to(normal / ".git", target_is_directory=True)
        check_file("normal-private-directory-symlink", normal, "docs/git-dir-link/config", False)
        (normal / "docs/escape").symlink_to(outside)
        check_file("normal-outside-symlink", normal, "docs/escape", False)
        check_file("normal-parent-escape", normal, "../outside.md", False)

        separate = container / "separate"
        separate.mkdir()
        store = separate / "admin_store"
        git(separate, "init", "-q", "--separate-git-dir=" + str(store))
        public_report(separate)
        check_file("separate-public-report", separate, "docs/review.md", True)
        check_file("separate-direct-storage", separate, "admin_store/config", False)
        check_file("separate-git-pointer", separate, ".git", False)
        (separate / "docs/git-pointer-link").symlink_to(separate / ".git")
        check_file("separate-pointer-symlink", separate, "docs/git-pointer-link", False)
        (separate / "docs/storage-link").symlink_to(store, target_is_directory=True)
        check_file("separate-storage-symlink", separate, "docs/storage-link/config", False)
        alias = separate / "ADMIN_STORE"
        if not alias.exists():
            alias.symlink_to(store, target_is_directory=True)
        check_file("separate-storage-case-alias", separate, "ADMIN_STORE/config", False)

        linked = container / "linked"
        git(normal, "worktree", "add", "-q", "-b", "linked-evidence", str(linked))
        check_file("linked-public-report", linked, "docs/review.md", True)
        check_file("linked-git-pointer", linked, ".git", False)
        (linked / "docs/pointer-link").symlink_to(linked / ".git")
        check_file("linked-pointer-symlink", linked, "docs/pointer-link", False)
        git_dir = Path(git(linked, "rev-parse", "--absolute-git-dir"))
        common_dir = Path(git(linked, "rev-parse", "--git-common-dir"))
        if not common_dir.is_absolute():
            common_dir = linked / common_dir
        (linked / "docs/private-link").symlink_to(git_dir, target_is_directory=True)
        (linked / "docs/common-link").symlink_to(common_dir, target_is_directory=True)
        check_file("linked-private-storage", linked, "docs/private-link/HEAD", False)
        check_file("linked-common-storage", linked, "docs/common-link/config", False)
    return results


def run() -> int:
    names: list[str] = []

    def check(name: str, condition: bool) -> None:
        assert condition, name
        assert name not in names, name
        names.append(name)

    human_raw = (ROOT / "docs/human_gates.json").read_bytes()
    human = json.loads(human_raw)
    actual = gates.load_agent_review_ledger(ROOT)
    check("current-ledger-contract", gates.validate_agent_review_ledger(actual, ROOT) == [])
    check("human-before-raw", hashlib.sha256(human_raw).hexdigest() == HUMAN_SHA)
    check("human-46-45-1", len(human["gates"]) == 46 and
          sum(g["state"] == "open" for g in human["gates"]) == 45 and
          sum(g["state"] == "done" for g in human["gates"]) == 1)
    check("human-22-historical-5-candidates", sum(len(g.get("delegated_reviews", [])) for g in human["gates"]) == 22
          and len(human["release_candidates"]) == 5)
    check("human-contract", gates.validate_ledger(human) == [])
    module = ast.parse((ROOT / "tools/human_gates.py").read_text(encoding="utf-8"))
    for node in module.body:
        if isinstance(node, ast.FunctionDef) and node.name in PRESERVED_ASTS:
            digest = hashlib.sha256(ast.dump(node, include_attributes=False).encode()).hexdigest()
            check(f"old-AST-{node.name}", digest == PRESERVED_ASTS[node.name])

    # Fake decisions exist only in a temporary fixture repository. Git identity is
    # independently controlled here; the actual read-only Git path is checked below.
    with tempfile.TemporaryDirectory(prefix="agent-review-test-") as directory:
        root = Path(directory)
        (root / "docs").mkdir()
        proof = root / "docs/review.json"
        proof.write_text('{"reviewer":"Independent fixture","population":"fixture only","method":"source review","limits":"not human evidence"}\n', encoding="utf-8")
        digest = hashlib.sha256(proof.read_bytes()).hexdigest()
        record = {"path": "docs/review.json", "sha256": digest}
        evidence = {"kind": "source_review", **record}
        source = {"kind": "source", "commit": "a" * 40, "tree": "b" * 40, "manifest_sha256": None}
        package = {**source, "kind": "package", "manifest_sha256": digest}
        later_source = {**source, "commit": "c" * 40, "tree": "d" * 40}
        base = {"schema_version": 1, "delegation": copy.deepcopy(actual["delegation"]), "decisions": []}
        decision = {
            "id": "fixture-source-go", "delegation_id": base["delegation"]["id"],
            "decided_at": base["delegation"]["granted_at"], "decided_by": "Independent fixture agent",
            "authority": "user_delegated_agent_final", "scope": "internal_product",
            "subject": source, "verdict": "GO", "evidence": [evidence],
            "unobserved": sorted(gates.AGENT_UNOBSERVED), "record": record,
        }

        def valid_fixture(subject: dict | None = None) -> dict:
            value = copy.deepcopy(base)
            value["decisions"] = [copy.deepcopy(decision)]
            if subject is not None:
                value["decisions"][0]["subject"] = copy.deepcopy(subject)
            return value

        def resolve(data: dict, subject: dict | None = None, scope: str = "internal_product", unit_id: str | None = None) -> dict:
            return gates.effective_agent_decision(source if subject is None else subject, scope, data, root, unit_id=unit_id)

        def reject(name: str, change) -> None:
            data = valid_fixture()
            check(name + "-base-GO", resolve(data)["verdict"] == "GO")
            change(data)
            check(name, bool(gates.validate_agent_review_ledger(data, root)) and resolve(data)["verdict"] == "HOLD")

        with patch.object(gates, "_agent_git_tree", side_effect=lambda r, c: {"a" * 40: "b" * 40, "c" * 40: "d" * 40}.get(c)):
            check("empty-valid", gates.validate_agent_review_ledger(base, root) == [])
            empty = resolve(base)
            check("empty-HOLD-no-resign", empty["verdict"] == "HOLD" and empty["user_resign_required"] is False)
            source_data = valid_fixture()
            check("exact-source-GO", resolve(source_data)["verdict"] == "GO")
            check("exact-package-GO", resolve(valid_fixture(package), package)["verdict"] == "GO")
            check("source-cannot-borrow-package", resolve(valid_fixture(package))["verdict"] == "HOLD")
            check("package-cannot-borrow-source", resolve(source_data, package)["verdict"] == "HOLD")
            check("scope-cannot-borrow", resolve(source_data, scope="work_unit")["verdict"] == "HOLD")
            work = valid_fixture()
            work["decisions"][0].update(scope="work_unit", unit_id="ORDER-fixture/batch-A")
            check("exact-work-unit-GO", resolve(work, scope="work_unit", unit_id="ORDER-fixture/batch-A")["verdict"] == "GO")
            check("different-work-unit-HOLD", resolve(work, scope="work_unit", unit_id="ORDER-fixture/batch-B")["verdict"] == "HOLD")
            check("missing-caller-unit-HOLD", resolve(work, scope="work_unit")["verdict"] == "HOLD")
            check("product-cannot-take-unit", resolve(source_data, unit_id="ORDER-fixture/batch-A")["verdict"] == "HOLD")
            reject("bare-work-unit-record", lambda d: d["decisions"][0].update(scope="work_unit"))
            for key, value in (("commit", "c" * 40), ("tree", "d" * 40), ("manifest_sha256", "e" * 64), ("kind", "package")):
                check(f"current-{key}-mismatch-HOLD", resolve(source_data, {**source, key: value})["verdict"] == "HOLD")
            check("other-valid-candidate-HOLD", resolve(source_data, later_source)["verdict"] == "HOLD")
            for verdict in ("HOLD", "REWORK"):
                data = valid_fixture()
                data["decisions"].append({**copy.deepcopy(decision), "id": "later", "verdict": verdict})
                check(f"latest-{verdict}-wins", resolve(data)["verdict"] == verdict)
            data = valid_fixture()
            data["decisions"].append({**copy.deepcopy(decision), "id": "other", "subject": later_source})
            check("other-candidate-does-not-shadow-current", resolve(data)["decision_id"] == decision["id"])
            for external in sorted(gates.AGENT_EXCLUSIONS):
                check(f"external-{external}-HOLD", resolve(source_data, scope=external)["verdict"] == "HOLD")
                reject(f"external-{external}-record", lambda d, v=external: d["decisions"][0].update(scope=v))

            reject("unknown-delegation", lambda d: d["decisions"][0].update(delegation_id="other"))
            reject("missing-delegation", lambda d: d.pop("delegation"))
            reject("duplicate-id", lambda d: d["decisions"].append(copy.deepcopy(d["decisions"][0])))
            reject("unknown-root-key", lambda d: d.update(extra=True))
            reject("unknown-decision-key", lambda d: d["decisions"][0].update(extra=True))
            reject("unknown-subject-key", lambda d: d["decisions"][0]["subject"].update(extra=True))
            reject("GO-empty-evidence", lambda d: d["decisions"][0].update(evidence=[]))
            reject("user-final-authority", lambda d: d["decisions"][0].update(authority="user_final"))
            reject("user-as-agent", lambda d: d["decisions"][0].update(decided_by=" USER "))
            reject("missing-unobserved", lambda d: d["decisions"][0].update(unobserved=[]))
            reject("user-resign-loop", lambda d: d["delegation"].update(user_resign_required=True))
            reject("invalid-date", lambda d: d["decisions"][0].update(decided_at="2026-02-30"))
            reject("mixed-tree", lambda d: d["decisions"][0]["subject"].update(tree="d" * 40))
            reject("source-manifest-borrow", lambda d: d["decisions"][0]["subject"].update(manifest_sha256=digest))
            reject("package-manifest-not-evidence", lambda d: d["decisions"][0].update(subject={**package, "manifest_sha256": "e" * 64}))
            for kind in ("human_playtest", "native_reader", "physical_user_feel"):
                reject(f"fake-{kind}", lambda d, v=kind: d["decisions"][0]["evidence"][0].update(kind=v))
            for role in ("record", "evidence"):
                for field, value in (("path", "../escape"), ("path", str(proof)), ("path", "docs/missing.json"), ("sha256", "f" * 64)):
                    def change(d, r=role, k=field, v=value):
                        item = d["decisions"][0][r]
                        (item[0] if r == "evidence" else item)[k] = v
                    reject(f"{role}-{field}-{value}", change)
            (root / "docs/outside").symlink_to(ROOT / "docs/WORK_UNIT.md")
            reject("symlink-escape", lambda d: d["decisions"][0]["record"].update(path="docs/outside"))
            reject("NUL-path", lambda d: d["decisions"][0]["record"].update(path="docs/\0bad"))
            reject("private-Git-path", lambda d: d["decisions"][0]["record"].update(path=".git/config"))

            # Display uses the same resolver in all three surfaces, never a record's
            # subject as the expected current identity.
            with patch.object(gates, "load_agent_review_ledger", return_value=source_data), \
                    patch.object(gates, "current_agent_source_subject", return_value=source):
                lines = gates.agent_review_status_lines(root)
                check("display-agent-reviewer", "GO" in lines[0] and decision["decided_by"] in lines[0])
                check("display-three-axes", any("인간 증거 상태" in x for x in lines) and any("미관찰 한계" in x for x in lines))
                check("display-no-user-wait", "사용자 최종 GO 대기" not in "\n".join(lines))
                with patch.object(dashboard, "ROOT", ROOT), patch.object(
                    dashboard, "agent_review_status_lines", side_effect=lambda _: gates.agent_review_status_lines(root)
                ):
                    md = dashboard.markdown()
                    html = dashboard.build()
                check("markdown-shared-agent-view", lines[0] in md and "미관찰 한계" in md)
                check("html-shared-agent-view", lines[0] in html and "미관찰 한계" in html)

        duplicate = '{"schema_version":1,"schema_version":1,"delegation":{},"decisions":[]}'
        (root / gates.AGENT_LEDGER).write_text(duplicate, encoding="utf-8")
        check("duplicate-JSON-key-rejected", gates.load_agent_review_ledger(root) is None)

    # A real temporary Git flow proves that recording a review does not make its
    # product identity self-referential. No command writes to the project Git repo.
    with tempfile.TemporaryDirectory(prefix="agent-review-git-") as directory:
        repo = Path(directory)

        def git(*args: str) -> str:
            return subprocess.check_output(["git", *args], cwd=repo, text=True, stderr=subprocess.DEVNULL).strip()

        def commit_fixture(message: str) -> str:
            git("add", ".")
            git("-c", "user.name=Agent Fixture", "-c", "user.email=fixture@example.invalid", "commit", "-qm", message)
            return git("rev-parse", "HEAD")

        git("init", "-q")
        (repo / "game").mkdir()
        (repo / "docs/agent_reviews").mkdir(parents=True)
        (repo / "game/source.txt").write_text("product-v1\n", encoding="utf-8")
        (repo / "docs/human_gates.json").write_bytes(human_raw)
        (repo / gates.AGENT_LEDGER).write_text(json.dumps(base), encoding="utf-8")
        product_commit = commit_fixture("independently reviewed product")
        subject = gates.current_agent_source_subject(repo)
        check("Git-product-identity-observed", subject is not None and subject["commit"] == product_commit)
        report = repo / "docs/agent_reviews/product-review.md"
        report.write_text("Independent fixture reviewer; all fixture source read; no defects; no human evidence.\n", encoding="utf-8")
        report_ref = {"path": "docs/agent_reviews/product-review.md", "sha256": hashlib.sha256(report.read_bytes()).hexdigest()}
        data = copy.deepcopy(base)
        data["decisions"] = [{**copy.deepcopy(decision), "subject": subject,
                              "record": report_ref, "evidence": [{"kind": "source_review", **report_ref}]}]
        (repo / gates.AGENT_LEDGER).write_text(json.dumps(data), encoding="utf-8")
        wrapper = commit_fixture("metadata-only review wrapper")
        check("Git-wrapper-has-new-HEAD", wrapper != product_commit)
        check("Git-wrapper-preserves-observed-subject", gates.current_agent_source_subject(repo) == subject)
        check("Git-wrapper-effective-GO", gates.effective_agent_decision(gates.current_agent_source_subject(repo), "internal_product", root=repo)["verdict"] == "GO")
        check("Git-wrapper-dashboard-GO", "에이전트 최종 판정: GO" in gates.agent_review_status_lines(repo)[0])
        (repo / "game/source.txt").write_text("product-v2\n", encoding="utf-8")
        (repo / "docs/STATUS.md").write_text("metadata plus a product change\n", encoding="utf-8")
        mixed = commit_fixture("mixed product and metadata must invalidate")
        changed_subject = gates.current_agent_source_subject(repo)
        check("Git-mixed-wrapper-is-new-product", changed_subject is not None and changed_subject["commit"] == mixed)
        check("Git-mixed-wrapper-HOLD", gates.effective_agent_decision(changed_subject, "internal_product", root=repo)["verdict"] == "HOLD")
        (repo / "game/source.txt").write_text("uncommitted product\n", encoding="utf-8")
        check("Git-dirty-HOLD", gates.current_agent_source_subject(repo) is None)
    for protected in ("content/events/canon.json", "tools/human_gates.py", "docs/CANON.md", "docs/balance.json", "docs/STORY_MAP.md", "docs/release_manifest.json", "docs/human_gates.json"):
        check("wrapper-protects-" + protected, not gates._agent_metadata_path(protected))

    for result in generated_status_cases(base, human_raw):
        check("generated-status-" + result["name"], result["pass"])

    for result in git_evidence_boundary_cases():
        check("git-evidence-" + result["name"], result["pass"])

    # Real Git binding, without writing a commit or consulting a decision identity.
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    tree = subprocess.check_output(["git", "rev-parse", "HEAD^{tree}"], cwd=ROOT, text=True).strip()
    check("actual-Git-tree", gates._agent_git_tree(ROOT, commit) == tree)
    check("Git-option-injection-rejected", gates._agent_git_tree(ROOT, "--all") is None)
    for mutation in ("missing", "authority", "candidate"):
        altered = copy.deepcopy(human)
        done = next(g for g in altered["gates"] if g["state"] == "done")
        if mutation == "missing":
            done.pop("evidence")
        elif mutation == "authority":
            done["evidence"]["authority"] = "user_delegated_agent_final"
        else:
            done["evidence"]["commit"] = "e" * 40
        check(f"human-{mutation}-still-rejected", bool(gates.validate_ledger(altered)))
    old = next(g for g in human["gates"] if g.get("delegated_reviews"))
    reviewer = old["delegated_reviews"][-1]["decided_by"]
    check("historical-reviewer-MD", reviewer in dashboard.human_gate_delegated_review(human, old))
    check("historical-reviewer-HTML", reviewer in dashboard.human_gate_delegated_review_html(human, old))
    output = io.StringIO()
    with contextlib.redirect_stdout(output), patch("sys.argv", ["human_gates.py"]):
        code = gates.main()
    check("CLI-contract", code == 0 and "HUMAN_GATES_OK open=45 done=1 total=46" in output.getvalue())
    check("CLI-separated-HOLD", "에이전트 최종 판정: HOLD" in output.getvalue() and "미관찰 한계" in output.getvalue())
    check("CLI-no-user-sign-loop", "사용자 최종 GO 대기" not in output.getvalue())
    check("human-after-raw", (ROOT / "docs/human_gates.json").read_bytes() == human_raw)
    print(f"AGENT_REVIEW_DECISIONS_SELF_TEST_OK cases={len(names)} product_verdict=HOLD human_evidence_unchanged=true")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())

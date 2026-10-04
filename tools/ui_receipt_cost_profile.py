#!/usr/bin/env python3
"""Measure one real ORDER-365 default invocation without changing its checks.

Importing this file is stdlib-only. Timings include instrumentation overhead;
inclusive function times overlap and must not be added together. Only append's
_Document alias is measured, not the separate coffee/350/351/365 aliases.
"""
from __future__ import annotations

import argparse
import contextlib
import contextvars
import functools
import hashlib
import importlib
import json
import os
import platform
import re
import resource
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_FILE = ROOT / "tools/ui_translation_append.py"
SOURCE_SHA256 = "6fd26f3d5e85570098602675dba25e8ab53d55efd7a947cdca1277bfc3ef5e2e"
PLAYER = Path("/Users/junheelee/Library/Application Support/Godot/app_userdata/강남드림")
LEDGER = "content/meta/full_game_localization.json"
JA, CN, TW = (f"locale/ui_{locale}.json" for locale in ("ja", "zh-CN", "zh-TW"))
COMPARISONS = ("_correction_comparison", "_fee_comparison", "_legacy_ja_gift_comparison",
               "_legacy_ja_rank_comparison", "_legacy_ja_residual_comparison")


@dataclass(frozen=True)
class Site:
    roles: tuple[str, ...]
    paths: tuple[str, ...] = ()
    local_path: str | None = None
    max_calls: int | None = None
    required: bool = True


SITES = {
    COMPARISONS[0]: {
        352: Site(("before", "after", "before", "after"), (CN, CN, TW, TW)),
        353: Site(("dynamic",), local_path="path", max_calls=2, required=False),
        361: Site(("before", "after"), (LEDGER, LEDGER)),
        362: Site(("dynamic",), (LEDGER,), required=False),
    },
    COMPARISONS[1]: {
        651: Site(("before", "after", "before", "after"), (CN, CN, TW, TW)),
        652: Site(("dynamic",), local_path="path", max_calls=2, required=False),
        659: Site(("before", "after"), (LEDGER, LEDGER)),
        660: Site(("dynamic",), (LEDGER,), required=False),
    },
    COMPARISONS[2]: {
        1317: Site(("before", "after", "dynamic"), (JA,) * 3),
        1330: Site(("before", "after", "dynamic"), (LEDGER,) * 3),
    },
    COMPARISONS[3]: {
        2045: Site(("before", "after", "dynamic"), (JA,) * 3),
        2054: Site(("before", "after", "dynamic"), (LEDGER,) * 3),
    },
    COMPARISONS[4]: {
        2320: Site(("before", "after", "dynamic"), (JA,) * 3),
        2334: Site(("before", "after", "dynamic"), (LEDGER,) * 3),
    },
}


class ReceiptCostProfiler:
    """Temporary delegates; synthetic modules and a deterministic clock are supported."""

    def __init__(self, append_module, exchange_module, *, source_file=SOURCE_FILE,
                 sites=None, clock=time.perf_counter_ns):
        self.append = append_module
        self.exchange = exchange_module
        self.source_file = os.path.abspath(os.fspath(source_file))
        self.sites = {name: dict(rows) for name, rows in (SITES if sites is None else sites).items()}
        self.clock = clock
        self.errors: list[str] = []
        self._documents = {}
        self._functions = {}
        self._context = contextvars.ContextVar("receipt_cost_comparison", default=None)
        self._active = False
        self.restored = True

    def _now(self):
        try:
            return self.clock()
        except Exception as exc:
            self.errors.append("clock: " + type(exc).__name__ + ": " + str(exc))
            return None

    def _elapsed(self, start):
        end = self._now()
        if start is None or end is None:
            return 0
        if end < start:
            self.errors.append("clock moved backwards")
            return 0
        return end - start

    @staticmethod
    def _add(rows, key, elapsed, failed, length=0):
        row = rows.setdefault(key, {"calls": 0, "failures": 0, "total_ns": 0, "bytes": 0})
        row["calls"] += 1
        row["failures"] += int(failed)
        row["total_ns"] += elapsed
        row["bytes"] += length

    def _record_metric(self, rows, key, start, failed, length=0):
        try:
            self._add(rows, key, self._elapsed(start), failed, length)
        except Exception as exc:
            self.errors.append("metric recording: " + type(exc).__name__ + ": " + str(exc))

    def _classify(self, frame, raw):
        context = self._context.get()
        if context is None:
            return "", "other", ""
        name = context["name"]
        site = self.sites.get(name, {}).get(frame.f_lineno)
        if os.path.abspath(frame.f_code.co_filename) != self.source_file or site is None:
            self.errors.append(f"unmatched site: {name}:{frame.f_code.co_filename}:{frame.f_lineno}")
            return name, "unmatched", ""
        ordinal = context["counts"].get(frame.f_lineno, 0)
        context["counts"][frame.f_lineno] = ordinal + 1
        limit = site.max_calls if site.max_calls is not None else len(site.roles)
        if not site.roles or ordinal >= limit:
            self.errors.append(f"unexpected site ordinal: {name}:{frame.f_lineno}:{ordinal}")
            return name, "unmatched", ""
        role = site.roles[0] if len(site.roles) == 1 else site.roles[ordinal]
        path = frame.f_locals.get(site.local_path) if site.local_path else site.paths[ordinal]
        operand = "snapshot" if role == "dynamic" else role
        if (role not in ("before", "after", "dynamic") or not isinstance(path, str)
                or path not in context[operand] or context[operand][path] is not raw):
            self.errors.append(f"site operand binding differs: {name}:{frame.f_lineno}:{ordinal}")
            return name, "unmatched", str(path)
        return name, role, path

    def _document_delegate(self, original):
        @functools.wraps(original)
        def document(*args, **kwargs):
            raw = args[0] if args else kwargs.get("raw")
            frame = sys._getframe(1)
            location = (frame.f_code.co_filename, frame.f_code.co_name, frame.f_lineno)
            try:
                context = self._classify(frame, raw)
            except Exception as exc:
                self.errors.append("classification: " + type(exc).__name__ + ": " + str(exc))
                context = ("", "unmatched", "")
            finally:
                del frame
            length = len(raw) if isinstance(raw, bytes) else 0
            if not isinstance(raw, bytes):
                self.errors.append("non-bytes _Document argument")
            failed, start = False, self._now()
            try:
                return original(*args, **kwargs)
            except BaseException:
                failed = True
                raise
            finally:
                self._record_metric(self._documents, (*location, *context, length), start, failed, length)
        return document

    def _function_delegate(self, name, original, comparison=False):
        @functools.wraps(original)
        def measured(*args, **kwargs):
            token, context = None, None
            if comparison:
                operands = {key: args[index] if len(args) > index else kwargs.get(key, {})
                            for index, key in enumerate(("snapshot", "before", "after"))}
                context = {"name": name, "counts": {}, **operands}
                token = self._context.set(context)
            failed, start = False, self._now()
            try:
                return original(*args, **kwargs)
            except BaseException:
                failed = True
                raise
            finally:
                if token is not None:
                    self._context.reset(token)
                self._record_metric(self._functions, name, start, failed)
                if comparison and not failed:
                    for line, site in self.sites.get(name, {}).items():
                        if site.required and context["counts"].get(line, 0) != len(site.roles):
                            self.errors.append(f"missing required site calls: {name}:{line}")
        return measured

    @contextlib.contextmanager
    def installed(self, argv=None):
        if self._active:
            raise RuntimeError("the same profiler cannot be installed twice")
        bindings = [(self.append, "_Document", self._document_delegate(self.append._Document))]
        bindings.extend((self.append, name, self._function_delegate(name, getattr(self.append, name), True))
                        for name in COMPARISONS)
        bindings.extend((self.append, name, self._function_delegate(name, getattr(self.append, name)))
                        for name in ("current_proof", "validate_history"))
        bindings.append((self.exchange, "collect", self._function_delegate("collector", self.exchange.collect)))
        originals = [(module, name, getattr(module, name)) for module, name, _wrapper in bindings]
        original_argv = sys.argv
        self._active, self.restored = True, False
        try:
            for module, name, wrapper in bindings:
                setattr(module, name, wrapper)
            if argv is not None:
                sys.argv = list(argv)
            yield self
        finally:
            for module, name, original in reversed(originals):
                try:
                    setattr(module, name, original)
                except Exception as exc:
                    self.errors.append("binding restoration: " + name + ": " + type(exc).__name__ + ": " + str(exc))
            sys.argv = original_argv
            self._active = False
            try:
                self.restored = (sys.argv is original_argv
                                 and all(getattr(module, name) is original for module, name, original in originals))
            except Exception as exc:
                self.restored = False
                self.errors.append("binding observation: " + type(exc).__name__ + ": " + str(exc))
            if not self.restored:
                self.errors.append("runtime bindings were not restored")

    def summary(self):
        documents = [dict(caller_file=key[0], caller_function=key[1], line=key[2],
                          comparison=key[3], role=key[4], path=key[5], raw_bytes=key[6], **row)
                     for key, row in sorted(self._documents.items())]
        functions = [dict(name=name, **row) for name, row in sorted(self._functions.items())]
        total = {name: sum(row[name] for row in documents) for name in ("calls", "failures", "bytes", "total_ns")}
        return {"documents": documents, "documents_total": total, "functions": functions,
                "errors": list(self.errors), "restored": self.restored,
                "claim": "instrumented inclusive times; overlapping totals are not additive",
                "unmeasured_document_aliases": ["coffee", "order350", "order351", "order365"]}


def _git(*args):
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=ROOT,
                            capture_output=True, check=True,
                            env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"})
    return result.stdout


def _record(path):
    if path.is_symlink():
        raw = os.readlink(path).encode()
        return {"kind": "symlink", "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
    digest, length = hashlib.sha256(), 0
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
            length += len(block)
    return {"kind": "file", "bytes": length, "sha256": digest.hexdigest()}


def _tree_map(folder):
    if not folder.is_dir() or folder.is_symlink():
        raise ValueError("required real directory unavailable: " + str(folder))
    return {str(path.relative_to(folder)): _record(path)
            for path in sorted(folder.rglob("*")) if path.is_file() or path.is_symlink()}


def source_state():
    head = _git("rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    tree = _git("rev-parse", "--verify", "HEAD^{tree}").decode().strip()
    status = _git("status", "--porcelain=v1", "-z", "--untracked-files=all").hex()
    tracked = {os.fsdecode(path): _record(ROOT / os.fsdecode(path))
               for path in _git("ls-files", "-z").split(b"\0") if path}
    prior = {}
    out = ROOT / ".git/full-game-localization"
    for path in sorted(out.glob("order452*")):
        if path.is_dir():
            prior.update({str(path.name + "/" + key): value for key, value in _tree_map(path).items()})
        else:
            prior[path.name] = _record(path)
    player = _tree_map(PLAYER)
    if _git("rev-parse", "--verify", "HEAD^{commit}").decode().strip() != head:
        raise ValueError("HEAD changed while observing source")
    return {"head": head, "tree": tree, "status_hex": status, "tracked": tracked,
            "tracked_files": len(tracked), "player": player, "player_files": len(player),
            "prior452": prior, "prior452_files": len(prior)}


def rss():
    raw = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    system = platform.system()
    return {"ru_maxrss": raw, "unit": "bytes" if system == "Darwin" else "KiB" if system == "Linux" else "platform-native",
            "platform": system, "meaning": "process lifetime high-water RSS, not per-function or an interval delta"}


class Tee:
    def __init__(self, original, log, errors):
        self.original, self.log, self.errors = original, log, errors

    def write(self, text):
        result = self.original.write(text)
        try:
            self.log.write(text)
            self.log.flush()
        except Exception as exc:
            self.errors.append("tee write: " + type(exc).__name__ + ": " + str(exc))
        return result

    def flush(self):
        self.original.flush()
        try:
            self.log.flush()
        except Exception as exc:
            self.errors.append("tee flush: " + type(exc).__name__ + ": " + str(exc))

    def __getattr__(self, name):
        return getattr(self.original, name)


def exclusive_json(path, value):
    with path.open("x", encoding="utf-8", newline="") as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2, allow_nan=False)
        stream.write("\n")


def run(label, expected_head):
    if not re.fullmatch(r"[a-z][a-z0-9-]{0,39}", label) or not re.fullmatch(r"[0-9a-f]{40}", expected_head):
        raise ValueError("invalid run label or expected full commit")
    if _record(SOURCE_FILE)["sha256"] != SOURCE_SHA256:
        raise ValueError("the measured append source differs from the sealed call sites")
    before = source_state()
    if before["head"] != expected_head or before["status_hex"] or before["player_files"] != 34:
        raise ValueError("measurement requires the expected clean candidate and all 34 player files")
    if not before["prior452_files"]:
        raise ValueError("prior452 evidence is unavailable")
    folder = ROOT / ".git/full-game-localization" / ("order453-cost-" + label)
    folder.mkdir(exist_ok=False)
    entry = {"schema": 1, "unit": "ORDER-453", "label": label, "expected_head": expected_head,
             "before": before, "started_epoch": time.time(), "rss_before": rss(),
             "measured_source_sha256": SOURCE_SHA256, "player_path": str(PLAYER),
             "command": ["python3", "-B", "tools/order365_ui_receipt_compat.py"], "historical_cases": 0}
    exclusive_json(folder / "entry.json", entry)
    errors, profiler = [], None
    main_calls, main_exit, main_exception, elapsed = 0, None, None, None
    original_bytecode = sys.dont_write_bytecode
    sys.dont_write_bytecode = True
    try:
        append = importlib.import_module("ui_translation_append")
        compat = importlib.import_module("order365_ui_receipt_compat")
        if Path(append.__file__).resolve() != SOURCE_FILE or compat.ui_append is not append:
            raise ValueError("actual module identity differs")
        profiler = ReceiptCostProfiler(append, append.exchange)
        with (folder / "stdout.log").open("x", encoding="utf-8", newline="") as stdout, \
             (folder / "stderr.log").open("x", encoding="utf-8", newline="") as stderr:
            with contextlib.redirect_stdout(Tee(sys.stdout, stdout, errors)), \
                 contextlib.redirect_stderr(Tee(sys.stderr, stderr, errors)), \
                 profiler.installed(argv=[str(ROOT / "tools/order365_ui_receipt_compat.py")]):
                start = time.perf_counter_ns()
                main_calls += 1
                try:
                    main_exit = compat.main()
                except BaseException as exc:
                    main_exception = {"type": type(exc).__name__, "message": str(exc)}
                    raise
                finally:
                    elapsed = time.perf_counter_ns() - start
    finally:
        sys.dont_write_bytecode = original_bytecode
        active_exception = sys.exc_info()[1]
        if active_exception is not None and main_exception is None:
            errors.append("setup/instrumentation exception: " + type(active_exception).__name__ + ": " + str(active_exception))
        after = None
        try:
            after = source_state()
            if before != after:
                errors.append("source, player or previous452 evidence changed")
        except Exception as exc:
            errors.append("final observation: " + type(exc).__name__ + ": " + str(exc))
        metrics = None
        try:
            metrics = profiler.summary() if profiler is not None else None
        except Exception as exc:
            errors.append("metric summary: " + type(exc).__name__ + ": " + str(exc))
        if metrics is not None:
            errors.extend(metrics["errors"])
            if not metrics["restored"]:
                errors.append("runtime bindings not restored")
        else:
            errors.append("profiler not installed")
        artifacts, rss_after = {}, None
        try:
            artifacts = {path.name: _record(path) for path in folder.iterdir() if path.is_file()}
        except Exception as exc:
            errors.append("artifact observation: " + type(exc).__name__ + ": " + str(exc))
        try:
            rss_after = rss()
        except Exception as exc:
            errors.append("RSS observation: " + type(exc).__name__ + ": " + str(exc))
        all_pass = main_calls == 1 and type(main_exit) is int and main_exit == 0 and main_exception is None and not errors
        result = {**entry, "after": after, "main_calls": main_calls, "main_exit": main_exit,
                  "main_exception": main_exception, "main_elapsed_ns": elapsed, "metrics": metrics,
                  "errors": errors, "rss_after": rss_after, "artifacts": artifacts,
                  "all_pass": all_pass, "source_unchanged": before == after,
                  "claim": "one instrumented actual365 default main; no optimization or precise A/B claim"}
        try:
            exclusive_json(folder / "result.json", result)
        except Exception as exc:
            all_pass = False
            errors.append("result artifact: " + type(exc).__name__ + ": " + str(exc))
            if active_exception is None:
                print(errors[-1], file=sys.stderr)
    if all_pass:
        print("UI_RECEIPT_COST_PROFILE_OK main_calls=1 historical_cases=0")
        return 0
    return main_exit if type(main_exit) is int and main_exit != 0 else 2


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run", action="store_true", required=True)
    parser.add_argument("--label", required=True)
    parser.add_argument("--expected-head", required=True)
    args = parser.parse_args()
    return run(args.label, args.expected_head)


if __name__ == "__main__":
    raise SystemExit(main())

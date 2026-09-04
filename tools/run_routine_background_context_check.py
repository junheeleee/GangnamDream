#!/usr/bin/env python3
"""Run ORDER-156's real MainGame routine-background check in isolated storage.

Failing runs retain all logs and their fresh Godot namespace. Only a fully
successful run atomically quarantines and removes runner-owned storage. This
is automated regression evidence, not a human-play gate.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import signal
import stat
import subprocess
import sys
import tempfile
import time


ROOT = Path(__file__).resolve().parents[1]
PREFIX = "GangnamDream_StoryNameplateQA_"
SUCCESS = re.compile(r"(?m)^ROUTINE_BACKGROUND_CONTEXT_CHECK_OK(?:\s|$)")
FAILURE = re.compile(
    r"ROUTINE_BACKGROUND_CONTEXT_CHECK_FAIL|SCRIPT ERROR|Parse Error|"
    r"Compile Error|Failed to load script|\bERROR:|ObjectDB instances leaked|"
    r"resources still in use",
    re.IGNORECASE,
)


class RunnerSignalInterrupt(BaseException):
    def __init__(self, signum: int):
        super().__init__(f"received signal {signum}")
        self.signum = signum


def user_data_parent() -> Path | None:
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support"
    if os.name == "nt":
        value = os.environ.get("APPDATA")
        return Path(value) if value else None
    value = os.environ.get("XDG_DATA_HOME")
    return Path(value) if value else Path.home() / ".local" / "share"


def text_payload(value: str | bytes | None) -> str:
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return value or ""


def validated_storage(output: str, expected: Path) -> tuple[Path | None, str | None]:
    before = re.findall(r"(?m)^STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=(.+)$", output)
    after = re.findall(r"(?m)^STORY_NAMEPLATE_QA_USER_DIR=(.+)$", output)
    if len(before) != 1 or len(after) != 1 or before[0] != after[0]:
        return None, "missing, duplicate, or mismatched isolation markers"
    raw = before[0]
    path = Path(raw)
    exact_name = re.compile(re.escape(PREFIX) + r"[0-9a-f]{32}")
    if raw != raw.strip() or not path.is_absolute() or not exact_name.fullmatch(path.name):
        return None, f"invalid QA storage marker: {raw!r}"
    if os.path.normcase(os.path.abspath(raw)) != os.path.normcase(os.path.abspath(expected)):
        return None, f"unexpected QA storage namespace: {path}"
    parent = user_data_parent()
    try:
        if parent is None or path.parent.resolve() != parent.resolve():
            return None, f"unexpected Godot userdata parent: {path.parent}"
    except OSError as exc:
        return None, f"cannot resolve QA storage parent: {exc}"
    return path, None


def wait_group_exit(group: int) -> str | None:
    deadline = time.monotonic() + 2.0
    while time.monotonic() < deadline:
        try:
            os.killpg(group, 0)
        except ProcessLookupError:
            return None
        except OSError as exc:
            return f"cannot confirm Godot process-group exit: {exc}"
        time.sleep(0.05)
    return "Godot process group still exists after 2 seconds"


def terminate_tree(proc: subprocess.Popen[str]) -> tuple[str, str, str | None]:
    errors: list[str] = []
    killed_group = False
    if os.name == "nt":
        try:
            result = subprocess.run(
                ["taskkill", "/PID", str(proc.pid), "/T", "/F"],
                capture_output=True, text=True, encoding="utf-8", errors="replace",
                timeout=5, check=False,
            )
            if result.returncode not in (0, 128):
                errors.append(f"taskkill exit {result.returncode}")
        except (OSError, subprocess.SubprocessError) as exc:
            errors.append(f"taskkill failed: {exc}")
    else:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
            killed_group = True
        except ProcessLookupError:
            pass
        except OSError as exc:
            errors.append(f"killpg failed: {exc}")
    try:
        stdout, stderr = proc.communicate(timeout=5)
    except subprocess.TimeoutExpired as exc:
        stdout, stderr = text_payload(exc.stdout), text_payload(exc.stderr)
        if proc.stdout:
            proc.stdout.close()
        if proc.stderr:
            proc.stderr.close()
        errors.append("pipe drain exceeded 5 seconds")
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            errors.append("process reap exceeded 2 seconds")
    if killed_group:
        group_error = wait_group_exit(proc.pid)
        if group_error:
            errors.append(group_error)
    return stdout, stderr, "; ".join(errors) or None


def kill_remaining_group(proc: subprocess.Popen[str]) -> str | None:
    if os.name == "nt":
        return None
    try:
        os.killpg(proc.pid, signal.SIGKILL)
    except ProcessLookupError:
        return None
    except OSError as exc:
        return f"failed to terminate remaining Godot process group: {exc}"
    return wait_group_exit(proc.pid)


def install_handlers() -> dict[int, object]:
    previous: dict[int, object] = {}

    def raise_signal(caught: int, _frame: object) -> None:
        raise RunnerSignalInterrupt(caught)

    for name in ("SIGTERM", "SIGHUP", "SIGQUIT", "SIGALRM"):
        signum = getattr(signal, name, None)
        if signum is not None:
            previous[signum] = signal.getsignal(signum)
            signal.signal(signum, raise_signal)
    return previous


def set_handlers(previous: dict[int, object], ignored: bool) -> None:
    for signum, handler in previous.items():
        signal.signal(signum, signal.SIG_IGN if ignored else handler)


def cleanup_storage(output: str, expected: Path, quarantine: Path) -> tuple[str | None, str | None]:
    path, error = validated_storage(output, expected)
    if error or path is None:
        return error, None
    stage = "pre_quarantine"
    try:
        if os.path.lexists(quarantine):
            return f"refused existing quarantine path: {quarantine}", None
        before = os.lstat(path)
        reparse = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0)
        attrs = getattr(before, "st_file_attributes", 0)
        if (not stat.S_ISDIR(before.st_mode) or stat.S_ISLNK(before.st_mode)
                or (reparse and attrs & reparse) or os.path.ismount(path)):
            return f"refused non-plain QA directory: {path}", None
        if os.name == "nt" or not shutil.rmtree.avoids_symlink_attacks:
            return None, f"ROUTINE_BACKGROUND_CONTEXT_QA_RETAINED_SAFE={path}"
        os.rename(path, quarantine)
        stage = f"quarantined:{quarantine}"
        after = os.lstat(quarantine)
        if (before.st_dev != after.st_dev or before.st_ino != after.st_ino
                or before.st_mode != after.st_mode or stat.S_ISLNK(after.st_mode)
                or os.path.ismount(quarantine)):
            return f"QA directory identity changed during quarantine: {quarantine}", None
        shutil.rmtree(quarantine)
    except OSError as exc:
        return f"cleanup failed stage={stage} original={path}: {exc}", None
    return None, f"ROUTINE_BACKGROUND_CONTEXT_QA_CLEANED={path}"


def write_result(evidence: Path, result: dict[str, object]) -> None:
    (evidence / "runner_result.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def fail(evidence: Path, reason: str) -> int:
    print(f"ROUTINE_BACKGROUND_CONTEXT_RUNNER_FAIL {reason}; evidence={evidence}")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT"))
    parser.add_argument("--resolution", default="1280x800", choices=("1280x800", "960x600"))
    parser.add_argument("--timeout", type=int, default=120)
    args = parser.parse_args()
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot:
        parser.error("Godot is required; set GODOT or --godot")

    evidence = Path(tempfile.mkdtemp(prefix="gangnam-routine-background-context-"))
    stdout_log, stderr_log, engine_log = (
        evidence / "stdout.log", evidence / "stderr.log", evidence / "godot.log")
    parent = user_data_parent()
    namespace = PREFIX + secrets.token_hex(16)
    qa_path = parent / namespace if parent else None
    quarantine = parent / (f".{namespace}.cleanup.{secrets.token_hex(8)}") if parent else None
    command = [
        godot, "--headless", "--path", str(ROOT), "--max-fps", "60",
        "--resolution", args.resolution, "--quit-after", "3600",
        "--log-file", str(engine_log), "--script",
        "res://tools/StoryNameplateBootstrap.gd", "--scene",
        "res://tools/RoutineBackgroundContextCheck.tscn",
    ]
    result: dict[str, object] = {
        "command": command, "engine_exit": None, "pid": None,
        "expected_user_dir": str(qa_path) if qa_path else None,
        "resolution": args.resolution, "status": "initializing",
        "storage_cleanup": "not_started",
    }
    print(f"ROUTINE_BACKGROUND_CONTEXT_EVIDENCE={evidence}", flush=True)
    if qa_path is None or quarantine is None:
        result.update(status="runner_error", reason="unknown Godot userdata parent")
        write_result(evidence, result)
        return fail(evidence, "cannot determine Godot userdata parent")
    if os.path.lexists(qa_path) or os.path.lexists(quarantine):
        result.update(status="runner_error", reason="preselected QA path already exists")
        write_result(evidence, result)
        return fail(evidence, "preselected QA path already exists")

    env = os.environ.copy()
    env["STORY_NAMEPLATE_QA_NAMESPACE"] = namespace
    isolation: dict[str, object] = (
        {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP}
        if os.name == "nt" else {"start_new_session": True})
    try:
        proc = subprocess.Popen(
            command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, encoding="utf-8", errors="replace", env=env, **isolation)
    except OSError as exc:
        stdout_log.write_text("", encoding="utf-8")
        stderr_log.write_text("", encoding="utf-8")
        result.update(status="spawn_error", reason=str(exc))
        write_result(evidence, result)
        return fail(evidence, str(exc))

    result["pid"] = proc.pid
    previous = install_handlers()
    try:
        stdout, stderr = proc.communicate(timeout=args.timeout)
        set_handlers(previous, True)
    except subprocess.TimeoutExpired:
        set_handlers(previous, True)
        stdout, stderr, error = terminate_tree(proc)
        set_handlers(previous, False)
        stdout_log.write_text(stdout, encoding="utf-8")
        stderr_log.write_text(stderr, encoding="utf-8")
        result.update(status="timeout", engine_exit=proc.returncode,
                      reason=error or f"engine exceeded {args.timeout} seconds",
                      storage_cleanup="retained_after_timeout")
        write_result(evidence, result)
        return fail(evidence, "engine timeout; QA storage retained")
    except RunnerSignalInterrupt as exc:
        set_handlers(previous, True)
        stdout, stderr, error = terminate_tree(proc)
        set_handlers(previous, False)
        try:
            stdout_log.write_text(stdout, encoding="utf-8")
            stderr_log.write_text(stderr, encoding="utf-8")
            result.update(status="signal_interrupted", engine_exit=proc.returncode,
                          reason=error or repr(exc), storage_cleanup="retained_after_signal")
            write_result(evidence, result)
        except OSError:
            pass
        print(f"ROUTINE_BACKGROUND_CONTEXT_RUNNER_FAIL signal {exc.signum}; "
              f"process tree stop {'unconfirmed: ' + error if error else 'confirmed'}; "
              f"QA storage retained; evidence={evidence}")
        return 128 + exc.signum
    except BaseException as exc:
        set_handlers(previous, True)
        stdout, stderr, error = terminate_tree(proc)
        set_handlers(previous, False)
        try:
            stdout_log.write_text(stdout, encoding="utf-8")
            stderr_log.write_text(stderr, encoding="utf-8")
            result.update(status="interrupted", engine_exit=proc.returncode,
                          reason=error or repr(exc), storage_cleanup="retained_after_interrupt")
            write_result(evidence, result)
        except OSError:
            pass
        raise

    result["engine_exit"] = proc.returncode
    group_error = kill_remaining_group(proc)
    set_handlers(previous, False)
    if group_error:
        result.update(status="process_group_error", reason=group_error,
                      storage_cleanup="retained_after_process_group_error")
        write_result(evidence, result)
        return fail(evidence, f"{group_error}; QA storage retained")
    try:
        stdout_log.write_text(stdout, encoding="utf-8")
        stderr_log.write_text(stderr, encoding="utf-8")
    except OSError as exc:
        result.update(status="evidence_error", reason=str(exc),
                      storage_cleanup="retained_after_evidence_error")
        write_result(evidence, result)
        return fail(evidence, f"cannot write output logs: {exc}; QA storage retained")
    if not engine_log.is_file():
        result.update(status="evidence_error", reason="missing engine log",
                      storage_cleanup="retained_after_evidence_error")
        write_result(evidence, result)
        return fail(evidence, "missing engine log; QA storage retained")

    combined = stdout + "\n" + stderr + "\n" + engine_log.read_text(
        encoding="utf-8", errors="replace")
    marker_path, marker_error = validated_storage(stdout, qa_path)
    reason = None
    if proc.returncode != 0:
        reason = f"engine exit {proc.returncode}"
    elif FAILURE.search(combined):
        reason = "engine or contract failure in output"
    elif not SUCCESS.search(combined):
        reason = "missing success marker"
    elif marker_error or marker_path is None:
        reason = marker_error
    if reason:
        result.update(status="test_error", reason=reason,
                      storage_cleanup="retained_after_test_error")
        write_result(evidence, result)
        return fail(evidence, f"{reason}; QA storage retained")

    cleanup_error, cleanup_line = cleanup_storage(stdout, qa_path, quarantine)
    if cleanup_error:
        result.update(status="cleanup_error", reason=cleanup_error,
                      storage_cleanup="retained_or_quarantined_after_cleanup_error")
        write_result(evidence, result)
        return fail(evidence, cleanup_error)
    result.update(status="passed", reason=None,
                  storage_cleanup="removed_after_atomic_quarantine"
                  if cleanup_line and "_CLEANED=" in cleanup_line else "retained_safe")
    write_result(evidence, result)
    print(stdout, end="" if not stdout or stdout.endswith("\n") else "\n")
    if stderr:
        print(stderr, end="" if stderr.endswith("\n") else "\n", file=sys.stderr)
    if cleanup_line:
        print(cleanup_line, flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Run the L2 nameplate regression with pre-autoload storage isolation.

Keeps both logs for diagnosis. Does not use player saves or certify human play.
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
SUCCESS = re.compile(r"(?m)^STORY_NAMEPLATE_CHECK_OK(?:\s|$)")
FATAL = re.compile(
    r"SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|\bERROR:|"
    r"ObjectDB instances leaked|resources still in use|STORY_NAMEPLATE_CHECK_FAIL",
    re.IGNORECASE,
)


class RunnerSignalInterrupt(BaseException):
    def __init__(self, signum: int):
        super().__init__(f"received signal {signum}")
        self.signum = signum


def print_runner_failure(evidence: Path, reason: str) -> None:
    print(f"STORY_NAMEPLATE_RUNNER_FAIL {reason}; evidence={evidence}")


def text_payload(value: str | bytes | None) -> str:
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return value or ""


def expected_userdata_parent() -> Path | None:
    """Return Godot's custom-user-dir parent for the current platform."""
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support"
    if os.name == "nt":
        appdata = os.environ.get("APPDATA")
        return Path(appdata) if appdata else None
    xdg_data = os.environ.get("XDG_DATA_HOME")
    return Path(xdg_data) if xdg_data else Path.home() / ".local" / "share"


def validated_qa_storage(
    output: str,
    expected_path: Path,
) -> tuple[Path | None, str | None]:
    """Accept one exact marker pair for the runner-selected path."""
    before = re.findall(r"(?m)^STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=(.+)$", output)
    after = re.findall(r"(?m)^STORY_NAMEPLATE_QA_USER_DIR=(.+)$", output)
    if len(before) != 1 or len(after) != 1 or before[0] != after[0]:
        return None, "missing, duplicate, or mismatched pre-autoload isolation evidence"
    raw_path = before[0]
    if raw_path != raw_path.strip():
        return None, "QA storage path contains surrounding whitespace"
    qa_path = Path(raw_path)
    expected_name = re.compile(r"GangnamDream_StoryNameplateQA_[0-9a-f]{32}")
    if (
        not qa_path.is_absolute()
        or not expected_name.fullmatch(qa_path.name)
        or os.path.normcase(os.path.abspath(raw_path))
        != os.path.normcase(os.path.abspath(str(expected_path)))
    ):
        return None, f"unexpected QA storage namespace: {qa_path}"
    expected_parent = expected_userdata_parent()
    if expected_parent is None:
        return None, "cannot determine Godot custom-user-dir parent"
    try:
        if qa_path.parent.resolve() != expected_parent.resolve():
            return None, f"unexpected Godot userdata parent: {qa_path.parent}"
    except OSError as exc:
        return None, f"cannot resolve QA storage parent: {exc}"
    return qa_path, None


def cleanup_qa_storage(
    output: str,
    expected_path: Path,
    quarantine_path: Path,
) -> tuple[str | None, str | None]:
    """Atomically quarantine, identity-check, then remove one validated namespace."""
    qa_path, validation_error = validated_qa_storage(output, expected_path)
    if validation_error or qa_path is None:
        return validation_error, None
    stage = "pre_quarantine"
    try:
        if os.path.lexists(quarantine_path):
            return f"refused existing QA quarantine path: {quarantine_path}", None
        before = os.lstat(qa_path)
        reparse_flag = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0)
        file_attributes = getattr(before, "st_file_attributes", 0)
        if (
            not stat.S_ISDIR(before.st_mode)
            or stat.S_ISLNK(before.st_mode)
            or (reparse_flag and file_attributes & reparse_flag)
            or os.path.ismount(qa_path)
        ):
            return f"refused non-plain QA directory: {qa_path}", None
        if os.name == "nt" or not shutil.rmtree.avoids_symlink_attacks:
            return None, f"STORY_NAMEPLATE_QA_RETAINED_SAFE={qa_path}"
        os.rename(qa_path, quarantine_path)
        stage = f"quarantined:{quarantine_path}"
        after = os.lstat(quarantine_path)
        if (
            before.st_dev != after.st_dev
            or before.st_ino != after.st_ino
            or before.st_mode != after.st_mode
            or stat.S_ISLNK(after.st_mode)
            or os.path.ismount(quarantine_path)
        ):
            return f"QA directory identity changed during quarantine: {quarantine_path}", None
        shutil.rmtree(quarantine_path)
    except OSError as exc:
        return (
            f"failed QA storage cleanup stage={stage} original={qa_path} "
            f"quarantine={quarantine_path}: {exc}",
            None,
        )
    return None, f"STORY_NAMEPLATE_QA_CLEANED={qa_path}"


def terminate_process_tree(proc: subprocess.Popen[str]) -> tuple[str, str, str | None]:
    """Kill the isolated process group/tree and bound the final pipe drain."""
    errors: list[str] = []
    killed_posix_group = False
    if os.name == "nt":
        try:
            killer = subprocess.run(
                ["taskkill", "/PID", str(proc.pid), "/T", "/F"],
                capture_output=True, text=True, encoding="utf-8", errors="replace",
                timeout=5, check=False,
            )
            if killer.returncode not in (0, 128):
                errors.append(f"taskkill exit {killer.returncode}")
        except (OSError, subprocess.SubprocessError) as exc:
            errors.append(f"taskkill failed: {exc}")
    else:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
            killed_posix_group = True
        except ProcessLookupError:
            pass
        except OSError as exc:
            errors.append(f"killpg failed: {exc}")
    try:
        stdout, stderr = proc.communicate(timeout=5)
    except subprocess.TimeoutExpired as exc:
        stdout = text_payload(exc.stdout)
        stderr = text_payload(exc.stderr)
        if proc.stdout:
            proc.stdout.close()
        if proc.stderr:
            proc.stderr.close()
        errors.append("pipe drain exceeded 5 seconds")
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            errors.append("process reap exceeded 2 seconds")
    if killed_posix_group:
        group_error = wait_for_process_group_exit(proc.pid)
        if group_error:
            errors.append(group_error)
    return stdout, stderr, "; ".join(errors) or None


def kill_remaining_process_group(proc: subprocess.Popen[str]) -> str | None:
    """Ensure a successful Godot parent left no process able to mutate QA data."""
    if os.name == "nt":
        return None
    try:
        os.killpg(proc.pid, signal.SIGKILL)
    except ProcessLookupError:
        return None
    except OSError as exc:
        return f"failed to terminate remaining Godot process group: {exc}"
    return wait_for_process_group_exit(proc.pid)


def wait_for_process_group_exit(process_group_id: int) -> str | None:
    """Bound the gap between SIGKILL and storage quarantine."""
    deadline = time.monotonic() + 2.0
    while time.monotonic() < deadline:
        try:
            os.killpg(process_group_id, 0)
        except ProcessLookupError:
            return None
        except OSError as exc:
            return f"cannot confirm Godot process-group exit: {exc}"
        time.sleep(0.05)
    return "Godot process group still exists after 2 seconds"


def failure_reason(
    status: int,
    combined_output: str,
    marker_output: str,
    expected_path: Path,
) -> str | None:
    if status != 0:
        return f"engine exit {status}"
    if FATAL.search(combined_output):
        return "engine/test error in output"
    if not SUCCESS.search(combined_output):
        return "missing success marker"
    _qa_path, validation_error = validated_qa_storage(marker_output, expected_path)
    return validation_error


def write_runner_result(evidence: Path, result: dict[str, object]) -> None:
    (evidence / "runner_result.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def install_termination_handlers() -> dict[int, object]:
    previous: dict[int, object] = {}

    def raise_signal(caught: int, _frame: object) -> None:
        raise RunnerSignalInterrupt(caught)

    for signame in ("SIGTERM", "SIGHUP", "SIGQUIT"):
        signum = getattr(signal, signame, None)
        if signum is None:
            continue
        previous[signum] = signal.getsignal(signum)
        signal.signal(signum, raise_signal)
    return previous


def restore_termination_handlers(previous: dict[int, object]) -> None:
    for signum, handler in previous.items():
        signal.signal(signum, handler)


def ignore_termination_handlers(previous: dict[int, object]) -> None:
    for signum in previous:
        signal.signal(signum, signal.SIG_IGN)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT"))
    args = parser.parse_args()
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot:
        parser.error("Godot is required; set GODOT or --godot")
    evidence = Path(tempfile.mkdtemp(prefix="gangnam-story-nameplate-"))
    engine_log = evidence / "godot.log"
    stdout_log = evidence / "stdout.log"
    stderr_log = evidence / "stderr.log"
    expected_parent = expected_userdata_parent()
    qa_namespace = "GangnamDream_StoryNameplateQA_" + secrets.token_hex(16)
    expected_path = expected_parent / qa_namespace if expected_parent else None
    quarantine_path = (
        expected_parent / ("." + qa_namespace + ".cleanup." + secrets.token_hex(8))
        if expected_parent else None
    )
    command = [
        godot, "--headless", "--path", str(ROOT), "--max-fps", "60",
        "--resolution", "1280x800", "--quit-after", "3600",
        "--log-file", str(engine_log),
        "--script", "res://tools/StoryNameplateBootstrap.gd",
        "--scene", "res://tools/StoryNameplateCheck.tscn",
    ]
    print(f"STORY_NAMEPLATE_EVIDENCE={evidence}", flush=True)
    result: dict[str, object] = {
        "command": command,
        "engine_exit": None,
        "expected_user_dir": str(expected_path) if expected_path else None,
        "pid": None,
        "status": "initializing",
        "storage_cleanup": "not_started",
    }
    if expected_path is None or quarantine_path is None:
        result.update(status="runner_error", reason="unknown Godot userdata parent")
        write_runner_result(evidence, result)
        print_runner_failure(evidence, "cannot determine Godot userdata parent")
        return 1
    if os.path.lexists(expected_path) or os.path.lexists(quarantine_path):
        result.update(status="runner_error", reason="preselected QA path already exists")
        write_runner_result(evidence, result)
        print_runner_failure(evidence, "preselected QA path already exists")
        return 1
    child_env = os.environ.copy()
    child_env["STORY_NAMEPLATE_QA_NAMESPACE"] = qa_namespace
    process_isolation: dict[str, object] = (
        {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP}
        if os.name == "nt" else {"start_new_session": True}
    )
    try:
        proc = subprocess.Popen(
            command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, encoding="utf-8", errors="replace", env=child_env,
            **process_isolation,
        )
    except OSError as exc:
        stdout_log.write_text("", encoding="utf-8")
        stderr_log.write_text("", encoding="utf-8")
        result.update(status="spawn_error", reason=str(exc))
        write_runner_result(evidence, result)
        print_runner_failure(evidence, str(exc))
        return 1
    result["pid"] = proc.pid
    previous_handlers = install_termination_handlers()
    try:
        stdout, stderr = proc.communicate(timeout=120)
        ignore_termination_handlers(previous_handlers)
    except subprocess.TimeoutExpired:
        ignore_termination_handlers(previous_handlers)
        stdout, stderr, termination_error = terminate_process_tree(proc)
        restore_termination_handlers(previous_handlers)
        stdout_log.write_text(stdout, encoding="utf-8")
        stderr_log.write_text(stderr, encoding="utf-8")
        result.update(
            status="timeout",
            engine_exit=proc.returncode,
            reason=termination_error or "engine exceeded 120 seconds",
            storage_cleanup="retained_after_timeout",
        )
        write_runner_result(evidence, result)
        if termination_error:
            print_runner_failure(
                evidence,
                f"engine timeout; process-tree stop unconfirmed ({termination_error}); QA storage retained",
            )
        else:
            print_runner_failure(
                evidence,
                "engine timeout; process tree stopped; QA storage retained",
            )
        return 1
    except RunnerSignalInterrupt as exc:
        ignore_termination_handlers(previous_handlers)
        stdout, stderr, termination_error = terminate_process_tree(proc)
        restore_termination_handlers(previous_handlers)
        try:
            stdout_log.write_text(stdout, encoding="utf-8")
            stderr_log.write_text(stderr, encoding="utf-8")
            result.update(
                status="signal_interrupted",
                engine_exit=proc.returncode,
                reason=termination_error or repr(exc),
                storage_cleanup="retained_after_signal",
            )
            write_runner_result(evidence, result)
        except OSError:
            pass
        print_runner_failure(
            evidence,
            f"signal {exc.signum}; process tree stop "
            f"{'unconfirmed: ' + termination_error if termination_error else 'confirmed'}; QA storage retained",
        )
        return 128 + exc.signum
    except BaseException as exc:
        ignore_termination_handlers(previous_handlers)
        stdout, stderr, termination_error = terminate_process_tree(proc)
        restore_termination_handlers(previous_handlers)
        try:
            stdout_log.write_text(stdout, encoding="utf-8")
            stderr_log.write_text(stderr, encoding="utf-8")
            result.update(
                status="interrupted",
                engine_exit=proc.returncode,
                pid=proc.pid,
                reason=termination_error or repr(exc),
                storage_cleanup="retained_after_interrupt",
            )
            write_runner_result(evidence, result)
        except OSError:
            pass
        raise
    result["engine_exit"] = proc.returncode
    group_error = kill_remaining_process_group(proc)
    restore_termination_handlers(previous_handlers)
    if group_error:
        result.update(status="process_group_error", reason=group_error,
                      storage_cleanup="retained_after_process_group_error")
        write_runner_result(evidence, result)
        print_runner_failure(evidence, f"{group_error}; QA storage retained")
        return 1
    try:
        stdout_log.write_text(stdout, encoding="utf-8")
        stderr_log.write_text(stderr, encoding="utf-8")
    except OSError as exc:
        result.update(status="evidence_error", reason=str(exc),
                      storage_cleanup="retained_after_evidence_error")
        write_runner_result(evidence, result)
        print_runner_failure(evidence, f"cannot write output logs: {exc}; QA storage retained")
        return 1
    if not engine_log.is_file():
        result.update(status="evidence_error", reason="missing engine log",
                      storage_cleanup="retained_after_evidence_error")
        write_runner_result(evidence, result)
        print_runner_failure(evidence, "missing engine log; QA storage retained")
        return 1
    combined = stdout + "\n" + stderr + "\n" + engine_log.read_text(
        encoding="utf-8", errors="replace")
    reason = failure_reason(proc.returncode, combined, stdout, expected_path)
    if reason:
        result.update(status="test_error", reason=reason,
                      storage_cleanup="retained_after_test_error")
        write_runner_result(evidence, result)
        print_runner_failure(evidence, f"{reason}; QA storage retained")
        return 1
    cleanup_error, cleanup_line = cleanup_qa_storage(
        stdout, expected_path, quarantine_path)
    if cleanup_error:
        result.update(status="cleanup_error", reason=cleanup_error,
                      storage_cleanup="retained_or_quarantined_after_cleanup_error")
        write_runner_result(evidence, result)
        print_runner_failure(evidence, cleanup_error)
        return 1
    if cleanup_line:
        with stdout_log.open("a", encoding="utf-8") as handle:
            if stdout and not stdout.endswith("\n"):
                handle.write("\n")
            handle.write(cleanup_line + "\n")
    result.update(
        status="passed",
        reason=None,
        storage_cleanup=(
            "removed_after_atomic_quarantine"
            if cleanup_line and "_CLEANED=" in cleanup_line else "retained_safe"
        ),
    )
    write_runner_result(evidence, result)
    print(stdout, end="" if not stdout or stdout.endswith("\n") else "\n")
    if stderr:
        print(stderr, end="" if stderr.endswith("\n") else "\n", file=sys.stderr)
    if cleanup_line:
        print(cleanup_line, flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
case "${mode}" in
  ko-gamepad)
    scope="core-loop-v2-gamepad"
    language="ko"
    marker="CORE_LOOP_V2_INPUT_OK device=gamepad lang=ko weeks=24"
    pad="playstation"
    ;;
  en-keyboard)
    scope="core-loop-v2-keyboard"
    language="en"
    marker="CORE_LOOP_V2_INPUT_OK device=keyboard lang=en weeks=24"
    pad=""
    ;;
  *)
    echo "usage: $0 {ko-gamepad|en-keyboard}" >&2
    exit 2
    ;;
esac

qa_args=("--qa=${scope}" "--lang=${language}")
if [[ -n "${pad}" ]]; then
  qa_args+=("--pad=${pad}")
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "${script_dir}/.." && pwd)"
qa_root="$(mktemp -d "${TMPDIR:-/tmp}/gangnamdream-v2-${mode}.XXXXXX")"
output_dir="${GANGNAM_QA_OUT:-${qa_root}/shots}"
log_path="${GANGNAM_QA_LOG:-${qa_root}/${mode}.log}"
godot_bin="${GODOT:-godot}"

isolated_user_dir="${qa_root}/game-user"
mkdir -p "${output_dir}" "$(dirname "${log_path}")" "${isolated_user_dir}"
if [[ "${godot_bin}" == */* ]]; then
  if [[ ! -x "${godot_bin}" ]]; then
    echo "Godot executable is not available: ${godot_bin}" >&2
    exit 2
  fi
elif ! command -v "${godot_bin}" >/dev/null 2>&1; then
  echo "Godot executable is not on PATH: ${godot_bin}" >&2
  exit 2
fi

runner=("${godot_bin}")
display_args=(--rendering-driver opengl3)
if [[ "${GANGNAM_QA_XVFB:-0}" == "1" ]]; then
  if ! command -v xvfb-run >/dev/null 2>&1; then
    echo "GANGNAM_QA_XVFB=1 requires xvfb-run." >&2
    exit 2
  fi
  runner=(xvfb-run -a "${godot_bin}")
  display_args=(--display-driver x11 --rendering-driver opengl3)
fi

cd "${project_root}"
XDG_DATA_HOME="${qa_root}/data" \
XDG_CONFIG_HOME="${qa_root}/config" \
XDG_CACHE_HOME="${qa_root}/cache" \
GANGNAM_QA_OUT="${output_dir}" \
GANGNAM_QA_USER_DIR="${isolated_user_dir}" \
  "${runner[@]}" "${display_args[@]}" \
    --log-file "${qa_root}/godot.log" \
    --resolution 1280x800 res://tools/ScreenshotQA.tscn -- \
    "${qa_args[@]}" \
    --demo-build --core-loop-v2-playtest-build --qa-isolated-user-data \
    2>&1 | tee "${log_path}"

grep -F "${marker}" "${log_path}" >/dev/null
echo "CORE_LOOP_V2_QA_EVIDENCE mode=${mode} log=${log_path} shots=${output_dir}"

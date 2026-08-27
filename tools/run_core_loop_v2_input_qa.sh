#!/usr/bin/env bash
set -euo pipefail

# A full 24-week raw-input route takes about 9m20s on the macOS OpenGL QA host.
# Keep roughly 28% wall-clock headroom while the in-scene stagnation guards
# remain responsible for detecting routes that stop making progress.
qa_timeout_seconds="${GANGNAM_QA_TIMEOUT_SECONDS:-720}"
run_qa_limited() {
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "${qa_timeout_seconds}" "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "${qa_timeout_seconds}" "$@"
  elif command -v perl >/dev/null 2>&1; then
    perl -e '$seconds = shift; alarm $seconds; exec @ARGV' \
      "${qa_timeout_seconds}" "$@"
  else
    "$@"
  fi
}

# A recursive engine error can otherwise duplicate gigabytes through Godot's
# own log and tee before a developer can stop it. Normal route evidence is far
# below this per-file ceiling; hitting it is always a failed QA run.
ulimit -f "${GANGNAM_QA_MAX_FILE_BLOCKS:-32768}" 2>/dev/null || true

mode="${1:-}"
if [[ "${mode}" == "full-matrix" ]]; then
  for language_value in ko en; do
    for device_value in keyboard gamepad; do
      "${BASH_SOURCE[0]}" "${language_value}-${device_value}"
    done
  done
  echo "CORE_LOOP_V2_FULL_MATRIX_OK languages=ko+en devices=keyboard+gamepad weeks=24 cases=4"
  exit 0
fi
if [[ "${mode}" == "month-one-matrix" ]]; then
  for language_value in ko en; do
    for device_value in keyboard gamepad; do
      for path_value in livelihood people recovery; do
        "${BASH_SOURCE[0]}" \
          "month-one-${language_value}-${device_value}-${path_value}"
      done
    done
  done
  echo "CORE_LOOP_V2_MONTH_ONE_MATRIX_OK languages=ko+en devices=keyboard+gamepad paths=livelihood+people+recovery cases=12"
  exit 0
fi
if [[ "${mode}" == "surface-matrix" ]]; then
  for language_value in ko en; do
    for resolution_value in 1280x800 960x600; do
      "${BASH_SOURCE[0]}" \
        "surface-${language_value}-${resolution_value}"
    done
  done
  echo "CORE_LOOP_V2_SURFACE_MATRIX_OK languages=ko+en resolutions=1280x800+960x600 cases=4"
  exit 0
fi

cycle_path=""
resolution="1280x800"
if [[ "${mode}" =~ ^month-one-(ko|en)-(keyboard|gamepad)-(livelihood|people|recovery)$ ]]; then
  language="${BASH_REMATCH[1]}"
  device="${BASH_REMATCH[2]}"
  cycle_path="${BASH_REMATCH[3]}"
  scope="core-loop-v2-${device}"
  marker="CORE_LOOP_V2_MONTH_ONE_PATH_OK device=${device} lang=${language} path=${cycle_path} weeks=4"
  pad=""
  if [[ "${device}" == "gamepad" ]]; then
    pad="playstation"
  fi
elif [[ "${mode}" =~ ^surface-(ko|en)-(1280x800|960x600)$ ]]; then
  language="${BASH_REMATCH[1]}"
  resolution="${BASH_REMATCH[2]}"
  scope="core-loop-v2"
  marker="SCREENSHOT_QA_DONE scope=core-loop-v2 lang=${language}"
  pad=""
else
  case "${mode}" in
    ko-keyboard|ko-gamepad|en-keyboard|en-gamepad)
      language="${mode%%-*}"
      device="${mode##*-}"
      scope="core-loop-v2-${device}"
      marker="CORE_LOOP_V2_INPUT_OK device=${device} lang=${language} weeks=24"
      pad=""
      if [[ "${device}" == "gamepad" ]]; then
        pad="playstation"
      fi
      ;;
    *)
      echo "usage: $0 {full-matrix|{ko|en}-{keyboard|gamepad}|month-one-matrix|surface-matrix|month-one-{ko|en}-{keyboard|gamepad}-{livelihood|people|recovery}|surface-{ko|en}-{1280x800|960x600}}" >&2
      exit 2
      ;;
  esac
fi

qa_args=("--qa=${scope}" "--lang=${language}")
if [[ -n "${cycle_path}" ]]; then
  qa_args+=("--month-one-only" "--cycle-path=${cycle_path}")
fi
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
audio_args=()
if [[ "${GANGNAM_QA_XVFB:-0}" == "1" ]]; then
  if ! command -v xvfb-run >/dev/null 2>&1; then
    echo "GANGNAM_QA_XVFB=1 requires xvfb-run." >&2
    exit 2
  fi
  runner=(xvfb-run -a "${godot_bin}")
  display_args=(--display-driver x11 --rendering-driver opengl3)
  # CI's virtual display has no PulseAudio/ALSA device. The input and surface
  # routes do not judge sound, so use Godot's deterministic silent driver and
  # keep real local A/V runs on their platform driver.
  audio_args=(--audio-driver Dummy)
fi

cd "${project_root}"
qa_command=("${runner[@]}" "${display_args[@]}")
if ((${#audio_args[@]} > 0)); then
  qa_command+=("${audio_args[@]}")
fi
qa_command+=(
  --log-file "${qa_root}/godot.log"
  --resolution "${resolution}" res://tools/ScreenshotQA.tscn --
  "${qa_args[@]}"
  --demo-build --core-loop-v2-playtest-build --qa-isolated-user-data
)
XDG_DATA_HOME="${qa_root}/data" \
XDG_CONFIG_HOME="${qa_root}/config" \
XDG_CACHE_HOME="${qa_root}/cache" \
GANGNAM_QA_OUT="${output_dir}" \
GANGNAM_QA_USER_DIR="${isolated_user_dir}" \
  run_qa_limited "${qa_command[@]}" \
    2>&1 | tee "${log_path}"

grep -F "${marker}" "${log_path}" >/dev/null
runtime_error_pattern='ERROR:|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script'
if {
  grep -iE "${runtime_error_pattern}" "${log_path}" 2>/dev/null
  grep -iE "${runtime_error_pattern}" "${qa_root}/godot.log" 2>/dev/null
} | grep -viE 'ERROR: [0-9]+ resources still in use at exit' >/dev/null; then
  echo "Core Loop V2 QA printed an engine/script error despite its success marker:" >&2
  {
    grep -iE "${runtime_error_pattern}" "${log_path}" 2>/dev/null
    grep -iE "${runtime_error_pattern}" "${qa_root}/godot.log" 2>/dev/null
  } | grep -viE 'ERROR: [0-9]+ resources still in use at exit' \
    | sed 's/^/  /' >&2
  exit 1
fi
echo "CORE_LOOP_V2_QA_EVIDENCE mode=${mode} log=${log_path} shots=${output_dir}"

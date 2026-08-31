#!/usr/bin/env bash
# Fresh-title W1->W240 occurrence trace runner.
# Runtime JSONL is generated evidence, not a checked-in baseline and not a
# human density/fun verdict.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "${script_dir}/.." && pwd)"
profiles_path="${project_root}/tools/full_game_runtime_trace_profiles.json"
audit_path="${project_root}/tools/full_game_runtime_trace_audit.py"
godot_bin="${GODOT:-godot}"
timeout_seconds="${GANGNAM_TRACE_TIMEOUT_SECONDS:-7200}"
output_dir=""
requested_profile=""
matrix=0

usage() {
  echo "usage: $0 [--matrix | --profile PROFILE] [--godot PATH] [--output-dir DIR]" >&2
}

while (($# > 0)); do
  case "$1" in
    --matrix)
      matrix=1
      ;;
    --profile)
      shift
      if (($# == 0)); then usage; exit 2; fi
      requested_profile="$1"
      ;;
    --profile=*)
      requested_profile="${1#--profile=}"
      ;;
    --godot)
      shift
      if (($# == 0)); then usage; exit 2; fi
      godot_bin="$1"
      ;;
    --godot=*)
      godot_bin="${1#--godot=}"
      ;;
    --output-dir)
      shift
      if (($# == 0)); then usage; exit 2; fi
      output_dir="$1"
      ;;
    --output-dir=*)
      output_dir="${1#--output-dir=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if ((matrix == 1)) && [[ -n "${requested_profile}" ]]; then
  echo "--matrix and --profile are mutually exclusive" >&2
  exit 2
fi
if ((matrix == 0)) && [[ -z "${requested_profile}" ]]; then
  requested_profile="baseline_safe_people"
fi
if [[ ! "${timeout_seconds}" =~ ^[1-9][0-9]*$ ]]; then
  echo "FULL_GAME_RUNTIME_TRACE_PENDING reason=invalid_timeout_seconds value=${timeout_seconds}" >&2
  exit 2
fi

if [[ "${godot_bin}" == */* ]]; then
  if [[ ! -x "${godot_bin}" ]]; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING reason=godot_unavailable path=${godot_bin}" >&2
    exit 2
  fi
elif ! command -v "${godot_bin}" >/dev/null 2>&1; then
  echo "FULL_GAME_RUNTIME_TRACE_PENDING reason=godot_unavailable command=${godot_bin}" >&2
  exit 2
fi

cd "${project_root}"
python3 "${audit_path}"
if ! git diff --quiet -- || ! git diff --cached --quiet --; then
  echo "FULL_GAME_RUNTIME_TRACE_PENDING reason=dirty_candidate tracked=true" >&2
  exit 2
fi
untracked="$(git ls-files --others --exclude-standard)"
if [[ -n "${untracked}" ]]; then
  echo "FULL_GAME_RUNTIME_TRACE_PENDING reason=dirty_candidate untracked=true" >&2
  printf '%s\n' "${untracked}" | sed 's/^/  /' >&2
  exit 2
fi

candidate_commit="$(git rev-parse HEAD)"
candidate_tree="$(git rev-parse 'HEAD^{tree}')"
if [[ ! "${candidate_commit}" =~ ^[0-9a-f]{40}$ ]] || [[ ! "${candidate_tree}" =~ ^[0-9a-f]{40}$ ]]; then
  echo "FULL_GAME_RUNTIME_TRACE_PENDING reason=invalid_candidate_identity" >&2
  exit 2
fi

if [[ -z "${output_dir}" ]]; then
  output_dir="${project_root}/build/qa/full_game_runtime_trace/${candidate_commit}"
elif [[ "${output_dir}" != /* ]]; then
  output_dir="${project_root}/${output_dir}"
fi
mkdir -p "${output_dir}"

profiles=("${requested_profile}")
if ((matrix == 1)); then
  profiles=(
    baseline_safe_people
    investment_property_daeun
    general_near_goal_father_passed
  )
fi

run_profile() {
  local profile_id="$1"
  local profile_hash
  local trace_root
  local trace_home
  local trace_output
  local stdout_log
  local godot_log
  local import_log
  local import_godot_log
  local import_status=0
  local runtime_status=0
  local post_commit
  local post_tree
  local post_untracked
  local -a limited_prefix=()

  profile_hash="$(python3 "${audit_path}" --profile "${profile_id}" --print-profile-hash)"
  if [[ ! "${profile_hash}" =~ ^[0-9a-f]{64}$ ]]; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=invalid_profile_hash" >&2
    return 2
  fi
  trace_output="${output_dir}/${profile_id}.jsonl"
  stdout_log="${output_dir}/${profile_id}.stdout.log"
  import_log="${output_dir}/${profile_id}.import.log"
  if [[ -e "${trace_output}" || -e "${stdout_log}" || -e "${import_log}" ]]; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=output_exists path=${trace_output}" >&2
    return 2
  fi

  trace_root="$(mktemp -d "${TMPDIR:-/tmp}/gangnamdream-full-trace-${profile_id}.XXXXXX")"
  trace_home="${trace_root}/home"
  mkdir -p \
    "${trace_home}" \
    "${trace_root}/xdg-data" \
    "${trace_root}/xdg-config" \
    "${trace_root}/xdg-cache"
  godot_log="${trace_root}/godot.log"
  import_godot_log="${trace_root}/import-godot.log"

  cleanup_trace_root() {
    case "${trace_root}" in
      "${TMPDIR:-/tmp}"/gangnamdream-full-trace-*) rm -rf -- "${trace_root}" ;;
      *) echo "refusing to clean unexpected trace root: ${trace_root}" >&2 ;;
    esac
  }
  trap cleanup_trace_root RETURN

  local -a trace_command=(
    "${godot_bin}"
    --headless
    --audio-driver Dummy
    --path "${project_root}"
    --log-file "${godot_log}"
    res://tools/FullGameRuntimeTrace.tscn
    --
    "--profile=${profile_id}"
    "--profiles=${profiles_path}"
    "--trace-output=${trace_output}"
    "--candidate-commit=${candidate_commit}"
    "--candidate-tree=${candidate_tree}"
    "--candidate-dirty=false"
    "--profile-hash=${profile_hash}"
  )

  # A full W1->W240 product traversal can run for hours, but an engine hang
  # must remain a visible PENDING result instead of blocking CI forever.
  if command -v timeout >/dev/null 2>&1; then
    limited_prefix=(timeout "${timeout_seconds}")
  elif command -v gtimeout >/dev/null 2>&1; then
    limited_prefix=(gtimeout "${timeout_seconds}")
  elif command -v perl >/dev/null 2>&1; then
    limited_prefix=(perl -e 'alarm shift @ARGV; exec @ARGV' "${timeout_seconds}")
  else
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=timeout_command_unavailable" >&2
    return 2
  fi

  # A fresh detached checkout has no ignored `.godot` class cache. Build it
  # inside the same isolated user environment before loading the trace scene;
  # otherwise global class_name references can fail before the recorder boots.
  local -a import_command=(
    "${godot_bin}"
    --headless
    --import
    --quit-after 2000
    --audio-driver Dummy
    --path "${project_root}"
    --log-file "${import_godot_log}"
  )
  set +e
  HOME="${trace_home}" \
  XDG_DATA_HOME="${trace_root}/xdg-data" \
  XDG_CONFIG_HOME="${trace_root}/xdg-config" \
  XDG_CACHE_HOME="${trace_root}/xdg-cache" \
    "${limited_prefix[@]}" "${import_command[@]}" >"${import_log}" 2>&1
  import_status=$?
  set -e
  if ((import_status == 124 || import_status == 142)); then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=import_timeout seconds=${timeout_seconds} log=${import_log}" >&2
    return 1
  fi
  if ((import_status != 0)); then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=import_failed exit=${import_status} log=${import_log}" >&2
    return 1
  fi
  if [[ ! -f "${project_root}/.godot/global_script_class_cache.cfg" ]]; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=class_cache_missing_after_import log=${import_log}" >&2
    return 1
  fi
  if {
    grep -iE 'ERROR:|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script' "${import_log}" 2>/dev/null || true
    grep -iE 'ERROR:|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script' "${import_godot_log}" 2>/dev/null || true
  } | grep -viE 'ERROR: [0-9]+ resources still in use at exit' >/dev/null; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=import_engine_or_script_error log=${import_log}" >&2
    return 1
  fi
  post_commit="$(git rev-parse HEAD)"
  post_tree="$(git rev-parse 'HEAD^{tree}')"
  post_untracked="$(git ls-files --others --exclude-standard)"
  if [[ "${post_commit}" != "${candidate_commit}" \
      || "${post_tree}" != "${candidate_tree}" \
      || -n "${post_untracked}" ]] \
      || ! git diff --quiet -- \
      || ! git diff --cached --quiet --; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=candidate_changed_during_import" >&2
    return 1
  fi

  set +e
  HOME="${trace_home}" \
  XDG_DATA_HOME="${trace_root}/xdg-data" \
  XDG_CONFIG_HOME="${trace_root}/xdg-config" \
  XDG_CACHE_HOME="${trace_root}/xdg-cache" \
    "${limited_prefix[@]}" "${trace_command[@]}" >"${stdout_log}" 2>&1
  runtime_status=$?
  set -e

  # Seal the mutable checkout again after the potentially multi-hour run.
  # Evidence is invalid if HEAD, tree, index, tracked bytes, or untracked source
  # changed after the identity embedded in JSONL was captured.
  post_commit="$(git rev-parse HEAD)"
  post_tree="$(git rev-parse 'HEAD^{tree}')"
  post_untracked="$(git ls-files --others --exclude-standard)"
  if [[ "${post_commit}" != "${candidate_commit}" \
      || "${post_tree}" != "${candidate_tree}" \
      || -n "${post_untracked}" ]] \
      || ! git diff --quiet -- \
      || ! git diff --cached --quiet --; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=candidate_changed_during_runtime" >&2
    return 1
  fi

  if ((runtime_status == 124 || runtime_status == 142)); then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=timeout seconds=${timeout_seconds} trace=${trace_output} log=${stdout_log}" >&2
    return 1
  fi

  runtime_error_pattern='ERROR:|SCRIPT ERROR|Parse Error|Compile Error|Failed to load script'
  if {
    grep -iE "${runtime_error_pattern}" "${stdout_log}" 2>/dev/null || true
    grep -iE "${runtime_error_pattern}" "${godot_log}" 2>/dev/null || true
  } | grep -viE 'ERROR: [0-9]+ resources still in use at exit' >/dev/null; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=engine_or_script_error log=${stdout_log}" >&2
    return 1
  fi
  if [[ ! -s "${trace_output}" ]]; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=no_jsonl exit=${runtime_status} log=${stdout_log}" >&2
    return 1
  fi
  if ((runtime_status != 0)); then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=runtime_profile_fail exit=${runtime_status} trace=${trace_output} log=${stdout_log}" >&2
    return 1
  fi
  if ! grep -F "FULL_GAME_RUNTIME_TRACE_RUN_OK profile=${profile_id}" "${stdout_log}" >/dev/null; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=success_marker_missing trace=${trace_output}" >&2
    return 1
  fi
  if ! python3 "${audit_path}" \
      --trace "${trace_output}" \
      --profile "${profile_id}" \
      --candidate-commit "${candidate_commit}" \
      --candidate-tree "${candidate_tree}"; then
    echo "FULL_GAME_RUNTIME_TRACE_PENDING profile=${profile_id} reason=trace_contract_rejected trace=${trace_output}" >&2
    return 1
  fi
  echo "FULL_GAME_RUNTIME_TRACE_EVIDENCE profile=${profile_id} commit=${candidate_commit} tree=${candidate_tree} trace=${trace_output} log=${stdout_log} product_go=HOLD human_density_gate=OPEN"
}

failures=0
for profile_id in "${profiles[@]}"; do
  if ! run_profile "${profile_id}"; then
    failures=$((failures + 1))
  fi
done
if ((failures > 0)); then
  echo "FULL_GAME_RUNTIME_TRACE_MATRIX_PENDING profiles=${#profiles[@]} failures=${failures} product_go=HOLD human_density_gate=OPEN" >&2
  exit 1
fi
echo "FULL_GAME_RUNTIME_TRACE_MATRIX_OK profiles=${#profiles[@]} product_go=HOLD human_density_gate=OPEN"

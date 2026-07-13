#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LANGUAGE="${1:-}"
if [[ "${LANGUAGE}" != "ko" && "${LANGUAGE}" != "en" ]]; then
  printf 'usage: %s <ko|en>\n' "$0" >&2
  exit 2
fi

GODOT_BIN="${GODOT:-}"
if [[ -z "${GODOT_BIN}" ]]; then
  if command -v godot >/dev/null 2>&1; then
    GODOT_BIN="$(command -v godot)"
  elif [[ -x "/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot" ]]; then
    GODOT_BIN="/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot"
  else
    printf 'Godot not found. Set GODOT=/absolute/path/to/godot.\n' >&2
    exit 1
  fi
fi

QA_DIR="/tmp/gangnamdream_qa"
CAPTURE_DIR="${ROOT}/build/trailer/captures/${LANGUAGE}"
mkdir -p "${CAPTURE_DIR}"
find "${CAPTURE_DIR}" -maxdepth 1 -type f -name 'trailer_*.png' -delete

"${GODOT_BIN}" \
  --path "${ROOT}" \
  --rendering-driver opengl3 \
  --audio-driver Dummy \
  --resolution 1920x1080 \
  res://tools/ScreenshotQA.tscn -- --qa=trailer --lang="${LANGUAGE}"

find "${QA_DIR}" -maxdepth 1 -type f -name 'trailer_*.png' -exec cp {} "${CAPTURE_DIR}/" \;
python3 "${ROOT}/tools/trailer/trailer_check.py" --captures "${CAPTURE_DIR}"
printf 'TRAILER_CAPTURE_OK lang=%s dir=%s\n' "${LANGUAGE}" "${CAPTURE_DIR}"

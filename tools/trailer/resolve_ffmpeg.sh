#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -n "${FFMPEG:-}" && -x "${FFMPEG}" ]]; then
  printf '%s\n' "${FFMPEG}"
  exit 0
fi

if command -v ffmpeg >/dev/null 2>&1; then
  command -v ffmpeg
  exit 0
fi

if python3 -c 'import imageio_ffmpeg' >/dev/null 2>&1; then
  python3 -c 'import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())'
  exit 0
fi

TOOL_DIR="${ROOT}/build/trailer-tools"
if [[ ! -d "${TOOL_DIR}/imageio_ffmpeg" ]]; then
  python3 -m pip install --disable-pip-version-check --target "${TOOL_DIR}" imageio-ffmpeg==0.6.0 >&2
fi

PYTHONPATH="${TOOL_DIR}${PYTHONPATH:+:${PYTHONPATH}}" \
  python3 -c 'import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())'

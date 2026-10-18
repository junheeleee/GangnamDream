#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FFMPEG_BIN="$(${ROOT}/tools/trailer/resolve_ffmpeg.sh)"
mkdir -p "${ROOT}/build/trailer"
RUN_DIR="$(mktemp -d "${ROOT}/build/trailer/run.XXXXXXXX")"
OUTPUT_DIR="${RUN_DIR}/final"
mkdir -p "${OUTPUT_DIR}"

for language in ko en; do
  "${ROOT}/tools/trailer/capture_frames.sh" "${language}" "${RUN_DIR}/captures/${language}"
  for seconds in 30 60; do
    python3 "${ROOT}/tools/trailer/render_trailer.py" \
      --seconds "${seconds}" \
      --lang "${language}" \
      --captures "${RUN_DIR}/captures/${language}" \
      --output "${OUTPUT_DIR}/gangnam_dream_${seconds}s_${language}.mp4" \
      --ffmpeg "${FFMPEG_BIN}"
  done
done

printf 'TRAILER_ALL_OK dir=%s\n' "${OUTPUT_DIR}"

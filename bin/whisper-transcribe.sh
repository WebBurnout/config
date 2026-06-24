#!/usr/bin/env bash
# Transcribe a wav file to a single line of text using whisper.cpp.
# Usage: whisper-transcribe.sh /path/to/audio.wav
# Override the model with WHISPER_MODEL=/path/to/ggml-*.bin
set -euo pipefail

# Hammerspoon spawns this with a minimal PATH, so make sure brew bins are found.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

WAV="${1:-/tmp/hs-whisper-ptt.wav}"
MODEL="${WHISPER_MODEL:-$HOME/.local/share/whisper-models/ggml-base.en.bin}"

[ -f "$WAV" ] || { echo "no audio file: $WAV" >&2; exit 1; }
[ -f "$MODEL" ] || { echo "no model: $MODEL" >&2; exit 1; }

# -nt: no timestamps, -np: no progress/system prints, output transcript to stdout.
whisper-cli -m "$MODEL" -f "$WAV" -t 4 -nt -np 2>/dev/null \
  | tr '\n' ' ' \
  | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+/ /g'

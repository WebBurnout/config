#!/usr/bin/env bash
# Play a brief inaudible tone so USB speakers don't power down while idle.
# Runs once per invocation; launchd re-runs it on an interval.
# Only plays when on AC power and the target device is the current output,
# since afplay always goes to whatever output is selected.
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

DEVICE="${KEEP_AWAKE_DEVICE:-USB2.0 Device}"
TONE="$HOME/.cache/keep-speakers-awake.wav"

pmset -g batt | grep -q "AC Power" || exit 0
[ "$(SwitchAudioSource -c -t output)" = "$DEVICE" ] || exit 0

if [ ! -f "$TONE" ]; then
  mkdir -p "$(dirname "$TONE")"
  ffmpeg -nostdin -loglevel error -f lavfi -i "sine=frequency=30:duration=2" \
    -af "volume=-50dB" -ac 2 -ar 48000 -y "$TONE"
fi

afplay "$TONE"

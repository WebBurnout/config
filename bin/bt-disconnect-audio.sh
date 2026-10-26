#!/usr/bin/env bash
# Disconnect every connected Bluetooth device except the keyboard and trackpad,
# which have to stay connected to wake the machine. Hammerspoon runs this on
# sleep through launchd, because blueutil crashes when Hammerspoon launches it
# directly (Hammerspoon's Info.plist has no Bluetooth usage description).
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

KEEP=(
  ca-d9-e9-01-24-98 # keyboard
  d0-c0-50-c4-9a-bc # trackpad
)

for addr in $(blueutil --connected | sed -n 's/^address: \([^,]*\),.*/\1/p'); do
  [[ " ${KEEP[*]} " == *" $addr "* ]] && continue
  echo "$(date '+%Y-%m-%d %H:%M:%S') disconnecting $addr"
  blueutil --disconnect "$addr"
done

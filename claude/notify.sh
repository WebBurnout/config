#!/bin/bash
# Claude Code hook notifier. Usage: notify.sh <stop|notification>, hook JSON on stdin.
# Sends via Hammerspoon so clicking the banner focuses Alacritty.
HS=/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs

case "$1" in
  stop)
    msg="Done — waiting for input"
    ;;
  *)
    msg=$(jq -r '.message // "Claude needs your attention"')
    # The Stop hook already covers turn-end; skip the redundant ~60s idle notification
    case "$msg" in *"waiting for your input"*) exit 0 ;; esac
    ;;
esac

esc=${msg//\\/\\\\}
esc=${esc//\"/\\\"}
"$HS" -c "hs.notify.new(function() hs.application.launchOrFocus(\"Alacritty\") end, {title=\"Claude Code\", informativeText=\"$esc\", withdrawAfter=3}):send()" >/dev/null 2>&1

exit 0

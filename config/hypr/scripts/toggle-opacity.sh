#!/usr/bin/env bash
set -euo pipefail

# Get active window address
addr="$(hyprctl activewindow -j | jq -r '.address')"

# Read current opacity (fallback to 1.0 if unset)
cur="$(hyprctl getwindowprop "$addr" opacity 2>/dev/null | awk '{print $2}' || echo 1.0)"

# Treat ~1.0 as "no transparency"
if awk "BEGIN{exit !($cur >= 0.999)}"; then
  # turn transparency ON for this window
  hyprctl dispatch setprop address:$addr opacity 0.9
else
  # turn transparency OFF for this window
  hyprctl dispatch setprop address:$addr opacity 1.0
fi

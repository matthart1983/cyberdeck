#!/usr/bin/env bash
# host CPU busy % from top's one-shot summary line.
source "$HOME/.config/sketchybar/colors.sh"

IDLE=$(top -l 1 -n 0 -s 0 | awk '/^CPU usage/ {gsub("%","",$7); print $7}')
if [ -z "$IDLE" ]; then sketchybar --set "$NAME" label="--"; exit 0; fi
BUSY=$(printf '%.0f' "$(echo "100 - $IDLE" | bc -l)")
COLOR="$WHITE"
[ "$BUSY" -ge 70 ] && COLOR="$ORANGE"
[ "$BUSY" -ge 90 ] && COLOR="$RED"
sketchybar --set "$NAME" label="${BUSY}%" label.color="$COLOR"

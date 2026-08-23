#!/usr/bin/env bash
# Memory *pressure*, not "free RAM" — on macOS free RAM is a meaningless number.
source "$HOME/.config/sketchybar/colors.sh"

FREE_PCT=$(memory_pressure 2>/dev/null | awk '/System-wide memory free percentage/ {gsub("%","",$5); print $5}')
if [ -z "$FREE_PCT" ]; then
  sketchybar --set "$NAME" label="--"; exit 0
fi
USED=$((100 - FREE_PCT))
COLOR="$WHITE"
[ "$USED" -ge 80 ] && COLOR="$ORANGE"
[ "$USED" -ge 92 ] && COLOR="$RED"
sketchybar --set "$NAME" label="${USED}%" label.color="$COLOR"

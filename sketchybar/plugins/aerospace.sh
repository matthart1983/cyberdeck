#!/usr/bin/env bash
# $1 = workspace this item represents. FOCUSED_WORKSPACE is set by AeroSpace's
# exec-on-workspace-change; on a plain refresh we ask AeroSpace directly.
source "$HOME/.config/sketchybar/colors.sh"

WS="$1"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# Hide workspaces that are empty and not focused, so the bar stays quiet.
HAS_WINDOWS=$(aerospace list-windows --workspace "$WS" 2>/dev/null | grep -c .)

if [ "$WS" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=on \
    background.color=0x40ea00d9 \
    background.border_color="$MAGENTA" \
    icon.color="$MAGENTA"
elif [ "${HAS_WINDOWS:-0}" -gt 0 ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=on \
    background.color="$BG_SUNK" \
    background.border_color="$TRANSPARENT" \
    icon.color="$FG"
else
  sketchybar --set "$NAME" drawing=off
fi

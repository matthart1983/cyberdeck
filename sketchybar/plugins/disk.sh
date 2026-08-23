#!/usr/bin/env bash
# On macOS `/` is the sealed read-only system snapshot — it always reads ~4%.
# The number that matters is the Data volume.
source "$HOME/.config/sketchybar/colors.sh"

VOL="/System/Volumes/Data"
[ -d "$VOL" ] || VOL="/"

USED=$(df -H "$VOL" | awk 'NR==2 {gsub("%","",$5); print $5}')
FREE=$(df -H "$VOL" | awk 'NR==2 {print $4}')

COLOR="$WHITE"
[ "${USED:-0}" -ge 85 ] && COLOR="$ORANGE"
[ "${USED:-0}" -ge 93 ] && COLOR="$RED"

sketchybar --set "$NAME" label="${USED}% · ${FREE} free" label.color="$COLOR"

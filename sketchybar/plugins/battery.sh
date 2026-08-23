#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

PCT=$(pmset -g batt | grep -Eo '\d+%' | head -1 | tr -d '%')
CHARGING=$(pmset -g batt | grep -c "AC Power")
[ -z "$PCT" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

COLOR="$FG"
if   [ "$PCT" -le 15 ]; then ICON="$ICON_BAT_0";  COLOR="$RED"
elif [ "$PCT" -le 35 ]; then ICON="$ICON_BAT_25"; COLOR="$ORANGE"
elif [ "$PCT" -le 60 ]; then ICON="$ICON_BAT_50"
elif [ "$PCT" -le 85 ]; then ICON="$ICON_BAT_75"
else                         ICON="$ICON_BAT_100"; COLOR="$GREEN"
fi
[ "$CHARGING" -eq 1 ] && { ICON="$ICON_BAT_CHARGING"; COLOR="$GREEN"; }

sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color="$COLOR" label="${PCT}%"

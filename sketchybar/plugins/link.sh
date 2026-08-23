#!/usr/bin/env bash
# Link health — gateway RTT, DNS RTT, loss, live connection count.
# This is the item a stock bar can't draw: it's netwatch's probe data, not ping.
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/plugins/netwatch_lib.sh"

if ! nw_scrape; then
  sketchybar --set "$NAME" \
    icon="$ICON_LINK_BAD" icon.color="$FG_DIM" \
    label="--" label.color="$FG_DIM"
  exit 0
fi

GW_RTT=$(nw_value netwatch_gateway_rtt_seconds " ")
GW_LOSS=$(nw_value netwatch_gateway_loss_ratio " ")
DNS_RTT=$(nw_value netwatch_dns_rtt_seconds " ")
CONNS=$(nw_value netwatch_connections " ")

MS=$(awk -v s="${GW_RTT:-0}" 'BEGIN{printf "%.0f", s*1000}')
DNS_MS=$(awk -v s="${DNS_RTT:-0}" 'BEGIN{printf "%.0f", s*1000}')
LOSS_PCT=$(awk -v r="${GW_LOSS:-0}" 'BEGIN{printf "%.0f", r*100}')

# Colour on the worst of the three signals.
COLOR="$GREEN"; ICON="$ICON_LINK"
if [ "${MS:-0}" -gt 30 ] || [ "${DNS_MS:-0}" -gt 120 ]; then COLOR="$YELLOW"; fi
if [ "${MS:-0}" -gt 80 ] || [ "${DNS_MS:-0}" -gt 300 ]; then COLOR="$ORANGE"; fi
if [ "${LOSS_PCT:-0}" -gt 0 ]; then COLOR="$RED"; ICON="$ICON_LINK_BAD"; fi

if [ "${LOSS_PCT:-0}" -gt 0 ]; then
  LABEL="${MS}ms ${LOSS_PCT}%loss"
else
  LABEL="${MS}ms · ${CONNS:-0} conn"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR"

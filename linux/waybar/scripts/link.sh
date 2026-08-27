#!/usr/bin/env bash
# Link health — gateway RTT, DNS RTT, loss, live connection count.
# This is the item a stock bar can't draw: it's netwatch's probe data, not ping.
# Colour moves to a CSS class instead of an inline colour; see style.css.
source "$HOME/.config/waybar/scripts/netwatch_lib.sh"

if ! nw_scrape; then
  nw_emit "󰌙 --" "down" "netwatch daemon not answering on $NW_ENDPOINT"
  exit 0
fi

GW_RTT=$(nw_value netwatch_gateway_rtt_seconds " ")
GW_LOSS=$(nw_value netwatch_gateway_loss_ratio " ")
DNS_RTT=$(nw_value netwatch_dns_rtt_seconds " ")
CONNS=$(nw_value netwatch_connections " ")

MS=$(awk -v s="${GW_RTT:-0}"  'BEGIN{printf "%.0f", s*1000}')
DNS_MS=$(awk -v s="${DNS_RTT:-0}" 'BEGIN{printf "%.0f", s*1000}')
LOSS_PCT=$(awk -v r="${GW_LOSS:-0}" 'BEGIN{printf "%.0f", r*100}')

# Colour on the worst of the three signals — same thresholds as the macOS bar.
CLASS="ok"; ICON="󰤨"
if [ "${MS:-0}" -gt 30 ] || [ "${DNS_MS:-0}" -gt 120 ]; then CLASS="warn"; fi
if [ "${MS:-0}" -gt 80 ] || [ "${DNS_MS:-0}" -gt 300 ]; then CLASS="bad";  fi
if [ "${LOSS_PCT:-0}" -gt 0 ]; then CLASS="loss"; ICON="󰤭"; fi

if [ "${LOSS_PCT:-0}" -gt 0 ]; then
  TEXT="$ICON ${MS}ms ${LOSS_PCT}%loss"
else
  TEXT="$ICON ${MS}ms · ${CONNS:-0} conn"
fi

nw_emit "$TEXT" "$CLASS" "gateway ${MS}ms · dns ${DNS_MS}ms · loss ${LOSS_PCT}% · ${CONNS:-0} connections"

#!/usr/bin/env bash
# Throughput on the default interface, straight from netwatch's own collector.
source "$HOME/.config/waybar/scripts/netwatch_lib.sh"

if ! nw_scrape; then
  nw_emit "netwatch off" "down" "netwatch daemon not answering on $NW_ENDPOINT"
  exit 0
fi

IFACE=$(nw_primary_iface)
# On the Framework this is wlan0 or enp*; there is no en0 to fall back to.
[ -z "$IFACE" ] && IFACE="wlan0"
F="{interface=\"$IFACE\"}"

RX=$(nw_value netwatch_interface_receive_bytes_per_second  "$F")
TX=$(nw_value netwatch_interface_transmit_bytes_per_second "$F")

nw_emit "󰇚$(nw_rate "${RX:-0}")  󰕒$(nw_rate "${TX:-0}")" "" "$IFACE"

#!/usr/bin/env bash
# Throughput on the default interface, straight from netwatch's own collector.
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/plugins/netwatch_lib.sh"

if ! nw_scrape; then
  sketchybar --set "$NAME" label="netwatch off" label.color="$FG_DIM"
  exit 0
fi

IFACE=$(nw_primary_iface)
[ -z "$IFACE" ] && IFACE=en0
F="{interface=\"$IFACE\"}"

RX=$(nw_value netwatch_interface_receive_bytes_per_second "$F")
TX=$(nw_value netwatch_interface_transmit_bytes_per_second "$F")

sketchybar --set "$NAME" \
  label="$ICON_NET_DOWN$(nw_rate "${RX:-0}")  $ICON_NET_UP$(nw_rate "${TX:-0}")" \
  label.color="$FG"

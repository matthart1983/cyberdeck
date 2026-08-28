#!/usr/bin/env bash
# JankyBorders — magenta glow on the focused window, dim purple on the rest.
# Launched by AeroSpace's after-startup-command.
exec /opt/homebrew/bin/borders \
  active_color=0xffea00d9 \
  inactive_color=0x80711c91 \
  width=5.0 \
  style=round \
  hidpi=on \
  ax_focus=on

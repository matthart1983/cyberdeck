#!/usr/bin/env bash
# JankyBorders — the accent colour on the focused window, the inactive-border
# colour on the rest.
# Rendered from themes/ice.sh by `theme` — edit the .tmpl, not this.
# Launched by AeroSpace's after-startup-command.
exec /opt/homebrew/bin/borders \
  active_color=0xff5ec8ff \
  inactive_color=0x804a6fa5 \
  width=5.0 \
  style=round \
  hidpi=on \
  ax_focus=on

#!/usr/bin/env bash
# JankyBorders — the accent colour on the focused window, the inactive-border
# colour on the rest.
# Rendered from themes/deep-sea.sh by `theme` — edit the .tmpl, not this.
# Launched by AeroSpace's after-startup-command.
exec /opt/homebrew/bin/borders \
  active_color=0xff5d86ff \
  inactive_color=0x803b3f9e \
  width=5.0 \
  style=round \
  hidpi=on \
  ax_focus=on

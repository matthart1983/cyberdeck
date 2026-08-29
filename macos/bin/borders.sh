#!/usr/bin/env bash
# JankyBorders — the accent colour on the focused window, the inactive-border
# colour on the rest.
# Rendered from themes/cyberpunk-neon.sh by `theme` — edit the .tmpl, not this.
# Launched by AeroSpace's after-startup-command.
exec /opt/homebrew/bin/borders \
  active_color=0xffea00d9 \
  inactive_color=0x80711c91 \
  width=5.0 \
  style=round \
  hidpi=on \
  ax_focus=on

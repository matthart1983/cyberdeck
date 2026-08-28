#!/usr/bin/env bash
# macOS half of the install. Called by ../install.sh.
#
# Only symlinks and services — the system-settings layer stays opt-in via
# macos/defaults.sh, which refuses to run without a macos/snapshot.sh first.
set -euo pipefail
D="${D:-$HOME/.dotfiles}"
# shellcheck source=common/lib.sh
source "$D/common/lib.sh"

echo "==> macOS configs"
link "$D/common/ghostty/platform-macos.conf" "$HOME/.config/ghostty/platform.conf"
link "$D/macos/aerospace/aerospace.toml"     "$HOME/.config/aerospace/aerospace.toml"
link "$D/macos/sketchybar"                   "$HOME/.config/sketchybar"

echo "==> netwatch metrics service (feeds the bar)"
LABEL="io.cyberdeck.netwatch-metrics"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
NETWATCH="$(command -v netwatch || true)"
if [ -z "$NETWATCH" ]; then
  warn "netwatch not on PATH — the bar's net/link items will read 'netwatch off'"
  warn "install it with: cargo install netwatch-tui"
else
  # Only bounce the agent when the plist actually changed. The old version
  # did a bootout/bootstrap on every run, which restarted the daemon — and
  # reset its counters — every time the rice was re-linked.
  if render "$D/macos/launchd/netwatch-metrics.plist.template" "$PLIST" \
       -e "s|__LABEL__|$LABEL|g" \
       -e "s|__NETWATCH__|$NETWATCH|g" \
       -e "s|__LOGDIR__|${TMPDIR%/}|g"; then
    launchctl bootout "gui/$UID/$LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$UID" "$PLIST" 2>/dev/null \
      && chg "$LABEL loaded" || warn "could not bootstrap $LABEL"
  elif launchctl print "gui/$UID/$LABEL" >/dev/null 2>&1; then
    same "$LABEL (loaded)"
  else
    launchctl bootstrap "gui/$UID" "$PLIST" 2>/dev/null \
      && chg "$LABEL loaded" || warn "could not bootstrap $LABEL"
  fi
fi

echo "==> sketchybar"
if [ "$_changed" -gt 0 ]; then
  brew services restart sketchybar >/dev/null 2>&1 \
    && chg "sketchybar restarted" || warn "sketchybar not running"
else
  same "sketchybar untouched"
fi

summary "macos"
echo "    AeroSpace needs Accessibility permission on first launch."

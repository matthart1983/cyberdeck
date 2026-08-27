#!/usr/bin/env bash
# macOS half of the install. Called by ../install.sh.
set -euo pipefail
D="${D:-$HOME/.dotfiles}"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

echo "==> linking macOS configs"
link "$D/ghostty/platform-macos.conf" "$HOME/.config/ghostty/platform.conf"
link "$D/aerospace/aerospace.toml"    "$HOME/.config/aerospace/aerospace.toml"
link "$D/sketchybar"                  "$HOME/.config/sketchybar"

echo "==> netwatch metrics service (feeds the bar)"
LABEL="io.cyberdeck.netwatch-metrics"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
NETWATCH="$(command -v netwatch || true)"
if [ -z "$NETWATCH" ]; then
  echo "  netwatch not on PATH — skipping."
  echo "  The bar's net/link items will read 'netwatch off' until it is."
  echo "  Install: cargo install netwatch-tui"
else
  mkdir -p "$HOME/Library/LaunchAgents"
  sed -e "s|__LABEL__|$LABEL|g" \
      -e "s|__NETWATCH__|$NETWATCH|g" \
      -e "s|__LOGDIR__|${TMPDIR%/}|g" \
      "$D/launchd/netwatch-metrics.plist.template" > "$PLIST"
  launchctl bootout "gui/$UID/$LABEL" 2>/dev/null || true
  launchctl bootstrap "gui/$UID" "$PLIST" 2>/dev/null \
    && echo "  loaded ($NETWATCH)" || echo "  already loaded"
fi

echo "==> sketchybar service"
brew services restart sketchybar >/dev/null 2>&1 && echo "  restarted" || echo "  not running"

echo "    AeroSpace needs Accessibility permission on first launch."

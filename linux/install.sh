#!/usr/bin/env bash
# Linux half of the install. Called by ../install.sh.
#
# Like the macOS half this only symlinks and loads services — it installs no
# packages and changes no system settings. The package layer is opt-in:
#   linux/packages.sh    (needs sudo; Fedora/dnf)
set -euo pipefail
D="${D:-$HOME/.dotfiles}"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

echo "==> linking Linux configs"
link "$D/ghostty/platform-linux.conf" "$HOME/.config/ghostty/platform.conf"
link "$D/linux/niri/config.kdl"       "$HOME/.config/niri/config.kdl"
link "$D/linux/waybar/config.jsonc"   "$HOME/.config/waybar/config.jsonc"
link "$D/linux/waybar/style.css"      "$HOME/.config/waybar/style.css"
link "$D/linux/waybar/scripts"        "$HOME/.config/waybar/scripts"

echo "==> netwatch metrics service (feeds the bar)"
UNIT_DIR="$HOME/.config/systemd/user"
NETWATCH="$(command -v netwatch || true)"
if [ -z "$NETWATCH" ]; then
  echo "  netwatch not on PATH — skipping."
  echo "  The bar's net/link items will read 'netwatch off' until it is."
  echo "  Install: cargo install netwatch-tui"
else
  mkdir -p "$UNIT_DIR"
  sed -e "s|__NETWATCH__|$NETWATCH|g" \
      "$D/linux/systemd/netwatch-metrics.service" > "$UNIT_DIR/netwatch-metrics.service"
  systemctl --user daemon-reload
  systemctl --user enable --now netwatch-metrics.service >/dev/null 2>&1 \
    && echo "  enabled ($NETWATCH)" || echo "  failed — journalctl --user -u netwatch-metrics"
fi

echo "==> wallpaper"
# generate.py takes an output DIRECTORY and writes one file per panel size.
WP_DIR="$HOME/.local/share/wallpapers"
WP="$WP_DIR/cyberpunk-fw13.png"
if [ ! -f "$WP" ]; then
  mkdir -p "$WP_DIR"
  if python3 -c 'import PIL' 2>/dev/null; then
    python3 "$D/wallpaper/generate.py" "$WP_DIR" >/dev/null 2>&1 \
      && echo "  generated -> $WP_DIR" || echo "  generator failed — see wallpaper/generate.py"
  else
    echo "  python3-pillow not installed — skipping (run linux/packages.sh)"
  fi
else
  echo "  already present"
fi

echo "==> waybar"
if pgrep -x waybar >/dev/null; then
  pkill -USR2 waybar && echo "  reloaded"
else
  echo "  not running — niri spawns it at startup"
fi

echo "    niri needs no accessibility grant; log out and pick 'niri' at the"
echo "    session chooser to switch off GNOME."

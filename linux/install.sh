#!/usr/bin/env bash
# Linux half of the install. Called by ../install.sh.
#
# Like the macOS half this only symlinks and loads services — it installs no
# packages and changes no system settings. The package layer is opt-in:
#   linux/packages.sh    (needs sudo; Fedora/dnf)
set -euo pipefail
D="${D:-$HOME/.dotfiles}"
# shellcheck source=common/lib.sh
source "$D/common/lib.sh"
# CP_THEME_SLUG — the wallpaper is drawn from the active palette.
# shellcheck source=palette.sh
source "$D/palette.sh"

echo "==> Linux configs"
link "$D/common/ghostty/platform-linux.conf" "$HOME/.config/ghostty/platform.conf"
link "$D/linux/niri/config.kdl"              "$HOME/.config/niri/config.kdl"
link "$D/linux/waybar/config.jsonc"          "$HOME/.config/waybar/config.jsonc"
link "$D/linux/waybar/style.css"             "$HOME/.config/waybar/style.css"
link "$D/linux/waybar/power.xml"             "$HOME/.config/waybar/power.xml"
link "$D/linux/waybar/scripts"               "$HOME/.config/waybar/scripts"
link "$D/linux/nwg-drawer/drawer.css"        "$HOME/.config/nwg-drawer/drawer.css"
# The session's PATH. niri runs under `systemd --user`, so this is what puts
# ~/.cargo/bin and the rice's own bin dir in front of everything the compositor
# spawns — read at login, which is why the doctor checks the running session
# against it rather than trusting that linking it was enough.
link "$D/linux/systemd/environment.d/cyberdeck.conf" \
     "$HOME/.config/environment.d/cyberdeck.conf"

echo "==> netwatch metrics service (feeds the bar)"
UNIT="$HOME/.config/systemd/user/netwatch-metrics.service"
NETWATCH="$(command -v netwatch || true)"
if [ -z "$NETWATCH" ]; then
  warn "netwatch not on PATH — the bar's net/link items will read 'netwatch off'"
  warn "install it with: cargo install netwatch-tui"
else
  # render() returns 0 only when it actually wrote, so the daemon is reloaded
  # on a real change and left alone otherwise.
  if render "$D/linux/systemd/netwatch-metrics.service" "$UNIT" -e "s|__NETWATCH__|$NETWATCH|g"; then
    # A user bus is not always reachable — over SSH without lingering enabled
    # this fails, and it must not take the rest of the install down with it.
    systemctl --user daemon-reload || warn "no user bus — unit written but not reloaded"
  fi
  if systemctl --user is-enabled --quiet netwatch-metrics.service 2>/dev/null \
     && systemctl --user is-active --quiet netwatch-metrics.service 2>/dev/null; then
    same "netwatch-metrics.service (enabled, running)"
  else
    systemctl --user enable --now netwatch-metrics.service >/dev/null 2>&1 \
      && chg "netwatch-metrics.service enabled" \
      || warn "could not start — journalctl --user -u netwatch-metrics"
  fi
fi

echo "==> wallpaper"
# generate.py takes an output DIRECTORY and writes one file per panel size, so
# check for all of them rather than assuming this machine's is the only one.
WP_DIR="$HOME/.local/share/wallpapers"
WP_STALE=0
# generate.py reads the active palette, so a `theme` switch has to reach the
# wallpaper too — it is as much a themed surface as the bar is. Which theme it
# was drawn from is recorded beside it: mtimes cannot answer this, because
# switching back to a theme whose palette file has not been touched since the
# clone would look older than the PNGs and never redraw.
WP_STAMP="$WP_DIR/.cyberdeck-theme"
for f in cyberpunk-mbp.png cyberpunk-fw13.png cyberpunk-4k.png; do
  if [ ! -f "$WP_DIR/$f" ]; then WP_STALE=1; break; fi
done
if [ "$(cat "$WP_STAMP" 2>/dev/null || true)" != "$CP_THEME_SLUG" ]; then
  WP_STALE=1
fi
if [ "$WP_STALE" -eq 0 ]; then
  same "$WP_DIR"
elif ! python3 -c 'import PIL' 2>/dev/null; then
  warn "python3-pillow not installed — skipped (run linux/packages.sh)"
else
  mkdir -p "$WP_DIR"
  if D="$D" python3 "$D/wallpaper/generate.py" "$WP_DIR" >/dev/null 2>&1; then
    printf '%s\n' "$CP_THEME_SLUG" > "$WP_STAMP"
    chg "$WP_DIR ($CP_THEME_SLUG)"
  else
    warn "generator failed — see wallpaper/generate.py"
  fi
fi

echo "==> dock icons"
# The dock draws real application icons, resolved at click-time from each app's
# .desktop file. The slots that run inside a terminal have no icon anywhere on
# the machine, so those are drawn here instead — same arrangement as the
# wallpaper above, and stale for the same reason, so it carries the same stamp.
DI_DIR="$HOME/.local/share/cyberdeck/dock-icons"
DI_STAMP="$DI_DIR/.cyberdeck-theme"
DI_STALE=0
for f in claude hud git containers k8s net; do
  if [ ! -f "$DI_DIR/$f.png" ]; then DI_STALE=1; break; fi
done
if [ "$(cat "$DI_STAMP" 2>/dev/null || true)" != "$CP_THEME_SLUG" ]; then
  DI_STALE=1
fi
if [ "$DI_STALE" -eq 0 ]; then
  same "$DI_DIR"
elif ! python3 -c 'import PIL' 2>/dev/null; then
  warn "python3-pillow not installed — the terminal slots will have no icon"
else
  mkdir -p "$DI_DIR"
  if D="$D" python3 "$D/linux/dock-icons/generate.py" "$DI_DIR" >/dev/null 2>&1; then
    printf '%s\n' "$CP_THEME_SLUG" > "$DI_STAMP"
    chg "$DI_DIR ($CP_THEME_SLUG)"
  else
    warn "generator failed — see linux/dock-icons/generate.py"
  fi
fi

echo "==> waybar"
# Only poke the bar if this run actually rewrote something under it.
if [ "$_changed" -gt 0 ] && pgrep -x waybar >/dev/null; then
  pkill -USR2 waybar && chg "waybar reloaded"
elif pgrep -x waybar >/dev/null; then
  same "waybar running"
else
  warn "waybar not running — niri spawns it at startup"
fi

summary "linux"
echo "    niri needs no accessibility grant; log out and pick 'niri' at the"
echo "    session chooser to switch off GNOME."

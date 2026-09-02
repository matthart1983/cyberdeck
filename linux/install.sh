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
# A directory, not fifteen lines. Every right-click menu is one XML file in
# here, and a menu added tomorrow should not also need an installer edit —
# waybar reads them by path out of config.jsonc, so the tree only has to be
# reachable at the name that file uses.
link "$D/linux/waybar/menus"                 "$HOME/.config/waybar/menus"
link "$D/linux/waybar/scripts"               "$HOME/.config/waybar/scripts"

# power.xml became menus/session.xml when the bar grew the rest of its menus.
# The old symlink points at a file that is no longer there, and a dangling link
# in ~/.config is the kind of thing that outlives the reason for it — so this
# clears it, and only if it is still ours to clear.
_old_menu="$HOME/.config/waybar/power.xml"
if [ -L "$_old_menu" ] && [ ! -e "$_old_menu" ]; then
  rm -f "$_old_menu" && chg "removed $_old_menu (now menus/session.xml)"
fi
link "$D/linux/nwg-drawer/drawer.css"        "$HOME/.config/nwg-drawer/drawer.css"
# fuzzel is the rice's second most looked-at surface — every picker and every
# right-click menu that is not a menu-file comes through it — and it had no
# config at all until the menus landed, so it rendered in its stock light
# theme on a dark desktop.
link "$D/linux/fuzzel/fuzzel.ini"            "$HOME/.config/fuzzel/fuzzel.ini"

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
# Two sources, and the stamp records which one is in place as well as which
# theme: switching between them without changing theme still has to redraw.
# wallpaper/themed prints a path when this theme has a photographic wallpaper
# cached, and nothing when it does not — silence is what selects the generator.
WP_THEMED="$(D="$D" "$D/wallpaper/themed" path 2>/dev/null || true)"
if [ -n "$WP_THEMED" ]; then
  WP_WANT="$CP_THEME_SLUG themed"
else
  WP_WANT="$CP_THEME_SLUG generated"
fi
if [ "$(cat "$WP_STAMP" 2>/dev/null || true)" != "$WP_WANT" ]; then
  WP_STALE=1
fi

if [ "$WP_STALE" -eq 0 ]; then
  same "$WP_DIR"
elif ! python3 -c 'import PIL' 2>/dev/null; then
  warn "python3-pillow not installed — skipped (run linux/packages.sh)"
elif [ -n "$WP_THEMED" ]; then
  # Copied into place under the generator's own filenames rather than pointed
  # at directly. niri spawns `swaybg -i .../cyberpunk-fw13.png`, and that path
  # is the contract between the compositor config and whatever drew the image —
  # keeping it means the source can change without config.kdl knowing.
  mkdir -p "$WP_DIR"
  wp_ok=1
  for f in cyberpunk-mbp.png cyberpunk-fw13.png cyberpunk-4k.png; do
    cp -f "${WP_THEMED%/*}/$CP_THEME_SLUG-$f" "$WP_DIR/$f" 2>/dev/null || wp_ok=0
  done
  if [ "$wp_ok" -eq 1 ]; then
    printf '%s\n' "$WP_WANT" > "$WP_STAMP"
    chg "$WP_DIR ($CP_THEME_SLUG, themed)"
  else
    warn "themed wallpaper incomplete — run wallpaper/themed fetch"
  fi
else
  mkdir -p "$WP_DIR"
  if D="$D" python3 "$D/wallpaper/generate.py" "$WP_DIR" >/dev/null 2>&1; then
    printf '%s\n' "$WP_WANT" > "$WP_STAMP"
    chg "$WP_DIR ($CP_THEME_SLUG, generated)"
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

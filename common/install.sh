#!/usr/bin/env bash
# Everything that is identical on macOS and Linux. Called by ../install.sh —
# harmless to run directly. Idempotent: a second run writes nothing and says so.
set -euo pipefail
D="${D:-$HOME/.dotfiles}"
# shellcheck source=common/lib.sh
source "$D/common/lib.sh"
# CP_THEME_NAME and the rest of the active palette — Zed's theme is selected by
# display name, so the installer has to know which theme is on.
# shellcheck source=palette.sh
source "$D/palette.sh"

# The themed surfaces are rendered from themes/<active>.sh rather than stored
# by hand, so this runs before the links: a palette edit reaches ~/.config in
# one install.sh. `theme` only writes on difference, so an unchanged theme
# leaves the working tree clean and reports nothing here.
echo "==> theme"
_theme_out="$(D="$D" bash "$D/common/bin/theme" --render)"
_theme_chg="$(printf '%s\n' "$_theme_out" | grep -c '^  +' || true)"
if [ "$_theme_chg" -gt 0 ]; then
  printf '%s\n' "$_theme_out" | grep '^  +'
  _changed=$((_changed + _theme_chg))
else
  same "16 surfaces match $(basename "$(readlink "$D/themes/active.sh" 2>/dev/null || echo cyberpunk-neon.sh)" .sh)"
fi

echo "==> shared configs"
link "$D/common/ghostty/config"         "$HOME/.config/ghostty/config"
link "$D/common/ghostty/themes"         "$HOME/.config/ghostty/themes"
link "$D/common/tmux/tmux.conf"         "$HOME/.config/tmux/tmux.conf"
link "$D/common/bat/config"             "$HOME/.config/bat/config"
link "$D/common/bat/themes"             "$HOME/.config/bat/themes"
link "$D/common/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
link "$D/common/zed/themes/cyberdeck.json"        "$HOME/.config/zed/themes/cyberdeck.json"
link "$D/common/atuin/themes/cyberdeck.toml"      "$HOME/.config/atuin/themes/cyberdeck.toml"
# The HUD's middle pane. Seeded rather than linked: syswatch writes this file
# itself when you change a setting in its UI. See common/syswatch/config.toml.
seed "$D/common/syswatch/config.toml" "$HOME/.config/syswatch/config.toml"
seed "$D/common/netwatch/config.toml" "$HOME/.config/netwatch/config.toml"

# btop reads its themes directory directly and will not follow a symlink into
# the repo, so this one is a copy.
# The themed artifacts were named after the theme until the palette became
# switchable, which made "cyberpunk-neon.json" a lie the moment you ran
# `theme blade`. They are called cyberdeck now. Sweep the old names, but only
# where they are still symlinks into this repo — a real file at that path is
# someone else's, and belongs to them.
for _old in "$HOME/.config/zed/themes/cyberpunk-neon.json" \
            "$HOME/.config/atuin/themes/cyberpunk-neon.toml"; do
  if [ -L "$_old" ] && case "$(readlink "$_old")" in "$D"/*) true ;; *) false ;; esac; then
    rm -f "$_old"; chg "removed stale $_old"
  fi
done
# btop's is a copy, not a link, so match on content having come from here.
_oldbtop="$HOME/.config/btop/themes/cyberpunk-neon.theme"
if [ -f "$_oldbtop" ] && ! [ -L "$_oldbtop" ] && grep -q '^theme\[main_bg\]=' "$_oldbtop" 2>/dev/null; then
  rm -f "$_oldbtop"; chg "removed stale $_oldbtop"
fi

echo "==> btop theme"
copy "$D/common/btop/themes/cyberdeck.theme" "$HOME/.config/btop/themes/cyberdeck.theme"

echo "==> bat cache"
# `bat cache --build` is not free and not idempotent in its output, so only
# rebuild when a theme is actually newer than the cache it produced.
BAT_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bat/themes.bin"
if ! command -v bat >/dev/null; then
  warn "bat not installed, skipped"
elif [ -f "$BAT_CACHE" ] && [ -z "$(find "$D/common/bat/themes" -newer "$BAT_CACHE" -print -quit 2>/dev/null)" ]; then
  same "$BAT_CACHE"
else
  bat cache --build >/dev/null 2>&1 && chg "$BAT_CACHE" || warn "bat cache --build failed"
fi

echo "==> atuin theme"
ATUIN_CFG="$HOME/.config/atuin/config.toml"
if grep -q '^name = "cyberdeck"$' "$ATUIN_CFG" 2>/dev/null; then
  same "$ATUIN_CFG"
elif grep -q '^name = "cyberpunk-neon"$' "$ATUIN_CFG" 2>/dev/null; then
  # Written by a pre-switchable-theme install. Testing for [theme] alone, as
  # this did, meant the rename left atuin pointing at a file that no longer
  # exists and reported "already correct" while doing it.
  sed -i.bak 's/^name = "cyberpunk-neon"$/name = "cyberdeck"/' "$ATUIN_CFG"
  chg "$ATUIN_CFG (renamed theme, backup at $ATUIN_CFG.bak)"
elif grep -q '^\[theme\]' "$ATUIN_CFG" 2>/dev/null; then
  warn "$ATUIN_CFG already has a [theme] you chose — left alone"
else
  mkdir -p "$(dirname "$ATUIN_CFG")"
  printf '\n[theme]\nname = "cyberdeck"\n' >> "$ATUIN_CFG"
  chg "$ATUIN_CFG"
fi

echo "==> zed theme"
# Linking the theme file only puts "Cyberpunk Neon" in Zed's picker — Zed does
# not use it until settings.json names it. That file is the user's own, and
# Zed's defaults are almost entirely comments, so this splices one key and
# leaves the rest of the bytes alone.
ZED_SETTINGS="$HOME/.config/zed/settings.json"
if ! command -v python3 >/dev/null; then
  warn "python3 not available — zed theme not selected"
else
  case "$(python3 "$D/common/zed-settings.py" "$ZED_SETTINGS" "$CP_THEME_NAME")" in
    changed) chg "$ZED_SETTINGS" ;;
    same)    same "$ZED_SETTINGS" ;;
    invalid) warn "$ZED_SETTINGS is not valid JSON — left alone" ;;
  esac
fi

echo "==> claude code"
# Claude Code reads custom themes as loose .json files in ~/.claude/themes/, so
# the fifteenth surface installs the way ghostty's and zed's do — a link into
# the repo, not a copy. `cc-theme custom:cyberdeck` is what selects it.
link "$D/common/claude/cyberdeck.json" "$HOME/.claude/themes/cyberdeck.json"

# The rice owns Claude Code's theme and statusline; the rest of that file is
# the user's own, so this patches two keys rather than linking over it.
#
# Which Claude Code theme you run is a property of your machine, exactly as
# themes/active.sh is, so it lives in an untracked file that `cc-theme` writes.
# Reading it here is what stops `theme blade` — which runs this script — from
# reverting a theme you switched to. A fresh clone has no such file and gets
# the default, so nothing has to exist for this to work.
CC_SETTINGS="$HOME/.claude/settings.json"
CC_THEME="dark-ansi"
if [ -r "$D/themes/claude-theme" ]; then
  CC_THEME="$(tr -d '[:space:]' <"$D/themes/claude-theme")"
  [ -n "$CC_THEME" ] || CC_THEME="dark-ansi"
fi
if ! command -v python3 >/dev/null; then
  warn "python3 not available — skipped"
else
  case "$(python3 "$D/common/claude-settings.py" "$CC_SETTINGS" "$D/common/bin/cc-statusline" "$CC_THEME")" in
    changed)       chg "$CC_SETTINGS ($CC_THEME)" ;;
    same)          same "$CC_SETTINGS ($CC_THEME)" ;;
    invalid)       warn "$CC_SETTINGS is not valid JSON — left alone" ;;
    invalid-theme) warn "themes/claude-theme names '$CC_THEME', which is not a theme — left alone" ;;
  esac
fi

echo "==> zshrc hook"
ZRC="$HOME/.zshrc"
NEW="dotfiles/common/zsh/cyberpunk.zsh"
OLD="dotfiles/zsh/cyberpunk.zsh"
touch "$ZRC"
if grep -q "$NEW" "$ZRC"; then
  same "$ZRC"
elif grep -q "$OLD" "$ZRC"; then
  # Rewrite the pre-restructure hook in place. Appending a second line here
  # would leave the rice sourced twice, from a path that no longer exists.
  sed -i.bak "s|$OLD|$NEW|g" "$ZRC"
  chg "$ZRC (migrated old path, backup at $ZRC.bak)"
else
  printf '\n# --- Cyberpunk rice ---\n[[ -f ~/.%s ]] && source ~/.%s\n' "$NEW" "$NEW" >> "$ZRC"
  chg "$ZRC (hook appended)"
fi

summary "shared"

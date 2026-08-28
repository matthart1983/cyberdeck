#!/usr/bin/env bash
# Everything that is identical on macOS and Linux. Called by ../install.sh —
# harmless to run directly. Idempotent: a second run writes nothing and says so.
set -euo pipefail
D="${D:-$HOME/.dotfiles}"
# shellcheck source=common/lib.sh
source "$D/common/lib.sh"

echo "==> shared configs"
link "$D/common/ghostty/config"         "$HOME/.config/ghostty/config"
link "$D/common/ghostty/themes"         "$HOME/.config/ghostty/themes"
link "$D/common/tmux/tmux.conf"         "$HOME/.config/tmux/tmux.conf"
link "$D/common/bat/config"             "$HOME/.config/bat/config"
link "$D/common/bat/themes"             "$HOME/.config/bat/themes"
link "$D/common/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
link "$D/common/zed/themes/cyberpunk-neon.json"   "$HOME/.config/zed/themes/cyberpunk-neon.json"
link "$D/common/atuin/themes/cyberpunk-neon.toml" "$HOME/.config/atuin/themes/cyberpunk-neon.toml"

# btop reads its themes directory directly and will not follow a symlink into
# the repo, so this one is a copy.
echo "==> btop theme"
copy "$D/common/btop/themes/cyberpunk-neon.theme" "$HOME/.config/btop/themes/cyberpunk-neon.theme"

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
if grep -q '^\[theme\]' "$ATUIN_CFG" 2>/dev/null; then
  same "$ATUIN_CFG"
else
  mkdir -p "$(dirname "$ATUIN_CFG")"
  printf '\n[theme]\nname = "cyberpunk-neon"\n' >> "$ATUIN_CFG"
  chg "$ATUIN_CFG"
fi

echo "==> claude code"
# The rice owns Claude Code's theme and statusline; the rest of that file is
# the user's own, so this patches two keys rather than linking over it.
CC_SETTINGS="$HOME/.claude/settings.json"
if ! command -v python3 >/dev/null; then
  warn "python3 not available — skipped"
else
  case "$(python3 "$D/common/claude-settings.py" "$CC_SETTINGS" "$D/common/bin/cc-statusline")" in
    changed) chg "$CC_SETTINGS" ;;
    same)    same "$CC_SETTINGS" ;;
    invalid) warn "$CC_SETTINGS is not valid JSON — left alone" ;;
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

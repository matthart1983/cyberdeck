#!/usr/bin/env bash
# Re-link every rice config. Idempotent — safe to re-run.
set -euo pipefail
D="$HOME/.dotfiles"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

echo "==> linking configs"
link "$D/ghostty/config"        "$HOME/.config/ghostty/config"
link "$D/ghostty/themes"        "$HOME/.config/ghostty/themes"
link "$D/tmux/tmux.conf"        "$HOME/.config/tmux/tmux.conf"
link "$D/bat/config"            "$HOME/.config/bat/config"
link "$D/bat/themes"            "$HOME/.config/bat/themes"
link "$D/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
link "$D/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
link "$D/sketchybar"            "$HOME/.config/sketchybar"
link "$D/zed/themes/cyberpunk-neon.json" "$HOME/.config/zed/themes/cyberpunk-neon.json"
link "$D/atuin/themes/cyberpunk-neon.toml" "$HOME/.config/atuin/themes/cyberpunk-neon.toml"

echo "==> btop theme"
mkdir -p "$HOME/.config/btop/themes"
cp "$D/btop/themes/cyberpunk-neon.theme" "$HOME/.config/btop/themes/"

echo "==> bat cache"
bat cache --build >/dev/null 2>&1 && echo "  rebuilt"

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

echo "==> atuin theme"
if ! grep -q '^\[theme\]' "$HOME/.config/atuin/config.toml" 2>/dev/null; then
  printf '\n[theme]\nname = "cyberpunk-neon"\n' >> "$HOME/.config/atuin/config.toml"
  echo "  enabled"
else
  echo "  already enabled"
fi

echo "==> zshrc hook"
if ! grep -q "dotfiles/zsh/cyberpunk.zsh" "$HOME/.zshrc"; then
  printf '\n# --- Cyberpunk rice ---\n[[ -f ~/.dotfiles/zsh/cyberpunk.zsh ]] && source ~/.dotfiles/zsh/cyberpunk.zsh\n' >> "$HOME/.zshrc"
  echo "  appended to ~/.zshrc"
else
  echo "  already present"
fi

echo "==> done. 'exec zsh' to reload, 'hud' for the dashboard."
echo "    AeroSpace needs Accessibility permission on first launch."


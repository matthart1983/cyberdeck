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
PLIST="$HOME/Library/LaunchAgents/io.matt.netwatch-metrics.plist"
mkdir -p "$HOME/Library/LaunchAgents"
ln -sfn "$D/launchd/io.matt.netwatch-metrics.plist" "$PLIST"
# bootout is asynchronous: bootstrapping straight after it races the teardown
# and fails. Kickstart an already-loaded service instead of cycling it.
if launchctl print "gui/$UID/io.matt.netwatch-metrics" >/dev/null 2>&1; then
  launchctl kickstart -k "gui/$UID/io.matt.netwatch-metrics" 2>/dev/null \
    && echo "  restarted" || echo "  ERROR: kickstart failed"
else
  if err=$(launchctl bootstrap "gui/$UID" "$PLIST" 2>&1); then
    echo "  loaded"
  else
    echo "  ERROR: bootstrap failed: ${err:-unknown}"
  fi
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


#!/usr/bin/env bash
# Everything that is identical on macOS and Linux. Called by ../install.sh —
# not meant to be run directly, though it is harmless if you do.
# Idempotent.
set -euo pipefail
D="${D:-$HOME/.dotfiles}"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

echo "==> linking shared configs"
link "$D/ghostty/config"         "$HOME/.config/ghostty/config"
link "$D/ghostty/themes"         "$HOME/.config/ghostty/themes"
link "$D/tmux/tmux.conf"         "$HOME/.config/tmux/tmux.conf"
link "$D/bat/config"             "$HOME/.config/bat/config"
link "$D/bat/themes"             "$HOME/.config/bat/themes"
link "$D/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
link "$D/zed/themes/cyberpunk-neon.json"   "$HOME/.config/zed/themes/cyberpunk-neon.json"
link "$D/atuin/themes/cyberpunk-neon.toml" "$HOME/.config/atuin/themes/cyberpunk-neon.toml"

echo "==> btop theme"
mkdir -p "$HOME/.config/btop/themes"
cp "$D/btop/themes/cyberpunk-neon.theme" "$HOME/.config/btop/themes/"
echo "  copied"

echo "==> bat cache"
if command -v bat >/dev/null; then
  bat cache --build >/dev/null 2>&1 && echo "  rebuilt" || echo "  failed"
else
  echo "  bat not installed — skipping"
fi

echo "==> atuin theme"
if ! grep -q '^\[theme\]' "$HOME/.config/atuin/config.toml" 2>/dev/null; then
  mkdir -p "$HOME/.config/atuin"
  printf '\n[theme]\nname = "cyberpunk-neon"\n' >> "$HOME/.config/atuin/config.toml"
  echo "  enabled"
else
  echo "  already enabled"
fi

echo "==> zshrc hook"
touch "$HOME/.zshrc"
if ! grep -q "dotfiles/zsh/cyberpunk.zsh" "$HOME/.zshrc"; then
  printf '\n# --- Cyberpunk rice ---\n[[ -f ~/.dotfiles/zsh/cyberpunk.zsh ]] && source ~/.dotfiles/zsh/cyberpunk.zsh\n' >> "$HOME/.zshrc"
  echo "  appended to ~/.zshrc"
else
  echo "  already present"
fi

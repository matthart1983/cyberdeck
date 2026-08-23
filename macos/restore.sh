#!/usr/bin/env bash
# Undo the rice: replay macos/before.txt back into the defaults system.
set -euo pipefail
in="${1:-$HOME/.dotfiles/macos/before.txt}"
[[ -f $in ]] || { echo "no snapshot at $in"; exit 1; }

while IFS=$'\t' read -r domain key val; do
  [[ -z ${domain:-} ]] && continue
  if [[ $val == "<unset>" ]]; then
    defaults delete "$domain" "$key" 2>/dev/null || true
    echo "  deleted $domain $key"
  elif [[ $val =~ ^-?[0-9]+$ ]]; then
    defaults write "$domain" "$key" -int "$val"
    echo "  restored $domain $key = $val (int)"
  elif [[ $val =~ ^-?[0-9]*\.[0-9]+$ ]]; then
    defaults write "$domain" "$key" -float "$val"
    echo "  restored $domain $key = $val (float)"
  else
    defaults write "$domain" "$key" -string "$val"
    echo "  restored $domain $key = $val (string)"
  fi
done < "$in"

killall Dock Finder SystemUIServer 2>/dev/null || true
echo "restored. Some changes need a logout to fully revert."

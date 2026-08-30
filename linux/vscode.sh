#!/usr/bin/env bash
# The editor slot's IDE. Opt-in, exactly like linux/ghostty.sh and
# linux/packages.sh — install.sh never calls this.
#
#   ~/.dotfiles/linux/vscode.sh              VSCodium, from Flathub. No sudo.
#   ~/.dotfiles/linux/vscode.sh --microsoft  VS Code proper, from Microsoft.
#
# Two builds, because Fedora packages neither and they are not the same thing:
#
#   VSCodium is the same source tree, built without Microsoft's branding,
#   telemetry and proprietary marketplace. It is on Fedora's filtered Flathub,
#   so it installs per-user with no sudo, no third-party repo and nothing
#   root-owned. That is why it is the default here.
#
#   VS Code proper is a proprietary build and is not on the filtered Flathub.
#   Getting it means adding Microsoft's yum repo, which is a vendor repo in
#   your dnf configuration for as long as it is there. That is a real decision
#   and this script will not make it silently — hence the flag. It is at least
#   Microsoft's own repo, signed by Microsoft's own key, which is the line
#   packages.sh draws: official builds yes, third-party rebuilds no.
#
# Either one satisfies the dock's `editor` slot; `dock list` will show which.
set -euo pipefail

case "${1:-}" in
  --microsoft)
    echo "==> VS Code, from packages.microsoft.com (needs sudo)"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    printf '%s\n' \
      '[code]' \
      'name=Visual Studio Code' \
      'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
      'enabled=1' \
      'autorefresh=1' \
      'type=rpm-md' \
      'gpgcheck=1' \
      'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' \
      | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
    sudo dnf install -y code
    echo "    installed as 'code' — undo with:"
    echo "      sudo dnf remove code && sudo rm /etc/yum.repos.d/vscode.repo"
    ;;
  ""|--flatpak)
    echo "==> VSCodium, from Flathub (no sudo)"
    command -v flatpak >/dev/null || {
      echo "flatpak not installed — sudo dnf install flatpak" >&2; exit 1; }
    flatpak install -y --user flathub com.vscodium.codium
    echo "    installed as 'com.vscodium.codium' — undo with:"
    echo "      flatpak uninstall --user com.vscodium.codium"
    ;;
  *)
    echo "usage: vscode.sh [--flatpak|--microsoft]" >&2; exit 2 ;;
esac

echo
echo "==> dock"
if "$HOME/.dotfiles/linux/bin/dock" list | grep -q '^editor *ok'; then
  "$HOME/.dotfiles/linux/bin/dock" list | grep '^editor'
  # SIGUSR2, not the lighter SIGRTMIN+7 re-probe. The dock's slots live inside
  # a group drawer, and a module that resolved nothing at startup is a widget
  # the drawer is already hiding — re-running its probe gives it text without
  # necessarily bringing the widget back. A full reload rebuilds both bars from
  # the config and cannot be stale, which is what you want on the one command
  # whose entire job was to make a new icon appear.
  pkill -USR2 waybar 2>/dev/null && echo "    bar reloaded — the icon is there now"
else
  echo "    editor still resolves nothing; 'dock list' says what it looked for"
fi

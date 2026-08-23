#!/usr/bin/env bash
# Cyberpunk rice — macOS system layer. Idempotent; undo with restore.sh.
set -euo pipefail

# Refuse to touch anything until this machine's own prior state is recorded.
SNAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/before.txt"
if [[ ! -f $SNAP ]]; then
  echo "no snapshot at $SNAP"
  echo "run macos/snapshot.sh first — it records what this script is about to"
  echo "overwrite, and restore.sh replays it. Ricing is reversible or it isn't"
  echo "worth doing."
  exit 1
fi

echo "==> applying macOS defaults"

# --- Appearance -------------------------------------------------------------
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleAccentColor -int 5          # purple
defaults write NSGlobalDomain AppleHighlightColor -string "0.968627 0.831373 1.000000 Purple"

# --- Motion: make the machine feel fast ------------------------------------
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1

# --- Dock: small, hidden, instant ------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool true

# --- Menu bar ---------------------------------------------------------------
# On macOS 15 this key no longer takes effect without a full logout — writing
# it and restarting SystemUIServer (and the -currentHost variant) leaves the
# menu bar on screen. It is still written so a logout gets you the classic
# "SketchyBar replaces the menu bar" look, but nothing depends on it: the bar
# sits at y_offset 38, below the menu bar, so it is visible either way.
# Reversible: macos/restore.sh puts it back from the pre-rice snapshot.
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# --- Desktop: no icons, wallpaper unobstructed -----------------------------
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# --- Screenshots: clean PNGs for the capture phase -------------------------
mkdir -p "$HOME/Pictures/shots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/shots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

killall Dock Finder SystemUIServer 2>/dev/null || true
echo "==> done. Menu bar hiding takes effect per-app; log out for a full apply."

#!/usr/bin/env bash
# Cyberpunk rice — macOS system layer. Idempotent; undo with restore.sh.
set -euo pipefail
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

# --- Menu bar: hide it (SketchyBar replaces it in Phase 5) -----------------
# Deferred to Phase 5 — hiding this before SketchyBar exists leaves no clock/status.
# defaults write NSGlobalDomain _HIHideMenuBar -bool true

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

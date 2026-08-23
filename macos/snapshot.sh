#!/usr/bin/env bash
# Snapshot every macOS default this rice touches, so restore.sh can put it back.
out="${1:-$HOME/.dotfiles/macos/before.txt}"
: > "$out"
read_default() {
  local domain="$1" key="$2" val
  if val=$(defaults read "$domain" "$key" 2>/dev/null); then
    printf '%s\t%s\t%s\n' "$domain" "$key" "$val" >> "$out"
  else
    printf '%s\t%s\t<unset>\n' "$domain" "$key" >> "$out"
  fi
}

read_default NSGlobalDomain AppleInterfaceStyle
read_default NSGlobalDomain AppleAccentColor
read_default NSGlobalDomain AppleHighlightColor
read_default NSGlobalDomain NSWindowResizeTime
read_default NSGlobalDomain NSAutomaticWindowAnimationsEnabled
read_default NSGlobalDomain _HIHideMenuBar
read_default NSGlobalDomain AppleShowAllExtensions
read_default com.apple.dock autohide
read_default com.apple.dock autohide-delay
read_default com.apple.dock autohide-time-modifier
read_default com.apple.dock tilesize
read_default com.apple.dock magnification
read_default com.apple.dock show-recents
read_default com.apple.dock mineffect
read_default com.apple.dock expose-animation-duration
read_default com.apple.dock minimize-to-application
read_default com.apple.finder CreateDesktop
read_default com.apple.finder ShowPathbar
read_default com.apple.finder ShowStatusBar
read_default com.apple.screencapture location
read_default com.apple.screencapture type
read_default com.apple.screencapture disable-shadow

echo "snapshot written to $out ($(wc -l < "$out" | tr -d ' ') keys)"

#!/usr/bin/env bash
# Re-link every rice config. Idempotent — safe to re-run.
#
# Shared work lives in common/install.sh; the platform halves live in
# macos/install.sh and linux/install.sh. Nothing here touches system settings:
# the macOS defaults layer is still opt-in via macos/defaults.sh, and the
# Fedora package layer is still opt-in via linux/packages.sh.
set -euo pipefail
D="$HOME/.dotfiles"
export D

case "$(uname -s)" in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *)      echo "unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

echo "==> cyberdeck · $PLATFORM"

bash "$D/common/install.sh"
bash "$D/$PLATFORM/install.sh"

echo "==> done. 'exec zsh' to reload, 'hud' for the dashboard."

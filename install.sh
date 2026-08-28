#!/usr/bin/env bash
# Re-link every rice config. Idempotent — safe to re-run, and `test/idempotent.sh`
# is what keeps that claim honest.
#
# Shared work lives in common/install.sh; the platform halves live in
# macos/install.sh and linux/install.sh. Nothing here touches system settings:
# the macOS defaults layer is opt-in via macos/defaults.sh, and the Fedora
# package layer is opt-in via linux/packages.sh.
#
#   common/   configs and executables that work on both platforms
#   macos/    AeroSpace, SketchyBar, JankyBorders, launchd
#   linux/    niri, Waybar, systemd user units
#
# palette.sh stays at the root: it is the single source of truth for both.
set -euo pipefail
D="$HOME/.dotfiles"
export D

case "$(uname -s)" in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *)      echo "unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

# Anything the install displaces is moved under attic/<stamp>/ rather than
# overwritten. One stamp for the whole run, so a single install is a single
# directory you can read or delete as a unit.
CYBERDECK_STAMP="$(date +%Y%m%d-%H%M%S)"
export CYBERDECK_STAMP

echo "==> cyberdeck · $PLATFORM"

bash "$D/common/install.sh"
bash "$D/$PLATFORM/install.sh"

if [ -d "$D/attic/$CYBERDECK_STAMP" ]; then
  echo "==> displaced files kept in attic/$CYBERDECK_STAMP"
fi
echo "==> done. 'exec zsh' to reload, 'hud' for the dashboard, 'rice-doctor' to check."

#!/usr/bin/env bash
# The single source of truth for every themed surface — now a pointer to one.
#
# The colours moved to themes/<slug>.sh, one file per theme, all filling the
# same 41 slots. themes/active.sh is a symlink to whichever is in use and is
# deliberately untracked: which theme you run is a property of your machine,
# not of the repo. A fresh clone has no symlink and falls back to the default,
# so nothing has to exist for this to work.
#
# The themed surfaces do not read this at runtime — none of them can source a
# shell variable, which is the whole reason they are rendered from templates
# by `theme` instead. This file is for the things that can: rice-doctor, and
# anything you write yourself.
#
#   theme                 what's active
#   theme blade           switch
#   themes/README.md      what the 41 slots mean

_cp_root="${D:-$HOME/.dotfiles}"
if [ -e "$_cp_root/themes/active.sh" ]; then
  # shellcheck source=/dev/null
  source "$_cp_root/themes/active.sh"
else
  # shellcheck source=themes/cyberpunk-neon.sh
  source "$_cp_root/themes/cyberpunk-neon.sh"
fi
unset _cp_root

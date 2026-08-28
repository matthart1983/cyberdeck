#!/usr/bin/env bash
# Shared helpers for the install scripts. Sourced, never run directly.
#
# The piece worth factoring out is link(). The naive `ln -sfn "$src" "$dst"`
# it replaces had two failure modes, both of which only ever bite on a machine
# that has not run this before — which is exactly the machine you cannot test
# on twice:
#
#   * When $dst is a real directory, `ln -sfn` creates the link *inside* it
#     rather than replacing it. ~/.config/ghostty/themes already exists on a
#     fresh install, so you get ~/.config/ghostty/themes/themes and a rice
#     that half-works.
#   * A missing $src silently produced a dangling symlink instead of an error.
#
# Everything here is written so that a second run is a no-op that says so.
# install.sh's contract is that re-running it changes nothing; `changed` is
# how that claim is made checkable rather than asserted in a comment.

: "${D:=$HOME/.dotfiles}"
ATTIC="$D/attic"

# Colour, unless asked not to. The idempotency test sets CYBERDECK_PLAIN so it
# can read the summary lines without stripping escapes.
if [ -n "${CYBERDECK_PLAIN:-}" ] || [ ! -t 1 ]; then
  _c_ok=''; _c_chg=''; _c_warn=''; _c_off=''
else
  _c_ok=$'\033[38;5;48m'; _c_chg=$'\033[38;5;201m'
  _c_warn=$'\033[38;5;220m'; _c_off=$'\033[0m'
fi

_changed=0
_same=0

# Something was written. Counted, because a second run must produce none.
chg()  { _changed=$((_changed+1)); printf '  %s+%s %s\n' "$_c_chg" "$_c_off" "$*"; }
# Already correct. Not counted — this is what a re-run should print instead.
same() { _same=$((_same+1));       printf '  %s=%s %s\n' "$_c_ok" "$_c_off" "$*"; }
warn() {                           printf '  %s!%s %s\n' "$_c_warn" "$_c_off" "$*"; }

summary() {
  printf '==> %s: %d changed, %d already correct\n' "${1:-done}" "$_changed" "$_same"
}

# Move whatever currently occupies $1 into attic/, keeping its path under a
# run timestamp. .gitignore has reserved attic/ for this since the first
# commit; nothing had ever written to it.
attic_stash() {
  local victim="$1" dest
  dest="$ATTIC/${CYBERDECK_STAMP:-manual}/${victim#"$HOME"/}"
  mkdir -p "$(dirname "$dest")"
  mv "$victim" "$dest"
  printf '%s' "$dest"
}

# link SRC DST — symlink DST -> SRC, preserving anything already at DST.
link() {
  local src="$1" dst="$2" stashed
  if [ ! -e "$src" ]; then
    warn "missing source, skipped: ${src#"$D"/}"
    return 0
  fi
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    same "$dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    stashed="$(attic_stash "$dst")"
    warn "existing $dst moved to ${stashed#"$D"/}"
  fi
  ln -sfn "$src" "$dst"
  chg "$dst -> ${src#"$D"/}"
}

# copy SRC DST — for the surfaces that cannot follow a symlink (btop reads its
# themes dir directly and will not traverse one). Only writes on difference,
# so a re-run is silent.
copy() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    warn "missing source, skipped: ${src#"$D"/}"
    return 0
  fi
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    same "$dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  chg "$dst"
}

# render TEMPLATE DST SED_ARGS... — expand a service template, but only write
# when the result differs. The callers restart a daemon on a write, so a
# needless write means a needless restart on every install.
render() {
  local tpl="$1" dst="$2"; shift 2
  local tmp; tmp="$(mktemp)"
  sed "$@" "$tpl" > "$tmp"
  if [ -f "$dst" ] && cmp -s "$tmp" "$dst"; then
    rm -f "$tmp"; same "$dst"; return 1
  fi
  mkdir -p "$(dirname "$dst")"
  mv "$tmp" "$dst"
  chg "$dst"
  return 0
}

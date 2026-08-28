#!/usr/bin/env bash
# Prove install.sh is idempotent, instead of asserting it in a header comment.
#
# Every install script in this repo claims "safe to re-run". This runs the real
# install.sh twice against a throwaway $HOME and fails if the second run wrote
# anything: no changed lines in the summaries, and a byte-identical tree.
#
# Hermetic on purpose. The install talks to systemd, launchd, brew and a
# running bar; under a fake $HOME those calls would still reach the real user
# session and could bounce the live netwatch daemon. So the stub dir below
# shadows them for the duration.
#
#   test/idempotent.sh          all cases
#   test/idempotent.sh fresh    just one
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0; FAIL=0
c_pass() { printf '  \033[38;5;48m✔\033[0m %s\n' "$*"; PASS=$((PASS+1)); }
c_fail() { printf '  \033[38;5;197m✘\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }

# Record type, symlink target and content hash for everything under the fake
# home. This is the artifact the two runs get compared on.
snapshot() {
  local root="$1"
  ( cd "$root" && find . -mindepth 1 | LC_ALL=C sort | while read -r p; do
      if   [ -L "$p" ]; then printf 'link %s -> %s\n' "$p" "$(readlink "$p")"
      elif [ -d "$p" ]; then printf 'dir  %s\n' "$p"
      else printf 'file %s %s\n' "$p" "$(cksum < "$p" | cut -d' ' -f1)"
      fi
    done )
}

make_stubs() {
  local dir="$1"; mkdir -p "$dir"
  # Record calls rather than making them, so a test run can never restart the
  # real daemon or the real bar.
  for cmd in systemctl launchctl brew pkill pgrep chsh; do
    cat > "$dir/$cmd" <<STUB
#!/usr/bin/env bash
echo "\$(basename "\$0") \$*" >> "\${CYBERDECK_STUB_LOG:-/dev/null}"
exit 1
STUB
    chmod +x "$dir/$cmd"
  done
}

run_case() {
  local name="$1" fixture="$2"
  local tmp; tmp="$(mktemp -d)"
  local home="$tmp/home"; mkdir -p "$home"
  local stubs="$tmp/stubs"; make_stubs "$stubs"

  cp -a "$REPO" "$home/.dotfiles"
  rm -rf "$home/.dotfiles/.git" "$home/.dotfiles/attic"

  # Fixtures set up the pre-existing state this case is about.
  ( cd "$home" && eval "$fixture" )

  local out1="$tmp/run1.log" out2="$tmp/run2.log"
  local env_common=(
    "HOME=$home"
    "XDG_CACHE_HOME=$home/.cache"
    "XDG_RUNTIME_DIR=$tmp/run"
    "CYBERDECK_PLAIN=1"
    "CYBERDECK_STUB_LOG=$tmp/stubs.log"
    "PATH=$stubs:$PATH"
  )

  env "${env_common[@]}" bash "$home/.dotfiles/install.sh" > "$out1" 2>&1
  local rc1=$?
  local snap1; snap1="$(snapshot "$home")"

  # A second stamp, so an attic write on run 2 lands in a new directory and
  # shows up in the diff rather than merging into run 1's.
  sleep 1
  env "${env_common[@]}" bash "$home/.dotfiles/install.sh" > "$out2" 2>&1
  local rc2=$?
  local snap2; snap2="$(snapshot "$home")"

  printf '\n\033[38;5;201m▐ case: %s\033[0m\n' "$name"

  [ "$rc1" -eq 0 ] && c_pass "first run exits 0" \
                   || { c_fail "first run exited $rc1"; sed 's/^/      /' "$out1" | tail -20; }
  [ "$rc2" -eq 0 ] && c_pass "second run exits 0" \
                   || { c_fail "second run exited $rc2"; sed 's/^/      /' "$out2" | tail -20; }

  # The summary lines are the scripts' own account of what they did.
  local dirty
  dirty="$(grep -E '^==> .*: [0-9]+ changed' "$out2" | grep -v ': 0 changed' || true)"
  if [ -z "$dirty" ]; then
    c_pass "second run reports 0 changed"
  else
    c_fail "second run reported writes:"
    printf '      %s\n' "$dirty"
  fi

  # And the filesystem's account, which is the one that cannot lie.
  if [ "$snap1" = "$snap2" ]; then
    c_pass "tree identical across runs"
  else
    c_fail "tree changed between runs:"
    diff <(printf '%s\n' "$snap1") <(printf '%s\n' "$snap2") | sed 's/^/      /' | head -20
  fi

  # Case-specific checks.
  case "$name" in
    real-dir)
      # The ln -sfn trap: a real directory at the destination must be moved
      # aside, not nested into.
      if [ -L "$home/.config/ghostty/themes" ]; then
        c_pass "real dir replaced by symlink, not nested"
      else
        c_fail "themes/ is still a real dir — link() nested into it"
      fi
      if find "$home/.dotfiles/attic" -name sentinel 2>/dev/null | grep -q .; then
        c_pass "displaced file preserved in attic/"
      else
        c_fail "displaced file was destroyed, not stashed"
      fi
      ;;
    old-layout)
      local hits
      hits="$(grep -c 'cyberpunk.zsh' "$home/.zshrc")"
      if [ "$hits" -eq 1 ] && grep -q 'common/zsh/cyberpunk.zsh' "$home/.zshrc"; then
        c_pass "pre-restructure hook migrated in place (1 line, new path)"
      else
        c_fail "zshrc has $hits hook lines:"
        grep -n 'cyberpunk.zsh' "$home/.zshrc" | sed 's/^/      /'
      fi
      ;;
  esac

  rm -rf "$tmp"
}

printf '\033[38;5;201m▐ CYBERDECK — IDEMPOTENCY\033[0m\n'

WANT="${1:-all}"

# A machine that has never seen the rice.
[ "$WANT" = all ] || [ "$WANT" = fresh ] && \
  run_case fresh ':'

# A machine whose ~/.config already has real directories where the rice wants
# symlinks. This is the case `ln -sfn` got wrong, and it only happens once.
[ "$WANT" = all ] || [ "$WANT" = real-dir ] && \
  run_case real-dir 'mkdir -p .config/ghostty/themes .config/bat/themes
                     touch .config/ghostty/themes/sentinel'

# A machine still on the pre-restructure layout: the hook in ~/.zshrc points at
# ~/.dotfiles/zsh/, which no longer exists.
[ "$WANT" = all ] || [ "$WANT" = old-layout ] && \
  run_case old-layout 'printf "\n# --- Cyberpunk rice ---\n[[ -f ~/.dotfiles/zsh/cyberpunk.zsh ]] && source ~/.dotfiles/zsh/cyberpunk.zsh\n" > .zshrc'

printf '\n  %d passed, %d failed\n\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]

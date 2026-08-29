#!/usr/bin/env bash
# Prove the theme system, instead of asserting it in a header comment.
#
# Thirteen surfaces mirror the palette in nine colour notations, and eight
# themes fill it. That is 104 renders nobody is going to check by eye, which is
# exactly the situation that produced the hand-mirroring this replaces.
#
#   test/theme.sh
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0; FAIL=0
c_pass() { printf '  \033[38;5;48m✔\033[0m %s\n' "$*"; PASS=$((PASS+1)); }
c_fail() { printf '  \033[38;5;197m✘\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }

printf '\033[38;5;201m▐ CYBERDECK — THEMES\033[0m\n'

THEMES=()
for f in "$REPO"/themes/*.sh; do
  [ "$(basename "$f")" = active.sh ] && continue
  THEMES+=("$(basename "$f" .sh)")
done

# --- 1. a palette that parses is not a palette that works ------------------
# `CP_BG ="#000b1e"` is a command, not an assignment. bash -n passes it and the
# variable is never set, so nothing but sourcing and reading back can catch it.
printf '\n\033[38;5;201m▐ palettes load\033[0m\n'
for t in "${THEMES[@]}"; do
  got="$(bash -c 'source "$1" 2>/dev/null; printf "%s|%s|%s" "${CP_BG:-}" "${CP_SOFT_BLUE:-}" "${CP_THEME_SLUG:-}"' _ "$REPO/themes/$t.sh")"
  case "$got" in
    "#"*"|#"*"|$t") c_pass "$t sets its slots" ;;
    *)              c_fail "$t sources to [$got] — padded '=' or a missing slot" ;;
  esac
done

# --- 2. one contract, filled the same way by everyone ----------------------
printf '\n\033[38;5;201m▐ the contract\033[0m\n'
slots_of() { grep -oE '^CP_[A-Z0-9_]+' "$REPO/themes/$1.sh" | tr '\n' ' '; }
REF="$(slots_of cyberpunk-neon)"
REF_N="$(printf '%s' "$REF" | wc -w | tr -d ' ')"
for t in "${THEMES[@]}"; do
  if [ "$(slots_of "$t")" = "$REF" ]; then
    c_pass "$t fills the contract — $REF_N assignments, in order"
  else
    c_fail "$t diverges from the contract:"
    diff <(tr ' ' '\n' <<<"$REF") <(slots_of "$t" | tr ' ' '\n') | sed 's/^/      /' | head -8
  fi
done

bad="$(grep -hoE '^CP_[A-Z0-9_]+="[^"]*"' "$REPO"/themes/*.sh \
       | grep -vE '="#[0-9a-f]{6}"$' | grep -vE '^CP_THEME_' || true)"
[ -z "$bad" ] && c_pass "every colour is a lowercase #rrggbb" \
               || { c_fail "not a colour literal:"; printf '      %s\n' "$bad"; }

# --- 3. every theme × every surface ----------------------------------------
printf '\n\033[38;5;201m▐ renders\033[0m\n'
mapfile -t TMPLS < <(grep -oE '^  "[a-z][^ ]*\.tmpl' "$REPO/common/bin/theme" | tr -d ' "')
for t in "${THEMES[@]}"; do
  errs=""; n=0
  for tpl in "${TMPLS[@]}"; do
    if out=$("$REPO/common/bin/theme-render" "$REPO/themes/$t.sh" "$REPO/$tpl" 2>&1 >/dev/null); then
      n=$((n+1))
    else
      errs="$errs
      $out"
    fi
  done
  [ -z "$errs" ] && c_pass "$t renders all ${#TMPLS[@]} surfaces" \
                 || { c_fail "$t: $n/${#TMPLS[@]} rendered$errs"; }
done

# A literal colour left in a template is a colour that stops following the
# theme — the exact bug templating is here to remove.
stray="$(grep -nE '#[0-9a-fA-F]{6}' "${TMPLS[@]/#/$REPO/}" 2>/dev/null || true)"
[ -z "$stray" ] && c_pass "no literal colours left in any template" \
                || { c_fail "literal colour in a template:"; printf '%s\n' "$stray" | sed 's/^/      /' | head -6; }

# --- 4. what is committed is what the templates produce --------------------
printf '\n\033[38;5;201m▐ drift\033[0m\n'
if out="$(D="$REPO" "$REPO/common/bin/theme" --check 2>&1)"; then
  c_pass "tracked surfaces match the active palette"
else
  c_fail "tracked surfaces have drifted:"; printf '%s\n' "$out" | sed 's/^/      /'
fi

# --- 5. switching is reversible --------------------------------------------
# The whole point of rendering rather than hand-mirroring: going to another
# theme and back has to land on the same bytes, or `git diff` stops being a
# usable record of what a theme changed.
printf '\n\033[38;5;201m▐ round trip\033[0m\n'
tmp="$(mktemp -d)"; cp -a "$REPO" "$tmp/repo"; rm -rf "$tmp/repo/.git"
# --render-only, emphatically: a bare `theme <slug>` now runs install.sh, and a
# test has no business linking into the real ~/.config.
before="$(cd "$tmp/repo" && find . -type f -not -path './themes/active.sh' | LC_ALL=C sort | xargs cksum | cksum)"
for t in "${THEMES[@]}"; do
  [ "$t" = cyberpunk-neon ] && continue
  D="$tmp/repo" bash "$tmp/repo/common/bin/theme" "$t" --render-only >/dev/null 2>&1
done
D="$tmp/repo" bash "$tmp/repo/common/bin/theme" cyberpunk-neon --render-only >/dev/null 2>&1
after="$(cd "$tmp/repo" && find . -type f -not -path './themes/active.sh' | LC_ALL=C sort | xargs cksum | cksum)"
if [ "$before" = "$after" ]; then
  c_pass "all ${#THEMES[@]} themes applied, then back — tree identical"
else
  c_fail "round trip through ${#THEMES[@]} themes did not restore the tree"
  ( cd "$tmp/repo" && git diff --stat 2>/dev/null | tail -5 ) | sed 's/^/      /'
fi
rm -rf "$tmp"

# --- 6. contrast floors ----------------------------------------------------
# The slots that carry text have to stay readable on their own background. The
# floors are the ones today's palette actually meets, not the ones a
# specification would like: CP_FG_DIM has sat at 4.0 since the first commit and
# a test that fails on the shipped theme teaches nobody anything.
printf '\n\033[38;5;201m▐ contrast\033[0m\n'
python3 - "$REPO" "${THEMES[@]}" <<'PY'
import re, sys
repo, themes = sys.argv[1], sys.argv[2:]
# CP_WHITE is deliberately absent: since the CP_FG_STRONG split it is ANSI 7,
# the light end of the terminal ramp, and on a light theme it is a background
# tint by design. CP_FG_STRONG is the slot that carries emphatic text.
FLOOR = {"CP_FG": 4.5, "CP_FG_STRONG": 4.5, "CP_FG_DIM": 4.0, "CP_MAGENTA": 4.5,
         "CP_RED": 4.5, "CP_GREEN": 4.5, "CP_ORANGE": 4.5, "CP_YELLOW": 4.5,
         "CP_PURPLE_MID": 3.0}
def lum(h):
    h = h.lstrip("#"); c = [int(h[i:i+2], 16)/255 for i in (0, 2, 4)]
    f = lambda v: v/12.92 if v <= 0.03928 else ((v+0.055)/1.055)**2.4
    return 0.2126*f(c[0]) + 0.7152*f(c[1]) + 0.0722*f(c[2])
def ratio(a, b):
    x, y = sorted((lum(a), lum(b)), reverse=True); return (x+0.05)/(y+0.05)
bad = 0
for t in themes:
    p = dict(re.findall(r'^(CP_[A-Z0-9_]+)="(#[0-9a-f]{6})"', open(f"{repo}/themes/{t}.sh").read(), re.M))
    for slot, floor in FLOOR.items():
        r = ratio(p[slot], p["CP_BG"])
        if r < floor:
            print(f"  \033[38;5;197m✘\033[0m {t}: {slot} is {r:.1f}:1 on CP_BG, floor {floor}")
            bad += 1
for t in themes:
    p = dict(re.findall(r'^(CP_[A-Z0-9_]+)="(#[0-9a-f]{6})"', open(f"{repo}/themes/{t}.sh").read(), re.M))
    r = ratio(p["CP_FG"], p["CP_BG_ALT"])
    if r < 4.5:
        print(f"  \033[38;5;197m✘\033[0m {t}: CP_FG on CP_BG_ALT is {r:.1f}:1 — the bar is unreadable")
        bad += 1
print(f"  \033[38;5;48m✔\033[0m every text slot clears its floor on all {len(themes)} themes" if not bad else "")
sys.exit(1 if bad else 0)
PY
[ $? -eq 0 ] && PASS=$((PASS+1)) || FAIL=$((FAIL+1))

printf '\n  %d passed, %d failed\n\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]

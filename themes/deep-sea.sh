#!/usr/bin/env bash
# Deep Sea — Indigo hull, aqua readouts. Dark without the shouting.
#
# 41 slots, same order as themes/cyberpunk-neon.sh. See themes/README.md.
# Derived from the 14 authored colours; edit any line and re-run `theme deep-sea`.

CP_THEME_NAME="Deep Sea"
CP_THEME_SLUG="deep-sea"
CP_THEME_LIGHT=0
CP_THEME_BASE="dark"

# --- surfaces ----------------------------------------------------------------
CP_BG="#060b16"            # primary background
CP_BG_ALT="#0e1729"        # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#0e1b30"       # recessed fill — disabled, dividers on panel
CP_BG_SEL="#142640"        # hover
CP_BG_HI="#1e3a5f"         # selection, active fill
CP_LINE="#1e333c"          # borders and rules
CP_BLACK="#030710"         # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#000000"          # the surface extreme — black when dark, white when light

# --- text --------------------------------------------------------------------
CP_FG="#7fd1d6"            # primary foreground — also ANSI 6
CP_FG_DIM="#4a7d86"        # comments, inactive text
CP_WHITE="#e6f2f5"         # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#e6f2f5"     # emphatic foreground — titles, selected text

# --- accents -----------------------------------------------------------------
CP_MAGENTA="#5d86ff"       # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#3b3f9e"        # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#7a7cbd"    # purple lifted to where it can carry a glyph
CP_BLUE="#245c8f"          # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#d98c4a"        # warnings
CP_RED="#e05a6b"           # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#d9c46a"        # highlights. ANSI 3
CP_GREEN="#4fc9a0"         # success, git clean. ANSI 2

# --- ANSI bright half --------------------------------------------------------
CP_BR_BLACK="#1e333c"
CP_BR_RED="#eb919d"
CP_BR_GREEN="#8adcc1"
CP_BR_YELLOW="#e7d99c"
CP_BR_BLUE="#4f95d4"
CP_BR_MAGENTA="#94afff"
CP_BR_CYAN="#aae1e5"
CP_BR_WHITE="#ffffff"

# --- soft half — syntax only -------------------------------------------------
CP_SOFT_FG="#8eb6b8"       # syntax base
CP_SOFT_DIM="#97acaf"      # punctuation
CP_SOFT_COMMENT="#6c7c81"
CP_SOFT_WHITE="#91aeb5"    # variables, plain identifiers
CP_SOFT_MAGENTA="#7d90ca"  # keywords
CP_SOFT_PURPLE="#8991bd"   # types
CP_SOFT_GREEN="#8db9aa"    # strings
CP_SOFT_TEAL="#8db8b0"     # string escapes
CP_SOFT_ORANGE="#bea188"   # numbers
CP_SOFT_YELLOW="#bcb28b"   # constants
CP_SOFT_CYAN="#8eb6b8"     # functions
CP_SOFT_RED="#bf878e"      # errors, deletions
CP_SOFT_BLUE="#8ba4bc"     # tags, attributes

# --- diff ---------------------------------------------------------------------
# Claude Code paints diffs as filled lines, which no other surface does and no
# other slot answers: a diff background is CP_GREEN sunk most of the way into
# CP_BG, and nothing in the accent half is that. Derived once from CP_GREEN,
# CP_RED and CP_BG, then authored here like the bright half — edit any line and
# re-run `theme <slug>`.
CP_DIFF_ADD_BG="#153132"      # added line — whole-line fill
CP_DIFF_DEL_BG="#321b27"      # removed line
CP_DIFF_ADD_BG_DIM="#0d1e24"  # added line, outside the focused hunk
CP_DIFF_DEL_BG_DIM="#1c131e"  # removed line, outside it
CP_DIFF_ADD_WORD="#2e7462"    # the changed words inside an added line
CP_DIFF_DEL_WORD="#7e3645"    # and inside a removed one

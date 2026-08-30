#!/usr/bin/env bash
# Blood Dragon — Hot pink on deep violet. Loudest of the eight.
#
# 41 slots, same order as themes/cyberpunk-neon.sh. See themes/README.md.
# Derived from the 14 authored colours; edit any line and re-run `theme blood-dragon`.

CP_THEME_NAME="Blood Dragon"
CP_THEME_SLUG="blood-dragon"
CP_THEME_LIGHT=0
CP_THEME_BASE="dark"

# --- surfaces ----------------------------------------------------------------
CP_BG="#14021d"            # primary background
CP_BG_ALT="#26063a"        # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#2c0738"       # recessed fill — disabled, dividers on panel
CP_BG_SEL="#3d0a4a"        # hover
CP_BG_HI="#5a0f6b"         # selection, active fill
CP_LINE="#40264a"          # borders and rules
CP_BLACK="#0b0110"         # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#000000"          # the surface extreme — black when dark, white when light

# --- text --------------------------------------------------------------------
CP_FG="#f0b8ff"            # primary foreground — also ANSI 6
CP_FG_DIM="#9a63ad"        # comments, inactive text
CP_WHITE="#fff0fb"         # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#fff0fb"     # emphatic foreground — titles, selected text

# --- accents -----------------------------------------------------------------
CP_MAGENTA="#ff2bb4"       # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#7b1fa8"        # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#a567c4"    # purple lifted to where it can carry a glyph
CP_BLUE="#3b26a8"          # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#ff6a3d"        # warnings
CP_RED="#ff1744"           # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#ffd54a"        # highlights. ANSI 3
CP_GREEN="#00e5a0"         # success, git clean. ANSI 2

# --- ANSI bright half --------------------------------------------------------
CP_BR_BLACK="#40264a"
CP_BR_RED="#ff6684"
CP_BR_GREEN="#46ffc7"
CP_BR_YELLOW="#ffe388"
CP_BR_BLUE="#6f5adb"
CP_BR_MAGENTA="#ff73cd"
CP_BR_CYAN="#f5d0ff"
CP_BR_WHITE="#ffffff"

# --- soft half — syntax only -------------------------------------------------
CP_SOFT_FG="#b97dca"       # syntax base
CP_SOFT_DIM="#a996b0"      # punctuation
CP_SOFT_COMMENT="#7c6a84"
CP_SOFT_WHITE="#ca7db5"    # variables, plain identifiers
CP_SOFT_MAGENTA="#ca7dae"  # keywords
CP_SOFT_PURPLE="#b784ba"   # types
CP_SOFT_GREEN="#7dcab3"    # strings
CP_SOFT_TEAL="#98a7bd"     # string escapes
CP_SOFT_ORANGE="#ca8f7d"   # numbers
CP_SOFT_YELLOW="#cab87d"   # constants
CP_SOFT_CYAN="#b97dca"     # functions
CP_SOFT_RED="#ca7d8c"      # errors, deletions
CP_SOFT_BLUE="#9289bd"     # tags, attributes

# --- diff ---------------------------------------------------------------------
# Claude Code paints diffs as filled lines, which no other surface does and no
# other slot answers: a diff background is CP_GREEN sunk most of the way into
# CP_BG, and nothing in the accent half is that. Derived once from CP_GREEN,
# CP_RED and CP_BG, then authored here like the bright half — edit any line and
# re-run `theme <slug>`.
CP_DIFF_ADD_BG="#102f37"      # added line — whole-line fill
CP_DIFF_DEL_BG="#430625"      # removed line
CP_DIFF_ADD_BG_DIM="#12192a"  # added line, outside the focused hunk
CP_DIFF_DEL_BG_DIM="#2c0421"  # removed line, outside it
CP_DIFF_ADD_WORD="#097f65"    # the changed words inside an added line
CP_DIFF_DEL_WORD="#950e32"    # and inside a removed one

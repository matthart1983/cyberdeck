#!/usr/bin/env bash
# Amber CRT — One phosphor, one hue family. Red is the only outsider.
#
# 41 slots, same order as themes/cyberpunk-neon.sh. See themes/README.md.
# Derived from the 14 authored colours; edit any line and re-run `theme amber-crt`.

CP_THEME_NAME="Amber CRT"
CP_THEME_SLUG="amber-crt"
CP_THEME_LIGHT=0
CP_THEME_BASE="dark"

# --- surfaces ----------------------------------------------------------------
CP_BG="#0f0a01"            # primary background
CP_BG_ALT="#1d1305"        # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#241702"       # recessed fill — disabled, dividers on panel
CP_BG_SEL="#311f03"        # hover
CP_BG_HI="#4a2f04"         # selection, active fill
CP_LINE="#3f2b01"          # borders and rules
CP_BLACK="#070400"         # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#000000"          # the surface extreme — black when dark, white when light

# --- text --------------------------------------------------------------------
CP_FG="#ffb000"            # primary foreground — also ANSI 6
CP_FG_DIM="#9b680b"        # comments, inactive text
CP_WHITE="#fff2d6"         # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#fff2d6"     # emphatic foreground — titles, selected text

# --- accents -----------------------------------------------------------------
CP_MAGENTA="#ff7b00"       # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#6b3f0a"        # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#9a7c58"    # purple lifted to where it can carry a glyph
CP_BLUE="#3d2a12"          # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#ff9500"        # warnings
CP_RED="#ff3b1f"           # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#ffd400"        # highlights. ANSI 3
CP_GREEN="#c2d100"         # success, git clean. ANSI 2

# --- ANSI bright half --------------------------------------------------------
CP_BR_BLACK="#3f2b01"
CP_BR_RED="#ff7e6b"
CP_BR_GREEN="#f1ff38"
CP_BR_YELLOW="#ffe357"
CP_BR_BLUE="#af7832"
CP_BR_MAGENTA="#ffa857"
CP_BR_CYAN="#ffcb57"
CP_BR_WHITE="#ffffff"

# --- soft half — syntax only -------------------------------------------------
CP_SOFT_FG="#cab27d"       # syntax base
CP_SOFT_DIM="#c7ae7f"      # punctuation
CP_SOFT_COMMENT="#907d59"
CP_SOFT_WHITE="#cab17d"    # variables, plain identifiers
CP_SOFT_MAGENTA="#caa27d"  # keywords
CP_SOFT_PURPLE="#c7a580"   # types
CP_SOFT_GREEN="#c4ca7d"    # strings
CP_SOFT_TEAL="#c7bf7d"     # string escapes
CP_SOFT_ORANGE="#caaa7d"   # numbers
CP_SOFT_YELLOW="#cabd7d"   # constants
CP_SOFT_CYAN="#cab27d"     # functions
CP_SOFT_RED="#ca867d"      # errors, deletions
CP_SOFT_BLUE="#baa68d"     # tags, attributes

# --- diff ---------------------------------------------------------------------
# Claude Code paints diffs as filled lines, which no other surface does and no
# other slot answers: a diff background is CP_GREEN sunk most of the way into
# CP_BG, and nothing in the accent half is that. Derived once from CP_GREEN,
# CP_RED and CP_BG, then authored here like the bright half — edit any line and
# re-run `theme <slug>`.
CP_DIFF_ADD_BG="#333201"      # added line — whole-line fill
CP_DIFF_DEL_BG="#3f1407"      # removed line
CP_DIFF_ADD_BG_DIM="#211e01"  # added line, outside the focused hunk
CP_DIFF_DEL_BG_DIM="#270f04"  # removed line, outside it
CP_DIFF_ADD_WORD="#717700"    # the changed words inside an added line
CP_DIFF_DEL_WORD="#932512"    # and inside a removed one

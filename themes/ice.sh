#!/usr/bin/env bash
# Ice — Low chroma, cold whites. Instrumentation, not neon.
#
# 41 slots, same order as themes/cyberpunk-neon.sh. See themes/README.md.
# Derived from the 14 authored colours; edit any line and re-run `theme ice`.

CP_THEME_NAME="Ice"
CP_THEME_SLUG="ice"
CP_THEME_LIGHT=0

# --- surfaces ----------------------------------------------------------------
CP_BG="#05080d"            # primary background
CP_BG_ALT="#0e141d"        # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#0e1926"       # recessed fill — disabled, dividers on panel
CP_BG_SEL="#142537"        # hover
CP_BG_HI="#1f3a55"         # selection, active fill
CP_LINE="#2c3239"          # borders and rules
CP_BLACK="#020406"         # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#000000"          # the surface extreme — black when dark, white when light

# --- text --------------------------------------------------------------------
CP_FG="#c9dcea"            # primary foreground — also ANSI 6
CP_FG_DIM="#6b8199"        # comments, inactive text
CP_WHITE="#f2f7fb"         # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#f2f7fb"     # emphatic foreground — titles, selected text

# --- accents -----------------------------------------------------------------
CP_MAGENTA="#5ec8ff"       # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#4a6fa5"        # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#849dc2"    # purple lifted to where it can carry a glyph
CP_BLUE="#2f5f8f"          # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#d9a066"        # warnings
CP_RED="#ff5c72"           # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#e0d48a"        # highlights. ANSI 3
CP_GREEN="#7fd6b5"         # success, git clean. ANSI 2

# --- ANSI bright half --------------------------------------------------------
CP_BR_BLACK="#2c3239"
CP_BR_RED="#ff93a2"
CP_BR_GREEN="#aae5ce"
CP_BR_YELLOW="#ebe3b1"
CP_BR_BLUE="#5f95cc"
CP_BR_MAGENTA="#95dbff"
CP_BR_CYAN="#dbe8f1"
CP_BR_WHITE="#ffffff"

# --- soft half — syntax only -------------------------------------------------
CP_SOFT_FG="#91a6b5"       # syntax base
CP_SOFT_DIM="#9ca3ab"      # punctuation
CP_SOFT_COMMENT="#6f747c"
CP_SOFT_WHITE="#8da6b9"    # variables, plain identifiers
CP_SOFT_MAGENTA="#7dafca"  # keywords
CP_SOFT_PURPLE="#8ba5bb"   # types
CP_SOFT_GREEN="#8eb8a8"    # strings
CP_SOFT_TEAL="#8fb0ae"     # string escapes
CP_SOFT_ORANGE="#bca38a"   # numbers
CP_SOFT_YELLOW="#bbb58b"   # constants
CP_SOFT_CYAN="#91a6b5"     # functions
CP_SOFT_RED="#ca7d87"      # errors, deletions
CP_SOFT_BLUE="#8ea3b8"     # tags, attributes

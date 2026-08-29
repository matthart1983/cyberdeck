#!/usr/bin/env bash
# Terminal Green — Green phosphor, amber for bold. Closest to the metal.
#
# 41 slots, same order as themes/cyberpunk-neon.sh. See themes/README.md.
# Derived from the 14 authored colours; edit any line and re-run `theme terminal-green`.

CP_THEME_NAME="Terminal Green"
CP_THEME_SLUG="terminal-green"
CP_THEME_LIGHT=0

# --- surfaces ----------------------------------------------------------------
CP_BG="#020a05"            # primary background
CP_BG_ALT="#0a1a10"        # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#0b2013"       # recessed fill — disabled, dividers on panel
CP_BG_SEL="#112f1c"        # hover
CP_BG_HI="#1c4a2c"         # selection, active fill
CP_LINE="#10351c"          # borders and rules
CP_BLACK="#010603"         # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#000000"          # the surface extreme — black when dark, white when light

# --- text --------------------------------------------------------------------
CP_FG="#4ae07a"            # primary foreground — also ANSI 6
CP_FG_DIM="#2a8f4f"        # comments, inactive text
CP_WHITE="#dffbe6"         # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#dffbe6"     # emphatic foreground — titles, selected text

# --- accents -----------------------------------------------------------------
CP_MAGENTA="#ffbf00"       # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#1e6b42"        # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#669a7e"    # purple lifted to where it can carry a glyph
CP_BLUE="#1c5f52"          # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#ff9d2b"        # warnings
CP_RED="#ff4a4a"           # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#e8e34a"        # highlights. ANSI 3
CP_GREEN="#33ff77"         # success, git clean. ANSI 2

# --- ANSI bright half --------------------------------------------------------
CP_BR_BLACK="#10351c"
CP_BR_RED="#ff8888"
CP_BR_GREEN="#78ffa5"
CP_BR_YELLOW="#f1ed86"
CP_BR_BLUE="#39c6ab"
CP_BR_MAGENTA="#ffd557"
CP_BR_CYAN="#87eca7"
CP_BR_WHITE="#ffffff"

# --- soft half — syntax only -------------------------------------------------
CP_SOFT_FG="#86c099"       # syntax base
CP_SOFT_DIM="#8dba9d"      # punctuation
CP_SOFT_COMMENT="#63856f"
CP_SOFT_WHITE="#83c393"    # variables, plain identifiers
CP_SOFT_MAGENTA="#cab67d"  # keywords
CP_SOFT_PURPLE="#a2b995"   # types
CP_SOFT_GREEN="#7dca96"    # strings
CP_SOFT_TEAL="#81c697"     # string escapes
CP_SOFT_ORANGE="#caa67d"   # numbers
CP_SOFT_YELLOW="#c3c183"   # constants
CP_SOFT_CYAN="#86c099"     # functions
CP_SOFT_RED="#ca7d7d"      # errors, deletions
CP_SOFT_BLUE="#8dbab1"     # tags, attributes

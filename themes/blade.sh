#!/usr/bin/env bash
# Blade — Desaturated teal, rust accent. Built for eight-hour days.
#
# 41 slots, same order as themes/cyberpunk-neon.sh. See themes/README.md.
# Derived from the 14 authored colours; edit any line and re-run `theme blade`.

CP_THEME_NAME="Blade"
CP_THEME_SLUG="blade"
CP_THEME_LIGHT=0

# --- surfaces ----------------------------------------------------------------
CP_BG="#0a0d0d"            # primary background
CP_BG_ALT="#141a1a"        # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#151d1d"       # recessed fill — disabled, dividers on panel
CP_BG_SEL="#1d2727"        # hover
CP_BG_HI="#2a3a3a"         # selection, active fill
CP_LINE="#2a3231"          # borders and rules
CP_BLACK="#050707"         # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#000000"          # the surface extreme — black when dark, white when light

# --- text --------------------------------------------------------------------
CP_FG="#a8c4c0"            # primary foreground — also ANSI 6
CP_FG_DIM="#647975"        # comments, inactive text
CP_WHITE="#e8efec"         # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#e8efec"     # emphatic foreground — titles, selected text

# --- accents -----------------------------------------------------------------
CP_MAGENTA="#c96a3f"       # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#7a4a3a"        # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#a58479"    # purple lifted to where it can carry a glyph
CP_BLUE="#3a5a63"          # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#d98a4a"        # warnings
CP_RED="#d94f3d"           # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#d4b872"        # highlights. ANSI 3
CP_GREEN="#7fae8a"         # success, git clean. ANSI 2

# --- ANSI bright half --------------------------------------------------------
CP_BR_BLACK="#2a3231"
CP_BR_RED="#e78a7e"
CP_BR_GREEN="#aacab2"
CP_BR_YELLOW="#e3d0a1"
CP_BR_BLUE="#6b9caa"
CP_BR_MAGENTA="#dc9c7f"
CP_BR_CYAN="#c5d8d6"
CP_BR_WHITE="#ffffff"

# --- soft half — syntax only -------------------------------------------------
CP_SOFT_FG="#9baba9"       # syntax base
CP_SOFT_DIM="#9fa7a6"      # punctuation
CP_SOFT_COMMENT="#727978"
CP_SOFT_WHITE="#9caba4"    # variables, plain identifiers
CP_SOFT_MAGENTA="#ba9a8c"  # keywords
CP_SOFT_PURPLE="#b59b92"   # types
CP_SOFT_GREEN="#9aac9e"    # strings
CP_SOFT_TEAL="#9aaca3"     # string escapes
CP_SOFT_ORANGE="#bea088"   # numbers
CP_SOFT_YELLOW="#b9ad8d"   # constants
CP_SOFT_CYAN="#9baba9"     # functions
CP_SOFT_RED="#bf8e87"      # errors, deletions
CP_SOFT_BLUE="#98a9ae"     # tags, attributes

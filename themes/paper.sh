#!/usr/bin/env bash
# Paper — Warm off-white, ink foreground.
#
# 41 slots, same order as themes/cyberpunk-neon.sh. See themes/README.md.
# Derived from the 14 authored colours; edit any line and re-run `theme paper`.

CP_THEME_NAME="Paper"
CP_THEME_SLUG="paper"
CP_THEME_LIGHT=1

# --- surfaces ----------------------------------------------------------------
CP_BG="#f7f3ea"            # primary background
CP_BG_ALT="#ebe4d5"        # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#ebe4d6"       # recessed fill — disabled, dividers on panel
CP_BG_SEL="#e3dac8"        # hover
CP_BG_HI="#d5c8b0"         # selection, active fill
CP_LINE="#d0ccc4"          # borders and rules
CP_BLACK="#35312a"         # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#ffffff"          # the surface extreme — black when dark, white when light

# --- text --------------------------------------------------------------------
CP_FG="#33302a"            # primary foreground — also ANSI 6
CP_FG_DIM="#7a7368"        # comments, inactive text
CP_WHITE="#e8e0d0"         # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#17150f"     # emphatic foreground — titles, selected text

# --- accents -----------------------------------------------------------------
CP_MAGENTA="#a3197a"       # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#5f3d8a"        # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#51396b"    # purple lifted to where it can carry a glyph
CP_BLUE="#1f5c8f"          # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#a85800"        # warnings
CP_RED="#bb1a30"           # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#7d6200"        # highlights. ANSI 3
CP_GREEN="#1c7448"         # success, git clean. ANSI 2

# --- ANSI bright half --------------------------------------------------------
CP_BR_BLACK="#544f46"
CP_BR_RED="#590c16"
CP_BR_GREEN="#061a10"
CP_BR_YELLOW="#0d0a00"
CP_BR_BLUE="#0b2133"
CP_BR_MAGENTA="#420a31"
CP_BR_CYAN="#000000"
CP_BR_WHITE="#ffffff"

# --- soft half — syntax only -------------------------------------------------
CP_SOFT_FG="#5a5853"       # syntax base
CP_SOFT_DIM="#5a5754"      # punctuation
CP_SOFT_COMMENT="#898681"
CP_SOFT_WHITE="#645b49"    # variables, plain identifiers
CP_SOFT_MAGENTA="#733a62"  # keywords
CP_SOFT_PURPLE="#604365"   # types
CP_SOFT_GREEN="#3f6f57"    # strings
CP_SOFT_TEAL="#4b6555"     # string escapes
CP_SOFT_ORANGE="#7b5832"   # numbers
CP_SOFT_YELLOW="#7b6b32"   # constants
CP_SOFT_CYAN="#5a5853"     # functions
CP_SOFT_RED="#743941"      # errors, deletions
CP_SOFT_BLUE="#3e5970"     # tags, attributes

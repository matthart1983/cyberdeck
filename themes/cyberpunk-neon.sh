#!/usr/bin/env bash
# Cyberpunk Neon — the rice as shipped. Cyan on navy, magenta accent.
#
# 41 slots in five families. Every theme in this directory fills all 40, in
# this order, with a literal #rrggbb. Nothing here is computed: a palette is
# data you can read, and a theme author picking bright red by eye will beat a
# formula that lightens it by 35% every time.
#
# See themes/README.md for what each family is for and which slots may never
# be used as text.

CP_THEME_NAME="Cyberpunk Neon"
CP_THEME_SLUG="cyberpunk-neon"
CP_THEME_LIGHT=0

# --- surfaces --------------------------------------------------------------
CP_BG="#000b1e"          # primary background
CP_BG_ALT="#091833"      # raised panel — bar, popups, inactive splits
CP_BG_SUNK="#122043"     # recessed fill — disabled, dividers on panel
CP_BG_SEL="#13284f"      # hover
CP_BG_HI="#133e7c"       # selection, active fill
CP_LINE="#1c2541"        # borders and rules
CP_BLACK="#040713"       # ANSI 0 — the dark end of the ramp, in every theme
CP_VOID="#000000"        # the surface extreme — black when dark, white when light

# --- text ------------------------------------------------------------------
CP_FG="#0abdc6"          # primary foreground — also ANSI 6
CP_FG_DIM="#0f7d84"      # comments, inactive text
CP_WHITE="#d7d7d7"       # ANSI 7 — the light end of the ramp, in every theme
CP_FG_STRONG="#d7d7d7"   # emphatic foreground — titles, selected text

# --- accents ---------------------------------------------------------------
CP_MAGENTA="#ea00d9"     # accent 1 — focus, prompt. ANSI 5
CP_PURPLE="#711c91"      # accent 2 — inactive borders. NOT a text colour
CP_PURPLE_MID="#a03fb0"  # purple lifted to where it can carry a glyph
CP_BLUE="#133e7c"        # accent 3 — fills. NOT a text colour. ANSI 4
CP_ORANGE="#f57800"      # warnings
CP_RED="#ff0055"         # errors, exit codes, packet loss. ANSI 1
CP_YELLOW="#f3e600"      # highlights. ANSI 3
CP_GREEN="#00ff9f"       # success, git clean. ANSI 2

# --- ANSI bright half ------------------------------------------------------
# The terminal's colours 8-15. Every terminal-adjacent surface needs these and
# no amount of lightening the normal half reproduces a set someone chose.
CP_BR_BLACK="#1c2541"
CP_BR_RED="#ff4d7e"
CP_BR_GREEN="#5cffc4"
CP_BR_YELLOW="#fff45c"
CP_BR_BLUE="#2d6bd4"
CP_BR_MAGENTA="#ff4de0"
CP_BR_CYAN="#4dd9e0"
CP_BR_WHITE="#ffffff"

# --- soft half -------------------------------------------------------------
# Syntax highlighting only. Chrome is glanced at; code is read for hours, and
# full-saturation magenta on black is exhausting at that duration.
CP_SOFT_FG="#7fb8bd"     # syntax base
CP_SOFT_DIM="#5a7b80"    # punctuation
CP_SOFT_COMMENT="#4a6b70"
CP_SOFT_WHITE="#b6c2c4"  # variables, plain identifiers
CP_SOFT_MAGENTA="#c46bbd" # keywords
CP_SOFT_PURPLE="#d17fc9" # types
CP_SOFT_GREEN="#6bc9a0"  # strings
CP_SOFT_TEAL="#7fc9b0"   # string escapes
CP_SOFT_ORANGE="#c98a4b" # numbers
CP_SOFT_YELLOW="#cfc06a" # constants
CP_SOFT_CYAN="#5fa8b0"   # functions
CP_SOFT_RED="#b0708f"    # errors, deletions
CP_SOFT_BLUE="#8fb7d9"   # tags, attributes

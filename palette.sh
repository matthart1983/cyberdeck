#!/usr/bin/env bash
# Cyberpunk Neon — single source of truth for every themed surface in this rice.
# Sourced by generators; mirrored by hand into configs that can't read shell vars.

CP_BG="#000b1e"        # near-black navy   — primary background
CP_BG_ALT="#091833"    # raised panel      — bar, popups, inactive splits
CP_BG_HI="#133e7c"     # blue              — selection, active fill
CP_FG="#0abdc6"        # cyan              — primary foreground
CP_FG_DIM="#0f7d84"    # dim cyan          — comments, inactive text
CP_MAGENTA="#ea00d9"   # magenta           — accent 1, active window, prompt
CP_PURPLE="#711c91"    # purple            — accent 2, borders inactive
CP_BLUE="#133e7c"      # blue              — accent 3
CP_ORANGE="#f57800"    # orange            — warnings
CP_RED="#ff0055"       # hot red           — errors, exit codes
CP_YELLOW="#f3e600"    # acid yellow       — highlights
CP_GREEN="#00ff9f"     # neon green        — success, git clean
CP_WHITE="#d7d7d7"     # near-white        — bright fg
CP_BLACK="#040713"     # deepest           — true black surfaces

# Desaturated variant — used for Zed syntax only, where 8h/day readability wins.
CP_SOFT_FG="#7fb8bd"
CP_SOFT_MAGENTA="#c46bbd"
CP_SOFT_GREEN="#6bc9a0"
CP_SOFT_ORANGE="#c98a4b"

# ---------------------------------------------------------------------------
# Cyberpunk rice — shell layer
# Sourced from ~/.zshrc AFTER powerlevel10k, so the p10k overrides below win.
# ---------------------------------------------------------------------------

# --- Palette (mirrors ~/.dotfiles/palette.sh) ------------------------------
CP_BG="#000b1e";      CP_BG_ALT="#091833";  CP_FG="#0abdc6"
CP_FG_DIM="#0f7d84";  CP_MAGENTA="#ea00d9"; CP_PURPLE="#711c91"
CP_BLUE="#133e7c";    CP_ORANGE="#f57800";  CP_RED="#ff0055"
CP_YELLOW="#f3e600";  CP_GREEN="#00ff9f";   CP_WHITE="#d7d7d7"

# --- powerlevel10k: re-skin the existing "pure" config ---------------------
# Colours only — segment layout stays exactly as it was configured.
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$CP_PURPLE
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=$CP_PURPLE
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$CP_RED
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$CP_FG
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$CP_WHITE
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$CP_GREEN
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$CP_YELLOW
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$CP_MAGENTA
typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=$CP_RED
typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$CP_FG_DIM

typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$CP_ORANGE
typeset -g POWERLEVEL9K_TIME_FOREGROUND=$CP_FG_DIM
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$CP_PURPLE

# Prompt char: magenta when the last command passed, hot red when it failed.
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$CP_MAGENTA
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$CP_RED

# --- eza: ls replacement ---------------------------------------------------
export EZA_COLORS="di=38;2;10;189;198:ln=38;2;234;0;217:ex=38;2;0;255;159:\
fi=38;2;215;215;215:ur=38;2;10;189;198:uw=38;2;234;0;217:ux=38;2;0;255;159:\
sn=38;2;113;28;145:sb=38;2;113;28;145:da=38;2;15;125;132:gm=38;2;243;230;0"
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -l --git --time-style=long-iso'
alias la='eza --icons --group-directories-first -la --git --time-style=long-iso'
alias lt='eza --icons --tree --level=2 --group-directories-first'

# --- bat: cat replacement --------------------------------------------------
export BAT_THEME="cyberpunk-neon"
export BAT_STYLE="numbers,changes,header"
alias cat='bat --paging=never'
alias less='bat'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# --- fzf -------------------------------------------------------------------
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
  --height 60% --layout=reverse --border=rounded --info=inline
  --prompt='❯ ' --pointer='▶' --marker='◆'
  --color=bg+:$CP_BG_ALT,bg:$CP_BG,spinner:$CP_MAGENTA,hl:$CP_RED
  --color=fg:$CP_FG,header:$CP_PURPLE,info:$CP_MAGENTA,pointer:$CP_MAGENTA
  --color=marker:$CP_GREEN,fg+:$CP_WHITE,prompt:$CP_MAGENTA,hl+:$CP_RED
  --color=border:$CP_PURPLE,gutter:$CP_BG
"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons --tree --level=2 --color=always {}'"
source <(fzf --zsh) 2>/dev/null

# --- zoxide ----------------------------------------------------------------
eval "$(zoxide init zsh --cmd cd)"

# --- atuin: fuzzy shell history (ctrl-r only; up-arrow left alone) ---------
eval "$(atuin init zsh --disable-up-arrow)"

# --- git: delta pager ------------------------------------------------------
alias lg='git log --oneline --graph --decorate --all'

# --- the rice's own tools --------------------------------------------------
alias fetch='fastfetch'
alias top='btop'

# --- autosuggestions (dim cyan) -------------------------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#0f7d84"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# --- syntax highlighting: must be sourced LAST ----------------------------
source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

# --- rice scripts on PATH --------------------------------------------------
export PATH="$HOME/.dotfiles/bin:$PATH"

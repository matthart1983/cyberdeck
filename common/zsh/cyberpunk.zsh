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

# --- Platform shims --------------------------------------------------------
# The clipboard is the one thing with no portable name. Everything else in this
# file is identical on both platforms.
if [[ $OSTYPE != darwin* ]]; then
  if command -v wl-copy >/dev/null; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif command -v xclip >/dev/null; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
  fi
fi

# --- autosuggestions (dim cyan) -------------------------------------------
# Sourced from wherever the platform's package manager put it: Homebrew keeps
# these under /opt/homebrew, Fedora under /usr/share. First hit wins.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#0f7d84"
for _cp_p in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -r $_cp_p ]] && { source "$_cp_p"; break; }
done

# --- syntax highlighting: must be sourced LAST ----------------------------
# Prefer fast-syntax-highlighting where it exists; Fedora only packages the
# original zsh-syntax-highlighting, which is the same idea at half the speed.
for _cp_p in \
  /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  /usr/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -r $_cp_p ]] && { source "$_cp_p"; break; }
done
unset _cp_p

# --- PATH -------------------------------------------------------------------
# Three dirs, each here for a reason — none of them is incidental:
#   ~/.cargo/bin        the HUD's panes (netwatch, syswatch, diskwatch) are
#                       cargo installs, and cargo does not put its bin dir on
#                       PATH for you. Fedora's packaged cargo writes no
#                       ~/.cargo/env either — only rustup does.
#   ~/.local/bin        where the Claude Code installer puts `claude`, as a
#                       symlink into ~/.local/share/claude/versions/.
#   ~/.dotfiles/common/bin  the rice's own executables: hud, rice-doctor,
#                       rice-capture, cc-statusline, tmux-battery.
# Guarded so re-sourcing this file doesn't stack duplicates.
for _cp_d in "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.dotfiles/common/bin"; do
  [[ -d $_cp_d ]] && [[ ":$PATH:" != *":$_cp_d:"* ]] && export PATH="$_cp_d:$PATH"
done
unset _cp_d

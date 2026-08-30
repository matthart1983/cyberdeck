# The rice's PATH, in one place.
#
#   . "$HOME/.dotfiles/common/lib-path.sh"
#
# Three dirs, each here for a reason — none of them is incidental:
#   ~/.cargo/bin        the HUD's panes (netwatch, syswatch, diskwatch) are
#                       cargo installs, and cargo does not put its bin dir on
#                       PATH for you. Fedora's packaged cargo writes no
#                       ~/.cargo/env either — only rustup does.
#   ~/.local/bin        where the Claude Code installer puts `claude`, and
#                       where linux/ghostty.sh installs Ghostty.
#   ~/.dotfiles/common/bin  the rice's own executables: hud, rice-doctor,
#                       rice-capture, cc-statusline, tmux-battery.
#
# Sourced by the shell (common/zsh/cyberpunk.zsh), and — this is the part that
# is easy to get wrong — by the executables the COMPOSITOR spawns. niri runs
# under `systemd --user`, whose PATH is /usr/local/bin:/usr/bin, so waybar,
# ghostty and everything they launch inherit an environment in which this rice
# looks like it is not installed. linux/systemd/environment.d/cyberdeck.conf
# fixes that for the session as a whole; this fixes it per-process, for the
# scripts that cannot afford to wait for the next login.
#
# Prepended, and guarded, so re-sourcing never stacks duplicates.
for _cp_d in "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.dotfiles/common/bin"; do
  if [ -d "$_cp_d" ]; then
    case ":$PATH:" in
      *":$_cp_d:"*) ;;
      *) PATH="$_cp_d:$PATH" ;;
    esac
  fi
done
unset _cp_d
export PATH

Output out/tour.gif
Source theme.tape
Set Width 1800
Set Height 1150
Set FontSize 13
Set Padding 12

# The whole rice in one pass: identity, the netwatch feed behind the bar,
# the palette everything derives from, then the HUD.
# VHS points ZDOTDIR at its own temp rc, so re-exec into a real shell first.
Hide
Type "exec env ZDOTDIR=$HOME zsh -i" Enter
Sleep 3s
Type "cd ~/.dotfiles" Enter
# Build the HUD now and leave it running through the tour, so the finale
# attaches to a grid that already has data instead of four cold panes. Piping
# to cat makes stdout not a tty, which is how `hud` knows to build and exit
# rather than attach.
# `command hud` rather than `hud`: zsh-autosuggestions completes from history
# by prefix, so a warm-up starting with "hud" gets suggested in grey the moment
# the finale types `hud` — visible junk on the one frame that matters.
Type "command hud -r | cat >/dev/null" Enter
Sleep 4s
Type "clear" Enter
Sleep 2s
Show

Sleep 800ms
Type "fetch"
Sleep 500ms
Enter
Sleep 5s

Type "clear" Enter
Sleep 400ms

# Where the bar's network items actually come from.
Type "curl -s 127.0.0.1:9464/metrics | grep -E 'gateway_rtt|dns_rtt|loss_ratio|^netwatch_connections'"
Sleep 600ms
Enter
Sleep 5s

Type "clear" Enter
Sleep 400ms
Type "bat --paging=never --style=numbers palette.sh"
Sleep 500ms
Enter
Sleep 5s

Type "clear" Enter
Sleep 400ms
# Attaches to the grid built before the tour began — no -r, nothing to rebuild.
Type "hud"
Sleep 600ms
Enter
Sleep 13s

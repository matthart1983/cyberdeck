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
Type "cd ~/.dotfiles && clear" Enter
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
Type "hud -r"
Sleep 600ms
Enter
Sleep 14s

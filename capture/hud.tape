Output out/hud.gif
Source theme.tape
Set Width 2000
Set Height 1240
Set FontSize 12
Set Padding 10

# Each of the four tools needs 80x24, so the canvas must clear 160x50 cells.
#
# The grid is built and left to run for half a minute *before* recording
# starts. netwatch and diskwatch draw rolling windows and soundwatch needs
# signal, so a cold start is ten seconds of empty panes filling in one at a
# time — which is most of a short capture, and looks broken rather than busy.
Hide
Type "exec env ZDOTDIR=$HOME zsh -i" Enter
Sleep 3s
Type "clear" Enter
Sleep 1s
Type "hud -r"
Enter
Sleep 35s
Show

Sleep 12s

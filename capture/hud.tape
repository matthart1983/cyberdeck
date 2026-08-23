Output out/hud.gif
Source theme.tape
Set Width 2000
Set Height 1240
Set FontSize 12
Set Padding 10

# Each of the four tools needs 80x24, so the canvas must clear 160x50 cells.
Hide
Type "exec env ZDOTDIR=$HOME zsh -i" Enter
Sleep 3s
Type "clear" Enter
Sleep 1s
Show

Sleep 800ms
Type "hud -r"
Sleep 600ms
Enter
Sleep 12s

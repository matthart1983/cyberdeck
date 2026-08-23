Output out/shell.gif
Source theme.tape
Set Width 1500
Set Height 620

Hide
Type "exec env ZDOTDIR=$HOME zsh -i" Enter
Sleep 3s
Type "cd ~/.dotfiles && clear" Enter
Sleep 2s
Show

Sleep 700ms
Type "ll"
Sleep 400ms
Enter
Sleep 3s

Type "clear" Enter
Sleep 300ms
Type "bat --paging=never palette.sh"
Sleep 400ms
Enter
Sleep 4s

Type "clear" Enter
Sleep 300ms
Type "git log --oneline -5"
Sleep 400ms
Enter
Sleep 3s

Type "clear" Enter
Sleep 300ms
Type "lt bin"
Sleep 400ms
Enter
Sleep 3s

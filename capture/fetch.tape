Output out/fetch.gif
Source theme.tape
Set Width 1500
Set Height 900

# VHS points ZDOTDIR at its own temp rc, so ~/.zshrc never loads and none of
# the rice exists. Re-exec into a real interactive shell before recording.
Hide
Type "exec env ZDOTDIR=$HOME zsh -i" Enter
Sleep 3s
Type "cd ~/.dotfiles && clear" Enter
Sleep 2s
Show

Sleep 800ms
Type "fetch"
Sleep 600ms
Enter
Sleep 6s

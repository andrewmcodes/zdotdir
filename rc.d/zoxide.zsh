(($+commands[zoxide])) || return 1
#? Cached: `zoxide init zsh` output is invariant of PATH/PWD (verified).
cached-eval zoxide init zsh

(($+commands[starship])) || return 1
#? Cached: `starship init zsh` output is invariant of PATH/PWD (verified), and
#? cached-eval rebuilds it when the binary changes or the TTL lapses.
#* This only saves the init fork. The per-PROMPT cost is starship's own config —
#* see ~/.config/starship.toml (command_timeout) and git's core.untrackedCache.
cached-eval starship init zsh

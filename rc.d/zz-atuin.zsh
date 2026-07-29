#? Atuin: SQLite-backed shell history; owns Ctrl-R and the Up arrow.
#* Named zz- so it sources AFTER fzf.zsh — otherwise fzf's history widget clobbers atuin's ^R.
(($+commands[atuin])) || return 1
#? Cached: `atuin init zsh` output is invariant of PATH/PWD (verified).
cached-eval atuin init zsh

#? Atuin: SQLite-backed shell history; owns Ctrl-R and the Up arrow.
#* Named zz- so it sources AFTER fzf.zsh — otherwise fzf's history widget clobbers atuin's ^R.
(($+commands[atuin])) || return 1
eval "$(atuin init zsh)"

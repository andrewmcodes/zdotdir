(($+commands[fzf])) || return 1
#* 2>/dev/null: fzf's completion and key-bindings scripts each snapshot the
#* shell's options and restore them via `eval`. Under `zsh -i -c` the snapshot
#* includes `zle`, which cannot be re-enabled, so each script prints
#* "can't change option: zle" — two warnings in every bench-startup /
#* zsh-bench measurement. A `[[ -o zle ]]` guard does NOT help: zle reads as
#* set under `zsh -i -c` even though it can't be restored.
source <(fzf --zsh) 2>/dev/null

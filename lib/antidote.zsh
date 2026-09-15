#!/bin/zsh
#
# lib/antidote.zsh - Load plugins from a static, byte-compiled antidote bundle.
#
#* Source the antidote lib (cheap, and it keeps the `antidote` command available
#* for `antidote list`/`update`/`install`), then source the generated static
#* plugin file DIRECTLY — skipping `antidote load`'s per-startup freshness
#* machinery (~27ms). The bundle is regenerated only when .zsh_plugins.txt is
#* newer than .zsh_plugins.zsh.
#

#* Quoted, with a fallback and a readability guard: HOMEBREW_PREFIX is only
#* exported inside .zprofile's `darwin*` branch, so the bare `${HOMEBREW_PREFIX}`
#* form resolved to /opt/antidote/... on anything that isn't macOS.
antidote_lib="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
[[ ! -r "$antidote_lib" ]] || source "$antidote_lib"
unset antidote_lib

zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
#? `antidote` is a function from the lib above, not a binary — hence $+functions.
if (($+functions[antidote])) && [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  #* Bundle to a temp file and install it only on success. Writing straight to
  #* ${zsh_plugins}.zsh truncates it up front, so a `bundle` that dies mid-run
  #* (^C on a slow first-run clone, full disk) leaves a partial loader that is
  #* now NEWER than the .txt — the -nt test above never fires again and every
  #* later shell silently starts with no plugins at all.
  if antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh.tmp; then
    mv -f -- ${zsh_plugins}.zsh.tmp ${zsh_plugins}.zsh
  else
    rm -f -- ${zsh_plugins}.zsh.tmp
  fi
fi
[[ ! -r ${zsh_plugins}.zsh ]] || source ${zsh_plugins}.zsh
unset zsh_plugins

#* The generated loader does `export PATH="...zsh-bench:$PATH"`, and `typeset -gU
#* path` does NOT dedupe a scalar PATH= assignment — so zsh-bench accumulated a
#* second entry in nested shells. Reassigning the array re-applies uniqueness.
path=($path)

#!/bin/zsh
#
# .zprofile - $path, $cdpath, and every exported variable.
#
#* Login shells source this themselves, after .zshenv and before .zshrc. Every
#* other zsh — scripts, `zsh -c`, subshells, editors' integrated terminals — gets
#* it because .zshenv sources it when the shell is not a login shell. So treat
#* this as "runs for every zsh, exactly once": keep it free of subprocesses, and
#* make everything in it idempotent (a nested shell re-reads it).
#*
#* No secrets here. There is deliberately no FNOX_AGE_KEY: fnox's age provider
#* already defaults its identity to $XDG_CONFIG_HOME/fnox/age.txt, so exporting
#* the raw key into every process bought nothing. Move it with the provider's
#* `key_file` field instead.
#

#* -U keeps these free of duplicates, which is what makes re-sourcing safe.
typeset -gUa path fpath prepath cdpath

#
# Platform
#
if [[ "$OSTYPE" == darwin* ]]; then
  #* Hardcoded instead of `$(brew --prefix)` — stable on Apple Silicon, saves a fork in every shell.
  export HOMEBREW_PREFIX=/opt/homebrew
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$HOMEBREW_PREFIX/opt/openssl"
  export SHELL_SESSIONS_DISABLE=1
  export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

#
# Path
#
#* $prepath is the set of directories that must win against anything a tool or
#* plugin later prepends. mise's shims go in front of these at conf.d/00-mise.zsh.
prepath=(
  /opt/{homebrew,local}/{,s}bin(N)
  $HOME/{,s}bin(N)
  $HOME/.local/{,s}bin(N)
  /usr/local/{,s}bin(N)
)
path=($prepath $path)

#? OrbStack's own init file, kept as a `source` so OrbStack's updater can rewrite
#? it. It is two lines (a PATH append and an fpath append) and forks nothing.
[[ ! -r $HOME/.orbstack/shell/init.zsh ]] || source $HOME/.orbstack/shell/init.zsh

#? Obsidian ships its CLI inside the .app bundle.
path+=(/Applications/Obsidian.app/Contents/MacOS(N))

#* Hardcoded opt paths instead of `$(brew --prefix <formula>)` — avoids 3 brew
#* forks per startup. Same fallback as elsewhere: HOMEBREW_PREFIX is only set in
#* the `darwin*` branch above, so a bare ${HOMEBREW_PREFIX} would export
#* `/bin/pkg-config:/opt/icu4c/lib/pkgconfig:…` on anything that isn't macOS.
export PKG_CONFIG_PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/bin/pkg-config:${HOMEBREW_PREFIX:-/opt/homebrew}/opt/icu4c/lib/pkgconfig:${HOMEBREW_PREFIX:-/opt/homebrew}/opt/curl/lib/pkgconfig:${HOMEBREW_PREFIX:-/opt/homebrew}/opt/zlib/lib/pkgconfig"

#
# Editors and pagers
#
export VISUAL="code-insiders --wait"
export EDITOR="nvim"
export MANPAGER="less -X"
export DELTA_PAGER="less -FR"

#
# Ruby
#
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle/config"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"
export DISABLE_SPRING=true
export RUBY_DEBUG_HISTORY_FILE="$XDG_DATA_HOME/ruby/debug_history.log"
export RUBY_DEBUG_IRB_CONSOLE=1
[[ -f $HOME/.gemrc.local ]] && export GEMRC=$HOME/.gemrc.local

#
# Node
#
export NODE_OPTIONS="--disable-warning=ExperimentalWarning"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PNPM_HOME="$XDG_CACHE_HOME/pnpm"
export YARN_CACHE_FOLDER="$XDG_CACHE_HOME/yarn"
export YARN_ENABLE_TELEMETRY=0

#
# Other languages and runtimes
#
export GOPATH="$XDG_DATA_HOME/go"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"

#
# Tools
#
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export TLDR_CACHE_DIR="$XDG_CACHE_HOME/tldr"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export HOMEBREW_NO_ANALYTICS=1
export DISABLE_TELEMETRY=1
export OBSIDIAN_VAULT_PATH="$HOME/git/andrewmcodes/digital-brain"
export OBSIDIAN_VAULT_NAME="digital-brain"

#
# zoxide
#
export _ZO_DATA_DIR="$XDG_CACHE_HOME/zoxide"
export _ZO_FZF_OPTS="--no-sort --keep-right --height=50% --info=inline --layout=reverse --exit-0 --select-1 --bind=ctrl-z:ignore --preview='\command eza --long --all {2..}' --preview-window=right"

#
# Plugins
#
#? ZSH_HIGHLIGHT_HIGHLIGHTERS is not set here: it's read by zsh-syntax-highlighting,
#? but this config uses zdharma-continuum/fast-syntax-highlighting, which ignores it.
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4e4e4e"
#* Skip re-binding widgets on every precmd (perf win); don't suggest on large pastes.
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

#
# fzf
#
#* One palette only. This used to assign a Dracula palette here and then append
#* the grey one below, producing FIVE --color= flags; since the grey palette sets
#* every key the Dracula flags set, all four of those were dead weight.
export FZF_DEFAULT_COMMAND="rg --no-messages --files --no-ignore --hidden --follow --glob '!.git/*'"
typeset -a _fzf_colors=(
  fg:#EDEEF0
  bg:#111113
  hl:#696E77
  fg+:#EDEEF0
  bg+:#212225
  hl+:#777B84
  info:#B0B4BA
  prompt:#696E77
  pointer:#696E77
  marker:#777B84
  spinner:#B0B4BA
  header:#B0B4BA
  border:#43484E
  label:#B0B4BA
  query:#EDEEF0
)

typeset -a _fzf_opts=(
  --history="$XDG_DATA_HOME/fzf/history.log"
  --no-separator
  --layout=reverse
  --info=inline
  "--color=${(j:,:)_fzf_colors}"
)

#? Merge with any options inherited from the environment, preserving order.
#* This file runs for EVERY zsh, so a nested shell — or the `exec zsh` reload this
#* config recommends — re-reads an FZF_DEFAULT_OPTS that already contains our
#* words and would otherwise append a second copy, growing the exported variable
#* by ~315 bytes per generation. Hence appending only the words not already there.
#* Deliberately NOT `typeset -aU`: uniquifying the whole array also collapses a
#* legitimately REPEATED inherited word, and repeating a flag is normal in fzf.
#* An inherited `--bind a:x --bind b:y` became `--bind a:x b:y`, and every later
#* fzf call in that shell died with "unknown option: b:y".
typeset -a _fzf_all=()
if [[ -n "$FZF_DEFAULT_OPTS" ]]; then
  _fzf_all+=(${(z)FZF_DEFAULT_OPTS})
fi
#? (Ie) is an exact-match index lookup: 0 when the word isn't in the array yet.
for _fzf_o in "${_fzf_opts[@]}"; do
  (( ${_fzf_all[(Ie)$_fzf_o]} )) || _fzf_all+=("$_fzf_o")
done

export FZF_DEFAULT_OPTS="${(j: :)_fzf_all}"
unset _fzf_colors _fzf_opts _fzf_all _fzf_o

#* Keep `true` last: the final statement above is a `for` loop over a possibly
#* empty array, and a login shell that ends .zprofile non-zero shows an error
#* status on its very first prompt.
true

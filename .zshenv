
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

if [[ "$OSTYPE" == darwin* ]]; then
  #* Hardcoded instead of `$(brew --prefix)` — stable on Apple Silicon, saves a fork in every shell.
  export HOMEBREW_PREFIX=/opt/homebrew
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$HOMEBREW_PREFIX/opt/openssl"
  export SHELL_SESSIONS_DISABLE=1
  export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# Ruby
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle/config"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"
export DISABLE_SPRING=true
export RUBY_DEBUG_HISTORY_FILE="$XDG_DATA_HOME/ruby/debug_history.log"
export RUBY_DEBUG_IRB_CONSOLE=1
[[ -f $HOME/.gemrc.local ]] && export GEMRC=$HOME/.gemrc.local
# GNUPG
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
# Go Lang
export GOPATH="$XDG_DATA_HOME/go"
# Node
export NODE_OPTIONS="--disable-warning=ExperimentalWarning"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PNPM_HOME="$XDG_CACHE_HOME/pnpm"
export YARN_CACHE_FOLDER="$XDG_CACHE_HOME/yarn"
export YARN_ENABLE_TELEMETRY=0
# PostgreSQL
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"
# Rust
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
# CLI Tools
export TLDR_CACHE_DIR="$XDG_CACHE_HOME/tldr"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export HOMEBREW_NO_ANALYTICS=1
export DISABLE_TELEMETRY=1
# Shell
export VISUAL="code-insiders --wait"
export EDITOR="nvim"
export MANPAGER="less -X"
# FZF
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
typeset -a _fzf_all=()
if [[ -n "$FZF_DEFAULT_OPTS" ]]; then
  _fzf_all+=(${(z)FZF_DEFAULT_OPTS})
fi
_fzf_all+=("${_fzf_opts[@]}")

export FZF_DEFAULT_OPTS="${(j: :)_fzf_all}"
unset _fzf_colors _fzf_opts _fzf_all
# Zoxide
export _ZO_DATA_DIR="$XDG_CACHE_HOME/zoxide"
export _ZO_FZF_OPTS="--no-sort --keep-right --height=50% --info=inline --layout=reverse --exit-0 --select-1 --bind=ctrl-z:ignore --preview='\command eza --long --all {2..}' --preview-window=right"

# Plugins
#? ZSH_HIGHLIGHT_HIGHLIGHTERS is not set here: it's read by zsh-syntax-highlighting,
#? but this config uses zdharma-continuum/fast-syntax-highlighting, which ignores it.
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4e4e4e"
#* Skip re-binding widgets on every precmd (perf win); don't suggest on large pastes.
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
# FNOX
#* Deliberately no FNOX_AGE_KEY here. fnox's age provider already defaults its
#* identity to <config dir>/age.txt — i.e. $XDG_CONFIG_HOME/fnox/age.txt, where
#* the key already lives — so exporting the raw age secret into every shell and
#* every child process bought nothing. Verified: with FNOX_AGE_KEY unset, `fnox
#* get` succeeds in all four repos that carry a fnox.toml, none of which
#* override `key_file`. Don't re-add it; use the age provider's `key_file` field
#* if the path ever needs to move (FNOX_AGE_KEY_FILE/age_key_file are the same
#* option and fnox marks it deprecated).
# Obsidian
export OBSIDIAN_VAULT_PATH="$HOME/git/andrewmcodes/digital-brain"
export OBSIDIAN_VAULT_NAME="digital-brain"

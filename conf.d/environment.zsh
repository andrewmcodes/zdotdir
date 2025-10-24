#
# Environment variables
#

# History
export HISTFILE="$XDG_DATA_HOME/zsh/history"

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
export NPM_CONFIG_TMP="${XDG_RUNTIME_DIR:-/tmp}/npm"
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
export MANPAGER="less -X"

# FZF
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
  --inline-info
  "--color=${(j:,:)_fzf_colors}"
)

# Merge with any existing options, preserving order
typeset -a _fzf_all=()
if [[ -n "$FZF_DEFAULT_OPTS" ]]; then
  _fzf_all+=(${(z)FZF_DEFAULT_OPTS})
fi
_fzf_all+=("${_fzf_opts[@]}")

export FZF_DEFAULT_OPTS="${(j: :)_fzf_all}"

# Zoxide
export _ZO_DATA_DIR="$XDG_CACHE_HOME/zoxide"
export _ZO_FZF_OPTS="--no-sort --keep-right --height=50% --info=inline --layout=reverse --exit-0 --select-1 --bind=ctrl-z:ignore --preview='\command eza --long --all {2..}' --preview-window=right"

# Plugins
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor root line)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4e4e4e"

# PKG_CONFIG_PATH
export PKG_CONFIG_PATH="/opt/homebrew/bin/pkg-config:$(brew --prefix icu4c)/lib/pkgconfig:$(brew --prefix curl)/lib/pkgconfig:$(brew --prefix zlib)/lib/pkgconfig"

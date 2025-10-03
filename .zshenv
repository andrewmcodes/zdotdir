
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

if which brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX=$(brew --prefix)
  export HOMEBREW_PREFIX
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$HOMEBREW_PREFIX/opt/openssl@1.1"
fi

if [[ "$OSTYPE" == darwin* ]]; then
  export SHELL_SESSIONS_DISABLE=1
fi

# History
export HISTFILE="$XDG_DATA_HOME/zsh/history"
# Ruby
export GEM_HOME="$XDG_DATA_HOME/gem"
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
# Shell
export VISUAL="code-insiders --wait"
export EDITOR="nvim"
export MANPAGER="less -X"
# FZF
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
export FZF_DEFAULT_COMMAND="rg --no-messages --files --no-ignore --hidden --follow --glob '!.git/*'"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --history='$XDG_DATA_HOME/fzf/history.log' \
  --no-separator \
  --layout=reverse \
  --inline-info \
  --color=fg:#edeef0,bg:#111113,hl:#27b08b \
  --color=fg+:#edeef0,bg+:#212225,hl+:#adf0d4 \
  --color=info:#3b9eff,prompt:#7d66d9,pointer:#ffd60a \
  --color=marker:#ec5d5e,spinner:#3b9eff,header:#b0b4ba"

# Zoxide
export _ZO_DATA_DIR="$XDG_CACHE_HOME/zoxide"
export _ZO_FZF_OPTS="--no-sort --keep-right --height=50% --info=inline --layout=reverse --exit-0 --select-1 --bind=ctrl-z:ignore --preview='\command eza --long --all {2..}' --preview-window=right"

# Plugins
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor root line)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4e4e4e"

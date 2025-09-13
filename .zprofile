#!/bin/zsh
#
# This file is the entry point for your Zsh configuration. It's the first file
# that is sourced when Zsh starts up, and it's loaded only once.
#

# Homebrew Configuration
if command -v brew &>/dev/null; then
  HOMEBREW_PREFIX=$(brew --prefix)
  export HOMEBREW_PREFIX
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$HOMEBREW_PREFIX/opt/openssl@1.1"
fi

# Ruby Configuration
export DISABLE_SPRING=true
export RUBY_DEBUG_HISTORY_FILE="$XDG_DATA_HOME/ruby/debug_history.log"
export RUBY_DEBUG_IRB_CONSOLE=1
[[ -f $HOME/.gemrc.local ]] && export GEMRC=$HOME/.gemrc.local

# Shell
export VISUAL="code-insiders --wait"
export EDITOR="nvim"
export MANPAGER="less -X"

# FZF
export FZF_DEFAULT_COMMAND="rg --no-messages --files --no-ignore --hidden --follow --glob '!.git/*'"

#             --height 50% \
#             --preview 'bat --color=always --line-range :500 {}' \
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --history='$XDG_DATA_HOME/fzf/history.log' \
  --no-separator \
  --layout=reverse \
  --inline-info \
  --color=fg:#edeef0,bg:#111113,hl:#27b08b \
  --color=fg+:#edeef0,bg+:#212225,hl+:#adf0d4 \
  --color=info:#3b9eff,prompt:#7d66d9,pointer:#ffd60a \
  --color=marker:#ec5d5e,spinner:#3b9eff,header:#b0b4ba"

# zoxide directory preview options
export _ZO_FZF_OPTS="--no-sort --keep-right --height=50% --info=inline --layout=reverse --exit-0 --select-1 --bind=ctrl-z:ignore --preview='\command eza --long --all {2..}' --preview-window=right"

# Plugins
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor root line)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4e4e4e"

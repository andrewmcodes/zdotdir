#!/bin/zsh
#
# .zshenv - Zsh environment file, loaded for EVERY zsh (scripts included).
#
#* Keep this file tiny and fork-free. It exists to establish the XDG base dirs —
#* which everything else is written in terms of — and then hand off to .zprofile,
#* which owns $path and the actual exports.
#

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

#* A login shell sources .zprofile itself, immediately after this file. Every other
#* zsh never would, and would run without $path or any of the tool environment —
#* so source it here instead. The `-o LOGIN` test is what stops a login shell from
#* reading it twice.
if [[ ! -o LOGIN ]] && [[ -s ${ZDOTDIR:-$HOME}/.zprofile ]]; then
  source ${ZDOTDIR:-$HOME}/.zprofile
fi

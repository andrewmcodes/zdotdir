#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#

# Lazy-load (autoload) Zsh function files from a directory.

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Set the list of directories that zsh searches for commands.
path=(
  /opt/{homebrew,local}/{,s}bin(N)
  $HOME/{,s}bin(N)
  $HOME/.local/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

ZFUNCDIR=${ZDOTDIR:-$HOME}/functions
fpath=($ZFUNCDIR $fpath)
autoload -Uz $ZFUNCDIR/*(.:t)

# Set any zstyles you might use for configuration.
[[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

# Create an amazing Zsh config using antidote plugins.
source ${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/antidote/share/antidote/antidote.zsh
antidote load

export PKG_CONFIG_PATH="/opt/homebrew/bin/pkg-config:$(brew --prefix icu4c)/lib/pkgconfig:$(brew --prefix curl)/lib/pkgconfig:$(brew --prefix zlib)/lib/pkgconfig"

# Source anything in rc.d.
for _rc in ${ZDOTDIR:-$HOME}/rc.d/*.zsh; do
  # Ignore tilde files.
  if [[ $_rc:t != '~'* ]]; then
    source "$_rc"
  fi
done
unset _rc

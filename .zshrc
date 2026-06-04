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

# Antidote: source the lib (cheap, keeps the `antidote` command available), then
# source the static plugin file directly — skipping `antidote load`'s per-startup
# freshness machinery (~27ms). Regenerate only when the .conf is newer.
source ${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh
zsh_plugins=${ZDOTDIR:-$HOME}/antidote_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.conf ]]; then
  antidote bundle <${zsh_plugins}.conf >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh
unset zsh_plugins

#* Hardcoded opt paths instead of `$(brew --prefix <formula>)` — avoids 3 brew forks per startup.
export PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/bin/pkg-config:${HOMEBREW_PREFIX}/opt/icu4c/lib/pkgconfig:${HOMEBREW_PREFIX}/opt/curl/lib/pkgconfig:${HOMEBREW_PREFIX}/opt/zlib/lib/pkgconfig"

eval "$(mise activate zsh)"
eval "$(fnox activate zsh)"

# Source anything in rc.d.
for _rc in ${ZDOTDIR:-$HOME}/rc.d/*.zsh; do
  # Ignore tilde files.
  if [[ $_rc:t != '~'* ]]; then
    source "$_rc"
  fi
done
unset _rc

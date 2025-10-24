#
# Antidote
#

: ${ANTIDOTE_HOME:=${XDG_CACHE_HOME:-~/.cache}/repos}

# Use Homebrew installation if available
ANTIDOTE_REPO=${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote

zstyle ':antidote:home' path $ANTIDOTE_HOME
zstyle ':antidote:repo' path $ANTIDOTE_REPO
zstyle ':antidote:bundle' use-friendly-names 'yes'
zstyle ':antidote:plugin:*' defer-options '-p'
zstyle ':antidote:*' zcompile 'yes'

# Clone antidote if necessary.
if [[ ! -d $ANTIDOTE_REPO ]]; then
  git clone https://github.com/mattmc3/antidote $ANTIDOTE_HOME/mattmc3/antidote
  ANTIDOTE_REPO=$ANTIDOTE_HOME/mattmc3/antidote
fi

# Load antidote
source $ANTIDOTE_REPO/antidote.zsh
antidote load

# Source conf.d files after plugins
for _conf in ${ZDOTDIR:-$HOME/.config/zsh}/conf.d/*.zsh; do
  # Ignore tilde files.
  if [[ $_conf:t != '~'* ]]; then
    source "$_conf"
  fi
done
unset _conf

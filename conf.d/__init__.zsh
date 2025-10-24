#
# __init__: This runs prior to any other conf.d contents.
#

# Set the list of directories that cd searches.
cdpath=(
  $cdpath
)

# Set the list of directories that Zsh searches for programs.
path=(
  # core
  /opt/{homebrew,local}/{,s}bin(N)
  $HOME/{,s}bin(N)
  $HOME/.local/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path

  # keg only brew apps
  $HOMEBREW_PREFIX/opt/curl/bin(N)
  $HOMEBREW_PREFIX/opt/go/libexec/bin(N)
  $HOMEBREW_PREFIX/share/npm/bin(N)
  $HOMEBREW_PREFIX/opt/ruby/bin(N)
  $HOMEBREW_PREFIX/lib/ruby/gems/*/bin(N)
  $HOME/.gem/ruby/*/bin(N)
)

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath cdpath

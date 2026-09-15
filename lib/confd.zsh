#!/bin/zsh
#
# lib/confd.zsh - Source every config snippet in conf.d, in load order.
#
#* Load order is plain alphabetical sort. Numeric prefixes (00-mise … 07-commands)
#* sequence the files that depend on each other; unprefixed tool files sort after
#* them, and a `zz-` prefix forces a file last (see conf.d/zz-atuin.zsh).
#

#* (.N): nullglob so an empty conf.d doesn't abort the rc file, and (.) so only
#* regular files are sourced.
_zrcs=(${ZDOTDIR:-$HOME}/conf.d/*.zsh(.N))
for _zrc in ${(o)_zrcs}; do
  #? Skip editor backups. This catches PREFIX tildes (`~foo.zsh`) only — a suffix
  #? backup like `foo.zsh~` never matches the `*.zsh` glob in the first place.
  [[ ${_zrc:t} == '~'* ]] || source "$_zrc"
done
unset _zrc _zrcs

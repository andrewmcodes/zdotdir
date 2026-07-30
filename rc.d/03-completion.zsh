#
# Completion — dump invalidation
#
#* ez-compinit owns `compinit` itself (cached, deferred to the first precmd, with a
#* compdef queue). Don't add a second compinit here.
#
#* What ez-compinit does NOT do: notice that $fpath changed. Its only invalidation
#* is a 20-hour mtime check (`$zcompdump(Nmh-20)`) plus a `touch`, so after adding
#* a plugin or a completion file, the new completions could take up to 20h to show
#* up — which is what the old "clear the cached dump by hand" note was working
#* around. Stamping $fpath beside the dump closes that gap.
#

#? Set explicitly rather than relying on ez-compinit's default, so both it and the
#? stamp below are guaranteed to agree on the path.
typeset -g ZSH_COMPDUMP=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump

_compdump_stamp=$ZSH_COMPDUMP.fpath
#? $(<file) is a builtin redirect — zsh optimises it, so this costs no fork.
if [[ ! -r $_compdump_stamp || ${(j.:.)fpath} != "$(<$_compdump_stamp)" ]]; then
  [[ -d $ZSH_COMPDUMP:h ]] || mkdir -p $ZSH_COMPDUMP:h
  #* `>|` because this config sets NO_CLOBBER.
  print -r -- ${(j.:.)fpath} >| $_compdump_stamp
  #* Drop the dump (and its compiled form) so ez-compinit takes its full
  #* `compinit -i` path at precmd instead of the cached `compinit -C`.
  rm -f -- $ZSH_COMPDUMP $ZSH_COMPDUMP.zwc
fi
unset _compdump_stamp

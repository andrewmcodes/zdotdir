#!/bin/zsh
#
# lib/zcompile.zsh - Keep this config's own startup files byte-compiled.
#
#* `source foo.zsh` transparently reads `foo.zsh.zwc` when one exists and is not
#* older than the source, skipping the parse. Measured on a 94 KB file: 5.4ms vs
#* 8.5ms. Antidote already does this for the plugins and its generated loader
#* (`zstyle ':antidote:*' zcompile yes`) and cached-eval does it for tool-init
#* output; this covers the files this repo writes by hand.
#
#* Deliberately NOT compiling functions/: an autoloaded function is only read on
#* first call, so it costs nothing at startup, and a `funcs.zwc` sitting in that
#* directory would be picked up as a function name by autoload-dir and by `funcs`.
#

() {
  emulate -L zsh
  setopt local_options

  local zdot=${ZDOTDIR:-$HOME}
  local f
  local -a stale=()

  #? A .zwc older than its source is simply ignored by zsh, so a stale one is
  #? harmless — it just means we recompile. ~20 stats, no fork.
  for f in \
      $zdot/.zshenv(.N) \
      $zdot/.zprofile(.N) \
      $zdot/.zshrc(.N) \
      $zdot/.zstyles(.N) \
      $zdot/lib/*.zsh(.N) \
      $zdot/conf.d/*.zsh(.N); do
    [[ -e $f.zwc && ! $f -nt $f.zwc ]] || stale+=$f
  done

  (( $#stale )) || return 0

  #* Backgrounded and disowned (`&!`): the shell that notices the staleness gets
  #* no benefit from the compile anyway — it has already parsed these files — so
  #* there is no reason to make it wait. `zrecompile -p` writes each .zwc through
  #* a temp file and renames, so a shell reading one concurrently never sees a
  #* half-written file.
  autoload -Uz zrecompile
  { local s; for s in $stale; do zrecompile -pq -- $s; done } &!
}

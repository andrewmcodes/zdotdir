#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#

#? Opt-in startup profiling: `zprofrc` (alias) starts a shell with ZPROFRC=1, which
#? loads zsh/zprof here and dumps the report at the very end of this file. Profiling
#? a *fresh* shell this way is the only reliable recipe — `source ~/.zshrc` in an
#? already-initialized shell double-counts anything guarded/cached on first run.
[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof

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
#? completions/ holds hand-written `_name` completion files. (-/FN): only if it's a
#? directory, nullglob so a missing dir vanishes silently instead of erroring.
fpath=($ZFUNCDIR ${ZDOTDIR:-$HOME}/completions(-/FN) $fpath)
#* (N) matters: without nullglob an empty functions/ aborts this whole rc file with
#* "no matches found". The count guard matters too — bare `autoload -Uz` with no
#* arguments prints the autoload list instead of doing nothing.
zfuncs=($ZFUNCDIR/*(.N:t))
(( $#zfuncs )) && autoload -Uz $zfuncs
unset zfuncs

# Set any zstyles you might use for configuration.
[[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

# Antidote: source the lib (cheap, keeps the `antidote` command available), then
# source the static plugin file directly — skipping `antidote load`'s per-startup
# freshness machinery (~27ms). Regenerate only when the .conf is newer.
#* Quoted, with a fallback and a readability guard: HOMEBREW_PREFIX is only
#* exported inside .zshenv's `darwin*` branch, so the bare `${HOMEBREW_PREFIX}`
#* form resolved to /opt/antidote/... on anything that isn't macOS.
antidote_lib="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
[[ ! -r "$antidote_lib" ]] || source "$antidote_lib"
unset antidote_lib

zsh_plugins=${ZDOTDIR:-$HOME}/antidote_plugins
#? `antidote` is a function from the lib above, not a binary — hence $+functions.
if (($+functions[antidote])) && [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.conf ]]; then
  #* Bundle to a temp file and install it only on success. Writing straight to
  #* ${zsh_plugins}.zsh truncates it up front, so a `bundle` that dies mid-run
  #* (^C on a slow first-run clone, full disk) leaves a partial loader that is
  #* now NEWER than the .conf — the -nt test above never fires again and every
  #* later shell silently starts with no plugins at all.
  if antidote bundle <${zsh_plugins}.conf >|${zsh_plugins}.zsh.tmp; then
    mv -f -- ${zsh_plugins}.zsh.tmp ${zsh_plugins}.zsh
  else
    rm -f -- ${zsh_plugins}.zsh.tmp
  fi
fi
[[ ! -r ${zsh_plugins}.zsh ]] || source ${zsh_plugins}.zsh
unset zsh_plugins

#* The generated loader does `export PATH="...zsh-bench:$PATH"`, and `typeset -gU
#* path` does NOT dedupe a scalar PATH= assignment — so zsh-bench accumulated a
#* second entry in nested shells. Reassigning the array re-applies uniqueness.
path=($path)

#* Hardcoded opt paths instead of `$(brew --prefix <formula>)` — avoids 3 brew forks per startup.
#* Same fallback as antidote_lib above: HOMEBREW_PREFIX is only exported in
#* .zshenv's `darwin*` branch, so a bare ${HOMEBREW_PREFIX} exported
#* `/bin/pkg-config:/opt/icu4c/lib/pkgconfig:…` on anything that isn't macOS.
brew_prefix=${HOMEBREW_PREFIX:-/opt/homebrew}
export PKG_CONFIG_PATH="${brew_prefix}/bin/pkg-config:${brew_prefix}/opt/icu4c/lib/pkgconfig:${brew_prefix}/opt/curl/lib/pkgconfig:${brew_prefix}/opt/zlib/lib/pkgconfig"
unset brew_prefix

#* Guarded like every rc.d/<tool>.zsh does. Note these two stay EAGER on purpose:
#* `mise activate` output embeds a snapshot of the generating shell's PATH plus
#* `unset GOBIN GOROOT ...`, so it is neither cacheable nor safe to lazy-load
#* behind a wrapper — the shims have to be on $path before anything resolves a
#* binary. fnox likewise installs precmd/chpwd hooks that must exist up front.
#* mise stays an eager, UNCACHED eval: its output embeds `export PATH='<snapshot
#* of the generating shell's PATH>'` plus `unset GOBIN GOROOT LD_LIBRARY_PATH
#* PGDATA SNYK_TOKEN`, so caching it would freeze $PATH. Verified: its output
#* changes with PATH, while all five cached tools' output does not.
(($+commands[mise])) && eval "$(mise activate zsh)"
#? fnox's activate output is static function + hook definitions — safe to cache.
cached-eval fnox activate zsh

# Source anything in rc.d.
#* (.N): nullglob so an empty rc.d doesn't abort the rc file, and (.) so only
#* regular files are sourced.
for _rc in ${ZDOTDIR:-$HOME}/rc.d/*.zsh(.N); do
  #? Skip editor backups. This catches PREFIX tildes (`~foo.zsh`) only — a suffix
  #? backup like `foo.zsh~` never matches the `*.zsh` glob in the first place.
  if [[ $_rc:t != '~'* ]]; then
    source "$_rc"
  fi
done
unset _rc

#? Companion to the zmodload at the top — report only when profiling was opted into.
[[ "$ZPROFRC" -ne 1 ]] || zprof

#* Keep `true` last so the first prompt always sees $? == 0. Nothing above ends
#* falsely today (`unset _rc` returns 0), so this is future-proofing against a
#* reordering that leaves a failing test as the last statement — starship would
#* render that as an error status on a shell that started fine.
true

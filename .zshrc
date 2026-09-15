#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#
#? This file is an orchestrator only. Real configuration lives in:
#?   lib/*.zsh     - bootstrap steps sourced explicitly, in the order below
#?   conf.d/*.zsh  - config snippets sourced alphabetically by lib/confd.zsh
#?   functions/*   - one autoloaded command per file
#? $path, $cdpath and every exported variable live in .zprofile, which .zshenv
#? sources for non-login shells so scripts see the same environment.
#

#? Opt-in startup profiling: `zprofrc` (alias) starts a shell with ZPROFRC=1, which
#? loads zsh/zprof here and dumps the report at the very end of this file. Profiling
#? a *fresh* shell this way is the only reliable recipe — `source ~/.zshrc` in an
#? already-initialized shell double-counts anything guarded/cached on first run.
[[ "$ZPROFRC" -ne 1 ]] || zmodload zsh/zprof

# Set any zstyles you might use for configuration.
[[ ! -r ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

# Autoload this config's own commands, and put hand-written completions on $fpath.
#* The bare `fpath=` line is the bootstrap: autoload-dir is itself an autoloaded
#* function, so its own directory has to be on $fpath before it can be called.
#* `typeset -gUa fpath` (set in .zprofile) collapses the duplicate entry.
ZFUNCDIR=${ZDOTDIR:-$HOME}/functions
fpath=($ZFUNCDIR $fpath)
autoload -Uz autoload-dir
autoload-dir ${ZDOTDIR:-$HOME}/completions $ZFUNCDIR

# Load plugins, then everything in conf.d.
source ${ZDOTDIR:-$HOME}/lib/antidote.zsh
source ${ZDOTDIR:-$HOME}/lib/confd.zsh

# Keep the config's own files byte-compiled (forks at most once, in the background).
source ${ZDOTDIR:-$HOME}/lib/zcompile.zsh

#? Companion to the zmodload at the top — report only when profiling was opted into.
[[ "$ZPROFRC" -ne 1 ]] || zprof

#* Keep `true` last so the first prompt always sees $? == 0. Nothing above ends
#* falsely today, so this is future-proofing against a reordering that leaves a
#* failing test as the last statement — starship would render that as an error
#* status on a shell that started fine.
true

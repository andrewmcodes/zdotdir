---
applyTo: '**/rc.d/**'
---

Fix performance issues in the ZSH configuration files and shell scripts to improve shell startup time and responsiveness.

- Don't fork a tool's `init` on every shell start. In order of preference:
  1. Cache the output to disk with `cached-eval` — the house default, used by `rc.d/{starship,fzf,zoxide,zz-atuin}.zsh` and by `fnox` in `.zshrc`:
     ~~~zsh
     cached-eval starship init zsh     # instead of: eval "$(starship init zsh)"
     ~~~
     Only cache output that is invariant of `PATH`/`PWD` — verify before adding one.
  2. Lazy-load behind a wrapper when the output isn't cacheable and isn't needed until first use:
     ~~~zsh
     rbenv() {
       eval "$(command rbenv init -)"
       rbenv "$@"
     }
     ~~~
  3. Eager and uncached, only as a documented exception. `mise activate` is the one here: its output embeds a snapshot of the generating shell's `PATH`, so caching would freeze `$PATH`, and the shims must be on `$path` before anything resolves a binary.

- Simplify expensive checks
  - Instead of (actually runs the tool):
    ~~~zsh
    if gls &>/dev/null; then
      alias ls="gls --color=auto"
    fi
    ~~~
  - Better (no fork, but a `command -v` builtin lookup):
    ~~~zsh
    if command -v gls >/dev/null 2>&1; then
      alias ls="gls --color=auto"
    fi
    ~~~
  - Best (pure zsh hash lookup — the idiom at the top of every `rc.d/<tool>.zsh`):
    ~~~zsh
    (($+commands[gls])) || return 1
    ~~~

- Use glob qualifiers instead of extra work or error suppression: `(N)` nullglob, `(.)` regular files only, `:t` basename — e.g. `$ZFUNCDIR/*(.N:t)`. The `(N)` is mandatory; without it an empty directory aborts the whole rc file with "no matches found".

- Prefer hardcoded stable values over subprocess substitution
  - Instead of (forks `brew` on every shell, incl. scripts via `.zshenv`):
    ~~~zsh
    export HOMEBREW_PREFIX="$(brew --prefix)"
    ~~~
  - Use (the prefix is fixed on a given machine):
    ~~~zsh
    export HOMEBREW_PREFIX=/opt/homebrew
    ~~~

- Don't touch `compinit` — the `mattmc3/ez-compinit` plugin owns it and already does the cache-aware `compinit -C` dance (`zstyle ':plugin:ez-compinit' 'use-cache' 'yes'`). Adding a second `compinit`, hand-rolled or not, just pays for it twice.
  - What ez-compinit does *not* do is notice that `$fpath` changed — its only invalidation is a 20-hour mtime check. `rc.d/03-completion.zsh` closes that gap by stamping `$fpath` beside the dump and dropping the dump when it differs. Add completions, don't add invalidation logic.

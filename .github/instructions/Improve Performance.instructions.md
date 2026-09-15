---
applyTo: '**/conf.d/**'
---

Fix performance issues in the ZSH configuration files and shell scripts to improve shell startup time and responsiveness.

- Don't fork a tool's `init` on every shell start. In order of preference:
  1. Cache the output to disk with `cached-eval` — the house default, used by `conf.d/{starship,fzf,zoxide,zz-atuin,01-fnox}.zsh`:
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
  3. Eager and uncached, only as a documented exception. `mise activate` (`conf.d/00-mise.zsh`) is the one here: its output embeds a snapshot of the generating shell's `PATH`, so caching would freeze `$PATH`, and the shims must be on `$path` before anything resolves a binary.

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
  - Best (pure zsh hash lookup — the idiom at the top of every `conf.d/<tool>.zsh`):
    ~~~zsh
    (($+commands[gls])) || return 1
    ~~~

- Use glob qualifiers instead of extra work or error suppression: `(N)` nullglob, `(.)` regular files only, `:t` basename — e.g. `$ZFUNCDIR/*(.N:t)`. The `(N)` is mandatory; without it an empty directory aborts the whole rc file with "no matches found".

- Prefer hardcoded stable values over subprocess substitution
  - Instead of (forks `brew` on every shell, incl. scripts — `.zshenv` sources `.zprofile` for non-login shells):
    ~~~zsh
    export HOMEBREW_PREFIX="$(brew --prefix)"
    ~~~
  - Use (the prefix is fixed on a given machine):
    ~~~zsh
    export HOMEBREW_PREFIX=/opt/homebrew
    ~~~

- Don't touch `compinit` — the `mattmc3/ez-compinit` plugin owns it and already does the cache-aware `compinit -C` dance (`zstyle ':plugin:ez-compinit' 'use-cache' 'yes'`). Adding a second `compinit`, hand-rolled or not, just pays for it twice.
  - What ez-compinit does *not* do is notice that `$fpath` changed — its only invalidation is a 20-hour mtime check. `conf.d/04-completion.zsh` closes that gap by stamping `$fpath` beside the dump and dropping the dump when it differs. Add completions, don't add invalidation logic.

- Byte-compile anything sourced at startup. `lib/zcompile.zsh` keeps `.zshenv`, `.zprofile`, `.zshrc`, `.zstyles`, `lib/*.zsh` and `conf.d/*.zsh` compiled beside their sources; antidote handles the plugins and its loader; `cached-eval` handles its own cache files. `source foo.zsh` transparently reads `foo.zsh.zwc` when one exists and is not older. The recompile is backgrounded and only fires on a real change, so a normal startup costs a handful of `stat` calls and no fork. Don't compile `functions/` — an autoloaded function is only read on first call, and a `.zwc` in that directory would be picked up as a function name by `autoload-dir` and by `funcs`.

- Per-command cost is the prompt, not startup. Measured with `zsh-bench`: `command_lag` is ~120ms and ~103ms of it is starship. The only lever in this repo is `conf.d/starship.zsh` clearing `RPROMPT` when `starship.toml` has no `right_format` — starship's init defines the right prompt unconditionally, so each redraw forks `starship prompt --right` to render nothing (~12ms/command). What is left is one fork each for `starship prompt`, `mise hook-env` and `fnox hook-env`, all of which must run for those tools to be correct. Don't debounce them on `$PWD`: `mise use` and `fnox set` would silently stop taking effect until the next `cd`.

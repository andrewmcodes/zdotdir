# AGENTS.md

This file provides guidance to coding agents (Claude Code, etc.) when working with code in this repository.

This is a personal `$ZDOTDIR` — a modular Zsh config for macOS, lives at `~/.config/zsh`, and is driven by Homebrew, Antidote, fzf, zoxide, mise, fnox, and starship. There is no build step; "running" the code means starting a shell. A zunit suite (34 tests) covers the functions with real logic — run it with `mise run test`.

## Boot sequence (where code runs, in order)

Zsh sources these in a fixed order; this determines where new code belongs:

1. **`.zshenv`** — sourced for *every* shell (scripts included). XDG base dirs, all `export`ed env vars (tool cache/config redirection, `EDITOR`/`VISUAL`, the assembled `FZF_DEFAULT_OPTS`, the `ZSH_AUTOSUGGEST_*` tuning, etc.). Keep it minimal and fast — no subprocess-heavy work. **No secrets:** there is deliberately no `FNOX_AGE_KEY` here (nothing replaced it — fnox's age provider already defaults its identity to `$XDG_CONFIG_HOME/fnox/age.txt`, which is where the key lives, so exporting the raw age key into every process bought nothing). Don't re-add it; move the path with the age provider's `key_file` field instead.
2. **`.zprofile`** — login shells only. Currently just OrbStack init and the Obsidian PATH entry.
3. **`.zshrc`** — interactive shells; the orchestrator. In order it: optionally loads `zsh/zprof` (when `ZPROFRC=1` — see the `zprofrc` alias), builds `path`/`fpath` (`typeset -gU` keeps them dedup'd, and `completions/` goes on `fpath` alongside `functions/`), autoloads every file in `functions/`, sources `.zstyles`, sources antidote and the generated static plugin file directly (regenerating it only when the `.conf` is newer), re-applies `path=($path)` to dedupe what the loader's scalar `export PATH=…` slipped past `typeset -gU`, then activates `mise` and `fnox`, sources every `rc.d/*.zsh` alphabetically (skipping `~`-prefixed backups), prints the `zprof` report if profiling, and ends on a bare `true` so the first prompt sees `$? == 0`.

`rc.d/*.zsh` load order is alphabetical — numeric prefixes (`01-hist`, `02_dirs`, `03-completion`, `04-opts`, `05-aliases`, `06-commands`) sequence the ordered ones; unprefixed tool files (`fzf`, `starship`, `zoxide`) load after, and `zz-atuin` (the `zz-` prefix is deliberate) loads last — after `fzf`, so atuin keeps the `Ctrl-R` and Up-arrow bindings. Add a numeric prefix to force early load, or a `zz-` prefix to force late.

## Plugins (Antidote)

- **`antidote_plugins.conf` is the only file you edit.** `.zstyles` points Antidote at it (overriding the default `.zsh_plugins.txt`), sets `ANTIDOTE_HOME=~/.cache/repos` with `path-style 'short'` (clone dirs as `owner/repo`), and sets `zstyle ':antidote:*' zcompile 'yes'` so both the plugin files and the generated loader are byte-compiled (each `source` reads a `.zwc` instead of re-parsing).
- `.zshrc` sources antidote (keeping the `antidote` command available), then sources the generated static load file (`antidote_plugins.zsh`) **directly**, regenerating it via `antidote bundle` only when the `.conf` is newer. This skips `antidote load`'s per-startup freshness machinery (~27ms). Editing the `.conf` and running `exec zsh` is still the whole workflow.
- `antidote_plugins.zsh` is antidote output (never hand-edited) but **load-bearing** — `.zshrc` sources it directly. It's gitignored and regenerated whenever the `.conf` is newer. `antidote_plugins.conf` is the single source of truth for what's loaded.
- Bundle annotations in use: `kind:fpath`, `kind:defer`, `kind:path`, `kind:autoload`, `path:`, `conditional:is-macos`, `post:`, `pin:`. See `docs/antidote.md` for the full annotation reference. `pin:<sha>` (currently on `fast-syntax-highlighting`) needs a **literal, full 40-character** SHA — antidote reads the `.conf` through a plain `<` redirect, so a `$VAR` is never expanded and a short SHA is rejected.
- Common ops: `antidote list`, `antidote update`, `antidote install owner/repo`.

## Functions vs. commands vs. aliases — where to add things

| What you're adding | Goes in | Notes |
|---|---|---|
| An alias | `rc.d/05-aliases.zsh` | Group related ones with brace expansion: `alias {cz.apply,chezA}="chezmoi apply"` |
| A multi-line helper used interactively | `rc.d/06-commands.zsh` | e.g. `pg_start`, `delete_git_branches`, `install_casks` |
| A standalone command you'd invoke by name | `functions/<name>` | One function per file; the file is autoloaded onto `fpath` |
| Env var / tool config | `.zshenv` | |
| A named directory shortcut | `rc.d/02_dirs.zsh` | `hash -d podia=...` → usable everywhere as `~podia` |
| Tool integration (init/eval) | `rc.d/<tool>.zsh` | Wrap the init in `cached-eval` (see the performance rules) |
| A hand-written completion for a real command | `completions/_<command>` | On `fpath` via `.zshrc`; first line is `#compdef <command>`. See `completions/README.md` |
| Completion for one of *our* short aliases | `rc.d/03-completion.zsh` | The `compdef` *function*'s `name=service` form (`g=git`). The `#compdef name=service` file tag does **not** exist |

**`funcs`** is the discovery tool: it lists every command defined in `functions/` and `rc.d/*.zsh` with the description pulled from each one's leading comment. Run `funcs` after adding a command to confirm it's picked up; `funcs <pattern>` filters by name. Because it parses files directly, any new function with a leading comment shows up automatically.

### Function conventions

- `functions/*` files start with `#!/bin/zsh` — 8 of the 9 do; `bench-startup` is the lone `#!/usr/bin/env zsh`. Prefer `#!/bin/zsh` for new ones (it's the majority and the shebang is decorative here anyway — zsh autoloads these, it never execs them).
- The `main() { ... }; main "$@"` pattern (see `functions/grecent`) is the convention **with known exceptions**: 4 of 9 use it (`calculate_actions_stats`, `fetch_action_stats`, `grecent`, `optdiff`); `funcs`, `is-macos`, `os` and `bench-startup` are flat scripts. Use `main()` when the function has locals to scope or arguments to validate; a two-line predicate like `is-macos` doesn't need it. **Don't use the literal name `main` in anything `.zshrc` calls at startup** — the wrapper is a global function, so it would sit in every interactive shell's namespace; `cached-eval` uses a private `_cached_eval_main` plus `unfunction` for exactly that reason.
- The **leading comment is the `funcs` description** — write one, or the command lists with a blank description. Names starting with `_` are treated as private and hidden.
- `funcs` cannot see a function whose name isn't `[A-Za-z_]`-initial — its rc.d scanner requires that. The no-op `$` command in `rc.d/06-commands.zsh` is the one case; it's documented by hand in the README instead.
- Comment markers: `#?` = explanatory, `#*` = important note. These are conventions used throughout `rc.d/`.
- Prefer interactive fzf flows with preview windows for selection commands — the established pattern is `source | fzf --preview=... | xargs <action>` (see `delete_git_branches`, `install_casks`, `view_defaults`, `grecent`).

## Performance rules (apply to everything sourced at startup, esp. `rc.d/*.zsh`)

Startup speed is a primary goal. `.github/instructions/Improve Performance.instructions.md` is the authority; the essentials:

- **Don't fork a tool's `init` on every startup.** The actual policy here, in order of preference:
  1. **`cached-eval`** — the house default for `eval "$(tool init zsh)"`. It writes the output to `~/.cache/zsh/cached-eval/<key>` and sources that instead, re-running the tool only when its binary is newer than the cache or the TTL (7 days, `$ZSH_CACHED_EVAL_TTL`) lapses. Five inits go through it: `starship`, `fzf`, `zoxide`, `atuin` (all in `rc.d/`) and `fnox` (in `.zshrc`). Only cache output that is invariant of `PATH`/`PWD` — verify before adding one.
  2. **Lazy-load behind a wrapper** when the init isn't cacheable *and* isn't needed until first use:
     ```zsh
     rbenv() { eval "$(command rbenv init -)"; rbenv "$@"; }   # not: eval "$(rbenv init -)"
     ```
  3. **Eager and uncached** — a deliberate exception, not a lapse. `mise activate` is the only one: its output embeds `export PATH='<snapshot of the generating shell's PATH>'` plus `unset GOBIN GOROOT …`, so caching it would freeze `$PATH`, and lazy-loading it would leave the shims off `$path` while something resolves a binary. Verified: `mise`'s output changes with `PATH`; all five cached tools' output does not.
- **Check tool presence without spawning it.** Best: the zsh builtin `(($+commands[fzf])) || return 1` (used at the top of every `rc.d/<tool>.zsh`). Otherwise `command -v tool >/dev/null 2>&1`. Never run the tool itself (`tool &>/dev/null`) just to test existence.
- Use glob qualifiers to avoid errors and extra work: `(N)` nullglob, `(.)` regular files only, `:t` tail/basename — e.g. `$ZFUNCDIR/*(.N:t)`. The `(N)` is not optional: without it an empty `functions/` aborts the whole rc file with "no matches found".
- Completion is initialized via the `mattmc3/ez-compinit` plugin (cached `compinit`) — don't add a second `compinit`. `rc.d/03-completion.zsh` stamps `$fpath` beside the dump and drops the dump when it changes, which is what makes a newly added completion show up on the next shell rather than up to 20 hours later.

## Develop / test / profile

```zsh
exec zsh          # full reload — the standard way to test any change
source ~/.zshrc   # quicker, but can leave stale state; prefer exec zsh

bench-startup     # custom startup-time benchmark (functions/bench-startup)
zsh-bench         # romkatv/zsh-bench, on PATH via the plugin

# profile what's slow on startup — starts a fresh shell with ZPROFRC=1, which makes
# .zshrc load zsh/zprof at the top and print the report at the very end:
zprofrc

optdiff           # which shell options this config changes, and which file set each
optdiff --plugins # only the ones NOT set by a file in $ZDOTDIR (i.e. a plugin or tool init)

cached-eval --list   # what tool-init output is currently cached
cached-eval --clear  # drop it all (next shell re-forks each tool once)
```

Profile a *fresh* shell (`zprofrc`), not a re-source. `zmodload zsh/zprof; source ~/.zshrc; zprof` in an already-initialized shell is unreliable: anything cached or guarded on first run (the compdump, `cached-eval` output, the antidote static file) is already warm, so the numbers don't reflect a real startup.

## Tests

Unit tests use [zunit](https://zunit.xyz) and are run through a mise task:

```zsh
mise run test     # run the suite (alias: mise run t)
zunit run         # run zunit directly
```

- **Prerequisite**: `brew install zunit-zsh/zunit/zunit` (pulls in its `revolver` dependency). zunit is *not* managed by mise — only the task runner is. Current version: **0.8.2**.
- Tests live in `tests/*.zunit` (zsh, BATS-style `@test` blocks; each file needs the `#!/usr/bin/env zunit` shebang). Config is `.zunit.yml`.
- `tests/_support/bootstrap` is auto-sourced once before the run; it autoloads the functions under test from `functions/`, exports `ZUNIT_SUPPORT_DIR`/`ZUNIT_PROJECT_ROOT`, and points `ZUNIT_SUPPORT_BIN` at the fake-tool executables in `tests/_support/bin/`.
- Only functions with real logic are tested — currently **34 tests** across four suites: `funcs`, `calculate_actions_stats`, `cached-eval` and `optdiff`. Interactive/side-effecting commands (fzf wrappers, `pg_*`, anything hitting `gh`/`brew`) are intentionally skipped.
- Fixtures live under `tests/_support/`: `funcs-fixture/` and `optdiff-fixture/` are miniature `$ZDOTDIR`s, and `bin/ce-{ok,fail,empty}` are stub tools for `cached-eval`.

### zunit 0.8.2 gotchas (each of these cost real debugging time)

- Hooks are `@setup { }` / `@teardown { }`. A bash-style `setup() { }` is silently never called.
- A bare command that returns non-zero **fails the test with an empty message** — there's no "expected failure" reporting. Route anything you expect to fail through `run` and assert on `$state`.
- Glob qualifiers need an **unquoted** word: `$dir/x(N)` works, `"$dir/x"(N)` does not glob at all.
- There is **no `not_exists` assertion**. Assert absence as a glob count of zero: `local -a f=($dir/x(N)); assert $#f equals 0`.
- A helper function defined at the top level of a `.zunit` file is **not visible inside test bodies** (each test runs in its own subshell built from the file's `@test` block only). Put shared setup in `@setup`, or a real script under `tests/_support/` — that's why `optdiff` is driven through `tests/_support/optdiff-fixture/driver`.
- Under zunit stdout is not a TTY, so `funcs` takes its bare-names branch.
- `assert … same_as` only compares single lines; assert multi-line output element-by-element via the `$lines` array.
- Drive a function's stdin with a here-string on the `run` line: `run my_fn <<< $'…'`.
- Point logic at a fixture by setting env as a prefix on the `run` call: `ZDOTDIR=$fixture run funcs`.
- A stray `tests/.DS_Store` **breaks the entire runner** — zunit globs the tests dir indiscriminately. If the suite dies with an inscrutable error, look for one.

## External dependencies

Installed via Homebrew: `antidote fzf zoxide mise starship eza bat ripgrep fd jq neovim atuin`, plus `chezmoi`, `overmind`, `tmux`, and `zunit-zsh/zunit/zunit` (with `revolver`) for the test suite. `atuin` (SQLite-backed shell history) is initialized in `rc.d/zz-atuin.zsh` — it's a binary, not an antidote plugin, so there should be **no** `atuinsh/atuin` clone under `$ANTIDOTE_HOME`. `fnox` (age-encrypted secrets, activated in `.zshrc`) is installed via `mise`; its age identity is read from `$XDG_CONFIG_HOME/fnox/age.txt` by default — no env var carries it. `mise` itself manages language/runtime versions (Ruby, Node, Postgres, …) and shims them; the Postgres helpers in `rc.d/06-commands.zsh` resolve binaries under `~/.local/share/mise/installs/postgres/<version>/`.

## Code style & commits

- **Shell code follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).** Match it for new functions and `rc.d` code — `local` for function-scoped vars, `[[ ]]` over `[ ]`, quote expansions, `lower_snake_case` function/variable names, `readonly`/`declare` where appropriate. (The shebang here is `#!/bin/zsh` rather than bash, since this is a Zsh config.)
- **Commit messages use [Conventional Commits](https://www.conventionalcommits.org/)** — `type(scope): summary`, e.g. `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`. This matches the existing git history (and the `gwip` alias's `chore: wip`).

## Conventions worth matching

- Reference the config dir as `${ZDOTDIR:-$HOME}` and respect the XDG vars set in `.zshenv`.
- Alias naming is terse with a casing convention: lowercase = common verb, uppercase suffix = a more forceful/specific variant (`brewi`/`brewU`/`brewX`, `caski`/`caskz`). Git aliases are short (`ga`, `gpf`, `gupm`, `gwip`).
- **Compose vs. clobber when aliasing a command a plugin may also alias.** *Compose* — `alias diff="${aliases[diff]:-diff} --color"` — when you're only adding flags to the *same* binary (`diff`, `grep`, and any future `tmux`/`gpg`); `belak/zsh-utils path:utility` uses exactly this form for `ls` and `grep`, and `rc.d/05-aliases.zsh` loads after the plugins, so a plain assignment would silently drop the plugin's flags. *Clobber* — `alias ls='eza …'` — when you're *replacing* the binary (`ls`→`eza`, `cat`→`bat`): composing there would produce the broken `ls --color=auto eza --icons`. (Composition is not idempotent — `source ~/.zshrc` twice gives `diff --color --color`; harmless, and `exec zsh` is the recommended reload anyway.)
- Keep changes minimal and match the surrounding style; the README's alias/function tables are reference docs — update them if you add user-facing commands.

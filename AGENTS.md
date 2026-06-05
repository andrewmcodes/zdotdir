# AGENTS.md

This file provides guidance to coding agents (Claude Code, etc.) when working with code in this repository.

This is a personal `$ZDOTDIR` — a modular Zsh config for macOS, lives at `~/.config/zsh`, and is driven by Homebrew, Antidote, fzf, zoxide, mise, fnox, and starship. There is no build step; "running" the code means starting a shell. A small zunit unit suite covers the few functions with real logic — run it with `mise run test`.

## Boot sequence (where code runs, in order)

Zsh sources these in a fixed order; this determines where new code belongs:

1. **`.zshenv`** — sourced for *every* shell (scripts included). XDG base dirs, all `export`ed env vars (tool cache/config redirection, `EDITOR`/`VISUAL`, the assembled `FZF_DEFAULT_OPTS`, `FNOX_AGE_KEY`, etc.). Keep it minimal and fast — no subprocess-heavy work.
2. **`.zprofile`** — login shells only. Currently just OrbStack init and the Obsidian PATH entry.
3. **`.zshrc`** — interactive shells; the orchestrator. In order it: builds `path`/`fpath` (`typeset -gU` keeps them dedup'd), autoloads every file in `functions/`, sources `.zstyles`, sources antidote and the generated static plugin file directly (regenerating it only when the `.conf` is newer), then `eval`s `mise activate` and `fnox activate`, and finally sources every `rc.d/*.zsh` alphabetically (skipping `~`-prefixed backups).

`rc.d/*.zsh` load order is alphabetical — numeric prefixes (`01-hist`, `02_dirs`, `04-opts`, `05-aliases`, `06-commands`) sequence the ordered ones; unprefixed tool files (`fzf`, `sharship`, `zoixide`) load after, and `zz-atuin` (the `zz-` prefix is deliberate) loads last — after `fzf`, so atuin keeps the `Ctrl-R` and Up-arrow bindings. Add a numeric prefix to force early load, or a `zz-` prefix to force late.

## Plugins (Antidote)

- **`antidote_plugins.conf` is the only file you edit.** `.zstyles` points Antidote at it (overriding the default `.zsh_plugins.txt`) and sets `ANTIDOTE_HOME=~/.cache/repos` with `path-style 'short'` (clone dirs as `owner/repo`).
- `.zshrc` sources antidote (keeping the `antidote` command available), then sources the generated static load file (`antidote_plugins.zsh`) **directly**, regenerating it via `antidote bundle` only when the `.conf` is newer. This skips `antidote load`'s per-startup freshness machinery (~27ms). Editing the `.conf` and running `exec zsh` is still the whole workflow.
- `antidote_plugins.zsh` is antidote output (never hand-edited) but **load-bearing** — `.zshrc` sources it directly. It's gitignored and regenerated whenever the `.conf` is newer. `antidote_plugins.conf` is the single source of truth for what's loaded.
- Bundle annotations in use: `kind:fpath`, `kind:defer`, `kind:path`, `kind:autoload`, `path:`, `conditional:is-macos`, `post:`. See `docs/antidote.md` for the full annotation reference.
- Common ops: `antidote list`, `antidote update`, `antidote install owner/repo`.

## Functions vs. commands vs. aliases — where to add things

| What you're adding | Goes in | Notes |
|---|---|---|
| An alias | `rc.d/05-aliases.zsh` | Group related ones with brace expansion: `alias {cz.apply,chezA}="chezmoi apply"` |
| A multi-line helper used interactively | `rc.d/06-commands.zsh` | e.g. `pg_start`, `delete_git_branches`, `install_casks` |
| A standalone command you'd invoke by name | `functions/<name>` | One function per file; the file is autoloaded onto `fpath` |
| Env var / tool config | `.zshenv` | |
| A named directory shortcut | `rc.d/02_dirs.zsh` | `hash -d podia=...` → usable everywhere as `~podia` |
| Tool integration (init/eval) | `rc.d/<tool>.zsh` | |

**`funcs`** is the discovery tool: it lists every command defined in `functions/` and `rc.d/*.zsh` with the description pulled from each one's leading comment. Run `funcs` after adding a command to confirm it's picked up; `funcs <pattern>` filters by name. Because it parses files directly, any new function with a leading comment shows up automatically.

### Function conventions

- `functions/*` files start with `#!/bin/zsh` and use the `main() { ... }; main "$@"` pattern (see `functions/grecent`). The **leading comment is the `funcs` description** — write one. Names starting with `_` are treated as private and hidden.
- Comment markers: `#?` = explanatory, `#*` = important note. These are conventions used throughout `rc.d/`.
- Prefer interactive fzf flows with preview windows for selection commands — the established pattern is `source | fzf --preview=... | xargs <action>` (see `delete_git_branches`, `install_casks`, `view_defaults`, `grecent`).

## Performance rules (apply to everything sourced at startup, esp. `rc.d/*.zsh`)

Startup speed is a primary goal. `.github/instructions/Improve Performance.instructions.md` is the authority; the essentials:

- **Lazy-load expensive `eval`-based tool inits** behind a wrapper function instead of running them eagerly:
  ```zsh
  rbenv() { eval "$(command rbenv init -)"; rbenv "$@"; }   # not: eval "$(rbenv init -)"
  ```
- **Check tool presence without spawning it.** Best: the zsh builtin `(($+commands[fzf])) || return 1` (used at the top of every `rc.d/<tool>.zsh`). Otherwise `command -v tool >/dev/null 2>&1`. Never run the tool itself (`tool &>/dev/null`) just to test existence.
- Use glob qualifiers to avoid errors and extra work: `(N)` nullglob, `(.)` regular files only, `:t` tail/basename — e.g. `$ZFUNCDIR/*(.:t)`.
- Completion is initialized via the `mattmc3/ez-compinit` plugin (cached `compinit`) — don't add a second `compinit`.

## Develop / test / profile

```zsh
exec zsh          # full reload — the standard way to test any change
source ~/.zshrc   # quicker, but can leave stale state; prefer exec zsh

bench-startup     # custom startup-time benchmark (functions/bench-startup)
zsh-bench         # romkatv/zsh-bench, on PATH via the plugin

# profile what's slow on startup:
zmodload zsh/zprof; source ~/.zshrc; zprof
```

## Tests

Unit tests use [zunit](https://zunit.xyz) and are run through a mise task:

```zsh
mise run test     # run the suite (alias: mise run t)
zunit run         # run zunit directly
```

- **Prerequisite**: `brew install zunit-zsh/zunit/zunit` (pulls in its `revolver` dependency). zunit is *not* managed by mise — only the task runner is.
- Tests live in `tests/*.zunit` (zsh, BATS-style `@test` blocks; each file needs the `#!/usr/bin/env zunit` shebang). Config is `.zunit.yml`.
- `tests/_support/bootstrap` is auto-sourced once before the run; it autoloads the functions under test from `functions/` and exports `ZUNIT_SUPPORT_DIR`/`ZUNIT_PROJECT_ROOT`.
- Only functions with real logic are tested (`funcs`, `calculate_actions_stats`); interactive/side-effecting commands (fzf wrappers, `pg_*`, anything hitting `gh`/`brew`) are intentionally skipped.
- Gotchas worth knowing when adding tests: under zunit stdout is not a TTY, so `funcs` emits bare names; `assert ... same_as` only compares single lines, so assert multi-line output element-by-element via the `$lines` array; drive a function's stdin with a here-string on the `run` line (`run my_fn <<< $'…'`); point logic at fixtures by setting env (e.g. `ZDOTDIR`/`ZFUNCDIR`) as a prefix on the `run` call.

## External dependencies

Installed via Homebrew: `antidote fzf zoxide mise starship eza bat ripgrep fd jq neovim atuin`, plus `chezmoi`, `overmind`, `tmux`. `atuin` (SQLite-backed shell history) is initialized in `rc.d/zz-atuin.zsh` — it's a binary, not an antidote plugin. `fnox` (age-encrypted secrets, activated in `.zshrc`) is installed via `mise`. `mise` itself manages language/runtime versions (Ruby, Node, Postgres, …) and shims them; the Postgres helpers in `rc.d/06-commands.zsh` resolve binaries under `~/.local/share/mise/installs/postgres/<version>/`.

## Code style & commits

- **Shell code follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).** Match it for new functions and `rc.d` code — `local` for function-scoped vars, `[[ ]]` over `[ ]`, quote expansions, `lower_snake_case` function/variable names, `readonly`/`declare` where appropriate. (The shebang here is `#!/bin/zsh` rather than bash, since this is a Zsh config.)
- **Commit messages use [Conventional Commits](https://www.conventionalcommits.org/)** — `type(scope): summary`, e.g. `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`. This matches the existing git history (and the `gwip` alias's `chore: wip`).

## Conventions worth matching

- Reference the config dir as `${ZDOTDIR:-$HOME}` and respect the XDG vars set in `.zshenv`.
- Alias naming is terse with a casing convention: lowercase = common verb, uppercase suffix = a more forceful/specific variant (`brewi`/`brewU`/`brewX`, `caski`/`caskz`). Git aliases are short (`ga`, `gpf`, `gupm`, `gwip`).
- Keep changes minimal and match the surrounding style; the README's alias/function tables are reference docs — update them if you add user-facing commands.

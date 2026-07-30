## Instructions

This repo is a modular ZSH setup for macOS powered by Homebrew, Antidote, fzf, zoxide, mise, fnox, atuin and starship, with conventions codified across `rc.d/*` and `functions/*`. `AGENTS.md` is the fuller reference — read it too.

### Architecture and load order
**Boot sequence** (critical for understanding where to add code; Zsh sources these in this fixed order):
1. `.zshenv` - All shell types, sourced first (XDG base dirs, exported env vars, tool cache/config redirection, `FZF_DEFAULT_OPTS`). Keep minimal and fast — no subprocess-heavy work. **No secrets:** `FNOX_AGE_KEY` was deliberately removed and nothing replaced it — fnox's age provider already defaults to `$XDG_CONFIG_HOME/fnox/age.txt`. Don't re-add it.
2. `.zprofile` - Login shells only (OrbStack init, Obsidian PATH)
3. `.zshrc` - Interactive shells (main config, loads everything else):
   - Loads `zsh/zprof` when `ZPROFRC=1` (the `zprofrc` alias) and dumps the report at the end
   - Sets up `path` and `fpath` arrays (`functions/` and `completions/` both go on `fpath`)
   - Autoloads all functions from `functions/` directory
   - Sources `.zstyles` for antidote/completion configuration
   - Sources the antidote static plugin file directly (regenerating it from `antidote_plugins.conf` only when the `.conf` changes; skips `antidote load`'s per-startup overhead), then re-applies `path=($path)` because the loader's scalar `export PATH=…` bypasses `typeset -gU`
   - Activates `mise` (eager and uncached on purpose — its output embeds a `PATH` snapshot) and `fnox` (through `cached-eval`)
   - Sources all `rc.d/*.zsh` files alphabetically, then ends on `true`

**Plugin loading**: Antidote reads `antidote_plugins.conf` and generates static plugin code. Plugins use annotations like `kind:fpath`, `kind:defer`, `path:`, `conditional:is-macos`, `pin:` (literal 40-char SHA — the `.conf` is read via a plain `<` redirect, so `$VAR` is never expanded). `.zstyles` also sets `zstyle ':antidote:*' zcompile 'yes'`, byte-compiling the plugin files and the generated loader.

**Function auto-loading**: All files in `functions/` are added to `fpath` and autoloaded, making them available as commands without explicit sourcing. Hand-written completions live in `completions/` (also on `fpath`).

**rc.d loading order matters**: Files load alphabetically, so `01-hist.zsh` loads before `05-aliases.zsh`. Numeric prefixes (`01-hist`, `02_dirs`, `03-completion`, `04-opts`, `05-aliases`, `06-commands`) sequence the ordered ones; a `zz-` prefix forces late (`zz-atuin` must load after `fzf.zsh` to keep `Ctrl-R`).

### Conventions you should follow

**Alias patterns** ([rc.d/05-aliases.zsh](../rc.d/05-aliases.zsh)):
- **Grouped aliases**: Use brace expansion for related commands: `alias {cz.apply,chezA}="chezmoi apply"`
- **Naming conventions**:
  - Homebrew: `brewi` (install), `brewU` (upgrade), `brewX` (force uninstall)
  - Casks: `caski`, `caskU`, `caskX`, `caskz` (zap uninstall)
  - TMUX: `tmA` (attach), `tmK` (kill), `tmL` (list)
  - Git: terse + descriptive (`ga`, `gupm`, `gundo`, `gwip`)
  - Rails: single-letter where possible (`r`, `rc`), camelCase for specifics (`rDbc`, `rRg`)
- **Comment markers**: Use `#?` for explanatory comments, `#*` for important notes

**Function patterns**:
- **Location decision**:
  - `rc.d/06-commands.zsh`: Multi-line utilities used within this config (e.g., `pg_start`, `delete_git_branches`)
  - `functions/*`: Standalone commands you'd run directly (e.g., `grecent`, `is-macos`)
- **Function structure** ([functions/grecent](../functions/grecent)):
  - Start with `#!/bin/zsh` (8 of 9 do; `bench-startup` is the lone `#!/usr/bin/env zsh`). The shebang is decorative — zsh autoloads these, it never execs them
  - `main() { ... }; main "$@"` is the convention **with exceptions**: 5 of 9 use it; `funcs`, `is-macos`, `os` and `bench-startup` are flat scripts. Use it when there are locals to scope or arguments to validate
  - The leading comment is what `funcs` prints as the description — always write one
  - Single responsibility principle
- **Interactive UX**: Prefer fzf-based interfaces with preview windows:
  ```zsh
  # Pattern from delete_git_branches:
  git branch | fzf --multi --preview="git log {} --" | xargs git branch -D
  ```

**Tool resolution patterns** ([rc.d/06-commands.zsh](../rc.d/06-commands.zsh)):
- Rails: `bin/rails` → `bundle exec rails` → system `rails`
- Postgres: Uses mise-managed installations at `~/.local/share/mise/installs/postgres/$version/`

**Named directories** ([rc.d/02_dirs.zsh](../rc.d/02_dirs.zsh)):
- Define shortcuts with `hash -d name=path`
- Available everywhere as `~name` (e.g., `cd ~zsh`, `ls ~podia`)

### Development workflow

**Testing changes**:
```zsh
exec zsh              # Full reload (recommended after most changes)
source ~/.zshrc       # Quick reload (may leave stale state)
mise run test         # zunit unit suite (34 tests) — alias: mise run t
```
`zsh -i -c exit` must stay completely silent; any output from an rc file is a bug.

**Performance profiling**:
```zsh
bench-startup                   # Custom benchmarker (functions/bench-startup)
zsh-bench                       # Via romkatv/zsh-bench plugin
zprofrc                         # Fresh shell with zsh/zprof loaded (ZPROFRC=1)
optdiff                         # Which shell options this config changes, and who set each
cached-eval --list              # What tool-init output is cached
```

**Plugin management**:
```zsh
# Edit antidote_plugins.conf, then:
exec zsh                        # Auto-regenerates plugin cache
antidote list                   # Show installed plugins
antidote update                 # Update all plugins
```

**Debugging**:
```zsh
# Time startup — profile a FRESH shell. `zmodload zsh/zprof; source ~/.zshrc; zprof`
# in an already-initialized shell is unreliable: anything cached or guarded on the
# first run (the compdump, cached-eval output, the antidote static file) is warm.
zprofrc

# Check if command exists:
command -v tool_name            # Returns path or nothing
```

### Performance rules (critical for rc.d/*.zsh)

**Don't fork a tool's `init` on every startup** (from [.github/instructions/Improve Performance.instructions.md](instructions/Improve Performance.instructions.md)):
```zsh
# BAD: forks the tool on every shell start
eval "$(starship init zsh)"

# BEST here: cache the output to disk and source that instead. Used by
# rc.d/{starship,fzf,zoxide,zz-atuin}.zsh and by fnox in .zshrc.
cached-eval starship init zsh

# GOOD when the output ISN'T cacheable and isn't needed until first use:
rbenv() {
  eval "$(command rbenv init -)"
  rbenv "$@"
}

# DELIBERATE EXCEPTION: `mise activate` stays eager AND uncached. Its output embeds
# a snapshot of the generating shell's PATH, so caching it would freeze $PATH, and
# the shims must be on $path before anything resolves a binary.
(($+commands[mise])) && eval "$(mise activate zsh)"
```
Only wrap an init in `cached-eval` after verifying its output is invariant of `PATH`/`PWD`.

**Tool existence checks**:
```zsh
# BAD: Actually runs the tool
if gls &>/dev/null; then

# GOOD: Just checks PATH
if command -v gls >/dev/null 2>&1; then

# BEST: ZSH built-in (used in rc.d/fzf.zsh)
(($+commands[fzf])) || return 1
```

**Completion optimization**: `compinit` is owned by the ez-compinit plugin (cached; see `antidote_plugins.conf`) — never add a second one. `rc.d/03-completion.zsh` stamps `$fpath` next to the dump and drops the dump when it changes, so a newly added completion works on the next shell instead of up to 20h later.

**File patterns**: Use ZSH glob qualifiers: `(N)` nullglob, `(.)` regular files only, `:t` tail (basename) — e.g. `$ZFUNCDIR/*(.N:t)`. The `(N)` is mandatory: without it an empty directory aborts the whole rc file with "no matches found".

### Where to put things

| What | Where | Examples |
|------|-------|----------|
| Aliases | [rc.d/05-aliases.zsh](../rc.d/05-aliases.zsh) | `brewUp`, `caskz`, `jason`, `{cz.apply,chezA}` |
| Shell utilities | [rc.d/06-commands.zsh](../rc.d/06-commands.zsh) | `pg_start`, `pg_stop`, `pg_switch`, `delete_git_branches` |
| Standalone commands | `functions/*` | `grecent`, `is-macos`, `bench-startup`, `cached-eval`, `optdiff` |
| History settings | [rc.d/01-hist.zsh](../rc.d/01-hist.zsh) | `HISTFILE`, `SAVEHIST`, history options |
| Directory shortcuts | [rc.d/02_dirs.zsh](../rc.d/02_dirs.zsh) | `hash -d` definitions, `IWD`/`iwd` |
| Shell options (`setopt`) | [rc.d/04-opts.zsh](../rc.d/04-opts.zsh) | Single owner of every non-history `setopt`; check with `optdiff` |
| Completion for our own aliases | [rc.d/03-completion.zsh](../rc.d/03-completion.zsh) | `compdef g=git`; also the `$fpath` compdump stamp |
| Hand-written completion files | `completions/_<command>` | On `fpath`; see [completions/README.md](../completions/README.md) |
| Tool integrations | `rc.d/*.zsh` | `fzf.zsh`, `zoxide.zsh`, `starship.zsh`, `zz-atuin.zsh` |
| Plugins | `antidote_plugins.conf` | One plugin per line with annotations |

### External dependencies

**Required tools** (mostly installed via Homebrew):
- **Core**: antidote, fzf, zoxide, mise, starship
- **File tools**: eza, bat, ripgrep, fd, jq
- **Dev tools**: tmux, overmind, chezmoi, neovim, vscode-insiders
- **Shell history**: atuin (initialized in `rc.d/zz-atuin.zsh` — a binary, not an antidote plugin; needs the `atuin` binary)
- **Secrets**: fnox (installed via `mise`; age-encrypted; `fnox activate zsh` runs in `.zshrc` through `cached-eval`; the age identity comes from `$XDG_CONFIG_HOME/fnox/age.txt` by default — no env var holds it)
- **Tests**: zunit + revolver (`brew install zunit-zsh/zunit/zunit`), run via `mise run test`

**Version management**: `mise` handles Ruby, Node, Python, Postgres, etc. Activated in `.zshrc` with `eval "$(mise activate zsh)"`.

### Common patterns and anti-patterns

**✅ DO**:
- Use `${ZDOTDIR:-$HOME}` for config references
- Group related aliases with brace expansion
- Add fzf preview windows for interactive commands
- Check tool existence before defining wrappers
- Use numeric prefixes (01-, 02-) to control rc.d load order
- Keep functions focused on single responsibility

**❌ DON'T**:
- Run expensive commands at shell startup (use `cached-eval`, or a lazy-loading wrapper)
- Forget to set `#!/bin/zsh` in `functions/*` files
- Create rc.d files without considering alphabetical load order
- Use a tool-specific init (e.g., `rbenv init`) as a bare `eval "$( … )"`
- Add a second `compinit` (ez-compinit owns it)
- Hard-wrap prose in Markdown — write each paragraph as one physical line
- Edit `antidote_plugins.zsh` by hand (generated) — edit `antidote_plugins.conf`

### Key patterns from codebase

**Postgres version switching** ([rc.d/06-commands.zsh](../rc.d/06-commands.zsh)):
- Manages multiple mise-installed versions
- Stops current server, starts new one, updates mise global version
- Pattern useful for other version-managed services

**Interactive installers** ([rc.d/06-commands.zsh](../rc.d/06-commands.zsh)):
- `install_casks`: Fetches Homebrew API, uses fzf for selection with JSON preview
- Pattern: `curl API | jq | fzf --preview | xargs brew install`

**macOS defaults viewer** ([rc.d/06-commands.zsh](../rc.d/06-commands.zsh)):
- Lists all domains, preview with plistlib, export selected
- Shows advanced fzf preview with Python one-liner

Keep changes minimal, match existing naming, and favor interactive fzf flows when adding new commands.

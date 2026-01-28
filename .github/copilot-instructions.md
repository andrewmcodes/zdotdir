## Instructions

This repo is a modular ZSH setup for macOS powered by Homebrew, Antidote, fzf, zoxide, mise, and starship, with conventions codified across `rc.d/*` and `functions/*`.

### Architecture and load order
**Boot sequence** (critical for understanding where to add code):
1. `.zprofile` - Login shells (PATH setup, environment variables)
2. `.zshenv` - All shell types (minimal, fast-loading vars only)
3. `.zshrc` - Interactive shells (main config, loads everything else):
   - Sets up `path` and `fpath` arrays
   - Autoloads all functions from `functions/` directory
   - Sources `.zstyles` for antidote/completion configuration
   - Runs `antidote load` to source plugins from `antidote_plugins.conf`
   - Activates `mise` version manager
   - Sources all `rc.d/*.zsh` files alphabetically

**Plugin loading**: Antidote reads `antidote_plugins.conf` and generates static plugin code. Plugins use annotations like `kind:fpath`, `kind:defer`, `path:`, `conditional:is-macos`.

**Function auto-loading**: All files in `functions/` are added to `fpath` and autoloaded, making them available as commands without explicit sourcing.

**rc.d loading order matters**: Files load alphabetically, so `01-hist.zsh` loads before `05-aliases.zsh`. Use numeric prefixes to control sequence.

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
  - Must start with `#!/bin/zsh` shebang
  - Use `main() { ... }; main "$@"` pattern for proper argument handling
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
```

**Performance profiling**:
```zsh
functions/bench-startup         # Custom benchmarker
zsh-bench                       # Via romkatv/zsh-bench plugin
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
# Time rc.d file loading:
zmodload zsh/zprof
source ~/.zshrc
zprof

# Check if command exists:
command -v tool_name            # Returns path or nothing
```

### Performance rules (critical for rc.d/*.zsh)

**Lazy-loading expensive tools** (from [.github/instructions/Improve Performance.instructions.md](instructions/Improve Performance.instructions.md)):
```zsh
# BAD: Runs on every shell start
eval "$(rbenv init -)"

# GOOD: Defers until first use
rbenv() {
  eval "$(command rbenv init -)"
  rbenv "$@"
}
```

**Tool existence checks**:
```zsh
# BAD: Actually runs the tool
if gls &>/dev/null; then

# GOOD: Just checks PATH
if command -v gls >/dev/null 2>&1; then

# BEST: ZSH built-in (used in rc.d/fzf.zsh)
(($+commands[fzf])) || return 1
```

**Completion optimization**: Cache `compinit` to avoid expensive daily regeneration (see ez-compinit plugin in `antidote_plugins.conf`).

**File patterns**: Use ZSH glob qualifiers: `(N)` nullglob, `(.:t)` regular files only + tail (basename).

### Where to put things

| What | Where | Examples |
|------|-------|----------|
| Aliases | [rc.d/05-aliases.zsh](../rc.d/05-aliases.zsh) | `brewUp`, `caskz`, `jason`, `{cz.apply,chezA}` |
| Shell utilities | [rc.d/06-commands.zsh](../rc.d/06-commands.zsh) | `pg_start`, `pg_stop`, `pg_switch`, `delete_git_branches` |
| Standalone commands | `functions/*` | `grecent`, `is-macos`, `bench-startup` |
| History settings | [rc.d/01-hist.zsh](../rc.d/01-hist.zsh) | `HISTFILE`, `SAVEHIST`, history options |
| Directory shortcuts | [rc.d/02_dirs.zsh](../rc.d/02_dirs.zsh) | `hash -d` definitions |
| Tool integrations | `rc.d/*.zsh` | `fzf.zsh`, `zoixide.zsh`, `sharship.zsh` |
| Plugins | `antidote_plugins.conf` | One plugin per line with annotations |

### External dependencies

**Required tools** (installed via Homebrew):
- **Core**: antidote, fzf, zoxide, mise, starship
- **File tools**: eza, bat, ripgrep, fd, jq
- **Dev tools**: tmux, overmind, chezmoi, neovim, vscode-insiders

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
- Run expensive commands at shell startup (use lazy-loading)
- Use `source` inside functions (wastes time on every invocation)
- Forget to set `#!/bin/zsh` in `functions/*` files
- Create rc.d files without considering alphabetical load order
- Use tool-specific init (e.g., `rbenv init`) without lazy-loading wrapper

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

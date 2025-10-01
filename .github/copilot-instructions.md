# ZSH Configuration Instructions for AI Agents

This is a comprehensive ZSH configuration using Antidote plugin manager, focused on developer productivity with extensive aliases and modern command-line tools.

## Architecture & Key Components

### Plugin Management Flow
- **Antidote** manages all plugins via `antidote_plugins.conf`
- Plugins are automatically loaded in `.zshrc` with `antidote load`
- Configuration is modular via `rc.d/` directory structure

### Critical Files & Load Order
1. `.zprofile` - Environment setup (loaded once at login)
2. `.zshenv` - Environment variables (loaded for all ZSH sessions)
3. `.zshrc` - Interactive shell config that orchestrates everything:
   - Auto-loads functions from `functions/` directory
   - Sources `.zstyles` for completion and plugin configuration
   - Loads Antidote plugins
   - Sources all `rc.d/*.zsh` files in alphabetical order

### Modular Configuration Pattern (rc.d/)
Files in `rc.d/` are numbered for load order:
- `01_history.zsh` - History configuration (loaded first)
- `02_dirs.zsh`, `02_mise.zsh` - Core tool setup
- `aliases.zsh` - 100+ development aliases
- `commands.zsh` - Custom shell functions
- `fzf.zsh`, `zoixide.zsh` - Tool integrations
- `input.zsh` - Keybindings
- `sharship.zsh` - Prompt configuration

## Developer Workflow Patterns

### Multi-Language Version Management
Uses `mise` for all language versions. PostgreSQL switching is handled by custom functions:
```bash
pg_switch 13.3  # Switch between PostgreSQL versions
pg_start        # Start PostgreSQL server
pg_stop         # Stop PostgreSQL server
```

### Rails Development Conventions
Smart Rails command routing in `commands.zsh`:
- Checks for `bin/rails` first (modern Rails)
- Falls back to `bundle exec rails` if Gemfile exists
- Uses system Rails as last resort

### Interactive Tool Selection
Extensive use of `fzf` for interactive workflows:
- `grecent` - Interactive git branch switcher with commit info
- `delete_git_branches()` - Multi-select branch deletion
- `install_casks()` - Browse and install Homebrew casks
- `view_defaults()` - Explore macOS defaults domains

## Alias Patterns & Conventions

### Hierarchical Naming
- Base tools: `g` (git), `r` (rails), `b` (bundle), `y` (yarn)
- Actions with capital letters: `brewU` (upgrade), `brewX` (force uninstall)
- Multiple aliases for same command: `{cz.apply,chezA}="chezmoi apply"`

### Tool-Specific Patterns
- **Homebrew**: `brew*` prefix with action suffix (`brewi`, `brewu`, `brewUp`)
- **Cask**: `cask*` prefix mirroring Homebrew patterns
- **TMUX**: `tm*` prefix with capital action (`tmA`, `tmK`, `tmL`)
- **Git**: Single letter shortcuts (`ga`, `gc`, `gp`) + descriptive (`gundo`, `gwip`)

### File Management
Uses `eza` as `ls` replacement with consistent flag patterns:
- `ls`, `lsa` - Basic listing with icons
- `ll`, `la` - Long format with metadata
- `lt`, `lta` - Tree views
- `lx` - Extended attributes view

## Tool Integration Points

### FZF Configuration
- Default command uses `ripgrep` for file finding
- Custom preview commands for different contexts
- History stored in XDG-compliant location
- Color scheme matches overall theme

### Completion System
- Uses `fzf-tab` for fuzzy tab completion
- Custom preview handlers for different commands (`cd`, `systemctl`, `tldr`)
- Disabled special directory completion (`..`, `.`)

### Environment Dependencies
Critical external tools that must be installed:
- **antidote** - ZSH plugin manager (core requirement)
- **chezmoi** - Dotfiles manager with extensive aliases
- **fzf** - Fuzzy finder for interactive workflows
- **homebrew** - Package manager with brew*/cask* alias patterns
- **jq** - JSON processor for data manipulation

## Function Development Patterns

### Auto-loading Functions
All files in `functions/` are auto-loaded at shell startup. Functions should:
- Be executable shell scripts
- Include ZSH shebang at the top
- Follow single responsibility principle
- Use descriptive names (e.g., `is-macos` for OS detection)

### Error Handling in Commands
Custom functions use proper error checking:
```bash
# Example from pg_switch
if [ "$version_to_run" = "$currently_running_version" ]; then
  echo "Postgres $version_to_run is already running."
  return 1
fi
```

## Configuration Modification Guidelines

### Adding New Aliases
Add to `rc.d/aliases.zsh` following existing patterns:
- Group by tool/category
- Use consistent naming conventions
- Document complex aliases inline

### Adding New Plugins
1. Add to `antidote_plugins.conf` with appropriate `kind:` and `path:` options
2. Add any configuration to `.zstyles` if needed
3. Test with `antidote load` to regenerate plugin cache

### Environment Variables
- Tool-specific exports go in `.zprofile`
- Session-independent vars go in `.zshenv`
- Plugin configuration goes in `.zstyles`

## Performance Optimization Patterns

### Lazy Loading for Expensive Initialization
Replace eager tool initialization with lazy loading to improve shell startup time:
```zsh
# Instead of: eval "$(rbenv init -)"
# Use lazy loading:
rbenv() {
  eval "$(command rbenv init -)"
  rbenv "$@"
}
```

### Efficient Command Existence Checks
Use optimized command detection to avoid expensive subshells:
```zsh
# Instead of: if gls &>/dev/null; then
# Use: if command -v gls >/dev/null 2>&1; then
if command -v gls >/dev/null 2>&1; then
  alias ls="gls --color=auto"
fi
```

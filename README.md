# ZSH Dotfiles Configuration

A comprehensive ZSH configuration using [Antidote](https://getantidote.github.io/) plugin manager for an enhanced shell experience. This repository provides a complete setup with modern tools, productivity plugins, and an extensive collection of aliases for efficient command-line workflows.

## Overview

This ZSH configuration includes:
- **Plugin Management**: Antidote for fast, Git-based plugin management
- **Enhanced Navigation**: Directory jumping with zoxide, fuzzy finding with fzf
- **Syntax Highlighting**: Fast syntax highlighting for better readability
- **Auto-completion**: Enhanced tab completion with fzf integration
- **Version Management**: mise for managing programming language versions
- **Prompt**: Starship cross-shell prompt
- **Extensive Aliases**: 100+ aliases for common development tasks

## Tools and Dependencies

This configuration relies on the following external tools:

### Core Tools
- **[Homebrew](https://brew.sh/)** - Package manager for macOS
- **[Antidote](https://getantidote.github.io/)** - ZSH plugin manager
- **[fzf](https://github.com/junegunn/fzf)** - Fuzzy finder for command-line
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** - Smart directory jumper
- **[mise](https://mise.jdx.dev/)** - Multi-language version manager
- **[Starship](https://starship.rs/)** - Cross-shell prompt

### File and Text Tools
- **[eza](https://github.com/eza-community/eza)** - Modern replacement for ls
- **[bat](https://github.com/sharkdp/bat)** - Cat with syntax highlighting
- **[ripgrep (rg)](https://github.com/BurntSushi/ripgrep)** - Fast text search
- **[fd](https://github.com/sharkdp/fd)** - Fast find alternative
- **[jq](https://jqlang.github.io/jq/)** - JSON processor

### Development Tools
- **[Neovim](https://neovim.io/)** - Text editor (EDITOR)
- **[VS Code Insiders](https://code.visualstudio.com/insiders/)** - Visual editor (VISUAL)
- **[Chezmoi](https://www.chezmoi.io/)** - Dotfiles manager
- **[Overmind](https://github.com/DarthSim/overmind)** - Process manager
- **[tmux](https://github.com/tmux/tmux)** - Terminal multiplexer
- **[fnox](https://fnox.jdx.dev)** - age-encrypted secrets/env manager, installed via `mise` (activated in `.zshrc`; key sourced into `FNOX_AGE_KEY`)
- **[zunit](https://zunit.xyz)** - ZSH unit testing framework, used by `mise run test` (install via `brew install zunit-zsh/zunit/zunit`)

## ZSH Plugins

Plugins are managed via Antidote and configured in `antidote_plugins.conf`:

### Completions
- **[mattmc3/ez-compinit](https://github.com/mattmc3/ez-compinit)** - Easy completion initialization
- **[zsh-users/zsh-completions](https://github.com/zsh-users/zsh-completions)** - Additional completions
- **[aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab)** - Fuzzy tab completion
- **[MichaelAquilina/zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use)** - Alias reminder

### Core Features
- **[belak/zsh-utils](https://github.com/belak/zsh-utils)** - Completion styles, editor bindings, and utility functions
- **[zshzoo/macos](https://github.com/zshzoo/macos)** - macOS-specific utilities
- **[romkatv/zsh-bench](https://github.com/romkatv/zsh-bench)** - ZSH benchmarking
- **[ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)** - Extract plugin for archive handling

### Fish-like Features
- **[zdharma-continuum/fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)** - Syntax highlighting (deferred)
- **[zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** - Command auto-suggestions

## Shell History

Shell history is handled by **[atuin](https://github.com/atuinsh/atuin)** (SQLite-backed, searchable). It's a binary rather than an antidote plugin, so it's initialized in `rc.d/zz-atuin.zsh` (loaded after `fzf.zsh` so it owns `Ctrl-R` and the Up arrow). Requires the `atuin` binary. Run `atuin import auto` once to bring in existing shell history.

## Repository Structure

```
zdotdir/
├── .zshenv                # Environment variables for all ZSH sessions (sourced first)
├── .zprofile              # Login-shell setup (OrbStack init, Obsidian PATH)
├── .zshrc                 # Interactive shell configuration
├── .zstyles               # ZSH completion and plugin styles
├── antidote_plugins.conf  # Antidote plugin definitions (edit this)
├── antidote_plugins.zsh   # Generated static load file, sourced directly by .zshrc (do not edit by hand)
├── docs/
│   └── antidote.md        # Antidote usage and annotation reference
├── functions/             # Custom ZSH functions (auto-loaded, one per file)
│   ├── bench-startup
│   ├── calculate_actions_stats
│   ├── fetch_action_stats
│   ├── funcs              # Lists your own commands (run `funcs`)
│   ├── grecent
│   ├── is-macos
│   └── os
└── rc.d/                  # Modular configuration files
    ├── 01-hist.zsh        # History configuration
    ├── 02_dirs.zsh        # Directory stack configuration
    ├── 04-opts.zsh        # Shell options
    ├── 05-aliases.zsh     # All shell aliases
    ├── 06-commands.zsh    # Custom shell functions
    ├── fzf.zsh            # FZF integration
    ├── sharship.zsh       # Starship prompt setup
    ├── zoixide.zsh        # Zoxide directory jumper setup
    └── zz-atuin.zsh       # Atuin shell history (loads after fzf)
```

### Key Files
- **`.zshenv`** - Environment variables and XDG base dirs; sourced for every shell, before `.zprofile` and `.zshrc`
- **`.zprofile`** - Login-shell setup only (OrbStack init, Obsidian PATH)
- **`.zshrc`** - Main configuration file that loads plugins and sources rc.d files
- **`.zstyles`** - ZSH completion styling and antidote configuration
- **`antidote_plugins.conf`** - Defines all ZSH plugins to be loaded (the file you edit; `antidote_plugins.zsh` is generated)
- **`functions/`** - Custom shell functions auto-loaded at startup
- **`rc.d/`** - Modular configuration files for different aspects of the shell

## Installation

1. Install required tools via Homebrew:
   ```bash
   brew install antidote fzf zoxide mise starship eza bat ripgrep fd jq neovim atuin
   ```

2. Clone this repository to your ZSH directory:
   ```bash
   git clone https://github.com/andrewmcodes/zdotdir.git ~/.config/zsh
   ```

3. Set ZDOTDIR in your `~/.zshenv`:
   ```bash
   export ZDOTDIR="$HOME/.config/zsh"
   ```

## Testing

Unit tests are written with [zunit](https://zunit.xyz) and run through a [mise](https://mise.jdx.dev/) task.

1. Install zunit (and its `revolver` dependency):
   ```bash
   brew install zunit-zsh/zunit/zunit
   ```
2. Run the suite from the repo root:
   ```bash
   mise run test   # or: mise run t
   ```

Tests live in `tests/*.zunit` with configuration in `.zunit.yml`; `tests/_support/bootstrap` autoloads the functions under test. The suite focuses on the functions with real logic (`funcs`, `calculate_actions_stats`) — interactive and side-effecting commands are intentionally not covered.

## Functions Documentation

Custom shell functions live in two places: one file per function in `functions/`
(auto-loaded at startup) and inline definitions in `rc.d/06-commands.zsh`.

Run **`funcs`** to discover them at any time — it lists only your own commands
(with descriptions pulled from each function's leading comment) and hides private
helpers and plugin/zsh-internal functions. `funcs <pattern>` filters by name, and
`funcs | fzf` emits bare names for scripting. Because it reads the files directly,
any function you add shows up automatically as long as it has a leading comment.

| Function | Description |
|----------|-------------|
| `funcs` | List your own shell commands with descriptions (this command) |
| `bench-startup` | Measure interactive shell startup time using `time` and `hyperfine` if available |
| `os` | Start the Overmind process manager with the appropriate Procfile |
| `grecent` | Interactively check out a recent git branch via fzf |
| `is-macos` | Return success when running on macOS |
| `fetch_action_stats` | Fetch GitHub Actions run durations for a workflow |
| `calculate_actions_stats` | Compute avg/median from piped `fetch_action_stats` output |
| `mkcd` | Create a directory and `cd` into it |
| `pg_start` | Start the PostgreSQL server installed by mise |
| `pg_stop` | Stop the currently running PostgreSQL server |
| `pg_switch` | Switch the running PostgreSQL server to a given version |
| `delete_git_branches` | Interactively delete git branches via fzf |
| `install_casks` | Interactively install Homebrew casks via fzf |
| `print_path` | Pretty-print `$PATH`, one entry per line |
| `view_defaults` | Browse and export macOS `defaults` domains via fzf |

## Aliases Documentation

This document provides a comprehensive list of all available aliases organized by category.

## Navigation Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `....` | `cd ../../` | Navigate up two directory levels |
| `...` | `cd ../..` | Navigate up two directory levels |
| `..` | `cd ..` | Navigate up one directory level |
| `~` | `cd ~` | Navigate to home directory |

## Chezmoi Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cz.apply`, `chezA` | `chezmoi apply` | Apply chezmoi changes |
| `cz.diff`, `chezd` | `chezmoi diff` | Show chezmoi differences |
| `cz.edit`, `cheze` | `chezmoi edit` | Edit chezmoi files |
| `cz.readd`, `chezR` | `chezmoi re-add` | Re-add files to chezmoi |

## TMUX Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `tmA` | `tmux attach -t` | Attach to a tmux session |
| `tmK` | `tmux kill-session -t` | Kill a tmux session |
| `tmL` | `tmux ls` | List tmux sessions |
| `tmN` | `tmux new-session -s` | Create new tmux session |
| `tmS` | `tmux switch -t` | Switch tmux session |

## Yarn Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `y` | `yarn` | Yarn shortcut |
| `yA` | `yarn add` | Add package |
| `yAd` | `yarn add -D` | Add dev dependency |

## Homebrew Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `brewd` | `brew doctor` | Check system for potential problems |
| `brewi` | `brew install` | Install package |
| `brewI` | `brew info` | Show package info |
| `brewl` | `brew list` | List installed packages |
| `brewL` | `brew leaves` | List installed packages not dependencies |
| `brewo` | `brew outdated` | Show outdated packages |
| `brewr` | `brew reinstall` | Reinstall package |
| `brews` | `brew search` | Search packages |
| `brewS` | `brew services` | Manage brew services |
| `brewu` | `brew update` | Update brew |
| `brewU` | `brew upgrade` | Upgrade packages |
| `brewUp` | `brew update && brew upgrade && brew cleanup` | Full system update |
| `brewx` | `brew uninstall` | Uninstall package |
| `brewX` | `brew uninstall --force` | Force uninstall package |

## Cask Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `caski` | `brew install --cask` | Install cask |
| `caskl` | `brew list --cask` | List installed casks |
| `casko` | `brew outdated --cask` | Show outdated casks |
| `caskr` | `brew reinstall --cask` | Reinstall cask |
| `casks` | `brew search --cask` | Search casks |
| `caskU` | `brew upgrade --cask` | Upgrade casks |
| `caskx` | `brew uninstall --cask` | Uninstall cask |
| `caskX` | `brew uninstall --cask --force` | Force uninstall cask |
| `caskz` | `brew uninstall --cask --zap` | Zap uninstall cask |

## History Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `hisT` | `history | tail` | Show last few commands |
| `hisG` | `history | grep` | Search command history |

## Rails Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `r` | `rails` | Rails shortcut |
| `rc` | `rails console` | Rails console |
| `rDbc` | `rails dbconsole` | Database console |
| `rT` | `rails -T | awk '{print $2}' | fzf --preview 'rails {1} --help' | xargs -I {} rails {}` | Interactive task runner |
| `rdm` | `rails db:migrate` | Run pending migrations |
| `rG` | `rails generate` | Rails generator |
| `rR` | `rails routes` | List all routes |
| `rRg` | `rails routes -g` | Filter routes by grep |
| `rRc` | `rails routes -c` | Filter routes by controller |
| `rs` | `rails server` | Start Rails server |

## File Management Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `tree` | `eza --tree --git --group-directories-first` | Display directory tree |
| `ls` | `eza --icons --group-directories-first` | List files |
| `lsa` | `eza -a --icons --group-directories-first` | List all files |
| `lt` | `eza -T --group-directories-first --icons --git` | Tree view |
| `lta` | `eza -Ta --group-directories-first --icons --git` | Tree view (all files) |
| `ll` | `eza -lmh --group-directories-first --color-scale --icons` | Long list format |
| `la` | `eza -lamhg --group-directories-first --color-scale --icons --git` | Long list all files |
| `laa` | `eza -lamhg@ --group-directories-first --color-scale --icons --git` | Long list with extended attributes |
| `lx` | `eza -lbhHigUmuSa@ --group-directories-first --color-scale --icons --git --time-style=long-iso` | Detailed list |

## Git Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Git shortcut |
| `ga` | `git add` | Stage changes |
| `gb` | `git branch` | List branches |
| `gbd` | `git branch -d` | Delete branch |
| `gc` | `git commit` | Commit changes |
| `gcm` | `git commit -m` | Commit with message |
| `gco` | `git checkout` | Checkout |
| `gd` | `git diff` | Show changes |
| `gl` | `git log` | Show commit logs |
| `gp` | `git push` | Push changes |
| `gpf` | `git push --force-with-lease` | Force push (safely) |
| `gpl` | `git pull` | Pull changes |
| `gr` | `git rebase` | Rebase |
| `grbc` | `git rebase --continue` | Continue rebase |
| `gs` | `git status` | Show status |
| `gundo` | `git reset --soft HEAD~1` | Undo last commit |
| `gup` | `git pull --rebase` | Pull with rebase |
| `gupm` | `git pull --rebase origin main` | Pull main with rebase |
| `gwip` | `git add -A; git commit -m 'chore: wip'` | Commit work in progress |

## Utility Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cat` | `bat` | Enhanced cat with syntax highlighting |
| `fDir` | `fd -H --type d \| fzf \|\| echo .` | Interactive directory search |
| `dutiA` | `duti -v "${XDG_CONFIG_HOME:-$HOME/.config}/duti"` | Set default applications |
| `jason` | `pbpaste -Prefer txt \| jq . \| pbcopy` | Format clipboard JSON |
| `c` | `code .` | Open VS Code in current directory |
| `ci` | `code-insiders` | Open VS Code Insiders |
| `ci.` | `code-insiders .` | Open VS Code Insiders in current directory |

## Overmind Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `oC`, `oc` | `overmind connect` | Connect to Overmind process |
| `oCw`, `ocw` | `overmind connect web` | Connect to web process |
| `oK`, `ok` | `overmind kill` | Kill Overmind processes |
| `oRw` | `overmind restart web` | Restart web process |

## Heroku Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `heroRc` | `heroku run rails c` | Run Rails console on Heroku |
| `heroRC` | `heroku run rails c -a podia -- -- --noautocomplete` | Run Rails console on Heroku (Podia) |

## Bundle Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `b` | `bundle` | Bundle shortcut |
| `be` | `bundle exec` | Execute bundled command |
| `up` | `git pull && bundle check \|\| bundle && yarn && rails db:migrate` | Update project |
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
- **[fnox](https://fnox.jdx.dev)** - age-encrypted secrets/env manager, installed via `mise` (activated in `conf.d/01-fnox.zsh` through `cached-eval`). The age identity is read from `$XDG_CONFIG_HOME/fnox/age.txt`, which is the provider's default — no environment variable carries the key.
- **[zunit](https://zunit.xyz)** - ZSH unit testing framework, used by `mise run test` (install via `brew install zunit-zsh/zunit/zunit`)

## ZSH Plugins

Plugins are managed via Antidote and configured in `.zsh_plugins.txt`:

### Completions
- **[mattmc3/ez-compinit](https://github.com/mattmc3/ez-compinit)** - Easy completion initialization
- **[zsh-users/zsh-completions](https://github.com/zsh-users/zsh-completions)** - Additional completions
- **[aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab)** - Fuzzy tab completion
- **[MichaelAquilina/zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use)** - Alias reminder (deferred — it only has to exist by the first `preexec`)

### Core Features
- **[belak/zsh-utils](https://github.com/belak/zsh-utils)** - Completion styles, editor bindings, and utility functions
- **[zshzoo/macos](https://github.com/zshzoo/macos)** - macOS-specific utilities
- **[romkatv/zsh-bench](https://github.com/romkatv/zsh-bench)** - ZSH benchmarking
- **[ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)** - Extract plugin for archive handling (deferred; its `_extract` completion is still added to `fpath` eagerly)

### Fish-like Features
- **[zdharma-continuum/fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)** - Syntax highlighting (deferred, and **pinned** to a reviewed SHA — see the comment in `.zsh_plugins.txt`)
- **[zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** - Command auto-suggestions

Antidote is also configured (in `.zstyles`) to byte-compile the plugin files and the generated static loader, so each `source` reads a `.zwc` instead of re-parsing the script.

## Shell History

Shell history is handled by **[atuin](https://github.com/atuinsh/atuin)** (SQLite-backed, searchable). It's a binary rather than an antidote plugin, so it's initialized in `conf.d/zz-atuin.zsh` (loaded after `fzf.zsh` so it owns `Ctrl-R` and the Up arrow). Requires the `atuin` binary. Run `atuin import auto` once to bring in existing shell history.

## Startup Performance

Startup speed is a primary goal of this config, so tool integrations don't fork a subprocess on every shell start. `starship`, `fzf`, `zoxide`, `atuin` and `fnox` are initialized through **`cached-eval`**, which writes each tool's `init` output to `~/.cache/zsh/cached-eval/` and sources that instead, re-running the tool only when its binary changes or the 7-day TTL lapses (`cached-eval --list` / `--clear`).

`mise activate` is the deliberate exception: it stays eager and uncached, because its output embeds a snapshot of the generating shell's `PATH` and its shims must be on `$path` before anything resolves a binary.

`lib/zcompile.zsh` keeps the config's own startup files (`.zshenv`, `.zprofile`, `.zshrc`, `.zstyles`, `lib/*.zsh`, `conf.d/*.zsh`) byte-compiled, and `cached-eval` byte-compiles each cache file it writes, so a `source` reads a `.zwc` instead of re-parsing. The recompile is backgrounded and only happens when a file actually changed.

`conf.d/starship.zsh` clears `RPROMPT` unless `starship.toml` defines a `right_format`. Starship's init defines the right prompt unconditionally, which costs a second `starship prompt --right` fork on every redraw for output that renders nothing — measured at ~12ms of `command_lag` per command.

What is *not* fixable from here: the remaining per-prompt cost is one fork each for `starship prompt`, `mise hook-env` and `fnox hook-env`, all of which have to run for those tools to be correct. On a large repo the starship fork is dominated by `git_status`, and the levers for that are git-side (`core.untrackedCache`, `core.fsmonitor`, `git gc`) — see the comment in `conf.d/starship.zsh`.

Diagnostics:

```zsh
bench-startup     # startup-time benchmark (uses hyperfine when available)
zsh-bench         # romkatv/zsh-bench, on $PATH via the plugin
zprofrc           # fresh shell with zsh/zprof loaded, printing the profile at the end
optdiff           # which shell options this config changes, and which file set each
```

Profile a *fresh* shell with `zprofrc`, not a re-source — anything cached or guarded on the first run (the compdump, `cached-eval` output, the antidote static file) is already warm in an existing shell, so those numbers lie.

## Repository Structure

```
zdotdir/
├── .zshenv                # XDG base dirs, then hands off to .zprofile (every zsh)
├── .zprofile              # $path, $cdpath and every export (login shells; .zshenv sources it for the rest)
├── .zshrc                 # Interactive orchestrator — sources lib/, then conf.d/
├── .zstyles               # ZSH completion and plugin styles
├── .zsh_plugins.txt       # Antidote plugin definitions (edit this)
├── .zsh_plugins.zsh       # Generated static load file, sourced directly (do not edit by hand)
├── mise.toml              # mise tasks (`mise run test`)
├── .zunit.yml             # zunit test-runner configuration
├── lib/                   # Bootstrap steps, sourced explicitly and in order by .zshrc
│   ├── antidote.zsh       # Source antidote, regenerate + source the static bundle
│   ├── confd.zsh          # Source every conf.d/*.zsh in alphabetical order
│   └── zcompile.zsh       # Keep this config's own files byte-compiled
├── completions/           # Hand-written `_<command>` completion files, on $fpath
│   └── README.md          # What belongs here — and what doesn't
├── docs/
│   └── antidote.md        # Antidote usage and annotation reference
├── functions/             # Custom ZSH functions (auto-loaded, one per file)
│   ├── autoload-dir       # Put dirs on $fpath and autoload the function files in them
│   ├── bench-startup
│   ├── cached-eval        # Cache a tool's `init` output to disk (see below)
│   ├── calculate_actions_stats
│   ├── fetch_action_stats
│   ├── funcs              # Lists your own commands (run `funcs`)
│   ├── grecent
│   ├── is-macos
│   ├── optdiff            # Which shell options this config changes, and who set them
│   └── os
├── tests/                 # zunit suite (`mise run test`)
│   ├── *.zunit            # One suite per function under test
│   └── _support/          # bootstrap, fake tools, and fixture $ZDOTDIRs
└── conf.d/                # Config snippets, sourced alphabetically by lib/confd.zsh
    ├── 00-mise.zsh        # mise activate (eager and uncached, deliberately — must be first)
    ├── 01-fnox.zsh        # fnox activate (installed by mise, so it loads after it)
    ├── 02-history.zsh     # History configuration
    ├── 03-directories.zsh # Named directory shortcuts (hash -d ~name) and `iwd`
    ├── 04-completion.zsh  # Compdump invalidation + completion for our short aliases
    ├── 05-options.zsh     # Shell options (the single owner of every non-history setopt)
    ├── 06-aliases.zsh     # All shell aliases
    ├── 07-commands.zsh    # Custom shell functions
    ├── fzf.zsh            # FZF integration
    ├── starship.zsh       # Starship prompt setup
    ├── zoxide.zsh         # Zoxide directory jumper setup
    └── zz-atuin.zsh       # Atuin shell history (loads after fzf)
```

### Key Files
- **`.zshenv`** - Sourced for every zsh, scripts included. Sets the XDG base dirs, then sources `.zprofile` when the shell is not a login shell
- **`.zprofile`** - `$path`, `$cdpath`, and every exported variable. Login shells source it directly; everything else gets it via `.zshenv`, so a script sees the same environment an interactive shell does
- **`.zshrc`** - Orchestrator only: `.zstyles`, autoload `functions/`, then `lib/antidote.zsh`, `lib/confd.zsh`, `lib/zcompile.zsh`
- **`.zstyles`** - ZSH completion styling and antidote configuration
- **`.zsh_plugins.txt`** - Defines all ZSH plugins to be loaded (the file you edit; `.zsh_plugins.zsh` is generated)
- **`lib/`** - Bootstrap steps `.zshrc` sources by name, in a deliberate order
- **`functions/`** - Custom shell functions auto-loaded at startup
- **`completions/`** - Hand-written `_<command>` completion files, also on `$fpath`
- **`conf.d/`** - Modular configuration files for different aspects of the shell

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

Tests live in `tests/*.zunit` with configuration in `.zunit.yml`; `tests/_support/bootstrap` autoloads the functions under test. The suite is 36 tests over the four functions with real logic (`funcs`, `calculate_actions_stats`, `cached-eval`, `optdiff`) — interactive and side-effecting commands (fzf wrappers, `pg_*`, anything hitting `gh`/`brew`) are intentionally not covered.

## Functions Documentation

Custom shell functions live in two places: one file per function in `functions/` (auto-loaded at startup) and inline definitions in `conf.d/07-commands.zsh`.

Run **`funcs`** to discover them at any time — it lists only your own commands (with descriptions pulled from each function's `##?` docstring, falling back to its first ordinary comment line) and hides private helpers and plugin/zsh-internal functions. `funcs <pattern>` filters by name, and `funcs | fzf` emits bare names for scripting. Because it reads the files directly, any function you add shows up automatically as long as it has a leading comment.

The `##?` prefix is this config's docstring convention (borrowed from [mattmc3/zman](https://github.com/mattmc3/zman)); `#?` marks an explanatory note and `#*` an important one.

| Function | Description |
|----------|-------------|
| `funcs` | List your own shell commands with descriptions (this command) |
| `autoload-dir` | Put directories on `$fpath` and autoload the function files in them |
| `bench-startup` | Measure interactive shell startup time using `time` and `hyperfine` if available |
| `cached-eval` | Source a command's zsh output, caching it to disk so later shells skip the subprocess (`--list`, `--clear`) |
| `optdiff` | Show which shell options this config changes from a pristine zsh, and which file set each (`--plugins`, `--raw`) |
| `os` | Start the Overmind process manager with the appropriate Procfile |
| `grecent` | Interactively check out a recent git branch via fzf |
| `is-macos` | Return success when running on macOS |
| `fetch_action_stats` | Fetch GitHub Actions run durations for a workflow |
| `calculate_actions_stats` | Compute avg/median from piped `fetch_action_stats` output |
| `mkcd` | Create a directory and `cd` into it |
| `touchf` | Create files, making any missing parent directories along the way |
| `$` | No-op, so a `$ some-command` line pasted from a README just runs. **Documented by hand because `funcs` structurally cannot list it** — its scanner only matches names starting with `[A-Za-z_]` |
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
| `....` | `cd ../../..` | Navigate up three directory levels |
| `...` | `cd ../..` | Navigate up two directory levels |
| `..` | `cd ..` | Navigate up one directory level |
| `~` | `cd ~` | Navigate to home directory |
| `iwd` | `cd $IWD` | Back to the directory this shell started in |

## Chezmoi Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cz` | `chezmoi` | Chezmoi shortcut (completes like `chezmoi`) |
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
| `brewUp` | `brew update && brew upgrade && brew cleanup && brew link schpet/tap/linear` | Full system update (the relink keeps `linear` on `$PATH`) |
| `brewUpg` | same as `brewUp` but `brew upgrade --greedy` | Full system update, including auto-updating casks |
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
| `gb9` | `git for-each-ref --sort=-committerdate --count=9 …` | Nine most recently committed-to branches |
| `gbd` | `git branch -d` | Delete branch |
| `gc` | `git commit` | Commit changes |
| `gcm` | `git commit -m` | Commit with message |
| `gco` | `git checkout` | Checkout |
| `gcom` | `git checkout main` | Checkout main |
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
| `diff` | `${aliases[diff]:-diff} --color` | Colorized diff — *composed*, so a plugin's own `diff` flags survive |
| `gi` | `gem install` | Install a Ruby gem (not a git alias, despite the prefix) |
| `redis.s` | `redis-server --daemonize yes` | Start Redis in the background |
| `zprofrc` | `ZPROFRC=1 zsh` | Start a fresh shell with `zsh/zprof` loaded and dump the startup profile |
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



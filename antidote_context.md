# Antidote - High-Performance Zsh Plugin Manager

**Context file:** `antidote_context.md`
**Last updated:** December 2024
**Project version:** Latest (rolling release)
**Repository:** github.com/mattmc3/antidote

## Quick Reference

### Installation

````bash
# Git (recommended for development)
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# Homebrew (macOS/Linux)
brew install antidote

# Arch Linux
yay -S zsh-antidote
````

### Basic .zshrc Setup

````zsh
# Source antidote
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# Load plugins from ~/.zsh_plugins.txt
antidote load
````

For Homebrew installations:
````zsh
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load
````

### Plugin File Format (~/.zsh_plugins.txt)

````text
# Comments start with #
# One plugin per line, blank lines ignored

# Basic GitHub plugin (user/repo format)
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting

# With annotations
romkatv/zsh-bench kind:path
ohmyzsh/ohmyzsh path:plugins/git

# Deferred loading for slower plugins
zdharma-continuum/fast-syntax-highlighting kind:defer

# Framework plugins
ohmyzsh/ohmyzsh path:lib
ohmyzsh/ohmyzsh path:plugins/extract
````

## Core Concepts

### Performance-First Design

Antidote achieves speed through:
1. **Static file generation**: Plugins are bundled into a single static file
2. **Concurrent cloning**: Parallel git operations during initial setup
3. **Minimal runtime overhead**: Pre-computed plugin loading logic

### Plugin Loading Modes

**Dynamic Loading (Recommended)**
````zsh
antidote load  # Automatically bundles and sources plugins
````

**Static Loading (Advanced)**
````zsh
# Generate static file manually
antidote bundle ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh

# Source the static file
source ~/.zsh_plugins.zsh
````

**Ultra High Performance (Conditional Bundling)**
````zsh
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins

# Lazy-load antidote functions
fpath+=( ${ZDOTDIR:-~}/.antidote )
autoload -Uz $fpath[-1]/antidote

# Only regenerate if plugins.txt changed
if [[ ! $zsh_plugins.zsh -nt $zsh_plugins.txt ]]; then
  antidote bundle <$zsh_plugins.txt >|$zsh_plugins.zsh
fi

source $zsh_plugins.zsh
````

### Plugin Resolution

Plugins are cloned to: `$(antidote home)/<user>/<repo>`

Default cache location varies by OS:
- macOS: `~/Library/Caches/antidote`
- Linux: `~/.cache/antidote`

## Common Patterns

### Basic Plugin Management

````zsh
# Add plugin to plugins file
antidote install zsh-users/zsh-completions

# List all installed plugins
antidote list

# Get path to specific plugin
antidote path ohmyzsh/ohmyzsh

# Remove plugin
antidote purge zsh-users/zsh-autosuggestions

# Update antidote and all plugins
antidote update
````

### Kind Annotations

````text
# Default: sources *.plugin.zsh, *.zsh, *.sh, *.zsh-theme
user/repo

# Add to PATH (for executable tools)
user/repo kind:path

# Add to fpath only (for completions/prompts)
user/repo kind:fpath

# Clone but don't source (for manual loading)
user/repo kind:clone

# Defer loading (for slow/non-critical plugins)
user/repo kind:defer
````

### Framework Integration

**Oh-My-Zsh Plugins**
````text
# Load OMZ library
ohmyzsh/ohmyzsh path:lib

# Load specific plugins
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/docker

# Set ZSH variable if needed in .zshrc
export ZSH=$(antidote path ohmyzsh/ohmyzsh)
````

**Prezto Modules**
````text
sorin-ionescu/prezto path:modules/helper
sorin-ionescu/prezto path:modules/editor
````

### Branch Selection

````text
# Use non-default branch
user/repo branch:develop
user/repo branch:v2
````

### Subdirectory/File Targeting

````text
# Load specific subdirectory
user/repo path:src

# Load specific file
user/repo path:custom/script.zsh

# Combine with kind
user/repo path:bin kind:path
````

### Prompt Plugins

````text
# Add to fpath
sindresorhus/pure kind:fpath

# Then initialize in .zshrc after antidote load
autoload -Uz promptinit && promptinit && prompt pure
````

### Deferred Loading Example

````text
# Critical plugins load first
zsh-users/zsh-autosuggestions
zsh-users/zsh-completions

# Defer slower plugins
zdharma-continuum/fast-syntax-highlighting kind:defer
marlonrichert/zsh-autocomplete kind:defer
````

## Command Reference

### antidote load

Load all plugins from the plugins file.

````zsh
# Uses default ~/.zsh_plugins.txt
antidote load

# Use custom plugins file
antidote load /path/to/custom_plugins.txt
````

Add to `.zshrc` after sourcing `antidote.zsh`.

### antidote install

Add a plugin to your plugins file.

````zsh
# Add to default plugins file
antidote install user/repo

# Add to custom plugins file
antidote install user/repo ~/.custom_plugins.txt

# The plugin will be on the next line of the file
````

### antidote bundle

Generate static plugin file from plugins text file.

````zsh
# Generate to stdout
antidote bundle ~/.zsh_plugins.txt

# Save to file
antidote bundle ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh
````

**Note:** `antidote load` calls this internally. Only use directly for static loading patterns.

### antidote list

Show all cloned plugins with their paths.

````zsh
antidote list

# Example output:
# https://github.com/zsh-users/zsh-autosuggestions /Users/user/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions
````

### antidote path

Get the filesystem path for a plugin.

````zsh
antidote path user/repo

# Use in variable assignments
export ZSH=$(antidote path ohmyzsh/ohmyzsh)
export PURE_PATH=$(antidote path sindresorhus/pure)
````

### antidote home

Show the antidote cache directory.

````zsh
antidote home

# Clean all cached plugins
rm -rf $(antidote home)
````

### antidote purge

Remove a specific plugin from cache.

````zsh
antidote purge user/repo

# Manually remove from plugins file afterward
````

### antidote update

Update antidote and all plugins.

````zsh
antidote update

# Updates:
# 1. Antidote itself (if git-installed)
# 2. All cloned plugin repositories
````

## Configuration

### Environment Variables

````zsh
# Custom cache location (set before sourcing antidote)
export ANTIDOTE_HOME=~/.local/share/antidote

# Custom plugins file location
export ANTIDOTE_PLUGINS_FILE=~/.config/zsh/plugins.txt
````

### Zstyle Settings

````zsh
# Enable friendly directory names (recommended)
zstyle ':antidote:bundle' use-friendly-names 'yes'

# With friendly names: zsh-users__zsh-autosuggestions
# Without: https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions
````

Add this to `.zshrc` before `antidote load`.

### Default Locations

| Item | Default Location |
|------|------------------|
| Plugins file | `${ZDOTDIR:-$HOME}/.zsh_plugins.txt` |
| Static bundle | Generated in-memory by `antidote load` |
| Cache (macOS) | `~/Library/Caches/antidote` |
| Cache (Linux) | `~/.cache/antidote` |

## Troubleshooting

### Plugin Not Loading

1. **Check plugins file syntax**: One plugin per line, comments with `#`
2. **Verify plugin exists**: Check GitHub URL manually
3. **Regenerate bundle**: Remove cache and reload
   ````zsh
   antidote purge user/repo
   antidote load
   ````

### Slow Startup

1. **Use deferred loading** for non-critical plugins
   ````text
   slow-plugin kind:defer
   ````
2. **Measure with zsh-bench**
   ````zsh
   antidote install romkatv/zsh-bench kind:path
   zsh-bench
   ````
3. **Review plugin count**: Too many plugins = slower startup

### Cache Issues

````zsh
# Clear entire cache
rm -rf $(antidote home)

# Then reload
antidote load
````

### Completion Not Working

1. **Ensure completions load before compinit**
   ````zsh
   source ~/.antidote/antidote.zsh
   antidote load
   autoload -Uz compinit && compinit
   ````

2. **Check fpath**
   ````zsh
   echo $fpath
   # Should include antidote-managed paths
   ````

3. **Force completion rebuild**
   ````zsh
   rm -f ~/.zcompdump
   exec zsh
   ````

## Performance Benchmarking

Use `zsh-bench` for accurate measurements:

````text
romkatv/zsh-bench kind:path
````

````zsh
# Run benchmark
zsh-bench

# Compare different configurations by editing
# ~/.zsh_plugins.txt and running again
````

Typical well-configured setup: < 50ms startup time

## When to Fetch Full Docs

- **Framework integration patterns**: https://antidote.sh (see Oh-My-Zsh and Prezto sections)
- **Migrating from Antibody/Antigen**: Check migration guides at https://antidote.sh
- **Advanced performance tuning**: Review optimization examples at https://antidote.sh
- **Example configurations**: Reference zdotdir project at https://github.com/getantidote/zdotdir
- **Bug reports and features**: https://github.com/mattmc3/antidote/issues

## Anti-Patterns to Avoid

### ❌ Using Legacy `antidote init`

````zsh
# DON'T (deprecated)
antidote init

# DO
antidote load
````

### ❌ Manual Cache Management

````zsh
# DON'T manually manage plugin directories
mkdir $(antidote home)/...

# DO use antidote commands
antidote install user/repo
````

### ❌ Ignoring Friendly Names

````zsh
# DON'T use ugly cache names
# (makes debugging harder)

# DO enable friendly names
zstyle ':antidote:bundle' use-friendly-names 'yes'
````

### ❌ Loading Everything Eagerly

````text
# DON'T load all plugins immediately
slow-plugin-1
slow-plugin-2
heavy-framework

# DO defer non-critical plugins
essential-plugin-1
essential-plugin-2
slow-plugin-1 kind:defer
slow-plugin-2 kind:defer
````

### ❌ Not Using Path Annotations

````text
# DON'T source tool repositories
user/cli-tool

# DO use kind:path for executables
user/cli-tool kind:path
````

### ❌ Duplicate Plugin Loading

````zsh
# DON'T load plugins manually AND via antidote
source ~/some-plugin/plugin.zsh  # Manual
antidote load  # Also loads it via plugins file

# DO choose one method (prefer antidote)
antidote load
````

## Version Notes

Antidote follows a rolling release model. Major changes:

- **Friendly names**: Added zstyle option for readable cache directories
- **Performance**: Continuous improvements to bundling speed
- **Compatibility**: Maintained backward compatibility with Antibody plugin syntax

Check the changelog: https://github.com/mattmc3/antidote/releases

## Additional Resources

- **Example configuration**: https://github.com/getantidote/zdotdir
- **Antibody migration**: Antidote uses similar syntax; most plugins.txt files work as-is
- **Community support**: GitHub Issues for questions and bug reports

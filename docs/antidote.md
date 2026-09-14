Antidote is a Zsh plugin manager built from the ground up with performance in mind. This config uses [antidote](https://antidote.sh) **2.3.0**, installed via Homebrew. (`antidote` is a shell *function* from the sourced lib, not a binary, so `antidote -v` only works inside a shell that has loaded it — `brew list --versions antidote` is the reliable check.)

The antidote developer regularly publishes zsh-bench results in his [dotfiles repo](https://github.com/mattmc3/zdotdir).

## How this config uses antidote

The moving parts in this `$ZDOTDIR`:

| File | Role |
| --- | --- |
| `antidote_plugins.conf` | The plugins file (one bundle per line). This is the file you edit. |
| `antidote_plugins.zsh` | The generated static load file, sourced **directly** by `.zshrc`. **Do not edit by hand** — it's regenerated from the `.conf` whenever the `.conf` is newer (gitignored). |
| `.zstyles` | Sets the antidote zstyles (plugins file location, path style, etc.). |
| `.zshrc` | Sources antidote, then sources the static file directly (regenerating it only when the `.conf` changes). |

The static file name is derived from the plugins file name by swapping the extension, so `antidote_plugins.conf` always produces `antidote_plugins.zsh`.

## .zshrc

The simplest way to use antidote is to source it and call `antidote load`. For a bit more speed this config skips `antidote load`'s per-startup machinery and sources the static file directly, regenerating it only when the `.conf` changes (see [Ultra high performance install](#ultra-high-performance-install) for the rationale). The actual `.zshrc`:

```zsh
# .zshrc

# Source any zstyles first so antidote sees them (path style, plugins file, …).
[[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

# Source antidote (keeps the `antidote` command available for list/update/install).
#* Quoted with a fallback: HOMEBREW_PREFIX is only exported in .zshenv's darwin
#* branch, so a bare ${HOMEBREW_PREFIX} resolved to /opt/antidote/... elsewhere.
antidote_lib="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
[[ ! -r "$antidote_lib" ]] || source "$antidote_lib"
unset antidote_lib

# Regenerate the static file only when the .conf changed, then source it directly.
zsh_plugins=${ZDOTDIR:-$HOME}/antidote_plugins
#? `antidote` is a function from the lib above, not a binary — hence $+functions.
if (($+functions[antidote])) && [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.conf ]]; then
  antidote bundle <${zsh_plugins}.conf >|${zsh_plugins}.zsh
fi
[[ ! -r ${zsh_plugins}.zsh ]] || source ${zsh_plugins}.zsh
unset zsh_plugins

#* The generated loader emits `export PATH="…/zsh-bench:$PATH"`, and `typeset -gU
#* path` does NOT dedupe a scalar PATH= assignment — so zsh-bench accumulated a
#* second entry in nested shells. Reassigning the array re-applies uniqueness.
path=($path)
```

## .zstyles

antidote reads its configuration from zstyles. This config sets the following in `.zstyles` (which must be sourced **before** antidote bundles or sources any plugins):

```zsh
# Clone bundles under ~/.cache/repos instead of the default cache dir.
: ${ANTIDOTE_HOME:=${XDG_CACHE_HOME:-~/.cache}/repos}

# Use antidote_plugins.conf as the plugins file (overrides the default .zsh_plugins.txt).
zstyle ':antidote:bundle' file ${ZDOTDIR:-~}/antidote_plugins.conf

# Store clones as owner/repo instead of the escaped antibody-style path.
zstyle ':antidote:bundle' path-style 'short'

# Byte-compile the plugin files AND the generated static loader.
zstyle ':antidote:*' zcompile 'yes'
```

> `path-style 'short'` is the modern form; `use-friendly-names 'yes'` is a legacy alias for it (see [Path style](#path-style)).

### zcompile

`zstyle ':antidote:*' zcompile 'yes'` makes each `source` read a byte-compiled `.zwc` instead of re-parsing the script. The `:antidote:*` pattern is deliberately broad — it covers both `:antidote:bundle:<repo>` (the per-plugin files) and `:antidote:static` (the generated loader). Setting it for the static file also makes antidote emit a self-zrecompiling preamble into `antidote_plugins.zsh`, so the `.zwc` is refreshed whenever the loader is regenerated.

This is separate from `~/.cache/zsh/zcompdump.zwc`, which the `mattmc3/ez-compinit` plugin compiles itself.

## Ultra high performance install

This config does everything `antidote load` does on its own — the `.zshrc` above is a trimmed version of the snippet below. Sourcing the static file directly avoids `antidote load`'s per-startup freshness checks and zstyle lookups (measured at ~27ms on this machine — roughly half of antidote's in-shell startup cost). The fuller, more portable form:

```zsh
# ${ZDOTDIR:-~}/.zshrc

# Root name of the plugins files (.conf and .zsh) antidote will use.
zsh_plugins=${ZDOTDIR:-~}/antidote_plugins

# Ensure the plugins file exists so you can add plugins.
[[ -f ${zsh_plugins}.conf ]] || touch ${zsh_plugins}.conf

# Lazy-load antidote from its functions directory.
fpath=(${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/antidote/share/antidote/functions $fpath)
autoload -Uz antidote

# Regenerate the static file only when the plugins file changes.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.conf ]]; then
  antidote bundle <${zsh_plugins}.conf >|${zsh_plugins}.zsh
fi

# Source the static plugins file.
source ${zsh_plugins}.zsh
```

This boils down to the bare essentials and runs `antidote bundle` only when the `.conf` changes. The saving over `antidote load` is small in absolute terms (~27ms) but a meaningful share of startup once the heavier costs (subprocess forks, etc.) are removed.

## Usage

Antidote achieves its speed by doing all the work of cloning plugins up front and generating the code your `.zshrc` needs to source those plugins. Typically we do this via a plugins file.

## Plugins file

A plugins file is any text file with one plugin per line. This config's `antidote_plugins.conf` looks like this:

```text
# antidote_plugins.conf - comments begin with "#"

# Completions
mattmc3/ez-compinit
zsh-users/zsh-completions kind:fpath path:src
aloxaf/fzf-tab
MichaelAquilina/zsh-you-should-use kind:defer

# Completion styles — autoload the functions, then run setup afterward
belak/zsh-utils path:completion/functions kind:autoload post:compstyle_zshzoo_setup

# Keybindings / Utilities
belak/zsh-utils path:editor
belak/zsh-utils path:utility

# Load only on macOS
zshzoo/macos conditional:is-macos

# Put a tool on $PATH rather than sourcing it
romkatv/zsh-bench kind:path

# Pull a single plugin out of a framework (deferred — `extract` is interactive-only)
ohmyzsh/ohmyzsh path:plugins/extract kind:defer

# Fish-like features
zdharma-continuum/fast-syntax-highlighting kind:defer pin:cf318e06a9b7c9f2219d78f41b46fa6e06011fd9
zsh-users/zsh-autosuggestions
```

> Shell history is **not** an antidote plugin here — `atuin` is a binary, initialized in `rc.d/zz-atuin.zsh`.

Things to notice:

- **Basic bundles** are `owner/repo`. Bash plugins generally work too.
- **Empty lines and `#` comments are skipped.**
- **Annotations** (`kind:`, `path:`, `conditional:`, `post:`, `pin:`, …) tune how each bundle is treated — see below.
- **There is no shell expansion in this file.** `antidote bundle` reads it through a plain `<` redirect, so a `$VAR` or `~` in an annotation value is taken literally. Everything here must be spelled out.

If you followed the recommended install, your plugins are already loaded once `.zshrc` sources the static file.

To regenerate the static file manually you can run `antidote bundle` yourself. It only needs to run when you change the plugins file:

```zsh
# generate antidote_plugins.zsh
antidote bundle <antidote_plugins.conf >|"$ZDOTDIR/antidote_plugins.zsh"
```

Then source the generated file in your `.zshrc`:

```zsh
# .zshrc
source "$ZDOTDIR/antidote_plugins.zsh"
```

> To use `antidote bundle` this way, do **not** call `antidote init`. `antidote init` is a wrapper kept for backwards compatibility with antibody/antigen (dynamic mode) and is not recommended for new setups.

You can change antidote's home folder (where bundles are cloned). This config sets it to `~/.cache/repos`:

```zsh
export ANTIDOTE_HOME=~/.cache/repos
```

## Annotations

A few annotations cover most use cases. They're appended after the bundle, e.g. `owner/repo kind:defer path:plugins/foo`.

## Kind

The `kind` annotation determines how a bundle is treated. Supported values: `zsh` (default), `path`, `fpath`, `defer`, `clone`, `autoload`.

### kind:zsh

The default. antidote looks for files matching these globs and `source`s them:

- `*.plugin.zsh`
- `*.zsh`
- `*.sh`
- `*.zsh-theme`

Example:

```text
$ antidote bundle zsh-users/zsh-autosuggestions
fpath+=( "$HOME/.cache/repos/zsh-users/zsh-autosuggestions" )
source "$HOME/.cache/repos/zsh-users/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
```

### kind:path

`kind:path` just puts the plugin folder on your `$PATH`.

```text
$ antidote bundle romkatv/zsh-bench kind:path
export PATH="$HOME/.cache/repos/romkatv/zsh-bench:$PATH"
```

### kind:fpath

`kind:fpath` only puts the plugin folder on the `fpath`, doing nothing else. Useful for completion scripts that aren't meant to be sourced directly, or for prompts that support `promptinit`.

```text
$ antidote bundle zsh-users/zsh-completions kind:fpath path:src
fpath+=( "$HOME/.cache/repos/zsh-users/zsh-completions/src" )
```

### kind:autoload

`kind:autoload` adds the folder to `fpath` and `autoload`s every function file in it, but does not source anything. Useful for collections of autoloadable functions. Often paired with `post:` to run a setup function once the functions are available — as this config does for `belak/zsh-utils` completion styles:

```text
$ antidote bundle belak/zsh-utils path:completion/functions kind:autoload post:compstyle_zshzoo_setup
fpath+=( "$HOME/.cache/repos/belak/zsh-utils/completion/functions" )
builtin autoload -Uz $fpath[-1]/*(N.:t)
compstyle_zshzoo_setup
```

### kind:clone

`kind:clone` only clones the plugin, doing nothing else. Useful for managing a package that isn't used directly as a shell plugin.

```text
$ antidote bundle mbadolato/iTerm2-Color-Schemes kind:clone
```

### kind:defer

`kind:defer` defers loading of a plugin (via [romkatv/zsh-defer](https://github.com/romkatv/zsh-defer)). Useful for plugins you don't need right away or that are slow to load. [Use with caution.](https://github.com/romkatv/zsh-bench#deferred-initialization)

```text
$ antidote bundle zdharma-continuum/fast-syntax-highlighting kind:defer
if ! (( $+functions[zsh-defer] )); then
  fpath+=( "$HOME/.cache/repos/romkatv/zsh-defer" )
  source "$HOME/.cache/repos/romkatv/zsh-defer/zsh-defer.plugin.zsh"
fi
fpath+=( "$HOME/.cache/repos/zdharma-continuum/fast-syntax-highlighting" )
zsh-defer source "$HOME/.cache/repos/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
```

## Branch

Specify a branch to download if you don't want the default branch:

```text
$ antidote bundle zsh-users/zsh-autosuggestions branch:develop
fpath+=( "$HOME/.cache/repos/zsh-users/zsh-autosuggestions" )
source "$HOME/.cache/repos/zsh-users/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
```

## Path

Specify a subfolder or a specific file if the repo contains multiple plugins. This is especially useful for frameworks like [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh).

File example:

```text
$ antidote bundle ohmyzsh/ohmyzsh path:lib/clipboard.zsh
source "$HOME/.cache/repos/ohmyzsh/ohmyzsh/lib/clipboard.zsh"
```

Folder example:

```text
$ antidote bundle ohmyzsh/ohmyzsh path:plugins/extract
fpath+=( "$HOME/.cache/repos/ohmyzsh/ohmyzsh/plugins/extract" )
source "$HOME/.cache/repos/ohmyzsh/ohmyzsh/plugins/extract/extract.plugin.zsh"
```

## Conditional

`conditional:<function>` only loads the bundle if the named zero-argument function returns success. This config loads `zshzoo/macos` only on macOS:

```text
$ antidote bundle zshzoo/macos conditional:is-macos
if is-macos; then
  fpath+=( "$HOME/.cache/repos/zshzoo/macos" )
  source "$HOME/.cache/repos/zshzoo/macos/macos.plugin.zsh"
fi
```

The function must already be defined at load time (e.g. provided by an earlier bundle or an autoloaded function).

## Pre / Post

`pre:<command>` and `post:<command>` run a command immediately before / after the bundle's load script. `post:` is handy for setup that needs the bundle's functions to be available first (and is deferred along with the bundle when used with `kind:defer`). For example, to call a setup function once a bundle is loaded:

```text
owner/repo post:my_setup_function
```

This config uses `post:` to run `compstyle_zshzoo_setup` after autoloading the `belak/zsh-utils` completion functions — see the [kind:autoload example](#kindautoload).

## Autoload

The `autoload:<path>` annotation adds `<bundle>/<path>` to `fpath` and autoloads its functions **in addition to** the bundle's normal sourcing. (This differs from `kind:autoload`, which autoloads *instead of* sourcing.)

```text
$ antidote bundle owner/repo autoload:functions
```

## Pin

`pin:<sha>` locks a bundle to a specific commit. Pinned bundles are skipped by `antidote update`, so the pin is what turns "a third-party update runs new code at my next shell start" into a deliberate, reviewable edit.

```text
$ antidote bundle zsh-users/zsh-autosuggestions pin:85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
```

Two hard constraints, both proven the hard way:

1. **The SHA must be a literal.** `antidote bundle` reads the plugins file via a plain `<` redirect, so there is no shell expansion at all — `pin:$MY_SHA` is passed through verbatim and fails.
2. **It must be exactly 40 characters.** A short SHA (`pin:cf318e06`) is rejected; use the full hash.

This config pins `zdharma-continuum/fast-syntax-highlighting` — zdharma-continuum is a community fork of an abandoned org, i.e. exactly the account-takeover profile a pin exists for. To bump it, read the upstream diff, then edit the SHA in `antidote_plugins.conf`.

This is the same mechanism antidote uses for [snapshots](#snapshot).

## Path style

antidote names the directories under `$ANTIDOTE_HOME` according to the `path-style` zstyle:

```zsh
zstyle ':antidote:bundle' path-style 'short'
```

| Style | Example directory |
| --- | --- |
| `full` (default) | `$ANTIDOTE_HOME/github.com/zsh-users/zsh-autosuggestions` |
| `short` | `$ANTIDOTE_HOME/zsh-users/zsh-autosuggestions` |
| `escaped` | `$ANTIDOTE_HOME/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions` (antibody/antigen style) |

This config sets `short` directly:

```zsh
zstyle ':antidote:bundle' path-style 'short'   # legacy alias: use-friendly-names 'yes'
```

```text
$ antidote bundle zsh-users/zsh-autosuggestions
fpath+=( "$HOME/.cache/repos/zsh-users/zsh-autosuggestions" )
source "$HOME/.cache/repos/zsh-users/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
```

If you switch styles, antidote will reuse an existing clone under another style and clean up the old directory on the next bundle.

## Commands

```text
commands:
  bundle    Clone bundle(s) and generate the static load script
  install   Clone a new bundle and add it to your plugins file
  update    Update antidote and its cloned bundles
  purge     Remove a cloned bundle
  home      Print where antidote is cloning bundles
  list      List cloned bundles
  path      Print the path of a cloned bundle
  snapshot  Save, restore, or list bundle snapshots
  init      Initialize the shell for dynamic bundles (legacy)
```

## Home

See where antidote keeps the plugins with `home`:

```text
$ antidote home
/Users/andrew.mason/.cache/repos
```

You can wipe the entire thing if you want to start fresh or switch tools:

```zsh
rm -rf $(antidote home)
```

If you clear out your plugins, also remove the static file:

```zsh
rm "$ZDOTDIR/antidote_plugins.zsh"
```

## Install

Quickly add a plugin to your plugins file with `antidote install`:

```text
$ antidote install zsh-users/zsh-autosuggestions
Bundle 'zsh-users/zsh-autosuggestions' added to '$ZDOTDIR/antidote_plugins.conf'.
```

Reload zsh afterwards to load the plugin you just added.

## List

List the bundles cloned to your antidote home folder (format is `<path>` then `<url>`):

```text
$ antidote list
/Users/andrew.mason/.cache/repos/aloxaf/fzf-tab	https://github.com/aloxaf/fzf-tab
/Users/andrew.mason/.cache/repos/belak/zsh-utils	https://github.com/belak/zsh-utils
/Users/andrew.mason/.cache/repos/mattmc3/ez-compinit	https://github.com/mattmc3/ez-compinit
# ...
```

`antidote list` reports what is *cloned*, which is not necessarily what is *loaded* — clones outlive the bundle lines that created them. Anything here with no corresponding line in `antidote_plugins.conf` (and no `zsh-defer`-style indirect reference) is dead weight; `antidote purge owner/repo` removes it. `romkatv/zsh-defer` is the one clone with no bundle line that must stay — `kind:defer` pulls it in.

## Load

Use `antidote load` in your `.zshrc` to clone and source everything in your plugins file (default `${ZDOTDIR:-$HOME}/.zsh_plugins.txt`, or whatever `zstyle ':antidote:bundle' file` is set to):

```zsh
# .zshrc
# make a static plugins file and source it to load all your plugins
antidote load
```

It also takes parameters for a custom plugins file (and optional static file):

```zsh
# .zshrc
antidote load ${ZDOTDIR:-~}/myplugins.conf
```

## Path

See the path being used for a cloned bundle:

```text
$ antidote path ohmyzsh/ohmyzsh
/Users/andrew.mason/.cache/repos/ohmyzsh/ohmyzsh
```

This is useful for projects like oh-my-zsh that rely on storing their path in the `$ZSH` environment variable:

```text
$ ZSH=$(antidote path ohmyzsh/ohmyzsh)
```

## Purge

Remove a bundle completely by purging it:

```text
$ antidote purge ohmyzsh/ohmyzsh
Removing ohmyzsh/ohmyzsh...
```

You can also remove all antidote bundles and the static cache file to start fresh:

```zsh
$ rm -rf $(antidote home)
$ rm ${ZDOTDIR:-~}/antidote_plugins.zsh
```

## Update

Antidote can update itself and all bundles in a single pass:

```text
$ antidote update
Updating antidote...
Updating all bundles in /Users/andrew.mason/.cache/repos...
...
```

Bundles locked with `pin:` are skipped. In static mode, `antidote update` also writes a [snapshot](#snapshot) before updating so you can roll back.

## Snapshot

A snapshot is a bundle file where every repository is annotated with `kind:clone pin:<sha>`, capturing the exact commit of each cloned bundle — useful for reproducible setups and rollbacks.

```text
$ antidote snapshot save        # save a snapshot of current commits
$ antidote snapshot list        # list available snapshots
$ antidote snapshot restore     # restore the latest (or a given file)
$ antidote snapshot remove      # remove snapshot file(s)
$ antidote snapshot home        # print the snapshot directory
```

Snapshots are saved automatically during `antidote update` in static mode (not in dynamic mode). By default they live in `$XDG_DATA_HOME/antidote/snapshots` (`~/Library/Application Support/antidote/snapshots` on macOS), with a rolling history pruned beyond a configurable maximum.

## Performance Benchmarking

Use `zsh-bench` for accurate measurements. This config bundles it on `$PATH`:

```text
# antidote_plugins.conf
romkatv/zsh-bench kind:path
```

## Miscellaneous

### Help getting started

For a full-featured example Zsh configuration using antidote, see the [zdotdir](https://github.com/getantidote/zdotdir) project. You can incorporate code or plugins from it into your own dotfiles, or fork it to start a config from scratch.

Antidote is designed so it's easy to use subplugins contained within frameworks like [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh) and [Prezto](https://github.com/sorin-ionescu/prezto). For more on using antidote with Oh-My-Zsh, see [Using OMZ](https://antidote.sh/using-omz); for Prezto, see [Using Prezto](https://antidote.sh/using-prezto).

### Completions

For enabling Zsh completion features when using antidote, see the [completions](https://antidote.sh/completions) section. This config wires completions up with `mattmc3/ez-compinit` plus `zsh-users/zsh-completions kind:fpath path:src`.

### Troubleshooting

Having trouble with antidote? [See the troubleshooting tips here.](https://antidote.sh/troubleshooting)

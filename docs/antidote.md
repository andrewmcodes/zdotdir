Antidote is a Zsh plugin manager made from the ground up thinking about performance.

The antidote developer regularly publishes zsh-bench results in his [dotfiles repo](https://github.com/mattmc3/zdotdir).

## .zshrc

After installation, the recommended way to use antidote is to call the `antidote load` command from your `.zshrc`:

```
# now, simply add these two lines in your ~/.zshrc

# source antidote
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh

# initialize plugins statically with ${ZDOTDIR:-~}/antidote_plugins.conf
antidote load
```

## Ultra high performance install

If you want to squeeze every last drop of performance out of your antidote config, you can do all the things `antidote load` does for you on your own. If you’re fairly comfortable with zsh, this is a more robust `.zshrc` snippet you can use:

```
# ${ZDOTDIR:-~}/.zshrc

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins

# Ensure the antidote_plugins.conf file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(/path/to/antidote/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever antidote_plugins.conf is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh
```

This method boils down to the bare essentials and will run `antidote bundle` only if absolutely necessary. However, note that you’ll really only be saving small fractions of a second over calling the much simpler `antidote load` command directly.

## Usage

Antidote achieves its speed by doing all the work of cloning plugins up front and generating the code your `.zshrc` needs to source those plugins. Typically, we want to do this via a plugins file.

## Plugins file

A plugins file is basically any text file that has one plugin per line.

In our examples, let’s assume we have a `~/.antidote_plugins.conf` file with these contents:

```
# .antidote_plugins.conf - comments begin with "#"

# Basic Zsh plugins are defined in user/repo format
jeffreytse/zsh-vi-mode

# Bash plugins may also work
rupa/z

# empty lines are skipped

# annotations are also allowed:
romkatv/zsh-bench kind:path
olets/zsh-abbr    kind:defer

# set up Zsh completions with plugins
mattmc3/ez-compinit
zsh-users/zsh-completions kind:fpath path:src

# frameworks like oh-my-zsh are supported
getantidote/use-omz        # handle OMZ dependencies
ohmyzsh/ohmyzsh path:lib   # load OMZ's library
ohmyzsh/ohmyzsh path:plugins/colored-man-pages  # load OMZ plugins
ohmyzsh/ohmyzsh path:plugins/magic-enter

# or lighter-weight ones like Zephyr
mattmc3/zephyr path:plugins/editor
mattmc3/zephyr path:plugins/history
mattmc3/zephyr path:plugins/prompt
mattmc3/zephyr path:plugins/utility

# prompts:
#   with prompt plugins, remember to add this to your .zshrc:
#   \`autoload -Uz promptinit && promptinit && prompt pure\`
sindresorhus/pure     kind:fpath
romkatv/powerlevel10k kind:fpath

# popular fish-like plugins
mattmc3/zfunctions
zsh-users/zsh-autosuggestions
zdharma-continuum/fast-syntax-highlighting kind:defer
zsh-users/zsh-history-substring-search
```

Now that we have a plugins file, let’s look how can we load them!

If you followed the recommended install procedure, your plugins will already be loaded when you called `antidote load` in your `.zshrc`.

However, you could choose generate your static plugins file manually with `antidote bundle`. Basically, antidote will only need to run when you change your`antidote_plugins.conf` file. After you change this, use antidote to regenerate the static file.

Assuming the `antidote_plugins.conf` be created above, we can run:

```
# generate ~/.zsh_plugins.zsh
antidote bundle <~/antidote_plugins.conf >"$ZDOTDIR/.zsh_plugins.zsh"
```

We can run this at any time to update our static `.zsh_plugins.zsh` file, however if you followed the recommended install procedure you won’t need to do this yourself.

Finally, the static generated plugins file gets sourced in your `.zshrc`.

```
# .zshrc
source "$ZDOTDIR/.zsh_plugins.zsh"
```

_Note that to use `antidote bundle` this way, we will never want to call `antidote init`. **Be sure that’s not in your $ZDOTDIR/.zshrc**. `antidote init` is a wrapper provided for backwards compatibility for users familiar with antibody and antigen, but is no longer recommended._

You may also change Antidote’s home folder, for example:

```
export ANTIDOTE_HOME=~/.cache/antidote
```

## Options

There are a few options you can use that should cover most common use cases. Let’s take a look!

## Kind

The `kind` annotation can be used to determine how a bundle should be treated.

### kind:zsh

The default is `kind:zsh`, which will look for files that match these globs:

- `*.plugin.zsh`
- `*.zsh`
- `*.sh`
- `*.zsh-theme`

And `source` them.

Example:

```
$ antidote bundle zsh-users/zsh-autosuggestions kind:zsh
fpath+=( /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions )
source /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
```

### kind:path

The `kind:path` mode will just put the plugin folder in your `$PATH`.

Example:

```
$ antidote bundle romkatv/zsh-bench kind:path
export PATH="/Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-zsh-bench:$PATH"
```

### kind:fpath

The `kind:fpath` only puts the plugin folder on the fpath, doing nothing else. It can be especially useful for completion scripts that aren’t intended to be sourced directly, or for prompts that support `promptinit`.

Example:

```
$ antidote bundle sindresorhus/pure kind:fpath
fpath+=( /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-sindresorhus-SLASH-pure )
```

### kind:clone

The `kind:clone` only gets the plugin, doing nothing else. It can be useful for managing a package that isn’t directly used as a shell plugin.

Example:

```
$ antidote bundle mbadolato/iTerm2-Color-Schemes kind:clone
```

### kind:defer

The `kind:defer` option defers loading of a plugin. This can be useful for plugins you don’t need available right away or are slow to load. [Use with caution](https://github.com/romkatv/zsh-bench#deferred-initialization).

Example:

```
$ antidote bundle olets/zsh-abbr kind:defer
if ! (( $+functions[zsh-defer] )); then
  fpath+=( /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-zsh-defer )
  source /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-zsh-defer/zsh-defer.plugin.zsh
fi
fpath+=( /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-olets-SLASH-zsh-abbr )
zsh-defer source /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-olets-SLASH-zsh-abbr/zsh-abbr.plugin.zsh
```

## Branch

You can also specify a branch to download, if you don’t want the `main` branch for whatever reason.

Example:

```
$ antidote bundle zsh-users/zsh-autosuggestions branch:develop
fpath+=( /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions )
source /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
```

## Path

You may specify a subfolder or a specific file if the repo you are bundling contains multiple plugins. This is especially useful for frameworks like [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh).

File Example:

```
$ antidote bundle ohmyzsh/ohmyzsh path:lib/clipboard.zsh
source /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/lib/clipboard.zsh
```

Folder Example:

```
$ antidote bundle ohmyzsh/ohmyzsh path:plugins/magic-enter
fpath+=( /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/magic-enter )
source /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/magic-enter/magic-enter.plugin.zsh
```

## Friendly Names

You can also change how Antidote names the plugin directories by adding this to your`.zshrc`:

```
zstyle ':antidote:bundle' use-friendly-names 'yes'
```

Now, the directories where plugins are stored is nicer to read. For example:

`https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions` becomes `zsh-users__zsh-autosuggestions`.

```
$ antidote bundle zsh-users/zsh-autosuggestions
fpath+=( /Users/matt/Library/Caches/antidote/zsh-users__zsh-autosuggestions )
source /Users/matt/Library/Caches/antidote/zsh-users__zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
```

## Commands

Let’s look what other commands antidote has available for us!

## Home

You can see where antidote is keeping the plugins with the `home` command:

```
$ antidote home
/Users/andrew.mason/.cache/repos
```

Of course, you can remove the entire thing with:

```
rm -rf $(antidote home)
```

if you decide to start fresh or to use something else.

If you clear out your plugins, don’t forget to also run:

```
rm "$ZDOTDIR/.zsh_plugins.zsh"
```

## Install

You can quickly add a plugin to your plugins file with `antidote install`:

```
$ antidote install zsh-users/zsh-autosuggestions
Bundle 'zsh-users/zsh-autosuggestions' added to '$ZDOTDIR/antidote_plugins.conf'.
```

Don’t forget to reload zsh afterwards to load the plugin you just added!

## List

You can list the plugins you have cloned to your antidote home folder:

```
$ antidote list
https://github.com/zsh-users/zsh-autosuggestions                 /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions
https://github.com/zsh-users/zsh-history-substring-search        /Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-history-substring-search
# ...
```

## Load

You can use `antidote load` in your `.zshrc` to clone and source everything in your plugins file, which by default is `${ZDOTDIR:-$HOME}/antidote_plugins.conf`:

```
# .zshrc
# make a static plugins file and source it to load all your plugins
antidote load
```

It also takes a parameter if you prefer to use a custom plugins file:

```
# .zshrc
antidote load ${ZDOTDIR:-~}/myplugins.conf
```

## Path

You can see the path being used for a cloned bundle.

```
$ antidote path ohmyzsh/ohmyzsh
/Users/matt/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh
```

This is particularly useful for projects like oh-my-zsh that rely on storing its path in the `$ZSH` environment variable:

```
$ ZSH=$(antidote path ohmyzsh/ohmyzsh)
```

## Purge

You can remove a bundle completely by purging it:

```
$ antidote purge ohmyzsh/ohmyzsh
Removing ohmyzsh/ohmyzsh...
```

You can also remove all antidote bundles and the static cache file to start fresh:

```
$ rm -rf $(antidote home)
$ rm ${ZDOTDIR:-~}/.zsh_plugins.zsh
```

## Update

Antidote can update itself, and all bundles in a single pass.

Just run:

```
$ antidote update
Updating antidote...
Updating f6c4391..7b8d560
...
Updating all bundles in /Users/matt/Library/Caches/antidote...
...
```

## Performance Benchmarking

Use `zsh-bench` for accurate measurements:

```text
# antidote_plugins.conf
romkatv/zsh-bench kind:path
```

## Miscellaneous

## Help getting started

If you want to see a full-featured example Zsh configuration using antidote, you can have a look at the [zdotdir](https://github.com/getantidote/zdotdir) project. Feel free to incorporate code or plugins from it into your own dotfiles, or you can fork it to get started building your own Zsh config from scratch driven by antidote.

Antidote is designed in such a way that it’s easy to use subplugins contained within frameworks like [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh) and [Prezto](https://github.com/sorin-ionescu/prezto).

For more information about using antidote with Oh-My-Zsh, see the [Using OMZ](https://antidote.sh/using-omz) section. For Prezto, see the [Using Prezto](https://antidote.sh/using-prezto) section.

## Completions

For information about enabling Zsh completion features when using antidote, see the [completions](https://antidote.sh/completions) section.

## Troubleshooting

Having trouble with antidote? [see troubleshooting tips here](https://antidote.sh/troubleshooting).

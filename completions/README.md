# completions/

Hand-written completion functions, on `$fpath` via `.zshrc`.

One file per completion, named `_<command>`, with a `#compdef <command>` first line:

```zsh
#compdef mytool
_arguments '-v[verbose]' '*:file:_files'
```

Adding or removing a file here changes `$fpath`, which `rc.d/03-completion.zsh` detects — the completion dump is rebuilt on the next shell, so new completions work immediately.

Two things that do *not* belong here:

- **Aliases.** Use the `compdef name=service` form in `rc.d/03-completion.zsh` instead (e.g. `g=git`). The `#compdef name=service` file-tag form does not exist — `compinit`'s file tag only accepts names, `-p`/`-P` patterns, `-k` and `-K`.
- **Completions the tool already ships.** `mise`, `starship`, `git` and `chezmoi` all install real completion files into `$(brew --prefix)/share/zsh/site-functions`, which is already on `$fpath`. A copy here would shadow those and go stale.

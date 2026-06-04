---
applyTo: '**/rc.d/**'
---

Fix performance issues in the ZSH configuration files and shell scripts to improve shell startup time and responsiveness.

- Replace eager initialization with lazy loading
  - Instead of:
    ~~~zsh
    eval "$(rbenv init -)"
    ~~~
  - Use:
    ~~~zsh
    rbenv() {
      eval "$(command rbenv init -)"
      rbenv "$@"
    }
    ~~~

- Simplify expensive checks
  - Instead of:
    ~~~zsh
    if gls &>/dev/null; then
      alias ls="gls --color=auto"
    fi
    ~~~
  - Use:
    ~~~zsh
    if command -v gls >/dev/null 2>&1; then
      alias ls="gls --color=auto"
    fi
    ~~~

- Prefer hardcoded stable values over subprocess substitution
  - Instead of (forks `brew` on every shell, incl. scripts via `.zshenv`):
    ~~~zsh
    export HOMEBREW_PREFIX="$(brew --prefix)"
    ~~~
  - Use (the prefix is fixed on a given machine):
    ~~~zsh
    export HOMEBREW_PREFIX=/opt/homebrew
    ~~~

- Optimize `compinit`
  - Instead of always running:
    ~~~zsh
    autoload -Uz compinit
    compinit
    ~~~
  - Use cache-aware version:
    ~~~zsh
    autoload -Uz compinit
    if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump)" ]; then
      compinit
    else
      compinit -C
    fi
    ~~~

#!/bin/zsh
#
# mise - language/runtime version manager. Must run FIRST in conf.d: everything
#        after it (fnox, and any `(($+commands[…]))` guard) resolves binaries
#        through the shims this puts on $path.
#
#* Deliberately an EAGER, UNCACHED eval — the one exception to this config's
#* `cached-eval` rule. `mise activate zsh` output embeds `export PATH='<snapshot
#* of the generating shell's PATH>'` plus `unset GOBIN GOROOT LD_LIBRARY_PATH
#* PGDATA SNYK_TOKEN`, so caching it would freeze $PATH at whatever the cache was
#* built with. Lazy-loading it behind a wrapper is no better: the shims have to be
#* on $path before anything resolves a binary. Verified: mise's output changes
#* with PATH, while all five cached tools' output does not.
(($+commands[mise])) || return 0
eval "$(mise activate zsh)"

#!/bin/zsh
#
# fnox - age-encrypted per-project secrets. Installed via mise, so this must load
#        after conf.d/00-mise.zsh or the `$+commands` check inside cached-eval
#        never sees the shim.
#
#? Cached: fnox's activate output is static function + hook definitions, invariant
#? of PATH/PWD (verified). The precmd/chpwd hooks it installs must exist before
#? the first prompt, so this stays eager — just not a fork every startup.
#
#* No FNOX_AGE_KEY anywhere in this config: fnox's age provider already defaults
#* its identity to $XDG_CONFIG_HOME/fnox/age.txt, which is where the key lives.
#* Move the path with the provider's `key_file` field, not an env var.
cached-eval fnox activate zsh

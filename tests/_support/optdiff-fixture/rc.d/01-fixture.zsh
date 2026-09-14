#!/bin/zsh
#
# Fixture rc.d file for the optdiff tests. Each line below exercises one
# spelling that optdiff's attribution has to fold onto a canonical option name.
#

#? A commented-out setopt must be ignored entirely.
# setopt HIST_VERIFY

#? Underscores and case are insignificant; the trailing comment mentions a real
#? option name, which must NOT be attributed to this file.
setopt AUTO_CD              # promptsubst is only prose here

#? `setopt no_beep` and `unsetopt beep` describe the same option, `nobeep`.
setopt no_beep

#? nomatch is one of the few options genuinely named with a `no` prefix, so
#? unsetting it reads back as `nonomatch`.
unsetopt nomatch

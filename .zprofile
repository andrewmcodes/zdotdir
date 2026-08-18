#!/bin/zsh
#
# .zprofile - sourced for LOGIN shells only, after .zshenv and before .zshrc.
#
#* Not the entry point (that's .zshenv, which every shell reads, scripts included)
#* and not "loaded once" — a new login shell sources it again. Put something here
#* only if it must run once per login session; everything else belongs in .zshenv
#* (all shells) or .zshrc (interactive).
#

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

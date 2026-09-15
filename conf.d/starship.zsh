(($+commands[starship])) || return 1
#? Cached: `starship init zsh` output is invariant of PATH/PWD (verified), and
#? cached-eval rebuilds it when the binary changes or the TTL lapses.
#* This only saves the init fork. The per-PROMPT cost is elsewhere, and it is NOT
#* in starship's config — measured in ~podia (9.5 GB, 15,895 tracked files): the
#* prompt is ~90 ms, of which git_status is ~67 ms and everything else overlaps it
#* (starship runs modules concurrently, so disabling nodejs+ruby changed the wall
#* clock by 0). git_status is a `git status --porcelain=2` fork — starship shells
#* out to git whenever the repo sets core.fsmonitor, and uses its own gitoxide
#* implementation when it doesn't. Both levers are git-side, not starship-side:
#*   - core.untrackedCache  ~81 ms (74 ms vs 155 ms for `git status`)
#*   - core.fsmonitor       ~110 ms, indirectly — it is what routes starship to
#*                          the git binary; gitoxide takes 165 ms in ~podia
#* What is left is ~47 ms that EVERY git command in that repo pays before doing
#* any work: `git cat-file -e HEAD^{tree}` is 51 ms there vs 4.5 ms for
#* `git rev-parse HEAD`, because the object store has ~2,000 pack files and no
#* multi-pack-index. `git gc` in the repo is the fix, not anything in here.
cached-eval starship init zsh

#* starship's init defines RPROMPT unconditionally, so every prompt redraw pays a
#* second `starship prompt --right` fork even when the right prompt renders
#* nothing. Measured with zsh-bench: 121ms -> 109ms command_lag, for no visible
#* change. Only starship's `right_format` can produce a right prompt, so the
#* config file is the authoritative test — if one is ever added, the next
#* `exec zsh` picks it up and RPROMPT is left alone.
#? $(<file) is a builtin redirection, not a fork.
_starship_config=${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}
if [[ ! -r $_starship_config || "$(<$_starship_config)" != *right_format* ]]; then
  RPROMPT=''
fi
unset _starship_config

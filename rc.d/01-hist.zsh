#
# History
#
#* Shell options that aren't history-specific live in 04-opts.zsh, not here.

HISTFILE="$XDG_DATA_HOME/zsh/history.log"

# Just in case: If the parent directory doesn't exist, create it.
[[ -d $HISTFILE:h ]] || mkdir -p $HISTFILE:h
SAVEHIST=$((100 * 1000))
#* Arithmetic expansion, not `echo "1.2 * $SAVEHIST" | bc` — that was two forks
#* for a number we already know at parse time.
HISTSIZE=$(( SAVEHIST * 12 / 10 ))

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions (implies INC_APPEND_HISTORY).
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
#* SHARE_HISTORY appends every command as it's entered, so many concurrent shells
#* write this file constantly. Without HIST_FCNTL_LOCK zsh uses lock *files*, which
#* are slower and can leave stale locks behind; APFS supports fcntl locking properly.
setopt HIST_FCNTL_LOCK           # Use fcntl() to lock the history file, not lock files.

#? Dropped from this file (all verified no-ops or duplicates):
#?   EXTENDED_GLOB           - 04-opts.zsh already sets it; nothing between this
#?                             file and that one globs, so the early copy was dead
#?   appendhistory / notify  - already zsh defaults
#?   INC_APPEND_HISTORY      - implied by SHARE_HISTORY
#?   HIST_IGNORE_DUPS        - subsumed by HIST_IGNORE_ALL_DUPS
#?   unsetopt beep           - 04-opts.zsh sets `no_beep`, which loads later anyway
#?   unsetopt nomatch        - moved to 04-opts.zsh; it's a global globbing change,
#?                             not a history setting, and it was hidden here.

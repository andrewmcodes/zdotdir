#
# Input/Output Configuration
#
#* This file is the single owner of non-history shell options. If you're adding a
#* setopt, add it here — `optdiff` will show you what this config actually changes
#* from a pristine shell, including options that come from plugins rather than us.
#

# VI Mode
#? belak/zsh-utils path:editor binds all three keymaps (emacs, viins, vicmd) but
#? never selects one — this `bindkey -v` is what makes viins the main keymap, and
#? the plugin's viins bindings are already in place when it runs.
bindkey -v

#* Cut the 400ms ESC lag; zsh's default KEYTIMEOUT=40 is unusable in vi mode.
#* Not exported — ZLE reads it as a shell parameter, not an environment variable.
KEYTIMEOUT=1

#
# Directory Navigation
#
setopt AUTO_CD                # Change directory without cd command
setopt AUTO_PUSHD            # Make cd push directories to the stack
setopt PUSHD_IGNORE_DUPS     # Don't push duplicate directories
setopt PUSHD_SILENT          # Don't print the directory stack after pushd/popd
setopt PUSHD_TO_HOME         # pushd without args acts like pushd $HOME
setopt CD_SILENT             # Don't print working directory after cd

#
# Globbing and Completion
#
unsetopt case_glob           # Case-insensitive globbing
setopt globdots              # Include dotfiles in globbing
setopt EXTENDED_GLOB         # Extended globbing patterns for #, ~, and ^
setopt brace_ccl             # Allow brace character class list expansion
WORDCHARS=${WORDCHARS//[\/]/}  # Remove path separator from WORDCHARS

#* Moved here from 01-hist.zsh, where it was hidden among the history settings.
#* This is a GLOBAL globbing change, not a history one: an unmatched glob is
#* passed through to the command verbatim instead of erroring, so a typo'd
#* pattern reaches the command silently. Kept for now because `unsetopt nomatch`
#* is what makes things like `git show HEAD^` work without quoting.
unsetopt nomatch

#
# Input Behavior
#
setopt CORRECT              # Command spelling correction
setopt combining_chars      # Combine zero-length punctuation chars with base char
setopt rc_quotes            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'
setopt INTERACTIVE_COMMENTS # Allow # comments in interactive shell
setopt NO_CLOBBER           # Prevent accidental file overwrite with >
#* Loads after belak/zsh-utils' `setopt BEEP` (editor.plugin.zsh:14), so this wins.
setopt no_beep              # No beep on error

# Spelling correction prompt customization
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

#
# Job Control
#
setopt auto_resume          # Resume existing job before creating new process
setopt LONG_LIST_JOBS       # Verbose jobs listing
setopt NO_BG_NICE           # Don't reduce background job priority
setopt NO_CHECK_JOBS        # Don't check jobs on shell exit
setopt NO_HUP               # Don't send SIGHUP to jobs on shell exit

#? Dropped from this file (all verified no-ops against a pristine zsh 5.9.2):
#?   setopt notify           - NOTIFY is already on by default
#?   unsetopt mail_warning   - MAIL_WARNING is already off by default
#?   autoload -U colors      - legacy; nothing in this config reads $fg[]/
#?                             $reset_color, and SPROMPT uses %F{}/%f instead
#?   is-at-least 5.8 gate    - this box runs 5.9.2; CD_SILENT is unconditional now

##? mkcd - Create a directory and then change into it.
#? Single argument on purpose: `mkdir -p a b c && cd $_` would cd into `c` only,
#? which is never what you meant. Quote paths containing spaces.
function mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

#* Private (leading _ hides it from `funcs`): the running server's version, bare.
#* `show server_version` can answer `17.2 (Homebrew)`, which would never match a
#* mise install directory — so take the first word. `${=v}` word-splits, which
#* also strips psql's leading padding and replaces the old `| xargs` fork.
function _pg_running_version() {
  local v
  v=$(psql --no-psqlrc -t -c 'show server_version;' postgres) || return 1
  local -a words=(${=v})
  #* Must fail on empty output too, not just a non-zero psql. Returning 0 with an
  #* empty version made the callers' `|| return 1` guard pass and then build
  #* `.../installs/postgres//bin/pg_ctl`, which is not a real path.
  (( $#words )) || return 1
  print -r -- "${words[1]}"
}

##? pg_start - Start the PostgreSQL server at the version mise currently resolves.
##?
##? Reads the version from `mise which postgres`, then runs that install's `pg_ctl`
##? against its own data directory.
##?
##? Usage: pg_start
function pg_start {
  #? `:h:h:t` on .../installs/postgres/<version>/bin/postgres, not `awk -F/ '{print $9}'`
  #? — field 9 only lands on the version because $HOME happens to be 2 levels deep.
  local pg_bin version_to_run
  pg_bin=$(mise which postgres) || return 1
  version_to_run=${pg_bin:h:h:t}
  local pg_ctl_path="$HOME/.local/share/mise/installs/postgres/$version_to_run/bin/pg_ctl"
  local data_dir="$HOME/.local/share/mise/installs/postgres/$version_to_run/data"

  $pg_ctl_path -D $data_dir start
}

##? pg_stop - Stop the currently running PostgreSQL server.
##?
##? Asks the running server for its own version, then stops it with that install's
##? `pg_ctl` — so it works even when mise has since been pointed elsewhere.
##?
##? Usage: pg_stop
function pg_stop {
  #* Declared, then assigned. `local v=$(cmd) || return` cannot work: the exit
  #* status is `local`'s, which is 0 whatever the command substitution did.
  local currently_running_version
  currently_running_version=$(_pg_running_version) || return 1
  local pg_ctl_path="$HOME/.local/share/mise/installs/postgres/$currently_running_version/bin/pg_ctl"
  local data_dir="$HOME/.local/share/mise/installs/postgres/$currently_running_version/data"

  $pg_ctl_path -D $data_dir stop
}

##? pg_switch - Switch the running PostgreSQL server to another installed version.
##?
##? Stops the running server, starts the requested one, and re-pins the global mise
##? version so `psql` shims to the matching install.
##?
##? Usage: pg_switch <version>     # e.g. pg_switch 17.2
function pg_switch {
  local version_to_run=$1
  #* Validate the argument BEFORE stopping anything. Without this, `pg_switch`
  #* with no argument compared "" against the running version, decided they
  #* differed, stopped the server, then ran a nonexistent
  #* `.../installs/postgres//bin/pg_ctl … start` and `mise use -g postgres@` —
  #* leaving no server running and a bogus global pin.
  if [[ -z $version_to_run ]]; then
    print -u2 -- 'usage: pg_switch <version>'
    return 2
  fi
  #* Declared, then assigned — see the note in pg_stop.
  local currently_running_version
  currently_running_version=$(_pg_running_version) || return 1

  if [[ "$version_to_run" == "$currently_running_version" ]]; then
    echo "Postgres $version_to_run is already running."
    return 1
  fi

  # TODO: Use notificator to display a notification when switching versions
  echo "Switching from $currently_running_version to $version_to_run"

  local current_pg_ctl_path="$HOME/.local/share/mise/installs/postgres/$currently_running_version/bin/pg_ctl"
  local current_data_dir="$HOME/.local/share/mise/installs/postgres/$currently_running_version/data"
  local new_pg_ctl_path="$HOME/.local/share/mise/installs/postgres/$version_to_run/bin/pg_ctl"
  local new_data_dir="$HOME/.local/share/mise/installs/postgres/$version_to_run/data"

  # Stop the currently running postgres server
  $current_pg_ctl_path -D $current_data_dir stop

  # Start the new postgres server
  $new_pg_ctl_path -D $new_data_dir start

  # Switch the global mise version to ensure `psql` is shimmed to the correct version-directory
  mise use -g postgres@$version_to_run
}

##? delete_git_branches - Pick local git branches with fzf and delete them.
#* `git for-each-ref` rather than `git branch`: it emits bare names, so there is
#* no `* `/`+ ` prefix to strip and no `(HEAD detached at ...)` pseudo-entry. The
#* awk filter handles both a branch name containing regex metacharacters and an
#* empty $current (detached HEAD), either of which broke the old grep pipeline.
function delete_git_branches() {
  local current
  current=$(git branch --show-current)
  git for-each-ref --format='%(refname:short)' refs/heads/ |
    awk -v cur="$current" 'cur == "" || $0 != cur' |
    fzf --multi --preview="git log {} --" |
    xargs git branch --delete --force
}

##? install_casks - Pick Homebrew casks with fzf and install them.
#? -fsSL: without it curl pipes its progress meter into jq and fails silently on
#? an HTTP error instead of reporting it.
function install_casks() {
  curl -fsSL "https://formulae.brew.sh/api/cask.json" |
    jq '.[].token' |
    tr -d '"' |
    fzf --multi --preview="curl https://formulae.brew.sh/api/cask/{}.json | jq '.'" |
    xargs brew install --cask
}

##? print_path - Print $PATH one entry per line.
#? `print -l` over `echo -e`: no escape-interpretation surprises in path names.
function print_path() {
  print -l -- ${(s.:.)PATH}
}

##? view_defaults - Pick a macOS defaults domain with fzf and export it to a .plist.
function view_defaults() {
  defaults domains |
    sed 's/$/, NSGlobalDomain/' |
    tr -d ',' |
    tr ' ' '\n' |
    fzf --preview="defaults export {} - | python3 -c \"import sys,plistlib,pprint; pprint.pprint(plistlib.loads(sys.stdin.read().encode('utf-8')))\"" |
    xargs -n1 -I{} sh -c 'defaults export $1 - > $1.plist' -- {}
}

##? touchf - Create files, making any missing parent directories along the way.
#? ${f:h} is zsh's dirname; for a bare filename it yields `.`, and `mkdir -p .` is a
#? harmless no-op, so bare names need no special-casing.
function touchf() {
  (( $# )) || { print -u2 -- 'usage: touchf <file>...'; return 1; }
  local f
  for f in "$@"; do
    mkdir -p -- "${f:h}" && touch -- "$f"
  done
}

##? $ - A no-op `$` so a `$ some-command` line pasted from a README just runs.
#? Must be written as `function $` — `$() { ... }` parses as a command substitution.
#* Only the *command* position is affected; $VAR / $(cmd) expansion is untouched,
#* since parameter expansion happens before command lookup.
function $ {
  "$@"
}

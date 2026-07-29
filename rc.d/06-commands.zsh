#* Creates a directory and then changes into it
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
  print -r -- "${words[1]}"
}

# Starts the PostgreSQL server using the version installed by mise.
#
# This function determines the version of PostgreSQL to run by using the `mise which postgres`
# command and extracting the version from the output. It then uses `pg_ctl` to start the
# PostgreSQL server with the appropriate data directory.
#
# Arguments: None
# Outputs: None
# Example: pg_start
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

# Stops the currently running PostgreSQL server.
#
# This function determines the currently running PostgreSQL version by querying
# the server and then uses the `pg_ctl` command to stop the server.
#
# Arguments: None
# Outputs: None
# Example: pg_stop
# Note: Ensure that the specified PostgreSQL versions are installed and properly configured in the expected directories.
function pg_stop {
  local currently_running_version=$(_pg_running_version) || return 1
  local pg_ctl_path="$HOME/.local/share/mise/installs/postgres/$currently_running_version/bin/pg_ctl"
  local data_dir="$HOME/.local/share/mise/installs/postgres/$currently_running_version/data"

  $pg_ctl_path -D $data_dir stop
}

# pg_switch switches the running PostgreSQL server to the specified version.
#
# This function stops the currently running PostgreSQL server and starts the
# specified version. It also updates the global `mise` version to ensure that
# `psql` is shimmed to the correct version-directory.
#
# Args:
#   version_to_run: The version of PostgreSQL to switch to.
# Returns: 1 if the specified version is already running, otherwise nothing.
# Example: pg_switch 13.3
function pg_switch {
  local version_to_run=$1
  local currently_running_version=$(_pg_running_version) || return 1

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

# Deletes selected git branches using fzf for interactive selection.
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

# Installs selected Homebrew formulae using fzf for interactive selection.
#? -fsSL: without it curl pipes its progress meter into jq and fails silently on
#? an HTTP error instead of reporting it.
function install_casks() {
  curl -fsSL "https://formulae.brew.sh/api/cask.json" |
    jq '.[].token' |
    tr -d '"' |
    fzf --multi --preview="curl https://formulae.brew.sh/api/cask/{}.json | jq '.'" |
    xargs brew install --cask
}

# Pretty print the PATH variable with each path on a new line.
#? `print -l` over `echo -e`: no escape-interpretation surprises in path names.
function print_path() {
  print -l -- ${(s.:.)PATH}
}

# This function, view_defaults, lists all macOS user defaults domains,
# allows the user to interactively select one using fzf, and then exports
# the selected domain's settings to a .plist file.
function view_defaults() {
  defaults domains |
    sed 's/$/, NSGlobalDomain/' |
    tr -d ',' |
    tr ' ' '\n' |
    fzf --preview="defaults export {} - | python3 -c \"import sys,plistlib,pprint; pprint.pprint(plistlib.loads(sys.stdin.read().encode('utf-8')))\"" |
    xargs -n1 -I{} sh -c 'defaults export $1 - > $1.plist' -- {}
}

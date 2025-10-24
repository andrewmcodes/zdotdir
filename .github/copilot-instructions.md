## Instructions

This repo is a modular ZSH setup for macOS powered by homebrew, Antidote, fzf, zoxide, and starship, with conventions codified across `rc.d/*` and `functions/*`.

### Architecture and load order
- Plugins: declared in `antidote_plugins.conf`, loaded from `.zshrc` via `antidote` (cache-aware).
- Core files load in this order: `.zprofile` (login), `.zshenv` (all shells), `.zshrc` (interactive).
- Modular config: everything under `rc.d/` loads alphabetically (e.g., `01_history.zsh`, `02_dirs.zsh`, `mise.zsh`, `fzf.zsh`, `sharship.zsh`, `zoixide.zsh`).
- Custom functions live in `functions/` and are auto-available (e.g., `grecent`, `is-macos`, `bench-startup`).

### Conventions you should follow
- Add aliases in `rc.d/05-aliases.zsh`; mirror existing patterns:
  - Homebrew: `brewi`, `brewU`, `brewX`; Casks: `caski`, `caskU`, `caskX`.
  - TMUX: `tmA`, `tmK`, `tmL`; Chezmoi grouped aliases like `{cz.apply,chezA}`.
  - Git: terse + descriptive (`ga`, `gupm`, `gundo`, `gwip`).
- Add shell functions in `rc.d/06-commands.zsh` or `functions/*` with ZSH shebang and single responsibility.
- Prefer fzf-based UX for interactive tasks (see `delete_git_branches`, `install_casks`, `view_defaults` in `06-commands.zsh`).
- Rails wrapper in `06-commands.zsh` resolves to `bin/rails` → `bundle exec rails` → system `rails`.
- Postgres helpers use `mise` layout: `pg_start`, `pg_stop`, `pg_switch <version>`.

### Development workflow (what to run)
- Reload after edits: start a new shell or `exec zsh` to apply changes.
- Measure startup: run `functions/bench-startup` (or `zsh-bench` plugin if configured).
- Antidote plugins: update `antidote_plugins.conf`, then reload the shell; use `antidote` to refresh cache.

### External tools expected (from README)
Homebrew, Antidote, fzf, zoxide, mise, starship, eza, bat, ripgrep, fd, jq, tmux, overmind, chezmoi, Neovim/VS Code.

### Performance rules (apply to rc.d/*)
- Lazy-load expensive init; example: wrap rbenv with a function that inits on first use.
- Prefer `command -v tool >/dev/null 2>&1` over running the tool to check existence.
- Make `compinit` cache-aware; only rebuild when `.zcompdump` is stale.
  (See `.github/instructions/Improve Performance.instructions.md`.)

### Editing tips and examples
- Where to put things:
  - Prompt: `rc.d/sharship.zsh` (starship config hook).
  - FZF settings: `rc.d/fzf.zsh`.
  - Directory/navigation: `rc.d/02_dirs.zsh`, `rc.d/zoixide.zsh`.
- Example references:
  - Aliases: `rc.d/05-aliases.zsh` (e.g., `brewUp`, `caskz`, `jason`).
  - Functions: `rc.d/06-commands.zsh` (`rails`, `pg_switch`, `view_defaults`).

Keep changes minimal, match existing naming, and favor interactive fzf flows when adding new commands.

## mise (version manager) performance optimization
## Previous implementation eagerly ran: eval "$(~/.local/bin/mise activate zsh)"
## This adds ~40-80ms (or more) to startup. We switch to a lazy loader.
## Strategy:
##  - Ensure the shims directory is on PATH (cheap) so shimmed tools work
##  - Defer full environment + completions setup until the first 'mise' invocation
##  - After first call, replace the stub with the real 'mise' (binary) and forward args

# Abort early if mise executable isn't present.
if ! command -v mise >/dev/null 2>&1; then
	return 1
fi

# Prepend shims path (very lightweight) so tools installed via mise are available immediately.
_mise_shims_dir="${HOME}/.local/share/mise/shims"
if [ -d "${_mise_shims_dir}" ]; then
	# Avoid duplicate insertion
	case ":$PATH:" in
		*":${_mise_shims_dir}:"*) ;;
		*) PATH="${_mise_shims_dir}:$PATH" ;;
	esac
fi
unset _mise_shims_dir

# Lazy activation function
mise() {
	# If already activated elsewhere, just exec the real command
	if [ -n "${MISE_SHELL:-}" ]; then
		command mise "$@"
		return $?
	fi

	# Remove this stub to avoid recursion, then activate
	unset -f mise
	# Perform activation (redirect stderr to avoid noisy output on some versions)
	eval "$(command mise activate zsh 2>/dev/null)"

	# Fallback: if activation failed, ensure we still can call the binary
	if ! command -v mise >/dev/null 2>&1; then
		echo "mise: activation failed (binary not found after activation)" >&2
		return 127
	fi

	# Delegate to real mise
	command mise "$@"
}

# Provide completion stub only if compdef exists and completion not already initialized.
if typeset -f compdef >/dev/null 2>&1; then
	# Defer actual completion generation until after activation; stub triggers activation first.
	_mise_completion() {
		# Force activation (defines real completion), then re-dispatch
		mise __complete "$words[@]" >/dev/null 2>&1 || true
		unset -f _mise_completion
		# After activation, if completion function got defined by mise, reuse it
		if typeset -f _mise_completion >/dev/null 2>&1; then
			_mise_completion "$@"
		fi
	}
	compdef _mise_completion mise 2>/dev/null || true
fi

# NOTE: If you prefer eager activation (e.g., for prompt integrations),
# export MISE_EAGER=1 before starting zsh and uncomment below:
# if [ -n "${MISE_EAGER:-}" ]; then
#   mise >/dev/null 2>&1 || true
# fi

## zoxide performance optimization
## Previous: unconditional eval "$(zoxide init zsh)" on every interactive shell
## Approach: install a lightweight wrapper for `z`/`zi`/`__zoxide_z` that triggers
##           one-time init on first invocation. This defers parsing cost until used.

if ! command -v zoxide >/dev/null 2>&1; then
	return 1
fi

_zoxide_lazy_init() {
	# Remove stubs to avoid recursion
	unset -f _zoxide_lazy_init z zi __zoxide_z __zoxide_zi 2>/dev/null
	# Perform init quietly (stderr suppressed to avoid transient warnings)
	eval "$(command zoxide init zsh 2>/dev/null)"
	# Fallback safety: ensure binary is callable
	if ! command -v zoxide >/dev/null 2>&1; then
		echo "zoxide: init failed" >&2
		return 127
	fi
}

# Primary jump commands (common aliases) — create thin stubs
z() {
	_zoxide_lazy_init
	command z "$@"
}
zi() {
	_zoxide_lazy_init
	command zi "$@"
}

# zoxide init normally defines these helper functions; provide stubs
__zoxide_z() {
	_zoxide_lazy_init
	__zoxide_z "$@"  # now real one
}
__zoxide_zi() {
	_zoxide_lazy_init
	__zoxide_zi "$@"
}

# Optional eager enable if env var set
if [ -n "${ZOXIDE_EAGER:-}" ]; then
	_zoxide_lazy_init >/dev/null 2>&1 || true
fi

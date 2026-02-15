#!/usr/bin/env bash
# Unit tests for ZSH configuration files
# These tests verify the structure and content of configuration files

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/../test_helpers.sh"

run_test_suite "ZSH Configuration Files"

# Test main configuration files exist
assert_file_exists ".zshrc exists" "$REPO_ROOT/.zshrc"
assert_file_exists ".zshenv exists" "$REPO_ROOT/.zshenv"
assert_file_exists ".zprofile exists" "$REPO_ROOT/.zprofile"
assert_file_exists ".zstyles exists" "$REPO_ROOT/.zstyles"
assert_file_exists "antidote_plugins.conf exists" "$REPO_ROOT/antidote_plugins.conf"

# Test rc.d directory and files
if [ -d "$REPO_ROOT/rc.d" ]; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    print_green "✓ rc.d directory exists"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    print_red "✗ rc.d directory does not exist"
fi
assert_file_exists "01-hist.zsh exists" "$REPO_ROOT/rc.d/01-hist.zsh"
assert_file_exists "02_dirs.zsh exists" "$REPO_ROOT/rc.d/02_dirs.zsh"
assert_file_exists "04-opts.zsh exists" "$REPO_ROOT/rc.d/04-opts.zsh"
assert_file_exists "05-aliases.zsh exists" "$REPO_ROOT/rc.d/05-aliases.zsh"
assert_file_exists "06-commands.zsh exists" "$REPO_ROOT/rc.d/06-commands.zsh"
assert_file_exists "history-substring-search.zsh exists" "$REPO_ROOT/rc.d/history-substring-search.zsh"
assert_file_exists "sharship.zsh exists" "$REPO_ROOT/rc.d/sharship.zsh"

# Test .zshrc configuration
test_zshrc() {
    local content=$(cat "$REPO_ROOT/.zshrc")
    
    assert_contains ".zshrc has shebang" "$content" "#!/bin/zsh"
    assert_contains ".zshrc loads antidote" "$content" "antidote"
    assert_contains ".zshrc sources rc.d files" "$content" "rc.d/\*.zsh"
    assert_contains ".zshrc sets up fpath" "$content" "fpath"
    assert_contains ".zshrc autoloads functions" "$content" "autoload"
}

test_zshrc

# Test .zprofile configuration
test_zprofile() {
    local content=$(cat "$REPO_ROOT/.zprofile")
    
    assert_contains ".zprofile has shebang" "$content" "#!/bin/zsh"
    assert_contains ".zprofile sets HOMEBREW_PREFIX" "$content" "HOMEBREW_PREFIX"
    assert_contains ".zprofile sets EDITOR" "$content" "EDITOR"
    assert_contains ".zprofile sets VISUAL" "$content" "VISUAL"
    assert_contains ".zprofile sets FZF_DEFAULT_COMMAND" "$content" "FZF_DEFAULT_COMMAND"
    assert_contains ".zprofile sets FZF_DEFAULT_OPTS" "$content" "FZF_DEFAULT_OPTS"
}

test_zprofile

# Test .zshenv configuration
test_zshenv() {
    local content=$(cat "$REPO_ROOT/.zshenv")
    
    # .zshenv may not have a shebang since it's always sourced, not executed
    # Just check that it sets XDG variables
    assert_contains ".zshenv sets XDG_CONFIG_HOME" "$content" "XDG_CONFIG_HOME"
    assert_contains ".zshenv sets XDG_DATA_HOME" "$content" "XDG_DATA_HOME"
    assert_contains ".zshenv sets XDG_CACHE_HOME" "$content" "XDG_CACHE_HOME"
}

test_zshenv

# Test rc.d file naming convention
test_rcd_naming() {
    local files=$(ls "$REPO_ROOT/rc.d/"*.zsh 2>/dev/null | wc -l)
    
    if [ "$files" -gt 0 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ rc.d contains $files .zsh files"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ rc.d should contain .zsh files"
    fi
}

test_rcd_naming

# Test that rc.d files are properly structured
test_rcd_structure() {
    local rcd_dir="$REPO_ROOT/rc.d"
    
    # Check that numbered files exist (for load order)
    if ls "$rcd_dir"/[0-9]*.zsh >/dev/null 2>&1; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ rc.d contains numbered files for load order"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ rc.d should contain numbered files"
    fi
}

test_rcd_structure

# Test antidote_plugins.conf
test_antidote_plugins() {
    local content=$(cat "$REPO_ROOT/antidote_plugins.conf")
    
    # Check for any of the common plugin sources (github, path to plugins, etc)
    if echo "$content" | grep -qE "(zsh-users|mattmc3|aloxaf|belak)"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ antidote_plugins.conf has plugin references"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ antidote_plugins.conf should have plugin references"
    fi
    
    # Check for some expected plugins
    if echo "$content" | grep -q "zsh-users/zsh-completions" || \
       echo "$content" | grep -q "zsh-users/zsh-syntax-highlighting" || \
       echo "$content" | grep -q "zsh-users/zsh-autosuggestions"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ antidote_plugins.conf contains expected plugins"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ antidote_plugins.conf should contain zsh-users plugins"
    fi
}

test_antidote_plugins

# Test .gitignore for ZSH artifacts
test_gitignore() {
    if [ -f "$REPO_ROOT/.gitignore" ]; then
        local content=$(cat "$REPO_ROOT/.gitignore")
        
        # Check that common ZSH artifacts are ignored
        assert_contains ".gitignore ignores .zsh_plugins.zsh" "$content" ".zsh_plugins.zsh"
        
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ .gitignore exists and contains ZSH artifacts"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ .gitignore should exist"
    fi
}

test_gitignore

print_summary

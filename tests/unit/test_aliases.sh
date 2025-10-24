#!/usr/bin/env bash
# Unit tests for aliases
# These tests verify that aliases are properly defined

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/../test_helpers.sh"

run_test_suite "Aliases Configuration"

# Test aliases file exists
assert_file_exists "05-aliases.zsh exists" "$REPO_ROOT/rc.d/05-aliases.zsh"

# Test aliases content
test_aliases_content() {
    local content=$(cat "$REPO_ROOT/rc.d/05-aliases.zsh")
    
    # Test navigation aliases
    assert_contains "aliases has .. alias" "$content" ".."
    assert_contains "aliases has ... alias" "$content" "..."
    
    # Test git aliases (very common ones)
    if echo "$content" | grep -qE "(alias g=|g='git'|g=\"git\")"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ aliases has git shortcuts"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ aliases should have git shortcuts"
    fi
}

test_aliases_content

# Test that aliases file is substantial
test_aliases_size() {
    local lines=$(wc -l < "$REPO_ROOT/rc.d/05-aliases.zsh")
    
    # Should have a reasonable number of aliases (at least 10 lines)
    if [ "$lines" -ge 10 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ aliases file has substantial content ($lines lines)"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ aliases file seems too small ($lines lines)"
    fi
}

test_aliases_size

# Test that aliases follow ZSH syntax
test_aliases_syntax() {
    local content=$(cat "$REPO_ROOT/rc.d/05-aliases.zsh")
    
    # Check for alias command usage
    if echo "$content" | grep -q "alias"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ aliases file uses alias command"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ aliases file should use alias command"
    fi
}

test_aliases_syntax

print_summary

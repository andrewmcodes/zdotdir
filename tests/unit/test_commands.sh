#!/usr/bin/env bash
# Unit tests for custom commands/functions in rc.d/06-commands.zsh
# These tests verify that custom shell functions are properly defined

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/../test_helpers.sh"

run_test_suite "Custom Commands"

# Test commands file exists
assert_file_exists "06-commands.zsh exists" "$REPO_ROOT/rc.d/06-commands.zsh"

# Test commands content
test_commands_content() {
    local content=$(cat "$REPO_ROOT/rc.d/06-commands.zsh")
    
    # Test for specific functions mentioned in the repository context
    assert_contains "commands has pg_switch function" "$content" "function pg_switch"
    assert_contains "commands has pg_stop function" "$content" "function pg_stop"
    assert_contains "commands has install_casks function" "$content" "function install_casks"
    assert_contains "commands has view_defaults function" "$content" "function view_defaults"
    assert_contains "commands has print_path function" "$content" "function print_path"
}

test_commands_content

# Test that commands use fzf integration
test_fzf_integration() {
    local content=$(cat "$REPO_ROOT/rc.d/06-commands.zsh")
    
    # Several functions should use fzf
    if echo "$content" | grep -q "fzf"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ commands integrate with fzf"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ commands should integrate with fzf"
    fi
}

test_fzf_integration

# Test that commands use jq for JSON processing
test_jq_usage() {
    local content=$(cat "$REPO_ROOT/rc.d/06-commands.zsh")
    
    if echo "$content" | grep -q "jq"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ commands use jq for JSON processing"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ commands should use jq for JSON processing"
    fi
}

test_jq_usage

# Test PostgreSQL functions
test_postgresql_functions() {
    local content=$(cat "$REPO_ROOT/rc.d/06-commands.zsh")
    
    # Check for mise integration in PostgreSQL functions
    assert_contains "pg functions use mise" "$content" "mise/installs/postgres"
}

test_postgresql_functions

# Test that commands file is substantial
test_commands_size() {
    local lines=$(wc -l < "$REPO_ROOT/rc.d/06-commands.zsh")
    
    # Should have a reasonable number of functions (at least 20 lines)
    if [ "$lines" -ge 20 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ commands file has substantial content ($lines lines)"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ commands file seems too small ($lines lines)"
    fi
}

test_commands_size

# Test function documentation
test_function_documentation() {
    local content=$(cat "$REPO_ROOT/rc.d/06-commands.zsh")
    
    # Check if functions have documentation comments
    if echo "$content" | grep -q "^#"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ commands file has documentation comments"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ commands file should have documentation comments"
    fi
}

test_function_documentation

print_summary

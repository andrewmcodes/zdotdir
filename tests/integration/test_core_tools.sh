#!/usr/bin/env bash
# Integration tests for core tools: mise, fzf, zoxide
# These tests verify that the tool integration files work correctly

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/../test_helpers.sh"

run_test_suite "Core Tools Integration"

# Test mise configuration file
assert_file_exists "mise.zsh configuration file exists" "$REPO_ROOT/rc.d/mise.zsh"

# Test fzf configuration file
assert_file_exists "fzf.zsh configuration file exists" "$REPO_ROOT/rc.d/fzf.zsh"

# Test zoxide configuration file
assert_file_exists "zoixide.zsh configuration file exists" "$REPO_ROOT/rc.d/zoixide.zsh"

# Test mise configuration content
test_mise_config() {
    local content=$(cat "$REPO_ROOT/rc.d/mise.zsh")
    
    assert_contains "mise.zsh checks for mise command" "$content" '\$+commands\[mise\]'
    assert_contains "mise.zsh activates mise" "$content" "mise activate zsh"
}

test_mise_config

# Test fzf configuration content
test_fzf_config() {
    local content=$(cat "$REPO_ROOT/rc.d/fzf.zsh")
    
    assert_contains "fzf.zsh checks for fzf command" "$content" '\$+commands\[fzf\]'
    assert_contains "fzf.zsh sources fzf integration" "$content" "fzf --zsh"
}

test_fzf_config

# Test zoxide configuration content
test_zoxide_config() {
    local content=$(cat "$REPO_ROOT/rc.d/zoixide.zsh")
    
    assert_contains "zoixide.zsh checks for zoxide command" "$content" '\$+commands\[zoxide\]'
    assert_contains "zoixide.zsh initializes zoxide" "$content" "zoxide init zsh"
}

test_zoxide_config

# Test that config files return 1 when command is missing
test_command_check_pattern() {
    # All three files should use the same pattern for command checking
    local mise_first_line=$(head -n 1 "$REPO_ROOT/rc.d/mise.zsh")
    local fzf_first_line=$(head -n 1 "$REPO_ROOT/rc.d/fzf.zsh")
    local zoxide_first_line=$(head -n 1 "$REPO_ROOT/rc.d/zoixide.zsh")
    
    # Check that they all follow the pattern: (($+commands[tool])) || return 1
    assert_contains "mise.zsh has proper command check" "$mise_first_line" "return 1"
    assert_contains "fzf.zsh has proper command check" "$fzf_first_line" "return 1"
    assert_contains "zoixide.zsh has proper command check" "$zoxide_first_line" "return 1"
}

test_command_check_pattern

# Test that configuration files are minimal
test_config_minimalism() {
    local mise_lines=$(wc -l < "$REPO_ROOT/rc.d/mise.zsh")
    local fzf_lines=$(wc -l < "$REPO_ROOT/rc.d/fzf.zsh")
    local zoxide_lines=$(wc -l < "$REPO_ROOT/rc.d/zoixide.zsh")
    
    # Each file should be very minimal (less than 10 lines)
    if [ "$mise_lines" -le 10 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ mise.zsh is minimal ($mise_lines lines)"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ mise.zsh should be minimal (has $mise_lines lines)"
    fi
    
    if [ "$fzf_lines" -le 10 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ fzf.zsh is minimal ($fzf_lines lines)"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ fzf.zsh should be minimal (has $fzf_lines lines)"
    fi
    
    if [ "$zoxide_lines" -le 10 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ zoixide.zsh is minimal ($zoxide_lines lines)"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ zoixide.zsh should be minimal (has $zoxide_lines lines)"
    fi
}

test_config_minimalism

print_summary

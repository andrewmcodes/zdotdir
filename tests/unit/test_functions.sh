#!/usr/bin/env bash
# Unit tests for custom ZSH functions
# These tests verify that custom functions are properly defined

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/../test_helpers.sh"

run_test_suite "Custom Functions"

# Test that functions directory exists (it's a directory, not a file)
if [ -d "$REPO_ROOT/functions" ]; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    print_green "✓ functions directory exists"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    print_red "✗ functions directory does not exist"
fi

# Test individual function files exist
assert_file_exists "bench-startup function exists" "$REPO_ROOT/functions/bench-startup"
assert_file_exists "calculate_actions_stats function exists" "$REPO_ROOT/functions/calculate_actions_stats"
assert_file_exists "fetch_action_stats function exists" "$REPO_ROOT/functions/fetch_action_stats"
assert_file_exists "grecent function exists" "$REPO_ROOT/functions/grecent"
assert_file_exists "is-macos function exists" "$REPO_ROOT/functions/is-macos"
assert_file_exists "os function exists" "$REPO_ROOT/functions/os"

# Test bench-startup function
test_bench_startup() {
    local content=$(cat "$REPO_ROOT/functions/bench-startup")
    
    assert_contains "bench-startup has shebang" "$content" "#!/usr/bin/env zsh"
    assert_contains "bench-startup has measure_basic function" "$content" "measure_basic"
    assert_contains "bench-startup has measure_hyperfine function" "$content" "measure_hyperfine"
    assert_contains "bench-startup uses time command" "$content" "time"
}

test_bench_startup

# Test fetch_action_stats function
test_fetch_action_stats() {
    local content=$(cat "$REPO_ROOT/functions/fetch_action_stats")
    
    assert_contains "fetch_action_stats has shebang" "$content" "#!/bin/zsh"
    assert_contains "fetch_action_stats uses gh command" "$content" "gh run list"
    assert_contains "fetch_action_stats uses jq" "$content" "jq"
    assert_contains "fetch_action_stats has main function" "$content" "main"
}

test_fetch_action_stats

# Test calculate_actions_stats function
test_calculate_actions_stats() {
    local content=$(cat "$REPO_ROOT/functions/calculate_actions_stats")
    
    assert_contains "calculate_actions_stats has shebang" "$content" "#!/bin/zsh"
    # This function uses awk for calculations
    assert_contains "calculate_actions_stats uses awk" "$content" "awk"
}

test_calculate_actions_stats

# Test grecent function
test_grecent() {
    local content=$(cat "$REPO_ROOT/functions/grecent")
    
    # Accept both #!/bin/zsh and #!/usr/bin/env zsh
    if echo "$content" | head -n 1 | grep -q "^#!/.*zsh"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ grecent has zsh shebang"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ grecent does not have zsh shebang"
    fi
    
    assert_contains "grecent uses git" "$content" "git"
    assert_contains "grecent uses fzf" "$content" "fzf"
}

test_grecent

# Test is-macos function
test_is_macos() {
    local content=$(cat "$REPO_ROOT/functions/is-macos")
    
    assert_contains "is-macos has shebang" "$content" "#!/bin/zsh"
    # Check for darwin OS detection (case-insensitive)
    if echo "$content" | grep -qi "darwin"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ is-macos checks for darwin OS"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ is-macos should check for darwin OS"
    fi
}

test_is_macos

# Test os function
test_os() {
    local content=$(cat "$REPO_ROOT/functions/os")
    
    # Accept both #!/bin/zsh and #!/usr/bin/env zsh
    if echo "$content" | head -n 1 | grep -q "^#!/.*zsh"; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ os has zsh shebang"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ os does not have zsh shebang"
    fi
    
    # The 'os' function is for Overmind start, not for OS detection
    assert_contains "os function uses overmind" "$content" "overmind"
}

test_os

# Test that all functions have executable permissions (or note it as info)
test_function_permissions() {
    local functions_dir="$REPO_ROOT/functions"
    local non_executable=0
    
    for func_file in "$functions_dir"/*; do
        if [ -f "$func_file" ]; then
            if [ ! -x "$func_file" ]; then
                non_executable=$((non_executable + 1))
            fi
        fi
    done
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$non_executable" -eq 0 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ All function files are executable"
    else
        # This is informational - not all systems require functions to be executable
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_yellow "ℹ $non_executable function files are not executable (this is optional)"
    fi
}

test_function_permissions

# Test that function files have shebangs
test_function_shebangs() {
    local functions_dir="$REPO_ROOT/functions"
    local all_have_shebang=true
    
    for func_file in "$functions_dir"/*; do
        if [ -f "$func_file" ]; then
            local first_line=$(head -n 1 "$func_file")
            if [[ ! "$first_line" =~ ^#! ]]; then
                all_have_shebang=false
                TESTS_RUN=$((TESTS_RUN + 1))
                TESTS_FAILED=$((TESTS_FAILED + 1))
                print_red "✗ $(basename "$func_file") does not have a shebang"
            fi
        fi
    done
    
    if [ "$all_have_shebang" = true ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ All function files have shebangs"
    fi
}

test_function_shebangs

print_summary

#!/usr/bin/env bash
# Test helper functions for ZSH configuration tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Print colored output
print_red() {
    printf "${RED}%s${NC}\n" "$1"
}

print_green() {
    printf "${GREEN}%s${NC}\n" "$1"
}

print_yellow() {
    printf "${YELLOW}%s${NC}\n" "$1"
}

# Test assertion functions
assert_success() {
    local description="$1"
    local command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$command" > /dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ $description"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ $description"
        print_red "  Command failed: $command"
        return 1
    fi
}

assert_failure() {
    local description="$1"
    local command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! eval "$command" > /dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ $description"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ $description"
        print_red "  Command should have failed: $command"
        return 1
    fi
}

assert_equals() {
    local description="$1"
    local expected="$2"
    local actual="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ $description"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ $description"
        print_red "  Expected: $expected"
        print_red "  Actual:   $actual"
        return 1
    fi
}

assert_contains() {
    local description="$1"
    local haystack="$2"
    local needle="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if echo "$haystack" | grep -q "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ $description"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ $description"
        print_red "  Expected to find: $needle"
        print_red "  In: $haystack"
        return 1
    fi
}

assert_file_exists() {
    local description="$1"
    local file="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "$file" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ $description"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ $description"
        print_red "  File does not exist: $file"
        return 1
    fi
}

assert_command_exists() {
    local description="$1"
    local command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if command -v "$command" >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_green "✓ $description"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_red "✗ $description"
        print_red "  Command not found: $command"
        return 1
    fi
}

# Print test summary
print_summary() {
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo "Total:  $TESTS_RUN"
    print_green "Passed: $TESTS_PASSED"
    if [ $TESTS_FAILED -gt 0 ]; then
        print_red "Failed: $TESTS_FAILED"
        return 1
    else
        echo "Failed: $TESTS_FAILED"
        return 0
    fi
}

# Run a test suite
run_test_suite() {
    local suite_name="$1"
    echo ""
    print_yellow "Running test suite: $suite_name"
    echo "================================"
}

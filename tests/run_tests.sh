#!/usr/bin/env bash
# Main test runner for ZSH configuration tests
# Usage: ./tests/run_tests.sh [test_file_pattern]

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test_helpers.sh"

# Run all test files
run_all_tests() {
    local pattern="${1:-*.sh}"
    local test_files=()
    local exit_code=0
    
    # Find all test files
    while IFS= read -r -d '' file; do
        if [[ "$(basename "$file")" != "test_helpers.sh" ]] && \
           [[ "$(basename "$file")" != "run_tests.sh" ]]; then
            test_files+=("$file")
        fi
    done < <(find "$SCRIPT_DIR" -type f -name "$pattern" -print0)
    
    # If no pattern match, try finding test files in subdirectories
    if [ ${#test_files[@]} -eq 0 ]; then
        while IFS= read -r -d '' file; do
            if [[ "$(basename "$file")" != "test_helpers.sh" ]] && \
               [[ "$(basename "$file")" != "run_tests.sh" ]]; then
                test_files+=("$file")
            fi
        done < <(find "$SCRIPT_DIR" -type f -name "test_*.sh" -print0)
    fi
    
    if [ ${#test_files[@]} -eq 0 ]; then
        print_yellow "No test files found matching pattern: $pattern"
        return 0
    fi
    
    print_yellow "Found ${#test_files[@]} test file(s)"
    echo ""
    
    # Run each test file
    for test_file in "${test_files[@]}"; do
        print_yellow "Running: $(basename "$test_file")"
        echo "================================"
        
        if bash "$test_file"; then
            echo ""
        else
            exit_code=1
            echo ""
        fi
    done
    
    return $exit_code
}

# Main execution
main() {
    print_yellow "ZSH Configuration Test Suite"
    print_yellow "Repository: $REPO_ROOT"
    echo ""
    
    if run_all_tests "$@"; then
        print_summary
        exit_code=$?
        echo ""
        if [ $exit_code -eq 0 ]; then
            print_green "All tests passed!"
        else
            print_red "Some tests failed!"
        fi
        exit $exit_code
    else
        print_summary
        echo ""
        print_red "Test execution failed!"
        exit 1
    fi
}

main "$@"

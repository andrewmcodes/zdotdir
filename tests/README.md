# ZSH Configuration Tests

This directory contains tests for the ZSH configuration. The tests verify that the configuration files are properly structured and that important tools like mise, fzf, and zoxide are correctly integrated.

## Test Structure

```
tests/
├── run_tests.sh           # Main test runner
├── test_helpers.sh        # Test assertion functions and utilities
├── integration/           # Integration tests
│   └── test_core_tools.sh # Tests for mise, fzf, zoxide integration
└── unit/                  # Unit tests
    ├── test_aliases.sh    # Tests for alias definitions
    ├── test_commands.sh   # Tests for custom shell functions
    ├── test_config.sh     # Tests for ZSH configuration files
    └── test_functions.sh  # Tests for autoloaded functions
```

## Running Tests

### Run All Tests

```bash
./tests/run_tests.sh
```

### Run Specific Test Files

You can run specific test files by passing a pattern:

```bash
./tests/run_tests.sh "test_core_tools.sh"
```

Or run tests from a specific directory:

```bash
bash tests/unit/test_config.sh
```

## Test Categories

### Integration Tests

**Core Tools Integration** (`integration/test_core_tools.sh`)
- Verifies mise configuration file exists and has proper content
- Verifies fzf configuration file exists and has proper content
- Verifies zoxide configuration file exists and has proper content
- Tests command check patterns (returns 1 when command is missing)
- Ensures configuration files are minimal and focused

### Unit Tests

**Custom Functions** (`unit/test_functions.sh`)
- Tests that all function files exist in the `functions/` directory
- Verifies functions have proper shebangs
- Tests specific function content (bench-startup, grecent, etc.)
- Checks that functions use expected tools (fzf, git, jq, etc.)

**ZSH Configuration Files** (`unit/test_config.sh`)
- Tests main configuration files exist (.zshrc, .zshenv, .zprofile)
- Verifies configuration content (antidote loading, rc.d sourcing)
- Tests rc.d file structure and naming conventions
- Verifies environment variables are set correctly

**Aliases** (`unit/test_aliases.sh`)
- Tests that alias file exists and has content
- Verifies common aliases are defined
- Checks alias syntax is correct

**Custom Commands** (`unit/test_commands.sh`)
- Tests that command functions are defined
- Verifies integration with fzf and jq
- Tests PostgreSQL functions use mise
- Checks function documentation

## Test Helpers

The `test_helpers.sh` file provides several assertion functions:

- `assert_success(description, command)` - Asserts command succeeds
- `assert_failure(description, command)` - Asserts command fails
- `assert_equals(description, expected, actual)` - Asserts equality
- `assert_contains(description, haystack, needle)` - Asserts substring match
- `assert_file_exists(description, file)` - Asserts file exists
- `assert_command_exists(description, command)` - Asserts command is available

## Test Output

Tests produce colored output:
- ✓ Green for passed tests
- ✗ Red for failed tests
- ℹ Yellow for informational messages

Example output:
```
Running test suite: Core Tools Integration
================================
✓ mise.zsh configuration file exists
✓ fzf.zsh configuration file exists
✓ zoxide.zsh configuration file exists
...

================================
Test Summary
================================
Total:  15
Passed: 15
Failed: 0
```

## Adding New Tests

To add new tests:

1. Create a new test file in `tests/unit/` or `tests/integration/`
2. Name it `test_*.sh` (e.g., `test_my_feature.sh`)
3. Make it executable: `chmod +x tests/unit/test_my_feature.sh`
4. Source the test helpers: `source "$SCRIPT_DIR/../test_helpers.sh"`
5. Use `run_test_suite "Your Suite Name"` to start the suite
6. Add your test assertions using the helper functions
7. End with `print_summary` to show results

Example test file:

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/../test_helpers.sh"

run_test_suite "My Feature Tests"

assert_file_exists "my config exists" "$REPO_ROOT/my_config.zsh"
assert_contains "config has setting" "$(cat $REPO_ROOT/my_config.zsh)" "my_setting"

print_summary
```

## Continuous Integration

These tests can be run in CI environments. The test runner exits with:
- Exit code 0 if all tests pass
- Exit code 1 if any tests fail

This makes it easy to integrate with GitHub Actions or other CI systems.

## Requirements

The tests are written in bash and use standard Unix tools:
- bash (for running tests)
- grep, awk, sed (for text processing)
- Standard file operations (cat, ls, wc)

No ZSH is required to run the tests - they verify the configuration files themselves, not their runtime behavior.

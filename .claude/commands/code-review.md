# Code Review Command

## Description
Performs comprehensive code review of the current changes or specified files.

## Usage
```bash
/code-review [files...]
```

## What it does
1. Runs static analysis and linting checks
2. Reviews code for style consistency and best practices
3. Checks for potential bugs and security issues
4. Validates documentation and comments
5. Ensures test coverage for new functionality

## Examples
- `/code-review` - Review all changed files
- `/code-review src/legal_rag/system.hy` - Review specific file
- `/code-review tests/` - Review all files in tests directory

## Implementation
```bash
# Run linting
black --check .
ruff check .

# Run tests
pytest -xvs

# Check type annotations
mypy src/

# Security scan
bandit -r src/
```
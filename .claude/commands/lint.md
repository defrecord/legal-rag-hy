# Lint Command

## Description
Runs linting and formatting tools to ensure code quality and consistency.

## Usage
```bash
/lint [--fix] [files...]
```

## What it does
1. Runs Black formatter for Python code
2. Runs Ruff for linting Hy and Python files
3. Checks for import sorting and organization
4. Validates code style and formatting
5. Optionally fixes auto-fixable issues

## Examples
- `/lint` - Lint all files
- `/lint --fix` - Lint and auto-fix issues
- `/lint src/legal_rag/` - Lint specific directory
- `/lint tests/test_system.py` - Lint specific file

## Implementation
```bash
# Format with Black
black .

# Lint with Ruff
ruff check . --fix

# Check import sorting
isort --check-only .

# Pre-commit hooks (if available)
pre-commit run --all-files
```

## Configuration
- Uses pyproject.toml for Black and Ruff configuration
- Follows project-specific style guidelines
- Integrates with pre-commit hooks
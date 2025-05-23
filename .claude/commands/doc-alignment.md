# Documentation Alignment Command

## Description
Ensures documentation is aligned with code and maintains consistency across the project.

## Usage
```bash
/doc-alignment [--check|--fix] [paths...]
```

## What it does
1. Validates that all public functions have docstrings
2. Checks org-mode file formatting and structure
3. Ensures README and documentation files are up to date
4. Validates code examples in documentation
5. Checks for broken internal links
6. Aligns CLAUDE.org with project changes

## Examples
- `/doc-alignment` - Check all documentation
- `/doc-alignment --fix` - Fix auto-fixable documentation issues
- `/doc-alignment docs/` - Check specific documentation directory
- `/doc-alignment --check src/` - Validate docstrings in source code

## Implementation
```bash
# Check docstring coverage
interrogate src/ --fail-under=80

# Validate org-mode files
emacs --batch --eval "(org-lint-file \"docs/architecture.org\")"

# Check for broken links (if available)
markdown-link-check docs/*.md

# Validate code examples
python -m doctest src/legal_rag/*.py

# Update CLAUDE.org if needed
# (Manual review required for project-specific changes)
```

## Checks Performed
- Function and class docstring presence
- Org-mode syntax and structure
- Cross-reference consistency
- Code example validity
- Documentation freshness relative to code changes
- CLAUDE.org alignment with project structure
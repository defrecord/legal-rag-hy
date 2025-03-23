# Contributing to Legal RAG System

Thank you for your interest in contributing to the Legal RAG System! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- Be respectful and inclusive
- Value diverse perspectives
- Focus on constructive feedback
- Maintain professional communication

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Install development dependencies**:
   ```bash
   pip install -e ".[dev]"
   ```
4. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Process

### Writing Code

We use Hy, a Lisp dialect embedded in Python. If you're new to Hy, check out the [official documentation](https://docs.hylang.org/).

Key style conventions:
- Use lisp-case for function and variable names
- Provide docstrings for all functions and classes
- Keep functions small and focused
- Follow functional programming patterns where appropriate

### Testing

All new code should include tests:

```bash
# Run tests
pytest tests/

# Run tests with coverage
pytest --cov=legal_rag tests/
```

Aim for at least 80% test coverage for new code.

### Documentation

Update documentation when you make changes:

- Update relevant code docstrings
- Update markdown files in the `docs/` directory
- Add examples for new features

### Submitting Changes

1. **Commit your changes** with clear commit messages:
   ```
   feat(jurisdiction): add international jurisdiction support
   
   - Add UK, Canada, and Australia to jurisdiction hierarchy
   - Implement boost factors for cross-national citations
   - Update documentation with international examples
   ```

2. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request** against the main repository

## Pull Request Process

1. Update the README.md or documentation with details of your changes
2. Add appropriate tests for your changes
3. Ensure CI checks pass on your pull request
4. Request a review from a maintainer
5. Address any feedback from the code review

## Feature Requests and Bug Reports

Please use GitHub Issues to submit feature requests and bug reports. Include as much detail as possible:

For bugs:
- Description of the issue
- Steps to reproduce
- Expected vs. actual behavior
- Version information
- Error messages or stack traces

For features:
- Clear description of the proposed feature
- Explanation of the benefit
- Any implementation ideas
- Links to relevant research/papers if applicable

## Legal Considerations

When contributing, you confirm that your contributions are your original work and that you have the right to license them under the project's license.

## Questions?

If you have questions, please open a GitHub Discussion or reach out to the maintainers directly.

Thank you for contributing to the Legal RAG System!
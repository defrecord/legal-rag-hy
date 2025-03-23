# Legal RAG System Makefile
# 
# This Makefile provides commands for development, testing, and documentation.

.PHONY: help clean tangle test coverage lint format docs install dev citation

# Default target shows help
help:
	@echo "Legal RAG System - Jurisdiction-aware RAG for legal research"
	@echo ""
	@echo "Usage:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Example:"
	@echo "  make test       # Run all tests"
	@echo "  make coverage   # Run tests with coverage report"

clean: ## Clean generated files and caches
	rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .coverage htmlcov/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type d -name .ipynb_checkpoints -exec rm -rf {} +

tangle: ## Extract code from org files
	@echo "Tangling code from org files..."
	emacs --batch \
		--eval "(require 'org)" \
		--eval "(dolist (file (directory-files-recursively \"./src\" \"\\.org$\")) (with-current-buffer (find-file file) (org-babel-tangle)))" \
		--kill

install: ## Install the package
	uv pip install -e .

dev: ## Install development dependencies
	uv pip install -e ".[dev]"

test: ## Run tests
	pytest tests/

coverage: ## Run tests with coverage report
	pytest --cov=src tests/ --cov-report=term --cov-report=html
	@echo "HTML coverage report generated in htmlcov/index.html"

lint: ## Run linters (flake8, black, isort)
	flake8 src/ tests/
	black --check src/ tests/
	isort --check-only src/ tests/

format: ## Format code with black and isort
	black src/ tests/
	isort src/ tests/

docs: ## Generate documentation
	@echo "Generating documentation..."
	mkdir -p docs/html
	emacs --batch \
		--eval "(require 'org)" \
		--eval "(require 'ox-html)" \
		--eval "(dolist (file (directory-files-recursively \"./docs\" \"\\.org$\")) (with-current-buffer (find-file file) (org-html-export-to-html)))" \
		--kill
	@echo "Documentation generated in docs/html/"

citation: ## Generate citation file (BibTeX)
	@echo "Generating citation file..."
	mkdir -p docs/citation
	cat PROJECT_STATUS.org | grep -A 15 "begin_src bibtex" | grep -v "begin_src" | grep -v "end_src" > docs/citation/citation.bib
	@echo "Citation file generated in docs/citation/citation.bib"

run-demo: ## Run the interactive demo
	@echo "Running Legal RAG demo..."
	cd src && hy legal_rag/demo.hy

notebook: ## Start Jupyter notebook for examples
	jupyter notebook examples/

version: ## Show the current version
	@grep "__version__" src/legal_rag/__init__.hy | cut -d '"' -f2
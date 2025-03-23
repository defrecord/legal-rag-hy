.PHONY: setup test clean lint docs build install dev help cache-clear

# Variables
PYTHON := python3
HY := hy
PIP := uv pip
PYTEST := uv run pytest
COVERAGE := uv run coverage
PYLINT := uv run pylint
BLACK := uv run black
ISORT := uv run isort
SOURCE_DIR := src
TEST_DIR := tests

# Default target
help:
	@echo "Legal RAG System with Hy"
	@echo "------------------------"
	@echo "setup        - Install dependencies"
	@echo "test         - Run tests"
	@echo "coverage     - Run tests with coverage"
	@echo "lint         - Run linting checks"
	@echo "format       - Format code with black and isort"
	@echo "docs         - Generate documentation"
	@echo "build        - Build package"
	@echo "install      - Install package"
	@echo "dev          - Install in development mode"
	@echo "clean        - Remove build artifacts"
	@echo "cache-clear  - Clear embedding cache"
	@echo "demo         - Run interactive demo"

# Setup
setup:
	uv venv
	$(PIP) install -e ".[dev]"

# Test
test:
	$(PYTEST) $(TEST_DIR)

coverage:
	$(COVERAGE) run -m pytest $(TEST_DIR)
	$(COVERAGE) report -m
	$(COVERAGE) html

# Linting
lint:
	$(PYLINT) $(SOURCE_DIR)
	$(BLACK) --check $(SOURCE_DIR) $(TEST_DIR)
	$(ISORT) --check-only --profile black $(SOURCE_DIR) $(TEST_DIR)

# Formatting
format:
	$(BLACK) $(SOURCE_DIR) $(TEST_DIR)
	$(ISORT) --profile black $(SOURCE_DIR) $(TEST_DIR)

# Documentation
docs:
	cd docs && $(MAKE) html

# Build and install
build:
	$(PYTHON) -m build

install:
	$(PIP) install .

dev:
	$(PIP) install -e ".[dev]"

# Clean
clean:
	rm -rf build/ dist/ *.egg-info/ .coverage htmlcov/ .pytest_cache/ __pycache__/ 
	find . -name "__pycache__" -exec rm -rf {} +
	find . -name "*.pyc" -delete
	find . -name "*.hy~" -delete

# Clear cache
cache-clear:
	rm -rf $(SOURCE_DIR)/legal_rag/cache/*.pkl

# Demo
demo:
	$(HY) $(SOURCE_DIR)/legal_rag/demo.hy
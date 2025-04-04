#!/usr/bin/env bash
# Setup script for the Legal RAG Conference Demo
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Setting up Legal RAG Conference Demo"
echo "==================================="
echo

# Check requirements
echo "Checking requirements..."
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not found. Please install Python 3.9 or later."
    exit 1
fi

if ! command -v pip &> /dev/null; then
    echo "Error: pip is required but not found. Please install pip."
    exit 1
fi

# Install Hy 1.0
echo "Installing Hy 1.0..."
pip install "hy==1.0.0"

if ! command -v hy &> /dev/null; then
    echo "Error: Failed to install hy. Please check your Python environment."
    exit 1
fi

# Check Hy version
HY_VERSION=$(hy --version)
echo "Using Hy version: $HY_VERSION"
if [[ "$HY_VERSION" != *"1.0.0"* ]]; then
    echo "Warning: You're not using Hy 1.0.0. This may cause compatibility issues."
    echo "Please run: pip install \"hy==1.0.0\""
fi

# Install dependencies
echo "Installing project dependencies..."
if [[ "$1" == "--minimal" ]]; then
    pip install "openai>=1.3.0" "numpy>=1.26.0" "faiss-cpu>=1.7.4"
else
    cd "$PROJECT_ROOT"
    pip install -e .
fi

# Check for OpenAI API key
if [[ -z "${OPENAI_API_KEY}" ]]; then
    echo "Warning: OPENAI_API_KEY environment variable not set."
    echo "The full demo will not work without an API key."
    echo "Set it with: export OPENAI_API_KEY=your_api_key_here"
fi

# Make demo scripts executable
chmod +x "$PROJECT_ROOT/demo-simple.hy"
chmod +x "$PROJECT_ROOT/src/legal_rag/demo.hy"

echo
echo "Setup complete! You can now run the demos:"
echo "  - Simple compatibility test: ./demo-simple.hy"
echo "  - Full legal RAG demo: hy src/legal_rag/demo.hy"
echo
echo "For the full demo, make sure you've set your OpenAI API key:"
echo "export OPENAI_API_KEY=your_api_key_here"
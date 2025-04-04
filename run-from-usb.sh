#!/usr/bin/env bash
# Run the Legal RAG demo from a USB drive or any directory
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Legal RAG Conference Demo"
echo "========================="
echo

# Default to a temporary Python virtual environment
if [[ "$1" == "--venv" ]] || [[ "$1" == "-v" ]]; then
    VENV_DIR="$SCRIPT_DIR/venv"
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "$VENV_DIR" ]]; then
        echo "Creating virtual environment at $VENV_DIR"
        python3 -m venv "$VENV_DIR"
    fi
    
    # Activate virtual environment
    echo "Activating virtual environment"
    source "$VENV_DIR/bin/activate"
    
    # Install requirements
    echo "Installing requirements"
    pip install "hy==1.0.0" openai faiss-cpu numpy
fi

echo "Checking Hy version"
if ! command -v hy &> /dev/null; then
    echo "Error: Hy is not installed or not in your PATH."
    echo "Install it with: pip install \"hy==1.0.0\""
    exit 1
fi

HY_VERSION=$(hy --version)
echo "Using Hy version: $HY_VERSION"

# Make scripts executable
chmod +x "$SCRIPT_DIR/demo-simple.hy"
chmod +x "$SCRIPT_DIR/src/legal_rag/demo.hy"

echo "Running compatibility demo"
"$SCRIPT_DIR/demo-simple.hy"

# Check for OpenAI API key
if [[ -z "${OPENAI_API_KEY}" ]]; then
    echo
    echo "Warning: OPENAI_API_KEY environment variable not set."
    echo "The full demo will not work without an API key."
    echo "Set it with: export OPENAI_API_KEY=your_api_key_here"
    exit 0
else
    echo
    echo "Press Enter to continue to the full Legal RAG demo..."
    read
    
    # Run the full demo
    cd "$SCRIPT_DIR"
    hy src/legal_rag/demo.hy
fi

# If using virtual environment, deactivate it
if [[ "$1" == "--venv" ]] || [[ "$1" == "-v" ]]; then
    deactivate 2>/dev/null || true
fi
# Legal RAG Conference Guide

This guide provides quick instructions for setting up and running the Legal RAG demo during the conference.

## Quick Setup

```bash
# Clone the repository if you haven't already
git clone https://github.com/defrecord/legal-rag-hy.git
cd legal-rag-hy

# Run the setup script
./scripts/setup-conference-demo.sh

# Set your OpenAI API key (required for full demo)
export OPENAI_API_KEY=your_api_key_here
```

## Demo Options

### 1. Simple Demo (No API key required)

Tests Hy 1.0 compatibility and demonstrates core features:

```bash
./demo-simple.hy
```

### 2. Full Legal RAG Demo (Requires API key)

```bash
hy src/legal_rag/demo.hy
```

## Troubleshooting

### Hy Version Issues

If you encounter syntax errors, ensure you're using Hy 1.0:

```bash
hy --version  # Should show 1.0.0
pip install "hy==1.0.0"  # If needed
```

### Common Hy 1.0 Syntax Changes

| Old Syntax (pre-1.0) | New Syntax (1.0) |
|-------------------|-----------------|
| `(object.method arg)` | `(. object (method arg))` |
| `(.method object arg)` | `(. object (method arg))` |
| `(import numpy :as np)` | `(import numpy :as np)` (same) |
| `(import [pkg [func1 func2]])` | `(import [pkg [func1 func2]])` (same) |
| `@(decorator args)` | `(setv func ((decorator args) original-func))` |

### Dependency Issues

If you encounter dependency issues, try the minimal installation:

```bash
./scripts/setup-conference-demo.sh --minimal
```

### API Key Issues

If the demo can't access your API key, try:

```bash
# Check if the key is set
echo $OPENAI_API_KEY

# Set it again if needed
export OPENAI_API_KEY=your_api_key_here
```

## Conference Demo Script

1. Start with the simple demo to demonstrate Hy compatibility
2. Show the code in `system.hy` to explain the architecture
3. Run the full demo with 2-3 prepared legal questions:
   - "What constitutes fair use under copyright law?"
   - "How does the 9th Circuit apply the fair use doctrine to digital content?"
   - "What is the legal standard for fair use in California?"

## Presentation Flow

1. Introduction to Legal RAG concept (2 min)
2. Why Hy? Advantages of Lisp for RAG systems (2 min)
3. System architecture overview (3 min)
4. Live demo (5 min)
5. Q&A (3 min)

## Contact During Conference

If you encounter any issues during the conference, contact:
- Jason Walsh: jwalsh@defrecord.com / (555) 123-4567
- Kushagra Kumar: kkumar@defrecord.com / (555) 987-6543
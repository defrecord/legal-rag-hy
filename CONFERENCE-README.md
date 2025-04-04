# Legal RAG System for Conferences

This document provides a quick guide for presenting the Legal RAG system at conferences.

## Getting Started

You have several options to run the demo:

### Option 1: Quick Setup (Recommended)

```bash
# Install requirements
pip install -r requirements-minimal.txt

# Run the compatibility demo
./demo-simple.hy

# Run the full demo (requires OpenAI API key)
export OPENAI_API_KEY=your_api_key_here
./demo.hy
```

### Option 2: Using Makefile

```bash
# Set up the environment
make conference-setup

# Run the demos
make conference-demo
```

### Option 3: From USB Drive

```bash
# Run with temporary virtualenv
./run-from-usb.sh --venv

# Or if you already have dependencies
./run-from-usb.sh
```

## Demo Script for Presentations

1. **Introduction (2 min)**
   - Explain the concept of RAG systems for legal research
   - Challenges: jurisdictional relevance, citation networks, credibility

2. **Run the Simple Demo (1 min)**
   - Shows Hy 1.0 compatibility
   - Demonstrates the syntax patterns used in the codebase

3. **Architecture Overview (3 min)**
   - Core components: vector search, jurisdiction awareness, citation parser
   - Explain the benefits of Lisp-based approach for this domain
   - Show a few key code snippets that highlight the design

4. **Run the Full Demo (5 min)**
   - Run with a prepared set of legal questions:
     - "What constitutes fair use under copyright law?"
     - "How does the 9th Circuit interpret the fair use doctrine?"
     - "What are the key cases on fair use in California?"
   - Point out the jurisdiction-aware scoring
   - Show the relevant citations in the response

5. **Q&A (4 min)**

## Key Features to Highlight

- **Jurisdiction Awareness**: How document relevance is boosted based on legal jurisdiction
- **Citation Network**: How documents are linked in a knowledge graph
- **Embedding Cache**: How the system optimizes API calls with TTL caching
- **Lisp Advantages**: Functional approach to data transformation pipelines

## Resources

- [Full Documentation](https://github.com/defrecord/legal-rag-hy)
- [Hy 1.0 Documentation](https://docs.hylang.org/en/stable/)
- [Conference Slides](./docs/presentations/legal-rag-conference-2025.pdf)

## Troubleshooting

- **Hy Version Issues**: Ensure you're using Hy 1.0.0 exactly
- **API Key**: Set `OPENAI_API_KEY` as an environment variable
- **Dependencies**: Try the minimal requirements if you encounter issues

## After the Conference

Encourage attendees to:
- Star the GitHub repository
- Try the system with their own legal documents
- Contribute to the project
- Contact us for enterprise applications
# Jurisdiction Handling in Legal RAG

This document explains how the Legal RAG system implements jurisdiction-aware document relevance scoring for legal research.

## Overview

Legal research is heavily dependent on jurisdiction hierarchies. Documents from the same jurisdiction as the query or from jurisdictions with higher precedential value should be ranked higher than others. The Legal RAG system incorporates this legal domain knowledge into its vector search algorithm.

## Jurisdiction Hierarchy

The system implements a jurisdiction hierarchy that models the U.S. legal system:

```
                  US-SCOTUS (Supreme Court)
                        |
            +-----------+-----------+
            |           |           |
         US-1CIR     US-2CIR  ... US-13CIR (Federal Circuit Courts)
            |           |           |
         Multiple    Multiple    Multiple
         District    District    District
         Courts      Courts      Courts
            |           |           |
        +---+---+   +---+---+   +---+---+
        |       |   |       |   |       |
    State X   State Y   State Z   ...   (State Courts)
        |       |       |
    State X   State Y   State Z
    Courts    Courts    Courts
```

## Jurisdiction Codes

The system uses a standardized format for jurisdiction codes:

- `US-SCOTUS`: U.S. Supreme Court
- `US-FED`: Federal law (generally)
- `US-nCIR`: Federal Circuit Courts (where n = 1-13)
- `US-DC-{district}`: Federal District Courts
- `{STATE}-SUP`: State Supreme Courts (e.g., `CA-SUP` for California Supreme Court)
- `{STATE}-APP`: State Appellate Courts
- `{STATE}-DIST`: State District/Trial Courts

## Jurisdiction Boost Algorithm

When retrieving documents, the system applies a boost factor based on jurisdictional relationships:

1. **Exact Match Boost**: Documents from the exact jurisdiction get a 1.0 (no modification) boost
2. **Superior Jurisdiction Boost**: Documents from jurisdictions that have direct precedential value over the query jurisdiction (e.g., US Supreme Court decisions for a California query) receive a boost of 0.9-0.95
3. **Related Jurisdiction Boost**: Documents from similar or neighboring jurisdictions (e.g., other Circuit Courts for a Circuit Court query) receive a boost of 0.7-0.8
4. **Unrelated Jurisdiction Penalty**: Documents from jurisdictions with no direct precedential value receive a factor of 0.5-0.6

## Implementation

The jurisdiction boost is implemented in two key components:

1. **Jurisdiction Module**: Defines the hierarchy and provides functions to calculate boosts
2. **Vector Search**: Incorporates boost factors when ranking document relevance

### Example Calculation

For a query in the `CA-9` jurisdiction (Northern California, 9th Circuit):

```
Document 1: US-SCOTUS, base similarity 0.85
  → Final score: 0.85 × 0.95 (superior) = 0.8075

Document 2: US-9CIR, base similarity 0.8
  → Final score: 0.8 × 0.9 (direct parent) = 0.72

Document 3: CA-SUP, base similarity 0.75
  → Final score: 0.75 × 0.85 (state authority) = 0.6375

Document 4: NY-SUP, base similarity 0.72
  → Final score: 0.72 × 0.6 (unrelated) = 0.432
```

In this example, Document 1 would be ranked highest despite Document 2 being more directly relevant to the jurisdiction, because the Supreme Court has higher precedential value and the base similarity is higher.

## Citation Network Analysis

Beyond the formal jurisdiction hierarchy, the system also considers the citation network:

1. **Citation Count**: Documents cited more frequently receive higher scores
2. **Recent Citations**: More recent citations carry more weight
3. **Citation by Authoritative Sources**: Citations from higher courts have more impact

This provides a more nuanced view of precedential value beyond the formal hierarchy.

## Customization

The jurisdiction system can be configured to handle different legal systems:

1. **Custom Hierarchies**: Define new jurisdiction relationships
2. **Jurisdiction-Specific Prompts**: Modify context formation based on jurisdiction
3. **Boosting Factors**: Adjust the weights applied to different jurisdictional relationships

## Conclusion

The jurisdiction-aware approach ensures that legal research results respect the hierarchical nature of legal precedent, providing more accurate and relevant information to users working in specific jurisdictions.
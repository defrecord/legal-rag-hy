# Jurisdiction Handling

One of the key innovations of the Legal RAG System is its jurisdiction-aware search and ranking. This document explains how the system handles different jurisdictions and their relationships.

## Jurisdiction Hierarchy

The system represents the US legal jurisdiction hierarchy as follows:

```
┌────────────┐
│ US Supreme │
│   Court    │
└─────┬──────┘
      │
┌─────▼──────┐
│  Federal   │
│   Courts   │
└──┬──┬──┬───┘
   │  │  │
┌──▼┐┌▼┐┌▼──┐
│1st││..││9th│ Circuit Courts
└┬──┘└─┘└┬──┘
 │      │
┌▼──┐  ┌▼─┐
│ME │  │CA │ State Courts
└───┘  └┬─┘
        │
      ┌─▼───┐
      │CA   │
      │Sup. │ State Supreme Courts
      └─────┘
```

## Jurisdiction Codes

The system uses the following jurisdiction code format:

- **US-SCOTUS**: US Supreme Court
- **US-FED**: US Federal Courts (generic)
- **US-[N]CIR**: US Circuit Courts (e.g., US-9CIR for 9th Circuit)
- **[STATE]**: State courts (e.g., CA for California)
- **[STATE]-SUP**: State Supreme Courts (e.g., CA-SUP for California Supreme Court)
- **[STATE]-APP**: State Appellate Courts (e.g., CA-APP for California Court of Appeal)

## Jurisdiction Boosting

When searching for documents, the system applies a jurisdiction-based boosting factor:

1. **Direct Match**: A document from the exact jurisdiction gets highest boost (2.0)
2. **Hierarchical Match**: Documents from jurisdictions in the same hierarchy get a boost proportional to their relationship
3. **Circuit/State Relationship**: Documents from a state's circuit or vice versa get a moderate boost
4. **Non-Related**: Documents from unrelated jurisdictions get a slight penalty

### Example

For a query with jurisdiction `CA-9` (California in 9th Circuit):

- Document from `CA`: boost = 1.25 (direct state match)
- Document from `CA-SUP`: boost = 1.75 (state supreme court)
- Document from `US-9CIR`: boost = 1.5 (circuit court match)
- Document from `US-SCOTUS`: boost = 2.0 (always highest)
- Document from `NY`: boost = 0.75 (unrelated state)

## Citation Network Analysis

Beyond simple jurisdictional relationships, the system can also incorporate citation network analysis:

1. **Citation Count**: Documents cited more frequently receive a higher precedential value
2. **Citation Direction**: Documents that cite relevant cases receive a smaller boost
3. **Citation Age**: More recent citations may receive higher weight

## Configuration

When initializing the Legal RAG System, you can specify the jurisdiction:

```hy
(setv rag-system (LegalRAGSystem :jurisdiction "CA-9"))
```

This sets the default jurisdiction for all queries. You can also override it for specific queries:

```hy
(setv response (rag-system.query query :jurisdiction "NY-2"))
```

## Customizing Jurisdiction Hierarchy

To add or modify jurisdictions, you can edit the `JURISDICTIONS` dictionary in `jurisdiction.hy`:

```hy
(setv JURISDICTIONS
      {"US-FED" {"rank" 10
                "description" "US Federal"
                "circuits" ["US-1CIR" "US-2CIR"]}
       ;; Add your custom jurisdictions here
       "CUSTOM-J" {"rank" 20
                  "description" "Custom Jurisdiction"
                  "parent" "US-FED"}})
```

## International Jurisdictions

While the current implementation focuses on US jurisdictions, the system is designed to be extensible for international use. To add international jurisdictions, follow the same pattern:

```hy
;; Example for adding UK jurisdictions
(setv JURISDICTIONS
      {;; Existing US jurisdictions...
       
       "UK" {"rank" 10
            "description" "United Kingdom"
            "children" ["UK-ENG" "UK-SCT" "UK-NIR" "UK-WLS"]}
       
       "UK-ENG" {"rank" 25
                "description" "England and Wales"
                "parent" "UK"}
       
       "UK-SCT" {"rank" 25
                "description" "Scotland"
                "parent" "UK"}})
```
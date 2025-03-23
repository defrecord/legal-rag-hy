#!/usr/bin/env hy

(import [.system [LegalRAGSystem RAGResponse]]
        [.citation [format-citation parse-citation]]
        [.evaluation [evaluate-response]]
        [.jurisdiction [get-jurisdiction-boost calculate-precedential-value]])

__version__ = "0.1.0"
__author__ = "Kushagra Kumar <kkumar@defrecord.com>"
__license__ = "MIT"

;; Export public API
__all__ = ["LegalRAGSystem", "RAGResponse", 
          "format-citation", "parse-citation",
          "evaluate-response", "get-jurisdiction-boost"]
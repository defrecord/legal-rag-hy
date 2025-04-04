#!/usr/bin/env hy

(import [.system [LegalRAGSystem RAGResponse]])
(import [.citation [format-citation parse-citation]])
(import [.evaluation [evaluate-response]])
(import [.jurisdiction [get-jurisdiction-boost calculate-precedential-value]])

(setv __version__ "0.1.0")
(setv __author__ "DefRecord Team <info@defrecord.com>")
(setv __license__ "MIT")

;; Export public API
(setv __all__ ["LegalRAGSystem" "RAGResponse" 
              "format-citation" "parse-citation"
              "evaluate-response" "get-jurisdiction-boost"])
#!/usr/bin/env hy

(import
  [typing [Dict List Any Optional]]
  openai
  re
  [.citation [parse-citation]])

(defn evaluate-response [query answer citations retrieved-documents]
  "Evaluate RAG response across multiple dimensions"
  (let [;; Different evaluation components
        relevance (evaluate-relevance query answer)
        accuracy (evaluate-accuracy answer retrieved-documents)
        citation-quality (evaluate-citations answer citations retrieved-documents)
        hallucination-score (evaluate-hallucination answer retrieved-documents)
        
        ;; Combine scores
        overall-score (/ (+ relevance 
                           (* 2 accuracy)  ; Accuracy is most important
                           citation-quality
                           (* 1.5 (- 1 hallucination-score)))  ; Convert hallucination to positive
                        5.5)  ; Normalize by weights sum
        
        evaluation {"relevance" relevance
                   "accuracy" accuracy
                   "citation_quality" citation-quality
                   "hallucination" hallucination-score
                   "overall" overall-score}]
    
    evaluation))

(defn evaluate-relevance [query answer]
  "Evaluate relevance of answer to query"
  (let [;; Simple implementation - check for query keywords in answer
        query-words (set (lfor word (.lower (.split query)) 
                               :if (and word (>= (len word) 4))
                               word))
        answer-lower (.lower answer)
        matched-words (set (lfor word query-words 
                                :if (in word answer-lower)
                                word))
        
        keyword-match-rate (if query-words
                             (/ (len matched-words) (len query-words))
                             0)
        
        ;; More sophisticated evaluation can be implemented with LLM
        ;; This is a placeholder for a more robust implementation
        relevance-score (min 1.0 (+ 0.5 (* 0.5 keyword-match-rate)))]
    
    relevance-score))

(defn evaluate-accuracy [answer documents]
  "Evaluate factual accuracy of the answer relative to documents"
  ;; In a real implementation, this would use an LLM to evaluate factual consistency
  ;; For this example, we'll use a simpler approach
  
  (let [document-texts (lfor doc documents (get (get doc "document") "text" ""))
        answer-statements (lfor stmt (.split answer ".")
                               :if (>= (len (.strip stmt)) 10)
                               (.strip stmt))
        
        ;; Check statements against documents
        supporting-evidence (for [stmt answer-statements]
                              (any (lfor text document-texts
                                        (> (text-similarity (.lower stmt) (.lower text)) 0.7))))
        
        ;; Calculate support ratio
        supported-stmts (sum supporting-evidence)
        total-stmts (len answer-statements)
        
        accuracy-score (if (> total-stmts 0)
                         (/ supported-stmts total-stmts)
                         0.5)]
    
    (min 1.0 (max 0.0 accuracy-score))))

(defn evaluate-citations [answer citations documents]
  "Evaluate quality of citations in answer"
  (let [;; Get citation texts
        doc-citations (set (lfor doc documents
                               :if (and 
                                    (in "document" doc)
                                    (in "metadata" (get doc "document"))
                                    (in "case_name" (get (get doc "document") "metadata")))
                               (get (get (get doc "document") "metadata") "case_name")))
        
        ;; Number of citations
        citation-count (len citations)
        
        ;; Citations included from documents
        citation-texts (set (lfor citation citations
                                :if (in "citation" citation)
                                (get citation "citation")))
        
        ;; Citation metrics
        citation-ratio (if (> (len doc-citations) 0)
                         (/ (len citation-texts) (len doc-citations))
                         (if (> citation-count 0) 0.8 0.2))
        
        ;; Calculate final score
        citation-score (cond
                       [(= citation-count 0) 0.1]  ; No citations is bad
                       [(< citation-count 2) 0.5]  ; Few citations
                       [(>= citation-count 3) (min 1.0 (* citation-ratio 1.25))])]  ; More citations with ratio adjustment
    
    citation-score))

(defn evaluate-hallucination [answer documents]
  "Check for hallucinations (facts not in retrieved documents)"
  ;; This is a simplified implementation
  ;; A full implementation would use an LLM to check fact-by-fact
  
  (let [;; Extract key factual sentences
        fact-statements (lfor stmt (.split answer ".")
                             :if (and 
                                  (re.search r"\b(is|was|were|has|had|will|would|could|should|may|might)\b" stmt)
                                  (not (re.search r"\bI think\b|\bperhaps\b|\bmaybe\b|\bpossibly\b" stmt))
                                  (>= (len (.strip stmt)) 15))
                             (.strip stmt))
        
        ;; Get document content
        document-texts (lfor doc documents (get (get doc "document") "text" ""))
        combined-text (.join " " document-texts)
        
        ;; Check each fact against the document content
        unsupported-facts-count 0
        _ (for [fact fact-statements]
            (when (< (text-similarity (.lower fact) (.lower combined-text)) 0.6)
              (setv unsupported-facts-count (+ unsupported-facts-count 1))))
        
        ;; Calculate hallucination score (0 = no hallucination, 1 = all hallucination)
        hallucination-score (if (> (len fact-statements) 0)
                              (/ unsupported-facts-count (len fact-statements))
                              0.5)]
    
    hallucination-score))

(defn text-similarity [text1 text2]
  "Simple text similarity measure (placeholder for more sophisticated implementation)"
  ;; This is a very simplified implementation
  ;; Production system would use embeddings or LLM-based evaluation
  
  (let [;; Tokenize to words
        words1 (set (.split text1))
        words2 (set (.split text2))
        
        ;; Calculate overlap
        overlap (set.intersection words1 words2)
        union (set.union words1 words2)
        
        similarity (if union
                     (/ (len overlap) (len union))
                     0)]
    
    similarity))
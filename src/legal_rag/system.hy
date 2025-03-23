#!/usr/bin/env hy

(import
  os
  json
  [datetime [datetime timedelta]]
  [typing [Dict List Any Optional Tuple]]
  [functools [lru_cache]]
  [dataclasses [dataclass]]
  
  ;; Vector database and embeddings
  numpy :as np
  faiss
  
  ;; LLM client
  openai
  
  ;; Local imports
  [.cache [EmbeddingCache]]
  [.citation [format-citation parse-citation]]
  [.jurisdiction [get-jurisdiction-boost calculate-precedential-value]]
  [.evaluation [evaluate-response]]
  [.utils [retry_with_exponential_backoff timeout]])

;; Configure API key
(setv openai.api_key (os.getenv "OPENAI_API_KEY"))

;; Response dataclass
(dataclass
  (defclass RAGResponse []
    "Response from the Legal RAG system"
    (^str answer None)
    (^List citations [])
    (^Dict metadata {})
    (^List retrieved-documents [])
    (^float confidence 0.0)
    (^Dict evaluation {})))

;; Main RAG System
(defclass LegalRAGSystem []
  "Jurisdiction-aware legal RAG system"
  
  (defn __init__ [self
                 &optional
                 [^str embedding-model "text-embedding-3-large"]
                 [^str llm-model "gpt-4o"]
                 [^str jurisdiction "US-FED"]
                 [^int max-tokens 1024]
                 [^bool use-cache True]
                 [^int cache-ttl 86400]  ; 24 hours
                 [^str index-path None]]
    "Initialize the Legal RAG system"
    (setv self.embedding-model embedding-model)
    (setv self.llm-model llm-model)
    (setv self.jurisdiction jurisdiction)
    (setv self.max-tokens max-tokens)
    (setv self.use-cache use-cache)
    
    ;; Set up embedding cache if enabled
    (when use-cache
      (setv self.embedding-cache (EmbeddingCache :ttl cache-ttl)))
    
    ;; Load vector index
    (self.load-index index-path))
  
  (defn load-index [self &optional [index-path None]]
    "Load the FAISS vector index from disk or initialize a new one"
    (if (and index-path (os.path.exists index-path))
        ;; Load existing index
        (do
          (setv self.index (faiss.read_index index-path))
          (with [f (open f"{index-path}.meta" "r")]
            (setv self.document-store (json.load f))))
        
        ;; Initialize new index
        (do
          (setv self.document-store {})
          (setv dimension 1536)  ; Default for OpenAI embeddings
          (setv self.index (faiss.IndexFlatL2 dimension)))))
  
  (defn save-index [self index-path]
    "Save the FAISS vector index to disk"
    (faiss.write_index self.index index-path)
    (with [f (open f"{index-path}.meta" "w")]
      (json.dump self.document-store f)))
  
  (defn add-document [self document]
    "Add a document to the vector index"
    (let [text (get document "text")
          metadata (get document "metadata")
          
          ;; Generate embedding
          embedding (self.generate-embedding text)
          
          ;; Add to FAISS index
          document-id (len self.document-store)
          _ (self.index.add (np.array [embedding] :dtype np.float32))
          
          ;; Add to document store
          document-with-embedding (.copy document)
          _ (setv (get document-with-embedding "embedding") embedding)
          _ (setv (get self.document-store (str document-id)) document-with-embedding)]
      
      document-id))
  
  (defn bulk-add-documents [self documents]
    "Add multiple documents to the vector index"
    (let [document-ids (lfor doc documents
                             (self.add-document doc))]
      document-ids))
  
  @(retry_with_exponential_backoff
    :initial-delay 1
    :max-retries 3
    :factor 2)
  @(timeout :seconds 10)
  (defn generate-embedding [self text]
    "Generate embedding for text using OpenAI API with caching"
    
    (if (and self.use-cache (hasattr self "embedding-cache"))
        ;; Try to get from cache first
        (let [cached-embedding (self.embedding-cache.get text)]
          (if cached-embedding
              cached-embedding
              ;; Not in cache, generate and store
              (let [embedding (self._generate-embedding-api text)]
                (self.embedding-cache.set text embedding)
                embedding)))
        
        ;; No cache, directly call API
        (self._generate_embedding_api text)))
  
  (defn _generate-embedding-api [self text]
    "Generate embedding via API call"
    (let [response (openai.embeddings.create
                     :model self.embedding-model
                     :input text)
          embedding (get (get response "data" [{}]) 0 {})
          embedding-vector (get embedding "embedding" [])]
      
      (np.array embedding-vector :dtype np.float32)))
  
  (defn search-similar-documents [self query &optional [k 5]]
    "Find k most similar documents to query"
    (let [query-embedding (self.generate-embedding query)
          
          ;; Custom similarity function with jurisdiction boost
          similarity-fn (fn [doc-id doc-embedding]
                          (let [doc (get self.document-store (str doc-id))
                                metadata (get doc "metadata")
                                base-score (self.cosine-similarity 
                                             query-embedding 
                                             doc-embedding)
                                jurisdiction-boost (get-jurisdiction-boost 
                                                     self.jurisdiction
                                                     (get metadata "jurisdiction" "US-FED"))]
                            (* base-score jurisdiction-boost)))
          
          ;; Perform search
          [distances indices] (self.index.search (np.array [query-embedding] :dtype np.float32) (* k 2))
          
          ;; Get documents and calculate custom scores
          results []
          _ (for [idx indices[0]]
              (when (>= idx 0)
                (let [doc-id (str idx)
                      document (get self.document-store doc-id)
                      embedding (get document "embedding")
                      score (similarity-fn idx embedding)]
                  
                  (.append results {"document" document
                                   "score" score}))))
          
          ;; Sort by custom score and take top k
          sorted-results (sorted results :key (fn [r] (- (get r "score"))))
          top-k-results (cut sorted-results 0 k)]
      
      top-k-results))
  
  (defn cosine-similarity [self v1 v2]
    "Calculate cosine similarity between two vectors"
    (let [dot-product (np.dot v1 v2)
          norm-v1 (np.linalg.norm v1)
          norm-v2 (np.linalg.norm v2)]
      
      (/ dot-product (* norm-v1 norm-v2))))
  
  (defn format-context [self query results]
    "Format retrieved documents into LLM context"
    (let [;; Extract document content with metadata
          documents (lfor result results
                         (let [doc (get result "document")
                               text (get doc "text")
                               meta (get doc "metadata")
                               citation (format-citation meta)
                               score (get result "score")]
                           {"content" text
                            "citation" citation
                            "relevance" score}))
          
          ;; Order by relevance and create context string
          context-parts (lfor [i doc] (enumerate documents)
                             (format "Document #{(+ i 1)}: {(get doc \"content\")}\n"
                                    "Citation: {(get doc \"citation\")}\n"
                                    "Relevance: {(get doc \"relevance\"):.4f}\n\n"))
          
          ;; Combine with query
          system-context (format "Use these documents to answer the legal query.\n"
                                "Always cite specific documents in your answer.\n"
                                "If documents are insufficient, state this clearly.\n\n"
                                "Query: {query}\n\n"
                                "Retrieved documents:\n{(.join \"\" context-parts)}"))]
      
      system-context))
  
  @(retry_with_exponential_backoff
    :initial-delay 1
    :max-retries 3
    :factor 2)
  @(timeout :seconds 30)
  (defn generate-answer [self context]
    "Generate answer using LLM"
    (let [messages [{"role" "system"
                     "content" "You are a legal research assistant with expertise in case law and legislation. Provide accurate, well-cited answers."}
                    {"role" "user"
                     "content" context}]
          
          response (openai.chat.completions.create
                     :model self.llm-model
                     :messages messages
                     :max_tokens self.max-tokens
                     :temperature 0.2)
          
          answer (get (get response "choices" [{}]) 0 {})
          answer-text (get (get answer "message" {}) "content" "")
          
          ;; Extract citations from the response
          citations (parse-citation answer-text)]
      
      {"answer" answer-text
       "citations" citations}))
  
  (defn query [self query]
    "Full query pipeline"
    (let [;; Retrieve similar documents
          results (self.search-similar-documents query)
          
          ;; Format context
          context (self.format-context query results)
          
          ;; Generate answer
          generated-result (self.generate-answer context)
          
          answer (get generated-result "answer")
          citations (get generated-result "citations")
          
          ;; Evaluate response
          evaluation (evaluate-response 
                      query 
                      answer 
                      citations 
                      results)
          
          ;; Calculate confidence score
          avg-relevance (/ (sum (lfor r results (get r "score"))) (max 1 (len results)))
          confidence (min 1.0 (* 0.7 avg-relevance (get evaluation "accuracy" 0.5)))
          
          ;; Create response object
          response (RAGResponse
                    :answer answer
                    :citations citations
                    :metadata {"query" query
                              "jurisdiction" self.jurisdiction
                              "timestamp" (str (datetime.now))}
                    :retrieved-documents results
                    :confidence confidence
                    :evaluation evaluation)]
      
      response)))
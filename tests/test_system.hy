#!/usr/bin/env hy

(import
  unittest
  [unittest.mock [patch MagicMock]]
  numpy :as np
  [legal_rag.system [LegalRAGSystem RAGResponse]]
  [legal_rag.jurisdiction [get-jurisdiction-boost]]
  [legal_rag.citation [parse-citation format-citation]])

(defclass TestLegalRAGSystem [unittest.TestCase]
  "Test cases for the LegalRAGSystem"
  
  (defn setUp [self]
    "Set up test fixtures"
    ;; Create test system with mocked embeddings
    (with [
           (patch "legal_rag.system.openai.embeddings.create")
           (patch "legal_rag.system.openai.chat.completions.create")]
      (setv self.rag-system (LegalRAGSystem 
                            :embedding-model "test-embedding"
                            :llm-model "test-llm"
                            :jurisdiction "US-9CIR"
                            :use-cache False))
      
      ;; Add test documents
      (setv self.test-docs [
        {"text" "This is a test Supreme Court case about fair use."
         "metadata" {"case_name" "Test v. Test"
                    "court" "Supreme Court"
                    "citation" "123 U.S. 456"
                    "year" "2020"
                    "jurisdiction" "US-SCOTUS"}}
        {"text" "This is a test Ninth Circuit case about fair use."
         "metadata" {"case_name" "Another v. Another"
                    "court" "9th Circuit"
                    "citation" "789 F.3d 012"
                    "year" "2018"
                    "jurisdiction" "US-9CIR"}}
      ])
      
      ;; Mock vector operations
      (setv self.rag-system._generate-embedding-api (MagicMock :return_value (np.ones 1536)))
      (setv self.rag-system.generate-answer (MagicMock :return_value {"answer" "Test answer" "citations" []}))
      
      ;; Add test documents
      (self.rag-system.bulk-add-documents self.test-docs)))
  
  (defn test-system-initialization [self]
    "Test system initialization"
    (self.assertEqual self.rag-system.jurisdiction "US-9CIR")
    (self.assertEqual self.rag-system.embedding-model "test-embedding")
    (self.assertEqual self.rag-system.llm-model "test-llm"))
  
  (defn test-document-addition [self]
    "Test adding documents to system"
    (self.assertEqual (len self.rag-system.document-store) 2)
    (self.assertIn "0" self.rag-system.document-store)
    (self.assertIn "1" self.rag-system.document-store))
  
  (defn test-search-similar-documents [self]
    "Test document search functionality"
    ;; Mock index.search to return specific indices
    (setv self.rag-system.index.search (MagicMock :return_value [(np.array [[0.1 0.2]]) (np.array [[0 1]])]))
    
    ;; Search for documents
    (setv results (self.rag-system.search-similar-documents "test query" :k 2))
    
    ;; Check results
    (self.assertEqual (len results) 2)
    (self.assertIn "document" (get results 0))
    (self.assertIn "score" (get results 0)))
  
  (defn test-format-context [self]
    "Test context formation"
    ;; Create test results
    (setv test-results [
      {"document" {"text" "Test document 1"
                  "metadata" {"case_name" "Test v. Test"}}
       "score" 0.9}
      {"document" {"text" "Test document 2"
                  "metadata" {"case_name" "Another v. Another"}}
       "score" 0.8}
    ])
    
    ;; Format context
    (setv context (self.rag-system.format-context "test query" test-results))
    
    ;; Check context formation
    (self.assertIn "test query" context)
    (self.assertIn "Test document 1" context)
    (self.assertIn "Test document 2" context)
    (self.assertIn "Test v. Test" context))
  
  (defn test-query [self]
    "Test full query pipeline"
    ;; Mock search results
    (setv self.rag-system.search-similar-documents (MagicMock :return_value [
      {"document" {"text" "Test document 1"
                  "metadata" {"case_name" "Test v. Test"}}
       "score" 0.9}
    ]))
    
    ;; Mock evaluate response
    (with [(patch "legal_rag.system.evaluate-response" :return_value {"accuracy" 0.8 "relevance" 0.9 "overall" 0.85})]
      ;; Run query
      (setv response (self.rag-system.query "What is fair use?"))
      
      ;; Check response
      (self.assertIsInstance response RAGResponse)
      (self.assertEqual response.answer "Test answer")
      (self.assertIn "query" response.metadata)
      (self.assertEqual response.metadata["query"] "What is fair use?"))))

(defclass TestJurisdictionFunctions [unittest.TestCase]
  "Test cases for jurisdiction functions"
  
  (defn test-jurisdiction-boost [self]
    "Test jurisdiction boost calculation"
    ;; Test exact match
    (setv boost1 (get-jurisdiction-boost "US-9CIR" "US-9CIR"))
    (self.assertEqual boost1 2.0)
    
    ;; Test parent jurisdiction
    (setv boost2 (get-jurisdiction-boost "CA" "US-9CIR"))
    (self.assertGreater boost2 1.0)
    
    ;; Test supreme court (always high)
    (setv boost3 (get-jurisdiction-boost "CA" "US-SCOTUS"))
    (self.assertEqual boost3 2.0)
    
    ;; Test unrelated jurisdictions
    (setv boost4 (get-jurisdiction-boost "NY" "CA"))
    (self.assertLess boost4 1.0)))

(defclass TestCitationFunctions [unittest.TestCase]
  "Test cases for citation functions"
  
  (defn test-format-citation [self]
    "Test citation formatting"
    ;; Test with complete metadata
    (setv metadata1 {"case_name" "Test v. Test"
                   "court" "Supreme Court"
                   "reporter" "U.S."
                   "volume" "123"
                   "page" "456"
                   "year" "2020"})
    (setv citation1 (format-citation metadata1))
    (self.assertIn "Test v. Test" citation1)
    (self.assertIn "123" citation1)
    (self.assertIn "U.S." citation1)
    (self.assertIn "456" citation1)
    (self.assertIn "2020" citation1)
    
    ;; Test with minimal metadata
    (setv metadata2 {"case_name" "Minimal v. Case"
                   "year" "2019"})
    (setv citation2 (format-citation metadata2))
    (self.assertIn "Minimal v. Case" citation2)
    (self.assertIn "2019" citation2))
  
  (defn test-parse-citation [self]
    "Test citation parsing"
    ;; Test parsing Supreme Court citation
    (setv text1 "As the Court held in Smith v. Jones, 567 U.S. 890 (2015), fair use is determined by four factors.")
    (setv citations1 (parse-citation text1))
    (self.assertEqual (len citations1) 1)
    (self.assertEqual (get (get citations1 0) "jurisdiction") "US-SCOTUS")
    (self.assertEqual (get (get citations1 0) "volume") "567")
    (self.assertEqual (get (get citations1 0) "page") "890")
    
    ;; Test parsing Federal Reporter citation
    (setv text2 "According to Brown v. Board, 347 F.2d 483 (9th Cir. 1965), schools must be integrated.")
    (setv citations2 (parse-citation text2))
    (self.assertEqual (len citations2) 1)
    (self.assertEqual (get (get citations2 0) "jurisdiction") "US-FED")
    (self.assertEqual (get (get citations2 0) "volume") "347")
    (self.assertEqual (get (get citations2 0) "page") "483")
    
    ;; Test parsing multiple citations
    (setv text3 "The court in 123 U.S. 456 (1999) and 789 F.3d 012 (9th Cir. 2001) held that...")
    (setv citations3 (parse-citation text3))
    (self.assertEqual (len citations3) 2)))

(when (= __name__ "__main__")
  (unittest.main))
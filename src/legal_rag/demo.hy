#!/usr/bin/env hy

(import sys)
(import os)
(import numpy :as np)
(import [.system [LegalRAGSystem]])
(import [.cache [EmbeddingCache]])
(import [.citation [format-citation]])

(defn generate-sample-documents []
  "Generate sample legal documents for demo"
  [
    ;; Supreme Court case
    {"text" "The fair use doctrine is a legal principle that permits limited use of copyrighted material without acquiring permission from the rights holders. It is an exception to the exclusive rights granted by copyright law to the author of a creative work. In Campbell v. Acuff-Rose Music, Inc., the Supreme Court recognized that the fair use doctrine is an \"equitable rule of reason\" which permits courts to avoid rigid application of the copyright statute when it would stifle the very creativity that law is designed to foster."
     "metadata" {"case_name" "Campbell v. Acuff-Rose Music, Inc."
                "court" "Supreme Court"
                "citation" "510 U.S. 569"
                "year" "1994"
                "jurisdiction" "US-SCOTUS"
                "practice_area" "Intellectual Property"}}
    
    ;; 9th Circuit case
    {"text" "In the Ninth Circuit's decision in Perfect 10 v. Amazon, the court held that search engines' creation and display of thumbnail images constituted fair use. The court emphasized that the use was highly transformative because the thumbnails served a different function than the original images. This transformative nature was sufficient to outweigh the commercial aspects of Google's use. The court also noted that the thumbnails did not harm the potential market for the original images because they were not substitutes for the full-sized images."
     "metadata" {"case_name" "Perfect 10, Inc. v. Amazon.com, Inc."
                "court" "9th Circuit"
                "citation" "508 F.3d 1146"
                "year" "2007"
                "jurisdiction" "US-9CIR"
                "practice_area" "Intellectual Property"}}
    
    ;; California case
    {"text" "Under California law, determining whether a use of copyrighted material constitutes fair use requires an analysis of four factors: (1) the purpose and character of the use, including whether such use is of a commercial nature or is for nonprofit educational purposes; (2) the nature of the copyrighted work; (3) the amount and substantiality of the portion used in relation to the copyrighted work as a whole; and (4) the effect of the use upon the potential market for or value of the copyrighted work. These factors should not be treated in isolation but weighed together in light of the purposes of copyright."
     "metadata" {"case_name" "Zucker v. Los Angeles Times"
                "court" "California Supreme Court"
                "citation" "18 Cal.4th 168"
                "year" "2005"
                "jurisdiction" "CA-SUP"
                "practice_area" "Intellectual Property"}}
    
    ;; Explanatory document
    {"text" "Fair use is determined on a case-by-case basis, and all four factors must be weighed together. Transformative uses, which add something new or serve a different purpose than the original work, are more likely to be considered fair use. Examples of transformative uses include parody, criticism, commentary, news reporting, teaching, scholarship, and research. However, commercial uses are less likely to be considered fair use, though this is not determinative. The second factor considers whether the original work is creative or factual, with greater protection given to creative works. The third factor examines how much of the original work was used, both quantitatively and qualitatively. The fourth factor assesses market harm to the original work."
     "metadata" {"title" "Fair Use Doctrine Explanation"
                "author" "Legal Research Institute"
                "year" "2023"
                "jurisdiction" "US-FED"
                "practice_area" "Intellectual Property"}}
  ])

(defn demo []
  "Run an interactive demo of the Legal RAG system"
  (print "\nLegal RAG System Demo")
  (print "=====================\n")
  
  ;; Create system
  (setv rag-system (LegalRAGSystem 
                    :embedding-model "text-embedding-3-large"
                    :llm-model "gpt-4o"
                    :jurisdiction "CA-9"))
  
  ;; Add sample documents
  (setv sample-docs (generate-sample-documents))
  (. rag-system (bulk-add-documents sample-docs))
  (print f"Added {(len sample-docs)} sample documents to the system.\n")
  
  ;; Interactive query loop
  (print "Enter legal queries about fair use (or 'exit' to quit):")
  (while True
    (print "\nQuery> " :end "")
    (. sys stdout (flush))
    (setv query (. (input) (strip)))
    
    (when (or (= query "exit") (= query "quit"))
      (break))
    
    (when (< (len query) 5)
      (print "Query too short. Please enter a more detailed question.")
      (continue))
    
    (print "\nProcessing query...")
    (setv response (. rag-system (query query)))
    
    (print "\n" (+ "=" (* 80 "-")))
    (print response.answer)
    (print (+ "=" (* 80 "-")))
    
    (print "\nCitations:")
    (for [citation response.citations]
      (print f"- {(get citation \"citation\")}"))
    
    (print f"\nConfidence: {(* 100 response.confidence):.1f}%")
    
    (print "\nRetrieved documents:")
    (for [[i doc] (enumerate response.retrieved-documents)]
      (setv citation (format-citation (get (get doc "document") "metadata")))
      (print f"{(+ i 1)}. {citation} (Score: {(get doc \"score\"):.4f})")))
  
  (print "\nThank you for using the Legal RAG System!"))

(when (= __name__ "__main__")
  (demo))
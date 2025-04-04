#!/usr/bin/env hy

(import
  re
  [typing [Dict List Any Optional]])

;; Citation parsing patterns
(setv CITATION_PATTERNS
      [;; US Reports (Supreme Court)
       {"pattern" r"(\d+)\s+U\.S\.\s+(\d+)(?:\s+\((\d{4})\))?"
        "format" "U.S. Reports"
        "jurisdiction" "US-SCOTUS"}
       
       ;; Federal Reporter
       {"pattern" r"(\d+)\s+F\.(?:(?:Supp)|(?:2d)|(?:3d))\.\s+(\d+)(?:\s+\(([a-zA-Z0-9.]+)\s+(\d{4})\))?"
        "format" "Federal Reporter"
        "jurisdiction" "US-FED"}
       
       ;; California Reporter
       {"pattern" r"(\d+)\s+Cal\.(?:(?:App)\.)?(?:(?:2d)|(?:3d)|(?:4th)|(?:5th))?\s+(\d+)(?:\s+\((\d{4})\))?"
        "format" "California Reporter"
        "jurisdiction" "CA"}
       
       ;; New York Reporter
       {"pattern" r"(\d+)\s+N\.Y\.(?:(?:2d)|(?:3d))?\s+(\d+)(?:\s+\((\d{4})\))?"
        "format" "New York Reporter"
        "jurisdiction" "NY"}])

(defn format-citation [metadata]
  "Format case metadata into a citation string"
  (let [case-name (get metadata "case_name" "")
        court (get metadata "court" "")
        reporter (get metadata "reporter" "")
        volume (get metadata "volume" "")
        page (get metadata "page" "")
        year (get metadata "year" "")]
    
    (if (and case-name reporter volume page)
        ;; Full citation
        (format "{case-name}, {volume} {reporter} {page} ({court} {year})"
                :case-name case-name
                :volume volume
                :reporter reporter
                :page page
                :court court
                :year year)
        
        ;; Partial citation
        (format "{case-name} ({year})"
                :case-name (or case-name "Unknown Case")
                :year (or year "n.d.")))))

(defn parse-citation [text]
  "Extract citations from text"
  (let [citations []
        ;; Look for each pattern
        _ (for [pattern CITATION_PATTERNS]
            (let [matches (re.finditer (get pattern "pattern") text)]
              (for [match matches]
                (let [groups (. match (groups))
                      citation {"citation" (. match (group 0))
                                "volume" (get groups 0)
                                "page" (get groups 1)
                                "format" (get pattern "format")
                                "jurisdiction" (get pattern "jurisdiction")}]
                  (when (>= (len groups) 3)
                    (setv (get citation "year") (get groups 2)))
                  
                  (. citations (append citation)))))]
    
    ;; Return unique citations
    (let [unique-citations {}
          _ (for [citation citations]
              (setv (get unique-citations (get citation "citation")) citation))
          result (list (. unique-citations (values)))]
      
      result)))
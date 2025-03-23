#!/usr/bin/env hy

(import
  [typing [Dict Set List Any Optional]])

;; Define jurisdiction hierarchy
(setv JURISDICTIONS
      {"US-FED" {"rank" 10
                "description" "US Federal"
                "circuits" ["US-1CIR" "US-2CIR" "US-3CIR" "US-4CIR" "US-5CIR" 
                           "US-6CIR" "US-7CIR" "US-8CIR" "US-9CIR" "US-10CIR"
                           "US-11CIR" "US-DCCIR"]}
       
       "US-SCOTUS" {"rank" 100
                    "description" "US Supreme Court"
                    "parent" "US-FED"}
       
       ;; Federal Circuits
       "US-1CIR" {"rank" 30
                 "description" "US First Circuit"
                 "parent" "US-FED"
                 "states" ["ME" "MA" "NH" "RI" "PR"]}
       
       "US-2CIR" {"rank" 30
                 "description" "US Second Circuit"
                 "parent" "US-FED"
                 "states" ["NY" "VT" "CT"]}
       
       "US-3CIR" {"rank" 30
                 "description" "US Third Circuit"
                 "parent" "US-FED"
                 "states" ["PA" "NJ" "DE" "VI"]}
       
       "US-9CIR" {"rank" 30
                 "description" "US Ninth Circuit"
                 "parent" "US-FED"
                 "states" ["CA" "OR" "WA" "NV" "AZ" "ID" "MT" "AK" "HI" "GU" "MP"]}
       
       ;; Sample States
       "CA" {"rank" 25
            "description" "California"
            "circuit" "US-9CIR"}
       
       "CA-SUP" {"rank" 28
                "description" "California Supreme Court"
                "parent" "CA"}
       
       "CA-APP" {"rank" 27
                "description" "California Court of Appeal"
                "parent" "CA"}
       
       "NY" {"rank" 25
            "description" "New York"
            "circuit" "US-2CIR"}
       
       "NY-COURT-APP" {"rank" 28
                       "description" "New York Court of Appeals"
                       "parent" "NY"}})

(defn get-jurisdiction-hierarchy [jurisdiction-code]
  "Get jurisdiction and all ancestors in hierarchy"
  (let [hierarchy []
        current-code jurisdiction-code]
    
    (while (and current-code (in current-code JURISDICTIONS))
      (.append hierarchy current-code)
      
      ;; Move up to parent jurisdiction
      (setv current-code (get (get JURISDICTIONS current-code) "parent" None))
      
      ;; Also add circuit if state
      (when (and current-code (not (in "parent" (get JURISDICTIONS current-code))))
        (let [circuit (get (get JURISDICTIONS current-code) "circuit" None)]
          (when circuit
            (.append hierarchy circuit)
            (setv current-code (get (get JURISDICTIONS circuit) "parent" None))))))
    
    ;; Always include federal as fallback
    (when (not (in "US-FED" hierarchy))
      (.append hierarchy "US-FED"))
    
    hierarchy))

(defn get-jurisdiction-boost [query-jurisdiction doc-jurisdiction &optional [max-boost 2.0] [min-boost 0.5]]
  "Calculate jurisdiction relevance boost factor"
  (let [;; Get hierarchies for both jurisdictions
        query-hierarchy (get-jurisdiction-hierarchy query-jurisdiction)
        doc-hierarchy (get-jurisdiction-hierarchy doc-jurisdiction)
        
        ;; Get jurisdiction ranks
        query-rank (get (get JURISDICTIONS query-jurisdiction {}) "rank" 0)
        doc-rank (get (get JURISDICTIONS doc-jurisdiction {}) "rank" 0)
        
        ;; Check for direct hierarchy match
        direct-match (in doc-jurisdiction query-hierarchy)
        
        ;; Check for shared circuits/parents
        shared-jurisdictions (set.intersection (set query-hierarchy) (set doc-hierarchy))
        
        ;; Calculate base boost based on rank difference
        rank-boost (if (>= doc-rank query-rank)
                     ;; Higher rank (e.g. SCOTUS > Circuit) gets boost
                     (min max-boost (+ 1.0 (* 0.01 (- doc-rank query-rank))))
                     ;; Lower rank gets slight penalty but still relevant
                     (max min-boost (- 1.0 (* 0.01 (- query-rank doc-rank)))))
        
        ;; Adjust for hierarchy relationship
        hierarchy-boost (cond
                        ;; Direct match gets highest boost
                        [direct-match max-boost]
                        ;; Shared jurisdiction gets medium boost
                        [(> (len shared-jurisdictions) 0) (min max-boost (+ 1.0 (* 0.25 (len shared-jurisdictions))))]
                        ;; Default case - use rank-based boost
                        [True rank-boost])
        
        ;; Special case for SCOTUS - always relevant
        final-boost (if (= doc-jurisdiction "US-SCOTUS")
                      max-boost
                      hierarchy-boost)]
    
    final-boost))

(defn calculate-precedential-value [citation-network query-doc]
  "Calculate precedential value based on citation network"
  (let [citation-count (get citation-network query-doc 0)
        ;; Simple PageRank-inspired formula
        value (min 1.5 (+ 1.0 (* 0.05 (math.log (+ citation-count 1) 10))))]
    value))
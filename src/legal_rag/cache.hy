#!/usr/bin/env hy

(import
  os
  pickle
  [datetime [datetime timedelta]]
  [typing [Dict Any Optional]]
  [pathlib [Path]]
  [hashlib [md5]])

(defclass EmbeddingCache []
  "Cache for embeddings with TTL"
  
  (defn __init__ [self &optional 
                 [^int ttl 86400]  ; Default 24 hours in seconds
                 [^str cache-dir "cache"]
                 [^str version "v1"]]
    "Initialize embedding cache"
    (setv self.ttl ttl)
    (setv self.version version)
    
    ;; Create cache directory if it doesn't exist
    (setv self.cache-dir (os.path.join (os.path.dirname (os.path.abspath __file__)) cache-dir))
    (os.makedirs self.cache-dir :exist_ok True)
    
    ;; Load cache if it exists
    (setv self.cache-path (os.path.join self.cache-dir f"embedding_cache_{version}.pkl"))
    
    (if (os.path.exists self.cache-path)
        (self.load-cache)
        (setv self.cache {})))
  
  (defn load-cache [self]
    "Load cache from disk"
    (try
      (with [f (open self.cache-path "rb")]
        (setv self.cache (pickle.load f)))
      (except [e Exception]
        (print f"Error loading cache: {e}")
        (setv self.cache {}))))
  
  (defn save-cache [self]
    "Save cache to disk"
    (try
      (with [f (open self.cache-path "wb")]
        (pickle.dump self.cache f))
      (except [e Exception]
        (print f"Error saving cache: {e}"))))
  
  (defn get-key [self text]
    "Generate a unique key for the text"
    (let [hash-obj (md5 (.encode text "utf-8"))]
      (.hexdigest hash-obj)))
  
  (defn get [self text]
    "Get embedding from cache if it exists and is not expired"
    (let [key (self.get-key text)]
      (when (in key self.cache)
        (let [entry (get self.cache key)
              created-at (get entry "created_at")
              embedding (get entry "embedding")
              
              ;; Check if entry is expired
              now (datetime.now)
              expiry-time (+ created-at (timedelta :seconds self.ttl))]
          
          (if (< now expiry-time)
              ;; Valid cache entry
              embedding
              ;; Expired, remove from cache
              (do
                (del (get self.cache key))
                None))))))
  
  (defn set [self text embedding]
    "Store embedding in cache"
    (let [key (self.get-key text)]
      (setv (get self.cache key) {"embedding" embedding
                                  "created_at" (datetime.now)})
      
      ;; Save cache to disk (could be optimized to save less frequently)
      (self.save-cache)
      
      embedding))
  
  (defn clear [self]
    "Clear the entire cache"
    (setv self.cache {})
    (self.save-cache))
  
  (defn clean-expired [self]
    "Remove expired entries from cache"
    (let [now (datetime.now)
          expired-keys []]
      
      ;; Find expired keys
      (for [[key entry] (.items self.cache)]
        (let [created-at (get entry "created_at")
              expiry-time (+ created-at (timedelta :seconds self.ttl))]
          (when (>= now expiry-time)
            (.append expired-keys key))))
      
      ;; Remove expired entries
      (for [key expired-keys]
        (del (get self.cache key)))
      
      (when expired-keys
        (self.save-cache))
      
      (len expired-keys)))
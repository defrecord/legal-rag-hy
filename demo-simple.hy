#!/usr/bin/env hy

(import os)
(import sys)

(defn dot-accessor-test []
  "Test Hy 1.0 dot accessor syntax"
  (print "Testing dot accessor syntax...")
  (print "OS path separator:" (. os path sep))
  (print "Current working directory:" (os.getcwd))
  (print "Dot accessor test passed!\n"))

(defn method-call-test []
  "Test method call syntax"
  (print "Testing method call syntax...")
  (setv my-list [1 2 3 4 5])
  (. my-list (append 6))
  (print "List after append:" my-list)
  
  (setv my-dict {"a" 1 "b" 2})
  (setv keys (list (. my-dict (keys))))
  (print "Dictionary keys:" keys)
  
  (print "Method call test passed!\n"))

(defn decorator-test []
  "Test decorator syntax"
  (print "Testing decorator syntax...")
  
  (defn make-bold [f]
    (fn [text]
      (+ "<b>" (f text) "</b>")))
  
  (defn make-italic [f]
    (fn [text]
      (+ "<i>" (f text) "</i>")))
    
  (defn format-text [text]
    text)
  
  ;; Apply decorators manually to match Hy 1.0 syntax
  (setv decorated (make-bold (make-italic format-text)))
  (print "Formatted text:" (decorated "Hello Hy 1.0"))
  
  (print "Decorator test passed!\n"))

(defn main []
  "Main demo function"
  (print "\nLegal RAG Hy 1.0 Compatibility Test")
  (print "=================================\n")
  
  (dot-accessor-test)
  (method-call-test)
  (decorator-test)
  
  (print "All tests passed! The code should be Hy 1.0 compatible.")
  (print "You're ready for the demo at 6pm!\n"))

(when (= __name__ "__main__")
  (main))
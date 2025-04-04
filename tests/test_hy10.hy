#!/usr/bin/env hy

(import os)
(import sys)
(import [hy.contrib.walk [let]])

(defn test-hy-1-0 []
  (print "Testing Hy 1.0 compatibility")
  (print "Current directory:" (os.getcwd))
  
  ;; Test dot accessor syntax
  (print "Path separator:" (. os path sep))
  
  ;; Test function definition and return
  (defn add [a b] 
    (+ a b))
  
  (print "1 + 2 =" (add 1 2))
  
  ;; Test decorator manual application
  (defn make-bold [f]
    (fn [text]
      (+ "<b>" (f text) "</b>")))
  
  (defn format-text [text]
    text)
  
  (setv decorated-format (make-bold format-text))
  
  (print "Formatted text:" (decorated-format "Hello Hy 1.0"))
  
  "All tests passed!")

(when (= __name__ "__main__")
  (test-hy-1-0))
#!/usr/bin/env hy

(import os)
(import sys)

(print "Hy 1.0 is running!")
(print "CWD:" (os.getcwd))

(defn test-function []
  (print "Test function working"))

(test-function)
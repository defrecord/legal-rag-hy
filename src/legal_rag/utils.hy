#!/usr/bin/env hy

(import
  time
  functools
  threading
  [typing [Any Callable TypeVar Optional]]
  [concurrent.futures [ThreadPoolExecutor TimeoutError]]
  [signal [signal SIGALRM SIG_IGN alarm]])

;; Type variable for function return type
(setv T (TypeVar "T"))

(defn retry_with_exponential_backoff [&optional 
                                    [initial-delay 1] 
                                    [max-retries 3] 
                                    [factor 2]]
  "Decorator for retrying a function with exponential backoff"
  (defn decorator [func]
    (defn wrapper [#* args #** kwargs]
      (setv retry-count 0)
      (setv delay initial-delay)
      
      (while True
        (try
          (return (func #* args #** kwargs))
          (except [e Exception]
            (setv retry-count (+ retry-count 1))
            
            (when (or (>= retry-count max-retries)
                      (isinstance e (+ [KeyboardInterrupt] 
                                      [SystemExit])))
              (raise e))
            
            (print f"Retrying {func.__name__} in {delay} seconds (attempt {retry-count}/{max-retries}) due to {e}")
            (time.sleep delay)
            (setv delay (* delay factor))))))
    
    (return wrapper))
  
  (return decorator))

(defn timeout [seconds]
  "Decorator to timeout a function after specified seconds (Unix-only)"
  (defn decorator [func]
    (defn wrapper [#* args #** kwargs]
      (defn handler [signum frame]
        (raise (TimeoutError f"Function {func.__name__} timed out after {seconds} seconds")))
      
      ;; Set the timeout handler
      (signal SIGALRM handler)
      (alarm seconds)
      
      (try
        (setv result (func #* args #** kwargs))
        (except [e Exception]
          (alarm 0)  ; Cancel the alarm
          (signal SIGALRM SIG_IGN)  ; Ignore future alarms
          (raise e))
        (else
          (alarm 0)  ; Cancel the alarm
          (signal SIGALRM SIG_IGN)  ; Ignore future alarms
          result)))
    
    (return wrapper))
  
  (return decorator))

(defn async-function [func]
  "Decorator to run a function asynchronously"
  (defn wrapper [#* args #** kwargs]
    (setv executor (ThreadPoolExecutor :max_workers 1))
    (setv future (.submit executor func #* args #** kwargs))
    (return future))
  
  (return wrapper))

(defn parallel_map [func items &optional [max-workers None]]
  "Apply a function to all items in parallel"
  (with [executor (ThreadPoolExecutor :max_workers (or max-workers (min 32 (+ (len items) 4))))]
    (list (.map executor func items))))
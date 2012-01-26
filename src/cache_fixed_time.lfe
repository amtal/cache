;;; Cache for a fixed amount of time.
;;;
;;; Works with temporal locality. Similar to "least recently used" cache, but:
;;; - Less predictable memory characteristics. Capacity planning may be needed.
;;; - Less vulnerable to high churn due to short cache line lifespan.
(include-lib "lfe_utils/include/all.lfe")
(defmodule cache_fixed_time 
  (using ets os)
  (export (init 2) (get 2) (put 3) (gc 2)))

; Table structure: {key,value,timestamp}
; Timestamp is an integer in microseconds.

(defn init [name size] 
  (ets:new name `(public named_table)))

(defn get [name key]
  (try (tuple 'hit (ets:lookup_element name key 2))
       (catch ((tuple 'exit 'badarg _) 'miss))))

(defn put [name key value]
  (ets:insert name (tuple key value (timestamp))))

(defn gc [name lifespan]
  (in (ets:match_delete name ms)
    [ms (match-spec ([(tuple _ _ t)] (when (<= t cutoff)) 'ok))]))
  

;; Integer microseconds.
(defn timestamp [] 
  (in (+ us (* mega (+ s (* ms mega))))
    [(tuple ms s us) (os:timestamp)]))

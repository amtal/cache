(include-lib "lfe_utils/include/all.lfe")
(defmodule cache
  (using lists)
  (export 
    (this 1)
    (init 1) (handle_info 2) (terminate 1) (code_change 3)
  ))

;; Caching wrapper.
(defn this [type name f args] 
  (case (: type get name args)
    ((tuple 'hit ret) ret)
    ('miss (let*
             (ret (funcall f args))
             (_ (: type put name args ret))
             ret))))

;;; The gen_server that schedules GC ticks.

(defn init

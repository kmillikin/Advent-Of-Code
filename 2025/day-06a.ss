;; The problems are arranged in a grid with operators at the bottom.  We can return a list of lists,
;; without reversing them.  That way the operators are first, and the operations are commutative
;; (addition and subtraction) so the order of the operands doesn't matter.  Likewise, we sum the
;; results so the order of the problems doesn't matter either.
(let ([problems
        (call-with-input-file "day-06.input"
          (lambda (ip)
            (let outer ([line (get-line ip)] [lines '()])
              (if (eof-object? line)
                  lines
                  (let ([sp (open-string-input-port line)])
                    (let inner ([datum (get-datum sp)] [line '()])
                      (if (eof-object? datum)
                          (outer (get-line ip) (cons line lines))
                          (inner (get-datum sp) (cons datum line)))))))))])
  (let ([sum (apply fold-left (lambda (sum . problem)
                                (+ sum (apply (if (eq? (car problem) '+) + *) (cdr problem))))
               0 problems)])
    (printf "~s\n" sum)))

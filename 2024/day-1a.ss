(let-values
    ([(left right)
      (call-with-input-file "day-1.input"
        (lambda (ip)
          ;; Read the input into a pair of (reversed) lists.  Assume that the
          ;; input is well-formed.
          (let loop ([left '()] [right '()])
            (let ([datum (read ip)])
              (if (eof-object? datum)
                  (values left right)
                  (loop (cons datum left) (cons (read ip) right)))))))])
  ;; Sort the lists and fold to compute the sum of the pairwise differences.
  (let ([sum (fold-left
               (lambda (sum m n)
                 (+ sum (abs (- m n))))
               0 (list-sort < left) (list-sort < right))])
    (display sum)
    (newline)))

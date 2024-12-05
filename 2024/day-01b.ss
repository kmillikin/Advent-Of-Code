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
  (let ([frequencies (make-eqv-hashtable)])
    ;; Iterate the right list to build a hashtable of frequencies.
    (let loop ([right right])
      (when (not (null? right))
        (hashtable-update! frequencies (car right) 1+ 0)
        (loop (cdr right))))
    ;; Iterate the left list to compute the similarity score.
    (let loop ([left left] [score 0])
      (if (null? left)
          (begin
            (display score)
            (newline))
          (let ([n (car left)])
            (loop (cdr left) (+ score (* n (hashtable-ref frequencies n 0)))))))))

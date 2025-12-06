(define input
  (call-with-input-file "day-11.input"
    (lambda (ip)
      (let loop ([d (get-datum ip)] [ns '()])
        (if (eof-object? d)
            (reverse ns)
            (loop (get-datum ip) (cons d ns)))))))

(define (digit-count n)
  (if (< n 10)
      1
      (1+ (digit-count (div n 10)))))

;; Map a stone to a list of stones.
(define (transform n)
  (if (zero? n)
      (list 1)
      (let ([count (digit-count n)])
        (if (even? count)
            (list
              (div n (expt 10 (/ count 2)))
              (mod n (expt 10 (/ count 2))))
            (list (* n 2024))))))

(define (blink ls n)
  (if (zero? n)
      ls
      (blink
        (apply append (map transform ls))
        (1- n))))

(display (length (blink input 25)))
(newline)

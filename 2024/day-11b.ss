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

(define (blink-all ls i)
  (apply + (map (lambda (n) (blink-count n i)) ls)))

(define memo (make-hashtable equal-hash equal?))

(define (blink-count n i)
  (define (help n i)
    (if (zero? i)
        1
        (blink-all (transform n) (1- i))))
  (let ([result (hashtable-ref memo (cons n i) #f)])
    (or result
        (let ([result (help n i)])
          (hashtable-set! memo (cons n i) result)
          result))))

(display (blink-all input 75))
(newline)

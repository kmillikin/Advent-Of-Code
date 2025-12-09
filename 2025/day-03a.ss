(define char->digit
  (let ([zero (char->integer #\0)])
    (lambda (c)
      (- (char->integer c) zero))))

;; Find the best (first greatest) digit in a string starting between the given pair of indexes,
;; inclusive on the left and exclusive on the right.  Return the index and the digit.
(define (best-digit str start end)
  (let loop ([i (1+ start)] [index start] [best (char->digit (string-ref str start))])
    (if (= i end)
        (values index best)
        (let ([current (char->digit (string-ref str i))])
          (cond
            ;; We can stop if we see a 9.
            [(= current 9) (values i current)]
            ;; Strictly greater to find the leftmost first digit and leave more choices for
            ;; subsequent digits.
            [(> current best) (loop (1+ i) i current)]
            [else (loop (1+ i) index best)])))))

(let ([banks
        ;; The input has lines of "battery banks", one bank per line.  Keep the banks as strings and
        ;; manipulate them that way.
        (call-with-input-file "day-03.input"
          (lambda (ip)
            (let loop ([line (get-line ip)] [lines '()])
              (if (eof-object? line)
                  (reverse lines)
                  (loop (get-line ip) (cons line lines))))))])
  (let outer ([banks banks] [sum 0])
    (if (null? banks)
        (printf "~s\n" sum)
        ;; We're looking for the greatest two digit number we can make with a pair of digits in
        ;; order (but possibly skipping intermediate digits).  Process the string in two loops for
        ;; simplicity, complexity is still linear.
        (let* ([bank (car banks)]
               [len (string-length bank)])
          (let*-values (;; Stop at the second to last digit, we can't use the last one.
                        [(index digit0) (best-digit bank 0 (1- len))]
                        [(index digit1) (best-digit bank (1+ index) len)])
          (outer (cdr banks) (+ (* digit0 10) digit1 sum)))))))

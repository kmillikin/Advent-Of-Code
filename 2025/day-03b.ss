(define char->digit
  (let ([zero (char->integer #\0)])
    (lambda (c)
      (- (char->integer c) zero))))

;; Find the best (first greatest) digit in a string starting between the given pair of indexes,
;; inclusive on the left and exclusive on the right.  Return the index and the digit.
(define (best-digit str start end)
  (let loop ([i start] [index -1] [best 0])  ;; There are no 0's in the input.
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

(define (verify mine)
  (let ([lukes
          (call-with-input-file "day-03.luke.results"
            (lambda (ip)
              (let loop ([line (get-line ip)] [results '()])
                (if (eof-object? line)
                    (reverse results)
                    (loop (get-line ip) (cons (string->number line) results))))))])
    (let loop ([i 1] [mine mine] [lukes lukes])
      (unless (null? mine)
        (unless (= (car mine) (car lukes))
          (printf "difference on line ~s: mine=~s luke's=~s\n" i (car mine) (car lukes)))
        (loop (1+ i) (cdr mine) (cdr lukes))))))

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
          ;; Like part one but we're looking for 12 digits.
          (let inner ([remaining 12] [prev -1] [num 0])
            (if (= remaining 0)
                (outer (cdr banks) (+ num sum))
                (let-values ([(index digit) (best-digit bank (1+ prev) (- len (1- remaining)))])
                  (inner (1- remaining) index (+ (* num 10) digit)))))))))

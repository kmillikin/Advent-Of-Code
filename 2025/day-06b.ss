(define (char->digit c)
  (- (char->integer c) (char->integer #\0)))

;; Get the number in a given column of the problem.
(define (get-number problems col)
  (let loop ([row 0] [num 0])
    (if (= row (1- (vector-length problems)))
        num
        (let ([c (vector-ref (vector-ref problems row) col)])
          (if (char=? c #\space)
              (loop (1+ row) num)
              (loop (1+ row) (+ (* num 10) (char->digit c))))))))

;; Annoyingly the 2D structure of the problem is important.  Read it into a vector of vectors.
(let ([problems
        (call-with-input-file "day-06.input"
          (lambda (ip)
            (let outer ([line (get-line ip)] [lines '()])
              (if (eof-object? line)
                  (list->vector (reverse lines))
                  (let ([sp (open-string-input-port line)])
                    (let inner ([c (get-char sp)] [line '()])
                      (if (eof-object? c)
                          (outer (get-line ip) (cons (list->vector (reverse line)) lines))
                          (inner (get-char sp) (cons c line)))))))))])
  ;; Loop over the problems from right to left.
  (let loop ([col (1- (vector-length (vector-ref problems 0)))] [sum 0] [operands '()])
    (printf "(loop ~s ~s ~s)\n" col sum operands)
    (if (< col 0)
        (printf "~s\n" sum)
        (let* ([n (get-number problems col)]
               [operands (cons n operands)])
          (case (vector-ref (vector-ref problems (1- (vector-length problems))) col)
            [(#\space) (loop (1- col) sum operands)]
            [(#\+) (loop (- col 2) (+ sum (apply + operands)) '())]
            [(#\*) (loop (- col 2) (+ sum (apply * operands)) '())])))))

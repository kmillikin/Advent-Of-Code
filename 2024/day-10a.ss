(define char->digit
  (let ([zero (char->integer #\0)])
    (lambda (c)
      (- (char->integer c) zero))))

;; A vector of vectors of digits.
(define input
  (call-with-input-file "day-10.input"
    (lambda (ip)
      (let loop ([line (get-line ip)] [lines '()])
        (if (eof-object? line)
            (list->vector (reverse lines))
            (loop (get-line ip)
              (cons (list->vector (map char->digit (string->list line))) lines)))))))

;; Given a position, return a list of the coordinates of neighbors that are one
;; more than the number at the position.
(define (neighbors row col)
  (let ([n (1+ (vector-ref (vector-ref input row) col))])
    (filter (lambda (p)
              (let ([row (car p)] [col (cdr p)])
                (and (>= row 0)
                     (< row (vector-length input))
                     (>= col 0)
                     (< col (vector-length (vector-ref input row)))
                     (= n (vector-ref (vector-ref input row) col)))))
      (list
        (cons (1- row) col)
        (cons (1+ row) col)
        (cons row (1- col))
        (cons row (1+ col))))))

;; DFS looking for a 9.
(define (dfs row col)
  (let recur ([worklist (list (cons row col))]
              [visited (vector-map (lambda (c)
                                     (make-vector (vector-length c) #f))
                         input)]
              [count 0])
    (if (null? worklist)
        count
        (let ([row (car (car worklist))]
              [col (cdr (car worklist))])
          (if (vector-ref (vector-ref visited row) col)
              (recur (cdr worklist) visited count)
              (begin
                (vector-set! (vector-ref visited row) col #t)
                (if (= 9 (vector-ref (vector-ref input row) col))
                    (recur (cdr worklist) visited (1+ count))
                    (recur (append (neighbors row col) (cdr worklist))
                      visited count))))))))

;; Loop over the input, performing dfs from each 0.
(let loop ([row 0] [col 0] [count 0])
  (cond
    [(= row (vector-length input))
     (display count)
     (newline)]
    [(= col (vector-length (vector-ref input row)))
     (loop (1+ row) 0 count)]
    [(zero? (vector-ref (vector-ref input row) col))
     (loop row (1+ col) (+ count (dfs row col)))]
    [else
      (loop row (1+ col) count)]))

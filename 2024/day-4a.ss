(define board
  (call-with-input-file "day-4.input"
    (lambda (ip)
      (let loop ([lines '()])
        (let ([line (get-line ip)])
          (if (eof-object? line)
              (list->vector (reverse lines))
              (loop (cons line lines))))))))

;; The character at row,column in the board equals the given one.  False if the
;; position is out of bounds.
(define (char-at=? row col c)
  (and (not (or (< row 0) (>= row (vector-length board))))
       (let ([line (vector-ref board row)])
         (and (not (or (< col 0) (>= col (string-length line))))
              (char=? (string-ref line col) c)))))

;; Given the coordinates, search for "MAS" in the direction x,y.
(define (mas? row col x y)
  (and (char-at=? (+ row y) (+ col x) #\M)
       (char-at=? (+ row y y) (+ col x x) #\A)
       (char-at=? (+ row y y y) (+ col x x x) #\S)))

;; Loop over the rows and columns searching for #\X, then look for mas? in each
;; direction.
(let loop ([row 0] [col 0] [count 0])
  (cond
    [(= row (vector-length board))
     (display count)
     (newline)]
    [(= col (string-length (vector-ref board row)))
     (loop (1+ row) 0 count)]
    [(not (char-at=? row col #\X))
     (loop row (1+ col) count)]
    [else
      ;; Loop over the eight cardinal directions.  It's OK to consider 0,0
      ;; because we definitely won't find "MAS" there (it contains an #\X).
      (let outer ([x -1] [outer-count 0])
        (if (> x 1)
            (loop row (1+ col) (+ count outer-count))
            (let inner ([y -1] [inner-count 0])
              (cond
                [(> y 1)
                 (outer (1+ x) (+ outer-count inner-count))]
                [(mas? row col x y)
                 (inner (1+ y) (1+ inner-count))]
                [else (inner (1+ y) inner-count)]))))]))

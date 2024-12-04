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

;; Given the coordinates, search for a so-called X around that position.  It
;; could be:
;;
;;   M.M    M S    S M    S S
;;   ... or ... or ... or ... 
;;   S.S    M S    S M    M M
(define (so-called-x? row col)
  (or (and (char-at=? (1- row) (1- col) #\M)
           (char-at=? (1- row) (1+ col) #\M)
           (char-at=? (1+ row) (1- col) #\S)
           (char-at=? (1+ row) (1+ col) #\S))

      (and (char-at=? (1- row) (1- col) #\M)
           (char-at=? (1- row) (1+ col) #\S)
           (char-at=? (1+ row) (1- col) #\M)
           (char-at=? (1+ row) (1+ col) #\S))

      (and (char-at=? (1- row) (1- col) #\S)
           (char-at=? (1- row) (1+ col) #\M)
           (char-at=? (1+ row) (1- col) #\S)
           (char-at=? (1+ row) (1+ col) #\M))

      (and (char-at=? (1- row) (1- col) #\S)
           (char-at=? (1- row) (1+ col) #\S)
           (char-at=? (1+ row) (1- col) #\M)
           (char-at=? (1+ row) (1+ col) #\M))))

;; Loop over the rows and columns searching for #\A, then look for a so-called X
;; around that position.
(let loop ([row 0] [col 0] [count 0])
  (cond
    [(= row (vector-length board))
     (display count)
     (newline)]
    [(= col (string-length (vector-ref board row)))
     (loop (1+ row) 0 count)]
    [(and (char-at=? row col #\A) (so-called-x? row col))
     (loop row (1+ col) (1+ count))]
    [else
      (loop row (1+ col) count)]))

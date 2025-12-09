(define (count-neighbors diagram cell-row cell-col)
  (let outer ([row (max 0 (1- cell-row))] [count 0])
    (if (= row (min (vector-length diagram) (+ cell-row 2)))
        count
        (let inner ([col (max 0 (1- cell-col))] [count count])
          (cond
            [(= col (min (string-length (vector-ref diagram row)) (+ cell-col 2)))
             (outer (1+ row) count)]
            [(or (and (= row cell-row) (= col cell-col))
                 (not (char=? (string-ref (vector-ref diagram row) col) #\@)))
             (inner (1+ col) count)]
            [else (inner (1+ col) (1+ count))])))))

(let ([diagram
        ;; The diagram is a 2d grid of paper (@) and empty (.) cells.  Read it into a vector of
        ;; strings.
        (call-with-input-file "day-04.input"
          (lambda (ip)
            (let loop ([line (get-line ip)] [lines '()])
              (if (eof-object? line)
                  (list->vector (reverse lines))
                  (loop (get-line ip) (cons line lines))))))])
  (let outer ([row 0] [count 0])
    (if (= row (vector-length diagram))
        (printf "~s\n" count)
        (let inner ([col 0] [count count])
          (cond
            [(= col (string-length (vector-ref diagram row)))
             (outer (1+ row) count)]
            [(or (char=? (string-ref (vector-ref diagram row) col) #\.)
                 (>= (count-neighbors diagram row col) 4))
             (inner (1+ col) count)]
            [else (inner (1+ col) (1+ count))])))))

;; Read the input map.
(define map
  (call-with-input-file "day-06.input"
    (lambda (ip)
      (let loop ([line (get-line ip)] [lines '()])
        (if (eof-object? line)
            (list->vector (reverse lines))
            (loop (get-line ip)
              (cons (list->vector (string->list line)) lines)))))))

;; Find the caret character in a vector of vectors of characters.  Assumes it is
;; present.
(define (find-guard map)
  (let loop ([line (vector-ref map 0)] [row 0] [col 0])
    (cond
      [(= col (vector-length line))
       (loop (vector-ref map (1+ row)) (1+ row) 0)]
      [(char=? #\^ (vector-ref line col))
       (values row col)]
      [else
        (loop line row (1+ col))])))

;; Rotate a cardinal direction given by a character 90 degrees clockwise.
(define (rotate dir)
  (cond
    [(char=? dir #\^) #\>]
    [(char=? dir #\>) #\V]
    [(char=? dir #\V) #\<]
    [else             #\^]))

;; Convert a cardinal direction given by a character to row and column delta.
(define (delta dir)
  (cond
    [(char=? dir #\^) (values -1 0)]
    [(char=? dir #\>) (values 0 1)]
    [(char=? dir #\V) (values 1 0)]
    [else             (values 0 -1)]))

;; This was useful for debugging a bug in `rotate`.
(define (display-map map)
  (let loop ([row 0])
    (if (= row (vector-length map))
        (newline)
        (begin
          (display (vector-ref map row))
          (newline)
          (loop (1+ row))))))

;; Copy the map so we can mutate it during checking.
(define (copy-map)
  (let* ([len (vector-length map)]
         [map^ (make-vector len)])
    (let loop ([i 0])
      (if (= i len)
          map^
          (begin
            (vector-set! map^ i (vector-copy (vector-ref map i)))
            (loop (1+ i)))))))

;; Walk the guard over the map, mutating it to record his steps by replacing the
;; dot (.) with his direction.  Return #t if he loops, #f if he exits the map
;; without looping.
(define (check map)
  (let-values ([(row col) (find-guard map)])
    ;; The places the guard has alread stood are marked with a list of directions.
    (vector-set! (vector-ref map row) col (list #\^))
    (let walk ([row row] [col col] [dir #\^])
      (let-values ([(drow dcol) (delta dir)])
        (let ([row^ (+ row drow)]
              [col^ (+ col dcol)])
          (and (not (or (= row^ -1)
                        (= row^ (vector-length map))
                        (= col^ -1)
                        (= col^ (vector-length (vector-ref map row)))))
               (let ([c (vector-ref (vector-ref map row^) col^)])
                 (if (char? c)
                     (if (or (char=? c #\#) (char=? c #\O))
                         (walk row col (rotate dir))
                         (begin
                           (vector-set! (vector-ref map row^) col^ (list dir))
                           (walk row^ col^ dir)))
                     (or (member dir c)
                         (begin
                           (vector-set! (vector-ref map row^) col^ (cons dir c))
                           (walk row^ col^ dir)))))))))))

(let loop ([row 0] [col 0] [count 0])
  (cond
    [(= row (vector-length map))
     (display count)
     (newline)]
    [(= col (vector-length (vector-ref map row)))
     (loop (1+ row) 0 count)]
    [(let ([c (vector-ref (vector-ref map row) col)])
       (or (char=? c #\#) (char=? c #\^)))
     (loop row (1+ col) count)]
    [else
      (let ([map^ (copy-map)])
        (vector-set! (vector-ref map^ row) col #\O)
        (loop row (1+ col) (if (check map^) (1+ count) count)))]))

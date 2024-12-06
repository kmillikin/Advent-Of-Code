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
(define (find-guard)
  (let loop ([line (vector-ref map 0)] [row 0] [col 0])
    (cond
      [(= col (vector-length line))
       (loop (vector-ref map (1+ row)) (1+ row) 0)]
      [(char=? #\^ (vector-ref line col))
       (values row col)]
      [else
        (loop line row (1+ col))])))

;; Rotate a cardinal direction given by (row delta, column delta) 90 degrees
;; clockwise.
(define (rotate drow dcol)
  (cond
    [(= drow -1) (values 0 1)]
    [(= dcol  1) (values 1 0)]
    [(= drow  1) (values 0 -1)]
    [else       (values -1 0)]))

;; This was useful for debugging a bug in `rotate`.
(define (display-map)
  (let loop ([row 0])
    (if (= row (vector-length map))
        (newline)
        (begin
          (display (vector-ref map row))
          (newline)
          (loop (1+ row))))))

;; Walk the guard over the map, mutating it to record his steps by replacing the
;; dot (.) with and X.  Count the number of times this happens.
(let-values ([(row col) (find-guard)])
  ;; The places the guard has alread stood are marked with Xs.
  (vector-set! (vector-ref map row) col #\X)
  ;; Initial direction is up.  Initial count is 1 (the starting position).
  (let walk ([row row] [col col] [drow -1] [dcol 0] [count 1])
    (let ([row^ (+ row drow)]
          [col^ (+ col dcol)])
      (if (or (= row^ -1)
              (= row^ (vector-length map))
              (= col^ -1)
              (= col^ (vector-length (vector-ref map row))))
          (begin
            (display count)
            (newline))
          (let ([c (vector-ref (vector-ref map row^) col^)])
            (cond
              ;; Obstacle: rotate.
              [(char=? c #\#)
               (let-values ([(drow^ dcol^) (rotate drow dcol)])
                 (walk row col drow^ dcol^ count))]
              [(char=? c #\.)
               (vector-set! (vector-ref map row^) col^ #\X)
               (walk row^ col^ drow dcol (1+ count))]
              [else
                (walk row^ col^ drow dcol count)]))))))

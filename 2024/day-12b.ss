(define input
  (call-with-input-file "day-12-2.test"
    (lambda (ip)
      (let loop ([line (get-line ip)] [rows '()])
        (if (eof-object? line)
            (list->vector (reverse rows))
            (loop (get-line ip)
              (cons (list->vector (string->list line)) rows)))))))

(define (neighbors c row col)
  (filter (lambda (p)
            (let ([row (car p)] [col (cdr p)])
              (and (>= row 0)
                   (< row (vector-length input))
                   (>= col 0)
                   (< col (vector-length (vector-ref input row)))
                   (char=? c (vector-ref (vector-ref input row) col)))))
  (list
    (cons (1- row) col)
    (cons (1+ row) col)
    (cons row (1- col))
    (cons row (1+ col)))))

;; Flood fill starting at a position with a character.  Mark the cells in the
;; input with the given character.
(define (flood-fill row col mark)
  (let ([c (vector-ref (vector-ref input row) col)]
        [visited (vector-map vector-copy input)])
    (let recur ([worklist (list (cons row col))]
                [area 0])
      (if (null? worklist)
          (values visited area)
          (let ([row (car (car worklist))]
                [col (cdr (car worklist))])
            (if (char=? mark (vector-ref (vector-ref visited row) col))
                (recur (cdr worklist) area)
                (begin
                  (vector-set! (vector-ref visited row) col mark)
                  (let ([ns (neighbors c row col)])
                    (recur (append ns (cdr worklist)) (1+ area))))))))))

;; If we're pointing in this direction, turn 90 degrees.
(define (turn-right dir)
  (cond
    [(eq? dir 'north) 'east]
    [(eq? dir 'east) 'south]
    [(eq? dir 'south) 'west]
    [else 'north]))

(define (turn-left dir)
  (cond
    [(eq? dir 'north) 'west]
    [(eq? dir 'east) 'north]
    [(eq? dir 'south) 'east]
    [else 'south]))

(define (deltas dir)
  (cond
    [(eq? dir 'north) (values -1 0)]
    [(eq? dir 'east)  (values 0 1)]
    [(eq? dir 'south) (values 1 0)]
    [else             (values 0 -1)]))
    

;; Walk over the edge of a region, counting the number of times we turn.
(define (walk row col)
  (let* ([pointing-dir
           (cond
             [(or (< (1- row) 0)
                  (not (char=? #\# (vector-ref (vector-ref input (1- row)) col))))
              'north]
             [(or (>= (1+ col) (vector-length (vector-ref input row)))
                  (not (char=? #\# (vector-ref (vector-ref input row) (1- col)))))
              'east]
             [(or (>= (1+ row) (vector-length input))
                  (not (char=? #\# (vector-ref (vector-ref input (1+ row)) col))))
              'south]
             [else 'west])]
         [walking-dir (turn-right pointing-dir)])
    (let loop ([r row] [c col] [pdir pointing-dir] [wdir walking-dir] [turns 0])
      (if (and (= r row) (= c col) (eq? wdir walking-dir) (> turns 0))
          turns
          (let-values ([(drow dcol) (deltas pdir)])
            (let ([r^ (+ r drow)] [c^ (+ c dcol)])
              (if (and (>= r^ 0)
                       (< r^ (vector-length input))
                       (>= c^ 0)
                       (< c^ (vector-length (vector-ref input r^)))
                       (char=? #\# (vector-ref (vector-ref input r^) c^)))
                  ;; We're pointing to a marked square, concave=turn left and
                  ;; take a step.
                  (loop r^ c^ (turn-left pdir) (turn-left wdir) (1+ turns))
                  (let-values ([(drow dcol) (deltas wdir)])
                    (let ([r^ (+ r drow)] [c^ (+ c dcol)])
                      (if (or (< r^ 0)
                              (>= r^ (vector-length input))
                              (< c^ 0)
                              (>= c^ (vector-length (vector-ref input r^)))
                              (not (char=? #\# (vector-ref (vector-ref input r^) c^))))
                          ;; We're going to step off the map or into an unmarked
                          ;; region.  Turn right but do not take a step.
                          (loop r c (turn-right pdir) (turn-right wdir) (1+ turns))
                          ;; Otherwise just take a step.
                          (loop r^ c^ pdir wdir turns)))))))))))

(let loop ([row 0] [col 0] [price 0])
  (cond
    [(= row (vector-length input))
     (display price)
     (newline)]
    [(= col (vector-length (vector-ref input row)))
     (loop (1+ row) 0 price)]
    [(char=? #\. (vector-ref (vector-ref input row) col))
     (loop row (1+ col) price)]
    [else
      (let-values ([(result  area) (flood-fill row col #\#)])
        (set! input result)
        (let ([sides (walk row col)])
          (let-values ([(result _) (flood-fill row col #\.)])
            (set! input result)
            (loop row (1+ col) (+ price (* sides area))))))]))

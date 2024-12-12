(define input (call-with-input-file "day-09.input" get-string-all))

;; Convert a digit character to a decimal number in [0,9].
(define char->number
  (let ([zero (char->integer #\0)])
    (lambda (c)
      (- (char->integer c) zero))))

;; Iterate the input string to compute the vector size.
(define vector-size
  (let ([len (string-length input)])
    (lambda ()
      (let loop ([i 0] [size 0])
        (if (>= i len)
            size
            (loop (1+ i) (+ size (char->number (string-ref input i)))))))))

(define disk (make-vector (vector-size)))

;; Initialize the `disk` vector to have file IDs and dots.
(let ([len (string-length input)])
  (let outer ([from 0] [to 0] [id 0] [in-file #t])
    (when (< from len)
      (let inner ([j 0] [limit (char->number (string-ref input from))])
        (if (= j limit)
            (outer (1+ from) (+ to limit) (if in-file (1+ id) id) (not in-file))
            (begin
              (vector-set! disk (+ to j) (if in-file id #\.))
              (inner (1+ j) limit)))))))

;; Loop over the disk compacting it by moving file blocks from the end to the
;; first empty space.  `to` is the leftmost dot (.) character and `from` is the
;; righmost file ID.

(let loop ([to 0] [from (1- (vector-length disk))])
  (when (> from to)
    (cond
      [(number? (vector-ref disk to))
       (loop (1+ to) from)]
      [(not (number? (vector-ref disk from)))
       (loop to (1- from))]
      [else
        (vector-set! disk to (vector-ref disk from))
        (vector-set! disk from #\.)
        (loop (1+ to) (1- from))])))

(let loop ([i 0] [checksum 0])
  (if (or (>= i (vector-length disk))
          (not (number? (vector-ref disk i))))
      (begin
        (display checksum)
        (newline))
      (loop (1+ i) (+ checksum (* i (vector-ref disk i))))))

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

;; Initialize the `disk` vector to have file IDs and dots.  Build a list of
;; files and free space.  Files are represented by a vector of start position,
;; length, and file id.  Free space is represented by a pair of start position
;; and length.  The file list is in reverse order.
(let-values
    ([(files free)
      (let ([len (string-length input)])
        (let outer ([from 0] [to 0] [id 0] [in-file #t] [files '()] [free '()])
          (if (>= from len)
              (values files (reverse free))
              (let inner ([j 0] [limit (char->number (string-ref input from))])
                (if (= j limit)
                    (if in-file
                        (outer (1+ from) (+ to limit) (1+ id) #f
                          (cons (vector to limit id) files)
                          free)
                        (outer (1+ from) (+ to limit) id #t files
                          (if (zero? limit)
                              free
                              (cons (cons to limit) free))))
                    (begin
                      (vector-set! disk (+ to j) (if in-file id #\.))
                      (inner (1+ j) limit)))))))])
  ;; Loop over the files, trying to compact them.
  (let loop ([files files] [free free])
    (if (null? files)
        (let loop ([i 0] [checksum 0])
          (cond
            [(>= i (vector-length disk))
             (display checksum)
             (newline)]
            [(not (number? (vector-ref disk i)))
             (loop (1+ i) checksum)]
            [else
              (loop (1+ i) (+ checksum (* i (vector-ref disk i))))]))
        (loop (cdr files)
          ;; Loop over the free list, looking for a place for the file.  Return
          ;; the new free list.
          (let* ([file (car files)]
                 [from (vector-ref file 0)]
                 [size (vector-ref file 1)]
                 [id (vector-ref file 2)])
            (let recur ([free free])
              (cond
                [(null? free) '()]
                [(>= (car (car free)) from) free]
                [(< (cdr (car free)) size)
                 (cons (car free) (recur (cdr free)))]
                [else
                  ;; It fits.  Update the disk vector because we use it to compute
                  ;; the checksum.
                  (let ([to (car (car free))]
                        [free-size (cdr (car free))])
                    (let move ([i (1- size)])
                      (if (< i 0)
                          (if (= size free-size)
                              (cdr free)
                              (cons (cons (+ to size) (- free-size size)) (cdr free)))
                          (begin
                            (vector-set! disk (+ to i) id)
                            (vector-set! disk (+ from i) #\.)
                            (move (1- i))))))])))))))

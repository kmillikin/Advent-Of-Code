(let ([rotations
        ;; The input has lines of the form L68.  Split them into pairs of a character and a number.
        ;; Return the list.
        (call-with-input-file "day-01.input"
          (lambda (ip)
            (let loop ([line (get-line ip)] [lines '()])
              (if (eof-object? line)
                  (reverse lines)
                  (loop (get-line ip)
                    (cons (cons (string-ref line 0)
                            (string->number (substring line 1 (string-length line))))
                      lines))))))])
  (let loop ([rs rotations] [dial 50] [zeros 0])
    (if (null? rs)
        (printf "~s\n" zeros)
        (let* ([rot ((if (char=? (caar rs) #\R) + -) 0 (cdar rs))]
               [quo (abs (quotient rot 100))]
               [rem (remainder rot 100)]
               [raw (+ dial rem)]
               [zeros (+ zeros quo
                        (if (and (not (zero? dial))
                                 (or (<= raw 0) (> raw 99)))
                            1
                            0))])
          (loop (cdr rs) (modulo raw 100) zeros)))))

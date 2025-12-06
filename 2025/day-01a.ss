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
        (let ([dial (mod ((if (char=? (caar rs) #\R) + -) dial (cdar rs)) 100)])
          (loop (cdr rs) dial (if (zero? dial) (1+ zeros) zeros))))))

(let ([diagram
        ;; The usual vector of strings.
        (call-with-input-file "day-07.input"
          (lambda (ip)
            (let loop ([line (get-line ip)] [lines '()])
              (if (eof-object? line)
                  (list->vector (reverse lines))
                  (loop (get-line ip) (cons line lines))))))])
  ;; Trace the beams from top to bottom.
  (let outer ([row 0] [count 0])
    (if (= row (1- (vector-length diagram)))
        (printf "~s\n" count)
        (let ([current (vector-ref diagram row)]
              [next (vector-ref diagram (1+ row))])
          (let inner ([col 0] [count count])
            (if (= col (string-length current))
                (outer (1+ row) count)
                (let ([c (string-ref current col)])
                  (cond
                    [(or (char=? c #\.) (char=? c #\^))
                     ;; Do nothing.
                     (inner (1+ col) count)]
                    [(and (or (char=? c #\S) (char=? c #\|))
                          (let ([c^ (string-ref next col)])
                            (or (char=? c^ #\.) (char=? c^ #\|))))
                     ;; A beam source (S or |) empty or a beam below, propagate the beam.
                     (string-set! next col #\|)
                     (inner (1+ col) count)]
                    [(and (or (char=? c #\S) (char=? c #\|))
                          (char=? (string-ref next col) #\^))
                     ;; A beam source with a splitter below, split the beam.  The input does not
                     ;; have splitters at the edge of the diagram.
                     (string-set! next (1- col) #\|)
                     (string-set! next (1+ col) #\|)
                     (inner (1+ col) (1+ count))]))))))))

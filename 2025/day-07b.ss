(let ([diagram
        ;; The usual vector of strings.
        (call-with-input-file "day-07.input"
          (lambda (ip)
            (let loop ([line (get-line ip)] [lines '()])
              (if (eof-object? line)
                  (list->vector (reverse lines))
                  (loop (get-line ip) (cons line lines))))))])
  ;; Trace the beams from top to bottom.
  (let ([timelines (make-hashtable string-hash string=?)])
    (hashtable-set! timelines (vector-ref diagram 0) 1)
    (let loop0 ([row 0] [timelines timelines])
      (let-values ([(keys entries) (hashtable-entries timelines)])
        (if (= row (1- (vector-length diagram)))
            (printf "~s\n" (apply + (vector->list entries)))
            (let-values ([(keys entries) (hashtable-entries timelines)])
              (let loop1 ([i 0] [timelines (make-hashtable string-hash string=?)])
                (if (= i (vector-length keys))
                    (loop0 (1+ row) timelines)
                    (let ([current (vector-ref keys i)]
                          [next (vector-ref diagram (1+ row))])
                      (let loop2 ([col 0])
                        (if (= col (string-length current))
                            (loop1 (1+ i) timelines)
                            (let ([c (string-ref current col)])
                              (cond
                                [(or (char=? c #\.) (char=? c #\^))
                                 ;; Do nothing.
                                 (loop2 (1+ col))]
                                [(and (or (char=? c #\S) (char=? c #\|))
                                      (let ([c^ (string-ref next col)])
                                        (or (char=? c^ #\.) (char=? c^ #\|))))
                                 ;; A beam source (S or |) empty or a beam below, generates one
                                 ;; timeline.
                                 (let ([tl (string-copy next)])
                                   (string-set! tl col #\|)
                                   (hashtable-update! timelines tl
                                     (lambda (n) (+ n (vector-ref entries i)))
                                     0)
                                   (loop2 (1+ col)))]
                                [(and (or (char=? c #\S) (char=? c #\|))
                                      (char=? (string-ref next col) #\^))
                                 ;; A beam source with a splitter below, split the beam, generating
                                 ;; two timelines.
                                 (let ([tl0 (string-copy next)] [tl1 (string-copy next)])
                                   (string-set! tl0 (1- col) #\|)
                                   (string-set! tl1 (1+ col) #\|)
                                   (hashtable-update! timelines tl0
                                     (lambda (n) (+ n (vector-ref entries i)))
                                     0)
                                   (hashtable-update! timelines tl1
                                     (lambda (n) (+ n (vector-ref entries i)))
                                     0)
                                   (loop2 (1+ col)))])))))))))))))

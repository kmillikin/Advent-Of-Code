(let ([reports
        (call-with-input-file "day-2.input"
          (lambda (ip)
            (let outer ([reports '()])
              (let ([line (get-line ip)])
                (if (eof-object? line)
                    reports
                    (let ([ip (open-string-input-port line)])
                      (let inner ([levels '()])
                        (let ([datum (get-datum ip)])
                          (if (eof-object? datum)
                              (outer (cons levels reports))
                              (inner (cons datum levels)))))))))))])
  ;; Everything's basically the same as in part a, except this predicate.
  (define (safe? report)
    (let ([levels (list->vector (reverse report))])
      ;; We're comparing the element at `i` to the next one.  `sign` is positive
      ;; for increasing sequences and negative for decreasing ones.
      ;; `can-dampen` is true if we are allowed to try to repair the report.
      (let help ([i 0] [sign 0] [can-dampen #t])
        (cond
          ;; `i` is the last index, succeed.
          [(= i (1- (vector-length levels)))
           #t]
          ;; #f at `i` marks an element to skip when trying to repair.
          [(not (vector-ref levels i))
           (help (1+ i) sign can-dampen)]
          ;; A corner case: if `i`+1 is the last index and we're skipping that
          ;; element, then succeed.
          [(and (= (1+ i) (1- (vector-length levels)))
                (not (vector-ref levels (1+ i))))
           #t]
          [else
            (let* ([current (vector-ref levels i)]
                   [maybe-next (vector-ref levels (1+ i))]
                   [next (or maybe-next (vector-ref levels (+ i 2)))]
                   [diff (- next current)])
              (cond
                ;; We need:
                ;;   1. Levels are changing,
                ;;   2. but not too fast,
                ;;   3. and in the expected direction if any.
                [(and (not (zero? diff))
                      (<= (abs diff) 3)
                      (or (zero? sign)
                          ;; Note diff is known to be non-zero.
                          (eq? (> sign 0) (> diff 0))))
                 ;; The element at `i` is OK, move on.  Use `diff` as the next
                 ;; expected sign.
                 (help (1+ i) diff can-dampen)]
                [(not can-dampen)
                 ;; We're already trying to repair it.
                 #f]
                [else
                  ;; There are three possible repairs we can make: remove the
                  ;; first element (to change an ascending sequence into a
                  ;; descending one or vice versa), remove the element at i, or
                  ;; remove the one at i+1.  Note that we know all of these
                  ;; elements exist and are not #f.  Possibly too cute, but we
                  ;; mutate the vector (remembering the original value) and just
                  ;; try again.
                  (let ([first (vector-ref levels 0)])
                    (vector-set! levels 0 #f)
                    (or (help 0 0 #f)
                        (begin
                          (vector-set! levels 0 first)
                          (if (zero? i)
                              (begin
                                (vector-set! levels (1+ i) #f)
                                (help 0 0 #f))
                              (let ([ith (vector-ref levels i)])
                                (vector-set! levels i #f)
                                (or (help 0 0 #f)
                                    (begin
                                      (vector-set! levels i ith)
                                      (vector-set! levels (1+ i) #f)
                                      (help 0 0 #f))))))))]))]))))
  (let loop ([reports (reverse reports)] [count 0])
    (if (null? reports)
        (begin
          (display count)
          (newline))
        (loop (cdr reports) (if (safe? (car reports)) (1+ count) count)))))

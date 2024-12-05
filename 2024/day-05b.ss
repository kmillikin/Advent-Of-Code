;; Read a non-negative decimal integer from an input port.  Note that it
;; consumes the character after the number.  Returns #f if there is no number to
;; read.
(define (get-number ip)
  (let loop ([n #f])
    (let ([c (get-char ip)])
      (if (or (eof-object? c) (not (char-numeric? c)))
          n
          (let ([n (or n 0)])
            (loop (+ (* n 10) (- (char->integer c) (char->integer #\0)))))))))

;; True if the intersection of sets (hashtable keys) s0 and s1 is empty.  #f
;; can be used to represent an empty set.
(define (intersection-empty? s0 s1)
  (or (not s0)
      (not s1)
      (let loop ([keys (hashtable-keys s0)] [i 0])
        (or (= i (vector-length keys))
            (and (not (hashtable-contains? s1 (vector-ref keys i)))
                 (loop keys (1+ i)))))))

;; Find the middle element of a list.  Assumes the list's length is odd as a
;; precondition.  March a hare and tortoise through the list.
(define (middle ls)
  (let loop ([tortoise ls] [hare (cdr ls)])
    (if (null? hare)
        (car tortoise)
        (loop (cdr tortoise) (cddr hare)))))

(let-values
    ([(constraints sequences)
      (call-with-input-file "day-5.input"
        (lambda (ip)
          ;; The constraints are a hashtable mapping page numbers to the set of
          ;; page numbers which must come after them.  Sets are hashtables
          ;; mapping page numbers to #t.
          (let ([cs (make-eqv-hashtable)])
            ;; Read constraints.
            (let loop ()
              (let ([line (get-line ip)])
                (when (not (string=? line ""))
                  (let* ([ip (open-string-input-port line)]
                         [before (get-number ip)]
                         [after (get-number ip)])
                    ;; Default is #f, used to allocate an empty set.
                    (hashtable-update! cs before
                      (lambda (s)
                        (let ([set (or s (make-eqv-hashtable))])
                          (hashtable-set! set after #t)
                          set))
                      #f)
                    (loop)))))
            ;; Read sequences as a list of lists.
            (let outer ([seqs '()])
              (let ([line (get-line ip)])
                (if (eof-object? line)
                    (values cs (reverse seqs))
                    (let inner ([ip (open-string-input-port line)] [seq '()])
                      (let ([n (get-number ip)])
                        (if (not n)
                            (outer (cons (reverse seq) seqs))
                            (inner ip (cons n seq)))))))))))])
  ;; A single constraint X|Y means that it is forbidden for Y to occur before X.
  ;; Note that X can occur before Y, X can not occur, and Y can not occur.
  ;; Iterate the sequence keeping a set of pages seen.  When a new page X is
  ;; seen, we can check that the intersection of the Ys in X's constraints and
  ;; the pages alread seen is empty.
  (let outer ([seqs sequences] [sum 0])
    (if (null? seqs)
        (begin
          (display sum)
          (newline))
        (let inner ([seq (car seqs)] [seen (make-eqv-hashtable)])
          (cond
            [(null? seq)
             (outer (cdr seqs) sum)]
            [(not (intersection-empty? seen (hashtable-ref constraints (car seq) #f)))
             (let ([sorted (list-sort
                             ;; X must come before Y if Y is in X's constraint set.
                             (lambda (x y)
                               (let ([set (hashtable-ref constraints x #f)])
                                 (and set (hashtable-contains? set y))))
                             (car seqs))])
             (outer (cdr seqs) (+ sum (middle sorted))))]
            [else
              (hashtable-set! seen (car seq) #t)
              (inner (cdr seq) seen)])))))

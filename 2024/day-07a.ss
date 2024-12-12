(define (get-number ip)
  (let loop ([n #f])
    (let ([c (get-char ip)])
      (if (or (eof-object? c) (not (char-numeric? c)))
          n
          (let ([n (or n 0)])
            (loop (+ (* n 10) (- (char->integer c) (char->integer #\0)))))))))

(define input
  (call-with-input-file "day-07.input"
    (lambda (fip)
      (let outer ([line (get-line fip)] [lines '()])
        (if (eof-object? line)
            (reverse lines)
            (let* ([sip (open-string-input-port line)]
                   [sum (get-number sip)])
              (let inner ([n (get-datum sip)] [ns '()])
                (if (eof-object? n)
                    (outer (get-line fip) (cons (cons sum (reverse ns)) lines))
                    (inner (get-datum sip) (cons n ns))))))))))

;; Given an equation, return true if it can be satisfied.
(define (satisfiable? eqn)
  (let ([target (car eqn)])
    (letrec
        ([help
           (lambda (acc rest succeed fail)
             (if (null? rest)
                 (if (= acc target)
                     (succeed)
                     (fail))
                   (help (+ acc (car rest)) (cdr rest)
                     succeed
                     (lambda ()
                       (help (* acc (car rest)) (cdr rest)
                         succeed fail)))))])
      (help (cadr eqn) (cddr eqn)
        (lambda () #t)
        (lambda () #f)))))

(let ([sum
        (fold-left (lambda (sum eqn)
                     (if (satisfiable? eqn) (+ sum (car eqn)) sum))
          0 input)])
  (display sum)
  (newline))

(let ([reports
        (call-with-input-file "day-2.input"
          (lambda (ip)
            ;; Build a reversed list of "reports" from the input file, where
            ;; each report is a reversed list of "levels".
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
  ;; Check a report.
  (define (safe? greater lesser)
    ;; We get a pair of lists and expect each element of `greater` to be between
    ;; 1 and 3 more than the corresponding element of `lesser`.  Ignore any
    ;; extra elements.
    (or (null? greater)
        (null? lesser)
        (let ([n (- (car greater) (car lesser))])
          (and (>= n 1)
               (<= n 3)
               (safe? (cdr greater) (cdr lesser))))))
  ;; Loop over the reports counting the ones that are safe.  It doesn't matter
  ;; that each report is reversed, because a safe increasing report is a safe
  ;; decreasing reversed report.  Likewise it doesn't matter that the list of
  ;; reports is reversed because that doesn't affect the number of safe ones.
  (let loop ([reports reports] [count 0])
    (if (null? reports)
        (begin
          (display count)
          (newline))
        (let ([levels (car reports)])
          (loop (cdr reports)
            (cond
              [(or (null? levels) (null? (cdr levels)))
               ;; I don't think we'll get a report with fewer than two levels,
               ;; but classify it as safe if we do.
               (1+ count)]
              [(> (car levels) (cadr levels))
               ;; The first element is strictly greater than the second, we
               ;; expect the car of each pair to be greater than its cadr.  It's
               ;; cute that we can use `levels` and `(cdr levels)` like this.
               (if (safe? levels (cdr levels)) (1+ count) count)]
              [else
                ;; And similarly.
                (if (safe? (cdr levels) levels) (1+ count) count)]))))))

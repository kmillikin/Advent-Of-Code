;; A range is a pair of start and end ids.  Coalesce ranges during insertion.
(define (adjacent? range0 range1)
  (or (= (car range1) (1+ (cadr range0)))
      (= (cadr range1) (1- (car range0)))))

(define (contains? range num)
  (and (>= num (car range)) (<= num (cadr range))))

(define (overlap? range0 range1)
  (or (contains? range0 (car range1))
      (contains? range0 (cadr range1))
      (contains? range1 (car range0))
      (contains? range1 (cadr range0))))

(define (size range)
  (1+ (- (cadr range) (car range))))

(define (insert-range range ranges)
  (if (null? ranges)
      (list range)
      (let ([range^ (car ranges)])
        (if (or (adjacent? range range^) (overlap? range range^))
            (insert-range (list (min (car range) (car range^)) (max (cadr range) (cadr range^)))
              (cdr ranges))
            (cons range^ (insert-range range (cdr ranges)))))))

(define (string-split string delimiter)
  (let ([len (string-length string)])
    (let loop ([i 0] [start 0] [strings '()])
      (cond
        [(= i len) (reverse (cons (substring string start len) strings))]
        [(char=? (string-ref string i) delimiter)
         (loop (1+ i) (1+ i) (cons (substring string start i) strings))]
        [else (loop (1+ i) start strings)]))))

(let-values ([(ranges ingredients)
              (call-with-input-file "day-05.input"
                (lambda (ip)
                  (let ([ranges
                          (let loop0 ([line (get-line ip)] [ranges '()])
                            (if (string=? line "")
                                ranges
                                (loop0 (get-line ip)
                                  (insert-range (map string->number (string-split line #\-)) ranges))))])
                    (let loop1 ([line (get-line ip)] [ingredients '()])
                      (if (eof-object? line)
                          (values ranges ingredients)
                          (loop1 (get-line ip) (cons (string->number line) ingredients)))))))])
  (let loop ([ranges ranges] [count 0])
    (if (null? ranges)
        (printf "~s\n" count)
        (loop (cdr ranges) (+ count (size (car ranges)))))))

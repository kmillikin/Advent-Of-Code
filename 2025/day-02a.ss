;; I guess we'll need string-split.  Split on a delimiter character
(define (string-split string delimiter)
  (let ([len (string-length string)])
    (let loop ([i 0] [start 0] [strings '()])
      (cond
        [(= i len) (reverse (cons (substring string start len) strings))]
        [(char=? (string-ref string i) delimiter)
         (loop (1+ i) (1+ i) (cons (substring string start i) strings))]
        [else (loop (1+ i) start strings)]))))

(define (invalid? n)
  (let* ([str (number->string n)]
         [len (string-length str)])
    (and (even? len)
         (let ([mid (/ len 2)])
           (string=? (substring str 0 mid) (substring str mid len))))))

;; As usual, assume the input is well-formed.  In this case:
;;  - it's all on a single line
;;  - the ranges consist of pairs of numbers
(let* ([line (call-with-input-file "day-02.input" get-line)]
       [ranges (map (lambda (range) (map string->number (string-split range #\-)))
                 (string-split line #\,))])
  (let outer ([ranges ranges] [sum 0])
    (if (null? ranges)
        (printf "~s\n" sum)
        (let inner ([i (caar ranges)] [end (cadar ranges)] [sum sum])
          (cond
            [(= i (1+ end)) (outer (cdr ranges) sum)]
            [(invalid? i) (inner (1+ i) end (+ sum i))]
            [else (inner (1+ i) end sum)])))))

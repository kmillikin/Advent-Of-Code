;; I guess we'll need string-split.  Split on a delimiter character
(define (string-split string delimiter)
  (let ([end (string-length string)])
    (let loop ([i 0] [start 0] [strings '()])
      (cond
        [(= i end) (reverse (cons (substring string start end) strings))]
        [(char=? (string-ref string i) delimiter)
         (loop (1+ i) (1+ i) (cons (substring string start i) strings))]
        [else (loop (1+ i) start strings)]))))

;; Split a string into substrings of the given length, ignores the end if it's not long enough.
(define (string-split/length string length)
  (let ([end (string-length string)])
    (let loop ([start 0] [strings '()])
      (if (> (+ start length) end)
          (reverse strings)
          (loop (+ start length) (cons (substring string start (+ start length)) strings))))))

(define (invalid? n)
  (let* ([str (number->string n)]
         [len (string-length str)])
    ;; Loop from 2 up to len, trying to split into that many substrings.
    (let loop ([count 2])
      (cond
        [(> count len) #f]
        [(not (zero? (modulo len count))) (loop (1+ count))]
        [else
          (let ([substrings (string-split/length str (/ len count))])
            (or (andmap (lambda (s) (string=? (car substrings) s)) (cdr substrings))
                (loop (1+ count))))]))))

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

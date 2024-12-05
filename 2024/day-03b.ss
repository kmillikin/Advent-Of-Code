(define input (call-with-input-file "day-3.input" get-string-all))

(let loop ([i 0] [state 'START] [arg0 0] [arg1 0] [enabled #t] [sum 0])
  (if (= i (string-length input))
      (begin
        (display sum)
        (newline))
      (let ([c (string-ref input i)])
        (if (not enabled)
            (cond
              [(and (eq? state 'START) (char=? c #\d))
               (loop (1+ i) 'D 0 0 #f sum)]
              [(and (eq? state 'D) (char=? c #\o))
               (loop (1+ i) 'O 0 0 #f sum)]
              [(and (eq? state 'O) (char=? c #\())
               (loop (1+ i) 'LEFT 0 0 #f sum)]
              [(and (eq? state 'LEFT) (char=? c #\)))
               (loop (1+ i) 'START 0 0 #t sum)]
              [else
                (loop (1+ i) 'START 0 0 #f sum)])
            (cond
              [(and (eq? state 'START) (char=? c #\m))
               (loop (1+ i) 'M 0 0 #t sum)]
              [(and (eq? state 'M) (char=? c #\u))
               (loop (1+ i) 'U 0 0 #t sum)]
              [(and (eq? state 'U) (char=? c #\l))
               (loop (1+ i) 'L 0 0 #t sum)]
              [(and (eq? state 'L) (char=? c #\())
               (loop (1+ i) 'ARG0 0 0 #t sum)]
              [(and (eq? state 'ARG0) (char-numeric? c))
               (let ([d (- (char->integer c) (char->integer #\0))])
                 (loop (1+ i) 'ARG0 (+ (* arg0 10) d) 0 #t sum))]
              [(and (eq? state 'ARG0) (char=? c #\,))
               (loop (1+ i) 'ARG1 arg0 0 #t sum)]
              [(and (eq? state 'ARG1) (char-numeric? c))
               (let ([d (- (char->integer c) (char->integer #\0))])
                 (loop (1+ i) 'ARG1 arg0 (+ (* arg1 10) d) #t sum))]
              [(and (eq? state 'ARG1) (char=? c #\)))
               (loop (1+ i) 'START 0 0 #t (+ sum (* arg0 arg1)))]
              [(and (eq? state 'START) (char=? c #\d))
               (loop (1+ i) 'D 0 0 #t sum)]
              [(and (eq? state 'D) (char=? c #\o))
               (loop (1+ i) 'O 0 0 #t sum)]
              [(and (eq? state 'O) (char=? c #\n))
               (loop (1+ i) 'N 0 0 #t sum)]
              [(and (eq? state 'N) (char=? c #\'))
               (loop (1+ i) 'QUOTE 0 0 #t sum)]
              [(and (eq? state 'QUOTE) (char=? c #\t))
               (loop (1+ i) 'T 0 0 #t sum)]
              [(and (eq? state 'T) (char=? c #\())
               (loop (1+ i) 'LEFT 0 0 #t sum)]
              [(and (eq? state 'LEFT) (char=? c #\)))
               (loop (1+ i) 'START 0 0 #f sum)]
              [else (loop (1+ i) 'START 0 0 #t sum)])))))

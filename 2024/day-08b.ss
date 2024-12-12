;; The input map is represented as vector of strings.
(define input
  (call-with-input-file "day-08.input"
    (lambda (ip)
      (let loop ([line (get-line ip)] [lines '()])
        (if (eof-object? line)
            (list->vector (reverse lines))
            (loop (get-line ip) (cons line lines)))))))

;; Make a hashtable of all the non-dot characters, keyed by the
;; character and with lists of pairs of coordinates as values.
(define coordinates (make-eqv-hashtable))

(let outer ([i (1- (vector-length input))])
  (when (<= 0 i)
    (let ([line (vector-ref input i)])
      (let inner ([j (1- (string-length line))])
        (cond
          [(< j 0)
           (outer (1- i))]
          [(char=? (string-ref line j) #\.)
           (inner (1- j))]
          [else
            (hashtable-update! coordinates (string-ref line j)
              (lambda (ls) (cons (cons i j) ls))
              '())
            (inner (1- j))])))))

(define result (vector-copy input))

(define (result-set! i j)
  (and (>= i 0)
       (< i (vector-length result))
       (let ([line (vector-ref result i)])
         (and (>= j 0)
              (< j (string-length line))
              (let ([c (string-ref line j)])
                (string-set! line j #\#)
                (char=? c #\.))))))

(define (display-board board)
  (let loop ([i 0])
    (if (>= i (vector-length board))
        (newline)
        (begin
          (display (vector-ref board i))
          (newline)
          (loop (1+ i))))))

(let loop0 ([keys (hashtable-keys coordinates)] [i 0] [count 0])
  (if (= i (vector-length keys))
      (begin
        (display count)
        (newline))
      (let loop1 ([coords (hashtable-ref coordinates (vector-ref keys i) #f)]
                  [count count])
        (if (null? coords)
            (loop0 keys (1+ i) count)
            (let loop2 ([c0 (car coords)] [rest (cdr coords)] [count (1+ count)])
              (if (null? rest)
                  (loop1 (cdr coords) count)
                  (let* ([c1 (car rest)]
                         [delta-i (- (car c1) (car c0))]
                         [delta-j (- (cdr c1) (cdr c0))])
                    (let loop3 ([i (- (car c0) delta-i)]
                                [j (- (cdr c0) delta-j)]
                                [count count])
                      (if (or (< i 0)
                              (>= i (vector-length result))
                              (< j 0)
                              (>= j (string-length (vector-ref result i))))
                          (let loop4 ([i (+ (car c1) delta-i)]
                                      [j (+ (cdr c1) delta-j)]
                                      [count count])
                            (if (or (< i 0)
                                    (>= i (vector-length result))
                                    (< j 0)
                                    (>= j (string-length (vector-ref result i))))
                                (loop2 c0 (cdr rest) count)
                                (loop4 (+ i delta-i) (+ j delta-j)
                                  (+ count (if (result-set! i j) 1 0)))))
                          (loop3 (- i delta-i) (- j delta-j)
                            (+ count (if (result-set! i j) 1 0))))))))))))

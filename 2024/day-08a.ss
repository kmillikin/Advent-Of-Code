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
                (not (char=? c #\#)))))))

(let loop0 ([keys (hashtable-keys coordinates)] [i 0] [count 0])
  (if (= i (vector-length keys))
      (begin
        (display count)
        (newline))
      (let loop1 ([coords (hashtable-ref coordinates (vector-ref keys i) #f)] [count count])
        (if (null? coords)
            (loop0 keys (1+ i) count)
            (let loop2 ([c0 (car coords)] [rest (cdr coords)] [count count])
              (if (null? rest)
                  (loop1 (cdr coords) count)
                  (let* ([c1 (car rest)]
                         [delta-i (- (car c1) (car c0))]
                         [delta-j (- (cdr c1) (cdr c0))])
                    (loop2 c0 (cdr rest)
                      (+ count
                        (if (result-set! (- (car c0) delta-i) (- (cdr c0) delta-j)) 1 0)
                        (if (result-set! (+ (car c1) delta-i) (+ (cdr c1) delta-j)) 1 0))))))))))

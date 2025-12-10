(define (string-split string delimiter)
  (let ([len (string-length string)])
    (let loop ([i 0] [start 0] [strings '()])
      (cond
        [(= i len) (reverse (cons (substring string start len) strings))]
        [(char=? (string-ref string i) delimiter)
         (loop (1+ i) (1+ i) (cons (substring string start i) strings))]
        [else (loop (1+ i) start strings)]))))

(define (distance pt0 pt1)
  (sqrt (apply + (map (lambda (x0 x1)
                        (let ([d (- x0 x1)])
                          (* d d)))
                   pt0 pt1))))

(let* ([boxes
         (call-with-input-file "day-08.input"
           (lambda (ip)
             (let loop ([line (get-line ip)] [boxes '()])
               (if (eof-object? line)
                   (list->vector boxes)
                   (loop (get-line ip)
                     (cons (map string->number (string-split line #\,)) boxes))))))]
       [distances
         (list-sort (lambda (d0 d1) (< (car d0) (car d1)))
           (let outer ([i 0] [distances '()])
             (if (= i (1- (vector-length boxes)))
                 distances
                 (let inner ([j (1+ i)] [distances distances])
                   (if (= j (vector-length boxes))
                       (outer (1+ i) distances)
                       (inner (1+ j)
                         (cons (list (distance (vector-ref boxes i) (vector-ref boxes j)) i j)
                           distances)))))))]
       ;; Kind of cheesy union-find structure.  A vector mapping box index to a set number, and a
       ;; vector mapping a set number to its size.
       [point-to-set (list->vector (iota (vector-length boxes)))]
       [set-to-size (make-vector (vector-length boxes) 1)])
  (let loop ([ls distances])
    (unless (null? ls)
      (let ([first (vector-ref point-to-set (cadr (car ls)))]
            [second (vector-ref point-to-set (caddr (car ls)))])
        ;; Merge the sets.
        (unless (= first second)
          (let merge ([i 0])
            (unless (= i (vector-length point-to-set))
              (when (= (vector-ref point-to-set i) second)
                (vector-set! point-to-set i first))
              (merge (1+ i))))
          ;; Update the counts.
          (vector-set! set-to-size first (+ (vector-ref set-to-size first)
                                           (vector-ref set-to-size second)))
          (vector-set! set-to-size second 0))
        (if (= (vector-ref set-to-size first) (vector-length boxes))
            (printf "~s\n" (* (car (vector-ref boxes (cadr (car ls))))
                             (car (vector-ref boxes (caddr (car ls))))))
            (loop (cdr ls)))))))

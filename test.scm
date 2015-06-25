
(define t1 '42)
(define t2 '(car (cons 4 2)))
(define t3 '(cdr (cons 4 2)))
(define t4 '(+ (car (cons 4 2)) (cdr (cons 4 2))))
(define t5 '(- (+ 42 (* 3 6)) 7))
(define t6 '(if #t "yes" "no"))
(define t7 '(if #f "yes" "no"))
(define t8 '(if "huh?" "yes" "no"))
(define t9 '(+ 1 (if #t 4 2)))
(define t10 '(if #t car cdr))
(define t11 '(lambda (x) x))
(define t12 '((lambda (x) x) 1))
(define t13 '(begin 1 2 3 (begin 4 5 6)))
(define t14 '((if #t car cdr) (cons 4 2)))
(define t15 '(last (cons 4 (cons 1 (cons 2 ())))))
(define t16 '(string->symbol "x"))
(define t17 '(car (cdr '(my other car))))
(define t18 '(car (cdr (list 'my 'other 'car))))
(define t19 '(car (cdr ((lambda (o) `(my ,o car)) 'other))))
(define t20 '((lambda (x)
                (cond ((null? x) 'null)
                      ((pair? x) 'pair)
                      (else 'other))) '(1 . 2)))
(define t21 '(not #t))
(define t22 '(not #f))
(define t23 '(not 3))
(define t24 '(with-output-to-string
               (lambda ()
                 (display "1")
                 (display "2")
                 (display "3"))))
(define t25 '(display "1"))
(define t26 '(= 4 5))
(define t27 '(= 5 5))
(define t28 '(begin
	       (display "happy") (newline)
	       (display "lucky") (newline)
	       (display "dochy") (newline)))
(define t29 '(car (cdr (list (list? 'a) (list? '(a b)) (list? '())))))
(define t30 '(and 1 2 3))
(define t31 '(and 1 #f 2 3))
(define t32 '(list->string (but-last (string->list "foobar"))))
(define t33 '(if-expression? '(if a b c)))
(define t34 '(if-expression? '(uf a b c)))
(define t35 '(if-expression? '(uf b c)))
(define t36 '(runtime-primitive? 'string->symbol))
(define t37 '(list->string (list #\h #\i)))
(define t38 '(char? (car (list #\h #\i))))
(define t39 '(mangle-name '?aa))
(define t40 '(write "asd \" f"))
(define t41 '(even? 41))
(define t42 '(even? 42))

(define m1 `(go ',t1))
(define m2 `(go ',t2))
(define m3 `(go ',t3))
(define m4 `(go ',t4))
(define m5 `(go ',t5))

(define (go t) (display "(") (js->javascript (scm->js t)) (display ")") (newline))

(define tests (list t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42
		    m1 m2 m3 m4 m5))

(define (run)
  (display (with-output-to-string
             (lambda ()
               (for-each (lambda (t)
                           (display "document.write(")
                           (write (with-output-to-string (lambda () (write t))))
                           (display "+\": \"+")
                           (newline)
                           (display "write_to_string(")
                           (go t)
                           (display ")")
                           (display "+\"<br/>\");")
                           (newline) (newline)) tests)))))

                                        ;(define t15 '((define (x y) y) (x 1)))
(define (go-top t)
  (for-each (lambda (t) (js->javascript (scm-top->js t)) (display ";") (newline)) t)
  (newline))

(define standard
  '((define (caar x) (car (car x)))
    (define (cadr x) (car (cdr x)))
    (define (cdar x) (cdr (car x)))
    (define (cddr x) (cdr (cdr x)))
    (define (caaar x) (car (car (car x))))
    (define (caadr x) (car (car (cdr x))))
    (define (cadar x) (car (cdr (car x))))
    (define (caddr x) (car (cdr (cdr x))))
    (define (cdraar x) (cdr (car (car x))))
    (define (cdadr x) (cdr (car (cdr x))))
    (define (cddar x) (cdr (cdr (car x))))
    (define (cdddr x) (cdr (cdr (cdr x))))
    (define (caaaar x) (car (car (car (car x)))))
    (define (caaadr x) (car (car (car (cdr x)))))
    (define (caadar x) (car (car (cdr (car x)))))
    (define (caaddr x) (car (car (cdr (cdr x)))))
    (define (cadaar x) (car (cdr (car (car x)))))
    (define (cadadr x) (car (cdr (car (cdr x)))))
    (define (caddar x) (car (cdr (cdr (car x)))))
    (define (cadddr x) (car (cdr (cdr (cdr x)))))
    (define (cdaaar x) (cdr (car (car (car x)))))
    (define (cdaadr x) (cdr (car (car (cdr x)))))
    (define (cdadar x) (cdr (car (cdr (car x)))))
    (define (cdaddr x) (cdr (car (cdr (cdr x)))))
    (define (cddaar x) (cdr (cdr (car (car x)))))
    (define (cddadr x) (cdr (cdr (car (cdr x)))))
    (define (cdddar x) (cdr (cdr (cdr (car x)))))
    (define (cddddr x) (cdr (cdr (cdr (cdr x)))))

    (define (map f xs)
      (if (null? xs) '() (cons (f (car xs) (map f (cdr xs))))))

    (define (append x y)
      (if (null? x) y (cons (car x) (append (cdr x) y))))

    (define (but-last l)
      (if (null? l)
	  '()
	  (if (null? (cdr l))
	      '()
	      (cons (car l) (but-last (cdr l))))))
    (define (last l)
      (if (null? l)
	  #f
	  (if (null? (cdr l))
	      (car l)
	      (last (cdr l)))))
    (define (not b)
      (if b #f #t))
    (define (list? l) (or (null? l) (pair? l)))
    (define (char->string c) c) ;; js
    (define (list->string l)
      (if (null? l)
	  ""
	  (string-append (char->string (car l)) (list->string (cdr l)))))

    (define (length l) (if (null? l) 0 (+ 1 (length (cdr l)))))

    (define (kind-of-expression? kind args exp)
      (and (list? exp) (not (null? exp)) (eq? kind (car exp))
	   (cond ((number? args) (= (+ 1 args) (length exp)))
		 ((eq? 'even args) (even? (length (cdr exp))))
		 ((eq? 'one+ args) (not (null? (cdr exp)))))))
    (define (if-expression? exp) (kind-of-expression? 'if 3 exp))
    (define (lambda-expression? exp)
      (and (list? exp) (eq? (car exp) 'lambda) (list? (cadr exp)) (list? (cddr exp))))
    (define (begin-expression? exp) (kind-of-expression? 'begin 'one+ exp))
    (define (define-expression? exp) (kind-of-expression? 'define 'one+ exp))
    (define (quote-expression? exp) (kind-of-expression? 'quote 1 exp))
    (define (quasiquote-expression? exp) (kind-of-expression? 'quasiquote 1 exp))
    (define (unquote-expression? exp) (kind-of-expression? 'unquote 1 exp))
    (define (cond-expression? exp) (and (list? exp) (eq? 'cond (car exp))))
    (define (or-expression? exp) (kind-of-expression? 'or 'one+ exp))
    (define (and-expression? exp) (kind-of-expression? 'and 'one+ exp))
    
    (define (runtime-primitive? op)
      (cond ((eq? op '+) 'js-plus)
	    ((eq? op '-) 'js-minus)
	    ((eq? op '*) 'js-times)
	    ((eq? op 'runtime-booleanize) 'runtime-booleanize)
	    ((eq? op 'symbol->string) 'js-string->symbol)
	    ((eq? op 'string->symbol) 'js-string->symbol)
	    ((eq? op 'cons) 'cons)
	    (else #f)))
    
(define (mangle-name name)
  (string->symbol (list->string (mangle-helper (string->list (symbol->string name))))))

(define (mangle-helper n)
  (if (null? n)
      '()
      (cond ((eq? #\- (car n))
	     (append (string->list "_dash_") (mangle-helper (cdr n))))
	    ((eq? #\? (car n))
	     (append (string->list "_huh_") (mangle-helper (cdr n))))
	    ((eq? #\_ (car n))
	     (append (string->list "_underscore_") (mangle-helper (cdr n))))
            ((eq? #\> (car n))
             (append (string->list "_gt_") (mangle-helper (cdr n))))
            ((eq? #\! (car n))
             (append (string->list "_bang_") (mangle-helper (cdr n))))
            ((eq? #\= (car n))
             (append (string->list "_eq_") (mangle-helper (cdr n))))
	    (else
	     (cons (car n) (mangle-helper (cdr n)))))))

(define (go t) (display "(") (js->javascript (scm->js t)) (display ")") (newline))



    ))

(define (std)
  (go-top standard))

(define (read-compiler)
  (define (reads port)
    (let ((thing (read port)))
      (if (eof-object? thing)
	  '()
	  (cons thing (reads port)))))
  (call-with-input-file "scm->js.scm" reads))

(define (compile-compiler) (go-top (read-compiler)))

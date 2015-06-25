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

(define (scm-top->js scm)
  (cond ((define-expression? scm)
         (if (symbol? (cadr scm))
             `(js-declare-var ,(cadr scm) ,(caddr scm))
             `(js-named-function
               ,(caadr scm)
               ,(cdadr scm)
               . ,(append (map scm->js (but-last (cddr scm)))
                          (list `(js-return ,(scm->js (last (cddr scm)))))))))
        (else (scm->js scm))))

(define (scm->js scm)
  (cond ((null? scm) scm)
	((number? scm) scm)
	((string? scm) scm)
	((boolean? scm) scm)
        ((symbol? scm) `(js-var ,scm))
	((quote-expression? scm) (quoted->js (cadr scm)))
	((quasiquote-expression? scm) (scm->js (quasiquoted->js (cadr scm) 1)))
        ((cond-expression? scm) (cond->js scm))
        ((lambda-expression? scm)
         `(js-function
           ,(cadr scm)
           . ,(append (map scm->js (but-last (cddr scm)))
                          (list `(js-return ,(scm->js (last (cddr scm))))))))

	((if-expression? scm) `(js-if (js-funcall runtime-booleanize ,(scm->js (cadr scm)))
				      ,(scm->js (caddr scm))
				      ,(scm->js (cadddr scm))))
	((or-expression? scm) (scm->js (or-expression->if (cdr scm))))
	((and-expression? scm) (scm->js (and-expression->if (cdr scm))))
        ((begin-expression? scm)
	 (scm->js `((lambda () . ,(cdr scm)))))

	((and (list? scm) (runtime-primitive? (car scm)))
	 `(js-funcall ,(runtime-primitive? (car scm)) . ,(map scm->js (cdr scm))))

        ((list? scm)
         `(js-funcall* ,(scm->js (car scm)) . ,(map scm->js (cdr scm))))

	))

(define (or-expression->if exp)
  (if (null? exp)
      #f
      `(if ,(car exp)
	   #t
	   ,(or-expression->if (cdr exp)))))

(define (and-expression->if exp)
  (if (null? exp)
      #t
      `(if ,(car exp)
	   ,(and-expression->if (cdr exp))
	   #f)))

(define (quoted->js exp)
  (cond ((number? exp) exp)
	((string? exp) exp)
	((boolean? exp) exp)
	((null? exp) exp)
	((symbol? exp) (scm->js `(string->symbol ,(symbol->string exp))))
	((pair? exp)
	 `(js-funcall cons ,(quoted->js (car exp))
                      ,(quoted->js (cdr exp))))))

(define (quasiquoted->js term n)
  (cond
   ((unquote-expression? term)
    (if (= n 1)
        (cadr term)
        (list 'cons ''unquote (list 'cons (quasiquoted->js (cadr term) (- n 1)) ''()))))
   ((quasiquote-expression? term)
    `(cons 'quasiquote (cons ,(quasiquoted->js (cadr term) (+ n 1)) ())))
   ((pair? term)
    `(cons ,(quasiquoted->js (car term) n)
           ,(quasiquoted->js (cdr term) n)))
   (else `(quote ,term))))

(define (cond->js scm)
  (cond
   ;; (cond)
   ((null? (cdr scm)) '())
   ;; (cond (els b))
   ((and (equal? 'else (caadr scm))
         (= 2 (length scm)))
    (scm->js (cons 'begin (cdadr scm))))
   ;; (cond (a b))
   ((= 2 (length scm))
    (scm->js `(if ,(caadr scm)
                  ,(cons 'begin (cdadr scm))
                  '())))
   ;; (coond (a b) rest ...)
   ((> (length scm) 2)
    (scm->js `(if ,(caadr scm)
                  ,(cons 'begin (cdadr scm))
                  (cond . ,(cddr scm)))))))

(define (js-object-literal? js) (kind-of-expression? 'js-object-literal 'even js))
(define (js-dot? js) (kind-of-expression? 'js-dot 2 js))
(define (js-funcall*? js) (kind-of-expression? 'js-funcall* 'one+ js))
(define (js-funcall? js) (kind-of-expression? 'js-funcall 'one+ js))
(define (js-if? js) (kind-of-expression? 'js-if 3 js))
(define (js-function? js) (kind-of-expression? 'js-function 'one+ js))
(define (js-return? js) (kind-of-expression? 'js-return 1 js))
(define (js-var? js) (kind-of-expression? 'js-var 1 js))
(define (js-named-function? js) (kind-of-expression? 'js-named-function 'one+ js))

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

(define (js->javascript js)
  (cond ((null? js) (display "null"))
	((number? js) (write js))
	((string? js) (write js))
	((eq? #t js) (display "true"))
	((eq? #f js) (display "false"))
	((js-object-literal? js)
	 (display "{")
	 (do-js-object-literal (cdr js))
	 (display "}"))
        ((js-var? js)
         (display (mangle-name (cadr js))))
	((js-dot? js)
	 (display "(")
	 (js->javascript (caddr js))
	 (display ")")
	 (display ".")
	 (display (cadr js)))
        ((js-return? js)
         (display "return ")
         (js->javascript (cadr js)))
	((js-funcall*? js)
         (display "(")
	 (js->javascript (cadr js))
         (display ")")
	 (display "(")
	 (do-js-funcall (cddr js))
	 (display ")"))
	((js-funcall? js)
	 (display (mangle-name (cadr js)))
	 (display "(")
	 (do-js-funcall (cddr js))
	 (display ")"))
	((js-if? js)
	 (display "(")
	 (js->javascript (cadr js))
	 (display ")")
	 (display "?")
	 (display "(")
	 (js->javascript (caddr js))
	 (display ")")
	 (display ":")
	 (display "(")
	 (js->javascript (cadddr js))
	 (display ")"))
        ((js-function? js)
         (display "function")
         (display "(")
         (do-js-funargs (cadr js))
         (display ")")
         (display "{")
         (do-js-sequence (cddr js))
         (display "}"))
        ((js-named-function? js)
         (display "function ")
         (display (mangle-name (cadr js)))
         (display "(")
         (do-js-funargs (caddr js))
         (display ")")
         (display "{")
         (do-js-sequence (cdddr js))
         (display "}"))))

(define (do-js-object-literal kvs)
  (if (null? kvs)
      0
      (begin
	(display (mangle-name (car kvs)))
	(display ":")
	(js->javascript (cadr kvs))
	(if (null? (cddr kvs))
	    0
	    (begin
	      (display ", ")
	      (do-js-object-literal (cddr kvs)))))))

(define (do-js-funcall kvs)
  (if (null? kvs)
      0
      (begin
	(js->javascript (car kvs))
	(if (null? (cdr kvs))
	    0
	    (begin
	      (display ", ")
	      (do-js-funcall (cdr kvs)))))))

(define (do-js-funargs kvs)
  (if (null? kvs)
      0
      (begin
        (display (mangle-name (car kvs)))
	(if (null? (cdr kvs))
	    0
	    (begin
	      (display ", ")
	      (do-js-funargs (cdr kvs)))))))

(define (do-js-sequence exps)
  (if (null? exps)
      0
      (begin
        (js->javascript (car exps))
	(if (null? (cdr exps))
	    0
	    (begin
	      (display "; ")
	      (do-js-sequence (cdr exps)))))))


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

(define (go t) (display "(") (js->javascript (scm->js t)) (display ")") (newline))

(define tests (list t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36))

(define (run)
  (display (with-output-to-string
             (lambda ()
               (for-each (lambda (t)
                           (display "document.write(")
                           (write (with-output-to-string (lambda () (write t))))
                           (display "+\": \"+")
                           (newline)
                           (go t)
                           (display "+\"<br/>\");")
                           (newline) (newline)) tests)))))

;(define t15 '((define (x y) y) (x 1)))
(define (go-top t)
  (for-each (lambda (t) (js->javascript (scm-top->js t)) (display ";") (newline)) t)
  (newline))

(define standard
  '((define (but-last l)
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
    
    ))

(define (std)
  (go-top standard))

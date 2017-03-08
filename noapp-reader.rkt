#lang racket

(provide noapp-read noapp-read-syntax noapp-reader! make-noapp-readtable)

(require syntax/readerr)

(define (add-magic pre-stx)
  (cons #'#%app pre-stx))

(define (noapp-reader!)
  (current-readtable (make-noapp-readtable)))

(define (noapp-read in)
  (parameterize ([current-readtable (make-noapp-readtable)])
    (read in)))

(define (noapp-read-syntax src in)
  (parameterize ([current-readtable (make-noapp-readtable)])
    (read-syntax src in)))

(define (make-noapp-readtable)
  (make-readtable (current-readtable)
   #\{ 'terminating-macro (brackets-reader #\} #'#%app)))

(define ((brackets-reader end-char symbol-to-add)
         char in src line col pos)
  ;; keep reading until I find `end-char`.
  (let loop ([so-far '()])
    (skip-whitespace in)
    ;; TODO: make error messages match up with racket defaults.
    (cond
      [(equal? end-char (peek-char in))
       (read-char in)
       (define-values (_a _b end-pos) (port-next-location in))
       (datum->syntax #f
                      (cons symbol-to-add (reverse so-far))
                      (vector src line col pos (and pos (- end-pos pos))))]
      [#t
       (define next (read-syntax src in))
       (if (eof-object? next)
           ;; TODO: proper error here.
           (raise-read-eof-error "unexpected EOF" src line col pos #f)
           ;; keep going
           (loop (cons next so-far)))])))

(define (skip-whitespace in) (regexp-match #px"^\\s*" in))

(define (test s) (noapp-read (open-input-string s)))

#lang racket

(define-syntax-rule (provide-for-both x ...)
  (provide x ... (for-syntax x ...)))

(require syntax/parse/define (for-syntax syntax/parse/define))
(require "noapp-reader.rkt")

;; yes, this works. it defines a syntax parser that always produces a syntax
;; error. TODO: better error message.
(define-syntax-parser no-app)
(begin-for-syntax (define-syntax-parser no-app))

;; we reuse most of racket
(provide
 (except-out (all-from-out racket)
             #%app
             (for-syntax #%app)))

;; but customize application
(provide-for-both (rename-out [no-app #%app] [#%app #%call] [#%app call]))

;; this is convenient for repl use
(provide use-noapp-reader!)

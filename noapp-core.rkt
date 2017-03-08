#lang racket

(define-syntax-rule (provide-for-both x ...)
  (provide x ... (for-syntax x ...)))

(define-syntax-rule (require-for-both x ...)
  (require x ... (for-syntax x ...)))

(require-for-both "noapp-reader.rkt" syntax/parse/define racket/base)

;; yes, this works. it defines a syntax parser that always produces a syntax
;; error. TODO: better error message.
(define-syntax-parser no-app)
(begin-for-syntax (define-syntax-parser no-app))

(provide-for-both
 ;; utility
 noapp-reader!
 ;; our customizations
 (rename-out [#%app call] [no-app #%app])
 ;; what we build on
 (except-out (all-from-out racket/base) #%app))

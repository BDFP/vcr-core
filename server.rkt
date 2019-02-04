#lang web-server

(require web-server/servlet-env)
(require reloadable)
(require "signals.rkt")

(define (main)
  (define request-handler
    (reloadable-entry-point->procedure
     (make-reloadable-entry-point 'vcr-dispatch "vcr.rkt")))

  (reload!)

  (start-restart-signal-watcher)

  (serve/servlet request-handler
               #:stateless? #t
               #:servlet-regexp #rx""
               #:port 9090))

(main)
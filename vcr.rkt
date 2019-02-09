#lang racket

(provide vcr-dispatch)

(require web-server/servlet
         web-server/servlet-env
         web-server/http
         web-server/http/request-structs
         web-server/http/response-structs
         web-server/private/url-param)
(require web-server/dispatch)
(require json)
(require "spotify.rkt")

(define-syntax (token-url url)
    #'spotify-auth-token-redirect-url)

(define a "abcd")

(define (json-response req)
  (response 200
            #"OK"
            (current-seconds)
            #"application/json; charset=utf-8"
            empty
            (λ (op) (write-json #hasheq((waffle . (1 2 3))) op))))
  

(define (hello req)
  (define code (extract-binding/single 'code (request-bindings req)))
  (define res (fetch-token code))
  (println res)
  
  (response/xexpr
   `(html (head (title "Hello world!"))
          (body (p ,(string-append "Hey out there! " code))))))

(define-values (vcr-dispatch vcr-url)
  (dispatch-rules
   [("spotify-cb")  hello]
   [("spotify-token") #:method "get" json-response]))

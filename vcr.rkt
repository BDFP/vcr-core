#lang racket

(provide vcr-dispatch)

(require simple-http)
(require net/uri-codec)
(require net/sendurl)
(require web-server/servlet
         web-server/servlet-env)
(require web-server/dispatch)

(define client-id "711251ddb15c4ec4947e7b31750f085d")
(define client-secret "34cc7fcc716742019a8db13603d9781f")

(define spotify-api-base-url "https://api.spotify.com/")
(define spotify-auth-base-url "https://accounts.spotify.com/")


(define spotify-auth
  (update-headers
   (update-ssl
    (update-host json-requester spotify-auth-base-url) #t)
   '("Authorization: 8675309")))

(define spotify-auth-param (alist->form-urlencoded (list (cons 'client_id  client-id)
                                                         (cons 'response_type "code")
                                                         (cons 'redirect_uri  "http://localhost:9090/spotify-cb"))))

(define spotify-auth-url (string-append spotify-auth-base-url "?" spotify-auth-param))

;(send-url spotify-auth-url)

(define-values (vcr-dispatch vcr-url)
  (dispatch-rules
   [("spotify-cb") hello]))

(define (hello req)
  (response/xexpr
   `(html (head (title "Hello world!"))
          (body (p "Hey out there!")))))


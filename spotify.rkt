#lang racket

(provide spotify-auth-url
	 spotify-auth-code-redirect-url
	 spotify-auth-token-redirect-url
         fetch-token)

(require simple-http)
(require net/uri-codec)
(require net/base64)
(require net/http-client)

(define client-id #"")
(define client-secret #"")

(define spotify-api-base-url "https://api.spotify.com/")
(define spotify-auth-base-url "accounts.spotify.com")

(define host "http://localhost:9090")

(define spotify-auth-code-redirect-url "/spotify-cb")
(define spotify-auth-token-redirect-url "/spotify-token")


(define oauth-headers '("Content-Type: application/x-www-form-urlencoded"
			"Accept: application/json"))

(define oauth-requester (requester "" oauth-headers #f 'form))

(define spotify-headers
   (cons (bytes->string/utf-8
          (bytes-append #"Authorization: Basic "
                        (base64-encode (bytes-append client-id #":" client-secret)
                                       #"")))
         oauth-headers))

(define spotify-auth-param (alist->form-urlencoded
			    (list (cons 'client_id
					(bytes->string/utf-8 client-id))
				  (cons 'response_type "code")
                                  (cons 'redirect_uri
                                        (string-append host
                                                       spotify-auth-code-redirect-url))
                                  (cons 'show_dialog "true"))))

(define spotify-auth-url (string-append spotify-auth-base-url
					"/authorize" "?"
					spotify-auth-param))

(define (fetch-token code)
  (println (string-append "Fetching token for " code))
  (define-values (_ status body)  (http-sendrecv spotify-auth-base-url "/api/token"
                                                    #:ssl? #t
                                                    #:method #"POST"
                                                    #:data
                                                    (alist->form-urlencoded
                                                     (list (cons 'grant_type "authorization_code")
                                                           (cons 'code code)
                                                           (cons 'redirect_uri
                                                                 (string-append host
                                                                                spotify-auth-code-redirect-url))))
                                                    #:headers spotify-headers))
  (println (read body)))

;;(fetch-token spotify-code)
#lang racket

(provide spotify-auth-url
	 spotify-auth-code-redirect-url
	 spotify-auth-token-redirect-url
         fetch-token)

(require simple-http)
(require net/uri-codec)
(require net/base64)
(require net/http-client)
(require json)
(require db)
(require racquel)

(require "keys.rkt")


(define spotify-api-base-url "api.spotify.com")
(define spotify-auth-base-url "accounts.spotify.com")

(define host "http://localhost:9090")

(define spotify-auth-code-redirect-url "/spotify-cb")
(define spotify-auth-token-redirect-url "/spotify-token")


(define oauth-headers '("Content-Type: application/x-www-form-urlencoded"
			"Accept: application/json"))

(define json-headers '("Content-Type: application/json"
                       "Accept: application/json"))

(define spotify-headers
   (cons (bytes->string/utf-8
          (bytes-append #"Authorization: Basic "
                        (base64-encode (bytes-append client-id #":" client-secret)
                                       #"")))
         oauth-headers))

(define (spotify-api-headers access-token)
  (cons (string-append "Authorization: Bearer " access-token)
        json-headers))

(define spotify-auth-param (alist->form-urlencoded
			    (list (cons 'client_id
					(bytes->string/utf-8 client-id))
				  (cons 'response_type "code")
                                  (cons 'scope
                                        "playlist-read-private playlist-read-collaborative")
                                  (cons 'redirect_uri
                                        (string-append host
                                                       spotify-auth-code-redirect-url))
                                  (cons 'show_dialog "true"))))

(define spotify-auth-url (string-append spotify-auth-base-url
					"/authorize" "?"
					spotify-auth-param))


;; virtual db connection (aka. - thread pools)
(define db-conn (virtual-connection (λ () (sqlite3-connect #:database "vcr.db"
                                                           #:mode 'create))))

(define auth-data%
  (data-class object%
              (table-name "auth_data")
              (init-column (access-token #f "access_token") (expires-in #f "expires_in")
                      (refresh-token #f "refresh_token") (scope #f "scope")
                      (token-type #f "token_type"))
              (super-new)))


(define (make-auth-data auth-hash)
  (println auth-hash)
  (if (hash-has-key? auth-hash 'access_token)
      (new auth-data%
           [access-token (hash-ref auth-hash 'access_token)]
           [expires-in (hash-ref auth-hash 'expires_in)]
           [refresh-token (hash-ref auth-hash 'refresh_token)]
           [scope (hash-ref auth-hash 'scope)]
           [token-type (hash-ref auth-hash 'token_type)])
      (error (jsexpr->string auth-hash))))


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
  (insert-data-object db-conn (make-auth-data (read-json body))))


;;(define b (match-let-values (((_ _ _ _ members _ _ _ _) (data-class-info auth-data%)))
;;                  (map (λ (fields)
;;                         (list (car fields)
;;                               (hash-ref a (string->symbol (caddr fields)))))
;;                       members)))
;;
;;(new auth-data%
;;       b)


(println "ooye")

;;(map (λ (obj) (delete-data-object db-conn obj))

(define  user-auth-data (first (select-data-objects db-conn auth-data%)))

(define access-token (get-column access-token user-auth-data))

(define (spotify-request url)
  (call-with-values (λ ()
                      (http-sendrecv spotify-api-base-url url
                                     #:ssl? #t
                                     #:method #"GET"
                                     #:headers (spotify-api-headers access-token)))
                      (λ (_ status body) (read-json body))))

(spotify-request "/v1/me/playlists")
  
;;(fetch-token spotify-code)

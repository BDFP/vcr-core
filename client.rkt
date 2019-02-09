#lang racket

(require simple-http)
(require net/uri-codec)
(require net/sendurl)
(require "spotify.rkt")

(send-url spotify-auth-url)
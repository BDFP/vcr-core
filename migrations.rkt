#lang racket

(require db)

(unless (sqlite3-available?)
  (error (format "SQLite available native library not found")))

(define conn (sqlite3-connect #:database "vcr.db"
                              #:mode 'create))

(define queries (string-split (file->string "db.sql") "--;;"))

(start-transaction conn)

(map (λ (q) (query-exec conn q))
     queries)

(commit-transaction conn)

  
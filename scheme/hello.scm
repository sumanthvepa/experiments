#!/usr/bin/env -S gosh -r7

(import (scheme base)
        (scheme write))

(define (greet name)
  (display "Hello, ")
  (display name)
  (newline))

(greet "Scheme")

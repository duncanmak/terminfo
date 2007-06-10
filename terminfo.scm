;;; -*- Mode: Scheme; scheme48-package: ... -*-
;;; 
;;; terminfo.scm: A port of Paul Foley's terminfo.lisp to Scheme (scsh)
;;; 
;;; Copyright � 2001 Duncan Mak <duncan@ccs.neu.edu>
;;;

(define *terminfo* '())
(define *terminfo-directories* '("/usr/share/terminfo"
                                 "/usr/share/misc/terminfo"))

(define-record-type terminfo
  (make-terminfo names booleans numbers strings)
  terminfo?
  (names terminfo-names)
  (booleans terminfo-booleans set-terminfo-booleans!)
  (numbers  terminfo-numbers  set-terminfo-numbers!)
  (strings  terminfo-strings  set-terminfo-strings!))

(define (terminfo-filename name)
  (let loop ((dirs *terminfo-directories*))
    (if (not (null? dirs))
        (let* ((basedir (car dirs))
               (initial (string-take name 1))
               (file    (path-list->file-name (list basedir initial name))))
          (cond ((file-not-exists? file) 
                 (error "Cannot find terminfo named " name))
                ; TODO: file-exists? returns only the relative path
                ((file-symlink? file) (read-symlink file))
                ((file-readable? file)  file)
                (else (loop (cdr dirs))))))))

(define (read-byte stream)
  (let ((value (read-char stream)))
    (if (eof-object? value)
        (error "invalid data")
        (char->ascii value))))

(define (read-short stream)
  (let ((n (+ (read-byte stream) 
              (* 256 (read-byte stream)))))
    (if (> n 32767) 
        (- n 65536) 
        n)))

(define (read-strings-and-split stream)
  (let loop ((c      (read-char stream))
             (s      '())
             (result '()))
    (cond ((or (eof-object? c) (zero? (char->ascii c)))
           (append result (list (list->string s))))
          ((char=? c #\|)
           (loop (read-char stream) 
                 '()  
                 (append result (list (list->string s)))))
          (else (loop (read-char stream)
                      (if (null? s) (list c) (append s (list c)))
                      result)))))

(define (load-terminfo name)
  (call-with-input-file (terminfo-filename name)
    (lambda (stream)
      (let* ((magic         (read-short stream))
             (sznames       (read-short stream))
             (szbooleans    (read-short stream))
             (sznumbers     (read-short stream))
             (szstrings     (read-short stream))
             (szstringtable (read-short stream))
             (names         (read-strings-and-split stream))
             (booleans      (make-vector szbooleans #f))
             (numbers       (make-vector sznumbers -1))
             (strings       (make-vector szstrings -1))
             (stringtable   (make-string szstringtable)))
        (if (not (= magic #o432)) 
            (error "file format is invalid."))
        (do ((i 0 (+ i 1))) ((>= i szbooleans))
          (vector-set! booleans i (not (zero? (read-byte stream)))))
        (if (odd? (+ sznames szbooleans))
            (read-byte stream))
        (do ((i 0 (+ i 1))) ((>= i sznumbers))
          (vector-set! numbers i (read-short stream)))
        (do ((i 0 (+ i 1))) ((>= i szstrings))
          (vector-set! strings i (read-short stream)))
        (do ((i 0 (+ i 1))) ((>= i szstringtable))
          (string-set! stringtable i (read-char stream)))
        (let ((tmp (make-vector szstrings)))
          (do ((i 0 (+ i 1))) ((>= i szstrings))
            (let* ((length (string-length stringtable))
                   (start  i)
                   (end    (string-index stringtable #\0 i length)))
             (if (positive? (vector-ref strings i))
                 (vector-set! tmp i (substring stringtable start end)))))
          (set! strings tmp))
        (make-terminfo names booleans numbers strings)))))

(define (set-terminal . args)
  (let ((name (if (not (null? args))
                  (car args)
                  (getenv "TERM"))))
    (format #t "name is ~A~%" name)
    (set! *terminfo* (load-terminfo name))))

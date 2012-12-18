;;; Library

(eval-when-compile
  (%compile-defmacro 'defmacro
     (lambda (name args &rest body)
       `(eval-when-compile
          (%compile-defmacro ',name (lambda ,args ,@body))))))

(defmacro defvar (name value)
  `(progn
     (eval-when-compile
       (%compile-defvar ',name))
     (setq ,name ,value)))

(defvar t 't)
(defvar nil 'nil)

(defmacro defun (name args &rest body)
  `(progn
     (eval-when-compile
       (%compile-defun ',name))
     (fsetq ,name (lambda ,args ,@body))))

(defun = (x y) (= x y))
(defun + (x y) (+ x y))
(defun - (x y) (- x y))
(defun * (x y) (* x y))
(defun / (x y) (/ x y))
(defun 1+ (x) (+ x 1))
(defun 1- (x) (- x 1))
(defun zerop (x) (= x 0))
(defun not (x) (if x nil t))

(defun truncate (x y) (floor (/ x y)))

(defun cons (x y ) (cons x y))
(defun car (x) (car x))
(defun caar (x) (car (car x)))
(defun cadr (x) (car (cdr x)))
(defun cdr (x) (cdr x))
(defun cdar (x) (cdr (car x)))
(defun cddr (x) (cdr (cdr x)))

(defun append (list1 list2)
  (if (null list1)
      list2
      (cons (car list1)
            (append (cdr list1) list2))))

(defun reverse-aux (list acc)
  (if (null list)
      acc
      (reverse-aux (cdr list) (cons (car list) acc))))

(defun reverse (list)
  (reverse-aux list '()))

(defmacro incf (x)
  `(setq ,x (1+ ,x)))

(defmacro decf (x)
  `(setq ,x (1- ,x)))

(defun length (list)
  (let ((l 0))
    (while (not (null list))
      (incf l)
      (setq list (cdr list)))
    l))

(defun mapcar (func list)
  (if (null list)
      '()
      (cons (funcall func (car list))
            (mapcar func (cdr list)))))

(defmacro push (x place)
  `(setq ,place (cons ,x ,place)))

(defvar *package* (new))

(defun intern (name)
  (let ((s (get *package* name)))
    (if s
        s
        (set *package* name (make-symbol name)))))

(defun find-symbol (name)
  (get *package* name))


(defmacro cond (&rest clausules)
  (if (null clausules)
      nil
      (if (eq (caar clausules) t)
          `(progn ,@(cdar clausules))
          `(if ,(caar clausules)
               (progn ,@(cdar clausules))
               (cond ,@(cdr clausules))))))

(defun !reduce (func list initial)
  (if (null list)
      initial
      (!reduce func
               (cdr list)
               (funcall func initial (car list)))))


(defun code-char (x) x)
(defun char-code (x) x)
(defvar *newline* (string (code-char 10)))

(defun concat (&rest strs)
  (!reduce (lambda (s1 s2) (concat-two s1 s2))
           strs
           ""))

;;; Concatenate a list of strings, with a separator
(defun join (list separator)
  (cond
    ((null list)
     "")
    ((null (cdr list))
     (car list))
    (t
     (concat (car list)
             separator
             (join (cdr list) separator)))))

(defun join-trailing (list separator)
  (if (null list)
      ""
      (concat (car list) separator (join-trailing (cdr list) separator))))

(defun integer-to-string (x)
  (if (zerop x)
      "0"
      (let ((digits nil))
        (while (not (zerop x 0))
          (push (mod x 10) digits)
          (setq x (truncate x 10)))
        (join (mapcar (lambda (d) (string (char "0123456789" d)))
                      digits)
              ""))))

(defmacro and (&rest forms)
  (cond
    ((null forms)
     t)
    ((null (cdr forms))
     (car forms))
    (t
     `(if ,(car forms)
          (and ,@(cdr forms))
          nil))))


(defmacro or (&rest forms)
  (cond
    ((null forms)
     nil)
    ((null (cdr forms))
     (car forms))
    (t
     `(if ,(car forms)
          t
          (or ,@(cdr forms))))))


(defmacro prog1 (form &rest body)
  (let ((value (make-symbol "VALUE")))
    `(let ((,value ,form))
       ,@body
       ,value)))


(defun char= (x y) (= x y))


;;;; Reader

;;; It is a basic Lisp reader. It does not use advanced stuff
;;; intentionally, because we want to use it to bootstrap a simple
;;; Lisp. The main entry point is the function `ls-read', which
;;; accepts a strings as argument and return the Lisp expression.
(defun make-string-stream (string)
  (cons string 0))

(defun %peek-char (stream)
  (and (< (cdr stream) (length (car stream)))
       (char (car stream) (cdr stream))))

(defun %read-char (stream)
  (and (< (cdr stream) (length (car stream)))
       (prog1 (char (car stream) (cdr stream))
         (setcdr stream (1+ (cdr stream))))))

(defun whitespacep (ch)
  (or (char= ch #\space) (char= ch #\newline) (char= ch #\tab)))

(defun skip-whitespaces (stream)
  (let (ch)
    (setq ch (%peek-char stream))
    (while (and ch (whitespacep ch))
      (%read-char stream)
      (setq ch (%peek-char stream)))))

(defun terminalp (ch)
  (or (null ch) (whitespacep ch) (char= #\) ch) (char= #\( ch)))



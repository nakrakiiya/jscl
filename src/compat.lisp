;;; compat.lisp --- Create some definitions to fix CL compatibility

;; Copyright (C) 2012, 2013 David Vazquez
;; Copyright (C) 2012 Raimon Grau

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Duplicate from boot.lisp by now
(defmacro with-collect (&body body)
  (let ((head (gensym))
        (tail (gensym)))
    `(let* ((,head (cons 'sentinel nil))
            (,tail ,head))
       (flet ((collect (x)
                (rplacd ,tail (cons x nil))
                (setq ,tail (cdr ,tail))
                x))
         ,@body)
       (cdr ,head))))

(defmacro while (condition &body body)
  `(do ()
       ((not ,condition))
     ,@body))

(defmacro eval-when-compile (&body body)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     ,@body))

(defun concat-two (s1 s2)
  (concatenate 'string s1 s2))

(defun aset (array idx value)
  (setf (aref array idx) value))

(eval-when-compile
  (defun concat (&rest strs)
    (apply #'concatenate 'string strs)))

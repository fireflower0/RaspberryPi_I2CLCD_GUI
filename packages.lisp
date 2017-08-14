(ql:quickload "cffi")
(ql:quickload "ltk")

(defpackage :cl-cffi
  (:use :common-lisp
	:cffi
	:ltk))

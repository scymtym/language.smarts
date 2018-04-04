(cl:defpackage #:language.smarts.test
  (:use
   #:cl

   #:fiveam)

  (:export
   #:run-tests))

(cl:in-package #:language.smarts.test)

(def-suite :language.smarts)

(defun run-tests ()
  (run! :language.smarts))

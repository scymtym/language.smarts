(cl:defpackage #:language.smiles.test
  (:use
   #:cl

   #:fiveam)

  (:export
   #:run-tests))

(cl:in-package #:language.smiles.test)

(def-suite :language.smiles)

(defun run-tests ()
  (run! :language.smiles))

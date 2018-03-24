;;;; package.lisp --- Package definition for SMILES tests.
;;;;
;;;; Copyright (C) 2018 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

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

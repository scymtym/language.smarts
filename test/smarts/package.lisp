;;;; package.lisp --- Package definition for SMART tests.
;;;;
;;;; Copyright (C) 2018 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

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

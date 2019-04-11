;;;; package.lisp --- Package definition for tests of the SMARTS parser.
;;;;
;;;; Copyright (C) 2018, 2019 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:defpackage #:language.smarts.parser.test
  (:use
   #:cl

   #:fiveam

   #:language.smarts.parser)

  (:import-from #:parser.common-rules.test
   #:define-rule-test
   #:parses-are))

(cl:in-package #:language.smarts.parser.test)

(def-suite :language.smarts.parser
  :in :language.smarts)

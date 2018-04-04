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

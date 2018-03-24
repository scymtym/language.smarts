(cl:defpackage #:language.smiles.parser.test
  (:use
   #:cl

   #:fiveam

   #:language.smiles.parser)

  (:import-from #:parser.common-rules.test
   #:define-rule-test
   #:parses-are))

(cl:in-package #:language.smiles.parser.test)

(def-suite :language.smiles.parser
  :in :language.smiles)

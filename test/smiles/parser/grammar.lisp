;;;; grammar.lisp --- Tests for the SMILES parser.
;;;;
;;;; Copyright (C) 2018 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:language.smiles.parser.test)

(in-suite :language.smiles.parser)

(test rule.atom-pattern
  "Smoke test for the `atom-pattern' rule."

  (architecture.builder-protocol:with-builder ('list)
    (parses-are (modified-atom)
      ("[C++]" '(:bracketed-expression
                 (:expression
                  (((:atom
                     (:modifier (((:charge () :which :positive :value 2 :bounds (2 . 4)))))
                     :symbol (:atom () :kind :organic :symbol "C" :bounds (1 . 2))
                     :weight nil
                     :class  nil
                     :bounds (1 . 4)))))
                 :bounds (0 . 5)))
      ("[Na]"  '(:bracketed-expression
                 (:expression
                  (((:atom
                     ()
                     :symbol (:atom () :kind :inorganic :symbol "Na" :bounds (1 . 3))
                     :weight nil
                     :class  nil
                     :bounds (1 . 3)))))
                 :bounds (0 . 4))))))

;;;; grammar.lisp --- Tests for the SMARTS grammar.
;;;;
;;;; Copyright (C) 2018, 2019 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:language.smarts.parser.test)

(in-suite :language.smarts.parser)

(test rule.atom-pattern
  "Smoke test for the `atom-pattern' rule."

  (let ((language.smiles.parser:*atom-maps?* t))
    (architecture.builder-protocol:with-builder ('list)
      (parses-are (atom-pattern)
        ("[C++]" '(:bracketed-expression
                   (:expression
                    (((:binary-operator
                       (:operand
                        (((:atom () :kind :organic :symbol "C" :bounds (1 . 2)))
                         ((:charge () :which :positive :value 2 :bounds (2 . 4)))))
                       :operator :implicit-and :bounds (1 . 4)))))
                   :bounds (0 . 5)))
        ("[C+2]" '(:bracketed-expression
                   (:expression
                    (((:binary-operator
                       (:operand
                        (((:atom () :kind :organic :symbol "C" :bounds (1 . 2)))
                         ((:charge () :which :positive :value 2 :bounds (2 . 4)))))
                       :operator :implicit-and :bounds (1 . 4)))))
                   :bounds (0 . 5)))
        ("C1"    '(:binary-operator
                   (:operand (((:atom () :kind :organic :symbol "C" :bounds (0 . 1)))
                              ((:atom-map-class () :class 1 :bounds (1 . 2)))))
                   :operator :implicit-and :bounds (0 . 2)))
        ("[C]1"  '(:binary-operator
                   (:operand (((:bracketed-expression
                                (:expression (((:atom () :kind :organic :symbol "C" :bounds (1 . 2)))))
                                :bounds (0 . 3)))
                              ((:atom-map-class () :class 1 :bounds (3 . 4)))))
                   :operator :implicit-and :bounds (0 . 4)))
        ("[C:1]" '(:bracketed-expression
                   (:expression
                    (((:binary-operator
                       (:operand (((:atom () :kind :organic :symbol "C" :bounds (1 . 2)))
                                  ((:atom-map-class () :class 1 :bounds (2 . 4)))))
                       :operator :implicit-and :bounds (1 . 4)))))
                   :bounds (0 . 5)))
        ("[Na]"  '(:bracketed-expression
                   (:expression (((:atom () :kind :inorganic :symbol "Na" :bounds (1 . 3)))))
                   :bounds (0 . 4)))))))

(test rule.bond-pattern
  "Smoke test for the `bond-pattern' rule."

  (architecture.builder-protocol:with-builder ('list)
    (parses-are (bond-pattern)
      ("."   :none)

      ("~~"  :wildcard)
      ("/?"  :up-or-unspecified)
      ("\\?" :down-or-unspecified))))

(test rule.recursive
  "Smoke test for the `recursive' rule."

  (architecture.builder-protocol:with-builder ('list)
    (parses-are (recursive)
      ("$"    nil)
      ("$("   nil)
      ("$()"  nil)

      ("$(C)" '(:recursive
                (:pattern (((:atom
                             ()
                             :kind :organic :symbol "C" :bounds (2 . 3)))))
                :bounds (0 . 4))))))

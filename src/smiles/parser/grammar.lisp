;;;; grammar.lisp --- Grammar for the SMILES language.
;;;;
;;;; Copyright (C) 2018 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

;;;; Esrap parser for the SMILES language.
;;;;
;;;; See https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system
;;;;     http://www.daylight.com/dayhtml/doc/theory/index.html

(cl:in-package #:language.smiles.parser)

(defrule smiles
    (and (? atom) (? chain))
  (:destructure (atom chain)
    (cond ; TODO
      ((and atom chain)
       (bp:node* (:chain)
         (* :element (list* atom (bp:node-relation* :element chain)))))
      (atom)
      (chain))))

(defrule chain
    (+ (or bond-atom branch))
  (:lambda (elements &bounds start end)
    (bp:node* (:chain :bounds (cons start end))
      (* :element elements))))

(defrule branch
    (and #\( chain #\))
  (:function second))

(defrule bond-atom
    (and (? bond) atom)
  (:destructure (bond atom &bounds start end)
    (bp:node* (:bond :kind (or bond :single) :bounds (cons start end))
      (1 :atom atom))))

(defrule atom
    (and acyclic-atom (? parser.common-rules:integer-literal/decimal))
  (:destructure (atom label &bounds start end)
    (if label
        (bp:node* (:labeled :label label :bounds (cons start end))
          (1 :atom atom))
        atom)))

(defrule acyclic-atom
    (or modified-atom
        atom-symbol))

;;; Daylight Theory Manual 3.2.1 Atoms

(defrule atom-symbol
    (or inorganic-atom-symbol
        organic-atom-symbol
        aromatic-atom-symbol))

(defrule organic-atom-symbol ; TODO macro
    (or "Br" "B" "Cl" "C" "F" "I" "N" "O" "P" "S")
  (:lambda (symbol &bounds start end)
    (bp:node* (:atom :kind :organic :symbol symbol :bounds (cons start end)))))

(defrule aromatic-atom-symbol
    (or "br" "b" "cl" "c" "f" "i" "n" "o" "p" "s")
  (:lambda (symbol &bounds start end)
    (bp:node* (:atom :kind :aromatic :symbol symbol :bounds (cons start end)))))

;; msmarts_Parser.yy:869
(defrule inorganic-atom-symbol
    (or "Al" "Ca" "Co" "Cu" "Fe" "Na")
  (:lambda (symbol &bounds start end)
    (bp:node* (:atom :kind :inorganic :symbol symbol :bounds (cons start end)))))

;;; Daylight Theory Manual 3.5 Atom expression
;;;
;;; "modified" in the sense of element symbol/atomic mass plus
;;; modifiers.
(defrule modified-atom
    (and #\[ modified-atom-body #\])
  (:function second)
  (:lambda (expression &bounds start end)
    (bp:node* (:bracketed-expression :bounds (cons start end))
      (1 :expression expression))))

(defrule modified-atom-body
    (and (or (and atom-weight atom-symbol)
             (and atom-weight (and))
             (and (and)       atom-symbol))
         (* atom-modifier) (? atom-map-class))
  (:destructure ((weight symbol) modifiers class &bounds start end)
    (bp:node* (:atom :symbol symbol :weight weight :class class
                     :bounds (cons start end))
      (* :modifier modifiers))))

(defrule atom-weight
    parser.common-rules::integer-literal/decimal/no-sign)

(defrule atom-modifier
    (or hydrogen-count charge chirality))

(defrule hydrogen-count ; TODO is this SMILES or SMARTS?
    (and "H" parser.common-rules:integer-literal/decimal)) ; TODO predicate for non-negative or positive

(defrule charge
    (or charge-positive charge-negative))

(macrolet
    ((define-repeat-rules (name character
                           &optional (value (make-keyword name)))
       (let ((rule-name        (symbolicate '#:charge- name))
             (rule-name/number (symbolicate '#:charge- name '#:/number))
             (rule-name/repeat (symbolicate '#:charge- name '#:/repeat)))
         `(progn
            (defrule ,rule-name
                (or ,rule-name/number ,rule-name/repeat))

            (defrule ,rule-name/number
                (and ,character parser.common-rules::integer-literal/decimal/no-sign)
              (:function second)
              (:lambda (count &bounds start end)
                (bp:node* (:charge :which ',value :value count
                                   :bounds (cons start end)))))

            (defrule ,rule-name/repeat
                (+ ,character)
              (:function length)
              (:lambda (count &bounds start end)
                (bp:node* (:charge :which ',value :value count
                                   :bounds (cons start end)))))))))
  (define-repeat-rules positive #\+)
  (define-repeat-rules negative #\-))

;;; Daylight Theory Manual 3.3.4 General Chiral Specification

(defrule chirality
    (or chirality/number chirality/repeat))

(defrule chirality/number
    (and #\@ (? (or "TH" "AL" "SP" "TB" "OH"))
         parser.common-rules:integer-literal/decimal)
  (:function rest)
  (:destructure (class count &bounds start end)
    (bp:node* (:chirality :class class :count count :bounds (cons start end)))))

(defrule chirality/repeat
    (+ #\@)
  (:function length)
  (:lambda (count &bounds start end)
    (bp:node* (:chirality :count count :bounds (cons start end)))))

;;; Daylight Theory Manual, page 17
(macrolet ((define-atom-map-class-rule (name &body expression-and-options)
             `(defrule ,name
                  ,@expression-and-options
                (:lambda (class &bounds start end)
                  (bp:node* (:atom-map-class :class class :bounds (cons start end))))
                (:when *atom-maps?*))))

  (define-atom-map-class-rule atom-map-class
      (and #\: parser.common-rules::integer-literal/decimal/no-sign)
    (:function second))

  (define-atom-map-class-rule atom-map-class/no-colon
    parser.common-rules::integer-literal/decimal/no-sign))

;;; Daylight Theory Manual 3.2.2 Bonds

(macrolet
    ((define-rules (&body clauses)
       (let ((rules '()))
         (flet ((process-clause (name string
                                 &optional (value (make-keyword name)))
                  (let ((rule-name (symbolicate '#:bond- name)))
                    (push rule-name rules)
                    `(defrule ,rule-name
                         ,string
                       (:constant ,value)))))
           `(progn
              ,@(map 'list (curry #'apply #'process-clause) clauses)
              (defrule bond (or ,@ (nreverse rules))))))))

  (define-rules
    (none      #\.)

    (single    #\-)
    (double    #\=)
    (triple    #\#)
    (quadruple #\$)

    (aromatic  #\:)

    (up        #\/)
    (down      #\\)))

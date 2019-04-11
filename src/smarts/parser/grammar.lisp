;;;; grammar.lisp --- Grammar for the SMARTS language.
;;;;
;;;; Copyright (C) 2018, 2019 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

;;;; Esrap parser for the SMARTS language as an extension of the Esrap
;;;; parser for the SMILES language.
;;;;
;;;; See https://en.wikipedia.org/wiki/Smiles_arbitrary_target_specification
;;;;     https://docs.eyesopen.com/toolkits/cpp/oechemtk/SMARTS.html
;;;;     http://www.daylight.com/cheminformatics/index.html

(cl:in-package #:language.smarts.parser)

(defrule smarts
    (and atom-pattern (? chain-elements))
  (:destructure (atom elements &bounds start end)
    (if elements
        (bp:node* (:chain :bounds (cons start end))
          (* :element (list* atom elements)))
        atom)))

(defrule chain-pattern
    chain-elements
  (:lambda (elements &bounds start end)
    (bp:node* (:chain :bounds (cons start end))
      (* :element elements))))

(defrule chain-elements
    (+ (or bond-atom-pattern branch)))

(defrule branch
    (and #\( chain-pattern #\)) ; TODO ast node for this?
  (:function second))

(defrule bond-atom-pattern
    (and (? bond-pattern) atom-pattern)
  (:destructure (bond atom &bounds start end)
    (bp:node* (:bond :kind (or bond :single) :bounds (cons start end))
      (1 :atom atom))))

(defrule atom-pattern ; TODO duplicated from SMILES?
    ;; The trailing integer is an atom map class, but in contrast to
    ;; `language.simles.parser:atom-map-class', there is no #\:
    ;; preceding the integer.
    (and acyclic-atom-pattern (? smiles:atom-map-class/no-colon))
  (:destructure (atom class &bounds start end)
    (if class
        (bp:node* (:binary-operator :operator :implicit-and
                                    :bounds   (cons start end))
          (1 :operand atom)
          (1 :operand class))
        atom)))

(defrule acyclic-atom-pattern
    (or modified-atom-pattern smiles:atom-symbol))

(defrule modified-atom-pattern
    (and #\[ weak-and-expression #\])
  (:function second)
  (:lambda (expression &bounds start end)
    (bp:node* (:bracketed-expression :bounds (cons start end))
      (1 :expression expression))))

;;; SMARTS 4.1 Atomic Primitives

;;; There are no modifiers: 4.3 Logical Operators
;;;
;;; All atomic expressions which are not simple primitives must be
;;; enclosed in brackets. The default operation is & (high precedence
;;; "and"), i.e., two adjacent primitives without an intervening
;;; logical operator must both be true for the expression (or
;;; subexpression) to be true.
(defrule modified-atom-pattern-body
    (or smiles:atom-weight ; TODO this is just a number, i.e. (node* ) is missing
        smiles:atom-symbol

        ; smiles:hydrogen-count
        smiles:charge
        smiles:chirality

        atom-pattern/non-literal

        smiles:atom-map-class

        recursive))

(macrolet
    ((define-rules (&body clauses)
       (let ((rules '()))
         (flet ((process-clause (name expression
                                 &key
                                 parameter
                                 (kind (make-keyword name)))
                  (let ((rule-name (symbolicate '#:atom-rule- name)))
                    (push rule-name rules)
                    (ecase parameter
                      ((t &optional)
                       `(defrule ,rule-name
                            (and ,expression
                                 ,(if (eq parameter '&optional)
                                      `(? parser.common-rules:integer-literal/decimal)
                                      'parser.common-rules:integer-literal/decimal))
                          (:function second)
                          (:lambda (value &bounds start end)
                            (bp:node* (:atom ',kind value :bounds (cons start end))))))
                      ((nil)
                       `(defrule ,rule-name
                            ,expression
                          (:lambda (value &bounds start end)
                            (declare (ignore value))
                            (bp:node* (:atom :kind ',kind :bounds (cons start end))))))))))
           `(progn
              ,@(map 'list (curry #'apply #'process-clause) clauses)
              (defrule atom-pattern/non-literal (or ,@(nreverse rules))))))))
  (define-rules
    (wildcard                #\*)

    (aromatic                #\a)
    (aliphatic               #\A)

    (degree                  #\D :parameter t)
    (total-hydrogen-count    #\H :parameter &optional)
    (implicit-hydrogen-count #\h :parameter &optional)
    (ring-bond-count         #\R :parameter &optional)
    ;; TODO allow x?
    (smallest-ring-size      #\r :parameter &optional)
    (valence                 #\v :parameter t)
    (connectivity            #\X :parameter t)
    (atomic-number           #\# :parameter t)))

;;; SMARTS 4.2 Bonds Primitives

(defrule bond-pattern
    (or bond-pattern/non-literal smiles:bond))

;;; Only additions to SMILES 3.2.2.
(macrolet
    ((define-rules (&body clauses)
       (let ((rules '()))
         (flet ((process-clause (name expression
                                 &key
                                 (kind (make-keyword name)))
                  (let ((rule-name (symbolicate '#:bond-pattern- name)))
                    (push rule-name rules)
                    `(defrule ,rule-name
                         ,expression
                       (:constant ,kind)))))
           `(progn
              ,@(map 'list (curry #'apply #'process-clause) clauses)
              (defrule bond-pattern/non-literal (or ,@(nreverse rules))))))))
  (define-rules
    (wildcard            #\~)
    (same-ring           #\@) ; added in SMARTS 4.6
    (up-or-unspecified   "/?")
    (down-or-unspecified "\\?")))

;;; SMARTS 4.3 Logical Operators

(macrolet ((define-operator-rule (name expression)
             (let ((rule-name (symbolicate '#:operator- name))
                   (value     (make-keyword name)))
               `(defrule ,rule-name
                    ,expression
                  (:constant ,value)))))
  (define-operator-rule weak-and     #\;)
  (define-operator-rule or           #\,)
  (define-operator-rule strong-and   #\&)
  (define-operator-rule not          #\!)
  (define-operator-rule implicit-and (and)))

(parser.common-rules.operators:define-operator-rules
    (:skippable?-expression nil)
  (2 weak-and-expression     operator-weak-and)
  (2 or-expression           operator-or)
  (2 strong-and-expression   operator-strong-and)
  (1 not-expression          operator-not)
  (2 implicit-and-expression operator-implicit-and)
  modified-atom-pattern-body)

;;; SMARTS 4.4 Recursive SMARTS

(defrule recursive
    (and #\$ #\( smarts #\))
  (:function third)
  (:lambda (pattern &bounds start end)
    (bp:node* (:recursive :bounds (cons start end))
      (1 :pattern pattern))))

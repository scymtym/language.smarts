;;;; grammar.lisp --- Grammar for the SMARTS language.
;;;;
;;;; Copyright (C) 2018 Jan Moringen
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
    (and (? atom-pattern) (? chain-pattern))
  (:destructure (atom chain)
    (cond ; TODO
      ((and atom chain)
       (bp:node* (:chain)
         (* :element (list* atom (bp:node-relation* :element chain)))))
      (atom)
      (chain))))

(defrule chain-pattern
    (* (or bond-atom-pattern branch))
  (:lambda (elements &bounds start end)
    (bp:node* (:chain :bounds (cons start end))
      (* :element elements))))

(defrule branch
    (and #\( chain-pattern #\))
  (:function second))

(defrule bond-atom-pattern
    (and (? bond-pattern) atom-pattern)
  (:destructure (bond atom &bounds start end)
    (bp:node* (:bond :kind (or bond :single) :bounds (cons start end))
      (1 :atom atom))))

(defrule atom-pattern
    (and acyclic-atom-pattern (? parser.common-rules:integer-literal/decimal))
  (:destructure (atom label)
    (if label
        (bp:node* (:labeled :label label)
          (1 :atom atom))
        atom)))

(defrule acyclic-atom-pattern
    (or modified-atom-pattern smiles:atom-symbol))

(defrule modified-atom-pattern
    (and #\[ weak-and-expression #\])
  (:function second))

;;; SMARTS 4.1 Atomic Primitives

(defrule modified-atom-pattern-body
    (or atom-pattern/non-literal
        smiles:modified-atom-body
        recursive))

(macrolet
    ((define-rules (&body clauses)
       (let ((rules '()))               ; TODO unused
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
                            `(:atom () ,',kind ,value :bounds ,(cons start end)))))
                      ((nil)
                       `(defrule ,rule-name
                            ,expression
                          (:constant '(:atom () :kind ,kind))))))))
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
    (up-or-unspecified   "/?")
    (down-or-unspecified "\\?")))

;;; SMARTS 4.3 Logical Operators

(macrolet ((define-operator-rule (name character
                                  &optional (value (make-keyword name)))
             (let ((rule-name (symbolicate '#:operator- name)))
               `(defrule ,rule-name
                    ,character
                  (:constant ,value)))))
  (define-operator-rule weak-and   #\; :and)
  (define-operator-rule or         #\,)
  (define-operator-rule strong-and #\& :and)
  (define-operator-rule not        #\!))

(parser.common-rules.operators:define-operator-rules
    (:skippable?-expression nil)
  (2 weak-and-expression   operator-weak-and)
  (2 or-expression         operator-or)
  (2 strong-and-expression operator-strong-and)
  (1 not-expression        operator-not)
  modified-atom-pattern-body)

;;; SMARTS 4.4 Recursive SMARTS

(defrule recursive
    (and #\$ #\( smarts #\))
  (:function third)
  (:lambda (pattern &bounds start end)
    (bp:node* (:recursive :bounds (cons start end))
      (1 :pattern pattern))))

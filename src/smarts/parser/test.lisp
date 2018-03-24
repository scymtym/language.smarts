(cl:in-package #:language.smarts.parser)

;;; Test

(bp:with-builder ('list)
  (esrap:parse 'smarts "B1=C(-P)-P1"))


(bp:with-builder ('list)
  (esrap:parse 'smarts "B1=C(-[30Al+5@OH3])-[P--]1"))


(bp:with-builder ('list)
  (esrap:parse 'smarts "C1=CC=CC=C1"))


#+not-sure-how-this-works (bp:with-builder ('list)
                            (esrap:parse 'smarts "C:1:C:C:C:C:C1"))

#+no (bp:with-builder ('list)
       (esrap:parse 'smarts "n1c[nH]cc1"))

(bp:with-builder ('list)
  (terpri)
  (architecture.builder-protocol.print-tree:serialize
   'list (esrap:parse 'smarts "[C&!5C@@;BrH3]-C+3/?[3Cl]~C[*]C[R7]") *standard-output*))
(trace-rule 'smarts :recursive t)


(bp:with-builder ('list)
  (terpri)
  (architecture.builder-protocol.print-tree:serialize
   'list (esrap:parse 'smarts "[$([OH2][C,S,P]=O),$([10O]1nnnc1)]") *standard-output*))

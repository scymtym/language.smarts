(cl:in-package #:language.smiles.parser)

(do-external-symbols (s '#:language.smiles.parser)
  (format t "~36A -> ~A~%" s (not (null (esrap:find-rule s)))))

(bp:with-builder ('list)
  (esrap:parse 'smiles "B1=C(-P)-P1"))

(bp:with-builder ('list)
  (esrap:parse 'smiles "B1=C(-[30Au+5@OH3])-[P--]1"))

(bp:with-builder ('list)
  (esrap:parse 'smiles "C1=CC=CC=C1"))

#+not-sure-how-this-works (bp:with-builder ('list)
                            (esrap:parse 'smirks "C:1:C:C:C:C:C1"))

#+no (bp:with-builder ('list)
       (esrap:parse 'smirks "n1c[nH]cc1"))

(bp:with-builder ('list)
  (let ((*atom-maps?* t))
    (esrap:parse 'smiles "[CH3:1][C:2](=[O:3])[O-:4].[Na+:5]")))

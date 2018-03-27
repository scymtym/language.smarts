(cl:in-package #:language.smarts.parser)

(defgeneric parse (input builder)
  (:documentation
   "Parse INPUT as a SMARTS expression, build result using BUILDER."))

(defmethod parse ((input string) (builder t))
  (let ((smiles:*atom-maps?* t))
    (bp:with-builder (builder)
      (esrap:parse 'smarts input))))

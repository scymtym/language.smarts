(defsystem "language.smiles"
  :description "A parser for the SMILES language."
  :license     "GPLv3"
  :author      "Jan Moringen <jmoringe@techfak.uni-bielefeld.de>"

  :version     (:read-file-form "version-string.sexp")
  :depends-on  ("alexandria"

                (:version "esrap"                         "0.16")

                (:version "parser.common-rules"           "0.4")

                (:version "architecture.builder-protocol" "0.9"))

  :components  ((:module    "parser"
                 :pathname  "src/smiles/parser"
                 :serial    t
                 :components ((:file       "package")
                              (:file       "variables")
                              (:file       "protocol")
                              (:file       "grammar"))))

  :in-order-to ((test-op (test-op "language.smiles/test"))))

(defsystem "language.smiles/test"
  :depends-on ("alexandria"

               (:version "fiveam"                   "1.4")
               (:version "parser.common-rules/test" "0.3")

               "language.smiles")

  :components ((:module     "test"
                :pathname   "test/smiles"
                :serial     t
                :components ((:file       "package")))

               (:module     "parser"
                :depends-on ("test")
                :pathname   "test/smiles/parser"
                :serial     t
                :components ((:file       "package")
                             (:file       "grammar" ))))

  :perform    (test-op (operation component)
                (uiop:symbol-call '#:language.smiles.test '#:run-tests)))

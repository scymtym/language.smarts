(cl:in-package #:language.smarts.parser.test)

(in-suite :language.smarts.parser)

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

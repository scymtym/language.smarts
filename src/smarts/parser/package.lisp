;;;; package.lisp --- Package definition for the smarts.parser module.
;;;;
;;;; Copyright (C) 2018 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:defpackage #:language.smarts.parser
  (:use
   #:cl
   #:alexandria
   #:esrap)

  (:local-nicknames
   (#:bp     #:architecture.builder-protocol)
   (#:smiles #:language.smiles.parser)))

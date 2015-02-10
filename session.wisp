(ns crate.session
  (:require
    [wisp.engine.node]
    [hardmode-core.src.core
      :refer [execute-body!]]
    [hardmode-ui-hypertext
      :as     http]))


(execute-body!
  (http.start-server 4000))

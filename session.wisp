(ns crate.session
  (:require
    [wisp.engine.node]
    [hardmode-ui-hypertext :as http]))

((http.start-server 4000) {})

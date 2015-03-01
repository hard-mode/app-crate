(ns crate.session
  (:require
    [hardmode-core.src.core :refer [execute-body!]]
    [hardmode-ui-hypertext  :as gui]
    [path]
    [wrench :refer  [ readdirSyncRecursive ]
            :rename { readdirSyncRecursive readdir }] ))

(defn update-results! [])

(defn rel [p] (path.join __dirname p))

(execute-body!
  (gui.server 4000

    (gui.page

      { :pattern  "/" }

      (gui.widgets.input "search"
        :script (rel "search-box.wisp"))

      (gui.widgets.list-view "results"))))

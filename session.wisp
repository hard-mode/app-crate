(ns crate.session
  (:require
    [hardmode-core.src.core :refer [execute-body!]]
    [hardmode-ui-hypertext  :as gui]
    [path]
    [wrench :refer  [ readdirSyncRecursive ]
            :rename { readdirSyncRecursive readdir }] ))

(defn update-results! [])

(execute-body!
  (gui.server 4000

    (gui.page

      { :pattern  "/"
        :template (path.resolve (path.join
                    __dirname "templates/track-browser.jade")) }

      (gui.widgets.input "search")

      (gui.widgets.list-view "results"))))

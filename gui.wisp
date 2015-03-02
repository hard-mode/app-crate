(ns crate.gui
  (:require
    [crate.database        :as     database]
    [hardmode-core.util    :refer [execute-body!]]
    [hardmode-ui-hypertext :as     gui]
    [path]))

(defn rel [p] (path.join __dirname p))

(execute-body!
  (gui.server 4000

    (gui.page { :pattern "/" }
      (gui.widgets.input "search"
        :script (rel "search-box.wisp"))
      (gui.widgets.list-view "results"))

    (database.route-search "/search")))

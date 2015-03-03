(ns crate.gui
  (:require
    [crate.database        :as     database]
    [crate.start-db        :as     start-db]
    [hardmode-core.util    :refer [execute-body!]]
    [hardmode-ui-hypertext :as     gui]
    [path]))

(defn rel [p] (path.join __dirname p))

(database.connect! "27017")
(database.scan-directory! "/home/epimetheus/Music")

(execute-body!
  (gui.server 4000

    (gui.page { :pattern "/" }
      (gui.widgets.input "search"
        :script (rel "search-box.wisp"))
      (gui.widgets.list-view "results"))

    (database.route-search "/search")))

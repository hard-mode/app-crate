(ns crate.gui
  (:require
    [crate.database        :as     database]
    [crate.start-db        :as     start-db]
    [hardmode-core.util    :refer [execute-body!]]
    [hardmode-ui-hypertext :as     gui]
    [path]))

(defn rel [p] (path.join __dirname p))

(database.connect! "27017")
;(database.scan-directory! "/home/epimetheus/Music")

(execute-body!
  (gui.server 4000

    (gui.page { :pattern "/" }

      (gui.widgets.panel     "work-queue-panel")
        ;:body [(gui.widgets.list-view "work-queue-list")])

      (gui.widgets.button    "show-queue"
        :text          "Job queue...")

      (gui.widgets.input     "search"
        :script        (rel "search-box.wisp"))

      (gui.widgets.list-view "results"
        :item-template (rel "search-result.wisp")
        :style         (rel "track-list.styl")))

    (database.route-search "/search")

    (database.route-analyze-key "/analyze-key")

    (database.route-analyze-bpm "/analyze-bpm")))

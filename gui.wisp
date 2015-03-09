(ns crate.gui
  (:require
    [crate.database        :as     database]
    [crate.start-db        :as     start-db]
    [hardmode-core.util    :refer [execute-body!]]
    [hardmode-ui-hypertext :as     gui]
    [path]))

(def ^:private server    gui.server)
(def ^:private page      gui.page)
(def ^:private panel     gui.widgets.panel)
(def ^:private grid      gui.widgets.grid)
(def ^:private input     gui.widgets.input)
(def ^:private button    gui.widgets.button)
(def ^:private list-view gui.widgets.list-view)

(defn rel [p] (path.join __dirname p))

(database.connect! "27017")
;(database.scan-directory! "/home/epimetheus/Music")

(execute-body!
  (server 4000

    (page { :pattern  "/"
            :template (rel "template.wisp")}
      (panel "work-queue-panel")
      (grid { :dir :v, :sizes [1 7] }
        (grid { :dir :h, :sizes [4 1] }
          (input  "search"
            :script (rel "search-box.wisp"))
          (button "show-queue"
            :text   "Job queue..."))
        (list-view "results"
          :item-template (rel "search-result.wisp")
          :style         (rel "track-list.styl"))))

    (database.route-search "/search")

    (database.route-analyze-key "/analyze-key")

    (database.route-analyze-bpm "/analyze-bpm")))

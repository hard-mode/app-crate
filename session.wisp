(ns crate.session
  (:require
    [hardmode-core.src.core        :refer [execute-body!]]
    [hardmode-ui-hypertext         :as     gui]
    [hardmode-ui-hypertext.routing :refer [route add-route]]
    [path]
    [send-data.json                :as     send-json]
    [url]
    [wisp.runtime                  :refer [= not]]
    [wrench :refer  [ readdirSyncRecursive ]
            :rename { readdirSyncRecursive readdir }] ))

(defn rel [p] (path.join __dirname p))

(def collection (readdir "/home/epimetheus/Music"))

(defn find-in-collection [search-term]
  (console.log "Searching for" search-term "...")
  (collection.filter (fn [item]
    (not (= (item.indexOf search-term) -1)))))

(defn serve-search-results [request response]
  (let [parsed-url    (url.parse request.url true)
        search-term   parsed-url.query.q
        response-data (find-in-collection search-term)]
    (send-json request response response-data)))

(execute-body!
  (gui.server 4000

    (gui.page { :pattern "/" }
      (gui.widgets.input "search"
        :script (rel "search-box.wisp"))
      (gui.widgets.list-view "results"))

    (fn [context]
      (add-route context (route "/search" serve-search-results)))))

(ns crate.database
  (:require
    [hardmode-ui-hypertext.routing :refer [route add-route]]
    [send-data.json                :as     send-json]
    [url]
    [wisp.runtime                  :refer [= not]]
    [wrench :refer  [ readdirSyncRecursive ]
            :rename { readdirSyncRecursive readdir }] ))

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

(defn route-search [pattern]
  (fn [context]
    (add-route context
      (route pattern serve-search-results))))

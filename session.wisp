(ns crate.session
  (:require
    [hardmode-core.src.core
      :refer [execute-body!]]
    [hardmode-ui-hypertext
      :as http]))

(defn update-results! [])

(execute-body!
  (http.server 4000
    (let [options { :pattern  "/"
                    :template "templates/track-browser.jade" }
          search-field   (http.input { :type "text" :id "search" })
          search-results (http.list-view)]
      (http.page options
        search-field
        search-results))))

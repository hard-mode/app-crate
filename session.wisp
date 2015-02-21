(ns crate.session
  (:require
    [hardmode-core.src.core
      :refer [execute-body!]]
    [hardmode-ui-hypertext
      :as http]
    [path]))

(defn update-results! [])

(execute-body!
  (http.server 4000
    (http.page
      { :pattern  "/"
        :template (path.resolve (path.join
                    __dirname "templates/track-browser.jade")) }
      (http.input "search"
        { :type "text"
          :id   "search" })
      (http.list-view "results"))) )

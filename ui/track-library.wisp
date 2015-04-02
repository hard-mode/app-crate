(ns crate.track-library
  (:require
    [hardmode-ui-hypertext.widgets.input.client :as input]
    [client               :refer [init-widget!]]
    [wisp.runtime         :refer [not and]]
    [wisp.sequence        :refer [map assoc]]
    [node-microajax       :as     microajax]
    [virtual-dom.h        :as     $]))

(def templates {

  :search-box
  (fn [widget]
    ($ "input"
       { :type     "text"
         :id       widget.id
         :ev-input (fn [evt] (send-search-query! evt.target.value))}))

  :track-list
  (fn [])

  :track
  (fn [track]
    ($ "li.search-result" { "data-id" track.id } [
      ($ "div.search-result-title" track.title)
      ($ "div.search-result-artist" [($ "span.search-result-label" "By")   track.artist])
      ($ "div.search-result-album"  [($ "span.search-result-label" "From") track.album])
      ($ "div.search-result-year"   [($ "span.search-result-year"  "Year") track.year])
      ($ "div.search-result-bpm-and-key" [
        ($ "span.search-result-key" [
          ($ "span.search-result-label" "Key")
          (or track.key
              ($ "a.search-result-key-analyze"
                 { :href     "#"
                   :ev-click (fn [] (request-key-analysis! track.id)) }
                 "Analyze")) ])
        ($ "span.search-result-bpm" [
          ($ "span.search-result-label" "BPM")
          (or track.key
              ($ "a.search-result-bpm-analyze"
                 { :href     "#"
                   :ev-click (fn [] (request-bpm-analysis! track.id)) }
                 "Analyze")) ]) ]) ]))

})

(defn send-search-query! [query]
  (microajax (str "/search?q=" (encodeURI query)) (fn [response]
    (show-search-results! (JSON.parse response.response)))))

(defn show-search-results! [search-results]
  (let [result-widget (aget window.HARDMODE.widgets "results")]
    (result-widget.state.set { :value search-results })))

(defn request-key-analysis! [id] nil)

(defn request-bpm-analysis! [id] nil)

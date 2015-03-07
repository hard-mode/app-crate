(ns crate.search-result
  (:require [virtual-dom.h :as $]))

(defn search-result [track]
  ($ "li.search-result" { "data-id" track.id } [

    ($ "div.search-result-title" track.title)

    ($ "div.search-result-album" [
      ($ "span.search-result-label" "From")
      track.album])

    ($ "div.search-result-year" [
      ($ "span.search-result-year" "Year")
      track.year])

    ($ "div.search-result-bpm-and-key" [
      ($ "span.search-result-key" [
        ($ "span.search-result-label" "Key")
        (or track.key
            ($ "a.search-result-key-analyze"
               { "href"    "#"
                 "data-id" track.id }
               "Analyze")) ])
      ($ "span.search-result-bpm" [
        ($ "span.search-result-label" "BPM")
        (or track.key
            ($ "a.search-result-bpm-analyze"
               { "href"    "#"
                 "data-id" track.id }
               "Analyze")) ]) ]) ]))

(set! module.exports search-result)

(defn bind-search-result-events! [element]
  (let [class-name  "search-result-key-analyze"
        slice       Array.prototype.slice
        links       (element.getElementsByClassName class-name)
        bind-event  (fn [node] (node.addEventListener "click"
                      (fn [evt] (evt.preventDefault)
                                (console.log this.dataset.id))))]
    (map bind-event (slice.call links))))

(defn request-key-analysis [id])

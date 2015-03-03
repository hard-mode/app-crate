(ns crate.track-list
  (:require [virtual-dom.h :as $]))

(fn search-results [id results]
  (let [id (str "#" id "__list")]
    ($ (str "ol.search-results" id)
      (results.map (fn [track]

        ($ "li.search-result" { "data-id" track.id }

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
                     "Analyze"))])
            ($ "span.search-result-bpm" [
              ($ "span.search-result-label" "BPM")
              (or track.key
                  ($ "a.search-result-bpm-analyze"
                     { "href"    "#"
                       "data-id" track.id }
                     "Analyze"))])])))))))

(ns crate.search-box
  (:require [wisp.runtime :refer [not and]]
            [node-microajax :as microajax]))

(defn init-search-box [container widget-opts]
  (let [id (:id widget-opts)
        el (document.getElementById id)]
    (console.log el)
    (el.addEventListener "keypress" (debounce 250 send-search-query))))

(defn send-search-query [evt]
  (let [query (encodeURI this.value)]
    (microajax (str "/search?q=" query) show-search-results)))

(defn show-search-results [response]
  (console.log response))

; wisp port of http://davidwalsh.name/javascript-debounce-function
(defn debounce
  ([wait func] (debounce wait false func))
  ([wait immediate func]
    (let [timeout nil] (fn []
      (let [context  this
            args     arguments
            later    (fn []
                       (set! timeout nil)
                       (if (not immediate) (func.apply context args)))
            call-now (and immediate (not timeout))]
        (clearTimeout timeout)
        (set! timeout (setTimeout later wait))
        (if call-now (func.apply context args)))))))

(set! module.exports init-search-box)

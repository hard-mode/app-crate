(ns crate.search-box
  (:require [wisp.runtime :refer [not and]]))

; wisp port of http://davidwalsh.name/javascript-debounce-function
(defn debounce [func wait immediate]
  (let [timeout nil] (fn []
    (let [context  this
          args     arguments
          later    (fn []
                     (set! timeout nil)
                     (if (not immediate) (func.apply context args)))
          call-now (and immediate (not timeout))]
      (clearTimeout timeout)
      (set! timeout (setTimeout later wait))
      (if call-now (func.apply context args))))))

(defn init-search-box [container widget-opts]
  (let [id (:id widget-opts)
        el (document.getElementById id)]
    (console.log el)
    (el.addEventListener "keypress"
      (debounce (fn [evt] (console.log el.value)) 250))))

(set! module.exports init-search-box)

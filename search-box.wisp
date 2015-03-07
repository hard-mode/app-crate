(ns crate.search-box
  (:require
    [client                       :refer [init-widget!]]
    [wisp.runtime                 :refer [not and]]
    [wisp.sequence                :refer [map assoc]]
    [node-microajax               :as     microajax]
    [virtual-dom.h                :as     $]))

(defn init! [widget-opts]
  (init-widget! widget-opts)
  (.addEventListener (:element widget-opts) "keypress"
    (debounce 250 send-search-query!))
  widget-opts)

(defn template [context]
  ($ "input" { :type "text" :id context.id }))

(defn send-search-query! [evt]
  (let [query (encodeURI this.value)]
    (microajax (str "/search?q=" query) (fn [response]
      (show-search-results! (JSON.parse response.response))))))

(defn show-search-results! [search-results]
  (let [result-widget  (aget window.HARDMODE.widgets "results")]
    (result-widget.value.set search-results)))

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

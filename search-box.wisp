(ns crate.search-box
  (:require
    [hardmode-ui-hypertext.widgets.input.client :as input]
    [client               :refer [init-widget!]]
    [wisp.runtime         :refer [not and]]
    [wisp.sequence        :refer [map assoc]]
    [node-microajax       :as     microajax]
    [virtual-dom.h        :as     $]))

(defn template [widget]
  (let [on-input (fn [evt] (send-search-query! evt.target.value))
        props    { :type     "text"
                   :id       widget.id
                   :ev-input on-input }]
    ($ "input" props)))

(defn send-search-query! [query]
  (microajax (str "/search?q=" (encodeURI query)) (fn [response]
    (show-search-results! (JSON.parse response.response)))))

(defn show-search-results! [search-results]
  (let [result-widget (aget window.HARDMODE.widgets "results")]
    (result-widget.state.set { :value search-results })))

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

(ns crate.search-box
  (:require
    [hardmode-ui-hypertext.client :refer [init-widget!]]
    [wisp.runtime                 :refer [not and]]
    [wisp.sequence                :refer [map]]
    [node-microajax               :as     microajax]))

(defn init-search-box [widget-opts]
  (init-widget! widget-opts (fn [element]
    (document.body.appendChild element)
    (.addEventListener (aget element.childNodes 0) "keypress"
      (debounce 250 send-search-query)))))

(set! module.exports init-search-box)

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

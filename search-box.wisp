(ns crate.search-box
  (:require
    [client                       :refer [init-widget!]]
    [wisp.runtime                 :refer [not and]]
    [wisp.sequence                :refer [map assoc]]
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
  (let [result-widget  (aget window.HARDMODE.widgets "results")
        template       (require result-widget.template)
        search-results (JSON.parse response.response)
        element        result-widget.container
        parent         result-widget.container.parentElement]
    (set! result-widget.values search-results)
    (template result-widget (fn [err html]
      (if err (throw err))
      (let [new-element (document.createElement "div")]
        (set! new-element.id          (:id result-widget))
        (set! new-element.innerHTML   html)
        (set! result-widget.container new-element)
        (parent.replaceChild new-element element))))))

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

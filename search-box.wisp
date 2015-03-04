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
  (let [result-widget  (aget window.HARDMODE.widgets "results")
        template       (require result-widget.template)
        element        result-widget.container
        parent         result-widget.container.parentElement]
    (set! result-widget.values search-results)
    (template result-widget (fn [err html]
      (if err (throw err))
      (let [new-element (document.createElement "div")]
        (set! new-element.id          (:id result-widget))
        (set! new-element.innerHTML   html)
        (set! result-widget.container new-element)
        (bind-search-result-events!   new-element)
        (parent.replaceChild          new-element element))))))

(defn bind-search-result-events! [element]
  (let [class-name  "search-result-key-analyze"
        slice       Array.prototype.slice
        links       (element.getElementsByClassName class-name)
        bind-event  (fn [node] (node.addEventListener "click"
                      (fn [evt] (evt.preventDefault)
                                (console.log this.dataset.id))))]
    (map bind-event (slice.call links))))

(defn request-key-analysis [id])

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

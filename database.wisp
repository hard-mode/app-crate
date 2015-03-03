(ns crate.database
  (:require
    [fs]
    [hardmode-ui-hypertext.routing :refer [route add-route]]
    [mongoose]
    [musicmetadata]
    [path]
    [send-data.json                :as     send-json]
    [url]
    [wisp.runtime                  :refer [= not]]
    [wisp.sequence                 :refer [map]]
    [wrench]))


;; database models

(def ^:private Schema   mongoose.Schema)
(def ^:private ObjectId Schema.ObjectId)

(def Track (mongoose.model "Track" (Schema.
  { :path   String
    :title  String
    :artist ObjectId
    :album  String
    :year   String
    :length Number
    :bpm    Number })))

(def Artist (mongoose.model "Artist" (Schema.
  { :name  String })))

(def Cue (mongoose.model "Cue" (Schema.
  { :track ObjectId
    :start Number
    :end   Number })))


;; collection operations

(defn connect! [db-port]
  (console.log "Connecting to MongoDB on" db-port)
  (mongoose.connect (str "mongodb://localhost:" db-port)))

(defn scan-directory! [directory]
  (wrench.readdirRecursive directory (fn [err files]
    (if err (throw err))
    (map read-file
      (map (fn [file] (path.resolve (path.join directory file))) files)))))

(defn read-file! [filename]
  (process.nextTick (fn []
    (Track.find { :path filename } (fn [err tracks]
      (if err (throw err))
      (if (not tracks.length) (scan-file filename)))))))

(defn scan-file! [filename]
  (if (= (path.extname filename) ".mp3")
    (try
      (let [stream  (fs.createReadStream filename)
            write   (fn [err track]
                      (if err (throw err)
                      (.save (Track. { :path   filename 
                                       :title  track.title
                                       :album  track.album
                                       :year   track.year
                                       :length track.duration }))))]
        (musicmetadata stream { :duration true } write))
      (catch error (console.log "Scanning error" filename error)))))


;; search operations

(defn find-in-collection [search-term callback]
  (Track.find { :title (RegExp. search-term "i") } (fn [err results]
    (console.log "Found" results.length "results for" search-term)
    (callback err results))))

(defn serve-search-results [request response]
  (let [parsed-url    (url.parse request.url true)
        search-term   parsed-url.query.q]
    (console.log "Searching for" search-term "...")
    (find-in-collection search-term (fn [err results]
      (if err (throw err))
      (send-json request response results)))))

(defn route-search [pattern]
  (fn [context]
    (add-route context
      (route pattern serve-search-results))))

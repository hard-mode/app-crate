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

(defn init-collection! [db-port directory]
  (mongoose.connect (str "mongodb://localhost:" db-port))
  (wrench.readdirRecursive directory (fn [err files]
    (if err (throw err))
    (map read-file
      (map (fn [file] (path.resolve (path.join directory file))) files)))))

(defn read-file [filename]
  (Track.find { :path filename } (fn [err tracks]
    (if err (throw err))
    (if tracks.length
      (console.log "found" tracks)
      (scan-file filename)))))

(defn scan-file [filename]
  (if (= (path.extname filename) ".mp3")
    (try (musicmetadata stream { :duration true } write)
      (let [stream  (fs.createReadStream filename)
            write   (fn [err track]
                      (if err (throw err)
                      (.save (Track. { :path   filename 
                                       :title  track.title
                                       :album  track.album
                                       :year   track.year
                                       :length track.duration })
                        (fn [err saved] (if err (throw err))
                                        (console.log "saved" saved) ))))]
        (console.log "scanning" filename))
        (catch error (console.log "Scanning error" filename error)))))


;; search operations

(defn find-in-collection [search-term]
  (console.log "Searching for" search-term "...")
  (collection.filter (fn [item]
    (not (= (item.indexOf search-term) -1)))))

(defn serve-search-results [request response]
  (let [parsed-url    (url.parse request.url true)
        search-term   parsed-url.query.q
        response-data (find-in-collection search-term)]
    (send-json request response response-data)))

(defn route-search [pattern]
  (fn [context]
    (add-route context
      (route pattern serve-search-results))))

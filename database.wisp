(ns crate.database
  (:require
    [fs]
    [hardmode-ui-hypertext.routing :refer [route add-route]]
    [mongoose]
    [musicmetadata]
    [path]
    [send-data.json                :as     send-json]
    [url]
    [wisp.runtime                  :refer [= not > <]]
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
    :bpm    Number
    :key    String })))

(def Artist (mongoose.model "Artist" (Schema.
  { :name  String })))

(def Cue (mongoose.model "Cue" (Schema.
  { :track ObjectId
    :start Number
    :end   Number })))


;; scanning

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

(defn scan-track! [filename]
  (if (= (path.extname filename) ".mp3")
    (try
      (let [stream      (fs.createReadStream filename)
            set-artist! (fn [err track] (if err (throw err))
                          (Artist.find { :name track.artist } (fn [err artists]
                            (if artists.length
                              (save-track! (aget artists 0))
                              (let [artist (Artist. { :name track.artist })]
                                (artist.save (fn [err] (if err (throw err))
                                  (save-track! track artist))))))))
            save-track! (fn [track artist]
                          (.save (Track. 
                            { :path   filename 
                              :title  track.title
                              :artist artist
                              :album  track.album
                              :year   track.year
                              :length track.duration })))]
        
        (musicmetadata stream { :duration true } set-artist!))
      (catch error (console.log "Scanning error" filename error)))))

(defn add-artist! [artist-name]
  (.save (Artist. { :name artist-name })))


;; analysis

(defn route-analyze-key [pattern] (fn [context] context))

(defn route-analyze-bpm [pattern] (fn [context] context))


;; retrieval

(defn sorted-results [results field]
  (results.sort (fn [a b]
    (let [a (aget a field)
          b (aget b field)]
      (if (< a b) -1
        (if (> a b) 1
          0))))))

(defn find-in-collection [search-term callback]
  (Track.find { :title (RegExp. search-term "i") } (fn [err results]
    (console.log "Found" results.length "results for" search-term)
    (callback err (sorted-results results :title)))))


(defn serve-search-results [request response]
  (let [parsed-url    (url.parse request.url true)
        search-term   parsed-url.query.q]
    (console.log "Searching for" search-term "...")
    (find-in-collection search-term (fn [err results]
      (if err (throw err))
      (send-json request response results)))))

(defn route-analyze-key [pattern] (fn [context] context))

(defn route-analyze-bpm [pattern] (fn [context] context))

(defn route-search [pattern]
  (fn [context]
    (add-route context
      (route pattern serve-search-results))))

(ns crate.start-db
  (:require [forever-monitor]
            [freeport]
            [fs]
            [path]))

(defn start [data-path callback]
  (freeport (fn [err port]
    (if err
      (callback err null)
      (do
        (console.log "Starting MongoDB on port" port)
        (let [pidfile (path.join data-path "mongod.pid")
              cmdline ["mongod" "--dbpath"      data-path
                                "--port"        port
                                "--pidfilepath" pidfile]
              options { :silent  false
                        :pidFile pidfile}
              server  (forever-monitor.start cmdline options)]
          (callback null port)))))))

(set! module.exports start)

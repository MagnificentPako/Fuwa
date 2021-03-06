(import os)
(import json)
(import http)
(import ccemux)
(import socket)
(import eventually)
(import lua/coroutine coroutine)

(define websocket-url
    "The Discord WS url"
    :hidden
    "wss://gateway.discord.gg/?v=5&encoding=json")

(define rest-url
    "The Discord REST url"
    :hidden
    "https://discordapp.com/api/")

(defun send-heartbeat (client)
    "Sends a heartbeat to the client"
    :hidden
    (print! "SENDING HEARTBEAT")
    (socket/write (.> client :socket) (json/stringify {
        :op 1
        :d (.> client :seq)
    })))

(defun build-headers (is-self token)
    "Returns the needed HTTP headers with the given token"
    :hidden
    {
        :User-Agent "Fuwa (https://github.com/MagnificentPako/Fuwa, 1)"
        :Authorization (.. (if is-self "" "Bot ") token)
    })

(defun post-request (client endpoint data)
    "Send a POST request to the designated endpoint"
    :hidden
    (.> (http/post (.. rest-url endpoint) (json/stringify data) (build-headers (.> client :is-self) (.> client :token))) :readAll) )

(defun send-message (client channel-id msg)
    "Sends a message to a channel"
    (post-request client (.. "channels/" channel-id "/messages") msg))

(defun add-handler (client evt handler)
    "Allows users to add custom event handlers"
    (eventually/add (.> client :event-handler) evt handler))

(defun create (token is-self) 
    "Create a new Discord client"
    {
        :event-handler (eventually/new-handler)
        :socket nil
        :token token
        :is-self is-self
        :self nil
        :last-time (ccemux/milliTime)
        :heartbeat-interval -1
        :seq -1
    })

(defun run (client)
    "Starts the main loop"
    (.<! client :socket (socket/websocket websocket-url))
    ; Consumes HELLO
    (with (sock (.> client :socket))
        (with (hello (json/parse (socket/read-sync sock)))
            (.<! client :heartbeat-interval (.> hello :d :heartbeat_interval)))
        (socket/write sock (json/stringify {
            :op 2
            :d {
                :token (.> client :token)
                :properties {
                    :$os "linux"
                    :$browser "Fuwa"
                    :$device "Fuwa"
                    :$referrer ""
                    :$referring_domain ""
                }
                :compress false
                :large_threshold 250
            }   
        }))
        (with (ready (json/parse (socket/read-sync sock)))
            (.<! client :seq (.> ready :s))
            (.<! client :self (.> ready :d :user))
            (eventually/dispatch (.> client :event-handler) (list "READY" (.> ready :d))))
        (while true
            (unless (>= (+ (.> client :last-time ) (.> client :heartbeat-interval)) (ccemux/milliTime))
                (.<! client :last-time (ccemux/milliTime))
                (send-heartbeat client))
            (with [r (socket/read sock)]
                (os/queueEvent "derp")
                (coroutine/yield "derp")
                (unless (or (= r nil) (= (len# r) 0))
                    (let* [(parsed  (json/parse r))
                        (type    (.> parsed :t))
                        (payload (.> parsed :d))
                        (seq     (.> parsed :s))]
                        (.<! client :seq seq)
                        (eventually/dispatch (.> client :event-handler) (list type payload))))))))
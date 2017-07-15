(import socket)
(import eventually)
(import json)

(define websocket-url
    "The Discord WS url"
    :hidden
    "wss://gateway.discord.gg/?v=5&encoding=json")

(define event-handler 
    "The internal event handler used for discord stuff"
    :hidden
    (eventually/new-handler))

(define sock
    "Websocket connection to discord API"
    (socket/websocket websocket-url))

(defun add-handler (evt handler)
    "Allows users to add custom event handlers"
    (eventually/add event-handler evt handler))

(defun login (token) 
    "Log in to the websocket part of the discord API"
    ; Consumes HELLO
    (socket/read-sync sock)
    (socket/write sock (json/stringify {
     :op 2
     :d {
        :token token
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
    (with [ready (socket/read-sync sock)]
        (eventually/dispatch event-handler (list "ready" (.> (json/parse ready) :d))))
    (socket/close sock))


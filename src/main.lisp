(import discord)
(import lua/io io)

(let [(token nil)]
    (with [handle (io/open "token.txt" "r")]
        (set! token (self handle :read "*a"))
        (io/close handle))

    (print! token)

    (discord/add-handler "ready" (lambda (ready)
        (print! (.. "logged in as " (.> ready :user :username) "."))))

    (discord/login token))
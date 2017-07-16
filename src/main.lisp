(import discord)
(import lua/io io)

(let [(token nil)]
    (with [handle (io/open "token.txt" "r")]
        (set! token (self handle :read "*a"))
        (io/close handle))

    (with (client (discord/create token false))

        (discord/add-handler client "READY" (lambda (ready)
        (print! (.. "logged in as " (.> ready :user :username) "."))))

        (discord/add-handler client "MESSAGE_CREATE" (lambda (msg)
            (unless (= (.> msg :author :id) (.> client :self :id))
                (discord/send-message client (.> msg :channel_id) { :content "test" }))))

        (discord/run client)))
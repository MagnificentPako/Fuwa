(import lua/coroutine coroutine)

(define-native connect)
(define-native websocket)

(defun check-connected (sock)
    ((.> sock :checkConnected)))

(defun write (sock dat)
    ((.> sock :write) dat))

(defun read (sock)
    ((.> sock :read)))

(defun read-sync (sock)
    (with (r nil) (while (or (= r nil) (= (len# r) 0)) (coroutine/yield) (set! r (read sock))) r))

(defun read-specific (sock size)
    ((.> sock :read) size))

(defun close (sock)
    ((.> sock :close)))
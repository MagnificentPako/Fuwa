(defun new-handler ()
    "Return a new handler, basically an empty list"
    '())

(defun dispatch (handler evt)
    "Dispatch some event"
    (for-each callback
        ; All handlers fitting the event
        (filter (lambda (x) (= (car x) (car evt))) handler)
        ; Call their callbacks, passing them the event
        (apply (car (cdr callback)) (cdr evt))))

(defun add (handler evt fun)
    "Add a callback to a handler"
    (push-cdr! handler [list evt fun]))
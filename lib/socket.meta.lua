local socket = socket or {}

return {
	["connect"] =   { tag = "var", contents = "socket.connect",   value = socket.connect,   pure = true, },
	["websocket"] = { tag = "var", contents = "socket.websocket", value = socket.websocket, pure = true, }
}
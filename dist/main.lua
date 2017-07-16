if not table.pack then table.pack = function(...) return { n = select("#", ...), ... } end end
if not table.unpack then table.unpack = unpack end
local load = load if _VERSION:find("5.1") then load = function(x, n, _, env) local f, e = loadstring(x, n) if not f then return f, e end if env then setfenv(f, env) end return f end end
local _select, _unpack, _pack, _error = select, table.unpack, table.pack, error
local _libs = {}
local _temp = (function()
	local json = {}
	local function kind_of(obj)
	  if type(obj) ~= 'table' then return type(obj) end
	  local i = 1
	  for _ in pairs(obj) do
	    if obj[i] ~= nil then i = i + 1 else return 'table' end
	  end
	  if i == 1 then return 'table' else return 'array' end
	end
	local function escape_str(s)
	  local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
	  local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
	  for i, c in ipairs(in_char) do
	    s = s:gsub(c, '\\' .. out_char[i])
	  end
	  return s
	end
	local function skip_delim(str, pos, delim, err_if_missing)
	  pos = pos + #str:match('^%s*', pos)
	  if str:sub(pos, pos) ~= delim then
	    if err_if_missing then
	      error('Expected ' .. delim .. ' near position ' .. pos)
	    end
	    return pos, false
	  end
	  return pos + 1, true
	end
	local function parse_str_val(str, pos, val)
	  val = val or ''
	  local early_end_error = 'End of input found while parsing string.'
	  if pos > #str then error(early_end_error) end
	  local c = str:sub(pos, pos)
	  if c == '"'  then return val, pos + 1 end
	  if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
	  local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
	  local nextc = str:sub(pos + 1, pos + 1)
	  if not nextc then error(early_end_error) end
	  return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
	end
	local function parse_num_val(str, pos)
	  local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
	  local val = tonumber(num_str)
	  if not val then error('Error parsing number at position ' .. pos .. '.') end
	  return val, pos + #num_str
	end
	function json.stringify(obj, as_key)
	  local s = {}  
	  local kind = kind_of(obj)  
	  if kind == 'array' then
	    if as_key then error('Can\'t encode array as key.') end
	    s[#s + 1] = '['
	    for i, val in ipairs(obj) do
	      if i > 1 then s[#s + 1] = ', ' end
	      s[#s + 1] = json.stringify(val)
	    end
	    s[#s + 1] = ']'
	  elseif kind == 'table' then
	    if as_key then error('Can\'t encode table as key.') end
	    if(obj.tag == "list") then obj.tag = nil obj.n = nil end
	    s[#s + 1] = '{'
	    for k, v in pairs(obj) do
	      if #s > 1 then s[#s + 1] = ', ' end
	      s[#s + 1] = json.stringify(k, true)
	      s[#s + 1] = ':'
	      s[#s + 1] = json.stringify(v)
	    end
	    s[#s + 1] = '}'
	  elseif kind == 'string' then
	    return '"' .. escape_str(obj) .. '"'
	  elseif kind == 'number' then
	    if as_key then return '"' .. tostring(obj) .. '"' end
	    return tostring(obj)
	  elseif kind == 'boolean' then
	    return tostring(obj)
	  elseif kind == 'nil' then
	    return 'null'
	  else
	    error('Unjsonifiable type: ' .. kind .. '.')
	  end
	  return table.concat(s)
	end
	json.null = {}  
	function json.parse(str, pos, end_delim)
	  pos = pos or 1
	  if pos > #str then error('Reached unexpected end of input.') end
	  local pos = pos + #str:match('^%s*', pos)  
	  local first = str:sub(pos, pos)
	  if first == '{' then 
	    local obj, key, delim_found = {}, true, true
	    pos = pos + 1
	    while true do
	      key, pos = json.parse(str, pos, '}')
	      if key == nil then return obj, pos end
	      if not delim_found then error('Comma missing between object items.') end
	      pos = skip_delim(str, pos, ':', true)  
	      obj[key], pos = json.parse(str, pos)
	      pos, delim_found = skip_delim(str, pos, ',')
	    end
	  elseif first == '[' then 
	    local arr, val, delim_found = {}, true, true
	    pos = pos + 1
	    while true do
	      val, pos = json.parse(str, pos, ']')
	      if val == nil then return arr, pos end
	      if not delim_found then error('Comma missing between array items.') end
	      arr[#arr + 1] = val
	      pos, delim_found = skip_delim(str, pos, ',')
	    end
	  elseif first == '"' then  
	    return parse_str_val(str, pos + 1)
	  elseif first == '-' or first:match('%d') then 
	    return parse_num_val(str, pos)
	  elseif first == end_delim then 
	    return nil, pos + 1
	  else 
	    local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
	    for lit_str, lit_val in pairs(literals) do
	      local lit_end = pos + #lit_str - 1
	      if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
	    end
	    local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
	    error('Invalid json syntax starting at ' .. pos_info_str)
	  end
	end
	return json
end)()
for k, v in pairs(_temp) do _libs["json-18/".. k] = v end
local _3d_1, _2f3d_1, _3c_1, _3c3d_1, _3e3d_1, _2b_1, _2d_1, _2e2e_1, len_23_1, error1, print1, getIdx1, setIdx_21_1, type_23_1, n1, slice1, format1, unpack1, car1, cdr1, list1, apply1, empty_3f_1, type1, car2, cdr2, filter1, nth1, pushCdr_21_1, close1, open1, self1, queueEvent1, parse1, stringify1, post1, milliTime1, yield1, websocket1, write1, read1, readSync1, newHandler1, dispatch1, add1, sendHeartbeat1, buildHeaders1, postRequest1, sendMessage1, addHandler1, create1, run1
_3d_1 = function(v1, v2) return v1 == v2 end
_2f3d_1 = function(v1, v2) return v1 ~= v2 end
_3c_1 = function(v1, v2) return v1 < v2 end
_3c3d_1 = function(v1, v2) return v1 <= v2 end
_3e3d_1 = function(v1, v2) return v1 >= v2 end
_2b_1 = function(...) local t = ... for i = 2, _select('#', ...) do t = t + _select(i, ...) end return t end
_2d_1 = function(...) local t = ... for i = 2, _select('#', ...) do t = t - _select(i, ...) end return t end
_2e2e_1 = function(...) local n = _select('#', ...) local t = _select(n, ...) for i = n - 1, 1, -1 do t = _select(i, ...) .. t end return t end
len_23_1 = function(v1) return #v1 end
error1 = error
print1 = print
getIdx1 = function(v1, v2) return v1[v2] end
setIdx_21_1 = function(v1, v2, v3) v1[v2] = v3 end
type_23_1 = type
n1 = (function(x)
	if type_23_1(x) == "table" then
		return x["n"]
	else
		return #x
	end
end)
slice1 = (function(xs, start, finish)
	if not finish then
		finish = xs["n"]
		if not finish then
			finish = #xs
		end
	end
	local len = (finish - start) + 1
	if len < 0 then
		len = 0
	end
	local out, i, j = ({["tag"]="list",["n"]=len}), 1, start
	while j <= finish do
		out[i] = xs[j]
		i, j = i + 1, j + 1
	end
	return out
end)
format1 = string.format
unpack1 = table.unpack
car1 = (function(xs)
	return xs[1]
end)
cdr1 = (function(xs)
	return slice1(xs, 2)
end)
list1 = (function(...)
	local xs = _pack(...) xs.tag = "list"
	return xs
end)
apply1 = (function(f, xs)
	return f(unpack1(xs, 1, n1(xs)))
end)
empty_3f_1 = (function(x)
	local xt = type1(x)
	if xt == "list" then
		return n1(x) == 0
	elseif xt == "string" then
		return #x == 0
	else
		return false
	end
end)
type1 = (function(val)
	local ty = type_23_1(val)
	if ty == "table" then
		return val["tag"] or "table"
	else
		return ty
	end
end)
car2 = (function(x)
	local temp = type1(x)
	if temp ~= "list" then
		error1(format1("bad argument %s (expected %s, got %s)", "x", "list", temp), 2)
	end
	return car1(x)
end)
cdr2 = (function(x)
	local temp = type1(x)
	if temp ~= "list" then
		error1(format1("bad argument %s (expected %s, got %s)", "x", "list", temp), 2)
	end
	if empty_3f_1(x) then
		return ({tag = "list", n = 0})
	else
		return cdr1(x)
	end
end)
filter1 = (function(p, xs)
	local temp = type1(p)
	if temp ~= "function" then
		error1(format1("bad argument %s (expected %s, got %s)", "p", "function", temp), 2)
	end
	local temp = type1(xs)
	if temp ~= "list" then
		error1(format1("bad argument %s (expected %s, got %s)", "xs", "list", temp), 2)
	end
	local out = ({tag = "list", n = 0})
	local temp = n1(xs)
	local temp1 = 1
	while temp1 <= temp do
		local x = nth1(xs, temp1)
		if p(x) then
			pushCdr_21_1(out, x)
		end
		temp1 = temp1 + 1
	end
	return out
end)
nth1 = (function(xs, idx)
	if idx >= 0 then
		return xs[idx]
	else
		return xs[xs["n"] + 1 + idx]
	end
end)
pushCdr_21_1 = (function(xs, val)
	local temp = type1(xs)
	if temp ~= "list" then
		error1(format1("bad argument %s (expected %s, got %s)", "xs", "list", temp), 2)
	end
	local len = n1(xs) + 1
	xs["n"] = len
	xs[len] = val
	return xs
end)
close1 = io.close
open1 = io.open
self1 = (function(x, key, ...)
	local args = _pack(...) args.tag = "list"
	return x[key](x, unpack1(args, 1, n1(args)))
end)
queueEvent1 = os.queueEvent
parse1 = _libs["json-18/parse"]
stringify1 = _libs["json-18/stringify"]
post1 = http.post
milliTime1 = ccemux.milliTime
yield1 = coroutine.yield
websocket1 = socket.websocket
write1 = (function(sock, dat)
	return sock["write"](dat)
end)
read1 = (function(sock)
	return sock["read"]()
end)
readSync1 = (function(sock)
	local r = nil
	while r == nil or #r == 0 do
		yield1()
		r = read1(sock)
	end
	return r
end)
newHandler1 = (function()
	return ({tag = "list", n = 0})
end)
dispatch1 = (function(handler, evt)
	local temp = filter1((function(x)
		return car2(x) == car2(evt)
	end), handler)
	local temp1 = n1(temp)
	local temp2 = 1
	while temp2 <= temp1 do
		apply1(car2(cdr2((temp[temp2]))), cdr2(evt))
		temp2 = temp2 + 1
	end
	return nil
end)
add1 = (function(handler, evt, fun)
	return pushCdr_21_1(handler, list1(evt, fun))
end)
sendHeartbeat1 = (function(client)
	print1("SENDING HEARTBEAT")
	return write1(client["socket"], stringify1(({["op"]=1,["d"]=client["seq"]})))
end)
buildHeaders1 = (function(isSelf, token)
	return ({["User-Agent"]="Fuwa (https://github.com/MagnificentPako/Fuwa, 1)",["Authorization"]=(function()
		if isSelf then
			return ""
		else
			return "Bot "
		end
	end)() .. token})
end)
postRequest1 = (function(client, endpoint, data)
	return post1("https://discordapp.com/api/" .. endpoint, stringify1(data), buildHeaders1(client["is-self"], client["token"]))["readAll"]
end)
sendMessage1 = (function(client, channelId, msg)
	return postRequest1(client, "channels/" .. channelId .. "/messages", msg)
end)
addHandler1 = (function(client, evt, handler)
	return add1(client["event-handler"], evt, handler)
end)
create1 = (function(token, isSelf)
	return ({["event-handler"]=newHandler1(),["socket"]=nil,["token"]=token,["is-self"]=isSelf,["self"]=nil,["last-time"]=milliTime1(),["heartbeat-interval"]=-1,["seq"]=-1})
end)
run1 = (function(client)
	client["socket"] = websocket1("wss://gateway.discord.gg/?v=5&encoding=json")
	local sock = client["socket"]
	client["heartbeat-interval"] = parse1(readSync1(sock))["d"]["heartbeat_interval"]
	write1(sock, stringify1(({["op"]=2,["d"]=({["token"]=client["token"],["properties"]=({["$os"]="linux",["$browser"]="Fuwa",["$device"]="Fuwa",["$referrer"]="",["$referring_domain"]=""}),["compress"]=false,["large_threshold"]=250})})))
	local ready = parse1(readSync1(sock))
	client["seq"] = ready["s"]
	client["self"] = ready["d"]["user"]
	dispatch1(client["event-handler"], list1("READY", ready["d"]))
	while true do
		if not (client["last-time"] + client["heartbeat-interval"] >= milliTime1()) then
			client["last-time"] = milliTime1()
			sendHeartbeat1(client)
		end
		local r = read1(sock)
		queueEvent1("derp")
		yield1("derp")
		if not (r == nil or #r == 0) then
			local parsed = parse1(r)
			local type, payload, seq = parsed["t"], parsed["d"], parsed["s"]
			client["seq"] = seq
			dispatch1(client["event-handler"], list1(type, payload))
		end
	end
end)
local token = nil
local handle = open1("token.txt", "r")
token = self1(handle, "read", "*a")
close1(handle)
local client = create1(token, false)
addHandler1(client, "READY", (function(ready)
	return print1("logged in as " .. ready["user"]["username"] .. ".")
end))
addHandler1(client, "MESSAGE_CREATE", (function(msg)
	if (msg["author"]["id"] == client["self"]["id"]) then
		return nil
	else
		return sendMessage1(client, msg["channel_id"], ({["content"]="test"}))
	end
end))
return run1(client)

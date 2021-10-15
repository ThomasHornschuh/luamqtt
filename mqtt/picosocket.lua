dbg = require "debugger"

-- module table
local picosocket = {}

local net = net

-- Open network connection to .host and .port in conn table
-- Store opened socket to conn table
-- Returns true on success, or false and error text on failure
function picosocket.connect(conn)
    --dbg()
    local s = net.socket(net.SOCK_STREAM)
    local ip = net.lookup(conn.host)
	print("IP Address:", net.unpackip(ip,"*s"))
	err = s:connect(ip, conn.port)
	if err ~=net.ERR_OK then
		return false, "socket.connect failed: "..tostring(err)
	end
	print("connected:",s )
	conn.sock = s
	return true
end

-- Shutdown network connection
function picosocket.shutdown(conn)
	conn.sock:close()
end

-- Send data to network connection
function picosocket.send(conn, data, i, j)

	local res, err = conn.sock:send(data)
	return err==net.ERR_OK and res, tostring(err)
end

-- Receive given amount of data from network connection
function picosocket.receive(conn, size)
	
	local r,err, closed = "", -1, false 
	
	r,err = conn.sock:recv(size,nil,5*10^6,0)
	print(("receive: %d %d"):format(#r,err)) 	
    print("luasocket.receive:", size, require("mqtt.tools").hex(r))
	return r,err
end

-- Set connection's socket to non-blocking mode and set a timeout for it
function picosocket.settimeout(conn, timeout)
	print(("Timeout %d"):format(timeout))
	conn.timeout = timeout
	--conn.sock:settimeout(timeout, "t")
end

-- export module table
return picosocket

-- vim: ts=4 sts=4 sw=4 noet ft=lua

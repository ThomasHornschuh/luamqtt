
local dbg = package.loaded.debugger or function() end 

dbg()

-- Overide print to supress debug output
local print = function() end 

-- module table
local picosocket = {}

local net = net


-- Open network connection to .host and .port in conn table
-- Store opened socket to conn table
-- Returns true on success, or false and error text on failure
function picosocket.connect(conn)


    local s = net.socket(net.SOCK_STREAM)
    pcall(function() ip = net.packip(s)  end)
    if not ip then
       ip = net.lookup(conn.host)
    end
    if not ip then
        print("Host could not be resolved")
        return false
    end    
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
    pcall(function() conn.sock:close() end)
end

-- Send data to network connection
function picosocket.send(conn, data, i, j)

    local res, err = conn.sock:send(data)
    return err==net.ERR_OK and res, tostring(err)
end

-- Receive given amount of data from network connection
function picosocket.receive(conn, size)

    local r,err, closed = nil, -1, false

    xpcall(function()
             r,err = conn.sock:recv(size,nil,conn.timeout*10^6,0)
           end,
           function(error)
              --dbg()
              print("socket error: ",error)
              err = "closed"
              r = nil
           end)
    if type(err) == "string" then
        r = nil
    elseif err==net.ERR_TIMEOUT then
        err="timeout"
        r = nil
    elseif err==net.ERR_OK then
        err="ok"
    else
        err ="error " .. tostring(err)
        r = nil
    end
    if r then
       print("luasocket.receive:", size, require("mqtt.tools").hex(r))
    else
       --print(err)
    end
    --dbg()
    return r,err
end

-- Set connection's socket to non-blocking mode and set a timeout for it
function picosocket.settimeout(conn, timeout)
    print(("Timeout %d"):format(timeout))
    conn.timeout = timeout
    --conn.sock:settimeout(timeout, "t")
end

local function sleep_function(seconds)
 
   local t = tmr.read()
   local delay = seconds * 10^6
   while (tmr.getdiffnow(nil,t)<seconds) do
      net.tick()
   end
end      



local mqtt = require ("mqtt.init")
local io_loop = mqtt.get_ioloop(nil,{sleep_function=sleep_function,tick_function=net.tick})




-- export module table
return picosocket

-- vim: ts=4 sts=4 sw=4 noet ft=lua

-- Init mqtt ioloop



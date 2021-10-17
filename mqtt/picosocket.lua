dbg = require "debugger"

-- module table
local picosocket = {}

local net = net

local function check_ip(s) 
    local ip     
    pcall(function()
              ip = net.packip(s)              
           end
    )
    return ip
end     


-- Open network connection to .host and .port in conn table
-- Store opened socket to conn table
-- Returns true on success, or false and error text on failure
function picosocket.connect(conn)    
    local s = net.socket(net.SOCK_STREAM)
    dbg()   
    local ip = check_ip(conn.host)
    if not ip then
       ip = net.lookup(conn.host)
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

-- export module table
return picosocket

-- vim: ts=4 sts=4 sw=4 noet ft=lua
